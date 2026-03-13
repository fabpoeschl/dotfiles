local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text briefly
autocmd("TextYankPost", {
  group = augroup("YankHighlight", {}),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- Restore cursor position on file open
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", {}),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lines = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Resize splits on window resize
autocmd("VimResized", {
  group = augroup("AutoResize", {}),
  command = "tabdo wincmd =",
})

-- Remove trailing whitespace on save (opt-in per filetype)
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", {}),
  pattern = { "*.lua", "*.rb", "*.py", "*.js", "*.ts", "*.sh", "*.vim", "*.zsh" },
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})
