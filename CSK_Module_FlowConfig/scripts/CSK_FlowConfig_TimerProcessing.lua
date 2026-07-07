_G.availableAPIs = require('Communication/FlowConfig/helper/checkAPIs')

-- Tables to hold timers and related functions
local timer = {}
local tmrFunctions = {}
local toggleStatus = {}

local tmrDelays = {}
local forwardFunctions = {}
local saveDataFunctions = {}
local tempForwardData = {}

-- Timer to wait 1 second
local tmrStartTimers = Timer.create()
tmrStartTimers:setExpirationTime(1000)
tmrStartTimers:setPeriodic(false)

local function addDelayBlock(sourceEvent, delay)
  local functionName = tostring(sourceEvent) .. '_Delay' .. tostring(delay)

  if not tmrDelays[functionName] then
    local tempDelayTmr = Timer.create()
    tempDelayTmr:setPeriodic(false)
    tempDelayTmr:setExpirationTime(delay)
    tmrDelays[functionName] = tempDelayTmr

    local isServed = Script.isServedAsEvent("CSK_FlowConfig." .. functionName)
    if not isServed then
      Script.serveEvent("CSK_FlowConfig." .. functionName, functionName, 'auto')
    end

    -- Function to save data to forward
    local function tempSaveData(data)
      if data ~= nil then
        tempForwardData[functionName] = data
      end
      tmrDelays[functionName]:start()
    end
    saveDataFunctions[functionName] = tempSaveData
    Script.register(sourceEvent, saveDataFunctions[functionName])

    -- Function to forward event with delay
    local function forwardData()
      if tempForwardData[functionName] ~= nil then
        Script.notifyEvent(functionName, tempForwardData[functionName])
      else
        Script.notifyEvent(functionName)
      end
    end
    forwardFunctions[functionName] = forwardData
    Timer.register(tmrDelays[functionName], 'OnExpired', forwardFunctions[functionName])
  end
end
Script.serveFunction('CSK_FlowConfig.addDelayBlock', addDelayBlock)

local function addTimer(value, valueType, cycleTime)
  local fullString = tostring(valueType) .. '_' .. tostring(cycleTime) .. '_' .. tostring(value)
  if not timer[fullString] then

    toggleStatus[fullString] = true
    local isServed = Script.isServedAsEvent("CSK_FlowConfig.OnExpired_" .. fullString)
    if not isServed then
      Script.serveEvent("CSK_FlowConfig.OnExpired_" .. fullString, "FlowConfig_OnExpired_" .. fullString, 'auto, int')
    end

    local tmr = Timer.create()

    if cycleTime == 0 then
      tmr:setExpirationTime(100)
      tmr:setPeriodic(false)
    else
      tmr:setExpirationTime(cycleTime)
      tmr:setPeriodic(true)
    end

    timer[fullString] = tmr

    local function tmrExpired()
      local timestamp = DateTime.getTimestamp()
      if valueType == 'STRING' then
        Script.notifyEvent('FlowConfig_OnExpired_' .. fullString, tostring(value), timestamp)
      elseif valueType == 'NUMBER' then
        Script.notifyEvent('FlowConfig_OnExpired_' .. fullString, tonumber(value), timestamp)
      elseif valueType == 'BOOL' then
        if value == 'true' then
          Script.notifyEvent('FlowConfig_OnExpired_' .. fullString, true, timestamp)
        elseif value == 'false' then
          Script.notifyEvent('FlowConfig_OnExpired_' .. fullString, false, timestamp)
        elseif value == 'toggle' then
          toggleStatus[fullString] = not toggleStatus[fullString]
          Script.notifyEvent('FlowConfig_OnExpired_' .. fullString, toggleStatus[fullString], timestamp)
        end
      end
    end
    tmrFunctions[fullString] = tmrExpired

    Timer.register(timer[fullString], "OnExpired", tmrFunctions[fullString])
  end
end
Script.serveFunction('CSK_FlowConfig.addTimer', addTimer)

--- Function to start all used timers
local function startAllTimers()
  for key, value in pairs(timer) do
    value:start()
  end
end
Timer.register(tmrStartTimers, "OnExpired", startAllTimers)

--- Function to wait 1 second after flow was loaded to start timers
local function triggerTimer()
  tmrStartTimers:start()
end
Script.register('CSK_FlowConfig.OnNewFlowConfig', triggerTimer)

--- Function to reset all old timers
local function reset()
  for key, value in pairs(timer) do
    value:stop()
    timer[key] = nil
  end
  for toggleKey, _ in pairs(toggleStatus) do
    toggleStatus[toggleKey] = nil
  end
  for key, _ in pairs(tmrDelays) do
    tmrDelays[key] = nil
    forwardFunctions[key] = nil
    saveDataFunctions[key] = nil
    tempForwardData[key] = nil
  end

  timer = {}
  toggleStatus = {}

  tmrDelays = {}
  forwardFunctions = {}
  saveDataFunctions = {}
  tempForwardData = {}

end
Script.register('CSK_FlowConfig.OnClearOldFlow', reset)
Script.register('CSK_FlowConfig.OnStopFlowConfigProviders', reset)