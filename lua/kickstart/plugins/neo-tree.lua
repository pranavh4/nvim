-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    use_popups_for_input = false,
    auto_clean_after_session_restore = true,
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['P'] = 'toggle_preview',
          ['m'] = {
            'move',
            config = {
              show_path = 'relative',
            },
          },
        },
      },
    },
  },
}
