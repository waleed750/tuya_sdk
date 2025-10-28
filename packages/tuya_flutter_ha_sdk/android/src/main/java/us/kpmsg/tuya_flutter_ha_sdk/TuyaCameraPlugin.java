package us.kpmsg.tuya_flutter_ha_sdk;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback;
import com.thingclips.smart.home.sdk.bean.HomeBean;
import com.thingclips.smart.sdk.bean.DeviceBean;
import com.thingclips.smart.home.sdk.ThingHomeSdk;
import com.thingclips.smart.android.camera.sdk.ThingIPCSdk;
import com.thingclips.smart.android.camera.sdk.api.IThingIPCCore;
import com.thingclips.smart.sdk.api.IThingDevice;
import com.thingclips.smart.android.camera.sdk.api.IThingCameraMessage;
import com.thingclips.smart.android.camera.sdk.api.IThingIPCMsg;
import com.thingclips.smart.home.sdk.callback.IThingResultCallback;
import com.thingclips.smart.android.camera.sdk.api.IThingIPCDpHelper;
import com.thingclips.smart.sdk.api.IResultCallback;
import com.thingclips.smart.camera.middleware.widget.ThingCameraView;
import com.thingclips.smart.camera.middleware.p2p.IThingSmartCameraP2P;
import com.thingclips.smart.camera.middleware.widget.AbsVideoViewCallback;
import com.thingclips.smart.camera.camerasdk.thingplayer.callback.OperationDelegateCallBack;
import com.thingclips.smart.sdk.api.IThingDataCallback;
import com.thingclips.smart.sdk.bean.message.MessageListBean;
import com.thingclips.smart.sdk.bean.push.PushType;
import com.thingclips.smart.android.device.bean.SchemaBean;
import com.facebook.drawee.backends.pipeline.Fresco;

import android.app.Application;
import android.content.Context;
import android.app.Activity;
import android.graphics.Color;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;

import android.view.LayoutInflater;
import android.view.View;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.TimeZone;

