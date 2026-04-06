local M = {}

function M.cfg()
    local copilot_chat = require("CopilotChat")

    -- Configure Copilot Chat with sensible defaults and useful keymappings
    copilot_chat.setup({
        -- General plugin options
        debug = false, -- Disable debug mode by default
        default_bindings = false, -- Disable default bindings to customize fully
        
        -- Prompts configuration
        prompts = {
            -- Predefined helpful prompts
            Explain = "Explain the selected code or current buffer's code in detail.",
            Review = "Review the selected code and provide constructive feedback.",
            Tests = "Generate unit tests for the selected code or current buffer.",
            Fix = "Help fix any issues in the selected code.",
            Optimize = "Suggest optimizations for the current code.",
            Docs = "Generate documentation for the selected code or function."
        },
        
        -- Window configuration
        window = {
            layout = 'float',  -- Floating window layout
            width = 0.8,       -- 80% of screen width
            height = 0.7,      -- 70% of screen height
            border = 'rounded' -- Rounded border for the chat window
        },
 
        
        -- Contextual behavior
        context = 'buffer',  -- Use current buffer context by default
        
        -- Saving and loading
        save_history = true,  -- Save chat history
        history_path = vim.fn.stdpath('data') .. '/copilot_chat_history',
        
        -- Autocompletion settings
        auto_follow_cursor = true,  -- Follow cursor in chat window
        auto_insert_mode = true,    -- Automatically enter insert mode in chat
    })

    vim.keymap.set('n', '<leader>cc', function() copilot_chat.open() end, { desc = 'Open Copilot Chat' })
    vim.keymap.set('n', '<leader>ce', function() copilot_chat.ask("Explain this code") end, { desc = 'Explain Code' })
    vim.keymap.set('v', '<leader>cr', function() copilot_chat.ask("Review this code") end, { desc = 'Review Selected Code' })
    vim.keymap.set('n', '<leader>cf', function() copilot_chat.ask("Help me fix this code") end, { desc = 'Fix Code' })
    vim.keymap.set('n', '<leader>ct', function() copilot_chat.ask("Generate unit tests") end, { desc = 'Generate Tests' })
    vim.keymap.set('n', '<leader>co', function() copilot_chat.ask("Optimize this code") end, { desc = 'Optimize Code' })
    vim.keymap.set('n', '<leader>cd', function() copilot_chat.ask("Generate documentation") end, { desc = 'Generate Docs' })
    vim.keymap.set('n', '<leader>cx', function() copilot_chat.close() end, { desc = 'Close Copilot Chat' })
  
    -- Optional: Custom command to quickly open Copilot Chat
    vim.api.nvim_create_user_command('CopilotChatOpen', function()
        copilot_chat.open()
    end, {})

    -- Optional: Telescope integration for prompt selection
    -- local telescope_ok, telescope = pcall(require, 'telescope')
    -- if telescope_ok then
    --     telescope.load_extension('copilot')
    -- end
end

return M
