---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()

  local flowConfigParameters = {}

  flowConfigParameters.flow = '' -- FlowConfig data
  flowConfigParameters.activeFlowConfigFeatures = {} -- Features to make available for FlowConfig
  flowConfigParameters.activeFlowConfigFeatures['FlowConfig'] = 'FlowConfig'

  return flowConfigParameters
end
functions.getParameters = getParameters

return functions