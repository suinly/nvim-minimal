-- Run with NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/lazygit.lua")'
local repo = vim.fn.tempname()
vim.fn.mkdir(repo, "p")
local init = vim.system({ "git", "init", "-b", "main", repo }, { text = true }):wait()
assert(init.code == 0, init.stderr)
local selected = repo .. "/file with spaces.txt"
local original = repo .. "/original.txt"
vim.fn.writefile({ "selected file" }, selected)
vim.fn.writefile({ "original file" }, original)
vim.cmd.cd(vim.fn.fnameescape(repo))
vim.cmd.edit(vim.fn.fnameescape(original))
local origin_win, tabs = vim.api.nvim_get_current_win(), #vim.api.nvim_list_tabpages()
local open = vim.fn.maparg("<Space>gg", "n", false, true).callback
open()
local buf = vim.api.nvim_get_current_buf()
local channel = vim.bo[buf].channel
local function later(callback)
  vim.defer_fn(function()
    local ok, err = pcall(callback)
    if not ok then
      print(err)
      vim.cmd.cquit()
    end
  end, 1500)
end
later(function()
  -- Select a file below the root directory, then hide LazyGit.
  vim.fn.chansend(channel, "2jq")
  later(function()
    assert(vim.api.nvim_get_current_win() == origin_win, "q must close the LazyGit window")
    assert(vim.api.nvim_buf_is_valid(buf), "q must preserve the terminal buffer")
    assert(vim.fn.jobwait({ channel }, 0)[1] == -1, "q must keep LazyGit running")
    open()
    assert(vim.api.nvim_get_current_buf() == buf, "Reopening must reuse the same terminal")
    later(function()
      -- Editing immediately after reopening verifies the selected file survived.
      vim.fn.chansend(channel, "e")
      later(function()
        assert(vim.api.nvim_get_current_win() == origin_win)
        assert(#vim.api.nvim_list_tabpages() == tabs)
        assert(vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0)) == vim.uv.fs_realpath(selected), "e must open the remembered file")
        assert(vim.fn.jobwait({ channel }, 0)[1] == -1, "e must keep LazyGit running")
        open()
        assert(vim.api.nvim_get_current_buf() == buf)
        -- A real process exit must still close the currently displayed window.
        vim.fn.jobstop(channel)
        later(function()
          assert(not vim.api.nvim_buf_is_valid(buf))
          assert(vim.api.nvim_get_current_win() == origin_win)
          print("LazyGit state, editing and exit checks passed")
          vim.cmd("qa!")
        end)
      end)
    end)
  end)
end)
