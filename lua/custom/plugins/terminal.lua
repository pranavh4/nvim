return {
  {
    'akinsho/toggleterm.nvim',
    config = true,
    cmd = 'ToggleTerm',
    keys = { { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = '[T]oggle floating [T]erminal' } },
    opts = {
      open_mapping = [[<leader>tt]],
      direction = 'horizontal',
      shade_filetypes = {},
      hide_numbers = true,
      insert_mappings = false,
      terminal_mappings = false,
      start_in_insert = true,
      close_on_exit = true,
    },
  },
}
