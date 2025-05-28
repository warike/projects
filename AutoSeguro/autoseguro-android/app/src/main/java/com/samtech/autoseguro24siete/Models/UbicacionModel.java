package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 30-08-2015.
 */
public class UbicacionModel implements Parcelable { //{"ID" : "5129","Patente" : "FLWY11","Estado" : "0","Velocidad" : "","Nombre" : "Vehiculo 2"}
    String idVehiculo;
    String patenteVehiculo;
    String estadoVehiculo;
    String nombreVehiculo;
    String ubicacionVehiculo;
    String corteVehiculo;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getIdVehiculo());
        dest.writeString(getPatenteVehiculo());
        dest.writeString(getEstadoVehiculo());
        dest.writeString(getNombreVehiculo());
        dest.writeString(getUbicacionVehiculo());
        dest.writeString(getCorteVehiculo());
    }

    public UbicacionModel(){
        idVehiculo = "";
        patenteVehiculo = "";
        estadoVehiculo = "";
        nombreVehiculo = "";
        ubicacionVehiculo = "";
        corteVehiculo = "";
    }

    public UbicacionModel(String idVehiculo, String patenteVehiculo, String estadoVehiculo,
                          String nombreVehiculo, String ubicacionVehiculo, String corteVehiculo) {
        this.idVehiculo = idVehiculo;
        this.patenteVehiculo = patenteVehiculo;
        this.estadoVehiculo = estadoVehiculo;
        this.nombreVehiculo = nombreVehiculo;
        this.ubicacionVehiculo = ubicacionVehiculo;
        this.corteVehiculo = corteVehiculo;
    }

    public UbicacionModel(Parcel in){
        setIdVehiculo(in.readString());
        setPatenteVehiculo(in.readString());
        setEstadoVehiculo(in.readString());
        setNombreVehiculo(in.readString());
        setUbicacionVehiculo(in.readString());
        setCorteVehiculo(in.readString());
    }

    public static final Parcelable.Creator<UbicacionModel> CREATOR = new Parcelable.Creator<UbicacionModel>() {
        public UbicacionModel createFromParcel(Parcel in) {
            return new UbicacionModel(in);
        }

        public UbicacionModel[] newArray(int size) {
            return new UbicacionModel[size];
        }
    };

    public String getIdVehiculo() {
        return idVehiculo;
    }

    public void setIdVehiculo(String idVehiculo) {
        this.idVehiculo = idVehiculo;
    }

    public String getPatenteVehiculo() {
        return patenteVehiculo;
    }

    public void setPatenteVehiculo(String patenteVehiculo) {
        this.patenteVehiculo = patenteVehiculo;
    }

    public String getEstadoVehiculo() {
        return estadoVehiculo;
    }

    public void setEstadoVehiculo(String estadoVehiculo) {
        this.estadoVehiculo = estadoVehiculo;
    }

    public String getNombreVehiculo() {
        return nombreVehiculo;
    }

    public void setNombreVehiculo(String nombreVehiculo) {
        this.nombreVehiculo = nombreVehiculo;
    }

    public String getUbicacionVehiculo() {
        return ubicacionVehiculo;
    }

    public void setUbicacionVehiculo(String ubicacionVehiculo) {
        this.ubicacionVehiculo = ubicacionVehiculo;
    }

    public String getCorteVehiculo() {
        return corteVehiculo;
    }

    public void setCorteVehiculo(String corteVehiculo) {
        this.corteVehiculo = corteVehiculo;
    }
}
