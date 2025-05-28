package com.samtech.autoseguro24siete;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Adapters.AdapterListUbicacion;
import com.samtech.autoseguro24siete.Models.UbicacionModel;

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

public class UbicacionListActivity extends ActionBarActivity  {
    String Usr, Psw, Usr_Lat, Usr_Lng;
    public ListView lv;
    public ProgressBar pb;
    public TextView tvNoHay;
    private ArrayList<UbicacionModel> listaVehiculos, listaVehiculosAux;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.ubicacion_lista);

        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Psw", "");
            Usr_Lat = b.getString("Usr_Lat", ""); Usr_Lng = b.getString("Usr_Lng", "");
        }
        else {

            finish();
        }

        // Desaparecemos la lista y se hace visible el cargando
        lv = (ListView) findViewById(R.id.lvVehiculos);

        pb = (ProgressBar) findViewById(R.id.pbCargando);

        tvNoHay = (TextView) findViewById(R.id.tvNoInfo);

        if(Usr.isEmpty() || Psw.isEmpty()) finish();
        else {
            /*LeerNombresTask lnt = new LeerNombresTask(Usr,Psw);
            lnt.execute((Void) null);*/
            LeerVehiculosUbicacionTask lvuTask = new LeerVehiculosUbicacionTask(Usr, Psw);
            lvuTask.execute((Void) null);
        }
        setearBarraSuperior();
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
    }
/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_ubicacion_list, menu);
        return true;
    }
