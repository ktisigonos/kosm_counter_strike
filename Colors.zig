//! The colors of `Scheme.Colors` in TrackerScheme.res, named as the scheme names them in
//! snake_case (`BaseText` is `base_text`, `ControlBG` is `control_bg`). null: left as it is.

/// Text in text windows and lists.
base_text: ?Color = null,
/// The brightest text.
bright_base_text: ?Color = null,
/// Selected text.
selected_text: ?Color = null,
/// Dim text.
dim_base_text: ?Color = null,
/// Info text.
label_dim_text: ?Color = null,
/// Text in every control.
control_text: ?Color = null,
/// Text in selected controls.
bright_control_text: ?Color = null,
/// Disabled text.
disabled_text1: ?Color = null,
/// The overlay over disabled text that gives it an inset look.
disabled_text2: ?Color = null,
/// Offline friends, unsubscribed games and the like.
dim_list_text: ?Color = null,
/// Controls' background.
control_bg: ?Color = null,
/// The darker background, e.g. of scrollbars.
control_dark_bg: ?Color = null,
/// Text edit panes' background (chat, text entries).
window_bg: ?Color = null,
/// Selected text's and menu items' background.
selection_bg: ?Color = null,
/// The selection's background in a window without focus.
selection_bg2: ?Color = null,
/// The server browser's and buddy list's background.
list_bg: ?Color = null,
/// Title bar text.
title_text: ?Color = null,
/// Title bar text of a window without focus.
title_dim_text: ?Color = null,
/// The title bar's background.
title_bg: ?Color = null,
/// The title bar's background of a window without focus.
title_dim_bg: ?Color = null,
/// A slider's ticks.
slider_tick_color: ?Color = null,
/// A slider's track.
slider_track_color: ?Color = null,
/// A control's lit side.
border_bright: ?Color = null,
/// A control's unlit side.
border_dark: ?Color = null,
/// The extra border of the default or selected button.
border_selection: ?Color = null,

const Color = @import("kosm").Color;
