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
tmrFlowConfig:setExpirationTime(1000)
tmrFlowConfig:setPeriodic(false)

-- Timer to update flow config for initial parameter load
local tmrFlowConfigInitialSetup = Timer.create()
tmrFlowConfigInitialSetup:setExpirationTime(200)
tmrFlowConfigInitialSetup:setPeriodic(false)

-- Timer to hide UI message
local tmrUIMessage = Timer.create()
tmrUIMessage:setExpirationTime(3000)
tmrUIMessage:setPeriodic(false)

-- Check if it was able to load demo flow
local demoFlowNotAvailable = false

-- Reference to global handle
local flowConfig_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_FlowConfig.OnExpired_TYPE_TIME_VALUE', 'FlowConfig_OnExpired_TYPE_TIME_VALUE')
Script.serveEvent('CSK_FlowConfig.OnNewLogicResult_ID', 'FlowConfig_OnNewLogicResult_ID')
Script.serveEvent('CSK_FlowConfig.OnNewValueToForward_ID', 'FlowConfig_OnNewValueToForward_ID')

Script.serveEvent('CSK_FlowConfig.OnNewStatusModuleVersion', 'FlowConfig_OnNewStatusModuleVersion')
Script.serveEvent('CSK_FlowConfig.OnNewStatusCSKStyle', 'FlowConfig_OnNewStatusCSKStyle')
Script.serveEvent('CSK_FlowConfig.OnNewStatusModuleIsActive', 'FlowConfig_OnNewStatusModuleIsActive')
Script.serveEvent('CSK_FlowConfig.OnNewStatusFlowConfigReady', 'FlowConfig_OnNewStatusFlowConfigReady')

Script.serveEvent('CSK_FlowConfig.OnNewStatusFlowActiveUIInfo', 'FlowConfig_OnNewStatusFlowActiveUIInfo')

Script.serveEvent('CSK_FlowConfig.OnNewStatusInfoToggle', 'FlowConfig_OnNewStatusInfoToggle')
Script.serveEvent('CSK_FlowConfig.OnNewStatusShowInfoOnPageReload', 'FlowConfig_OnNewStatusShowInfoOnPageReload')

Script.serveEvent('CSK_FlowConfig.OnNewStatusSaveMode', 'FlowConfig_OnNewStatusSaveMode')

Script.serveEvent('CSK_FlowConfig.OnNewStatusListOfAvailableFeatures', 'FlowConfig_OnNewStatusListOfAvailableFeatures')
Script.serveEvent('CSK_FlowConfig.OnNewStatusListOfActiveFeatures', 'FlowConfig_OnNewStatusListOfActiveFeatures')

Script.serveEvent('CSK_FlowConfig.OnNewFlowConfig', 'FlowConfig_OnNewFlowConfig')
Script.serveEvent('CSK_FlowConfig.OnClearOldFlow', 'FlowConfig_OnClearOldFlow')
Script.serveEvent('CSK_FlowConfig.OnStopFlowConfigProviders', 'FlowConfig_OnStopFlowConfigProviders')

Script.serveEvent('CSK_FlowConfig.OnNewFlow', 'FlowConfig_OnNewFlow')
Script.serveEvent('CSK_FlowConfig.OnNewManifest', 'FlowConfig_OnNewManifest')

Script.serveEvent('CSK_FlowConfig.OnNewStatusDemoFlow', 'FlowConfig_OnNewStatusDemoFlow')

Script.serveEvent('CSK_FlowConfig.OnNewStatusSaveAllModulesAvailable', 'FlowConfig_OnNewStatusSaveAllModulesAvailable')
Script.serveEvent("CSK_FlowConfig.OnNewStatusLoadParameterOnReboot", "FlowConfig_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_FlowConfig.OnPersistentDataModuleAvailable", "FlowConfig_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_FlowConfig.OnNewParameterName", "FlowConfig_OnNewParameterName")
Script.serveEvent("CSK_FlowConfig.OnDataLoadedOnReboot", "FlowConfig_OnDataLoadedOnReboot")

