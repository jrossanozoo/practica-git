define class Generador as zoosession of zoosession.prg

	#IF .f.
		Local this as Generador of Generador.prg
	#ENDIF

	cArchivo = ""
	nArchivo = 0
	cTipo = ""
	cPath = ""

	cPrefijo = ""
	cSufijo = ""
	cExtension = "prg"
	
	cBuffer = ""
	oControladorDeTablasAbiertas = null

	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		dodefault()
	
		if type( "_screen.zoo.cRutaInicial" ) = "C"
			if empty( tcRuta )
				this.cPath = addbs( _screen.zoo.cRutaInicial ) + this.cPath
			else
				this.cPath = addbs( tcRuta ) + this.cPath
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVersion( tcEntidad as String ) as integer
		return 2
	endfunc

	*-----------------------------------------------------------------------------------------
	function Generar( tcTipo as String ) as Void
		local loError as Exception, loEx as Exception		

		with this
			.cTipo = Upper( alltrim( tcTipo ) )
			
			.ValidarPath()
			.SetearNombreArchivo()					
			.oControladorDeTablasAbiertas = newobject( "ControlarTablasAbiertas", "ControlarTablasAbiertas.prg" )
			.oControladorDeTablasAbiertas.IniciaControl( this )	
			.AntesDeGenerarCodigo() 

			Try
				.EstadoInicial()
				.GenerarCodigo() 
				.Compilar()
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.ReestablecerEstadoInicial()
				.oControladorDeTablasAbiertas.FinalizaControl()
				.oControladorDeTablasAbiertas = null
			EndTry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarPath() as Void
		local loError as Exception, lcPath as String

		lcPath = this.cPath
		if directory( lcPath )
		else
			mkdir &lcPath
		endif
		if directory( lcPath )
		else
			loError = createobject("Exception")
			loError.UserValue ="No se puede generar el " + .cTipo + " (El directorio de origen no existe)"
			loError.Procedure = this.class
			throw loError
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		with this
			.cArchivo = .cPath + "Din_" + alltrim( proper( .cPrefijo  ) ) + ;
					alltrim( Proper( .cTipo ) ) + ;
					alltrim( proper( .cSufijo ) ) + "." + this.cExtension
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AntesDeGenerarCodigo() as Void
		local lcArchivo as String, loError as exception


		lcArchivo = strtran( this.cArchivo, "." + this.cExtension , "" ) + "." + this.cExtension
		if file( lcarchivo )
			try
				delete file &lcArchivo
			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCodigo() as Void
		with this
			
			try
				.GenerarArchivo()
				.GenerarCabeceraClase()
				.GenerarCuerpoClase()
				.GenerarPieClase()
				.GenerarCodigoAuxiliar()
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally	
				.CerrarArchivo()
			endtry

		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivo() as Void
		this.nArchivo = fcreate( this.cArchivo )
		this.cBuffer = ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarArchivo() as Void
*		this.nArchivo = fcreate( this.cArchivo )
		= fwrite( this.nArchivo, this.cBuffer )
		= fclose( this.nArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		local lcClase as String
		
		lcClase = this.ObtenerHerencia()
		
		this.AgregarLinea( "define class Din_" + alltrim( proper( this.cPrefijo  ) ) + ;
					alltrim( Proper( this.cTipo ) ) + ;
					alltrim( proper( this.cSufijo ) ) + " as " + lcClase + " of " + lcClase + ".prg" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerencia() as Void
		return "ZooSession"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarPieClase() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "enddefine" )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarLinea( tcTexto, tnTabs ) as Void
		local lcEnter as string, tcTabs as string

		if pcount() = 2 and tnTabs > 0
			tcTabs = replicate( chr(9), tnTabs )
		else
			tcTabs = ""
		endif
		
		lcEnter = chr(13) + chr(10)

		this.cBuffer = this.cBuffer + lcEnter + tcTabs + tcTexto

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValorVacioSegunTipo( tcTipo as string ) as Void
		local  lxRetorno
		do case
			case tcTipo = "C"
				lxRetorno = ""
			case tcTipo = "N"
				lxRetorno = 0
			case tcTipo = "L"
				lxRetorno = .f.
			case tcTipo = "D"
				lxRetorno = ctod( "" )
			otherwise
				lxRetorno = ""
		endcase
		return 	lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Compilar() as Void
		local loError as Exception, loEx as Exception, lcArchivo as String, lcArchivoTmp as String

		Try
			lcArchivo = forceext( this.cArchivo, "prg" )
			if ( "\" $ lcArchivo )
			else
				lcArchivo = addbs( this.cPath ) + lcArchivo 
			endif
			lcArchivoTmp = forceext( lcArchivo, "err" )
			if file( lcArchivoTmp )
				delete file &lcArchivoTmp
			endif
			try
				lcArchivoTmp = forceext( lcArchivo, "fxp" )
				if file( lcArchivoTmp )
					delete file &lcArchivoTmp
				endif
			
				compile &lcArchivo
			catch To loError
				this.EventoMensajeProceso( "El archivo " + upper( lcArchivo ) + " se encuentra en memoria y no puede ser compilado." )
			endtry
			
			lcArchivoTmp = forceext( lcArchivo, "err" )
			if file( lcArchivoTmp )
				This.LimpiarInformacion()
				This.Agregarinformacion( "La compilación del archivo " + upper( lcArchivo ) + " ha dado error." )
				goServicios.Errores.LevantarExcepcion( This.Obtenerinformacion() )
			endif
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeProceso( tcMensaje as String ) as Void
		** Este método es para levantar un evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarNombreDeAplicacion() as String 
		*!*	Levanto datos de APLICACION.INI
		local loIni as object, lcIniValor as string, lcSeccion as string, ;
			lcOpcion as string, lcArchivo as string, lnRetorno as integer,;
			lcRetorno as String 

		loIni = newobject( "OldIniReg", "registry.vcx" )
		store "" to lcIniValor, lcSeccion, lcOpcion, lcArchivo
		store 0 to lnRetorno
		lcSeccion = "SETEOSAPLICACION"
		lcOpcion = "NombreAplicacion"
		lcArchivo = addbs( _screen.zoo.crutainicial ) + 'aplicacion.ini'
		lnRetorno = loIni.GetIniEntry( @lcIniValor, lcSeccion, lcOpcion, lcArchivo )

		if lnRetorno = 0 and empty( lcIniValor )
			if upper( right( sys(16), 3) ) == "FXP"
				lcRetorno = strtran( substr( curdir(), rat( "\", curdir(),2 ) + 1 ), "\", "" )
			else
				lcRetorno = juststem( sys( 16,0 ) )	
			endif 
		else
			lcRetorno = alltrim( lcIniValor )
		endif
		
		loIni = null
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function GenerarCodigoAuxiliar() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXml( tcTabla as String ) as String
		return this.cursoraxml( tcTabla )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXmlSentencia( tcSentencia as String, tcNombreCursor as String ) as String
		local lcXml as String
		
		&tcSentencia
		
		lcXml = this.cursoraxml( tcNombreCursor )
		use in select( tcNombreCursor )
		
		return lcXml
	endfunc 

enddefine