public class TuyaCameraPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private Application appContext;
    private Activity activity;
    private EventChannel eventChannel;
    private EventSink eventSink;
    private TuyaCameraViewFactory tuyaCameraViewFactory;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        appContext = (Application) binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk/camera");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk/notifications");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        activity = activityPluginBinding.getActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public void registerPlugin(FlutterPluginBinding binding) {
        appContext = (Application) binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk/camera");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk/notifications");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
            }
        });
        tuyaCameraViewFactory = new TuyaCameraViewFactory();
        binding.getPlatformViewRegistry().registerViewFactory("tuya_camera_view", tuyaCameraViewFactory);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "listCameras":
                //isIPCDevice function of the Tuya SDK is called
                Number devHomeId = call.argument("homeId");
                ThingHomeSdk.newHomeInstance(devHomeId.intValue()).getHomeDetail(new IThingHomeResultCallback() {
                    @Override
                    public void onSuccess(HomeBean homeBean) {
                        IThingIPCCore cameraInstance = ThingIPCSdk.getCameraInstance();

                        ArrayList<DeviceBean> devices = (ArrayList) homeBean.getDeviceList();
                        ArrayList<HashMap<String, Object>> deviceList = new ArrayList<>();
                        for (int i = 0; i < devices.size(); i++) {
                            HashMap<String, Object> deviceDetails = new HashMap<>();
                            if (cameraInstance != null) {

                                if (cameraInstance.isIPCDevice(devices.get(i).getDevId())) {
                                    deviceDetails.put("devId", devices.get(i).getDevId());
                                    deviceDetails.put("name", devices.get(i).getName());
                                    deviceDetails.put("productId", devices.get(i).getProductId());
                                    deviceDetails.put("uuid", devices.get(i).getUuid());
                                    deviceDetails.put("iconUrl", devices.get(i).getIconUrl());
                                    deviceDetails.put("isOnline", devices.get(i).getIsOnline());
                                    deviceDetails.put("isCloudOnline", devices.get(i).isCloudOnline());
                                    deviceDetails.put("homeId", "not available");
                                    deviceDetails.put("roomId", "not available");

                                    deviceDetails.put("mac", devices.get(i).getMac());
                                    deviceDetails.put("bleType", "Not available");
                                    deviceDetails.put("bleProtocolV", "Not available");
                                    deviceDetails.put("support5G", "Not available");
                                    deviceDetails.put("isProductKey", "Not available");
                                    deviceDetails.put("isSupportMutliUserShare", devices.get(i).getIsShare());
                                    deviceDetails.put("isActive", "Not available");
                                    deviceDetails.put("dps", devices.get(i).getDps());
                                    deviceList.add(deviceDetails);
                                }
                            }


                        }

                        result.success(deviceList);
                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("LIST_CAMERAS_FAILED", errorMsg, "");
                    }
                });
                break;
            case "getCameraCapabilities":
                //getP2PType function of Tuya SDK is called
                String devId = call.argument("deviceId");
                IThingIPCCore cameraInstance = ThingIPCSdk.getCameraInstance();
                HashMap<String, Object> deviceDetails = new HashMap<>();

                if (cameraInstance != null) {
                    var p2pType = cameraInstance.getP2PType(devId);
                    DeviceBean mDevice = ThingHomeSdk.getDataInstance().getDeviceBean(devId);
                    deviceDetails.put("isCamera", true);
                    deviceDetails.put("p2pType", String.valueOf(p2pType));
                    deviceDetails.put("uuid", mDevice.getUuid());
                    deviceDetails.put("productId", mDevice.getProductId());
                    deviceDetails.put("deviceName", mDevice.getName());
                    deviceDetails.put("isOnline", mDevice.getIsOnline());
                    deviceDetails.put("isCloudOnline", mDevice.isCloudOnline());
                    result.success(deviceDetails);
                }

                break;
            case "startLiveStream":
                //startCamera function of Platform view is called
                result.success(null);
                tuyaCameraViewFactory.startCamera();

                break;
            case "stopLiveStream":
                //stopCamera function of Platform view is called
                tuyaCameraViewFactory.stopCamera();
                result.success(null);
                break;
            case "saveVideoToGallery":
                // startLocalRecording of Tuya SDK is called
                String picPath = call.argument("filePath");
                tuyaCameraViewFactory.startLocalRecording(picPath);
                result.success(null);
                break;
            case "stopSaveVideoToGallery":
                // stopLocalRecording of Tuya SDK is called
                tuyaCameraViewFactory.stopLocalRecording();
                result.success(null);
                break;
            case "getDeviceAlerts":
                //queryMotionDaysByMonth function is called
                String alertsDevId = call.argument("deviceId");
                Number alertYear = call.argument("year");
                Number alertMonth = call.argument("month");
                IThingCameraMessage cameraMessage;

                IThingIPCMsg message = ThingIPCSdk.getMessage();
                if (message != null) {
                    cameraMessage = message.createCameraMessage();
                    cameraMessage.queryMotionDaysByMonth(alertsDevId, alertYear.intValue(), alertMonth.intValue(), TimeZone.getDefault().getID(), new IThingResultCallback<List<String>>() {
                        @Override
                        public void onSuccess(List<String> resultMsg) {
                            result.success(resultMsg);
                        }

                        @Override
                        public void onError(String errorCode, String errorMessage) {
                            result.error("GET_DEVICE_ALERTS_FAILED", errorMessage, "");
                        }
                    });
                }

                break;
            case "setDeviceDpConfigs":
                //publishDps function of Tuya SDK is called
                String setDpDevId = call.argument("deviceId");
                HashMap<String, Object> setDps = (HashMap<String, Object>) call.argument("dps");

                StringBuilder mapAsString = new StringBuilder("{");
                for (String key : setDps.keySet()) {
                    mapAsString.append('"'+key + "\":" + setDps.get(key) + ", ");
                }
                mapAsString.delete(mapAsString.length()-2, mapAsString.length()).append("}");
                Log.i("dps",mapAsString.toString());
                IThingDevice dpDevice = ThingHomeSdk.newDeviceInstance(setDpDevId);
                dpDevice.publishDps(mapAsString.toString(), new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        result.error("SET_DEVICE_CONFIG_FAILED", error, "");
                        // The error code 11001 is returned due to the following causes:
                        // 1: Data has been sent in an incorrect format. For example, the data of String type has been sent in the format of Boolean data.
                        // 2: Read-only DPs cannot be sent. For more information, see SchemaBean getMode. `ro` indicates the read-only type.
                        // 3: Data of Raw type has been sent in a format rather than a hexadecimal string.
                    }
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });

                break;
            case "getDeviceDpConfigs":
                //getDps function of Tuya SDK is called
                String getDpsdevId = call.argument("deviceId");
                DeviceBean mDevice = ThingHomeSdk.getDataInstance().getDeviceBean(getDpsdevId);
                Map<String,SchemaBean> schemaBeanMap =mDevice.getSchemaMap();
                ArrayList<HashMap<String, Object>> dpConfigs = new ArrayList<>();
                Map<String,Object> dps=mDevice.getDps();
                schemaBeanMap.forEach((key,value)->{
                    String valueStr="null";
                    if(dps.get(key)!=null){
                        valueStr=String.valueOf(dps.get(key));
                    }
                    HashMap<String, Object> dpDetails = new HashMap<>();
                    dpDetails.put("dpId",key);
                    dpDetails.put("code",value.getCode());
                    dpDetails.put("name",value.getName());
                    dpDetails.put("type",value.getType());
                    dpDetails.put("value",valueStr);

                    dpConfigs.add(dpDetails);
                });

                result.success(dpConfigs);
                break;
            case "registerPush":
                //setPushStatusByType function of Tuya SDK is called
                Number pushTypeInt = call.argument("type");
                Boolean checked = call.argument("isOpen");
                PushType pushType = PushType.values()[pushTypeInt.intValue()];
                Log.i("pushType", pushType.toString());
                ThingHomeSdk.getPushInstance().setPushStatusByType(pushType, checked, new IThingDataCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean setup) {
                        result.success(null);
                    }

                    @Override
                    public void onError(String errorCode, String errorMessage) {
                        result.error("REGISTER_PUSH_FAILED", errorMessage, "");
                    }
                });

                break;
            case "getAllMessages":
                //getMessageList function of Tuya SDK is called
                int offset = 0;
                int limit = 30;
                ThingHomeSdk.getMessageInstance().getMessageList(offset, limit, new IThingDataCallback<MessageListBean>() {
                    @Override
                    public void onSuccess(MessageListBean listBean) {
                        ArrayList<HashMap<String, Object>> messageList = new ArrayList<>();
                        for (int i = 0; i < listBean.getTotalCount()-1; i++) {
                            HashMap<String, Object> messageDetails = new HashMap<>();
                            messageDetails.put("msgType",listBean.getDatas().get(i).getMsgType());
                            messageDetails.put("msgContent",listBean.getDatas().get(i).getMsgContent());
                            messageList.add(messageDetails);
                        }
                        result.success(messageList);
                    }

                    @Override
                    public void onError(String errorCode, String errorMessage) {
                        result.error("GET_MESSAGES_FAILED", errorMessage, "");
                    }
                });

                break;

        }
    }
}

