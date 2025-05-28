package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 23-08-2015.
 */
public class VehiculoModel implements Parcelable {
    String idVehiculo;
    String patenteVehiculo;
    String nombreVehiculo;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getIdVehiculo());
        dest.writeString(getPatenteVehiculo());
        dest.writeString(getNombreVehiculo());
    }

    public VehiculoModel(Parcel in) {
        setIdVehiculo(in.readString());
        setPatenteVehiculo(in.readString());
        setNombreVehiculo(in.readString());
    }

    public VehiculoModel(String idVehiculo, String patenteVehiculo) {
        this.idVehiculo = idVehiculo;
        this.patenteVehiculo = patenteVehiculo;
        this.nombreVehiculo = "";
    }

    public VehiculoModel(String idVehiculo, String patenteVehiculo, String nombre) {
        this.idVehiculo = idVehiculo;
        this.patenteVehiculo = patenteVehiculo;
        this.nombreVehiculo = nombre;
    }

    public static final Creator<VehiculoModel> CREATOR = new Creator<VehiculoModel>() {
        public VehiculoModel createFromParcel(Parcel in) {
            return new VehiculoModel(in);
        }

        public VehiculoModel[] newArray(int size) {
            return new VehiculoModel[size];
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

    public String getNombreVehiculo() {
        return nombreVehiculo;
    }

    public void setNombreVehiculo(String nombreVehiculo) {
        this.nombreVehiculo = nombreVehiculo;
    }
}
