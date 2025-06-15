-- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

-- golbal leader key
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- display options
vim.o.number = true
vim.o.showmode = false
vim.o.cursorline = true
vim.o.signcolumn = "yes"
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- editing options
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.breakindent = true
vim.o.undofile = true

-- search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "nosplit"

-- window options
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.confirm = true

-- mouse support
vim.o.mouse = "a"

-- sync clipboard
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
