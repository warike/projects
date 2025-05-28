package com.samtech.autoseguro24siete;

import android.app.ProgressDialog;
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
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Adapters.AdapterListAsignaVehiculo;
import com.samtech.autoseguro24siete.Models.AsignaVehiculoModel;
import com.samtech.autoseguro24siete.Models.UsuariosModel;

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

public class CrearUsuarioActivity extends ActionBarActivity {
    String Usr, Psw;
    UsuariosModel usuario;
    boolean flagEditar = false;
    EditText etUsr, etPsw1, etPsw2, etEmail, etTelefono, etNombreReal;
    TextView tvNoHay, tvMensaje;
    ProgressBar pb;
    ListView lv;
    ArrayList<AsignaVehiculoModel> listaVehiculos;
    ProgressDialog dialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crear_usuario);

        etUsr = (EditText) findViewById(R.id.etUsr);
        etPsw1 = (EditText) findViewById(R.id.etPsw1);
        etPsw2 = (EditText) findViewById(R.id.etPsw2);
        etEmail = (EditText) findViewById(R.id.etEmail);
        etTelefono = (EditText) findViewById(R.id.etFono);
        etNombreReal = (EditText) findViewById(R.id.etNombreReal);

        lv = (ListView) findViewById(R.id.lvVehiculos);
        pb = (ProgressBar) findViewById(R.id.pbCargando);
        tvNoHay = (TextView) findViewById(R.id.tvNoInfo);
        tvMensaje = (TextView) findViewById(R.id.tvMensaje);

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
            usuario = (UsuariosModel) b.get("Usuario");
            if(usuario != null) {
                flagEditar = true;
                etUsr.setText(usuario.getUsr().toString());
                etUsr.setEnabled(false);
                etPsw1.setText(usuario.getPsw().toString());
                etPsw2.setText(usuario.getPsw().toString());
                etEmail.setText(usuario.getEmail().toString());
                etTelefono.setText(usuario.getTelefono().toString());
                etNombreReal.setText(usuario.getNombreUsr().toString());

                VehiculosUsuarioTask v = new VehiculosUsuarioTask(Usr,Psw,usuario.getUsr().toString());
                v.execute((Void) null);
            }
            else{
                VehiculosUsuarioTask v = new VehiculosUsuarioTask(Usr,Psw);
                v.execute((Void) null);
            }
        }
        else {
            finish();
        }

        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setearBarraSuperior();
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
        tvMensaje.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_crear_usuario, menu);
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
            Intent intent = new Intent().setClass(this, UsuariosActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }
        else if(id == R.id.action_guardar){
            if(etPsw1.getText().toString().contentEquals(etPsw2.getText().toString())){
                if(!flagEditar){
                    crearUsuarioTask cuTask = new crearUsuarioTask(etNombreReal.getText().toString(), Usr, Psw, etUsr.getText().toString(), etPsw1.getText().toString(), etEmail.getText().toString(), etTelefono.getText().toString(), "1");
                    cuTask.execute((Void) null);
                }
                else{ // se está editando
                    crearUsuarioTask cuTask = new crearUsuarioTask(etNombreReal.getText().toString(), Usr, Psw, etUsr.getText().toString(), etPsw1.getText().toString(), etEmail.getText().toString(), etTelefono.getText().toString(), "2");
                    cuTask.execute((Void) null);
                }
            }
            else {
                Toast.makeText(getBaseContext(), getBaseContext().getString(R.string.error_psw_distintos), Toast.LENGTH_SHORT).show();
            }
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

    // Permite cargar la lista de vehiculos disponibles para el usuario
    public class VehiculosUsuarioTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/AsignaVehiculosPorUsuario.asp";
        private final String Usr;
        private final String Psw;
        private final String Accion;
        private final String UsuarioHijo;
        private final String Estado;

        VehiculosUsuarioTask(String Usuario, String Password) {
            Usr = Usuario;
            Psw = Password;
            Accion = "1";
            UsuarioHijo = "";
            Estado = null;
        }

        VehiculosUsuarioTask(String UsuarioPadre, String Password, String Usuario) {
            Usr = UsuarioPadre;
            Psw = Password;
            Accion = "1";
            UsuarioHijo = Usuario;
            Estado = "1";
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
            BasicNameValuePair postAcc = new BasicNameValuePair("accion", Accion);
            BasicNameValuePair postEstado = null;
            //if(Estado != null) postEstado = new BasicNameValuePair("estado", Estado);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postAcc);
            //if(Estado != null && postEstado != null) datosPost.add(postEstado);

            if(!UsuarioHijo.isEmpty()){
                BasicNameValuePair postSubUsr = new BasicNameValuePair("usuario", UsuarioHijo);
                datosPost.add(postSubUsr);
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
        protected void onPostExecute(String Resultado) {
            if(Resultado!=null){
                Log.d("AsignaVehiculos", Resultado);
                listaVehiculos = new ArrayList<AsignaVehiculoModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("vehiculos");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonVeh = jsonArr.getJSONObject(i);  // Se considera solo el primero
                                    if (jsonVeh != null) {
                                        if(!jsonVeh.getString("GPS").isEmpty() && !jsonVeh.getString("Patente").isEmpty()) {
                                            AsignaVehiculoModel a = new AsignaVehiculoModel(jsonVeh.getString("GPS"), jsonVeh.getString("Patente"), jsonVeh.getString("Estado"));
                                            listaVehiculos.add(a);
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
                        ArrayList<AsignaVehiculoModel> listaVehiculosAux = new ArrayList<AsignaVehiculoModel>();
                        listaVehiculosAux.add(new AsignaVehiculoModel("0", "Activar Todos", "0"));
                        for(int i=0; i<listaVehiculos.size();i++) listaVehiculosAux.add(listaVehiculos.get(i));

                        listaVehiculos = new ArrayList<AsignaVehiculoModel>();
                        listaVehiculos = listaVehiculosAux;
                    }
                    AdapterListAsignaVehiculo adapter = new AdapterListAsignaVehiculo(getBaseContext(), Usr, Psw, listaVehiculos);
                    lv.setAdapter(adapter);
                    setListViewHeightBasedOnItems(lv);
                }
                else {
                    tvNoHay.setVisibility(View.VISIBLE);
                    tvMensaje.setVisibility(View.GONE);
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

    // Funcion que redimensiona dinamicamente la altura del scrollview
    public static boolean setListViewHeightBasedOnItems(ListView listView) {
        ListAdapter listAdapter = listView.getAdapter();
        if (listAdapter != null) {

            int numberOfItems = listAdapter.getCount();

            // Get total height of all items.
            int totalItemsHeight = 0;
            for (int itemPos = 0; itemPos < numberOfItems; itemPos++) {
                View item = listAdapter.getView(itemPos, null, listView);
                item.measure(0, 0);
                totalItemsHeight += item.getMeasuredHeight();
            }

            // Get total height of all item dividers.
            int totalDividersHeight = listView.getDividerHeight() *
                    (numberOfItems - 1);

            // Set list height.
            ViewGroup.LayoutParams params = listView.getLayoutParams();
            params.height = totalItemsHeight + totalDividersHeight;
            listView.setLayoutParams(params);
            listView.requestLayout();

            return true;

        } else {
            return false;
        }
    }

    // Permite crear el usuario en la bd
    public class crearUsuarioTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/InsertaUsuario.asp";
        private final String Nombre;
        private final String Usr;
        private final String Psw;
        private final String UsuarioNuevo;
        private final String PswNuevo;
        private final String telefono;
        private final String email;
        private final String Accion;
        private final String app;

        crearUsuarioTask(String nombre, String Usuario, String Password, String UsuarioNuevo, String PswNuevo, String email, String fono, String accion) {
            Usr = Usuario;
            Psw = Password;
            this.UsuarioNuevo = UsuarioNuevo;
            this.PswNuevo = PswNuevo;
            this.email = email;
            this.telefono = fono;
            this.Accion = accion;
            this.app = getResources().getString(R.string.app_ws2);
            this.Nombre = nombre;
        }

        @Override
        protected void onPreExecute() {
            String titulo = "Creando Usuario";
            if(flagEditar) titulo = "Actualizando Usuario";
            dialog = ProgressDialog.show(CrearUsuarioActivity.this, titulo, "Espere, por favor...", true);
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postUsrNuevo = new BasicNameValuePair("usuario", UsuarioNuevo);
            BasicNameValuePair postNombre = new BasicNameValuePair("nombre_usu", Nombre);
            BasicNameValuePair postPswNuevo = new BasicNameValuePair("clave_usuario", PswNuevo);
            BasicNameValuePair postMail = new BasicNameValuePair("mail_usuario", email);
            BasicNameValuePair postTipoIngreso = new BasicNameValuePair("tipo_ingreso", Accion);
            BasicNameValuePair postFono = new BasicNameValuePair("fono", telefono);
            BasicNameValuePair postTipoUsr = new BasicNameValuePair("tipo_usu", "2");
            BasicNameValuePair postApp = new BasicNameValuePair("app", app);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postUsrNuevo);
            datosPost.add(postPswNuevo);
            datosPost.add(postMail);
            datosPost.add(postTipoIngreso);
            datosPost.add(postFono);
            datosPost.add(postTipoUsr);
            datosPost.add(postApp);
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
                Log.d("crearUsuario", Resultado);
                // Llamar al 2do ws para asignar vehiculos
                String respuestSTR = "";
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("usuario");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                JSONObject jsonVeh = jsonArr.getJSONObject(0);  // Se considera solo el primero
                                respuestSTR = jsonVeh.getString("mensaje");
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(respuestSTR.contains("Error")){
                    Toast.makeText(getBaseContext(), respuestSTR, Toast.LENGTH_SHORT).show();
                    dialog.dismiss();
                    finish();
                }
                else{
                    asignarVehiculosUsrTask asig = new asignarVehiculosUsrTask(Usr, Psw, UsuarioNuevo,listaVehiculos);
                    asig.execute((Void) null);
                }
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class asignarVehiculosUsrTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/AsignaVehiculosPorUsuario.asp";
        private final String Usr;
        private final String Psw;
        private final String UsuarioNuevo;
        private final String Accion;
        private final ArrayList<AsignaVehiculoModel> listaAsignacion;
        private String respuesta = "";

        asignarVehiculosUsrTask(String Usuario, String Password, String UsuarioNuevo, ArrayList<AsignaVehiculoModel> lista) {
            Usr = Usuario;
            Psw = Password;
            this.UsuarioNuevo = UsuarioNuevo;
            Accion = "2";
            listaAsignacion = lista;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postUsrNuevo = new BasicNameValuePair("usuario", UsuarioNuevo);
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", Accion);

            for(int i=0;i<listaAsignacion.size();i++){
                if(!listaAsignacion.get(i).getPatenteVehiculo().contentEquals("Activar Todos")){
                    // Agrupando la informacion de logueo
                    List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
                    datosPost.add(postUsr);
                    datosPost.add(postPsw);
                    datosPost.add(postUsrNuevo);
                    datosPost.add(postAccion);
                    BasicNameValuePair postID = new BasicNameValuePair("id", listaAsignacion.get(i).getIdVehiculo());
                    BasicNameValuePair postPatente = new BasicNameValuePair("patente", listaAsignacion.get(i).getPatenteVehiculo());
                    BasicNameValuePair postEstadoAsig = new BasicNameValuePair("estado", listaAsignacion.get(i).getEstadoAsignacion());

                    datosPost.add(postID);
                    datosPost.add(postPatente);
                    datosPost.add(postEstadoAsig);
                    Log.d("datosCrear", datosPost.toString());

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
                            respuesta = respuesta + stringBuilder.toString();

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
            }

            return respuesta;
        }

        @Override
        protected void onPostExecute(String Resultado) {
            dialog.dismiss();
            if(Resultado!=null){
                Log.d("AsignaVehWS", Resultado);
                Log.d("AsignaVehWS", respuesta);
                Intent intent = new Intent().setClass(CrearUsuarioActivity.this, UsuariosActivity.class);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
                NavUtils.navigateUpTo(CrearUsuarioActivity.this, intent);
            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                // finish();
            }
        }
    }
}
