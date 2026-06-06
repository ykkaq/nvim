return {
  -- ============================================================
  -- Treesitter: syntax highlighting & code understanding
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp",         -- C / C++
          "rust",             -- Rust
          "python",           -- Python
          "julia",            -- Julia
          "latex",            -- TeX / LaTeX
          "lua",              -- Neovim config
          "vim", "vimdoc",    -- Vim script / help
          "bash",             -- Shell
          "json", "jsonc",    -- JSON
          "toml",             -- TOML (Cargo.toml, etc.)
          "yaml",             -- YAML
          "markdown", "markdown_inline",  -- Markdown
          "regex",            -- Regex
          "query",            -- Treesitter query
        },
        auto_install = true,
        highlight = {
          enable = true,
          -- Disable for very large files to keep performance
          disable = function(_, buf)
            local max_filesize = 100 * 1024  -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
          disable = { "python" },  -- Python indentation is tricky with treesitter
        },
        -- Text objects (select blocks, functions, etc.)
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ab"] = "@block.outer",
              ["ib"] = "@block.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
          swap = {
            enable = true,
            swap_next     = { ["<leader>a"] = "@parameter.inner" },
            swap_previous = { ["<leader>A"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  -- ============================================================
  -- Autopairs: automatically close brackets, quotes, etc.
  -- ============================================================
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local autopairs = require("nvim-autopairs")
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")

      autopairs.setup({
        check_ts = true,  -- Use treesitter for better pair detection
        ts_config = {
          lua  = { "string" },   -- Don't pair in lua strings
          javascript = { "template_string" },
          java = false,
        },
        disable_filetype = { "TelescopePrompt", "spectre_panel" },
        fast_wrap = {
          map = "<M-e>",   -- Alt+e to fast-wrap the next character
          chars = { "{", "[", "(", '"', "'" },
          pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "PmenuSel",
          highlight_grey = "LineNr",
        },
      })

      -- Integrate with nvim-cmp: confirm adds closing pair
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ============================================================
  -- Comment.nvim: toggle comments (gcc / gc in visual)
  -- ============================================================
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup({
        padding = true,   -- Add a space after comment symbol
        sticky = true,    -- Cursor stays in place
        ignore = nil,
        toggler = {
          line  = "gcc",  -- Toggle current line comment
          block = "gbc",  -- Toggle block comment
        },
        opleader = {
          line  = "gc",   -- Line comment operator (gc{motion})
          block = "gb",   -- Block comment operator
        },
        extra = {
          above = "gcO",  -- Add comment on the line above
          below = "gco",  -- Add comment on the line below
          eol   = "gcA",  -- Add comment at end of line
        },
        mappings = {
          basic = true,
          extra = true,
        },
        post_hook = nil,
      })
    end,
  },

  -- ============================================================
  -- Telescope: fuzzy finder (VSCode Ctrl+P / Ctrl+Shift+F)
  -- ============================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = " ",
          selection_caret = " ",
          path_display    = { "smart" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            i = {
              ["<C-k>"]    = actions.move_selection_previous,
              ["<C-j>"]    = actions.move_selection_next,
              ["<C-q>"]    = actions.send_selected_to_qflist + actions.open_qflist,
              ["<M-q>"]    = actions.send_to_qflist + actions.open_qflist,
              ["<esc>"]    = actions.close,
              ["<C-u>"]    = false,  -- Clear prompt
              ["<C-d>"]    = false,
            },
            n = {
              ["q"]        = actions.close,
              ["<C-k>"]    = actions.move_selection_previous,
              ["<C-j>"]    = actions.move_selection_next,
            },
          },
          file_ignore_patterns = {
            "node_modules", ".git/", "*.o", "*.out",
            ".DS_Store", "dist/", "build/", "target/",
            "%.pdf", "%.png", "%.jpg", "%.jpeg", "%.gif", "%.svg",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!.git/",
          },
        },
        pickers = {
          find_files = {
            theme = "dropdown",
            previewer = false,
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          },
          live_grep = {
            theme = "ivy",
          },
          buffers = {
            theme = "dropdown",
            previewer = false,
            initial_mode = "normal",
            mappings = {
              n = { ["dd"] = actions.delete_buffer },
            },
          },
          oldfiles = {
            theme = "dropdown",
            previewer = false,
          },
          colorscheme = { enable_preview = true },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      -- Load extensions
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },

  -- ============================================================
  -- Which-key: shows available keybindings in a popup
  -- ============================================================
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
      local wk = require("which-key")
      wk.setup({
        plugins = {
          marks      = true,
          registers  = true,
          spelling   = { enabled = true, suggestions = 20 },
          presets    = {
            operators    = false,
            motions      = false,
            text_objects = false,
            windows      = true,
            nav          = true,
            z            = true,
            g            = true,
          },
        },
        win = {
          border   = "rounded",
          padding  = { 2, 2, 2, 2 },
        },
        layout = {
          height = { min = 4, max = 25 },
          width  = { min = 20, max = 50 },
          spacing = 3,
          align  = "left",
        },
        show_help = true,
        show_keys = true,
      })

      -- Register key group labels
      wk.add({
        { "<leader>b",  group = "Buffer" },
        { "<leader>c",  group = "Code" },
        { "<leader>e",  desc = "File Explorer" },
        { "<leader>f",  group = "Find/File" },
        { "<leader>g",  group = "Git" },
        { "<leader>l",  group = "LSP" },
        { "<leader>q",  desc = "Quit" },
        { "<leader>r",  group = "Rename" },
        { "<leader>w",  desc = "Save" },
        { "<leader>/",  desc = "Toggle comment" },
      })
    end,
  },

  -- ============================================================
  -- Plenary (utility library, required by telescope & others)
  -- ============================================================
  { "nvim-lua/plenary.nvim", lazy = true },

  -- ============================================================
  -- Treesitter textobjects (loaded as dependency above)
  -- ============================================================
  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
}
