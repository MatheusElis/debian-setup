-- LSP Keymaps and Configuration (Neovim 0.12 APIs)

local function get_capabilities()
  local has_blink, blink = pcall(require, "blink.cmp")
  if has_blink and blink.get_lsp_capabilities then
    return vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), blink.get_lsp_capabilities(), {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    })
  else
    return vim.lsp.protocol.make_client_capabilities()
  end
end

local function setup_keymaps(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc, silent = true })
  end

  -- Navigation (handled by Snacks picker in snacks.lua for gd, gr, gi, gy)
  map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
  map("n", "K", vim.lsp.buf.hover, "Hover documentation")
  map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
  map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

  -- Code actions
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("n", "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
  end, "Format buffer")

  -- Diagnostics (Neovim 0.12 API)
  map("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
  end, "Previous diagnostic")
  map("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
  end, "Next diagnostic")
  map("n", "<leader>cd", vim.diagnostic.open_float, "Show diagnostic")
  map("n", "<leader>cl", vim.diagnostic.setloclist, "Diagnostics to loclist")

  -- Workspace
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "List workspace folders")
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then
      return
    end

    setup_keymaps(bufnr)
    local capabilities = get_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })
  end,
})

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})
