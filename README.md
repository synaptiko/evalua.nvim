# evalua.nvim

Neovim plugin for easier plugin development in lua.

## Features

Allows you to:
1. reload your plugin during the development and test it in the current instance of neovim
2. run lua statement(s)
3. evaluate expression and see the result or error and what was printed while running in floating window

## Getting started

This plugin was written with usage of new features of [Neovim 0.7](https://github.com/neovim/neovim/releases/tag/v0.7.0).

### Installation

Example configuration with `packer.nvim`:
```lua
use({
	'synaptiko/evalua.nvim',
	config = function()
		local evalua = require('evalua')
		local augroup = vim.api.nvim_create_augroup('evalua_mappings', { clear = true })

		vim.api.nvim_create_autocmd('FileType', {
			group = augroup,
			pattern = 'lua',
			callback = function()
				vim.keymap.set('n', '<Leader>r', evalua.run, { buffer = true, silent = true })
				vim.keymap.set('n', '<Leader>e', evalua.eval, { buffer = true, silent = true })
				vim.keymap.set('v', '<Leader>r', evalua.run_block, { buffer = true, silent = true })
				vim.keymap.set('v', '<Leader>e', evalua.eval_block, { buffer = true, silent = true })
			end,
		})

		vim.cmd([[
			command! EvaluaEnableReload :lua vim.keymap.set('n', '<Leader>a', require('evalua').reload, { silent = true })
		]])
	end,
	requires = 'nvim-lua/plenary.nvim'
})
```

then sync your plugins:
```
:PackerSync
```

Now you should be ready to use the plugin in your plugins or lua files.

### Usage

To use plugin reload feature in your plugin, you need to create `development-reload.lua` files in the root of your plugin. Here's example of `evalua`'s one:
```lua
require('evalua').unload('evalua')

local evalua = require('evalua')

vim.keymap.set('n', '<Leader>r', evalua.run, { silent = true })
vim.keymap.set('n', '<Leader>e', evalua.eval, { silent = true })
vim.keymap.set('v', '<Leader>r', evalua.run_block, { silent = true })
vim.keymap.set('v', '<Leader>e', evalua.eval_block, { silent = true })
vim.keymap.set('n', '<Leader>a', evalua.reload, { silent = true })
```

The important part is `require('evalua').unload('<your-plugin-name>')`. After that you can require your plugin again, it will load an up-to-date version of it. The `unload` function will take care of nested imports like `my-plugin.utils` or `my-plugin/utils`.

Feel free to provide any type of "testing" code you need to run after your plugin is reloaded during development, ie. bind some keymaps.

Another use-case is when you need to verify that specific part of your plugin works as expected. You can use `run`, `eval` and `run_block` and `eval_block` functions for that. The `run` function only runs the statements and won't show anything while `eval` will show you a floating window with results. You can close this window by pressing `<Esc>`, or you can copy some part of it for later.

## Inspiration
- https://github.com/bfredl/nvim-luadev
- https://github.com/rafcamlet/nvim-luapad
