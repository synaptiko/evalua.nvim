require('evalua').unload('evalua')

local evalua = require('evalua')

vim.keymap.set('n', '<Leader>r', evalua.run, { silent = true })
vim.keymap.set('n', '<Leader>e', evalua.eval, { silent = true })
vim.keymap.set('v', '<Leader>r', evalua.run_block, { silent = true })
vim.keymap.set('v', '<Leader>e', evalua.eval_block, { silent = true })
vim.keymap.set('n', '<Leader>a', evalua.reload, { silent = true })
