// android/src/main/java/us/kpmsg/tuya_flutter_ha_sdk/TuyaFlutterHaSdkPlugin.java

package us.kpmsg.tuya_flutter_ha_sdk;

// at top of file:
import android.os.Build;
import java.util.Arrays;
import android.util.Log;

import android.app.Application;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;
import android.content.Context;
import android.net.wifi.SupplicantState;
import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.thingclips.smart.home.sdk.ThingHomeSdk;
// The login callback interface (adjust the package if needed):
//import com.thingclips.smart.home.sdk.api.ILoginCallback;
import com.thingclips.smart.android.user.api.ILoginCallback;
import com.thingclips.smart.android.user.bean.User;
import com.thingclips.smart.android.user.api.ILogoutCallback;
import com.thingclips.smart.optimus.lock.api.callback.RemoteUnlockListener;

import com.thingclips.smart.sdk.api.IResultCallback;
import com.thingclips.smart.sdk.enums.TempUnitEnum;
import com.thingclips.smart.android.user.api.IReNickNameCallback;
// Import for registration callback
import com.thingclips.smart.android.user.api.IRegisterCallback;
import com.thingclips.smart.home.sdk.bean.HomeBean;
import com.thingclips.smart.home.sdk.callback.IThingHomeResultCallback;
import com.thingclips.smart.home.sdk.callback.IThingGetHomeListCallback;
import com.thingclips.smart.sdk.bean.DeviceBean;
import com.thingclips.smart.sdk.ThingSdk;
import com.thingclips.smart.sdk.api.IThingActivatorGetToken;
import com.thingclips.smart.home.sdk.builder.ActivatorBuilder;
import com.thingclips.smart.sdk.api.IThingActivator;
import com.thingclips.smart.sdk.api.IThingSmartActivatorListener;
import com.thingclips.smart.sdk.enums.ActivatorModelEnum;
import com.thingclips.smart.home.sdk.builder.ThingApActivatorBuilder;
import com.thingclips.smart.sdk.api.IThingOptimizedActivator;
import com.thingclips.smart.sdk.bean.ApQueryBuilder;
import com.thingclips.smart.home.sdk.callback.IThingResultCallback;
import com.thingclips.smart.home.sdk.bean.WiFiInfoBean;
import com.thingclips.smart.android.ble.api.LeScanSetting;
import com.thingclips.smart.android.ble.api.ScanType;
import com.thingclips.smart.android.ble.api.BleScanResponse;
import com.thingclips.smart.android.ble.api.ScanDeviceBean;
import com.thingclips.smart.sdk.bean.BleActivatorBean;
import com.thingclips.smart.sdk.api.IBleActivatorListener;
import com.thingclips.smart.sdk.bean.MultiModeActivatorBean;
import com.thingclips.smart.sdk.api.IMultiModeActivatorListener;
import com.thingclips.smart.sdk.api.IThingDevice;
import com.thingclips.smart.sdk.api.IDevListener;
import com.thingclips.smart.sdk.api.WifiSignalListener;
import com.thingclips.smart.home.sdk.callback.IThingRoomResultCallback;
import com.thingclips.smart.home.sdk.bean.RoomBean;
import com.thingclips.smart.home.sdk.callback.IThingGetRoomListCallback;
import com.thingclips.smart.optimus.lock.api.IThingBleLockV2;
import com.thingclips.smart.optimus.lock.api.IThingLockManager;
import com.thingclips.smart.optimus.sdk.ThingOptimusSdk;
import com.thingclips.smart.sdk.optimus.lock.bean.ble.BLELockUser;
import com.thingclips.smart.optimus.lock.api.IThingWifiLock;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.android.FlutterActivity;

import com.thingclips.smart.sdk.api.IBleActivator;

import com.thingclips.smart.sdk.api.IMultiModeActivator;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;

import android.util.Log;

import org.jetbrains.annotations.Nullable;

/**
 * TuyaFlutterHaSdkPlugin
 */
public class TuyaFlutterHaSdkPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private Application appContext;
    IThingActivator mThingActivator;
    private Activity activity;
    private EventChannel eventChannel;
    private EventSink eventSink;

    private IBleActivator mBleActivator;

    private IMultiModeActivator mComboActivator;


    private String mBleActivatorUuid;

    private String mComboActivatorUuid;


    /**
     * Stop any ongoing BLE scan or activator so the next one
     * <p>
     * starts with a clean slate.
     */
    private void emitEvent(String type, Map<String, Object> data) {
        if (eventSink == null) return;
        Map<String, Object> ev = new HashMap<>();
        ev.put("type", type);
        if (data != null) ev.putAll(data);
        eventSink.success(ev);
    }
    private void stopAnyPairingOrScan() {

        // stop any BLE scan

        ThingHomeSdk.getBleOperator().stopLeScan();

        if (mThingActivator != null) {
            mThingActivator.stop();
            mThingActivator = null;
        }


        // stop BLE-only activator

        if (mBleActivator != null && mBleActivatorUuid != null) {

            mBleActivator.stopActivator(mBleActivatorUuid);

            mBleActivator = null;

            mBleActivatorUuid = null;

        }

        // stop Combo (BLE→Wi-Fi) activator

        if (mComboActivator != null && mComboActivatorUuid != null) {

            mComboActivator.stopActivator(mComboActivatorUuid);

            mComboActivator = null;

            mComboActivatorUuid = null;

        }


    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        appContext = (Application) binding.getApplicationContext();
        channel = new MethodChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk");
        channel.setMethodCallHandler(this);
        eventChannel = new EventChannel(binding.getBinaryMessenger(), "tuya_flutter_ha_sdk/pairingEvents");
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
        TuyaCameraPlugin tuyaCameraPlugin=new TuyaCameraPlugin();
        tuyaCameraPlugin.registerPlugin(binding);
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
        activity = null;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;

           case "tuyaSdkInit": 
            String appKey = call.argument("appKey");
            String appSecret = call.argument("appSecret");
            boolean isDebug = Boolean.TRUE.equals(call.argument("isDebug"));

            if (appKey == null || appSecret == null) {
                result.error("MISSING_ARGS", "appKey and appSecret are required", null);
                break;
            }

            final String TAG = "TuyaInit";
            boolean isEmulator =
                    Build.FINGERPRINT != null && Build.FINGERPRINT.contains("generic")
                 || Build.MODEL != null && (Build.MODEL.contains("Emulator") || Build.MODEL.contains("Android SDK"))
                 || Build.MANUFACTURER != null && Build.MANUFACTURER.contains("Genymotion")
                 || (Build.BRAND != null && Build.DEVICE != null
                        && (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")));

            // If the emulator ABI is x86/x86_64 and Tuya libs are ARM-only, skip init in debug.
            boolean isX86 = Arrays.toString(Build.SUPPORTED_ABIS).contains("x86");
            boolean shouldSkipForEmu = isDebug && isEmulator && isX86;

            try {
                if (shouldSkipForEmu) {
                    Log.w(TAG, "Skipping Tuya init on x86/x86_64 emulator (debug).");
                    result.error("INIT_FAILED", "Skipping Tuya init on x86/x86_64 emulator (debug).", null); //(null); // don’t crash; your Flutter side should handle "no Tuya" in debug
                    break;
                }

                ThingHomeSdk.init(appContext, appKey, appSecret);
                ThingHomeSdk.setDebugMode(isDebug);
                Log.i(TAG, "Tuya SDK initialized OK");
                result.success(null);
            } catch (UnsatisfiedLinkError e) {
                Log.w(TAG, "Native libs missing (likely x86 emulator). Skipping Tuya init in debug.", e);
                // You can still succeed to let the app run without Tuya on emulator
                result.error("INIT_FAILED", "Native libs missing (likely x86 emulator). Skipping Tuya init in debug.", null);
            } catch (Throwable t) {
                Log.e(TAG, "Tuya init failed", t);
                result.error("INIT_FAILED", t.getMessage(), null);
            } catch (Exception e) {
                    Log.e(TAG, "Exception in ThingHomeSdk.init", e);
                    result.error("INIT_FAILED", "Exception in ThingHomeSdk.init: " + e.getMessage(), null);
                    break;
            }
            break;

            case "loginWithUid":
                // loginOrRegisterWithUid function of the Tuya SDK is called with the passed on data
                String countryCode = call.argument("countryCode");
                String uid = call.argument("uid");
                String password = call.argument("password");
                Boolean createHome = call.argument("createHome");
                if (countryCode == null || uid == null || password == null || createHome == null) {
                    result.error("MISSING_ARGS", "countryCode, uid, password, createHome required", null);
                    return;
                }
                Log.i("UID", uid);
                Log.i("PWD", password);
                // Directly invoke loginOrRegisterWithUid(...) on ThingHomeSdk.getUserInstance()
                ThingHomeSdk.getUserInstance().loginOrRegisterWithUid(
                        countryCode,
                        uid,
                        password,
                        // If your version supports a 4-argument login, omit `createHome` and use this callback only:
                        new ILoginCallback() {
                            @Override
                            public void onSuccess(User user) {
                                Map<String, Object> resp = new HashMap<>();
                                //resp.put("uid", userId);
                                result.success(resp);
                            }

                            @Override
                            public void onError(String code, String error) {
                                result.error("LOGIN_FAILED", error + " (code: " + code + ")", null);
                            }
                        }
                );
                break;
                
            case "loginWithEmail":
                // loginByEmail function of the Tuya SDK is called with the passed on data
                String emailCountryCode = call.argument("countryCode");
                String email = call.argument("email");
                String emailPassword = call.argument("password");
                Boolean emailCreateHome = call.argument("createHome");
                if (emailCountryCode == null || email == null || emailPassword == null || emailCreateHome == null) {
                    result.error("MISSING_ARGS", "countryCode, email, password, createHome required", null);
                    return;
                }
                Log.i("EMAIL", email);
                // Invoke loginByEmail on ThingHomeSdk.getUserInstance()
                ThingHomeSdk.getUserInstance().loginWithEmail(
                        emailCountryCode,
                        email,
                        emailPassword,
                        new ILoginCallback() {
                            @Override
                            public void onSuccess(User user) {
                                Map<String, Object> resp = new HashMap<>();
                                resp.put("email", user.getEmail());
                                resp.put("uid", user.getUid());
                                result.success(resp);
                            }

                            @Override
                            public void onError(String code, String error) {
                                result.error("LOGIN_FAILED", error + " (code: " + code + ")", null);
                            }
                        }
                );
                break;
            case "checkLogin":
                // return the value of isLogin of the user instance of Tuya SDK
                result.success(ThingHomeSdk.getUserInstance().isLogin());
                break;
            case "getCurrentUser":
                // returns the user info available in the user instance of Tuya SDK
                User user = ThingHomeSdk.getUserInstance().getUser();
                if (user != null) {
                    HashMap<String, Object> info = new HashMap<>();
                    info.put("uid", (user.getUid() != null) ? user.getUid() : "");
                    info.put("userName", (user.getUsername() != null) ? user.getUsername() : "");
                    info.put("email", (user.getEmail() != null) ? user.getEmail() : "");
                    info.put("phoneNumber", (user.getMobile() != null) ? user.getMobile() : "");
                    info.put("countryCode", (user.getPhoneCode() != null) ? user.getPhoneCode() : "");
                    info.put("regionCode", (user.getDomain().getRegionCode() != null) ? user.getDomain().getRegionCode() : "");
                    info.put("headIconUrl", (user.getHeadPic() != null) ? user.getHeadPic() : "");
                    info.put("tempUnit", String.valueOf(user.getTempUnit()));
                    info.put("timezoneId", (user.getTimezoneId() != null) ? user.getTimezoneId() : "");
                    info.put("snsNickname", (user.getNickName() != null) ? user.getNickName() : "");
                    info.put("regFrom", String.valueOf(user.getRegFrom()));

                    result.success(info);
                } else {
                    result.error("NO_USER", "No user is currently logged in", "");
                }
                break;
                
            case "registerAccountWithEmail":
                // Register by email using Tuya SDK
                String regEmailCountryCode = call.argument("countryCode");
                String regEmail = call.argument("email");
                String regEmailPassword = call.argument("password");
                String regEmailCode = call.argument("code");
                
                if (regEmailCountryCode == null || regEmail == null || regEmailPassword == null || regEmailCode == null) {
                    result.error("MISSING_ARGS", "countryCode, email, password, code required", null);
                    return;
                }
                
                ThingHomeSdk.getUserInstance().registerAccountWithEmail(
                    regEmailCountryCode,
                    regEmail,
                    regEmailPassword,
                    regEmailCode,
                    new IRegisterCallback() {
                        public void onSuccess(User user) {
                            Map<String, Object> resp = new HashMap<>();
                            resp.put("email", user.getEmail());
                            resp.put("uid", user.getUid());
                            result.success(resp);
                        }

                        public void onError(String code, String error) {
                            result.error("REGISTER_FAILED", error + " (code: " + code + ")", null);
                        }
                    }
                );
                break;
            case "sendVerificationCode":
                String verificationCountryCode = call.argument("countryCode");
                String verificationAccount = call.argument("account");
                String verificationAccountType = call.argument("accountType");
                Integer verificationTypeArg = call.argument("type");
                Log.i("TuyaSendVerification", "countryCode: " + verificationCountryCode);
                Log.i("TuyaSendVerification", "account: " + verificationAccount);
                Log.i("TuyaSendVerification", "accountType: " + verificationAccountType);
                Log.i("TuyaSendVerification", "type: " + verificationTypeArg);

                if (verificationCountryCode == null || verificationAccount == null || verificationAccountType == null) {
                    result.error("MISSING_ARGS", "countryCode, account, accountType required", null);
                    return;
                }

                String normalizedAccountType = verificationAccountType.trim().toLowerCase();
                if (!normalizedAccountType.equals("email") && !normalizedAccountType.equals("phone")) {
                    result.error("INVALID_PARAMETER", "accountType must be either 'email' or 'phone'", null);
                    return;
                }

                int verificationType = verificationTypeArg != null ? verificationTypeArg : 1; // default: register

                ThingHomeSdk.getUserInstance().sendVerifyCodeWithUserName(
                    verificationAccount,
                    verificationCountryCode,
                    verificationAccountType, // accountType ("email" or "phone")
                    verificationType,
                    new IResultCallback() {
                        @Override
                        public void onSuccess() {
                            result.success(null);
                        }

                        @Override
                        public void onError(String errorCode, String errorMessage) {
                            result.error("SEND_VERIFICATION_FAILED", errorMessage + " (code: " + errorCode + ")", null);
                        }
                    }
                );
                break;
            case "registerAccountWithPhone":
                // Register by phone using Tuya SDK
                String regPhoneCountryCode = call.argument("countryCode");
                String regPhone = call.argument("phone");
                String regPhonePassword = call.argument("password");
                String regPhoneCode = call.argument("code");
                
                if (regPhoneCountryCode == null || regPhone == null || regPhonePassword == null || regPhoneCode == null) {
                    result.error("MISSING_ARGS", "countryCode, phone, password, code required", null);
                    return;
                }
                
                ThingHomeSdk.getUserInstance().registerAccountWithPhone(
                    regPhoneCountryCode,
                    regPhone,
                    regPhonePassword,
                    regPhoneCode,
                    new IRegisterCallback() {
                        public void onSuccess(User user) {
                            Map<String, Object> resp = new HashMap<>();
                            resp.put("phone", user.getMobile());
                            resp.put("uid", user.getUid());
                            result.success(resp);
                        }

                        public void onError(String code, String error) {
                            result.error("REGISTER_FAILED", error + " (code: " + code + ")", null);
                        }
                    }
                );
                break;
            case "userLogout":
                // logout function of the Tuya SDK is called
                ThingHomeSdk.getUserInstance().logout(new ILogoutCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);

                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("LOGOUT_FAILED", errorMsg, "");
                    }
                });
                break;
            case "deleteAccount":
                // cancelAccount function of the Tuya SDK is called
                ThingHomeSdk.getUserInstance().cancelAccount(new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        result.error("DELETE_FAILED", error, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });
                break;
            case "updateTimeZone":
                // updateTimeZone function of the Tuya SDK is called
                String timezoneId = call.argument("timeZoneId");
                ThingHomeSdk.getUserInstance().updateTimeZone(
                        timezoneId,
                        new IResultCallback() {
                            @Override
                            public void onSuccess() {
                                result.success(null);
                            }

                            @Override
                            public void onError(String code, String error) {
                                result.error("UPDATE_TIMEZONE_FAILED", error, "");
                            }
                        });
                break;
            case "updateTempUnit":
                // setTempUnit of the Tuya SDK is called
                Number tempUnit = call.argument("tempUnit");
                ThingHomeSdk.getUserInstance().setTempUnit((tempUnit.intValue() == 1) ? TempUnitEnum.Celsius : TempUnitEnum.Fahrenheit, new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(@Nullable String code, @Nullable String error) {
                        result.error("UPDATE_TEMPUNIT_FAILED", error, "");
                    }
                });
                break;
            case "updateNickname":
                // updateNickName of the Tuya SDK is called
                String nickName = call.argument("nickname");
                ThingHomeSdk.getUserInstance().updateNickName(nickName,
                        new IReNickNameCallback() {
                            @Override
                            public void onSuccess() {
                                result.success(null);
                            }

                            @Override
                            public void onError(String code, String error) {
                                result.error("UPDATE_NICKNAME_FAILED", error, "");
                            }
                        });
                break;
            case "createHome":
                // return the homeId from createHome function of Tuya SDK is called
                String homeName = call.argument("name");
                String geoName = call.argument("geoName");
                double lat = call.argument("latitude");
                double lng = call.argument("longitude");
                ArrayList<String> rooms = call.argument("rooms");
                ThingHomeSdk.getHomeManagerInstance().createHome(
                        homeName,
                        lng,
                        lat,
                        (geoName != null) ? geoName : "",
                        (rooms != null) ? rooms : new ArrayList<>(),

                        new IThingHomeResultCallback() {
                            @Override
                            public void onSuccess(HomeBean bean) {
                                result.success(bean.getHomeId());
                            }

                            @Override
                            public void onError(String errorCode, String errorMsg) {
                                result.error("CREATE_HOME_FAILED", errorMsg, "");
                            }
                        }
                );
                break;
            case "getHomeList":
                // return a list of home from queryHomeList function of Tuya SDK is called
                ThingHomeSdk.getHomeManagerInstance().queryHomeList(new IThingGetHomeListCallback() {
                    @Override
                    public void onSuccess(List<HomeBean> homeBeans) {
                        ArrayList<HashMap<String, Object>> homeList = new ArrayList<>();
                        for (int i = 0; i < homeBeans.size(); i++) {
                            HashMap<String, Object> homeDetails = new HashMap<>();
                            homeDetails.put("name", homeBeans.get(i).getName());
                            homeDetails.put("background", homeBeans.get(i).getBackground());
                            homeDetails.put("lon", homeBeans.get(i).getLon());
                            homeDetails.put("lat", homeBeans.get(i).getLat());
                            homeDetails.put("geoName", homeBeans.get(i).getGeoName());
                            homeDetails.put("homeId", homeBeans.get(i).getHomeId());
                            homeDetails.put("admin", homeBeans.get(i).isAdmin());
                            homeDetails.put("inviteName", homeBeans.get(i).getInviteName());
                            homeDetails.put("homeStatus", homeBeans.get(i).getHomeStatus());
                            homeDetails.put("role", homeBeans.get(i).getRole());
                            homeDetails.put("managementStatus", homeBeans.get(i).managmentStatus());
                            List<RoomBean> roomBeans = homeBeans.get(i).getRooms();
                            Log.i("rooms size", String.valueOf(roomBeans.size()));
                            List<String> homeRoomIds = new ArrayList<>();
                            for (int j = 0; j < roomBeans.size(); j++) {
                                homeRoomIds.add(String.valueOf(roomBeans.get(j).getRoomId()));
                            }
                            homeDetails.put("roomIds", String.join(",", homeRoomIds));
                            homeList.add(homeDetails);
                        }
                        result.success(homeList);
                    }

                    @Override
                    public void onError(String errorCode, String error) {
                        result.error("GET_HOME_LIST_FAILED", error, "");
                    }
                });
                break;
            case "updateHomeInfo":
                // updateHome function of Tuya SDK is called
                Number homeId = call.argument("homeId");
                String newName = call.argument("homeName");
                String newGeoName = call.argument("geoName");
                double newLat = (call.argument("latitude") != null) ? call.argument("latitude") : 0.0;
                double newLng = (call.argument("longitude") != null) ? call.argument("longitude") : 0.0;
                //List<String> updateRooms = (List<String>) call.argument("rooms");
                //if (updateRooms == null) updateRooms = new ArrayList<>();
                Log.i("Lat", String.valueOf(newLat));
                Log.i("Lng", String.valueOf(newLng));
                ThingHomeSdk.newHomeInstance(homeId.intValue()).updateHome(newName, newLng, newLat, newGeoName, new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        result.error("UPDATE_HOME_FAILED", error, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });
                break;
            case "deleteHome":
                // dismissHome function of the Tuya SDK is called
                Number delHomeId = call.argument("homeId");
                ThingHomeSdk.newHomeInstance(delHomeId.intValue()).dismissHome(new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("DELETE_HOME_FAILED", error, "");
                    }
                });
                break;
            case "getHomeDevices":
                // return a list of devices from getDeviceList function of Tuya SDK is called
                Number devHomeId = call.argument("homeId");
                ThingHomeSdk.newHomeInstance(devHomeId.intValue()).getHomeDetail(new IThingHomeResultCallback() {
                    @Override
                    public void onSuccess(HomeBean homeBean) {
                        ArrayList<DeviceBean> devices = (ArrayList) homeBean.getDeviceList();
                        ArrayList<HashMap<String, Object>> deviceList = new ArrayList<>();
                        for (int i = 0; i < devices.size(); i++) {
                            HashMap<String, Object> deviceDetails = new HashMap<>();
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

                        result.success(deviceList);
                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("GET_HOME_DEVICES_FAILED", errorMsg, "");
                    }
                });
                break;
            case "discoverDeviceInfo":
                // return the device info from startLeScan function of Tuya SDK
                checkPermission();
                stopAnyPairingOrScan();
                LeScanSetting scanSetting = new LeScanSetting.Builder()
                        .setTimeout(60_000) // The duration of the scanning. Unit: milliseconds.
                        .addScanType(ScanType.SINGLE) // ScanType.SINGLE: scans for Bluetooth LE devices.
                        .build();

                ThingHomeSdk.getBleOperator().startLeScan(scanSetting, new BleScanResponse() {
                    @Override
                    public void onResult(ScanDeviceBean bean) {
                        HashMap<String, Object> deviceDetails = new HashMap<>();
                        deviceDetails.put("name", bean.getName());
                        deviceDetails.put("productId", bean.getProductId());
                        deviceDetails.put("uuid", bean.getUuid());
                        deviceDetails.put("mac", bean.getMac());
                        deviceDetails.put("providerName", bean.getProviderName());
                        deviceDetails.put("flag", bean.getFlag());
                        deviceDetails.put("address", bean.getAddress());
                        deviceDetails.put("bleType", bean.getDeviceType());
                        deviceDetails.put("deviceType", bean.getDeviceType());
                        deviceDetails.put("configType", bean.getConfigType());
                
                        emitEvent("ble.onScanResult", new HashMap<>(deviceDetails));      // <— add
                        result.success(deviceDetails);
                        ThingHomeSdk.getBleOperator().stopLeScan();
                    }
                });
                break;
            case "getSSID":
                // Uses the WifiManager to return the ssid
                WifiManager wifiManager = (WifiManager) appContext.getSystemService(Context.WIFI_SERVICE);
                WifiInfo wifiInfo;

                wifiInfo = wifiManager.getConnectionInfo();
                if (wifiInfo.getSupplicantState() == SupplicantState.COMPLETED) {
                    String ssid = wifiInfo.getSSID();
                    result.success(ssid);
                }
                break;
            case "updateLocation":
                // setLatAndLong function of Tuya SDK is called
                double updateLat = call.argument("latitude");
                double updateLng = call.argument("longitude");
                ThingSdk.setLatAndLong(String.valueOf(updateLat), String.valueOf(updateLng));
                result.success(null);
                break;
            case "getToken":
                // returns token from getActivatorToken function of the Tuya SDK is called
                Number tokenHomeId = call.argument("homeId");
                ThingHomeSdk.getActivatorInstance().getActivatorToken(tokenHomeId.intValue(),
                        new IThingActivatorGetToken() {

                            @Override
                            public void onSuccess(String token) {
                                result.success(token);
                            }

                            @Override
                            public void onFailure(String s, String s1) {
                                result.error(s, s1, "");
                            }
                        });
                break;
            case "startConfigWiFi":
                // returns the device info from Activator start function of Tuya SDK
                String configSSID = call.argument("ssid");
                String configPassword = call.argument("password");
                String configMode = call.argument("mode");
                Number configTimeOut = call.argument("timeout");
                String configToken = call.argument("token");
                ActivatorBuilder builder = new ActivatorBuilder()
                        .setContext(activity)
                        .setSsid(configSSID)
                        .setPassword(configPassword)
                        .setActivatorModel((configMode.equals("EZ")) ? ActivatorModelEnum.THING_EZ : ActivatorModelEnum.THING_AP)
                        .setTimeOut(configTimeOut.intValue())
                        .setToken(configToken)
                        .setListener(new IThingSmartActivatorListener() {
                            @Override
                            public void onError(String errorCode, String errorMsg) {
                                Map<String, Object> data = new HashMap<>();
                                data.put("errorCode", errorCode);
                                data.put("errorMessage", errorMsg);
                                emitEvent("wifi.onError", data);                 // <— add
                                result.error("CONFIG_ERROR", errorMsg, "");
                            }

                            @Override
                            public void onActiveSuccess(DeviceBean devResp) {
                                HashMap<String, Object> deviceDetails = new HashMap<>();
                                deviceDetails.put("devId", devResp.getDevId());
                                deviceDetails.put("name", devResp.getName());
                                deviceDetails.put("productId", devResp.getProductId());
                                deviceDetails.put("uuid", devResp.getUuid());
                                deviceDetails.put("iconUrl", devResp.getIconUrl());
                                deviceDetails.put("isOnline", devResp.getIsOnline());
                                deviceDetails.put("isCloudOnline", devResp.isCloudOnline());
                                deviceDetails.put("homeId", "not available");
                                deviceDetails.put("roomId", "not available");

                                emitEvent("wifi.onActiveSuccess", new HashMap<>(deviceDetails)); // <— add
                                result.success(deviceDetails);
                                Log.i("Device_Details", deviceDetails.toString());
                            }

                            @Override
                            public void onStep(String step, Object dataObj) {
                                Map<String, Object> data = new HashMap<>();
                                data.put("step", step);
                                if (dataObj != null) data.put("data", String.valueOf(dataObj));
                                emitEvent("wifi.onStep", data);                  // <— add
                                Log.i("ON_STEP", step + ":" + dataObj);
                            }
                         }); 
                mThingActivator = ThingHomeSdk.getActivatorInstance().newActivator(builder);
                mThingActivator.start();
                break;
            case "stopConfigWiFi":
                // calls the Activator stop function of Tuya SDK
                
                if (mThingActivator != null) {
                    mThingActivator.stop();
                    result.success(null);
                } else {
                    result.error("CONFIG_ERROR", "Configurator not started", "");
                }
                break;
            case "connectDeviceAndQueryWifiList":
                // returns the wifi info from the queryDeviceConfigState function of Tuya SDK
                Number apConfigTimeOut = call.argument("timeout");
                ThingApActivatorBuilder apActivatorBuilder = new ThingApActivatorBuilder().setContext(activity);
                IThingOptimizedActivator mThingActivator = ThingHomeSdk.getActivatorInstance().newOptimizedActivator(apActivatorBuilder);

                ApQueryBuilder queryBuilder = new ApQueryBuilder.Builder().setContext(activity).setTimeout(apConfigTimeOut != null ? apConfigTimeOut.intValue() * 1000 : 120).build();
                mThingActivator.queryDeviceConfigState(queryBuilder, new IThingResultCallback<List<WiFiInfoBean>>() {
                    @Override
                    public void onSuccess(List<WiFiInfoBean> resultIB) {
                        // The list of Wi-Fi networks is obtained.
                        result.success(String.valueOf(resultIB.size()));
                        Log.i("WIFI_INFO_BEAN", String.valueOf(resultIB.size()));
                    }

                    @Override
                    public void onError(String errorCode, String errorMessage) {
                        // Failed to get the list of Wi-Fi networks.
                        result.error("WIFI_LIST_ERROR", errorMessage, "");
                    }
                });

                break;
            case "pairBleDevice":

                // returns device info from startActivator function of Tuya SDK
                checkPermission();
                stopAnyPairingOrScan();
                BleActivatorBean bleActivatorBean = new BleActivatorBean();
                Number pairHomeId = call.argument("homeId");
                if (pairHomeId != null) bleActivatorBean.homeId = pairHomeId.intValue();
                bleActivatorBean.uuid = call.argument("uuid");
                bleActivatorBean.productId = call.argument("productId"); // The product ID.

                Number pairDeviceType = call.argument("deviceType");
                if (pairDeviceType != null && pairDeviceType.intValue() != 0) bleActivatorBean.deviceType = pairDeviceType.intValue();
                String pairAddress = call.argument("address");
                if (pairAddress != null) bleActivatorBean.address = pairAddress;

                Number pairDeviceTimeout = call.argument("timeout");
                if (pairDeviceTimeout != null && pairDeviceTimeout.intValue() > 0) bleActivatorBean.timeout = pairDeviceTimeout.intValue() * 1000;
                Number pairDeviceFlag = call.argument("flag");
                if (pairDeviceFlag != null && pairDeviceFlag.intValue() == 9) {
                    result.error("BLE_UNPAIRABLE",
                            "Beacon (flag 9) – pairing not supported", null);
                    return;
                }
                Log.i("Pairing homeId", String.valueOf(pairHomeId));
                mBleActivator = ThingHomeSdk.getActivator().newBleActivator();
                mBleActivator.startActivator(bleActivatorBean, new IBleActivatorListener() {
                    @Override
                    public void onSuccess(DeviceBean deviceBean) {
                        Log.i("Pairing success", deviceBean.getDevId());
                        HashMap<String, Object> deviceDetails = new HashMap<>();
                        deviceDetails.put("devId", deviceBean.getDevId());
                        deviceDetails.put("name", deviceBean.getName());
                        deviceDetails.put("productId", deviceBean.getProductId());
                        deviceDetails.put("uuid", deviceBean.getUuid());
                        deviceDetails.put("iconUrl", deviceBean.getIconUrl());
                        deviceDetails.put("isOnline", deviceBean.getIsOnline());
                        deviceDetails.put("isCloudOnline", deviceBean.isCloudOnline());
                        deviceDetails.put("homeId", "not available");
                        deviceDetails.put("roomId", "not available");
                        deviceDetails.put("mac", deviceBean.getMac());
                        deviceDetails.put("bleType", "Not available");
                        deviceDetails.put("bleProtocolV", "Not available");
                        deviceDetails.put("support5G", "Not available");
                        deviceDetails.put("isProductKey", "Not available");
                        deviceDetails.put("isSupportMutliUserShare", deviceBean.getIsShare());
                        deviceDetails.put("isActive", "Not available");
                        deviceDetails.put("dps", deviceBean.getDps());
                        result.success(deviceDetails);
                        stopAnyPairingOrScan();
                    }

                    @Override
                    public void onFailure(int code, String msg, Object handle) {
                        // Failed to pair the device.
                        Log.i("Pairing failure", msg);
                        result.error("BLE_QUERY_FAILED", msg, "");
                        stopAnyPairingOrScan();
                    }
                });
                break;
            case "startComboPairing":

                // returns device info from startActivator function of Tuya SDK
                checkPermission();
                stopAnyPairingOrScan();
                MultiModeActivatorBean multiModeActivatorBean = new MultiModeActivatorBean();
                multiModeActivatorBean.uuid = call.argument("uuid"); // The UUID of the device.
                multiModeActivatorBean.ssid = call.argument("ssid"); // The SSID of the target Wi-Fi network.
                multiModeActivatorBean.pwd = call.argument("password"); // The password of the target Wi-Fi network.
                String cPairProductId = call.argument("productId");
                Number cPairHomeId = call.argument("homeId");
                if (cPairHomeId != null) multiModeActivatorBean.homeId = cPairHomeId.longValue(); // The value of `homeId` for the current home.

                Number cPairTimeout = call.argument("timeout");
                if (cPairTimeout != null && cPairTimeout.intValue() > 0) multiModeActivatorBean.timeout = cPairTimeout.intValue() * 1000; // The timeout value.

                multiModeActivatorBean.token = call.argument("token"); // The pairing token.
                Number cPairDeviceType = call.argument("deviceType");
                if (cPairDeviceType != null) multiModeActivatorBean.deviceType = cPairDeviceType.intValue(); // The type of device.

                String cPairAddress = call.argument("address");
                if (cPairAddress != null) {
                    multiModeActivatorBean.address = cPairAddress; // The IP address of the device.
                    multiModeActivatorBean.mac = cPairAddress;
                }
                Number cPairDeviceFlag = call.argument("flag");
                if (cPairDeviceFlag != null && cPairDeviceFlag.intValue() == 9) {
                    result.error("BLE_UNPAIRABLE",
                            "Beacon (flag 9) – pairing not supported", null);
                    return;
                }
                mComboActivator = ThingHomeSdk.getActivator().newMultiModeActivator();
                mComboActivator.startActivator(multiModeActivatorBean, new IMultiModeActivatorListener() {
                    @Override
                    public void onSuccess(DeviceBean deviceBean) {
                        HashMap<String, Object> deviceDetails = new HashMap<>();
                        deviceDetails.put("devId", deviceBean.getDevId());
                        deviceDetails.put("name", deviceBean.getName());
                        deviceDetails.put("productId", deviceBean.getProductId());
                        deviceDetails.put("uuid", deviceBean.getUuid());
                        deviceDetails.put("iconUrl", deviceBean.getIconUrl());
                        deviceDetails.put("isOnline", deviceBean.getIsOnline());
                        deviceDetails.put("isCloudOnline", deviceBean.isCloudOnline());
                        deviceDetails.put("homeId", "not available");
                        deviceDetails.put("roomId", "not available");
                        deviceDetails.put("mac", deviceBean.getMac());
                        deviceDetails.put("bleType", "Not available");
                        deviceDetails.put("bleProtocolV", "Not available");
                        deviceDetails.put("support5G", "Not available");
                        deviceDetails.put("isProductKey", "Not available");
                        deviceDetails.put("isSupportMutliUserShare", deviceBean.getIsShare());
                        deviceDetails.put("isActive", "Not available");
                        result.success(deviceDetails);
                    }

                    @Override
                    public void onFailure(int code, String msg, Object handle) {
                        result.error("COMBO_PAIR_FAILED", msg, "");
                        stopAnyPairingOrScan();
                    }
                });
                break;
            case "initDevice":
                // calls the registerDevListener function of Tuya SDK
                String initDeviceId = call.argument("devId");
                IThingDevice mDevice = ThingHomeSdk.newDeviceInstance(initDeviceId);
                mDevice.registerDevListener(new IDevListener() {
                    @Override
                    public void onDpUpdate(String devId, String dpStr) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("devId", devId);
                        data.put("dps", dpStr);
                        emitEvent("device.onDpUpdate", data);           // <— add
                    }
                
                    @Override
                    public void onRemoved(String devId) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("devId", devId);
                        emitEvent("device.onRemoved", data);            // <— add
                    }
                
                    @Override
                    public void onStatusChanged(String devId, boolean online) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("devId", devId);
                        data.put("online", online);
                        emitEvent("device.onStatusChanged", data);      // <— add
                    }
                
                    @Override
                    public void onNetworkStatusChanged(String devId, boolean status) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("devId", devId);
                        data.put("status", status);
                        emitEvent("device.onNetworkStatusChanged", data); // <— add
                    }
                
                    @Override
                    public void onDevInfoUpdate(String devId) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("devId", devId);
                        emitEvent("device.onDevInfoUpdate", data);      // <— add
                    }
                });

                break;
            case "queryDeviceInfo":
                // returns DP details after calling getDpList
                String queryDeviceId = call.argument("devId");
                IThingDevice queryDevice = ThingHomeSdk.newDeviceInstance(queryDeviceId);
                List<String> dpIds = call.argument("dpIds");
                queryDevice.registerDevListener(new IDevListener() {
                    @Override
                    public void onDpUpdate(String devId, String dpStr) {
                        eventSink.success("onDpUpdate:" + dpStr);
                    }

                    @Override
                    public void onRemoved(String devId) {
                        eventSink.success("onRemoved");
                    }

                    @Override
                    public void onStatusChanged(String devId, boolean online) {
                        eventSink.success("onStatusChanged:" + String.valueOf(online));
                    }

                    @Override
                    public void onNetworkStatusChanged(String devId, boolean status) {
                        eventSink.success("onNetworkStatusChanged:" + String.valueOf(status));
                    }

                    @Override
                    public void onDevInfoUpdate(String devId) {
                        eventSink.success("onDevInfoUpdate");
                    }
                });
                queryDevice.getDpList(dpIds, new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        result.error("DEVICE_INFO_FAILED", error, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });

                break;
            case "renameDevice":
                // calls renameDevice of Tuya SDK
                String renameDeviceId = call.argument("devId");
                String renameName = call.argument("name");
                IThingDevice renameDevice = ThingHomeSdk.newDeviceInstance(renameDeviceId);
                renameDevice.renameDevice(renameName, new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        result.error("RENAME_FAILED", error, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });

                break;
            case "removeDevice":
                // removeDevice function of Tuya SDK is called
                String removeDeviceId = call.argument("devId");
                IThingDevice removeDevice = ThingHomeSdk.newDeviceInstance(removeDeviceId);
                removeDevice.removeDevice(new IResultCallback() {
                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("REMOVE_DEVICE_FAILED", errorMsg, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });

                break;
            case "restoreFactoryDefaults":
                // resetFactory function of Tuya SDK is called
                String restoreDeviceId = call.argument("devId");
                IThingDevice restoreDevice = ThingHomeSdk.newDeviceInstance(restoreDeviceId);
                restoreDevice.resetFactory(new IResultCallback() {
                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("RESET_FAILED", errorMsg, "");
                    }

                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }
                });

                break;
            case "queryDeviceWiFiStrength":
                // returns data from requestWifiSignal function of Tuya SDK
                String strengthDeviceId = call.argument("devId");
                IThingDevice strengthDevice = ThingHomeSdk.newDeviceInstance(strengthDeviceId);
                strengthDevice.requestWifiSignal(new WifiSignalListener() {

                    @Override
                    public void onSignalValueFind(String signal) {
                        result.success(signal);
                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("QUERY_STRENGTH_FAILED", errorMsg, "");
                    }
                });
                break;
            case "querySubDeviceList":
                // This functionality not available in Android
                result.error("Sub Device List", "Not available", "");
                break;
            case "getRoomList":
                // retuns a list of room from queryRoomList function of Tuya SDK
                Number getRoomsHomeId = call.argument("homeId");
                ThingHomeSdk.newHomeInstance(getRoomsHomeId.intValue()).queryRoomList(new IThingGetRoomListCallback() {
                    @Override
                    public void onSuccess(List<RoomBean> roomBeans) {
                        Log.i("rooms", String.valueOf(roomBeans.size()));
                        ArrayList<HashMap<String, String>> homeList = new ArrayList<>();

                        for (int j = 0; j < roomBeans.size(); j++) {
                            HashMap<String, String> roomsList = new HashMap<>();
                            roomsList.put("id", String.valueOf(roomBeans.get(j).getRoomId()));
                            roomsList.put("name", String.valueOf(roomBeans.get(j).getName()));
                            //homeRoomIds.add(String.valueOf(roomBeans.getRoomId()));
                            homeList.add(roomsList);
                        }
                        Log.i("rooms added", String.valueOf(homeList.size()));
                        //Log.i("homeList",String.join(",",homeList));
                        result.success(homeList);
                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("ADD_ROOM_FAILED", errorMsg, "");
                    }
                });
                break;
            case "addRoom":
                // addRoom function of Tuya SDK is called
                Number addRoomHomeId = call.argument("homeId");
                String addRoomName = call.argument("roomName");
                ThingHomeSdk.newHomeInstance(addRoomHomeId.intValue()).addRoom(addRoomName, new IThingRoomResultCallback() {
                    @Override
                    public void onSuccess(RoomBean bean) {
                        result.success(null);
                    }

                    @Override
                    public void onError(String errorCode, String errorMsg) {
                        result.error("ADD_ROOM_FAILED", errorMsg, "");
                    }
                });

                break;
            case "removeRoom":
                // removeRoom function of Tuya SDK is called
                Number remRoomHomeId = call.argument("homeId");
                Number remRoomId = call.argument("roomId");
                ThingHomeSdk.newHomeInstance(remRoomHomeId.intValue()).removeRoom(remRoomId.intValue(), new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("REMOVE_ROOM_FAILED", error, "");
                    }
                });

                break;
            case "sortRooms":
                // sortRoom function of Tuya SDK is called
                Number sortRoomHomeId = call.argument("homeId");
                List<Long> sortRoomIds = call.argument("roomIds");
                ThingHomeSdk.newHomeInstance(sortRoomHomeId.intValue()).sortRoom(sortRoomIds, new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("SORT_ROOM_FAILED", error, "");
                    }
                });

                break;
            case "updateRoomName":
                // updateRoom function of Tuya SDK is called
                Number updateRoomId = call.argument("roomId");
                String updateRoomName = call.argument("roomName");
                ThingHomeSdk.newRoomInstance(updateRoomId.intValue()).updateRoom(updateRoomName, new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("UPDATE_ROOM_FAILED", error, "");
                    }
                });

                break;
            case "addDeviceToRoom":
                // addDevie function of Tuya SDK is called
                Number addDevRoomId = call.argument("roomId");
                String addDevRoomDevId = call.argument("devId");
                ThingHomeSdk.newRoomInstance(addDevRoomId.intValue()).addDevice(addDevRoomDevId, new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("ADD_DEVICE_FAILED", error, "");
                    }
                });

                break;
            case "removeDeviceFromRoom":
                // removeDevice function of Tuya SDK is called
                Number remDevRoomId = call.argument("roomId");
                String remDevRoomDevId = call.argument("devId");
                ThingHomeSdk.newRoomInstance(remDevRoomId.intValue()).removeDevice(remDevRoomDevId, new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("REMOVE_DEVICE_FAILED", error, "");
                    }
                });

                break;
            case "addGroupToRoom":
                // addGroup function of Tuya SDK is called
                Number addGroupRoomId = call.argument("roomId");
                Number addGroupId = call.argument("groupId");
                ThingHomeSdk.newRoomInstance(addGroupRoomId.intValue()).addGroup(addGroupId.intValue(), new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("ADD_GROUP_FAILED", error, "");
                    }
                });

                break;
            case "removeGroupFromRoom":
                // removeGroup function of Tuya SDK is called
                Number remGroupRoomId = call.argument("roomId");
                Number remGroupId = call.argument("groupId");
                ThingHomeSdk.newRoomInstance(remGroupRoomId.intValue()).removeGroup(remGroupId.longValue(), new IResultCallback() {
                    @Override
                    public void onSuccess() {
                        result.success(null);
                    }

                    @Override
                    public void onError(String code, String error) {
                        result.error("REMOVE_GROUP_FAILED", error, "");
                    }
                });

                break;
            case "unlockBLELock":
                //bleUnlock function of Tuya SDK is called
                String unlockBLEDevId = call.argument("devId");
                ThingOptimusSdk.init(activity);
                IThingLockManager thingLockManager = ThingOptimusSdk.getManager(IThingLockManager.class);

                IThingBleLockV2 thingLockDevice = thingLockManager.getBleLockV2(unlockBLEDevId);

                thingLockDevice.getCurrentMemberDetail(new IThingResultCallback<BLELockUser>() {
                    @Override
                    public void onSuccess(BLELockUser result1) {
                        Log.i("BLE Lock", "getCurrentMemberDetail:" +result1);
                        // Runs the unlocking task.
                        thingLockDevice.bleUnlock(result1.lockUserId, new IResultCallback() {
                            @Override
                            public void onError(String code, String error) {
                                Log.e("BLE Lock", "bleUnlock onError code:" + code + ", error:" + error);
                                result.error("BLE_UNLOCK_FAILED", error, "");
                            }

                            @Override
                            public void onSuccess() {
                                Log.i("BLE Lock", "bleUnlock onSuccess");
                                result.success(null);
                            }
                        });
                    }

                    @Override
                    public void onError(String code, String error) {
                        Log.e("BLE Lock", "getCurrentMemberDetail onError code:" + code + ", error:" + error);
                        result.error("BLE_UNLOCK_FAILED", error, "");
                    }
                });
                break;
            case "lockBLELock":
                //bleManualLock function of Tuya SDK called
                String lockBLEDevId = call.argument("devId");
                ThingOptimusSdk.init(activity);
                IThingLockManager thingLockManagerBLeLock = ThingOptimusSdk.getManager(IThingLockManager.class);
                IThingBleLockV2 thingLockDeviceBleLock = thingLockManagerBLeLock.getBleLockV2(lockBLEDevId);

                thingLockDeviceBleLock.bleManualLock(new IResultCallback() {
                    @Override
                    public void onError(String code, String error) {
                        Log.e("BLE Lock", "bleManualLock onError code:" + code + ", error:" + error);
                        result.error("BLE_LOCK_FAILED", error, "");
                    }

                    @Override
                    public void onSuccess() {
                        Log.i("BLE Lock", "bleManualLock onSuccess");
                        result.success(null);
                    }
                });
                break;
            case "unlockWifiLock":
                //replyRemoteUnlock function of Tuya SDK is called
                String unlockWifiDevId = call.argument("devId");
                boolean allow=call.argument("allow");
                ThingOptimusSdk.init(activity);
                IThingLockManager thingLockManagerWifiLock = ThingOptimusSdk.getManager(IThingLockManager.class);
                IThingWifiLock thingLockDeviceWifiLock = thingLockManagerWifiLock.getWifiLock(unlockWifiDevId);

                thingLockDeviceWifiLock.replyRemoteUnlock(allow, new IThingResultCallback<Boolean>() {
                    @Override
                    public void onError(String code, String message) {
                        Log.e("WIFI Lock", "reply remote unlock failed: code = " + code + "  message = " + message);
                        result.error("WIFI_UNLOCK_FAILED", message, "");
                    }

                    @Override
                    public void onSuccess(Boolean result1) {
                        Log.i("WIFI Lock", "reply remote unlock success");
                        result.success(null);
                    }
                });
                break;
            //  case "lockWifiLock": {
            //     final String devId = call.argument("devId");
            //     final Boolean confirm = call.argument("confirm");

            //     if (devId == null || devId.isEmpty() || confirm == null) {
            //         result.error("MISSING_ARGS", "devId and confirm are required", null);
            //         break;
            //     }

            //     // Initialize the SDK and get the lock manager
            //     ThingOptimusSdk.init(activity);
            //     IThingLockManager lockManager = ThingOptimusSdk.getManager(IThingLockManager.class);
            //     IVideoLockManager videoLockManager = lockManager.newVideoLockManagerInstance(devId);

            //     if (videoLockManager == null) {
            //         result.error("DEVICE_NOT_FOUND", "IVideoLockManager is null", null);
            //         break;
            //     }

            //     // Lock the device
            //     videoLockManager.remoteLock(
            //         /* isOpen */ false,
            //         /* confirm */ confirm,
            //         new IResultCallback() {
            //             @Override
            //             public void onError(String code, String error) {
            //                 Log.e("WIFI Lock", "remoteLock failed: code=" + code + " error=" + error);
            //                 result.error("WIFI_LOCK_FAILED", error, code);
            //             }

            //             @Override
            //             public void onSuccess() {
            //                 Log.i("WIFI Lock", "remoteLock success");
            //                 result.success(null);
            //             }
            //         }
            //     );
            //     break;
            // case "dynamicWifiLockPassword":
            //     //getDynamicPassword function of Tuya SDK is called
            //     String dynamicPwdDevId = call.argument("devId");
            //     ThingOptimusSdk.init(activity);
            //     IThingLockManager thingLockManagerWifiLockPwd = ThingOptimusSdk.getManager(IThingLockManager.class);
            //     IThingWifiLock thingLockDeviceWifiLockPwd = thingLockManagerWifiLockPwd.getWifiLock(dynamicPwdDevId);
            //     thingLockDeviceWifiLockPwd.getDynamicPassword(new IThingResultCallback<String>() {
            //         @Override
            //         public void onError(String code, String message) {
            //             Log.e("WIFI Lock", "get lock dynamic password failed: code = " + code + "  message = " + message);
            //             result.error("WIFI_DYNAMIC_PASSWORD_FAILED", message, "");
            //         }

            //         @Override
            //         public void onSuccess(String dynamicPassword) {
            //             Log.i("Wifi Lock", "get lock dynamic password success: dynamicPassword = " + dynamicPassword);
            //             result.success(dynamicPassword);
            //         }
            //     });
            //     break;
        
            case "checkIfMatter":
                //isMatter function of Tuya SDK is called
                String checkMatterDevId = call.argument("devId");
                DeviceBean deviceBean = ThingHomeSdk.getDataInstance().getDeviceBean(checkMatterDevId);
                if(deviceBean != null) {
                    boolean isMatter = deviceBean.isMatter();
                    result.success(isMatter);
                }else {
                    result.error("MATTER_CHECK_ERROR","Device not initiated","");
                }
                break;
            case "controlMatter":
                //publishDps function of Tuya SDK is called
                String setDpDevId = call.argument("devId");
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
            case "setRemoteUnlockListener": {
                final String devId = call.argument("devId");

                if (devId == null || devId.isEmpty()) {
                    result.error("MISSING_ARGS", "devId is required", null);
                    break;
                }

                // Initialize the SDK and get the lock manager
                ThingOptimusSdk.init(activity);
                IThingLockManager lockManager = ThingOptimusSdk.getManager(IThingLockManager.class);
                IThingWifiLock wifiLock = lockManager.getWifiLock(devId);

                if (wifiLock == null) {
                    result.error("DEVICE_NOT_FOUND", "IThingWifiLock is null", null);
                    break;
                }

                // Set the remote unlock listener
                wifiLock.setRemoteUnlockListener(new RemoteUnlockListener() {
                    @Override
                    public void onReceive(String devId, int second) {
                        if (second != 0) {
                            Log.i("WIFI Lock", "Remote unlock request received for device: " + devId);
                            Map<String, Object> event = new HashMap<>();
                            event.put("devId", devId);
                            event.put("timeout", second);
                            if (eventSink != null) {
                                eventSink.success(event);
                            }
                        }
                    }
                });

                result.success(null);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void checkPermission() {
        if (ContextCompat.checkSelfPermission(activity, "android.permission.BLUETOOTH_SCAN") != 0 || ContextCompat.checkSelfPermission(activity, "android.permission.ACCESS_FINE_LOCATION") != 0 || ContextCompat.checkSelfPermission(activity, "android.permission.BLUETOOTH_CONNECT") != 0) {
            ActivityCompat.requestPermissions(activity, new String[]{"android.permission.BLUETOOTH_SCAN", "android.permission.ACCESS_FINE_LOCATION", "android.permission.BLUETOOTH_CONNECT"}, 1001);
        }
    }
}
