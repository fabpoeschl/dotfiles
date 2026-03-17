local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local config_dir = vim.fn.stdpath('config')
package.path = package.path .. ";" .. config_dir .. "/lua/?.lua"

-- configure leader Key
vim.g.mapleader = ','
vim.g.maplocalleader = ','

require("options")
require("lazy").setup({
    spec = "plugins",
    install = { missing = true }
})

require("auto-dark-mode").init()
require("keymaps")

-- Change colors for Ruby instance variables
vim.cmd([[autocmd FileType ruby highlight rubyInstanceVar guifg=#FF6347]])

-- Change colors for Ruby function calls
vim.cmd([[autocmd FileType ruby highlight rubyFunction guifg=#4682B4]])
