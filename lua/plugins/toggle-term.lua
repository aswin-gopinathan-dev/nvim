return {
  "akinsho/toggleterm.nvim",

  cmd = {
      "ToggleTerm",
      "TermExec",
  },

  keys = {
      [[<c-\>]],
      "<leader>tt",
      "<leader>tf",
  },

  config = function()
    local platform = require("platform")

    if platform.is_win then
      vim.o.shell = platform.get_shell()
      vim.o.shellcmdflag = "-NoLogo -NoProfile -Command"
      vim.o.shellxquote = ""
    else
      vim.o.shell = platform.get_shell()
    end

    require("toggleterm").setup({
      size = 9,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 3,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = false,
      direction = "horizontal",
      close_on_exit = true,
      shell = platform.get_shell_cmd(),

      float_opts = {
        border = "curved",
        col = 8,
        row = 2,
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    })
  end,
}
