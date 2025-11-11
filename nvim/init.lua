-- vim.cmd("syntax off") -- turn off syntax highlighting
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = "nv"
vim.opt.showmode = false
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
vim.opt.breakindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = "split"
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.guicursor = ""
vim.opt.list = false
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.wo.wrap = true

vim.opt.colorcolumn = "80"

vim.opt.swapfile = false
vim.opt.backup = false
-- vim.opt.shadafile = "NONE"
vim.opt.undofile = true
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.confirm = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move"<CR>')

vim.keymap.set("n", "bb", vim.cmd.Ex)
vim.keymap.set("t", "<C-x>", "<C-\\><C-n>", { desc = "[E]xit [T]erminal mode" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Make indenting and unindenting in visual mode retain the selection
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, silent = true })

-- calculate current buffer index
function _G.buffer_index()
	local current = vim.fn.bufnr('%')
	local buffers = vim.fn.getbufinfo({buflisted = 1})
	for i, buf in ipairs(buffers) do
		if buf.bufnr == current then
			return string.format("[%d]", i)
		end
	end
	return "[?]"
end	

vim.o.laststatus = 2
vim.o.statusline = "%f %y %m %r %{mode()} %=Line:%l/%L Buf:%{v:lua.buffer_index()}"

-- Setup lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

