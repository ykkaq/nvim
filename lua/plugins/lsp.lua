return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "rust_analyzer", "texlab", "pyright", "lua_ls" },
        automatic_installation = true,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gd",         vim.lsp.buf.definition,     vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,    vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, vim.tbl_extend("force", opts, { desc = "Go to implementation" }))
        vim.keymap.set("n", "gr",         vim.lsp.buf.references,     vim.tbl_extend("force", opts, { desc = "References" }))
        vim.keymap.set("n", "K",          vim.lsp.buf.hover,          vim.tbl_extend("force", opts, { desc = "Hover" }))
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,         vim.tbl_extend("force", opts, { desc = "Rename" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,    vim.tbl_extend("force", opts, { desc = "Code action" }))
        vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format" }))
      end

      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      lspconfig.clangd.setup({
        on_attach = on_attach, capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=detailed" },
      })

      lspconfig.rust_analyzer.setup({
        on_attach = on_attach, capabilities = capabilities,
        settings = { ["rust-analyzer"] = { checkOnSave = { command = "clippy" } } },
      })

      lspconfig.texlab.setup({ on_attach = on_attach, capabilities = capabilities })

      lspconfig.pyright.setup({
        on_attach = on_attach, capabilities = capabilities,
        settings = { python = { analysis = { typeCheckingMode = "basic" } } },
      })

      lspconfig.lua_ls.setup({
        on_attach = on_attach, capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- Julia: requires julia -e 'using Pkg; Pkg.add("LanguageServer")'
      lspconfig.julials.setup({ on_attach = on_attach, capabilities = capabilities })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
        experimental = { ghost_text = true },
      })
    end,
  },

  { "hrsh7th/cmp-nvim-lsp",    lazy = true },
  { "hrsh7th/cmp-buffer",      lazy = true },
  { "hrsh7th/cmp-path",        lazy = true },
  { "saadparwaiz1/cmp_luasnip", lazy = true },
}
