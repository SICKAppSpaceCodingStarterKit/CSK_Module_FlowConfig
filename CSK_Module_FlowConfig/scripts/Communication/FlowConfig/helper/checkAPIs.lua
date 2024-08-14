---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- Load all relevant APIs for this module
--**************************************************************************

local availableAPIs = {}

-- Function to load all default APIs
local function loadAPIs()
  CSK_FlowConfig = require 'API.CSK_FlowConfig'

  Log = require 'API.Log'
  Log.Handler = require 'API.Log.Handler'
  Log.SharedLogger = require 'API.Log.SharedLogger'

  Container = require 'API.Container'
  DateTime = require 'API.DateTime'
  Engine = require 'API.Engine'
  File = require 'API.File'
  Object = require 'API.Object'
  Timer = require 'API.Timer'

  -- Check if related CSK modules are available to be used
  local appList = Engine.listApps()
  for i = 1, #appList do
    if appList[i] == 'CSK_Module_PersistentData' then
      CSK_PersistentData = require 'API.CSK_PersistentData'
    elseif appList[i] == 'CSK_Module_UserManagement' then
      CSK_UserManagement = require 'API.CSK_UserManagement'
    end
  end
end

-- Function to load specific APIs
local function loadSpecificAPIs()
  -- If you want to check for specific APIs/functions supported on the device the module is running, place relevant APIs here
  Flow = require 'API.Flow'
end

-- Function to check for CSK_RecipeManager feature
local function loadRecipeAPIs()
  CSK_RecipeManager = require 'API.CSK_RecipeManager'
  CSK_Commands = require 'API.CSK_Commands'
  CSK_PersistentData = require 'API.CSK_PersistentData'
end

availableAPIs.default = xpcall(loadAPIs, debug.traceback) -- TRUE if all default APIs were loaded correctly
availableAPIs.specific = xpcall(loadSpecificAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly
availableAPIs.recipe = xpcall(loadRecipeAPIs, debug.traceback) -- TRUE if all specific APIs were loaded correctly

return availableAPIs
--**************************************************************************