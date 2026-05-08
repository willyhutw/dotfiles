return {
	-- https://github.com/iamcco/markdown-preview.nvim
	"iamcco/markdown-preview.nvim",
	enabled = true,
	branch = "master",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn["mkdp#util#install"]()
	end,
}
