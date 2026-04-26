-- General keymaps
vim.keymap.set("n", "<leader>w", ":w!<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit/close window", silent = true })

-- Keymaps for tabs
vim.keymap.set("n", "<C-t>", ":tabnew<CR>")
vim.keymap.set("n", "th", ":tabfirst<CR>")
vim.keymap.set("n", "tk", ":tabnext<CR>")
vim.keymap.set("n", "tj", ":tabprev<CR>")
vim.keymap.set("n", "tl", ":tablast<CR>")
vim.keymap.set("n", "tt", ":tabedit ")
vim.keymap.set("n", "tn", ":tabnext ")
vim.keymap.set("n", "tm", ":tabm ")
vim.keymap.set("n", "td", ":tabclose<CR>")

-- Line-related keymaps
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "gV", "`[v`]")

-- 'jk' acts as an escape in insert mode
vim.keymap.set("i", "jk", "<Esc>")

-- Move to beginning/end of line
vim.keymap.set("n", "B", "^")
vim.keymap.set("n", "E", "$")

-- Save session
vim.keymap.set("n", "<leader>ss", ":mksession<CR>", { desc = "Save session" })

-- Clipboard yank, cut, paste
vim.keymap.set("", "<leader>y", "\"*y")
vim.keymap.set("", "<leader>x", "\"*x")
vim.keymap.set("", "<leader>p", "\"*p")

-- Strip trailing whitespace
vim.keymap.set("n", "<leader>S", function()
  local save = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(save)
end, { desc = "Strip trailing whitespace" })

-- Surround shortcuts (requires vim-surround or mini.surround)
vim.keymap.set("n", '<leader>s"', 'ysiw"')
vim.keymap.set("n", "<leader>s'", "ysiw'")
vim.keymap.set("n", "<leader>s`", "ysiw`")
vim.keymap.set("n", "<leader>s*", "ysiw*l")
vim.keymap.set("n", "<leader>s_", "ysiw_l")
vim.keymap.set("n", "<leader>s$", "ysiw$")
vim.keymap.set("n", "<leader>s(", "ysiw(")
vim.keymap.set("n", "<leader>s)", "ysiw)")
vim.keymap.set("n", "<leader>s[", "ysiw[")
vim.keymap.set("n", "<leader>s]", "ysiw]")
vim.keymap.set("n", "<leader>s{", "ysiw{")
vim.keymap.set("n", "<leader>s}", "ysiw}")

-- Diff mode (vimdiff). Run on two buffers to compare; :diffoff to clear.
vim.keymap.set("n", "<leader>gD", ":diffthis<CR>", { desc = "Diff buffer (vimdiff)" })

-- Copilot keymaps
vim.keymap.set("i", "<C-l>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  end
end)

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>fe", "<cmd>NvimTreeFocus<CR>")
