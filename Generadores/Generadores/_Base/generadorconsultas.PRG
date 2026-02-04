define class GeneradorConsultas as generadordinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorConsultas of GeneradorConsultas.prg
	#endif

	cPath = "Generados\"
	cCursorHerencia = ""
	cEntidades = ""

	oObjeto = null

	cPrefijo = ""
	cSufijo = "Consulta"
	cPrefijoCursor = "c_"
	lVacia = .F.
	oColLlamadasLlenarCamposMemos = null

	oCacheDatos = null
	CacheIniciarCursores = ""
	CacheCargarDatosEnCursores = ""
	cCacheActiva = ""
	CacheTemp = ""
	oCacheFunciones = null
	lRecursivo = .f.

	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		dodefault( tcRuta )

		This.oColLlamadasLlenarCamposMemos = _Screen.zoo.CrearObjeto( "zooColeccion" )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function oCacheFunciones_Access() as Void
		if !this.ldestroy and ( !vartype( this.oCacheFunciones ) = 'O' or isnull( this.oCacheFunciones ) )
			if !pemstatus(_screen.zoo,"oCacheFunciones",5)
				=addproperty(_screen.zoo,"oCacheFunciones",null)
			endif
			_screen.zoo.oCacheFunciones = _Screen.zoo.CrearObjeto( "zooColeccion" )
			this.oCacheFunciones = _screen.zoo.oCacheFunciones
		endif 
		return this.oCacheFunciones
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.ldestroy = .t.
		this.oCacheFunciones = null
		dodefault()
	endfunc


	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		if vartype( this.oObjeto ) = "O"
			this.oObjeto.release()
		endif
		this.oObjeto = null
		
		if vartype( this.oCacheDatos ) = "O"
			this.oCacheDatos.release()
		endif
		this.oCacheDatos = null

		use in select( this.cCursorHerencia )
		use in select( "c_Estructura" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFiltro( tcEntidad as String, tcTabla as String ) as string
		local lcRetorno as String, lcSql as string
		
		if empty( tcEntidad )
			tcEntidad = this.oObjeto.cEntidad
		endif

		if this.oCacheFunciones.Buscar( "FILTRO_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheFunciones.Item[ "FILTRO_" + upper( tcEntidad ) ]
		else
			lcSql = "Select Filtro From c_Estructura Where !empty( Filtro ) And Alltrim( upper( Entidad ) ) == '" + ;
						Alltrim( upper( tcentidad ) ) + "' into cursor c_ObtenerFiltro"
			&lcSql	
			lcRetorno = This.ObtenerFiltroParseado( tcEntidad, c_ObtenerFiltro.Filtro )
			use in c_ObtenerFiltro

			this.oCacheFunciones.Agregar( lcRetorno, "FILTRO_" + upper( tcEntidad ) )
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerFiltroParseado( tcEntidad as String, tcFiltro as String ) as String
		local lcRetorno as String
		lcRetorno = " !empty( " + This.ObtenerCampoClavePrimaria( tcEntidad ) + " )"
		if !empty( tcFiltro )
			lcRetorno = upper( lcRetorno + " And " + alltrim( tcFiltro ) )
		endif
		return lcRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerTabla( tcEntidad as String ) as String
		local lcRetorno as String, lcSql as string
		
		if empty( tcEntidad )
			tcEntidad = this.oObjeto.cEntidad
		endif
		
		if this.oCacheFunciones.Buscar( "TABLA_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheFunciones.Item[ "TABLA_" + upper( tcEntidad ) ]
		else
			lcSql = "select Distinct Tabla from c_Estructura where Alltrim( upper( Entidad ) ) == '" + ;
					alltrim( upper( tcEntidad ) ) + "'" + ;
						" and !empty( atributo ) " + ;
						" and !empty( Entidad ) " + ;
						" and ClavePrimaria " + ;
					" into cursor c_Tabla "
			
			&lcSql
			lcRetorno = alltrim( upper( c_Tabla.Tabla ) )
			use in c_Tabla

			this.oCacheFunciones.Agregar( lcRetorno, "TABLA_" + upper( tcEntidad ) )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoDato( tcEntidad as String, tcCampo as string ) as String
		local lcRetorno as String, lcSql as string
		
		if empty( tcEntidad )
			tcEntidad = this.oObjeto.cEntidad
		endif

		if this.oCacheFunciones.Buscar( "TIPODATO_" + upper( tcEntidad ) + "_" + upper( tcCampo ) )
			lcRetorno = this.oCacheFunciones.Item[ "TIPODATO_" + upper( tcEntidad ) + "_" + upper( tcCampo ) ]
		else
			lcSql = "select TipoDato from c_Estructura where Alltrim( upper( Entidad ) ) == '" + alltrim( upper( tcEntidad ) ) + "'" + ;
						" and  Alltrim( upper( Campo ) ) == '" + alltrim( upper( tcCampo ) ) + "'" + ;
						" and !empty( campo ) " + ;
						" and !empty( Entidad ) " + ;
						" and ClavePrimaria " + ;
					" into cursor c_Tabla "
			
			&lcSql
			lcRetorno = alltrim( upper( c_Tabla.TipoDato ) )
			use in c_Tabla

			this.oCacheFunciones.Agregar( lcRetorno, "TIPODATO_" + upper( tcEntidad ) + "_" + upper( tcCampo ) )
		endif

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCampoClavePrimaria( tcEntidad as String ) as string
		local lcSql As String, lcCampoClavePrimaria As String

		store "" to lcCampoClavePrimaria, lcSql

		if empty( tcEntidad )
			tcEntidad = this.oObjeto.cEntidad
		endif

		if this.oCacheFunciones.Buscar( "CAMPOPK_" + upper( tcEntidad ) )
			lcCampoClavePrimaria = this.oCacheFunciones.Item[ "CAMPOPK_" + upper( tcEntidad ) ]
		else
			lcSql = "select Campo from c_Estructura where Alltrim( upper( Entidad ) ) == '" + ;
					alltrim( upper( tcEntidad ) ) + "'" + ;
						" and !empty( atributo ) " + ;
						" and !empty( Entidad ) " + ;
						" and ClavePrimaria " + ;
					" into cursor c_ClavePrimaria "
			
			&lcSql
				
			select c_ClavePrimaria
			scan
				lcCampoClavePrimaria = lcCampoClavePrimaria + "+" + alltrim( c_ClavePrimaria.Campo )
			endscan

			lcCampoClavePrimaria = substr( lcCampoClavePrimaria, 2 )
			use in c_ClavePrimaria

			this.oCacheFunciones.Agregar( lcCampoClavePrimaria, "CAMPOPK_" + upper( tcEntidad ) )
		endif

		return lcCampoClavePrimaria
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposClaveCandidata( tcEntidad as String ) as string
		local lcRetorno as String, lcCursor as string, lcEntidad as String 

		lcRetorno = ""
		if pcount() > 0
			lcEntidad = upper( alltrim( tcEntidad ) )
		else
			lcEntidad = this.cTipo
		endif

		if this.oCacheFunciones.Buscar( "CAMPOPC_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheFunciones.Item[ "CAMPOPC_" + upper( tcEntidad ) ]
		else
			lcCursor = this.ObtenerCursorClaveCandidata( lcEntidad )
			try
				if reccount( lcCursor ) > 0
					select &lcCursor
					scan all
						lcRetorno = lcRetorno + "," + alltrim( &lcCursor..Campo )
					EndScan	
					lcRetorno = substr( lcRetorno, 2 )
				endif	
			finally
				use in select( lcCursor )
			endtry

			this.oCacheFunciones.Agregar( lcRetorno, "CAMPOPC_" + upper( tcEntidad ) )
		endif
		return lcRetorno
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function ObtenerOrderBy( tcEntidad as String ) as string
		local lcRetorno as String, lcAux as String, lcCampoItem as string
		
		lcRetorno = ""
		lcAux = ""

		with this as GeneradorConsultas of GeneradorConsultas.prg
			if this.oCacheDatos.Buscar( "ORDERBY_" + upper( tcEntidad ) )
				lcRetorno = this.oCacheDatos.Item[ "ORDERBY_" + upper( tcEntidad ) ]
			else
				lcAux = .ObtenerCamposClaveCandidata( tcEntidad )
				
				if ( empty( lcAux ) )
					lcAux =  .ObtenerCampoClavePrimaria( tcEntidad )
					if ( !empty( lcAux ) )
						if ( .EsDetalle( tcEntidad ) )
							lcCampoItem = .ObtenerCampoAtributo( tcEntidad, "NroItem" )
							if !empty( lcCampoItem )
								lcAux = lcAux + "," + lcCampoItem 
							endif
						endif

						lcRetorno = "order by " + lcAux 
					endif
				else
					lcRetorno = "order by " + lcAux 
				endif

				this.oCacheDatos.Agregar( lcRetorno, "ORDERBY_" + upper( tcEntidad ) )
			endif
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGenerarCodigo() as Void
		local lcClase as String

		lcClase = "Din_" + alltrim( this.cPrefijo ) + alltrim( this.cTipo ) + "objeto"
		this.oObjeto = newobject( lcClase, lcClase + ".prg" )
		this.oCacheDatos = newobject( "ZooColeccion", "ZooColeccion.prg" )
		
		This.InicializarParaGenerar()
		this.AbrirCursorEstructura()

		dodefault()

		this.cEntidades = "'" + this.oObjeto.cEntidad + "'"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function InicializarParaGenerar() as Void

		this.oObjeto.Inicializar()

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirCursorEstructura() as Void
		local loXMLAdapter as Object
		
		loXMLAdapter = CreateObject( "xmladapter") 
		if type( "this.oObjeto.cEstructuraDeDatos" ) = "C"
			loXMLAdapter.LoadXML( this.oObjeto.cEstructuraDeDatos )
		else 	
			loXMLAdapter.LoadXML( this.oObjeto.oSetDatos.item[ 1 ] )
		endif 	
		
		loXMLAdapter.Tables.Item[ 1 ].ToCursor()
		loXMLAdapter.destroy()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerencia() as string
		return alltrim( this.cPrefijo ) + "Base"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarLinea( tcTexto, tnTabs ) as Void
		local lcEnter as string, tcTabs as string
		lcEnter = chr(13) + chr(10)
		if pcount() = 2 and tnTabs > 0
			tcTabs = replicate( chr(9), tnTabs )
		else
			tcTabs = ""
		endif
		
		do case
			case this.cCacheActiva == "CacheTemp"
				this.CacheTemp = this.CacheTemp + lcEnter + tcTabs + tcTexto
			case this.cCacheActiva == "CacheIniciarCursores"
				this.CacheIniciarCursores = this.CacheIniciarCursores +  tcTabs + tcTexto
			case this.cCacheActiva == "CacheCargarDatosEnCursores"
				this.CacheCargarDatosEnCursores = this.CacheCargarDatosEnCursores + tcTabs + tcTexto
			otherwise 
				this.cBuffer = this.cBuffer + lcEnter + tcTabs + tcTexto
		endcase

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void

		with this as GeneradorConsultas of GeneradorConsultas.prg
		
			this.lRecursivo = this.VerificarFuncionalidad( this.cTipo, "PAQRECURSIVO" )
		
			if !empty( .cCursorHerencia )
				use in select( .cCursorHerencia )
			endif
			.cCursorHerencia = sys( 2015 ) + "_CursorHerencia"
			create cursor ( .cCursorHerencia ) ( Entidad C(200), Dependencia C(200), tipo C(1), Orden N(4), DependenciaOrig C(200) )
			
			.ObtenerSubentidadesYDetallesYMemos( .cEntidades, 4 ) && Revisar la forma de que la recursion termine por otra cosa..	
			.AgregarFuncionObtener()
			.agregarLinea("")
			.AgregarConsultas()
			.cCacheActiva = "cBuffer"
			.AgregarFuncionIniciarCursores()
			.agregarLinea("")
			.AgregarFuncionCargarDatosEnCursores()		
			.agregarLinea("")
			.AgregarFuncionUnificarMemos()
			.agregarLinea("")
			.AgregarFuncionActualizarInfoAdicionalGenerica()
			.agregarLinea("")			
			if .CorrespondeBlanquearInfoAfectacionesEnEnvioABaseDeDatos( this.cTipo )
				.AgregarFuncionBlanquearInfoAfectacionesEnEnvioABaseDeDatos()
				.agregarLinea("")
			endif
			.AgregarFuncionActualizarDatosConsulta()
			.agregarLinea("")
			.AgregarFuncionCerrarTodosLosCursores()
			.AgregarFuncionVaciadoDeTablas()
			.agregarLinea("")
			.AgregarFuncionArmarResultadoFinal()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionUnificarMemos() as Void
		local lcLinea as Integer

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function UnificarCamposMemos() as String", 1 )

			if this.oColLlamadasLlenarCamposMemos.count > 0
				.AgregarLinea( "", 1 )
				.AgregarLinea( "if _Screen.zoo.app.TipodeBase = 'NATIVA'", 2 )
				for each lcLinea in this.oColLlamadasLlenarCamposMemos 
					this.agregarLinea( lcLinea, 3 )
				endfor
				.AgregarLinea( "endif", 2 )
			endif	
			this.oColLlamadasLlenarCamposMemos.remove( -1 )

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarLineaCargarDatosEnCursores( tnTab as Integer ) as Void
		This.AgregarLinea( ".CargarDatosEnCursores( toWhere )", tnTab )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtener() as Void
		local lnTab as Integer
		lnTab = 2

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function Obtener( toWhere as object ) as String", lnTab )
			.AgregarLinea( "local lcRetorno as string, loDatos as object, loContainer as zooDataContainer of zooDataContainer.prg", lnTab + 1 )
			.AgregarLinea( "Try", lnTab + 1 )
			.AgregarLinea( "lcRetorno = dodefault( toWhere )", lnTab + 2 )
			.AgregarLinea( "with this", lnTab + 2 )
			.AgregarInstanciaZooData( lnTab + 3 )
			.AgregarLinea( "*Se crean los cursores", lnTab + 3 )
			.AgregarLinea( ".IniciarCursores( toWhere, loDatos )", lnTab + 3 )
			.AgregarLlamadaATransformacion( lnTab + 3 )
			.AgregarLinea( "*Se cargan los datos en los cursores segun los filtros seleccionados", lnTab + 3 )
			.AgregarLineaCargarDatosEnCursores( lnTab + 3 )
			.AgregarLlamadaAOrdenarCursores( lnTab )

			.AgregarLinea( "*Se pasan las tablas de observaciones de nativa a campos memos", lnTab + 3 )			
			.AgregarLinea( ".UnificarCamposMemos()", lnTab + 3 )
			.AgregarLlamadaActualizarInfoAdicional( lnTab + 3 )
			if .CorrespondeBlanquearInfoAfectacionesEnEnvioABaseDeDatos( this.cTipo )
				.AgregarLlamadaBlanquearInfoAfectacionesEnEnvioABaseDeDatos( lnTab + 3 )
			endif

			.AgregarLinea( "*Se actualizan la fecha y estado de la consulta en las tablas originales", lnTab + 3 )
			.AgregarLlamadaActualizarDatosConsulta( lnTab )

			.AgregarLinea( "", lnTab + 3 )
			.AgregarLinea( ".DespuesDeObtener( toWhere )", lnTab + 3 )
			.AgregarLinea( "", lnTab + 3 )
			
			.AgregarLineasDeDataContainer( lnTab + 3 )
			
			.AgregarLinea( "" )
			.AgregarLinea( ".CerrarTodosLosCursores( toWhere, loDatos )", lnTab + 3 )
			.AgregarLinea( "endwith", lnTab + 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "loDatos.release()", lnTab + 2 )
			.AgregarLinea( "" )

			.AgregarLinea( "Catch To loError", lnTab + 1 )
*-----------------		
			.AgregarLinea( "local lcMensajeError as String , lnI as Integer , loInformacion as Object ", lnTab + 2 )
			.AgregarLinea( "lcMensajeError = ''", lnTab + 2 )
			.AgregarLinea( "if loError.ErrorNo = 2071 ", lnTab + 2 )
			.AgregarLinea( "*Error generado por el Usuario  ", lnTab + 2 )
			.AgregarLinea( "This.CargarInformacion( loError.UserValue.ObtenerInformacion() )", lnTab + 3 )
			.AgregarLinea( "loInformacion = this.obtenerinformacion()", lnTab + 3 )
			.AgregarLinea( "with loInformacion", lnTab + 3 )
			.AgregarLinea( "if .hayInformacion()", lnTab + 4 )
			.AgregarLinea( "for lnI = 1 to loInformacion.count", lnTab + 5 )
			.AgregarLinea( "lcMensajeError = lcMensajeError + chr(13) + loInformacion.item[ lnI ].cMensaje", lnTab + 6 ) 
			.AgregarLinea( "endfor", lnTab + 5 )
			.AgregarLinea( "endif	", lnTab + 4 )
			.AgregarLinea( "endwith", lnTab + 3 )
			.AgregarLinea( "endif ", lnTab + 2 )
			
*-----------------			
			.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", lnTab + 2 )
			.AgregarLinea( "With loEx", lnTab + 2 )
			.AgregarLinea( ".Message = 'Se Produjo un error al realizar la consulta de la " + alltrim( this.cPrefijo ) + " " + ;
			 alltrim( transform( this.oObjeto.cNombre ) ) + "'+ lcMensajeError ", lnTab + 3 )
			.AgregarLinea( ".Details = loError.Message + lcMensajeError ", lnTab + 3 )
			.AgregarLinea( ".ErrorNo = 1", lnTab + 3 )
			.AgregarLinea( ".Grabar()", lnTab + 3 )
			.AgregarLinea( ".Throw()", lnTab + 3 )
			.AgregarLinea( "EndWith", lnTab + 2 )
			.AgregarLinea( "EndTry", lnTab + 1 )

			.AgregarLinea( "return lcRetorno", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLineasDeDataContainer( tnTab as Integer ) as Void
		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "loContainer = newobject( 'zooDataContainer', 'zooDataContainer.prg' )", tnTab )
			.AgregarLinea( "*Se llena el zoocontainer", tnTab )
			.AgregarLinea( ".ArmarResultadoFinal( toWhere, loContainer )", tnTab )
			.AgregarLinea( "*Se crea el archivo fisico del zoocontainer con los datos de la consulta", tnTab )
			.AgregarLinea( "lcRetorno = loContainer.Serializar( .t. )", tnTab )
			.AgregarLinea( "loContainer.Release()", tnTab )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaActualizarDatosConsulta( tnTab as Integer ) as Void
			.AgregarLinea( ".ActualizarDatosConsulta( toWhere, loDatos )", tnTab + 4 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivo() as Void
		dodefault()
		with this
			.cCacheActiva = "cBuffer"
			.CacheIniciarCursores = ""
			.CacheCargarDatosEnCursores = ""
			.CacheTemp = ""
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionIniciarCursores() as Void
		local lnTab as Integer
		lnTab = 2

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.cCacheActiva = "cBuffer"
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function IniciarCursores( toWhere as object, loDatos as object ) as void", lnTab )
			.AgregarLinea( "Local lcWhere as String", lnTab + 1 )
			.AgregarLinea( "dodefault( toWhere, loDatos )", lnTab + 1 )
			.AgregarLinea( "with this", lnTab + 1 )

			* En algunos casos el tamaño de los Buffer es muy grande para la funcion AgregarLinea para incluir al buffer general
			=strtofile( .cBuffer, "tGFPC.txt", 0 )
			=strtofile( .CacheIniciarCursores, "tGFPC.txt", 1 )
			.cBuffer = filetostr( "tGFPC.txt" )
			delete file "tGFPC.txt"

			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCargarDatosEnCursores() as Void
		local lnTab as Integer
		lnTab = 2

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.cCacheActiva = "cBuffer"
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function CargarDatosEnCursores( toWhere as object ) as Void", lnTab )
			.AgregarLinea( "local lcWhere as string, lcIn as string, llFin as boolean, llPrimera as boolean, lnRecursividad as Integer", lnTab + 1 )
			.AgregarLinea( "dodefault( toWhere )", lnTab + 1 )
			.AgregarLinea( "with this", lnTab + 1 )
			.AgregarLinea( "llFin = .f.", lnTab + 2 )
			.AgregarLinea( "llPrimera = .t.", lnTab + 2 )
			.AgregarLinea( "lnRecursividad = 0", lnTab + 2 )
			.AgregarLinea( "do while !llFin", lnTab + 2 )
			.AgregarLinea( "llFin = .t.", lnTab + 3 )
			.AgregarLinea( "" )
			.AgregarLinea( "set collate to 'SPANISH'", lnTab + 5 )

			* En algunos casos el tamaño de los Buffer es muy grande para la funcion AgregarLinea para incluir al buffer general
			=strtofile( .cBuffer, "tGFPC.txt", 0 )
			=strtofile( .CacheCargarDatosEnCursores, "tGFPC.txt", 1 )
			.cBuffer = filetostr( "tGFPC.txt" )
			delete file "tGFPC.txt"

			.AgregarLinea( "llPrimera = .f.", lnTab + 3 )
			.AgregarLinea( "enddo", lnTab + 2 )
			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionActualizarDatosConsulta() as Void
		local lnTab as Integer
		lnTab = 2

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function ActualizarDatosConsulta( toWhere as object, loDatos as object ) as Void", lnTab )
			.AgregarLinea( "dodefault( toWhere )", lnTab + 1 )
			.AgregarLinea( "with this", lnTab + 1 )
			.AgregarActualizarEstado( lnTab + 2 )
			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCerrarTodosLosCursores() as Void
		local lnTab as Integer
		lnTab = 2

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function CerrarTodosLosCursores( toWhere as object, loDatos as object ) as Void", lnTab )
			.AgregarLinea( "dodefault( toWhere, loDatos )", lnTab + 1 )
			.AgregarLinea( "with this", lnTab + 1 )
			.CerrarCursores()
			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionVaciadoDeTablas() as Void
		local lnTab as Integer, lcCursorHer as String, lcEntidad as String, lcTabla as String
				
		lnTab = 1

		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", lnTab )
			.AgregarLinea( "function VaciadoDeTablas( toWhere as object, loDatos as object ) as void", lnTab )
			.AgregarLinea( "dodefault( toWhere, loDatos )", lnTab + 1 )

			with this as GeneradorConsultas of GeneradorConsultas.prg

				.AgregarLinea( "delete from " + alltrim( .ObtenerTabla( .oObjeto.cEntidad ) ), lnTab + 2 )

				lcCursorHer = sys( 2015 ) + "_AddConsultaConDependencia"

				select distinct Entidad from ( .cCursorHerencia ) ;
					order by Orden ;
					into cursor ( lcCursorHer )

				scan
					lcEntidad = &lcCursorHer..Entidad
					lcTabla = .ObtenerTabla( lcEntidad )

					if !empty( lcTabla )
						.AgregarLinea( "delete from " + alltrim( lcTabla ) , lnTab + 2 )
					endif
				endscan
				use in select( lcCursorHer )
			endwith
		
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarInstanciaZooData( tnTab as Integer ) as Void
		**Firma de metodo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAperturaTablas( tcEntidad as String, tcTabla as String, tnTab as Integer ) as Void
		**Firma de metodo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarConsultasVacias() as Void
		This.lVacia = .T.
		This.AgregarConsultas()
		This.lVacia = .F.
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSubentidadesYDetallesYMemos( tcEntidades as String, tnRecursividad as integer ) as Void
		local lcEntidades as string, lcEntidad as string, lcDetalles as string, lcMemos as string, ;
			lcSubEntidades as string, lcSubEntidadesDeDetalles as string, lcEntidadesEnBasea as String 

		local array laEntidades[ 1 ]
		lcEntidadesEnBasea = ""

		with this as GeneradorConsultas of GeneradorConsultas.prg
			if tnRecursividad >= 0
				alines( laEntidades, tcEntidades, 8, "," )
				for each lcEntidad in laEntidades
					lcEntidad = upper( alltrim( strtran( lcEntidad, "'", "" ) ) )
					lcSubEntidades = .ObtenerSubEntidades( lcEntidad )
					lcDetalles = .ObtenerDetallesNormalizados( lcEntidad )
					lcSubEntidadesDeDetalles = .ObtenerSubEntidadesDeDetallesDesnormalizados( lcEntidad )
					if !empty( lcEntidad )
						lcEntidadesEnBasea = .ObtenerEntidadesEnBasea( lcEntidad )
					endif
					lcMemos = .ObtenerMemos( lcEntidad )

					if !empty( lcSubEntidadesDeDetalles )
						.ObtenerSubentidadesYDetallesYMemos( lcSubEntidadesDeDetalles, tnRecursividad - 1 )
					endif
					if !empty( lcSubEntidades )
						.ObtenerSubentidadesYDetallesYMemos( lcSubEntidades, tnRecursividad - 1 )
					endif
					if !empty( lcDetalles )
						.ObtenerSubentidadesYDetallesYMemos( lcDetalles, tnRecursividad - 1 )
					endif
					if !empty( lcEntidadesEnBasea )
						.ObtenerSubentidadesYDetallesYMemos( lcEntidadesEnBasea, tnRecursividad - 1 )
					endif
				endfor
			else
				alines( laEntidades, tcEntidades, 8, "," )
				for each lcEntidad in laEntidades
					lcEntidad = upper( alltrim( strtran( lcEntidad, "'", "" ) ) )
					lcDetalles = .ObtenerDetallesNormalizados( lcEntidad )
					lcMemos = .ObtenerMemos( lcEntidad )
				endfor
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadesEnBasea( tcEntidad as String ) as string
		local lcEntidad as string, lcCursor as string, lcRetorno as string, lcSubEntidad as string

		if this.oCacheDatos.Buscar( "ENTIDADESENBASEA_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheDatos.Item[ "ENTIDADESENBASEA_" + upper( tcEntidad ) ]
		else
			lcCursor = sys( 2015 ) + "_GetEntidadEnBaseA"
			lcRetorno = ""

			select c2.descripcion as SubEntidad, c.descripcion as Entidad from c_comprobantes c, c_relacomprobantes r, c_comprobantes c2 ;
				where alltrim(upper(c.descripcion)) == tcEntidad and c.id = r.idcomp and ;
					c2.id = r.idcompafectado ;
				into cursor ( lcCursor )
				
			scan
				lcSubEntidad = upper( alltrim( &lcCursor..SubEntidad ) )
				lcRetorno = this.AgregarSubEntidad( lcSubEntidad, &lcCursor..Entidad, "B", lcRetorno )
			endscan
			use in select( lcCursor )
		
			this.oCacheDatos.Agregar( lcRetorno, "ENTIDADESENBASEA_" + upper( tcEntidad ) )
		endif
				
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSubEntidades( tcEntidad as String ) as string
		local lcEntidad as string, lcCursor as string, lcRetorno as string, lcSubEntidad as string

		if this.oCacheDatos.Buscar( "SUBENTIDADES_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheDatos.Item[ "SUBENTIDADES_" + upper( tcEntidad ) ]
		else
			lcCursor = sys( 2015 ) + "_GetSubEntidades"
			lcRetorno = ""

			select ClaveForanea as SubEntidad, Entidad from c_Estructura Dic ;
				where rtrim( upper( Dic.Entidad ) ) == tcEntidad and ;
					!empty( Dic.ClaveForanea ) and ( !empty( campo ) or !empty( tabla ) ) ;
				into cursor ( lcCursor )
				
			scan
				lcSubEntidad = upper( alltrim( &lcCursor..SubEntidad ) )
				lcRetorno = this.AgregarSubEntidad( lcSubEntidad, &lcCursor..Entidad, "E", lcRetorno )
			endscan
			use in select( lcCursor )
		
			this.oCacheDatos.Agregar( lcRetorno, "SUBENTIDADES_" + upper( tcEntidad ) )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSubEntidadesDeDetallesDesnormalizados( tcEntidad as String ) as string
		local lcEntidad as string, lcCursor as string, lcRetorno as string, lcSubEntidad as string

		if this.oCacheFunciones.Buscar( "SUBENTIDADESDEDETALLESDESNORMALIZADOS_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheFunciones.Item[ "SUBENTIDADESDEDETALLESDESNORMALIZADOS_" + upper( tcEntidad ) ]
		else
			lcCursor = sys( 2015 ) + "_GetSubEntidadesDetDesno"
			lcRetorno = ""

			select ClaveForanea as SubEntidad, Entidad from c_Estructura Dic ;
				where !empty( Dic.Claveforanea ) and ;
					alltrim( upper( Entidad ) ) in ;
					( select upper( right( Dic2.Dominio, len( dic2.dominio ) - 7 ) ) ;
						from c_Estructura Dic2 ;
						where rtrim( upper( Dic2.Entidad ) ) == tcEntidad and empty( campo ) and ;
								left( upper( Dic2.Dominio ), 7 ) == "DETALLE" );
			 into cursor ( lcCursor )
				 			
			scan
				lcSubEntidad = upper( alltrim( &lcCursor..SubEntidad ) )
				lcRetorno = this.AgregarSubEntidad( lcSubEntidad, &lcCursor..Entidad, "D", lcRetorno )
			endscan
			use in select( lcCursor )
		
			this.oCacheFunciones.Agregar( lcRetorno, "SUBENTIDADESDEDETALLESDESNORMALIZADOS_" + upper( tcEntidad ) )
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetallesNormalizados( tcEntidad as String ) as Void
		local lcEntidad as string, lcCursor as string, lcRetorno as string, lcSubEntidad as string

		if this.oCacheDatos.Buscar( "DETALLESNORMALIZADOS_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheDatos.Item[ "DETALLESNORMALIZADOS_" + upper( tcEntidad ) ]
		else
			lcCursor = sys( 2015 ) + "GetDetallesNormaliz"
			lcRetorno = ""

			select right( Dic.Dominio, len( dic.dominio ) - 7 ) as SubEntidad, Entidad from c_Estructura Dic ;
				where rtrim( upper( Dic.Entidad ) ) == tcEntidad and !empty( campo ) and ;
					left( upper( Dic.Dominio ), 7 ) == "DETALLE" ;
				 into cursor ( lcCursor )
				
			scan
				lcSubEntidad = upper( alltrim( &lcCursor..SubEntidad ) )
				lcRetorno = this.AgregarSubEntidad( lcSubEntidad, &lcCursor..Entidad, "I", lcRetorno )
			endscan
			use in select( lcCursor )
		
			this.oCacheDatos.Agregar( lcRetorno, "DETALLESNORMALIZADOS_" + upper( tcEntidad ) )
		endif

		return lcRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMemos( tcEntidad as String ) as string
		local lcRetorno as string, lcCursor as string

		lcRetorno = ""

		if this.oCacheDatos.Buscar( "MEMOS_" + upper( tcEntidad ) )
			lcRetorno = this.oCacheDatos.Item[ "MEMOS_" + upper( tcEntidad ) ]
		else
			lcCursor = sys( 2015 ) + "_GetMemos"
			with this as GeneradorConsultas of GeneradorConsultas.prg
				select Campo, Atributo from c_Estructura ;
						where alltrim( upper( entidad ) ) == tcEntidad and TipoDato = "M" ;
					into cursor ( lcCursor )
				if _tally > 0
					select ( lcCursor )
					scan
						insert into ( .cCursorHerencia ) ;
							( Entidad, Dependencia, Tipo, Orden, DependenciaOrig ) values ;
							( upper( tcEntidad + "_" + alltrim( &lcCursor..Campo ) ), upper( tcentidad ), "O", 9999, upper( tcentidad ) )
						
						select ( lcCursor )
					endscan
				endif
				use in select( lcCursor )
			endwith
		
			this.oCacheDatos.Agregar( lcRetorno, "MEMOS_" + upper( tcEntidad ) )
		endif
		
		return lcRetorno		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarSubEntidad( tcSubEntidad as String, tcentidad as string, tcTipo as string, tcAcumulador as string ) as string
		local lcRetorno as string, lcCursor as string

		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcCursor = sys( 2015 ) + "AddSubentidad"
			if at( "'" + tcSubEntidad + "'", upper( .cEntidades ) ) = 0
				tcAcumulador = tcAcumulador + ",'" + tcSubEntidad + "'"
				.cEntidades = .cEntidades + ",'" + tcSubEntidad + "'"
			endif

			select Entidad from ( .cCursorHerencia ) ;
					where alltrim( upper( entidad ) ) == tcSubEntidad and ;
						alltrim( upper( Dependencia ) ) == alltrim( upper( tcEntidad ) ) ;
				into cursor (lcCursor )
			if _tally = 0
				insert into ( .cCursorHerencia ) ;
					( Entidad, Dependencia, Tipo, Orden, DependenciaOrig ) values ;
					( upper( tcSubEntidad ), upper( tcentidad ), tcTipo, 9999, upper( tcEntidad ) )
			endif
			use in select( lcCursor )
		endwith
		
		return tcAcumulador
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarConsultas() as void
		local lcEntidadesAgregadas as string

		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcEntidadesAgregadas = .AgregarConsultasSinDependencia()
			.OrdenarDependencia( lcentidadesAgregadas )
			.AgregarConsultasConDependencia()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarConsultasSinDependencia() as string
		local lcEntidad as string, lcEntidades as string, lcRetorno as string
		local array laEntidades[ 1 ]

			lcRetorno = ""
		
		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcEntidad = this.oObjeto.cEntidad
			if this.lRecursivo
				lcDependenciaMemo = this.ObtenerDependenciaMemo( lcEntidad  )
						
				lcCursor = .GenerarCursorEntidadesRelacionados( lcEntidad  )
				if reccount( lcCursor ) > 0
					if empty( lcDependenciaMemo )			
						.AgregarConsultaEspecifica( alltrim( lcEntidad  ), lcCursor ) &&, lcCursorAtributos )
					endif
				else
					.AgregarConsultaEspecifica( lcEntidad, "" )
				endif
			else
				.AgregarConsultaEspecifica( lcEntidad, "" )
			endif
			lcRetorno = iif( !empty( lcRetorno ), ",", "" ) + "'" + alltrim( upper( lcEntidad ) ) + "'"
		endwith
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function OrdenarDependencia( tcEntidades as String, tnOrden as Integer ) as string
		local lcCursorHer as string, lnOrden as integer, lcCursorEntidades as string, llEncontro as boolean, ;
				lcCursorEntidadesAux as string, lcCursorEntidadesAux2 as string, lcCursorEntidadesAux3 as string, ;
				lnTally as integer, lcAnsiAnt as string

		llEncontro = .f.
		lcCursorEntidades = sys( 2015 ) + "_OrdenarDependencia1"
		lcCursorEntidadesAux = sys( 2015 ) + "_OrdenarDependencia2"
		lcCursorEntidadesAux2 = sys( 2015 ) + "_OrdenarDependencia3"
		lcCursorEntidadesAux3 = sys( 2015 ) + "_OrdenarDependencia4"

		if vartype( tnOrden ) # "N"
			tnOrden = 1
			.ArreglarHerenciaDetallesDesnormalizados()
			.OrdenarObservacionesYEntidadesBases()
		endif
			
		with this as GeneradorConsultas of GeneradorConsultas.prg

			if empty( tcEntidades )
				lnTally = 0
			else
				lcAnsiAnt = set("Ansi")
				set ansi on
				
				select distinct Her.Entidad from ( .cCursorHerencia ) Her ;		
						where	Her.Orden = 9999 and ;
								upper( alltrim( Her.Dependencia ) ) in ( &tcEntidades ) ;
						into cursor ( lcCursorEntidadesAux )

				set ansi &lcAnsiAnt

				select * from ( .cCursorHerencia ) Her ;		
						where upper( Her.Entidad ) in ( Select upper( Entidad )from ( lcCursorEntidadesAux ) ) ;
						into cursor ( lcCursorEntidadesAux2 )

				select Entidad, count( Entidad ) as cant from ( lcCursorEntidadesAux2 ) Her group by Entidad ;
						into cursor  ( lcCursorEntidadesAux3 )
						
				select Entidad from ( lcCursorEntidadesAux3 ) Her where cant = 1 ;
						into cursor  ( lcCursorEntidades )
						
				use in select ( lcCursorEntidadesAux )
				use in select ( lcCursorEntidadesAux2 )
				use in select ( lcCursorEntidadesAux3 )
				
				lnTally = _tally
			endif
			if lnTally > 0
				llEncontro = .t.
			else
				select distinct Her.Dependencia from ( .cCursorHerencia ) Her ;		
						where	Her.Orden = 9999 ;
						into cursor ( lcCursorEntidadesAux3 )
						
				select distinct Her.Dependencia from ( lcCursorEntidadesAux3 ) Her ;
						where	upper( Her.Dependencia ) not in ;
										( select upper( Entidad ) from ( .cCursorHerencia ) where Orden = 9999 ) ;
						into cursor ( lcCursorEntidadesAux2 )

				select distinct Her.Entidad from ( .cCursorHerencia ) Her ;
						where	Her.Orden = 9999 and ;
								upper( Her.Dependencia ) in ( select upper( Dependencia ) from ( lcCursorEntidadesAux2  ) ) ;
						into cursor ( lcCursorEntidades )
				if _tally > 0
					llEncontro = .t.
				endif

				use in select ( lcCursorEntidadesAux3 )
				use in select ( lcCursorEntidadesAux2 )
			endif

			if llEncontro
				update ( .cCursorHerencia ) set Orden = tnOrden ;
						where Entidad in ;
							( select Entidad from ( lcCursorEntidades ) )

				select ( lcCursorEntidades )
				scan
					tcEntidades = tcEntidades + ",'" + alltrim( upper( &lcCursorEntidades..Entidad ) ) + "'"
				endscan

				tnOrden = tnOrden + 1
				.OrdenarDependencia( tcEntidades, tnOrden )
			endif
			
			use in select ( lcCursorEntidades )

		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ArreglarHerenciaDetallesDesnormalizados() as string
		local lcCursor as string
		with this as GeneradorConsultas of GeneradorConsultas.prg

			lcCursor = sys( 2015 ) + "_ArreglarHerenciaDetalleDesno"
			select distinct nvl( Her.Dependencia, "" ) as dependencia from ( .cCursorHerencia ) Her where tipo = "D" ;
				into cursor ( lcCursor )
			scan
				update ( .cCursorHerencia ) ;
					set Dependencia = ( select nvl( Entidad, "" ) as entidad from c_Estructura ;
						left join  ( lcCursor ) on ;
							upper( alltrim( c_estructura.Dominio ) ) == "DETALLE" + upper( alltrim( &lcCursor..Dependencia ) ) );
				where alltrim( upper( Dependencia ) ) == alltrim( upper( &lcCursor..Dependencia ) )
			endscan
			use in select ( lcCursor )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function OrdenarObservacionesYEntidadesBases() as string
		local lcCursor as string

		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcCursor = sys( 2015 ) + "_OrdenarObservacioYentidadeS"
			select Entidad from ( .cCursorHerencia ) ;		
					where upper( Entidad ) not in ( Select upper( Dependencia ) from ( .cCursorHerencia ) ) ;
					into cursor ( lcCursor )
			scan
				update ( .cCursorHerencia ) ;
					set Orden = 9998 ;
				where Entidad = &lcCursor..Entidad
			endscan
			use in select ( lcCursor )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarConsultasConDependencia() as string
		local lcCursorHer as string, lcCursor as string, lcDependenciaMemo as string

		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcCursorHer = sys( 2015 ) + "_AddConsultaConDependencia"

			select distinct Entidad from ( .cCursorHerencia ) ;	
				where Entidad != .cTipo;
				order by Orden ;
				into cursor ( lcCursorHer )

			scan
				lcDependenciaMemo = this.ObtenerDependenciaMemo( &lcCursorHer..Entidad )
					
				lcCursor = .GenerarCursorEntidadesRelacionados( &lcCursorHer..entidad )
				if empty( lcDependenciaMemo )
					.AgregarConsultaEspecifica( alltrim( &lcCursorHer..Entidad ), lcCursor ) &&, lcCursorAtributos )
				endif
				use in select( lcCursor )
				
				select ( lcCursorHer )
			endscan
			use in select( lcCursorHer )
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function AgregarLineaEntidad( tcEntidad As String, tnTab as Integer ) as Void
		this.AgregarLinea( "*** Entidad: " + tcEntidad, tnTab )
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDependenciaMemo( tcEntidad as string) as string
		local lcDependenciaMemo as String, lcCursorAux as string
		
		with this as GeneradorConsultas of GeneradorConsultas.prg
			if this.oCacheDatos.Buscar( "DEPENDENCIAMEMO_" + upper( tcEntidad ) )
				lcDependenciaMemo = this.oCacheDatos.Item[ "DEPENDENCIAMEMO_" + upper( tcEntidad ) ]
			else
				lcCursorAux = sys( 2015 ) + "_ObtenerDependenciaMemo"

				lcDependenciaMemo = ""
				select Entidad, dependenciaOrig, tipo from ( .cCursorHerencia ) her ;
					where tcEntidad == her.Entidad and her.Tipo = "O" into cursor ( lcCursorAux )
			
				if _tally > 0
					lcDependenciaMemo = alltrim( &lcCursorAux..dependenciaOrig )
				endif
			
				use in select ( lcCursorAux )

				this.oCacheDatos.Agregar( lcDependenciaMemo, "DEPENDENCIAMEMO_" + upper( tcEntidad ) )
			endif
		endwith
		
		return lcDependenciaMemo 
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCursorEntidadesRelacionados( tcEntidad as String ) as string
		local lcEntidad as string, lcEntidades as string, lcCursur as string, lcCursorH as string, lcCursurAux as string, lcItemArticulos as String
		lcCursor = sys( 2015 ) + "_CursorEntidadesRelacionados1"
		lcCursorAux = sys( 2015 ) + "_CursorEntidadesRelacionados2"
		lcCursorH = sys( 2015 ) + "_CursorEntidadesRelacionados3"

		with this as GeneradorConsultas of GeneradorConsultas.prg
			select * from ( .cCursorHerencia ) where upper( alltrim( tcEntidad ) ) == upper( alltrim( Entidad ) ) ;
				into cursor ( lcCursorH )
			
			scan
				do case
					case &lcCursorH..Tipo = "E" 
						select Dic.Entidad, Dic.Campo, Dic.TipoDato from c_Estructura Dic ;
							where alltrim( upper( dic.entidad ) )== alltrim( upper( &lcCursorH..DependenciaOrig ) ) and ;
								alltrim( upper( dic.ClaveForanea ) ) == alltrim( upper( tcEntidad ) ) ;
						into cursor ( lcCursorAux )
				
					case inlist( &lcCursorH..Tipo, "I", "O" )
						select Dic.Entidad, Dic.Campo, Dic.TipoDato from c_Estructura Dic ;
							where upper( alltrim( dic.Entidad ) ) == alltrim( upper( &lcCursorH..DependenciaOrig ) ) and ;
								dic.ClavePrimaria ;
						into cursor ( lcCursorAux )

					*Entidades de detalles desnormalizados
					case &lcCursorH..Tipo = "D"
						select Dic.Entidad, Dic.Campo, Dic.TipoDato from c_Estructura Dic ;
							where upper( alltrim( dic.Entidad ) ) == alltrim( upper( &lcCursorH..DependenciaOrig ) ) and ;
								alltrim( upper( dic.ClaveForanea ) ) == alltrim( upper( tcEntidad ) ) ;
						into cursor ( lcCursorAux )

						select Dic.Entidad, &lcCursorAux..Campo as campo,&lcCursorAux..TipoDato as TipoDato from c_Estructura Dic, ( lcCursorAux ) ;
							where upper( alltrim( dic.Dominio ) ) == "DETALLE" + alltrim( upper( &lcCursorAux..Entidad ) ) ;
						into cursor ( lcCursorAux )

					*Entidades en base a
					case &lcCursorH..Tipo = "B"
						create cursor ( lcCursorAux ) ( Entidad c(25), Campo c(100), TipoDato c( 1 ))
						lcItemArticulos = This.ObtenerItemArticulos( alltrim( upper( &lcCursorH..DependenciaOrig ) ) )
						if This.EsComprobanteDeVentas( alltrim( upper( &lcCursorH..DependenciaOrig ) ) )
							insert into  ( lcCursorAux ) values ( lcItemArticulos, 'Padl( AfeTipoCom,2,"0" )+ AfeLETRA + Padl( AfePTOVEN, 4, "0" ) + Padl( AfeNUMCOM, 8, "0" )', 'C' )
						else
							insert into  ( lcCursorAux ) values ( lcItemArticulos, 'AFE_COD', 'C' )						
						Endif
				endcase

				if used( lcCursor )
					select * from ( lcCursor ) union select * from ( lcCursorAux ) into cursor ( lcCursor ) readwrite
				else
					select * from ( lcCursorAux ) into cursor ( lcCursor ) readwrite
				endif
				
				select ( lcCursorH )
			endscan
		endwith
		
		use in select( lcCursorAux )
		use in select( lccursorH )
		return lcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemArticulos( tcEntidad as String ) as String
		local lcRetorno as String
		lcRetorno = ""
		select c_Diccionario
		locate for upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and upper( alltrim( Atributo ) ) == upper( alltrim( "FACTURADETALLE" ) )
		if found( )
			lcRetorno = upper( alltrim( substr( alltrim( c_Diccionario.Dominio ), 8 ) ) )
		endif
		return lcRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeVentas( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		select c_Entidad
		locate for upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) )
		if "<VENTAS>" $ upper( Funcionalidades )
			llRetorno = .T.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarConsultaEspecifica( tcEntidad as String, tcCursorDependencias as string ) as void
		local lcSql as string, lcCampos as String, lcTabla as String, lcCursorAtributos as string, lcTipoDato as String, ;
			lcCampoCP as string, lcIn as string, loEx as Exception, lcTextoIn as string, lcFiltro as string
			
		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcCursorAtributos = .ObtenerCursorAtributos( tcEntidad )
			lcTabla = .ObtenerTabla( tcEntidad )
			lcCampoCP = .ObtenerCampoClavePrimaria( tcEntidad )
			lcCampos = .ObtenerCadenaDeCampos( lcCursorAtributos, lcTabla )
			lcFiltro = .ObtenerFiltro( tcEntidad, lcTabla )
			lcTipoDato = .ObtenerTipoDato( tcEntidad, lcCampoCP )
			use in select( lcCursorAtributos )

			if tcEntidad = this.oObjeto.cEntidad and this.lRecursivo
				lcIn = ""				
			else
				lcIn = .ObtenerClausulasIN( tcEntidad, lcCampoCP, tcCursorDependencias, lcTipoDato  )
			endif
			lcInRecursiva = .ObtenerClausulasINRecursivas( tcEntidad, lcCampoCP, tcCursorDependencias, lcTipoDato )

			if !empty(lcTabla) and !empty( lcCampos)
				.EscribirConsultaEspecifica( tcEntidad, lcTabla, lcCampos, lcFiltro, lcIn, lcInRecursiva  )
			endif 
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarBaseDedatos( tcCampoPk as String, tcCampoDependencia as String, tcTipoDato as String, tcRetorno as String ) as Void
		if "+" $ tcCampoDependencia and empty( tcRetorno )
			tcCampoPk = 'Padl( FactTipo,2,"0" )+ fLETRA+ Padl( fPTOVEN, 4, "0" ) + Padl( fNUMCOMP, 8, "0" )'
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarConsultaMemoEspecifica( tcEntidad as String, tcDependencia as string, tcCursorDependencias as string ) as void
		local lcSql as string, lcCampos as String, lcTabla as String, lcCursorAtributos as string, lcInRecursiva as String, lcTipoDato as String , ;
			lcCampoCP as string, lcIn as string, loEx as Exception, lcTextoIn as string, lcFiltro as string, lcCampoMemo as String
			
		with this as GeneradorConsultas of GeneradorConsultas.prg
			lnguion = at( "_", tcEntidad )
			lcTabla = .ObtenerTabla( tcDependencia ) + substr( tcEntidad, lnguion, len( tcEntidad ) - lnguion + 1 )
			lcCampoCP = .ObtenerCampoClavePrimaria( tcDependencia )
			lcCampos = " * "
			lcFiltro = ""
			lcCampoMemo = substr( tcEntidad, lnguion + 1 )
			lcTipoDato = .obtenertipodato( tcEntidad, lcCampoCP )
			lcIn = .ObtenerClausulasIN( tcEntidad, lcCampoCP, tcCursorDependencias, lcTipoDato )
			lcInRecursiva = .ObtenerClausulasINRecursivas( tcEntidad, lcCampoCP, tcCursorDependencias, lcTipoDato )

			.EscribirConsultaEspecifica( tcEntidad, lcTabla, lcCampos, lcFiltro, lcIn, lcInRecursiva  )

			if !.lVacia
				this.oColLlamadasLlenarCamposMemos.add( [this.LlenarCampoMemo( "] + this.cPrefijoCursor + tcDependencia + [", "] + ;
					lcCampoMemo + [", "] + lcCampoCP + [", "] + this.cPrefijoCursor + tcEntidad + [" )] )
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirConsultaEspecifica( tcEntidad as string, tcTabla as string, tcCampos as string, ;
			tcFiltro as string, tcIn as string, tcInRecursiva as string ) as string
		local lcTextoIn as string, lcSql as string, lnTab as Integer, lcCampos as String, lcOrderBy as string, ;
			llAgregaCondicionCentraliza as Boolean, lcIndice as String, lcIniciarCursores as String, lcCargarDatosEnCursores as String, lcLineaNew as String, ;
			llRecursiva as Boolean

		lcIndice = upper(tcEntidad) + sys(2007, tcCampos + tcFiltro + tcIn + tcInRecursiva ) 
		lcIniciarCursores = "ECE_IC" + lcIndice
		lcCargarDatosEnCursores = "ECE_CDC" + lcIndice
		
		lnTab = 5
		with this as GeneradorConsultas of GeneradorConsultas.prg
			if !.oCacheFunciones.Buscar( lcIniciarCursores )
				.CacheTemp = ""
				.cCacheActiva = "CacheTemp"
				.AgregarLinea( "*** Entidad: " + tcEntidad, lnTab - 1 )
				.AgregarAperturaTablas( tcEntidad, tcTabla, lnTab )
				lcSql = "select " + tcCampos + " from " + tcTabla + " Where .F. into cursor " + this.cPrefijoCursor + tcEntidad + " readwrite"
				.AgregarLinea( "text to lcConsultaEspecifica noshow ", lnTab )
				.AgregarLinea( lcSql, lnTab + 1 )
				.AgregarLinea( "endtext", lnTab )
				.AgregarLinea( "try", lnTab )
				.AgregarLinea( "&lcConsultaEspecifica", lnTab + 1 )
				.AgregarLinea( "catch to loError", lnTab )
				.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", lnTab + 1 )
				.AgregarLinea( "endtry", lnTab )
				.oCacheFunciones.Agregar( .CacheTemp, lcIniciarCursores )
			endif
			.cCacheActiva = "CacheIniciarCursores"

			* Es lo unico que cambia de de una Entidad a Otra en el string This.IniciarAperturaDeTabla( P1, P2, null, <<ENTIDAD>>)
			lcLineaNew = strtran(.oCacheFunciones.item[ lcIniciarCursores ],"<<ENTIDAD>>",this.cTipo)
			.AgregarLinea( lcLineaNew, 0 )

			if !.oCacheFunciones.Buscar( lcCargarDatosEnCursores )
				.CacheTemp = ""
				.cCacheActiva = "CacheTemp"
				.AgregarLinea( "*** Entidad: " + tcEntidad, lnTab + 1 )
				llAgregaCondicionCentraliza = this.DebeAgregarCondicionCentraliza( tcEntidad ) and !this.EsRemitoComoMercEnTransito( tcEntidad )
				if llAgregaCondicionCentraliza
					.Agregarlinea( "if toWhere.lCentraliza or toWhere.lRequiereTransformacion" , lnTab  )
					lnTab = lnTab + 1
				endif
				.AgregarLinea( "if llPrimera", lntab )
				if empty( tcIn ) and !empty( tcInRecursiva )
					.AgregarLinea( "lcIn = ' .t. '", lntab + 1 )
				else
					.AgregarLinea( "lcIn = " + iif( empty( tcIn ), "''", tcIn ), lntab + 1 )
				endif
				.AgregarLinea( "lcWhere = .ObtenerWhere( '" + tcEntidad + "', toWhere )", lntab + 1 )
				if !empty( tcFiltro )
					.AgregarLinea( [lcWhere = lcWhere + iif( !empty( lcWhere ), ' and ', '' ) + "( ] + tcFiltro  + [ )" ], lntab + 1 )
				endif
				if !empty( tcIn )
					.AgregarLinea( "lcWhere = lcWhere + iif( !empty( lcWhere ), ' and ', '' ) + '(' + lcIn + ')' ", lntab + 1 )
				endif
				.AgregarLinea( "lcWhere = iif( !empty( lcWhere ), ' where ', '' ) + lcWhere ", lntab + 1 )
				if .EsAuditoria( tcEntidad )
					lcCampos = strtran( upper( tcCampos ), "ADT_EXT", ".T. as ADT_EXT" )
				else
					lcCampos = tcCampos
				endif
				lcOrderBy = .ObtenerOrderBy( tcEntidad )
				lcSql = "select " + lcCampos + " from " + tcTabla + " &lcWhere " + lcOrderBy + " into cursor " + this.cPrefijoCursor + tcEntidad 
				if !empty( tcInRecursiva )
					lcSql = lcsql + "aux2"
				endif
				lcSql = lcsql + " readwrite "
				.AgregarLinea( lcSql, lnTab + 1 )
				.AgregarLinea( "" )
				.AgregarLinea( "else", lntab )
				if !empty( tcInRecursiva )
					llRecursiva = ( tcEntidad = this.oObjeto.cEntidad and this.lRecursivo )
					lnTabAux = lnTab
					if llRecursiva
						.AgregarLinea( "if lnRecursividad < 7", lntab + 1 )
						lnTabAux = lnTab + 1
					endif
					.AgregarLinea( "lcWhere = ''", lnTabAux + 1 )
					.AgregarLinea( "lcIn = " + tcInRecursiva, lnTabAux + 1 )
					if !empty( tcFiltro )
						.AgregarLinea( [lcWhere = lcWhere + iif( !empty( lcWhere ), ' and ', '' ) + "( ] + tcFiltro  + [ )" ], lnTabAux + 1 )
					endif
					if !empty( tcInRecursiva )
						.AgregarLinea( "lcWhere = lcWhere + iif( !empty( lcWhere ), ' and ', '' ) + '(' + lcIn + ')' ", lnTabAux + 1 )
					endif
					.AgregarLinea( "lcWhere = iif( !empty( lcWhere ), ' where ', '' ) + lcWhere ", lnTabAux + 1 )
					lcSql = "select " + lcCampos + " from " + tcTabla + " &lcWhere into cursor " + this.cPrefijoCursor + tcEntidad + "Aux2 readwrite "
					.AgregarLinea( lcSql, lnTabAux + 1 )
					.AgregarLinea( "" )
					if llRecursiva
						.AgregarLinea( "endif", lntab + 1 )
					endif
				endif
				.AgregarLinea( "endif", lntab )
				lcOrderBy = .ObtenerOrderBy( tcEntidad )
				if !empty( tcInRecursiva )
					.AgregarLinea( "if !used( '" + this.cPrefijoCursor + tcEntidad + "' ) ", lntab )
					.AgregarLinea( "select * from " + this.cPrefijoCursor + tcEntidad + "Aux2 " + lcOrderBy + " into cursor " + this.cPrefijoCursor + tcEntidad + " readwrite ", lntab + 1 )
					.AgregarLinea( "else", lntab )
					.AgregarLinea( "select * from " + this.cPrefijoCursor + tcEntidad + " union ;", lntab + 1 )
					.AgregarLinea( "select * from " + this.cPrefijoCursor + tcEntidad + "aux2 " + lcOrderBy + " into cursor " + this.cPrefijoCursor + tcEntidad + " readwrite ", lntab + 1 )
					.AgregarLinea( "endif", lntab )
					.AgregarLinea( "" )
					.AgregarLinea( "select * from " + this.cPrefijoCursor + tcEntidad + "aux2 into cursor " + this.cPrefijoCursor + tcEntidad + "aux", lntab )
					.AgregarLinea( "" )
					.AgregarLinea( "if reccount( '" + this.cPrefijoCursor + tcEntidad + "aux' ) > 0", lntab )
					.AgregarLinea( "llFin = .f.", lntab + 1 )
					.AgregarLinea( "endif", lntab )
				endif
				if llAgregaCondicionCentraliza
					lnTab = lnTab - 1
					.Agregarlinea( "endif" , lnTab  )
				endif
				.AgregarLinea( "" )
				.oCacheFunciones.Agregar( .CacheTemp, lcCargarDatosEnCursores )
			endif
			.cCacheActiva = "CacheCargarDatosEnCursores"
			.AgregarLinea( .oCacheFunciones.item[ lcCargarDatosEnCursores ], 0 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributos( tcTipo as String ) as string
		local lcNombreCursor, lcsql as String, lcCursorAux as String
		
		lcCursorAux = sys( 2015 ) + "_ObtenerCursorAtributos1" 
		lcNombreCursor = sys( 2015) + "_ObtenerCursorAtributos2"

		select * from c_Estructura Dic where rtrim( upper( Dic.Entidad ) ) == alltrim( upper( tcTipo ) ) ;
			into cursor ( lcNombreCursor )

		* Agrego los campos del detalle desnormalizado
		select * from c_Estructura Dic ;
			inner join ( lcNombreCursor ) Detalle on "DETALLE" + upper( Dic.entidad ) = Detalle.Entidad ;
			inner join ( lcNombreCursor ) Campos on upper( Dic.Campo ) != upper( Campos.Campo ) ;
			into cursor ( lcCursorAux )

		if reccount(select(lcCursorAux))>0
			select * from ( lcNombreCursor ) union select * from ( lcCursorAux ) into cursor ( lcNombreCursor )
		endif
	
		use in select( lcCursorAux )
		
		return lcNombreCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClausulasIN( tcEntidad as string, tcCampoCP as String, tcCursorDependencias as String, tcTipoDato as String ) as String
		local lcRetorno as String, lcCursor as string, lcCampoCP as String, lcCampoDependencia as String, lnCantTabulaciones as Integer
		lnCantTabulaciones = 6
		if this.DebeAgregarCondicionCentraliza( tcEntidad )
			lnCantTabulaciones = lnCantTabulaciones + 1
		endif

		lcRetorno = ""
		lcCursor = sys( 2015 ) + "_ObtenerClausulasIn"
		if used( tcCursorDependencias )
			
			select ( tcCursorDependencias )
			scan
				if !empty( tcTipoDato ) and  upper( alltrim( &tcCursorDependencias..TipoDato )) <> upper(alltrim( tcTipoDato ))
					lcCampoDependencia =  "transform( " + alltrim( &tcCursorDependencias..Campo ) + ")"
				else
					lcCampoDependencia =  alltrim( &tcCursorDependencias..Campo )
				endif 	
				lcCampoCP = tcCampoCP
				This.AgregarBaseDedatos( @lcCampoCP, @lcCampoDependencia, &tcCursorDependencias..TipoDato, lcRetorno )
				if empty( lcRetorno )
					lcRetorno = "'" + lcCampoCP + " in ( select " + lcCampoDependencia  + ;
							" from " + this.cPrefijoCursor + alltrim( &tcCursorDependencias..Entidad ) + ") '"
				else
					if alltrim( upper( &tcCursorDependencias..Entidad ) ) != alltrim( upper( tcEntidad ) )
						lcRetorno = lcRetorno + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), lnCantTabulaciones ) + ;
							"lcIn = lcIn + ' or " + lcCampoCP + " in ( select " + lcCampoDependencia  + ;
							" from " + this.cPrefijoCursor + alltrim( &tcCursorDependencias..Entidad ) + ") '"
					endif
				endif
			endscan
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClausulasINRecursivas( tcEntidad as string, tcCampoCP as String, tcCursorDependencias as String, tcTipoDato as String ) as String
		local lcRetorno as String, lcCursor as string, lcCampoCP as String, lcCampoDependencia as String, lnCantTabulaciones as Integer
		lcRetorno = ""
		lnCantTabulaciones = 6
		if this.DebeAgregarCondicionCentraliza( tcEntidad )
			lnCantTabulaciones = lnCantTabulaciones + 1
		endif

		lcCursor = sys( 2015 ) + "_GetClausulasInRecursivas"
		if used( tcCursorDependencias )
			select ( tcCursorDependencias )
			scan
				if !empty( tcTipoDato ) and upper(alltrim( tcTipoDato )) <> upper(alltrim( &tcCursorDependencias..tipodato ))
					lcCampoDependencia = "transform( " + alltrim( &tcCursorDependencias..Campo ) + ")"
				else
					lcCampoDependencia = alltrim( &tcCursorDependencias..Campo )
				endif 	
				lcCampoCP = tcCampoCP
				This.AgregarBaseDedatos( @lcCampoCP, @lcCampoDependencia, &tcCursorDependencias..TipoDato, lcRetorno )
				if empty( lcRetorno )
					lcRetorno = "'" + lcCampoCP + " in ( select " + lcCampoDependencia + ;
							" from " + this.cPrefijoCursor + alltrim( &tcCursorDependencias..Entidad ) + ") '"

				else
					lcRetorno = lcRetorno + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), lnCantTabulaciones ) + ;
						"lcIn = lcIn + ' or " + lcCampoCP + " in ( select " + lcCampoDependencia  + ;
						" from " + this.cPrefijoCursor + alltrim( &tcCursorDependencias..Entidad ) + " ) '"
				endif
			endscan
			
			if !empty( lcRetorno )
				lcRetorno = substr( lcRetorno, 2 )
				lcRetorno = left( lcRetorno, len( lcRetorno ) - 1 )
				lcCampoDependencia = alltrim( &tcCursorDependencias..Campo )
				lcCampoCP = tcCampoCP
				This.AgregarBaseDedatos( @lcCampoCP, @lcCampoDependencia, &tcCursorDependencias..TipoDato, lcRetorno )
				lcRetorno =  "'( " + lcRetorno + " )'" + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), lnCantTabulaciones ) + ;
				"lcIn = lcIn + ' and " + lcCampoCP + " not in ( select " + lcCampoCP  + ;
						" from " + this.cPrefijoCursor + alltrim( tcEntidad  ) + " )'"
			endif
		endif
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObetnerOrden( tcEntidad as string ) as Integer
		local lnRetorno as integer, lcCursor as string

		if this.oCacheDatos.Buscar( "ORDEN_" + upper( tcEntidad ) )
			lnRetorno = this.oCacheDatos.Item[ "ORDEN_" + upper( tcEntidad ) ]
		else
			lnRetorno = 0
			lcCursor = sys( 2015 ) + "_GetORden"
			select Orden from ( this.cCursorHerencia ) where upper( alltrim( tcEntidad ) ) == alltrim( upper( Entidad ) ) ;
				into cursor ( lcCursor )
			lnRetorno = Orden
			use in select ( lcCursor )

			this.oCacheDatos.Agregar( lnRetorno, "ORDEN_" + upper( tcEntidad ) )
		endif
		
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCadenaDeCampos( tcCursor as String, tcTabla as string ) as String
		local lcRetorno as String
		lcRetorno = ""

		select( tcCursor )
		scan for !empty( campo ) and upper( alltrim( tcTabla ) ) == upper( alltrim( Tabla ) )
			if ( upper( alltrim( &tcCursor..TipoDato ) ) = "D" )
				lcRetorno = lcRetorno + iif( !empty( lcRetorno ), ",", "" ) + "goServicios.Librerias.ObtenerFechaFormateada( " + alltrim( campo ) + ") as " + alltrim( campo )
			else
				lcRetorno = lcRetorno + iif( !empty( lcRetorno ), ",", "" ) + alltrim( campo )
			Endif	
		endscan
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionArmarResultadoFinal() as Void
		local array laEntidades[ 1 ]
		local lcEntidad as string, lcEntidades as string, lcTabla as string, lcCurH as string, lnguion as integer
		
		with this as GeneradorConsultas of GeneradorConsultas.prg
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1)
			.AgregarLinea( "function ArmarResultadoFinal( toWhere as object, toContainer as zooDataContainer of zooDataContainer.prg ) as Void", 1)	

			lcCurH = .cCursorHerencia
			
			lcEntidades = strtran( strtran( .cEntidades, "'", "" ), '"', "" )
			alines( laEntidades, lcEntidades, 8, "," )

			for each lcEntidad in laEntidades
				.AgregarLinea( "toContainer.AgregarCursor( '" + this.cPrefijoCursor + alltrim( lcentidad )+ "' )", 2 )
			endfor

			.AgregarLinea( "endfunc", 1)	
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarCursores() as Void
		local array laEntidades[ 1 ]
		local lcEntidad as string, lcEntidades as string, lcTabla as string, lcCurH as string, lnguion as integer, lcTabla as string
		
		with this as GeneradorConsultas of GeneradorConsultas.prg
			lcCurH = .cCursorHerencia
			lcEntidades = strtran( strtran( .cEntidades, "'", "" ), '"', "" )
			alines( laEntidades, lcEntidades, 8, "," )

			for each lcEntidad in laEntidades
				lcTabla = .ObtenerTabla( lcentidad )
				.AgregarLinea( "loDatos.CerrarTablas( '" + lcTabla + "' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( lcentidad ) + "' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( lcentidad ) + "aux' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( lcentidad ) + "aux2' )", 4 )
			endfor
			select ( lcCurH )
			scan for Tipo = "O"
				lcEntidad = getwordnum( &lcCurH..Entidad, 1, "_" )
				lcTabla = .ObtenerTabla( lcentidad ) + "_" + getwordnum( &lcCurH..Entidad, 2, "_" )
				.AgregarLinea( "loDatos.CerrarTablas( '" + alltrim( lcTabla ) + "' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( &lcCurH..Entidad ) + "' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( &lcCurH..Entidad ) + "aux' )", 4 )
				.AgregarLinea( "use in select( '" + this.cPrefijoCursor + alltrim( &lcCurH..Entidad ) + "aux2' )", 4 )
				select ( lcCurH )
			endscan
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarActualizarEstado( tnTab as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAtributosGenericosEntidades() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarDatosAuditoria() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo() as void
		generador::SetearNombreArchivo()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsAuditoria( tcEntidad as String ) as Boolean
		return left( upper( alltrim( tcEntidad ) ), 4 ) == "ADT_" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarArchivo() as Void
		use in select( this.cCursorHerencia )
		dodefault()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaAOrdenarCursores( tnTab as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaATransformacion( tnTab as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsItemDeEntidadPrincipal( tcEntidad As String ) as Boolean
		local lcAlias as String, llRetorno as Boolean
		lcAlias = select()
		select c_Estructura
		locate for upper( alltrim( Entidad ) ) == upper( this.cTipo ) and upper( alltrim( Dominio ) ) == "DETALLE" + alltrim( upper( tcEntidad  ) )
		llRetorno = found()
		select ( lcAlias )	
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function EsItemDeEntidad( tcEntidad As String ) as Boolean
		local lcAlias as String, llRetorno as Boolean
		lcAlias = select()
		select c_Estructura
		locate for upper( alltrim( Dominio ) ) == "DETALLE" + alltrim( upper( tcEntidad  ) )
		llRetorno = found()
		select ( lcAlias )	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaActualizarInfoAdicional( tnTab ) as Void
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionActualizarInfoAdicionalGenerica( ) as Void
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaBlanquearInfoAfectacionesEnEnvioABaseDeDatos( tnTab ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionBlanquearInfoAfectacionesEnEnvioABaseDeDatos() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeAgregarCondicionCentraliza( tcEntidad as String ) as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsEntidadEnBaseA( tcEntidad As String ) as Boolean
		local lcAlias as String, llRetorno as Boolean
		llRetorno = .f.
		if used( this.cCursorHerencia )
			lcAlias = select()
			select ( this.cCursorHerencia )
			locate for upper( alltrim( Entidad ) ) == upper( tcEntidad )
			if found()
				if Tipo == "B"
					llRetorno = .t.
				endif
			endif
			select ( lcAlias )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsEntidadItemComprobante( tcEntidad As String ) as Boolean
		return upper( alltrim( tcEntidad ) ) == "ITEMCOMPROBANTE" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CorrespondeBlanquearInfoAfectacionesEnEnvioABaseDeDatos( tcEntidad as String ) as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsEntidadConItemArticulos( tcEntidad as String ) as Boolean
		return !empty( this.ObtenerItemArticulos( tcEntidad ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionEntidadConTransferenciaALince( tnTab as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsRemitoComoMercEnTransito( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = alltrim(upper(tcEntidad))=="REMITO" and ( alltrim(upper(this.cTipo)) == "REMXMOVTRANS" or alltrim(upper(this.cTipo)) == "REMITO" )
		return llRetorno
	endfunc 


enddefine 