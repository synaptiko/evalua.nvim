if not vim.fn.has('nvim-0.7.0') then
  vim.cmd('echoerr "metalua.nvim requires at least nvim-0.7.0."')
  return
end
