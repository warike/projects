package com.samtech.autoseguro24siete;

import android.app.AlertDialog;
import android.app.Service;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;

import com.samtech.autoseguro24siete.R;

public class gestorGPS extends Service implements LocationListener {

    private final Context ctx;

    // flag para el estado del GPS
    boolean GPSDisponible = false;

    // flag para el estado de la red
    boolean RedDisponible = false;

    // flag para obtener ubicacion
    boolean flagUbicacion = false;

    Location location; // ubicacion
    double lat; // latitud
    double lng; // longitud

    // La distancia minima para actualizar la ubicacion
    private static final long DISTANCIA_MIN = 10; // 10 mts

    // El tiempo minimo entre actualizaciones en ms
    private static final long TIEMPO_MIN = 1000 * 60 * 1; // 1 min

    // Declaring a Location Manager
    protected LocationManager locationManager;

    public gestorGPS(Context context) {
        this.ctx = context;
        obtenerUbicacion();
    }

    public Location obtenerUbicacion() {
        try {
            locationManager = (LocationManager) ctx.getSystemService(LOCATION_SERVICE);
            GPSDisponible = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            RedDisponible = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

            if (!GPSDisponible && !RedDisponible) {
                // ningun proveedor esta activo
            } else {
                this.flagUbicacion = true;
                // Intenta obtener la ubicacion usando el proveedor de red
                if (RedDisponible) {
                    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER, TIEMPO_MIN, DISTANCIA_MIN, this);
                    Log.d("gestorGPS.obtenerUbic", "Utilizando Red");
                    if (locationManager != null) {
                        location = locationManager
                                .getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                        if (location != null) {
                            lat = location.getLatitude();
                            lng = location.getLongitude();
                        }
                    }
                }
                // Si el gps esta disponible obtiene lat y lng
                if (GPSDisponible) {
                    if (location == null) {
                        locationManager.requestLocationUpdates( LocationManager.GPS_PROVIDER, TIEMPO_MIN, DISTANCIA_MIN, this);
                        Log.d("gestorGPS.obtenerUbic", "Utilizando GPS");
                        if (locationManager != null) {
                            location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                            if (location != null) {
                                lat = location.getLatitude();
                                lng = location.getLongitude();
                            }
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return location;
    }

    public void detenerGPS(){
        if(locationManager != null){
            locationManager.removeUpdates(gestorGPS.this);
        }
    }

    public double obtenerLat(){
        if(location != null){
            lat = location.getLatitude();
        }
        return lat;
    }

    public double obtenerLng(){
        if(location != null){
            lng = location.getLongitude();
        }
        return lng;
    }

    public boolean puedeObtenerUbicacion() {
        return this.flagUbicacion;
    }

    // Muestra un alert para ir a la configuracion del gps
    public void mostrarAlertaConfig(){
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(ctx);
        alertDialog.setTitle(ctx.getString(R.string.titulo_conf_GPS));
        alertDialog.setMessage(ctx.getString(R.string.pregunta_gps_inactivo));

        // Muestra la configuración en caso afirmativo
        alertDialog.setPositiveButton(ctx.getString(R.string.GPS_btn_afirmativo), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog,int which) {
                Intent intent = new Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS);
                ctx.startActivity(intent);
            }
        });
        alertDialog.setNegativeButton(ctx.getString(R.string.GPS_btn_negativo), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                Toast.makeText(ctx, ctx.getString(R.string.SOS_no_enviado), Toast.LENGTH_LONG).show();
                dialog.cancel();
            }
        });
        alertDialog.show();
    }

    @Override
    public void onLocationChanged(Location location) {
    }

    @Override
    public void onProviderDisabled(String provider) {
    }

    @Override
    public void onProviderEnabled(String provider) {
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
    }

    @Override
    public IBinder onBind(Intent arg0) {
        return null;
    }

}