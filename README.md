# kosm_counter_strike

Counter-Strike 1.6 for kosm: the colors and font of the game's menus (VGUI's
`TrackerScheme.res`), set in place. Every other line of the scheme stays as it is, and each set
color's key must already be in it.

The scheme belongs to the game: Steam may restore it when it verifies or updates the game, so
apply again afterwards.

`from(theme)` sets text from white (black in light mode), brighter when selected and dimmer by
the theme's emphasis; backgrounds from black (white in light mode) with its surface steps;
borders white and cyan. The backgrounds take the theme's `background_alpha`, so the menus are
translucent like the rest of the kosmos. The title bar and the disabled overlay stay transparent, as shipped.
The font is left alone.

## Fields

| Field | Default |
|---|---|
| `file` | `~/.local/share/Steam/steamapps/common/Half-Life/valve/resource/TrackerScheme.res`; set it for another Steam library |
| `format` | the adapter's: `r g b a` |
| `colors` | every key of `Scheme.Colors` in snake_case (`base_text`, `control_bg`, `selection_bg2`, `border_selection`, ...); null leaves each as it is |
| `font` | the family of every font of the scheme (`Scheme.Fonts.*.*.name`); null leaves them |
