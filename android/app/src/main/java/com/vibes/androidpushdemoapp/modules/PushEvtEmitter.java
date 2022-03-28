package com.vibes.androidpushdemoapp.modules;

import android.app.Application;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.vibes.vibes.PushPayloadParser;
import com.vibes.vibes.Vibes;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;
import java.util.Set;

/**
 * Component for emitting events to the Javascript layer.
 */
public class PushEvtEmitter {
    private static final String TAG = "c.v.a.m.PushEvtEmitter";
    private ReactContext mReactContext;
    private VibesAppHelper appHelper;

    public PushEvtEmitter(ReactContext reactContext) {
        mReactContext = reactContext;
        appHelper = new VibesAppHelper((Application) reactContext.getApplicationContext());
    }

    void sendEvent(String eventName, Object params) {
        if (mReactContext.hasActiveCatalystInstance()) {
            mReactContext
                    .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        }
    }

    public void notifyPushReceived(PushPayloadParser bundle) {
        String bundleString = convertJson(bundle.getMap());
        WritableMap params = Arguments.createMap();
        params.putString("payload", bundleString);
        sendEvent("pushReceived", params);
    }

    public void notifyPushOpened(PushPayloadParser bundle) {
        appHelper.invokeApp();
        String bundleString = convertJson(bundle.getMap());
        WritableMap params = Arguments.createMap();
        params.putString("payload", bundleString);
        sendEvent("pushOpened", params);
    }

    String convertJSON(Bundle bundle) {
        try {
            JSONObject json = convertJSONObject(bundle);
            return json.toString();
        } catch (JSONException e) {
            return null;
        }
    }

    String convertJson(Map<String, String> data) {
        String jsonString = null;
        JSONObject json = new JSONObject();
        try {
            for (Map.Entry<String, String> entry : data.entrySet()) {
                if (entry.getKey().equals("client_app_data")) {
                    json.put(entry.getKey(), new JSONObject(entry.getValue()));
                } else if (entry.getKey().equals("client_custom_data")) {
                    json.put(entry.getKey(), new JSONObject(entry.getValue()));
                } else {
                    json.put(entry.getKey(), entry.getValue());
                }
            }
            jsonString = json.toString();
        } catch (Exception e) {
            Log.e(TAG, "Failure converting push message payload to json");
        }
        return jsonString;
    }

    private JSONObject convertJSONObject(Bundle bundle) throws JSONException {
        JSONObject json = new JSONObject();
        Set<String> keys = bundle.keySet();
        for (String key : keys) {
            Object value = bundle.get(key);
            if (value instanceof Bundle) {
                json.put(key, convertJSONObject((Bundle) value));
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                json.put(key, JSONObject.wrap(value));
            } else {
                json.put(key, value);
            }
        }
        return json;
    }
}