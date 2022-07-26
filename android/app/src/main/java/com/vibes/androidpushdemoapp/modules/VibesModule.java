package com.vibes.androidpushdemoapp.modules;


import android.app.Application;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;


import com.vibes.vibes.VibesListener;
import com.vibes.vibes.Vibes;

public class VibesModule extends ReactContextBaseJavaModule {

    public static final String TAG = "VibesSampleModule";
    private VibesAppHelper appHelper;

    public VibesModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
        appHelper = new VibesAppHelper((Application) reactApplicationContext.getApplicationContext());
    }

    @Override
    public String getName() {
        return "VibesModule";
    }

    @ReactMethod
    public void invokeApp(final Promise promise) {
        appHelper.invokeApp();
        promise.resolve(null);;
    }

    /**
    * @param externalPersonId The id to associate with the logged-in person.
    */
    @ReactMethod
    public void associatePerson(final String externalPersonId, final Promise promise) {
            Log.d(TAG, "Associating Person --> " + externalPersonId);
            VibesListener<Void> listener = new VibesListener<Void>() {
                public void onSuccess(Void value) {
                    promise.resolve("Success");;
                }

                public void onFailure(String errorText) {
                    promise.reject("ASSOCIATE_PERSON_ERROR", errorText);
                }
            };
            this.associatePerson(externalPersonId, listener);
    }

    private void associatePerson(String externalPersonId, VibesListener<Void> listener) {
        Vibes.getInstance().associatePerson(externalPersonId, listener);
    }

    @ReactMethod
    public void unregisterPush(final Promise promise) {
        VibesListener<Void> listener = new VibesListener<Void>() {
            public void onSuccess(Void credential) {
                Log.d(TAG, "Unregister push successful");
                promise.resolve("Success");
            }

            public void onFailure(String errorText) {
                Log.d(TAG, "Unregister push failed");
                promise.reject("REGISTER_PUSH_ERROR", errorText);
            }
        };
        Vibes.getInstance().unregisterPush(listener);
    }

    @ReactMethod
    public void registerPush(final Promise promise) {
        String pushToken = appHelper.getPushToken();
        if(pushToken == null ){
            String msg = "Failure registering token with vibes: Token not yet generated";
            Log.d(TAG, msg);
            promise.reject("UNREGISTER_PUSH_ERROR", msg);
            return;
        }
        Log.d(TAG, "Registering push token with vibes");
        Vibes.getInstance().registerPush(pushToken, new VibesListener<Void>() {
            public void onSuccess(Void credential) {
                Log.d(TAG, "Push token registration success");
                promise.resolve("Success");
            }

            public void onFailure(String errorText) {
                Log.d(TAG, "Failure registering token with vibes: " + errorText);
                promise.reject("UNREGISTER_PUSH_ERROR", errorText);
            }
        });
    }
}