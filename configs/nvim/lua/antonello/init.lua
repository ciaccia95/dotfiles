-- Load the plugin-free editor core in a deterministic order.

require("antonello.options")

vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

require("antonello.colors")
require("antonello.diagnostics")
require("antonello.keymaps")
require("antonello.autocmds")
