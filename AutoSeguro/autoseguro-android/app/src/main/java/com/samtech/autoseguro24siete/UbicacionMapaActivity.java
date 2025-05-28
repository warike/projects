package com.samtech.autoseguro24siete;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.FragmentManager;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

public class UbicacionMapaActivity extends ActionBarActivity {
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    public String Usr, Psw, Usr_Lat, Usr_Lng, idVehiculo, Patente, GPS_Lat, GPS_Lng, app, dToken, corte;
    ProgressBar pbCargando;
    LinearLayout llMapa;
    MarkerOptions mUsuario, mGPS;
    Marker marcadorGPS;
    ArrayList<MarkerOptions> todosGPS = null;
    ArrayList<Marker> todosMarcadores = null;
    float zoomMapa = 14;
    ImageView btnModoEstacionado;
    boolean flagModoEstacionado = false;
    boolean flagCorte = false;
    ProgressDialog progressDialog;
    private int demo;
    private String texto;
    boolean isRegisterded;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_ubicacion_mapa);

        pbCargando = (ProgressBar) findViewById(R.id.pbCargando);
        llMapa = (LinearLayout) findViewById(R.id.llMapa);
        btnModoEstacionado = (ImageView) findViewById(R.id.btn_estacionado_mapa);
        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        //setUpMapIfNeeded();
        // usr,psw, ubicacion_gps, ubicacion_movil

        //demo = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("demo", "0"));

        progressDialog =new ProgressDialog(this);
        progressDialog.setMessage("Cargando");

        app = getResources().getString(R.string.app_ws);
        dToken = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("deviceToken", "");
        isRegisterded = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("isRegistered", false);
        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
            Usr_Lat = b.getString("Usr_Lat", ""); Usr_Lng = b.getString("Usr_Lng", "");
            idVehiculo = b.getString("idVehiculo", ""); Patente = b.getString("Patente", "");
            corte = (b.getString("corte") != null) ? b.getString("corte") : "";
            demo = b.getInt("demo", 0);
            Log.d("UbicacAct", b.toString());
            Log.d("corte", corte);

            if(Usr_Lat.isEmpty() || Usr_Lng.isEmpty()){ // Obtengo las coordenadas del usuario
                gestorGPS miGPS = new gestorGPS(UbicacionMapaActivity.this);
                if(miGPS.puedeObtenerUbicacion()){
                    Usr_Lat = miGPS.obtenerLat()+"";
                    Usr_Lng = miGPS.obtenerLng()+"";
                    if(miGPS.obtenerLat()==0.0 || miGPS.obtenerLng()==0.0) Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_LONG).show();
                }
                else miGPS.mostrarAlertaConfig();
                miGPS.detenerGPS();
            }

            if (demo != 1){
                if(!Patente.isEmpty() && !Usr.isEmpty() && !Psw.isEmpty() && !idVehiculo.isEmpty()){
                    if(Patente.compareToIgnoreCase("Todos los vehículos")==0){
                        //btnModoEstacionado.setVisibility(View.GONE);
                        UbicacionTodosTask utTask = new UbicacionTodosTask(Usr, Psw, Usr_Lat, Usr_Lng);
                        utTask.execute((Void) null);
                    }
                    else{
                        UbicacionTask mTask = new UbicacionTask(Usr, Psw, idVehiculo, Patente, Usr_Lat, Usr_Lng);
                        mTask.execute((Void) null);
                    }
                }
                else {
                    Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_enviado), Toast.LENGTH_LONG).show();
                    finish();
                }
            } else {
                setearMapa(Usr_Lat, Usr_Lng);
            }
        }

        ImageView btnUbicacionUsr = (ImageView) findViewById(R.id.btn_usuario_mapa);
        btnUbicacionUsr.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(Usr_Lat != null && !Usr_Lat.isEmpty() && Usr_Lng != null && !Usr_Lng.isEmpty()){
                    LatLng nuevaPosUsr = new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng));
                    if(mUsuario != null){
                        //mUsuario.position(nuevaPosUsr);
                        if(mMap!=null) mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(nuevaPosUsr, zoomMapa));
                    }
                    else{
                        mUsuario = new MarkerOptions().position(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng))).title("Usuario");
                        if(mMap!=null) {
                            //mMap.addMarker(mUsuario);
                            mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(nuevaPosUsr, zoomMapa));
                        }
                    }
                }
                else Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_usuario), Toast.LENGTH_LONG).show();
            }
        });

        // Accion btn SOS
        DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if(which == DialogInterface.BUTTON_POSITIVE){
                    String lat = "", lng = "";
                    gestorGPS miGPS = new gestorGPS(UbicacionMapaActivity.this);
                    if(miGPS.puedeObtenerUbicacion()){
                        lat = miGPS.obtenerLat()+"";
                        lng = miGPS.obtenerLng()+"";
                        if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                            SOSTask sTask = new SOSTask(Usr, Psw, idVehiculo, Patente, lat, lng);
                            sTask.execute((Void) null);
                        }
                        else {
                            Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_LONG).show();
                            Log.d("MenuActiv", "Lat:"+miGPS.obtenerLat()+" Lng:"+miGPS.obtenerLng());
                        }
                    }
                    else miGPS.mostrarAlertaConfig();
                    miGPS.detenerGPS();
                }
                else if(which == DialogInterface.BUTTON_NEGATIVE){
                    Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_enviado), Toast.LENGTH_LONG).show();
                }
            }
        };

        final AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setMessage(getString(R.string.SOS_pregunta)).setPositiveButton(getString(R.string.SOS_btn_afirmativo), dialogClickListener)
                .setNegativeButton(getString(R.string.SOS_btn_negativo), dialogClickListener);

        ImageView btnSOS = (ImageView) findViewById(R.id.btn_sos);
        btnSOS.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (demo == 1){
                    if (isRegisterded){
                        FragmentManager fm = getFragmentManager();
                        SOSDemoActivity fragment = new SOSDemoActivity();
                        fragment.show(fm,"sosdemo");
                    } else {
                        FragmentManager fm = getFragmentManager();
                        RegistrarDemoActivity fragment = new RegistrarDemoActivity();
                        fragment.show(fm, "registrarDemo");
                    }
                } else {
                    builder.show();
                }
            }
        });

        ImageView btnUbicacionGPS = (ImageView) findViewById(R.id.btn_gps_mapa);
        btnUbicacionGPS.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(GPS_Lat != null && !GPS_Lat.isEmpty() && GPS_Lng != null && !GPS_Lng.isEmpty()){
                    LatLng nuevaPosGPS = new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng));
                    if(mGPS != null){
                        mGPS.position(nuevaPosGPS);
                        marcadorGPS.setPosition(nuevaPosGPS);
                        if(mMap!=null) mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(nuevaPosGPS, zoomMapa));
                    }
                    else{
                        mGPS = new MarkerOptions().position(new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng))).title("Usuario");
                        mGPS.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));
                        if(mMap!=null) {
                            marcadorGPS = mMap.addMarker(mGPS);
                            mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(nuevaPosGPS, zoomMapa));
                        }
                    }
                }
                else Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_GPS), Toast.LENGTH_LONG).show();
            }
        });

        // Seteo la imagen del boton modo estacionado
        if(demo == 1){
            btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.seguridad_block));
        } else {
            btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoestacionado));
        }

        btnModoEstacionado.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (demo == 1){
                    texto = "Recibe notificaciones en linea de los siguientes eventos:\n" +
                            "\n" +
                            "-Encendido de motor\n" +
                            "-Movimiento\n" +
                            "-Desconexión GPS\n" +
                            "-Movimiento dentro del vehículo*\n" +
                            "*Servicio adicional\n" +
                            "\n" +
                            "Para obtener este servicio, es necesario instalar un dispositivo GPS, AutoSeguro 24Siete en su vehículo";
                    generarAlerta("Alertas de Seguridad", texto, false);
                } else {
                    final AlertDialog alertDialog = new AlertDialog.Builder(UbicacionMapaActivity.this).create();
                    alertDialog.setTitle("Activar Modo Estacionado");
                    alertDialog.setMessage("¿Desea Cortar Contacto de vehículo?");
                    alertDialog.setButton(Dialog.BUTTON_NEGATIVE, "NO", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "1", "0");
                            meTask.execute((Void) null);
                            progressDialog.show();
                        }
                    });
                    alertDialog.setButton(Dialog.BUTTON_POSITIVE, "SI", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "1", "1");
                            meTask.execute((Void) null);
                            progressDialog.show();
                        }
                    });
                    if (corte.contentEquals("1") || corte.contentEquals("2")){
                        if (flagModoEstacionado){
                            if (corte.compareToIgnoreCase("0") == 1){
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "0", "1");
                                meTask.execute((Void) null);
                            } else {
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "0", "1");
                                meTask.execute((Void) null);
                            }
                        } else {
                            alertDialog.show();
                        }
                    } else {
                        if(flagModoEstacionado){
                            //Toast.makeText(UbicacionMapaActivity.this, flagModoEstacionado+" desactivar modo sin alert"+" "+corte, Toast.LENGTH_SHORT).show();
                            if (Patente.compareToIgnoreCase("todos los vehículos") == 0){
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "2");
                                meTask.execute((Void) null);
                            } else {
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "0");
                                meTask.execute((Void) null);
                            }
                        }else {
                            //Toast.makeText(UbicacionMapaActivity.this, flagModoEstacionado+" activar modo sin alert"+" "+corte, Toast.LENGTH_SHORT).show();
                            if (Patente.compareToIgnoreCase("todos los vehículos") == 0){
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "3");
                                meTask.execute((Void) null);
                            } else {
                                ModoEstacionadoTask meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "1");
                                meTask.execute((Void) null);
                            }
                        }
                    }
                    //if(flagModoEstacionado) meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "0"); // String Usr, String Psw, String id, String pat, String est
                    //else meTask = new ModoEstacionadoTask(Usr, Psw, idVehiculo, Patente, "1"); // String Usr, String Psw, String id, String pat, String est
                    //meTask.execute((Void) null);
                    Log.d("Patente", Patente);
                }
            }
        });

        setearBarraSuperior();

        if (demo != 1){
            int delay = 0; // retraso
            int period = 30000; // repite cada 30 seg
            Timer timer = new Timer();
            timer.scheduleAtFixedRate(new TimerTask() {
                public void run() {
                    Log.d("UbicMapAct", "Recargando ubicaciones");
                    if(Patente.compareToIgnoreCase("Todos los vehículos")==0){
                        UbicacionTodos2Task utTask = new UbicacionTodos2Task(Usr, Psw, Usr_Lat, Usr_Lng);
                        utTask.execute((Void) null);
                    }
                    else{
                        UbicacionTask2 mTask = new UbicacionTask2(Usr, Psw, idVehiculo, Patente, Usr_Lat, Usr_Lng);
                        mTask.execute((Void) null);
                    }
                }
            }, delay, period);
        }
    }

    public void setearBarraSuperior(){
        ColorDrawable colorDrawable = new ColorDrawable(Color.parseColor("#B71C1C"));
        //Drawable barraSuperior = getResources().getDrawable(R.drawable.top_franja_rojo);
        Drawable barraSuperior = colorDrawable;

        if(barraSuperior != null){
            getSupportActionBar().setBackgroundDrawable(barraSuperior);
            getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM | ActionBar.DISPLAY_HOME_AS_UP);

            View v = getLayoutInflater().inflate(R.layout.barra_superior, null);
            ActionBar.LayoutParams lay = new ActionBar.LayoutParams(ActionBar.LayoutParams.WRAP_CONTENT,ActionBar.LayoutParams.MATCH_PARENT,
                    Gravity.CENTER);
            getSupportActionBar().setCustomView(v, lay);
            TextView titulo = (TextView) v.findViewById(R.id.abTitulo_tv);
            String strTitulo = "";

            ActivityInfo activityInfo = null;
            try {
                activityInfo = getPackageManager().getActivityInfo(getComponentName(), PackageManager.GET_META_DATA);
                strTitulo = activityInfo.loadLabel(getPackageManager()).toString();
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
            titulo.setText(strTitulo);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        //setUpMapIfNeeded();
    }

    /**
     * Sets up the map if it is possible to do so (i.e., the Google Play services APK is correctly
     * installed) and the map has not already been instantiated.. This will ensure that we only ever
     * call {@link #setUpMap()} once when {@link #mMap} is not null.
     * <p/>
     * If it isn't installed {@link SupportMapFragment} (and
     * {@link com.google.android.gms.maps.MapView MapView}) will show a prompt for the user to
     * install/update the Google Play services APK on their device.
     * <p/>
     * A user can return to this FragmentActivity after following the prompt and correctly
     * installing/updating/enabling the Google Play services. Since the FragmentActivity may not
     * have been completely destroyed during this process (it is likely that it would only be
     * stopped or paused), {@link #onCreate(Bundle)} may not be called again so we should call this
     * method in {@link #onResume()} to guarantee that it will be called.
     */
    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.fMapa)).getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                //setUpMap();
            }
        }
    }

    /**
     * This is where we can add markers or lines, add listeners or move the camera. In this case, we
     * just add a marker near Africa.
     * <p/>
     * This should only be called once and when we are sure that {@link #mMap} is not null.
     */
    private void setUpMap() {
        mMap.addMarker(new MarkerOptions().position(new LatLng(0, 0)).title("Marker"));
    }

    private void setearMapa(String Usr_Lat, String Usr_Lng, String GPS_Lat, String GPS_Lng, String tituloMarcador, String textoMarcador) {
        boolean flagMapaCentrado = false;
        if(mMap == null){
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.fMapa)).getMap();

            if(mMap != null){ // Colocar marcadores
                mMap.getUiSettings().setZoomControlsEnabled(true);
            }
        }
        mMap.setMyLocationEnabled(true);
        /*
        if((!Usr_Lat.contentEquals("0.0") && !Usr_Lat.isEmpty())&&(!Usr_Lng.contentEquals("0.0") && !Usr_Lng.isEmpty())) {
            if(mUsuario == null) {
                mUsuario = new MarkerOptions().position(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng))).title("Usuario");
                mUsuario.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE));
                mMap.addMarker(mUsuario);
            }
            else mUsuario.position(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng)));
        }
        else Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_usuario), Toast.LENGTH_LONG).show();
*/
        if((!GPS_Lat.contentEquals("0.0") && !GPS_Lat.isEmpty())&& (!GPS_Lng.contentEquals("0.0") && !GPS_Lng.isEmpty())){
            if(mGPS == null) {
                mGPS = new MarkerOptions().position(new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng))).title(tituloMarcador).snippet(textoMarcador);
                mGPS.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));
                marcadorGPS = mMap.addMarker(mGPS);
            }
            else {
                mGPS.position(new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng)));
                marcadorGPS.setPosition(new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng)));
            }

            mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(Double.parseDouble(GPS_Lat), Double.parseDouble(GPS_Lng)), zoomMapa));
            flagMapaCentrado = true;
        }
        else Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_GPS), Toast.LENGTH_LONG).show();

        if(!flagMapaCentrado) if(mMap!=null && !Usr_Lat.isEmpty() && !Usr_Lng.isEmpty()) mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng)), zoomMapa));
    }


    private void setearMapa(String Latitud, String Longitud) {
        Usr_Lat = Latitud;
        Usr_Lng = Longitud;
        boolean flagMapaCentrado = false;
        if(mMap == null){
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.fMapa)).getMap();

            if(mMap != null){ // Colocar controles
                mMap.getUiSettings().setZoomControlsEnabled(true);
            }
        }

        mMap.setMyLocationEnabled(true);
