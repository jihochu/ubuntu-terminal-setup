-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Fast saving
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })

-- Quit with leader
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- Lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- opencode
map({ "n", "x" }, "<C-a>", function()
	require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode…" })
map({ "n", "x" }, "<C-x>", function()
	require("opencode").select()
end, { desc = "Execute opencode action…" })
map({ "n", "t" }, "<C-b>", function()
	require("opencode").toggle()
end, { desc = "Toggle opencode" })

map({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { desc = "Add range to opencode", expr = true })
map("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Add line to opencode", expr = true })

map("n", "<S-C-u>", function()
	require("opencode").command("session.half.page.up")
end, { desc = "Scroll opencode up" })
map("n", "<S-C-d>", function()
	require("opencode").command("session.half.page.down")
end, { desc = "Scroll opencode down" })
