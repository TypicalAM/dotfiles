local theme = 'rosepine'

if theme == 'rosepine' then
  return {
    'rose-pine/neovim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'rose-pine'
    end,
  }
else
  return {
    'catppuccin/nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin-macchiato'
    end,
  }
end
