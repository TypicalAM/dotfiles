return {
  'echasnovski/mini.hipatterns',
  config = function()
    local hipatterns = require('mini.hipatterns')
    hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme     = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
    hack      = { pattern = '%f[%w]()HACK()%f[%W]', group = 'MiniHipatternsHack' },
    todo      = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
    note      = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
    test      = {
      pattern = '%f[%w]()%a+()%f[%W]',
      group = function(_, match, _)
        local word = match:lower()
        if word == 'dupa' or word == 'kurwa' or word == 'chuj' then
          return 'MiniHipatternsFixme'
        end
        return nil
      end,
    },

    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
  })
  end
}
