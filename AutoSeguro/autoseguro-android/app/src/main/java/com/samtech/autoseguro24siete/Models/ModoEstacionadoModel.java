package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 28-08-2015.
 */
//{"ID" : "5129","Patente" : "FLWY11","Estado" : "1","Velocidad" : "500","Nombre" : "Vehiculo 2"}
public class ModoEstacionadoModel implements Parcelable {
    String ID, Patente, Estado, Velocidad, Nombre, Corte;
    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getID());
        dest.writeString(getPatente());
        dest.writeString(getEstado());
        dest.writeString(getVelocidad());
        dest.writeString(getNombre());
        dest.writeString(getCorte());
    }

    public ModoEstacionadoModel() {
        Estado = "";
        this.ID = "";
        Nombre = "";
        Patente = "";
        Velocidad = "";
        Corte = "";
    }

    public ModoEstacionadoModel(String ID, String patente, String estado, String velocidad, String nombre, String corte) {
        Estado = estado;
        this.ID = ID;
        Nombre = nombre;
        Patente = patente;
        Velocidad = velocidad;
        Corte = corte;
    }

    public ModoEstacionadoModel(Parcel in) {
        setID(in.readString());
        setPatente(in.readString());
        setEstado(in.readString());
        setVelocidad(in.readString());
        setNombre(in.readString());
        setCorte(in.readString());
    }

    public static final Parcelable.Creator<ModoEstacionadoModel> CREATOR = new Parcelable.Creator<ModoEstacionadoModel>() {
        public ModoEstacionadoModel createFromParcel(Parcel in) {
            return new ModoEstacionadoModel(in);
        }

        public ModoEstacionadoModel[] newArray(int size) {
            return new ModoEstacionadoModel[size];
        }
    };

    public String getEstado() {
        return Estado;
    }

    public void setEstado(String estado) {
        Estado = estado;
    }

    public String getID() {
        return ID;
    }

    public void setID(String ID) {
        this.ID = ID;
    }

    public String getNombre() {
        return Nombre;
    }

    public void setNombre(String nombre) {
        Nombre = nombre;
    }

    public String getPatente() {
        return Patente;
    }

    public void setPatente(String patente) {
        Patente = patente;
    }

    public String getVelocidad() {
        return Velocidad;
    }

    public void setVelocidad(String velocidad) {
        Velocidad = velocidad;
    }

    public String getCorte() {
        return Corte;
    }

    public void setCorte(String corte) {
        Corte = corte;
    }
}
