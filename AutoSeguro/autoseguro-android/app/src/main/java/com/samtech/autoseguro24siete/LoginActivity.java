package com.samtech.autoseguro24siete;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

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

public class LoginActivity extends Activity{
    private LoginTask mAuthTask = null;
    // UI references.
    private EditText etUsuario;
    private EditText etPassword;
    private TextView tvOlvide;
    private View mProgressView;
    private View mLoginFormView;
    private boolean recordar = true;
    Intent intent;
    ProgressDialog progress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        etUsuario = (EditText) findViewById(R.id.usuario);

        progress =new ProgressDialog(this);
        progress.setMessage("Cargando");

        etPassword = (EditText) findViewById(R.id.password);
        etPassword.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_NULL) {
                    iniciarSesion();
                    return true;
                }
                return false;
            }
        });

        ImageView ivIngresar = (ImageView) findViewById(R.id.btn_ingresar);
        ivIngresar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                iniciarSesion();
                System.out.println("Iniciar Sesion");
            }
        });

        ImageView btnInterruptor = (ImageView) findViewById(R.id.btn_interruptor);
        btnInterruptor.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) { // Toggle de la imagen por on/off
                if(recordar){
                    ((ImageView) view).setImageResource(R.drawable.off);
                    recordar = false;
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("btnRec", recordar).commit();
                }
                else{
                    ((ImageView) view).setImageResource(R.drawable.on);
                    recordar = true;
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("btnRec", recordar).commit();
                }
            }
        });

        mLoginFormView = findViewById(R.id.login_form);
        mProgressView = findViewById(R.id.login_progress);

        // Obtener los valores guardados en shared preferences
        boolean spRecordar = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("ultimoRec", false);
        boolean spBtnRecordar = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("btnRec", false);
        String spUsr = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoUsr", "");
        String spPsw = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPsw", "");
        Log.d("LoginActivity", spRecordar+"");
        if(spRecordar){ // loguear al usuario
            Intent intent = new Intent(LoginActivity.this, MenuActivity.class);
            String spTipo = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoTipo", "");
            String spPlan = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPlan", "");
            intent.putExtra("usr", spUsr);
            intent.putExtra("pass", spPsw);
            intent.putExtra("tipo", spTipo);
            intent.putExtra("plan", spPlan);
            startActivity(intent);
            finish();
        }
        else { // setear los valores del ultimo usuario
            etUsuario.setText(spUsr);
            etPassword.setText(spPsw);
            if(!spBtnRecordar){
                btnInterruptor.setImageResource(R.drawable.off);
                recordar = false;
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("btnRec", recordar).commit();
            }
            else{
                btnInterruptor.setImageResource(R.drawable.on);
                recordar = true;
                PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("btnRec", recordar).commit();
            }
        }

        // Olvidé mi Contraseña
        tvOlvide = (TextView) findViewById(R.id.tvOlvide);
        tvOlvide.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                final EditText input = new EditText(getApplicationContext());
                input.setHint("Ingrese Nombre de Usuario");
                input.setTextColor(Color.BLACK);
                input.setHintTextColor(Color.GRAY);
                input.setBackgroundColor(Color.WHITE);
                final AlertDialog alertDialog = new AlertDialog.Builder(LoginActivity.this).create();
                alertDialog.setTitle("Recuperar Contraseña");
                alertDialog.setMessage("La contraseña será enviada a su correo electrónico");
                alertDialog.setView(input);
                alertDialog.setButton("Enviar", new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        if (!input.getText().toString().isEmpty()) {
                            OlvideContrasenaTask ocTask = new OlvideContrasenaTask(input.getText().toString());
                            ocTask.execute((Void) null);
                        } else {
                            Toast.makeText(LoginActivity.this, "Ingrese nombre de usuario", Toast.LENGTH_SHORT).show();
                        }
                    }
                });
                alertDialog.show();
            }
        });
    }

    public void iniciarSesion() {
        if (mAuthTask != null) {
            return;
        }

        // Reset errors.
        etUsuario.setError(null);
        etPassword.setError(null);

        // Store values at the time of the login attempt.
        String usuario = etUsuario.getText().toString();
        String password = etPassword.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            etPassword.setError(getString(R.string.error_pass_invalido));
            focusView = etPassword;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(usuario)) {
            etUsuario.setError(getString(R.string.error_campo_necesario));
            focusView = etUsuario;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(password)) {
            etPassword.setError(getString(R.string.error_campo_necesario));
            focusView = etPassword;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            // Show a progress spinner, and kick off a background task to
            // perform the user login attempt.
            showProgress(true);
            mAuthTask = new LoginTask(usuario, password);
            mAuthTask.execute((Void) null);
        }
    }

    private boolean isPasswordValid(String password) {
        return password.length() > 2;
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
    public void showProgress(final boolean show) {
        // On Honeycomb MR2 we have the ViewPropertyAnimator APIs, which allow
        // for very easy animations. If available, use these APIs to fade-in
        // the progress spinner.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB_MR2) {
            int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);

            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
            mLoginFormView.animate().setDuration(shortAnimTime).alpha(
                    show ? 0 : 1).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
                }
            });

            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mProgressView.animate().setDuration(shortAnimTime).alpha(
                    show ? 1 : 0).setListener(new AnimatorListenerAdapter() {
                @Override
                public void onAnimationEnd(Animator animation) {
                    mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
                }
            });
        } else {
            // The ViewPropertyAnimator APIs are not available, so simply show
            // and hide the relevant UI components.
            mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
        }
    }

    public class LoginTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/SesionUsuario.asp";
        private final String mUsuario;
        private final String mPassword;
        private final String mApp;

        LoginTask(String Usr, String Psw) {
            mUsuario = Usr;
            mPassword = Psw;
            //mApp = "claro";
            mApp = getResources().getString(R.string.app_ws2);
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postApp = new BasicNameValuePair("app", mApp);
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", mUsuario);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", mPassword);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postApp);

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
                Log.d("Login.onPostExecute", Resultado);
                Boolean exito = false;
                String tipoPlan = "", tipoUsr = "", idGPS ="", Patente = "", estadoVeh ="", estadoControlV = "", cantVeh="", demo="";

                //{"users":[{"mensaje" : "1","usuario" : "Masivo","tipo_usuario" : "1","total" : "34","gps" : "0000","patente" : "0000","estado" : "1","contro_vel" : "1"}]}
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("users");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                JSONObject jsonUsr = jsonArr.getJSONObject(0);
                                if (jsonUsr != null) {
                                    String estado = jsonUsr.getString("mensaje");
                                    if (estado != null) {
                                        if (!estado.isEmpty()) {
                                            if (estado.compareTo("1") == 0) {
                                                tipoPlan = jsonUsr.getString("usuario");
                                                tipoUsr = jsonUsr.getString("tipo_usuario");
                                                idGPS = jsonUsr.getString("gps");
                                                Patente = jsonUsr.getString("patente");
                                                estadoVeh = jsonUsr.getString("estado");
                                                estadoControlV = jsonUsr.getString("contro_vel");
                                                cantVeh = jsonUsr.getString("total");
                                                demo = jsonUsr.getString("demo");
                                                if (tipoPlan != null && tipoUsr != null) {
                                                    if (!tipoPlan.isEmpty() && !tipoUsr.isEmpty()) {
                                                        tipoPlan = tipoPlan.toLowerCase();
                                                        if(tipoPlan.compareTo("masivo") == 0) exito = true;
                                                    }
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

                if (exito) {
                    intent = new Intent(LoginActivity.this, MenuActivity.class);
                    intent.putExtra("usr", mUsuario);
                    intent.putExtra("pass", mPassword);
                    intent.putExtra("tipoPlan", tipoPlan);
                    intent.putExtra("tipoUsuario", tipoUsr);
                    intent.putExtra("VehAsignado", idGPS);
                    intent.putExtra("estadoVehAsignado", estadoVeh);
                    intent.putExtra("patenteVeh", Patente);
                    intent.putExtra("estadoControl", estadoControlV);
                    intent.putExtra("cantVeh", cantVeh);
                    intent.putExtra("demo", demo);

                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("ultimoUsr", mUsuario).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("ultimoPsw", mPassword).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("ultimoPlan", tipoPlan).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("ultimoTipo", tipoUsr).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putBoolean("ultimoRec", recordar).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoVehAsignado", estadoVeh).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("estadoControl", estadoControlV).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("cantVeh", cantVeh).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("demo", demo).commit();

                    // En teoría no van
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("VehAsignado", idGPS).commit();
                    PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).edit().putString("patenteVehAsignado", Patente).commit();

                    mAuthTask = null;
                    showProgress(false);
                    startActivity(intent);
                    finish();
                }
                else {
                    mAuthTask = null;
                    showProgress(false);
                    etPassword.setError(getString(R.string.error_pass_incorrecto));
                    etPassword.requestFocus();
                }
            }
            else{
                mAuthTask = null;
                showProgress(false);
                Toast.makeText(getApplicationContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }

        @Override
        protected void onCancelled() {
            mAuthTask = null;
            showProgress(false);
        }
    }

    public class OlvideContrasenaTask extends AsyncTask<Void, Void, String> {

        private final String login;
        private final String urlWs = "http://libs.samtech.cl/movil/RecuperaContrasena.asp";

        public OlvideContrasenaTask(String login) {
            this.login = login;
        }

        @Override
        protected void onPreExecute() {
            progress.show();
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWs);

            // Informacion entregada por medio del POST
            BasicNameValuePair postLogin= new BasicNameValuePair("ilogin", login);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postLogin);

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
            progress.dismiss();
            if(Resultado!=null) {
                Log.d("Login.onPostExecute", Resultado);
                Boolean exito = false;
                String mensaje;
                //{"users":[{"mensaje" : "1","usuario" : "Masivo","tipo_usuario" : "1","total" : "34","gps" : "0000","patente" : "0000","estado" : "1","contro_vel" : "1"}]}
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if (jsonObj != null) {
                        JSONArray jsonArr = jsonObj.getJSONArray("contrasena");
                        if (jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                JSONObject jsonUsr = jsonArr.getJSONObject(0);
                                if (jsonUsr != null) {
                                    mensaje = jsonUsr.getString("mensaje");
                                    if (mensaje != null) {
                                        if (!mensaje.isEmpty()) {
                                            final AlertDialog alertDialog = new AlertDialog.Builder(LoginActivity.this).create();
                                            alertDialog.setTitle("Recuperar Contraseña");
                                            alertDialog.setMessage(mensaje);
                                            alertDialog.setButton("OK", new DialogInterface.OnClickListener() {
                                                public void onClick(DialogInterface dialog, int which) {
                                                    alertDialog.cancel();
                                                }
                                            });
                                            alertDialog.setIcon(R.drawable.conf_usuarios);
                                            alertDialog.show();
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
