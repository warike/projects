//
//  LibraryAPI.swift
//  lobarnecheagps
//
//  Created by RWBook Retina on 8/6/15.
//  Copyright (c) 2015 SAMTECH SA. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    fileprivate let _vehiculoService : IVehiculoService
    fileprivate let _eventoService : IEventoService
    fileprivate let _loginService : ILoginService
    fileprivate let _ubicacionService : IUbicacionService
    fileprivate let _usuarioService : IUsuarioService
    
    
    fileprivate var _velocidad : String = "0"
    fileprivate var _estacionado : String = "0"
    fileprivate var _deviceToken : String
    fileprivate var _usuario : Usuario
    fileprivate var _userLocation : Ubicacion
    
    fileprivate var _isMapaUbicacion : Bool = false
    
    class var sharedInstance : LibraryAPI{
        struct Singleton {
            
            static let instance  = LibraryAPI(
                vehiculoService: VehiculoService(),
                eventoService: EventoService(),
                loginService: LoginService(),
                ubicacionService: UbicacionService(),
                usuarioService: UsuarioService(),
                usuario: Usuario(),
                ubicacionUsuario: Ubicacion(),
                deviceToken: String("")
                
            )
        }
        return Singleton.instance
    }
    
    init(
        vehiculoService: IVehiculoService,
        eventoService: IEventoService,
        loginService: ILoginService,
        ubicacionService: IUbicacionService,
        usuarioService: IUsuarioService,
        usuario: Usuario,
        ubicacionUsuario: Ubicacion,
        deviceToken: String)
    {
        self._vehiculoService = vehiculoService
        self._eventoService = eventoService
        self._loginService = loginService
        self._ubicacionService = ubicacionService
        self._usuarioService = usuarioService
        self._deviceToken = deviceToken
        self._usuario = usuario
        self._userLocation = ubicacionUsuario
    }
    
    func getDeviceToken() ->String {
        return self._deviceToken
    }
    
    func tieneVelocidadActivado() -> String {
        return self._velocidad as String
    }
    
    func tieneEstacionadoActivado() -> String {
        return self._estacionado as String
    }
    
    func setVelocidadActivado(_ estado :String) -> Void {
        self._velocidad = estado
    }
    
    func setEstacionadoActivado(_ estado :String) -> Void {
        self._estacionado = estado
    }
    
    func consultaEstados() {
        self._usuarioService.consultaEstados()
    }
    
    func isMapaUbicacion() -> Bool {
        return self._isMapaUbicacion
    }
    
    func setIsMapaUbicacion(_ estado : Bool) {
        self._isMapaUbicacion = estado
    }
    
    func getCurrentLocation() -> Ubicacion {
        return self._userLocation
    }
    
    func setUserLocation(_ ubicacion: Ubicacion) -> Void{
        self._userLocation = ubicacion
    }
    
    func getCurrentUser() -> Usuario{
        return self._usuario
    }
    
    func getListaVehiculoEstacionados(){
        self._vehiculoService.getListaVehiculoEstacionados()
    }
    
    func getListaVehiculoTodos() -> Void
    {
        self._vehiculoService.getListaVehiculoTodos()
    }
    
    func getEventos(_ patente_id: String, gps_id: String){
        self._eventoService.getEventos(patente_id, gps_id: gps_id)
    }
    
    func actualizarControlVelocidad(_ gps_id : String, patente_id :String, estado_id : String, velocidad_id :String, accion_id: String) -> Void{
        self._vehiculoService.actualizarControlVelocidad(gps_id , patente_id :patente_id, estado_id : estado_id, velocidad_id:velocidad_id, accion_id: accion_id)
    }
    
    func alarmaSOS(_ latitud: Double, longitud: Double)-> Void {
        let _lat = String(format:"%f", latitud)
        let _lon = String(format:"%f", longitud)
        self._vehiculoService.AlarmaSOS(_lat, longitud: _lon)
    }
    
    func contadorVehiculo() -> Void
    {
        self._vehiculoService.ContadorVehiculo()
    }
    
    func listaControlVelocidad() -> Void{
        self._vehiculoService.listaControlVelocidad()
    }
    
    
    func ModoEstacionadoVehiculo(_ gps_id: String, patente_id :String, estado_id: String, cortacont: String, genAlert: Bool) -> Void
    {
        self._vehiculoService.ModoEstacionadoVehiculo(gps_id, patente_id :patente_id, estado_id: estado_id, device_token: self._deviceToken, corta_corr: cortacont, genAlert: genAlert)
    }
    
    func logIn(_ ilogin:String, ipassword:String, recordar:Int) -> Void {
        self._loginService.login(ilogin, ipassword: ipassword, recordar: recordar)
    }
    
    func recuperarContraseña(_ ilogin:String) -> String {
        return self._loginService.recuperarContraseña(ilogin)
    }
    
    func setUsuario(_ usuario: Usuario!){
        self._usuario = usuario
    }
    
    func actualizarModoEstacionadoVehiculo(_ gps_id: String, patente_id :String, estado_id: String, cortacont: String, genAlert: Bool) -> Void{
        self._vehiculoService.ModoEstacionadoVehiculo(gps_id, patente_id: patente_id, estado_id: estado_id, device_token: self._deviceToken, corta_corr: cortacont, genAlert: genAlert)
    }
    
    func isSuperUser() -> Bool
    {
        return (self.getCurrentUser().tipo == 1) ? true : false;
    }
    
    func getUltimoEstado(_ gps_id: String, patente_id : String)-> Void {
        self._vehiculoService.getUltimoEstado(gps_id, patente_id: patente_id)
    }
    
    func getUltimaUbicacion(_ gps_id: String, patente_id: String)-> Void {
        self._ubicacionService.UltimaUbicacion(gps_id, patente_id: patente_id, ilogin: self.getCurrentUser().ilogin, ipassword: self.getCurrentUser().ipassword)
    }
    
    func getListaUsuarios()-> Void
    {
        self._usuarioService.getListaUsuarios()
    }
    
    func AsignaVehiculosPorUsuario(_ user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    {
        self._usuarioService.AsignaVehiculosPorUsuario(user_id, gps_id: gps_id, patente_id: patente_id, estado_id: estado_id, accion_id: accion_id)
    }
    
    func ActualizarAsignaVehiculosPorUsuario(_ user_id: String, gps_id: String, patente_id: String, estado_id: String, accion_id: String) -> Void
    {
        self._usuarioService.ActualizarAsignaVehiculosPorUsuario(user_id, gps_id: gps_id, patente_id: patente_id, estado_id: estado_id, accion_id: accion_id)
    }
    
    func InsertaUsuario(_ usuario_id: String, nombre_id: String, password_id: String, mail_id: String, numero_id: String, tipo_id: String)
    {
        self._usuarioService.InsertaUsuario(usuario_id, nombre_id: nombre_id, password_id: password_id, mail_id: mail_id, numero_id: numero_id, tipo_id: tipo_id)
    }
    
    func InsertaDeviceToken(_ device_id: Data) -> Void
    {

        var tokenLimpio = NSString(format: "%@", device_id as CVarArg)
        tokenLimpio = tokenLimpio.replacingOccurrences(of: " ", with: "") as NSString
        tokenLimpio = tokenLimpio.replacingOccurrences(of: ">", with: "") as NSString
        tokenLimpio = tokenLimpio.replacingOccurrences(of: "<", with: "") as NSString

        self._deviceToken = tokenLimpio as String
        self._usuarioService.InsertaDeviceToken(self._deviceToken)
    }
    
    func InsertaDToken(_ token :String) -> Void {
        self._usuarioService.InsertaDeviceToken(token)
    }
    
    func NombrePorPatente(_ gps_id: String, patente_id: String, nombre_id: String, accion_id: String) -> Void
    {
        self._usuarioService.NombrePorPatente(gps_id, patente_id: patente_id, nombre_id: nombre_id, accion_id: accion_id)
    }
    
    func ActualizarNombrePorPatente(_ gps_id: String, patente_id: String, nombre_id: String) -> Void
    {
        self._usuarioService.ActualizarNombrePorPatente(gps_id, patente_id: patente_id, nombre_id: nombre_id)
    }
    
    func DatosPorFlota() -> Void{
        self._ubicacionService.DatosPorFlota()
    }
    
    func ActualizarNotificaciones(_ accion_id: String, estado_id: String, notificacion_id: String) -> Void
    {
        self._usuarioService.ActualizarNotificaciones(accion_id, estado_id: estado_id, notificacion_id: notificacion_id)
    }
    
    func SalirApp() -> Void {
        self._usuario.recordar = 0
        
        let encodedIlogin = NSKeyedArchiver.archivedData(withRootObject: LibraryAPI.sharedInstance.getCurrentUser().ilogin)
        let encodedIpassword = NSKeyedArchiver.archivedData(withRootObject: LibraryAPI.sharedInstance.getCurrentUser().ipassword)
        let encodedTipo = NSKeyedArchiver.archivedData(withRootObject: LibraryAPI.sharedInstance.getCurrentUser().tipo)
        let encodedRecordar = NSKeyedArchiver.archivedData(withRootObject: LibraryAPI.sharedInstance.getCurrentUser().recordar)
        
        let encodedUsuario: [Data] = [encodedIlogin, encodedIpassword, encodedTipo, encodedRecordar]
        
        UserDefaults.standard.set(encodedUsuario, forKey: "usuario")
        UserDefaults.standard.synchronize()
    }
    
    func ContactoList(_ contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void
    {
        self._usuarioService.ContactoList(contenido_id, nombre_id: nombre_id, telefono_id: telefono_id, mail_id: mail_id, accion_id: accion_id)
    }
    
    func ContactoActualizar(_ contenido_id: String, nombre_id: String, telefono_id: String, mail_id: String, accion_id: String) -> Void
    {
        self._usuarioService.ContactoActualizar(contenido_id, nombre_id: nombre_id, telefono_id: telefono_id, mail_id: mail_id, accion_id: accion_id)
    }
    
    func InsertarUsuarioDemo(_ email: String, ilogin: String, ipassword: String, nombre: String,
        apellido: String, rut: String, fono: String){
            self._usuarioService.InsertarUsuarioDemo(email, ilogin: ilogin, ipassword: ipassword, nombre: nombre, apellido: apellido, rut: rut, fono: fono)
    }
    
    func SolicitarEjecutivo(_ ilogin: String, ipassword: String){
        self._usuarioService.SolicitarEjecutivo(ilogin, ipassword: ipassword)
    }
}