/*
        if((!Usr_Lat.contentEquals("0.0") && !Usr_Lat.isEmpty())&&(!Usr_Lng.contentEquals("0.0") && !Usr_Lng.isEmpty())) {
            if(mUsuario == null) {
                mUsuario = new MarkerOptions().position(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng))).title("Usuario");
                mUsuario.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE));
                mMap.addMarker(mUsuario);
            }
            else mUsuario.position(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng)));
        }
        else Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_usuario), Toast.LENGTH_LONG).show();
*/
        if(todosGPS != null){
            if(todosGPS.size()>0){
                ArrayList<Marker> marcs = new ArrayList<>();

                for(int x=0;x<todosGPS.size();x++){
                    if(todosMarcadores == null){
                        marcs.add(mMap.addMarker(todosGPS.get(x)));
                    }
                    else{
                        if(x<todosMarcadores.size())todosMarcadores.get(x).setPosition(todosGPS.get(x).getPosition());
                    }
                }
                if(todosMarcadores == null) todosMarcadores = marcs;

                mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(todosGPS.get(0).getPosition(), zoomMapa));
                GPS_Lat = todosGPS.get(0).getPosition().latitude+"";
                GPS_Lng = todosGPS.get(0).getPosition().longitude+"";
                flagMapaCentrado = true;
            }
        }
        else //Toast.makeText(getApplicationContext(), getString(R.string.error_no_ubicacion_GPS), Toast.LENGTH_LONG).show();

        if(!flagMapaCentrado) if(mMap!=null && !Usr_Lat.isEmpty() && !Usr_Lng.isEmpty()) mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(Double.parseDouble(Usr_Lat), Double.parseDouble(Usr_Lng)), zoomMapa));
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_ubicacion, menu);

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.ubicacion_cambiar_tipo_mapa) { // Cambia el tipo de mapa de satelital a mapa y viceversa
            if(mMap.getMapType() == GoogleMap.MAP_TYPE_NORMAL) mMap.setMapType(GoogleMap.MAP_TYPE_HYBRID);
            else mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
            return true;
        }
        else if (id == R.id.ubicacion_recargar_mapa) { // Recarga el mapa actualizando los marcadores de usuario y gps
            gestorGPS miGPS = new gestorGPS(UbicacionMapaActivity.this);
                if(miGPS.puedeObtenerUbicacion()){
                    if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                        if(Patente.compareToIgnoreCase("Todos los vehículos") == 0){
                            UbicacionTodosTask utTask = new UbicacionTodosTask(Usr, Psw, miGPS.obtenerLat()+"", miGPS.obtenerLng()+"");
                            utTask.execute((Void) null);
                        }
                        else{
                            UbicacionTask mTask = new UbicacionTask(Usr, Psw, idVehiculo, Patente, miGPS.obtenerLat()+"", miGPS.obtenerLng()+"");
                            mTask.execute((Void) null);
                        }
                    }
                    else {
                        // Tratar de usar la ubicacion anterior
                        if(Usr_Lat != null && !Usr_Lat.isEmpty() && Usr_Lng != null && !Usr_Lng.isEmpty()){
                            if(Patente.compareToIgnoreCase("Todos los vehículos") == 0){
                                UbicacionTodosTask utTask = new UbicacionTodosTask(Usr, Psw, Usr_Lat, Usr_Lng);
                                utTask.execute((Void) null);
                            }
                            else {
                                UbicacionTask mTask = new UbicacionTask(Usr, Psw, idVehiculo, Patente, Usr_Lat, Usr_Lng);
                                mTask.execute((Void) null);
                            }
                        }
                        else Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_LONG).show();
                    }
                }
                else miGPS.mostrarAlertaConfig();
                miGPS.detenerGPS();
            return true;
        }
        else if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, UbicacionListActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void mostrarCargando(boolean flagMostrar){
        if(pbCargando != null){
            if(flagMostrar) pbCargando.setVisibility(View.VISIBLE);
            else pbCargando.setVisibility(View.GONE);
        }

        if(llMapa != null){
            if(flagMostrar) llMapa.setVisibility(View.GONE);
            else llMapa.setVisibility(View.VISIBLE);
        }
    }

    // Ubicacion Task
    public class UbicacionTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/UltimaUbicacion.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Latitud;
        private final String Longitud;

        UbicacionTask(String Usr, String Psw, String id, String pat, String lat, String lng) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected void onPreExecute() {
            mostrarCargando(true);
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postID = new BasicNameValuePair("id", idVehiculo);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", Patente);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postPatente);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("Ubic.onPostExecute", Resultado);
                boolean exito = false;
                String LatGPS="", LngGPS = "", nombreMark = "", descripMark = "";
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("ubicacion");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    LatGPS = jsonRes.getString("latitud");
                                    LngGPS = jsonRes.getString("longitud");
                                    nombreMark = jsonRes.getString("ubicacion");
                                    descripMark = jsonRes.getString("velocidad")+ " Km/h, "+ jsonRes.getString("fecha")+ " "+ jsonRes.getString("hora");
                                    if(nombreMark == null || nombreMark.isEmpty()) nombreMark = jsonRes.getString("NomPatente");
                                    if(!LatGPS.isEmpty() && LatGPS != null && !LngGPS.isEmpty() && LngGPS != null) exito = true;
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                //mostrarCargando(false);
                if(exito){ // Setear mapa con las coordenadas correspondientes y actualizo las coordenadas
                    setearMapa(Latitud,Longitud,LatGPS,LngGPS, nombreMark, descripMark);
                    Usr_Lat = Latitud;
                    Usr_Lng = Longitud;
                    GPS_Lat = LatGPS;
                    GPS_Lng = LngGPS;

                    estadoModoEstacionadoTask estadoV = new estadoModoEstacionadoTask(Usr, Psw, idVehiculo, Patente);
                    estadoV.execute((Void) null);
                }
                else mostrarCargando(false);
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }
    }

    // Ubicacion Task
    public class UbicacionTask2 extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/UltimaUbicacion.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Latitud;
        private final String Longitud;

        UbicacionTask2(String Usr, String Psw, String id, String pat, String lat, String lng) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postID = new BasicNameValuePair("id", idVehiculo);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", Patente);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postPatente);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("Ubic.onPostExecute", Resultado);
                boolean exito = false;
                String LatGPS="", LngGPS = "", nombreMark = "", descripMark = "";
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("ubicacion");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    LatGPS = jsonRes.getString("latitud");
                                    LngGPS = jsonRes.getString("longitud");
                                    nombreMark = jsonRes.getString("ubicacion");
                                    descripMark = jsonRes.getString("velocidad")+ " Km/h, "+ jsonRes.getString("fecha")+ " "+ jsonRes.getString("hora");
                                    if(nombreMark == null || nombreMark.isEmpty()) nombreMark = jsonRes.getString("NomPatente");
                                    if(!LatGPS.isEmpty() && LatGPS != null && !LngGPS.isEmpty() && LngGPS != null) exito = true;
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                //mostrarCargando(false);
                if(exito){ // Setear mapa con las coordenadas correspondientes y actualizo las coordenadas
                    setearMapa(Latitud,Longitud,LatGPS,LngGPS, nombreMark, descripMark);
                    Usr_Lat = Latitud;
                    Usr_Lng = Longitud;
                    GPS_Lat = LatGPS;
                    GPS_Lng = LngGPS;
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }
    }

    // Hilos para llamar a los WS
    // Modo estacionado Task
    public class ModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Estado;
        private final String corta_corr;

        ModoEstacionadoTask(String Usr, String Psw, String id, String pat, String est, String corta_corr) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
            if(Estado.compareTo("1") == 0) {
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "1").commit();
            }
            else {
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "0").commit();
            }
            this.corta_corr = corta_corr;
        }

        ModoEstacionadoTask(String Usr, String Psw, String id, String pat, String est) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
            if(Estado.compareTo("1") == 0) {
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "1").commit();
            }
            else {
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "0").commit();
            }
            this.corta_corr = "";
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postID = new BasicNameValuePair("id", idVehiculo);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", Patente);
            BasicNameValuePair postEstado = new BasicNameValuePair("estado", Estado);
            BasicNameValuePair postApp = new BasicNameValuePair("app", app);
            BasicNameValuePair postdToken = new BasicNameValuePair("dtoken", dToken);
            BasicNameValuePair postCortaCorr = new BasicNameValuePair("corta_corr", corta_corr);


            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            //datosPost.add(postID);
            //datosPost.add(postPatente);
            datosPost.add(postEstado);
            datosPost.add(postApp);
            datosPost.add(postdToken);
            if (corta_corr != ""){
                datosPost.add(postCortaCorr);
            }
            if (Estado.compareTo("0") == 0 || Estado.compareTo("1") == 0){
                Log.d("DatosPost.add", Estado);
                datosPost.add(postID);
                datosPost.add(postPatente);
            }

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                if (progressDialog.isShowing()){
                    progressDialog.dismiss();
                }
                Log.d("ModoEst.onPostExecute", Resultado);
                boolean exito = false;

                //{"ME":[{"mensaje" : "Modo estacionado"}]}
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("ME");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    String resultadoModoEstacionado = jsonRes.getString("mensaje");
                                    Toast.makeText(getApplicationContext(), resultadoModoEstacionado, Toast.LENGTH_LONG);
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            if(resultadoModoEstacionado.compareToIgnoreCase("Modo estacionado activado") == 0 && Estado.compareTo("1") == 0) exito = true;
                                            else if(resultadoModoEstacionado.compareToIgnoreCase("Modo estacionado desactivado") == 0 && Estado.compareTo("0") == 0) exito = true;
                                            else exito = false;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(exito) { // Cambiar el boton segun el estado mostrado
                    if(Estado.compareTo("1") == 0 || Estado.compareTo("3") == 0) {
                        btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoestacionado_activado));
                        flagModoEstacionado = true;
                        //PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "1").commit();
                    }
                    else {
                        btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoestacionado));
                        flagModoEstacionado = false;
                        //PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "0").commit();
                    }
                }
                else Toast.makeText(getApplicationContext(), getString(R.string.error_cambiar_modo_estacionado), Toast.LENGTH_SHORT).show();
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }


    public class estadoModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/EstadoVehiculo.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;

        estadoModoEstacionadoTask(String Usr, String Psw, String id, String pat) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postID = new BasicNameValuePair("id", idVehiculo);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", Patente);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postPatente);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("ModoEst.onPostExecute", Resultado);
                boolean exito = false;
                String EstadoVeh = "";

                //{"ME":[{"mensaje" : "Modo estacionado"}]}
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("estadovehiculo");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    String resultadoModoEstacionado = jsonRes.getString("estado");
                                    String resultadoCorte = jsonRes.getString("corte");
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            EstadoVeh = resultadoModoEstacionado;
                                            exito = true;
                                        }
                                    }
                                    if (resultadoCorte != null){
                                        if (!resultadoCorte.isEmpty()){
                                            if (resultadoCorte.compareToIgnoreCase("1")==0){
                                                flagCorte = true;
                                                if (corte == "") corte = "1";
                                            }
                                            else {
                                                flagCorte = false;
                                                if (corte == "") corte="0";
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                mostrarCargando(false);
                if(exito) { // Cambiar el boton segun el estado mostrado
                    if(EstadoVeh.compareToIgnoreCase("1") == 0) {
                        if(btnModoEstacionado!=null) btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoestacionado_activado));
                        flagModoEstacionado = true;
                    }
                    else {
                        if(btnModoEstacionado!=null) btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoestacionado));
                        flagModoEstacionado = false;
                    }
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }

    public class UbicacionTodosTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/DatosporFlota.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Latitud;
        private final String Longitud;

        UbicacionTodosTask(String Usr, String Psw, String lat, String lng) {
            ilogin = Usr;
            ipassword = Psw;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected void onPreExecute() {
            mostrarCargando(true);
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("Ubic.onPostExecute", Resultado);
                boolean exito = false;
                String LatGPS="", LngGPS = "";
                todosGPS = new ArrayList<>();

                /*{"DatoFlota":[{"Modelo" : "NISSAN","Patente" : "GSRT52","Ignicion" : "Encendido","Velocidad" : "0",
                "Ubicacion" : "A 0 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:25:16","Latitud" : "-33.352245",
                "Longitud" : "-70.508320","NomPatente" : "","Estado" : "1","GPS" : "G280"},{"Modelo" : "FIAT","Patente" : "GSVT56",
                "Ignicion" : "Encendido","Velocidad" : "0","Ubicacion" : "A 0 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:04:26",
                "Latitud" : "-33.352391","Longitud" : "-70.508422","NomPatente" : "Luis","Estado" : "1","GPS" : "G281"},
                {"Modelo" : "JEEP","Patente" : "HCKR20","Ignicion" : "Encendido","Velocidad" : "0",
                "Ubicacion" : "A 0.1 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:35:49","Latitud" : "-33.351791","Longitud" : "-70.508251",
                "NomPatente" : "Jorge","Estado" : "0","GPS" : "G279"}]}*/
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("DatoFlota");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonRes = jsonArr.getJSONObject(i);
                                    if(jsonRes!=null){
                                        String nombreMark = jsonRes.getString("Ubicacion");
                                        String descripMark = jsonRes.getString("Velocidad")+ " Km/h, "+ jsonRes.getString("Fecha");
                                    /*if(jsonRes.getString("NomPatente").isEmpty()) nombreMark = jsonRes.getString("Patente");
                                    else nombreMark = jsonRes.getString("NomPatente");*/
                                        if(nombreMark == null || nombreMark.isEmpty()) nombreMark = jsonRes.getString("NomPatente");
                                        MarkerOptions m = new MarkerOptions().position(new LatLng(Double.parseDouble(jsonRes.getString("Latitud")), Double.parseDouble(jsonRes.getString("Longitud")))).title(nombreMark).snippet(descripMark);
                                        todosGPS.add(m);
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mostrarCargando(false);
                if(todosGPS!= null ){
                    if(todosGPS.size()>0){
                        setearMapa(Latitud,Longitud);
                    }
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }
    }

    // SOS Task
    public class SOSTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/AlarmaSOS.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Latitud;
        private final String Longitud;

        SOSTask(String Usr, String Psw, String id, String pat, String lat, String lng) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postLat = new BasicNameValuePair("latitud", Latitud);
            BasicNameValuePair postLng = new BasicNameValuePair("longitud", Longitud);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postLat);
            datosPost.add(postLng);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("ModoEst.onPostExecute", Resultado);
                String mensaje = "";

                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("SOS");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    mensaje = jsonRes.getString("mensaje");
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(!mensaje.isEmpty()) Toast.makeText(getApplicationContext(), mensaje, Toast.LENGTH_LONG).show();
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }

    // Usado para recargar la posicion de todos los gps, no puede modificar las vistas
    public class UbicacionTodos2Task extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/DatosporFlota.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Latitud;
        private final String Longitud;

        UbicacionTodos2Task(String Usr, String Psw, String lat, String lng) {
            ilogin = Usr;
            ipassword = Psw;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);

            try {
                // Creando el POST request con los datos.
                UrlEncodedFormEntity urlEncodedFormEntity = new UrlEncodedFormEntity(datosPost);
                httpPost.setEntity(urlEncodedFormEntity);

                try {
                    // Se ejecuta el post por medio de http
                    HttpResponse httpResponse = httpClient.execute(httpPost);

                    // Se obtiene el resultado de la request
                    InputStream inputStream = httpResponse.getEntity().getContent();
                    InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                    BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
                    StringBuilder stringBuilder = new StringBuilder();
                    String bufferedStrChunk = null;

                    // Se crea un string con el resultado de la request
                    while((bufferedStrChunk = bufferedReader.readLine()) != null){
                        stringBuilder.append(bufferedStrChunk);
                    }

                    // Se retorna el String para ser procesado en onPostExecute
                    return stringBuilder.toString();

                } catch (ClientProtocolException cpe) {
                    System.out.println("Excepcion de HttpResponse :" + cpe);
                    cpe.printStackTrace();
                } catch (IOException ioe) {
                    System.out.println("Excepcion de HttpResponse :" + ioe);
                    ioe.printStackTrace();
                }
            } catch (UnsupportedEncodingException uee) {
                System.out.println("Excepcion de UrlEncodedFormEntity:" + uee);
                uee.printStackTrace();
            }

            return null;
        }

        @Override
        protected void onPostExecute(String Resultado){
            if(Resultado!=null){
                Log.d("Ubic.onPostExecute", Resultado);
                boolean exito = false;
                String LatGPS="", LngGPS = "";
                todosGPS = new ArrayList<>();

                /*{"DatoFlota":[{"Modelo" : "NISSAN","Patente" : "GSRT52","Ignicion" : "Encendido","Velocidad" : "0",
                "Ubicacion" : "A 0 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:25:16","Latitud" : "-33.352245",
                "Longitud" : "-70.508320","NomPatente" : "","Estado" : "1","GPS" : "G280"},{"Modelo" : "FIAT","Patente" : "GSVT56",
                "Ignicion" : "Encendido","Velocidad" : "0","Ubicacion" : "A 0 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:04:26",
                "Latitud" : "-33.352391","Longitud" : "-70.508422","NomPatente" : "Luis","Estado" : "1","GPS" : "G281"},
                {"Modelo" : "JEEP","Patente" : "HCKR20","Ignicion" : "Encendido","Velocidad" : "0",
                "Ubicacion" : "A 0.1 Km. de Oficina Proseguridad","Fecha" : "06/09/2015 21:35:49","Latitud" : "-33.351791","Longitud" : "-70.508251",
                "NomPatente" : "Jorge","Estado" : "0","GPS" : "G279"}]}*/
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("DatoFlota");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonRes = jsonArr.getJSONObject(i);
                                    if(jsonRes!=null){
                                        String nombreMark = jsonRes.getString("Ubicacion");
                                        String descripMark = jsonRes.getString("Velocidad")+ " Km/h, "+ jsonRes.getString("Fecha");
                                    /*if(jsonRes.getString("NomPatente").isEmpty()) nombreMark = jsonRes.getString("Patente");
                                    else nombreMark = jsonRes.getString("NomPatente");*/
                                        if(nombreMark == null || nombreMark.isEmpty()) nombreMark = jsonRes.getString("NomPatente");
                                        MarkerOptions m = new MarkerOptions().position(new LatLng(Double.parseDouble(jsonRes.getString("Latitud")), Double.parseDouble(jsonRes.getString("Longitud")))).title(nombreMark).snippet(descripMark);
                                        todosGPS.add(m);
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if(todosGPS!= null ){
                    if(todosGPS.size()>0){
                        setearMapa(Latitud,Longitud);
                    }
                }
            }
        }
    }

    public void generarAlerta(String titulo, String mensaje, final boolean esRespuesta){
        if(esRespuesta){

        } else {
            FragmentManager fm = getFragmentManager();
            PopupWindows fragment = new PopupWindows();
            Bundle bundle = new Bundle();
            bundle.putString("titulo", titulo);
            bundle.putString("texto", mensaje);
            fragment.setArguments(bundle);
            fragment.show(fm,"popupwindow");
        }
    }
}
