# Screenshots

Weblate imports every PNG here that matches a component's screenshot filemask, and
re-imports it whenever the file changes. One directory per component.

A screenshot exists so a translator can see where a string lands. Name each file after
the plugin whose render it shows, so `rake weblate:screenshot_units` can find the keys
that belong to it: `plugin_renders/weather.png` links the `renders->weather->*` strings.

These are the 800x480 panel previews from core's `app/assets/images/plugin_previews`.
Keep them small; they live in every clone forever.
