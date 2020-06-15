package com.vibes.androidpushdemoapp.notifications;

import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.vibes.androidpushdemoapp.MainApplication;
import com.vibes.vibes.BuildConfig;
import com.vibes.vibes.PushPayloadParser;
import com.vibes.vibes.Vibes;

import java.util.Map;

public class FMS extends FirebaseMessagingService {
    private static final String TAG = "c.v.a.FMS";

    /**
     * @see FMS#onMessageReceived(com.google.firebase.messaging.RemoteMessage)
     */
    @Override
    public void onMessageReceived(RemoteMessage message) {
        PushPayloadParser pushModel = this.createPushPayloadParser(message.getData());
        if (BuildConfig.DEBUG) {
            PayloadWrapper wrapper = new PayloadWrapper(pushModel);
            Log.d(TAG, wrapper.toString());
        }
        // pass the received payload to the handleNotification SDK method. It takes care
        // of displaying the message
        Vibes.getInstance().handleNotification(getApplicationContext(), message.getData());
    }

    /**
     * This is invoked everytime the application generates a new Firebase push
     * token, which is then sent the the Vibes server to be able to target this
     * device with push messages.
     *
     * @param pushToken
     */
    @Override
    public void onNewToken(String pushToken) {
        super.onNewToken(pushToken);
        Log.d(TAG, "Firebase token obtained as " + pushToken);
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putString(MainApplication.TOKEN_KEY, pushToken);
        editor.apply();

        boolean registered = preferences.getBoolean(MainApplication.REGISTERED, false);
        if (registered) {
            MainApplication.registerPush(pushToken);
        }
    }

    public PushPayloadParser createPushPayloadParser(Map<String, String> map) {
        return new PushPayloadParser(map);
    }
}
