local overseer = require 'overseer'
local TASK_SAVE_DIR = '~/.local/share/nvim/tasks/'

local supported_file_types = { 'java', 'python', 'javascript', 'typescript' }
local get_task_file_path = function(file_path)
  return vim.fs.joinpath(vim.fs.normalize(TASK_SAVE_DIR), string.gsub(vim.fs.normalize(file_path), '[/%.]', '_')[1])
end

local get_saved_task = function(file_path)
  local task_file = io.open(get_task_file_path(file_path), 'r')
  if not task_file then
    return {}
  end

  local ret = vim.json.decode(task_file:read '*a')
  task_file:close()
  return ret
end

local base_template = {
  params = {
    cmd = { type = 'string', order = 1 },
    cwd = { type = 'string', order = 2 },
    env = {
      type = 'list',
      optional = true,
      delimiter = ';',
      subtype = {
        type = 'list',
        delimiter = '=',
        optional = true,
        subtype = {
          type = 'string',
          optional = true,
        },
      },
      order = 3,
    },
  },
}

local save_task = function(params, file_path)
  local params_json = vim.json.encode(params)
  if vim.fn.isdirectory(TASK_SAVE_DIR) == 0 then
    vim.fn.mkdir(TASK_SAVE_DIR, 'p')
  end
  local task_file, err = io.open(get_task_file_path(file_path), 'w')
  if err or not task_file then
    vim.notify('Unable to save task. Error: ' .. vim.inspect(err), vim.log.levels.WARN)
  else
    task_file:write(params_json)
    task_file:close()
  end
end

local get_defaults = {
  java = function()
    local ret = nil
    local has_jdtls, jdtls_util = pcall(require, 'jdtls.util')
    local client = vim.lsp.get_clients({ name = 'jdtls' })[1]

    if has_jdtls and client then
      jdtls_util.with_java_executable(jdtls_util.resolve_classname(), '', function(java_exec)
        local command = java_exec or 'java'

        jdtls_util.with_classpaths(function(result)
          local classpaths = {}

          for _, path in pairs(result.classpaths) do
            if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
              table.insert(classpaths, path)
            end
          end

          if #classpaths then
            command = command .. ' -classpath ' .. table.concat(classpaths, ':') .. ' ' .. jdtls_util.resolve_classname()
          end

          local working_directory = client.config and client.config.root_dir or vim.fn.getcwd()
          ret = {
            cmd = command,
            cwd = working_directory,
          }
        end)
      end)
    else
      ret = {
        cmd = 'java ' .. vim.api.nvim_buf_get_name(0),
        cwd = vim.fn.getcwd(),
      }
    end

    vim.fn.wait(5000, function()
      return ret ~= nil
    end)
    return ret
  end,
  python = function()
    return {
      cmd = 'python ' .. vim.api.nvim_buf_get_name(0),
      cwd = vim.fn.getcwd(),
    }
  end,
  javascript = function()
    return {
      cmd = 'node ' .. vim.api.nvim_buf_get_name(0),
      cwd = vim.fn.getcwd(),
    }
  end,
}
get_defaults.typescript = get_defaults.javascript

local parse_envs = function(envs)
  local parsed_envs = {}
  if not envs or type(envs) ~= 'table' then
    return parsed_envs
  end
  for _, env in ipairs(envs) do
    if type(env) == 'table' and #env == 2 then
      parsed_envs[env[1]] = env[2]
    end
  end

  return parsed_envs
end

return {
  name = 'Run File',
  generator = function(search, cb)
    local filetype = search.filetype
    local file_path = vim.api.nvim_buf_get_name(0)
    local defaults = get_defaults[filetype]()
    local saved_params = vim.tbl_deep_extend('force', defaults, get_saved_task(file_path))
    vim.print(saved_params)
    local create_task_definition = function(params)
      params.env = parse_envs(params.env)
      return params
    end

    local ret = {}
    table.insert(
      ret,
      overseer.wrap_template(base_template, {
        name = 'Run ' .. filetype .. ' file',
        builder = function(params)
          return create_task_definition(params)
        end,
      }, defaults)
    )
    table.insert(
      ret,
      overseer.wrap_template(base_template, {
        name = 'Run ' .. filetype .. ' file (with saved params)',
        builder = function(params)
          save_task(params, file_path)
          return create_task_definition(params)
        end,
      }, saved_params)
    )
    cb(ret)
  end,
  condition = {
    filetype = supported_file_types,
  },
}
