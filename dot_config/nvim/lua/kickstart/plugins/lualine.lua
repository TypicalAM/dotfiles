return {
  'nvim-lualine/lualine.nvim',
  opts = function()
    local moon = {
      base    = '#232136',
      overlay = '#393552',
      muted   = '#6e6a86',
      subtle  = '#908caa',
      text    = '#e0def4',
      love    = '#eb6f92',
      gold    = '#f6c177',
      rose    = '#ea9a97',
      pine    = '#3e8fb0',
      foam    = '#9ccfd8',
      iris    = '#c4a7e7',
    }

    local theme = {
      normal   = { a = { fg = moon.base, bg = moon.iris, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      insert   = { a = { fg = moon.base, bg = moon.foam, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      visual   = { a = { fg = moon.base, bg = moon.rose, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      replace  = { a = { fg = moon.base, bg = moon.love, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      command  = { a = { fg = moon.base, bg = moon.gold, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      terminal = { a = { fg = moon.base, bg = moon.pine, gui = 'bold' }, b = { fg = moon.text, bg = moon.overlay }, c = { fg = moon.subtle, bg = 'NONE' } },
      inactive = { a = { fg = moon.muted, bg = 'NONE' }, b = { fg = moon.muted, bg = 'NONE' }, c = { fg = moon.muted, bg = 'NONE' } },
    }

    local mode_map = {
      ['NORMAL']    = ' 󰋜  NORMAL',
      ['INSERT']    = '   INSERT',
      ['VISUAL']    = ' 󰈈  VISUAL',
      ['V-LINE']    = ' 󰈈  V-LINE',
      ['V-BLOCK']   = ' 󰈈  V-BLOCK',
      ['REPLACE']   = '   REPLACE',
      ['R-LINE']    = '   R-LINE',
      ['COMMAND']   = '   COMMAND',
      ['TERMINAL']  = '   TERMINAL',
      ['SELECT']    = '   SELECT',
      ['S-LINE']    = '   S-LINE',
      ['EX']        = '   EX',
    }

    local function lsp_clients()
      local clients = vim.lsp.get_clients and vim.lsp.get_clients({ bufnr = 0 })
        or vim.lsp.buf_get_clients(0)
      if #clients == 0 then return '' end
      local names = {}
      for _, c in ipairs(clients) do
        if c.name ~= 'null-ls' and c.name ~= 'copilot' then
          names[#names + 1] = c.name
        end
      end
      return #names > 0 and (' 󰒋 ' .. table.concat(names, ', ')) or ''
    end

    local function macro_recording()
      local reg = vim.fn.reg_recording()
      return reg ~= '' and (' 󰑊 @' .. reg) or ''
    end

    return {
      options = {
        theme = theme,
        icons_enabled = true,
        globalstatus = true,
        section_separators   = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },

      sections = {
        lualine_a = {
          {
            'mode',
            fmt = function(str) return mode_map[str] or (' 󰋜  ' .. str) end,
          },
        },

        lualine_b = {
          { 'branch', icon = '' },
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            colored = true,
            diff_color = {
              added    = { fg = moon.foam },
              modified = { fg = moon.gold },
              removed  = { fg = moon.love },
            },
          },
        },

        lualine_c = {
          {
            'filename',
            path = 1,
            symbols = { modified = ' ●', readonly = '  ', unnamed = '[No Name]', newfile = '[New]' },
          },
        },

        lualine_x = {
          { macro_recording, color = { fg = moon.love, gui = 'bold' } },
          { lsp_clients,     color = { fg = moon.pine } },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
            diagnostics_color = {
              error = { fg = moon.love },
              warn  = { fg = moon.gold },
              info  = { fg = moon.foam },
              hint  = { fg = moon.iris },
            },
          },
          {
            'fileformat',
            symbols = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
            cond = function() return vim.bo.fileformat ~= 'unix' end,
          },
        },

        lualine_y = {
          { 'filetype', colored = true, icon_only = false },
        },

        lualine_z = {
          { 'location' },
          { 'progress' },
        },
      },

      inactive_sections = {
        lualine_c = {
          { 'filename', path = 1, symbols = { modified = ' ●', readonly = '  ', unnamed = '[No Name]' } },
        },
        lualine_x = { 'location' },
      },
    }
  end,
}
