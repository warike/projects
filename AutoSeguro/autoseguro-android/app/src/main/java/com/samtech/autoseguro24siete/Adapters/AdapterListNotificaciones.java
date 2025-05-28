package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Models.NotificacionesModel;
import com.samtech.autoseguro24siete.R;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Tato on 30-08-2015.
 */
public class AdapterListNotificaciones extends BaseAdapter {
    private Context c;
    private String Usr, Psw, Usr_Lat, Usr_Lng;
    private ArrayList<NotificacionesModel> listaNotificaciones;
    private int estadoMovimiento = -1, estadoEncendido = -1;

    public AdapterListNotificaciones(Context c, String usr, String psw, ArrayList<NotificacionesModel> lista){
        this.c = c;
        Usr = usr;
        Psw = psw;
        listaNotificaciones = lista;
    }

    @Override
    public int getCount() {
        if(listaNotificaciones == null) return 0;
        else return listaNotificaciones.size();
    }

    @Override
    public Object getItem(int position) {
        return listaNotificaciones.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;

        if(convertView == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.notificacion_item, null);

            holder = new ViewHolder();
            holder.txtTitulo = (TextView) convertView.findViewById(R.id.txtNotificacion);
            holder.txtDescripcion = (TextView) convertView.findViewById(R.id.txtDescripcion);
            holder.btnSwitch = (ImageView) convertView.findViewById(R.id.btn_switch);
            convertView.setTag(holder);
        }
        else holder = (ViewHolder) convertView.getTag();

        if(position<listaNotificaciones.size()){
            holder.txtTitulo.setText(listaNotificaciones.get(position).getTitulo());
            String descripcion = listaNotificaciones.get(position).getDescripcion();
            if(descripcion == null || descripcion.isEmpty() || descripcion.length() == 0) holder.txtDescripcion.setVisibility(View.INVISIBLE);
            else holder.txtDescripcion.setText(descripcion);

            if(listaNotificaciones.get(position).getEstado().contentEquals("1")) holder.btnSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
            else holder.btnSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
        }

        if(listaNotificaciones.get(position).getTitulo().compareToIgnoreCase("Encendido de Motor")== 0) estadoEncendido = Integer.parseInt(listaNotificaciones.get(position).getEstado());
        if(listaNotificaciones.get(position).getTitulo().compareToIgnoreCase("Movimiento")== 0) estadoMovimiento = Integer.parseInt(listaNotificaciones.get(position).getEstado());

        final int pos = position;

        holder.btnSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean reglaNegocio = true;

                if(listaNotificaciones.get(pos).getEstado().contentEquals("1")){
                    if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Movimiento")== 0 && estadoEncendido == 0) reglaNegocio = false;
                    if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Encendido de Motor")== 0 && estadoMovimiento == 0) reglaNegocio = false;

                    if(reglaNegocio){
                        if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Encendido de Motor")== 0) estadoEncendido = 0;
                        if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Movimiento")== 0) estadoMovimiento = 0;

                        listaNotificaciones.get(pos).setEstado("0");
                        holder.btnSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        ActivarNotif n = new ActivarNotif(Usr, Psw, listaNotificaciones.get(pos).getIdNotificacion(), "0");
                        n.execute((Void) null);
                    }
                    else Toast.makeText(c, c.getString(R.string.error_una_activa), Toast.LENGTH_SHORT).show();
                }
                else{
                    if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Encendido de Motor")== 0) estadoEncendido = 1;
                    if(listaNotificaciones.get(pos).getTitulo().compareToIgnoreCase("Movimiento")== 0) estadoMovimiento = 1;

                    listaNotificaciones.get(pos).setEstado("1");
                    holder.btnSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                    ActivarNotif n = new ActivarNotif(Usr, Psw, listaNotificaciones.get(pos).getIdNotificacion(), "1");
                    n.execute((Void) null);
                }
            }
        });

        return convertView;
    }

    public static class ViewHolder{
        TextView txtTitulo;
        TextView txtDescripcion;
        ImageView btnSwitch;
    }

    // Permite cargar la lista de vehiculos para el modo estacionado
    public class ActivarNotif extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/Notificaciones.asp";
        private final String Usr;
        private final String Psw;
        private final String Accion;
        private final String id;
        private final String estado;

        ActivarNotif(String Usuario, String Password, String idNotif, String estado) {
            Usr = Usuario;
            Psw = Password;
            Accion = "2";
            id = idNotif;
            this.estado = estado;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", Accion);
            BasicNameValuePair postID = new BasicNameValuePair("id_notificacion", id);
            BasicNameValuePair postEstado= new BasicNameValuePair("estado", estado);


            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postAccion);
            datosPost.add(postID);
            datosPost.add(postEstado);

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
                Log.d("NotificWS", Resultado);
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }
    }
}
