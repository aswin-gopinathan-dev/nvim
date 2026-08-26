return {
	{
		"EdenEast/nightfox.nvim",
		--lazy=true,

		dependencies = {
			"nvim-lualine/lualine.nvim",
			"nvim-tree/nvim-web-devicons",
			"catppuccin/nvim",
			"rktjmp/lush.nvim",
		},
		config = function()
			vim.cmd.colorscheme "dayfox"

			--require("catppuccin").setup(flavour="latte",)

			-- setup must be called before loading
			--vim.cmd.colorscheme "catppuccin-latte"
			--require("yorumi").setup({variant="mist"})
			vim.g.yorumi_variant = "mist"
            vim.g.ayucolor = "light"


			require("catppuccin").setup({
				flavour = "macchiato", -- latte, frappe, macchiato, mocha

				transparent_background = false, -- disables setting the background color.	
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
				no_italic = true,  -- Force no italic
				no_bold = false,   -- Force no bold
				no_underline = false, -- Force no underline
				styles = {         -- Handles the styles of general hi groups (see `:h highlight-args`):
					comments = { "italic" }, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
					-- miscs = {}, -- Uncomment to turn off hard-coded styles
				},
				color_overrides = {},
				custom_highlights = function(colors)
					return
					{
						LineNr = { fg = colors.sky },
						CursorLineNr = { fg = colors.lavender },
						CursorLine = { bg = colors.surface0 },

						Cursor = { fg = colors.blue },
					}
				end,
				default_integrations = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
					-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
				},
			})
			
			require("newpaper").setup({ style = "auto"})
	

			-- setup must be called before loading
			--vim.cmd.colorscheme "newpaper"  --"terafox"
			
			vim.cmd.colorscheme "PaperColor"
			vim.api.nvim_set_hl(0, "TabLineFill", {
				fg = "#303030",
				bg = "#eeeeee",
			  })
			
			
			local function line_info()
				local line = vim.fn.line(".")
				local total = vim.fn.line("$")
				local col = vim.fn.col(".")
				return string.format("Ln %d/%d  Col %d", line, total, col)
			end


			require('lualine').setup {
				options = {
					--theme = "terafox",
					theme = "newpaper",
					globalstatus = true,
				},
				sections = {
					lualine_a = { 'mode' },
					lualine_b = { 'branch', 'diff', 'diagnostics' },
					lualine_c = { {
						function()
							return " 󰋇"
						end,
						separator = '',
					},
						{ 'filename', path = 1 } },
					--lualine_x = {'encoding', 'fileformat', 'filetype'},
					lualine_x = {},
					lualine_y = { 'progress' },
					lualine_z = { line_info }, --{'location'}
				},
			}


			local navic = require("nvim-navic")

			local function get_winbar_string(bufnr)
				local ft = vim.bo[bufnr].filetype

				-- no winbar in Neo-tree
				if ft == "neo-tree" then
					return ""
				end

				-- your normal winbar everywhere else
				if navic.is_available() then
					return "  %{%v:lua.require'nvim-navic'.get_location()%}"
				end

				return ""
			end


			vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
				callback = function(args)
					vim.wo.winbar = get_winbar_string(args.buf)
				end,
			})
		end,
	},

	-- 🔹 Other themes (installed but NOT auto-applied)
	{ "sainnhe/gruvbox-material", lazy = true },
	{ "olimorris/onedarkpro.nvim" },
	{ "shaunsingh/nord.nvim", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "projekt0n/github-nvim-theme" },
	{ "olivercederborg/poimandres.nvim", lazy = true },
	{ "yorumicolors/yorumi.nvim", lazy = true },
	{ "yorik1984/newpaper.nvim" },
	{ "NLKNguyen/papercolor-theme" },
	{ 'ayu-theme/ayu-vim', lazy = true},
    { 'scottmckendry/cyberdream.nvim', lazy = true},
    { 'mofiqul/adwaita.nvim' },
    { 'sainnhe/everforest', lazy = true },
    { 'letorbi/vim-colors-modern-borland' },
    { 'lmintmate/blue-mood-vim' },
    { "mhartington/oceanic-next" },
    { 'uloco/bluloco.nvim' },
    { 'ayu-theme/ayu-vim' },
    { "savq/melange-nvim" },
    { "folke/tokyonight.nvim" }
}
