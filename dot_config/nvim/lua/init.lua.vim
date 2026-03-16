lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "ruby", "python", "typescript", "javascript", "json", "yaml", "regex" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- neotest setup
local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-rspec")({
      rspec_cmd = function()
        return vim.tbl_flatten({ "bundle", "exec", "rspec" })
      end,
    }),
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
    }),
    require("neotest-jest")({
      jestCommand = "npx jest",
      cwd = function()
        return vim.fn.getcwd()
      end,
    }),
  },
  status = { virtual_text = true },
  output = { open_on_run = true },
})

-- keybindings (<leader>t namespace)
vim.keymap.set("n", "<leader>tn", function() neotest.run.run() end,                       { desc = "Test nearest" })
vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end,     { desc = "Test file" })
vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end,                { desc = "Test summary" })
vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end,   { desc = "Test output" })
vim.keymap.set("n", "<leader>tp", function() neotest.output_panel.toggle() end,           { desc = "Test output panel" })
vim.keymap.set("n", "<leader>tl", function() neotest.run.run_last() end,                  { desc = "Re-run last test" })
vim.keymap.set("n", "<leader>tx", function() neotest.run.stop() end,                      { desc = "Stop test" })
vim.keymap.set("n", "[t",         function() neotest.jump.prev({ status = "failed" }) end,{ desc = "Prev failed test" })
vim.keymap.set("n", "]t",         function() neotest.jump.next({ status = "failed" }) end,{ desc = "Next failed test" })

EOF
