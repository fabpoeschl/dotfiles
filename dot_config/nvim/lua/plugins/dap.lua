return {
  -- Core DAP client
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI panels (scopes, breakpoints, watches, call stack, REPL, console)
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>di", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
          { "<leader>de", function() require("dapui").eval() end, desc = "Eval expression", mode = { "n", "v" } },
        },
        config = function()
          local dapui = require("dapui")
          dapui.setup({
            layouts = {
              {
                elements = {
                  { id = "scopes", size = 0.35 },
                  { id = "breakpoints", size = 0.15 },
                  { id = "stacks", size = 0.25 },
                  { id = "watches", size = 0.25 },
                },
                position = "left",
                size = 50,
              },
              {
                elements = {
                  { id = "repl", size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                position = "bottom",
                size = 12,
              },
            },
          })

          -- Auto open/close UI when debug session starts/ends
          local dap = require("dap")
          dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
          dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
          dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
        end,
      },

      -- Inline variable values next to code
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = { commented = true },
      },

      -- Auto-install debug adapters via Mason. Keys are mason-nvim-dap
      -- adapter aliases ("python" -> debugpy, "js" -> js-debug-adapter).
      -- Ruby uses rdbg from the `debug` gem (installed via `bundle install`),
      -- which is not a mason package, so it is intentionally absent here.
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
          ensure_installed = { "python", "js" },
          automatic_installation = true,
        },
      },
    },

    keys = {
      -- Stepping
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Continue / Start" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step out" },

      -- Breakpoints
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log: ")) end, desc = "Log point" },

      -- Session control
      { "<leader>dx", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dq", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },

      -- REPL
      { "<leader>do", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },

      -- Run to cursor
      { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to cursor" },

      -- Hover (inspect variable)
      { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover variable", mode = { "n", "v" } },
    },

    config = function()
      local dap = require("dap")

      -- Default remote workspace root for "Attach remote" configs. Override
      -- per project by setting `vim.g.dap_remote_root = "/srv/app"` (or
      -- whatever the container uses) in a .nvim.lua at the project root —
      -- requires `:trust` on first encounter.
      local function remote_root() return vim.g.dap_remote_root or "/app" end

      -- Gutter signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◇", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", linehl = "", numhl = "" })

      -- Highlight for the stopped line
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e4034" })

      -- =====================================================================
      -- Python (debugpy)
      -- =====================================================================
      dap.adapters.python = function(cb, config)
        if config.request == "attach" then
          cb({
            type = "server",
            host = config.connect.host or "127.0.0.1",
            port = config.connect.port or 5678,
          })
        else
          cb({
            type = "executable",
            command = "debugpy-adapter",
          })
        end
      end

      dap.configurations.python = {
        {
          name = "Launch file",
          type = "python",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          name = "Launch with arguments",
          type = "python",
          request = "launch",
          program = "${file}",
          args = function()
            local input = vim.fn.input("Arguments: ")
            return vim.split(input, " ", { trimempty = true })
          end,
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
        {
          name = "Attach remote (localhost:5678)",
          type = "python",
          request = "attach",
          connect = { host = "127.0.0.1", port = 5678 },
          pathMappings = {
            { localRoot = "${workspaceFolder}", remoteRoot = remote_root },
          },
        },
        {
          name = "Attach remote (custom host:port)",
          type = "python",
          request = "attach",
          connect = {
            host = function() return vim.fn.input("Host: ", "127.0.0.1") end,
            port = function() return tonumber(vim.fn.input("Port: ", "5678")) end,
          },
          pathMappings = {
            {
              localRoot = "${workspaceFolder}",
              remoteRoot = function() return vim.fn.input("Remote path: ", remote_root()) end,
            },
          },
        },
      }

      -- =====================================================================
      -- JavaScript / TypeScript (js-debug-adapter via vscode-js-debug)
      -- =====================================================================
      for _, adapter in ipairs({ "pwa-node", "pwa-chrome" }) do
        dap.adapters[adapter] = {
          type = "server",
          host = "localhost",
          port = "${port}",
          executable = {
            command = "js-debug-adapter",
            args = { "${port}" },
          },
        }
      end

      for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[lang] = {
          {
            name = "Launch file (Node)",
            type = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
          },
          {
            name = "Attach to Node (localhost:9229)",
            type = "pwa-node",
            request = "attach",
            port = 9229,
            cwd = "${workspaceFolder}",
            localRoot = "${workspaceFolder}",
            remoteRoot = remote_root,
            restart = true,
          },
          {
            name = "Attach to Node (custom host:port)",
            type = "pwa-node",
            request = "attach",
            address = function() return vim.fn.input("Host: ", "127.0.0.1") end,
            port = function() return tonumber(vim.fn.input("Port: ", "9229")) end,
            cwd = "${workspaceFolder}",
            localRoot = "${workspaceFolder}",
            remoteRoot = function() return vim.fn.input("Remote path: ", remote_root()) end,
            restart = true,
          },
          {
            name = "Launch Chrome",
            type = "pwa-chrome",
            request = "launch",
            url = function() return vim.fn.input("URL: ", "http://localhost:3000") end,
            webRoot = "${workspaceFolder}",
          },
        }
      end

      -- =====================================================================
      -- Ruby (rdbg / debug.gem)
      -- =====================================================================
      dap.adapters.ruby = function(cb, config)
        if config.request == "attach" then
          cb({
            type = "server",
            host = config.server or "127.0.0.1",
            port = config.port or 1234,
          })
        else
          cb({
            type = "executable",
            command = "rdbg",
            args = { "-n", "--open", "--port", config.port or "1234", "-c", "--", config.command or "ruby", config.script },
          })
        end
      end

      dap.configurations.ruby = {
        {
          name = "Launch file",
          type = "ruby",
          request = "launch",
          command = "ruby",
          script = "${file}",
        },
        {
          name = "Launch with bundler",
          type = "ruby",
          request = "launch",
          command = "bundle",
          script = "exec ruby ${file}",
        },
        {
          name = "Launch Rails server",
          type = "ruby",
          request = "launch",
          command = "bundle",
          script = "exec rails server",
        },
        {
          name = "Launch RSpec (current file)",
          type = "ruby",
          request = "launch",
          command = "bundle",
          script = "exec rspec ${file}",
        },
        {
          name = "Attach remote (localhost:1234)",
          type = "ruby",
          request = "attach",
          server = "127.0.0.1",
          port = 1234,
          localfs = true,
        },
        {
          name = "Attach remote (custom host:port)",
          type = "ruby",
          request = "attach",
          server = function() return vim.fn.input("Host: ", "127.0.0.1") end,
          port = function() return tonumber(vim.fn.input("Port: ", "1234")) end,
          localfs = true,
        },
      }
    end,
  },
}
