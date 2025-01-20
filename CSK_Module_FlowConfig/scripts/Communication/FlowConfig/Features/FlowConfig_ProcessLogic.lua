-- Block namespace
local BLOCK_NAMESPACE = 'FlowConfig_FC.ProcessLogic'
local nameOfModule = 'CSK_FlowConfig'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function processLogic(handle, sourceA, sourceB)

  local instance = Container.get(handle, 'Instance')
  local logic = Container.get(handle, 'Logic')
  local criteriaA = Container.get(handle, 'CriteriaA')
  local criteriaB = Container.get(handle, 'CriteriaB')

  CSK_FlowConfig.addLogicBlock(instance, logic, sourceA or '', sourceB or '', criteriaA, criteriaB)

  return 'CSK_FlowConfig.OnNewLogicResult_' .. tostring(instance), 'CSK_FlowConfig.OnNewValueToForward_' .. tostring(instance)
end
Script.serveFunction(BLOCK_NAMESPACE .. '.processLogic', processLogic)

--*************************************************************
--*************************************************************

local function create(logic, criteriaA, criteriaB)

  local instanceNo = #instanceTable + 1

  local handle = Container.create()
  instanceTable[instanceNo] = instanceNo
  Container.add(handle, 'Instance', tostring(instanceNo))
  Container.add(handle, 'Logic', logic)
  Container.add(handle, 'CriteriaA', criteriaA or '')
  Container.add(handle, 'CriteriaB', criteriaB or '')
  return handle
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
