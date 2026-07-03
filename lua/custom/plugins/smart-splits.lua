return {
  'mrjones2014/smart-splits.nvim',
  lazy = false,
  config = function()
    local smart_splits = require 'smart-splits'
    smart_splits.setup {}
    if vim.env.WEZTERM_PANE then
      pcall(vim.fn.serverstart, '/tmp/nvim-wezterm-' .. vim.env.WEZTERM_PANE)
    end
    vim.keymap.set('n', '<A-Left>', smart_splits.move_cursor_left, { desc = 'Move to left split/pane' })
    vim.keymap.set('n', '<A-Down>', smart_splits.move_cursor_down, { desc = 'Move to below split/pane' })
    vim.keymap.set('n', '<A-Up>', smart_splits.move_cursor_up, { desc = 'Move to above split/pane' })
    vim.keymap.set('n', '<A-Right>', smart_splits.move_cursor_right, { desc = 'Move to right split/pane' })
    vim.keymap.set('n', '<C-S-Left>', smart_splits.resize_left, { desc = 'Resize split left' })
    vim.keymap.set('n', '<C-S-Down>', smart_splits.resize_down, { desc = 'Resize split down' })
    vim.keymap.set('n', '<C-S-Up>', smart_splits.resize_up, { desc = 'Resize split up' })
    vim.keymap.set('n', '<C-S-Right>', smart_splits.resize_right, { desc = 'Resize split right' })
  end,
}
