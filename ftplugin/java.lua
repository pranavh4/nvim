local home = os.getenv 'HOME'
local workspace_path = home .. '/.local/share/nvim/jdtls-workspace/'
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = workspace_path .. project_name
local jdtls_install_path = require('mason-registry').get_package('jdtls'):get_install_path()
local java_debug_install_path = require('mason-registry').get_package('java-debug-adapter'):get_install_path()
local java_test_install_path = require('mason-registry').get_package('java-test'):get_install_path()

local status, jdtls = pcall(require, 'jdtls')
if not status then
  return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities

local bundles = vim.fn.glob(java_debug_install_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', nil, true)
vim.list_extend(bundles, vim.fn.glob(java_test_install_path .. '/extension/server/*.jar', nil, true))

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',
    '-javaagent:' .. jdtls_install_path .. '/lombok.jar',
    '-jar',
    vim.fn.glob(jdtls_install_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration',
    jdtls_install_path .. '/config_linux',
    '-data',
    workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = extendedClientCapabilities,
      maven = {
        downloadSources = true,
      },
      referencesCodeLens = {
        enabled = true,
      },
      references = {
        includeDecompiledSources = true,
      },
      inlayHints = {
        parameterNames = {
          enabled = 'all', -- literals, all, none
        },
      },
      format = {
        enabled = true,
      },
    },
  },

  init_options = {
    bundles = bundles,
  },

  on_attach = function(client, _)
    vim.lsp.inlay_hint.enable()
    require('jdtls').setup_dap { hotcodereplace = 'auto' }
    require('jdtls.dap').setup_dap_main_class_configs()
  end,

  server_capabilities = { inlayHintProvider = true },

  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  },
}
require('jdtls').start_or_attach(config)
