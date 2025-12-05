# wheels-i18n v1.0.0

**The simplest, fastest, and most powerful internationalization (i18n) plugin for Wheels 3.x+**

Lightweight • Zero dependencies • JSON or Database backed • Built-in pluralization • Full fallback support

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/wheels-dev/wheels-i18n/blob/main/LICENSE)
[![Wheels 3+](https://img.shields.io/badge/Wheels-3%2B-brightgreen)](https://wheels.dev)

## Features

- `t()` – Simple key-based translation with variable interpolation
- `tp()` – Pluralization support (`.zero`, `.one`, `.other`)
- JSON file or database translation sources
- Session-based locale switching
- Fallback locale & missing key handling
- Optional in-memory caching (great for production)
- Works anywhere in views, controllers, or models

## Installation

```bash
wheels plugin install wheels-i18n
```

## Translation via JSON File

### Step 1: Configuration Settings

Add these settings in your `config/settings.cfm` file:

```cfml
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationSource="json");
set(i18n_translationsPath="/app/locales");
set(i18n_cacheTranslations=false);
```

Below is a description of all available i18n configuration settings and their default values:

| Setting Name | Default | Description  |
|-------------|-----------------|-----------|
| i18n_defaultLocale | `en` | Default locale if none is set in session |
| i18n_availableLocales | `en` | A comma-separated list of all supported locales: "en,es" |
| i18n_fallbackLocale | `en` | Used if a translation key is missing in current locale |
| i18n_translationSource | `json` | Translation method: "json" or "database" |
| i18n_translationsPath | `/app/locales` | Path for JSON files (only used with json source) |
| i18n_cacheTranslations | `false` | Cache translations in memory (recommended for production) |

___Pro Tip___: __Set i18n_cacheTranslations=true in production for fast performance.__

### Step 2: Add Your First Translation

Create this file: `/app/locales/en/common.json`

```json
{
  "welcome": "Welcome to my app!",
  "greeting": "Hello, {name}!",
  "save": "Save",
  "posts": {
    "zero": "No Post Found",
    "one": "{count} Post Found", 
    "other": "{count} Posts Found" 
  },
  "nav": {
    "home": "Home",
    "about": {
        "service": "Service",
        "portfolio": "Portfolio"
    },
    "contact": "Contact"
  }
}
```

Same for different language: `/app/locales/es/common.json`

```json
{
  "welcome": "Bienvenido a nuestra aplicación",
  "greeting": "¡Hola, {name}!",
  "save": "Guardar",
  "posts": {
    "zero": "No se encontraron publicaciones",
    "one": "{count} publicación encontrada",
    "other": "{count} publicaciones encontradas"
  },
  "nav": {
    "home": "Hogar",
    "about": {
        "service": "Servicio",
        "portfolio": "Cartera"
    },
    "contact": "Contacto"
  }
}
```

### Directory Structure

Your application should follow the following localization structure:

```bash
/app
  /locales
    /en
      common.json
      forms.json
    /es
      common.json
      forms.json
```

### Step 3: Use It Anywhere

```cfml
#t("common.welcome")#
#t("common.greeting", name="Sarah")#
#t("common.nav.about.service)#
#tp("common.posts", count=5)#
```

__Your Are Done!__

## Video Tutorial

https://raw.githubusercontent.com/wheels-dev/wheels-i18n/main/assets/translation-via-json.mp4

## Translation via Database

### Step 1: Configuration Settings

Add these settings in your `config/settings.cfm` file:

```cfml
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationSource="database");
set(i18n_cacheTranslations=false);
```

### Step 2: Create the Translation Table

Create the database table using a standard Wheels migration:

#### Run the command in CLI:

```bash
wheels dbmigrate create table i18n_translations
```

Then replace the generated file with this content:

```cfml
// app/migrator/migrations/XXXX_cli_create_table_i18n_translations.cfc
component {
  function up() {
    t = createTable(name = 'i18n_translations', force='false', id='true', primaryKey='id');
    t.string(columnNames = 'locale', limit = '10', allowNull = false);
    t.string(columnNames = 'translation_key', limit = '255', allowNull = false);
    t.text(columnNames = 'translation_value', allowNull = false);
    t.timestamps();
    t.create();

    addIndex(table="i18n_translations", columnNames="locale");
    addIndex(table="i18n_translations", columnNames="translation_key");
  }

  function down() {
    dropTable("i18n_translations");
  }
}
```

Then this command in CLI to run your migration:

```bash
wheels dbmigrate up
```

### Step 3: Add Insertions in the i18n_translations Table

Insert your translations keys according to your database to run your translation. here's a sample in MySQL

```
INSERT INTO i18n_translations (locale, translation_key, translation_value, createdat, updatedat) VALUES
('en', 'common.welcome', 'Welcome to our application', NOW(), NOW()),
('en', 'common.greeting', 'Hello, {name}!', NOW(), NOW()),
('en', 'common.goodbye', 'Goodbye', NOW(), NOW()),
('en', 'common.posts.zero', 'No Post Found', NOW(), NOW()),
('en', 'common.posts.one', '{count} Post Found', NOW(), NOW()),
('en', 'common.posts.other', '{count} Posts Found', NOW(), NOW()),
('es', 'common.welcome', 'Bienvenido a nuestra aplicación', NOW(), NOW()),
('es', 'common.greeting', '¡Hola, {name}!', NOW(), NOW()),
('es', 'common.goodbye', 'Adiós', NOW(), NOW()),
('es', 'common.posts.zero', 'Ningún Post Encontrado', NOW(), NOW()),
('es', 'common.posts.one', '{count} Post Encontrado', NOW(), NOW()),
('es', 'common.posts.other', '{count} Posts Encontrados', NOW(), NOW());
```

### Step 4: User It Anywhere

```cfml
#t("common.welcome")#
#t("common.greeting", name="Sarah")#
#tp("common.posts", count=5)#
```

__Your Are Done!__

## Video Tutorial

https://raw.githubusercontent.com/wheels-dev/wheels-i18n/main/assets/translation-via-database.mp4

### (Optional) Add Admin Panel

Want translators or clients to edit translations live in the browser?

You can easily build your own admin area using standard Wheels tools:

* Create a simple model mapped to the i18n_translations table
* Add a controller with index and save actions
* Build a clean view with a form (locale + key + value)

That’s it — your translators can now update text instantly.

___Many agencies love this workflow. You’re in full control — build it exactly how you want.___

## Plugin Functions

- `#t("key")#` → Translate
- `#t("key", name="[param]")#` → With variables
- `#tp("key", count=[param])#` → Pluralization (.zero, .one, .other)
- `#currentLocale()#` → Get current language
- `#changeLocale("es")#` → Switch language
- `#availableLocales()#` → Array of supported languages

## Usage

### Basic Translation Function - `t()`

The core function to translate a key to the current locale, with parameter interpolation and fallback logic.

```cfml
// Basic Usage
#t("common.welcome")#       // (Output: Welcome to our application)

// With parameter interpolation
#t(key="common.greeting", name="John Doe")#       // (Output: "Hello, John Dow!")
```

### Pluralization Function - `tp()`

Translates a key and automatically selects the correct singular (.one) or plural (.other) form based on the count argument. The count is also available for interpolation as {count}.

Note: This implementation assumes the simple English plural rule (1 is singular, anything else is plural).

```cfml
// Zero usage (Count = 0) 
#tp(key="common.posts", count=0)#     // (Output: "No Post Found")

// Singular usage (Count = 1)
#tp(key="common.posts", count=1)#     // (Output: "1 Post Found")

// Plural usage (Count > 1)
#tp(key="common.posts", count=5)#     // (Output: "5 Posts Found")
```

### Change Locale - `changeLocale()`

Sets the application locale in Session and returns a boolean based on success.

```cfml
// Change to Spanish
changeLocale("es");

// Unsupported locale
changeLocale("jp");       // false
```

### Get Current Locale - `currentLocale()`

Gets the current application locale from the Session, or the default locale if not set.

```cfml
locale = currentLocale();       // "en"
```

### Get All Available Locales - `availableLocales()`

Returns an array of all configured available locales.

```cfml
locales = availableLocales();       // ["en", "es", "fr"]
```

## License

[MIT](https://github.com/wheels-dev/wheels-i18n/blob/main/LICENSE)

## Author

[Wheels-dev](https://forgebox.io/@wheels%2Ddev)