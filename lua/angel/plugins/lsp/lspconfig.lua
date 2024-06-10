return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
		"antosha417/nvim-lsp-file-operations",
		{ "folke/neodev.nvim", opts = {} },
		"jose-elias-alvarez/null-ls.nvim", -- Add null-ls as a dependency
	},

	config = function()
		local lspconfig = require("lspconfig")
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local cmp = require("cmp")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local fidget = require("fidget")
		local keymap = vim.keymap -- for conciseness
		local null_ls = require("null-ls") -- require null-ls

		-- Setup Mason and Mason-LSPConfig
		mason.setup()
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"gopls",
				"tsserver", -- Ensure tsserver is installed
				"pyright", -- Ensure pyright is installed for Python
			},
		})

		-- Setup Fidget
		fidget.setup({})

		-- Configure diagnostics symbols in the sign column
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Configure diagnostic display
		vim.diagnostic.config({
			float = {
				focusable = true, -- Make the floating window focusable
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "", -- Custom header
				prefix = "", -- Custom prefix for each diagnostic message
			},
		})

		-- Define on_attach function
		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr, silent = true }

			-- Set keybinds
			opts.desc = "Show LSP references"
			keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Close hover window"
			keymap.set("n", "<Esc>", function()
				if vim.fn.pumvisible() == 0 then
					vim.api.nvim_input("<C-w>w") -- Switch window to close floating window
				else
					vim.api.nvim_input("<Esc>")
				end
			end, { noremap = true, silent = true })

			-- Scroll documentation in hover window
			keymap.set("n", "<C-f>", function()
				if vim.fn.pumvisible() == 0 then
					vim.api.nvim_input("<C-w>w<C-e>") -- Scroll down
				else
					vim.api.nvim_input("<C-f>")
				end
			end, { noremap = true, silent = true })

			keymap.set("n", "<C-b>", function()
				if vim.fn.pumvisible() == 0 then
					vim.api.nvim_input("<C-w>w<C-y>") -- Scroll up
				else
					vim.api.nvim_input("<C-b>")
				end
			end, { noremap = true, silent = true })

			opts.desc = "Restart LSP"
			keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end
		-- Set up capabilities for autocompletion
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_nvim_lsp.default_capabilities()
		)

		-- Set up nvim-cmp
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Set up LSP servers with Mason
		mason_lspconfig.setup_handlers({
			function(server_name)
				lspconfig[server_name].setup({
					on_attach = on_attach,
					capabilities = capabilities, -- Ensure capabilities are included here
				})
			end,
			["svelte"] = function()
				lspconfig.svelte.setup({
					capabilities = capabilities,
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePost", {
							pattern = { "*.js", "*.ts" },
							callback = function(ctx)
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
							end,
						})
						on_attach(client, bufnr)
					end,
				})
			end,
			["graphql"] = function()
				lspconfig.graphql.setup({
					capabilities = capabilities,
					filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
					on_attach = on_attach,
				})
			end,
			["emmet_ls"] = function()
				lspconfig.emmet_ls.setup({
					capabilities = capabilities,
					filetypes = {
						"html",
						"typescriptreact",
						"javascriptreact",
						"css",
						"sass",
						"scss",
						"less",
						"svelte",
					},
					on_attach = on_attach,
				})
			end,
			["lua_ls"] = function()
				lspconfig.lua_ls.setup({
					capabilities = capabilities,
					settings = {
						Lua = {
							runtime = { version = "Lua 5.1" },
							diagnostics = {
								globals = { "vim", "it", "describe", "before_each", "after_each" },
							},
							completion = {
								callSnippet = "Replace",
							},
						},
					},
					on_attach = on_attach,
				})
			end,
			["tsserver"] = function()
				lspconfig.tsserver.setup({
					on_attach = on_attach,
					capabilities = capabilities, -- Ensure capabilities are included here
					init_options = {
						preferences = {
							disableSuggestions = false, -- Ensure suggestions are enabled
						},
					},
				})
			end,
			["pyright"] = function()
				lspconfig.pyright.setup({
					on_attach = on_attach,
					capabilities = capabilities, -- Ensure capabilities are included here
				})
			end,
		})

		-- Configure null-ls
		null_ls.setup({
			sources = {
				null_ls.builtins.diagnostics.eslint, -- JS
				null_ls.builtins.code_actions.eslint, -- JS
				null_ls.builtins.formatting.prettier, -- JS
				null_ls.builtins.diagnostics.flake8, -- Python
				null_ls.builtins.formatting.black, -- Python
				null_ls.builtins.diagnostics.mypy, -- Python
				null_ls.builtins.diagnostics.cppcheck, -- C++
				null_ls.builtins.diagnostics.cpplint, -- C++
			},
			on_attach = on_attach,
		})
	end,
}
