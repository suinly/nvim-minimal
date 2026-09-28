return {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
      tsserver = {
        globalPlugins = {
          {
            name = "@vue/typescript-plugin",
            location = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
            languages = { "vue" },
            configNamespace = "typescript",
            enableForWorkspaceTypeScriptVersions = true,
          },
        },
      },
    },
  },
}
