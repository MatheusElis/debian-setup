local util = require("comuvim.util")

return {
  "zk-org/zk-nvim",
  name = "zk",
  cond = not util.is_windows,
  config = function()
    require("zk").setup({
      picker = "snacks_picker",
      lsp = {
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
        },
        auto_attach = {
          enabled = true,
        },
      },
    })

    local opts = { noremap = true, silent = false }
    vim.keymap.set("n", "<leader>zn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", opts)
    vim.keymap.set("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
    vim.keymap.set("n", "<leader>zt", "<Cmd>ZkTags<CR>", opts)
    vim.keymap.set(
      "n",
      "<leader>zf",
      "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>",
      opts
    )
    vim.keymap.set("v", "<leader>zf", ":'<,'>ZkMatch<CR>", opts)
    vim.keymap.set("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", opts)
    vim.keymap.set("n", "<leader>zl", "<Cmd>ZkLinks<CR>", opts)
    vim.keymap.set("n", "<leader>zi", "<Cmd>ZkIndex<CR>", opts)
  end,
}
