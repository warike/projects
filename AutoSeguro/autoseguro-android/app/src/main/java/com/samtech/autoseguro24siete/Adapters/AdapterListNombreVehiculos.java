package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.VehiculoModel;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 28-08-2015.
 */
public class AdapterListNombreVehiculos extends BaseAdapter /*implements Filterable */{
    private Context c;
    private String Usr, Psw;
    private ArrayList<VehiculoModel> listaVehiculos, listaVehiculosFiltrada;
    //private ListaFiltro Filtro;
    //private ArrayList<ViewHolder> vistas;
    private int editPos = 0;
    private TextWatcher watcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            Log.d("AdpListVelM", "onTxtChanged: " + s.toString());
            listaVehiculosFiltrada.get(editPos).setNombreVehiculo(s.toString());
        }

        @Override
        public void afterTextChanged(Editable s) {}
    };

    public AdapterListNombreVehiculos(Context c, String usr, String psw, ArrayList<VehiculoModel> listaVehiculos) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        this.listaVehiculos = listaVehiculos;
        this.listaVehiculosFiltrada = listaVehiculos;
        //Filtro = new ListaFiltro();
        //vistas = new ArrayList<ViewHolder>();
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

    /*public String getNombre(int position){
        return vistas.get(position).etNombrePatente.getText().toString();
    }

    public Object getVehiculo(int pos){
        return new VehiculoModel(listaVehiculosFiltrada.get(pos).getIdVehiculo(), listaVehiculosFiltrada.get(pos).getPatenteVehiculo(), vistas.get(pos).etNombrePatente.getText().toString());
    }
*/
    @Override
    public long getItemId(int position) {
        return position;
        //return Long.parseLong(listaVehiculosFiltrada.get(position).getID());
    }
    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if(convertView == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.vehiculos_nombre_lista_item, parent, false);

            holder = new ViewHolder();
            holder.txtPatente = (TextView) convertView.findViewById(R.id.txtPatente);
            holder.etNombrePatente = (EditText) convertView.findViewById(R.id.etNombrePatente);

            convertView.setTag(holder);
            //vistas.add(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.etNombrePatente.removeTextChangedListener(watcher);

        if(position < listaVehiculosFiltrada.size()) {
            holder.txtPatente.setText(listaVehiculosFiltrada.get(position).getPatenteVehiculo());
            holder.etNombrePatente.setText(listaVehiculosFiltrada.get(position).getNombreVehiculo());
        }

        /*final int pos = position;
        holder.etNombrePatente.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                Log.d("onKey", keyCode + "");
                return false;
            }
        });*/

        holder.etNombrePatente.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if(hasFocus) editPos = position;
            }
        });

        holder.etNombrePatente.addTextChangedListener(watcher);
        holder.etNombrePatente.clearFocus();

        return convertView;
    }
/*
    @Override
    public Filter getFilter() {
        return Filtro;
    }
*/
    public static class ViewHolder {
        public TextView txtPatente;
        public EditText etNombrePatente;
    }
/*
    private class ListaFiltro extends Filter {
        ArrayList<VehiculoModel> resultadosFiltro;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            resultadosFiltro = new ArrayList<VehiculoModel>();
            String filterString = constraint.toString().toLowerCase();

            FilterResults results = new FilterResults();

            for (int i = 0; i < listaVehiculos.size(); i++) {
                if (listaVehiculos.get(i).getPatenteVehiculo().toLowerCase().contains(filterString)) {
                    resultadosFiltro.add(listaVehiculos.get(i));
                }
            }

            if (constraint.toString().isEmpty()) {
                resultadosFiltro = listaVehiculos;
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
    }*/
}
