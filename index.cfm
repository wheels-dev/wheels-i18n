<style>
    body {
        font-family: Arial, sans-serif;
        line-height: 1.6;
        color: #222;
    }
    h1, h3, h4 {
        color: #333;
        margin-top: 32px;
    }
    h1 {
        font-size: 32px;
        margin-bottom: 10px;
        border-bottom: 3px solid #eee;
        padding-bottom: 10px;
    }
    p {
        margin: 10px 0 18px 0;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin: 15px 0;
        font-size: 14px;
    }
    table thead {
        background: #f7f7f7;
        border-bottom: 2px solid #ddd;
    }
    table th, table td {
        padding: 10px;
        border: 1px solid #e1e1e1;
        text-align: left;
    }
    code {
        background: #f3f3f3;
        padding: 3px 6px;
        border-radius: 4px;
        font-size: 90%;
    }
    pre {
        background: #f8f8f8;
        padding: 12px;
        border-radius: 6px;
        overflow-x: auto;
        border: 1px solid #e1e1e1;
    }
    ul {
        margin: 10px 0;
        padding-left: 20px;
    }
    hr {
        margin: 30px 0;
        border: none;
        border-bottom: 1px solid #eee;
    }
</style>

<h1>wheels-i18n: Localization Plugin</h1>
<p>
    Internationalization (i18n) and localization plugin for Wheels, providing easy-to-use functions for translating content,
    managing locales, and locale-based configuration.
</p>

<hr>

<h3>Installation</h3>
<pre>
wheels plugin install wheels-i18n
</pre>

<hr>

<h3>Configuration Settings</h3>
<p>Add the following configuration settings inside your application's <code>config/settings.cfm</code> file:</p>

<pre>
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationsPath="/app/locales");
set(i18n_cacheTranslations=false); // Set to true in production
</pre>

<p>Below is a description of all available i18n configuration settings and their default values:</p>

<table>
    <thead>
        <tr>
            <th>Setting Name</th>
            <th>Default Value</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><strong>i18n_defaultLocale</strong></td>
            <td><code>"en"</code></td>
            <td>The default locale (language code) to use if no session locale is set.</td>
        </tr>
        <tr>
            <td><strong>i18n_availableLocales</strong></td>
            <td><code>"en"</code></td>
            <td>A comma-separated list of all supported locales (e.g., <code>"en,es,fr"</code>).</td>
        </tr>
        <tr>
            <td><strong>i18n_fallbackLocale</strong></td>
            <td><code>"en"</code></td>
            <td>The locale to fall back to if a translation is missing in the current locale.</td>
        </tr>
        <tr>
            <td><strong>i18n_translationsPath</strong></td>
            <td><code>"/app/locales"</code></td>
            <td>The path where translation JSON files are stored.</td>
        </tr>
        <tr>
            <td><strong>i18n_cacheTranslations</strong></td>
            <td><code>false</code></td>
            <td>Set true to cache translations in memory (recommended for production).</td>
        </tr>
    </tbody>
</table>

<hr>

<h3>Translation Files (<code>/app/locales</code>)</h3>

<p>Translations are organized into folders by locale. Each locale contains one or more JSON files (e.g., <code>common.json</code>) that store translation keys and values.</p>

<pre>
/app
    /locales
        /en
            common.json
        /es
            common.json
</pre>

<h4><code>/app/locales/en/common.json</code></h4>
<pre>{
  "welcome": "Welcome to our application",
  "greeting": "Hello, {name}!",
  "goodbye": "Goodbye",
  "nav": {
    "home": "Home",
    "about": "About Us",
    "contact": "Contact",
    "dashboard": "Dashboard"
  },
  "buttons": {
    "save": "Save",
    "cancel": "Cancel",
    "delete": "Delete",
    "edit": "Edit",
    "view": "View",
    "new": "New",
    "back": "Back"
  },
  "posts": {
    "zero": "No Post Found",
    "one": "{count} Post Found", 
    "other": "{count} Posts Found" 
  },
  "messages": {
    "success": "Operation completed successfully",
    "error": "An error occurred",
    "loading": "Loading...",
    "no_results": "No results found"
  },
  "actions": "Actions",
  "confirm_delete": "Are you sure you want to delete this?"
}
</pre>

