-- Block namespace
local BLOCK_NAMESPACE = "FlowConfig_FC.OnEvent"
local nameOfModule = 'CSK_FlowConfig'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function register(handle, _ , callback)

  Container.remove(handle, "CB_Function")
  Container.add(handle, "CB_Function", callback)

  local eventName = Container.get(handle, 'EventName')

  local function localCallback()
    if callback ~= nil then
      Script.callFunction(callback, eventName)
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

local function create(eventName)

  -- Check if same instance is already configured
  if nil ~= instanceTable[eventName] then
    _G.logger:warning(nameOfModule .. ": Timer already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[eventName] = eventName
    Container.add(handle, 'EventName', eventName)
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