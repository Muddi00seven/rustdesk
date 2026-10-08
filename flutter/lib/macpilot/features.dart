abstract class MacPilotFeatures {
  static const branding =
      bool.fromEnvironment('MACPILOT_BRANDING', defaultValue: true);
  static const dashboard =
      bool.fromEnvironment('MACPILOT_DASHBOARD', defaultValue: true);
  static const smartRemoteKeyboard =
      bool.fromEnvironment('SMART_REMOTE_KEYBOARD', defaultValue: true);
  static const newIpadPointer = bool.fromEnvironment('NEW_IPAD_POINTER');
  static const newReconnectUi = bool.fromEnvironment('NEW_RECONNECT_UI');
  static const macPermissionOnboarding =
      bool.fromEnvironment('MAC_PERMISSION_ONBOARDING');
}
