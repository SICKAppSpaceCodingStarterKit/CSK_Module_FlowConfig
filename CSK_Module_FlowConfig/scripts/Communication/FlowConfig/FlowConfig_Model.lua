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
flowConfig_Model.saveAllPersistentDataAvailable = false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
flowConfig_Model.parametersName = 'CSK_FlowConfig_Parameter' -- name of parameter dataset to be used for this module
flowConfig_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load FlowConfig relevant features
-- Needs to be in its own thread as otherwise it will block the Flow.start process in this module
Script.startScript('CSK_FlowConfig_FlowConfig')
-- Load script for timer blocks
Script.startScript('CSK_FlowConfig_TimerProcessing')
-- Load script for logic blocks
Script.startScript('CSK_FlowConfig_LogicProcessing')

-- Load script to communicate with the FlowConfig_Model interface and give access
-- to the FlowConfig_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setFlowConfig_ModelHandle = require('Communication/FlowConfig/FlowConfig_Controller')
setFlowConfig_ModelHandle(flowConfig_Model)

--Loading helper functions if needed
flowConfig_Model.helperFuncs = require('Communication/FlowConfig/helper/funcs')

-- Create parameters / instances for this module
if _G.availableAPIs.specific == true then
  flowConfig_Model.currentFlow = Flow.create()
end
flowConfig_Model.showInfoOnUI = Parameters.get('FlowConfig_ShowImportantInformation') -- Show information about FlowConfig at UI page reload
flowConfig_Model.flowPath = "private/flow.dflow" -- Path to flow file
flowConfig_Model.manifest = '' -- Created manifest of features to provide within BlocksEditor by other CSK modules
flowConfig_Model.triggerValue = '' -- Value to notify within 'OnNewStatusTriggerValue' event
flowConfig_Model.demoFlow = '' -- Selected DemoFlow to load
flowConfig_Model.styleForUI = 'None' -- Optional parameter to set UI style
flowConfig_Model.version = Engine.getCurrentAppVersion() -- Version of module
flowConfig_Model.saveMode = 'MODULE' -- Method to save if 'Save' button is pressed: 'MODULE', 'FLOW', 'ALL'

