-- Block namespace
local BLOCK_NAMESPACE = "FlowConfig_FC.OnNewValue"
local nameOfModule = 'CSK_FlowConfig'

Script.serveEvent('CSK_FlowConfig.OnNewStatusTriggerValue', 'FlowConfig_OnNewStatusTriggerValue')

--*************************************************************
--*************************************************************

local function register(handle, _ , callback)
  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local value = Container.get(handle, 'Value')
  local valueType = Container.get(handle, 'ValueType')
  local cycleTime = Container.get(handle, 'CycleTime')

  if valueType == 'STRING' then
    Script.notifyEvent('FlowConfig_OnNewStatusTriggerValue', tostring(value), cycleTime)
  elseif valueType == 'NUMBER' then
    Script.notifyEvent('FlowConfig_OnNewStatusTriggerValue', tonumber(value), cycleTime)
  elseif valueType == 'BOOL' then
    if value == 'true' then
      Script.notifyEvent('FlowConfig_OnNewStatusTriggerValue', true, cycleTime)
    else
      Script.notifyEvent('FlowConfig_OnNewStatusTriggerValue', false, cycleTime)
    end
  end

  local function localCallback()
    if callback ~= nil then
      Script.callFunction(callback, 'CSK_FlowConfig.OnNewValue')
    else
      _G.logger:warning(nameOfModule .. ": " .. BLOCK_NAMESPACE .. ".CB_Function missing!")
    end
  end
  Script.register('CSK_FlowConfig.OnNewFlowConfig', localCallback)

  return true
end
Script.serveFunction(BLOCK_NAMESPACE ..".register", register)

--*************************************************************
--*************************************************************

local function create(value, valueType, cycleTime)
  local container = Container.create()
  Container.add(container, "CB_Function", "")

  Container.add(container, "Value", value)
  Container.add(container, "ValueType", valueType)
  Container.add(container, "CycleTime", cycleTime)
  return(container)
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)