package com.samtech.autoseguro24siete;

import android.app.ProgressDialog;
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
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Models.ContactosModel;

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

/**
 * Created by gurofo on 10/30/15.
 */
public class CrearContactoActivity extends ActionBarActivity {
    ContactosModel contacto;
    boolean flagEditar = false;
    String Usr, Psw;
    EditText etNombreContacto, etFono, etEmail;
    ProgressBar pb;
    ProgressDialog dialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_crear_contacto);

        etNombreContacto = (EditText) findViewById(R.id.etNombreContacto);
        etFono = (EditText) findViewById(R.id.etFono);
        etEmail = (EditText) findViewById(R.id.etEmail);
        pb = (ProgressBar) findViewById(R.id.pbCargando);

        Bundle b = getIntent().getExtras();
        if (b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
            contacto = (ContactosModel) b.get("Contacto");
            if (contacto != null){
                flagEditar = true;
                etNombreContacto.setText(contacto.getNombre().toString());
                etFono.setText(contacto.getTelefono().toString());
                etEmail.setText(contacto.getEmail().toString());

                /**
                 * Add ContactosTask
                 */
            } else {
                /**
                 * Add ContactosTask
                 */
            }
        } else {
            finish();
        }

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setearBarraSuperior();
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_crear_contacto, menu);
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
            if(!chkNull(etNombreContacto.getText().toString(), etFono.getText().toString(),
                    etEmail.getText().toString())){
                if(!flagEditar){
                    crearContactoTask ccTask = new crearContactoTask(Usr, Psw,
                            //contacto.getIdCont().toString(),
                            etNombreContacto.getText().toString(),
                            etFono.getText().toString(),
                            etEmail.getText().toString(), "2");
                    ccTask.execute((Void) null);
                }
                else{ // se está editando
                    /**
                     * TaskCrearUsuario (editar)
                     */
                    crearContactoTask ccTask = new crearContactoTask(Usr, Psw,
                            contacto.getIdCont().toString(),
                            etNombreContacto.getText().toString(),
                            etFono.getText().toString(),
                            etEmail.getText().toString(),"3");
                    ccTask.execute((Void) null);
                }
            }
            else {
                Toast.makeText(getBaseContext(), getBaseContext().getString(R.string.error_incompleto),
                        Toast.LENGTH_SHORT).show();
            }
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public boolean chkNull(String nombre, String fono, String email){
        if (nombre.isEmpty() || fono.isEmpty() || email.isEmpty()) return true;
        else return false;
    }

    public void setearBarraSuperior(){

        ColorDrawable colorDrawable = new ColorDrawable(Color.parseColor("#B71C1C"));
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

    public class crearContactoTask extends AsyncTask<Void, Void, String> {

        private final String urlWS = "http://libs.samtech.cl/movil/contacto.asp";
        private final String Usr;
        private final String Psw;
        private String idCont;
        private final String nombre;
        private final String telefono;
        private final String email;
        private final String sw;

        crearContactoTask(String Usr, String Psw, String idCont,String nombre, String telefono,
                          String email, String sw) {
            this.Usr = Usr;
            this.Psw = Psw;
            this.idCont = idCont;
            this.nombre = nombre;
            this.telefono = telefono;
            this.email = email;
            this.sw = sw;
        }

        crearContactoTask(String Usr, String Psw, String nombre, String telefono,
                          String email, String sw) {
            this.Usr = Usr;
            this.Psw = Psw;
            this.nombre = nombre;
            this.telefono = telefono;
            this.email = email;
            this.sw = sw;
        }

        @Override
        protected void onPreExecute() {
            String titulo = "Creando Contacto";
            if(flagEditar) titulo = "Actualizando Contacto";
            dialog = ProgressDialog.show(CrearContactoActivity.this, titulo, "Espere, por favor...", true);
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postIdCont = new BasicNameValuePair("id_cont", idCont);
            BasicNameValuePair postNombre = new BasicNameValuePair("nombre", nombre);
            BasicNameValuePair postTelefono = new BasicNameValuePair("telefono", telefono);
            BasicNameValuePair postMail = new BasicNameValuePair("mail", email);
            BasicNameValuePair postSw = new BasicNameValuePair("sw", sw);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postIdCont);
            datosPost.add(postNombre);
            datosPost.add(postMail);
            datosPost.add(postTelefono);
            datosPost.add(postSw);

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
                Log.d("crearContacto", Resultado);
                String respuestSTR = "";
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("lista");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                JSONObject jsonCont = jsonArr.getJSONObject(0);  // Se considera solo el primero
                                respuestSTR = jsonCont.getString("Nombre");
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
                    Toast.makeText(getBaseContext(), respuestSTR, Toast.LENGTH_SHORT).show();
                    dialog.dismiss();
                    finish();
                }

            }
            else{
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }
    }
}
