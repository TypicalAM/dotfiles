return {
  'lewis6991/gitsigns.nvim',
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    current_line_blame = true,
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map({ 'n', 'v' }, ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.next_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'Jump to next hunk' })

      map({ 'n', 'v' }, '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.prev_hunk()
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'Jump to previous hunk' })

      -- Actions
      -- visual mode
      map('v', '<leader>hs', function()
        gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'stage git hunk' })
      map('v', '<leader>hr', function()
        gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
      end, { desc = 'reset git hunk' })
      -- normal mode
      map('n', 'ga', gs.stage_hunk, { desc = 'Git stage hunk' })
      map('n', '<leader>ga', gs.stage_hunk, { desc = 'Git stage hunk' })
      map('n', '<leader>gr', gs.reset_hunk, { desc = 'Git reset hunk' })
      map('n', '<leader>gfs', gs.stage_buffer, { desc = 'Git stage file' })
      map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
      map('n', '<leader>gfr', gs.reset_buffer, { desc = 'Git Reset buffer' })
      map('n', '<leader>gs', gs.preview_hunk, { desc = 'Preview git hunk' })
      map('n', '<leader>gb', function()
        gs.blame_line { full = false }
      end, { desc = 'git blame line' })
      map('n', '<leader>gd', function()
        gs.diffthis '~'
      end, { desc = 'git diff against last commit' })

      -- Toggles
      map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
      map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })
    end,
  },
}
