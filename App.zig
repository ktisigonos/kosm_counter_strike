//! Counter-Strike 1.6's menus: the colors and font of the VGUI scheme in TrackerScheme.res,
//! set in place; every other line stays as it is.

const App = @This();

const std = @import("std");
const kosm = @import("kosm");

/// The scheme; each set color's key must be in it already. Default: the one in Steam's default
/// library, `~/.local/share/Steam/steamapps/common/Half-Life/valve/resource/TrackerScheme.res`.
file: []const u8 = "~/.local/share/Steam/steamapps/common/Half-Life/valve/resource/TrackerScheme.res",
/// How values are spelled. Null fields take the adapter's: `r g b a`.
format: kosm.Format = .{},
/// The scheme's colors. null: left as they are.
colors: Colors = .{},
/// The family of every font of the scheme (`Scheme.Fonts.*.*.name`). null: left as they are.
font: ?[]const u8 = null,

/// The colors of `Scheme.Colors`.
pub const Colors = @import("Colors.zig");

/// Colors from the theme: text from the foreground role, brighter when selected and dimmer
/// by the theme's emphasis; backgrounds from the background role with its surface steps;
/// borders the foreground and the accent. The title bar and the disabled overlay stay transparent, as shipped.
pub fn from(theme: kosm.Theme) App {
    const variations = theme.variations;
    const foreground = theme.roles.foreground;
    const background = theme.asBackground(theme.roles.background);
    const bright = variations.lightness.bright.apply(foreground);
    const raised = variations.surface.raised.apply(background);
    return .{ .colors = .{
        .base_text = foreground,
        .bright_base_text = bright,
        .selected_text = bright,
        .dim_base_text = variations.emphasis.muted.apply(foreground),
        .label_dim_text = variations.emphasis.muted.apply(foreground),
        .control_text = foreground,
        .bright_control_text = bright,
        .disabled_text1 = variations.state.disabled.apply(foreground),
        .dim_list_text = variations.emphasis.subtle.apply(foreground),
        .control_bg = background,
        .control_dark_bg = raised,
        .window_bg = background,
        .selection_bg = raised,
        .selection_bg2 = raised,
        .list_bg = background,
        .title_text = foreground,
        .title_dim_text = variations.emphasis.subtle.apply(foreground),
        .slider_tick_color = foreground,
        .slider_track_color = variations.surface.sunken.apply(background),
        .border_bright = foreground,
        .border_dark = theme.roles.accent,
        .border_selection = variations.lightness.dark.apply(theme.roles.accent),
    } };
}

/// Sets every set color and the font in `file`. With nothing set, the file is not read.
pub fn apply(self: App, output: *kosm.Output) !void {
    var scheme: ?kosm.Output.Selection = null;
    inline for (@typeInfo(Colors).@"struct".field_names) |name| {
        if (@field(self.colors, name)) |color| {
            if (scheme == null) scheme = try self.edit(output);
            try scheme.?.set(.{ "Scheme", "Colors", comptime keyName(name) }, color);
        }
    }
    if (self.font) |font| {
        if (scheme == null) scheme = try self.edit(output);
        try scheme.?.setAll("Scheme.Fonts.*.*.name", font);
    }
}

fn edit(self: App, output: *kosm.Output) !kosm.Output.Selection {
    return output.edit(.{ .files = self.file, .lang = "keyvalues", .format = self.format });
}

/// The scheme's key for a field: `control_bg` is `ControlBG`, `selection_bg2` is `SelectionBG2`.
fn keyName(comptime name: []const u8) []const u8 {
    comptime var key: []const u8 = "";
    comptime var words = std.mem.splitScalar(u8, name, '_');
    inline while (comptime words.next()) |word| {
        if (comptime std.mem.startsWith(u8, word, "bg")) {
            key = key ++ "BG" ++ word[2..];
        } else {
            key = key ++ [_]u8{std.ascii.toUpper(word[0])} ++ word[1..];
        }
    }
    return key;
}

const testing = std.testing;
const adapter = @import("root.zig").keyvalues_adapter;

/// The start of the scheme the game ships, cut short.
const shipped = "Scheme\n{\n" ++
    "\tColors\n\t{\n" ++
    "\t\t\"BaseText\"\t\t\t\"216 222 211 255\"\t// used in text windows, lists\n" ++
    "\t\t\"ControlBG\"\t\t\t\"76 88 68 255\"\t\t// background color of controls\n" ++
    "\t\t\"SelectionBG2\"\t\t\"62 70 55 255\"\n" ++
    "\t}\n" ++
    "\tFonts\n\t{\n" ++
    "\t\t\"Default\"\n\t\t{\n" ++
    "\t\t\t\"1\"\n\t\t\t{\n\t\t\t\t\"name\"\t\t\"Tahoma\"\n\t\t\t\t\"tall\"\t\t\"16\"\n\t\t\t}\n" ++
    "\t\t\t\"2\"\n\t\t\t{\n\t\t\t\t\"name\"\t\t\"Arial\" [$WIN32]\n\t\t\t}\n" ++
    "\t\t}\n" ++
    "\t}\n" ++
    "}\n";

