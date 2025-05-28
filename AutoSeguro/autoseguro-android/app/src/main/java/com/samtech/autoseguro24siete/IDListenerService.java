package com.samtech.autoseguro24siete;

import android.content.Intent;

import com.google.android.gms.iid.InstanceIDListenerService;

// https://github.com/googlesamples/google-services/blob/master/android/gcm/app/src/main/java/gcm/play/android/samples/com/gcmquickstart/MyInstanceIDListenerService.java
public class IDListenerService extends InstanceIDListenerService {
    @Override
    public void onTokenRefresh() {
        // Fetch updated Instance ID token and notify our app's server of any changes (if applicable).
        Intent intent = new Intent(this, RegistrationIntentService.class);
        startService(intent);
    }
}
