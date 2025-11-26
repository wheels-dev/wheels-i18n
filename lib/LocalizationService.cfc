component output="false" {

    variables.translations = {};
    variables.config = {};

    public function init(
        required string translationsPath,
        required string availableLocales,
        required string defaultLocale,
        required string fallbackLocale,
        required boolean cacheTranslations
    ) {
        variables.config = arguments;
        return this;
    }

    /**
     * Scans the directories and loads JSON files into memory
     */
    public void function loadTranslations() {
        // If caching is on and we already have data, exit
        if (variables.config.cacheTranslations && !structIsEmpty(variables.translations)) {
            return;
        }

        // Reset translations
        variables.translations = {};
        
        var local = {};
        local.localesList = listToArray(variables.config.availableLocales);
        local.basePath = expandPath(variables.config.translationsPath);

        // Loop through defined locales (e.g., 'en', 'es')
        for (local.loc in local.localesList) {
            variables.translations[local.loc] = {};
            
            local.localeDir = local.basePath & "/" & local.loc;

            if (directoryExists(local.localeDir)) {
                // Find all .json files in this locale's folder
                local.files = directoryList(local.localeDir, false, "name", "*.json");

                for (local.file in local.files) {
                    local.fileContent = fileRead(local.localeDir & "/" & local.file, "utf-8");
                    
                    if (isJSON(local.fileContent)) {
                        local.jsonData = deserializeJSON(local.fileContent);
                        
                        // Get the namespace from filename (e.g., 'common.json' -> 'common')
                        local.namespace = listFirst(local.file, ".");
                        
                        // Flatten and store keys
                        flattenAndStore(local.loc, local.namespace, local.jsonData);
                    }
                }
            }
        }
    }

    /**
     * Retrieves a specific key for a specific locale
     */
    public string function getTranslation(required string locale, required string key) {
        // Reload if caching is disabled (for development)
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

    /**
     * Private helper: Recursive function to flatten JSON
     * Turns { "nav": { "home": "Home" } } into "nav.home" = "Home"
     */
    private void function flattenAndStore(
        required string locale, 
        required string prefix, 
        required struct data
    ) {
        for (var key in arguments.data) {
            var fullKey = arguments.prefix & "." & key;
            var value = arguments.data[key];

            if (isStruct(value)) {
                // Recurse deeper
                flattenAndStore(arguments.locale, fullKey, value);
            } else if (isSimpleValue(value)) {
                // Store value
                variables.translations[arguments.locale][fullKey] = value;
            }
        }
    }
}