package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.Spinner;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.ControlUsoModel;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 22-09-2015.
 */
public class AdapterListConfigControlUso extends BaseAdapter implements Filterable {
    private Context c;
    private ArrayList<ControlUsoModel> listaControlUso, listaFiltrada;
    private String Usr, Psw;
    private String dias[];
    //private ListaFiltro Filtro;

    public AdapterListConfigControlUso(Context ctx, ArrayList<ControlUsoModel> lista, String usuario, String password) {
        c = ctx;
        listaControlUso = lista;
        listaFiltrada = lista;
        Usr = usuario;
        Psw = password;
        //Filtro = new ListaFiltro();
        dias = c.getResources().getStringArray(R.array.dias_str);
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
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View vista = convertView;
        final ViewHolder holder;

        if (vista == null) {
            LayoutInflater inf = (LayoutInflater) c.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            vista = inf.inflate(R.layout.conf_control_uso_item, null);

            holder = new ViewHolder();
            holder.tvPatente = (TextView) vista.findViewById(R.id.txtPatente);
            holder.spDesdeDia = (Spinner) vista.findViewById(R.id.spinDesdeDia);
            holder.spHastaDia = (Spinner) vista.findViewById(R.id.spinHastaDia);
            holder.etDesdeHora = (EditText) vista.findViewById(R.id.etHoraDesde);
            holder.etHastaHora = (EditText) vista.findViewById(R.id.etHoraHasta);
            vista.setTag(holder);
        } else {
            holder = (ViewHolder) vista.getTag();
        }

        if (position < listaFiltrada.size()) {
            holder.tvPatente.setText(listaFiltrada.get(position).getPatente());
            int posDesde = Integer.parseInt(listaFiltrada.get(position).getDiaDesde());
            if(posDesde>=0 && posDesde<dias.length) holder.spDesdeDia.setSelection(posDesde);
            else holder.spDesdeDia.setSelection(0);

            int posHasta = Integer.parseInt(listaFiltrada.get(position).getDiaHasta());
            if(posHasta>=0 && posHasta<dias.length) holder.spHastaDia.setSelection(posHasta);
            else holder.spHastaDia.setSelection(0);

            if(!listaFiltrada.get(position).getHoraDesde().isEmpty()) holder.etDesdeHora.setText(listaFiltrada.get(position).getHoraDesde());
            else holder.etDesdeHora.setText("00:00:00");

            if(!listaFiltrada.get(position).getHoraHasta().isEmpty()) holder.etHastaHora.setText(listaFiltrada.get(position).getHoraHasta());
            else holder.etHastaHora.setText("00:00:00");
        }
        final int posix = position;
        holder.spDesdeDia.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                listaFiltrada.get(posix).setDiaDesde(position+"");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.spHastaDia.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                listaFiltrada.get(posix).setDiaHasta(position + "");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.etDesdeHora.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                listaFiltrada.get(posix).setHoraDesde(holder.etDesdeHora.getText().toString());
                return false;
            }
        });

        holder.etHastaHora.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                listaFiltrada.get(posix).setHoraHasta(holder.etHastaHora.getText().toString());
                return false;
            }
        });

        return vista;
    }

    @Override
    public Filter getFilter() {
        return null;
    }

    private static class ViewHolder {
        TextView tvPatente;
        Spinner spDesdeDia;
        EditText etDesdeHora;
        Spinner spHastaDia;
        EditText etHastaHora;
    }
}
