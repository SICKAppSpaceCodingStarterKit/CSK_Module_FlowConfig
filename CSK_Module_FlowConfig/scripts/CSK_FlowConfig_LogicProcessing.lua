_G.availableAPIs = require('Communication/FlowConfig/helper/checkAPIs')
-----------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()
-----------------------------------------------------------

local parameters = {}

local function runOperator(instance)
  local result
  if parameters[instance]['logic'] == 'EQUAL' then
    result = tostring(parameters[instance]['values']['1']) == parameters[instance]['criteria']['1']
  elseif parameters[instance]['logic'] == 'AND' then
    if type(parameters[instance]['values']['1']) == 'boolean' and type(parameters[instance]['values']['2']) == 'boolean' then
      result = parameters[instance]['values']['1'] and parameters[instance]['values']['2']
    end
  elseif parameters[instance]['logic'] == 'AND_PREV' then
    if parameters[instance]['values']['1'] ~= '' and parameters[instance]['values']['2'] ~= '' then
      if type(parameters[instance]['values']['1']) == 'boolean' and type(parameters[instance]['values']['2']) == 'boolean' then
        result = parameters[instance]['values']['1'] and parameters[instance]['values']['2']
      end
    else
      return
    end
  elseif parameters[instance]['logic'] == 'OR_PREV' then
    if parameters[instance]['values']['1'] ~= '' or parameters[instance]['values']['2'] ~= '' then
      if parameters[instance]['values']['1'] == true or parameters[instance]['values']['2'] == true then
        result = true
      elseif parameters[instance]['values']['1'] == false or parameters[instance]['values']['2'] == false then
        result = false
      end
    else
      return
    end
  elseif parameters[instance]['logic'] == 'OR' then
    if type(parameters[instance]['values']['1']) == 'boolean' and type(parameters[instance]['values']['2']) == 'boolean' then
      result = parameters[instance]['values']['1'] or parameters[instance]['values']['2']
    end
  elseif parameters[instance]['logic'] == 'INVERT' then
    if type(parameters[instance]['values']['1']) == 'boolean' then
      result = not parameters[instance]['values']['1']
    end
  elseif parameters[instance]['logic'] == 'GREATER' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] > tonumber(parameters[instance]['criteria']['1'])
    end
  elseif parameters[instance]['logic'] == 'GREATER_EQUAL' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] >= tonumber(parameters[instance]['criteria']['1'])
    end
  elseif parameters[instance]['logic'] == 'LESS' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] < tonumber(parameters[instance]['criteria']['1'])
    end
  elseif parameters[instance]['logic'] == 'LESS_EQUAL' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] <= tonumber(parameters[instance]['criteria']['1'])
    end
  elseif parameters[instance]['logic'] == 'RISING_EDGE' then
    if type(parameters[instance]['values']['1']) == 'boolean' then
      if parameters[instance]['values']['1'] == true then
        if parameters[instance]['values']['2'] == false then
          result = true
        else
          result = false
        end
        parameters[instance]['values']['2'] = true
      else
        result = false
        parameters[instance]['values']['2'] = false
      end
    end
  elseif parameters[instance]['logic'] == 'WITHIN_RANGE' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] >= tonumber(parameters[instance]['criteria']['1']) and parameters[instance]['values']['1'] <= tonumber(parameters[instance]['criteria']['2'])
    end
  elseif parameters[instance]['logic'] == 'OUT_OF_RANGE' then
    if type(parameters[instance]['values']['1']) == 'number' then
      result = parameters[instance]['values']['1'] < tonumber(parameters[instance]['criteria']['1']) or parameters[instance]['values']['1'] > tonumber(parameters[instance]['criteria']['2'])
    end
  elseif parameters[instance]['logic'] == 'CHANGED' then
    result = parameters[instance]['oldValue'] ~= parameters[instance]['values']['1']
    if result then
      parameters[instance]['oldValue'] = parameters[instance]['values']['1']
    end
  elseif parameters[instance]['logic'] == 'TO_NUMBER' then
    if tonumber(parameters[instance]['values']['1']) then
      result = true
      parameters[instance]['values']['1'] = tonumber(parameters[instance]['values']['1'])
    else
      result = false
    end
  elseif parameters[instance]['logic'] == 'TO_STRING' then
    if tostring(parameters[instance]['values']['1']) then
      result = true
      parameters[instance]['values']['1'] = tostring(parameters[instance]['values']['1'])
    else
      result = false
    end
  end

  if result == nil then
    _G.logger:warning("CSK_FlowConfig: Error within operartor")
  else
    if parameters[instance]['logic'] == 'RISING_EDGE' then
      if result == true then
        Script.notifyEvent(parameters[instance]['event'], true)
      end
    else
      Script.notifyEvent(parameters[instance]['event'], result)
    end

    if result == true then
      if parameters[instance]['logic'] == 'EQUAL' or parameters[instance]['logic'] == 'GREATER' or parameters[instance]['logic'] == 'GREATER_EQUAL' or parameters[instance]['logic'] == 'SMALLER' or parameters[instance]['logic'] == 'SMALLER_EQUAL' or parameters[instance]['logic'] == 'WITHIN_RANGE' or parameters[instance]['logic'] == 'OUT_OF_RANGE' or parameters[instance]['logic'] == 'CHANGED' or parameters[instance]['logic'] == 'TO_NUMBER' or parameters[instance]['logic'] == 'TO_STRING' then
        Script.notifyEvent(parameters[instance]['forwardEvent'], parameters[instance]['values']['1'])
      end
    end
  end

  if parameters[instance]['logic'] ~= 'AND_PREV' and parameters[instance]['logic'] ~= 'OR_PREV' then
    parameters[instance]['values']['1'] = ''
    if parameters[instance]['logic'] ~= 'RISING_EDGE' then
      parameters[instance]['values']['2'] = ''
    end
  end
