local neotree_was_open = false
  local function ensure_chat_open()
	  for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype

		if ft == "codecompanion" then
		  vim.api.nvim_set_current_win(win)
		  return
		end
	  end

	  pcall(vim.cmd, "Neotree close")
	  vim.cmd("CodeCompanionChat")

	  vim.schedule(function()
		vim.cmd("wincmd L")

		local chat_width = math.floor(vim.o.columns * 0.35)
		vim.cmd("vertical resize " .. chat_width)
	  end)
  end
  local function open_chat_with_current_file()
	  ensure_chat_open()

	  local file = vim.fn.expand("%:p")
	  vim.api.nvim_put({
		"#file:" .. file,
		"",
	  }, "l", true, true)

	  vim.cmd("startinsert")
  end
  
  local function open_chat_with_selection()
	  pcall(vim.cmd, "Neotree close")

	  vim.cmd("CodeCompanionChat")

	  vim.schedule(function()
		vim.cmd("wincmd L")

		local chat_width = math.floor(vim.o.columns * 0.35)
		vim.cmd("vertical resize " .. chat_width)

		vim.cmd("startinsert")
	  end)
  end
  
  local function open_ai_chat()
	  neotree_was_open = false

	  for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		local ft = vim.bo[buf].filetype

		if ft == "neo-tree" then
		  neotree_was_open = true
		  break
		end
	  end

	  pcall(vim.cmd, "Neotree close")
	  vim.cmd("CodeCompanionChat")

	  vim.schedule(function()
		vim.cmd("wincmd L")

		local chat_width = math.floor(vim.o.columns * 0.35)
		vim.cmd("vertical resize " .. chat_width)
	  end)
  end
  
  local function open_chat_with_attachment()
	  ensure_chat_open()
	  require("telescope.builtin").find_files({
		prompt_title = "Attach file to CodeCompanion",
		attach_mappings = function(prompt_bufnr)
		  local actions = require("telescope.actions")
		  local state = require("telescope.actions.state")

		  actions.select_default:replace(function()
			local entry = state.get_selected_entry()
			actions.close(prompt_bufnr)

			local file = entry.path or entry.filename

			vim.api.nvim_put({
			  "#file:" .. file,
			}, "l", true, true)
		  end)

		  return true
		end,
	  })
  end
  
	local function attach_clipboard_image()
	  ensure_chat_open()

	  local tmp = vim.fn.stdpath("cache")
		.. "\\cc_image_"
		.. os.date("%Y%m%d_%H%M%S")
		.. ".png"

	  local ps = string.format([[
	powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; if ([Windows.Forms.Clipboard]::ContainsImage()) { [Windows.Forms.Clipboard]::GetImage().Save('%s', [System.Drawing.Imaging.ImageFormat]::Png) }"
	]], tmp)

	  vim.fn.system(ps)

	  if vim.fn.filereadable(tmp) == 1 then
		vim.api.nvim_put({
		  "@image:" .. tmp,
		  "",
		}, "l", true, true)

		print("Attached image: " .. tmp)
	  else
		print("No image found in clipboard")
	  end
	end


return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      acp = {
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chat-gpt", -- uses ChatGPT login, not API key
              session_config_options = {
                -- keep model unset first; choose from CodeCompanion debug/options if needed
                -- model = "gpt-5.4",
              },
            },
          })
        end,
      },
    },

    interactions = {
      chat = {
        adapter = "codex",
      },
    },
  },
  
  config = function(_, opts)
	  require("codecompanion").setup(opts)

	  vim.api.nvim_create_autocmd("FileType", {
	  pattern = "codecompanion",
	  callback = function(args)
		vim.keymap.set("n", "<Esc>", function()
		  vim.cmd("close")

		  if neotree_was_open then
			vim.cmd("Neotree show")
		  end
		end, {
		  buffer = args.buf,
		  silent = true,
		})
	  end,
	})
  end,
  
  
	keys = {
	  { "<leader>cc", open_ai_chat, mode = "n", desc = "AI Chat" },
	  { "<leader>cf", open_chat_with_current_file, mode = "n", desc = "AI Chat (attach current file)" },
	  { "<leader>ct", open_chat_with_attachment, mode = "n", desc = "Attach file" },
	  { "<leader>cp", attach_clipboard_image, mode = "n", desc = "Attach clipboard image" },
	  { "<leader>cc", open_chat_with_selection, mode = "v", desc = "AI Chat (selection)" },
	  -- { "<leader>ae", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Edit Inline" },
	  -- { "<leader>ad", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
	},
}
