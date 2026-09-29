-- Basics
vim.pack.add({ "https://github.com/nvim-mini/mini.basics" })
require("mini.basics").setup()

-- Comment
vim.pack.add({ "https://github.com/nvim-mini/mini.comment" })
require("mini.comment").setup({
  mappings = {
    comment = "<leader>/",
    comment_line = "<leader>/",
    comment_visual = "<leader>/",
    textobject = "<leader>/"
  }
})

-- Completion
vim.pack.add({ "https://github.com/nvim-mini/mini.completion" })
require("mini.completion").setup({
  lsp_completion = {
    process_items = function(items, base)
      local sorted = MiniCompletion.default_process_items(items, base)
      if vim.bo.filetype ~= "rust" then return sorted end
      local project, other = {}, {}
      for _, item in ipairs(sorted) do
        local local_import = false
        for _, import in ipairs(item.data and item.data.imports or {}) do
          local path = import.full_import_path
          local root = type(path) == "string" and path:match("^([^:]+)::")
          if root == "crate" or root == "self" or root == "super" then
            local_import = true
            break
          end
        end
        local group = local_import and project or other
        group[#group + 1] = item
      end
      return vim.list_extend(project, other)
    end,
  },
})
vim.opt.completeopt = { "menuone", "noinsert" }

-- Keymap
vim.pack.add({ "https://github.com/nvim-mini/mini.keymap" })
require("mini.keymap").setup()

local map_multistep = require("mini.keymap").map_multistep

map_multistep("i", "<Tab>",   { "pmenu_next" })
map_multistep("i", "<S-Tab>", { "pmenu_prev" })
map_multistep("i", "<CR>", {
  "pmenu_accept",
  {
    condition = function() return vim.fn.pumvisible() == 1 end,
    action = function() return "<C-n><C-y>" end,
  },
  "minipairs_cr",
})
map_multistep("i", "<BS>",    { "minipairs_bs" })

local map_combo = require("mini.keymap").map_combo
local mode = { "i", "c", "x", "s" }
map_combo(mode, "jk", "<BS><BS><Esc>")
map_combo(mode, "kj", "<BS><BS><Esc>")

-- Pairs
vim.pack.add({ "https://github.com/nvim-mini/mini.pairs" })
require("mini.pairs").setup()

-- Surround
vim.pack.add({ "https://github.com/nvim-mini/mini.surround" })
require("mini.surround").setup()

-- Cmdline
vim.pack.add({ "https://github.com/nvim-mini/mini.cmdline" })
require("mini.cmdline").setup()

-- Tailspace
vim.pack.add({ "https://github.com/nvim-mini/mini.trailspace" })
require("mini.trailspace").setup()

-- Syntax highlighting
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })
require("nvim-treesitter").setup()
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("LanguageHighlight", { clear = true }),
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "python", "html", "css", "rust" },
  callback = function(event)
    pcall(vim.treesitter.start, event.buf)
    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
