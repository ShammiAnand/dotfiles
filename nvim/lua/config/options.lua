-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Make nvm-managed node/npm/npx available to mason and LSP servers (e.g. pyright)
-- nvm uses lazy-loading in zsh, so node isn't in PATH when nvim starts from a GUI/tmux
local nvm_dir = vim.fn.expand("$HOME/.nvm")
local nvm_node_path = vim.fn.glob(nvm_dir .. "/versions/node/*/bin", false, true)
if #nvm_node_path > 0 then
  -- Sort descending so the latest version comes first
  table.sort(nvm_node_path, function(a, b) return a > b end)
  vim.env.PATH = nvm_node_path[1] .. ":" .. vim.env.PATH
end
