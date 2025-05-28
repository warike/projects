package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 07-09-2015.
 */
public class VelMaxModel implements Parcelable{
    String idVehiculo;
    String patenteVehiculo;
    String velMaxVehiculo;
    String nombreVehiculo;

    public VelMaxModel(String id, String pat, String vel, String nomb){
        idVehiculo = id;
        patenteVehiculo = pat;
        velMaxVehiculo = vel;
        nombreVehiculo = nomb;
    }

    protected VelMaxModel(Parcel in) {
        setIdVehiculo(in.readString());
        setPatenteVehiculo(in.readString());
        setVelMaxVehiculo(in.readString());
        setNombreVehiculo(in.readString());
    }

    public static final Creator<VelMaxModel> CREATOR = new Creator<VelMaxModel>() {
        @Override
        public VelMaxModel createFromParcel(Parcel in) {
            return new VelMaxModel(in);
        }

        @Override
        public VelMaxModel[] newArray(int size) {
            return new VelMaxModel[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(idVehiculo);
        dest.writeString(patenteVehiculo);
        dest.writeString(velMaxVehiculo);
        dest.writeString(nombreVehiculo);
    }

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

    public String getVelMaxVehiculo() {
        return velMaxVehiculo;
    }

    public void setVelMaxVehiculo(String velMaxVehiculo) {
        this.velMaxVehiculo = velMaxVehiculo;
    }

    public String getNombreVehiculo() {
        return nombreVehiculo;
    }

    public void setNombreVehiculo(String nombreVehiculo) {
        this.nombreVehiculo = nombreVehiculo;
    }
}
