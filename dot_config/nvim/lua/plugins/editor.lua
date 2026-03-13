return {
  -- Telescope (replaces fzf.vim)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
          layout_strategy = "flex",
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- Treesitter (upgraded from the minimal lua config)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufReadPost",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "ruby", "python", "typescript", "javascript", "json", "yaml",
          "regex", "lua", "vim", "vimdoc", "bash", "html", "css",
          "markdown", "markdown_inline", "dockerfile", "go",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<BS>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = { query = "@function.outer", desc = "Select outer function" },
              ["if"] = { query = "@function.inner", desc = "Select inner function" },
              ["ac"] = { query = "@class.outer", desc = "Select outer class" },
              ["ic"] = { query = "@class.inner", desc = "Select inner class" },
              ["aa"] = { query = "@parameter.outer", desc = "Select outer argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Select inner argument" },
              ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
              ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]m"] = { query = "@function.outer", desc = "Next function start" },
              ["]]"] = { query = "@class.outer", desc = "Next class start" },
              ["]a"] = { query = "@parameter.inner", desc = "Next argument" },
            },
            goto_next_end = {
              ["]M"] = { query = "@function.outer", desc = "Next function end" },
              ["]["] = { query = "@class.outer", desc = "Next class end" },
            },
            goto_previous_start = {
              ["[m"] = { query = "@function.outer", desc = "Previous function start" },
              ["[["] = { query = "@class.outer", desc = "Previous class start" },
              ["[a"] = { query = "@parameter.inner", desc = "Previous argument" },
            },
            goto_previous_end = {
              ["[M"] = { query = "@function.outer", desc = "Previous function end" },
              ["[]"] = { query = "@class.outer", desc = "Previous class end" },
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>a"] = { query = "@parameter.inner", desc = "Swap with next argument" } },
            swap_previous = { ["<leader>A"] = { query = "@parameter.inner", desc = "Swap with previous argument" } },
          },
        },
      })
    end,
  },

  -- Extended text objects (better a)/i), adds aq/iq for quotes, af/if for function calls, etc.)
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function()
      local ai = require("mini.ai")
      ai.setup({
        n_lines = 500,
        custom_textobjects = {
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
        },
      })
    end,
  },

  -- Surround (replaces vim-surround)
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Which-key (keybinding discovery)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({ preset = "modern" })
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Diff" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunk" },
        { "<leader>q", group = "Session" },
        { "<leader>r", group = "Refactor" },
        { "<leader>s", group = "Surround" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>?", function() vim.cmd("Telescope keymaps") end, desc = "Search all keymaps" },
        { "<leader>/", function() vim.cmd("help cheatsheet") end, desc = "Cheatsheet" },
      })
    end,
  },

  -- Undo tree (replaces gundo)
  {
    "mbbill/undotree",
    keys = {
      { "<leader>G", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
    },
  },

  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({})
      -- Integrate with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Comment line" },
      { "gc", mode = "v", desc = "Comment selection" },
    },
    opts = {},
  },

  -- Flash (jump anywhere with 2-3 keystrokes)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
    },
    opts = {},
  },

  -- Trouble (better diagnostics/references list)
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix list" },
      { "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", desc = "LSP references" },
    },
    opts = {},
  },

  -- Todo comments (highlight and search TODO/FIXME/HACK/etc.)
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "TODOs (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
    },
    opts = {},
  },

  -- Session management (replaces manual :mksession)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
    opts = {},
  },
}
