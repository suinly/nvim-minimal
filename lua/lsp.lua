vim.pack.add({ "https://github.com/neovim/nvim-lspconfig", "https://github.com/stevearc/conform.nvim" })
local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    vue = { "prettier" },
    python = { "ruff_organize_imports", "ruff_format" },
  },
})

vim.diagnostic.config({ virtual_text = true })

vim.lsp.config("ruff", {
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})
vim.lsp.enable({ "rust_analyzer", "vtsls", "vue_ls", "ty", "ruff" })

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
  callback = function(event)
    if #conform.list_formatters_to_run(event.buf) > 0 then
      conform.format({ bufnr = event.buf, async = false, timeout_ms = 2000 })
      return
    end
    local clients = vim.lsp.get_clients({ bufnr = event.buf, method = "textDocument/formatting" })
    if #clients == 0 then return end
    vim.lsp.buf.format({ bufnr = event.buf, id = clients[1].id, async = false, timeout_ms = 2000 })
  end,
})
