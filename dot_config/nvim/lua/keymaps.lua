local map = vim.keymap.set

-- jk to escape
map("i", "jk", "<Esc>")

-- Move by visual line
map("n", "j", "gj")
map("n", "k", "gk")

-- Beginning/end of line
map("n", "B", "^")
map("n", "E", "$")

-- Clear search highlight
map("n", "<leader><space>", ":nohlsearch<CR>", { silent = true })

-- Folding with space
map("n", "<space>", "za")

-- Save / quit
map("n", "<leader>w", ":w!<CR>")
map("n", "<leader>q", ":q<CR>", { silent = true })

-- System clipboard
map({ "n", "v" }, "<leader>y", '"+y')
map({ "n", "v" }, "<leader>x", '"+x')
map({ "n", "v" }, "<leader>p", '"+p')
map({ "n", "v" }, "<C-c>", '"+y')

-- Tab navigation (kept from vimrc)
map("n", "<C-t>", ":tabnew<CR>")
map("n", "th", ":tabfirst<CR>")
map("n", "tk", ":tabnext<CR>")
map("n", "tj", ":tabprev<CR>")
map("n", "tl", ":tablast<CR>")
map("n", "tt", ":tabedit<Space>")
map("n", "tn", ":tabnext<Space>")
map("n", "tm", ":tabm<Space>")
map("n", "td", ":tabclose<CR>")

-- Highlight last inserted text
map("n", "gV", "`[v`]")

-- Diff
map("n", "<leader>df", ":diffthis<CR>")

-- Grep word under cursor
map("n", "K", ':grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>')

-- Strip trailing whitespace
map("n", "<leader>S", function()
  local pos = vim.api.nvim_win_get_cursor(0)
  local search = vim.fn.getreg("/")
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setreg("/", search)
  vim.api.nvim_win_set_cursor(0, pos)
end, { desc = "Strip trailing whitespace" })

-- Toggle relative line numbers
map("n", "<leader>n", function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative numbers" })

-- Better window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Resize splits with arrows
map("n", "<C-Up>", ":resize +2<CR>", { silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep visual selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
