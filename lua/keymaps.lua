local keymap = vim.keymap.set

keymap("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlights" })

keymap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
keymap("n", "<leader>cr", vim.lsp.buf.rename, { desc = "LSP rename" })

keymap("n", "<space>", "<Nop>")

local function project_root()
  local path = vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) or ""
  local start = path ~= "" and path or vim.fn.getcwd()
  return vim.fs.root(start, ".git") or vim.fs.root(start, { "Cargo.toml", "package.json", "pyproject.toml" }) or vim.fn.getcwd()
end
keymap("n", "gd", function()
  local root = project_root()
  root = vim.uv.fs_realpath(root) or root
  vim.lsp.buf.definition({ on_list = function(list)
    local unique, local_items, seen = {}, {}, {}
    for _, item in ipairs(list.items) do
      local path = item.filename or vim.api.nvim_buf_get_name(item.bufnr)
      path = vim.uv.fs_realpath(path) or vim.fs.normalize(path)
      local id = path .. ":" .. item.lnum .. ":" .. item.col
      if not seen[id] then
        seen[id] = true
        unique[#unique + 1] = item
        if vim.fs.relpath(root, path) then local_items[#local_items + 1] = item end
      end
    end
    list.items = #local_items > 0 and local_items or unique
    vim.fn.setqflist({}, " ", list)
    if #list.items == 1 then
      vim.cmd.cclose()
      vim.cmd.cfirst()
    else
      vim.cmd("botright copen")
    end
  end })
end, { desc = "Go to definition" })
keymap("n", "<leader>e", function()
  local path = vim.api.nvim_buf_get_name(0)
  local target = vim.bo.buftype == "" and vim.fn.filereadable(path) == 1 and path or project_root()
  MiniFiles.open(target, false)
end, { desc = "File explorer" })
keymap("n", "<leader>E", function()
  MiniFiles.open(project_root(), false)
end, { desc = "Project explorer" })
keymap("n", "<leader>w", "<cmd>w!<CR>", { desc = "Save file" })
keymap("n", "<leader>r", "<cmd>restart<CR>", { desc = "Restart Neovim" })

keymap("n", "<leader>ff", "<cmd>Pick files<CR>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Pick grep_live<CR>", { desc = "Search text" })
keymap("n", "<leader>fb", "<cmd>Pick buffers<CR>", { desc = "Find buffers" })
local function line_diagnostics()
  vim.diagnostic.open_float({ scope = "line", border = "rounded", source = "always" })
end
keymap("n", "<leader>d", line_diagnostics, { desc = "Line diagnostics" })
keymap("n", "<leader>cd", line_diagnostics, { desc = "Line diagnostics" })
keymap("n", "<leader>fd", vim.diagnostic.setqflist, { desc = "All diagnostics" })
keymap("n", "<leader>bd", function() MiniBufremove.delete() end, { desc = "Close buffer" })
keymap("n", "<leader>bo", function()
  local current = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      MiniBufremove.delete(buf)
    end
  end
end, { desc = "Close other buffers" })
local lazygit_buffers = {}
keymap("n", "<leader>gg", function()
  local config = vim.env.LG_CONFIG_FILE
  if not config then
    local result = vim.system({ "lazygit", "--print-config-dir" }, { text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr, vim.log.levels.ERROR)
      return
    end
    config = vim.trim(result.stdout) .. "/config.yml"
  end
  config = config .. "," .. vim.fn.stdpath("config") .. "/lazygit.yml"
  local cwd = vim.fn.getcwd()
  local buf = lazygit_buffers[cwd]
  local is_new = not (buf and vim.api.nvim_buf_is_valid(buf))
  if is_new then
    buf = vim.api.nvim_create_buf(false, true)
    lazygit_buffers[cwd] = buf
  end
  local function window_config()
    local width = math.max(1, math.floor(vim.o.columns * 0.9))
    local height = math.max(1, math.floor((vim.o.lines - 2) * 0.85))
    return {
      relative = "editor",
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width - 2) / 2),
      row = math.floor((vim.o.lines - height - 2) / 2),
      style = "minimal",
      border = "rounded",
      title = " Lazygit ",
      title_pos = "center",
    }
  end
  local win = vim.api.nvim_open_win(buf, true, window_config())
  local resize_autocmd = vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then return true end
      vim.api.nvim_win_set_config(win, window_config())
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function() pcall(vim.api.nvim_del_autocmd, resize_autocmd) end,
  })
  vim.bo[buf].bufhidden = "hide"
  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    keymap("t", "<C-" .. key .. ">", function()
      require("herdr-splits")["move_cursor_" .. direction]()
    end, { buffer = buf, desc = "Herdr: " .. direction })
    keymap("t", "<C-M-" .. key .. ">", function()
      require("herdr-splits")["resize_" .. direction]()
    end, { buffer = buf, desc = "Herdr resize: " .. direction })
  end
  if is_new then
    local job = vim.fn.jobstart({ "lazygit", "--use-config-file", config }, {
      term = true,
      on_exit = vim.schedule_wrap(function()
        for _, window in ipairs(vim.fn.win_findbuf(buf)) do
          vim.api.nvim_win_close(window, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
      end),
    })
    if job <= 0 then
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.notify("Failed to start LazyGit", vim.log.levels.ERROR)
      return
    end
  end
  vim.cmd.startinsert()
end, { desc = "Lazygit" })

keymap("n", "H", "<cmd>bprevious<CR>")
keymap("n", "L", "<cmd>bnext<CR>")

-- Herdr Splits
keymap("n", "<leader>\\", "<cmd>split<CR>", { desc = "Horizontal split" })
keymap("n", "<leader>|", "<cmd>vsplit<CR>", { desc = "Vertical split" })
keymap("n", "<C-h>", "<cmd> lua require('herdr-splits').move_cursor_left()<CR>")
keymap("n", "<C-j>", "<cmd> lua require('herdr-splits').move_cursor_down()<CR>")
keymap("n", "<C-k>", "<cmd> lua require('herdr-splits').move_cursor_up()<CR>")
keymap("n", "<C-l>", "<cmd> lua require('herdr-splits').move_cursor_right()<CR>")
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
  keymap("n", "<C-M-" .. key .. ">", function()
    require("herdr-splits")["resize_" .. direction]()
  end, { desc = "Herdr resize: " .. direction })
end

keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Close window" })
