-- Block namespace
local BLOCK_NAMESPACE = 'FlowConfig_FC.NotifyEvent'
local nameOfModule = 'CSK_FlowConfig'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}
local internalFunctions = {}

local function notifyEvent(handle, source)

  -- Optionally check for specific parameter
  local eventName = Container.get(handle, 'EventName')

  -- Check incoming value
  if source then
    local function forwardData(data1, data2, data3, data4)
      if data1 ~= nil and data2 ~= nil and data3 ~= nil and data4 ~= nil then
        Script.notifyEvent('FlowConfig_' .. eventName, data1, data2, data3, data4)
      elseif data1 ~= nil and data2 ~= nil and data3 ~= nil then
        Script.notifyEvent('FlowConfig_' .. eventName, data1, data2, data3)
      elseif data1 ~= nil and data2 ~= nil then
        Script.notifyEvent('FlowConfig_' .. eventName, data1, data2)
      elseif data1 ~= nil then
        Script.notifyEvent('FlowConfig_' .. eventName, data1)
      end
    end
    if not Script.isServedAsEvent('CSK_FlowConfig.' .. tostring(eventName)) then
      Script.serveEvent('CSK_FlowConfig.' .. tostring(eventName), 'FlowConfig_' .. eventName, 'auto:[?*],auto:[?*],auto:[?*],auto:[?*]')
    end
    internalFunctions[source] = forwardData
    Script.register(source, internalFunctions[source])
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.notifyEvent', notifyEvent)

--*************************************************************
--*************************************************************

local function create(eventName)

  -- Check for multiple instances if same instance is already configured
  if instanceTable[eventName] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[eventName] = eventName
    Container.add(handle, 'EventName', eventName)

    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  for key, value in pairs(internalFunctions) do
    Script.deregister(key, internalFunctions[key])
  end
  Script.releaseObject(instanceTable)
  Script.releaseObject(internalFunctions)
  instanceTable = {}
  internalFunctions = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)