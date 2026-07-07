-- Block namespace
local BLOCK_NAMESPACE = 'FlowConfig_FC.Delay'
local nameOfModule = 'CSK_FlowConfig'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function delay(handle, source)

  --local instance = Container.get(handle, 'Instance')
  local delay = Container.get(handle, 'Delay')

  local functionName = tostring(source) .. '_Delay' .. tostring(delay)

  CSK_FlowConfig.addDelayBlock(source, delay)

  return 'CSK_FlowConfig.' .. functionName
end
Script.serveFunction(BLOCK_NAMESPACE .. '.delay', delay)

--*************************************************************
--*************************************************************

local function create(delay)

  local instanceNo = #instanceTable + 1

  local handle = Container.create()
  instanceTable[instanceNo] = instanceNo
  Container.add(handle, 'Instance', tostring(instanceNo))
  Container.add(handle, 'Delay', delay)
  return handle
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
