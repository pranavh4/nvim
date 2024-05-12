return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('nvim-treesitter.configs').setup {
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            ['am'] = '@function.outer',
            ['im'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['a='] = '@assignment.outer',
            ['i='] = '@assignment.inner',
            ['l='] = '@assignment.lhs',
            ['r='] = '@assignment.rhs',
            ['ab'] = '@block.outer',
            ['ib'] = '@block.inner',
            ['ai'] = '@conditional.outer',
            ['ii'] = '@conditional.inner',
            ['al'] = '@loop.outer',
            ['il'] = '@loop.inner',
            ['ap'] = '@parameter.outer',
            ['ip'] = '@parameter.inner',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>np'] = '@parameter.inner',
            ['<leader>nm'] = '@function.outer',
            ['<leader>nc'] = '@class.outer',
          },
          swap_previous = {
            ['<leader>pp'] = '@parameter.inner',
            ['<leader>pm'] = '@function.outer',
            ['<leader>pc'] = '@class.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']m'] = '@function.inner',
            [']c'] = '@class.inner',
            [']='] = '@assignment.outer',
            [']b'] = '@block.inner',
            [']i'] = '@conditional.inner',
            [']l'] = '@loop.inner',
            [']p'] = '@parameter.inner',
          },

          goto_next_end = {
            [']M'] = '@function.inner',
            [']C'] = '@class.inner',
            [']B'] = '@block.inner',
            [']I'] = '@conditional.inner',
            [']L'] = '@loop.inner',
            [']P'] = '@parameter.inner',
          },
          goto_previous_start = {
            ['[m'] = '@function.inner',
            ['[c'] = '@class.inner',
            ['[='] = '@assignment.outer',
            ['[b'] = '@block.inner',
            ['[i'] = '@conditional.inner',
            ['[l'] = '@loop.inner',
            ['[p'] = '@parameter.inner',
          },
          goto_previous_end = {
            ['[M'] = '@function.inner',
            ['[C'] = '@class.inner',
            ['[B'] = '@block.inner',
            ['[I'] = '@conditional.inner',
            ['[L'] = '@loop.inner',
            ['[P'] = '@parameter.inner',
          },
        },
        include_surrounding_whitespace = false,
      },
    }

    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

    -- Repeat movement with ; and ,
    -- ensure ; goes forward and , goes backward regardless of the last direction
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_previous)

    -- vim way: ; goes to the direction you were moving.
    -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f)
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F)
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t)
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T)
  end,
}
