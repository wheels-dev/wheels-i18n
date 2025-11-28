component hint="wheels-i18n" output="false" mixin="global" {

    public function init() {
        this.version = "3.0.0";

        // 1. Set default configuration settings
        setDefaultSettings();

        // 2. Load the localization service singleton
        loadService();
        return this;
    }

    private function setDefaultSettings() {
        // Correct way: Check if the key exists in the global Wheels application scope
        
        local.appKey = application.wo.$appKey();

        if (!structKeyExists(application[local.appKey], "i18n_defaultLocale")) {
            application.wo.set(i18n_defaultLocale="en");
        }
        if (!structKeyExists(application[local.appKey], "i18n_availableLocales")) {
            application.wo.set(i18n_availableLocales="en");
        }
        if (!structKeyExists(application[local.appKey], "i18n_fallbackLocale")) {
            application.wo.set(i18n_fallbackLocale="en");
        }
        if (!structKeyExists(application[local.appKey], "i18n_translationSource")) {
            application.wo.set(i18n_translationSource="json"); // json or database
        }
        if (!structKeyExists(application[local.appKey], "i18n_translationsPath")) {
            application.wo.set(i18n_translationsPath="/app/locales");
        }
        if (!structKeyExists(application[local.appKey], "i18n_cacheTranslations")) {
            application.wo.set(i18n_cacheTranslations=false);
        }
    }

    private function loadService() {

        local.appKey = application.wo.$appKey();
        // Initialize the service and store it in application scope
        application[local.appKey].i18n = createObject("component", "plugins.I18n.lib.LocalizationService").init(
            translationsPath    = application.wo.get("i18n_translationsPath"),
            availableLocales    = application.wo.get("i18n_availableLocales"),
            defaultLocale       = application.wo.get("i18n_defaultLocale"),
            fallbackLocale      = application.wo.get("i18n_fallbackLocale"),
            translationSource   = application.wo.get("i18n_translationSource"),
            cacheTranslations   = application.wo.get("i18n_cacheTranslations")
        );

        // Perform initial load of translation files
        application[local.appKey].i18n.loadTranslations();
    }

    /**
     * Translate a key to the current locale
     * Usage: #t("common.welcome")# or #t(key="common.hello", name="John")#
     */
    public string function t(required string key) {
        // 1. Determine Locale
        local.currentLocale = currentLocale();
        local.i18nService = application.wheels.i18n;
        
        // 2. Get Translation
        local.translation = local.i18nService.getTranslation(local.currentLocale, arguments.key);

        // 3. Fallback Logic
        if (!len(local.translation)) {
            local.fallbackLocale = get("i18n_fallbackLocale");
            // Only try fallback if it's different from current
            if (local.fallbackLocale != local.currentLocale) {
                local.translation = local.i18nService.getTranslation(local.fallbackLocale, arguments.key);
            }
        }

        // 4. If still empty, return the key itself (easier for debugging)
        if (!len(local.translation)) {
            return arguments.key;
        }

        // 5. Parameter Interpolation (replacing {name} with arguments.name)
        for (local.param in arguments) {
            if (local.param != "key") {
                local.searchString = "{" & local.param & "}";
                // Case-insensitive replacement
                local.translation = replaceNoCase(local.translation, local.searchString, arguments[local.param], "all");
            }
        }

        return local.translation;
    }

    /**
     * Translate a key with pluralization support
     * Usage:
     *   tp("inbox.messages", count=1)   → "1 message" or "1 mensaje"
     *   tp("inbox.messages", count=5)   → "5 messages" or "5 mensajes"
     */
    public string function tp(required string key, required numeric count) {
		local.arguments = duplicate(arguments);
		local.translationKey = arguments.key;

		if (arguments.count == 0) {
            local.translationKey = arguments.key & ".zero";
        } else if (arguments.count == 1) {
            // Use the explicit 'zero' key if count is 0
            local.translationKey = arguments.key & ".one";
        } else {
            // Use the 'other' key for all other counts (2, 3, 4, etc.)
            local.translationKey = arguments.key & ".other";
        }

		local.arguments.key = local.translationKey;
		return t(argumentCollection=local.arguments);
	}

    /**
     * Get current application locale from Session, or default if not set
     */
    public string function currentLocale() {
        if (structKeyExists(session, "locale") && len(session.locale)) {
            return session.locale;
        }
        return get("i18n_defaultLocale");
    }

    /**
     * Change application locale
     * Returns true if successful, false if locale not supported
     */
    public boolean function changeLocale(required string language) {
        if (listFindNoCase(get("i18n_availableLocales"), arguments.language)) {
            session.locale = arguments.language;
            return true;
        }
        return false;
    }

    /**
     * Get all available locales as an array
     */
    public array function availableLocales() {
        return listToArray(get("i18n_availableLocales"));
    }

}