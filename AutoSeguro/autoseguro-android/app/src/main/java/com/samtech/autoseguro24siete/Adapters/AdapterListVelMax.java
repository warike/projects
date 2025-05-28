package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.VelMaxModel;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 28-08-2015.
 */
public class AdapterListVelMax extends BaseAdapter implements Filterable {
    private Context c;
    private String Usr, Psw;
    private ArrayList<VelMaxModel> listaVehiculos, listaVehiculosFiltrada;
    private ListaFiltro Filtro;
    private int editPos = 0;
    private TextWatcher watcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
            Log.d("AdpListVelM", "onTxtChanged: " + s.toString());
            listaVehiculosFiltrada.get(editPos).setVelMaxVehiculo(s.toString());
        }

        @Override
        public void afterTextChanged(Editable s) {}
    };

    public AdapterListVelMax(Context c, String usr, String psw, ArrayList<VelMaxModel> listaVehiculos) {
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
        //return Long.parseLong(listaVehiculosFiltrada.get(position).getID());
    }
    
    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        final ViewHolder holder;

        if(convertView == null){
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inf.inflate(R.layout.vel_max_lista_item, parent, false);

            holder = new ViewHolder();
            holder.txtPatente = (TextView) convertView.findViewById(R.id.txtPatente);
            holder.etVelocidad = (EditText) convertView.findViewById(R.id.etVelocidad);
            convertView.setTag(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.etVelocidad.removeTextChangedListener(watcher);

        if(position < listaVehiculosFiltrada.size()) {
            String nombreVeh = listaVehiculosFiltrada.get(position).getNombreVehiculo();
            if(nombreVeh.isEmpty()) nombreVeh = listaVehiculosFiltrada.get(position).getPatenteVehiculo();
            else {
                if(nombreVeh.length()>11) nombreVeh = nombreVeh.substring(0,11)+"...";
            }
            holder.txtPatente.setText(nombreVeh);
            holder.etVelocidad.setText(listaVehiculosFiltrada.get(position).getVelMaxVehiculo());
        }

        holder.etVelocidad.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                v.setFocusable(true);
                v.setFocusableInTouchMode(true);
                return false;
            }
        });

        holder.etVelocidad.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) editPos = position;
            }
        });

        holder.etVelocidad.addTextChangedListener(watcher);

        holder.etVelocidad.clearFocus();
        holder.etVelocidad.setInputType(InputType.TYPE_CLASS_NUMBER);

        return convertView;
    }

    @Override
    public Filter getFilter() {
        return Filtro;
    }

    public static class ViewHolder {
        public TextView txtPatente;
        public EditText etVelocidad;
    }

    private class ListaFiltro extends Filter {
        ArrayList<VelMaxModel> resultadosFiltro;

        @Override
        protected FilterResults performFiltering(CharSequence constraint) {
            resultadosFiltro = new ArrayList<VelMaxModel>();

            FilterResults results = new FilterResults();

            if (constraint == null || constraint.toString().isEmpty()) {
                resultadosFiltro = listaVehiculos;
            }
            else {
                String filterString = constraint.toString().toLowerCase();
                for (int i = 0; i < listaVehiculos.size(); i++) {
                    if (listaVehiculos.get(i).getPatenteVehiculo().toLowerCase().contains(filterString)) {
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
                listaVehiculosFiltrada = new ArrayList<VelMaxModel>();
                notifyDataSetInvalidated();
            } else {
                listaVehiculosFiltrada = (ArrayList<VelMaxModel>) results.values;
                notifyDataSetChanged();
            }
        }
    }
}
