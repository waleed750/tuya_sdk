package com.syncn.example


import com.facebook.drawee.backends.pipeline.Fresco
import android.app.Application
import com.thingclips.smart.home.sdk.ThingHomeSdk

class MainApplication : Application() {
  override fun onCreate() {
    super.onCreate()
    Fresco.initialize(this)
    // ThingHomeSdk.init(this)
  }
}