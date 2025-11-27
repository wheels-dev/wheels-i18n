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

        var sql = "
            SELECT locale, translation_key, translation_value
            FROM i18n_translations
            WHERE locale IN (?)
        ";

        var q = queryExecute(
            sql,
            [locales],
            { datasource: application.$wheels.dataSourceName }
        );

        for (var row in q) {
            variables.translations[row.locale] = variables.translations[row.locale] ?: {};
            variables.translations[row.locale][row.translation_key] = row.translation_value;
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

    // Optional: Allow live updates from admin panel
    public void function setTranslation(required string locale, required string key, required string value) {
        variables.translations[locale] = variables.translations[locale] ?: {};
        variables.translations[locale][key] = value;

        queryExecute(
            "INSERT INTO i18n_translations (locale, translation_key, translation_value)
             VALUES (?, ?, ?)
             ON DUPLICATE KEY UPDATE translation_value = ?",
            [locale, key, value, value],
            { datasource: application.$wheels.dataSourceName }
        );
    }
}