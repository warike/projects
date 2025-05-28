package com.samtech.autoseguro24siete;

import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GcmListenerService;

//https://github.com/googlesamples/google-services/blob/master/android/gcm/app/src/main/java/gcm/play/android/samples/com/gcmquickstart/MyGcmListenerService.java
public class GCMListenerService extends GcmListenerService {
    private static final String TAG = "GCMListenerService";

    @Override
    public void onMessageReceived(String from, Bundle data) {
        String mensaje = data.getString("Mensaje", "");
        String titulo = data.getString("Titulo", "");
        String idVehiculo = data.getString("idVehiculo", "");
        String patente = data.getString("Patente", "");
        Log.d(TAG, data.toString());
        crearNotificacion(titulo, mensaje, idVehiculo, patente);
        super.onMessageReceived(from, data);
    }

    public void crearNotificacion(String Titulo, String Mensaje, String idVehiculo, String Patente){
        Intent intent = null;
        if(!idVehiculo.isEmpty()){
            intent = new Intent(this, UbicacionMapaActivity.class);
            intent.putExtra("Usr", PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoUsr", ""));
            intent.putExtra("Password", PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPsw", ""));
            intent.putExtra("idVehiculo", idVehiculo);
            intent.putExtra("Patente", Patente);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        }
        PendingIntent pendingIntent = null;
        if(!idVehiculo.isEmpty()) pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent, PendingIntent.FLAG_ONE_SHOT);
        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = (NotificationCompat.Builder) new NotificationCompat.Builder(this)
                .setSmallIcon(R.mipmap.icon_notif)
                /*.setLargeIcon(R.mipmap.ic_launcher)*/
                .setContentTitle(Titulo)
                /*.setColor()*/
                .setContentText(Mensaje)
                .setAutoCancel(true)
                .setSound(defaultSoundUri);
        if(!idVehiculo.isEmpty()) notificationBuilder.setContentIntent(pendingIntent);

        if(android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) notificationBuilder.setColor(0xB71C1C);
        Log.d("GCM", Build.VERSION.SDK_INT+"");
        Log.d("GCM", android.os.Build.VERSION.SDK_INT+"");

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
}