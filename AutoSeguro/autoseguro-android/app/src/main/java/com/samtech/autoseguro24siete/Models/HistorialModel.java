package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 23-08-2015.
 */
public class HistorialModel implements Parcelable {
    String tipoEvento;
    String horaEvento;
    String ubicacionEvento;
    String Latitud;
    String Longitud;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getTipoEvento());
        dest.writeString(getHoraEvento());
        dest.writeString(getUbicacionEvento());
        dest.writeString(getLatitud());
        dest.writeString(getLongitud());
    }

    public HistorialModel(String tipEv, String horEv, String ubicEv, String latEv, String lngEv){
        super();
        tipoEvento = tipEv;
        horaEvento = horEv;
        ubicacionEvento = ubicEv;
        Latitud = latEv;
        Longitud = lngEv;
    }

    public HistorialModel(Parcel in){
        setTipoEvento(in.readString());
        setHoraEvento(in.readString());
        setUbicacionEvento(in.readString());
        setLatitud(in.readString());
        setLongitud(in.readString());
    }

    public static final Parcelable.Creator<HistorialModel> CREATOR = new Parcelable.Creator<HistorialModel>() {
        public HistorialModel createFromParcel(Parcel in) {
            return new HistorialModel(in);
        }

        public HistorialModel[] newArray(int size) {
            return new HistorialModel[size];
        }
    };

    public String getTipoEvento() {
        return tipoEvento;
    }

    public void setTipoEvento(String tipoEvento) {
        this.tipoEvento = tipoEvento;
    }

    public String getHoraEvento() {
        return horaEvento;
    }

    public void setHoraEvento(String horaEvento) {
        this.horaEvento = horaEvento;
    }

    public String getUbicacionEvento() {
        return ubicacionEvento;
    }

    public void setUbicacionEvento(String ubicacionEvento) {
        this.ubicacionEvento = ubicacionEvento;
    }

    public String getLatitud() {
        return Latitud;
    }

    public void setLatitud(String latitud) {
        Latitud = latitud;
    }

    public String getLongitud() {
        return Longitud;
    }

    public void setLongitud(String longitud) {
        Longitud = longitud;
    }
}
