package com.samtech.autoseguro24siete.Adapters;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
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
public class AdapterListModoEstacionado extends BaseAdapter implements Filterable {
    private Context c;
    private String Usr, Psw, dToken, app;
    private ArrayList<ModoEstacionadoModel> listaVehiculos, listaVehiculosFiltrada;
    private ListaFiltro Filtro;
    private ArrayList<ViewHolder> vistas;
    private String ModoEstacionadoActivado = "Modo estacionado activado";
    private String ModoEstacionadoDesactivado = "Modo estacionado desactivado";
    private String ModoEstacionadoAllActivado = "Modo estacionado activado";
    private String ModoEstacionadoAllDesactivado = "Modo estacionado descativado";
    ProgressDialog progressDialog;
    private ViewHolder vActivarTodos = null;

    public AdapterListModoEstacionado(Context c, String usr, String psw, ArrayList<ModoEstacionadoModel> listaVehiculos, String dtok) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        this.listaVehiculos = listaVehiculos;
        this.listaVehiculosFiltrada = listaVehiculos;
        Filtro = new ListaFiltro();
        vistas = new ArrayList<ViewHolder>();
        dToken = dtok;
        app = c.getResources().getString(R.string.app_ws);
    }

    @Override
    public int getCount() {
        if(listaVehiculosFiltrada == null) listaVehiculosFiltrada = listaVehiculos;
        return listaVehiculosFiltrada.size();
    }

    @Override
    public Object getItem(int position) {
        return listaVehiculosFiltrada.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
        //return Long.parseLong(listaVehiculosFiltrada.get(position).getID());
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
    public View getView(final int position, View convertView, final ViewGroup parent) {
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
            Log.d("ActivarTodos", "Estado:"+holder.estado);
            vActivarTodos = holder;
        }

        if(holder.estado == 0) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
        else if(holder.estado == 1) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));

        holder.ivSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CambiarModoEstacionadoTask cMeTask = null;
                if (listaVehiculosFiltrada.get(position).getPatente().contentEquals("Activar Todos")) { // Activar Todos
                    if(holder.estado == 0) {
                        holder.estado = 1;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                        cMeTask = new CambiarModoEstacionadoTask(Usr, Psw, "", "", "3", dToken);
                        for(int j=0;j<vistas.size();j++){
                            vistas.get(j).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                            vistas.get(j).estado = 1;
                            if(j<listaVehiculosFiltrada.size()) listaVehiculosFiltrada.get(j).setEstado(holder.estado+"");
                        }
                    }
                    else{
                        holder.estado = 0;
                        holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        cMeTask = new CambiarModoEstacionadoTask(Usr, Psw, "", "", "2", dToken);
                        for(int j=0;j<vistas.size();j++){
                            vistas.get(j).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                            vistas.get(j).estado = 0;
                            if(j<listaVehiculosFiltrada.size()) listaVehiculosFiltrada.get(j).setEstado(holder.estado+"");
                        }
                    }
                }
                else {
                    if (listaVehiculosFiltrada.get(position).getCorte().contentEquals("1") ||
                            listaVehiculosFiltrada.get(position).getCorte().contentEquals("2")){
                        if (holder.estado == 0){
                            holder.estado = 1;
                            holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                            if(esTodosActivados()){
                                if(listaVehiculosFiltrada.size()>1) {
                                    if (vActivarTodos != null) {
                                        listaVehiculosFiltrada.get(0).setEstado("1");
                                        vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                                    }
                                }
                            }
                            confirmar(parent.getContext(), listaVehiculosFiltrada.get(position), Integer.toString(holder.estado));
                        } else if (holder.estado == 1){
                            holder.estado = 0;
                            holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                            listaVehiculosFiltrada.get(position).setEstado(holder.estado + "");
                            if(!esTodosActivados()){
                                if(listaVehiculosFiltrada.size()>1)
                                    if(vActivarTodos != null){
                                        listaVehiculosFiltrada.get(0).setEstado("0");
                                        vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                                    }
                            }
                            //confirmar(c, listaVehiculosFiltrada.get(position), Integer.toString(holder.estado));
                            CambiarModoEstacionadoTask cambiarModoEstacionadoTask = new CambiarModoEstacionadoTask(Usr, Psw,
                                    listaVehiculosFiltrada.get(position).getID(), listaVehiculosFiltrada.get(position).getPatente(),
                                    "0", dToken, "1");
                            cambiarModoEstacionadoTask.execute((Void) null);
                        }
                    } else {
                        if(holder.estado == 0) {
                            holder.estado = 1;
                            holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                            cMeTask = new CambiarModoEstacionadoTask(Usr, Psw, listaVehiculosFiltrada.get(position).getID(), listaVehiculosFiltrada.get(position).getPatente(), "1", dToken);
                            listaVehiculosFiltrada.get(position).setEstado(holder.estado + "");
                            if(esTodosActivados()){
                                if(listaVehiculosFiltrada.size()>1)
                                    if(vActivarTodos != null){
                                        listaVehiculosFiltrada.get(0).setEstado("1");
                                        vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                                    }
                            }
                            cMeTask.execute((Void) null);
                        }
                        else if (holder.estado == 1) {
                            holder.estado = 0;
                            holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                            cMeTask = new CambiarModoEstacionadoTask(Usr, Psw, listaVehiculosFiltrada.get(position).getID(), listaVehiculosFiltrada.get(position).getPatente(), "0", dToken);
                            listaVehiculosFiltrada.get(position).setEstado(holder.estado+"");
                            if(!esTodosActivados()){
                                if(listaVehiculosFiltrada.size()>1)
                                    if(vActivarTodos != null){
                                        listaVehiculosFiltrada.get(0).setEstado("0");
                                        vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                                    }
                            }
                            cMeTask.execute((Void) null);
                        }
                    }
                }

                //if (cMeTask != null) cMeTask.execute((Void) null);
            }
        });
        vistas.add(holder);
        return convertView;
    }

    public void confirmar(Context context, final ModoEstacionadoModel modoEstacionadoModel, final String estado){
        final AlertDialog alertDialog = new AlertDialog.Builder(context).create();
        alertDialog.setTitle("Activar Modo Estacionado");
        alertDialog.setMessage("¿Desea Cortar Contacto de vehículo?");
        alertDialog.setButton(Dialog.BUTTON_NEGATIVE, "NO", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                //String Usr, String Psw, String id, String pat, String est, String token
                CambiarModoEstacionadoTask cambiarModoEstacionadoTask = new CambiarModoEstacionadoTask(Usr, Psw,
                        modoEstacionadoModel.getID(), modoEstacionadoModel.getPatente(), estado,
                        dToken, "0");
                cambiarModoEstacionadoTask.execute((Void) null);
                alertDialog.dismiss();
            }
        });
        alertDialog.setButton(Dialog.BUTTON_POSITIVE, "SI", new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                CambiarModoEstacionadoTask cambiarModoEstacionadoTask = new CambiarModoEstacionadoTask(Usr, Psw,
                        modoEstacionadoModel.getID(), modoEstacionadoModel.getPatente(), estado,
                        dToken, "1");
                cambiarModoEstacionadoTask.execute((Void) null);
                alertDialog.dismiss();
            }
        });
        //alertDialog.setIcon(R.drawable.boton_modoestacionado);
        alertDialog.show();
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

    // Modo estacionado Task
    public class CambiarModoEstacionadoTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/ModoEstacionadoVehiculo.asp";
        private final String ilogin;
        private final String ipassword;
        private final String Patente;
        private final String idVehiculo;
        private final String Estado;
        private final String dtoken;
        private final String corta_corr;

        CambiarModoEstacionadoTask(String Usr, String Psw, String id, String pat, String est, String token) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
            dtoken = token;
            corta_corr = "";
        }

        CambiarModoEstacionadoTask(String Usr, String Psw, String id, String pat, String est, String token, String corta_corr) {
            ilogin = Usr;
            ipassword = Psw;
            idVehiculo = id;
            Patente = pat;
            Estado = est;
            dtoken = token;
            this.corta_corr = corta_corr;
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
            BasicNameValuePair postApp = new BasicNameValuePair("app", app);
            BasicNameValuePair postDToken = new BasicNameValuePair("dtoken", dtoken);
            BasicNameValuePair postCortacorr = new BasicNameValuePair("corta_corr", corta_corr);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postID);
            datosPost.add(postApp);
            datosPost.add(postDToken);
            if (corta_corr != ""){
                datosPost.add(postCortacorr);
            }
            if(!idVehiculo.contentEquals("0")){
                datosPost.add(postPatente);
                datosPost.add(postEstado);
            }
            Log.d("AdapterME", datosPost.toString());
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
                        JSONArray jsonArr = jsonObj.getJSONArray("ME");
                        if(jsonArr != null) {
                            if(jsonArr.length() > 0) {
                                JSONObject jsonRes = jsonArr.getJSONObject(0);
                                if(jsonRes != null) {
                                    String resultadoModoEstacionado = jsonRes.getString("mensaje");
                                    if(resultadoModoEstacionado != null) {
                                        if(!resultadoModoEstacionado.isEmpty()) {
                                            String retornoWS = "";
                                            if(Estado.contentEquals("0")) retornoWS = ModoEstacionadoDesactivado;
                                            else if(Estado.contentEquals("1")) retornoWS = ModoEstacionadoActivado;
                                            else if(Estado.contentEquals("2")) retornoWS = ModoEstacionadoAllDesactivado;
                                            else if(Estado.contentEquals("3")) retornoWS = ModoEstacionadoAllActivado;
                                            if(resultadoModoEstacionado.compareToIgnoreCase(retornoWS) == 0) exito = true;
                                            else exito = false;
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
                    Log.d("CambiarME", "Se cambio el modo estacionado de la patente "+Patente+" a: "+ Estado);
                    // Permite cambiar la imagen en el menu
                    if(esTodosDesactivados()) PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoVehAsignado", "0").commit();
                    else PreferenceManager.getDefaultSharedPreferences(c).edit().putString("estadoVehAsignado", "1").commit();
                }
                else {
                    Toast.makeText(c, c.getString(R.string.error_cambiar_modo_estacionado), Toast.LENGTH_SHORT).show();
                }
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }
    }

}