class TuyaCameraViewFactory extends PlatformViewFactory {
    TuyaCameraPlatformView tuyaCameraPlatformView;

    TuyaCameraViewFactory() {
        super(StandardMessageCodec.INSTANCE);
    }

    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = (Map<String, Object>) args;
        tuyaCameraPlatformView = new TuyaCameraPlatformView(context, id, creationParams);
        return tuyaCameraPlatformView;
    }

    public void startCamera() {
        if (tuyaCameraPlatformView != null) {
            tuyaCameraPlatformView.startCamera();
        }
    }

    public void stopCamera() {
        if (tuyaCameraPlatformView != null) {
            tuyaCameraPlatformView.stopCamera();
        }
    }

    public void startLocalRecording(String picPath) {
        if (tuyaCameraPlatformView != null) {
            tuyaCameraPlatformView.startLocalRecording(picPath);
        }
    }

    public void stopLocalRecording() {
        if (tuyaCameraPlatformView != null) {
            tuyaCameraPlatformView.stopLocalRecording();
        }
    }
}

class TuyaCameraPlatformView implements PlatformView {
    private View view = null;
    private IThingSmartCameraP2P mCameraP2P = null;
    private String devId;

    private Context pluginContext;
    private ThingCameraView cameraView;

    TuyaCameraPlatformView(Context context, int id, Map<String, Object> creationParams) {

        devId = (String) creationParams.get("deviceId");
        Log.i("Device Id", devId);
        /*view = LayoutInflater.from(context).inflate(R.layout.camera_video_view, null);
        ThingCameraView cameraView = view.findViewById(R.id.camera_video_view);
        cameraView.createVideoView(devId);
        pluginContext = context;*/
        IThingIPCCore cameraInstance = ThingIPCSdk.getCameraInstance();
        if (cameraInstance != null) {
            mCameraP2P = cameraInstance.createCameraP2P(devId);
            view = LayoutInflater.from(context).inflate(R.layout.camera_video_view, null);
            cameraView = view.findViewById(R.id.camera_video_view);
            cameraView.setViewCallback(new AbsVideoViewCallback() {
                @Override
                public void onCreated(Object view) {
                    super.onCreated(view);
                    //3. Binds the rendered view with `IThingSmartCameraP2P`.
                    Log.i("CAMERA","cameraView on created");
                    if (null != mCameraP2P){
                        mCameraP2P.generateCameraView(view);
                        Log.i("CAMERA","after generate camera view");
                    }
                }
            });
            cameraView.createVideoView(devId);
            mCameraP2P.setMute(0, new OperationDelegateCallBack() {
                @Override
                public void onSuccess(int sessionId, int requestId, String data) {
                    // The operation result is returned by `data`.

                }

                @Override
                public void onFailure(int sessionId, int requestId, int errCode) {
                }
            });
        }


    }

