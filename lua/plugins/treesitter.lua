return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = {
        "BufReadPost",
        "BufNewFile",
    },
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")

        local required = {
            "cpp",
            "lua",
            "python",
            "qmljs",
            "rust",
        }

        local installed = ts.get_installed()
        local installed_set = {}

        for _, parser in ipairs(installed) do
            installed_set[parser] = true
        end

        local missing = {}

        for _, parser in ipairs(required) do
            if not installed_set[parser] then
                table.insert(missing, parser)
            end
        end

        if #missing > 0 then
            ts.install(missing)
        end
    end,
}
