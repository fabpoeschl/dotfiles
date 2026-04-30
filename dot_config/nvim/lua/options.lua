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

-- Auto-load .nvim.lua / .nvimrc / .exrc from the cwd. Trust per file via
-- :trust (state in stdpath('state')/trust). Used to override settings like
-- vim.g.dap_remote_root on a per-project basis.
opt.exrc = true

-- Load per-project config from ~/.config/nvim/projects/<repo-name>.lua.
-- The project name is derived from the git common dir so the same file is
-- used across all linked worktrees. Files live outside the dotfiles repo
-- (excluded via .gitignore / .chezmoiignore) for machine-local settings.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local out = vim.fn.system("git rev-parse --git-common-dir 2>/dev/null")
    if vim.v.shell_error ~= 0 then return end
    local git_common = vim.trim(out)
    if git_common:sub(1, 1) ~= "/" then
      git_common = vim.fn.getcwd() .. "/" .. git_common
    end
    local project_name = vim.fn.fnamemodify(git_common, ":h:t")
    local cfg = vim.fn.stdpath("config") .. "/projects/" .. project_name .. ".lua"
    if vim.fn.filereadable(cfg) == 1 then
      dofile(cfg)
    end
  end,
})

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