end

local function checkForAllParameters(instance)
  local allExist = true
  for key, value in pairs(parameters[instance]['values']) do
    if value == nil or value == '' then
      allExist = false
    end
  end
  if allExist then
    runOperator(instance)
  else
    -- Wait for further values...
  end
end

local function addLogicBlock(instance, logic, source1, source2, criteriaA, criteriaB)

  -- Create new instance of block
  if not parameters[instance] then
    parameters[instance] = {}

    parameters[instance]['checkMultiValues'] = false

    parameters[instance]['values'] = {}
    parameters[instance]['values']['1'] = ''
    parameters[instance]['values']['2'] = ''

    if logic == 'RISING_EDGE' then
      parameters[instance]['values']['2'] = false
    end

    parameters[instance]['oldValue'] = ''

    parameters[instance]['criteria'] = {}
    parameters[instance]['criteria']['1'] = criteriaA
    parameters[instance]['criteria']['2'] = criteriaB

    parameters[instance]['eventNames'] = {}
    table.insert(parameters[instance]['eventNames'], source1 or '')
    table.insert(parameters[instance]['eventNames'], source2 or '')

    parameters[instance]['logic'] = logic
    parameters[instance]['event'] = "OnNewLogicResult_" .. tostring(instance)
    parameters[instance]['forwardEvent'] = "OnNewValueToForward_" .. tostring(instance)

    local isServed = Script.isServedAsEvent("CSK_FlowConfig." .. parameters[instance]['event'])
    if not isServed then
      Script.serveEvent("CSK_FlowConfig." .. parameters[instance]['event'], parameters[instance]['event'], 'bool')
    end
    isServed = Script.isServedAsEvent("CSK_FlowConfig." .. parameters[instance]['forwardEvent'])
    if not isServed then
      Script.serveEvent("CSK_FlowConfig." .. parameters[instance]['forwardEvent'], parameters[instance]['forwardEvent'], 'auto')
    end

  local setFunctions = {}
  for i = 1, 2 do
    local function setParameter(value)
      parameters[instance]['values'][tostring(i)] = value
      if parameters[instance]['checkMultiValues'] then
        checkForAllParameters(instance)
      else
        runOperator(instance)
      end
    end
    table.insert(setFunctions, setParameter)
  end
  parameters[instance].setFunctions = setFunctions

  if source1 ~= '' then
    Script.register(source1, parameters[instance].setFunctions[1])
  end
  if source2 ~= '' then
    if logic ~= 'AND_PREV' and logic ~= 'OR_PREV' then
      parameters[instance]['checkMultiValues'] = true
    end
    Script.register(source2, parameters[instance].setFunctions[2])
  end

  -- Instance already exists. Only extend event registration
  else
    -- Check if new sources needs to be added
    if source1 ~= '' and parameters[instance]['eventNames'][1] == '' then
      parameters[instance]['eventNames'][1] = source1
      Script.register(source1, parameters[instance].setFunctions[1])
    end
    if source2 ~= '' and parameters[instance]['eventNames'][2] == '' then
      if logic ~= 'AND_PREV' and logic ~= 'OR_PREV' then
        parameters[instance]['checkMultiValues'] = true
      end
      parameters[instance]['eventNames'][2] = source2
      Script.register(source2, parameters[instance].setFunctions[2])
    end
  end
end
Script.serveFunction('CSK_FlowConfig.addLogicBlock', addLogicBlock)

--- Function to reset all old timers
local function reset()
  for key, value in pairs(parameters) do
    if parameters[key]['eventNames'][1] and parameters[key].setFunctions[1] then
      Script.deregister(parameters[key]['eventNames'][1], parameters[key].setFunctions[1])
    end
    if parameters[key]['eventNames'][2] and parameters[key].setFunctions[2] then
      Script.deregister(parameters[key]['eventNames'][2], parameters[key].setFunctions[2])
    end
  end

  parameters = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', reset)