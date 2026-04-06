local M = {}

function M.cfg()

  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')

  vim.keymap.set('n', '<leader>fp', builtin.git_files)
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})  -- Find files

  vim.keymap.set('n', '<leader>fg', function()
    local opts = {}

    -- Ask for directories (comma-separated) and split them into a table
    local dirs_input = vim.fn.input('Directories (comma-separated, leave empty for all): ')
    if dirs_input ~= "" then
      opts.search_dirs = vim.split(dirs_input, ",%s*") -- Split input into a table
    end

    -- Ask for file type filter (optional)
    local file_type = vim.fn.input('File type (e.g., *.lua, leave empty for all): ')
    if file_type ~= "" then
      opts.additional_args = function() return { "--glob=" .. file_type } end
    end

    require('telescope.builtin').live_grep(opts)
  end, { noremap = true, silent = false })
 
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})  -- Switch buffers
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})  -- Search help
  vim.keymap.set('n', '<leader>fk', builtin.keymaps, {})

  require("telescope").setup({
    defaults = {
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      mappings = {
        i = {
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        },
        n = {
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
          ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        },
      },
    },
    pickers = {
      buffers = {
        sort_lastused = true,
        theme = "dropdown",
      },
      find_files = {
        theme = "dropdown",
      },
      git_files = {
        theme = "dropdown",
      },
      live_grep = {
        theme = "dropdown",
      },
      lsp_code_actions = {
        theme = "cursor",
      },
      lsp_definitions = {
        theme = "cursor",
      },
      lsp_document_diagnostics = {
        theme = "cursor",
      },
      lsp_implementations = {
        theme = "cursor",
      },
      lsp_references = {
        theme = "cursor",
      },
      lsp_workspace_diagnostics = {
        theme = "cursor",
      },
      oldfiles = {
        theme = "dropdown",
      },
      registers = {
        theme = "cursor",
      },
      search_history = {
        theme = "dropdown",
      },
      spell_suggest = {
        theme = "dropdown",
      },
      tags = {
        theme = "dropdown",
      },
    },
  })
end

return M
