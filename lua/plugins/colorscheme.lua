return {
	{
        "savq/melange-nvim",
        priority = 1000,

        dependencies = {
            "nvim-lualine/lualine.nvim",
            "nvim-tree/nvim-web-devicons",
        },

        config = function()
            -- Default colorscheme
            vim.cmd.colorscheme("melange")

            -- Status line: line/column information
            local function line_info()
                local line = vim.fn.line(".")
                local total = vim.fn.line("$")
                local col = vim.fn.col(".")

                return string.format(
                    "Ln %d/%d  Col %d",
                    line,
                    total,
                    col
                )
            end

            -- Lualine
            require("lualine").setup({
                options = {
                    theme = "auto",
                    globalstatus = true,
                },

                sections = {
                    lualine_a = {
                        "mode",
                    },

                    lualine_b = {
                        "branch",
                        "diff",
                        "diagnostics",
                    },

                    lualine_c = {
                        {
                            function()
                                return " 󰋇"
                            end,
                            separator = "",
                        },

                        {
                            "filename",
                            path = 1,
                        },
                    },

                    lualine_x = {},

                    lualine_y = {
                        "progress",
                    },

                    lualine_z = {
                        line_info,
                    },
                },
            })

            -- Winbar / Navic
            local navic = require("nvim-navic")

            local function get_winbar_string(bufnr)
                local ft = vim.bo[bufnr].filetype

                -- No winbar in Neo-tree
                if ft == "neo-tree" then
                    return ""
                end

                if navic.is_available() then
                    return "  %{%v:lua.require'nvim-navic'.get_location()%}"
                end

                return ""
            end

            vim.api.nvim_create_autocmd(
                { "BufWinEnter", "WinEnter" },
                {
                    callback = function(args)
                        vim.wo.winbar =
                            get_winbar_string(args.buf)
                    end,
                }
            )
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
