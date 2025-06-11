local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = desc })
end

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local themes = require "telescope.themes"
local make_entry = require "telescope.make_entry"
local conf = require "telescope.config".values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }
      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "Multi Grep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
    sorter = require("telescope.sorters").empty(),
  }):find()
end

local function mark_todo()
  local todo_root = "/home/adam/notes/luzne notatki/temp"
  local todo_root_filename = "/home/adam/notes/luzne notatki/todo.md"
  local name = vim.api.nvim_buf_get_name(0)
  if name == todo_root_filename then
    local word_under_cursor = vim.fn.expand('<cword>')
    local todo_filename = todo_root .. "/" .. word_under_cursor .. ".todo.md"
    vim.cmd('e ' .. todo_filename)
    vim.opt.showtabline = 0
  end
end

local telescope = require('telescope.builtin')
local function telescope_live_grep_open_files()
  telescope.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

local fuzzy_current_buffer = function()
  telescope.current_buffer_fuzzy_find(themes.get_dropdown {
    winblend = 10,
    previewer = false,
  })
end

-- Telescope
nmap(';f', telescope.find_files, "Search files")
nmap(';j', telescope.jumplist, "Search jumplist")
nmap(';;', telescope.buffers, "Search open files")
nmap(';r', telescope.lsp_references, "Search references")
nmap(';c', telescope.commands, "Search commands")
nmap(';g', live_multigrep, "Live multigrep in cwd")
nmap('<C-CR>', telescope.lsp_definitions, 'Goto definition')
nmap('<C-[>', telescope.lsp_definitions, 'Goto definition')
nmap('gd', telescope.lsp_definitions, 'Goto definition')
nmap('gr', telescope.lsp_references, 'Goto deferences')
nmap('gt', telescope.lsp_type_definitions, 'Type definition')
nmap('gs', telescope.lsp_document_symbols, 'Document Symbols')
nmap(';w', fuzzy_current_buffer, "Fuzzily search in current buffer")
nmap(';o', telescope_live_grep_open_files, '[S]earch [/] in Open Files')
nmap(';s', telescope.lsp_dynamic_workspace_symbols,  '[s]earch symbols in the workspace')
nmap(';h', telescope.help_tags, '[S]earch [H]elp')
nmap(';d', telescope.diagnostics, '[S]earch [D]iagnostics')

-- LSP
nmap('gn', vim.lsp.buf.rename, 'Rename')
nmap('ga', vim.lsp.buf.code_action, 'Code Action')
nmap('gi', vim.lsp.buf.hover, 'Hover Documentation')
nmap('gf', vim.lsp.buf.format, 'Format document with LSP')
nmap('zf', vim.lsp.buf.format, 'Format document with LSP')
nmap('[e', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
nmap(']e', vim.diagnostic.goto_next, 'Go to next diagnostic message')
nmap('<leader>e', vim.diagnostic.open_float, 'Open floating diagnostic message')
nmap('.', vim.lsp.buf.signature_help, 'Signature Documentation')

-- Misc
nmap('<C-]>', mark_todo, 'Mark todos')
nmap('<S-CR>', mark_todo, 'Mark todos')
nmap('<C-a>', 'ggVG', 'Select everything')
nmap('<C-w>', ':bw<CR>', 'Close tab')
nmap('<TAB>', ':BufferLineCycleNext<CR>', 'Next tab')
nmap('M', ':set number!<CR>', 'Toggle line numbers')
nmap('zs', ':w<CR>', 'Save current file')
nmap('zq', ':q!<CR>', 'Quit')
nmap('<Space>', '<Nop>', "Silent space")

-- document existing key chains
local wk = require("which-key")

wk.add({
  -- Group declaration
  { "<leader>c", group = "[C]ode" },
  { "<leader>d", group = "[D]ocument" },
  { "<leader>g", group = "[G]it" },
  { "<leader>h", group = "Git [H]unk" },
  { "<leader>r", group = "[R]ename" },
  { "<leader>s", group = "[S]earch" },
  { "<leader>t", group = "[T]oggle" },
  { "<leader>w", group = "[W]orkspace" },

  -- Optional hidden keys (e.g., group prefixes or catch-alls)
  { "<leader>c_", hidden = true },
  { "<leader>d_", hidden = true },
  { "<leader>g_", hidden = true },
  { "<leader>h_", hidden = true },
  { "<leader>r_", hidden = true },
  { "<leader>s_", hidden = true },
  { "<leader>t_", hidden = true },
  { "<leader>w_", hidden = true },
})

wk.add({{ "<leader>", group = "VISUAL <leader>", mode = "v" }, { "<leader>h", desc = "Git [H]unk", mode = "v" }})
