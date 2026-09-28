vim.diagnostic.config({ virtual_text = true })

vim.lsp.enable("rust_analyzer")

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
  callback = function(event)
    local clients = vim.lsp.get_clients({ bufnr = event.buf, method = "textDocument/formatting" })
    if #clients == 0 then return end
    vim.lsp.buf.format({ bufnr = event.buf, id = clients[1].id, async = false, timeout_ms = 2000 })
  end,
})
