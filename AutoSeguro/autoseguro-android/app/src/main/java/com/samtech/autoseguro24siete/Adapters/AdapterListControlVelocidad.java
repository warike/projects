package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.Models.ModoEstacionadoModel;
import com.samtech.autoseguro24siete.R;

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
 * Created by Tato on 28-08-2015.
 */
public class AdapterListControlVelocidad extends BaseAdapter implements Filterable {
    private Context c;
    private String Usr, Psw;
    private ArrayList<ModoEstacionadoModel> listaVehiculos, listaVehiculosFiltrada;
    private ListaFiltro Filtro;
    private ArrayList<ViewHolder> vistas;
    private ViewHolder vActivarTodos = null;

    public AdapterListControlVelocidad(Context c, String usr, String psw, ArrayList<ModoEstacionadoModel> listaVehiculos) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        this.listaVehiculos = listaVehiculos;
        this.listaVehiculosFiltrada = listaVehiculos;
        Filtro = new ListaFiltro();
        vistas = new ArrayList<ViewHolder>();
    }

    @Override
    public int getCount() {
        if(listaVehiculosFiltrada == null) listaVehiculosFiltrada = listaVehiculos;
        return listaVehiculosFiltrada.size();
    }

    public boolean esTodosActivados(){
        boolean flag = true;
        for(int i=0;i<listaVehiculos.size();i++){
            if(listaVehiculos.get(i).getEstado().compareToIgnoreCase("0")==0 && listaVehiculos.get(i).getPatente().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
    }

    public boolean esTodosDesactivados(){
        boolean flag = true;
        for(int i=0;i<listaVehiculos.size();i++){
            if(listaVehiculos.get(i).getEstado().compareToIgnoreCase("1")==0 && listaVehiculos.get(i).getPatente().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
    }

    @Override
    public Object getItem(int position) {
        return listaVehiculosFiltrada.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;

        if(convertView == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.estacionado_lista_item, null);

            holder = new ViewHolder();
            holder.txtPatente = (TextView) convertView.findViewById(R.id.txtPatente);
            holder.ivSwitch = (ImageView) convertView.findViewById(R.id.btn_switch);

            convertView.setTag(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }

        if(position < listaVehiculosFiltrada.size()) {
            String nombreVeh = listaVehiculosFiltrada.get(position).getNombre();
            if(nombreVeh.isEmpty()) nombreVeh = listaVehiculosFiltrada.get(position).getPatente();
            holder.txtPatente.setText(nombreVeh);
            holder.estado = Integer.parseInt(listaVehiculosFiltrada.get(position).getEstado());
        }

        if(listaVehiculosFiltrada.get(position).getPatente().contentEquals("Activar Todos")){
            if(esTodosActivados()) holder.estado = 1;
            else holder.estado = 0;
            if(vActivarTodos == null) vActivarTodos = holder;
        }

        if(holder.estado == 0) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
        else if(holder.estado == 1) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));

        holder.ivSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listaVehiculosFiltrada.get(position).getPatente().contentEquals("Activar Todos")) { // Activar Todos
                    CambiarAllControlVelocidadTask cACVTask = null;
                    if (holder.estado == 0) {
                        holder.estado = 1;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                        cACVTask = new CambiarAllControlVelocidadTask(Usr, Psw, "4");
                        for(int j=0;j<vistas.size();j++){
                            vistas.get(j).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                            vistas.get(j).estado = 1;
                            if(j<listaVehiculosFiltrada.size()) listaVehiculosFiltrada.get(j).setEstado(holder.estado+"");
                        }
                    }
                    else if (holder.estado == 1){
                        holder.estado = 0;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        cACVTask = new CambiarAllControlVelocidadTask(Usr, Psw, "5");
                        for(int j=0;j<vistas.size();j++){
                            vistas.get(j).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                            vistas.get(j).estado = 0;
                            if(j<listaVehiculosFiltrada.size()) listaVehiculosFiltrada.get(j).setEstado(holder.estado+"");
                        }
                    }
                    if(cACVTask != null) cACVTask.execute((Void) null);
                }
                else {
                    CambiarControlVelocidadTask cCVTask = null;
                    if (holder.estado == 0) {
                        holder.estado = 1;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                        cCVTask = new CambiarControlVelocidadTask(Usr, Psw, listaVehiculosFiltrada.get(position).getID(), listaVehiculosFiltrada.get(position).getPatente(), "1");
                        listaVehiculosFiltrada.get(position).setEstado(holder.estado+"");
                        if(esTodosActivados()){
                            if(vActivarTodos != null) {
                                vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                                vActivarTodos.estado = 1;
                            }
                        }
                            /*if(listaVehiculosFiltrada.size()>1)
                                if(vActivarTodos != null){
                                    listaVehiculosFiltrada.get(0).setEstado("1");
                                    vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                                }
                        }*/
                    }
                    else if (holder.estado == 1) {
                        holder.estado = 0;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        cCVTask = new CambiarControlVelocidadTask(Usr, Psw, listaVehiculosFiltrada.get(position).getID(), listaVehiculosFiltrada.get(position).getPatente(), "0");
                        listaVehiculosFiltrada.get(position).setEstado(holder.estado+"");
                        if(!esTodosActivados()){
                            if(vActivarTodos != null) {
                                vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                                vActivarTodos.estado = 0;
                            }
                            /*if(listaVehiculosFiltrada.size()>1)
                                if(vActivarTodos != null){
                                    listaVehiculosFiltrada.get(0).setEstado("0");
                                    vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                                }*/
                        }
                    }

                    if(cCVTask != null) cCVTask.execute((Void) null);
                }
            }
        });
        vistas.add(holder);
        return convertView;
    }

    @Override
    public Filter getFilter() {
        return Filtro;
    }

    public static class ViewHolder {
        public TextView txtPatente;
        public ImageView ivSwitch;
        public int estado;
    }

    private class ListaFiltro extends Filter {
        ArrayList<ModoEstacionadoModel> resultadosFiltro;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            resultadosFiltro = new ArrayList<ModoEstacionadoModel>();

            FilterResults results = new FilterResults();

            if (constraint == null || constraint.toString().isEmpty()) {
                resultadosFiltro = listaVehiculos;
            }
            else {
                String filterString = constraint.toString().toLowerCase();
                for (int i = 0; i < listaVehiculos.size(); i++) {
                    if (listaVehiculos.get(i).getPatente().toLowerCase().contains(filterString) || listaVehiculos.get(i).getNombre().toLowerCase().contains(filterString)) {
                        resultadosFiltro.add(listaVehiculos.get(i));
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
                listaVehiculosFiltrada = new ArrayList<ModoEstacionadoModel>();
                notifyDataSetInvalidated();
            } else {
                listaVehiculosFiltrada = (ArrayList<ModoEstacionadoModel>) results.values;
                notifyDataSetChanged();
            }
        }
    }

    // Control Velocidad Task
    public class CambiarControlVelocidadTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Estado;
        private final String Accion;

        CambiarControlVelocidadTask(String Usr, String Psw, String id, String pat, String est) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
            Accion = "3";
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postID = new BasicNameValuePair("id", idVehiculo);
            BasicNameValuePair postPatente = new BasicNameValuePair("patente", Patente);
            BasicNameValuePair postEstado = new BasicNameValuePair("estado", Estado);
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", Accion);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postPatente);
            datosPost.add(postEstado);
            datosPost.add(postAccion);
            Log.d("ModoEst.onPostEx", "-> "+idVehiculo + "|"+ Patente);
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
                boolean exito = false;

                //{"ME":[{"mensaje" : "Modo estacionado"}]}
                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("ControlVelocidad");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    String resultadoModoEstacionado = jsonRes.getString("GPS");
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            if(resultadoModoEstacionado.compareTo("Patente activada") == 0 && Estado.compareTo("1") == 0) exito = true;
                                            else if(resultadoModoEstacionado.compareTo("Patente desactivada") == 0 && Estado.compareTo("0") == 0) exito = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(exito) { // Cambiar el boton segun el estado mostrado
                    Log.d("CambiarME", "Se cambio el control de velocidad de la patente " + Patente + " a: " + Estado);
                    if(esTodosDesactivados()) PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControl", "0").commit();
                    else PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControl", "1").commit();
                }
                else {
                    Toast.makeText(c, c.getString(R.string.error_cambiar_ctrl_velocidad), Toast.LENGTH_SHORT).show();
                }
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }
    }

    // Control Velocidad Task
    public class CambiarAllControlVelocidadTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ControlDeVelocidad.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Accion;

        CambiarAllControlVelocidadTask(String Usr, String Psw, String acc) {
            ilogin = Usr;
            ipassword = Psw;
            Accion = acc;
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", ilogin);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", ipassword);
            BasicNameValuePair postAccion = new BasicNameValuePair("accion", Accion);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postAccion);
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
                Log.d("ModoEstAll.onPostEx", Resultado);
                boolean exito = false;

                try {
                    JSONObject jsonObj = new JSONObject(Resultado);
                    if(jsonObj!=null){
                        JSONArray jsonArr = jsonObj.getJSONArray("ControlVelocidad");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    String resultadoModoEstacionado = jsonRes.getString("GPS");
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            if(resultadoModoEstacionado.compareToIgnoreCase("Patentes activadas") == 0 && Accion.compareTo("4") == 0) exito = true;
                                            else if(resultadoModoEstacionado.compareToIgnoreCase("Patentes desactivadas") == 0 && Accion.compareTo("5") == 0) exito = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if(exito) { // Cambiar el boton segun el estado mostrado
                    Log.d("CambiarME", "Se cambio el control de velocidad de todas las patentes");
                    if(esTodosDesactivados()) PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControl", "0").commit();
                    else PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoControl", "1").commit();
                }
                else {
                    Toast.makeText(c, c.getString(R.string.error_cambiar_ctrl_velocidad), Toast.LENGTH_SHORT).show();
                }
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }
    }


}
