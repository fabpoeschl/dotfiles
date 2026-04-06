local M = {}

function M.cfg()
    -- Import nvim-tree safely
    local status_ok, nvim_tree = pcall(require, "nvim-tree")
    if not status_ok then
        return
    end

    -- Recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- Configure nvim-tree
    nvim_tree.setup({
        -- General settings
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        hijack_cursor = true,
        hijack_unnamed_buffer_when_opening = false,
        
        -- UI and view settings
        view = {
            width = 30,
            side = "left",
            number = false,
            relativenumber = false,
            signcolumn = "yes"
        },
        
        -- Rendering options
        renderer = {
            root_folder_modifier = ":t",
            icons = {
                glyphs = {
                    default = "",
                    symlink = "",
                    folder = {
                        arrow_open = "",
                        arrow_closed = "",
                        default = "",
                        open = "",
                        empty = "",
                        empty_open = "",
                        symlink = "",
                        symlink_open = "",
                    },
                    git = {
                        unstaged = "✗",
                        staged = "✓",
                        unmerged = "",
                        renamed = "➜",
                        untracked = "★",
                        deleted = "",
                        ignored = "◌"
                    }
                }
            },
            special_files = { 
                "Cargo.toml", 
                "Makefile", 
                "README.md", 
                "readme.md", 
                "CMakeLists.txt" 
            },
            symlink_destination = true
        },
        
        -- File filtering and ignore rules
        filters = {
            dotfiles = false,
            custom = { 
                ".git", 
                "node_modules", 
                ".cache", 
                "__pycache__" 
            },
            exclude = { ".env", ".gitignore" }
        },
        
        -- Git integration
        git = {
            enable = true,
            ignore = false,
            show_on_dirs = true,
            timeout = 400
        },
        
        -- Actions and interactions
        actions = {
            change_dir = {
                enable = true,
                global = false,
            },
            open_file = {
                quit_on_open = false,
                resize_window = true,
                window_picker = {
                    enable = true,
                    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                    exclude = {
                        filetype = { 
                            "notify", 
                            "packer", 
                            "qf", 
                            "diff", 
                            "fugitive", 
                            "fugitiveblame" 
                        },
                        buftype = { 
                            "nofile", 
                            "terminal", 
                            "help" 
                        }
                    }
                }
            }
        },
        
        -- Live filtering
        live_filter = {
            prefix = "[FILTER]: ",
            always_show_folders = true
        }
    })

    -- Set up keymappings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- File tree toggles and navigation
    keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
    keymap('n', '<leader>tf', ':NvimTreeFocus<CR>', opts)
    keymap('n', '<leader>tr', ':NvimTreeRefresh<CR>', opts)
    keymap('n', '<leader>tc', ':NvimTreeCollapse<CR>', opts)

    -- File operations from tree
    local tree_api = require("nvim-tree.api")
    keymap('n', '<leader>ta', function() 
        tree_api.fs.create() 
    end, { desc = "Create File/Directory" })

    keymap('n', '<leader>td', function() 
        tree_api.fs.remove() 
    end, { desc = "Delete File/Directory" })

    keymap('n', '<leader>tr', function() 
        tree_api.fs.rename() 
    end, { desc = "Rename File/Directory" })

    -- Optional: Auto-open on startup
    vim.api.nvim_create_autocmd({"VimEnter"}, {
        callback = function(data)
            -- Buffer is a directory
            local directory = vim.fn.isdirectory(data.file) == 1
            if directory then
                require("nvim-tree.api").tree.open({ path = data.file })
            end
        end
    })
end

return M
