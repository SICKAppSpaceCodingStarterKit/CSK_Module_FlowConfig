---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the FlowConfig_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_FlowConfig'

-- Timer to update UI via events after page was loaded
local tmrFlowConfig = Timer.create()
tmrFlowConfig:setExpirationTime(300)
tmrFlowConfig:setPeriodic(false)

-- Reference to global handle
local flowConfig_Model

-- ************************ UI Events Start ********************************

-- Script.serveEvent("CSK_FlowConfig.OnNewEvent", "FlowConfig_OnNewEvent")
Script.serveEvent("CSK_FlowConfig.OnNewStatusLoadParameterOnReboot", "FlowConfig_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_FlowConfig.OnPersistentDataModuleAvailable", "FlowConfig_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_FlowConfig.OnNewParameterName", "FlowConfig_OnNewParameterName")
Script.serveEvent("CSK_FlowConfig.OnDataLoadedOnReboot", "FlowConfig_OnDataLoadedOnReboot")

Script.serveEvent('CSK_FlowConfig.OnUserLevelOperatorActive', 'FlowConfig_OnUserLevelOperatorActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelMaintenanceActive', 'FlowConfig_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelServiceActive', 'FlowConfig_OnUserLevelServiceActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelAdminActive', 'FlowConfig_OnUserLevelAdminActive')

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("FlowConfig_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("FlowConfig_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("FlowConfig_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("FlowConfig_OnUserLevelAdminActive", status)
end

--- Function to get access to the flowConfig_Model object
---@param handle handle Handle of flowConfig_Model object
local function setFlowConfig_Model_Handle(handle)
  flowConfig_Model = handle
  if flowConfig_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if flowConfig_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("FlowConfig_OnUserLevelAdminActive", true)
    Script.notifyEvent("FlowConfig_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("FlowConfig_OnUserLevelServiceActive", true)
    Script.notifyEvent("FlowConfig_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrFlowConfig()

  updateUserLevel()

  -- Script.notifyEvent("FlowConfig_OnNewEvent", false)

  Script.notifyEvent("FlowConfig_OnNewStatusLoadParameterOnReboot", flowConfig_Model.parameterLoadOnReboot)
  Script.notifyEvent("FlowConfig_OnPersistentDataModuleAvailable", flowConfig_Model.persistentModuleAvailable)
  Script.notifyEvent("FlowConfig_OnNewParameterName", flowConfig_Model.parametersName)
  -- ...
end
Timer.register(tmrFlowConfig, "OnExpired", handleOnExpiredTmrFlowConfig)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrFlowConfig:start()
  return ''
end
Script.serveFunction("CSK_FlowConfig.pageCalled", pageCalled)

--[[
local function setSomething(value)
  _G.logger:info(nameOfModule .. ": Set new value = " .. value)
  flowConfig_Model.varA = value
end
Script.serveFunction("CSK_FlowConfig.setSomething", setSomething)
]]

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:info(nameOfModule .. ": Set parameter name: " .. tostring(name))
  flowConfig_Model.parametersName = name
end
Script.serveFunction("CSK_FlowConfig.setParameterName", setParameterName)

local function sendParameters()
  if flowConfig_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(flowConfig_Model.helperFuncs.convertTable2Container(flowConfig_Model.parameters), flowConfig_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, flowConfig_Model.parametersName, flowConfig_Model.parameterLoadOnReboot)
    _G.logger:info(nameOfModule .. ": Send FlowConfig parameters with name '" .. flowConfig_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_FlowConfig.sendParameters", sendParameters)

local function loadParameters()
  if flowConfig_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(flowConfig_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      flowConfig_Model.parameters = flowConfig_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_FlowConfig.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_FlowConfig.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  flowConfig_Model.parameterLoadOnReboot = status
  _G.logger:info(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_FlowConfig.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    flowConfig_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      flowConfig_Model.parametersName = parameterName
      flowConfig_Model.parameterLoadOnReboot = loadOnReboot
    end

    if flowConfig_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('FlowConfig_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setFlowConfig_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

