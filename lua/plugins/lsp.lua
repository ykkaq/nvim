return {
  -- ============================================================
  -- Mason: LSP/DAP/linter/formatter installer
  -- ============================================================
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- ============================================================
  -- Mason-lspconfig: bridge between mason and lspconfig
  -- ============================================================
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",       -- C / C++
          "rust_analyzer",-- Rust
          "texlab",       -- TeX / LaTeX
          "pyright",      -- Python
          -- julia: installed via juliaup, julials started manually
        },
        automatic_installation = true,
      })
    end,
  },

  -- ============================================================
  -- nvim-lspconfig + on_attach setup
  -- ============================================================
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Capabilities with completion support
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Shared on_attach: set keymaps when LSP attaches to a buffer
      local on_attach = function(_, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        -- Go to definition/declaration/references (like VSCode F12, etc.)
        vim.keymap.set("n", "gd",          vim.lsp.buf.definition,       vim.tbl_extend("force", bufopts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD",          vim.lsp.buf.declaration,      vim.tbl_extend("force", bufopts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gi",          vim.lsp.buf.implementation,   vim.tbl_extend("force", bufopts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr",          vim.lsp.buf.references,       vim.tbl_extend("force", bufopts, { desc = "References" }))
        vim.keymap.set("n", "gt",          vim.lsp.buf.type_definition,  vim.tbl_extend("force", bufopts, { desc = "Type definition" }))

        -- Hover / Signature (like VSCode hover)
        vim.keymap.set("n", "K",           vim.lsp.buf.hover,            vim.tbl_extend("force", bufopts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "<C-k>",       vim.lsp.buf.signature_help,   vim.tbl_extend("force", bufopts, { desc = "Signature help" }))

        -- Rename / Code actions (like VSCode F2 / Quick Fix)
        vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,           vim.tbl_extend("force", bufopts, { desc = "Rename symbol" }))
        vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action,      vim.tbl_extend("force", bufopts, { desc = "Code action" }))
        vim.keymap.set("v", "<leader>ca",  vim.lsp.buf.code_action,      vim.tbl_extend("force", bufopts, { desc = "Code action" }))

        -- Format (like VSCode Alt+Shift+F)
        vim.keymap.set("n", "<leader>lf",  function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", bufopts, { desc = "Format file" }))
        vim.keymap.set("v", "<leader>lf",  function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", bufopts, { desc = "Format selection" }))

        -- Workspace
        vim.keymap.set("n", "<leader>wa",  vim.lsp.buf.add_workspace_folder,    vim.tbl_extend("force", bufopts, { desc = "Add workspace folder" }))
        vim.keymap.set("n", "<leader>wr",  vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("force", bufopts, { desc = "Remove workspace folder" }))
        vim.keymap.set("n", "<leader>wl",  function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, vim.tbl_extend("force", bufopts, { desc = "List workspace folders" }))
      end

      -- Diagnostic appearance (VSCode-like)
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })

      -- Diagnostic signs in the gutter
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Hover / Signature border
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

      -- --------------------------------------------------------
      -- C / C++ — clangd
      -- --------------------------------------------------------
      lspconfig.clangd.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_dir = require("lspconfig.util").root_pattern(
          "compile_commands.json", "compile_flags.txt", ".git"
        ),
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      })

      -- --------------------------------------------------------
      -- Rust — rust_analyzer
      -- --------------------------------------------------------
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = { command = "clippy" },
            inlayHints = {
              bindingModeHints = { enable = false },
              chainingHints = { enable = true },
              closingBraceHints = { enable = true, minLines = 25 },
              closureReturnTypeHints = { enable = "never" },
              lifetimeElisionHints = { enable = "never" },
              maxLength = 25,
              parameterHints = { enable = true },
              reborrowHints = { enable = "never" },
              renderColons = true,
              typeHints = { enable = true },
            },
            cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
            procMacro = { enable = true, ignored = { ["async-trait"] = { "async_trait" }, ["napi-derive"] = { "napi" }, ["async-recursion"] = { "async_recursion" } } },
          },
        },
      })

      -- --------------------------------------------------------
      -- TeX / LaTeX — texlab
      -- --------------------------------------------------------
      lspconfig.texlab.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          texlab = {
            auxDirectory = ".",
            bibtexFormatter = "texlab",
            build = {
              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
              executable = "latexmk",
              forwardSearchAfter = false,
              onSave = false,
            },
            chktex = { onEdit = false, onOpenAndSave = false },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            forwardSearch = { args = {} },
            latexFormatter = "latexindent",
            latexindent = { modifyLineBreaks = false },
          },
        },
      })

      -- --------------------------------------------------------
      -- Python — pyright
      -- --------------------------------------------------------
      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })

      -- --------------------------------------------------------
      -- Julia — julials (requires Julia + LanguageServer.jl installed)
      -- Start with: julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
      -- --------------------------------------------------------
      lspconfig.julials.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          julia = {
            symbolCacheDownload = true,
            enableCrashReporter = false,
            lint = {
              run = true,
              missingrefs = "all",
              iter = true,
              lazy = true,
              modname = true,
            },
          },
        },
      })
    end,
  },

  -- ============================================================
  -- Completion engine
  -- ============================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- VSCode-like icons for completion kinds
      local kind_icons = {
        Text          = "󰉿",
        Method        = "󰆧",
        Function      = "󰊕",
        Constructor   = "",
        Field         = "󰜢",
        Variable      = "󰀫",
        Class         = "󰠱",
        Interface     = "",
        Module        = "",
        Property      = "󰜢",
        Unit          = "󰑭",
        Value         = "󰎠",
        Enum          = "",
        Keyword       = "󰌋",
        Snippet       = "",
        Color         = "󰏘",
        File          = "󰈙",
        Reference     = "󰈇",
        Folder        = "󰉋",
        EnumMember    = "",
        Constant      = "󰏿",
        Struct        = "󰙅",
        Event         = "",
        Operator      = "󰆕",
        TypeParameter = "",
      }

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          -- Tab/S-Tab to navigate completion (like VSCode)
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Enter to confirm (like VSCode)
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,  -- Only confirm explicitly selected item
          }),
          -- Ctrl+Space to trigger completion (like VSCode)
          ["<C-Space>"] = cmp.mapping.complete(),
          -- Ctrl+e to abort
          ["<C-e>"] = cmp.mapping.abort(),
          -- Scroll docs
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icon
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)
            -- Source label
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip  = "[Snippet]",
              buffer   = "[Buffer]",
              path     = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        experimental = {
          ghost_text = { hl_group = "CmpGhostText" },  -- Inline preview like Copilot
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      })

      -- Highlight for ghost text
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    end,
  },

  -- Sources (loaded as dependencies of nvim-cmp above, listed separately for clarity)
  { "hrsh7th/cmp-nvim-lsp", lazy = true },
  { "hrsh7th/cmp-buffer",   lazy = true },
  { "hrsh7th/cmp-path",     lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
  { "rafamadriz/friendly-snippets", lazy = true },
}
