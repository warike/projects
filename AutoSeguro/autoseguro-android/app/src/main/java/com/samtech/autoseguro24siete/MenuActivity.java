package com.samtech.autoseguro24siete;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.FragmentManager;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;

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

public class MenuActivity extends Activity {
    int tipoUsr = 0, contador=0, estadoVeh = -1, estadoControlVelocidad = -1, estadoControldeUso = -1, demo;
    String idVehiculo, patenteVehiculo, Usr, Password, bPlan;
    ImageView btnModoEstacionado, btnVelMax;
    boolean flagModoEstacionado = false, flagControlVelocidad = false, flagControldeUso = false;
    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    private static final String TAG = "MenuActivity";
    public static final String tknEnviado = "TokenEnviado";
    public static final String regCompletado = "RegistracionCompleta";
    public static final String devID = "deviceToken";
    ProgressDialog progressDialog;
    private BroadcastReceiver mRegBroadcastRec;
    private String texto;
    private ImageView btnHistorial;
    private boolean isRegistered, activado;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.d("MenuActivity", "onCreate");
        super.onCreate(savedInstanceState);
        /*Bundle b = getIntent().getExtras();
        String bPlan = b.getString("tipoPlan", "");
        tipoUsr = Integer.parseInt(b.getString("tipoUsuario", "0"));*/
        Usr = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoUsr", "");
        Password = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPsw", "");
        tipoUsr = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoTipo", "0"));
        bPlan = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPlan", "");
        estadoVeh = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoVehAsignado", "-1"));
        estadoControlVelocidad = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoControl", "-1"));
        estadoControldeUso = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoControlUso", "-1"));
        demo = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("demo", "0"));
        isRegistered = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("isRegistered", false);
        idVehiculo = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("VehAsignado", "");
        patenteVehiculo = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("patenteVehAsignado", "");
        activado = false;
        /*Log.d("MenuActivity", patenteVehiculo);
        if(bPlan.isEmpty()) {
            tipoUsr = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoTipo", "0"));
            bPlan = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPlan", "");
        }*/

        // Establece el modo estacionado
        if(estadoVeh == 0) flagModoEstacionado = false;
        else if(estadoVeh == 1) flagModoEstacionado = true;

        // Establece el Control de Velocidad
        if(estadoControlVelocidad == 0) flagControlVelocidad = false;
        else if(estadoControlVelocidad == 1) flagControlVelocidad = true;


        // Setea la vista
        setContentView(R.layout.activity_menu);
        // Instanciando los botones
        btnModoEstacionado = (ImageView) findViewById(R.id.btnEstacionado);
        btnVelMax = (ImageView) findViewById(R.id.btnVelMax);
        btnHistorial = (ImageView) findViewById(R.id.btnHistorial);

        if (demo == 1) {
            btnModoEstacionado.setImageResource(R.drawable.boton_modoe_bloqueado);
            btnHistorial.setImageResource(R.drawable.historial_block);
        }

        mRegBroadcastRec = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences.getBoolean(tknEnviado, false);
                /*if (sentToken) {
                    mInformationTextView.setText(getString(R.string.gcm_send_message));
                } else {
                    mInformationTextView.setText(getString(R.string.token_error_message));
                }*/
            }
        };

        if (checkPlayServices() && demo != 1) {
            // Start IntentService to register this application with GCM.
            Intent intent = new Intent(this, RegistrationIntentService.class);
            Log.d("MenuActiv", "Existe Play Services");
            startService(intent);
        }

        // Seteo la imagen del boton modo estacionado
        if(flagControlVelocidad) btnVelMax.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_velocidad_activado));
        else btnVelMax.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_velocidad_desactivado));

        // Seteo la accion del boton
        btnModoEstacionado.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
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
                    Intent in;
                /*if(bPlan.compareToIgnoreCase("masivo")==0){
                    in = new Intent(MenuActivity.this, ModoEstacionadoActivity.class);
                }
                else in = new Intent(MenuActivity.this, ControlUsoActivity.class);*/

                    if(bPlan.compareToIgnoreCase("masivo")==0){
                        in = new Intent(MenuActivity.this, ModoEstacionadoActivity.class);
                    }
                    else {
                        if(tipoUsr == 1) in = new Intent(MenuActivity.this, ControlUsoActivity.class);
                        else in = new Intent(MenuActivity.this, ModoEstacionadoActivity.class);
                    }

                    in.putExtra("Usr", Usr);
                    in.putExtra("Password", Password);
                    startActivity(in);
                }
            }
        });

        // Seteo la accion del boton
        btnVelMax.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (demo == 1) {

                    if (activado) {
                        btnVelMax.setImageResource(R.drawable.boton_velocidad_desactivado);
                        activado = false;

                    } else {
                        btnVelMax.setImageResource(R.drawable.boton_velocidad_activado);
                        activado = true;
                        Toast.makeText(MenuActivity.this, "Recibirás notificaciones cuando el vehículo " +
                                "supere el límite de velocidad establecido", Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Intent ctrl_velocidad = new Intent(MenuActivity.this, ControlVelocidadActivity.class);
                    ctrl_velocidad.putExtra("Usr", Usr);
                    ctrl_velocidad.putExtra("Psw", Password);
                    startActivity(ctrl_velocidad);
                }
            }
        });

        // Setea la accion del boton cerrar sesion
        ImageView btnSalir = (ImageView) findViewById(R.id.btnCerrarSesion);
        btnSalir.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                cerrarSesion();
            }
        });

        // Accion btn SOS
        DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if(which == DialogInterface.BUTTON_POSITIVE){
                    String lat = "", lng = "";
                    gestorGPS miGPS = new gestorGPS(MenuActivity.this);
                    if(miGPS.puedeObtenerUbicacion()){
                        lat = miGPS.obtenerLat()+"";
                        lng = miGPS.obtenerLng()+"";
                        if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                            SOSTask sTask = new SOSTask(Usr, Password, idVehiculo, patenteVehiculo, lat, lng);
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

        ImageView btnSOS = (ImageView) findViewById(R.id.btnSOS);
        btnSOS.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(demo == 1){
                    if(isRegistered){
                        FragmentManager fm = getFragmentManager();
                        SOSDemoActivity fragment = new SOSDemoActivity();
                        fragment.show(fm,"sosdemo");
                    }else{
                        FragmentManager fm = getFragmentManager();
                        RegistrarDemoActivity fragment = new RegistrarDemoActivity();
                        Bundle b = new Bundle();
                        b.putBoolean("isSOS", true);
                        fragment.setArguments(b);
                        fragment.show(fm,"registrardemo");
                    }
                }else {
                    builder.show();
                }
            }
        });

        // Acciones de boton Ubicacion
        final ImageView btnUbicacion = (ImageView) findViewById(R.id.btnUbicacion);
        btnUbicacion.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (demo == 1){
                    String lat = "", lng = "";
                    Log.d("MenuActivity", "btnUbicacion");
                    gestorGPS miGPS = new gestorGPS(MenuActivity.this);
                    if(miGPS.puedeObtenerUbicacion()){
                        lat = miGPS.obtenerLat()+"";
                        lng = miGPS.obtenerLng()+"";
                        if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                            Intent ubicacion_mapa = new Intent(MenuActivity.this, UbicacionMapaActivity.class);
                            ubicacion_mapa.putExtra("Usr", Usr);
                            ubicacion_mapa.putExtra("Psw", Password);
                            ubicacion_mapa.putExtra("Usr_Lat", lat);
                            ubicacion_mapa.putExtra("Usr_Lng", lng);
                            ubicacion_mapa.putExtra("demo", demo);
                            startActivity(ubicacion_mapa);
                        }
                        else Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_LONG).show();
                    }
                    else miGPS.mostrarAlertaConfig();
                    miGPS.detenerGPS();
                } else {
                    String lat = "", lng = "";
                    Log.d("MenuActivity", "btnUbicacion");
                    gestorGPS miGPS = new gestorGPS(MenuActivity.this);
                    if(miGPS.puedeObtenerUbicacion()){
                        lat = miGPS.obtenerLat()+"";
                        lng = miGPS.obtenerLng()+"";
                        if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                            Intent ubicacion_mapa = new Intent(MenuActivity.this, UbicacionListActivity.class);
                            ubicacion_mapa.putExtra("Usr", Usr);
                            ubicacion_mapa.putExtra("Psw", Password);
                            ubicacion_mapa.putExtra("Usr_Lat", lat);
                            ubicacion_mapa.putExtra("Usr_Lng", lng);
                            startActivity(ubicacion_mapa);
                        }
                        else Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_LONG).show();
                    }
                    else miGPS.mostrarAlertaConfig();
                    miGPS.detenerGPS();
                }
            }
        });


        btnHistorial.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (demo == 1){
                    texto = "Observa los últimos eventos que realizó tu vehículo.\n" +
                            "\n" +
                            "Para obtener este servicio, es necesario instalar un dispositivo GPS, Auto" +
                            "Seguro 24Siete en su vehículo.";
                    generarAlerta("Historial", texto, false);
                } else {
                    Intent historialVehiculo = new Intent(MenuActivity.this, HistorialListActivity.class);
                    historialVehiculo.putExtra("Usr", Usr);
                    historialVehiculo.putExtra("Password", Password);
                    startActivity(historialVehiculo);
                }
            }
        });

        // Accion del boton Configuración
        ImageView brnConfiguracion = (ImageView) findViewById(R.id.btnConfiguracion);
        brnConfiguracion.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent config = new Intent(MenuActivity.this, ConfiguracionActivity.class);
                config.putExtra("Usr", Usr);
                config.putExtra("Password", Password);
                config.putExtra("tipoUsr", tipoUsr);
                config.putExtra("demo", demo);
                startActivity(config);
            }
        });

        // Accion del boton Configuración
        final ImageView btnNotificaciones = (ImageView) findViewById(R.id.btnNotificaciones);
        btnNotificaciones.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (demo == 1){
                    Toast.makeText(MenuActivity.this, "Podrás seleccionar que alertas quieres recibir, Por Ejmeplo:" +
                            "Encendido de Motor, Desconexión de GPS, Alertas de Movimiento, entre otras.",
                            Toast.LENGTH_SHORT).show();
                    //generarAlerta("notificaciones", msj, false);
                } else {
                    Intent notif = new Intent(MenuActivity.this, NotificacionesActivity.class);
                    notif.putExtra("Usr", Usr);
                    notif.putExtra("Password", Password);
                    startActivity(notif);
                }
            }
        });
    }

    @Override
    protected void onResume() {
        Log.d("MenuActivity","onResume");
        LocalBroadcastManager.getInstance(this).registerReceiver(mRegBroadcastRec, new IntentFilter(regCompletado));
        //// Cambiar el icono del menu si es que hay por lo menos un vehiculo en modo Estacionado ////
        // Instanciando los botones
        if(btnModoEstacionado == null) btnModoEstacionado = (ImageView) findViewById(R.id.btnEstacionado);

        isRegistered = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("isRegistered", false);
        Log.d("ISREGISTERED", isRegistered+"");

        // Se utiliza para cambiar la imagen, si es que hay un GPS activado por lo menos
        estadoVeh = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoVehAsignado", "-1"));

        // Se utiliza para cambiar la imagen, si es que hay (por lo menos) un GPS con control de uso
        estadoControldeUso = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoControlUso", "-1"));
        if (demo != 1){
            if(bPlan.compareToIgnoreCase("masivo")==0){
                // Cambia el modo estacionado por medio del WS
                estadoModoEstacionadoTask estadoModoE = new estadoModoEstacionadoTask(Usr, Password);
                estadoModoE.execute((Void) null);
            }
            else if(bPlan.compareToIgnoreCase("pyme")==0){
                if(tipoUsr == 1){
                    // Establece el control de uso
                    if(estadoControldeUso == 0) flagControldeUso = false;
                    else if(estadoControldeUso == 1) flagControldeUso = true;

                    // Seteo la imagen del boton modo estacionado
                    if(flagControldeUso) btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.controldeuso_activado));
                    else btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.controldeuso_desactivado));
                }
                else{
                    // Cambia el modo estacionado por medio del WS
                    estadoModoEstacionadoTask estadoModoE = new estadoModoEstacionadoTask(Usr, Password);
                    estadoModoE.execute((Void) null);
                }
            }
        }

        // Instanciando los botones
        if(btnVelMax == null) btnVelMax = (ImageView) findViewById(R.id.btnVelMax);

        // Se utiliza para cambiar la imagen, si es que hay un GPS activado por lo menos
        estadoControlVelocidad = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoControl", "-1"));

        // Establece el modo estacionado
        if(estadoControlVelocidad == 0) flagControlVelocidad = false;
        else if(estadoControlVelocidad == 1) flagControlVelocidad = true;

        // Seteo la imagen del boton modo estacionado
        if(flagControlVelocidad) btnVelMax.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_velocidad_activado));
        else btnVelMax.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_velocidad_desactivado));

        super.onResume();
    }

    @Override
    protected void onPause() {
        Log.d("MenuActivity", "onPause");
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegBroadcastRec);
        super.onPause();
    }

    public void cerrarSesion(){
        // Borrar las preferencias
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("ultimoTipo").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("ultimoPlan").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("VehAsignado").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("estadoVehAsignado").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("patenteVehAsignado").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().remove("estadoControl").commit();
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("ultimoRec", false).commit();

        /*SharedPreferences settings = getApplicationContext().getSharedPreferences("clear_cache", Context.MODE_PRIVATE);
        settings.edit().clear().commit();*/
        if (demo == 1){
            Intent intent = new Intent(MenuActivity.this, StartActivity.class);
            startActivity(intent);
            finish();
        } else {
            Intent intent = new Intent(MenuActivity.this, LoginActivity.class);
            startActivity(intent);
            finish();
        }
    }

    public Location getUltimaUbicacion(){
        LocationManager lm = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

        Criteria criteria = new Criteria();
        String bestProvider = lm.getBestProvider(criteria, false);
        Location location = lm.getLastKnownLocation(bestProvider);

        return location;
    }

    private boolean checkPlayServices() {
        int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                GooglePlayServicesUtil.getErrorDialog(resultCode, this,
                        PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

    public void generarAlerta(String titulo, String mensaje, final boolean esRespuesta){
        if(esRespuesta){
            FragmentManager fm = getFragmentManager();
            PopupWindows fragment = new PopupWindows();
            Bundle bundle = new Bundle();
            bundle.putString("titulo", titulo);
            bundle.putString("texto", mensaje);
            bundle.putBoolean("isResponse", esRespuesta);
            fragment.setArguments(bundle);
            fragment.show(fm,"popupwindow");
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

    // Hilos para llamar a los WS
    // Modo estacionado Task
    public class ModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Estado;

        ModoEstacionadoTask(String Usr, String Psw, String id, String pat, String est) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
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

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postPatente);
            datosPost.add(postEstado);

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
                Boolean exito = false;

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
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            if(resultadoModoEstacionado.compareTo("Modo estacionado") == 0 && Estado.compareTo("1") == 0) exito = true;
                                            else if(resultadoModoEstacionado.compareTo("Modo no estacionado") == 0 && Estado.compareTo("0") == 0) exito = true;
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
                    if(Estado.compareTo("1") == 0) {
                        btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoe_activado));
                        flagModoEstacionado = true;
                        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "1").commit();

                    }
                    else {
                        btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoe_desactivado));
                        flagModoEstacionado = false;
                        PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "0").commit();
                    }
                }
                else Toast.makeText(getApplicationContext(), getString(R.string.error_cambiar_modo_estacionado), Toast.LENGTH_SHORT).show();
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
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
            }
        }
    }

    // Permite leer el estado del modo estacionado para mostrar en el menu
    public class estadoModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp";
        private final String Usr;
        private final String Psw;

        estadoModoEstacionadoTask(String Usuario, String Password) {
            Usr = Usuario;
            Psw = Password;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);

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
        protected void onPostExecute(String Resultado) {
            boolean ModoEstacionadoActivo = false;
            if(Resultado!=null){
                Log.d("ModoEstacActiv", Resultado);
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("lista");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonVeh = jsonArr.getJSONObject(i);  // Se considera solo el primero
                                    if (jsonVeh != null) {
                                        if(!jsonVeh.getString("Estado").isEmpty()) {
                                            if(jsonVeh.getString("Estado").contentEquals("1")){
                                                ModoEstacionadoActivo = true;
                                                break;
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

                if(ModoEstacionadoActivo){ // cambiar el icono a activado
                    if(btnModoEstacionado != null) btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoe_activado));
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "1").commit();
                }
                else{  // cambiar el icono a desactivado
                    if(btnModoEstacionado != null) btnModoEstacionado.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.boton_modoe_desactivado));
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", "0").commit();
                }
            }
        }
    }


}
