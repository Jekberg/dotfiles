--[[
  _   _ _____ _____     _____ __  __
 | \ | | ____/ _ \ \   / /_ _|  \/  |
 |  \| |  _|| | | \ \ / / | || |\/| |
 | |\  | |__| |_| |\ V /  | || |  | |
 |_| \_|_____\___/  \_/  |___|_|  |_|

  _    _   _   _      ___ _   _ ___ _____
 | |  | | | | / \    |_ _| \ | |_ _|_   _|
 | |  | | | |/ _ \    | ||  \| || |  | |
 | |__| |_| / ___ \ _ | || |\  || |  | |
 |_____\___/_/   \_(_)___|_| \_|___| |_|
]]--

require("config.lazy")
require("style")
require("lsp")

vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.expandtab      = true
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4

vim.opt.cursorline     = true
vim.opt.cursorlineopt  = 'number'

vim.diagnostic.config({
    virtual_text = true,
})

vim.treesitter.start()
