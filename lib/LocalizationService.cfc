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

    public void function $loadTranslations() {
        // Always reload if cache is off
        if (!variables.config.cacheTranslations || structIsEmpty(variables.translations)) {
            variables.translations = {};

            if (variables.config.translationSource == "database") {
                $loadFromDatabase();
            } else {
                $loadFromJson();
            }
        }
    }

    // Load from JSON files
    private void function $loadFromJson() {
        local.locales = listToArray(variables.config.availableLocales);
        local.basePath = expandPath(variables.config.translationsPath);

        for (local.loc in locales) {
            variables.translations[loc] = {};

            local.localeDir = basePath & "/" & loc;
            if (directoryExists(localeDir)) {
                local.files = directoryList(localeDir, false, "name", "*.json");
                for (local.file in files) {
                    local.content = fileRead(localeDir & "/" & file, "utf-8");
                    try{
                        if (isJSON(content)) {
                            local.data = deserializeJSON(content);
                            local.namespace = listFirst(file, ".");
                            $flattenAndStore(loc, namespace, data);
                        }
                    } catch (any e) {
                        local.appKey = application.wo.$appKey();
                        if (structKeyExists(application[local.appKey], "logError")) {
                            application[local.appKey].logError("i18n plugin: Failed to parse JSON file #localeDir#/#file#: #e.message#");
                        }
                    }
                }
            }
        }
    }

    // Load from Database
    private void function $loadFromDatabase() {
        local.locales = listToArray(variables.config.availableLocales);

        // Generate parameter names :locale1,:locale2,:locale3
        local.namedParams = [];
        for (local.i = 1; i <= arrayLen(locales); i++) {
            arrayAppend(namedParams, ":locale#i#");
        }

        // Join placeholders for SQL
        local.placeholders = arrayToList(namedParams, ",");

        local.sql = "
            SELECT locale, translation_key, translation_value
            FROM i18n_translations
            WHERE locale IN (#placeholders#)
        ";

        // Build the param struct
        local.params = {};
        for (local.i = 1; i <= arrayLen(locales); i++) {
            params["locale#i#"] = {
                value = locales[i],
                cfsqltype = "cf_sql_varchar"
            };
        }

        try {
            local.appKey = application.wo.$appKey();
            local.q = queryExecute(
                sql,
                params,
                { datasource = application[local.appKey].dataSourceName }
            );

            for (local.row in q) {
                variables.translations[row.locale] = variables.translations[row.locale] ?: {};
                variables.translations[row.locale][row.translation_key] = row.translation_value;
            }
        } catch (any e) {
            local.isMissingTable = (
                FindNoCase("Table", e.message) && FindNoCase("i18n_translations", e.message)
                || FindNoCase("relation.*does not exist", e.message) // PG
                || FindNoCase("no such table", e.message) // SQLite
            );

            if (isMissingTable) {
                // Optional: log via Wheels logger if available
                local.appKey = application.wo.$appKey();
                if (structKeyExists(application[local.appKey], "logError")) {
                    application[local.appKey].logError("i18n plugin: Table 'i18n_translations' not found. Falling back to empty translations for DB source.");
                }
                // Ensure structure exists so app doesn't crash later
                variables.translations = variables.translations ?: {};
                return;
            }
        }
        
    }

    public string function $getTranslation(required string locale, required string key) {
        if (!variables.config.cacheTranslations) {
            $loadTranslations();
        }

        if (
            structKeyExists(variables.translations, arguments.locale) &&
            structKeyExists(variables.translations[arguments.locale], arguments.key)
        ) {
            return variables.translations[arguments.locale][arguments.key];
        }

        return "";
    }

    private void function $flattenAndStore(required string locale, required string prefix, required struct data) {
        for (local.key in data) {
            local.fullKey = prefix & "." & key;
            local.value = data[key];

            if (isStruct(value)) {
                $flattenAndStore(locale, fullKey, value);
            } else if (isSimpleValue(value)) {
                variables.translations[locale][fullKey] = value;
            }
        }
    }
}