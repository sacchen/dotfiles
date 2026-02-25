--[[
Plugin quick reference (remaining setup)
- Mofiqul/vscode.nvim: colorscheme/theme. Access: automatic on startup (`:colorscheme vscode`).
- nvim-lualine/lualine.nvim: statusline UI. Access: automatic on startup.
- nvim-tree/nvim-web-devicons: filetype icons for tree/statusline/telescope. Access: automatic where supported.
- windwp/nvim-autopairs: auto-insert closing pairs in insert mode. Access: type brackets/quotes.
- nvim-treesitter/nvim-treesitter: syntax parsing/highlighting. Access: automatic on supported filetypes.
- nvim-tree/nvim-tree.lua: file sidebar. Access: `<leader>e` or `:NvimTreeToggle`.
- stevearc/conform.nvim: formatting. Access: `<leader>f` and format-on-save (`BufWritePre`).
- lewis6991/gitsigns.nvim: git hunks in signcolumn. Access: `:Gitsigns ...` commands.
- nvim-telescope/telescope.nvim (+ nvim-lua/plenary.nvim + telescope-fzf-native): fuzzy finder.
  Access: `<leader>sf` files, `<leader>sg` live grep, `<leader>sd` diagnostics,
  `<leader>sh` help tags, `<leader><leader>` buffers, or `:Telescope`.
- neovim/nvim-lspconfig + mason.nvim + mason-lspconfig.nvim + mason-tool-installer.nvim: LSP server setup/installation.
  Access: automatic via `LspAttach`; mappings include `gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`,
  plus diagnostics `<leader>d` (float) and `<leader>q` (location list).
- saghen/blink.cmp: completion menu/capabilities integration. Access: completion in insert mode.
]]

-- [[ 1. Global Settings & Leader ]]
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ 2. Options ]]
local opt = vim.opt

-- Line numbers & visual helpers
opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.cursorline = true -- Highlights the current line
opt.scrolloff = 10 -- Keep 10 lines context above/below cursor

-- Search & Case
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = 'split' -- Preview substitutions live
opt.hlsearch = true

-- Indentation & Wrapping
opt.breakindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

-- System & UI
opt.mouse = 'a'
opt.showmode = false
opt.termguicolors = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.confirm = true
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.undofile = true

-- Clipboard (Sync with system)
opt.clipboard = 'unnamedplus'

-- [[ 3. Basic Keymaps ]]
-- Clear highlights on Esc
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show line [D]iagnostic' })
vim.keymap.set('n', '<leader>td', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = '[T]oggle [D]iagnostics' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Terminal exit
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- [[ 4. Autocommands ]]
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ 5. Bootstrap Lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ 6. Plugin Configuration ]]
require('lazy').setup {
  -- Theme: VSCode
  {
    'Mofiqul/vscode.nvim',
    priority = 1000,
    config = function()
      require('vscode').setup {
        style = 'dark',
        transparent = false,
        italic_comments = true,
      }
      vim.cmd.colorscheme 'vscode'
      -- FIX: "vim.opt.guicursor = ''" removed to restore cursor contrast
    end,
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  -- Auto-close brackets
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- Treesitter (Syntax Highlighting)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'lua', 'python', 'rust', 'bash', 'markdown', 'vim', 'vimdoc', 'julia' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- File Explorer
  {
    'nvim-tree/nvim-tree.lua',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require('nvim-tree').setup {
        view = { width = 30 },
        actions = { open_file = { quit_on_open = true } }, -- Optional: Close tree when opening a file
      }
      vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle File Tree' })
    end,
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_format' },
        rust = { 'rustfmt' },
      },
    },
  },

  -- Git Signs
  { 'lewis6991/gitsigns.nvim', opts = {} },

  -- Telescope (Fuzzy Finder)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        extensions = {
        },
      }
      pcall(telescope.load_extension, 'fzf')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    end,
  },

  -- [[ LSP Configuration & Autocompletion ]]
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason: Package manager
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Autocompletion (Blink.cmp)
      {
        'saghen/blink.cmp',
        version = '*',
        opts = {
          keymap = { preset = 'default' },
          appearance = {
            use_nvim_cmp_as_default = true,
            nerd_font_variant = 'mono',
          },
          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
          },
        },
      },
    },
    config = function()
      -- 1. Setup Autocommands (Keymaps, Highlights)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to definition/ref
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- Highlight references under cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- 2. Setup Capabilities (Autocompletion)
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- 3. Setup Mason (Auto-install servers)
      require('mason').setup()

      local ensure_installed = {
        'basedpyright', -- Python
        'ruff', -- Python Linter/Formatter
        'lua_ls', -- Lua
        'rust_analyzer', -- Rust
        'stylua', -- Lua Formatter
      }

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server_opts = { capabilities = capabilities }
            -- Lua specific settings
            if server_name == 'lua_ls' then
              server_opts.settings = { Lua = { completion = { callSnippet = 'Replace' } } }
            end
            vim.lsp.config(server_name, server_opts)
            vim.lsp.enable(server_name)
          end,
        },
      }

      -- Julia LSP
      vim.lsp.config('julials', {
        capabilities = capabilities,
        on_new_config = function(new_config, _)
          local julia_env_path = vim.fn.expand("~/.julia/environments/nvim-lspconfig")
          new_config.cmd = {
            "julia",
            "--project=" .. julia_env_path,
            "--startup-file=no",
            "--history-file=no",
            "-e",
            "using LanguageServer; runserver()"
          }
        end
      })
      vim.lsp.enable('julials')
    end,
  },
}
