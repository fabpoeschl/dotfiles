local opt = vim.opt

opt.termguicolors = true

opt.showmatch = true
opt.number = true
opt.cursorline = true
opt.clipboard='unnamedplus'

opt.updatetime = 300

-- use global statusline
opt.laststatus = 3

opt.incsearch = true -- search as characters are entered
opt.hlsearch = true -- highlight search results
opt.ignorecase = true
opt.smartcase = true

opt.completeopt = { 'menuone', 'noselect' }

-- mouse mode
vim.opt.mouse = "a"

opt.wrap = false
opt.matchtime = 2

-- Ruby specific settings
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2

opt.encoding = 'utf-8'
opt.fileencoding = 'utf-8'

-- Add Ruby file types to auto-formatting
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "eruby", "rake" },
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.tabstop = 2
  end,
})
