package com.samtech.autoseguro24siete;

import android.content.Intent;
import android.content.SharedPreferences;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.app.ActionBarActivity;
import android.view.Display;
import android.view.View;
import android.widget.Button;
import android.widget.VideoView;


public class StartActivity extends ActionBarActivity {

    private VideoView videoView;
    private Button btnProbarApp, btnIniciarSesion;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_start);

        btnIniciarSesion = (Button) findViewById(R.id.btnIniciarSesion);
        btnProbarApp = (Button) findViewById(R.id.btnProbarApp);

        Uri video = Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.video);

        Display display = getWindowManager().getDefaultDisplay();
        //int w = display.getWidth();
        //int h = display.getHeight();

        videoView = (VideoView) findViewById(R.id.videoview);
        videoView.setVideoURI(video);
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.setLooping(true);
            }
        });
        //videoView.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, h));
        videoView.start();

        btnIniciarSesion.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(StartActivity.this, LoginActivity.class);
                startActivity(intent);
                finish();
            }
        });

        btnProbarApp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(StartActivity.this);
                sharedPreferences.edit().putString("demo", "1").apply();
                Intent intent = new Intent(StartActivity.this, MenuActivity.class);
                startActivity(intent);
                finish();
            }
        });
    }
}
