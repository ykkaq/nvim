local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================
-- General
-- ============================================================

-- Save / Quit
map("n", "<leader>w", "<cmd>w<CR>", vim.tbl_extend("force", opts, { desc = "Save file" }))
map("n", "<leader>q", "<cmd>q<CR>", vim.tbl_extend("force", opts, { desc = "Quit" }))
map("n", "<leader>Q", "<cmd>qa!<CR>", vim.tbl_extend("force", opts, { desc = "Quit all (force)" }))

-- Clear search highlight with Escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- Better indenting in visual mode (stay in visual after indent)
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up/down (Alt+j/k like VSCode)
map("n", "<A-j>", "<cmd>m .+1<CR>==", vim.tbl_extend("force", opts, { desc = "Move line down" }))
map("n", "<A-k>", "<cmd>m .-2<CR>==", vim.tbl_extend("force", opts, { desc = "Move line up" }))
map("v", "<A-j>", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection down" }))
map("v", "<A-k>", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection up" }))

-- Paste without overwriting register
map("v", "p", '"_dP', opts)

-- ============================================================
-- Window navigation (Ctrl+hjkl like VSCode pane switching)
-- ============================================================
map("n", "<C-h>", "<C-w>h", vim.tbl_extend("force", opts, { desc = "Move to left window" }))
map("n", "<C-j>", "<C-w>j", vim.tbl_extend("force", opts, { desc = "Move to lower window" }))
map("n", "<C-k>", "<C-w>k", vim.tbl_extend("force", opts, { desc = "Move to upper window" }))
map("n", "<C-l>", "<C-w>l", vim.tbl_extend("force", opts, { desc = "Move to right window" }))

-- Window resize
map("n", "<C-Up>", "<cmd>resize +2<CR>", opts)
map("n", "<C-Down>", "<cmd>resize -2<CR>", opts)
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", opts)
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", opts)

-- ============================================================
-- Buffer management (VSCode-like tab behavior)
-- ============================================================
map("n", "<S-h>", "<cmd>bprevious<CR>", vim.tbl_extend("force", opts, { desc = "Previous buffer" }))
map("n", "<S-l>", "<cmd>bnext<CR>", vim.tbl_extend("force", opts, { desc = "Next buffer" }))
map("n", "<leader>bd", "<cmd>bdelete<CR>", vim.tbl_extend("force", opts, { desc = "Delete buffer" }))
map("n", "<leader>bD", "<cmd>bdelete!<CR>", vim.tbl_extend("force", opts, { desc = "Delete buffer (force)" }))
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<CR>", vim.tbl_extend("force", opts, { desc = "Close other buffers" }))

-- ============================================================
-- File explorer (Neo-tree) — VSCode sidebar
-- ============================================================
map("n", "<leader>e", "<cmd>Neotree toggle<CR>", vim.tbl_extend("force", opts, { desc = "Toggle file explorer" }))
map("n", "<leader>E", "<cmd>Neotree reveal<CR>", vim.tbl_extend("force", opts, { desc = "Reveal current file in explorer" }))

-- ============================================================
-- Telescope — VSCode Ctrl+P / Ctrl+Shift+F
-- ============================================================
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", vim.tbl_extend("force", opts, { desc = "Find files" }))
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", vim.tbl_extend("force", opts, { desc = "Live grep" }))
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", vim.tbl_extend("force", opts, { desc = "Find buffers" }))
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", vim.tbl_extend("force", opts, { desc = "Help tags" }))
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", vim.tbl_extend("force", opts, { desc = "Recent files" }))
map("n", "<leader>fc", "<cmd>Telescope commands<CR>", vim.tbl_extend("force", opts, { desc = "Commands" }))
-- Ctrl+P shortcut (VSCode muscle memory)
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", vim.tbl_extend("force", opts, { desc = "Find files (Ctrl+P)" }))

-- ============================================================
-- LSP (set in lsp.lua on_attach, but global fallbacks here)
-- ============================================================
map("n", "<leader>lr", "<cmd>LspRestart<CR>", vim.tbl_extend("force", opts, { desc = "Restart LSP" }))
map("n", "<leader>li", "<cmd>LspInfo<CR>", vim.tbl_extend("force", opts, { desc = "LSP info" }))
map("n", "<leader>lm", "<cmd>Mason<CR>", vim.tbl_extend("force", opts, { desc = "Open Mason" }))

-- ============================================================
-- Comment toggle (VSCode Ctrl+/ equivalent)
-- ============================================================
-- Actual toggle is handled by Comment.nvim, bound to gcc/gc
-- Add <leader>/ as additional shortcut
map("n", "<leader>/", "gcc", { noremap = false, silent = true, desc = "Toggle comment" })
map("v", "<leader>/", "gc", { noremap = false, silent = true, desc = "Toggle comment" })

-- ============================================================
-- Git (lazygit)
-- ============================================================
map("n", "<leader>gg", "<cmd>LazyGit<CR>", vim.tbl_extend("force", opts, { desc = "Open LazyGit" }))
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", vim.tbl_extend("force", opts, { desc = "LazyGit current file" }))

-- ============================================================
-- Diagnostics
-- ============================================================
map("n", "<leader>xx", "<cmd>TroubleToggle<CR>", vim.tbl_extend("force", opts, { desc = "Trouble toggle" }))
map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
map("n", "<leader>d", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
