return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    -- Copilot configuration
    vim.g.copilot_no_tab_map = true
    -- Use Ctrl+O to accept suggestions
    vim.keymap.set("i", "<C-o>", 'copilot#Accept("\\<CR>")', { silent = true, expr = true, replace_keycodes = false })
    vim.g.copilot_filetypes = {
      ["*"] = true,
    }
  end,
}
