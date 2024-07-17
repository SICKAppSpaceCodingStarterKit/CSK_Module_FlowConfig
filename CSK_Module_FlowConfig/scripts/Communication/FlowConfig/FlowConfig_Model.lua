---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_FlowConfig'

local flowConfig_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
flowConfig_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
flowConfig_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
flowConfig_Model.parametersName = 'CSK_FlowConfig_Parameter' -- name of parameter dataset to be used for this module
flowConfig_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the FlowConfig_Model interface and give access
-- to the FlowConfig_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setFlowConfig_ModelHandle = require('Communication/FlowConfig/FlowConfig_Controller')
setFlowConfig_ModelHandle(flowConfig_Model)

--Loading helper functions if needed
flowConfig_Model.helperFuncs = require('Communication/FlowConfig/helper/funcs')

-- Optionally check if specific API was loaded via
--[[
if _G.availableAPIs.specific then
-- ... doSomething ...
end
]]

--[[
-- Create parameters / instances for this module
flowConfig_Model.object = Image.create() -- Use any AppEngine CROWN
flowConfig_Model.counter = 1 -- Short docu of variable
flowConfig_Model.varA = 'value' -- Short docu of variable
--...
]]

-- Parameters to be saved permanently if wanted
flowConfig_Model.parameters = {}
--flowConfig_Model.parameters.paramA = 'paramA' -- Short docu of variable
--flowConfig_Model.parameters.paramB = 123 -- Short docu of variable
--...

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--[[
-- Some internal code docu for local used function to do something
---@param content auto Some info text if function is not already served
local function doSomething(content)
  _G.logger:info(nameOfModule .. ": Do something")
  flowConfig_Model.counter = flowConfig_Model.counter + 1
end
flowConfig_Model.doSomething = doSomething
]]

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return flowConfig_Model
