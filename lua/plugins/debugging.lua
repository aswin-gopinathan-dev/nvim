return {
	"mfussenegger/nvim-dap",

    lazy = true, 

	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"mfussenegger/nvim-dap-python",
	},

	opts = {
		layouts =
		{
			{
				elements =
				{
					{ id = "scopes",  size = 0.50 },
					--{ id = "breakpoints", size = 0.00 },
					--{ id = "stacks", size = 0.20 },
					{ id = "watches", size = 0.50 },
				},
				position = "left",
				size = 45,
			},
			{
				elements =
				{
					{ id = "console", size = 0.5 },
					{ id = "stacks",  size = 0.5 },
					-- { id = "repl", size = 0.5 },
				},
				position = "bottom",
				size = 8,
			},

		},
	},


	config = function(_, opts)
		local dap = require("dap")
		local dapui = require("dapui")

		local layouts_left_full = {
			{
				elements = {
					{ id = "scopes",  size = 0.60 },
					{ id = "watches", size = 0.40 },
				},
				size = 45,
				position = "left",
			},
		}

		local layouts_left_scopes = {
			{
				elements = { { id = "scopes", size = 1.0 } },
				size = 45,
				position = "left",
			},
		}

		local layouts_left_watches = {
			{
				elements = { { id = "watches", size = 1.0 } },
				size = 45,
				position = "left",
			},
		}

		local layouts_bottom_full = {
			{
				elements = {
					{ id = "console", size = 0.50 },
					{ id = "stacks",  size = 0.50 },
				},
				size = 8,
				position = "bottom",
			},
		}

		local layouts_bottom_console = {
			{
				elements = { { id = "console", size = 1.0 } },
				size = 12,
				position = "bottom",
			},
		}

		local layouts_left_stacks = {
			{
				elements = { { id = "stacks", size = 1.0 } },
				size = 45,
				position = "left",
			},
		}

		local layouts_master = {
			layouts_left_full[1], -- 1
			layouts_left_scopes[1], -- 2
			layouts_left_watches[1], -- 3
			layouts_bottom_full[1], -- 4
			layouts_bottom_console[1], -- 5
			layouts_left_stacks[1], -- 6
		}

		dapui.setup({ layouts = layouts_master })


		local function pick_exe()
			local cwd = vim.fn.getcwd()
			local exe_dir = cwd .. "\\out\\Debug"

			local exes = vim.fn.globpath(exe_dir, "*.exe", false, true)
			if #exes == 0 then
				vim.notify("No executable found in " .. exe_dir, vim.log.levels.ERROR)
				return nil
			end

			-- pick the most recently modified exe
			table.sort(exes, function(a, b)
				return vim.fn.getftime(a) > vim.fn.getftime(b)
			end)

			return exes[1]
		end
		
		
		local platform = require("platform")
		local cfg, target = platform.get_active_target()
		if not cfg then
			return
		end

		target = cfg[target]

		local mason_path = vim.fn.stdpath("data")
		local codelldb_path = platform.join(mason_path, "mason", cfg.codelldb)

		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_path,
				args = { "--port", "${port}" },
				detached = false,
			},
			enrich_config = function(config, on_config)
				dap.set_log_level("TRACE")
				on_config(config)
			end,
		}
		
		dap.listeners.after.event_initialized["dap_exception_breakpoints"] = function()
			dap.set_exception_breakpoints({})
		end
		
		local cpp_program = platform.join(
			platform.resolve(target.build_dir or "."),
			target.program
		)

		local lib_dir = platform.resolve(target.build_dir or ".")
		
		dap.configurations.cpp = {
			{
				name = target.name or "Launch",
				type = "codelldb",
				request = "launch",
				program = cpp_program,
				cwd = platform.resolve(target.cwd or "."),

				stopOnEntry = target.stopOnEntry == nil and false or target.stopOnEntry,
				args = target.args or {},
				runInTerminal = target.runInTerminal == nil and false or target.runInTerminal,

				env = {
					LD_LIBRARY_PATH = lib_dir,
				},
	
				preRunCommands = {
					"breakpoint name configure --disable cpp_exception",
				},
			},
		}

        dap.configurations.rust = 
        {
            {
                name = "Launch Rust executable",
                type = "codelldb",
                request = "launch",

                program = function()
                    return vim.fn.input(
                        "Path to executable: ",
                        vim.fn.getcwd() .. "/target/debug/",
                        "file"
                    )
                end,

                cwd = "${workspaceFolder}",
                stopOnEntry = false,
            },
        }

		local python_path = platform.resolve(cfg.python)

		dap.adapters.python = {
			type = "executable",
			command = python_path,
			args = { "-m", "debugpy.adapter" },
		}


		require("dap-python").setup(python_path)

		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = target.name or "Python",
				program = platform.resolve(target.program),
				cwd = platform.resolve(target.cwd or "."),
				console = target.console or "integratedTerminal",
				justMyCode = target.justMyCode == nil and false or target.justMyCode,
				subProcess = target.subProcess == nil and true or target.subProcess,
				args = target.args or {},
			},
		}


		local nio = require("nio")
		nio.api.nvim_buf_set_name(dapui.elements.scopes.buffer(), "Locals")
		nio.api.nvim_buf_set_name(dapui.elements.stacks.buffer(), "Call Stack")
		nio.api.nvim_buf_set_name(dapui.elements.watches.buffer(), "Watch")
		nio.api.nvim_buf_set_name(dapui.elements.breakpoints.buffer(), "Breakpoints")
		nio.api.nvim_buf_set_name(dapui.elements.console.buffer(), "Console")

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = " ",
					[vim.diagnostic.severity.HINT] = "󰠠 ",
				},
				linehl = {
					[vim.diagnostic.severity.ERROR] = nil, -- "Error",
					[vim.diagnostic.severity.WARN] = nil, -- "Warn",
					[vim.diagnostic.severity.INFO] = nil, -- "Info",
					[vim.diagnostic.severity.HINT] = nil, -- "Hint",
				},
			},
		})

		vim.fn.sign_define("DapBreakpoint", { text = "🐞" })
		vim.fn.sign_define("DapStopped", { text = "" })

		dap.listeners.before.attach.dapui_config = function() dapui.open() end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
			dapui.close()
			dapui.open({ layout = 1, reset = true })
			dapui.open({ layout = 4, reset = true })
		end
		dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
	end,
}
