package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.samtech.autoseguro24siete.CrearContactoActivity;
import com.samtech.autoseguro24siete.Models.ContactosModel;
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
 * Created by gurofo on 10/30/15.
 */
public class AdapterListContactos extends BaseAdapter {

    private Context c;
    private String Usr, Psw;
    private ArrayList<ViewHolder> vistas;
    private ArrayList<ContactosModel> listaContactos;
    private boolean flagEditando = false;

    public AdapterListContactos(Context c, String usr, String psw,
                                ArrayList<ContactosModel> listaContactos) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        vistas = new ArrayList<>();
        this.listaContactos = listaContactos;
    }

    @Override
    public int getCount() {
        if(listaContactos != null ) return listaContactos.size();
        return 0;
    }

    @Override
    public Object getItem(int position) {
        return listaContactos.get(position);
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
            convertView = inf.inflate(R.layout.contactos_lista_item, parent, false);

            holder = new ViewHolder();
            holder.txtContacto = (TextView) convertView.findViewById(R.id.txtContacto);
            holder.btnEliminar = (ImageView) convertView.findViewById(R.id.btnEliminar);
            holder.btnEditar = (ImageView) convertView.findViewById(R.id.btnEditar);

            convertView.setTag(holder);
            vistas.add(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }

        if(position < listaContactos.size()) {
            //String nombreUsr = listaUsuarios.get(position).getNombreUsr();
            String nombreUsr = listaContactos.get(position).getNombre();
            //if(nombreUsr.isEmpty()) listaUsuarios.get(position).getUsr();
            holder.txtContacto.setText(nombreUsr);
        }

        if(flagEditando){ // Mostar los botones de edición de usuarios
            holder.btnEditar.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d("onClickList", "boton Editar");
                    Intent editar = new Intent(c, CrearContactoActivity.class);
                    editar.putExtra("Contacto", listaContactos.get(position));
                    editar.putExtra("Usr", Usr);
                    editar.putExtra("Password", Psw);
                    editar.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    c.startActivity(editar);
                }
            });
            holder.btnEditar.setVisibility(View.VISIBLE);
            holder.btnEditar.setClickable(true);
            final int pos = position;
            /*final AlertDialog.Builder dialogo = new AlertDialog.Builder(new ContextThemeWrapper(c, R.style.myDialog))
                    .setTitle("Confirmación")
                    .setMessage("Esta seguro de eliminar el usuario?")
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                            eliminarTask eTask = new eliminarTask(Usr, Psw, listaUsuarios.get(pos).getUsr(), listaUsuarios.get(pos).getPsw(), listaUsuarios.get(pos).getNombreUsr());
                            eTask.execute((Void) null);
                        }})
                    .setNegativeButton(android.R.string.no, null);*/

            holder.btnEliminar.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d("onClickList", "boton Eliminar");
                    eliminarTask eTask = new eliminarTask(Usr, Psw, listaContactos.get(pos).getIdCont());
                    eTask.execute((Void) null);
                    //dialogo.show();
                }
            });
            holder.btnEliminar.setVisibility(View.VISIBLE);
            holder.btnEliminar.setClickable(true);
        }
        else{ // Mostrar sólo el nombre de usuario
            holder.btnEditar.setVisibility(View.INVISIBLE);
            holder.btnEditar.setClickable(false);

            holder.btnEliminar.setVisibility(View.INVISIBLE);
            holder.btnEliminar.setClickable(false);
        }

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(flagEditando){
                    Log.d("onClickList", "boton Editar");
                    Intent editar = new Intent(c, CrearContactoActivity.class);
                    editar.putExtra("Contacto", listaContactos.get(position));
                    editar.putExtra("Usr", Usr);
                    editar.putExtra("Password", Psw);
                    editar.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    c.startActivity(editar);
                }
            }
        });

        return convertView;
    }

    public boolean cambiarModoEdicion(){
        if(flagEditando) {
            flagEditando = false;
        }
        else {
            flagEditando = true;
        }

        for(int i=0; i<vistas.size();i++){
            if(flagEditando){ // Mostar los botones de edición de usuarios
                final int pos = i;
                vistas.get(i).btnEditar.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.d("onClickList", "boton Editar");
                        Intent editar = new Intent(c, CrearContactoActivity.class);
                        editar.putExtra("Contacto", listaContactos.get(pos));
                        editar.putExtra("Usr", Usr);
                        editar.putExtra("Password", Psw);
                        editar.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        c.startActivity(editar);
                    }
                });

                vistas.get(i).btnEditar.setVisibility(View.VISIBLE);
                vistas.get(i).btnEditar.setClickable(true);
                vistas.get(i).btnEliminar.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.d("onClickList", "boton Eliminar");
                        eliminarTask eTask = new eliminarTask(Usr, Psw, listaContactos.get(pos).getIdCont());
                        eTask.execute((Void) null);
                    }
                });
                vistas.get(i).btnEliminar.setVisibility(View.VISIBLE);
                vistas.get(i).btnEliminar.setClickable(true);
            }
            else{ // Mostrar sólo el nombre de usuario
                vistas.get(i).btnEditar.setVisibility(View.INVISIBLE);
                vistas.get(i).btnEditar.setClickable(false);

                vistas.get(i).btnEliminar.setVisibility(View.INVISIBLE);
                vistas.get(i).btnEliminar.setClickable(false);
            }
        }
        return flagEditando;
    }

    public boolean cambiarModoEdicion(boolean modo){
        if(modo) {
            flagEditando = true;
        }
        else {
            flagEditando = false;
        }

        for(int i=0; i<vistas.size();i++){
            if(flagEditando){ // Mostar los botones de edición de usuarios
                final int pos = i;
                vistas.get(i).btnEditar.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.d("onClickList", "boton Editar");
                        Intent editar = new Intent(c, CrearContactoActivity.class);
                        editar.putExtra("Contacto", listaContactos.get(pos));
                        editar.putExtra("Usr", Usr);
                        editar.putExtra("Password", Psw);
                        editar.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        c.startActivity(editar);
                    }
                });

                vistas.get(i).btnEditar.setVisibility(View.VISIBLE);
                vistas.get(i).btnEditar.setClickable(true);
                vistas.get(i).btnEliminar.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.d("onClickList", "boton Eliminar");
                        eliminarTask eTask = new eliminarTask(Usr, Psw, listaContactos.get(pos).getIdCont());
                        eTask.execute((Void) null);
                    }
                });
                vistas.get(i).btnEliminar.setVisibility(View.VISIBLE);
                vistas.get(i).btnEliminar.setClickable(true);
            }
            else{ // Mostrar sólo el nombre de usuario
                vistas.get(i).btnEditar.setVisibility(View.INVISIBLE);
                vistas.get(i).btnEditar.setClickable(false);

                vistas.get(i).btnEliminar.setVisibility(View.INVISIBLE);
                vistas.get(i).btnEliminar.setClickable(false);
            }
        }

        return flagEditando;
    }

    public static class ViewHolder {
        public TextView txtContacto;
        public ImageView btnEliminar;
        public ImageView btnEditar;
    }

    public class eliminarTask extends AsyncTask<Void, Void, String> {
        private final String urlWS = "http://libs.samtech.cl/movil/contacto.asp";
        private final String Usr;
        private final String Psw;
        private final String idCont;
        private final String sw;

        eliminarTask(String Usuario, String Password, String idCont) {
            Usr = Usuario;
            Psw = Password;
            this.idCont = idCont;
            sw = "4";
        }

        @Override
        protected String doInBackground(Void... params) {
            HttpClient httpClient = new DefaultHttpClient();
            HttpPost httpPost = new HttpPost(urlWS);

            // Informacion entregada por medio del POST
            BasicNameValuePair postUsr = new BasicNameValuePair("ilogin", Usr);
            BasicNameValuePair postPsw = new BasicNameValuePair("ipassword", Psw);
            BasicNameValuePair postSw = new BasicNameValuePair("sw", sw);
            BasicNameValuePair postIdCont = new BasicNameValuePair("id_cont", idCont);

            // Agrupando la informacion de logueo
            List<NameValuePair> datosPost = new ArrayList<NameValuePair>();
            datosPost.add(postUsr);
            datosPost.add(postPsw);
            datosPost.add(postSw);
            datosPost.add(postIdCont);

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
                Log.d("EliminarContacto", Resultado);
                for(int i = 0; i<listaContactos.size();i++){
                    if(listaContactos.get(i).getIdCont().compareToIgnoreCase(idCont)==0){
                        listaContactos.remove(i);
                        if(i<vistas.size()) vistas.remove(i);
                        Toast.makeText(c, c.getString(R.string.correcto_eliminar_contacto), Toast.LENGTH_SHORT).show();
                        notifyDataSetChanged();
                        break;
                    }
                }
            }
            else{
                Toast.makeText(c.getApplicationContext(), c.getString(R.string.error_conexion), Toast.LENGTH_LONG).show();
            }
        }
    }
}

