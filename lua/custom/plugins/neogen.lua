return {
  'danymat/neogen',
  config = function()
    local neogen = require 'neogen'
    neogen.setup {}
    vim.keymap.set('n', '<leader>gf', neogen.generate, { desc = '[G]enerate [F]unction Annotation' })
    vim.keymap.set('n', '<leader>gc', function()
      neogen.generate { type = 'class' }
    end, { desc = '[G]enerate [C]lass Annotation' })
  end,
  version = '*',
}
