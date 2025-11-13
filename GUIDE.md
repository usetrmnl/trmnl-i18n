## web application
TRMNL leverages YAML formatted files with a resource-based hierarchy. content on the Account page (`/account`) is thus nested:

```
account:
  index:
    title: Account
    tagline: Manage your account settings
```

if a given phrase is used in other locations, it will be placed in the "root" node of the YML file as global variable:

```
en:
  add: Add
  back: Back
  cancel: Cancel
```

## plugin renders
TRMNL namespaces each native plugin's text content into a node matching the plugin's "keyname", for example `days_left_year` represents the "Days Left This Year" plugin.

```
days_left_year:
  title: Days Left This Year
  days_passed: Days Passed
  days_left: Days Left
```

plugin render localizations are more useful than web application contributions, as TRMNL generates millions of screens every month.

## custom plugins
TRMNL lets users build their own plugins, which they may want to share with others.

```
es-ES:
  # namespace to not interfere with other localizations
  custom_plugins:

    # generic words and phrases to make custom plugins more accessible
    today: hoy
    tomorrow: mañana
  ```

learn how users can leverage this dictionary here:
https://help.usetrmnl.com/en/articles/10347358-custom-plugin-filters

## how to provide localizations
in [a previous guide](https://github.com/usetrmnl/localizations/blob/87c0ce5b4b71bff2f80346065aa50a5ce7a7e050/GUIDE.md) we provided annotated screenshots for each phrase, but this approach was cumbersome. whenever our interface changed, the guide become outdated.

to ensure this library is in parity with our website, we now support a `raw` locale that can be enabled while creating localizations.

<kbd>![trmnl-localizations-raw-locale-example](https://github.com/usetrmnl/localizations/blob/main/support/raw_locale_example.png)</kbd>

**enable raw locales**

* Option A - while logged into TRMNL, navigate to your Account and set the Locale to "locale_name" in the dropdown

<kbd>![trmnl-locale-dropdown-picker](https://github.com/usetrmnl/localizations/blob/main/support/locale_dropdown_picker.png)</kbd>

* Option B - visit any TRMNL web page, for example `/dashboard`, then add `?locale=raw` to the URL and reload the page.

### plugin renders
to localize plugins, pick a plugin here (requires login):
https://usetrmnl.com/plugins/demo

<kbd>![trmnl-localizations-raw-locale-plugin-example](https://github.com/usetrmnl/localizations/blob/main/support/raw_plugin_example.png)</kbd>

### submitting content

localization files live inside `lib/trmnl/i18n/locales`. from within that directory make a copy of `web_ui/en.yml`, `plugin_renders/en.yml`, or `custom_plugins/en.yml`, save a new version using your [ISO 639 language code](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes). submit this as a pull request and [ask questions](https://github.com/usetrmnl/trmnl-i18n/issues/new) if you need help.

## general tips

we understand that...
* not all languages support casing
* some languages (ex: Korean) support levels of formality
* some languages are genered

so in general we prefer a casual tone with simple vocabulary. this matches the spirit of our brand and makes TRMNL comfortable for people all around the world.
