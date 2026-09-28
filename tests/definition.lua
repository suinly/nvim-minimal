-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/definition.lua")' '+qa!'
local directory = vim.fn.tempname()
vim.fn.mkdir(directory .. "/project/src", "p")
vim.fn.mkdir(directory .. "/project-library", "p")
vim.fn.writefile({}, directory .. "/project/.git")
local source = directory .. "/project/src/main.txt"
local local_file = directory .. "/project/src/bootstrap.txt"
local library = directory .. "/project-library/tokio.txt"
for _, path in ipairs({ source, local_file, library }) do
  vim.fn.writefile({ "definition", "second definition" }, path)
end
local definition = vim.lsp.buf.definition
local function check(items, expected)
  vim.cmd.cclose()
  vim.cmd.edit(vim.fn.fnameescape(source))
  vim.lsp.buf.definition = function(opts)
    assert(opts and opts.on_list, "gd must filter definition results")
    opts.on_list({ title = "LSP locations", items = items })
  end
  vim.fn.maparg("gd", "n", false, true).callback()
  assert(#vim.fn.getqflist() == expected)
  if expected == 1 then
    assert(vim.bo.buftype ~= "quickfix", "Single definition must jump directly")
    assert(vim.api.nvim_win_get_cursor(0)[1] == 1)
  else
    assert(vim.bo.buftype == "quickfix", "Multiple definitions must remain selectable")
  end
end
local own = { filename = local_file, lnum = 1, col = 1 }
local external = { filename = library, lnum = 1, col = 1 }
check({ external, own, own }, 1)
assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) == vim.uv.fs_realpath(local_file))
check({ external, external }, 1)
assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) == vim.uv.fs_realpath(library))
check({ own, { filename = local_file, lnum = 2, col = 1 }, external }, 2)
vim.cmd.cclose()
vim.lsp.buf.definition = definition
vim.fn.delete(directory, "rf")
print("Definition filtering checks passed")
