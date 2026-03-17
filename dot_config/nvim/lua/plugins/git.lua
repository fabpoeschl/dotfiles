return {
  {
    "tpope/vim-fugitive",
    config = function()
      require("config-fugitive").cfg()
    end,
    keys = {
      { "<leader>gb", ":Git blame<CR>", desc = "Git Blame" },
      { "<leader>gc", ":Git commit<CR>", desc = "Git Commit" },
      { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git Diff" },
      { "<leader>gl", ":Glog<CR>", desc = "Git Log" },
      { "<leader>gp", ":Git push<CR>", desc = "Git Push" },
      { "<leader>gP", ":Git pull<CR>", desc = "Git Pull" },
      { "<leader>gs", ":Git<CR>", desc = "Git Status" },
    },
    cmd = { "Git", "Gwrite", "Gdiffsplit", "Glog" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