Script.serveEvent('CSK_FlowConfig.OnUserLevelOperatorActive', 'FlowConfig_OnUserLevelOperatorActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelMaintenanceActive', 'FlowConfig_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelServiceActive', 'FlowConfig_OnUserLevelServiceActive')
Script.serveEvent('CSK_FlowConfig.OnUserLevelAdminActive', 'FlowConfig_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************
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

  if demoFlowNotAvailable then
    demoFlowNotAvailable = false
    Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'error')
  else
    Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'empty')
  end
  Script.notifyEvent("FlowConfig_OnNewStatusModuleVersion", 'v' .. flowConfig_Model.version)
  Script.notifyEvent("FlowConfig_OnNewStatusCSKStyle", flowConfig_Model.styleForUI)
  Script.notifyEvent("FlowConfig_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  Script.notifyEvent("FlowConfig_OnNewStatusListOfAvailableFeatures", flowConfig_Model.helperFuncs.createJsonList(flowConfig_Model.availableFeatures))
  Script.notifyEvent("FlowConfig_OnNewStatusListOfActiveFeatures", flowConfig_Model.helperFuncs.createJsonList(flowConfig_Model.parameters.activeFlowConfigFeatures))

  Script.notifyEvent("FlowConfig_OnNewStatusSaveMode", flowConfig_Model.saveMode)

  Script.notifyEvent("FlowConfig_OnNewManifest", flowConfig_Model.manifest)
  Script.notifyEvent("FlowConfig_OnNewFlow", flowConfig_Model.parameters.flow)

  Script.notifyEvent("FlowConfig_OnNewStatusDemoFlow", flowConfig_Model.demoFlow)

  Script.notifyEvent("FlowConfig_OnNewStatusSaveAllModulesAvailable", flowConfig_Model.saveAllPersistentDataAvailable)
  Script.notifyEvent("FlowConfig_OnNewStatusLoadParameterOnReboot", flowConfig_Model.parameterLoadOnReboot)
  Script.notifyEvent("FlowConfig_OnPersistentDataModuleAvailable", flowConfig_Model.persistentModuleAvailable)
  Script.notifyEvent("FlowConfig_OnNewParameterName", flowConfig_Model.parametersName)

  Script.notifyEvent('FlowConfig_OnNewStatusShowInfoOnPageReload', flowConfig_Model.showInfoOnUI)
  Script.notifyEvent('FlowConfig_OnNewStatusInfoToggle', flowConfig_Model.showInfoOnUI)
end
Timer.register(tmrFlowConfig, "OnExpired", handleOnExpiredTmrFlowConfig)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrFlowConfig:start()
  return ''
end
Script.serveFunction("CSK_FlowConfig.pageCalled", pageCalled)

local function handleOnExpiredUIMessage()
  Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'empty')
end
Timer.register(tmrUIMessage, 'OnExpired', handleOnExpiredUIMessage)

local function getFlow(flow)
  _G.logger:info(nameOfModule .. ": Got FlowConfig update.")

  local suc = flowConfig_Model.activateFlow(flow)

  if suc then
    flowConfig_Model.parameters.flow = flow
    Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'active')
  else
    Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'error')
  end

  tmrUIMessage:start()
end
Script.serveFunction('CSK_FlowConfig.getFlow', getFlow)

local function openUI(nameOfBlock)
  if nameOfBlock == 'FlowConfig_FC.OnExpired.OnExpired' or nameOfBlock == 'FlowConfig_FC.ProcessLogic.processLogic' then
    Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'noUI')
    tmrUIMessage:start()
  end
end
Script.serveFunction('CSK_FlowConfig.openUI', openUI)

local function setActiveFeature(featureList)
  flowConfig_Model.parameters.activeFlowConfigFeatures = {}
  flowConfig_Model.parameters.activeFlowConfigFeatures['FlowConfig'] = 'FlowConfig'
  for key, value in pairs(featureList) do
    flowConfig_Model.parameters.activeFlowConfigFeatures[value] = value
  end
  flowConfig_Model.manifest = flowConfig_Model.buildManifest()
  Script.notifyEvent("FlowConfig_OnNewManifest", flowConfig_Model.manifest)
end
Script.serveFunction('CSK_FlowConfig.setActiveFeature', setActiveFeature)

local function saveAllModuleConfigs()
  if flowConfig_Model.saveAllPersistentDataAvailable then
    _G.logger:fine(nameOfModule .. ': Trigger to save configuration of all CSK modules.')
    Script.callFunctionAsync('CSK_PersistentData.saveAllModuleConfigs')
  end
