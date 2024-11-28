---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--**************************************************************************
-- Check if modules for selected demo flow are available
---@param demoFlow string Demo flow to load
---@return boolean modulesAvailable Status if all needed modules are available
local function checkDemoFlowModules(demoFlow)
  local modulesAvailable
  if demoFlow == 'DataProcessing' then
    local check = Script.isServedAsFunction('CSK_ResultManager.getStatusModuleActive')
    if check then
      _, modulesAvailable = Script.callFunction('CSK_ResultManager.getStatusModuleActive')
    else
      modulesAvailable = false
    end

  elseif demoFlow == 'ColorInspection' then
    local check1 = Script.isServedAsFunction('CSK_ImagePlayer.getStatusModuleActive')
    local check2 = Script.isServedAsFunction('CSK_MultiColorSelection.getStatusModuleActive')
    local check3 = Script.isServedAsFunction('CSK_MultiTCPIPClient.getStatusModuleActive')

    if check1 and check2 and check3 then
      local _, modulesAvailable1 = Script.callFunction('CSK_ImagePlayer.getStatusModuleActive')
      local _, modulesAvailable2 = Script.callFunction('CSK_MultiColorSelection.getStatusModuleActive')
      local _, modulesAvailable3 = Script.callFunction('CSK_MultiTCPIPClient.getStatusModuleActive')
      modulesAvailable = modulesAvailable1 and modulesAvailable2 and modulesAvailable3
    else
      modulesAvailable = false
    end

  elseif demoFlow == 'ImageFilter_FTP' then
    local check1 = Script.isServedAsFunction('CSK_ImagePlayer.getStatusModuleActive')
    local check2 = Script.isServedAsFunction('CSK_MultiImageFilter.getStatusModuleActive')
    local check3 = Script.isServedAsFunction('CSK_ResultManager.getStatusModuleActive')
    local check4 = Script.isServedAsFunction('CSK_FTPClient.getStatusModuleActive')

    if check1 and check2 and check3 and check4 then
      local _, modulesAvailable1 = Script.callFunction('CSK_ImagePlayer.getStatusModuleActive')
      local _, modulesAvailable2 = Script.callFunction('CSK_MultiImageFilter.getStatusModuleActive')
      local _, modulesAvailable3 = Script.callFunction('CSK_ResultManager.getStatusModuleActive')
      local _, modulesAvailable4 = Script.callFunction('CSK_FTPClient.getStatusModuleActive')
      modulesAvailable = modulesAvailable1 and modulesAvailable2 and modulesAvailable3 and modulesAvailable4
    else
      modulesAvailable = false
    end

  elseif demoFlow == 'ImageEdgeMatcher' then
    local check1 = Script.isServedAsFunction('CSK_ImagePlayer.getStatusModuleActive')
    local check2 = Script.isServedAsFunction('CSK_MultiImageFilter.getStatusModuleActive')
    local check3 = Script.isServedAsFunction('CSK_MultiImageEdgeMatcher.getStatusModuleActive')

    if check1 and check2 and check3 then
      local _, modulesAvailable1 = Script.callFunction('CSK_ImagePlayer.getStatusModuleActive')
      local _, modulesAvailable2 = Script.callFunction('CSK_MultiImageFilter.getStatusModuleActive')
      local _, modulesAvailable3 = Script.callFunction('CSK_MultiImageEdgeMatcher.getStatusModuleActive')
      modulesAvailable = modulesAvailable1 and modulesAvailable2 and modulesAvailable3
    else
      modulesAvailable = false
    end

  elseif demoFlow == 'DeepLearning' then
    local check1 = Script.isServedAsFunction('CSK_ImagePlayer.getStatusModuleActive')
    local check2 = Script.isServedAsFunction('CSK_MultiDeepLearning.getStatusModuleActive')
    local check3 = Script.isServedAsFunction('CSK_ResultManager.getStatusModuleActive')

    if check1 and check2 and check3 then
      local _, modulesAvailable1 = Script.callFunction('CSK_ImagePlayer.getStatusModuleActive')
      local _, modulesAvailable2 = Script.callFunction('CSK_MultiDeepLearning.getStatusModuleActive')
      local _, modulesAvailable3 = Script.callFunction('CSK_ResultManager.getStatusModuleActive')
      modulesAvailable = modulesAvailable1 and modulesAvailable2 and modulesAvailable3
    else
      modulesAvailable = false
    end
  else
    modulesAvailable = false
  end

  return modulesAvailable
end

return checkDemoFlowModules