# Neovim minimal

Конфигурация использует встроенный `vim.pack`. Порядок загрузки задан в `init.lua`:
leader → плагины → опции → горячие клавиши → LSP.

```text
init.lua                  — точка входа и leader
lua/
  options.lua             — общие настройки редактора
  keymaps.lua             — основные горячие клавиши
  lsp.lua                 — включение серверов и диагностика
  plugins.lua             — порядок загрузки групп плагинов
  plugins/
    ui.lua                — тема, иконки, стартовый экран, строки состояния
    editing.lua           — ввод, дополнение, комментарии, пары и окружения
    navigation.lua        — файлы, поиск, переходы и управление окнами
    tools.lua             — Git diff и Mason
lsp/
  rust_analyzer.lua       — команда, типы файлов и корневые маркеры Rust LSP
nvim-pack-lock.json        — зафиксированные версии плагинов
lazygit.yml               — открытие файлов в текущем Neovim из LazyGit
```

Настройки каждого плагина находятся рядом с его `vim.pack.add`.
Специальные сочетания для дополнения и выхода через `jk`/`kj` находятся
в `plugins/editing.lua`, рядом с настройками `mini.keymap`.

Запуск: `NVIM_APPNAME=nvim-minimal nvim`.
Проверка загрузки: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE +qa`.

`<leader>fb` — поиск открытых буферов; `<leader>bd` — закрытие буфера без закрытия окон.
`<leader>gg` — LazyGit; `e` открывает выбранный файл в текущем окне Neovim и закрывает окно LazyGit.
`q` скрывает LazyGit; повторный `<leader>gg` сохраняет выбранный файл, панель и позицию прокрутки.
Состояние сохраняется отдельно для каждого рабочего каталога в пределах текущего сеанса Neovim. `Ctrl+c` завершает LazyGit.
Несохранённые изменения требуют подтверждения перед закрытием.
Перед сохранением файл форматируется первым доступным LSP с поддержкой форматирования.
Без такого сервера файл сохраняется как обычно. `scrolloff = 5` оставляет контекст вокруг курсора.

Проверка поведения: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/editor.lua")' '+qa!'`.
Проверка состояния LazyGit: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/lazygit.lua")'`.