<h4><code>/app/locales/es/common.json</code></h4>
<pre>{
  "welcome": "Bienvenido a nuestra aplicación",
  "greeting": "¡Hola, {name}!",
  "goodbye": "Adiós",
  "nav": {
    "home": "Inicio",
    "about": "Sobre Nosotros",
    "contact": "Contacto",
    "dashboard": "Panel de Control"
  },
  "buttons": {
    "save": "Guardar",
    "cancel": "Cancelar",
    "delete": "Eliminar",
    "edit": "Editar",
    "view": "Ver",
    "new": "Nuevo",
    "back": "Volver"
  },
  "posts": {
    "zero": "No se encontraron publicaciones",
    "one": "{count} publicación encontrada",
    "other": "{count} publicaciones encontradas"
  },
  "messages": {
    "success": "Operación completada exitosamente",
    "error": "Ocurrió un error",
    "loading": "Cargando...",
    "no_results": "No se encontraron resultados"
  },
  "actions": "Acciones",
  "confirm_delete": "¿Estás seguro de que quieres eliminar esto?"
}
</pre>

<hr>

<h3>Functions Reference</h3>
<ul>
    <li><strong>t(required key, [params])</strong> – Translate key for current locale.</li>
    <li><strong>tp(required key, required count, [params])</strong> – Translate and pluralize key based on count.</li>
    <li><strong>currentLocale()</strong> – Returns the active locale.</li>
    <li><strong>changeLocale(required lang)</strong> – Sets session locale.</li>
    <li><strong>availableLocales()</strong> – Returns list of allowed languages.</li>
</ul>

<hr>

<h3>Usage: Key Functions</h3>

<h4>Translate Function - <code>t()</code></h4>
<p>The core function to translate a key to the current locale, with parameter interpolation and fallback logic.</p>

<pre>
// Basic usage
#t("common.welcome")# 

// With parameter interpolation
#t(key="common.greeting", name="John Doe")# 
// (Assumes: "Hello, {name}!")
</pre>

<h4>Pluralization Function - <code>tp()</code></h4> 
<p>Translates a key and automatically selects the correct singular (<code>.one</code>) or plural (<code>.other</code>) form based on the <code>count</code> argument. 
    The count is also available for interpolation as <strong><code>{count}</code></strong>.</p> 
<p><strong>Note:</strong> This implementation assumes the simple English plural rule (1 is singular, anything else is plural).</p>

<pre>
// Singular usage (Count = 1) #tp(key="common.posts", count=1)# // Result: "1 Post Found"

// Plural usage (Count > 1) #tp(key="common.posts", count=5)# // Result: "5 Posts Found"

// Zero usage (Count = 0) #tp(key="common.posts", count=0)# // Result: "0 Posts Found" 
</pre>

<h4>Current Locale - <code>currentLocale()</code></h4>
<p>Gets the current application locale from the Session, or the default locale if not set.</p>

<pre>
locale = currentLocale(); // "en"
</pre>

<h4>Change Locale - <code>changeLocale()</code></h4>
<p>Sets the application locale in Session and returns a boolean based on success.</p>

<pre>
// Change to Spanish
success = changeLocale("es");

// Unsupported locale
success = changeLocale("jp"); // false
</pre>

<h4>Available Locales - <code>availableLocales()</code></h4>
<p>Returns an array of all configured available locales.</p>

<pre>
locales = availableLocales(); // ["en", "es", "fr"]
</pre>

<hr>

<h3>Author</h3>
<p>wheels-dev</p>

<h3>Wheels Version</h3>
<p>3.0.0</p>

<h3>License</h3>
<p>MIT</p>