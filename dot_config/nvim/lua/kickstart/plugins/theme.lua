return {
  'rose-pine/neovim',
  name = 'rose-pine',
  priority = 1000,
  config = function()
    require('rose-pine').setup {
      variant = 'moon',
      dark_variant = 'moon',
      dim_inactive_windows = false,
      extend_background_behind_borders = true,

      enable = {
        terminal_colors = true,
        legacy_highlights = true,
        migrations = true,
      },

      styles = {
        bold = true,
        italic = true,
        transparency = true,
      },

      groups = {
        border = 'muted',
        link = 'iris',
        panel = 'surface',
        error = 'love',
        hint = 'iris',
        info = 'foam',
        note = 'pine',
        todo = 'rose',
        warn = 'gold',
        git_add = 'foam',
        git_change = 'rose',
        git_delete = 'love',
        git_dirty = 'rose',
        git_ignore = 'muted',
        git_merge = 'iris',
        git_rename = 'pine',
        git_stage = 'iris',
        git_text = 'rose',
        git_untracked = 'subtle',
        h1 = 'iris',
        h2 = 'foam',
        h3 = 'rose',
        h4 = 'gold',
        h5 = 'pine',
        h6 = 'foam',
      },

      -- Silently convert underlines to undercurls everywhere
      before_highlight = function(_, highlight, _)
        if highlight.underline then
          highlight.underline = false
          highlight.undercurl = true
        end
      end,

      highlight_groups = {
        -- Cursor line
        CursorLine    = { bg = 'highlight_med' },
        CursorLineNr  = { fg = 'gold', bold = true },
        LineNr        = { fg = 'muted' },

        -- Floating windows
        FloatBorder  = { fg = 'iris', bg = 'NONE' },
        FloatTitle   = { fg = 'iris', bold = true },
        NormalFloat  = { bg = 'NONE' },

        -- Telescope — all three panes must be explicit; rose-pine only covers TelescopeNormal
        TelescopeNormal          = { bg = 'NONE' },
        TelescopePreviewNormal   = { bg = 'NONE' },
        TelescopeResultsNormal   = { bg = 'NONE' },
        TelescopeBorder          = { fg = 'iris', bg = 'NONE' },
        TelescopePromptBorder    = { fg = 'pine', bg = 'NONE' },
        TelescopePreviewBorder   = { fg = 'muted', bg = 'NONE' },
        TelescopeResultsBorder   = { fg = 'muted', bg = 'NONE' },
        TelescopePromptNormal    = { bg = 'NONE' },
        TelescopePromptPrefix    = { fg = 'iris' },
        TelescopePromptTitle     = { fg = 'foam', bold = true },
        TelescopePreviewTitle    = { fg = 'pine', bold = true },
        TelescopeResultsTitle    = { fg = 'rose', bold = true },
        TelescopeSelection       = { fg = 'text', bg = 'highlight_med', bold = true },
        TelescopeSelectionCaret  = { fg = 'rose', bg = 'highlight_med' },
        TelescopeMatching        = { fg = 'gold', bold = true },

        -- LSP diagnostics
        DiagnosticError              = { fg = 'love' },
        DiagnosticWarn               = { fg = 'gold' },
        DiagnosticInfo               = { fg = 'foam' },
        DiagnosticHint               = { fg = 'iris' },
        DiagnosticVirtualTextError   = { fg = 'love', bg = 'NONE', italic = true },
        DiagnosticVirtualTextWarn    = { fg = 'gold', bg = 'NONE', italic = true },
        DiagnosticVirtualTextInfo    = { fg = 'foam', bg = 'NONE', italic = true },
        DiagnosticVirtualTextHint    = { fg = 'iris', bg = 'NONE', italic = true },
        DiagnosticUnderlineError     = { undercurl = true, sp = 'love' },
        DiagnosticUnderlineWarn      = { undercurl = true, sp = 'gold' },
        DiagnosticUnderlineInfo      = { undercurl = true, sp = 'foam' },
        DiagnosticUnderlineHint      = { undercurl = true, sp = 'iris' },

        -- Search & selection
        Search    = { fg = 'base', bg = 'gold' },
        IncSearch = { fg = 'base', bg = 'rose' },
        CurSearch = { fg = 'base', bg = 'iris', bold = true },
        Visual    = { bg = 'highlight_high' },

        -- Indent blankline
        IblIndent = { fg = 'highlight_med' },
        IblScope  = { fg = 'iris' },

        -- Completion menu (built-in)
        Pmenu      = { fg = 'subtle', bg = 'surface' },
        PmenuSel   = { fg = 'text', bg = 'highlight_med', bold = true },
        PmenuSbar  = { bg = 'surface' },
        PmenuThumb = { bg = 'muted' },

        -- blink.cmp windows
        BlinkCmpMenu                = { bg = 'NONE' },
        BlinkCmpMenuBorder          = { fg = 'iris', bg = 'NONE' },
        BlinkCmpMenuSelection       = { bg = 'highlight_med', bold = true },
        BlinkCmpDoc                 = { bg = 'NONE' },
        BlinkCmpDocBorder           = { fg = 'muted', bg = 'NONE' },
        BlinkCmpSignatureHelp       = { bg = 'NONE' },
        BlinkCmpSignatureHelpBorder = { fg = 'pine', bg = 'NONE' },
        BlinkCmpGhostText           = { fg = 'muted', italic = true },
        BlinkCmpScrollBarThumb      = { bg = 'muted' },
        BlinkCmpScrollBarGutter     = { bg = 'NONE' },
        BlinkCmpLabelMatch          = { fg = 'gold', bold = true },

        -- blink.cmp kind icon colours (match our TreeSitter palette)
        BlinkCmpKindText          = { fg = 'subtle' },
        BlinkCmpKindMethod        = { fg = 'foam' },
        BlinkCmpKindFunction      = { fg = 'foam' },
        BlinkCmpKindConstructor   = { fg = 'foam' },
        BlinkCmpKindField         = { fg = 'iris' },
        BlinkCmpKindVariable      = { fg = 'text' },
        BlinkCmpKindClass         = { fg = 'gold' },
        BlinkCmpKindInterface     = { fg = 'gold' },
        BlinkCmpKindModule        = { fg = 'foam' },
        BlinkCmpKindProperty      = { fg = 'iris' },
        BlinkCmpKindUnit          = { fg = 'rose' },
        BlinkCmpKindValue         = { fg = 'rose' },
        BlinkCmpKindEnum          = { fg = 'gold' },
        BlinkCmpKindKeyword       = { fg = 'pine' },
        BlinkCmpKindSnippet       = { fg = 'rose' },
        BlinkCmpKindColor         = { fg = 'rose' },
        BlinkCmpKindFile          = { fg = 'foam' },
        BlinkCmpKindReference     = { fg = 'iris' },
        BlinkCmpKindFolder        = { fg = 'foam' },
        BlinkCmpKindEnumMember    = { fg = 'iris' },
        BlinkCmpKindConstant      = { fg = 'iris' },
        BlinkCmpKindStruct        = { fg = 'gold' },
        BlinkCmpKindEvent         = { fg = 'gold' },
        BlinkCmpKindOperator      = { fg = 'subtle' },
        BlinkCmpKindTypeParameter = { fg = 'foam' },

        -- Folds
        Folded     = { fg = 'muted', bg = 'surface', italic = true },
        FoldColumn = { fg = 'muted' },

        -- Which-key
        WhichKey          = { fg = 'iris' },
        WhichKeyGroup     = { fg = 'foam' },
        WhichKeyDesc      = { fg = 'subtle' },
        WhichKeySeparator = { fg = 'muted' },
        WhichKeyBorder    = { fg = 'muted' },

        -- Gitsigns
        GitSignsAdd              = { fg = 'foam' },
        GitSignsChange           = { fg = 'gold' },
        GitSignsDelete           = { fg = 'love' },
        GitSignsCurrentLineBlame = { fg = 'muted', italic = true },

        -- TreeSitter — vivid syntax
        ['@variable']             = { fg = 'text' },
        ['@variable.builtin']     = { fg = 'love', italic = true },
        ['@variable.parameter']   = { fg = 'rose', italic = true },
        ['@variable.member']      = { fg = 'iris' },

        ['@function']             = { fg = 'foam', bold = true },
        ['@function.builtin']     = { fg = 'pine', italic = true },
        ['@function.call']        = { fg = 'foam' },
        ['@function.method']      = { fg = 'foam', bold = true },
        ['@function.method.call'] = { fg = 'foam' },

        ['@keyword']              = { fg = 'pine', italic = true },
        ['@keyword.return']       = { fg = 'love', italic = true },
        ['@keyword.function']     = { fg = 'pine', italic = true },
        ['@keyword.operator']     = { fg = 'subtle' },
        ['@keyword.import']       = { fg = 'iris', italic = true },
        ['@keyword.exception']    = { fg = 'love', italic = true },
        ['@keyword.conditional']  = { fg = 'pine', italic = true },
        ['@keyword.repeat']       = { fg = 'pine', italic = true },

        ['@string']               = { fg = 'gold' },
        ['@string.escape']        = { fg = 'rose', bold = true },
        ['@string.special']       = { fg = 'rose' },
        ['@string.regexp']        = { fg = 'foam', italic = true },

        ['@number']               = { fg = 'rose' },
        ['@number.float']         = { fg = 'rose' },
        ['@boolean']              = { fg = 'love', bold = true },

        ['@comment']              = { fg = 'muted', italic = true },
        ['@comment.documentation']= { fg = 'subtle', italic = true },
        ['@comment.error']        = { fg = 'love', italic = true },
        ['@comment.warning']      = { fg = 'gold', italic = true },
        ['@comment.todo']         = { fg = 'rose', bold = true, italic = true },
        ['@comment.note']         = { fg = 'foam', italic = true },

        ['@type']                 = { fg = 'foam' },
        ['@type.builtin']         = { fg = 'foam', italic = true },
        ['@type.definition']      = { fg = 'foam', bold = true },

        ['@constant']             = { fg = 'iris' },
        ['@constant.builtin']     = { fg = 'love', bold = true },
        ['@constant.macro']       = { fg = 'iris', bold = true },

        ['@property']             = { fg = 'iris' },
        ['@attribute']            = { fg = 'iris', italic = true },
        ['@constructor']          = { fg = 'foam', bold = true },

        ['@operator']             = { fg = 'subtle' },
        ['@punctuation.bracket']  = { fg = 'subtle' },
        ['@punctuation.delimiter']= { fg = 'subtle' },
        ['@punctuation.special']  = { fg = 'rose' },

        ['@markup.heading']       = { fg = 'iris', bold = true },
        ['@markup.heading.1']     = { fg = 'iris', bold = true },
        ['@markup.heading.2']     = { fg = 'foam', bold = true },
        ['@markup.heading.3']     = { fg = 'rose', bold = true },
        ['@markup.raw']           = { fg = 'gold' },
        ['@markup.link']          = { fg = 'pine', italic = true },
        ['@markup.link.url']      = { fg = 'pine', underline = true },
        ['@markup.italic']        = { italic = true },
        ['@markup.strong']        = { bold = true },
      },
    }

    vim.cmd.colorscheme 'rose-pine'

    -- Rose Pine Moon palette literals — used below so no palette lookup is needed
    local subtle = '#908caa'
    local text   = '#e0def4'

    -- Strips only the bg from a highlight, preserving all other attrs
    local function clear_bg(group)
      local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
      hl.bg, hl.ctermbg = nil, nil
      vim.api.nvim_set_hl(0, group, hl)
    end

    -- dim_inactive_windows is disabled because rose-pine sets NormalNC to a solid
    -- surface color for the dim effect, which leaks into every non-current float pane
    -- (Telescope results/preview, floaterm sub-windows, etc).
    local function apply_transparent()
      for _, g in ipairs({
        'Normal', 'NormalNC', 'NormalFloat',
        'TelescopeNormal', 'TelescopeResultsNormal',
        'TelescopePreviewNormal', 'TelescopePromptNormal',
        'Floaterm', 'FloatermNC',
        'BlinkCmpMenu', 'BlinkCmpDoc', 'BlinkCmpSignatureHelp',
      }) do
        clear_bg(g)
      end
    end

    apply_transparent()

    -- Re-apply after all plugins have finished loading (catches late highlight setters)
    vim.api.nvim_create_autocmd('VimEnter', {
      once     = true,
      callback = function() vim.schedule(apply_transparent) end,
    })

    -- Re-apply if the colorscheme is ever reloaded
    vim.api.nvim_create_autocmd('ColorScheme', {
      pattern  = 'rose-pine*',
      callback = apply_transparent,
    })
  end,
}
