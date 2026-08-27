return {
  "NvChad/nvim-colorizer.lua",
  ft = {
      "qml",
      "lua",
  },
  config = function()
    require("colorizer").setup({
      qml = {
        RGB = true,
        RRGGBB = true,
        AARRGGBB = true,
        css = true,
      },
      lua = { names = false },
    }, {
      mode = "background", -- background color like VS Code
    })
  end,
}
