package com.samtech.autoseguro24siete.Adapters;

import android.preference.PreferenceManager;
import android.widget.BaseAdapter;
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

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Models.ControlUsoModel;
import com.samtech.autoseguro24siete.R;

import javax.xml.transform.Result;

/**
 * Created by Tato on 21-09-2015.
 */
public class AdapterListControlUso extends BaseAdapter implements Filterable {
    private Context c;
    private ArrayList<ControlUsoModel> listaControlUso, listaFiltrada;
    private String Usr, Psw;
    private ListaFiltro Filtro;

    public AdapterListControlUso(Context ctx, ArrayList<ControlUsoModel> lista, String usuario, String password) {
        c = ctx;
        listaControlUso = lista;
        listaFiltrada = lista;
        Usr = usuario;
        Psw = password;
        Filtro = new ListaFiltro();
    }

    @Override
    public int getCount() {
        if (listaFiltrada == null) listaFiltrada = listaControlUso;
        return listaFiltrada.size();
    }

    @Override
    public Object getItem(int position) {
        return listaControlUso.get(position);
    }

    @Override
    public long getItemId(int position) {
        //String idV = listaControlUso.get(position).getIdVehiculo();
        return position;
    }

    public boolean esTodosActivados(){
        boolean flag = true;
        for(int i=0;i<listaControlUso.size();i++){
            if(listaControlUso.get(i).getActivado().compareToIgnoreCase("0")==0 && listaControlUso.get(i).getPatente().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
    }

    public boolean esTodosDesactivados(){
        boolean flag = true;
        for(int i=0;i<listaControlUso.size();i++){
            if(listaControlUso.get(i).getActivado().compareToIgnoreCase("1")==0 && listaControlUso.get(i).getPatente().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View vista = convertView;

        // utilizando un holder para optimizar la memoria
        final ViewHolder holder;
        if (vista == null) {
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            vista = inf.inflate(R.layout.estacionado_lista_item, null);

            holder = new ViewHolder();
            holder.tvPatente = (TextView) vista.findViewById(R.id.txtPatente);
            holder.ivSwitch = (ImageView) vista.findViewById(R.id.btn_switch);
            vista.setTag(holder);
        } else {
            holder = (ViewHolder) vista.getTag();
        }

        if (position < listaFiltrada.size()) {
            holder.tvPatente.setText(listaFiltrada.get(position).getNombre());
            holder.estado = listaFiltrada.get(position).getActivado();
        }

        if (holder.estado.compareToIgnoreCase("0")==0) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
        else holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
        final int pos = position;
        holder.ivSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ControlUsoTask cuTsk;
                if (holder.estado.compareToIgnoreCase("0") == 0) { // cambiar a on
                    holder.estado = "1";
                    holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                    listaFiltrada.get(pos).setActivado("1");

                    // Llamar a WS para cambiar el estado
                    cuTsk = new ControlUsoTask(Usr,Psw, "1", listaFiltrada.get(pos).getIdVehiculo(), listaFiltrada.get(pos).getPatente());
                } else { // cambiar a off
                    holder.estado = "0";
                    holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                    listaFiltrada.get(pos).setActivado("0");

                    // Llamar a WS para cambiar el estado
                    cuTsk = new ControlUsoTask(Usr,Psw, "0", listaFiltrada.get(pos).getIdVehiculo(), listaFiltrada.get(pos).getPatente());
                }
                cuTsk.execute((Void) null);
            }
        });

        return vista;
    }

    private static class ViewHolder {
        TextView tvPatente;
        ImageView ivSwitch;
        String estado;
    }

    @Override
    public Filter getFilter() {
        return Filtro;
    }

    private class ListaFiltro extends Filter {
        ArrayList<ControlUsoModel> resultadosFiltro;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            resultadosFiltro = new ArrayList<ControlUsoModel>();

            FilterResults results = new FilterResults();

            if (constraint == null || constraint.toString().isEmpty()) {
                resultadosFiltro = listaControlUso;
            }
            else {
                String filterString = constraint.toString().toLowerCase();
                for (int i = 0; i < listaControlUso.size(); i++) {
                    if (listaControlUso.get(i).getPatente().toLowerCase().contains(filterString) || listaControlUso.get(i).getNombre().toLowerCase().contains(filterString)) {
                        resultadosFiltro.add(listaControlUso.get(i));
                    }
                }
            }

            results.values = resultadosFiltro;
            results.count = resultadosFiltro.size();

            return results;
        }

        @SuppressWarnings("unchecked")
        @Override
        protected void publishResults(CharSequence constraint, FilterResults results) {
            if (results.count == 0) {
                listaFiltrada = new ArrayList<ControlUsoModel>();
                notifyDataSetInvalidated();
            } else {
                listaFiltrada = (ArrayList<ControlUsoModel>) results.values;
                notifyDataSetChanged();
            }
        }
    }

    // Permite cambiar el estado del control de uso de un gps/vehiculo
    public class ControlUsoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeUso.asp";
        private final String wsUsuario;
        private final String wsPassword;
        private final String wsAccion;
        private final String wsEstado;
        private final String wsGPS;
        private final String wsPatente;

        ControlUsoTask(String Usr, String Psw, String Estado, String idGPS, String Patente) {
            wsUsuario = Usr;
            wsPassword = Psw;
            wsAccion = "3"; // Lista todos los items de control de uso asociados al cliente
            wsEstado = Estado;
            wsPatente = Patente;
            wsGPS = idGPS;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postAcc = new BasicNameValuePair("accion", wsAccion);
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", wsUsuario);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", wsPassword);
            BasicNameValuePair postEstado = new BasicNameValuePair("estado", wsEstado);
            BasicNameValuePair postID = new BasicNameValuePair("id", wsGPS);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", wsPatente);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postAcc);
            datosPost.add(postEstado);
            datosPost.add(postID);
            datosPost.add(postPatente);

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
                    while ((bufferedStrChunk = bufferedReader.readLine()) != null) {
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
                Log.d("AdapterControl Uso", Resultado);
                if(esTodosDesactivados()) PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControlUso", "0").commit();
                else PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControlUso", "1").commit();
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }

        @Override
        protected void onCancelled() {
            /*cuTsk = null;
            mostrarProgreso(false); */
        }
    }
}