---@diagnostic disable [missing-fields]
require("lazy").setup({
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{ -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
				defaults = {
					file_ignore_patterns = {
						"node_modules",
						"vendor",
						".git",
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
			})
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "ff", builtin.find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "ft", builtin.live_grep, { desc = "[F]ind [T]exts" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "fb", builtin.buffers, { desc = "[S]earch Buffer Files" })
		end,
	},
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- { -- LSP Configuration & Plugins
	-- 	"neovim/nvim-lspconfig",
	-- 	dependencies = {
	-- 		{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
	-- 		"williamboman/mason-lspconfig.nvim",
	-- 		"WhoIsSethDaniel/mason-tool-installer.nvim",
	-- 		{ "j-hui/fidget.nvim", opts = {} },
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 	},
	-- 	config = function()
	-- 		vim.api.nvim_create_autocmd("LspAttach", {
	-- 			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	-- 			callback = function(event)
	-- 				local map = function(keys, func, desc)
	-- 					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	-- 				end
	--
	-- 				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	-- 				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	-- 				map("K", vim.lsp.buf.hover, "Hover Documentation")
	-- 				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	-- 				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	-- 				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	--
	-- 				local function client_supports_method(client, method, bufnr)
	-- 					if vim.fn.has("nvim-0.11") == 1 then
	-- 						return client:supports_method(method, bufnr)
	-- 					else
	-- 						return client.supports_method(method, { bufnr = bufnr })
	-- 					end
	-- 				end
	--
	-- 				local client = vim.lsp.get_client_by_id(event.data.client_id)
	-- 				if
	-- 					client
	-- 					and client_supports_method(
	-- 						client,
	-- 						vim.lsp.protocol.Methods.textDocument_documentHighlight,
	-- 						event.buf
	-- 					)
	-- 				then
	-- 					local highlight_augroup =
	-- 						vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
	-- 					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	-- 						buffer = event.buf,
	-- 						group = highlight_augroup,
	-- 						callback = vim.lsp.buf.document_highlight,
	-- 					})
	--
	-- 					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	-- 						buffer = event.buf,
	-- 						group = highlight_augroup,
	-- 						callback = vim.lsp.buf.clear_references,
	-- 					})
	--
	-- 					vim.api.nvim_create_autocmd("LspDetach", {
	-- 						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
	-- 						callback = function(event2)
	-- 							vim.lsp.buf.clear_references()
	-- 							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
	-- 						end,
	-- 					})
	-- 				end
	--
	-- 				if
	-- 					client
	-- 					and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
	-- 				then
	-- 					map("<leader>th", function()
	-- 						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
	-- 					end, "[T]oggle Inlay [H]ints")
	-- 				end
	-- 			end,
	-- 		})
	--
	-- 		vim.diagnostic.config({
	-- 			severity_sort = true,
	-- 			float = { border = "rounded", source = "if_many" },
	-- 			underline = { severity = vim.diagnostic.severity.ERROR },
	-- 			signs = vim.g.have_nerd_font and {
	-- 				text = {
	-- 					[vim.diagnostic.severity.ERROR] = "󰅚 ",
	-- 					[vim.diagnostic.severity.WARN] = "󰀪 ",
	-- 					[vim.diagnostic.severity.INFO] = "󰋽 ",
	-- 					[vim.diagnostic.severity.HINT] = "󰌶 ",
	-- 				},
	-- 			} or {},
	-- 			virtual_text = {
	-- 				source = "if_many",
	-- 				spacing = 2,
	-- 				format = function(diagnostic)
	-- 					local diagnostic_message = {
	-- 						[vim.diagnostic.severity.ERROR] = diagnostic.message,
	-- 						[vim.diagnostic.severity.WARN] = diagnostic.message,
	-- 						[vim.diagnostic.severity.INFO] = diagnostic.message,
	-- 						[vim.diagnostic.severity.HINT] = diagnostic.message,
	-- 					}
	-- 					return diagnostic_message[diagnostic.severity]
	-- 				end,
	-- 			},
	-- 		})
	--
	-- 		-- local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- 		-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
	-- 		-- local servers = {}
	-- 		-- local ensure_installed = vim.tbl_keys(servers or {})
	-- 		-- vim.list_extend(ensure_installed, {})
	-- 		-- require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
	--
	-- 		-- require("mason-lspconfig").setup({
	-- 		-- 	ensure_installed = {},
	-- 		-- 	automatic_installation = false,
	-- 		-- 	handlers = {
	-- 		-- 		function(server_name)
	-- 		-- 			local server = servers[server_name] or {}
	-- 		-- 			server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
	-- 		-- 			require("lspconfig")[server_name].setup(server)
	-- 		-- 		end,
	-- 		-- 	},
	-- 		-- })
	--
	-- 	end,
	-- },
	{ -- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- This on_attach function will be used for all LSP servers
			local on_attach = function(client, bufnr)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end
	
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			end
	
			require("mason").setup()
	
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
	
			local servers = {
				intelephense = {
					root_dir = function(fname)
						local root = vim.fs.find({ "wp-load.php" }, { upward = true, path = fname, type = "file" })
						return root and vim.fs.dirname(root[1]) or nil
					end,
				},
				-- gopls = {},
				-- lua_ls = { settings = { Lua = { diagnostics = { globals = {'vim'} } } } },
			}
	
			require("mason-lspconfig").setup({
				ensure_installed = vim.tbl_keys(servers),
			})
	
			for server_name, config in pairs(servers) do
				config.on_attach = on_attach
				config.capabilities = capabilities
				require("lspconfig")[server_name].setup(config)
			end
		end,
	},
	{ -- Autocompletion
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp-signature-help",
		},
		config = function()
			-- See `:help cmp`
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})
	
			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{
						name = "lazydev",
						-- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
						group_index = 0,
					},
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "nvim_lsp_signature_help" },
				},
			})
		end,
	},
	{	
		"echasnovski/mini.nvim",
		config = function()

			require("mini.indentscope").setup({
				draw = {
					animation = require("mini.indentscope").gen_animation.none(),
				},
			})
			require("mini.comment").setup()
			require("mini.pairs").setup()

		end,
	},
	-- { -- Highlight, edit, and navigate code
	-- 	"nvim-treesitter/nvim-treesitter",
	-- 	build = ":TSUpdate",
	-- 	main = "nvim-treesitter.configs",
	-- 	opts = {
	-- 		ensure_installed = {},
	-- 		auto_install = false,
	-- 		highlight = {
	-- 			enable = true,
	-- 			additional_vim_regex_highlighting = { "ruby" },
	-- 		},
	-- 		indent = { enable = true, disable = { "ruby" } },
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("nvim-treesitter.install").prefer_git = true
	-- 		require("nvim-treesitter.configs").setup(opts)
	-- 		local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
	-- 		parser_config.blade = {
	-- 			install_info = {
	-- 				url = "https://github.com/EmranMR/tree-sitter-blade",
	-- 				files = { "src/parser.c" },
	-- 				branch = "main",
	-- 			},
	-- 			filetype = "blade",
	-- 		}
	-- 		vim.filetype.add({
	-- 			pattern = {
	-- 				[".*%.blade%.php"] = "blade",
	-- 			},
	-- 		})
	-- 	end,
	-- },
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			formatters_by_ft = {
				javascript = { "prettierd", "prettier", stop_after_first = true },
				go = { "goimports", "gofmt" },
				templ = { "templ" },
				blade = { "blade-formatter" },
			},
		},
	},
	{
		"vague2k/vague.nvim",
		config = function()
			require("vague").setup({
				style = {
					comments = "none",
					strings = "none",
				},
				colors = {
					floatBorder = "#878787",
				},
			})

			vim.cmd.colorscheme("vague")
		end,
	},
	{
		'tpope/vim-fugitive'
	}
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
