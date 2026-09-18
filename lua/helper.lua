local M = {}

local uv = vim.uv or vim.loop

local function is_windows()
  return vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
end

local function path_join(...)
  local sep = package.config:sub(1, 1)
  return table.concat({ ... }, sep)
end

local function shellescape(s)
  return vim.fn.shellescape(s)
end

local function notify_missing_tool(tool_names)
  vim.notify("Missing required tool: " .. tool_names, vim.log.levels.WARN)
end

local function open_with_system(target, select_file)
  if not target or target == "" then
    return
  end

  target = vim.fn.fnamemodify(target, ":p")

  if is_windows() then
    local win_target = target:gsub("/", "\\")

    if select_file and vim.fn.filereadable(target) == 1 then
      local cmd = 'start "" explorer.exe /select,"' .. win_target .. '"'
      vim.fn.system({ "cmd.exe", "/C", cmd })
    else
      local cmd = 'start "" explorer.exe "' .. win_target .. '"'
      vim.fn.system({ "cmd.exe", "/C", cmd })
    end
    return
  end

  local open_target = target
  if select_file and vim.fn.filereadable(target) == 1 then
    open_target = vim.fn.fnamemodify(target, ":h")
  end

  if vim.fn.executable("xdg-open") == 1 then
    vim.fn.jobstart({ "xdg-open", open_target }, { detach = true })
  elseif vim.fn.executable("gio") == 1 then
    vim.fn.jobstart({ "gio", "open", open_target }, { detach = true })
  else
    notify_missing_tool("xdg-open or gio")
  end
end

local function terminal_clear_command()
  return is_windows() and "cls" or "clear"
end

local function get_python_cmd()
  if is_windows() then
    if vim.fn.executable("python") == 1 then
      return "python"
    end
    if vim.fn.executable("py") == 1 then
      return "py"
    end
  else
    if vim.fn.executable("python3") == 1 then
      return "python3"
    end
    if vim.fn.executable("python") == 1 then
      return "python"
    end
  end

  return nil
end

local function get_qml_cmd()
  if is_windows() then
    if vim.fn.executable("qml.exe") == 1 then
      return "qml.exe"
    end
    if vim.fn.executable("qml") == 1 then
      return "qml"
    end
    if vim.fn.executable("qmlscene.exe") == 1 then
      return "qmlscene.exe"
    end
    if vim.fn.executable("qmlscene") == 1 then
      return "qmlscene"
    end
  else
    if vim.fn.executable("qml") == 1 then
      return "qml"
    end
    if vim.fn.executable("qmlscene") == 1 then
      return "qmlscene"
    end
  end

  return nil
end

-- =====================================================================

