local utils = require('evalua/utils')

local M = {
  count = 1,
}

function M.eval()
  print('Evalua: eval', M.count)

  local current_line = vim.api.nvim_get_current_line()
  local result, err, prints = utils.eval(current_line, M.count, true)

  M.count = M.count + 1

	utils.open_eval_window(result, err, prints)

	if err ~= nil then
		error(err)
	end
end

function M.eval_block()
  print('Evalua: eval_block', M.count)

  local block = utils.get_visual_selection()

  local result, err, prints = utils.eval(block, M.count, true)

  M.count = M.count + 1

	utils.open_eval_window(result, err, prints)

  vim.api.nvim_input('<esc>')

	if err ~= nil then
		error(err)
	end
end

function M.run_block()
  print('Evalua: run_block', M.count)

  local block = utils.get_visual_selection()
  local _, err = utils.eval(block, M.count, false)

  M.count = M.count + 1

  vim.api.nvim_input('<esc>')

  if err ~= nil then
    error(err)
  end
end

function M.run()
  print('Evalua: run', M.count)

  local current_line = vim.api.nvim_get_current_line()
  local _, err = utils.eval(current_line, M.count, false)

  M.count = M.count + 1

  if err ~= nil then
    error(err)
  end
end

function M.reload()
  print('Evalua: reload')

  utils.eval_file('./development-reload.lua')
end

function M.unload(module_name)
  package.loaded[module_name] = nil

  for name in pairs(package.loaded) do
    local prefix = string.sub(name, 1, #module_name + 1)
    if prefix == module_name .. '.' or prefix == module_name .. '/' then
      package.loaded[name] = nil
    end
  end
end

return M
