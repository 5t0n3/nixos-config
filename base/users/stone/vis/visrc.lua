require('vis')

vis.events.subscribe(vis.events.INIT, function()
    vis:command("set tabwidth 4")
    vis:command("set autoindent")
    vis:command("set expandtab")
    vis:command("set theme gruvbox")

    vis.ftdetect.filetypes.nix = {
      ext = { "%.nix$" }
    }
end)

vis.events.subscribe(vis.events.WIN_OPEN, function(win)
    vis:command("set relativenumbers")
    vis:command("set cursorline")
    
    -- TODO: Figure out a way to set this on a per-window basis
    if win.syntax == "nix" then
      vis:command("set tabwidth 2")
    end
end)
