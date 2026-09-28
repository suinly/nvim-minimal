-- Diff
vim.pack.add({ "https://github.com/nvim-mini/mini.diff" })
require("mini.diff").setup({
  view = { style = "sign", signs = { add = "+", change = "~", delete = "-" } },
})

-- Mason
vim.pack.add({ "https://github.com/mason-org/mason.nvim" })
require("mason").setup()
