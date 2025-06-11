-- This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  -- clangd = {
  --   clangd = {
  --   }
  -- },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      -- diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local mason_lspconfig = require 'mason-lspconfig'
local lspconfig = require 'lspconfig'
mason_lspconfig.setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

lspconfig.pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
          maxLineLength = 200,
        },
      },
    },
  },
}

lspconfig.ruff.setup {
  settings = {
    ruff = {
      cmd = { 'ruff', 'server' },
      filetypes = { 'python' },
      root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
      settings = {},
    },
  },
}

lspconfig.basedpyright.setup {
  settings = {
    basedpyright = {
      disablePullDiagnostics = true, -- disables server -> client diagnostic push
      analysis = {
        diagnosticMode = 'openFilesOnly', -- minimum scope (no "off" available)
        typeCheckingMode = 'off', -- disable type checking
      },
    },
  },

  -- Will need to fix this someday, not now tho

  handlers = {
    -- Override diagnostic publishing to do nothing
    ['textDocument/publishDiagnostics'] = function() end,
  },

  on_attach = function(client)
    -- Strip all capabilities except document symbols
    --[[     client.server_capabilities.hoverProvider = false ]]
    client.server_capabilities.completionProvider = nil
    --[[     client.server_capabilities.signatureHelpProvider = nil ]]
    --[[     client.server_capabilities.definitionProvider = false ]]
    --[[     client.server_capabilities.referencesProvider = false ]]
    --[[     client.server_capabilities.renameProvider = false ]]
    -- client.server_capabilities.documentFormattingProvider = false
    -- client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.codeLensProvider = nil
    --[[     client.server_capabilities.documentHighlightProvider = false ]]
    --[[     client.server_capabilities.semanticTokensProvider = nil ]]
    --[[     client.server_capabilities.typeDefinitionProvider = false ]]
    client.server_capabilities.implementationProvider = false
    -- Leave only documentSymbolProvider
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- Create a command `:Format` local to the LSP buffer
vim.api.nvim_create_user_command('Format', function(_)
  vim.lsp.buf.format()
end, { desc = 'Format current buffer with LSP' })
