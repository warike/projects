package com.samtech.autoseguro24siete;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.samtech.autoseguro24siete.R;

public class HistorialMapaActivity extends ActionBarActivity{
    private GoogleMap mMap; // Might be null if Google Play services APK is not available.
    String Patente, Hora, Evento, Latitud, Longitud;
    float zoomMapa = 16;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_historial_mapa);
        Bundle b = getIntent().getExtras();

        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        if(b != null){
            Patente = b.getString("Patente", ""); Hora = b.getString("Hora", "");
            Evento = b.getString("Evento", "");
            Latitud = b.getString("Latitud", ""); Longitud = b.getString("Longitud", "");

            if(!Patente.isEmpty() && !Hora.isEmpty() && !Evento.isEmpty() && !Latitud.isEmpty() && !Longitud.isEmpty()){
                TextView Pat = (TextView) findViewById(R.id.txtPatente);
                Pat.setText(Patente);

                TextView Hor = (TextView) findViewById(R.id.txtHora);
                Hor.setText(Hora);

                TextView Eve = (TextView) findViewById(R.id.txtEvento);
                Eve.setText(Evento);

                int tipoEv=-1;

                if(Evento.compareTo("Abre Contacto")==0 ) tipoEv = 1; // Encendido de motor
                else tipoEv = 0; // Apagado de motor

                if(tipoEv == 1) Eve.setTextColor(Color.parseColor("#035F7E"));
                else Eve.setTextColor(Color.parseColor("#FF0000"));

                setearMapa(tipoEv, Latitud, Longitud);
            }
            else {
                Toast.makeText(getApplicationContext(), getString(R.string.SOS_no_enviado), Toast.LENGTH_LONG).show();
                finish();
            }
        }
        else finish();

        setearBarraSuperior();
    }

    public void setearBarraSuperior(){
        ColorDrawable colorDrawable = new ColorDrawable(Color.parseColor("#B71C1C"));
        //Drawable barraSuperior = getResources().getDrawable(R.drawable.top_franja_rojo);
        Drawable barraSuperior = colorDrawable;

        if(barraSuperior != null){
            getSupportActionBar().setBackgroundDrawable(barraSuperior);
            getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM | ActionBar.DISPLAY_HOME_AS_UP);

            View v = getLayoutInflater().inflate(R.layout.barra_superior, null);
            ActionBar.LayoutParams lay = new ActionBar.LayoutParams(ActionBar.LayoutParams.WRAP_CONTENT,ActionBar.LayoutParams.MATCH_PARENT,
                    Gravity.CENTER);
            getSupportActionBar().setCustomView(v, lay);
            TextView titulo = (TextView) v.findViewById(R.id.abTitulo_tv);
            String strTitulo = "";

            ActivityInfo activityInfo = null;
            try {
                activityInfo = getPackageManager().getActivityInfo(getComponentName(), PackageManager.GET_META_DATA);
                strTitulo = activityInfo.loadLabel(getPackageManager()).toString();
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
            titulo.setText(strTitulo);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    private void setearMapa(int tipoEvento, String Latitud, String Longitud) {
        if (mMap == null) mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map)).getMap();

        MarkerOptions mo = new MarkerOptions().position(new LatLng(Double.parseDouble(Latitud), Double.parseDouble(Longitud))).title("Vehículo");
        if(tipoEvento == 1) mo.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE));
        else mo.icon(BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED));
        mMap.addMarker(mo);
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(Double.parseDouble(Latitud), Double.parseDouble(Longitud)), zoomMapa));
        mMap.setMapType(GoogleMap.MAP_TYPE_HYBRID);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, HistorialActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