end
Script.serveFunction("CSK_FlowConfig.saveAllModuleConfigs", saveAllModuleConfigs)

local function saveFlowRelevantModuleConfigs()
  if flowConfig_Model.saveAllPersistentDataAvailable then
    _G.logger:fine(nameOfModule .. ': Trigger to save configuration of flow relevant CSK modules.')
    local usedModules = {}
    usedModules['FlowConfig'] = 'FlowConfig'
    local searchPos = 0

    while true do
      local _, pathFoud = string.find(flowConfig_Model.parameters.flow, 'path="', searchPos)
      if pathFoud then
        searchPos = pathFoud
        local endOfModule = string.find(flowConfig_Model.parameters.flow, '_FC.', searchPos)
        local check = string.find(flowConfig_Model.parameters.flow, '"', searchPos+1)
        if endOfModule then
          if endOfModule < check then
            local foundModule = string.sub(flowConfig_Model.parameters.flow, pathFoud+1, endOfModule-1)
            usedModules[foundModule] = foundModule
          end
        end
      else
        break
      end
    end
    local tempContainer = flowConfig_Model.helperFuncs.convertTable2Container(usedModules)
    Script.callFunctionAsync('CSK_PersistentData.saveAllModuleConfigs', tempContainer)
  end
end
Script.serveFunction('CSK_FlowConfig.saveFlowRelevantModuleConfigs', saveFlowRelevantModuleConfigs)

local function setSaveMode(mode)
  _G.logger:fine(nameOfModule .. ': Set save mode to: ' .. tostring(mode))
  flowConfig_Model.saveMode = mode
end
Script.serveFunction('CSK_FlowConfig.setSaveMode', setSaveMode)

local function reloadApps()
  _G.logger:info(nameOfModule .. ': Reload all apps')
  Engine.reloadApps()
end
Script.serveFunction('CSK_FlowConfig.reloadApps', reloadApps)

local function setInfoToggle(status)
  Script.notifyEvent('FlowConfig_OnNewStatusInfoToggle', status)
end
Script.serveFunction('CSK_FlowConfig.setInfoToggle', setInfoToggle)

local function setDemoFlow(flowName)
  _G.logger:fine(nameOfModule .. ': Select demo flow: ' .. tostring(flowName))
  flowConfig_Model.demoFlow = flowName
end
Script.serveFunction('CSK_FlowConfig.setDemoFlow', setDemoFlow)

local function loadDemoFlow()

  -- Check if all relevant modules of the demo flow are available
  local modulesAvailable = flowConfig_Model.helperFuncs.checkDemoFlowModules(flowConfig_Model.demoFlow)

  if modulesAvailable then

    if _G.availableAPIs.recipe then
      _G.logger:fine(nameOfModule .. ': Load demo flow')

      local demoFlowsExists = true

      if not File.exists('public/FlowConfigDemo') then
        File.mkdir('public/FlowConfigDemo')
        demoFlowsExists = false
      end
      if not File.exists('/public/FlowConfigDemo/FlowConfigDemo.bin') then
        File.copy('/resources/CSK_Module_FlowConfig/FlowConfigDemo.bin', '/public/FlowConfigDemo/FlowConfigDemo.bin')
        demoFlowsExists = false
      end

      local currentParameter = CSK_PersistentData.getCurrentParameterInfo()

      if currentParameter ~= 'public/FlowConfigDemo/FlowConfigDemo.bin' or demoFlowsExists == false then
        CSK_PersistentData.setPath('public/FlowConfigDemo/FlowConfigDemo.bin')
        CSK_PersistentData.loadContent()

      end

      CSK_RecipeManager.setParameterName('RecipeManager_FlowConfigDemoFlows')
      CSK_RecipeManager.loadParameters()

      Script.callFunctionAsync('CSK_RecipeManager.loadRecipe', flowConfig_Model.demoFlow)

    else
      _G.logger:warning(nameOfModule .. ': Modules CSK_RecipeManager / CSK_Commands / CSK_PersistentData needed. Not able to load DemoFlows.')
    end
  else
    _G.logger:warning(nameOfModule .. ': Modules of selected demo flow not available on device.')
    demoFlowNotAvailable = true
  end
