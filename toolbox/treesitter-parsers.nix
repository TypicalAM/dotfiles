# Tree-sitter parsers compiled into the toolbox, so nvim highlights these
# languages offline and without a C compiler on the target host.
#
# Language -> GitHub repo (and subdirectory, for repos holding several
# grammars), copied from lua/nvim-treesitter/parsers.lua. The revision each one
# is built at comes from the locked nvim-treesitter's own lockfile.json, so the
# parsers always match the queries shipped with the plugin.
#
# Keep this in step with ensure_installed in dot_config/nvim/init.lua; a
# language missing here is still downloaded and compiled on first start, which
# needs network and a C compiler.
{
  bash = { repo = "tree-sitter/tree-sitter-bash"; };
  c = { repo = "tree-sitter/tree-sitter-c"; };
  cpp = { repo = "tree-sitter/tree-sitter-cpp"; };
  go = { repo = "tree-sitter/tree-sitter-go"; };
  javascript = { repo = "tree-sitter/tree-sitter-javascript"; };
  lua = { repo = "MunifTanjim/tree-sitter-lua"; };
  python = { repo = "tree-sitter/tree-sitter-python"; };
  rust = { repo = "tree-sitter/tree-sitter-rust"; };
  tsx = { repo = "tree-sitter/tree-sitter-typescript"; location = "tsx"; };
  typescript = { repo = "tree-sitter/tree-sitter-typescript"; location = "typescript"; };
  vim = { repo = "neovim/tree-sitter-vim"; };
  vimdoc = { repo = "neovim/tree-sitter-vimdoc"; };
}
