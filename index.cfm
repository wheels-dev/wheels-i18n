<style>
    body {font-family: "Segoe UI", Arial, sans-serif; line-height: 1.7; color: #222; background: #fdfdfd;}
    h1, h3, h4 {color: #1976d2;}
    h1 {font-size: 36px; border-bottom: 4px solid #eee; padding-bottom: 15px;}
    h2 {color: #333; border-bottom: 2px solid #2196F3; padding-bottom: 8px;}
    code {background: #f0f7ff; padding: 3px 8px; border-radius: 4px; font-size: 92%; color: #d63384;}
    pre {background: #f8f9fa; padding: 16px; border-radius: 8px; overflow-x: auto; border: 1px solid #e0e0e0; font-size: 14px;}
    .highlight {background: #e8f5e8; padding: 16px; border-left: 5px solid #4caf50; border-radius: 0 8px 8px 0; margin: 20px 0;}
    .pro {background: #fff8e1; padding: 16px; border-left: 5px solid #ff9800; border-radius: 0 8px 8px 0; margin: 25px 0;}
    .note {background: #e3f2fd; padding: 14px; border-left: 4px solid #1976d2; margin: 20px 0; border-radius: 4px;}
    table {width: 100%; border-collapse: collapse; margin: 20px 0;}
    th, td {padding: 12px; border: 1px solid #ddd; text-align: left;}
    th {background: #f5f5f5;}
    hr {border: none; height: 1px; background: #ddd; margin: 20px 0;}
    ul {padding-left: 20px;}
    a {color: #1976d2; text-decoration: none;}
    a:hover {text-decoration: underline;}
</style>

<h1>wheels-i18n v1.0.0</h1>
<p><strong>The simplest, fastest, and most powerful internationalization plugin for Wheels.</strong></p>

<hr>

<h2>Installation</h2>
<pre>wheels plugins install wheels-i18n</pre>

<hr>

<h2>Translation via JSON File</h2>

<h3>Step 1: Configuration Settings</h3>
<p>Add the following configuration settings inside your application's <code>config/settings.cfm</code> file:</p>

<pre>
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationSource = "json");
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
            <td><strong>i18n_translationSource</strong></td>
            <td><code>"json"</code></td>
            <td>The method that will be used for locales (<code>"json/database"</code>).</td>
        </tr>
        <tr>
            <td><strong>i18n_translationsPath</strong></td>
            <td><code>"/app/locales"</code></td>
            <td>The path where JSON files are stored for translation.</td>
        </tr>
        <tr>
            <td><strong>i18n_cacheTranslations</strong></td>
            <td><code>false</code></td>
            <td>Set true to cache translations in memory (recommended for production).</td>
        </tr>
    </tbody>
</table>

<div class="note">
    <strong>Pro Tip:</strong> Set <code>i18n_cacheTranslations=true</code> in production for fast performance.
</div>

<hr>

<h3>Step 2: Add Your First Translation</h3>
<p>Create this file: <code>/app/locales/en/common.json</code></p>
<pre>
{
  "welcome": "Welcome to my app!",
  "hello": "Hello, {name}!",
  "save": "Save",
  "posts": {
    "zero": "No Post Found",
    "one": "{count} Post Found", 
    "other": "{count} Posts Found" 
  },
}
</pre>
<p>Same structure file for different language e.g: <code>/app/locales/es/common.json</code></p>
<pre>
{
  "welcome": "Bienvenido a nuestra aplicación",
  "hello": "¡Hola, {name}!",
  "save": "Guardar",
  "posts": {
    "zero": "No se encontraron publicaciones",
    "one": "{count} publicación encontrada",
    "other": "{count} publicaciones encontradas"
  },
}
</pre>

<hr>

<h3>Step 3: Use It Anywhere</h3>
<pre>
#t("common.welcome")#
#t("common.greeting", name="Sarah")#
#tp("common.posts", count=5)#
</pre>

<p>You're done!</p>

<hr>

<h3>Folder Structure</h3>
<pre>
/app/locales/
    /en/
        common.json
        forms.json
    /es/
        common.json
        forms.json
</pre>

<hr>

<h2>Translation via Database</h2>

<h3>Step 1: Configuration Settings</h3>
<p>Add the following configuration settings inside your application's <code>config/settings.cfm</code> file:</p>

<pre>
set(i18n_defaultLocale="en");
set(i18n_availableLocales="en,es");
set(i18n_fallbackLocale="en");
set(i18n_translationSource = "database");
set(i18n_cacheTranslations=false); // Set to true in production
</pre>

<hr>

<h3>Step 2: Create the Translations Table</h3>

<p>Create the database table using a standard Wheels migration:</p>

<h4>Run the command in CLI:</h4>
<pre>
wheels dbmigrate create table i18n_translations
</pre>

<p>Then replace the generated file with this content:</p>

<pre>
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
</pre>

<p>Finally run:</p>
<pre>
wheels dbmigrate up
</pre>

<p>That’s it — your database is ready for translation.</p>

<hr>

<h3>Step 3: Add Insertions in the i18n_translations Table</h3>
<p>Insert your keys in your database table according to your database to run your translation. here's a sample</p>
<pre>
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
</pre>

<p>This is MySQL queries, you can change it according to your database</p>

<h3>Step 4: Use It Anywhere</h3>
<pre>
#t("common.welcome")#
#t("common.greeting", name="Sarah")#
#tp("common.posts", count=5)#
</pre>

<p>You're done!</p>

<h4>(Optional) Add Admin Panel</h4>
<p>Want translators or clients to edit translations live in the browser?</p>
<p>You can easily build your own admin area using standard Wheels tools:</p>
<ul>
    <li>Create a simple <strong>model</strong> mapped to the <code>i18n_translations</code> table</li>
    <li>Add a <strong>controller</strong> with <code>index</code> and <code>save</code> actions</li>
    <li>Build a clean <strong>view</strong> with a form (locale + key + value)</li>
</ul>
<p>That’s it — your translators can now update text instantly.</p>
<p><em>Many agencies love this workflow. You’re in full control — build it exactly how you want.</em></p>

<hr>

<h2>Plugin Functions (Work in Both JSON & Database Mode)</h2>
<ul>
    <li><code>#t("key")#</code> → Translate</li>
    <li><code>#t("key", name="John")#</code> → With variables</li>
    <li><code>#tp("key", count=5)#</code> → Pluralization (.zero, .one, .other)</li>
    <li><code>#currentLocale()#</code> → Get current language</li>
    <li><code>#changeLocale("es")#</code> → Switch language</li>
    <li><code>#availableLocales()#</code> → Array of supported languages</li>
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

<p>This is the <strong>only i18n plugin</strong> you'll ever need for Wheels translation/localization.</p>

<div class="highlight">
    Made with love by <strong>wheels-dev</strong><br>
    MIT License • Works with Wheels 3.0+<br>
    GitHub: <a href="https://github.com/zainforbjs/wheels-i18n">github.com/zainforbjs/wheels-i18n</a>
</div>