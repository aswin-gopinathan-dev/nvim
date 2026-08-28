local keymap = vim.keymap
local helper = require("helper")

local function load_dap()
  require("lazy").load({ plugins = { "nvim-dap" } })
end

-- Debugger
-- <leader>d	--> Begin Debug Functionalities
-- ============================================
keymap.set('n', '<F5>', function() load_dap(); require('neo-tree').close_all(); require('dap').continue() end)
keymap.set('n', '<F10>', function() load_dap(); require('dap').step_over() end)
keymap.set('n', '<F11>', function() load_dap(); require('dap').step_into() end)
keymap.set('n', '<leader><F10>', function() load_dap(); require('dap').step_out() end)
keymap.set('n', '<F9>', function() load_dap(); require('dap').toggle_breakpoint() end)
keymap.set('n', '<leader><F9>', function() load_dap(); require('dap').set_breakpoint() end)
keymap.set('n', '<leader><F5>', helper.close_debugger)
keymap.set('v', '<F12>', helper.add_debug_watch)
keymap.set("n", "<leader>dl", helper.select_debug_layout)
keymap.set('n', '<F12>', function() load_dap(); require('dapui').elements.watches.add(vim.fn.expand('<cword>')) end)
keymap.set('n', '<leader>ds', function() load_dap(); require("dapui").float_element("stacks", {width=70,height=20,enter=true}) end)
keymap.set('n', '<leader>db', function() load_dap(); require("dapui").float_element("breakpoints", {width=70,height=20,enter=true}) end)
-- ==========================================
-- <leader>d	--> End Debug Functionalities



-- LSP Shortcuts
local M = {}
function M.MapLspKeys(ev)
	local opts = { buffer = ev.buf, silent = true }
  
	-- <leader>h	--> Begin LSP Functionalities
	-- ======================================================
	keymap.set("n", "<leader>hr", "<cmd>Telescope lsp_references<CR>", vim.tbl_extend("force", opts, {desc="Show all references"}))
	keymap.set("n", "<leader>hD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, {desc="Go to declaration"}))
	keymap.set("n", "<leader>hd", "<cmd>Telescope lsp_definitions<CR>", vim.tbl_extend("force", opts, {desc="Go to definitions"}))
	keymap.set("n", "<leader>hk", function() vim.lsp.buf.hover({border = 'rounded',}) end, vim.tbl_extend("force", opts, {desc="Show documentation"}))
	keymap.set("n", "<leader>hh", function() vim.diagnostic.open_float(nil, {border = "rounded",scope = "line",focusable = false,}) end, vim.tbl_extend("force", opts, { desc = "Show line diagnostics" }))
	keymap.set("n", "<leader>hf", helper.format_file, {desc="Format File"})
	keymap.set("n", "<leader>h[", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, {desc="Go to previous diagnostic"}))
	keymap.set("n", "<leader>h]", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, {desc="Go to next diagnostic"}))
	keymap.set("n", "<Esc>", helper.close_floating_windows, { desc = "Close floating windows / clear hlsearch" })
	
	keymap.set("n", "g", "<cmd>Telescope lsp_definitions<CR>", vim.tbl_extend("force", opts, {silent = true}))
	-- ====================================================
	-- <leader>h	--> End LSP Functionalities
end

return M
