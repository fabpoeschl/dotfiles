return {
  {
    "tpope/vim-fugitive",
    config = function()
      require("config-fugitive").cfg()

      -- Blame tracing through file moves / copies (blame-origin alias)
      vim.api.nvim_create_user_command("BlameOrigin", function()
        vim.cmd("Git blame -w -C -C -C")
      end, {})

      -- Pickaxe search: find commits that introduced/removed a string
      vim.api.nvim_create_user_command("GitSearch", function(opts)
        local query = opts.args ~= "" and opts.args or vim.fn.input("Search: ")
        if query == "" then return end
        vim.cmd("Git log -S " .. vim.fn.shellescape(query))
      end, { nargs = "?" })
    end,
    keys = {
      { "<leader>gb", ":Git blame<CR>",        desc = "Git Blame" },
      { "<leader>gB", ":BlameOrigin<CR>",       desc = "Git Blame (origin)" },
      { "<leader>gc", ":Git commit<CR>",        desc = "Git Commit" },
      { "<leader>gd", ":Gdiffsplit<CR>",        desc = "Git Diff" },
      { "<leader>gl", ":Glog<CR>",              desc = "Git Log" },
      { "<leader>gp", ":Git push<CR>",          desc = "Git Push" },
      { "<leader>gP", ":Git pull<CR>",          desc = "Git Pull" },
      { "<leader>gs", ":Git<CR>",               desc = "Git Status" },
      { "<leader>gS", ":GitSearch<CR>",         desc = "Git Search (pickaxe)" },
    },
    cmd = { "Git", "Gwrite", "Gdiffsplit", "Glog", "BlameOrigin", "GitSearch" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },
}