    @Override
    public View getView() {
        return view;
    }

    @Override
    public void dispose() {
        //cameraView.onDestroy();
    }

    public void startCamera() {
        mCameraP2P.connect(devId, new OperationDelegateCallBack() {
            @Override
            public void onSuccess(int sessionId, int requestId, String data) {
                // A P2P connection is created.
                Log.i("CAMERA","p2p connect on success");
                mCameraP2P.startPreview(new OperationDelegateCallBack() {
                    @Override
                    public void onSuccess(int sessionId, int requestId, String data) {
                        // Live streaming is started.
                        Log.i("CAMERA","start preview on success");
                    }

                    @Override
                    public void onFailure(int sessionId, int requestId, int errCode) {
                        // Failed to start live streaming.
                        Log.i("CAMERA","start preview on failure");
                    }
                });
            }

            @Override
            public void onFailure(int sessionId, int requestId, int errCode) {
                // Failed to create a P2P connection.
                Log.i("CAMERA","p2p connect on failure");
            }
        });
    }

    public void stopCamera() {
        mCameraP2P.stopPreview(new OperationDelegateCallBack() {
            @Override
            public void onSuccess(int sessionId, int requestId, String data) {
            }

            @Override
            public void onFailure(int sessionId, int requestId, int errCode) {
            }
        });
    }

    public void startLocalRecording(String picPath) {
        mCameraP2P.startRecordLocalMp4(picPath, pluginContext, new OperationDelegateCallBack() {
            @Override
            public void onSuccess(int sessionId, int requestId, String data) {

            }

            @Override
            public void onFailure(int sessionId, int requestId, int errCode) {

            }
        });
    }

    public void stopLocalRecording() {
        mCameraP2P.stopRecordLocalMp4(new OperationDelegateCallBack() {
            @Override
            public void onSuccess(int sessionId, int requestId, String data) {
                // The success callback.
            }

            @Override
            public void onFailure(int sessionId, int requestId, int errCode) {
                // The failure callback.
            }
        });
    }
}
