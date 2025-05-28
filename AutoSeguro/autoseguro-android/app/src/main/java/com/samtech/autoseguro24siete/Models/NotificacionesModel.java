package com.samtech.autoseguro24siete.Models;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Tato on 23-08-2015.
 */
public class NotificacionesModel implements Parcelable {
    String idNotificacion;
    String Titulo;
    String Descripcion;
    String Estado;

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getIdNotificacion());
        dest.writeString(getTitulo());
        dest.writeString(getDescripcion());
        dest.writeString(getEstado());
    }

    public NotificacionesModel(String id, String tit, String desc, String estado){
        super();
        idNotificacion = id;
        Titulo = tit;
        Descripcion = desc;
        Estado = estado;
    }

    public NotificacionesModel(Parcel in){
        setIdNotificacion(in.readString());
        setTitulo(in.readString());
        setDescripcion(in.readString());
        setEstado(in.readString());
    }

    public static final Creator<NotificacionesModel> CREATOR = new Creator<NotificacionesModel>() {
        public NotificacionesModel createFromParcel(Parcel in) {
            return new NotificacionesModel(in);
        }

        public NotificacionesModel[] newArray(int size) {
            return new NotificacionesModel[size];
        }
    };

    public String getTitulo() {
        return Titulo;
    }

    public void setTitulo(String titulo) {
        Titulo = titulo;
    }

    public String getDescripcion() {
        return Descripcion;
    }

    public void setDescripcion(String descripcion) {
        Descripcion = descripcion;
    }

    public String getEstado() {
        return Estado;
    }

    public void setEstado(String estado) {
        Estado = estado;
    }

    public String getIdNotificacion() {
        return idNotificacion;
    }

    public void setIdNotificacion(String idNotificacion) {
        this.idNotificacion = idNotificacion;
    }
}
