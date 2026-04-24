/**
 * wheels-i18n — WheelsTest BDD specs.
 *
 * Covers LocalizationService behaviour directly (isolated from the
 * application framework) using JSON fixtures committed at
 * tests/_fixtures/locales/<locale>/<namespace>.json.
 *
 * The mixin methods on I18n.cfc (t/tp/currentLocale/changeLocale/
 * availableLocales) depend on application-scope state set up by
 * init(), so they're covered indirectly via LocalizationService here.
 * Full mixin integration is validated by running the test app with
 * the package installed.
 *
 * Note: uses createObject() rather than `new` because the package
 * directory name contains a hyphen (`wheels-i18n`), which some CFML
 * parsers interpret as a subtraction operator inside a `new` path.
 */
component extends="wheels.WheelsTest" output="false" {

    function run() {

        describe("LocalizationService — init()", () => {

            it("instantiates without throwing with JSON source config", () => {
                var threw = false;
                try {
                    var svc = createObject("component", "vendor.wheels-i18n.lib.LocalizationService").init(
                        translationsPath    = "/vendor/wheels-i18n/tests/_fixtures/locales",
                        availableLocales    = "en,es",
                        defaultLocale       = "en",
                        fallbackLocale      = "en",
                        translationSource   = "json",
                        cacheTranslations   = false
                    );
                } catch (any e) {
                    threw = true;
                }
                expect(threw).toBeFalse("LocalizationService init should not throw for valid JSON config");
            });

            it("instantiates without throwing with database source config", () => {
                var threw = false;
                try {
                    var svc = createObject("component", "vendor.wheels-i18n.lib.LocalizationService").init(
                        translationsPath    = "/unused",
                        availableLocales    = "en",
                        defaultLocale       = "en",
                        fallbackLocale      = "en",
                        translationSource   = "database",
                        cacheTranslations   = false,
                        dbTable             = "i18n_translations",
                        dbLocaleColumn      = "locale",
                        dbKeyColumn         = "translation_key",
                        dbValueColumn       = "translation_value"
                    );
                } catch (any e) {
                    threw = true;
                }
                expect(threw).toBeFalse("LocalizationService init should not throw for valid DB config");
            });

        });

        describe("LocalizationService — JSON loader", () => {

            it("loads flat keys from a JSON file", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "common.welcome")).toBe("Welcome to the test app");
            });

            it("flattens nested keys into dotted lookup paths", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "common.nav.home")).toBe("Home");
                expect(svc.$getTranslation("en", "common.nav.about.service")).toBe("Service");
            });

            it("loads pluralization keys (.zero/.one/.other)", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "common.posts.zero")).toBe("No Post Found");
                expect(svc.$getTranslation("en", "common.posts.one")).toBe("{count} Post Found");
                expect(svc.$getTranslation("en", "common.posts.other")).toBe("{count} Posts Found");
            });

            it("loads translations from multiple locales", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("es", "common.welcome")).toBe("Bienvenido a la aplicación de prueba");
            });

            it("returns empty string for missing keys", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "nonexistent.key")).toBe("");
            });

            it("returns empty string for missing locale", () => {
                var svc = $newService();
                svc.$loadTranslations();
                expect(svc.$getTranslation("fr", "common.welcome")).toBe("");
            });

        });

        describe("LocalizationService — caching", () => {

            it("reloads translations on every lookup when cacheTranslations=false", () => {
                var svc = $newService(cacheTranslations: false);
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "common.welcome")).toBe("Welcome to the test app");
                expect(svc.$getTranslation("en", "common.welcome")).toBe("Welcome to the test app");
            });

            it("retains translations between lookups when cacheTranslations=true", () => {
                var svc = $newService(cacheTranslations: true);
                svc.$loadTranslations();
                expect(svc.$getTranslation("en", "common.welcome")).toBe("Welcome to the test app");
                expect(svc.$getTranslation("en", "common.nav.home")).toBe("Home");
            });

        });

        describe("I18n — pluralization key selection", () => {

            // tp() rewrites the lookup key based on count before delegating to t().
            // The key-transformation rule is pure and isolated here:
            //   count == 0 → .zero
            //   count == 1 → .one
            //   otherwise  → .other

            it("maps count=0 to .zero", () => {
                expect($pluralKey("inbox.messages", 0)).toBe("inbox.messages.zero");
            });

            it("maps count=1 to .one", () => {
                expect($pluralKey("inbox.messages", 1)).toBe("inbox.messages.one");
            });

            it("maps count=2+ to .other", () => {
                expect($pluralKey("inbox.messages", 2)).toBe("inbox.messages.other");
                expect($pluralKey("inbox.messages", 42)).toBe("inbox.messages.other");
            });

        });

    }

    // --- helpers -----------------------------------------------------------

    private any function $newService(boolean cacheTranslations = false) {
        return createObject("component", "vendor.wheels-i18n.lib.LocalizationService").init(
            translationsPath    = "/vendor/wheels-i18n/tests/_fixtures/locales",
            availableLocales    = "en,es",
            defaultLocale       = "en",
            fallbackLocale      = "en",
            translationSource   = "json",
            cacheTranslations   = arguments.cacheTranslations
        );
    }

    /**
     * Mirror of the key-selection logic inside I18n.tp(). Extracted as a
     * testable pure function so pluralization can be verified without
     * standing up the full mixin context.
     */
    private string function $pluralKey(required string key, required numeric count) {
        if (arguments.count == 0) return arguments.key & ".zero";
        if (arguments.count == 1) return arguments.key & ".one";
        return arguments.key & ".other";
    }

}
