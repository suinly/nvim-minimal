-- Run with nvim --headless -i NONE -u init.lua '+lua dofile("tests/rust-completion.lua")' '+qa!'
local process = MiniCompletion.config.lsp_completion.process_items
local function item(label, path, sort)
  return {
    label = label,
    filterText = label,
    sortText = sort,
    data = path and { imports = { { full_import_path = path } } } or nil,
  }
end
local items = {
  item("Condvar", "std::sync::Condvar", "1"),
  item("Config", "serde::Config", "2"),
  item("Context", "crate::local::Context", "3"),
  item("Condvar", "crate::local::Condvar", "4"),
  item("Core", "self::Core", "5"),
  item("Counter", "super::Counter", "6"),
  item("Constant", nil, "7"),
}
local function paths(list)
  return vim.tbl_map(function(entry)
    return entry.data and entry.data.imports[1].full_import_path or entry.label
  end, list)
end
vim.bo.filetype = "rust"
local result = process(items, "Co")
assert(vim.deep_equal(paths(result), {
  "crate::local::Context", "crate::local::Condvar", "self::Core", "super::Counter",
  "std::sync::Condvar", "serde::Config", "Constant",
}), "Project imports must come first while keeping each group's original order")
vim.bo.filetype = "lua"
local unchanged = process(items, "Co")
assert(vim.deep_equal(paths(unchanged), {
  "std::sync::Condvar", "serde::Config", "crate::local::Context", "crate::local::Condvar",
  "self::Core", "super::Counter", "Constant",
}), "Other languages must retain the default order")
print("Rust completion priority checks passed")
