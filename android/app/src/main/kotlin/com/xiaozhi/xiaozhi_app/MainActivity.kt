package com.xiaozhi.xiaozhi_app

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * [MainActivity] 主 Activity。
 * 注册 MethodChannel 处理蓝牙扫描请求，
 * 通过 EventChannel 将扫描到的设备实时推送给 Flutter 层。
 */
class MainActivity : FlutterActivity() {

    companion object {
        private const val BLUETOOTH_METHOD_CHANNEL = "com.xiaozhi/bluetooth"
        private const val BLUETOOTH_EVENT_CHANNEL = "com.xiaozhi/bluetooth_events"
        private const val REQUEST_BT_PERMISSIONS = 1001
    }

    private var bluetoothAdapter: BluetoothAdapter? = null
    private var pendingResult: MethodChannel.Result? = null
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())

    /**
     * 广播接收器：接收蓝牙发现结果和扫描完成事件。
     */
    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    val device: BluetoothDevice? =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }
                    val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
                    device?.let { d ->
                        // 优先使用 discovery 返回的名称；为空时尝试从已配对设备中查找
                        val name = d.name?.takeIf { it.isNotEmpty() }
                            ?: bluetoothAdapter?.bondedDevices
                                ?.firstOrNull { it.address == d.address }?.name
                            ?: d.address  // 最终兜底：用 MAC 地址
                        // 将发现的设备通过 EventChannel 推送给 Flutter 层
                        eventSink?.success(mapOf(
                            "name" to name,
                            "address" to d.address,
                            "rssi" to rssi
                        ))
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    // 扫描完成，通知 Flutter 层
                    eventSink?.success(mapOf("event" to "scan_finished"))
                    unregisterBluetoothReceiver()
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()

        // ---- MethodChannel：处理蓝牙操作请求 ----
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // 检查蓝牙是否可用
                    "isBluetoothAvailable" -> {
                        val available = bluetoothAdapter != null
                        result.success(available)
                    }
                    // 检查蓝牙是否已开启
                    "isBluetoothEnabled" -> {
                        val enabled = bluetoothAdapter?.isEnabled == true
                        result.success(enabled)
                    }
                    // 开启蓝牙
                    "enableBluetooth" -> {
                        if (bluetoothAdapter?.isEnabled == true) {
                            result.success(true)
                        } else {
                            try {
                                val enabled = bluetoothAdapter?.enable() ?: false
                                result.success(enabled)
                            } catch (e: SecurityException) {
                                result.error("PERMISSION", "缺少蓝牙权限", null)
                            }
                        }
                    }
                    // 开始扫描蓝牙设备
                    "startScan" -> {
                        if (!hasBluetoothPermissions()) {
                            requestBluetoothPermissions()
                            result.error("PERMISSION", "需要蓝牙和位置权限", null)
                            return@setMethodCallHandler
                        }
                        try {
                            bluetoothAdapter?.cancelDiscovery()
                            registerBluetoothReceiver()
                            val started = bluetoothAdapter?.startDiscovery() ?: false
                            if (started) {
                                pendingResult = result
                                handler.postDelayed({
                                    bluetoothAdapter?.cancelDiscovery()
                                    pendingResult?.success(true)
                                    pendingResult = null
                                }, 12000)
                            } else {
                                result.error("FAILED", "无法启动蓝牙扫描", null)
                            }
                        } catch (e: SecurityException) {
                            result.error("PERMISSION", "缺少蓝牙权限", null)
                        }
                    }
                    // 停止扫描
                    "stopScan" -> {
                        try {
                            bluetoothAdapter?.cancelDiscovery()
                            unregisterBluetoothReceiver()
                            result.success(true)
                        } catch (e: SecurityException) {
                            result.error("PERMISSION", "缺少蓝牙权限", null)
                        }
                    }
                    // 配对/连接设备
                    "connectDevice" -> {
                        val address = call.argument<String>("address") ?: ""
                        result.success(true) // 简化为直接返回成功
                    }
                    else -> result.notImplemented()
                }
            }

        // ---- EventChannel：实时推送蓝牙事件 ----
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, BLUETOOTH_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
    }

    private fun hasBluetoothPermissions(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val hasScan = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_SCAN) == PackageManager.PERMISSION_GRANTED
            val hasConnect = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
            return hasScan && hasConnect
        }
        @Suppress("DEPRECATION")
        val hasBt = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH) == PackageManager.PERMISSION_GRANTED
        val hasBtAdmin = ContextCompat.checkSelfPermission(this, Manifest.permission.BLUETOOTH_ADMIN) == PackageManager.PERMISSION_GRANTED
        val hasLoc = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        return hasBt && hasBtAdmin && hasLoc
    }

    private fun requestBluetoothPermissions() {
        val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            arrayOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.ACCESS_FINE_LOCATION
            )
        } else {
            arrayOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            )
        }
        ActivityCompat.requestPermissions(this, permissions, REQUEST_BT_PERMISSIONS)
    }

    private fun registerBluetoothReceiver() {
        try {
            val filter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                @Suppress("UnspecifiedRegisterReceiverFlag")
                registerReceiver(receiver, filter)
            }
        } catch (_: Exception) {}
    }

    private fun unregisterBluetoothReceiver() {
        try {
            unregisterReceiver(receiver)
        } catch (_: Exception) {}
    }

    override fun onDestroy() {
        unregisterBluetoothReceiver()
        super.onDestroy()
    }
}
