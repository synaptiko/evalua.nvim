local Path = require('plenary.path')

local M = {}

function M.get_visual_selection()
  local visual_modes = { v = true, V = true }
  local mode = vim.api.nvim_get_mode().mode

  if visual_modes[mode] == nil then
    return
  end

  local _, line1, col1 = unpack(vim.fn.getpos('v'))
  local _, line2, col2 = unpack(vim.fn.getpos('.'))

  if line1 > line2 then
    local swap_line = line2
    local swap_col = col2

    line2 = line1
    col2 = col1
    line1 = swap_line
    col1 = swap_col
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

  if mode == 'v' then
    if line1 == line2 then
      lines[1] = vim.fn.strpart(lines[1], col1 - 1, col2 - col1 + 1)
    else
      lines[1] = vim.fn.strpart(lines[1], col1 - 1)
      lines[#lines] = vim.fn.strpart(lines[#lines], 0, col2)
    end
  end

  return table.concat(lines, '\n')
end

function M.split(str, delimiter)
  local result = {}
  local from = 1
  local delim_from, delim_to = string.find(str, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from)
  end
  table.insert(result, string.sub(str, from))
  return result
end

function M.eval_file(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then
      return
    end

    if stat.type == 'file' then
      local path = Path:new(filepath)
      path:read(vim.schedule_wrap(function(content)
        M.eval(content, 'reload', false)
      end))
    end
  end)
end

function M.print(...)
  local strs = {}
  local args = { ... }

  for i = 1, select('#', ...) do
    strs[i] = tostring(args[i])
  end

  table.insert(M.prints, table.concat(strs, ' '))
end

function M.eval(content, count, redirect_print)
  local name = '@[evalua ' .. count .. ']'
  local chunk, error = loadstring('return \n' .. content, name)

  if error or chunk == nil then
    chunk, error = loadstring(content, name)
  end

  local result

  if chunk ~= nil then
    local orig_print = _G.print

    if redirect_print then
      M.prints = {}
      _G.print = M.print
    end

    local status, call_result = pcall(chunk)

    if redirect_print then
      _G.print = orig_print
    end

    if status == false then
      error = call_result
    else
      result = call_result
    end
  end

  local prints = M.prints

  M.prints = nil

  return result, error, prints
end

function M.value_to_lines(value)
  return M.split(vim.inspect(value), '\n')
end

function M.open_eval_window(result, error, prints)
  local buffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(buffer, 'bufhidden', 'wipe')

  local ui_width = vim.api.nvim_get_option('columns')
  local ui_height = vim.api.nvim_get_option('lines')

  local width = math.ceil(ui_width * 0.4)
  local height = math.ceil(ui_height * 0.5 - 4)

  local col = math.ceil((ui_width - width) / 2)
  local row = math.ceil((ui_height - height) / 2 - 1)

  local window = vim.api.nvim_open_win(buffer, true, {
    style = 'minimal',
    border = 'double',
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
  })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(window, true)
  end, { buffer = buffer, silent = true })

  local lines = {}

  if error == nil then
    local result_lines = M.value_to_lines(result)

    table.insert(lines, 'Result:')

    for _, line in ipairs(result_lines) do
      table.insert(lines, line)
    end
  else
    local error_lines = M.value_to_lines(error)

    table.insert(lines, 'Error:')

    for _, line in ipairs(error_lines) do
      table.insert(lines, line)
    end
  end

  if #prints > 0 then
    if #lines > 0 then
      table.insert(lines, '')
    end
    table.insert(lines, 'Printed:')

    for _, line in ipairs(prints) do
      table.insert(lines, line)
    end
  end

  vim.api.nvim_buf_set_lines(buffer, 0, 0, false, lines)
end

return M
