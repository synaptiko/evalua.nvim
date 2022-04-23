local utils = require('evalua/utils')

local M = {}

function M.eval()
  print('Evalua: eval')

  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local curline = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]

  local chunk = assert(loadstring('return ' .. curline))
  local result = utils.split(vim.inspect(chunk()), '\n')

  table.insert(result, 1, '--' .. '[[') -- use .. to avoid confusing the lua parser
  table.insert(result, '--]]')

  vim.api.nvim_buf_set_lines(0, linenr, linenr, false, result)
end

function M.eval_block()
  print('Evalua: eval_block')

  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local block = utils.get_visual_selection()

  local chunk = assert(loadstring('return ' .. block))
  local result = utils.split(vim.inspect(chunk()), '\n')

  table.insert(result, 1, '--' .. '[[') -- use .. to avoid confusing the lua parser
  table.insert(result, '--]]')

  vim.api.nvim_buf_set_lines(0, linenr, linenr, false, result)

  vim.api.nvim_input('<esc>')
end

function M.run_block()
  print('Evalua: run_block')

  local block = utils.get_visual_selection()

  vim.cmd('lua << EOF\n' .. block .. '\nEOF')

  vim.api.nvim_input('<esc>')
end

function M.run()
  print('Evalua: run')

  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local curline = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]

  assert(loadstring(curline))()
end

function M.reload()
  print('Evalua: reload')

  utils.eval_file('./development-reload.lua')
end

function M.set_mappings()
  local augroup = vim.api.nvim_create_augroup('evalua_mappings', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'lua',
    callback = function()
      vim.keymap.set('v', '<Leader>r', M.run_block, { buffer = true, silent = true })
      vim.keymap.set('n', '<Leader>r', M.run, { buffer = true, silent = true })
      vim.keymap.set('v', '<Leader>e', M.eval_block, { buffer = true, silent = true })
      vim.keymap.set('n', '<Leader>e', M.eval, { buffer = true, silent = true })
    end,
  })

  vim.keymap.set('n', '<Leader>d', M.reload, { silent = true })
end

function M.setup()
  M.set_mappings()
end

return M
