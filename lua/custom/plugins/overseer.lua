return {
  'stevearc/overseer.nvim',
  config = function()
    local overseer = require 'overseer'
    overseer.setup {
      templates = { 'builtin', 'run_file' },
      default_template_prompt = 'always',
      strategy = {
        'toggleterm',
      },
      task_editor = {
        bindings = {
          i = { -- Unmap the below bindings as they're buggy. It adds a <CR> in the terminal
            ['<CR>'] = false,
            ['<C-s>'] = false,
          },
        },
      },
    }

    vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<CR>', { desc = '[O]verseer [T]oggle' })
    vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = '[O]verseer [R]un' })
    vim.keymap.set('n', '<leader>oR', '<cmd>OverseerRunCmd<CR>', { desc = '[O]verseer [R]un Command' })
    vim.keymap.set('n', '<leader>ob', '<cmd>OverseerBuild<CR>', { desc = '[O]verseer [B]uild' })
    vim.keymap.set('n', '<leader>oi', '<cmd>OverseerInfo<CR>', { desc = '[O]verseer [I]nfo' })
  end,
}