*/
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, MenuActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }
        return super.onOptionsItemSelected(item);
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
/*
    // Permite cargar la lista de vehiculos con sus nombres
    public class LeerNombresTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp";
        private final String Usr;
        private final String Psw;

        LeerNombresTask(String Usuario, String Password) {
            Usr = Usuario;
            Psw = Password;
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
            Log.d("ResLeerNombre", Resultado);
            listaVehiculosAux = new ArrayList<UbicacionModel>();
            try {
                JSONObject jsonObj = new JSONObject(Resultado);
                if(jsonObj!=null){
                    JSONArray jsonArr = jsonObj.getJSONArray("lista");
                    if(jsonArr != null) {
                        if (jsonArr.length() > 0) {
                            for(int i=0; i<jsonArr.length();i++){
                                JSONObject jsonVeh = jsonArr.getJSONObject(i);
                                if (jsonVeh != null) {
                                    if(!jsonVeh.getString("ID").isEmpty() && !jsonVeh.getString("Patente").isEmpty()) {
                                        UbicacionModel m = new UbicacionModel(jsonVeh.getString("ID"), jsonVeh.getString("Patente"), "", jsonVeh.getString("Nombre"), "");
                                        if(m.getNombreVehiculo().isEmpty()) m.setNombreVehiculo(jsonVeh.getString("Patente"));
                                        listaVehiculosAux.add(m);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            if(listaVehiculosAux.size()>0){ // Se llama al 2do hilo para obtener la ubicacion
                LeerUbicacionTask lut = new LeerUbicacionTask(Usr,Psw);
                lut.execute((Void) null);
            }
            else {
                tvNoHay.setVisibility(View.VISIBLE);
            }
        }

        @Override
        protected void onCancelled() { }
    }

    // Permite cargar la lista de vehiculos con sus ubicaciones
    public class LeerUbicacionTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/DatosporFlota.asp";
        private final String Usr;
        private final String Psw;

        LeerUbicacionTask(String Usuario, String Password) {
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
            Log.d("ResLeerUbic", Resultado);
            listaVehiculos = new ArrayList<UbicacionModel>();
            try {
                JSONObject jsonObj = new JSONObject(Resultado);
                if(jsonObj!=null){
                    JSONArray jsonArr = jsonObj.getJSONArray("DatoFlota");
                    if(jsonArr != null) {
                        if (jsonArr.length() > 0) {
                            for(int i=0; i<jsonArr.length();i++){
                                JSONObject jsonVeh = jsonArr.getJSONObject(i);
                                if (jsonVeh != null) {
                                    if(!jsonVeh.getString("Patente").isEmpty() && !jsonVeh.getString("Ubicacion").isEmpty()) {
                                        String strPatente = jsonVeh.getString("Patente");
                                        for(int j=0; j<listaVehiculosAux.size();j++){
                                            if(listaVehiculosAux.get(j).getPatenteVehiculo().compareToIgnoreCase(strPatente)==0){
                                                listaVehiculosAux.get(j).setUbicacionVehiculo(jsonVeh.getString("Ubicacion"));
                                                if(jsonVeh.getString("Estado").contentEquals("1")) listaVehiculosAux.get(j).setEstadoVehiculo("Encendido");
                                                else listaVehiculosAux.get(j).setEstadoVehiculo("Apagado");
                                                listaVehiculos.add(listaVehiculosAux.get(j));
                                                listaVehiculosAux.remove(j);
                                                break;
                                            }
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

            if(listaVehiculos.size()>0){ // Se cargan los datos en la lista por medio del adapter
                AdapterListUbicacion adapter = new AdapterListUbicacion(getApplicationContext(), Usr, Psw, listaVehiculos, Usr_Lat, Usr_Lng);
                lv.setAdapter(adapter);
            }
            else {
                tvNoHay.setVisibility(View.VISIBLE);
            }
        }

        @Override
        protected void onCancelled() { }
    }*/

    // Permite cargar la lista de vehiculos con sus ubicaciones
    public class LeerVehiculosUbicacionTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/DatosporFlota.asp";
        private final String Usr;
        private final String Psw;

        LeerVehiculosUbicacionTask(String Usuario, String Password) {
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
            if(Resultado!=null){
                Log.d("ResLeerUbic", Resultado);
                listaVehiculos = new ArrayList<UbicacionModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("DatoFlota");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonVeh = jsonArr.getJSONObject(i);
                                    if (jsonVeh != null) {
                                        if(!jsonVeh.getString("Patente").isEmpty() && !jsonVeh.getString("Ubicacion").isEmpty() && !jsonVeh.getString("GPS").isEmpty()) {
                                            String Estado = "", NombreVeh = "";
                                            /*if(jsonVeh.getString("Estado").contentEquals("1")) Estado = "Encendido";
                                            else Estado = "Apagado";*/

                                            if(jsonVeh.getString("NomPatente").isEmpty()) NombreVeh = jsonVeh.getString("Patente");
                                            else NombreVeh = jsonVeh.getString("NomPatente");

                                            UbicacionModel v = new UbicacionModel(jsonVeh.getString("GPS"),
                                                    jsonVeh.getString("Patente"), jsonVeh.getString("Ignicion"),
                                                    NombreVeh,jsonVeh.getString("Ubicacion"),
                                                    jsonVeh.getString("Corte"));
                                            listaVehiculos.add(v);
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

                if(listaVehiculos.size()>0){ // Se cargan los datos en la lista por medio del adapter
                    if(listaVehiculos.size()>1){ // tiene más de un vehiculo, se debe agregar el activar todos
                        ArrayList<UbicacionModel> listaVehiculosAux = new ArrayList<UbicacionModel>();
                        listaVehiculosAux.add(new UbicacionModel("0", "Todos los vehículos", "0", "0", "", "0"));
                        for(int i=0; i<listaVehiculos.size();i++) listaVehiculosAux.add(listaVehiculos.get(i));

                        listaVehiculos = new ArrayList<UbicacionModel>();
                        listaVehiculos = listaVehiculosAux;
                    }

                    AdapterListUbicacion adapter = new AdapterListUbicacion(getApplicationContext(), Usr, Psw, listaVehiculos, Usr_Lat, Usr_Lng);
                    lv.setAdapter(adapter);
                }
                else {
                    tvNoHay.setVisibility(View.VISIBLE);
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }

        @Override
        protected void onCancelled() { }
    }

}
