package com.samtech.gpsalert.Models;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

/**
 * Created by Tato on 21-09-2015.
 */
public class ControlUsoModel implements Parcelable {
    protected String Patente;
    protected String idVehiculo;
    protected String activado; // true si esta activado el control de uso
    protected String DiaDesde;
    protected String DiaHasta;
    protected String HoraDesde;
    protected String HoraHasta;
    protected String MinDesde;
    protected String MinHasta;
    protected String Nombre;

    public static final Parcelable.Creator<ControlUsoModel> CREATOR = new Parcelable.Creator<ControlUsoModel>() {
        public ControlUsoModel createFromParcel(Parcel in) {
            return new ControlUsoModel( in);
        }

        public ControlUsoModel[] newArray(int size) {
            return new ControlUsoModel[size];
        }
    };

    public ControlUsoModel(String gps, String patente, String estado, String dDesde, String dHasta, String hDesde, String hHasta, String mDesde, String mHasta, String nomb) {
        super();
        Patente = patente;
        idVehiculo = gps;
        activado = estado;
        DiaDesde = dDesde;
        DiaHasta = dHasta;
        HoraDesde = hDesde;
        HoraHasta = hHasta;
        MinDesde = mDesde;
        MinHasta = mHasta;
        Nombre = nomb;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getPatente());
        dest.writeString(getIdVehiculo());
        dest.writeString(getActivado());
        dest.writeString(getDiaDesde());
        dest.writeString(getDiaHasta());
        dest.writeString(getHoraDesde());
        dest.writeString(getHoraHasta());
        dest.writeString(getMinDesde());
        dest.writeString(getMinHasta());
        dest.writeString(getNombre());
    }

    public ControlUsoModel(Parcel in) {
        setPatente(in.readString());
        setIdVehiculo(in.readString());
        setActivado(in.readString());
        setDiaDesde(in.readString());
        setDiaHasta(in.readString());
        setHoraDesde(in.readString());
        setHoraHasta(in.readString());
        setMinDesde(in.readString());
        setMinHasta(in.readString());
        setNombre(in.readString());
    }

    public String getPatente() {
        return Patente;
    }

    public void setPatente(String patente) {
        Patente = patente;
    }

    public String getIdVehiculo() {
        return idVehiculo;
    }

    public void setIdVehiculo(String idVehiculo) {
        this.idVehiculo = idVehiculo;
    }

    public String getActivado() {
        return activado;
    }

    public void setActivado(String activado) {
        this.activado = activado;
    }

    public String getHoraHasta() {
        return HoraHasta;
    }

    public void setHoraHasta(String horaHasta) {
        HoraHasta = horaHasta;
    }

    public String getDiaDesde() {
        return DiaDesde;
    }

    public void setDiaDesde(String diaDesde) {
        DiaDesde = diaDesde;
    }

    public String getDiaHasta() {
        return DiaHasta;
    }

    public void setDiaHasta(String diaHasta) {
        DiaHasta = diaHasta;
    }

    public String getHoraDesde() {
        return HoraDesde;
    }

    public void setHoraDesde(String horaDesde) {
        HoraDesde = horaDesde;
    }

    public String getNombre() { return Nombre; }

    public void setNombre(String nombre) { Nombre = nombre; }

    public String getMinHasta() {
        return MinHasta;
    }

    public void setMinHasta(String minHasta) {
        MinHasta = minHasta;
    }

    public String getMinDesde() {
        return MinDesde;
    }

    public void setMinDesde(String minDesde) {
        MinDesde = minDesde;
    }
}

