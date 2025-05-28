package com.samtech.gpsalert;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.preference.PreferenceManager;
import android.support.v4.app.NavUtils;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Gravity;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class ConfiguracionActivity extends ActionBarActivity {
    String Usr, Psw, tipoUsr, tipoPlan;
    LinearLayout llUsuarios, llVehiculos;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_configuracion);

        // Configuracion ActionBar
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        setearBarraSuperior();

        Bundle b = getIntent().getExtras();
        if(b != null){
            Usr = b.getString("Usr", ""); Psw = b.getString("Password", "");
            tipoUsr = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoTipo", "");
            tipoPlan = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPlan", "");
        }
        else {
            finish();
        }

        llUsuarios = (LinearLayout) findViewById(R.id.llUsuarios);
        llVehiculos = (LinearLayout) findViewById(R.id.llVehiculos);

        ImageView btnVelMax = (ImageView) findViewById(R.id.btnVelMax);
        btnVelMax.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent VelMax = new Intent(ConfiguracionActivity.this, VelMaxActivity.class);
                VelMax.putExtra("Usr", Usr);
                VelMax.putExtra("Password", Psw);
                startActivity(VelMax);
            }
        });

        ImageView btnVehiculos = (ImageView) findViewById(R.id.btnVehiculos);
        btnVehiculos.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent Nombres = new Intent(ConfiguracionActivity.this, VehiculosActivity.class);
                Nombres.putExtra("Usr", Usr);
                Nombres.putExtra("Password", Psw);
                startActivity(Nombres);
            }
        });

        ImageView btnUsuarios = (ImageView) findViewById(R.id.btnUsuarios);
        /*if(tipoUsr.compareToIgnoreCase("2") == 0){*/
            btnUsuarios.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent Usuarios = new Intent(ConfiguracionActivity.this, UsuariosActivity.class);
                    Usuarios.putExtra("Usr", Usr);
                    Usuarios.putExtra("Password", Psw);
                    startActivity(Usuarios);
                }
            });
        /*}
        else btnUsuarios.setVisibility(View.INVISIBLE);*/

        ImageView btnControlUso = (ImageView) findViewById(R.id.btnControlUso);
        ImageView btnAyuda = (ImageView) findViewById(R.id.btnAyuda);
        if(tipoUsr.compareToIgnoreCase("2")==0){
            llUsuarios.setVisibility(View.GONE);
            //llVehiculos.setVisibility(View.GONE);
            btnAyuda = (ImageView) findViewById(R.id.btnVehiculos);
            btnAyuda.setImageDrawable(getApplicationContext().getResources().getDrawable(R.drawable.conf_ayuda));
            LinearLayout llAyuda = (LinearLayout) findViewById(R.id.llAyuda);
            llAyuda.setVisibility(View.GONE);
            TextView tvVehiculos = (TextView) findViewById(R.id.txtVehiculosConf);
            tvVehiculos.setText("Ayuda");
        }
        else if(tipoUsr.compareToIgnoreCase("1")==0) {
            if(tipoPlan.compareToIgnoreCase("pyme")==0) {
                btnControlUso.setVisibility(View.VISIBLE);
                btnControlUso.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent confControlUso = new Intent(ConfiguracionActivity.this, ConfigControlUsoActivity.class);
                        confControlUso.putExtra("Usr", Usr);
                        confControlUso.putExtra("Password", Psw);
                        startActivity(confControlUso);
                    }
                });
            }
        }

        btnAyuda.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent();
                i.setAction(Intent.ACTION_VIEW);
                i.addCategory(Intent.CATEGORY_BROWSABLE);
                i.setData(Uri.parse("http://www.gpsalerta.cl/ayuda"));
                startActivity(i);
            }
        });
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

/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_configuracion, menu);
        return true;
    }
*/
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        if(id == android.R.id.home){
            Intent intent = new Intent().setClass(this, MenuActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_SINGLE_TOP);
            NavUtils.navigateUpTo(this, intent);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
