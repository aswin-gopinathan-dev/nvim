return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    config = function()
        require("nvim-treesitter").install({
            "cpp",
            "lua",
            "python",
            "qmljs",
            "rust"
        })
    end, 
}
