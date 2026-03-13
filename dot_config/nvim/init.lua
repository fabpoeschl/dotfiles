-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Core settings (before plugins)
require("options")
require("keymaps")
require("autocmds")

-- Plugins
require("lazy").setup("plugins", {
  defaults = { lazy = false },
  install = { colorscheme = { "gruvbox" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
