//! Counter-Strike 1.6: the colors and font of its menus, set in TrackerScheme.res.

const std = @import("std");

/// The scheme's colors and font; build one with `from`.
pub const App = @import("App.zig");
/// Colors from the theme.
pub const from = App.from;
/// The adapter the app edits the scheme with, so a config needs only this package.
pub const keyvalues_adapter = @import("kosm_keyvalues").adapter;

test {
    std.testing.refAllDecls(@This());
    std.testing.refAllDecls(App);
}
