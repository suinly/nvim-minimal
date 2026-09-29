local ui = require("vim._core.ui2")
if #vim.api.nvim_list_uis() == 0 then return end

local function layout()
  if vim.o.cmdheight ~= 0 then
    vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function() vim.o.cmdheight = 0 end)
  end
  for _, kind in ipairs({ "cmd", "dialog" }) do
    local win = ui.wins[kind]
    if win and vim.api.nvim_win_is_valid(win) then
      local config = vim.api.nvim_win_get_config(win)
      if not config.hide then
        local width = math.max(1, math.min(80, vim.o.columns - 4))
        vim.api.nvim_win_set_width(win, width)
        local height = math.max(1, math.min(vim.api.nvim_win_text_height(win, {}).all, vim.o.lines - 4))
        vim.api.nvim_win_set_config(win, {
          relative = "editor", anchor = "NW", border = "rounded",
          width = width, height = height,
          col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
          row = math.max(0, math.floor((vim.o.lines - height - 2) / 2)),
        })
        vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
      end
    end
  end
end

local warning, prompt_args
local show_cmdline = ui.cmd.cmdline_show
local function render_prompt(args)
  local content, pos, firstc, prompt, indent, level, hl_id = unpack(args, 1, 7)
  if warning and prompt ~= "" then prompt = warning .. "\n\n" .. prompt end
  show_cmdline(content, pos, firstc, prompt, indent, level, hl_id)
  layout()
end

ui.cmd.cmdline_show = function(...)
  prompt_args = { ... }
  render_prompt(prompt_args)
end

local hide_cmdline = ui.cmd.cmdline_hide
ui.cmd.cmdline_hide = function(...)
  hide_cmdline(...)
  if ui.cmd.level == 0 then
    prompt_args = nil
    -- An invalid confirm key hides and reopens the same prompt synchronously.
    vim.schedule(function()
      if ui.cmd.level == 0 then warning = nil end
    end)
  end
end

local show_message = ui.msg.msg_show
ui.msg.msg_show = function(kind, content, replace_last, history, append, id, trigger)
  if kind == "confirm" then
    local chunks = {}
    for _, chunk in ipairs(content) do chunks[#chunks + 1] = chunk[2] end
    warning = table.concat(chunks):gsub("^\n+", ""):gsub("\n+$", "")
    if prompt_args and ui.cmd.level > 0 and ui.cmd.prompt then
      render_prompt(prompt_args)
      -- Scheduled message events do not redraw the command window themselves.
      vim.api.nvim__redraw({ win = ui.wins.cmd, cursor = true, flush = true })
    end
    return
  end
  return show_message(kind, content, replace_last, history, append, id, trigger)
end

local set_pos = ui.msg.set_pos
ui.msg.set_pos = function(...)
  set_pos(...)
  layout()
end
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ModalCommandUI", { clear = true }),
  callback = vim.schedule_wrap(layout),
})
