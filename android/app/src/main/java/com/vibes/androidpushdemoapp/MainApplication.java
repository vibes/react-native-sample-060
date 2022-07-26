package com.vibes.androidpushdemoapp;

import android.app.Application;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;

import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.facebook.soloader.SoLoader;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.InstanceIdResult;
import com.vibes.androidpushdemoapp.modules.VibesPackage;
import com.vibes.vibes.Credential;
import com.vibes.vibes.Vibes;
import com.vibes.vibes.VibesConfig;
import com.vibes.vibes.VibesListener;

import java.util.Arrays;
import java.util.List;
import static com.vibes.androidpushdemoapp.modules.VibesModule.TAG;


public class MainApplication extends Application implements ReactApplication {

    public static final String REGISTERED = "REGISTERED";
    public static final String TOKEN_KEY = "c.v.a.PushToken";
    public static final String VIBES_APPID_KEY = "com.vibes.androidpushdemoapp.appId";
    public static final String VIBES_APIURL_KEY = "com.vibes.androidpushdemoapp.apiUrl";

    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }

        @Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new VibesPackage()
            );
        }

        @Override
        protected String getJSMainModuleName() {
            return "index";
        }
    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
        /**
         * This initializes the Vibes SDK
         */
        this.initialize();
    }

    private void initialize() {
        FirebaseInstanceId.getInstance().getInstanceId()
                .addOnSuccessListener(
                        new OnSuccessListener<InstanceIdResult>() {
                            @Override
                            public void onSuccess(InstanceIdResult instanceIdResult) {
                                String instanceToken = instanceIdResult.getToken();
                                if (instanceToken != null) {
                                    SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(MainApplication.this);
                                    SharedPreferences.Editor editor = preferences.edit();
                                    editor.putString(MainApplication.TOKEN_KEY, instanceToken);
                                    editor.apply();
                                    Log.d(TAG, "Push token obtained from FirebaseInstanceId --> " + instanceToken);
                                }
                            }
                        }
                )
                .addOnFailureListener(
                        new OnFailureListener() {
                            @Override
                            public void onFailure(Exception e) {
                                Log.d(TAG, "Failed to fetch token from FirebaseInstanceId: " + e.getLocalizedMessage());
                            }
                        }
                );

        if (BuildConfig.DEBUG) Log.d(TAG, "Initializing Vibes SDK");

        String env = null;
        String appId = null;
        String apiUrl = null;
        try {
            ApplicationInfo ai = super.getApplicationContext().getPackageManager()
                    .getApplicationInfo(super.getApplicationContext().getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            appId = bundle.getString(VIBES_APPID_KEY);
            apiUrl = bundle.getString(VIBES_APIURL_KEY);
            Log.d(TAG, "Vibes parameters are : appId=[" + appId + "], appUrl=[" + apiUrl + "]");

        } catch (PackageManager.NameNotFoundException ex) {

        }
        if (appId == null || appId.isEmpty()) {
            throw new IllegalStateException("No appId provided in manifest under name [" + VIBES_APPID_KEY + "]");
        }
        if (apiUrl == null || apiUrl.isEmpty()) {
            throw new IllegalStateException("No appId provided in manifest under name [" + VIBES_APIURL_KEY + "]");
        }

        VibesConfig config = new VibesConfig.Builder().setApiUrl(apiUrl).setAppId(appId).build();
        Vibes.initialize(super.getApplicationContext(), config);
        Vibes.getInstance().registerDevice(new VibesListener<Credential>() {
            public void onSuccess(Credential credential) {
                SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(MainApplication.this);
                SharedPreferences.Editor editor = preferences.edit();
                editor.putBoolean(MainApplication.REGISTERED, true);
                editor.apply();
                String deviceId = credential.getDeviceID();
                Log.d(TAG, "Device id obtained is --> " + deviceId);
                String pushToken = preferences.getString(MainApplication.TOKEN_KEY, null);
                if (pushToken == null) {
                    Log.d(TAG, "Token not yet available. Skipping registerPush");
                    return;
                }
                Log.d(TAG, "Token found after registering device. Attempting to register push token");
                registerPush(pushToken);
            }

            public void onFailure(String errorText) {
                Log.e(TAG, "Failure registering device with vibes: " + errorText);
            }
        });

    }

    /**
     * To be able to target each device, we need to send the push token generated by the Firebase environment to the
     * server-side via the SDK. However, ensure that {@link Vibes#registerDevice()} has been called before this is called.
     *
     * @param pushToken
     */
    public static void registerPush(String pushToken) {
        Log.d(TAG, "Registering push token with vibes");
        Vibes.getInstance().registerPush(pushToken, new VibesListener<Void>() {
            public void onSuccess(Void credential) {
                Log.d(TAG, "Push token registration success");
            }

            public void onFailure(String errorText) {
                Log.d(TAG, "Failure registering token with vibes: " + errorText);
            }
        });
    }

}
