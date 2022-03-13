vim.g.mapleader = ' '

local map = vim.api.nvim_set_keymap

map('i', 'jj', '<Esc>', {noremap = true})
map('n', '<C-s>', ':w<CR>', {noremap = true})
map('n', '<leader>e', ':NERDTreeFocus<CR>', {noremap = true})
map('n', '<C-e>', ':NERDTreeToggle<CR>', {noremap = true})
map('n', '<C-z>', ':BufferLineCyclePrev<CR>', {noremap = true})
map('n', '<C-x>', ':BufferLineCycleNext<CR>', {noremap = true})
map('n', '<C-S-q>', ':wqa<CR>', {noremap = true})
