local cmd = vim.cmd             -- execute Vim commands
local exec = vim.api.nvim_exec  -- execute Vimscript
local g = vim.g                 -- global variables
local opt = vim.opt             -- global/buffer/windows-scoped options

opt.number = true
opt.autoindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.smarttab = true
opt.softtabstop = 4
opt.mouse = 'a'
-- opt.termguicolors = true --

g.NERDCreateDefaultMappings = 1
g.NERDSpaceDelims = 1
g.NERDCompactSexyComs = 1
g.minimap_width = 15
g.minimap_auto_start = 1
g.minimap_auto_start_win_enter = 1

require("bufferline").setup{}
require('lualine').setup{}

vim.cmd('colorscheme levuaska')
vim.cmd('filetype plugin on')