function M.manage_search_settings()
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function get_settings_list()
    local results = {
      { type = "flag", name = "Match Case", value = _G.MyConfig.case_sensitive },
      { type = "flag", name = "Whole Word", value = _G.MyConfig.match_whole_word },
    }

    for _, f in ipairs(_G.MyConfig.skip_folders or {}) do
      table.insert(results, { type = "folder", name = f })
    end

    for _, e in ipairs(_G.MyConfig.file_extensions or {}) do
      table.insert(results, { type = "extension", name = e })
    end

    return results
  end

  local function refresh(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    picker:refresh(finders.new_table({
      results = get_settings_list(),
      entry_maker = function(entry)
        local display = string.format("[%s] %s", entry.type:sub(1, 1):upper(), entry.name)
        if entry.type == "flag" then
          display = display .. ": " .. (entry.value and "ON" or "OFF")
        end
        return { value = entry, display = display, ordinal = entry.name }
      end,
    }), { reset_prompt = true })
  end

  pickers.new({}, {
    prompt_title = "Search Manager (t: Toggle, f: +Folder, e: +Ext, d: Delete)",
    initial_mode = "normal",
    finder = finders.new_table({
      results = get_settings_list(),
      entry_maker = function(entry)
        local display = string.format("[%s] %s", entry.type:sub(1, 1):upper(), entry.name)
        if entry.type == "flag" then
          display = display .. ": " .. (entry.value and "ON" or "OFF")
        end
        return { value = entry, display = display, ordinal = entry.name }
      end,
    }),
    sorter = conf.generic_sorter({}),
    layout_config = { width = 0.5, height = 0.5 },
    attach_mappings = function(prompt_bufnr, map)
      local win = vim.api.nvim_get_current_win()

      map("n", "t", function()
        local selection = action_state.get_selected_entry()
        if selection and selection.value.type == "flag" then
          if selection.value.name == "Match Case" then
            _G.MyConfig.case_sensitive = not _G.MyConfig.case_sensitive
          else
            _G.MyConfig.match_whole_word = not _G.MyConfig.match_whole_word
          end
          refresh(prompt_bufnr)
        end
      end)

      map("n", "f", function()
        vim.ui.input({ prompt = "Exclude Folder: " }, function(input)
          if input and input ~= "" then
            table.insert(_G.MyConfig.skip_folders, input)
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
                refresh(prompt_bufnr)
              end
            end, 10)
          end
        end)
      end)

      map("n", "e", function()
        vim.ui.input({ prompt = "Include Extension: " }, function(input)
          if input and input ~= "" then
            table.insert(_G.MyConfig.file_extensions, input)
            vim.defer_fn(function()
              if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_set_current_win(win)
                refresh(prompt_bufnr)
              end
            end, 10)
          end
        end)
      end)

      map("n", "d", function()
        local selection = action_state.get_selected_entry()
        if not selection or selection.value.type == "flag" then
          return
        end

        local target = (selection.value.type == "folder") and _G.MyConfig.skip_folders or _G.MyConfig.file_extensions
        for i, v in ipairs(target) do
          if v == selection.value.name then
            table.remove(target, i)
            break
          end
        end
        refresh(prompt_bufnr)
      end)

      map("n", "<Esc>", actions.close)
      return true
    end,
  }):find()
end

function M.format_file()
  local ft = vim.bo.filetype

  if ft == "qml" then
    vim.cmd("silent !qmlformat -i %")
    vim.cmd("edit")
  else
    vim.lsp.buf.format({ async = true })
  end
end

function M.find_word_under_cursor()
  local word = vim.fn.expand("<cword>")
  local tb = require("telescope.builtin")

  if word ~= nil and word ~= "" then
    tb.grep_string({
      search = word,
      use_regex = false,
      additional_args = M.text_filter(),
    })
  else
    tb.live_grep({
      additional_args = M.text_filter(),
    })
  end
end

