local wezterm = require("wezterm")
local platform = require("utils.platform")()
local act = wezterm.action

local mod = {}

if platform.is_mac then
    mod.SUPER = "SUPER"
    mod.SUPER_REV = "SUPER|CTRL"
elseif platform.is_win or platform.is_linux then
    mod.SUPER = "ALT" -- to not conflict with Windows key shortcuts
    mod.SUPER_REV = "ALT|CTRL"
end

local keys = {
    -- Quit Application
    { key = 'q', mods = 'LEADER',      action = act.QuitApplication },
    { key = 'q', mods = 'CMD',         action = act.QuitApplication },

    -- misc/useful --
    { key = "c", mods = "LEADER",      action = "ActivateCopyMode" },
    { key = "C", mods = "LEADER",      action = act.ActivateCommandPalette },

    { key = "T", mods = "CTRL|ALT",    action = act.ShowLauncher },
    { key = "n", mods = "LEADER",      action = act.ShowTabNavigator },
    { key = "F", mods = "LEADER",      action = act.ToggleFullScreen },
    { key = "d", mods = "LEADER",      action = act.ShowDebugOverlay },
    { key = "f", mods = "CTRL|SHIFT",  action = act.Search({ CaseInSensitiveString = "" }) },

    -- copy/paste --
    { key = "c", mods = "CTRL|SHIFT",  action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CTRL|SHIFT",  action = act.PasteFrom("Clipboard") },
    { key = "c", mods = "CMD",         action = act.CopyTo("Clipboard") },
    { key = "v", mods = "CMD",         action = act.PasteFrom("Clipboard") },

    -- tabs --
    -- tabs: spawn+close
    { key = "t", mods = "CTRL",        action = act.SpawnTab("DefaultDomain") },
    { key = "t", mods = "CMD",         action = act.SpawnTab("DefaultDomain") },
    { key = "t", mods = "CTRL|ALT",    action = act.SpawnTab({ DomainName = "WSL:archlinux" }) },

    { key = "w", mods = "CTRL|ALT",    action = act.CloseCurrentTab({ confirm = true }) },

    -- tabs: navigation
    { key = "[", mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
    { key = "]", mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
    { key = "[", mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    { key = "]", mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

    -- window --
    -- spawn windows
    { key = "n", mods = "CTRL|SHIFT",  action = act.SpawnWindow },

    -- panes --
    -- panes: split panes
    {
        key = [[/]],
        mods = mod.SUPER_REV,
        action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
    },
    {
        key = [[\]],
        mods = mod.SUPER_REV,
        action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        key = [[-]],
        mods = mod.SUPER_REV,
        action = act.CloseCurrentPane({ confirm = true }),
    },

    -- panes: zoom+close pane
    { key = "z",          mods = mod.SUPER_REV, action = act.TogglePaneZoomState },
    { key = "w",          mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

    -- panes: navigation
    { key = "k",          mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Up") },
    { key = "j",          mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Down") },
    { key = "h",          mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Left") },
    { key = "l",          mods = mod.SUPER_REV, action = act.ActivatePaneDirection("Right") },

    -- panes: resize
    { key = "UpArrow",    mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "DownArrow",  mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "LeftArrow",  mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "RightArrow", mods = mod.SUPER_REV, action = act.AdjustPaneSize({ "Right", 1 }) },

    -- fonts --
    -- fonts: resize
    { key = "UpArrow",    mods = mod.SUPER,     action = act.IncreaseFontSize },
    { key = "DownArrow",  mods = mod.SUPER,     action = act.DecreaseFontSize },
    { key = "r",          mods = mod.SUPER,     action = act.ResetFontSize },

    -- key-tables --
    -- resizes fonts
    {
        key = "f",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "resize_font",
            one_shot = false,
            timemout_miliseconds = 1000,
        }),
    },
    -- resize panes
    {
        key = "p",
        mods = "LEADER",
        action = act.ActivateKeyTable({
            name = "resize_pane",
            one_shot = false,
            timemout_miliseconds = 1000,
        }),
    },
    -- rename tab bar
    {
        key = "R",
        mods = "CTRL|SHIFT",
        action = act.PromptInputLine({
            description = "Enter new name for tab",
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        }),
    },

    { key = "1", mods = 'CTRL', action = act.ActivateTab(0) },
    { key = "2", mods = 'CTRL', action = act.ActivateTab(1) },
    { key = "3", mods = 'CTRL', action = act.ActivateTab(2) },
    { key = "4", mods = 'CTRL', action = act.ActivateTab(3) },
    { key = "5", mods = 'CTRL', action = act.ActivateTab(4) },
    { key = "6", mods = 'CTRL', action = act.ActivateTab(5) },
    { key = "7", mods = 'CTRL', action = act.ActivateTab(6) },
    { key = "8", mods = 'CTRL', action = act.ActivateTab(7) },
    { key = "9", mods = 'CTRL', action = act.ActivateTab(8) },
}

local key_tables = {
    resize_font = {
        { key = "k",      action = act.IncreaseFontSize },
        { key = "j",      action = act.DecreaseFontSize },
        { key = "r",      action = act.ResetFontSize },
        { key = "Escape", action = "PopKeyTable" },
        { key = "q",      action = "PopKeyTable" },
    },
    resize_pane = {
        { key = "k",      action = act.AdjustPaneSize({ "Up", 1 }) },
        { key = "j",      action = act.AdjustPaneSize({ "Down", 1 }) },
        { key = "h",      action = act.AdjustPaneSize({ "Left", 1 }) },
        { key = "l",      action = act.AdjustPaneSize({ "Right", 1 }) },
        { key = "Escape", action = "PopKeyTable" },
        { key = "q",      action = "PopKeyTable" },
    },
}

local mouse_bindings = {
    -- Ctrl-click will open the link under the mouse cursor
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = act.OpenLinkAtMouseCursor,
    },
    -- Move mouse will only select text and not copy text to clipboard
    {
        event = { Down = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = act.SelectTextAtMouseCursor("Cell"),
    },
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = act.ExtendSelectionToMouseCursor("Cell"),
    },
    {
        event = { Drag = { streak = 1, button = "Left" } },
        mods = "NONE",
        action = act.ExtendSelectionToMouseCursor("Cell"),
    },
    -- Triple Left click will select a line
    {
        event = { Down = { streak = 3, button = "Left" } },
        mods = "NONE",
        action = act.SelectTextAtMouseCursor("Line"),
    },
    {
        event = { Up = { streak = 3, button = "Left" } },
        mods = "NONE",
        action = act.SelectTextAtMouseCursor("Line"),
    },
    -- Double Left click will select a word
    {
        event = { Down = { streak = 2, button = "Left" } },
        mods = "NONE",
        action = act.SelectTextAtMouseCursor("Word"),
    },
    {
        event = { Up = { streak = 2, button = "Left" } },
        mods = "NONE",
        action = act.SelectTextAtMouseCursor("Word"),
    },
    -- Turn on the mouse wheel to scroll the screen
    {
        event = { Down = { streak = 1, button = { WheelUp = 1 } } },
        mods = "NONE",
        action = act.ScrollByCurrentEventWheelDelta,
    },
    {
        event = { Down = { streak = 1, button = { WheelDown = 1 } } },
        mods = "NONE",
        action = act.ScrollByCurrentEventWheelDelta,
    },
}

return {
    disable_default_key_bindings = true,
    disable_default_mouse_bindings = true,
    leader = { key = "a", mods = "CTRL", timemout_miliseconds = 1000 },
    keys = keys,
    key_tables = key_tables,
    mouse_bindings = mouse_bindings,
}
