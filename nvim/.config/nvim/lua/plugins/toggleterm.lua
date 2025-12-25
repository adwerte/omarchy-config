return {
  "akinsho/toggleterm.nvim",
  opts = function(_, opts)
    -- keep LazyVim's defaults
    return opts
  end,
  config = function()
    local Terminal = require("toggleterm.terminal").Terminal

    -- Persistent Cargo Run terminal
    local cargo = Terminal:new({
      cmd = "clear && cargo run",
      hidden = true,
      close_on_exit = false,
      direction = "horizontal",
      on_open = function()
        vim.cmd("startinsert!")
      end,
    })

    -- Keybind: rerun cargo
    vim.keymap.set("n", "<leader>rr", function()
      cargo:shutdown()
      cargo:open()
    end, { desc = "Cargo run (rerun)" })
  end,
}
