return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      enabled = false, -- Disable snacks explorer
    },
  },
  keys = {
    -- Disable all explorer keybindings from snacks
    { "<leader>fe", false },
    { "<leader>fE", false },
    { "<leader>e", false },
    { "<leader>E", false },
  },
}
