local function cfg()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "python",
      "regex",
      "ruby",
      "rust",
      "scss",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    highlight = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    endwise = { enable = true },
  })

  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldlevel = 99
end

local M = {}
M.cfg = cfg
return M
