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

import com.samtech.autoseguro24siete.Adapters.AdapterListConfigControlUso;
import com.samtech.autoseguro24siete.Adapters.AdapterListControlUso;
import com.samtech.autoseguro24siete.Models.ControlUsoModel;

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

public class ConfigControlUsoActivity extends ActionBarActivity {
    String Usr, Psw;
    ListView lv;
    ProgressBar pb;
    TextView tvNoHay;
    private ArrayList<ControlUsoModel> listaControlUso;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_config_control_uso);

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
            ControlUsoTask cuTsk = new ControlUsoTask(Usr,Psw);
            cuTsk.execute((Void) null);
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
        getMenuInflater().inflate(R.menu.menu_config_control_uso, menu);
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
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }
        else if(id == R.id.action_guardar){
            /*for(ControlUsoModel v : listaControlUso){
                Log.d("ConfigCtrlUsoActiv", v.getDiaDesde()+"-"+v.getHoraDesde()+"|"+v.getDiaHasta()+"-"+v.getHoraHasta());
            }*/
            if(validarHoras()){
                actualizarControlUsoTask actu = new actualizarControlUsoTask(Usr,Psw, listaControlUso);
                actu.execute((Void)null);
            }
            else Toast.makeText(getApplicationContext(), getString(R.string.error_horas), Toast.LENGTH_SHORT).show();

            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    private boolean validarHoras() {
        boolean valido = true;
        if(listaControlUso!=null){
            if(listaControlUso.size()>0){
                for(int i=0;i<listaControlUso.size();i++){
                    String strHDesde = listaControlUso.get(i).getHoraDesde();
                    String strHHasta = listaControlUso.get(i).getHoraHasta();
                    if(!strHDesde.isEmpty()){
                        String[] divisionDesde = strHDesde.split(":");
                        if(divisionDesde!=null){
                            if(divisionDesde.length>0){
                                int horas = Integer.parseInt(divisionDesde[0]);
                                int minutos = Integer.parseInt(divisionDesde[1]);
                                int segundos = Integer.parseInt(divisionDesde[2]);
                                if(horas > 23 || horas < 0) valido = false;
                                if(minutos > 59 || minutos < 0) valido = false;
                                if(segundos > 59 || segundos < 0) valido = false;
                            }
                            else valido = false;
                        }
                        else valido = false;
                    }
                    if(!strHHasta.isEmpty()){
                        String[] divisionHasta = strHHasta.split(":");
                        if(divisionHasta!=null){
                            if(divisionHasta.length>0){
                                int horas = Integer.parseInt(divisionHasta[0]);
                                int minutos = Integer.parseInt(divisionHasta[1]);
                                int segundos = Integer.parseInt(divisionHasta[2]);
                                if(horas > 23 || horas < 0) valido = false;
                                if(minutos > 59 || minutos < 0) valido = false;
                                if(segundos > 59 || segundos < 0) valido = false;
                            }
                            else valido = false;
                        }
                        else valido = false;
                    }
                }
            }
        }

        return valido;
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
            super.onPreExecute();
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Debido a la programacion del WS, se deben pasar todos los parametros INCLUSO con un string vacio
            String vacio = "";

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
        protected void onPostExecute(String Resultado){
            if(Resultado != null){
                Log.d("ControlU.onPostExecute", Resultado);
                listaControlUso = new ArrayList<ControlUsoModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    JSONArray jsonArr = jsonObj.getJSONArray("ControlDeUso");
                    if(jsonArr!=null){
                        if(jsonArr.length()>0){
                            for(int i=0;i<jsonArr.length();i++){
                                JSONObject Veh = jsonArr.getJSONObject(i);
                                String hInicio = Veh.getString("Hora_ini"), fInicio = Veh.getString("Fecha_ini"), hHasta = Veh.getString("Hora_fin"), fHasta = Veh.getString("Fecha_fin");
                                if(hInicio == null || hInicio.isEmpty()) hInicio = "00:00:00"; if(fInicio == null || fInicio.isEmpty()) fInicio = "0";
                                if(hHasta == null || hHasta.isEmpty()) hHasta = "00:00:00"; if(fHasta == null || fHasta.isEmpty()) fHasta = "0";
                                //{"GPS" : "G280","Patente" : "GSRT52","Fecha_ini" : "2","Fecha_fin" : "5","Hora_ini" : "12:45:12","Hora_fin" : "14:12:12","Estado" : "1"},
                                ControlUsoModel Item = new ControlUsoModel(Veh.getString("GPS"), Veh.getString("Patente"), Veh.getString("Estado"), fInicio, fHasta, hInicio, hHasta, "");
                                listaControlUso.add(Item);
                            }

                            // Verificar que la lista se lleno
                            if(listaControlUso.size()>0){
                                // Poblar el listView con los datos leidos desde el ws
                                AdapterListConfigControlUso adapter = new AdapterListConfigControlUso(getBaseContext(), listaControlUso, wsUsuario, wsPassword);
                                lv.setAdapter(adapter);
                                //lv.setTextFilterEnabled(true);
                            }
                            else{
                                // Mostrar un mensaje que no hay elementos para este usuario
                                tvNoHay.setVisibility(View.VISIBLE);
                            }
                            mostrarCargando(false);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
            else {
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                finish();
            }
        }

        @Override
        protected void onCancelled() {
            mostrarCargando(false);
        }
    }

    // Permite cargar la lista de patentes de control de uso
    public class actualizarControlUsoTask extends AsyncTask<Void, Void, String> {
        //private final String urlWS = "http://consulta.tracklite.cl/WSMov.asmx/ControlDeUso";
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeUso.asp";
        private final String wsUsuario;
        private final String wsPassword;
        private final String wsAccion;
        ArrayList<ControlUsoModel> listaCtrlUso;
        String ResultadoWS;
        int contador_exito = 0;

        actualizarControlUsoTask(String Usr, String Psw, ArrayList<ControlUsoModel> lista) {
            wsUsuario = Usr;
            wsPassword = Psw;
            wsAccion = "2"; // Actualiza
            listaCtrlUso = lista;
            ResultadoWS = "";
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postAcc = new BasicNameValuePair("accion", wsAccion);
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", wsUsuario);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", wsPassword);
            BasicNameValuePair postEstado = new BasicNameValuePair("estado", "");

            for(int i = 0; i<listaCtrlUso.size();i++){
                // Agrupando la informacion de logueo
                List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
                datosPost.add(postUsr);
                datosPost.add(postPsw);
                datosPost.add(postAcc);
                datosPost.add(postEstado);

                String horaInicio = listaCtrlUso.get(i).getHoraDesde();
                horaInicio = horaInicio.replaceAll(":","-");
                String horaFin = listaCtrlUso.get(i).getHoraHasta();
                horaFin = horaFin.replaceAll(":","-");

                // Datos CtrlUso
                BasicNameValuePair postID = new BasicNameValuePair("id", listaCtrlUso.get(i).getIdVehiculo());
                BasicNameValuePair postPatente = new BasicNameValuePair("patente", listaCtrlUso.get(i).getPatente());
                BasicNameValuePair postDiaInicio = new BasicNameValuePair("dia_ini", listaCtrlUso.get(i).getDiaDesde());
                BasicNameValuePair postHoraInicio = new BasicNameValuePair("hora_ini", horaInicio);
                BasicNameValuePair postDiaFin = new BasicNameValuePair("dia_fin", listaCtrlUso.get(i).getDiaHasta());
                BasicNameValuePair postHoraFin = new BasicNameValuePair("hora_fin", horaFin);

                datosPost.add(postID);
                datosPost.add(postPatente);
                datosPost.add(postDiaInicio);
                datosPost.add(postHoraInicio);
                datosPost.add(postDiaFin);
                datosPost.add(postHoraFin);

                Log.d("Cfg", datosPost.toString());

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
                        ResultadoWS += stringBuilder.toString();
                        contador_exito++;

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

            return ResultadoWS;
        }

        @Override
        protected void onPostExecute(String Resultado) {
            if(Resultado != null) {
                Log.d("ControlU.onPostExecute", Resultado);
                if (contador_exito == listaCtrlUso.size())
                    Toast.makeText(getApplicationContext(), getString(R.string.exito_cambiar_ctrl_uso), Toast.LENGTH_SHORT).show();
                /*boolean exito = false;
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    JSONArray jsonArr = jsonObj.getJSONArray("ControlDeUso");
                    if(jsonArr!=null){
                        if(jsonArr.length()>0){
                            for(int i=0;i<jsonArr.length();i++){
                                JSONObject Veh = jsonArr.getJSONObject(i);
                                //{"GPS" : "G280","Patente" : "GSRT52","Fecha_ini" : "2","Fecha_fin" : "5","Hora_ini" : "12:45:12","Hora_fin" : "14:12:12","Estado" : "1"},
                                ControlUsoModel Item = new ControlUsoModel(Veh.getString("GPS"), Veh.getString("Patente"), Veh.getString("Estado"), Veh.getString("Fecha_ini"), Veh.getString("Fecha_fin"), Veh.getString("Hora_ini"), Veh.getString("Hora_fin"));
                                listaControlUso.add(Item);
                            }

                            // Verificar que la lista se lleno
                            if(listaControlUso.size()>0){
                                // Poblar el listView con los datos leidos desde el ws
                                AdapterListConfigControlUso adapter = new AdapterListConfigControlUso(getBaseContext(), listaControlUso, wsUsuario, wsPassword);
                                lv.setAdapter(adapter);
                                //lv.setTextFilterEnabled(true);
                            }
                            else{
                                // Mostrar un mensaje que no hay elementos para este usuario
                                tvNoHay.setVisibility(View.VISIBLE);
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }*/
            }
            else {
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }

    }
}
