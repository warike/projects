package com.samtech.autoseguro24siete;

import android.app.DialogFragment;
import android.app.FragmentManager;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class RegistrarDemoActivity extends DialogFragment implements View.OnClickListener {

    EditText etNombreDemo, etEmailDemo, etTelefonoDemo;
    Button btnGuardarDemo;
    private boolean isSOS;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.activity_registrar_demo, container, false);
        etNombreDemo = (EditText) rootView.findViewById(R.id.etNombreDemo);
        etEmailDemo = (EditText) rootView.findViewById(R.id.etEmailDemo);
        etTelefonoDemo = (EditText) rootView.findViewById(R.id.etTelefonoDemo);
        btnGuardarDemo = (Button) rootView.findViewById(R.id.btnGuardarDemo);
        btnGuardarDemo.setOnClickListener(this);
        getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);

        if (savedInstanceState != null){
            isSOS = savedInstanceState.getBoolean("isSOS", false);
        }
        return rootView;
    }

    @Override
    public void onClick(View v) {
        switch(v.getId()){
            case R.id.btnGuardarDemo:
                if (!checkNull(etNombreDemo.getText().toString(), etEmailDemo.getText().toString(),
                        etTelefonoDemo.getText().toString()) && countChar(etTelefonoDemo.getText().toString())){
                    guardarDatos(etNombreDemo.getText().toString(),
                            etEmailDemo.getText().toString(), etTelefonoDemo.getText().toString());
                    FragmentManager fm = getFragmentManager();
                    PopupWindows fragment = new PopupWindows();
                    Bundle bundle = new Bundle();
                    bundle.putString("titulo", "Aviso");
                    bundle.putString("texto", "Pronto será contactado por un ejecutivo.");
                    bundle.putBoolean("isResponse", true);
                    fragment.setArguments(bundle);
                    fragment.show(fm, "popupwindow");
                    dismiss();
                    Log.d("guardar", "guardar");
                } else {
                    if (!countChar(etTelefonoDemo.getText().toString()))
                        Toast.makeText(getActivity().getApplicationContext(), "Numero debe tener 9 digitos.",
                                Toast.LENGTH_SHORT).show();
                    else
                        Toast.makeText(getActivity().getApplicationContext(), "Todos los campos son requeridos",
                                Toast.LENGTH_SHORT).show();
                }
                break;
            default:
                break;
        }
    }

    private boolean checkNull(String... params){
        boolean hasNull = false;
        for (String param: params) {
            if (param.isEmpty() && param.contentEquals(""))
                hasNull = true;
        }
        return hasNull;
    }

    private boolean countChar(String param){
        if (param.length() <= 7)
            return false;
        else
            return true;
    }

    private void guardarDatos(String nombre, String email, String telefono){
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(
                getActivity().getApplicationContext());
        sharedPreferences.edit().putString("nombreDemo", nombre).apply();
        sharedPreferences.edit().putString("emailDemo", email).apply();
        sharedPreferences.edit().putString("telefonoDemo", telefono).apply();
        sharedPreferences.edit().putBoolean("isRegistered", true).apply();
    }
}
