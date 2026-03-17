local M = {}

function M.cfg()
    -- Fugitive and Git-related keymappings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Git Blame Commands
    keymap('n', '<leader>gb', ':Git blame<CR>', opts)
    
    -- Open blame in a vertical split
    keymap('n', '<leader>gbl', ':Git blame -w -L<CR>', opts)
    
    -- Copy current line's commit hash
    keymap('n', '<leader>gch', function()
        -- Extract commit hash from fugitive blame output
        local line = vim.fn.getline('.')
        local hash = line:match("^(%x+)%s")
        if hash then
            vim.fn.setreg('+', hash)
            vim.notify('Copied commit hash: ' .. hash, vim.log.levels.INFO)
        end
    end, opts)

    -- Open commit details for current line
    keymap('n', '<leader>gc', function()
        -- Extract commit hash and open in split
        local line = vim.fn.getline('.')
        local hash = line:match("^(%x+)%s")
        if hash then
            vim.cmd('Git show ' .. hash)
        end
    end, opts)

    -- Fugitive commands
    vim.api.nvim_create_user_command('Gblame', 'Git blame', {})
    
    -- Advanced blame configuration
    vim.g.fugitive_custom_blame_format = '%h %an, %cr: %s'

    -- Autocommands for specific file types
    vim.api.nvim_create_augroup('FugitiveBlame', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = 'FugitiveBlame',
        pattern = 'fugitiveblame',
        callback = function()
            -- Custom keymappings specific to blame buffer
            vim.keymap.set('n', 'q', ':q<CR>', { buffer = true, silent = true })
            vim.keymap.set('n', '<CR>', function()
                -- Open commit details when enter is pressed
                local line = vim.fn.getline('.')
                local hash = line:match("^(%x+)%s")
                if hash then
                    vim.cmd('Git show ' .. hash)
                end
            end, { buffer = true, silent = true })
        end
    })
end

return M
