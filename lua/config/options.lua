-- Leader key (must be set before lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Line wrapping
vim.opt.wrap = false

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Appearance
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = ""
vim.opt.showmode = false  -- lualine shows it instead

-- Split behavior (VSCode-like: new splits open to the right/below)
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Clipboard: share with system clipboard
vim.opt.clipboard = "unnamedplus"

-- File encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Backup/swap
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Performance
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Completion
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.pumheight = 10  -- popup menu height

-- Misc
vim.opt.mouse = "a"
vim.opt.conceallevel = 0
vim.opt.isfname:append("@-@")
vim.opt.shortmess:append("c")

-- Fold (disabled by default, use treesitter when needed)
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

-- WSL clipboard fix (uncomment if using WSL)
-- vim.g.clipboard = {
--   name = "win32yank",
--   copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
--   paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
-- }
