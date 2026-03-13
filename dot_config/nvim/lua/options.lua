local opt = vim.opt

-- Leader (must be set before plugins)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- Indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- UI
opt.number = true
opt.showcmd = true
opt.showmode = true
opt.cursorline = false
opt.wildmenu = true
opt.lazyredraw = true
opt.showmatch = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.updatetime = 200

-- Searching
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.wrapscan = true

-- Folding
opt.foldenable = true
opt.foldlevelstart = 10
opt.foldnestmax = 10
opt.foldmethod = "indent"

-- Clipboard
opt.clipboard = "unnamedplus"

-- No swap/backup
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- History
opt.history = 10000
opt.undolevels = 1000

-- Misc
opt.visualbell = true
opt.matchpairs:append("<:>")
opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 8

-- Grep (use ripgrep if available)
if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case"
  opt.grepformat = "%f:%l:%c:%m"
end

-- Dictionary
if vim.fn.filereadable("/usr/share/dict/words") == 1 then
  opt.dictionary:append("/usr/share/dict/words")
end
