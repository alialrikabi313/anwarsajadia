package com.alialrikabi313.anwarsajadia

import android.hardware.GeomagneticField
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "anwarsajadia/geomag"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "declination") {
                    // Magnetic declination (degrees, positive = east) at the
                    // given position/time, from Android's built-in World
                    // Magnetic Model — converts the magnetometer's magnetic
                    // heading to a true-north heading for the qibla compass.
                    val lat = call.argument<Double>("lat") ?: 0.0
                    val lon = call.argument<Double>("lon") ?: 0.0
                    val alt = call.argument<Double>("alt") ?: 0.0
                    val field = GeomagneticField(
                        lat.toFloat(),
                        lon.toFloat(),
                        alt.toFloat(),
                        System.currentTimeMillis()
                    )
                    result.success(field.declination.toDouble())
                } else {
                    result.notImplemented()
                }
            }
    }
}
