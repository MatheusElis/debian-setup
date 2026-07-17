local function map(m, k, v, d)
  vim.keymap.set(m, k, v, { silent = true, desc = d })
end

-- Splits
map("n", "|", "<cmd>vsplit<cr>", "Vertical Split")
map("n", "\\", "<cmd>split<cr>", "Horizontal Split")

-- Buffers
map("n", "<leader>bn", "<cmd>enew<CR>", "New File")
map("n", "<leader>bc", "<cmd>bdelete<CR>", "Close buffer")
map("n", "<leader>bC", "<cmd>bdelete!<CR>", "Force close buffer")
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", "Next buffer tab")
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer tab")
map("n", ">b", "<cmd>BufferLineMoveNext<cr>", "Move buffer tab right")
map("n", "<b", "<cmd>BufferLineMovePrev<cr>", "Move buffer tab left")

-- Stay in indent mode
map("v", "<", "<gv", "Unindent line")
map("v", ">", ">gv", "Indent line")

-- Window navigation
map("n", "<C-h>", "<C-w><C-h>", "Move focus to the left window")
map("n", "<C-l>", "<C-w><C-l>", "Move focus to the right window")
map("n", "<C-j>", "<C-w><C-j>", "Move focus to the lower window")
map("n", "<C-k>", "<C-w><C-k>", "Move focus to the upper window")

-- Clipboard / void register
map("x", "<leader>p", [["_dP]], "Paste without changing buffer")
map({ "n", "v" }, "<leader>y", [["+y]], "Copy to clipboard")
map({ "n", "v" }, "<leader>d", '"_d', "Delete to void")

-- Comment (native gc/gcc in Neovim 0.10+)
vim.keymap.set("n", "<leader>/", "gcc", { remap = true, silent = true, desc = "Comment line" })
vim.keymap.set("v", "<leader>/", "gc", { remap = true, silent = true, desc = "Comment selection" })
