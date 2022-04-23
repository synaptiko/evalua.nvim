vim.api.nvim_list_uis()
vim.api.nvim_win_get_cursor(0)

function test()
  -- vim.cmd('messages clear')
  -- print(vim.inspect(vim.api.nvim_list_uis()))
  -- print(vim.inspect(vim.api.nvim_win_get_cursor(0)))
	print('yay')
  return 'test!'
end
print(test())
test()
