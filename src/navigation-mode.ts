import Mx from './specs/NativeMendixNative';

export const AndroidNavigationBar = {
  height: Mx.navigationModeGetNavigationBarHeight(),
  isActive: Mx.navigationModeIsNavigationBarActive(),
};
