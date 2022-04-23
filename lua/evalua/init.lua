local utils = require('evalua/utils')

local M = {
  count = 1,
}

function M.eval()
  print('Evalua: eval', M.count)

  local current_line, line_number = utils.get_current_line()
  local result, err, prints = utils.eval(current_line, M.count, true)

  M.count = M.count + 1

	if err == nil then
		local lines = utils.value_to_lines(result)
		table.insert(lines, 1, '--' .. '[[') -- use .. to avoid confusing the lua parser
		table.insert(lines, '--]]')

		vim.api.nvim_buf_set_lines(0, line_number, line_number, false, result)
	else
		error(err)
	end
end

function M.eval_block()
  print('Evalua: eval_block', M.count)

  local _, line_number = utils.get_current_line()
  local block = utils.get_visual_selection()

  local result, err, prints = utils.eval(block, M.count, true)

  M.count = M.count + 1

	if err == nil then
		local lines = utils.value_to_lines(result)
		table.insert(lines, 1, '--' .. '[[') -- use .. to avoid confusing the lua parser
		table.insert(lines, '--]]')

		vim.api.nvim_buf_set_lines(0, line_number, line_number, false, result)
	else
    error(err)
	end

  vim.api.nvim_input('<esc>')
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

  local current_line = utils.get_current_line()
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
