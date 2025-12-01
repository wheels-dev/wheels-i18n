component output="false" {

    variables.translations = {};
    variables.config = {};

    public function init(
        required string translationsPath,
        required string availableLocales,
        required string defaultLocale,
        required string fallbackLocale,
        required boolean cacheTranslations,
        required string translationSource = "json"
    ) {
        variables.config = arguments;
        return this;
    }

    public void function loadTranslations() {
        // Always reload if cache is off
        if (!variables.config.cacheTranslations || structIsEmpty(variables.translations)) {
            variables.translations = {};

            if (variables.config.translationSource == "database") {
                loadFromDatabase();
            } else {
                loadFromJson();
            }
        }
    }

    // Load from JSON files (your original logic)
    private void function loadFromJson() {
        var locales = listToArray(variables.config.availableLocales);
        var basePath = expandPath(variables.config.translationsPath);

        for (var loc in locales) {
            variables.translations[loc] = {};

            var localeDir = basePath & "/" & loc;
            if (directoryExists(localeDir)) {
                var files = directoryList(localeDir, false, "name", "*.json");
                for (var file in files) {
                    var content = fileRead(localeDir & "/" & file, "utf-8");
                    if (isJSON(content)) {
                        var data = deserializeJSON(content);
                        var namespace = listFirst(file, ".");
                        flattenAndStore(loc, namespace, data);
                    }
                }
            }
        }
    }

    // Load from Database
    private void function loadFromDatabase() {
        var locales = listToArray(variables.config.availableLocales);

        // Generate parameter names :locale1,:locale2,:locale3
        var namedParams = [];
        for (var i = 1; i <= arrayLen(locales); i++) {
            arrayAppend(namedParams, ":locale#i#");
        }

        // Join placeholders for SQL
        var placeholders = arrayToList(namedParams, ",");

        var sql = "
            SELECT locale, translation_key, translation_value
            FROM i18n_translations
            WHERE locale IN (#placeholders#)
        ";

        // Build the param struct
        var params = {};
        for (var i = 1; i <= arrayLen(locales); i++) {
            params["locale#i#"] = {
                value = locales[i],
                cfsqltype = "cf_sql_varchar"
            };
        }

        try {
            local.appKey = application.wo.$appKey();
            var q = queryExecute(
                sql,
                params,
                { datasource = application[local.appKey].dataSourceName }
            );

            for (var row in q) {
                variables.translations[row.locale] = variables.translations[row.locale] ?: {};
                variables.translations[row.locale][row.translation_key] = row.translation_value;
            }
        } catch (any e) {
            var isMissingTable = (
                FindNoCase("Table", e.message) && FindNoCase("i18n_translations", e.message) && FindNoCase("doesn't exist", e.message)
                || FindNoCase("relation", e.message) && FindNoCase("does not exist", e.message) // PostgreSQL
                || FindNoCase("no such table", e.message) // SQLite
            );
        }
        
    }

    public string function getTranslation(required string locale, required string key) {
        if (!variables.config.cacheTranslations) {
            loadTranslations();
        }

        if (
            structKeyExists(variables.translations, arguments.locale) &&
            structKeyExists(variables.translations[arguments.locale], arguments.key)
        ) {
            return variables.translations[arguments.locale][arguments.key];
        }

        return "";
    }

    // Your original flatten helper
    private void function flattenAndStore(required string locale, required string prefix, required struct data) {
        for (var key in data) {
            var fullKey = prefix & "." & key;
            var value = data[key];

            if (isStruct(value)) {
                flattenAndStore(locale, fullKey, value);
            } else if (isSimpleValue(value)) {
                variables.translations[locale][fullKey] = value;
            }
        }
    }
}