return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		routes = {
			{
				filter = { event = "notify", find = "No information available" },
				opts = { skip = true },
			},
		},
		presets = {
			lsp_doc_border = true,
		},
	},
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	messages = {
		-- NOTE: If you enable messages, then the cmdline is enabled automatically.
		-- This is a current Neovim limitation.
		enabled = true, -- enables the Noice messages UI
		view = "notify", -- default view for messages
		view_error = "notify", -- view for errors
		view_warn = "notify", -- view for warnings
		view_history = "messages", -- view for :messages
		view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
	},
}