end
Script.serveFunction('CSK_FlowConfig.loadDemoFlow', loadDemoFlow)

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_FlowConfig.getStatusModuleActive', getStatusModuleActive)

local function stopFlowProviders()
  _G.logger:fine(nameOfModule .. ': Stop FlowConfig providers.')
  Script.notifyEvent('FlowConfig_OnStopFlowConfigProviders')
  Script.notifyEvent("FlowConfig_OnNewStatusFlowActiveUIInfo", 'stopFlowProvider')
  tmrUIMessage:start()
end
Script.serveFunction('CSK_FlowConfig.stopFlowProviders', stopFlowProviders)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  flowConfig_Model.parametersName = name
end
Script.serveFunction("CSK_FlowConfig.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if flowConfig_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(flowConfig_Model.helperFuncs.convertTable2Container(flowConfig_Model.parameters), flowConfig_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, flowConfig_Model.parametersName, flowConfig_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send FlowConfig parameters with name '" .. flowConfig_Model.parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end

  --[[
  -- Only for developing process
  if not File.exists('public/FlowData/') then
    File.mkdir('public/FlowData')
  end
  local flowFile = File.open('public/FlowData/' .. flowConfig_Model.parametersName .. '.flow', 'wb')
  File.write(flowFile, flowConfig_Model.parameters.flow)
  File.close(flowFile)
  ]]
end
Script.serveFunction("CSK_FlowConfig.sendParameters", sendParameters)

local function loadParameters()
  if flowConfig_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(flowConfig_Model.parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      flowConfig_Model.parameters = flowConfig_Model.helperFuncs.convertContainer2Table(data)
      flowConfig_Model.parameters = flowConfig_Model.helperFuncs.checkParameters(flowConfig_Model.parameters, flowConfig_Model.helperFuncs.defaultParameters.getParameters())
      flowConfig_Model.manifest = flowConfig_Model.buildManifest()

      -- If something needs to be configured/activated with new loaded data, place this here:
      if flowConfig_Model.parameters.flow ~= nil and flowConfig_Model.parameters.flow ~= '' then
        flowConfig_Model.activateFlow(flowConfig_Model.parameters.flow)
      end

      CSK_FlowConfig.pageCalled()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    return false
  end
end
Script.serveFunction("CSK_FlowConfig.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  flowConfig_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("FlowConfig_OnNewStatusLoadParameterOnReboot", flowConfig_Model.parameterLoadOnReboot)
end
Script.serveFunction("CSK_FlowConfig.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      flowConfig_Model.persistentModuleAvailable = false
    else

      local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

      if parameterName then
        flowConfig_Model.parametersName = parameterName
        flowConfig_Model.parameterLoadOnReboot = loadOnReboot
      end

      tmrFlowConfigInitialSetup:start()

    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

--- Function to trigger FlowConfig setup 100ms after initial load of persistent parameters
local function handleOnExpiredInitialSetupTimer()
  if flowConfig_Model.parameterLoadOnReboot then
    loadParameters()
  end
  Script.notifyEvent('FlowConfig_OnDataLoadedOnReboot')
end
Timer.register(tmrFlowConfigInitialSetup, 'OnExpired', handleOnExpiredInitialSetupTimer)

local function getParameters()
  return flowConfig_Model.helperFuncs.json.encode(flowConfig_Model.parameters)
end
Script.serveFunction('CSK_FlowConfig.getParameters', getParameters)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    flowConfig_Model.currentFlow = Flow.create()
    pageCalled()
  end
end
Script.serveFunction('CSK_FlowConfig.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

local function saveConfigViaUI()
  if flowConfig_Model.saveMode == 'MODULE' then
    sendParameters()
  elseif flowConfig_Model.saveMode == 'FLOW' then
    saveFlowRelevantModuleConfigs()
  elseif flowConfig_Model.saveMode == 'ALL' then
    saveAllModuleConfigs()
  end
end
Script.serveFunction('CSK_FlowConfig.saveConfigViaUI', saveConfigViaUI)

local function setShowImportantInformation(status)
  flowConfig_Model.showInfoOnUI = status
  Parameters.set('FlowConfig_ShowImportantInformation', status)
end
Script.serveFunction('CSK_FlowConfig.setShowImportantInformation', setShowImportantInformation)

return setFlowConfig_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

