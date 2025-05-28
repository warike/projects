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

import com.samtech.autoseguro24siete.Adapters.AdapterListVelMax;
import com.samtech.autoseguro24siete.Models.VelMaxModel;
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

public class VelMaxActivity extends ActionBarActivity {
    String Usr, Psw;
    ListView lv;
    ProgressBar pb;
    TextView tvNoHay;
    ArrayList<VelMaxModel> listaVehiculos;
    boolean flagFiltrar = false;
    AdapterListVelMax adapter;
    final ArrayList<VelMaxModel> listaVehiculosOriginal = new ArrayList<VelMaxModel>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vel_max);

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
            VelMaxTask vmTask = new VelMaxTask(Usr, Psw);
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

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_vel_max, menu);
/*
        SearchManager searchManager = (SearchManager) getSystemService( Context.SEARCH_SERVICE );
        SearchView searchView = (SearchView) menu.findItem(R.id.action_buscar).getActionView();
        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        searchView.setSubmitButtonEnabled(false);

        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                Log.d("onQtext", flagFiltrar + "");
                if (flagFiltrar) {
                    if (newText.isEmpty()) lv.clearTextFilter();
                    else lv.setFilterText(newText.toString());
                }
                return true;
            }
        });
        searchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                Log.d("onCloseText", flagFiltrar + "");
                lv.setTextFilterEnabled(false);
                flagFiltrar = false;
                return false;
            }
        });
        searchView.setOnSearchClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                lv.setTextFilterEnabled(true);
                flagFiltrar = true;
            }
        });

        int searchPlateId = searchView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        EditText searchPlate = (EditText) searchView.findViewById(searchPlateId);
        searchPlate.setTextColor(Color.parseColor("#FFFFFF"));
*/
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        //noinspection SimplifiableIfStatement
        if (id == R.id.action_buscar) {
            lv.setTextFilterEnabled(true);
            flagFiltrar = true;
            return true;
        }
        else if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, ConfiguracionActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }
        else if(id == R.id.action_guardar){
            ActualizarVelocidades();
            Log.d("VelMaxAct", "ACTION_GUARDAR");
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
    }

    public void ActualizarVelocidades(){
        ArrayList<VelMaxModel> lista = new ArrayList<>();
        for(int j=0; j<listaVehiculos.size();j++){
            VelMaxModel v = (VelMaxModel) adapter.getItem(j);
            if(v!=null){
                Log.d("VelMaxActiv", "Modif: " + v.getPatenteVehiculo() + "-" + v.getVelMaxVehiculo());
                Log.d("VelMaxActiv","Orig: "+listaVehiculosOriginal.get(j).getPatenteVehiculo()+"-"+listaVehiculosOriginal.get(j).getVelMaxVehiculo());
                if(v.getPatenteVehiculo().contentEquals(listaVehiculosOriginal.get(j).getPatenteVehiculo())){
                    if(!v.getVelMaxVehiculo().contentEquals(listaVehiculosOriginal.get(j).getVelMaxVehiculo())){
                        lista.add(v);
                    }
                    else Log.d("VelMaxActiv", "Velocidades: CERO");
                }
            }
            else break;
        }

        if(lista.size()>0){
            ActualizarVelocidadTask avTask = new ActualizarVelocidadTask(Usr,Psw, lista);
            avTask.execute((Void) null);
        }
        else Log.d("ActVel",lista.size()+"");
    }

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class VelMaxTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp";
        private final String Usr;
        private final String Psw;

        VelMaxTask(String Usuario, String Password) {
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
                Intent intent;
                listaVehiculos = new ArrayList<VelMaxModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("lista");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonVeh = jsonArr.getJSONObject(i);  // Se considera solo el primero
                                    if (jsonVeh != null) {
                                        if(!jsonVeh.getString("ID").isEmpty() && !jsonVeh.getString("Patente").isEmpty()) {
                                            VelMaxModel m = new VelMaxModel(jsonVeh.getString("ID"), jsonVeh.getString("Patente"), jsonVeh.getString("Velocidad"), jsonVeh.getString("Nombre"));
                                            VelMaxModel a = new VelMaxModel(jsonVeh.getString("ID"), jsonVeh.getString("Patente"), jsonVeh.getString("Velocidad"), jsonVeh.getString("Nombre"));
                                            listaVehiculos.add(m);
                                            listaVehiculosOriginal.add(a);
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
                    adapter = new AdapterListVelMax(getBaseContext(), Usr, Psw, listaVehiculos);
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
    public class ActualizarVelocidadTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp";
        private final String Usr;
        private final String Psw;
        private ArrayList<VelMaxModel> listaActualizar = null;
        private int contador_exito = 0;
        private String respuesta_total;
        private String[] respuestasWS;

        ActualizarVelocidadTask(String Usuario, String Password, ArrayList<VelMaxModel> v) {
            Usr = Usuario;
            Psw = Password;
            listaActualizar = v;
            this.respuestasWS = new String[v.size()];
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postEstado = new BasicNameValuePair("estado", "");
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", "2");

            for(int i=0; i<listaActualizar.size();i++){
                Log.d("ActVelTask", "Actualizando: "+listaActualizar.get(i).getPatenteVehiculo());
                BasicNameValuePair postidVehiculo = new BasicNameValuePair("id", listaActualizar.get(i).getIdVehiculo());
                BasicNameValuePair postPatente = new BasicNameValuePair("patente", listaActualizar.get(i).getPatenteVehiculo());
                BasicNameValuePair postVelocidad = new BasicNameValuePair("spd", listaActualizar.get(i).getVelMaxVehiculo());

                // Agrupando la informacion de post
                List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
                datosPost.add(postUsr);
                datosPost.add(postPsw);
                datosPost.add(postidVehiculo);
                datosPost.add(postPatente);
                datosPost.add(postVelocidad);
                datosPost.add(postEstado);
                datosPost.add(postAccion);

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
                        respuesta_total += respuesta;
                        respuestasWS[i] = "";
                        try {
                            JSONObject jsonObj = new JSONObject(respuesta);
                            if(jsonObj!=null){
                                JSONArray jsonArr = jsonObj.getJSONArray("ControlVelocidad");
                                if(jsonArr != null) {
                                    if (jsonArr.length() > 0) {
                                        JSONObject jsonVeh = jsonArr.getJSONObject(0);  // Se considera solo el primero
                                        if (jsonVeh != null) {
                                            if (!jsonVeh.getString("GPS").isEmpty()) {
                                                contador_exito++;
                                                respuestasWS[i] = jsonVeh.getString("GPS");
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
                Log.d("VelMaxAct", respuesta_total);
                //{"ControlVelocidad":[{"GPS" : "Velocidad actualizada","Patente" : "","Velocidad" : "","Nombre" : "","Estado" : ""}]}

                if(respuestasWS.length == listaActualizar.size()) {
                    String mensajeError = "";
                    boolean encontroError = false;
                    for(int j=0;j<respuestasWS.length;j++){
                        if(!respuestasWS[j].toLowerCase().contains("actualizada")){
                            encontroError = true;
                            mensajeError = respuestasWS[j];
                            break;
                        }
                    }

                    if(encontroError) Toast.makeText(getApplicationContext(), mensajeError, Toast.LENGTH_SHORT).show();
                    else Toast.makeText(getApplicationContext(), getString(R.string.exito_cambiar_vel_max), Toast.LENGTH_SHORT).show();
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }
    }
}
