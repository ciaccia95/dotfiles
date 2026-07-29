local opt = vim.opt

--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

-- Keep the terminal responsible for the palette.
opt.background = "dark"
opt.termguicolors = false

-- Show the current line as an absolute number and all other lines as relative.
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4

-- Reserve a stable column for diagnostics and future Git signs.
opt.signcolumn = "yes"

-- Make the active line easier to locate without imposing custom colors.
opt.cursorline = true

-- Keep useful context visible while moving through a file.
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.smoothscroll = true

-- Use one global status line and consistent borders for floating windows.
opt.laststatus = 3
opt.winborder = "rounded"

-- Remove decorative end-of-buffer tildes and the startup message.
opt.fillchars:append({ eob = " " })
opt.shortmess:append("I")

--------------------------------------------------------------------------------
-- Indentation and wrapping
--------------------------------------------------------------------------------

-- Use four spaces by default. Filetype plugins and EditorConfig may override it.
opt.expandtab = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

opt.autoindent = true
opt.smartindent = true

-- Do not wrap by default, but preserve readable indentation when it is enabled.
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

--------------------------------------------------------------------------------
-- Search and commands
--------------------------------------------------------------------------------

-- Search case-insensitively unless the pattern contains an uppercase letter.
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- Preview substitutions in a split before applying them.
opt.inccommand = "split"

-- Make built-in command-line completion compact and predictable.
opt.wildmode = { "longest:full", "full" }
opt.wildoptions = { "pum", "tagfile" }

--------------------------------------------------------------------------------
-- Completion
--------------------------------------------------------------------------------

opt.completeopt = { "menu", "menuone", "noselect", "popup" }
opt.pumheight = 12

--------------------------------------------------------------------------------
-- Files and recovery
--------------------------------------------------------------------------------

-- Persist completed changes between sessions.
opt.undofile = true

-- Keep swap files enabled to recover unsaved work after a crash or disconnect.
-- Neovim stores them below stdpath("state"), not beside project files.
opt.swapfile = true

-- Do not retain backup copies, but keep the temporary write-safety backup.
opt.backup = false
opt.writebackup = true

-- Notice changes made by external tools.
opt.autoread = true

-- Ask before abandoning modified buffers.
opt.confirm = true

--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------

opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

--------------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------------

opt.mouse = "a"
opt.backspace = { "indent", "eol", "start" }
opt.virtualedit = "block"

-- The default registers remain local to Neovim. System clipboard access is
-- explicit through leader mappings, which also works predictably over SSH.
opt.clipboard = ""

-- Invisible characters are available on demand with the list toggle mapping.
opt.list = false
opt.listchars = {
    tab = "» ",
    trail = "·",
    extends = "›",
    precedes = "‹",
    nbsp = "␣",
}

--------------------------------------------------------------------------------
-- Responsiveness
--------------------------------------------------------------------------------

opt.updatetime = 250
opt.timeoutlen = 400

--------------------------------------------------------------------------------
-- External search
--------------------------------------------------------------------------------

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --vimgrep --smart-case"
    opt.grepformat = "%f:%l:%c:%m"
end
