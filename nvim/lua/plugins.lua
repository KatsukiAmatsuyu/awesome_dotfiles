return require('packer').startup(function()
	use 'tpope/vim-fugitive'
	use 'scrooloose/nerdtree'
	use 'scrooloose/nerdcommenter'
	use 'kyazdani42/nvim-web-devicons'
	use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}
	use 'nvim-treesitter/nvim-treesitter'
	use 'nathom/filetype.nvim'
	use 'lewis6991/gitsigns.nvim'
	use 'neovim/nvim-lspconfig'
	use 'ray-x/lsp_signature.nvim'
	use 'nvim-telescope/telescope.nvim'
	use 'glepnir/dashboard-nvim'
	use 'junegunn/fzf.vim'
	use 'liuchengxu/vim-clap'
	use 'dylanaraps/wal.vim'
	use 'ap/vim-css-color'
end)

