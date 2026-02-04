Define Class procesodinamico as zoosession of zoosession.prg

#DEFINE  MODOFORMULARIO "AVANZADO"
#DEFINE  ESTILOFORMULARIO 2

	protected cNumeroDeVersion
	datasession = 1

	cPath = ""
	lGenerarReservados = .f.
	oGenLogueos = null
	oGenLogueosXml = null
	oGenLogueosXmlSqlServer = null
	oGenLogueosXmlV2 = null
	oGenLogueosXmlSqlServerV2 = null
	oGenMockEntidad = null
	oGenMock = null
	oGenMockDin = null
	oGenEntidad = null
	oGeneraAdSql = null
	oGenDetalle = null
	oGenItem = null
	oGenEstilos = null
	oGenFormSinEntidad = null
	oGenFormEntidad = null
	oGenMenuEntidades = null
	oGenFormSubEnt = null
	oGenCompFiscal = null
	oGenKontroler = null
	oGenFormTransferencia = null
	oGenObjTransferencia = null
	oGenObjTransferenciaAgrupadas = null
	oGenObjTransferenciaAdicionales = null
	oGenConsultaTransferencias = null
	oGenFormDuro = null
	oGenFormExportacion = null
	oGenFormExportacionAgrupada = null	
	oGenObjExportacion = null
	oGenObjExportacionAgrupada = null	
	oGenConsultaExportacion = null
	oGenConsultaExportacionSQLServer = null
	oGenBuscadorOB = null
	oGenBuscadorAD = null
	oGenFormImportacion = null
	oGenFormImportacionAgrupada = null
	oGenComponente = null
	cNumeroDeVersion = ""
	oProcesoDinamicoListados = null
	lEnviarEnviarMensaje = .t.
	oGenOperacionesREST = null
	oGenEjectutorREST = null
	oLibControles = null
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		with this
			if dbused('metadata')
				set database to metadata
				close databases
			endif

			.lDestroy = .t.
			* LogueosV2
			.oGenLogueos  = null
			.oGenLogueosXml = null
			.oGenLogueosXmlSqlServer = null
			.oGenLogueosXmlV2 = null
			.oGenLogueosXmlSqlServerV2 = null
			.oGenMockEntidad = null
			.oGenMock = null
			.oGenMockDin = null
			.oGenEntidad = null
			.oGeneraAdSql = null
			.oGenDetalle = null
			.oGenItem = null
			.oGenCompFiscal = null

			if type( ".oGenKontroler" ) = "O" and !isnull( .oGenKontroler )
				unbindevent( .oGenKontroler, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			.oGenKontroler = null
			.oGenFormTransferencia = null
			.oGenObjTransferencia = null
			.oGenObjTransferenciaAgrupadas = null
			.oGenObjTransferenciaAdicionales = null
			.oGenConsultaTransferencias = null
			.oGenFormExportacion = null
			.oGenFormExportacionAgrupada = null
			.oGenObjExportacion = null
			.oGenObjExportacionAgrupada = null			
			.oGenConsultaExportacion = null
			.oGenConsultaExportacionSQLServer = null
			.oGenFormImportacion = null
			.oGenFormImportacionAgrupada = null
			.oGenComponente = null
			.oLibControles = null

			if type( ".oGenFormDuro" ) = "O" and !isnull( .oGenFormDuro )
				unbindevent( .oGenFormDuro , "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif	
			.oGenFormDuro = null

			if type( ".oGenFormSinEntidad" ) = "O" and !isnull( .oGenFormSinEntidad )
				unbindevent( .oGenFormSinEntidad, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			.oGenFormSinEntidad = null

			if type( ".oGenFormEntidad" ) = "O" and !isnull( .oGenFormEntidad )
				unbindevent( .oGenFormEntidad, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			.oGenFormEntidad = null

			.oGenMenuEntidades = null
			
			if type( ".oGenFormSubEnt" ) = "O" and !isnull( .oGenFormSubEnt )
				unbindevent( .oGenFormSubEnt, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			.oGenFormSubEnt = null

			if type( ".oEstilos" ) = "O" and !isnull( .oEstilos )
				unbindevent( .oGenEstilos, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			.oGenEstilos = null

			if type( ".oProcesoDinamicoListados" ) = "O" and !isnull( .oProcesoDinamicoListados )
				unbindevent( .oProcesoDinamicoListados, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			endif
			
		endwith
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oProcesoDinamicoListados_Access() as Void
		if !this.ldestroy and !vartype( this.oProcesoDinamicoListados ) = 'O'
			this.oProcesoDinamicoListados = _Screen.zoo.crearobjeto( "ProcesoDinamicoListados" )
			bindevent( this.oProcesoDinamicoListados, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oProcesoDinamicoListados
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGenLogueos_Access() as Void
		if !this.ldestroy and !vartype( this.oGenLogueos ) = 'O'
			this.oGenLogueos = _Screen.zoo.crearobjeto( 'GeneradorDinamicoLogueos', "", this.cPath )
		endif
		return this.oGenLogueos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenOperacionesREST_Access() as Void
		if !this.ldestroy and !vartype( this.oGenOperacionesREST ) = 'O'
			this.oGenOperacionesREST = _Screen.zoo.crearobjeto( 'generadordinamicoServicioRestOperaciones', "generadordinamicoServicioRestOperaciones.prg", this.cPath )
		endif
		return this.oGenOperacionesREST
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenEjectutorREST_Access() as Void
		if !this.ldestroy and !vartype( this.oGenEjectutorREST ) = 'O'
			this.oGenEjectutorREST = _Screen.zoo.crearobjeto( "GeneradorDinamicoEjecutorServicioRest", "GeneradorDinamicoEjecutorServicioRest.prg", this.cPath ) 
		endif
		return this.oGenEjectutorREST 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenLogueosXml_Access() as Void
		if !this.ldestroy and !vartype( this.oGenLogueosXml ) = 'O'
			this.oGenLogueosXml = _Screen.zoo.crearobjeto( 'GeneradorXmlLogueos', "", this.cPath )
		endif
		return this.oGenLogueosXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenLogueosXmlSqlServer_Access() as Void
		if !this.ldestroy and !vartype( this.oGenLogueosXmlSqlServer ) = 'O'
			this.oGenLogueosXmlSqlServer = _Screen.zoo.crearobjeto( 'GeneradorXmlLogueosSqlServer', "", this.cPath )
		endif
		return this.oGenLogueosXmlSqlServer
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenLogueosXmlV2_Access() as Void
		if !this.ldestroy and !vartype( this.oGenLogueosXmlV2 ) = 'O'
			this.oGenLogueosXmlV2 = _Screen.zoo.crearobjeto( 'GeneradorXmlLogueosV2', "", this.cPath )
		endif
		return this.oGenLogueosXmlV2
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenLogueosXmlSqlServerV2_Access() as Void
		if !this.ldestroy and !vartype( this.oGenLogueosXmlSqlServerV2 ) = 'O'
			this.oGenLogueosXmlSqlServerV2 = _Screen.zoo.crearobjeto( 'GeneradorXmlLogueosSqlServerV2', "", this.cPath )
		endif
		return this.oGenLogueosXmlSqlServerV2
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGenMockEntidad_Access() as Void
		if !this.ldestroy and !vartype( this.oGenMockEntidad ) = 'O'
			this.oGenMockEntidad = _Screen.zoo.crearobjeto( 'GeneradorDinamicoMocksEntidad', "", this.cPath )
		endif
		return this.oGenMockEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenMock_Access() as Void
		if !this.ldestroy and !vartype( this.oGenMock ) = 'O'
			this.oGenMock = _Screen.zoo.crearobjeto( 'GeneradorDinamicoMocks', "", this.cPath )
		endif
		return this.oGenMock
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenMockDin_Access() as Void
		if !this.ldestroy and !vartype( this.oGenMockDin ) = 'O'
			this.oGenMockDin = _Screen.zoo.crearobjeto( 'generadordinamicomocksDin', "", this.cPath )
		endif
		return this.oGenMockDin
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenEntidad_Access() as Void
		if !this.ldestroy and !vartype( this.oGenEntidad ) = 'O'
			this.oGenEntidad = _Screen.zoo.crearobjeto( 'GeneradorDinamicoEntidad', "", this.cPath )
		endif
		return this.oGenEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGeneraAdSql_Access() as Void
		if !this.ldestroy and !vartype( this.oGeneraAdSql ) = 'O'
			this.oGeneraAdSql = _Screen.zoo.crearobjeto( 'GeneradorDinamicoAccesoDatosSqlServer', "", this.cPath )
		endif
		return this.oGeneraAdSql
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenDetalle_Access() as Void
		if !this.ldestroy and !vartype( this.oGenDetalle ) = 'O'
			this.oGenDetalle = _Screen.zoo.crearobjeto( 'GeneradorDinamicoDetalle', "", this.cPath )
		endif
		return this.oGenDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenItem_Access() as Void
		if !this.ldestroy and !vartype( this.oGenItem ) = 'O'
			this.oGenItem = _Screen.zoo.crearobjeto( 'GeneradorDinamicoItem', "", this.cPath )
		endif
		return this.oGenItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenEstilos_Access() as Void
		if !this.ldestroy and !vartype( this.oGenEstilos ) = 'O'
			this.oGenEstilos = _Screen.zoo.crearobjeto( 'GeneradorDinamicoEstilos', "", this.cPath )
			bindevent( this.oGenEstilos, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenEstilos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormSinEntidad_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormSinEntidad ) = 'O'
			this.oGenFormSinEntidad = _Screen.zoo.crearobjeto( 'generadorFormulariosSinEntidad', "", this.cPath )
			bindevent( this.oGenFormSinEntidad, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenFormSinEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormEntidad_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormEntidad ) = 'O'
			this.oGenFormEntidad = _Screen.zoo.crearobjeto( 'generadorFormulariosEntidades', "", this.cPath )
			bindevent( this.oGenFormEntidad, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenFormEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenMenuEntidades_Access() as Void
		if !this.ldestroy and !vartype( this.oGenMenuEntidades ) = 'O'
			this.oGenMenuEntidades = _Screen.zoo.crearobjeto( 'GeneradorDinamicoMenuAltas', "", this.cPath )
		endif
		return this.oGenMenuEntidades
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormSubEnt_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormSubEnt ) = 'O'
			this.oGenFormSubEnt = _Screen.zoo.crearobjeto( 'GeneradorFormulariosSubEntidad', "", this.cPath )
			bindevent( this.oGenFormSubEnt, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenFormSubEnt
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGenComponente_Access() as Void
		if !this.ldestroy and !vartype( this.oGenComponente ) = 'O'
			this.oGenComponente = _Screen.zoo.crearobjeto( 'generadordinamicocomponente', "", this.cPath )
		endif
		return this.oGenComponente
	endfunc  

	*-----------------------------------------------------------------------------------------
	function oGenKontroler_Access() as Void
		if !this.ldestroy and !vartype( this.oGenKontroler ) = 'O'
			this.oGenKontroler = _Screen.zoo.crearobjeto( 'generadordinamicokontroler', "", this.cPath )
			bindevent( this.oGenKontroler, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenKontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormTransferencia_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormTransferencia ) = 'O'
			this.oGenFormTransferencia = _Screen.zoo.crearobjeto( 'GeneradorFormulariosTransferencias', "", this.cPath )
		endif
		return this.oGenFormTransferencia
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGenFormExportacion_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormExportacion ) = 'O'
			this.oGenFormExportacion = _Screen.zoo.crearobjeto( 'GeneradorFormulariosExportaciones', "", this.cPath )
		endif
		return this.oGenFormExportacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormImportacion_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormImportacion ) = 'O'
			this.oGenFormImportacion = _Screen.zoo.crearobjeto( 'GeneradorFormulariosImportaciones', "", this.cPath )
		endif
		return this.oGenFormImportacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormImportacionAgrupada_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormImportacionAgrupada ) = 'O'
			this.oGenFormImportacionAgrupada = _Screen.zoo.crearobjeto( 'GeneradorFormulariosImportacionesAgrupada', "", this.cPath )
		endif
		return this.oGenFormImportacionAgrupada
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenFormExportacionAgrupada_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormExportacionAgrupada ) = 'O'
			this.oGenFormExportacionAgrupada = _Screen.zoo.crearobjeto( 'GeneradorFormulariosExportacionesAgrupada', "", this.cPath )
		endif
		return this.oGenFormExportacionAgrupada 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenObjTransferencia_Access() as Void
		if !this.ldestroy and !vartype( this.oGenObjTransferencia ) = 'O'
			this.oGenObjTransferencia = _Screen.zoo.crearobjeto( 'GeneradorDinamicoObjetoTransferencia', "", this.cPath )
			this.oGenObjTransferencia.SetearNumeroDeVersion( this.cNumeroDeVersion )
		endif
		return this.oGenObjTransferencia
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oGenObjTransferenciaAdicionales_Access() as Void
		if !this.ldestroy and !vartype( this.oGenObjTransferenciaAdicionales ) = 'O'
			this.oGenObjTransferenciaAdicionales = _Screen.zoo.crearobjeto( 'GeneradorDinamicoObjetoTransferenciaAdicionales', "", this.cPath )
			this.oGenObjTransferenciaAdicionales.SetearNumeroDeVersion( this.cNumeroDeVersion )
		endif
		return this.oGenObjTransferenciaAdicionales
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function oGenObjExportacion_Access() as Void
		if !this.ldestroy and !vartype( this.oGenObjExportacion ) = 'O'
			this.oGenObjExportacion = _Screen.zoo.crearobjeto( 'GeneradorDinamicoObjetoExportacion', "", this.cPath )
		endif
		return this.oGenObjExportacion
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	function oGenObjExportacionAgrupada_Access() as Void
		if !this.ldestroy and !vartype( this.oGenObjExportacionAgrupada ) = 'O'
			this.oGenObjExportacionAgrupada = _Screen.zoo.crearobjeto( 'GeneradorDinamicoObjetoExportacionAgrupada', "", this.cPath )
		endif
		return this.oGenObjExportacionAgrupada
	endfunc  

	*-----------------------------------------------------------------------------------------
	function oGenObjTransferenciaAgrupadas_Access() as Void
		if !this.ldestroy and !vartype( this.oGenObjTransferenciaAgrupadas ) = 'O'
			this.oGenObjTransferenciaAgrupadas = _Screen.zoo.crearobjeto( 'GeneradorDinamicoObjetoTransferenciaAgrupada', "", this.cPath )
		endif
		return this.oGenObjTransferenciaAgrupadas
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenConsultaTransferencias_Access() as Void
		if !this.ldestroy and !vartype( this.oGenConsultaTransferencias ) = 'O'
			this.oGenConsultaTransferencias = _Screen.zoo.crearobjeto( 'GeneradorConsultasTransferencias', "", this.cPath )
		endif
		return this.oGenConsultaTransferencias
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oGenConsultaExportacion_Access() as Void
		if !this.ldestroy and !vartype( this.oGenConsultaExportacion ) = 'O'
			this.oGenConsultaExportacion = _Screen.zoo.crearobjeto( 'GeneradorConsultasExportaciones', "", this.cPath )
		endif
		return this.oGenConsultaExportacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function oGenConsultaExportacionSQLServer_Access() as Void
		if !this.ldestroy and !vartype( this.oGenConsultaExportacionSQLServer ) = 'O'
			this.oGenConsultaExportacionSQLServer = _Screen.zoo.crearobjeto( 'GeneradorConsultasExportacionesSQLServer', "", this.cPath )
		endif
		return this.oGenConsultaExportacionSQLServer
	endfunc

	*-----------------------------------------------------------------------------------------
	function oGenFormDuro_Access() as Void
		if !this.ldestroy and !vartype( this.oGenFormDuro ) = 'O'
			this.oGenFormDuro = _Screen.zoo.crearobjeto( 'GeneradorFormulariosDuros', "", this.cPath )
			bindevent( this.oGenFormDuro, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenFormDuro
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenBuscadorOB_Access() as Void
		if !this.ldestroy and !vartype( this.oGenBuscadorOB ) = 'O'
			this.oGenBuscadorOB = _Screen.zoo.crearobjeto( 'GeneradorDinamicoBuscadorOB', "", this.cPath )
			bindevent( this.oGenBuscadorOB, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenBuscadorOB
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oGenBuscadorAD_Access() as Void
		if !this.ldestroy and !vartype( this.oGenBuscadorAD ) = 'O'
			this.oGenBuscadorAD = _Screen.zoo.crearobjeto( 'GeneradorDinamicoBuscadorAD', "", this.cPath )
			bindevent( this.oGenBuscadorAD, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
		endif
		return this.oGenBuscadorAD
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ControlarError( toError as Exception, tcMensaje as String ) as void
		local loEx as Exception 

		if type( "_Screen.zoo.EsBuildAutomatico" ) == "L" and _Screen.zoo.EsBuildAutomatico 
			if !isnull( toError ) and pemstatus( toError, "grabar", 5  )
				try
					toError.Grabar()
				catch 
				endtry
			endif
			this.EnviarMensajeProceso( tcMensaje + chr( 13 ) + this.DesglosarError( toError )  )
		else
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				if !isnull( tcMensaje ) and vartype( toError ) == "C"
					if "(ROJO)" $ tcMensaje
						.AgregarInformacion( tcMensaje )
					else
						.AgregarInformacion( tcMensaje + " (ROJO)." )
					endif
				endif	
				
				.Grabar( toError )
				.Throw()
			endwith
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarParametros( tcTipo as string, tcXmlParametros as String, tcXmlJerarquias as string, tnProyecto as integer ) as Void
		local loError as exception, loGenerador as GeneradorDinamicoParametros of GeneradorDinamicoParametros.prg
		
		try 
			this.EnviarMensajeProceso( "Generando " + tcTipo )
			loGenerador = _Screen.zoo.crearobjeto( 'GeneradorDinamicoParametros', "", this.cPath )
			loGenerador.generar( tcTipo, tcXmlParametros, tcXmlJerarquias, tnProyecto )
		catch to loError
			this.ControlarError( loError, "Error al generar los parametros" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarMocksParametros( tcTipo as string, tcXmlParametros as String, tcXmlJerarquias as string, tnProyecto as integer ) as Void
		local loError as exception, loGenerador as GeneradorDinamicoMocksParametros of GeneradorDinamicoMocksParametros.prg
		
		try 
			this.EnviarMensajeProceso( "Generando Mocks " + tcTipo )
			loGenerador  = _Screen.zoo.crearobjeto( 'GeneradorDinamicoMocksParametros', "", this.cPath )
			loGenerador.Generar( tcTipo, tcXmlParametros, tcXmlJerarquias, tnProyecto )
		catch to loError
			this.ControlarError( loError, "Error al generar los parametros" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarColeccionLogueos( tcXmlLoggers as String, tcXmlAppenders as String, tcXmlTipoAppenders as String ) as Void
		local loError as exception, lcError as String
		
		try 
			this.EnviarMensajeProceso( "Generando Logueos" )
			lcError = "Coleccion"

			with this.oGenLogueos 
				.cXmlLoggers = tcXmlLoggers 
				.cXmlAppenders = tcXmlAppenders
				.cXmlTipoAppenders = tcXmlTipoAppenders
				.generar( "Logueos" )
			endwith
			
			lcError = "XML"
	
			with this.oGenLogueosXml
				.cXmlLoggers = tcXmlLoggers 
				.cXmlAppenders = tcXmlAppenders
				.cXmlTipoAppenders = tcXmlTipoAppenders
				.generar( "Logueos" )
			endwith

			with this.oGenLogueosXmlV2
				.cXmlLoggers = tcXmlLoggers 
				.generar( "Loggers" )
			endwith

			lcError = "XML-SqlServer"
	
			with this.oGenLogueosXmlSqlServer
				.cXmlLoggers = tcXmlLoggers 
				.cXmlAppenders = tcXmlAppenders
				.cXmlTipoAppenders = tcXmlTipoAppenders
				.generar( "LogueosSqlServer" )
			endwith
			
			with this.oGenLogueosXmlSqlServerV2
				.cXmlLoggers = tcXmlLoggers 
				.generar( "LoggersSqlServer" )
			endwith

		catch to loError
			this.ControlarError( loError, "Error al generar Logueos (" + lcError + ")" )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarMocksEntidad( tcEntidad as String ) as Void
		this.GenerarMockEspecifico( alltrim( tcEntidad ), 0 )
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function GenerarMocksProyecto( tcEntidad as String ) as Void
		local loError, lcNombre, lcPathAnt

		if pcount() < 1
			tcEntidad = ""
		endif
		
		lcPathAnt = set("Path")

		this.AbrirTabla( "ClasesMock" )

		select c_ClasesMock
		scan
			lcNombre = alltrim( c_ClasesMock.entidad )

			try
				this.EnviarMensajeProceso( "Generando Mock " + alltrim( lcNombre ) )
				this.oGenMock.generar( lcNombre )
			catch to loError
				this.ControlarError( loError, "Error al generar el Mock ClasesMock " + lcNombre )
			endtry
		endscan

		this.CerrarTabla( "c_ClasesMock" )
		set path to &lcPathAnt
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarMockEspecifico( tcEntidad as String, tnVersion as integer ) as Void
		local loGeneraMock as object, loError as exception, loEx  as Exception 
		try 
			this.EnviarMensajeProceso( "Generando Mock " + alltrim( tcEntidad ) )
			if lower( left( tcEntidad, 4 ) ) == "din_"
				this.oGenMockDin.generar( tcEntidad )
			else
				this.oGenMockEntidad.generar( tcEntidad )
			endif
		catch to loError
			this.ControlarError( loError, "Error al generar el Mock entidad " + alltrim( tcEntidad ) )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Generar( tcElemento as String ) as boolean
		local loError as exception, llRetorno as boolean, lcValorAnt as string, lcNombreADT as string

		llRetorno  = .t.
		lcValorAnt = this.oGenEntidad.cClaseBase

		try 
			this.EnviarMensajeProceso( "Generando Entidad " + alltrim( tcElemento ) )
			this.oGenEntidad.generar( tcElemento )

			this.EnviarMensajeProceso( "Generando Entidad " + alltrim( tcElemento ) + " (Acceso datos SqlServer)" )
			this.oGeneraAdSql.generar( tcElemento )
			
			this.EnviarMensajeProceso( "Generando Entidad " + alltrim( tcElemento ) + " (Operaciones REST)" )
			this.oGenOperacionesREST.Generar( tcElemento )

			this.GenerarDetalles( tcElemento )
		catch to loError
			llRetorno = .f.
			this.ControlarError( loError, "Error al generar la entidad " + alltrim( tcElemento ) )
		finally
			this.oGenEntidad.cClaseBase = lcValorAnt 
		endtry
		
		return llRetorno 
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function GenerarDetalles( tcEntidad as String ) as VOID
		local  loErrorTest as Exception, loDetalles as object, loItem as object

		with this
			try
				loDetalles = this.oGenEntidad.ObtenerInfoDetalles()
				for each loItem in loDetalles

					this.EnviarMensajeProceso( "Generando Entidad " + alltrim( tcEntidad ) + " (Detalle " + loItem.Atributo + ")" )

					.oGenDetalle.Generar( tcEntidad, alltrim( loItem.Atributo ), alltrim( loItem.Tipo ), alltrim( loItem.Dominio ), alltrim( loItem.Tags ) )

					this.EnviarMensajeProceso( "Generando Entidad " + alltrim( tcEntidad ) + " (Item " + loItem.Atributo + ")" )
					.oGenItem.Generar( tcEntidad, alltrim( loItem.Atributo ), alltrim( loItem.Tipo ), alltrim( loItem.Dominio ), loItem.GenHabilitar )
				endfor
			catch to loErrorTest
				throw loErrorTest
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarEstilos() as Boolean
		local lnIndE as integer, llRetorno as Boolean, loError as Exception
        llRetorno = .T.

		for lnIndE = 1 to 2
			this.EnviarMensajeProceso( "Generando Estilo " + alltrim( str( lnIndE ) ) )
			this.oGenEstilos.nEstilo = lnIndE
			try
				this.oGenEstilos.Generar( "Estilo" + alltrim( str( lnIndE ) ) )
			catch to loError
				llRetorno = .f.
				this.ControlarError( loError, "Error al generar el Estilo: " + + alltrim( str( lnIndE ) ) )
			endtry
		endfor

        return llRetorno
    endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarFormularios( tcEntidad as String, tcModo as string, tnEstilo as integer, tlSinEntidad as Boolean ) as Boolean
		local llRetorno as Boolean, lcModo as String, lnEstilo as Integer
		
		llRetorno = .t.
		
		if pcount() < 3
			lnEstilo = iif(type('tnEstilo') = 'N',tnEstilo,ESTILOFORMULARIO)
		endif
		lcModo = MODOFORMULARIO

		llRetorno = this.GenerarFormularioEspecifico( tcEntidad, tcModo, tnEstilo, tlSinEntidad )

		return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarModo( tcModo as String ) as boolean
		local llRetorno as Boolean
		
		llRetorno = inlist( tcModo, "AVANZADO" )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarFormularioEspecifico( tcEntidad, tcModo, tnEstilo, tlSinEntidad ) as boolean
		local loGeneraFormulario as object, loError as object, llRetorno as boolean, lnEstilo as integer

		llRetorno = .t.
		this.EnviarMensajeProceso( "Generando Menu FRM " + alltrim( tcEntidad ))
		this.oGenMenuEntidades.generar( "menuabm" + proper( tcEntidad ) )

		if tlSinEntidad	
			loGeneraFormulario = this.oGenFormSinEntidad
			lcMensaje = "(S/Ent.) "
		else
			loGeneraFormulario = this.oGenFormEntidad
			lcMensaje = "(C/Ent.) "
		endif
		loGeneraFormulario.oLibControles = this.oLibControles

		lnEstilo = tnEstilo 
		try
			if lnEstilo > 0
				this.EnviarMensajeProceso( "Generando FRM " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim(str( lnEstilo ) ) )
				llRetorno = loGeneraFormulario.generar( tcEntidad, tcModo, lnEstilo )
			else
				lnEstilo = 2
				this.EnviarMensajeProceso( "Generando FRM " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim(str( lnEstilo ) ) )
				llRetorno = llRetorno and loGeneraFormulario.generar( tcEntidad, tcModo, lnEstilo )
			endif
		catch to loError
			llRetorno = .f.
			this.ControlarError( loError, "Error al generar la Formulario " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim(str( lnEstilo ) ) )
		finally 
			loGeneraFormulario = null
		endtry

		if !tlSinEntidad
			lnEstilo = tnEstilo 
			try
				if lnEstilo > 0
					this.EnviarMensajeProceso( "Generando FRM SubEntidad " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim( str( lnEstilo ) ) )
					llRetorno = llRetorno and this.oGenFormSubEnt.generar( tcEntidad, tcModo, lnEstilo )
				else
					lnEstilo = 2
					this.EnviarMensajeProceso( "Generando FRM SubEntidad " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim(str( lnEstilo ) ) )
					llRetorno = llRetorno and this.oGenFormSubEnt.generar( tcEntidad, tcModo, lnEstilo )
				endif
			catch to loError
				llRetorno = .f.
				this.ControlarError( loError, "Error al generar la Formulario SubEntidad " + lcMensaje + alltrim( tcEntidad ) + " Modo: " + tcModo + " Estilo: " + alltrim(str( lnEstilo ) ) )
			endtry
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarHerramientaStock() as Void
		local loGenerador as generadorconsultasherramientastock of generadorconsultasherramientastock.prg, loError as Exception
		
		Try
			this.EnviarMensajeProceso( "Generando Heramienta de Stock" )
			loGenerador = newobject( "generadorconsultasherramientastock", "generadorconsultasherramientastock.prg", "", this.cPath)
			loGenerador.Generar("AjusteDeStock")			
		Catch To loError
			this.ControlarError( loError, "Error al generar la Herramienta stock" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif		
		EndTry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarComponenteEnBaseA() as Void
		local loGenerador as generadordinamicocomponenteEnBaseA of generadordinamicocomponenteEnBaseA.prg, loError as Exception

		Try
			this.EnviarMensajeProceso( "Generando componente Nuevo En Base A" )
			loGenerador = newobject( "generadordinamicocomponenteEnBaseA", "generadordinamicocomponenteEnBaseA.prg", "", this.cPath)
			loGenerador.Generar()			
		Catch To loError
			this.ControlarError( loError, "Error al generar componente en Base A" )		
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif	
		EndTry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarMenuPrincipal() as Void
		local loGenerador as generadordinamicoMenuPrincipal of generadordinamicoMenuPrincipal.prg, loError as Exception

		Try
			this.EnviarMensajeProceso( "Generando Menú Principal dinámico" )
			loGenerador = newobject( "generadordinamicoMenuPrincipal", "generadordinamicoMenuPrincipal.prg", "", this.cPath )
			loGenerador.Generar("MenuPrincipal")			
		Catch To loError
			this.ControlarError( loError, "Error al generar el menu principal." )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		EndTry
		
		this.GenerarArbolDeModulos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarArbolDeModulos() as Void	
		local loGenerador as generadordinamicoArbolModulos of generadordinamicoArbolModulos.prg, loError as Exception

		try
			this.EnviarMensajeProceso("Generando Arbol de Módulos" )
			loGenerador = _screen.zoo.CrearObjeto( "generadordinamicoArbolModulos", "generadordinamicoArbolModulos.prg", this.cPath )
			loGenerador.Generar("ArbolDeModulos")			
		Catch To loError
			this.ControlarError( loError, "Error al generar el arbol de modulos." )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry	
		this.GenerarXmlEstructuraDeModulos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarXmlEstructuraDeModulos() as Void
		local loGenerador as GeneradorEstructuraDeModulosV2 of GeneradorEstructuraDeModulosV2.prg, loError as Exception
		
		Try
			this.EnviarMensajeProceso( "Generando Arbol de Módulos" )
			loGenerador = _screen.zoo.crearobjeto( "GeneradorEstructuraDeModulosV2", "GeneradorEstructuraDeModulosV2.prg", this.cPath )
			loGenerador.GenerarXmlEstructuraDeModulosV2()
		Catch To loError
			this.ControlarError( loError, "Error al generar Estructura de modulos V2." )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarConstantesModulos() as Void
		local loGenerador as generadordinamicoConstantesModulos of generadordinamicoConstantesModulos.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Constante de Módulos" )
			loGenerador = newobject( "generadordinamicoConstantesModulos", "generadordinamicoConstantesModulos.prg" , "", this.cPath)
			loGenerador.Inicializar()
			loGenerador.Generar( "ConstanteDeModulos" )			

			if vartype( goModulos ) != "O" 
				if file( "Modulos" + _screen.zoo.app.cProyecto + ".fxp" ) 
					compile ( locfile( "Modulos" + _screen.zoo.app.cProyecto + ".prg"  ) )
				endif					
			endif 			
		Catch To loError
			this.ControlarError( loError, "Error al generar constantes modulos." )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		EndTry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarKontrolers( tcEntidad as String ) as Void
		local loError as Exception, lcClase as string

		try
			this.EnviarMensajeProceso( "Generando Kontroler " + alltrim( tcEntidad ) )
			this.oGenKontroler.generar( tcEntidad )
		catch to loError
			this.ControlarError( loError, "Error al generar el Kontroler " + alltrim( tcEntidad ) )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarKontrolerListados( tcListado as string, tlSecuencial as boolean ) as Void
		this.oProcesoDinamicoListados.GenerarKontrolerListados( tcListado, tlSecuencial )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarKontrolerListadoEspecifico( tcListado as string, tlSecuencial as boolean ) as Void
		this.oProcesoDinamicoListados.GenerarKontrolerListadoEspecifico( tcListado, tlSecuencial )
	endfunc
	*-----------------------------------------------------------------------------------------
	function GenerarComprobante() as Void
		local loGenerador as GeneradorDinamicoComprobante of GeneradorDinamicoComprobante.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Comprobante"  )
			loGenerador = newobject( "GeneradorDinamicoComprobante", "GeneradorDinamicoComprobante.prg", "", this.cPath ) 
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error al generar el Comprobante" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif		
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarAutocompletar() as Void
		local loGenerador as GeneradorDinamicoAutocompletar of GeneradorDinamicoAutocompletar.prg, loError as Exception
		try
			this.EnviarMensajeProceso( "Generando Dinamico autocompletar" )
			loGenerador = _screen.zoo.crearobjeto( "GeneradorDinamicoAutocompletar", "GeneradorDinamicoAutocompletar.prg", this.cPath ) 

			loGenerador.generar( "Autocompletar"  )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Autocompletar" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		endtry
		
		try
			this.EnviarMensajeProceso( "Generando Dinamico autocompletar SqlServer" )
			loGenerador = _screen.zoo.crearobjeto( "GeneradorDinamicoAutocompletarSqlServer", "GeneradorDinamicoAutocompletarSqlServer.prg", this.cPath ) 
		
			loGenerador.generar( "Autocompletar" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto AutocompletarSqlServer" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarNumeraciones() as Void
		local loGenerador as GeneradorDinamicoNumeraciones of GeneradorDinamicoNumeraciones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Dinamico Numeraciones" )
			loGenerador = newobject( "GeneradorDinamicoNumeraciones", "GeneradorDinamicoNumeraciones.prg","", this.cPath ) 
			loGenerador.generar( "Numeraciones" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Numeraciones" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarObjetoPromociones() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Objeto Promociones" )
			loGenerador = newobject( "GeneradorDinamicoObjetoPromociones", "GeneradorDinamicoObjetoPromociones.prg","", this.cPath ) 
			loGenerador.generar( "Promociones" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Promociones" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarObjetoGTIN() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Objeto GTIN" )
			loGenerador = newobject( "GeneradorDinamicoObjetoGTIN", "GeneradorDinamicoObjetoGTIN.prg","", this.cPath ) 
			loGenerador.generar( "GTIN" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto GTIN" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarEjecutorServicioRest() as Void
		local loGenerador as Object, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando EjecutorServicioRest" )
			this.oGenEjectutorREST.Generar( "REST" )
		catch to loError
			this.ControlarError( loError, "Error al generar el EjecutorServicioRest" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarDocumentacionSwaggerServicioRest() as Void
		local loGenerador as Object, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Documentacion Swagger Servicio Rest" )
			loGenerador = newobject( "GeneradorAyudaServicioREST", "GeneradorAyudaServicioREST.prg" ) 
			bindevent( loGenerador, "EventoMensajeProceso", this, "EnviarMensajeProceso" )
			loGenerador.Generar("")
		catch to loError
			this.ControlarError( loError, "Error al generar AyudaServicioREST" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarFactoriaControlesExportaciones() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Factoria Controles Exportaciones" )
			loGenerador = newobject( "GeneradorDinamicoFactoriaControlesExportaciones", "GeneradorDinamicoFactoriaControlesExportaciones.prg","", this.cPath ) 
			loGenerador.generar( "FactoriaControlesExportaciones" )
		catch to loError
			this.ControlarError( loError, "Error al generar Factoria Controles Exportaciones" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarComprobantesYGruposDeCajaSQL() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Objeto Comprobantes Y Grupos de Caja SQL" )
			loGenerador = newobject( "GeneradorComprobantesYGruposDeCajaSQL", "GeneradorComprobantesYGruposDeCajaSQL.prg","", this.cPath ) 
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error al generar comprobantes Y Grupos de caja SQL" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.release()
			endif			
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarTipodeValores() as Void
		local loGenerador as GeneradorDinamicoTipoDeValores of GeneradorDinamicoTipoDeValores.prg, loError as Exception
		
		try
			this.EnviarMensajeProceso( "Generando tipo de valores" )
			loGenerador = newobject( "GeneradorDinamicoTipoDeValores", "GeneradorDinamicoTipoDeValores.prg","", this.cPath ) 
			loGenerador.generar("TipoDeValores")
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto TipoDeValores" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarObjetoListado( tcListado as string, tlSecuencial as boolean ) as Void
		this.oProcesoDinamicoListados.GenerarObjetoListado( tcListado, tlSecuencial )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarPresentacion() as Void
		local loGenerador as GeneradorDinamicoPresentacion of GeneradorDinamicoPresentacion.prg, ;
			loError as Exception

		this.EnviarMensajeProceso( "Generando Presentación" )
		loGenerador = _screen.zoo.crearobjeto( "GeneradorDinamicoPresentacion", "", this.cPath )
		try
			loGenerador.generar()
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto TipoDeValores" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarObjetoListadoEspecifico( tcListado as string, tlSecuencial as boolean ) as Void
		this.oProcesoDinamicoListados.GenerarObjetoListadoEspecifico( tcListado, tlSecuencial )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarConsultas( tcListado as string ) as Void
		this.oProcesoDinamicoListados.GenerarConsultas( tcListado )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarConsultasEspecifica( tcListado as string ) as Void
		this.oProcesoDinamicoListados.GenerarConsultasEspecifica( tcListado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFormularioTransferencias( tcEntidad as integer, tnEstilo as integer ) as Void
		local loError as exception, i as integer, lnEstilo as Integer
		
		try 
			if tnEstilo = 0
				lnEstilo = 2
				this.EnviarMensajeProceso( "Generando FRM Transferencia " + alltrim( tcEntidad ) + " estilo " + transform( lnEstilo ) )
				this.oGenFormTransferencia.generar( tcEntidad,"" , lnEstilo )
			else
				this.EnviarMensajeProceso( "Generando FRM Transferencia " + alltrim( tcEntidad ) + " estilo " + transform( tnEstilo ) )
				this.oGenFormTransferencia.generar( tcEntidad, "" , tnEstilo )
			endif
		catch to loError
			this.ControlarError( loError, "Error al generar la formulario Transferencia " + alltrim( tcEntidad ) )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarFormularioExportacion( tcEntidad as integer, tnEstilo as integer ) as Void
		local loError as exception, i as integer, lnEstilo as Integer
		
		try 
			if tnEstilo = 0
				lnEstilo = 2
				this.EnviarMensajeProceso( "Generando FRM Exportacion " + alltrim( tcEntidad ) + " estilo " + transform( lnEstilo ) )
				this.oGenFormExportacion.generar( tcEntidad,"" , lnEstilo )
			else
				this.EnviarMensajeProceso( "Generando FRM Exportacion " + alltrim( tcEntidad ) + " estilo " + transform( tnEstilo ) )
				this.oGenFormExportacion.generar( tcEntidad,"" , tnEstilo )
			endif
		catch to loError
			this.ControlarError( loError, "Error al generar el formulario Exportacion " + alltrim( tcEntidad ) )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFormularioExportacionAgrupada( tnEstilo as integer ) as Void
		local loError as exception, i as integer, lnEstilo as Integer

		try 
			if tnEstilo = 0
				lnEstilo = 2
				this.EnviarMensajeProceso( "Generando FRM Exportacion Agrupada estilo " + transform( lnEstilo ) )
				this.oGenFormExportacionAgrupada.generar( '',"" , lnEstilo )
			else
				this.EnviarMensajeProceso( "Generando FRM Exportacion Agrupada estilo " + transform( tnEstilo ) )
				this.oGenFormExportacionAgrupada.generar( '',"" , tnEstilo )
			endif
		catch to loError
			this.ControlarError( loError, "Error al generar el formulario Exportacion Agrupada" )
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarFormularioTransferenciasAgrupadas( tnTrans as integer, tnEstilo as integer ) as Void
		local loGenerador as GeneradorFormulariosTransferenciasAgrupada of GeneradorFormulariosTransferenciasAgrupada.prg, ;
			lcPathAnt as String, loError as exception, i as integer, lnEstilo as Integer
			
		try 
			loGenerador = _screen.zoo.crearobjeto( "GeneradorFormulariosTransferenciaAgrupada", "", this.cPath )
		
			if tnEstilo = 0
				lnEstilo = 2
				this.EnviarMensajeProceso( "Generando FRM Transferencia Agrupada " + transform( tnTrans ) + " estilo " + transform( lnEstilo ) )
				loGenerador.generar( tnTrans,"" , lnEstilo )
			else
				this.EnviarMensajeProceso( "Generando FRM Transferencia Agrupada " + transform( tnTrans ) + " estilo " + transform( tnEstilo ) )
				loGenerador.generar( tnTrans,"" , tnEstilo )
			endif
		catch to loError
			this.ControlarError( loError, "Error al generar la formulario Transferencia Agrupada " + transform( tnTrans ) )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarImportacion() as Void
		local i as Integer, lnEstilo as Integer
		
		lnEstilo = 2
		this.EnviarMensajeProceso( "Generando FRM Importacion estilo " + transform( lnEstilo ) )
		this.oGenFormImportacion.generar( '',"" , lnEstilo )
		this.EnviarMensajeProceso( "Generando FRM Importacion agrupada estilo " + transform( lnEstilo ) )
		this.oGenFormImportacionAgrupada.generar( '',"" , lnEstilo )			

	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFormularioListados( tcListado as string, tnEstilo as integer, tlSecuencial as boolean ) as Void
		this.oProcesoDinamicoListados.GenerarFormularioListados( tcListado, tnEstilo, tlSecuencial )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarComponente( tcElemento as String ) as Void
		local loError as exception

		try 
			this.EnviarMensajeProceso( "Generando Componente " + alltrim( tcElemento ) )	
			this.oGenComponente.generar( tcElemento )
		catch to loError
			this.ControlarError( loError, "Error al generar el componente especifico " + alltrim( tcElemento ) )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarFormulariosParametrosPrincipal( tcTipo as string, tcXml as string, tcXmlJerarquias as string, tnEstilo as integer ) as Void
		local loGeneradoras as GeneradorFormulariosParametrosPrincipal of GeneradorFormulariosParametrosPrincipal.prg, ;
			loError as exception, lni as Integer, lcTipo as String, lnEstilo as Integer
		
		lcTipo = tcTipo
		try 
			loGenerador = _screen.zoo.crearobjeto( "GeneradorFormulariosParametrosPrincipal", "", this.cPath )
		
			if empty( tnEstilo )
				lnEstilo = 2
			else
				lnEstilo = tnEstilo
			endif
		
			this.EnviarMensajeProceso( "Generando Formulario " + lcTipo + " Principal Estilo " + transform( lnEstilo ) )
			loGenerador.Generar( lcTipo, tcXml, tcXmlJerarquias, lnEstilo )

		catch to loError
			this.ControlarError( loError, "Error al generar el formulario principal de " + lcTipo )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarFormulariosParametros( tcTipo as string, tcXml as string, tnEstilo as integer ) as Void
		local loGenerador as GeneradorFormulariosParametros of GeneradorFormulariosParametros.prg, ;
			loError as exception, lni as integer, lcCursorAux as String, lcCursor as string, ;
			lnNodo as Integer, lcproyecto as string, lnEstilo as integer, lcTipo as String
		
		lcTipo = tcTipo
			
		if empty( tnEstilo )
			lnEstilo = 2
		else
			lnEstilo = tnEstilo
		endif
		
		try 
			loGenerador = _screen.zoo.crearobjeto( "GeneradorFormulariosParametros", "", this.cPath )

			lcCursorAux = sys( 2015 )
			lcCursor = sys( 2015 )

			this.Xmlacursor( tcXml, lcCursorAux )
			select idnodoCliente from ( lcCursorAux ) ;
				group by idnodoCliente ;
				into cursor ( lcCursor ) readwrite

			use in select( lcCursorAux )

			select( lcCursor )
			replace all idnodoCliente with 1 for idnodoCliente = 0

			scan
				lnNodo = &lcCursor..idnodoCliente 
			
				this.EnviarMensajeProceso( "Generando Formulario Nodo " + transform( lnNodo ) + " " + lcTipo + " Estilo " + transform( lnEstilo ) )
				loGenerador.generar( lcTipo, lnNodo, lnEstilo, tcXml )

				select( lcCursor )
			endscan
			
			use in select( lcCursor )
		catch to loError
			this.ControlarError( loError, "Error al generar el formulario de " + transform( lcTipo ) )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif				
		endtry		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarObjetoTransferencias( tcEntidad as string, tlTransformacion as Boolean ) as Void
		local loError as exception, loGen as generadordinamico of generadordinamico.prg
		try 
			this.EnviarMensajeProceso( "Generando Objeto Transferencia " + alltrim( proper( tcEntidad ) ) )
			if tlTransformacion
				loGen = this.oGenObjTransferenciaAdicionales
			else
				loGen = this.oGenObjTransferencia
			endif
			loGen.generar( tcEntidad )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Transferencia " + alltrim( proper( tcEntidad ) ) )
		finally
			loGen = null
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarObjetoExportacion( tcEntidad as string ) as Void
		local loError as exception
		try 
			this.EnviarMensajeProceso( "Generando Objeto Exportacion " + alltrim( proper( tcEntidad ) ) )
			this.oGenObjExportacion.generar( tcEntidad )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Exportacion " + alltrim( proper( tcEntidad ) ) )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarPresentacionTransferencias() as Void
		local loGenerador as GeneradorDinamicoPresentacionTransferencias of GeneradorDinamicoPresentacionTransferencias.prg, ;
			loError as Exception
		
		this.EnviarMensajeProceso( "Generando Presentación de transferencias" )
		loGenerador = _screen.zoo.crearobjeto( "GeneradorDinamicoPresentacionTransferencias", "", this.cPath )
		try		
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error Generando Presentación de transferencias" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif				
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarObjetoExportacionAgrupada() as Void
		local loError as exception
		try 
			this.EnviarMensajeProceso( "Generando Objeto Exportacion Agrupada" )
			this.oGenObjExportacionAgrupada.generar( '' )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Exportacion Agrupada" )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarObjetoTransferenciasAgrupadas( tnTrans as integer ) as Void
		local loError as exception, lcPathAnt as String, loError

		try 
			this.EnviarMensajeProceso( "Generando Objeto Transferencia Agrupada " + transform( tnTrans ) )
			this.oGenObjTransferenciaAgrupadas.generar( tnTrans )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto Transferencia Agrupada " + transform( tnTrans ) )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarConsultaTransferencias( tcEntidad as string ) as Void
		local loError as exception
		try 
			this.EnviarMensajeProceso( "Generando Consulta Transferencia " + alltrim( proper( tcEntidad ) ) )
			this.oGenConsultaTransferencias.generar( tcEntidad )
		catch to loError
			this.ControlarError( loError, "Error al generar el Consulta Transferencia " + alltrim( proper( tcEntidad ) ) )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarConsultaExportacion( tcEntidad as string ) as Void
		local loError as exception
		try 
			this.EnviarMensajeProceso( "Generando Consulta Exportacion " + alltrim( proper( tcEntidad ) ) )

			this.oGenConsultaExportacionSQLServer.generar( tcEntidad )
		catch to loError
			this.ControlarError( loError, "Error al generar el Consulta Exportacion " + alltrim( proper( tcEntidad ) ) )
		endtry
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	function GenerarEstructuraAdn() as Void
		local loGenerador as GeneradorDinamicoEstructuraAdn of GeneradorDinamicoEstructuraAdn.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando estructura ADN" )
			loGenerador = newobject( "GeneradorDinamicoEstructuraAdn", "GeneradorDinamicoEstructuraAdn.prg", "", this.cPath ) 
			loGenerador.SetearNumeroDeVersion( This.cNumeroDeVersion )
			loGenerador.generar("EstructuraAdn")
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto EstructuraAdn" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif				
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFormulariosDuros( tcGenerar as String, tcRuta as string, tnEstilo as integer ) as Void
		local i as Integer, lntotal as Integer, lnEstilo as Integer, llRetorno as boolean, loGeneraFormulario as object, ;
			loError as Exception
					
		if empty( tnEstilo )
			lnEstilo = 2
		else
			lnEstilo = tnEstilo
		endif

		loGeneraFormulario = this.oGenFormDuro

		this.EnviarMensajeProceso( "Generando FRM Duro " + tcGenerar + " Estilo: " + transform( lnEstilo ) )
	
		try
			llRetorno = loGeneraFormulario.generar( tcGenerar, tcRuta, lnEstilo )
		catch to loError
			this.ControlarError( loError, "Error al generar el FRM Duro " + tcGenerar )
		endtry

		loGeneraFormulario = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesglosarError( toError as Exception ) as string
		local loAux as Exception, lcError as string

		lcError = "Error desconocido."
		loAux = toError
		do while vartype( loAux ) = "O"
			if !empty( lcError )
				lcError = lcError + chr(13) + "---------------------------------" + chr(13)
			endif

			lcError = lcError + "Error: " + loAux.Message + chr( 13) + ;
					"Nro. Error: " + transform( loAux.ErrorNo ) + chr( 13 ) + ;
					"Detalle: " + loAux.Details + chr( 13) + ;
					"Procedimiento: " + loAux.Procedure + chr( 13) + ;
					"Linea: " + loAux.LineContents + chr( 13 ) + ;
					"Nro. Linea: " + transform( loAux.LineNo )
					
			loAux = loAux.UserValue
		enddo
		
		return lcError
	endfunc

	*-----------------------------------------------------------------------------------------
	function AbrirTabla( tcTabla as String, tlCursor as boolean, tcAlias as string ) as Void
		local lcTabla as String, lcAlias as String
		lcTabla = alltrim( tcTabla )
		if empty( tcAlias )
			lcAlias = "c_" + lcTabla
		else
			lcAlias = tcAlias
		endif

		use in select( lcTabla )
		use in select( lcAlias )
		
		use ( lcTabla ) in 0 shared noupdate again alias ( lcAlias )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function CerrarTabla( tcTabla as String ) as Void

		local lcTabla as String, lcAlias as String
		lcTabla = alltrim( tcTabla )
		lcAlias = "c_" + lcTabla
		use in select( lcTabla )
		use in select( lcAlias )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarBuscadores( tnIdBuscador as integer ) as Void
		this.GenerarBuscadorEspecifico( tnIdBuscador )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarBuscadorEspecifico( tnIdBuscador as integer ) as Void
		local loError as Exception
	
		try
			this.oGenBuscadorOB.Generar( transform( tnIdBuscador ) )
			this.oGenBuscadorAD.Generar( transform( tnIdBuscador ) )
		catch to loError
			this.ControlarError( loError, "Error al generar el buscador " + transform( tnIdBuscador ) )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarProcedimientosAlmacenados() as Void
		local loGenerador as generadorDinamicoProcedimientosAlmacenados of generadorDinamicoProcedimientosAlmacenados.prg, ;
			loError as Exception
		
		this.EnviarMensajeProceso( "Generando Procedimientos Almacenados" )

		loGenerador = _screen.zoo.crearobjeto( "generadorDinamicoProcedimientosAlmacenados", "", this.cPath )
		try
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error al generar procedimientos almacenados" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarConfiguracionBasica( tcProyecto as String ) as Void
		local loGenerador as Object, ldFechaEnBlancoParaSqlServer as Date, lcOrigen as String, lcDestino as String

		this.EnviarMensajeProceso( "Generando Configuracion Basica" )
		this.agregarReferencia( "zoologicsa.generadordedatos.dll" )
		ldFechaEnBlancoParaSqlServer = {01/01/1900}
		loGenerador = _screen.zoo.crearobjeto( "zoologicsa.generadordedatos.ManagerGeneracionScriptDatos", "", ldFechaEnBlancoParaSqlServer )

		try
			with loGenerador
				.RutaOrigen = addbs( left( addbs( _Screen.zoo.crutainicial ), rat( "\",addbs( _Screen.zoo.crutainicial ),2 )) )
				if(empty(this.cPath))
					.RutaDestino = addbs( _Screen.zoo.cRutaInicial ) + "generados\"
				else
					.RutaDestino = addbs( this.cPath ) + "generados\"			
				endif

				.Proyecto = alltrim( tcProyecto )
				.PrefijoCarpetasEspecificas = "especifico"
				.PrefijoCarpetasHerencias = "Herencia"
				if file(.RutaOrigen + "data\proyectos.dbf")
					.CarpetaTablaProyectos = .RutaOrigen + "data\"
				else
					.CarpetaTablaProyectos = .RutaOrigen + "taspein\data\"
				endif
				.RutaOrigen = .RutaOrigen + "ConfiguracionBasica\"
				.RutaEntidadesEspeciales = "DatosDefaultEntidadesEspeciales\"
				.RutaAdn = addbs( _Screen.zoo.cRutaInicial ) + "Adn\Dbc\"
				.Procesar()
			endwith

			* Copiamos los XML de DatosDefaultEntidadesEspeciales a Generados (No se pasan de DBF a XML ahora)
			lcOrigen = addbs(loGenerador.RutaOrigen) + addbs(loGenerador.PrefijoCarpetasEspecificas) + addbs(loGenerador.Proyecto) + addbs(loGenerador.RutaEntidadesEspeciales) + "*.xml"
			lcDestino = addbs(loGenerador.RutaDestino) + "*.xml"

			if directory( justpath( lcOrigen ) )
				copy file (lcOrigen) to (lcDestino)
			endif
		finally
			loGenerador = null
		endtry					
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroVersion() as String
		return this.cNumeroDeVersion
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearNumeroDeVersion( tcNumeroDeVersion as String ) as VOID
		this.cNumeroDeVersion = tcNumeroDeVersion
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarFuncionesAdicionalesParaSqlServer() as Void
		local loGenerador as GeneradorDinamicoFuncionesParaSqlServer of GeneradorDinamicoFuncionesParaSqlServer.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando funciones para sql server" )
			loGenerador = newobject( "GeneradorDinamicoFuncionesParaSqlServer", "GeneradorDinamicoFuncionesParaSqlServer.prg", "", this.cPath ) 
			loGenerador.generar()
		catch to loError
			this.ControlarError( loError, "Error al generar funciones para sql server" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerandoDatosDeEntidades() as Void
		local loGenerador as GeneradorDinamicoFuncionesParaSqlServer of GeneradorDinamicoFuncionesParaSqlServer.prg, loError as Exception
		
		try
			this.EnviarMensajeProceso( "Generando Datos de entidades" )
			loGenerador = newobject( "GeneradorDinamicoDatosDeEntidades", "GeneradorDinamicoDatosDeEntidades.prg", "", this.cPath ) 
			loGenerador.Generar( "DatosDeEntidades" )
		catch to loError
			this.ControlarError( loError, "Error al generar Datos de entidades" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarConsultaCompletarDesdeVentas() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Objeto ConsultaCompletarDesdeVentas" )
			loGenerador = newobject( "GeneradorConsultaCompletarDesdeVentas", "GeneradorConsultaCompletarDesdeVentas.prg","", this.cPath ) 
			loGenerador.generar( "ConsultaCompletarDesdeVentas" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto ConsultaCompletarDesdeVentas" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarCursorAtributosConSaltoDeCampo() as Void
		local loGenerador as GeneradorDinamicoObjetoPromociones of GeneradorDinamicoObjetoPromociones.prg, loError as Exception

		try
			this.EnviarMensajeProceso( "Generando Objeto CursorAtributosConSaltoDeCampo" )
			loGenerador = newobject( "GeneradorCursorAtributosConSaltoDeCampo", "GeneradorCursorAtributosConSaltoDeCampo.prg","", this.cPath ) 
			loGenerador.generar( "CursorAtributosConSaltoDeCampo" )
		catch to loError
			this.ControlarError( loError, "Error al generar el Objeto CursorAtributosConSaltoDeCampo" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif			
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoMensajeProceso( tcMensaje ) as Void
		** Este método es para levantar un evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeProceso( tcMensaje ) as Void
		if this.lEnviarEnviarMensaje
			this.EventoMensajeProceso( tcMensaje )
		endif
		** Este método es para levantar un evento
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function GenerarMapeoEntidadesDetalles() as Void
		local loGeneradorNet as Object
		try
			this.EnviarMensajeProceso( "Generando Mapeo de Entidades con detalles " )
			loGenerador = newobject( "GeneradorDinamicoEstructuraDetalles", "GeneradorDinamicoEstructuraDetalles.prg", "", this.cPath ) 
			loGenerador.Generar( "MapeoEntidadesDetalles" )
		catch to loError
			this.ControlarError( loError, "Error al generar Datos de entidades" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif	
		endtry		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function GenerarTriggersRegistrodeBaja() as Void
		local loGeneradorNet as Object
		try
			this.EnviarMensajeProceso( "Generando Triggers Registros de Baja" )
			loGenerador = newobject( "GeneradorDinamicoTriggersRegistrodeBaja", "GeneradorDinamicoTriggersRegistrodeBaja.prg", "", this.cPath ) 
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error al generar Triggers Registros de Baja" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif	
		endtry		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function GenerarTriggersRegistrodeBajaDeOrganizacion() as Void
		local loGenerador as Object
		try
			this.EnviarMensajeProceso( "Generando Triggers Registros de Baja de Organización" )
			loGenerador = newobject( "GeneradorDinamicoTriggersRegistrodeBajaOrganizacion", "GeneradorDinamicoTriggersRegistrodeBajaOrganizacion.prg", "", this.cPath ) 
			loGenerador.Generar()
		catch to loError
			this.ControlarError( loError, "Error al generar Triggers Registros de Baja de Organización" )
		finally
			if vartype( loGenerador ) = "O" and !isnull( loGenerador )
				loGenerador.Release()
			endif	
		endtry		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarLibreriaClasesVisuales( toColProxy as Collection ) as Void
		local loSerializador as Object
		loSerializador = newobject( "SerializadorLibreriaControles", "SerializadorLibreriaControles.prg" )
		loSerializador.Serializar( toColProxy, "LibProxyControles" )
	endfunc 

EndDefine

