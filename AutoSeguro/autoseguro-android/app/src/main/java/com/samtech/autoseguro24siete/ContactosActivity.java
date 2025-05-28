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
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Adapters.AdapterListContactos;
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
public class ContactosActivity extends ActionBarActivity {
    String Usr, Psw;
    ProgressBar pb;
    ListView lv;
    TextView tvEditar;
    ImageView ivAgregar;
    ArrayList<ContactosModel> listaContactos;
    AdapterListContactos adapter;
    boolean creando = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_contactos);

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
        }
        else {
            finish();
        }
        // Desaparecemos la lista y se hace visible el cargando
        lv = (ListView) findViewById(R.id.lvContactos);

        pb = (ProgressBar) findViewById(R.id.pbCargando);

        tvEditar = (TextView) findViewById(R.id.tvEditar);
        ivAgregar = (ImageView) findViewById(R.id.ivAgregar);

        if(Usr.isEmpty() || Psw.isEmpty()) finish();
        else {
            ContactosTask uTask = new ContactosTask(Usr, Psw);
            uTask.execute((Void) null);
        }

        setearBarraSuperior();

        tvEditar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d("Usuarios", "Editar");
                if(adapter != null) {
                    if(adapter.cambiarModoEdicion()) tvEditar.setText("OK");
                    else tvEditar.setText("Editar");
                }
            }
        });

        ivAgregar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent crear = new Intent(ContactosActivity.this, CrearContactoActivity.class);
                crear.putExtra("Usr", Usr);
                crear.putExtra("Password", Psw);
                creando = true;
                startActivity(crear);
                Log.d("Contactos", "Agregar");
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(Usr.isEmpty() || Psw.isEmpty());
        else {
            if(adapter!=null) adapter.notifyDataSetInvalidated();
            ContactosTask uTask = new ContactosTask(Usr, Psw);
            uTask.execute((Void) null);
            if(adapter!=null) adapter.notifyDataSetChanged();
            if(adapter != null && tvEditar != null ){
                if(adapter.cambiarModoEdicion(true)) tvEditar.setText("Editar");
                else tvEditar.setText("Ok");
            }
        }
    }

    public void mostrarCargando(boolean flagMostrar){
        pb.setVisibility(flagMostrar ? View.VISIBLE : View.GONE);
        lv.setVisibility(flagMostrar ? View.GONE : View.VISIBLE);
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
        //getMenuInflater().inflate(R.menu.menu_usuarios, menu);
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

        return super.onOptionsItemSelected(item);
    }

    public class ContactosTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/contacto.asp";
        private final String Usr;
        private final String Psw;
        private final String sw;

        ContactosTask(String Usuario, String Password) {
            Usr = Usuario;
            Psw = Password;
            sw = "1";
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
            BasicNameValuePair postSw = new BasicNameValuePair("sw", sw);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
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
                Log.d("ContactosActiv", Resultado);
                Intent intent;
                listaContactos = new ArrayList<ContactosModel>();
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("lista");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                for(int i=0; i<jsonArr.length();i++){
                                    JSONObject jsonCont = jsonArr.getJSONObject(i);  // Se considera solo el primero
                                    if(jsonCont != null) {
                                        ContactosModel u = new ContactosModel(Usr, Psw,
                                                jsonCont.getString("Nombre"),
                                                jsonCont.getString("eMail"), jsonCont.getString("Telefono"),
                                                jsonCont.getString("ID_cont"));
                                        listaContactos.add(u);
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

                if(listaContactos.size()>0){
                    adapter = new AdapterListContactos(getBaseContext(), Usr, Psw, listaContactos);
                    lv.setAdapter(adapter);
                }
                else {
                    //tvNoHay.setVisibility(View.VISIBLE);
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

