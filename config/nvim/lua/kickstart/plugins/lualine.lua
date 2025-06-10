return {
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = {
          left = '',
          right = ''
        },
        always_divide_middle = true,
      },

      sections = {
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = {
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = {
              error = ' ',
              warn  = ' ',
              info  = ' ',
              hint  = ' '
            }
          },
        },
        lualine_y = { 'filetype' },
        lualine_z = {}
      }
    },
  }
