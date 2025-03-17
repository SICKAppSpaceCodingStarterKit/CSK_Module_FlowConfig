# Changelog
All notable changes to this project will be documented in this file.

## Release 1.2.1

### Improvement
- Full UI usable via iFrame in other SensorApps
- Hide fullscreen icon within iFrame
- Include all internal blocks to show info that no extra UI exists
- Hide non used button for "Global parameters"

## Release 1.2.0

### New features
- 'OnExpired' blocks to provide, periodically triggered via events. Multiple blocks can be used. (Replaces former 'OnNewValue' block)
- Logic blocks to solve simple logic operations directly within a flow
- New event 'OnStopFlowConfigProviders' to inform other modules to stop their FlowConfig related providers, e.g. via UI button (related modules need to be updated to support this feature)

### Improvement
- App property 'LuaLoadAllEngineAPI' set to false

## Release 1.1.0

### Improvement
- New event "OnNewStatusFlowConfigReady" to state that module is ready after creating manifest for BlocksEditor (might be relevant for other modules)

## Release 1.0.0
- Initial commit