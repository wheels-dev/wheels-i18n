# wheels-i18n

A lightweight and flexible localization (i18n) plugin for **Wheels 3.x**, providing an easy way to manage translations, locales, and multi-language support.

### This plugin adds:

- Simple translation helpers (t(), tp())
- Automatic locale detection & switching
- JSON-based translation files
- Fallback locale support
- Optional caching
- Compatible with all Wheels 3.x applications

## LICENSE

MIT License

## Installation

Install via CommandBox:

```bash
wheels plugin install wheels-i18n
```

## Configuration

Add these settings in your `config/settings.cfm` file:

```
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationsPath="/app/locales");
set(i18n_cacheTranslations=false); // Set to true in production
```

Below is a description of all available i18n configuration settings and their default values:

| Setting Name | Default | Description  |
|-------------|-----------------|-----------|
| i18n_defaultLocale | `en` | Default locale if none is set in session |
| i18n_availableLocales | `en` | Comma-separated list: "en,es" |
| i18n_fallbackLocale | `en` | Used if a translation key is missing |
| i18n_translationsPath | `/app/locales` | Base folder for translations |
| i18n_cacheTranslations | `false` | Enable in-memory caching |

## Directory Structure

Your application should include the following localization structure:

```
/app
    /locales
        /en
            common.json
        /es
            common.json
```
Each language contains one or more JSON translation files (e.g., `common.json`).

## Usage

## Basic Locales Examples

Example: `/app/locales/en/common.json`

```
{
  "welcome": "Welcome to our application",
  "greeting": "Hello, {name}!",
  "posts": {
    "zero": "No Post Found",
    "one": "{count} Post Found", 
    "other": "{count} Posts Found" 
  },
  "buttons": {
    "save": "Save",
    "cancel": "Cancel"
  }
}
```

Example: `/app/locales/es/common.json`

```
{
  "welcome": "Bienvenido a nuestra aplicación",
  "greeting": "¡Hola, {name}!",
  "posts": {
    "zero": "No se encontraron publicaciones",
    "one": "{count} publicación encontrada",
    "other": "{count} publicaciones encontradas"
  },
  "buttons": {
    "save": "Guardar",
    "cancel": "Cancelar",
  }
}
```
### Basic Translation Example

```cfml
// Translate a key from the default or active locale
writeOutput( t("welcome.message") );      // Output: Welcome to our application
```

### Pluralization Example

```cfml
// Translate a key for pluralized terms from the default locale
writeOutput( tp(key="common.posts", count=0) );     // Output: No Post Found
writeOutput( tp(key="common.posts", count=1) );     // Output: 1 Post Found
writeOutput( tp(key="common.posts", count=5) );     // Output: 5 Posts Found
```

### Change Locale

```cfml
changeLocale("es");
```

### Get Current Locale

```cfml
current = currentLocale();
```

### Get All Available Locales

```cfml
result = availableLocales("test");
```

## Functions Provided

- `t( key, [params])` – Translate a string by key
- `tp( key, count, [params])` – Translate and pluralize key based on count.
- `changeLocale( locale )` – Set active locale
- `currentLocale()` – Get active locale
- `availableLocales()` – Returns available locales

## License

MIT

## Author

wheels-dev
