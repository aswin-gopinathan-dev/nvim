local keymap = vim.keymap


-- <leader>f	--> Begin Find Functionalities
-- ===========================================
keymap.set("n", "<leader>fs", function() require("telescope.builtin").live_grep({cwd = vim.loop.cwd(), hidden = true, no_ignore = false, additional_args = require("helper").text_filter() }) end)
keymap.set("n", "<leader>ff", function() require("telescope.builtin").find_files({cwd = vim.loop.cwd(), hidden = true, no_ignore = false, find_command = { "fd", "--type", "f", "--strip-cwd-prefix" }, file_ignore_patterns = require("helper").folder_filter(), sorter = require("telescope.sorters").get_substr_matcher({case_mode = "ignore_case"}), case_mode = "ignore_case",}) end)
keymap.set("n", "<leader>fg", function() require("telescope.builtin").resume() end, { desc = "Resume last find" })
keymap.set("n", "<leader>fh", function() require("spectre").open() end, { desc = "Replace string" })
keymap.set("n", "<leader>fo", function() require("telescope.builtin").oldfiles() end, { desc = "Find old files" })
keymap.set("n", "<leader>f/", function() require("helper").find_word_under_cursor() end, { desc = "Find word under cursor" })
keymap.set("v", "<leader>f/", function() require("helper").find_selected_word() end, { desc = "Live Grep Visual Selection" })
keymap.set("n", "<leader>fd", function() require("helper").find_classes_and_methods() end, { desc = "List classes/methods" })
keymap.set("n", "<leader>fc", function() require("helper").manage_search_settings() end, { desc = "Find Settings" })
-- =========================================
-- <leader>f	--> End Find Functionalities



-- <leader>b	--> Begin Tab Functionalities
-- ===========================================
keymap.set("n", "<leader>b]", "<Cmd>BufferLineGoToBuffer 1<CR>")
keymap.set("n", "<leader>b[", "<Cmd>BufferLineGoToBuffer -1<CR>")
keymap.set("n", "<leader>bX", "<Cmd>BufferLineCloseOthers<CR>")
keymap.set("n", '<leader><Right>', '<Cmd>BufferLineCycleNext<CR>', { noremap = true, silent = true })
keymap.set("n", "<leader><tab>", "<cmd>b#<CR>", { noremap = true, silent = true })
keymap.set("n", '<leader><Left>', '<Cmd>BufferLineCyclePrev<CR>', { noremap = true, silent = true })
keymap.set("n", "<leader><S-Left>", "<cmd>BufferLineMovePrev<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader><S-Right>", "<cmd>BufferLineMoveNext<CR>", { noremap = true, silent = true })
keymap.set("n", "<leader>bx", function() require("helper").smart_close_buffer() end, { silent = true, noremap = true })
keymap.set("n", "<leader>bb", function() require("helper").get_files_list() end, { desc = "Buffer list (filenames only)" })

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    vim.cmd("BufferLineGoToBuffer " .. i)
  end, { silent = true, desc = nil })
end

local gs = require("gitsigns")
keymap.set("n", "<leader>v]", gs.next_hunk, { desc = "Next hunk" })
keymap.set("n", "<leader>v[", gs.prev_hunk, { desc = "Prev hunk" })
keymap.set("n", "<leader>vp", gs.preview_hunk, { desc = "Preview hunk" })
keymap.set("n", "<leader>vd", gs.diffthis, { desc = "Diff this" })
keymap.set("n", "<leader>vD", function() gs.diffthis("~") end, { desc = "Diff against last commit" })
-- ========================================
-- <leader>b	--> End Tab Functionalities



-- <leader>w	--> Begin Window Functionalities
-- =============================================
keymap.set("n", "<leader>wh", "<C-w>v")
keymap.set("n", "<leader>wv", "<C-w>s")
keymap.set("n", "<leader>we", "<C-w>=")
keymap.set("n", "<leader>w", function() require("helper").resize_window() end)
keymap.set({"n", "t"}, '<leader>w]', function() require("helper").activate_next_window() end)
keymap.set("n", "<leader>wr", function() require("helper").reset_buffers_to_default_size() end)
keymap.set({"n", "t"}, "<leader>ww", function() require("helper").activate_code_buffer() end)
keymap.set("n", "<A-w>", function()  require("helper").code_only_view() end, { silent = true })
keymap.set("i", "<A-w>", function()  vim.cmd("stopinsert") require("helper").code_only_view() end, { silent = true })
keymap.set("t", "<A-w>", [[<C-\><C-n><Cmd>lua require("helper").code_only_view()<CR>]], { silent = true })
-- ===========================================
-- <leader>w	--> End Window Functionalities



