-- Event-driven editor behavior.

local api = vim.api
local group = api.nvim_create_augroup("antonello", { clear = true })
local highlight_on_yank = (vim.hl and vim.hl.on_yank) or vim.highlight.on_yank

api.nvim_create_autocmd("TextYankPost", {
    group = group,
    desc = "Briefly highlight yanked text",
    callback = function()
        highlight_on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = group,
    desc = "Check whether files changed outside Neovim",
    callback = function()
        if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
})

api.nvim_create_autocmd("VimResized", {
    group = group,
    desc = "Equalize splits after resizing the UI",
    callback = function()
        vim.cmd("wincmd =")
    end,
})

api.nvim_create_autocmd("BufReadPost", {
    group = group,
    desc = "Restore the last cursor position",
    callback = function(event)
        local excluded = {
            gitcommit = true,
            gitrebase = true,
        }

        if excluded[vim.bo[event.buf].filetype] then
            return
        end

        local mark = api.nvim_buf_get_mark(event.buf, '"')
        local line_count = api.nvim_buf_line_count(event.buf)

        if mark[1] > 0 and mark[1] <= line_count and api.nvim_get_current_buf() == event.buf then
            pcall(api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "checkhealth", "help", "lspinfo", "man", "qf" },
    desc = "Use q to close temporary utility windows",
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", {
            buffer = event.buf,
            desc = "Close utility window",
            silent = true,
        })
    end,
})

api.nvim_create_autocmd("TermOpen", {
    group = group,
    desc = "Hide editor UI columns in terminal buffers",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})
