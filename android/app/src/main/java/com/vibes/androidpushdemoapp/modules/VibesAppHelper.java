package com.vibes.androidpushdemoapp.modules;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import static com.vibes.androidpushdemoapp.modules.VibesModule.TAG;

public class VibesAppHelper{
    private Context context;

    public  VibesAppHelper(Application context){
        this.context = context;
    }
    
    private Class getMainActivityClass() {
        String packageName = context.getPackageName();
        Intent launchIntent = context.getPackageManager().getLaunchIntentForPackage(packageName);
        String className = launchIntent.getComponent().getClassName();
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    public void invokeApp() {
        try {
            Class<?> activityClass = getMainActivityClass();
            Intent activityIntent = new Intent(context, activityClass);
            activityIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

            context.startActivity(activityIntent);
        } catch(Exception e) {
            Log.e(TAG, "Class not found", e);
            return;
        }
    }
}