-- Parameters to be saved permanently if wanted
flowConfig_Model.parameters = {}
flowConfig_Model.parameters.flow = '' -- FlowConfig data

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  flowConfig_Model.styleForUI = theme
  Script.notifyEvent("FlowConfig_OnNewStatusCSKStyle", flowConfig_Model.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

-- Building manifest file for editor based on snippets retrieved from the engine for every served block which
-- should be available in the editor
---@return string manifest Manifest information of provided FlowConfig features
local function buildManifest()

  local usedEnums = {}

  local manifest = '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n'
  manifest = manifest .. '    <manifest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"Manifest.mf.xsd\">\n'
  manifest = manifest .. '        <application name=\"' .. nameOfModule .. '"\">\n'

  -- Get available CROWNs
  local flowCrowns = Engine.getCrowns()
  for key, value in pairs(flowCrowns) do

    -- Check if CROWN is relevant for module links
    local _, posSubCrown = string.find(value, '_FC.')
    local _, posMainCrown = string.find(value, '_FC')

    if posMainCrown == #value or posSubCrown then
      local crownName = string.sub(value, 1, posMainCrown)
      local moduleNameToCheck = 'CSK_' .. string.sub(crownName, 1, #crownName-3) .. '.getStatusModuleActive'

      local _, moduleStatus = Script.callFunction(moduleNameToCheck) -- check if module is active on device
      local content = Engine.getCrownAsXML(value)

      if content then

        if moduleStatus == nil or moduleStatus == true then

          if crownName ~= value then
            -- Create CROWN entry in manifest
            manifest = manifest .. '            <crown name=\"' .. crownName .. '\"><keywords>$ConfigUIAvailable$</keywords><serves/>\n'
            manifest = manifest .. '                ' .. content .. '\n'
          else
            local _, firstPartPos = string.find(content, '>')
            if firstPartPos then
              local firstPart = string.sub(content, 1, firstPartPos)
              local lastPart = string.sub(content, firstPartPos+1, #content)
              local newContent = firstPart .. '<keywords>$ConfigUIAvailable$</keywords>' .. lastPart
              manifest = manifest .. '                ' .. newContent .. '\n'
            end
          end
        else
          --break
        end

        ---------------- ENUM check ----------------
        -- Check if ENUMs are used within the used parameters to add them later on
        local startPos = 0

        while true do
          local _, enumPos = string.find(content, 'type="enum"', startPos)

          if enumPos then
            local _, refPos = string.find(content, 'ref="', startPos)

            if refPos then
              local endPos = string.find(content, '"', refPos+1)

              if endPos then

                local result = string.sub(content, refPos+1, endPos-1)
                local enumSeperator = string.find(result, '%.')

                if enumSeperator then
                  local enumCrown = string.sub(result, 1, enumSeperator-1)
                  local enumName = string.sub(result, enumSeperator+1, #result)

                  -- Collect ENUMs to add them later
                  if not usedEnums[enumCrown] then
                    usedEnums[enumCrown] = {}
                  end

                  if not usedEnums[enumCrown][enumName] then
                    usedEnums[enumCrown][enumName] = enumName
                  end
                end
              end
            end
            if enumPos > refPos then
              startPos = enumPos + 1
            else
              startPos = refPos + 1
            end
          else
            break
          end
        end
      end

      if crownName ~= value then
        manifest = manifest .. '        </crown>\n'
      end

    end
  end

  -- Add collected ENUMs in manifest
  for crownNameOfEnums, _ in pairs(usedEnums) do
    local manifestString = '        <crown name="' .. crownNameOfEnums ..'">\n            <trait>released</trait>\n'

    for enumInCrown, _ in pairs(usedEnums[crownNameOfEnums]) do
      local enumValues = {}
      enumValues = Engine.getEnumValues(crownNameOfEnums .. '.' .. enumInCrown)

      if enumValues == nil or #enumValues == 0 then
        local checkFC = string.find(crownNameOfEnums, '_FC')
        if checkFC then
          enumValues = Engine.getEnumValues(enumInCrown)
        end
      end

      if enumValues then
        manifestString = manifestString .. '            <enum name="' .. enumInCrown .. '" trait="released">\n'
        for _, enum in ipairs(enumValues) do
          manifestString = manifestString .. '                <item name="' .. enum .. '">' .. enum .. '</item>\n'
        end
        manifestString = manifestString .. '            </enum>\n'
      end
    end
    manifestString = manifestString .. '        </crown>\n'
    manifest = manifest .. manifestString
  end

  manifest = manifest .. '    </application>\n'
  manifest = manifest .. '</manifest>'

  return manifest
end
flowConfig_Model.buildManifest = buildManifest

--- Function to react on new FlowConfig setup
---@param flow string Flow configuration to activate
---@return bool? suc Success to activate flow
local function activateFlow(flow)

  _G.logger:fine(nameOfModule .. ": Clear old FlowConfig!")
  Script.notifyEvent('FlowConfig_OnClearOldFlow')


  local fl = File.open(flowConfig_Model.flowPath, "wb")
  fl:write(flow)
  fl:close()

  local success = flowConfig_Model.currentFlow:load(flowConfig_Model.flowPath)

  if success then

    success = flowConfig_Model.currentFlow:start()

    _G.logger:fine(nameOfModule .. ": FlowConfig triggered! Success: " .. tostring(success))
    if success then
      Script.notifyEvent('FlowConfig_OnNewFlowConfig')
      return true
    else
      _G.logger:warning(nameOfModule .. ": Not able to start FlowConfig!")
      return nil
    end
  else
    _G.logger:warning(nameOfModule .. ": Not able to start FlowConfig!")
    return nil
  end
end
flowConfig_Model.activateFlow = activateFlow

-- Function to check if CSK_Module_PersistentData is available and up to date to trigger all modules to save data
local function checkForSaveAllConfigFeature()
  if flowConfig_Model.persistentModuleAvailable then
    local moduleVersion = CSK_PersistentData.getVersion()
    local majorVersion = tonumber(string.sub(moduleVersion, 1, 1))
    local minorVersion = tonumber(string.sub(moduleVersion, 3, 3))

    if majorVersion == 4 and minorVersion >= 1 or majorVersion > 4 then
      flowConfig_Model.saveAllPersistentDataAvailable = true
    end
  end
end
flowConfig_Model.checkForSaveAllConfigFeature = checkForSaveAllConfigFeature

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return flowConfig_Model
