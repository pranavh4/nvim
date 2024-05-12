return {
  'stevearc/conform.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local conform = require 'conform'
    local format_options = {
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    }
    conform.formatters.shfmt = {
      prepend_args = { '-i', '4' }, -- Indent 4 spaces
    }
    conform.setup {
      formatters_by_ft = {
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        javascriptreact = { 'prettier' },
        typescriptreact = { 'prettier' },
        svelte = { 'prettier' },
        css = { 'prettier' },
        html = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        sh = { 'shfmt' },
      },
      format_on_save = format_options,
    }
    vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
      conform.format(format_options)
    end, { desc = '[F]ormat' })
  end,
}
