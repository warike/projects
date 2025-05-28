package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import com.samtech.autoseguro24siete.HistorialActivity;
import com.samtech.autoseguro24siete.Models.VehiculoModel;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 28-08-2015.
 */
public class AdapterListVehiculos extends BaseAdapter implements Filterable {
    private Context c;
    private String Usr, Psw;
    private ArrayList<VehiculoModel> listaVehiculos, listaVehiculosFiltrada;
    private ListaFiltro Filtro;

    public AdapterListVehiculos(Context c, String usr, String psw, ArrayList<VehiculoModel> listaVehiculos) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        this.listaVehiculos = listaVehiculos;
        this.listaVehiculosFiltrada = listaVehiculos;
        Filtro = new ListaFiltro();
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
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;

        if(convertView == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.vehiculos_lista_item, null);

            holder = new ViewHolder();
            holder.txtPatente = (TextView) convertView.findViewById(R.id.txtPatente);

            convertView.setTag(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }

        if(position < listaVehiculosFiltrada.size()) {
            String nombre = listaVehiculosFiltrada.get(position).getNombreVehiculo();
            if(nombre.isEmpty() || nombre.length() == 0) nombre = listaVehiculosFiltrada.get(position).getPatenteVehiculo();
            holder.txtPatente.setText(nombre);
        }

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent historialVehiculo = new Intent(c, HistorialActivity.class);
                historialVehiculo.putExtra("Usr", Usr);
                historialVehiculo.putExtra("Password", Psw);
                historialVehiculo.putExtra("idVehiculo", listaVehiculosFiltrada.get(position).getIdVehiculo());
                historialVehiculo.putExtra("Patente", listaVehiculosFiltrada.get(position).getPatenteVehiculo());
                historialVehiculo.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                c.startActivity(historialVehiculo);
            }
        });

        return convertView;
    }

    @Override
    public Filter getFilter() {
        return Filtro;
    }

    public static class ViewHolder {
        public TextView txtPatente;
    }

    private class ListaFiltro extends Filter {
        ArrayList<VehiculoModel> resultadosFiltro;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            resultadosFiltro = new ArrayList<VehiculoModel>();

            FilterResults results = new FilterResults();

            if (constraint == null || constraint.toString().isEmpty()) {
                resultadosFiltro = listaVehiculos;
            }
            else {
                String filterString = constraint.toString().toLowerCase();
                for (int i = 0; i < listaVehiculos.size(); i++) {
                    if (listaVehiculos.get(i).getPatenteVehiculo().toLowerCase().contains(filterString) || listaVehiculos.get(i).getNombreVehiculo().toLowerCase().contains(filterString)) {
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
                listaVehiculosFiltrada = new ArrayList<VehiculoModel>();
                notifyDataSetInvalidated();
            } else {
                listaVehiculosFiltrada = (ArrayList<VehiculoModel>) results.values;
                notifyDataSetChanged();
            }
        }
    }
}
