package com.samtech.autoseguro24siete;

import android.app.Activity;
import android.content.Intent;
import android.preference.PreferenceManager;
import android.os.Bundle;

import com.samtech.autoseguro24siete.R;

import java.util.Timer;
import java.util.TimerTask;

public class SplashActivity extends Activity {
    String Usr, Psw, estadoVehiculo, estadoControlVelocidad, tipoUsr, bPlan;
    private long splashDelay = 1500; //1.5 segundos

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        estadoVehiculo = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoVehAsignado", "");
        Usr = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoUsr", "");
        Psw = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPsw", "");
        tipoUsr = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoTipo", "");
        bPlan = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("ultimoPlan", "");
        estadoControlVelocidad  = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getString("estadoControl", "");
        final boolean flagRecordar = PreferenceManager.getDefaultSharedPreferences(getApplicationContext()).getBoolean("ultimoRec", false);

        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                Intent mainIntent = new Intent().setClass(SplashActivity.this, LoginActivity.class);
                startActivity(mainIntent);
                /*if(flagRecordar)*/ finish(); // Destruimos esta activity para prevenir que el usuario retorne aqui presionando el boton Atras.
            }
        };

        if(!estadoVehiculo.isEmpty() && !Usr.isEmpty() && !Psw.isEmpty() && !tipoUsr.isEmpty() && !bPlan.isEmpty() && !estadoControlVelocidad.isEmpty() && flagRecordar){
            Intent mainIntent = new Intent().setClass(SplashActivity.this, MenuActivity.class);
            startActivity(mainIntent);
            finish();
        }
        else {
            setContentView(R.layout.activity_splash);
            Timer timer = new Timer();
            timer.schedule(task, splashDelay);
        }
    }
/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_splash, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
*/
}
