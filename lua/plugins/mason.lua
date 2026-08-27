return {
    "williamboman/mason.nvim",

    cmd = {
        "Mason",
        "MasonInstall",
        "MasonUninstall",
        "MasonUpdate",
        "MasonLog",
    },
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
    config = function()
        -- import mason
        local mason = require("mason")
        -- import mason-lspconfig
        local mason_lspconfig = require("mason-lspconfig")
        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            -- list of servers for mason to install
            ensure_installed = {
                --"clangd",         -- cpp
                --"codelldb",
                "biome",         -- json
                "lua_ls",        -- lua
                "pyright",       -- python
                "rust_analyzer", -- rust
                --"mypy",
                --"ruff",
            },
            --automatic_installation = true,
        })
    end,
}
