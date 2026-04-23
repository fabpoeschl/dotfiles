return {
  {
    "tpope/vim-rails",
    ft = {
      "ruby",
      "eruby",
      "haml",
      "slim",
      "yaml",
      "dockerfile",
      "gitconfig",
      "javascript",
      "typescript",
    },
    lazy = true,
  },
  {
    "tpope/vim-bundler",
    ft = "ruby",
  },
  {
    "tpope/vim-rake",
    ft = "ruby",
  },
  {
    "tpope/vim-projectionist",
    lazy = true,
    dependencies = "tpope/vim-rails",
  },
  {
    "slim-template/vim-slim",
    ft = "slim",
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = "InsertEnter",
    dependencies = "nvim-treesitter/nvim-treesitter",
  },
}
