-- Run with NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/languages.lua")' '+qa!'
for _, server in ipairs({ "rust_analyzer", "vtsls", "vue_ls", "ty", "ruff" }) do
  assert(vim.lsp.is_enabled(server), server .. " must be enabled")
end
local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p")
directory = vim.uv.fs_realpath(directory)
vim.fn.writefile({ '{"name":"language-check","private":true}' }, directory .. "/package.json")
vim.fn.writefile({ '{"compilerOptions":{"strict":true}}' }, directory .. "/tsconfig.json")
vim.fn.writefile({ "[project]", 'name = "language-check"', 'version = "0.1.0"' }, directory .. "/pyproject.toml")
local cwd = vim.fn.getcwd()
vim.cmd.cd(vim.fn.fnameescape(directory))
local cases = {
  { "check.ts", { 'const answer: number = "wrong";' }, { "vtsls" }, "typescript" },
  { "check.vue", { '<script setup lang="ts">', 'const answer: number = "wrong";', '</script>', '<template><div>{{ answer }}</div></template>' }, { "vtsls", "vue_ls" }, "vue" },
  { "check.py", { "import sys", "import os", 'answer: int = "wrong"' }, { "ty", "ruff" }, "python" },
}
for _, case in ipairs(cases) do
  local path = directory .. "/" .. case[1]
  vim.fn.writefile(case[2], path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local buf = vim.api.nvim_get_current_buf()
  assert(vim.bo.filetype == case[4])
  for _, server in ipairs(case[3]) do
    assert(vim.wait(20000, function()
      local client = vim.lsp.get_clients({ bufnr = buf, name = server })[1]
      return client and client.initialized
    end, 50), server .. " must attach to " .. case[1])
  end
  assert(vim.treesitter.highlighter.active[buf], "Tree-sitter must highlight " .. case[1])
  local type_error = case[4] == "python" and "invalid-assignment" or 2322
  assert(vim.wait(20000, function()
    for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
      if diagnostic.code == type_error then return true end
    end
    return false
  end, 50), "Type errors must be reported in " .. case[1])
  if case[4] == "python" then
    assert(not vim.lsp.get_clients({ bufnr = buf, name = "ruff" })[1].server_capabilities.hoverProvider)
    vim.cmd.write()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    assert(lines[1] == "import os" and lines[2] == "import sys", "Ruff must organize Python imports")
  else
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, case[4] == "vue" and { '<script setup lang="ts">', 'const answer=1', '</script>', '<template><div>{{answer}}</div></template>' } or { "const answer=1" })
    vim.cmd.write()
    local lines = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    assert(lines:find("const answer = 1;", 1, true), "Prettier must format " .. case[1])
  end
  vim.bo[buf].modified = false
end
vim.cmd.cd(vim.fn.fnameescape(cwd))
for _, client in ipairs(vim.lsp.get_clients()) do client:stop(true) end
vim.fn.delete(directory, "rf")
print("Vue, TypeScript and Python language checks passed")
