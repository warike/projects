package com.samtech.gpsalert.Adapters;

import android.content.Context;
import android.util.Log;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.Spinner;
import android.widget.TextView;

import com.samtech.gpsalert.Models.ControlUsoModel;
import com.samtech.gpsalert.R;

import java.util.ArrayList;

/**
 * Created by Tato on 22-09-2015.
 */
public class AdapterListConfigControlUso extends BaseAdapter implements Filterable {
    private Context c;
    private ArrayList<ControlUsoModel> listaControlUso, listaFiltrada;
    private String Usr, Psw;
    private String dias[], horas[], minutos[];
    ArrayAdapter<String> adpHoras, adpMins;
    //private ListaFiltro Filtro;

    public AdapterListConfigControlUso(Context ctx, ArrayList<ControlUsoModel> lista, String usuario, String password) {
        c = ctx;
        listaControlUso = lista;
        listaFiltrada = lista;
        Usr = usuario;
        Psw = password;
        //Filtro = new ListaFiltro();
        dias = c.getResources().getStringArray(R.array.dias_str);

        horas = new String[24];
        for(int i=0;i<24;i++){
            if(i<10) horas[i] = "0"+i;
            else horas[i]=""+i;
        }
        adpHoras = new ArrayAdapter<String>(c, android.R.layout.simple_spinner_item, horas);
        minutos = new String[60];
        for(int i=0;i<60;i++){
            if(i<10) minutos[i] = "0"+i;
            else minutos[i]=""+i;
        }
        adpMins = new ArrayAdapter<String>(c, android.R.layout.simple_spinner_item, minutos);
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
            holder.spDesdeHora = (Spinner) vista.findViewById(R.id.spinDesdeHora);
            holder.spDesdeHora.setAdapter(adpHoras);
            holder.spDesdeMin = (Spinner) vista.findViewById(R.id.spinDesdeMin);
            holder.spDesdeMin.setAdapter(adpMins);
            holder.spHastaDia = (Spinner) vista.findViewById(R.id.spinHastaDia);
            holder.spHastaHora = (Spinner) vista.findViewById(R.id.spinHastaHora);
            holder.spHastaHora.setAdapter(adpHoras);
            holder.spHastaMin = (Spinner) vista.findViewById(R.id.spinHastaMin);
            holder.spHastaMin.setAdapter(adpMins);

            vista.setTag(holder);
        } else {
            holder = (ViewHolder) vista.getTag();
        }

        if (position < listaFiltrada.size()) {
            holder.tvPatente.setText(listaFiltrada.get(position).getPatente());

            // Desde
            int posDesde = Integer.parseInt(listaFiltrada.get(position).getDiaDesde());
            if(posDesde>=0 && posDesde<dias.length) holder.spDesdeDia.setSelection(posDesde);
            else holder.spDesdeDia.setSelection(0);

            int posHDesde = 0;
            posHDesde = Integer.parseInt(listaFiltrada.get(position).getHoraDesde());
            if(posHDesde>=0 && posHDesde<horas.length) holder.spDesdeHora.setSelection(posHDesde);
            else holder.spDesdeHora.setSelection(0);

            int posMDesde = 0;
            posMDesde = Integer.parseInt(listaFiltrada.get(position).getMinDesde());
            if(posMDesde>=0 && posMDesde<minutos.length) holder.spDesdeMin.setSelection(posMDesde);
            else holder.spDesdeMin.setSelection(0);


            // Hasta
            int posHasta = Integer.parseInt(listaFiltrada.get(position).getDiaHasta());
            if(posHasta>=0 && posHasta<dias.length) holder.spHastaDia.setSelection(posHasta);
            else holder.spHastaDia.setSelection(0);

            int posHHasta = 0;
            posHHasta = Integer.parseInt(listaFiltrada.get(position).getHoraHasta());
            if(posHHasta>=0 && posHHasta<horas.length) holder.spHastaHora.setSelection(posHHasta);
            else holder.spHastaHora.setSelection(0);

            int posMHasta = 0;
            posMHasta = Integer.parseInt(listaFiltrada.get(position).getMinHasta());
            if(posMHasta>=0 && posMHasta<minutos.length) holder.spHastaMin.setSelection(posMHasta);
            else holder.spHastaMin.setSelection(0);

        }
        final int posix = position;

        // Desde
        holder.spDesdeDia.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                listaFiltrada.get(posix).setDiaDesde(position+"");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.spDesdeHora.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(position<10) listaFiltrada.get(posix).setHoraDesde("0"+position);
                else listaFiltrada.get(posix).setHoraDesde(position+"");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.spDesdeMin.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(position<10) listaFiltrada.get(posix).setMinDesde("0"+position);
                else listaFiltrada.get(posix).setMinDesde(position + "");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });


        //Hasta
        holder.spHastaDia.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                listaFiltrada.get(posix).setDiaHasta(position + "");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.spHastaHora.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(position<10) listaFiltrada.get(posix).setHoraHasta("0" + position);
                else listaFiltrada.get(posix).setHoraHasta(position + "");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        holder.spHastaMin.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if(position<10) listaFiltrada.get(posix).setMinHasta("0" + position);
                else listaFiltrada.get(posix).setMinHasta(position + "");
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

        /*holder.etDesdeHora.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                listaFiltrada.get(posix).setHoraDesde(holder.etDesdeHora.getText().toString());
                return false;
            }
        });*/

        /*holder.etHastaHora.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                listaFiltrada.get(posix).setHoraHasta(holder.etHastaHora.getText().toString());
                return false;
            }
        });*/

        return vista;
    }

    @Override
    public Filter getFilter() {
        return null;
    }

    private static class ViewHolder {
        TextView tvPatente;
        Spinner spDesdeDia;
        Spinner spDesdeHora;
        Spinner spDesdeMin;
        Spinner spHastaDia;
        Spinner spHastaHora;
        Spinner spHastaMin;
    }
}
