# lazy-lock.json name -> GitHub repo, so the toolbox can prefetch every plugin
# at the locked commit and nvim starts without network.
#
# lazy-lock.json only records names, hence this table. toolbox.nix fails the
# build with the missing names when a plugin is added to the config but not here.
{
  "Comment.nvim" = "numToStr/Comment.nvim";
  "LuaSnip" = "L3MON4D3/LuaSnip";
  "alpha-nvim" = "goolord/alpha-nvim";
  "blink.cmp" = "saghen/blink.cmp";
  "bufferline.nvim" = "akinsho/bufferline.nvim";
  "fidget.nvim" = "j-hui/fidget.nvim";
  "friendly-snippets" = "rafamadriz/friendly-snippets";
  "gitsigns.nvim" = "lewis6991/gitsigns.nvim";
  "gopher.nvim" = "olexsmir/gopher.nvim";
  "indent-blankline.nvim" = "lukas-reineke/indent-blankline.nvim";
  "lazy.nvim" = "folke/lazy.nvim";
  "lazydev.nvim" = "folke/lazydev.nvim";
  "lualine.nvim" = "nvim-lualine/lualine.nvim";
  "mason-lspconfig.nvim" = "mason-org/mason-lspconfig.nvim";
  "mason.nvim" = "mason-org/mason.nvim";
  "mini.hipatterns" = "echasnovski/mini.hipatterns";
  "mini.icons" = "echasnovski/mini.icons";
  "nvim-lspconfig" = "neovim/nvim-lspconfig";
  "nvim-treesitter" = "nvim-treesitter/nvim-treesitter";
  "nvim-treesitter-textobjects" = "nvim-treesitter/nvim-treesitter-textobjects";
  "nvim-web-devicons" = "nvim-tree/nvim-web-devicons";
  "plenary.nvim" = "nvim-lua/plenary.nvim";
  "rose-pine" = "rose-pine/neovim";
  "telescope-fzf-native.nvim" = "nvim-telescope/telescope-fzf-native.nvim";
  "telescope.nvim" = "nvim-telescope/telescope.nvim";
  "vim-floaterm" = "voldikss/vim-floaterm";
  "vim-fugitive" = "tpope/vim-fugitive";
  "vim-pandoc-markdown-preview" = "conornewton/vim-pandoc-markdown-preview";
  "vim-rhubarb" = "tpope/vim-rhubarb";
  "vim-sleuth" = "tpope/vim-sleuth";
  "wezterm-types" = "DrKJeff16/wezterm-types";
  "which-key.nvim" = "folke/which-key.nvim";
}
