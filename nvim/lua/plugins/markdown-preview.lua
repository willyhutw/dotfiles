return {
	-- https://github.com/iamcco/markdown-preview.nvim
	"iamcco/markdown-preview.nvim",
	enabled = true,
	version = "v0.0.10",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
}
