return {
  -- Git integration (kept from previous config)
  { "tpope/vim-fugitive" },

  -- Lazygit in a floating terminal
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
      { "<leader>gl", "<cmd>LazyGitLog<CR>", desc = "LazyGit log" },
    },
  },

  -- Side-by-side diff viewer + file history
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Branch history" },
      { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
    },
    opts = {
      enhanced_diff_hl = true,
    },
  },
}
