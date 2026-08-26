return {
	"akinsho/bufferline.nvim",
	--enabled = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("bufferline").setup({
			options = {
				offsets = {
					{
						filetype = "neo-tree", -- Use the filetype of your sidebar
						text = "Project Explorer", -- Optional: text to display in the offset area
						text_align = "left", -- Optional: alignment of the text
						separator = true, -- Optional: add a separator
					}
				},
				-- other bufferline options...

				indicator = {
					style = { 'icon', 'underline' }, -- Options: 'icon', 'underline', 'none'
				},
				numbers = "ordinal",
				separator_style = "thick",
				left_separator = ' | ',
				right_separator = ' | ',

				close_command = function(bufnr)
				  require("helper").smart_close_buffer(bufnr)
				end,

				right_mouse_command = function(bufnr)
				  require("helper").smart_close_buffer(bufnr)
				end,

                left_mouse_command = function(bufnr)
                    require("helper").activate_code_buffer()
                    vim.api.nvim_set_current_buf(bufnr)
                end,

				name_formatter = function(buf)
					return vim.fn.fnamemodify(buf.name, ":t")  -- filename only
				end,
			},

		})
	end,
}
