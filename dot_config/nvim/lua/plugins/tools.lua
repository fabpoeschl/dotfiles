return {
  {
    "vim-test/vim-test",
    keys = {
      { "<leader>tn", "<cmd>TestNearest<cr>", desc = "Test Nearest" },
      { "<leader>tf", "<cmd>TestFile<cr>", desc = "Test File" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "suketa/nvim-dap-ruby",
      "rcarriga/nvim-dap-ui",
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle Breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>", desc = "Continue" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = "markdown",
  },
}
