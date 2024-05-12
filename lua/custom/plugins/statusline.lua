return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', 'folke/noice.nvim' },
  opts = {
    options = {
      icons_enabled = true,
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_a = {
        {
          'buffers',
        },
      },
      lualine_c = {
        {
          'mode',
        },
      },
    },
  },
}
