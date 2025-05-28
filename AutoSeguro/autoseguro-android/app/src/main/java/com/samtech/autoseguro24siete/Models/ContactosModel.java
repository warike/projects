package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by gurofo on 10/30/15.
 */
public class ContactosModel implements Parcelable {
    String Usr;
    String Psw;
    String nombre;
    String email;
    String telefono;
    String idCont;

    public ContactosModel(String usr, String psw, String nombre, String email, String telefono, String idCont) {
        Usr = usr;
        Psw = psw;
        this.nombre = nombre;
        this.email = email;
        this.telefono = telefono;
        this.idCont = idCont;
    }

    public ContactosModel(String nombre, String email, String telefono, String idCont) {
        this.nombre = nombre;
        this.email = email;
        this.telefono = telefono;
        this.idCont = idCont;
    }

    public ContactosModel(Parcel in) {
        setUsr(in.readString());
        setPsw(in.readString());
        setNombre(in.readString());
        setEmail(in.readString());
        setTelefono(in.readString());
        setIdCont(in.readString());
    }

    public String getUsr() {
        return Usr;
    }

    public void setUsr(String usr) {
        Usr = usr;
    }

    public String getPsw() {
        return Psw;
    }

    public void setPsw(String psw) {
        Psw = psw;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
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

    public String getIdCont() {
        return idCont;
    }

    public void setIdCont(String idCont) {
        this.idCont = idCont;
    }

    public static final Creator<ContactosModel> CREATOR = new Creator<ContactosModel>() {
        @Override
        public ContactosModel createFromParcel(Parcel in) {
            return new ContactosModel(in);
        }

        @Override
        public ContactosModel[] newArray(int size) {
            return new ContactosModel[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getUsr());
        dest.writeString(getPsw());
        dest.writeString(getNombre());
        dest.writeString(getEmail());
        dest.writeString(getTelefono());
        dest.writeString(getIdCont());
    }
}