const Fixture = struct {
    tmp: testing.TmpDir,
    arena: std.heap.ArenaAllocator,
    plan: kosm.Plan,
    diagnostics: kosm.Diagnostics = .{},
    warnings: kosm.Warnings = undefined,
    home_buffer: [std.Io.Dir.max_path_bytes]u8 = undefined,
    output: kosm.Output = undefined,

    const directory = ".local/share/Steam/steamapps/common/Half-Life/valve/resource";

    fn init(fixture: *Fixture) !void {
        fixture.* = .{ .tmp = testing.tmpDir(.{}), .arena = .init(testing.allocator), .plan = .init(testing.allocator, testing.io) };
        try fixture.tmp.dir.createDirPath(testing.io, directory);
        try fixture.tmp.dir.writeFile(testing.io, .{ .sub_path = directory ++ "/TrackerScheme.res", .data = shipped });
        fixture.warnings = .init(fixture.arena.allocator());
        const length = try fixture.tmp.dir.realPath(testing.io, &fixture.home_buffer);
        fixture.output = .{
            .allocator = fixture.arena.allocator(),
            .home = fixture.home_buffer[0..length],
            .adapters = &.{adapter},
            .plan = &fixture.plan,
            .diagnostics = &fixture.diagnostics,
            .warnings = &fixture.warnings,
            .app = "counter_strike",
        };
    }

    fn deinit(fixture: *Fixture) void {
        fixture.plan.deinit();
        fixture.arena.deinit();
        fixture.tmp.cleanup();
    }
};

test "only the set colors' values and every font's name change" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app: App = .{
        .colors = .{ .base_text = kosm.hex("a3c5cc"), .selection_bg2 = kosm.hex("082e3f") },
        .font = "Maple Mono",
    };
    try app.apply(&fixture.output);
    const expected = "Scheme\n{\n" ++
        "\tColors\n\t{\n" ++
        "\t\t\"BaseText\"\t\t\t\"163 197 204 255\"\t// used in text windows, lists\n" ++
        "\t\t\"ControlBG\"\t\t\t\"76 88 68 255\"\t\t// background color of controls\n" ++
        "\t\t\"SelectionBG2\"\t\t\"8 46 63 255\"\n" ++
        "\t}\n" ++
        "\tFonts\n\t{\n" ++
        "\t\t\"Default\"\n\t\t{\n" ++
        "\t\t\t\"1\"\n\t\t\t{\n\t\t\t\t\"name\"\t\t\"Maple Mono\"\n\t\t\t\t\"tall\"\t\t\"16\"\n\t\t\t}\n" ++
        "\t\t\t\"2\"\n\t\t\t{\n\t\t\t\t\"name\"\t\t\"Maple Mono\" [$WIN32]\n\t\t\t}\n" ++
        "\t\t}\n" ++
        "\t}\n" ++
        "}\n";
    try testing.expectEqualStrings(expected, fixture.plan.files.items[0].new);
}

test "a color the scheme lacks fails naming its path" {
    var fixture: Fixture = undefined;
    try fixture.init();
    defer fixture.deinit();
    const app: App = .{ .colors = .{ .title_dim_bg = kosm.hex("000000") } };
    try testing.expectError(error.NoMatch, app.apply(&fixture.output));
    try testing.expect(std.mem.indexOf(u8, fixture.diagnostics.message(), "Scheme.Colors.TitleDimBG") != null);
}

test "every field names a key of the scheme" {
    try testing.expectEqualStrings("BaseText", comptime keyName("base_text"));
    try testing.expectEqualStrings("ControlDarkBG", comptime keyName("control_dark_bg"));
    try testing.expectEqualStrings("SelectionBG2", comptime keyName("selection_bg2"));
    try testing.expectEqualStrings("DisabledText1", comptime keyName("disabled_text1"));
}

test "the backgrounds take the theme's background alpha, the text stays opaque" {
    var theme = kosm.Theme.from(.{ .palette = .{ .black = kosm.hex("041c26"), .white = kosm.hex("a3c5cc") }, .mode = .dark });
    theme.background_alpha = 0.5;
    const colors = from(theme).colors;
    inline for (.{ colors.control_bg, colors.control_dark_bg, colors.window_bg, colors.selection_bg, colors.list_bg }) |background| {
        try testing.expectEqual(0.5, background.?.alpha);
    }
    try testing.expectEqual(1, colors.base_text.?.alpha);
}
