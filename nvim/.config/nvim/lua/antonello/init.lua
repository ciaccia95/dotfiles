require("antonello.options")

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

require("antonello.diagnostics")
require("antonello.keymaps")
require("antonello.autocmds")
