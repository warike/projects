package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.content.Intent;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.UbicacionModel;
import com.samtech.autoseguro24siete.R;
import com.samtech.autoseguro24siete.UbicacionMapaActivity;

import java.util.ArrayList;

/**
 * Created by Tato on 30-08-2015.
 */
public class AdapterListUbicacion extends BaseAdapter {
    private Context c;
    private String Usr, Psw, Usr_Lat, Usr_Lng;
    private ArrayList<UbicacionModel> listaVehiculos;

    public AdapterListUbicacion(Context c, String usr, String psw, ArrayList<UbicacionModel> lista, String usr_lat, String usr_lng){
        this.c = c;
        Usr = usr;
        Psw = psw;
        listaVehiculos = lista;
        this.Usr_Lat = usr_lat;
        this.Usr_Lng = usr_lng;
    }

    @Override
    public int getCount() {
        if(listaVehiculos == null) return 0;
        else return listaVehiculos.size();
    }

    @Override
    public Object getItem(int position) {
        return listaVehiculos.get(position);
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
            convertView = inf.inflate(R.layout.ubicacion_lista_item, null);

            holder = new ViewHolder();
            holder.lblVehiculo = (TextView) convertView.findViewById(R.id.lblVehiculo);
            holder.lblIgnicion = (TextView) convertView.findViewById(R.id.lblIgnicion);
            holder.lblUbicacion = (TextView) convertView.findViewById(R.id.lblUbicacion);
            holder.txtVehiculo = (TextView) convertView.findViewById(R.id.txtVehiculo);
            holder.txtIgnicion = (TextView) convertView.findViewById(R.id.txtIgnicion);
            holder.txtUbicacion = (TextView) convertView.findViewById(R.id.txtUbicacion);
            convertView.setTag(holder);
        }
        else holder = (ViewHolder) convertView.getTag();

        if(position<listaVehiculos.size()){
            holder.txtVehiculo.setText(listaVehiculos.get(position).getNombreVehiculo());
            holder.txtIgnicion.setText(listaVehiculos.get(position).getEstadoVehiculo());
            holder.txtUbicacion.setText(listaVehiculos.get(position).getUbicacionVehiculo());
        }
        final int pos = position;
        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent mapaUbicacion = new Intent(c, UbicacionMapaActivity.class);
                mapaUbicacion.putExtra("Usr", Usr);
                mapaUbicacion.putExtra("Password", Psw);
                mapaUbicacion.putExtra("Usr_Lat", Usr_Lat);
                mapaUbicacion.putExtra("Usr_Lng", Usr_Lng);
                mapaUbicacion.putExtra("idVehiculo", listaVehiculos.get(pos).getIdVehiculo());
                mapaUbicacion.putExtra("Patente", listaVehiculos.get(pos).getPatenteVehiculo());
                mapaUbicacion.putExtra("corte", listaVehiculos.get(pos).getCorteVehiculo());
                mapaUbicacion.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                c.startActivity(mapaUbicacion);
            }
        });

        if(listaVehiculos.get(position).getPatenteVehiculo().compareToIgnoreCase("Todos los vehículos")==0){
            holder.lblVehiculo.setText("Todos los vehículos");
            holder.lblVehiculo.setGravity(Gravity.CENTER_VERTICAL);
            holder.lblVehiculo.setPadding(0,10,0,10);
            holder.txtVehiculo.setVisibility(View.GONE);
            holder.txtIgnicion.setVisibility(View.GONE);
            holder.txtUbicacion.setVisibility(View.GONE);
            holder.lblUbicacion.setVisibility(View.GONE);
            holder.lblIgnicion.setVisibility(View.GONE);
        }
        else{
            holder.lblVehiculo.setText("Nombre:");
            holder.lblVehiculo.setGravity(Gravity.CENTER_VERTICAL);
            holder.lblVehiculo.setPadding(0,0,0,0);
            holder.txtVehiculo.setVisibility(View.VISIBLE);
            holder.txtIgnicion.setVisibility(View.VISIBLE);
            holder.txtUbicacion.setVisibility(View.VISIBLE);
            holder.lblUbicacion.setVisibility(View.VISIBLE);
            holder.lblIgnicion.setVisibility(View.VISIBLE);
        }

        return convertView;
    }

    public static class ViewHolder{
        TextView lblVehiculo;
        TextView lblIgnicion;
        TextView lblUbicacion;
        TextView txtVehiculo;
        TextView txtIgnicion;
        TextView txtUbicacion;
    }
}
