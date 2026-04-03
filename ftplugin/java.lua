local home = os.getenv 'HOME'
local jdtls_install_path = require('mason-registry').get_package('jdtls'):get_install_path()
local java_debug_install_path = require('mason-registry').get_package('java-debug-adapter'):get_install_path()
local java_test_install_path = require('mason-registry').get_package('java-test'):get_install_path()

local status, jdtls = pcall(require, 'jdtls')
if not status then
  return
end

-- Extension bundles for debugging/testing
local bundles = vim.fn.glob(java_debug_install_path .. '/extension/server/com.microsoft.java.debug.plugin-*.jar', nil, true)
for _, jar in ipairs(vim.fn.glob(java_test_install_path .. '/extension/server/*.jar', nil, true)) do
  if not vim.endswith(jar, 'com.microsoft.java.test.runner-jar-with-dependencies.jar') and not vim.endswith(jar, 'jacocoagent.jar') then
    table.insert(bundles, jar)
  end
end

-- Detect project root
local root_dir = require('jdtls.setup').find_root { 'MODULE.bazel', 'WORKSPACE', 'WORKSPACE.bazel' }
  or require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }

local is_bazel = root_dir and (vim.uv.fs_stat(root_dir .. '/WORKSPACE') or vim.uv.fs_stat(root_dir .. '/MODULE.bazel'))

-- Workspace data directory (unique per project)
local project_name = root_dir and vim.fn.fnamemodify(root_dir, ':t') or 'default'
local workspace_dir = home .. '/.local/share/nvim/jdtls-workspace/' .. project_name

-------------------------------------------------------------------------------
-- Bazel classpath helpers
-------------------------------------------------------------------------------

-- Collect header jars from bazel-bin (internal + external deps)
local function collect_bazel_jars(root)
  local jars = {}
  local bazel_bin = vim.fn.resolve(root .. '/bazel-bin')

  -- Internal hjars
  local handle = io.popen('find ' .. bazel_bin .. ' -maxdepth 6 -name "*-hjar.jar"' .. ' -not -path "*/runfiles/*" -not -path "*/external/*"' .. ' 2>/dev/null')
  if handle then
    for jar in handle:read('*a'):gmatch '[^\n]+' do
      table.insert(jars, jar)
    end
    handle:close()
  end

  -- External header jars (in bazel-bin/external, NOT in the cache)
  handle = io.popen('find ' .. bazel_bin .. '/external -name "header_*.jar" -not -name "*sources*" 2>/dev/null')
  if handle then
    for jar in handle:read('*a'):gmatch '[^\n]+' do
      table.insert(jars, jar)
    end
    handle:close()
  end

  return jars
end

-- Collect all src/main/java and src/test/java roots, relative to root
local function collect_source_paths(root)
  local paths = {}
  local handle = io.popen(
    'find '
      .. root
      .. ' -name "*.java" -not -path "*/bazel-*" -printf "%h\\n" 2>/dev/null'
      .. " | sed 's|"
      .. root
      .. "/||'"
      .. " | sed 's|/src/main/java/.*|/src/main/java|;s|/src/test/java/.*|/src/test/java|'"
      .. ' | sort -u'
  )
  if handle then
    for dir in handle:read('*a'):gmatch '[^\n]+' do
      table.insert(paths, dir)
    end
    handle:close()
  end
  return paths
end

-------------------------------------------------------------------------------
-- Build settings
-------------------------------------------------------------------------------

local source_paths = {}
local referenced_libraries = {}

if is_bazel then
  source_paths = collect_source_paths(root_dir)
  referenced_libraries = collect_bazel_jars(root_dir)
  vim.notify(string.format('Bazel: %d source paths, %d jars', #source_paths, #referenced_libraries), vim.log.levels.INFO)
end

local project_settings = {
  sourcePaths = source_paths,
  referencedLibraries = referenced_libraries,
}

local import_exclusions = {
  '**/bazel-*/**',
  '**/bazel-bin/**',
  '**/bazel-out/**',
  '**/bazel-testlogs/**',
}

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xmx24g',
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

  root_dir = root_dir,

  settings = {
    java = {
      signatureHelp = { enabled = true },
      extendedClientCapabilities = jdtls.extendedClientCapabilities,
      import = {
        gradle = { enabled = not is_bazel },
        maven = { enabled = not is_bazel },
        exclusions = is_bazel and import_exclusions or {},
      },
      referencesCodeLens = { enabled = true },
      references = { includeDecompiledSources = true },
      inlayHints = { parameterNames = { enabled = 'all' } },
      format = { enabled = true },
      completion = { enabled = false },
      autobuild = { enabled = false },
      project = project_settings,
    },
  },

  init_options = {
    bundles = bundles,
    settings = {
      java = {
        import = {
          gradle = { enabled = not is_bazel },
          maven = { enabled = not is_bazel },
          exclusions = is_bazel and import_exclusions or {},
        },
        project = project_settings,
      },
    },
  },

  on_attach = function(client, bufnr)
    vim.lsp.inlay_hint.enable()

    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    map('gd', function()
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      client:request('textDocument/definition', params, function(err, result)
        if err then
          vim.notify('Definition error: ' .. vim.inspect(err), vim.log.levels.ERROR)
        elseif result == nil or (type(result) == 'table' and #result == 0) then
          vim.notify('No definition found', vim.log.levels.INFO)
        else
          vim.lsp.util.show_document(result[1] or result, client.offset_encoding, { focus = true })
        end
      end, bufnr)
    end, '[G]oto [D]efinition')
    map('gr', function()
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
      params.context = { includeDeclaration = true }
      client:request('textDocument/references', params, function(err, result)
        if err then
          vim.notify('References error: ' .. vim.inspect(err), vim.log.levels.ERROR)
        elseif result == nil or #result == 0 then
          vim.notify('No references found', vim.log.levels.INFO)
        else
          vim.fn.setqflist({}, ' ', {
            title = 'References',
            items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
          })
          vim.cmd 'copen'
        end
      end, bufnr)
    end, '[G]oto [R]eferences')
    map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    map('K', vim.lsp.buf.hover, 'Hover Documentation')
    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- :JdtRefresh — rescan bazel-bin and update classpath live
    if is_bazel and root_dir then
      vim.api.nvim_buf_create_user_command(bufnr, 'JdtRefresh', function()
        local old_count = #referenced_libraries
        referenced_libraries = collect_bazel_jars(root_dir)
        project_settings.referencedLibraries = referenced_libraries
        client:notify('workspace/didChangeConfiguration', {
          settings = { java = { project = project_settings } },
        })
        vim.notify(string.format('Classpath refreshed: %d jars (was %d)', #referenced_libraries, old_count), vim.log.levels.INFO)
      end, { desc = 'Refresh jdtls classpath from bazel-bin' })
    end
  end,

  server_capabilities = { inlayHintProvider = true },

  capabilities = {
    textDocument = {
      completion = {
        completionItem = { snippetSupport = true },
      },
    },
  },
}

require('jdtls').start_or_attach(config)
