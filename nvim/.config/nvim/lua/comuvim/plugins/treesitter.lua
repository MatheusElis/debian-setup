local parsers = {
  "python",
  "go",
  "gomod",
  "gosum",
  "java",
  "kotlin",
  "c",
  "lua",
  "vim",
  "vimdoc",
  "javascript",
  "typescript",
  "markdown",
  "markdown_inline",
  "html",
  "css",
  "json",
  "yaml",
  "toml",
  "bash",
  "sql",
  "dockerfile",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  commit = "4916d6592ede8c07973490d9322f187e07dfefac",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    ts.install(parsers)

    local filetypes = {}
    for _, lang in ipairs(parsers) do
      for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
        filetypes[#filetypes + 1] = ft
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("comuvim_treesitter", { clear = true }),
      pattern = filetypes,
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