-- <leader>g	--> Begin Navigation Functionalities
-- =================================================
keymap.set("n", "<leader>g[", "<C-o>") -- go to previous cursor pos
keymap.set("n", "<leader>g]", "<C-i>") -- go to next cursor pos
keymap.set("n", "<leader>[", "<C-o>")  -- go to previous cursor pos
keymap.set("n", "<leader>]", "<C-i>")  -- go to next cursor pos
keymap.set("n", "<leader>ge", "$")     -- go to end of current line
keymap.set("n", "<leader>gs", "^")     -- go to start of current line
keymap.set("n", "<leader>gS", "gg^")   -- go to start of current file
keymap.set("n", "<leader>gE", "G$")    -- go to end of current line
-- =================================================
-- <leader>g	--> End Navigation Functionalities



-- <leader>t	--> Begin Terminal Functionalities
-- ===============================================
keymap.set("n", "<leader>tf", function()
    require("helper").open_terminal_floating()
    vim.schedule(function()
        vim.cmd("startinsert")
    end)
end, { desc = "Open Floating Terminal" })

keymap.set("n", "<leader>tt", function()
    require("helper").open_terminal_horizontal()
    vim.schedule(function()
        vim.cmd("startinsert")
    end)
end, { desc = "Open Horizontal Terminal" })

--[[
keymap.set({ "n", "t" }, "<leader>tt", function()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "toggleterm" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  vim.cmd("ToggleTerm")
end, { desc = "Open or focus terminal" })
]]

keymap.set({ "n", "t" }, "<leader>ty", function()
    require("helper").open_terminal_side()
end, { desc = "Open Right-side Terminal" })

keymap.set("n", "<leader>ts", function() require("helper").preview_svg() end, { desc = 'Preview SVG' })
--keymap.set("n", "<F8>", function() require("helper").preview_svg() end, { desc = 'Preview SVG' })
keymap.set("n", "<leader>tr", function() require("helper").run_app() end, { desc = "Run Application" })
keymap.set({ "n", "i", "t" }, "<F7>", function() require("helper").run_app2() end)
keymap.set({ "n", "i", "t" }, "<F8>", function() require("helper").build_app() end)
keymap.set({ "t" }, "<Esc><Esc>", function() require("helper").close_terminal() end)
-- <leader>tv mapping is in py-venv.lua
-- =============================================
-- <leader>t	--> End Terminal Functionalities



-- <leader>e	--> Begin Explorer Functionalities
-- ===============================================
--keymap.set("n", "<leader>ee", ":Neotree toggle<CR>")
--keymap.set("n", "<leader>ef", ":Neotree focus<CR>")
keymap.set("n", "<leader>ee", function()
  local neotree_win = nil

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      neotree_win = win
      break
    end
  end

  if neotree_win then
    vim.api.nvim_set_current_win(neotree_win)
  else
    vim.cmd("Neotree show focus")
  end
end, { desc = "Open/focus Neo-tree" })

--[[
keymap.set("n", "<leader>ev", function()
  local path = vim.fn.expand("%:p:h")
  vim.fn.setreg("+", path)
  -- open Windows Run dialog
  vim.fn.jobstart({ "cmd.exe", "/C", "start", "", path }, {
    detach = true,
  })
end, { desc = "Open folder in Explorer" })
]]

vim.keymap.set('n', '<leader>ev', function()
    local file_path = vim.api.nvim_buf_get_name(0)
    if file_path == '' then
        vim.notify("Buffer has no file path", vim.log.levels.WARN)
        return
    end

    local sys = vim.loop.os_uname().sysname

    if sys == "Windows_NT" then
        local win_path = file_path:gsub('/', '\\')
        local cmd = string.format('explorer.exe /select,"%s"', win_path)
        vim.fn.jobstart(cmd, { detach = true }) 
    else
        vim.fn.jobstart({
            "dbus-send", "--session", "--print-reply",
            "--dest=org.freedesktop.FileManager1",
            "/org/freedesktop/FileManager1",
            "org.freedesktop.FileManager1.ShowItems",
            "array:string:file://" .. file_path, "string:"
        }, { detach = true })
    end 
end, { desc = "Reveal file in OS File Explorer" })



