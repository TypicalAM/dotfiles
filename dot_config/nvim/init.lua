-- Set <space> as the leader key
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'conornewton/vim-pandoc-markdown-preview',

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  require 'kickstart.plugins.highlight',
  require 'kickstart.plugins.gitsigns',
  require 'kickstart.plugins.lualine',
  require 'kickstart.plugins.autoformat',
  require 'kickstart.plugins.bufferline',
  require 'kickstart.plugins.theme',

  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    dependencies = {
      {
        'DrKJeff16/wezterm-types',
        lazy = true,
        version = false, -- Get the latest version
      },
    },
    opts = {
      library = {
        -- Other library configs...
        { path = 'wezterm-types', mods = { 'wezterm' } },
      },
    },
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = 'enter',

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        menu = {
          border = 'rounded',
          winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
          draw = {
            gap = 1,
            columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = 'rounded',
            winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc',
          },
        },
        ghost_text = { enabled = true },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      fuzzy = { implementation = 'lua' },

      signature = {
        enabled = true,
        window = {
          border = 'rounded',
          winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
        },
      },
    },
  },

  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    -- branch = "develop", -- if you want develop branch
    -- keep in mind, it might break everything
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
  },

  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'echasnovski/mini.icons',
    },
    opts = {
      icons = {
        mappings = false,
      },
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    opts = {
      defaults = {
        file_ignore_patterns = {
          '__pycache__',
          'staticfiles',
          'media',
          'venv',
        },
      },
      pickers = {
        find_files = {
          follow = true,
        },
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.install').ensure_installed({
        'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash',
      })

      -- Shim removed nvim-treesitter v0 APIs that telescope (and other plugins) still call
      local parsers = require('nvim-treesitter.parsers')
      if not parsers.ft_to_lang then
        parsers.ft_to_lang = function(ft)
          return vim.treesitter.language.get_lang(ft) or ft
        end
        parsers.get_parser = function(bufnr, lang)
          return vim.treesitter.get_parser(bufnr, lang)
        end
      end
      package.loaded['nvim-treesitter.configs'] = {
        is_enabled = function() return false end,
        setup = function() end,
        get_module = function(name)
          if name == 'highlight' then
            return { additional_vim_regex_highlighting = false }
          end
          if name == 'textobjects.select' then
            return { lookahead = true, keymaps = {}, selection_modes = {} }
          end
          return {}
        end,
      }

      -- Treesitter-based indentation
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if pcall(vim.treesitter.get_parser, 0) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Textobjects: select
      local to_select = require('nvim-treesitter.textobjects.select')
      local select_maps = {
        aa = '@parameter.outer', ia = '@parameter.inner',
        af = '@function.outer',  ['if'] = '@function.inner',
        ac = '@class.outer',     ic = '@class.inner',
      }
      for lhs, capture in pairs(select_maps) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          to_select.select_textobject(capture, 'textobjects')
        end)
      end

      -- Textobjects: move
      local to_move = require('nvim-treesitter.textobjects.move')
      local move_maps = {
        [']m']  = { 'next_start',    '@function.outer' },
        [']]']  = { 'next_start',    '@class.outer'    },
        [']M']  = { 'next_end',      '@function.outer' },
        ['][']  = { 'next_end',      '@class.outer'    },
        ['[m']  = { 'previous_start','@function.outer' },
        ['[[']  = { 'previous_start','@class.outer'    },
        ['[M']  = { 'previous_end',  '@function.outer' },
        ['[]']  = { 'previous_end',  '@class.outer'    },
      }
      for lhs, v in pairs(move_maps) do
        local dir, capture = v[1], v[2]
        vim.keymap.set('n', lhs, function()
          to_move['goto_' .. dir](capture, 'textobjects')
        end)
      end

      -- Textobjects: swap
      local to_swap = require('nvim-treesitter.textobjects.swap')
      vim.keymap.set('n', '<leader>a', function()
        to_swap.swap_next('@parameter.inner', 'textobjects')
      end)
      vim.keymap.set('n', '<leader>A', function()
        to_swap.swap_previous('@parameter.inner', 'textobjects')
      end)
    end,
  },

  {
    "goolord/alpha-nvim",
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require 'kickstart.plugins.alpha'
    end,
  },
  {
    "voldikss/vim-floaterm",
    config = function()
      vim.api.nvim_create_user_command('FancyRanger', function()
        local cwd = vim.fn.getcwd()
        vim.cmd('FloatermNew --height=0.8 --width=0.6 --wintype=float --position=center --autoclose=2 ranger "' ..
          cwd .. '"')
      end, { desc = "Fancy floating file manager" })

      vim.api.nvim_create_user_command('FancyGitPush', function()
        vim.cmd('FloatermNew --height=0.6 --width=0.6 --wintype=float --position=center --autoclose=0 git push')
      end, { desc = "Fancy git push" })

      vim.api.nvim_create_user_command('FancyShell', function()
        vim.cmd('FloatermNew --height=0.9 --width=0.9 --wintype=float --position=center')
      end, { desc = "Inline shell" })

      vim.api.nvim_create_user_command('LazyGit', function()
        vim.cmd('FloatermNew --height=0.9 --width=0.9 --wintype=float --position=center --autoclose=2 lazygit')
      end, { desc = "Fancy lazygit" })
    end
  }
})

require 'kickstart.options' -- Options
require 'kickstart.keymaps' -- Keymaps

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

require 'kickstart.keymaps'
require 'kickstart.plugins.lsp'

pcall(vim.keymap.del, 'n', '<C-w>d')
pcall(vim.keymap.del, 'n', '<C-w><C-D>')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
