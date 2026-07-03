return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = '[G]it [D]iff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = '[G]it file [H]istory' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = '[G]it repo [H]istory' },
    { '<leader>gx', '<cmd>DiffviewClose<CR>', desc = '[G]it diff close' },
    {
      '<leader>gp',
      function()
        local result = vim.fn.system('git rev-parse --abbrev-ref origin/HEAD'):gsub('%s+', '')
        local base = result:match('origin/(.+)') or 'master'
        vim.cmd('DiffviewOpen ' .. base .. '...HEAD')
      end,
      desc = '[G]it [P]R diff',
    },
  },
  opts = {},
}
