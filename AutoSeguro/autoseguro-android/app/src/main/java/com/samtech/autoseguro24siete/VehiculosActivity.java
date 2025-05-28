package com.samtech.autoseguro24siete;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Adapters.AdapterListNombreVehiculos;
import com.samtech.autoseguro24siete.Models.VehiculoModel;
import com.samtech.autoseguro24siete.R;

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

public class VehiculosActivity extends ActionBarActivity {
    String Usr, Psw;
    ListView lv;
    ProgressBar pb;
    TextView tvNoHay;
    ArrayList<VehiculoModel> listaVehiculos;
    final ArrayList<VehiculoModel> listaVehiculosOriginal = new ArrayList<VehiculoModel>();
    AdapterListNombreVehiculos adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cambiar_nombre);

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
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
            VehiculosTask vmTask = new VehiculosTask(Usr, Psw);
            vmTask.execute((Void) null);
        }
        setearBarraSuperior();
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

    public void ActualizarNombres(){
        ArrayList<VehiculoModel> lista = new ArrayList<>();
        for(int j=0; j<listaVehiculos.size();j++){
            VehiculoModel v = (VehiculoModel) adapter.getItem(j);
            Log.d("VehiculosAct","Orig: "+listaVehiculosOriginal.get(j).getIdVehiculo()+"-"+listaVehiculosOriginal.get(j).getPatenteVehiculo()+"-"+listaVehiculosOriginal.get(j).getNombreVehiculo());
            Log.d("VehiculosAct", "Modif: " +v.getIdVehiculo()+"-"+v.getPatenteVehiculo() + "-" + v.getNombreVehiculo());
            if(v.getPatenteVehiculo().contentEquals(listaVehiculosOriginal.get(j).getPatenteVehiculo())){
                if(!v.getNombreVehiculo().contentEquals(listaVehiculosOriginal.get(j).getNombreVehiculo())){
                    lista.add(v);
                }
            }
        }

        if(lista.size()>0){ Log.d("ActuNombres", lista.size()+"");
            cambiarNombreTask cnTask = new cambiarNombreTask(Usr,Psw, lista);
            cnTask.execute((Void) null);
        }
        else Log.d("NombresActiv",lista.size()+"");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_vel_max, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        //noinspection SimplifiableIfStatement
        if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, ConfiguracionActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }
        else if(id == R.id.action_guardar){
            ActualizarNombres();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
    }

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class VehiculosTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp";
        private final String Usr;
        private final String Psw;

        VehiculosTask(String Usuario, String Password) {
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
            if(Resultado!=null){
                Log.d("ModoEstacActiv", Resultado);
                listaVehiculos = new ArrayList<VehiculoModel>();

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
                                            VehiculoModel m = new VehiculoModel(jsonVeh.getString("ID"), jsonVeh.getString("Patente"), jsonVeh.getString("Nombre"));
                                            VehiculoModel o = new VehiculoModel(jsonVeh.getString("ID"), jsonVeh.getString("Patente"), jsonVeh.getString("Nombre"));
                                            listaVehiculos.add(m);
                                            listaVehiculosOriginal.add(o);
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                // Se oculta el progress bar
                mostrarCargando(false);

                if(listaVehiculos.size()>0){
                    adapter = new AdapterListNombreVehiculos(getBaseContext(), Usr, Psw, listaVehiculos);
                    lv.setAdapter(adapter);
                    //lv.setTextFilterEnabled(true);
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
        protected void onCancelled() {
            mostrarCargando(false);
        }
    }

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class cambiarNombreTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/NombrePorPatente.asp";
        private final String Usr;
        private final String Psw;
        private ArrayList<VehiculoModel> listaModificar;
        private int contador_exito = 0;

        cambiarNombreTask(String Usuario, String Password, ArrayList<VehiculoModel> v) {
            Usr = Usuario;
            Psw = Password;
            listaModificar = v;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", "2");


            for(int i=0; i<listaModificar.size();i++){
                BasicNameValuePair postPatente = new BasicNameValuePair("patente", listaModificar.get(i).getPatenteVehiculo());
                BasicNameValuePair postGPS = new BasicNameValuePair("gps", listaModificar.get(i).getIdVehiculo());
                BasicNameValuePair postNombre = new BasicNameValuePair("nombre", listaModificar.get(i).getNombreVehiculo());

                // Agrupando la informacion de logueo
                List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
                datosPost.add(postUsr);
                datosPost.add(postPsw);
                datosPost.add(postAccion);
                datosPost.add(postPatente);
                datosPost.add(postGPS);
                datosPost.add(postNombre);

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
                        //return stringBuilder.toString();
                        String respuesta = stringBuilder.toString();
                        Log.d("doInBackgnd", respuesta);
                        try {
                            JSONObject jsonObj = new JSONObject(respuesta);
                            if(jsonObj!=null){
                                JSONArray jsonArr = jsonObj.getJSONArray("NomPatente");
                                if(jsonArr != null) {
                                    if (jsonArr.length() > 0) {
                                        JSONObject jsonVeh = jsonArr.getJSONObject(0);  // Se considera solo el primero
                                        if (jsonVeh != null) {
                                            if (!jsonVeh.getString("GPS").isEmpty()) {
                                                if(jsonVeh.getString("GPS").compareToIgnoreCase("Patente Actualizada")==0) contador_exito++;
                                            }
                                        }
                                    }
                                }
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

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
            }

            return contador_exito+"";
        }

        @Override
        protected void onPostExecute(String Resultado) {
            if(Resultado!=null){
                if(contador_exito == listaModificar.size()) {
                    Log.d("VehiculosNo", "Se actualizaron correctamente los nombres de los vehiculos");
                    Toast.makeText(VehiculosActivity.this, getString(R.string.cambio_nombre_realizado), Toast.LENGTH_SHORT).show();
                }
                else Toast.makeText(VehiculosActivity.this, getString(R.string.error_no_cambio), Toast.LENGTH_SHORT).show();
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }
}
