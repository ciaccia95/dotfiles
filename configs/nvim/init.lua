-- Neovim entrypoint.

-- Leaders must be defined before loading mappings or future plugins.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- External provider hosts are disabled until a concrete plugin requires one.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

require("antonello")
