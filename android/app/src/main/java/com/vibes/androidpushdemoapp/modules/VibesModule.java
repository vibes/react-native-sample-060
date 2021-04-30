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

    public static final String TAG = "c.v.a.m.Vibes";
    private VibesAppHelper appHelper;

    public VibesModule(ReactApplicationContext reactApplicationContext) {
        super(reactApplicationContext);
        appHelper = new VibesAppHelper((Application) reactApplicationContext.getApplicationContext());
    }

    @Override
    public String getName() {
        return "Vibes";
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
                    promise.resolve(null);;
                }

                public void onFailure(String errorText) {
                    promise.reject("ASSOCIATE_PERSON_FAILED", errorText);
                }
            };
            this.associatePerson(externalPersonId, listener);
    }

    private void associatePerson(String externalPersonId, VibesListener<Void> listener) {
        Vibes.getInstance().associatePerson(externalPersonId, listener);
    }
}