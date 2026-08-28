vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set clipboard=unnamedplus")
vim.g.mapleader = " "
vim.g.background = "light"

vim.opt.swapfile = false
vim.opt.relativenumber = true -- shows line number relative to cursor position. used to jump lines
vim.opt.number = true         -- shows absolute line number where the cursor is
vim.opt.cursorline = true     -- highlight the cursor line
vim.wo.number = true
vim.o.whichwrap = "b,s,[,],h,l"
vim.opt.sessionoptions:remove("terminal")
vim.opt.showtabline = 2
-- Don't let sessions change the working directory
vim.opt.sessionoptions:remove("curdir")
vim.opt.sessionoptions:remove("sesdir")
vim.o.equalalways = false
--vim.opt.signcolumn = "auto:2"

vim.o.autocomplete = false
vim.o.completeopt = "menu,menuone,popup,noselect"
-- Completion menu
vim.o.pumborder = "rounded"
vim.o.pumheight = 12
vim.o.pumwidth = 30
vim.o.pummaxwidth = 60
vim.o.pumblend = 5
-- Show: completion | type | extra info
vim.o.completeitemalign = "abbr,kind,menu"


if vim.fn.has("unnamedplus") == 1 then
  vim.opt.clipboard = "unnamedplus"
else
  vim.opt.clipboard = ""
end
