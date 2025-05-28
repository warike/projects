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

import com.samtech.autoseguro24siete.Adapters.AdapterListHistorial;
import com.samtech.autoseguro24siete.Models.HistorialModel;
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

public class HistorialActivity extends ActionBarActivity {
    String Usr,Psw,idVehiculo, Patente;
    ProgressBar pbCargando;
    TextView tvNoHistorial;
    ListView lvHistorial;
    private ArrayList<HistorialModel> HistorialM;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.historial_lista);

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
            idVehiculo = b.getString("idVehiculo", ""); Patente = b.getString("Patente", "");
        }

        pbCargando = (ProgressBar) findViewById(R.id.pbCargando);
        tvNoHistorial = (TextView) findViewById(R.id.tvNoHistor);
        lvHistorial = (ListView) findViewById(R.id.listaHistorial);

        // Cargando
        pbCargando.setVisibility(View.VISIBLE);
        lvHistorial.setVisibility(View.GONE);

        // Llamada al WS
        if(!Patente.isEmpty() && !Usr.isEmpty() && !Psw.isEmpty() && !idVehiculo.isEmpty()){
            HistorialTask hTask = new HistorialTask(Usr, Psw, idVehiculo, Patente);
            hTask.execute((Void) null);
        }
        else {
            Toast.makeText(getApplicationContext(), getString(R.string.error_leer_historial), Toast.LENGTH_LONG).show();
            finish();
        }
        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        setearBarraSuperior();
    }
    public void mostrarCargando(boolean m){
        if(m){
            pbCargando.setVisibility(View.VISIBLE);
            lvHistorial.setVisibility(View.GONE);
        }
        else {
            pbCargando.setVisibility(View.GONE);
            lvHistorial.setVisibility(View.VISIBLE);
        }
    }


    // Cargar el historial
    public class HistorialTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/Historia.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;

        HistorialTask(String Usr, String Psw, String id, String pat) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
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
                HistorialM = new ArrayList<HistorialModel>();

                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("historia");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonEvento = jsonArr.getJSONObject(i);
                                    HistorialModel Evento = new HistorialModel(jsonEvento.getString("Evento"),jsonEvento.getString("Hora"),jsonEvento.getString("Ubicacion"),jsonEvento.getString("Latitud"),jsonEvento.getString("Longitud"));
                                    HistorialM.add(Evento);
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                mostrarCargando(false);
                if(HistorialM.size()>0){ // Se setea el adaptador
                    AdapterListHistorial adapter = new AdapterListHistorial(HistorialActivity.this, HistorialM, Usr, Psw, Patente, idVehiculo);
                    lvHistorial.setAdapter(adapter);
                }
                else tvNoHistorial.setVisibility(View.VISIBLE);
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
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
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getMenuInflater().inflate(R.menu.menu_historial, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == android.R.id.home) {
            Intent intent = new Intent().setClass(this, HistorialListActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

}
