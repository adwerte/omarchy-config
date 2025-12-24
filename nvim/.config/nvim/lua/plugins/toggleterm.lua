return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 15,
      direction = "horizontal",
      close_on_exit = false,
    })
  end,
}
