package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 13-09-2015.
 */
public class UsuariosModel implements Parcelable {
    String Usr;
    String Psw;
    String nombreUsr;
    String estadoUsr;
    String email;
    String telefono;

    public static final Creator<UsuariosModel> CREATOR = new Creator<UsuariosModel>() {
        @Override
        public UsuariosModel createFromParcel(Parcel in) {
            return new UsuariosModel(in);
        }

        @Override
        public UsuariosModel[] newArray(int size) {
            return new UsuariosModel[size];
        }
    };

    public UsuariosModel(Parcel in) {
        setUsr(in.readString());
        setPsw(in.readString());
        setNombreUsr(in.readString());
        setEstadoUsr(in.readString());
        setEmail(in.readString());
        setTelefono(in.readString());
    }

    public String getEstadoUsr() {
        return estadoUsr;
    }

    public void setEstadoUsr(String estadoUsr) {
        this.estadoUsr = estadoUsr;
    }

    public String getNombreUsr() {
        return nombreUsr;
    }

    public void setNombreUsr(String nombreUsr) {
        this.nombreUsr = nombreUsr;
    }

    public String getPsw() {
        return Psw;
    }

    public void setPsw(String psw) {
        Psw = psw;
    }

    public String getUsr() {
        return Usr;
    }

    public void setUsr(String usr) {
        Usr = usr;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getUsr());
        dest.writeString(getPsw());
        dest.writeString(getNombreUsr());
        dest.writeString(getEstadoUsr());
        dest.writeString(getEmail());
        dest.writeString(getTelefono());
    }

    public UsuariosModel(String usr, String psw, String nombreUsr, String estadoUsr, String email, String telefono) {
        this.email = email;
        this.estadoUsr = estadoUsr;
        this.nombreUsr = nombreUsr;
        Psw = psw;
        this.telefono = telefono;
        Usr = usr;
    }
}
