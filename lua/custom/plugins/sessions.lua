return {
  'rmagatti/auto-session',
  config = function()
    local session = require 'auto-session'

    -- Automatically open neo tree on session restore
    local function restore_nvim_tree()
      local neo_tree = require 'neo-tree.command'
      neo_tree.execute { dir = vim.fn.getcwd() }
    end

    -- Close NeoTree before saving as it's sketchy on restore
    local function close_sketchy_buffers()
      require('neo-tree.command').execute { action = 'close' }
    end

    session.setup {
      auto_session_create_enabled = false,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      post_restore_cmds = { restore_nvim_tree },
      pre_save_cmds = { close_sketchy_buffers },
    }
    vim.keymap.set('n', '<leader>ws', '<cmd>SessionSave<CR>', { desc = '[S]ave Session' })
    vim.keymap.set('n', '<leader>wr', '<cmd>SessionRestore<CR>', { desc = '[R]estore Session' })
    vim.keymap.set('n', '<leader>wd', '<cmd>SessionDelete<CR>', { desc = '[D]elete Session in current workspace' })
    vim.keymap.set('n', '<leader>wD', '<cmd>Autosession delete<CR>', { desc = '[D]elete any session' })
    vim.keymap.set('n', '<leader>wf', '<cmd>Autosession search<CR>', { desc = '[F]ind Session' })

    -- Don't save terminal session info
    vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions'
  end,
}
