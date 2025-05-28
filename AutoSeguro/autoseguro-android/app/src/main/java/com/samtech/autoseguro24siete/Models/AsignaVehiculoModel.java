package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 23-08-2015.
 */
public class AsignaVehiculoModel implements Parcelable {
    String idVehiculo;
    String patenteVehiculo;
    String estadoAsignacion;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getIdVehiculo());
        dest.writeString(getPatenteVehiculo());
        dest.writeString(getEstadoAsignacion());
    }

    public AsignaVehiculoModel(Parcel in) {
        setIdVehiculo(in.readString());
        setPatenteVehiculo(in.readString());
        setEstadoAsignacion(in.readString());
    }

    public AsignaVehiculoModel(String idVehiculo, String patenteVehiculo, String nombre) {
        this.idVehiculo = idVehiculo;
        this.patenteVehiculo = patenteVehiculo;
        this.estadoAsignacion = nombre;
    }

    public static final Creator<AsignaVehiculoModel> CREATOR = new Creator<AsignaVehiculoModel>() {
        public AsignaVehiculoModel createFromParcel(Parcel in) {
            return new AsignaVehiculoModel(in);
        }

        public AsignaVehiculoModel[] newArray(int size) {
            return new AsignaVehiculoModel[size];
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

    public String getEstadoAsignacion() {
        return estadoAsignacion;
    }

    public void setEstadoAsignacion(String estadoAsignacion) {
        this.estadoAsignacion = estadoAsignacion;
    }
}
