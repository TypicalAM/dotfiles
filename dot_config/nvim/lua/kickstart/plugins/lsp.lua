require('mason').setup()

-- Broadcast blink.cmp capabilities to all LSP servers
local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('*', { capabilities = capabilities })

require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_enable = true,
}

local server_binaries = {
  nil_ls = 'nil',
  ruff = 'ruff',
  basedpyright = 'basedpyright-langserver',
  lua_ls = 'lua-language-server',
}

local function setup_if_available(server_name, opts)
  local bin = server_binaries[server_name]
  if bin and vim.fn.executable(bin) == 1 then
    if opts then
      vim.lsp.config(server_name, opts)
    end
    vim.lsp.enable(server_name)
    return true
  end
  return false
end

setup_if_available('nil_ls')

setup_if_available('ruff', {
  settings = {
    ruff = {
      cmd = { 'ruff', 'server' },
      filetypes = { 'python' },
      root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
      settings = {},
    },
  },
})

setup_if_available('basedpyright', {
  settings = {
    basedpyright = {
      disablePullDiagnostics = true,
      analysis = {
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'off',
      },
    },
  },

  -- Will need to fix this someday, not now tho

  handlers = {
    ['textDocument/publishDiagnostics'] = function() end,
  },

  on_attach = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    client.server_capabilities.codeActionProvider = false
    client.server_capabilities.codeLensProvider = nil
    client.server_capabilities.implementationProvider = false
  end,
})

setup_if_available('lua_ls', {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

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
