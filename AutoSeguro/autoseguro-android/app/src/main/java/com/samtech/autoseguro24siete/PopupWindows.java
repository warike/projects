package com.samtech.autoseguro24siete;

import android.app.DialogFragment;
import android.app.FragmentManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
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

/**
 * Created by gurofo on 3/4/16.
 */
public class PopupWindows extends DialogFragment {

    String titulo, texto;
    Button btnSolicitarEjecutivo;
    boolean isResponse;
    View rootView;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.popupview, container, false);

        Bundle bundle = getArguments();

        if(bundle != null) {
            titulo = bundle.getString("titulo", "No titulo");
            texto = bundle.getString("texto", "No texto");
            isResponse = bundle.getBoolean("isResponse", false);
        }

        TextView tvTitulo = (TextView) rootView.findViewById(R.id.txtTitulo);
        TextView tvTexto = (TextView) rootView.findViewById(R.id.txtTexto);

        tvTitulo.setText(titulo);
        tvTexto.setText(texto);

        btnSolicitarEjecutivo = (Button) rootView.findViewById(R.id.btnSolicitarEjecutivo);
        if (isResponse){
            btnSolicitarEjecutivo.setText("Cerrar");
        }
        btnSolicitarEjecutivo.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!isResponse) {
                    Log.d("Button pressed", "button pressed");
                    if (PreferenceManager.getDefaultSharedPreferences(getActivity().getApplicationContext()).getBoolean("isRegistered", false)) {
                        String nombre = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("nombreDemo", "");
                        String correo = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("emailDemo", "");
                        String telefono = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("telefonoDemo", "");
                        SolicitarEjecutivoTask ejecutivoTask = new SolicitarEjecutivoTask(nombre, telefono, correo);
                        ejecutivoTask.execute((Void) null);
                    } else {
                        FragmentManager fm = getFragmentManager();
                        RegistrarDemoActivity fragment = new RegistrarDemoActivity();
                        dismiss();
                        fragment.show(fm, "popupwindow");
                    }
                } else {
                    dismiss();
                }
            }
        });

        getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);

        return rootView;
    }

    public class SolicitarEjecutivoTask extends AsyncTask<Void, Void, String> {

        String urlWS ="http://libs.samtech.cl/movil/MailUsuarioDemo_SinLogin.asp";
        String nombre, telefono, correo;

        SolicitarEjecutivoTask(String nombre, String telefono, String correo){
            this.nombre = nombre;
            this.telefono = telefono;
            this.correo = correo;
        }

        @Override
        protected void onPostExecute(String Resultado) {
            super.onPostExecute(Resultado);

            if(Resultado!=null){
                Log.d("SolicitarEjecutivo", Resultado);
                String respuestSTR = "";
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("Resp");
                        if(jsonArr != null) {
                            if (jsonArr.length() > 0) {
                                JSONObject jsonCont = jsonArr.getJSONObject(0);  // Se considera solo el primero
                                respuestSTR = jsonCont.getString("mensaje");
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (!respuestSTR.isEmpty()){
                    FragmentManager fm = getFragmentManager();
                    PopupWindows fragment = new PopupWindows();
                    Bundle bundle = new Bundle();
                    bundle.putString("titulo", "Aviso");
                    bundle.putString("texto", respuestSTR);
                    bundle.putBoolean("isResponse", true);
                    fragment.setArguments(bundle);
                    fragment.show(fm, "popupwindow");
                    dismiss();
                }
                Toast.makeText(rootView.getContext(), respuestSTR, Toast.LENGTH_SHORT).show();
            }
            else{
                Toast.makeText(rootView.getContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
                //finish();
            }
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postNombre = new BasicNameValuePair("ilogin", nombre);
            BasicNameValuePair postTelefono = new BasicNameValuePair("telefono", telefono);
            BasicNameValuePair postCorreo = new BasicNameValuePair("email", correo);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postNombre);
            datosPost.add(postTelefono);
            datosPost.add(postCorreo);


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
    }
}