--require("helper").preview_file() end, { desc = "File Preview" })
-- =============================================
-- <leader>e	--> End Explorer Functionalities



-- <leader>s	--> Begin AutoSession Functionalities
-- ==================================================
keymap.set("n", "<leader>sr", "<cmd>AutoSession restore<CR>")
keymap.set("n", "<leader>ss", "<cmd>AutoSession save<CR>")
keymap.set("n", "<leader>sf", "<cmd>AutoSession search<CR>")
-- ================================================
-- <leader>s	--> End AutoSession Functionalities



-- <leader>c	--> Begin CMake Functionalities
-- ==============================================
--[[
local opts = { noremap = true, silent = true }
keymap.set("n", "<leader>cg", "<cmd>CMakeGenerate<CR>", vim.tbl_extend("force", opts, { desc = "CMake Generate" }))
keymap.set("n", "<leader>cb", "<cmd>CMakeBuild<CR>",    vim.tbl_extend("force", opts, { desc = "CMake Build" }))
keymap.set("n", "<leader>cr", "<cmd>CMakeRun<CR>",      vim.tbl_extend("force", opts, { desc = "CMake Run" }))
keymap.set("n", "<leader>c]", "<cmd>cnext<cr>", { desc = "Next error" })
keymap.set("n", "<leader>c[", "<cmd>cprev<cr>", { desc = "Prev error" })
]]
-- ============================================
-- <leader>c	--> End CMake Functionalities



-- <leader>c	--> Begin ChatGPT Functionalities
-- ==============================================


-- ============================================
-- <leader>c	--> End ChatGPT Functionalities



-- Miscellaneous
keymap.set("n", "<leader>q", ":qa<CR>")
keymap.set("n", "/", "*", { noremap = true, silent = true })  -- search word under cursor
keymap.set("n", "<leader>/", function() require("helper").find_word() end)

keymap.set("n", "<leader>mc", function() require("helper").select_colorscheme() end, { desc = "Choose colorscheme", })
keymap.set("n", "<leader>ms", function() require("helper").toggle_themestyle() end, { desc = "Toggle dark/light mode" })

keymap.set("n", "<leader>mb", "<Plug>(Marks-toggle-bookmark0)", {silent = true})
keymap.set("n", "<leader>m]", "<Plug>(Marks-next-bookmark0)", {silent = true})
keymap.set("n", "<leader>m[", "<Plug>(Marks-prev-bookmark0)", {silent = true})
--keymap.set("n", "<leader>ml", "<cmd>BookmarksListAll<CR>")
keymap.set("n", "<leader>ml", "<cmd>Telescope marks<CR>", { desc = "Telescope Marks" })


keymap.set("n", "<leader>mp", function() require("helper").create_project() end, { desc = "Create C++ project" })
keymap.set("n", "<leader>mf", function() require("helper").create_class() end, { desc = "Create C++ class" })
keymap.set("n", "<leader>mi", function() require("helper").create_project_config() end, { desc = "Initialize project config" })


-- Common Windows shortcut
keymap.set({ "n", "i" }, "<C-f>", function() require("helper").find_word() end, { silent = true })
keymap.set({ "n", "i" }, "<F6>", function() require("telescope.builtin").live_grep({cwd = vim.loop.cwd(), hidden = true, no_ignore = false, additional_args = require("helper").text_filter() 
  }) end, { silent = true })
keymap.set({ "n", "i", "v" }, "<C-a>", "<esc>ggVG", { silent = true })
keymap.set({ "n", "i" }, "<C-o>", function() require("helper").preview_file() end, { desc = "File Preview" })
-- S-Home: Select to beginning of line
keymap.set("n", "<S-Home>", "v0", { silent = true })
keymap.set("i", "<S-Home>", "<Esc>v0", { silent = true })
keymap.set("v", "<S-Home>", "0", { silent = true })
-- S-End: Select to end of line
keymap.set("n", "<S-End>", "v$", { silent = true })
keymap.set("i", "<S-End>", "<Esc>v$", { silent = true })
keymap.set("v", "<S-End>", "$", { silent = true })

vim.keymap.set("i", "<C-l>", function()
  local view = vim.fn.winsaveview()
  pcall(function() vim.cmd("undojoin") end)
  vim.cmd("silent! normal! =a{")
  vim.fn.winrestview(view)
end, { desc = "Indent block with clean undo history", silent = true })


