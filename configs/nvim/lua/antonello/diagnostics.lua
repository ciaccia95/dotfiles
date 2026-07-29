-- Diagnostic presentation shared by local and remote sessions.

vim.diagnostic.config({
    severity_sort = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_lines = false,
    virtual_text = false,
    float = {
        border = "rounded",
        source = true,
    },
})
