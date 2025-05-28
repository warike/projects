package com.samtech.autoseguro24siete;

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
import android.util.Log;
import android.view.Gravity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.SearchView;
import android.widget.SearchView.OnQueryTextListener;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Adapters.AdapterListModoEstacionado;
import com.samtech.autoseguro24siete.Models.ModoEstacionadoModel;

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

public class ModoEstacionadoActivity extends ActionBarActivity  implements OnQueryTextListener {
    String Usr, Psw;
    public ListView lv;
    public ProgressBar pb;
    public TextView tvNoHay;
    private ArrayList<ModoEstacionadoModel> listaVehiculos;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.estacionado_lista);

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
            ModoEstacionadoTask me = new ModoEstacionadoTask(Usr,Psw);
            me.execute((Void) null);
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
        SearchView searchView = (SearchView) menu.findItem(R.id.action_buscar).getActionView();
        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        searchView.setSubmitButtonEnabled(false);
        searchView.setOnQueryTextListener(this);
        int searchPlateId = searchView.getContext().getResources().getIdentifier("android:id/search_src_text", null, null);
        EditText searchPlate = (EditText) searchView.findViewById(searchPlateId);
        searchPlate.setTextColor(Color.parseColor("#FFFFFF"));

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
            return true;
        }
        else if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, MenuActivity.class);
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
        AdapterListModoEstacionado adp = (AdapterListModoEstacionado) lv.getAdapter();
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

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class ModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ListaVehiculoTodos.asp";
        private final String Usr;
        private final String Psw;

        ModoEstacionadoTask(String Usuario, String Password) {
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
                listaVehiculos = new ArrayList<ModoEstacionadoModel>();
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
                                            ModoEstacionadoModel m = new ModoEstacionadoModel(jsonVeh.getString("ID"),
                                                    jsonVeh.getString("Patente"), jsonVeh.getString("Estado"),
                                                    jsonVeh.getString("Velocidad"), jsonVeh.getString("Nombre"),
                                                    jsonVeh.getString("Corte"));
                                            listaVehiculos.add(m);
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
                    if(listaVehiculos.size()>1){ // tiene más de un vehiculo, se debe agregar el activar todos
                        ArrayList<ModoEstacionadoModel> listaVehiculosAux = new ArrayList<ModoEstacionadoModel>();
                        listaVehiculosAux.add(new ModoEstacionadoModel("0", "Activar Todos", "0", "0", "", "0"));
                        for(int i=0; i<listaVehiculos.size();i++) listaVehiculosAux.add(listaVehiculos.get(i));

                        listaVehiculos = new ArrayList<ModoEstacionadoModel>();
                        listaVehiculos = listaVehiculosAux;
                    }
                    String dtoken = PreferenceManager.getDefaultSharedPreferences(getBaseContext()).getString("deviceToken", "");
                    AdapterListModoEstacionado adapter = new AdapterListModoEstacionado(getBaseContext(), Usr, Psw, listaVehiculos,dtoken);
                    lv.setAdapter(adapter);
                    lv.setTextFilterEnabled(true);
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
}
