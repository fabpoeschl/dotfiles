-- File: ~/.config/nvim/lua/plugins/avante_integration.lua

local M = {}

-- Main setup function
function M.cfg()
  vim.api.nvim_create_user_command("AvanteAskQF", function(opts)
    local prompt = opts.args or "Explain this code"
    vim.cmd("cdo AvanteAsk " .. vim.fn.shellescape(prompt))
  end, { nargs = "?" })
  vim.keymap.set('n', '<leader>aaq', ':AvanteAskQF<CR>', { noremap = true, silent = true })
  
  vim.api.nvim_create_user_command("AvanteEditQF", function(opts)
    vim.cmd("cdo AvanteEdit ")
  end, { nargs = "?" })
  vim.keymap.set('n', '<leader>aeq', ':AvanteEditQF<CR>', { noremap = true, silent = true })

  -- Setup Avante
  require('avante').setup({
    ask = {
      -- Store suggestions in quickfix list
      output_to_quickfix = true,
      -- Enable code execution
      allow_execution = true,
      -- Configure context
      context_lines = 10,
      -- Configure modification templates
      templates = {
        refactor = "Refactor this code to improve readability and performance",
        document = "Add comprehensive documentation to this code",
        test = "Generate unit tests for this code",
        optimize = "Optimize this code for performance"
      }
    }
  })
  
  -- Load Avante extension for telescope
  -- require('telescope').load_extension('avante')
end

return M
