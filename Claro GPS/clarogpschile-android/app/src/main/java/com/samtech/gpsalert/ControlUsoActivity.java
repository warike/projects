package com.samtech.gpsalert;

import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.SearchView;
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.Toast;

import com.samtech.gpsalert.Adapters.AdapterListControlUso;
import com.samtech.gpsalert.Models.ControlUsoModel;
import com.samtech.gpsalert.Models.VehiculoModel;

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

public class  ControlUsoActivity extends ActionBarActivity implements OnQueryTextListener {
    String Usr, Psw;
    ListView lv;
    ProgressBar pb;
    TextView tvNoHay;
    private ArrayList<ControlUsoModel> listaControlUso;
    private ArrayList<VehiculoModel> listaNombres;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_control_uso);

        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

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
            /*VehiculosTask vTsk = new VehiculosTask(Usr,Psw);
            vTsk.execute((Void) null);*/
            ControlUsoTask cTsk = new ControlUsoTask(Usr,Psw);
            cTsk.execute((Void) null);
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
        getMenuInflater().inflate(R.menu.menu_modo_estacionado, menu);

        SearchManager searchManager = (SearchManager) getSystemService( Context.SEARCH_SERVICE );
        android.widget.SearchView searchView = (android.widget.SearchView) menu.findItem(R.id.action_buscar).getActionView();
        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        searchView.setSubmitButtonEnabled(false);
        searchView.setOnQueryTextListener(this);
        int searchPlateId = searchView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        EditText searchPlate = (EditText) searchView.findViewById(searchPlateId);
        searchPlate.setTextColor(Color.parseColor("#FFFFFF"));

        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_buscar) {
            return true;
        }
        else if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, ConfiguracionActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onQueryTextSubmit(String query) {
        return false;
    }

    @Override
    public boolean onQueryTextChange(String stringIngresado) {
        AdapterListControlUso adp = (AdapterListControlUso) lv.getAdapter();
        if(stringIngresado.isEmpty()) {
            //lv.clearTextFilter();
            adp.getFilter().filter(null);
        }
        else {
            adp.getFilter().filter(stringIngresado.toString());
            //lv.setFilterText(stringIngresado.toString());
        }
        return true;
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
    }

    // Permite cargar la lista de patentes de control de uso
    public class ControlUsoTask extends AsyncTask<Void, Void, String> {
        //private final String urlWS = "http://consulta.tracklite.cl/WSMov.asmx/ControlDeUso";
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeUso.asp";
        private final String wsUsuario;
        private final String wsPassword;
        private final String wsAccion;

        ControlUsoTask(String Usr, String Psw) {
            wsUsuario = Usr;
            wsPassword = Psw;
            wsAccion = "1"; // Lista todos los items de control de uso asociados al cliente
        }

        @Override
        protected void onPreExecute() {
            mostrarCargando(true);
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postAcc = new BasicNameValuePair("accion", wsAccion);
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", wsUsuario);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", wsPassword);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postAcc);

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
                Log.d("ControlU.onPostExecute", Resultado);
                boolean exito = false;
                listaControlUso = new ArrayList<ControlUsoModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    JSONArray jsonArr = jsonObj.getJSONArray("ControlDeUso");
                    if(jsonArr!=null){
                        if(jsonArr.length()>0){
                            for(int i=0;i<jsonArr.length();i++){
                                JSONObject Veh = jsonArr.getJSONObject(i);
                                //["8709","CVRX36","01/01/1990 00:00:01","01/01/1990 23:59:59","0"]
                                ControlUsoModel Item = new ControlUsoModel(Veh.getString("GPS"), Veh.getString("Patente"), Veh.getString("Estado"), Veh.getString("Fecha_ini"), Veh.getString("Fecha_fin"), Veh.getString("Hora_ini"), Veh.getString("Hora_fin"),"","", Veh.getString("NomPatente")/*cargarNombre(Veh.getString("GPS"),Veh.getString("Patente"))*/);
                                listaControlUso.add(Item);
                            }

                            // Verificar que la lista se lleno
                            if(listaControlUso.size()>0){

                                if(listaControlUso.size()>1){
                                    ArrayList<ControlUsoModel> listaAux = new ArrayList<>();
                                    ControlUsoModel c = new ControlUsoModel("0", "Activar Todos", "", "", "", "", "", "", "", "Activar Todos");
                                    listaAux.add(c);
                                    for(int i=0; i<listaControlUso.size();i++){
                                        listaAux.add(listaControlUso.get(i));
                                    }
                                    listaControlUso = new ArrayList<>();
                                    listaControlUso = listaAux;
                                }

                                // Poblar el listView con los datos leidos desde el ws
                                AdapterListControlUso adapter = new AdapterListControlUso(getBaseContext(), listaControlUso, wsUsuario, wsPassword);
                                lv.setAdapter(adapter);
                                lv.setTextFilterEnabled(true);
                            }
                            else{
                                // Mostrar un mensaje que no hay elementos para este usuario
                                tvNoHay.setVisibility(View.VISIBLE);
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                mostrarCargando(false);
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

    private String cargarNombre(String gps, String patente) {
        String nombre = "";

        if(listaNombres.size()>0){
            for(int i=0; i<listaNombres.size();i++){
                if(listaNombres.get(i).getIdVehiculo().compareToIgnoreCase(gps) == 0 || listaNombres.get(i).getPatenteVehiculo().compareToIgnoreCase(patente) == 0){
                    if(listaNombres.get(i).getNombreVehiculo().isEmpty()) nombre = patente;
                    else nombre = listaNombres.get(i).getNombreVehiculo();
                    break;
                }
            }
        }

        return nombre;
    }
}
