-- Block namespace
local BLOCK_NAMESPACE = "FlowConfig_FC.OnExpired"
local nameOfModule = 'CSK_FlowConfig'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local value = Container.get(handle, 'Value')
  local valueType = Container.get(handle, 'ValueType')
  local cycleTime = Container.get(handle, 'CycleTime')

  CSK_FlowConfig.addTimer(value, valueType, cycleTime)

  local function localCallback()
    if callback ~= nil then
      Script.callFunction(callback, 'CSK_FlowConfig.OnExpired_' .. tostring(valueType) .. '_' .. tostring(cycleTime) .. '_' .. tostring(value))
      --print('CSK_FlowConfig.OnExpired_' .. tostring(valueType) .. '_' .. tostring(cycleTime) .. '_' .. tostring(value))
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

local function create(cycleTime, valueType, value)
  local fullInstanceName = tostring(valueType) .. '_' .. tostring(cycleTime) .. '_' .. tostring(value)

  -- Check if same instance is already configured
  if nil ~= instanceTable[fullInstanceName] then
    _G.logger:warning(nameOfModule .. ": Timer already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'Value', value)
    Container.add(handle, 'ValueType', valueType)
    Container.add(handle, 'CycleTime', cycleTime)
    Container.add(handle, "CB_Function", "")
    return(handle)
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. ".create", create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)