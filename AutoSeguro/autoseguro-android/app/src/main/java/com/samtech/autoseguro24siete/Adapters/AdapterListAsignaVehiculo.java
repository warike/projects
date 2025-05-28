package com.samtech.autoseguro24siete.Adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.samtech.autoseguro24siete.Models.AsignaVehiculoModel;
import com.samtech.autoseguro24siete.R;

import java.util.ArrayList;

/**
 * Created by Tato on 28-08-2015.
 */
public class AdapterListAsignaVehiculo extends BaseAdapter {
    private Context c;
    private String Usr, Psw, dToken, app;
    private ArrayList<AsignaVehiculoModel> listaVehiculos, listaVehiculosFiltrada;
    private ArrayList<ViewHolder> vistas;
    private ViewHolder vActivarTodos = null;
    private AsignaVehiculoModel TodosActivados = null;

    public AdapterListAsignaVehiculo(Context c, String usr, String psw, ArrayList<AsignaVehiculoModel> listaVehiculos) {
        this.c = c;
        Usr = usr;
        Psw = psw;
        this.listaVehiculos = listaVehiculos;
        this.listaVehiculosFiltrada = listaVehiculos;
        vistas = new ArrayList<ViewHolder>();
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
            if(listaVehiculos.get(i).getEstadoAsignacion().compareToIgnoreCase("0")==0 && listaVehiculos.get(i).getPatenteVehiculo().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
    }

    public boolean esTodosDesactivados(){
        boolean flag = true;
        for(int i=0;i<listaVehiculos.size();i++){
            if(listaVehiculos.get(i).getEstadoAsignacion().compareToIgnoreCase("1")==0 && listaVehiculos.get(i).getPatenteVehiculo().compareToIgnoreCase("Activar Todos")!=0) {
                flag = false;
                break;
            }
        }
        return flag;
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
            vistas.add(holder);
            convertView.setTag(holder);
        }
        else {
            holder = (ViewHolder) convertView.getTag();
        }

        if(position < listaVehiculosFiltrada.size()) {
            holder.txtPatente.setText(listaVehiculosFiltrada.get(position).getPatenteVehiculo());
        }

        if(listaVehiculosFiltrada.get(position).getPatenteVehiculo().contentEquals("Activar Todos")){
            /*if(esTodosActivados()) holder.estado = 1;
            else holder.estado = 0;*/
            vActivarTodos = holder;
            TodosActivados = listaVehiculosFiltrada.get(position);
            if(esTodosActivados()) {
                listaVehiculosFiltrada.get(position).setEstadoAsignacion("1");
            }
        }

        if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("0")) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
        else if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("1")) holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));

        holder.ivSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("1")) {
                    holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                    listaVehiculosFiltrada.get(position).setEstadoAsignacion("0");
                }
                else if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("0")) {
                    holder.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                    listaVehiculosFiltrada.get(position).setEstadoAsignacion("1");
                }

                if(listaVehiculosFiltrada.get(position).getPatenteVehiculo().contentEquals("Activar Todos")){
                    if(vistas.size()>0){ // activar vistas
                        for(int z=0;z<vistas.size();z++){
                            if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("1")){
                                vistas.get(z).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                            }
                            else vistas.get(z).ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        }
                    }
                    if(listaVehiculosFiltrada.size()>0){
                        for(int x=0;x<listaVehiculosFiltrada.size();x++){
                            if(listaVehiculosFiltrada.get(position).getEstadoAsignacion().contentEquals("1")){
                                listaVehiculosFiltrada.get(x).setEstadoAsignacion("1");
                            }
                            else listaVehiculosFiltrada.get(x).setEstadoAsignacion("0");
                        }
                    }
                }
                else{
                    if(esTodosActivados()){
                        if(vActivarTodos != null) vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.on));
                        if(TodosActivados != null) TodosActivados.setEstadoAsignacion("1");
                    }
                    else {
                        if(vActivarTodos != null) vActivarTodos.ivSwitch.setImageDrawable(c.getResources().getDrawable(R.drawable.off));
                        if(TodosActivados != null) TodosActivados.setEstadoAsignacion("0");
                    }
                }
            }
        });


        return convertView;
    }

    public static class ViewHolder {
        public TextView txtPatente;
        public ImageView ivSwitch;
    }

}
