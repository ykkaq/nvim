return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp", "rust", "python", "julia", "latex",
          "lua", "vim", "vimdoc", "bash", "toml",
        },
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(_, buf)
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > 100 * 1024
          end,
        },
        indent = { enable = true, disable = { "python" } },
      })
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },
          sorting_strategy = "ascending",
          layout_config = { horizontal = { prompt_position = "top" } },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<esc>"] = actions.close,
            },
          },
          file_ignore_patterns = { ".git/", "node_modules", "%.o", "%.pdf" },
        },
        pickers = {
          find_files = { theme = "dropdown", previewer = false, hidden = true },
          live_grep  = { theme = "ivy" },
          buffers    = { theme = "dropdown", previewer = false },
        },
      })

      pcall(telescope.load_extension, "fzf")
    end,
  },

  { "nvim-lua/plenary.nvim", lazy = true },
}