-- Word/Line selection keymaps in insert mode
keymap.set('i', '<A-Up>', '<Esc>viw', { desc = 'Insert→select inner word' })
keymap.set('i', '<A-Left>', '<Esc>v0', { desc = 'Insert→BOL selection' })
keymap.set('i', '<A-Right>', '<Esc>v$', { desc = 'Insert→EOL selection' })
keymap.set('i', '<A-Down>', '<Esc>V',  { desc = 'Insert→Visual (line)' })
keymap.set({ "n", "v" }, "<Up>", "v:count ? 'k' : 'gk'", { expr = true, silent = true })
keymap.set({ "n", "v" }, "<Down>", "v:count ? 'j' : 'gj'", { expr = true, silent = true })
-- Save on Ctrl-S & Exit on Ctrl-X
keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { silent = true })
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", { silent = true })
keymap.set({ "n", "v" }, "<C-x>", "<Cmd>qa<CR>", { silent = true })
keymap.set("i", "<C-x>", "<Esc><Cmd>qa<CR>", { silent = true })
keymap.set("t", "<C-x>", [[<C-\><C-n><Cmd>qa<CR>]], { silent = true })
keymap.set({ "n", "v" }, "<C-X>", "<Cmd>qa!<CR>", { silent = true })
keymap.set("i", "<C-X>", "<Esc><Cmd>qa!<CR>", { silent = true })
keymap.set("t", "<C-X>", [[<C-\><C-n><Cmd>qa!<CR>]], { silent = true })
keymap.set("n", "<leader>y", '"+yiw', { silent = true })
keymap.set("v", "<leader>y", '"+y', { silent = true })
keymap.set("n", "<leader>d", '"_diw', { silent = true })
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
keymap.set('n', '<C-z>', 'u', { silent = true })
keymap.set('i', '<C-z>', '<C-o>u', { silent = true })
keymap.set("n", "[", "<C-o>", { silent = true }) 
keymap.set("n", "]", "<C-i>", { silent = true })
keymap.set("n", "<leader>=", "=a{", { silent = true })
keymap.set("i", "<A-=>", "<Esc>=a{gi", { silent = true })


vim.keymap.set("n", "p", "p`[v`]=")
vim.keymap.set("n", "P", function()
  vim.cmd("normal! o<Esc>p`[v`]=")
end)
vim.keymap.set("v", "p", '"_dP`[v`]=')

local function reindent_last_change_keep_cursor()
    if vim.bo.buftype ~= "" then
        return
    end

    -- Finish current insert/change so '[ and '] are updated
    vim.cmd("stopinsert")

    local start_pos = vim.fn.getpos("'[")
    local end_pos = vim.fn.getpos("']")

    local srow = start_pos[2]
    local erow = end_pos[2]

    if srow == 0 or erow == 0 then
        vim.cmd("startinsert")
        return
    end

    local win = vim.api.nvim_get_current_win()
    local cur = vim.api.nvim_win_get_cursor(win)

    vim.cmd("silent! keepjumps normal! `[=']")

    pcall(vim.api.nvim_win_set_cursor, win, cur)

    vim.cmd("startinsert")
end

-- Insert mode: Ctrl+Space → auto-indent last changed/pasted block
vim.keymap.set("i", "<C-v>", '<C-R><C-P>+', {
  silent = true,
  desc = "Paste clipboard with indentation",
})

-- Fallback: some terminals send <C-@> for Ctrl+Space
vim.keymap.set("i", "<C-Space>", reindent_last_change_keep_cursor, {
  silent = true,
  desc = "Auto-indent last change/paste (insert mode, C-@ fallback)",
})



-- replace word under cursor with the last yanked text (register 0)
vim.keymap.set("n", "<leader>p", function()
  local keys = vim.api.nvim_replace_termcodes([["_ciw<C-r>+<Esc>"]], true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end, { noremap = true, silent = true })



-- Disable the following keymaps
local opts = { noremap = true, silent = true }
keymap.set("n", "s", "<Nop>", opts)
keymap.set("n", "c", "<Nop>", opts)
keymap.set("n", "r", "<Nop>", opts)
keymap.set("n", "gi", "<Nop>", opts)
keymap.set("n", "S", "<Nop>", opts)
keymap.set("n", "C", "<Nop>", opts)
keymap.set("n", "R", "<Nop>", opts)
keymap.set("n", "gI", "<Nop>", opts)



keymap.set("n", "<leader>?", function()
  require("which-key").show("<leader>")
end, { desc = "Show which-key popup" })


