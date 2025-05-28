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

public class SOSDemoActivity extends DialogFragment implements View.OnClickListener{

    Button btnSi, btnNo;
    View rootView;
    Boolean isRegistered;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.activity_sosdemo, container, false);

        btnSi = (Button) rootView.findViewById(R.id.btnSiSosDemo);
        btnNo = (Button) rootView.findViewById(R.id.btnNoSosDemo);

        btnNo.setOnClickListener(this);
        btnSi.setOnClickListener(this);

        getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);

        isRegistered = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getBoolean("isRegistered", false);

        return rootView;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.btnNoSosDemo:
                this.dismiss();
                break;
            case R.id.btnSiSosDemo:
                gestorGPS miGPS = new gestorGPS(rootView.getContext());
                if(miGPS.puedeObtenerUbicacion()){
                    String lat = miGPS.obtenerLat()+"";
                    String lng = miGPS.obtenerLng()+"";
                    if(miGPS.obtenerLat()!=0.0 && miGPS.obtenerLng()!=0.0){
                        if (isRegistered){
                            String nombre = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("nombreDemo", "");
                            String correo = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("emailDemo", "");
                            String telefono = PreferenceManager.getDefaultSharedPreferences(rootView.getContext()).getString("telefonoDemo", "");
                            SOSDemoTask sTask = new SOSDemoTask(nombre, telefono, correo, lat, lng);
                            sTask.execute((Void) null);
                        }
                    }
                    else {
                        Toast.makeText(rootView.getContext(), getString(R.string.SOS_no_ubicacion), Toast.LENGTH_SHORT).show();
                        Log.d("MenuActiv", "Lat:"+miGPS.obtenerLat()+" Lng:"+miGPS.obtenerLng());
                    }
                }
                else miGPS.mostrarAlertaConfig();
                miGPS.detenerGPS();
                break;
            default:
                break;
        }
    }

    public class SOSDemoTask extends AsyncTask<Void, Void, String> {

        //libs.samtech.cl/movil/MailUsuarioDemo_SinLogin.asp?ilogin=fdrt&telefono=968448387&correo=m.martinez@samtech.cl
        private final String urlWS = "http://libs.samtech.cl/movil/alarmaSOS_demo.asp";
        private final String ilogin;
        private final String telefono;
        private final String correo;
        private final String Latitud;
        private final String Longitud;

        SOSDemoTask(String Usr, String telefono, String correo, String lat, String lng) {
            ilogin = Usr;
            this.telefono = telefono;
            this.correo = correo;
            Latitud = lat;
            Longitud = lng;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);
            Log.d("SOSDEMO", ilogin+telefono+correo+Latitud+Longitud);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("nombre", ilogin);
            BasicNameValuePair postTel = new BasicNameValuePair("telefono", telefono);
            BasicNameValuePair postCorreo = new BasicNameValuePair("correo", correo);
            BasicNameValuePair postLat = new BasicNameValuePair("latitud", Latitud);
            BasicNameValuePair postLng = new BasicNameValuePair("longitud", Longitud);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postTel);
            datosPost.add(postCorreo);
            datosPost.add(postLat);
            datosPost.add(postLng);

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
                Log.d("ModoEst.onPostExecute", Resultado);
                String mensaje = "";

                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("SOSdemo");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    mensaje = jsonRes.getString("mensaje");
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(!mensaje.isEmpty()) {
                    FragmentManager fm = getFragmentManager();
                    PopupWindows fragment = new PopupWindows();
                    Bundle bundle = new Bundle();
                    bundle.putString("titulo", "SOS");
                    bundle.putString("texto", mensaje);
                    bundle.putBoolean("isResponse", true);
                    fragment.setArguments(bundle);
                    fragment.show(fm, "popupwindow");
                }
            }
            else{
                Toast.makeText(rootView.getContext(), getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
            dismiss();
        }
    }
}
