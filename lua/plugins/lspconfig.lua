return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
    },
    config = function()
        local navic = require("nvim-navic")

        -- 1. Global Diagnostic Configuration (Replaces manual sign loops)
        vim.diagnostic.config({
            underline = true,
            update_in_insert = true, -- Replaces your custom insert mode logic
            severity_sort = true,
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN]  = " ",
                    [vim.diagnostic.severity.HINT]  = "󰠠 ",
                    [vim.diagnostic.severity.INFO]  = " ",
                },
            },
        })

        -- 2. Global LspAttach for Shared Logic
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                require("vim-keymaps-debug").MapLspKeys(ev)
								
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then
                    return
                end

                if client:supports_method("textDocument/completion") then
                    local chars = {}
                    for i = 32, 126 do
                        table.insert(chars, string.char(i))
                    end

                    client.server_capabilities.completionProvider.triggerCharacters = chars

                    vim.lsp.completion.enable(true, client.id, ev.buf, {
                        autotrigger = true,
                    })
                end

                if (vim.g.restoring_session ~= nil and vim.g.restoring_session) or vim.api.nvim_get_current_buf() ~= ev.buf then
					return
				end

                -- Attach Navic globally if server supports symbols
                if client.server_capabilities.documentSymbolProvider then
                    navic.attach(client, ev.buf)
                end

                -- Map custom keys from your external module
                -- require("vim-keymaps-debug").MapLspKeys(ev)
            end,
        })

        -- Enable specific servers
        -- Note: 'ruff_lsp' is deprecated; Nvim 0.11 uses 'ruff' natively
        local servers = { "lua_ls", "clangd", "pyright", "ruff", "qmlls", "rust_analyzer" }

        -- Define specific settings for each server to avoid "overlap"
        vim.lsp.config("pyright", {
            filetypes = { "python" },
            -- Ensure pyright looks for your entrypoint.py or scripts folder
            root_dir = vim.fs.root(0, { "sagacity", "entrypoint.py", "pyproject.toml", ".git" }),
        })

        vim.lsp.config("clangd", {
            cmd = { "clangd", "--function-arg-placeholders=false", },
            filetypes = { "cpp", "c", "objc", "objcpp", "cuda", "proto" },
            root_dir = vim.fs.root(0, { "CMakeLists.txt", "build", ".git" }),
        })

        vim.lsp.config("qmlls", {
            cmd = { "qmlls", "-E" },
            filetypes = { "qml", "qmljs" },
            -- Specifically look for QML project markers
            root_dir = vim.fs.root(0, { "main.qml", "qmldir", ".git" }),
        })

        -- Activate all servers
        vim.lsp.enable(servers)

    end
}
