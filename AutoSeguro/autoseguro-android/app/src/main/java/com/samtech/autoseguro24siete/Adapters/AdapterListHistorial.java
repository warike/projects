package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.HistorialModel;
import com.samtech.autoseguro24siete.HistorialMapaActivity;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 23-08-2015.
 */
public class AdapterListHistorial extends BaseAdapter  {
    private Context c;
    private ArrayList<HistorialModel> historial;
    private String Usr, Psw, Patente, idVehiculo;

    public AdapterListHistorial(Context c, ArrayList<HistorialModel> historial, String usr, String psw, String patente, String idVehiculo) {
        this.c = c;
        this.historial = historial;
        Usr = usr;
        Psw = psw;
        Patente = patente;
        this.idVehiculo = idVehiculo;
    }

    @Override
    public int getCount() {
        return historial.size();
    }

    @Override
    public Object getItem(int position) {
        return historial.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        View vista = convertView;
        final ViewHolder holder;

        if(vista == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            vista = inf.inflate(R.layout.historial_lista_item, null);

            holder = new ViewHolder();
            holder.txtEvento = (TextView) vista.findViewById(R.id.txtEvento);
            holder.txtHora = (TextView) vista.findViewById(R.id.txtHora);
            holder.txtUbicacion = (TextView) vista.findViewById(R.id.txtUbicacion);
            vista.setTag(holder);
        }
        else holder = (ViewHolder) vista.getTag();

        if(position < getCount()){
            holder.txtEvento.setText(historial.get(position).getTipoEvento());
            holder.txtUbicacion.setText(historial.get(position).getUbicacionEvento());
            holder.txtHora.setText(historial.get(position).getHoraEvento());
            if(historial.get(position).getTipoEvento().compareTo("Abre Contacto")== 0) holder.txtEvento.setTextColor(Color.parseColor("#035F7E"));
            else holder.txtEvento.setTextColor(Color.parseColor("#FF0000"));
        }

        vista.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent in = new Intent(c, HistorialMapaActivity.class);
                in.putExtra("Patente", Patente);
                in.putExtra("Hora", historial.get(position).getHoraEvento());
                in.putExtra("Evento", historial.get(position).getTipoEvento());
                in.putExtra("Latitud", historial.get(position).getLatitud());
                in.putExtra("Longitud", historial.get(position).getLongitud());

                c.startActivity(in);
            }
        });

        return vista;
    }

    private static class ViewHolder{
        TextView lblEvento;
        TextView txtEvento;
        TextView txtHora;
        TextView lblUbicacion;
        TextView txtUbicacion;
    }
}
