local opt = vim.opt

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------

-- La palette appartiene al terminale, non a Neovim.
opt.termguicolors = false

-- Mostra il numero assoluto sulla riga corrente e relativo sulle altre.
opt.number = true
opt.relativenumber = true

-- Mantiene sempre disponibile la colonna usata da diagnostica e Git.
-- Evita che il testo si sposti quando compare un segno.
opt.signcolumn = "yes"

-- Evidenzia la riga corrente senza imporre colori specifici.
opt.cursorline = true

-- Mantiene alcune righe visibili sopra e sotto il cursore.
opt.scrolloff = 8
opt.sidescrolloff = 8

--------------------------------------------------------------------------------
-- Indentation
--------------------------------------------------------------------------------

-- Usa spazi invece dei caratteri tab.
opt.expandtab = true

-- Numero di spazi inseriti con Tab.
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4

-- Mantiene automaticamente l'indentazione della riga precedente.
opt.autoindent = true
opt.smartindent = true

--------------------------------------------------------------------------------
-- Search
--------------------------------------------------------------------------------

-- Ignora maiuscole e minuscole durante la ricerca.
opt.ignorecase = true

-- Ripristina la distinzione quando la ricerca contiene lettere maiuscole.
opt.smartcase = true

-- Mostra i risultati mentre si digita.
opt.incsearch = true

-- Evidenzia tutte le corrispondenze.
opt.hlsearch = true

--------------------------------------------------------------------------------
-- Files
--------------------------------------------------------------------------------

-- Mantiene una cronologia persistente delle modifiche.
opt.undofile = true

-- Evita la creazione dei file di backup accanto ai file modificati.
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Rileva modifiche effettuate esternamente al file.
opt.autoread = true

--------------------------------------------------------------------------------
-- Windows
--------------------------------------------------------------------------------

-- Apre gli split nella direzione naturale.
opt.splitright = true
opt.splitbelow = true

--------------------------------------------------------------------------------
-- Editing
--------------------------------------------------------------------------------

-- Abilita il mouse soltanto dove utile.
opt.mouse = "a"

-- Usa la clipboard di sistema.
opt.clipboard = "unnamedplus"

-- Permette Backspace su , fine riga e inizio inserimento.
opt.backspace = { "indent", "eol", "start" }

-- Non manda automaticamente il testo a capo.
opt.wrap = false

-- Mostra caratteri invisibili solo quando richiesto con :set list.
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

-- Riduce il ritardo di aggiornamento per diagnostica e plugin futuri.
opt.updatetime = 250

-- Tempo massimo per completare una sequenza di tasti.
opt.timeoutlen = 500

-- Chiede conferma invece di fallire quando un buffer ha modifiche non salvate.
opt.confirm = true
