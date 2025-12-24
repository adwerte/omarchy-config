-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Cargo run in ToggleTerm
vim.keymap.set("n", "<leader>rr", function()
  require("lazyvim.util").terminal("cargo run")
end, { desc = "Cargo run" })
