local platform = require("utils.platform")()

local options = {
    default_prog = {},
    launch_menu = {},
}

if platform.is_win then
    options.default_prog = { "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe" }
    options.launch_menu = {
        { label = " PowerShell v1", args = { "powershell" } },
        { label = " PowerShell v7", args = { "C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe" } },
        {
            label = " archlinux wsl",
            args = { "wsl", "-d", "archlinux" },
        },
        { label = " Cmd", args = { "cmd" } },
    }
elseif platform.is_mac then
    options.default_prog = { "/opt/homebrew/bin/fish", "--login" }
    options.launch_menu = {
        { label = " Bash", args = { "bash", "--login" } },
        { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
        { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
        { label = " Zsh", args = { "zsh", "--login" } },
    }
elseif platform.is_linux then
    options.default_prog = { "bash", "--login" }
    options.launch_menu = {
        { label = " Bash", args = { "bash", "--login" } },
        { label = " Fish", args = { "/opt/homebrew/bin/fish", "--login" } },
        { label = " Nushell", args = { "/opt/homebrew/bin/nu", "--login" } },
        { label = " Zsh", args = { "zsh", "--login" } },
    }
end

return options
