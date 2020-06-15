package com.vibes.androidpushdemoapp.notifications;

import android.content.Context;
import android.content.Intent;

import com.vibes.androidpushdemoapp.MainActivity;
import com.vibes.vibes.PushPayloadParser;
import com.vibes.vibes.Vibes;
import com.vibes.vibes.VibesReceiver;

public class SampleReceiver extends VibesReceiver {

    @Override
    protected void onPushOpened(Context context, PushPayloadParser pushModel) {
        super.onPushOpened(context, pushModel);


        // this causes the app to open when new push messages are received and app is in the background
        Intent mainActivityIntent = new Intent(context, MainActivity.class);
        mainActivityIntent.putExtra(Vibes.VIBES_REMOTE_MESSAGE_DATA, pushModel.getMap());
        context.startActivity(mainActivityIntent);
    }
}
