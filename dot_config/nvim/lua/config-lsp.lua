local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

  -- Format on save if the client supports it
  if client and client.supports_method("textDocument/formatting") then
    local format_group = vim.api.nvim_create_augroup("user_lsp_format_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end

local function cfg()
  require("mason").setup()
  require("mason-lspconfig").setup()

  local lsp_servers = {
    "ansiblels",
    "basedpyright",
    "bashls",
    "dockerls",
    "dprint",
    "emmet_ls",
    "eslint",
    "gh_actions_ls",
    "gopls",
    "jsonls",
    "lua_ls",
    "powershell_es",
    "ruff",
    "solargraph",
    "terraformls",
    "tflint",
    "volar",
    "yamlls",
  }
  for _, server in ipairs(lsp_servers) do
    local opts = {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 150,
      },
    }

    if server == "lua_ls" then
      opts.settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      }
    end

    if server == "ansiblels" then
      opts.filetypes = { "yaml.ansible" }
      opts.settings = {
        ansible = {
          ansibleLint = {
            enabled = true,
            arguments = "",
          },
        },
      }
    end

    if server == "volar" then
      opts.filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" }
    end

    if server == "jsonls" then
      local ok, schemastore = pcall(require, "schemastore")
      if ok then
        opts.settings = {
          json = {
            schemas = schemastore.json.schemas(),
            validate = { enable = true },
          },
        }
      end
    end

    if server == "yamlls" then
      local ok, schemastore = pcall(require, "schemastore")
      if ok then
        opts.settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            schemas = schemastore.yaml.schemas(),
            schemaStore = {
              enable = false,
              url = "",
            },
          },
        }
      end
    end

    if server == "dprint" then
      opts.filetypes = { "toml" }
    end

    vim.lsp.config(server, opts)
    vim.lsp.enable(server)
  end
end

local M = {}
M.cfg = cfg
return M
