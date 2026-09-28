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
after/lsp/
  vtsls.lua               — TypeScript и Vue-плагин поверх настроек nvim-lspconfig
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
Vue, JavaScript и TypeScript используют `vtsls`, Vue дополнительно использует `vue_ls`.
Python использует `ty` для типов и навигации, `ruff` для линтинга и code actions.
Tree-sitter включает подсветку и отступы для этих языков, HTML, CSS и Rust.
Перед сохранением Prettier форматирует Vue/JS/TS; Ruff сортирует импорты и форматирует Python.
Для остальных файлов используется первый доступный LSP с поддержкой форматирования.
Без форматтера файл сохраняется как обычно. `scrolloff = 5` оставляет контекст вокруг курсора.

На новой машине установить инструменты через `:MasonInstall rust-analyzer vtsls vue-language-server ty ruff prettier tree-sitter-cli`,
затем парсеры через `:TSInstall typescript tsx javascript vue python html css rust`. Для сборки парсеров нужен C-компилятор; для `vtsls`, Vue и Prettier — Node.js.

Проверка поведения: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/editor.lua")' '+qa!'`.
Проверка состояния LazyGit: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/lazygit.lua")'`.
Проверка языков: `rtk proxy env NVIM_APPNAME=nvim-minimal nvim --headless -i NONE -u init.lua '+lua dofile("tests/languages.lua")' '+qa!'`.
