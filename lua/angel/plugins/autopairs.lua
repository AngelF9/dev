return {
	"windwp/nvim-autopairs",
	event = { "InsertEnter" },
	dependencies = {
		"hrsh7th/nvim-cmp",
		"nvim-treesitter/nvim-treesitter",
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local autopairs = require("nvim-autopairs")
		autopairs.setup({
			check_ts = true,
			ts_config = {
				lua = { "string" },
				javascript = { "template_string" },
				java = false,
			},
		})

		-- Setup nvim-cmp integration with nvim-autopairs
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
