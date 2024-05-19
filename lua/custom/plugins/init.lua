-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'dstein64/nvim-scrollview',
    config = function()
      require('scrollview.contrib.gitsigns').setup {}
    end,
  },
  { 'tpope/vim-fugitive' },
  {
    'windwp/nvim-ts-autotag',
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('nvim-ts-autotag').setup()
    end,
    lazy = true,
    event = 'VeryLazy',
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  {
    'ThePrimeagen/vim-be-good',
  },
  -- Display Diagnostic In Toolbar
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local trouble = require 'trouble'
      vim.keymap.set('n', '<leader>tq', function()
        trouble.toggle 'quickfix'
      end, { desc = '[T]oggle [Q]uickfix List' })
      vim.keymap.set('n', '<leader>td', function()
        trouble.toggle 'workspace_diagnostics'
      end, { desc = '[T]oggle [D]iagnsotics' })
      vim.keymap.set('n', '<leader>tl', function()
        trouble.toggle 'loclist'
      end, { desc = '[T]oggle [L]ocal List' })
      vim.keymap.set('n', 'tr', function()
        trouble.toggle 'lsp_references'
      end, { desc = '[T]oggle [R]eferences' })
    end,
  },
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
}
