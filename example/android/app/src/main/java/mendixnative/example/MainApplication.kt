package mendixnative.example

import android.app.Application
import com.facebook.react.PackageList
import com.facebook.react.ReactApplication
import com.facebook.react.ReactHost
import com.facebook.react.ReactNativeHost
import com.facebook.react.ReactPackage
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.load
import com.facebook.react.defaults.DefaultReactHost.getDefaultReactHost
import com.facebook.react.defaults.DefaultReactNativeHost
import com.facebook.react.soloader.OpenSourceMergedSoMapping
import com.facebook.soloader.SoLoader

//Start - For MendixApplication compatibility only, not part of React Native template
import com.mendix.mendixnative.MendixApplication
import com.mendix.mendixnative.react.splash.MendixSplashScreenPresenter
import com.mendix.mendixnative.react.MxConfiguration

class SplashScreenPresenter: MendixSplashScreenPresenter {
    override fun show(activity: android.app.Activity) {}
    override fun hide(activity: android.app.Activity) {}
}
//End - For MendixApplication compatibility only, not part of React Native template

class MainApplication : Application(), MendixApplication {

  override val reactNativeHost: ReactNativeHost =
      object : DefaultReactNativeHost(this) {
        override fun getPackages(): List<ReactPackage> =
            PackageList(this).packages.apply {
              // Packages that cannot be autolinked yet can be added manually here, for example:
              // add(MyReactNativePackage())
            }

        override fun getJSMainModuleName(): String = "index"

        override fun getUseDeveloperSupport(): Boolean = BuildConfig.DEBUG

        override val isNewArchEnabled: Boolean = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED
        override val isHermesEnabled: Boolean = BuildConfig.IS_HERMES_ENABLED
      }

  override val reactHost: ReactHost
    get() = getDefaultReactHost(applicationContext, reactNativeHost)

  override fun onCreate() {
    super.onCreate()
    MxConfiguration.runtimeUrl = "http://10.0.2.2:8081" //For MendixApplication compatibility only, not part of React Native template
    SoLoader.init(this, OpenSourceMergedSoMapping)
    if (BuildConfig.IS_NEW_ARCHITECTURE_ENABLED) {
      // If you opted-in for the New Architecture, we load the native entry point for this app.
      load()
    }
  }

  //Start - For MendixApplication compatibility only, not part of React Native template
  override fun getUseDeveloperSupport() = false
  override fun createSplashScreenPresenter() = SplashScreenPresenter()
  override fun getPackages(): List<ReactPackage> = PackageList(this).packages
  override fun getJSBundleFile() = null
  override fun getAppSessionId() = null
  //End - For MendixApplication compatibility only, not part of React Native template
}
