require('mason').setup()

local lspconfig = require 'lspconfig'
lspconfig.nil_ls.setup {}

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
      disablePullDiagnostics = true,      -- disables server -> client diagnostic push
      analysis = {
        diagnosticMode = 'openFilesOnly', -- minimum scope (no "off" available)
        typeCheckingMode = 'off',         -- disable type checking
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
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
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

lspconfig.lua_ls.setup {
  Lua = {
    workspace = { checkThirdParty = false },
    telemetry = { enable = false },
    -- diagnostics = { disable = { 'missing-fields' } },
  },
}

-- blink.cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = require('blink.cmp').get_lsp_capabilities()
require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_installation = false,
  handlers = {
    function(server_name)
      local server = servers[server_name] or {}
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      require('lspconfig')[server_name].setup(server)
    end,
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
    ---@param client vim.lsp.Client
    ---@param method vim.lsp.protocol.Method
    ---@param bufnr? integer some lsp support methods only in specific files
    ---@return boolean
    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end,
})

-- Create a command `:Format` local to the LSP buffer
vim.api.nvim_create_user_command('Format', function(_)
  vim.lsp.buf.format()
end, { desc = 'Format current buffer with LSP' })

-- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("warning: multiple different client offset_encodings") then
    return
  end

  notify(msg, ...)
end

-- Make nvim shut up about the buf_highlight_references race condition
local orig_handler = vim.lsp.handlers["textDocument/documentHighlight"]
vim.lsp.handlers["textDocument/documentHighlight"] = function(err, result, ctx, config)
  local bufnr = ctx.bufnr
  if not vim.api.nvim_buf_is_valid(bufnr) then return end
  return orig_handler(err, result, ctx, config)
end
