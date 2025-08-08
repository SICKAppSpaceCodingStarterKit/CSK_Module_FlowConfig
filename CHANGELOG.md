# Changelog
All notable changes to this project will be documented in this file.

## Release 1.3.1

### Bugfixes
- Minor UI edits

## Release 1.3.0

### New features
- New logic 'RISING_EDGE' available within logic block

### Improvement
- Full UI usable via iFrame in other SensorApps
- Include all internal blocks to show info that no extra UI exists

### Bugfixes
- Legacy bindings of ValueDisplay elements within UI did not work if deployed with VS Code AppSpace SDK
- UI differs if deployed via Appstudio or VS Code AppSpace SDK
- Fullscreen icon was visible within iFrame
- Button for unsupported "Global parameters" was visible
- Manifest check was not compatible with VS Code AppSpacek SDK
- UI Bindings did not work with HTTPS

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