function M.find_selected_word()
  local _, ls, cs = unpack(vim.fn.getpos("v"))
  local _, le, ce = unpack(vim.fn.getpos("."))
  local lines = vim.fn.getline(ls, le)
  if #lines == 0 then
    return
  end

  lines[#lines] = string.sub(lines[#lines], 1, ce)
  lines[1] = string.sub(lines[1], cs)
  local text = table.concat(lines, "\n")

  require("telescope.builtin").live_grep({
    default_text = text,
    additional_args = M.text_filter(),
  })
end

function M.find_classes_and_methods()
  local aerial = require("aerial")
  aerial.open({ direction = "float", focus = true })
end

-- =====================================================================

function M.activate_next_window()
  local start_win = vim.api.nvim_get_current_win()

  local function is_neotree(win)
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    return bufname:match("neo%-tree")
  end

  vim.cmd("wincmd w")
  local curr_win = vim.api.nvim_get_current_win()

  while curr_win ~= start_win and is_neotree(curr_win) do
    vim.cmd("wincmd w")
    curr_win = vim.api.nvim_get_current_win()
  end
end

function M.resize_window()
  local key = vim.fn.keytrans(vim.fn.getcharstr())

  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  local is_special = (ft == "neo-tree" or bt == "terminal")

  local map
  if is_special then
    map = {
      ["<Left>"]  = "3<C-w><",
      ["<Right>"] = "3<C-w>>",
      ["<Up>"]    = "3<C-w>+",
      ["<Down>"]  = "3<C-w>-",
    }
  else
    map = {
      ["<Left>"]  = "3<C-w>>",
      ["<Right>"] = "3<C-w><",
      ["<Up>"]    = "3<C-w>-",
      ["<Down>"]  = "3<C-w>+",
    }
  end

  local cmd = map[key]
  if cmd then
    local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
    vim.api.nvim_feedkeys(keys, "n", false)
  end
end

function M.activate_code_buffer()
  local skip_filetypes = {
    ["neo-tree"] = true,
    ["toggleterm"] = true,
    ["dapui_scopes"] = true,
    ["dapui_breakpoints"] = true,
    ["dapui_stacks"] = true,
    ["dapui_watches"] = true,
    ["dapui_console"] = true,
  }

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype

    if not skip_filetypes[ft] then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

function M.code_only_view()
  -- 1. Close Neo-tree
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- 2. Close all toggleterm terminals
  pcall(function()
    require("helper").close_terminal()
  end)

  -- 3. Close floating windows (optional but useful)
  pcall(function()
    require("helper").close_floating_windows()
  end)

  -- 4. Close quickfix if open
  vim.cmd("cclose")

  -- 5. Focus code buffer (final step)
  require("helper").activate_code_buffer()
end

function M.reset_buffers_to_default_size()
  local cur_win = vim.api.nvim_get_current_win()

  require("neo-tree.command").execute({ action = "show", position = "left" })

  local neotree_win = nil
  local term_win = nil

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype

    if ft == "neo-tree" then
      neotree_win = win
    elseif ft == "toggleterm" then
      term_win = win
    end
  end

  if neotree_win and vim.api.nvim_win_is_valid(neotree_win) then
    vim.api.nvim_win_set_width(neotree_win, 35)
    vim.wo[neotree_win].winfixwidth = true
  end

  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_set_height(term_win, 9)
    vim.wo[term_win].winfixheight = true
  end

  if vim.api.nvim_win_is_valid(cur_win) then
    vim.api.nvim_set_current_win(cur_win)
  end
end

-- =====================================================================

local function close_quickfix()
  local wininfo = vim.fn.getwininfo()
  for _, win in ipairs(wininfo) do
    if win.quickfix == 1 then
      vim.cmd("cclose")
    end
  end
end

function M.open_terminal_floating()
  close_quickfix()
  local cwd = vim.fn.getcwd()
  vim.cmd(string.format("ToggleTerm dir=%s direction=float", shellescape(cwd)))
end

local BOTTOM_TERM_ID = 97
function M.open_terminal_horizontal()
    close_quickfix()

    local terminal = require("toggleterm.terminal")
    local Terminal = terminal.Terminal

    local term = terminal.get(BOTTOM_TERM_ID)

    if not term then
        term = Terminal:new({
            id = BOTTOM_TERM_ID,
            direction = "horizontal",
            close_on_exit = false,
            hidden = false,
        })
    end

    if term:is_open() and term.direction ~= "horizontal" then
        term:close()
    end

    if term:is_open() then
        term:focus()
    else
        term.dir = vim.fn.getcwd()
        term:open(nil, "horizontal")
    end

    vim.schedule(function()
        vim.cmd("startinsert")
    end)

    return term
end

function M.preview_svg()
  vim.cmd([[normal! "vyi"]])
  local path = vim.fn.getreg("v")

  if not path or path == "" then
    vim.notify('No path yanked. Put cursor inside the "path" string first.', vim.log.levels.WARN)
    return
  end

  local viewBox = "0 0 100 100"
  local width, height = 360, 360
  local fill = "#000000"

  local svg = string.format([[
<svg xmlns="http://www.w3.org/2000/svg" viewBox="%s" width="%d" height="%d">
  <path d="%s" fill="%s"/>
</svg>
]], viewBox, width, height, path, fill)

  local tempdir = vim.env.TMPDIR or vim.env.TEMP or vim.env.TMP or "/tmp"
  local outfile = path_join(tempdir, "qml_path_preview.svg")

  local f, err = io.open(outfile, "w")
  if not f then
    vim.notify("Failed to write SVG: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  f:write(svg)
  f:close()

  open_with_system(outfile, false)
end


local RUN_TERM_COUNT = 99

local function get_run_term()
  local terminal = require("toggleterm.terminal")
  local Terminal = terminal.Terminal
  local term = terminal.get(RUN_TERM_COUNT)
  if not term then
    term = Terminal:new({
      id = RUN_TERM_COUNT,
      direction = "horizontal",
      close_on_exit = false,
      hidden = false,
    })
  end
  return term
end


local SIDE_TERM_ID = 98
local side_terminal = nil
local side_terminal_restore_neotree = false

local function is_neotree_open()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)

        if vim.bo[buf].filetype == "neo-tree" then
            return true
        end
    end

    return false
end

local function get_side_terminal()
    if side_terminal then
        return side_terminal
    end

    local terminal = require("toggleterm.terminal")
    local Terminal = terminal.Terminal

    side_terminal = terminal.get(SIDE_TERM_ID)

    if not side_terminal then
        side_terminal = Terminal:new({
            id = SIDE_TERM_ID,
            direction = "vertical",
            close_on_exit = false,
            hidden = false,

            on_close = function()
                if side_terminal_restore_neotree then
                    vim.schedule(function()
                        pcall(vim.cmd, "Neotree show left")
                    end)
                end

                side_terminal_restore_neotree = false
            end,
        })
    end

    return side_terminal
end

function M.open_terminal_side()
    close_quickfix()

    local term = get_side_terminal()

    if term:is_open() then
        term:focus()
        vim.cmd("startinsert")
        return term
    end

    side_terminal_restore_neotree = is_neotree_open()

    pcall(vim.cmd, "Neotree close")

    M.close_terminal()

    term.dir = vim.fn.getcwd()
    term:open()

    vim.schedule(function()
        if term.window and vim.api.nvim_win_is_valid(term.window) then
            local terminal_width = math.floor(vim.o.columns * 0.40)

            vim.api.nvim_win_set_width(
                term.window,
                terminal_width
            )

            vim.api.nvim_set_current_win(term.window)
            vim.cmd("startinsert")
        end
    end)

    return term
end

local function launch_app(pgm)
    local term = M.open_terminal_side()

    vim.defer_fn(function()
        term:send(terminal_clear_command(), true)
        term:send(pgm, true)
    end, 50)
end

function M.run_app()
  local src_buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(src_buf)
  local ext = vim.fn.fnamemodify(file, ":e")

  local cmd
  if ext == "qml" then
    local qml_cmd = get_qml_cmd()
    if not qml_cmd then
      notify_missing_tool("qml or qmlscene")
      return
    end
    cmd = string.format('%s "%s"', qml_cmd, file)
  else
    local python_cmd = get_python_cmd()
    if not python_cmd then
      notify_missing_tool("python / python3")
      return
    end

    local entrypoint = path_join(vim.fn.getcwd(), "entrypoint.py")
    cmd = string.format('%s "%s"', python_cmd, entrypoint)
  end

  launch_app(cmd)
end

function M.build_app()
  vim.cmd("write")
  vim.cmd("stopinsert")
  
  local ok, platform = pcall(require, "platform")
  local project = platform.read_project()
  if not project then return end

  if project.type == "cpp" then
      local build_path = platform.resolve(project.cwd or ".")
      launch_app(string.format('cd "%s" && make', build_path))
  elseif project.type == "rs" then
      launch_app("cargo build")
  elseif project.type == "python" then
      vim.notify("Python project has no build step.", vim.log.levels.INFO)
  end 
end

function M.run_app2()
  vim.cmd("write")
  vim.cmd("stopinsert")
  
  
  local ok, platform = pcall(require, "platform")
  local project = platform.read_project()
  if not project then return end

  if project.type == "python" then
    local python_cmd = get_python_cmd()
    launch_app(string.format('%s "%s"', python_cmd, platform.resolve(project.program)))
  elseif project.type == "cpp" then
    local exe = platform.resolve(
      platform.join(project.build_dir or ".", project.program)
    )
    local cmd = string.format('"%s"', exe)
    if project.command and project.command ~= "" then
        cmd = cmd .. " && " .. project.command
    end

    launch_app(cmd)
  elseif project.type == "rs" then
    launch_app("cargo run")
  end
end

function M.close_terminal()
  local ok, term = pcall(require, "toggleterm.terminal")
  if not ok then
    return
  end

  for _, t in pairs(term.get_all()) do
    if t:is_open() then
      t:close()
    end
  end
end

-- =====================================================================

local function open_explorer(path)
  if not path or path == "" then
    path = vim.fn.expand("%:p")
  end
  if path == "" then
    path = vim.fn.getcwd()
  end

  path = vim.fn.fnamemodify(path, ":p")
  open_with_system(path, true)
end

function M.preview_file()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype

  if ft == "neo-tree" then
    local ok, manager = pcall(require, "neo-tree.sources.manager")
    if ok then
      local state = manager.get_state("filesystem")
      local node = state.tree:get_node()
      if node and node.path then
        open_with_system(node.path, false)
      end
    end
  else
    open_explorer(vim.fn.expand("%:p"))
  end
end

-- =====================================================================

function M.find_word()
  vim.ui.input({ prompt = "Find > " }, function(input)
    if input == nil or input == "" then
      return
    end

    local pattern = [[\c\V]] .. input
    vim.fn.setreg("/", pattern)

    local found = vim.fn.search(pattern, "nw")
    if found == 0 then
      vim.notify("Text not found: " .. input, vim.log.levels.INFO)
      return
    end

    vim.cmd("normal! n")
    vim.fn.histadd("search", pattern)
  end)
end

function M.text_filter()
  local args = { "--fixed-strings" }

  if _G.MyConfig.match_whole_word then
    table.insert(args, "--word-regexp")
  end

  if _G.MyConfig.case_sensitive then
    table.insert(args, "--case-sensitive")
  else
    table.insert(args, "--ignore-case")
  end

  for _, name in ipairs(_G.MyConfig.skip_folders or {}) do
    table.insert(args, "--glob")
    table.insert(args, "!**/" .. name .. "/**")
  end

  for _, ext in ipairs(_G.MyConfig.file_extensions or {}) do
    table.insert(args, "--glob")
    table.insert(args, "**/*." .. ext)
  end

  return args
end

local function lua_pat_escape(s)
  return (s:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

function M.folder_filter()
  local patterns = {}
  for _, name in ipairs(_G.MyConfig.skip_folders or {}) do
    local escaped = lua_pat_escape(name)
    table.insert(patterns, escaped .. "[\\/]")
  end

  return patterns
end

local filter_win = nil
local filter_buf = nil

function M.show_find_filters()
  local path = vim.fn.stdpath("config") .. "/lua/config/search_filters.lua"

  if filter_win and vim.api.nvim_win_is_valid(filter_win) then
    vim.api.nvim_set_current_win(filter_win)
    return
  end

  filter_buf = vim.fn.bufadd(path)
  vim.fn.bufload(filter_buf)
  vim.bo[filter_buf].buflisted = false

  local width = math.floor(vim.o.columns * 0.45)
  local height = math.floor(vim.o.lines * 0.65)

  filter_win = vim.api.nvim_open_win(filter_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Search Filters ",
    title_pos = "center",
  })

  local function close()
    if filter_win and vim.api.nvim_win_is_valid(filter_win) then
      vim.api.nvim_win_close(filter_win, true)
    end
    filter_win = nil
  end

  vim.keymap.set("n", "q", close, { buffer = filter_buf, nowait = true })
  vim.keymap.set("n", "<Esc>", close, { buffer = filter_buf, nowait = true })
end

local themes = {
  "dayfox",
  "nightfox",
  "terafox",
  "dawnfox",
  "carbonfox",
  "catppuccin-latte",
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "catppuccin-mocha",
  "gruvbox-material",
  "onedark",
  "onelight",
  "onedark_vivid",
  "onedark_dark",
  "vaporwave",
  "nord",
  "kanagawa-wave",
  "kanagawa-dragon",
  "kanagawa-lotus",
  "github_dark",
  "github_dark_default",
  "github_dark_dimmed",
  "github_dark_high_contrast",
  "github_light",
  "github_light_default",
  "github_light_high_contrast",
  "poimandres",
  "yorumi",
  "newpaper",
  "PaperColor",
  "cyberdream",
  "adwaita",
  "everforest",
  "borland",
  "blue-mood",
  "OceanicNext",
  "bluloco-dark",
  "ayu",
  "melange",
  "tokyonight-night",
  "tokyonight-storm",
  "tokyonight-day",
  "tokyonight-moon"
}

function M.select_colorscheme()
  local sorted_themes = vim.deepcopy(themes)
  table.sort(sorted_themes, function(a, b) return a:lower() < b:lower() end )
  vim.ui.select(sorted_themes, {
    prompt = "Select colorscheme",
  }, function(choice)
    if not choice then
      return
    end
    vim.cmd.colorscheme(choice)
  end)
end

function M.toggle_themestyle()
    vim.o.background = vim.o.background == "dark" and "light" or "dark" 

    -- Schedule the Bufferline refresh
    vim.schedule(function()
        local status_ok, bufferline = pcall(require, "bufferline")
        if status_ok then
            local bl_config = require("bufferline.config")
            bufferline.setup({
                options = bl_config.options or {}
            })
            vim.cmd("redraw!")
        end
    end)
end

-- =====================================================================

function M.close_debugger()
  require("dap").disconnect({ terminateDebuggee = true })
  require("dap").close()
  require("dapui").close()
end

local function dapui_preset(left_idx, bottom_idx)
  local dapui = require("dapui")
  dapui.close()

  if left_idx then
    dapui.open({ layout = left_idx, reset = true })
  end
  if bottom_idx then
    dapui.open({ layout = bottom_idx, reset = true })
  end
end

local function get_visual_selection_exact()
  local save, savetype = vim.fn.getreg("z"), vim.fn.getregtype("z")
  vim.cmd([[silent noautocmd normal! "zy]])
  local text = vim.fn.getreg("z")
  vim.fn.setreg("z", save, savetype)
  return text
end

function M.add_debug_watch()
  local expr = get_visual_selection_exact()
      :gsub("^%s+", "")
      :gsub("%s+$", "")
      :gsub("\n+", " ")

  if expr ~= "" then
    local ok, err = pcall(function()
      require("dapui").elements.watches.add(expr)
    end)
    if not ok then
      vim.notify("Failed to add watch: " .. tostring(err), vim.log.levels.WARN)
    end
  else
    vim.notify("No valid selection to watch", vim.log.levels.INFO)
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

local layouts = {
  { label = "Full", scopes = 1, console = 4 },
  { label = "Variables", scopes = 1, console = nil },
  { label = "Locals", scopes = 2, console = nil },
  { label = "Watch", scopes = 3, console = nil },
  { label = "Stack", scopes = 6, console = nil },
  { label = "Console", scopes = nil, console = 5 },
}

function M.select_debug_layout()
  vim.ui.select(layouts, {
    prompt = "DAP UI layout:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    dapui_preset(choice.scopes, choice.console)
  end)
end

function M.close_floating_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end

  vim.cmd("nohlsearch")
end

function M.toggle_lsp()
  local running = {}
  for _, client in pairs(vim.lsp.get_active_clients()) do
    running[client.name] = true
  end

  local stopped_any = false

  for _, name in ipairs({ "pyright", "basedpyright", "mypy_lsp" }) do
    if running[name] then
      vim.cmd("LspStop " .. name)
      stopped_any = true
    end
  end

  if stopped_any then
    vim.notify("Pyright / Mypy stopped", vim.log.levels.INFO)
  else
    vim.cmd("LspStart pyright")
    vim.cmd("LspStart mypy_lsp")
    vim.notify("Pyright / Mypy started", vim.log.levels.INFO)
  end
end

-- =====================================================================

function M.smart_close_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local listed = vim.fn.getbufinfo({ buflisted = 1 })

  if #listed > 1 then
    if bufnr == vim.api.nvim_get_current_buf() then
      vim.cmd("bprevious")
    else
      vim.cmd("buffer " .. listed[1].bufnr)
    end
  else
    vim.cmd("enew")
  end

  vim.cmd("bdelete " .. bufnr)
end

-- =====================================================================

function M.get_files_list()
  local pickers      = require("telescope.pickers")
  local finders      = require("telescope.finders")
  local conf         = require("telescope.config").values
  local actions      = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if vim.tbl_isempty(bufs) then
    vim.notify("No listed buffers", vim.log.levels.INFO)
    return
  end

  table.sort(bufs, function(a, b)
    local name_a = vim.fn.fnamemodify(a.name ~= "" and a.name or "[No Name]", ":t"):lower()
    local name_b = vim.fn.fnamemodify(b.name ~= "" and b.name or "[No Name]", ":t"):lower()
    return name_a > name_b
  end)

  pickers.new({}, {
    prompt_title = "Buffers",
    initial_mode = "normal",
    finder = finders.new_table({
      results = bufs,
      entry_maker = function(buf)
        local name = buf.name ~= "" and buf.name or "[No Name]"
        return {
          value = buf,
          ordinal = name,
          display = vim.fn.fnamemodify(name, ":t"),
          bufnr = buf.bufnr,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = false,
    layout_strategy = "center",
    layout_config = {
      width = 0.35,
      height = 0.80,
    },
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if entry and entry.bufnr then
          vim.api.nvim_set_current_buf(entry.bufnr)
        end
      end)

      map("n", "x", function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry or not entry.bufnr then
          return
        end

        local row = picker:get_selection_row()

        vim.api.nvim_buf_delete(entry.bufnr, { force = false })

        picker:refresh(
          finders.new_table({
            results = vim.fn.getbufinfo({ buflisted = 1 }),
            entry_maker = function(buf)
              local name = buf.name ~= "" and buf.name or "[No Name]"
              return {
                value = buf,
                ordinal = name,
                display = vim.fn.fnamemodify(name, ":t"),
                bufnr = buf.bufnr,
              }
            end,
          }),
          { reset_prompt = false }
        )

        local new_count = #vim.fn.getbufinfo({ buflisted = 1 })
        if row >= new_count then
          row = new_count - 1
        end
        if row >= 0 then
          picker:set_selection(row)
        end
      end)

      return true
    end,
  }):find()
end

function M.create_project()
    vim.ui.input({ prompt = "Project name: " }, function(project_name)
        if not project_name or project_name == "" then
            return
        end

        local root = vim.fn.getcwd()
        local project_dir = path_join(root, project_name)

        local src_dir = path_join(project_dir, "src")
        local inc_dir = path_join(project_dir, "inc")
        local build_dir = path_join(project_dir, "build")

        -- Create project directories
        vim.fn.mkdir(src_dir, "p")
        vim.fn.mkdir(inc_dir, "p")
        vim.fn.mkdir(build_dir, "p")

        -- Create main.cpp inside src/
        local main_cpp = path_join(src_dir, "main.cpp")

        local main_file = io.open(main_cpp, "w")
        if main_file then
            main_file:write([[
#include <iostream>

int main()
{
	std::cout << "Hello, World!" << std::endl;
	return 0;
}
]])
            main_file:close()
        end

        -- Create Makefile in project root
        local makefile_path = path_join(project_dir, "Makefile")

        local makefile = io.open(makefile_path, "w")
        if makefile then
            makefile:write([[
CXX := g++
CXXFLAGS := -std=c++20 -Wall -Wextra -Iinc

SRC_DIR := src
BUILD_DIR := build

SOURCES := $(wildcard $(SRC_DIR)/*.cpp)
OBJECTS := $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(SOURCES))

TARGET := $(BUILD_DIR)/main

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $(TARGET)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

cc:
	bear -- make build		

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all clean
]])
            makefile:close()
        end

        -- Switch Neovim to the new project
        vim.cmd("cd " .. vim.fn.fnameescape(project_dir))

        -- Open main.cpp
        vim.cmd("edit " .. vim.fn.fnameescape(main_cpp))

        vim.notify(
            "Created C++ project: " .. project_name,
            vim.log.levels.INFO
        )
    end)
end


function M.create_class()
	vim.ui.input({ prompt = "Class name: " }, function(class_name)
		if not class_name or class_name == "" then
			return
		end

		local root = vim.fn.getcwd()
		local src_dir = path_join(root, "src")
		local inc_dir = path_join(root, "inc")

		if vim.fn.isdirectory(src_dir) == 0 or vim.fn.isdirectory(inc_dir) == 0 then
			vim.notify(
				"src/ or inc/ directory not found",
				vim.log.levels.ERROR
			)
			return
		end

		local cpp_path = path_join(src_dir, class_name .. ".cpp")
		local header_path = path_join(inc_dir, class_name .. ".h")

		-- Don't accidentally overwrite an existing class
		if vim.fn.filereadable(cpp_path) == 1 or
		   vim.fn.filereadable(header_path) == 1 then
			vim.notify(
				"Class already exists: " .. class_name,
				vim.log.levels.ERROR
			)
			return
		end

		-- Header
		local header = io.open(header_path, "w")
		if header then
			header:write(string.format([[
#pragma once

class %s
{
public:
	%s();
	~%s();

private:
	
};
	]], class_name, class_name, class_name))

			header:close()
		end

		-- Source
		local source = io.open(cpp_path, "w")
		if source then
			source:write(string.format([[
#include "../inc/%s.h"

%s::%s()
{
}

%s::~%s()
{
}
	]],
				class_name,
				class_name,
				class_name,
				class_name,
				class_name
			))

			source:close()
		end

		vim.cmd("edit " .. vim.fn.fnameescape(header_path))
		vim.cmd("badd " .. vim.fn.fnameescape(cpp_path))

		vim.notify(
			"Created class: " .. class_name,
			vim.log.levels.INFO
		)
	end)
end

function M.create_project_config()
	local root = vim.fn.getcwd()
	local path = root .. "/project.toml"

	-- Do not overwrite an existing project.toml
	if vim.fn.filereadable(path) == 1 then
		vim.notify("project.toml already exists", vim.log.levels.INFO)
		vim.cmd("edit " .. vim.fn.fnameescape(path))
		return
	end

	local config = {
		'type = "cpp"',
		'name = "Project"',
		'build_dir = "./build"',
		'program = "main"',
		'cwd = "."',
		'args = []',
		'stopOnEntry = false',
		'runInTerminal = true',
        'command=""'
	}

	vim.fn.writefile(config, path)

	vim.notify("Created project.toml", vim.log.levels.INFO)
	vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
