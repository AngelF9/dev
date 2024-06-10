return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local transform_mod = require("telescope.actions.mt").transform_mod

		local trouble = require("trouble")

		-- local trouble_telescope = require("trouble.providers.telescope")
		local trouble_telescope = require("trouble.sources.telescope") -- updated this line

		-- or create your custom action
		local custom_actions = transform_mod({
			open_trouble_qflist = function(prompt_bufnr)
				trouble.toggle("quickfix")
			end,
		})

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
						-- ["<C-t>"] = trouble_telescope.smart_open_with_trouble,
						["<C-t>"] = trouble_telescope.open, -- updated this line
					},
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		-- Custom functions to search documentation
		local function search_mdn()
			local word = vim.fn.expand("<cword>")
			local mdn_url = "https://developer.mozilla.org/en-US/search?q=" .. word
			os.execute(string.format("open %s", mdn_url))
		end

		local function search_python()
			local word = vim.fn.expand("<cword>")
			local python_url = "https://docs.python.org/3/search.html?q=" .. word
			os.execute(string.format("open %s", python_url))
		end

		local function search_css()
			local word = vim.fn.expand("<cword>")
			local css_url = "https://developer.mozilla.org/en-US/search?q=" .. word .. "&topic=css"
			os.execute(string.format("open %s", css_url))
		end

		local function search_html()
			local word = vim.fn.expand("<cword>")
			local html_url = "https://developer.mozilla.org/en-US/search?q=" .. word .. "&topic=html"
			os.execute(string.format("open %s", html_url))
		end

		local function search_node()
			local word = vim.fn.expand("<cword>")
			local node_url = "https://nodejs.org/api/all.html#all_" .. word
			os.execute(string.format("open %s", node_url))
		end

		local function search_express()
			local word = vim.fn.expand("<cword>")
			local express_url = "https://expressjs.com/en/5x/api.html#search-" .. word
			os.execute(string.format("open %s", express_url))
		end

		local function search_mongodb()
			local word = vim.fn.expand("<cword>")
			local mongodb_url = "https://docs.mongodb.com/search/?q=" .. word
			os.execute(string.format("open %s", mongodb_url))
		end

		-- Keybindings to search documentation
		keymap.set("n", "<leader>md", search_mdn, { desc = "Search MDN for word under cursor" })
		keymap.set("n", "<leader>py", search_python, { desc = "Search Python docs for word under cursor" })
		keymap.set("n", "<leader>cs", search_css, { desc = "Search CSS docs for word under cursor" })
		keymap.set("n", "<leader>ht", search_html, { desc = "Search HTML docs for word under cursor" })
		keymap.set("n", "<leader>no", search_node, { desc = "Search Node.js docs for word under cursor" })
		keymap.set("n", "<leader>ex", search_express, { desc = "Search Express.js docs for word under cursor" })
		keymap.set("n", "<leader>mg", search_mongodb, { desc = "Search MongoDB docs for word under cursor" })
	end,
}
