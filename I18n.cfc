/**
 * wheels-i18n — Wheels package for internationalization.
 *
 * Provides JSON-file or database-backed translations with parameter
 * interpolation and pluralization. Mixin methods are injected into the
 * controller target (which covers views, since Wheels views execute in
 * the controller's variables scope).
 *
 * Mixin methods available in controllers and views:
 *   t(key, [params...])             Translate a key to the current locale
 *   tp(key, count, [params...])     Translate with pluralization (.zero/.one/.other)
 *   currentLocale()                 Get the current locale from session or default
 *   changeLocale(language)          Switch locale; returns false if not in availableLocales
 *   availableLocales()              Array of configured locales
 */
component hint="wheels-i18n" output="false" mixin="controller" {

    public function init() {
        this.version = "2.0.0";

        // 1. Set default configuration settings
        $setDefaultSettings();

        // 2. Load the localization service singleton
        $loadService();
        return this;
    }

    private function $setDefaultSettings() {
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
        if (!structKeyExists(application[local.appKey], "i18n_dbTable")) {
            application.wo.set(i18n_dbTable="i18n_translations");
        }
        if (!structKeyExists(application[local.appKey], "i18n_dbLocaleColumn")) {
            application.wo.set(i18n_dbLocaleColumn="locale");
        }
        if (!structKeyExists(application[local.appKey], "i18n_dbKeyColumn")) {
            application.wo.set(i18n_dbKeyColumn="translation_key");
        }
        if (!structKeyExists(application[local.appKey], "i18n_dbValueColumn")) {
            application.wo.set(i18n_dbValueColumn="translation_value");
        }
    }

    private function $loadService() {
        local.appKey = application.wo.$appKey();
        // Initialize the service and store it in application scope
        application[local.appKey].i18n = createObject("component", "vendor.wheels-i18n.lib.LocalizationService").init(
            translationsPath    = application.wo.get("i18n_translationsPath"),
            availableLocales    = application.wo.get("i18n_availableLocales"),
            defaultLocale       = application.wo.get("i18n_defaultLocale"),
            fallbackLocale      = application.wo.get("i18n_fallbackLocale"),
            translationSource   = application.wo.get("i18n_translationSource"),
            cacheTranslations   = application.wo.get("i18n_cacheTranslations"),
            dbTable             = application.wo.get("i18n_dbTable"),
            dbLocaleColumn      = application.wo.get("i18n_dbLocaleColumn"),
            dbKeyColumn         = application.wo.get("i18n_dbKeyColumn"),
            dbValueColumn       = application.wo.get("i18n_dbValueColumn")
        );

        // Perform initial load of translation files
        application[local.appKey].i18n.$loadTranslations();
    }

    /**
     * Translate a key to the current locale with parameter interpolation.
     * Usage: #t("common.welcome")# or #t(key="common.hello", name="John")#
     */
    public string function t(required string key) {
        local.currentLocale = currentLocale();
        local.appKey = application.wo.$appKey();
        local.i18nService = application[local.appKey].i18n;

        local.translation = local.i18nService.$getTranslation(local.currentLocale, arguments.key);

        // Fallback to fallbackLocale if translation missing in current locale
        if (!len(local.translation)) {
            local.fallbackLocale = get("i18n_fallbackLocale");
            if (local.fallbackLocale != local.currentLocale) {
                local.translation = local.i18nService.$getTranslation(local.fallbackLocale, arguments.key);
            }
        }

        // If still empty, return the key itself (debugging aid)
        if (!len(local.translation)) {
            return arguments.key;
        }

        // Parameter interpolation (replace {name} with arguments.name)
        for (local.param in arguments) {
            if (local.param != "key") {
                local.searchString = "{" & local.param & "}";
                local.translation = replaceNoCase(local.translation, local.searchString, arguments[local.param], "all");
            }
        }

        return local.translation;
    }

    /**
     * Translate a key with pluralization support.
     * Usage:
     *   tp("inbox.messages", count=0)   → .zero variant
     *   tp("inbox.messages", count=1)   → .one variant
     *   tp("inbox.messages", count=5)   → .other variant
     */
    public string function tp(required string key, required numeric count) {
        local.arguments = duplicate(arguments);

        if (arguments.count == 0) {
            local.arguments.key = arguments.key & ".zero";
        } else if (arguments.count == 1) {
            local.arguments.key = arguments.key & ".one";
        } else {
            local.arguments.key = arguments.key & ".other";
        }

        return t(argumentCollection=local.arguments);
    }

    /**
     * Get the current locale from session, or default if not set.
     */
    public string function currentLocale() {
        if (structKeyExists(session, "locale") && len(session.locale)) {
            return session.locale;
        }
        return get("i18n_defaultLocale");
    }

    /**
     * Change the application locale. Returns true if successful, false if
     * the requested language is not in the configured availableLocales list.
     */
    public boolean function changeLocale(required string language) {
        if (listFindNoCase(get("i18n_availableLocales"), arguments.language)) {
            session.locale = arguments.language;
            return true;
        }
        return false;
    }

    /**
     * Returns all configured available locales as an array.
     */
    public array function availableLocales() {
        return listToArray(get("i18n_availableLocales"));
    }

}
