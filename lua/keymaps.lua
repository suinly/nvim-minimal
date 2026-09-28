local keymap = vim.keymap.set

keymap("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlights" })

keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })

keymap("n", "<space>", "<Nop>")

keymap("n", "<leader>e", "<cmd>lua MiniFiles.open()<CR>", { desc = "File explorer" })
keymap("n", "<leader>w", "<cmd>w!<CR>", { desc = "Save file" })
keymap("n", "<leader>r", "<cmd>restart<CR>", { desc = "Restart Neovim" })

keymap("n", "<leader>ff", "<cmd>Pick files<CR>", { desc = "Find files" })
keymap("n", "<leader>fg", "<cmd>Pick grep_live<CR>", { desc = "Search text" })
keymap("n", "<leader>fb", "<cmd>Pick buffers<CR>", { desc = "Find buffers" })
keymap("n", "<leader>d", function()
  vim.diagnostic.open_float({ scope = "line", border = "rounded", source = "always" })
end, { desc = "Line diagnostics" })
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
keymap("n", "<leader>gg", function()
  local buf = vim.api.nvim_create_buf(false, true)
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
  vim.bo[buf].bufhidden = "wipe"
  for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    keymap("t", "<C-" .. key .. ">", function()
      require("herdr-splits")["move_cursor_" .. direction]()
    end, { buffer = buf, desc = "Herdr: " .. direction })
    keymap("t", "<M-" .. key .. ">", function()
      require("herdr-splits")["resize_" .. direction]()
    end, { buffer = buf, desc = "Herdr resize: " .. direction })
  end
  vim.fn.jobstart({ "lazygit" }, {
    term = true,
    on_exit = vim.schedule_wrap(function()
      pcall(vim.api.nvim_del_autocmd, resize_autocmd)
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end),
  })
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

keymap("n", "<leader>q", "<cmd>q<CR>", { desc = "Close window" })
