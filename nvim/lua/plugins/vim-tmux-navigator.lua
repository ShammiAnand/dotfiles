return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", mode = { "n", "t", "i" } },
    { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", mode = { "n", "t", "i" } },
    { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", mode = { "n", "t", "i" } },
    { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", mode = { "n", "t", "i" } },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", mode = { "n", "t", "i" } },
  },
}
