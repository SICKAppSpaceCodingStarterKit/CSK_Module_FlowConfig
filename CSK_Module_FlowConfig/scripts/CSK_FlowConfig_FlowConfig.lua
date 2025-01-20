--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
-- This specific script will run in its own thread (special use case, see FlowConfig_Model.lua)
--*****************************************************************

_G.availableAPIs = require('Communication/FlowConfig/helper/checkAPIs')

require('Communication.FlowConfig.Features.FlowConfig_OnNewValue')
require('Communication.FlowConfig.Features.FlowConfig_OnExpired')
require('Communication.FlowConfig.Features.FlowConfig_ProcessLogic')
