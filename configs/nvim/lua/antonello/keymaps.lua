-- Portable keymaps for local and remote editing.

local map = vim.keymap.set

local function opts(description)
    return {
        desc = description,
        silent = true,
    }
end

--------------------------------------------------------------------------------
-- Navigation
--------------------------------------------------------------------------------

map("n", "n", "nzzzv", opts("Next search result and center it"))
map("n", "N", "Nzzzv", opts("Previous search result and center it"))
map("n", "<C-d>", "<C-d>zz", opts("Scroll down and center"))
map("n", "<C-u>", "<C-u>zz", opts("Scroll up and center"))

map("n", "<C-h>", "<C-w>h", opts("Focus window to the left"))
map("n", "<C-j>", "<C-w>j", opts("Focus window below"))
map("n", "<C-k>", "<C-w>k", opts("Focus window above"))
map("n", "<C-l>", "<C-w>l", opts("Focus window to the right"))

map("n", "<C-Up>", "<cmd>resize +2<CR>", opts("Increase window height"))
map("n", "<C-Down>", "<cmd>resize -2<CR>", opts("Decrease window height"))
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts("Decrease window width"))
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts("Increase window width"))

--------------------------------------------------------------------------------
-- Clipboard
--------------------------------------------------------------------------------

map({ "n", "x" }, "<leader>y", '"+y', opts("Yank to system clipboard"))
map("n", "<leader>Y", '"+Y', opts("Yank line to system clipboard"))
map({ "n", "x" }, "<leader>p", '"+p', opts("Paste system clipboard after cursor"))
map({ "n", "x" }, "<leader>P", '"+P', opts("Paste system clipboard before cursor"))

--------------------------------------------------------------------------------
-- Buffers and quickfix
--------------------------------------------------------------------------------

map("n", "[b", "<cmd>bprevious<CR>", opts("Previous buffer"))
map("n", "]b", "<cmd>bnext<CR>", opts("Next buffer"))
map("n", "<leader>bd", "<cmd>confirm bdelete<CR>", opts("Delete current buffer"))

map("n", "[q", "<cmd>silent! cprevious<CR>", opts("Previous quickfix item"))
map("n", "]q", "<cmd>silent! cnext<CR>", opts("Next quickfix item"))
map("n", "<leader>co", "<cmd>copen<CR>", opts("Open quickfix list"))
map("n", "<leader>cc", "<cmd>cclose<CR>", opts("Close quickfix list"))

--------------------------------------------------------------------------------
-- Files and application
--------------------------------------------------------------------------------

map("n", "<leader>w", "<cmd>write<CR>", opts("Write current file"))
map("n", "<leader>q", "<cmd>confirm quit<CR>", opts("Quit current window"))
map("n", "<leader>x", "<cmd>xit<CR>", opts("Write changes and quit"))

--------------------------------------------------------------------------------
-- Diagnostics
--------------------------------------------------------------------------------

map("n", "<leader>dd", function()
    vim.diagnostic.open_float({ scope = "cursor" })
end, opts("Show diagnostic at cursor"))

map("n", "<leader>dq", vim.diagnostic.setqflist, opts("Send diagnostics to quickfix"))

--------------------------------------------------------------------------------
-- Editing and display
--------------------------------------------------------------------------------

map("x", "<", "<gv", opts("Indent left and keep selection"))
map("x", ">", ">gv", opts("Indent right and keep selection"))

map("n", "<leader>ul", function()
    vim.opt_local.list = not vim.opt_local.list:get()
end, opts("Toggle invisible characters"))

map("n", "<leader>uw", function()
    vim.opt_local.wrap = not vim.opt_local.wrap:get()
end, opts("Toggle line wrapping"))

map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts("Clear search highlight"))
map("t", "<Esc><Esc>", [[<C-\><C-n>]], opts("Leave terminal mode"))
