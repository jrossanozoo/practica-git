define class GeneradorConsultasListados as generador of generador.prg

	#IF .f.
		Local this as GeneradorConsultasListados of GeneradorConsultasListados.prg
	#ENDIF
	
	protected oFactory as Object
	
	cListado = 0
	oListado = null

	* esta funcion llena la coleccion. Key = numero de campo, dato = EntidadSelect al que esta relacionado
	oRelacionCamposYCursores = null

	cPrefijo = "Listado"
	cSufijo = "Consulta"
	cPath = "Generados\"
	lTieneGroupBy = .F.
	cGroupBy = ''
	oColCamposComoNull = null
	cCamposAgrumaniento = ""	
	cCamposSubtotalizadoresGB = ""
	cCamposSelectSub = ""
	nLongitudBaseDeDatos = 8
	oDatos = Null
	oEstrucSqlServer = null
	oCreateCursor = null
	cCamposConcatenados = ""
	oEntidadesSelect = null
	lGenerico = .f.
	oCamposYCursores = null
	oFactory = null
	lUsaNuevaVersionSqlServer = .t.
	oCamposQueRequierenJoin = null
	
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		if vartype( this.oRelacionCamposYCursores ) = "O"
			this.oRelacionCamposYCursores.remove( -1 )
		endif
		
		if vartype( this.oCamposYCursores ) = "O"
			this.oCamposYCursores.Remove( -1 )
		endif
		
		if vartype( this.oEntidadesSelect ) = "O"
			this.oEntidadesSelect.Remove( -1 )
		endif
		
		this.oDatos = null
		this.oListado = null
		this.oColCamposComoNull = null
		this.oEntidadesSelect = null
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Generar( tcListado as string ) as Void
		local lcNombreListado as String, loFactoryDeListados as FactoryDeListados of FactoryDeListados.prg, ;
		lcArchivoclase as String
		
		with this
			if ( isnull( .oFactory ) )
				this.oFactory = goServicios.Listados.ObtenerFactoryDeListados()	
			endif
			if ( isnull( .oCreateCursor ) )
				.oCreateCursor = newobject( "GeneradorConsultasCreateCursor", "GeneradorConsultasCreateCursor.prg" )
			endif
			
			loFactoryDeListados = this.oFactory
			lcNombreListado = loFactoryDeListados.ObtenerNombreDeClase( upper( alltrim( tcListado ) ), "Objeto", "GENERADORCONSULTA" )
			
			.cListado = upper( alltrim( tcListado ) )
			lcArchivoclase = addbs( this.cPath ) + forceext( lcNombreListado, "prg" )
			.oListado = _screen.zoo.crearobjeto( lcNombreListado, lcArchivoclase )
			.lUsaNuevaVersionSqlServer = .oListado.UsaNuevaVersionSqlServer()
			 
			if ( .oListado.nEstiloDeConsulta < 1 ) or ( .oListado.nEstiloDeConsulta > 3 )
				if .oListado.lGenerico
					.oListado.nEstiloDeConsulta = 1
				else
					.oListado.nEstiloDeConsulta = 3
				endif
			endif
			
			if ( isnull( this.oDatos ) )
				.oDatos = _screen.zoo.crearobjeto( "serviciodatos" )
				.oEstrucSqlServer = _screen.zoo.crearobjeto( "servicioestructurasqlserver" )			
				.oEstrucSqlServer.Inicializar()
			endif

			dodefault( .oListado.cEntidadPrincipal )
			
			.GenerarScriptDeConsultasParaSql()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarScriptDeConsultasParaSql() as Void
		local loJoins as zoocoleccion OF zoocoleccion.prg, lcEntidadSelect as string,;
			  loGenSql as GeneradorDeScriptDeConsultasParaSql of GeneradorDeScriptDeConsultasParaSql.prg,;
			  loJoinsDeUnSQL as zoocoleccion OF zoocoleccion.prg

		loJoins = _screen.zoo.Crearobjeto( "zooColeccion" )
		
		if this.olistado.lGeneraConsultaSQL
			for each lcEntidadSelect in this.oEntidadesSelect foxobject
				&& loJoinsDeUnSQL >> zooColección de ItemJoin
				loJoinsDeUnSQL = this.ObtenerColeccionOrdenadaDeEntidadesParaElJoinSubentidades( lcEntidadSelect )
				loJoins.Agregar( loJoinsDeUnSQL, lcEntidadSelect )
			endfor
		
			loGenSql = _screen.zoo.crearobjeto( "GeneradorDeScriptDeConsultasParaSql", "", this.oListado, loJoins, this.cPath )
			loGenSql.Ejecutar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		this.AgregarLinea( "define class Din_" + this.cPrefijo + upper( alltrim( this.cListado ) ) + this.cSufijo + " as ListadoBase of ListadoBase.prg" )
		this.AgregarLinea( "" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearNombreArchivo() as void
		this.cArchivo = this.cPath + "Din_" + this.cPrefijo + upper( alltrim( this.cListado ) ) + this.cSufijo + ".prg"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AntesDeGenerarCodigo() as Void
		dodefault()
		this.oColCamposComoNull = _Screen.Zoo.Crearobjeto( "ZooColeccion" )
		this.oListado.Inicializar()
		this.oCamposQueRequierenJoin = this.oListado.oCampos.Filtrar( "#ITEM.ClavePrimaria and !empty( #ITEM.idCampoGuia )" )
		this.SetearRelacionDeEntidades()
	endfunc

	*-----------------------------------------------------------------------------------------
	* esta funcion llena la coleccion. Key = numero de campo, dato = EntidadSelect al que esta relacionado
	protected function SetearRelacionDeEntidades() as Void
		local i as Integer, loItem as Object, lcEntidad as string, loItemCampoCursor as CampoCursor of ListadoBase.prg

		with this
			if vartype( .oRelacionCamposYCursores ) = "O"
				.oRelacionCamposYCursores.remove( -1 )
			endif
			
			if vartype( .oCamposYCursores ) = "O"
				.oCamposYCursores.remove( -1 )
			endif
			
			if vartype( .oEntidadesSelect ) = "O"
				.oEntidadesSelect.remove( -1 )
			endif
			
			.oRelacionCamposYCursores = _Screen.zoo.crearobjeto( "ZooColeccion" )
			.oCamposYCursores = _Screen.zoo.crearobjeto( "ZooColeccion" )
			.oEntidadesSelect = _Screen.zoo.crearobjeto( "ZooColeccion" )
			
			lcEntidad = alltrim( upper( .oListado.cEntidadPrincipal ) )
			if !empty( lcEntidad )
				.oEntidadesSelect.add( lcEntidad, lcEntidad )
				
				for each loItem in .oListado.oCampos foxobject 
					lcEntidad = alltrim( upper( .ObtenerEntidadSelectRelacionada( loItem ) ) )
					
					.oRelacionCamposYCursores.add( lcEntidad, transform( loItem.idCampo ) )
					
					loItemCampoCursor = newobject( "CampoCursor", "ListadoBase.prg" )
					loItemCampoCursor.cCursor = lcEntidad
					loItemCampoCursor.cCampo = transform( loItem.idCampo )				
					.oCamposYCursores.Agregar( loItemCampoCursor )
					
					if .oEntidadesSelect.getkey( lcEntidad ) = 0
						.oEntidadesSelect.add( lcEntidad, lcEntidad )
					endif
				endfor
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadSelectRelacionada( toItem as Object ) as Void
		local lcRetorno as String
		
		with this
			lcRetorno = .oListado.cEntidadPrincipal
		
			if toItem.TipoAtributo == "I"
				lcRetorno = toItem.Entidad
			else
				if ( toItem.idCampoGuia > 0 ) and .oListado.oCampos.Buscar( transform( toItem.idCampoGuia ) )
					lcRetorno = .ObtenerEntidadSelectRelacionada( .oListado.oCampos[ transform( toItem.idCampoGuia ) ] )
				endif
			endif
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPadre( toItem as Object ) as Void
		local lcRetorno as string
		with this
			if !empty( toItem.idCampoGuia )
				lcretorno = .ObtenerEntidadPadre( .oListado.oCampos[ transform( toItem.idCampoGuia ) ] )
			else
				lcRetorno = alltrim( toItem.entidad )
			endif
		endwith
		
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPadreInmediato( toItem as ItemCampo of ItemCampo.prg ) as ItemCampo of ItemCampo.prg
		local loRetorno as object, loItem as ItemCampo of ItemCampo.prg
		
		loRetorno = null
		if !empty( toItem.idCampoGuia )
			loItem = this.oListado.oCampos[ transform( toItem.idCampoGuia ) ]

			loRetorno = loItem
		endif
		
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		local lcCursor as string
		
		with this
			.AgregarLinea( "" )
			.AgregarFuncionEntidadesSelect_Access()
			.AgregarFuncionConexionBD()
			.AgregarFuncionCerraCursoresPrincipales()
			.AgregarFuncionConsultas()
			
			if !this.lGenerico
				.AgregarFuncionCrearCursoresPorBaseDeDatos()
				.AgregarFuncionCrearCursorVacio()
				.AgregarFuncionConsultaPorBaseDeDatos()
			else
				.AgregarFuncionCrearCursorVacioV2()
			endif
						
			.AgregarFuncionConsultaPorBaseDeDatosSqlServer()
			.AgregarFuncionCerrarConexionBD()
			.AgregarFuncionObtenerGroupBy()
			.AgregarFuncionEliminarRegistros()
			*.SerializaroRelacionCamposYCursores()
			.AgregarFuncionDespuesDeObtenerAuxiliar()
			.AgregarFuncionCerraCursoresComplementariosPie()
			.AgregarFuncionAgregarCursoresComplementariosPie()
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionEntidadesSelect_Access()
		local lnTab as Integer, lcEntidadSelect as String
		
		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function EntidadesSelect_Access() as zoocoleccion OF zoocoleccion.prg", lnTab )
			.AgregarLinea( "if ( vartype( this.EntidadesSelect ) != 'O' or isnull( this.EntidadesSelect ) ) and !this.lDestroy", lnTab + 1 )
			.AgregarLinea( "this.EntidadesSelect = _Screen.zoo.crearobjeto( 'ZooColeccion' )", lnTab + 2 )
			.AgregarLinea( "", lnTab + 2 )
			for each lcEntidadSelect in this.oEntidadesSelect foxobject
				lcEntidadSelect = upper( alltrim( lcEntidadSelect ) )
				.AgregarLinea( "this.EntidadesSelect.Add( '" + lcEntidadSelect + "', '" + lcEntidadSelect + "' )", lnTab + 2 )
			endfor
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )		
			.AgregarLinea( "return this.EntidadesSelect", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionConsultas()
		local lnTab as Integer, lcEntidadSelect as String

		lnTab = 1
		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function Consultas( toListado as ObjetoListado of ObjetoListado.prg ) as zooColeccion of zooColeccion.prg", lnTab )
			
			if .oListado.nEstiloDeConsulta = 1
				.AgregarLinea( "local loCursores as zooColeccion of zooColeccion.prg, lcListaDeBD as string", lnTab + 1 )
			else
				.AgregarLinea( "local loCursores as zooColeccion of zooColeccion.prg, lcListaDeBD as string,;", lnTab + 1 )
				.AgregarLinea( "  lnCantidadDeBD as integer, lcBaseDeDatos as string, lnBD as integer", lnTab + 2 )
			endif
			.AgregarLinea( "", lnTab + 1 )
			
			.AgregarLinea( "this.CerrarCursoresPrincipales()", lnTab + 1 )
			.AgregarLinea( "loCursores = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )
			
			.AgregarLinea( "toListado.ObtenerBasesDeDatos( toListado.cAgrupamientoBD )", lnTab + 1 )
			.AgregarLinea( "lcListaDeBD = this.ObtenerListaDeBasesDeDatos( toListado )" , lnTab + 1 )
			
			if .oListado.nEstiloDeConsulta = 1
				.AgregarLinea( "", lnTab + 1 )
				.AgregarLinea( "This.CrearCursorVacio()", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				.AgregarLinea( "this.ConsultaPorBaseDeDatosSqlServer( toListado, lcListaDeBD )", lnTab + 1 )
			else
				.AgregarLinea( "lnCantidadDeBD = GetWordCount( lcListaDeBD , ',' )", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				.ArmarConsultaFinal( lnTab + 1 )
			endif
			.AgregarLinea( "", lnTab + 1 )

			for each lcEntidadSelect in this.oEntidadesSelect foxobject
				lcEntidadSelect = upper( alltrim( lcEntidadSelect  ) )
				.AgregarLinea( "loCursores.Add(" + " 'c_List" + lcEntidadSelect + "', '" + lcEntidadSelect + "' )", lnTab + 1 )
			endfor 
			.AgregarLinea( "", lnTab + 1 )
			
			.ArmarIndices( lnTab + 1 )			
						
			.ArmarRelaciones( lnTab + 1 )

			if .oListado.nEstiloDeConsulta = 2
				.AgregarLinea( "this.EliminarRegistrosConFiltrosSobreCamposAgrupados( toListado )", lnTab + 1 )
			endif
			.AgregarLinea( "this.EliminarRegistros( toListado )", lnTab + 1 )
			.AgregarLinea( "this.ReemplazarValoresCombos( toListado, loCursores )", lnTab + 1 )
			.AgregarLinea( "this.CerrarCursoresComplementariosPie()", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )
			.AgregarLinea( "loCursores = this.AgregarCursoresComplementariosPie( loCursores )", lnTab + 1 )
			.ArmarResultadoFinal( lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )
			.AgregarLinea( "return loCursores", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCrearCursoresPorBaseDeDatos() as Void
		local lnTab as Integer
		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function CrearCursoresPorBaseDeDatos( toListado as ObjetoListado of ObjetoListado.prg, tcBaseDeDatos as string ) as void", lnTab )
			.AgregarLinea( "This.CrearCursorVacio()", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionConsultaPorBaseDeDatos() as Void
		local lnTab as Integer

		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ConsultaPorBaseDeDatos( toListado as ObjetoListado of ObjetoListado.prg, tcBaseDeDatos as string ) as object", lnTab )
			.AgregarLinea( "local lcSentenciaCampos as string, lcWhere as string, loOrden as object, lcCampoOrderBy as String,;", lnTab + 1 )
			.AgregarLinea( "  lcSentenciaOrderBy as String, lcGroupBy as string", lnTab + 2 )

			.AgregarLinea( "" )
			.AgregarLinea( "if goServicios.Datos.EsSqlServer() and toListado.UsaNuevaVersionSqlServer()", lnTab + 1 )
			.AgregarLinea( "this.ConsultaPorBaseDeDatosSqlServer( toListado, tcBaseDeDatos )", lnTab + 2 )
			.AgregarLinea( "else", lnTab + 1 )
			
			.ArmarConsultaPorBaseDeDatos( lnTab + 2 )
			
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionConsultaPorBaseDeDatosSqlServer() as Void
		local lnTab as Integer

		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			if .oListado.nEstiloDeConsulta = 1
				.AgregarLinea( "function ConsultaPorBaseDeDatosSqlServer( toListado as ObjetoListado of ObjetoListado.prg, tcListaDeBD as string ) as object", lnTab )
				.AgregarLinea( "local lcCursorTemp as string, lcSentenciaSelect as String", lnTab + 1 )
				.ArmarConsultaPorBaseDeDatosSqlServerEstilo1( lnTab + 1 )
			else
				.AgregarLinea( "function ConsultaPorBaseDeDatosSqlServer( toListado as ObjetoListado of ObjetoListado.prg, tcBaseDeDatos as string ) as object", lnTab )
				.AgregarLinea( "local lcWhere as string, lcSelect as string, lcCursorTemp as string, lcNombreFuncionSql as string, lcFor as String", lnTab + 1 )
				.ArmarConsultaPorBaseDeDatosSqlServerEstilo2( lnTab + 1 )
			endif
			
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionConexionBD()
		local lnTab as Integer
		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ConexionBD( tcSucursal ) as void", lnTab )
			if .lUsaNuevaVersionSqlServer
				.AgregarLinea( "*** Se conserva la definición del método por compatibilidad.", lnTab + 1 )
			else
				.AgregarConexionBD( lnTab + 1 )
			endif
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCerraCursoresPrincipales() as VOID 
		local lnTab as Integer, lcEntidadSelect as String
		
		lnTab = 1
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function CerrarCursoresPrincipales() as void", lnTab )
			
			for each lcEntidadSelect in this.oEntidadesSelect foxobject 
				.AgregarLinea( "use in select( 'c_List" + alltrim( lcEntidadSelect ) + "' )", lnTab + 1 )
				.AgregarLinea( "use in select( 'c_List" + alltrim( lcEntidadSelect ) + "aux' )", lnTab + 1 )
			endfor						
			
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCerraCursoresComplementariosPie() as VOID 
		local lnTab as Integer
		
		lnTab = 1
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function CerrarCursoresComplementariosPie() as void", lnTab )
			.AgregarLinea( "*** Hook para ser sobreescrito para Subinforme en pie.", 2 )			
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCerrarConexionBD()
		local lnTab as Integer
		lnTab = 1
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function CerrarConexionBD() as void", lnTab )
			.AgregarCierreBD( lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtenerGroupBy() as void
		local lnTab as Integer, lcTexto as string
		lnTab = 1
		with this
			lcTexto = strtran( .cGroupBy, ",", "' + ;" + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), lnTab + 2 ) + "', " )
			
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ObtenerGroupBy( tcEntidad as string ) as string", lnTab )
			if .lTieneGroupBy
				.AgregarLinea( "return ' Group By " + lcTexto  + "'", lnTab + 1 )
			else
				.AgregarLinea( "return ''", lnTab )
			endif
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionEliminarRegistros() as Void
		local lnTab as Integer, lcTexto as string, lcEntDet as String, lcCond as string,;
			  lcCondPadre as String, lcEntPrincipal as string
		
		lnTab = 1
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function EliminarRegistros( toListado as ObjetoListado of ObjetoListado.prg ) as string", lnTab )

			lcEntPrincipal = .oListado.cEntidadPrincipal
			
			lcCondPadre = .oListado.ObtenerCondicionDeCamposSinDatos( lcEntPrincipal )
			if !empty( lcCondPadre )
				lcTexto = "delete from c_List" + lcEntPrincipal  + " where " + lcCondPadre
				.AgregarLinea( lcTexto, lnTab + 1 )
			endif

			for each lcEntDet in this.oEntidadesSelect foxobject 
				if alltrim( upper( lcEntDet ) ) != alltrim( upper( lcEntPrincipal ) )
					lcTablaDet = "c_List"  + lcEntDet
					
					lcCond = .oListado.ObtenerCondicionDeCamposSinDatos( lcEntDet )
					if !empty( lcCond )
						lcTexto = "delete from " +  lcTablaDet + " where " + lcCond
						.AgregarLinea( lcTexto, lnTab + 1 )
					endif

					if !empty( lcCondPadre )
						lcTablaDet = "c_List"  + lcEntDet
						lcTexto = "delete from " +  lcTablaDet + " where " + lcEntDet + "__Grupo " + ;
								"not in ( select " + lcEntPrincipal + "__grupo from c_List" + lcEntPrincipal + " )"
						.AgregarLinea( lcTexto, lnTab + 1 )
					endif
				endif
			endfor

			.AgregarLinea( "endfunc", lnTab )
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArmarConsultaFinal( tnTab as Integer ) as Void
		local lnTab as Integer, lcCampos as string, ;
			i as Integer, lcEntidadSelect as string, lcCamposAgrupados as String,;
			loCol as zoocoleccion OF zoocoleccion.prg, loColSubtot as zoocoleccion OF zoocoleccion.prg

		with this
			lnTab = tnTab

			.AgregarLinea( "for lnBD = 1 to lnCantidadDeBD" , lnTab  )
			.AgregarLinea( "lcBaseDeDatos = upper( GETWORDNUM( lcListaDeBD , lnBD, ',' ) )", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )
			.AgregarLinea( "this.CerrarConexionBD()", lnTab + 1 )
			.AgregarLinea( "this.Conexionbd( lcBaseDeDatos )", lnTab + 1 )	
			.AgregarLinea( "", lnTab + 1 )
			.AgregarLinea( "this.CrearCursoresPorBaseDeDatos( toListado, lcBaseDeDatos )", lnTab + 1 )
			.AgregarLinea( "If this.VerificarFiltroPorBaseDeDatos( toListado, lcBaseDeDatos )", lnTab + 1 )
				.AgregarLinea( "this.ConsultaPorBaseDeDatos( toListado, lcBaseDeDatos )", lnTab + 2 )
			.AgregarLinea( "endIf", lnTab + 1 )
			.AgregarLinea( "endfor", lnTab )
			.agregarLinea( "", lnTab )

			lnTab = tnTab
			loCol = _screen.zoo.crearobjeto( "zoocoleccion" )
			loColSubtot= _screen.zoo.crearobjeto( "zoocoleccion" )		
			
			for each lcEntidadSelect in this.oEntidadesSelect foxobject 
				.cCamposSubtotalizadoresGB = ""
				.cCamposSelectSub = ""
				.cCamposAgrumaniento = ""

				** Esta funcion llena oColCamposComoNull, cCamposSubtotalizadoresGB, cCamposSelectSub, cCamposAgrumaniento
				lcCampos = .ObtenerCamposListados( lcEntidadSelect, lnTab + 2, .f. )

				if .EsConsultaAgrupada()
					lcCamposAgrupados = .ObtenerCondicionAgrupamiento( lcEntidadSelect )

					if empty( lcCamposAgrupados )
					else
						loCol.Add( "Select " +  alltrim( .cCamposAgrumaniento ) + " from  c_list"  + lcEntidadSelect + ;
								" group by " + lcCamposAgrupados + " into cursor c_list" + lcEntidadSelect + " readwrite" )
					endif	
				endif
			endfor

			*** Una sola consulta y campos a subtotalizar
			if ( this.oEntidadesSelect.Count = 1 ) and ( .oListado.oSubtotalizados.count > 0 )
				lcCamposAgrupados = .ObtenerCondicionSubtotaliza( lnTab + 2 )
						
				if empty( lcCamposAgrupados )
				else
					loColSubtot.Add( "Select "+  alltrim( .cCamposSelectSub ) + " from  c_list"  + lcEntidadSelect + ;
							" group by " + lcCamposAgrupados + " into cursor c_list" + lcEntidadSelect + " readwrite" )
				endif	
			endif

			
			if loColSubtot.Count > 0
				for i = 1 to loColSubtot.Count 
					.AgregarLinea( loColSubtot.Item[ i ], lnTab )
				endfor 
				.AgregarLinea( "", lnTab )
			endif
			
			if loCol.Count > 0
				.AgregarLinea( "if toListado.lAgrupado ", lnTab )
				for i = 1 to loCol.Count 
					.AgregarLinea( loCol.Item[ i ], lnTab + 1 )
				endfor 
				.AgregarLinea( "endif ", lnTab )
				.AgregarLinea( "", lnTab )
			endif
			
			.AgregarLinea( "This.OrdenarConsultaFinal( toListado )", lnTab )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCrearCursorVacio() as Void
		local lnTab as Integer, lcEntidadSelect as string

		lnTab = 1
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "Function CrearCursorVacio( tcSufijo as string ) as Void", lnTab )
			.AgregarLinea( "Local lcSufijo as string", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )		
			.AgregarLinea( "lcSufijo = ''", lnTab + 1 )
			.AgregarLinea( "if !empty( tcSufijo )", lnTab + 1 )
			.AgregarLinea( "lcSufijo = alltrim( tcSufijo ) ", lnTab + 2 )
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )		
			
			for each lcEntidadSelect in this.oEntidadesSelect foxobject 
				.oColCamposComoNull.remove( -1 )
				.cCamposAgrumaniento = ""

				.AgregarLinea( "", lnTab + 1 )
				.AgregarLinea( "if used( 'c_list" + lcEntidadSelect + "' + lcSufijo )", lnTab + 1 )
				.AgregarLinea( "else", lnTab + 1  )
					.ObtenerCamposListados( lcEntidadSelect, lnTab + 2, .f. )
					
				lcQueryCursor = .oCreateCursor.ObtenerSentenciaConSufijo( this.cCamposConcatenados, lcEntidadSelect, .nLongitudBaseDeDatos ) 
				lcQueryCursor = strtran( lcQueryCursor, "<<SUFIJO>>", "lcSufijo" )
				
				.AgregarLinea( lcQueryCursor, lntab + 2 )
				.AgregarLinea( "endif" , lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
			endfor
			
			.AgregarLinea( "Endfunc", lnTab )			
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCrearCursorVacioV2() as Void
		local lnTab as Integer, i as Integer, lcEntidadSelect as string, lcUltimaEntidad as String

		lnTab = 1
		
		this.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		this.AgregarLinea( "Function CrearCursorVacio() as Void", lnTab )
		
		if this.oEntidadesSelect.Count > 0
			lcUltimaEntidad = this.oEntidadesSelect( this.oEntidadesSelect.Count )
		endif
		
		for each lcEntidadSelect in this.oEntidadesSelect foxobject 
			this.oColCamposComoNull.remove( -1 )
			this.cCamposAgrumaniento = ""

			this.AgregarLinea( "if !used( 'c_list" + lcEntidadSelect + "' )", lnTab + 1 )
			this.AgregarLinea( "this.CrearCursorVacioParaEntidadDeSelect( this.oListado, '"+ alltrim( lcEntidadSelect  ) + "' )", lnTab + 2 )
			this.AgregarLinea( "endif" , lnTab + 1 )
			
			if lcEntidadSelect != lcUltimaEntidad
				this.AgregarLinea( "", lnTab + 1 )
			endif
		endfor
		
		this.AgregarLinea( "Endfunc", lnTab )			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarConsultaPorBaseDeDatos( tnTab as Integer ) as Void
		local lnTab as Integer, lcCampos as string, lcRelaciones as string, lcCampoDetCP as String,;
			  lcEntidadSelect as string, lcTipoOrdenamiento as String, lcRelacionCabecera as string, loCampoDetCP as object,;
			  lcSeparador as String, lcFuncionCampoDetCP as String, lcCabeceraQuery as string, lcPieQuery as String 

		lnTab = tnTab
		
		for each lcEntidadSelect in this.oEntidadesSelect foxobject
			this.oColCamposComoNull.remove( -1 )
			this.cCamposAgrumaniento = ""

			** Esta funcion llena oColCamposComoNull, cCamposSubtotalizadoresGB, cCamposSelectSub, cCamposAgrumaniento
			lcCampos = this.ObtenerCamposListados( lcEntidadSelect, lnTab + 2, .t. )
			lcRelaciones = this.ObtenerRelacionesListados( lcEntidadSelect )
			lcRelacionCabecera = ""
			
			if this.lGenerico
				this.AgregarLinea( "lcSentenciaCampos = toListado.ObtenerSentenciaDeCamposParaSelect( '" + lcEntidadSelect + "' )", lnTab )
			else
				this.AgregarLinea( "text to lcSentenciaCampos textmerge noshow pretext 15", lnTab )
				this.AgregarLinea( lcCampos, lnTab + 2 )
				this.AgregarLinea( "endtext", lnTab )
			endif			
			this.AgregarLinea( "lcWhere = toListado.ObtenerWhere( '" + lcEntidadSelect + "' )", lnTab )
			
			if alltrim( upper( this.cTipo ) ) == lcEntidadSelect
				lcTipoOrdenamiento = ""
				this.AgregarLinea( "lcGroupBy = this.ObtenerGroupBy( '" + lcEntidadSelect + "' )", lnTab )
			else
				lcRelacionCabecera = this.ObtenerRelacionCabecera( lcEntidadSelect )
				lcTipoOrdenamiento = "'DETALLE'"
				this.AgregarLinea( "lcGroupBy = ''", lnTab )						
			endif
			this.AgregarLinea( "", lnTab )
			
			this.AgregarLinea( "loOrden = toListado.ObtenerOrdenamiento(" + lcTipoOrdenamiento + ")", lnTab )
			this.AgregarLinea( "lcCampoOrderBy = alltrim( loOrden.cCampoOrderBy )", lnTab )
			this.AgregarLinea( "lcSentenciaOrderBy = alltrim( loOrden.cSentenciaOrderBy )", lnTab )
			this.AgregarLinea( "loOrden = null", lnTab )
			
			this.AgregarLinea( "", lnTab )
			this.AgregarLinea( "toListado.lSigueProceso = .t.", lnTab )
			this.AgregarLinea( "try", lnTab )

			loCampoDetCP = this.oListado.ObtenerItemClavePrimaria( lcEntidadSelect )
			lcCampoDetCP = this.oListado.ModificarLongitudEnSelect( "c_" + lcEntidadSelect + "." + loCampoDetCP.Campo, loCampoDetCP.TipoDato, loCampoDetCP.Longitud, loCampoDetCP.Decimales, .t., loCampoDetCP.Dominio )
			lcCampoGrupo = this.oListado.ModificarLongitudEnSelect( "tcBaseDeDatos", "C", this.nLongitudBaseDeDatos, 0, .t., "" )
			
			lcFuncionCampoDetCP = iif( upper( alltrim( loCampoDetCP.TipoDato ) ) == "C", "padr", "padl" )					

			lcSeparador = " " + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), 5 )
			this.AgregarLinea( "text to lcSentencia textmerge noshow pretext 15", lnTab + 1 )

			lcCabeceraQuery = "select "+ lcFuncionCampoDetCP + "( " + lcCampoGrupo + ", " + transform( this.nLongitudBaseDeDatos ) + ", ' ' ) + " + ;
							  	"padr( " + lcCampoDetCP + ", " + transform( loCampoDetCP.Longitud ) + ", ' ' ) as " + lcEntidadSelect + "__Grupo," + ;
							  	lcSeparador + chr( 9 ) + "tcBaseDeDatos as " + lcEntidadSelect + "__BD"

			lcPieQuery = lcSeparador + chr( 9 ) + "<< lcSentenciaCampos >> " + ;
						 lcSeparador + chr( 9 ) + "<< lcCampoOrderBy >> " + ;
						 lcSeparador + "from c_" + lcEntidadSelect + " " + ;
						 lcRelaciones + ;
						 lcRelacionCabecera + ;
						 lcSeparador + " << lcWhere >> " + ;
						 lcSeparador + " << lcSentenciaOrderBy >> " + ;
						 lcSeparador + " << lcGroupBy >> " + ;
						 lcSeparador + "into cursor c_List" + lcEntidadSelect +"aux readwrite "
												
			if this.lGenerico
				this.AgregarLinea( lcCabeceraQuery + " " + lcPieQuery, lnTab + 2 )
			else
				this.AgregarLinea( lcCabeceraQuery + "," + lcPieQuery , lnTab + 2 )
			endif

			this.AgregarLinea( "endtext", lnTab + 1 )	


			this.AgregarLinea( "&lcSentencia", lnTab + 1 )
			loCampoDetCP = null


			this.AgregarLinea( "", lnTab + 1 )

			this.AgregarLinea( "catch to loerror", lnTab )
				this.AgregarLinea( "if loError.errorno = 18", lnTab + 1 )
					this.AgregarLinea( "toListado.lSigueProceso = .f.", lnTab + 2 )
					this.AgregarLinea( "loError.Message = 'Listado con demasiados campos seleccionados.'", lnTab + 2 )
					this.AgregarLinea( "this.InformarDeError( loError, toListado )", lnTab + 2 )
				this.AgregarLinea( "else", lnTab + 1 )
					this.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loError.Message )", lnTab + 2 )
				this.AgregarLinea( "endif", lnTab + 1 )
			this.AgregarLinea( "endtry", lnTab )
			
			
			if This.oColCamposComoNull.Count > 0				
				lcReplaceNull = this.CrearReplaceEmptyWithNull( "c_List" + lcEntidadSelect + "aux", lnTab + 1 )
				if !empty( lcReplaceNull )
					*----- Paso todos los campos que están en la colección a NULL
					this.AgregarLinea( "if toListado.lSigueProceso", lnTab )
					this.AgregarLinea( lcReplaceNull, lnTab + 1 )
					this.AgregarLinea( "endif", lnTab )
				endif
				this.AgregarLinea( "", lnTab )
			EndIf

			this.AgregarLinea( "this.DespuesDeObtenerAuxiliar_" + lcEntidadSelect+ "( toListado, tcBaseDeDatos )" , tnTab )
			this.AgregarLinea( "", lnTab )
			this.AgregarCreacionCursorAuxiliar( lcEntidadSelect, lnTab )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarConsultaPorBaseDeDatosSqlServerEstilo1( tnTab as Integer ) as Void
		local lnTab as Integer, lcEntidadSelect as string

		lnTab = tnTab
		with this
			for each lcEntidadSelect in this.oEntidadesSelect foxobject 
				.oColCamposComoNull.remove( -1 )
				.cCamposAgrumaniento = ""
				
				.AgregarLinea( "" )
				.AgregarLinea( "if toListado.ExistenCamposSeleccionadosDeLaEntidad( '" + lcEntidadSelect + "' )", lnTab )
				
				.AgregarLinea( "lcCursorTemp = 'c_List" + lcEntidadSelect + "'", lnTab + 1 )
				.AgregarLinea( "if used( lcCursorTemp )", lnTab + 1 )
				.AgregarLinea( "lcCursorTemp = lcCursorTemp + 'aux'", lnTab + 2 )
				.AgregarLinea( "endif", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				
				.AgregarLinea( "lcSentenciaSelect = this.ObtenerSentenciaParaInvocarElEjecutorDeConsultasDeListados( toListado, tcListaDeBD, '" + lcEntidadSelect + "' )", lnTab + 1 )
				.AgregarLinea( "goServicios.Datos.EjecutarSentencias( lcSentenciaSelect, '', '', lcCursorTemp, this.DataSessionId )", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				
				.AgregarLinea( "this.DespuesDeObtenerAuxiliar_" + lcEntidadSelect+ "( toListado, tcListaDeBD )" , lnTab + 1 )
				.AgregarLinea( "" )
				.AgregarCreacionCursorAuxiliar( lcEntidadSelect, lnTab + 1 )
				
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "", lnTab )
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarConsultaPorBaseDeDatosSqlServerEstilo2( tnTab as Integer ) as Void
		local lnTab as Integer, lcEntidadSelect as string

		lnTab = tnTab
		with this
			for each lcEntidadSelect in this.oEntidadesSelect foxobject 
				.oColCamposComoNull.remove( -1 )
				.cCamposAgrumaniento = ""
				
				.AgregarLinea( "" )
				.AgregarLinea( "if toListado.ExistenCamposSeleccionadosDeLaEntidad( '" + lcEntidadSelect + "' )", lnTab )
				
				.AgregarLinea( "lcCursorTemp = 'c_List" + lcEntidadSelect + "'", lnTab + 1 )
				.AgregarLinea( "if used( lcCursorTemp )", lnTab + 1 )
				.AgregarLinea( "lcCursorTemp = lcCursorTemp + 'aux'", lnTab + 2 )
				.AgregarLinea( "endif", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				
				if .oListado.nEstiloDeConsulta = 2
					.AgregarLinea( "toListado.InicializarFiltrosSobreCamposSumarizados()", lnTab + 1 )
				endif
				.AgregarLinea( "lcWhere = toListado.ObtenerWhere( '" + lcEntidadSelect + "' )", lnTab + 1  )
				.AgregarLinea( "lcSelect = this.ObtenerCamposSelect( toListado, '" + lcEntidadSelect + "' )", lnTab + 1)
				.AgregarLinea( "lcNombreFuncionSql = this.ObtenerNombreFuncionSql( '" + upper( alltrim( this.cListado ) ) + "_" + lcEntidadSelect + "', tcBaseDeDatos )", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				
				.AgregarLinea( "goServicios.Datos.EjecutarSentencias( " + ;
					"'SELECT ' + lcSelect + ' FROM ' + lcNombreFuncionSql + ' ( ' + ['] + tcBaseDeDatos + ['] + lcWhere + [)], '', '', lcCursorTemp, this.DataSessionId )", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )
				
				.AgregarLinea( "this.DespuesDeObtenerAuxiliar_" + lcEntidadSelect+ "( toListado, tcBaseDeDatos )" , lnTab + 1 )
				.AgregarLinea( "" )
				
				.AgregarCreacionCursorAuxiliar( lcEntidadSelect, lnTab + 1, .oListado.nEstiloDeConsulta = 2 )
				
				
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "", lnTab )
			endfor
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCreacionCursorAuxiliar( tcEntidad as String, tnTab as integer, tlAplicarFiltros as Boolean ) as Void
		with this
			.AgregarLinea( "if used( 'c_List" + tcEntidad + "aux' )", tnTab )
				if tlAplicarFiltros 
					.AgregarLinea( "lcFor = toListado.ObtenerFiltroSobreLosResultados( '" + tcEntidad + "' )", tnTab  + 1 )
					.AgregarLinea( "lcFor = 'For ' + iif( empty( lcFor ), '.t.', lcFor )", tnTab + 1 )
					.AgregarLinea( "", tnTab  + 1 )
				endif
				
				.AgregarLinea( "Select c_List" + tcEntidad , tnTab + 1 )
				if tlAplicarFiltros 
					.AgregarLinea( "Append From dbf( 'c_List" + tcEntidad + "aux' ) &lcFor" , tnTab + 2 )
				else
					.AgregarLinea( "Append From dbf( 'c_List" + tcEntidad + "aux' )" , tnTab + 2 )
				endif
			.AgregarLinea( "endif", tnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionAgrupamiento( tcEntidad as String ) as String 
		local lcCampos as String, lnI as Integer, lcTabla as String   
		lcCampos = ""
		for lni = 1 to this.oListado.oAgrupamientos.count
			lcTabla = upper(alltrim(getwordnum(this.oListado.oAgrupamientos.item[ lnI ].cCampoTabla,1,"_")))
			if lcTabla == upper( alltrim( tcEntidad ))
				lcCampos = lcCampos + "," + this.oListado.oAgrupamientos.item[ lnI ].cCampoTabla
			endif
		endfor 	
		
		lcCampos = substr( lcCampos , 2 )
		
		return lcCampos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionSubtotaliza( tnTab as Integer ) as String 
		local lcCampos as String, lnI as Integer, lcTabla as String, lcCamposNoincluidos as String, lnCont as Integer, ;
			lnElementos as Integer, loItem as object, lcCampoEspecifico as string, lcSeparador as String
			
		lcSeparador = ","
		if empty( tnTab )
			tnTab = 0
		else
			lcSeparador = ",;" + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), tnTab )
		endif
			

		*** Cadena de campos subtotalizados
		lcCampos = ""
		lcCamposNoincluidos = ""
		for lni = 1 to this.oListado.oSubtotalizados.count
			loItem = this.oListado.oSubtotalizados[ lni ]
			loItemAsociado = this.oListado.ObtenerCampoAsociado( loItem.IdCampo )
			
			lcCampos = lcCampos + lcSeparador + this.ObtenerNombreCampo( loItemAsociado )
		endfor
		
		*** adicionamos el resto de los campos
		for lni = 1 to this.oListado.oCampos.count
			loItem = this.oListado.oCampos[ lni ]
			lcCampoEspecifico = this.ObtenerNombreCampo( loItemAsociado )

			if at( lcCampoEspecifico + ",", lcCampos + "," ) > 0
			else
				lcCampos = lcCampos + lcSeparador + lcCampoEspecifico
			endif
		endfor

		lcCampos = substr( lcCampos , len( lcSeparador ) )

		return lcCampos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsConsultaAgrupada() as Boolean 
		local llRetorno as Boolean 
		
		if this.oListado.oAgrupamientos.count > 0
			llRetorno = .T.
		endif 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearReplaceEmptyWithNull( tcCursor As String, tnTab As Integer ) as Void
		local lcReplace As String, lcSeparador as String, lcCampo as string
		
		lcReplace = ""
		for each lcCampo in This.oColCamposComoNull foxObject
			lcReplace = lcReplace + "if upper( '" + lcCampo + "' ) $ upper( lcSentenciaCampos ) " + chr(13) + chr(10) + replicate( chr( 9 ), tnTab + 1 ) + ;
				"Replace All " + lcCampo + ;
				" With null For empty( " + lcCampo + " ) or " + lcCampo + ;
				" == this.dFechaEnBlancoSqlServer in " + tcCursor + chr(13) ;
				+ chr( 10 ) + replicate( chr( 9 ), tnTab ) + "endif" + chr( 13 ) + chr(10) + replicate( chr( 9 ), tnTab )
		endfor
		lcReplace = left( lcReplace, len( lcReplace ) - 1 )
		
		return ( lcReplace )
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ArmarRelaciones( tnTab as Integer ) as Void
		local lnTab as Integer, lcEntidadSelect as string, lcAdd as string, lcCampoRela as string,;
			  lcEntidad as string, lcTexto as string, lcTablaDet as string, lcEntDet as string,;
			  lcTabla as string, llSeAgregaronRelaciones as Boolean
		
		lnTab = tnTab
		
		with this
			lcEntidad = proper( alltrim( .cTipo ) )
			lcAdd = ""
			
			for each lcEntDet in this.oEntidadesSelect foxobject
				if !empty( lcEntDet ) and upper( lcEntDet ) # upper( lcEntidad )
					lcTablaDet = "c_List"  + lcEntDet
					lcTabla = "c_List"  + lcEntidad 

**** Arreglar ObtenerCampoRelacion No debe traer la clave primaria, para eso esta la funcion ObtenerCampoClavePrimaria

					lcCampoRela = lcEntidad + "_" + getwordnum( alltrim( .ObtenerCampoRelacion( lcEntDet ) ), 1, "+" )
											
					lcTexto = "set relation to "+ lcEntidad + "__bd + transform( " + lcCampoRela + " ) into " + lcTablaDet + " in " + lcTabla + lcAdd
					.AgregarLinea( lcTexto, lnTab )
					
					if empty( lcAdd )
						lcAdd = " additive"
					endif
					
					llSeAgregaronRelaciones = .t.
				endif
			endfor
			
			if llSeAgregaronRelaciones then
				.AgregarLinea( "", lnTab )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArmarIndices( tnTab as Integer ) as Void
		local lnTab as Integer, lcEntidadSelect as string, lcAdd as string, lcCampo as string, lcEntidad as string,;
			  lcTexto as string, lcTablaDet as string, lcEntDet as string, lcTabla as string, llSeAgregaronIndices as Boolean
		
		lnTab = tnTab
		
		with this
			lcEntidad = proper( alltrim( .cTipo ) )
			lcAdd = ""
			
			for each lcEntDet in this.oEntidadesSelect foxobject
				if !empty( lcEntDet ) and upper( lcEntDet ) # upper( lcEntidad )
					lcTablaDet = "c_List"  + lcEntDet
					lcCampo = lcEntDet + "_" + getwordnum( alltrim( .ObtenerCampoClavePrimaria( lcEntDet ) ), 1, "+" )
					
					.AgregarLinea( "select " + lcTablaDet, lnTab )
					lcTexto = "index on '"+lcEntDet+"__bd + transform( " + lcCampo + " )' tag ORD1"
					.AgregarLinea( lcTexto, lnTab )
					
					llSeAgregaronIndices = .t.
				endif
			endfor
			
			if llSeAgregaronIndices then
				.AgregarLinea( "", lnTab )
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCamposListados( tcEntidadSelect as String, tnTab as integer, tlSacarPuntoYComa as Boolean ) as string
		local lcCampos as string, i as Integer, loItem as ItemCampo of ItemCampo.prg, lcId as string, lcCampoModificado as String,;
		lcCampoAux as string, lcCadena as String, lcCadenaAux as String, lcEntidad as String , lcCadenaSelectSubTotal as String, lcCadenaSubTotalGB as String, ;
		llExiste as Boolean, lnNull as Integer, lcSeparador as string
		
		lcSeparador = ","
		if empty( tnTab )
			tnTab = 0
		else
			if !tlSacarPuntoYComa
				lcSeparador = lcSeparador + ";"
			endif
			lcSeparador = lcSeparador + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), tnTab )
		endif
		this.cCamposConcatenados = ""
 		
		lcCampos = ""
		lcCadena = ""
		lcCadenaAux = ""
		lcEntidad = ""
		lcCadenaSelectSubTotal = ""
		lcCadenaSubTotalGB  = ""
		lcCampoModificado = ""
		This.cGroupBy = ''
		This.lTieneGroupBy = .F.
		
		tcEntidadSelect = alltrim( upper( tcEntidadSelect ) )

		for each loItem in this.oListado.oCampos foxobject 

			if upper( alltrim( loItem.Atributo ) ) == "_BD" or loItem.EsCampoExpresion
				loop
			endif

			lcId = transform( loItem.idCampo )
			lcEntidad = this.oRelacionCamposYCursores[ lcId ]
			
			if empty( loItem.Expresion )
				if !empty( loItem.Campo ) and alltrim( upper( this.oRelacionCamposYCursores[ lcId ] ) ) == tcEntidadSelect and ;
					( loItem.MuestraRelacion or loItem.idCampo > 0 or loItem.lPuedeSerPersonalizablePorElUsuario or loItem.EsCampoComplementario )
					
					if loItem.TipoDato == "D"
						this.AgregarCamposComoNull( loItem, lcEntidad )
					endIf
					
					lcCampoModificado = this.oListado.ObtenerCampoParaSelect( loItem )
					
					if occurs( lcCampoModificado, lcCampos ) == 0
						lcCampos = lcCampos + lcCampoModificado + lcSeparador  
						this.AgregarCampoConcatenado( loItem.Campo, loItem.TipoDato, loItem.Longitud, loItem.Decimales, lcSeparador, "", loItem )
						
						lcCadenaAux = loItem.ObtenerAliasDelCampo()
						This.cGroupBy = This.cGroupBy + iif( empty( This.cGroupBy ), "", "," ) + alltrim( lcEntidad ) + "_" + alltrim( loItem.Campo )
					endif
				endif
			else
				if alltrim( upper( this.oRelacionCamposYCursores[ lcId ] ) ) == tcEntidadSelect and ( loItem.idCampo > 0 or loItem.lPuedeSerPersonalizablePorElUsuario )
					if empty( loItem.GrupoFX )
						lcExpresion = loItem.Expresion
					else
						lcExpresion = alltrim( loItem.GrupoFx ) + "( " + alltrim( loItem.Expresion ) + " )"	
						this.lTieneGroupBy = .T.
					endif	

					if empty( loItem.Campo ) and upper( loItem.TipoDato ) == "N"
						lcExpresion = " cast( " + lcExpresion + " as numeric ( " + transform( loItem.Longitud ) + ", " + transform( loItem.Decimales ) + " ) ) "
					endif
					
					lcExpresion = this.oListado.ModificarLongitudEnSelect( lcExpresion, loItem.TipoDato, loItem.Longitud, loItem.Decimales, .f., loItem.Dominio )
					
					lcCampoAux = iif( empty( loItem.Campo ), alltrim( loItem.Atributo ), alltrim( loItem.Campo ) )
					lcAliasCampo = " as " + loItem.ObtenerAliasDelCampo( lcSeparador )
					
					lcCampos = lcCampos + lcExpresion + lcAliasCampo && lcSeparador
					this.AgregarCampoConcatenado( lcCampoAux, loItem.TipoDato, loItem.Longitud, loItem.Decimales, lcSeparador, loItem.GrupoFX, loItem )
							
					lcCadenaAux = loItem.ObtenerAliasDelCampo()

					if empty( loItem.GrupoFX )
						this.cGroupBy = this.cGroupBy + iif( empty( This.cGroupBy ), "", "," ) + alltrim( lcEntidad ) + "_" + lcCampoAux
					endif
				endif
			endif
				
			if !empty( lcCadenaAux )
				if empty( loItem.Calculo )
					lcCadena = lcCadena + lcSeparador + alltrim( lcCadenaAux )
					lcCadenaSelectSubTotal = lcCadenaSelectSubTotal + lcSeparador + alltrim( lcCadenaAux )

					if loItem.Visible
						lcCadenaSubTotalGB = lcCadenaSubTotalGB + "," + alltrim( lcCadenaAux )
					endif
				else
					lcCadena = lcCadena + lcSeparador + alltrim( loItem.Calculo ) + "( " + alltrim( lcCadenaAux ) + " ) as " + lcCadenaAux	 
					lcCadenaSelectSubTotal = lcCadenaSelectSubTotal + lcSeparador + alltrim( loItem.Calculo ) + "( " + alltrim( lcCadenaAux ) + " ) as " + lcCadenaAux
				endif
				
			endif	
			lcCadenaAux = ""
		endfor
		
		this.cCamposSubtotalizadoresGB = substr( lcCadenaSubTotalGB, 2 )
		this.cCamposSelectSub = tcEntidadSelect + "__grupo, " + tcEntidadSelect + "__bd" + lcCadenaSelectSubTotal
		this.cCamposAgrumaniento = tcEntidadSelect + "__grupo, " + tcEntidadSelect + "__bd" + lcCadena
		this.cCamposConcatenados = left( this.cCamposConcatenados, len( this.cCamposConcatenados ) - len( lcSeparador ) ) 
		
		return left( lcCampos, len( lcCampos ) - len( lcSeparador ) ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarCamposComoNull( toItem as ItemCampo of ItemCampo.Prg, tcEntidad as String ) as VOID
		local lcCampoAux as String
		*lcCampoAux = upper( alltrim( tcEntidad ) + "_" + alltrim( toItem.Campo ) )
		lcCampoAux = toItem.ObtenerAliasDelCampo()
		
		if !this.oColCamposComoNull.Buscar( lcCampoAux )
			This.oColCamposComoNull.Agregar( lcCampoAux )
		endif		
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function AgregarCampoConcatenado( tcCampo as String, tcTipoDato as String, tnLongitud as Integer, ;
		tnDecimales as Integer, tcSeparador as String, tcGrupoFx as String, toCampo as ItemCampo of ItemCampo.prg, tlNoAgregarComboV2 as Boolean ) as Void
		
		*jbarrionuevo # 07/07/11 15:34:59 
		*Si el tipo de datos no es numérico pero tiene la función COUNT() asociada (campo GrupoFX de listcampos),
		*el campo pasa a ser numérico
		
		if upper( alltrim( tcTipoDato ) ) != "N" and !empty( tcGrupoFx ) and upper( alltrim( tcGrupoFx ) ) == "COUNT"
			tcTipoDato = "N"
		endif
		
		this.cCamposConcatenados = this.cCamposConcatenados + ;
			toCampo.EntidadUnicidad + "_" + alltrim( tcCampo ) + " " + ;
			tcTipoDato + "(" + transform( tnLongitud ) + ;
			iif( tnDecimales = 0, ")", ", " + transform( tnDecimales ) + ")" ) + " null" + tcSeparador
			
		if ( !tlNoAgregarComboV2 and toCampo.EsComboV2() )		
			this.AgregarCampoConcatenado( tcCampo + "COMBO", "C", "140", 0, tcSeparador, tcGrupoFx, toCampo, .t. )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRelacionesListados( tcEntidadSelect as String ) as string
		local lcRetorno as String, lcCampoRel as String, lcCampoCP as string, lcEntidad as string, lcEntidadPadre as String, ;
			loItem as ItemJoin of GeneradorConsultasListados.prg, loEnt as collection
		
		lcRetorno = ""

		tcEntidadSelect = alltrim( upper( tcEntidadSelect ) )
		
		loEnt = this.ObtenerColeccionOrdenadaDeEntidadesParaElJoinSubentidades( tcEntidadSelect )

		for each loItem in loEnt foxobject
			lcEntidad = loItem.Entidad
			lcEntidadPadre = loItem.EntidadPadre
			lcCampoCP = loItem.Campo
			lcCampoRel = iif( empty( loItem.ExpresionPadre ), "c_" + loItem.EntidadUnicidadPadre + "." + loItem.CampoRel, loItem.ExpresionPadre )

			lcRetorno = lcRetorno + chr(13) + chr(10) + replicate( chr( 9 ), 6 ) + " LEFT JOIN c_" + loItem.EntidadUnicidad + " ON " + lcCampoRel + " == " + ;
												"c_" + loItem.EntidadUnicidad + "." + lcCampoCP + " and " + ;
												"!empty( c_" + loItem.EntidadUnicidad + "." + lcCampoCP + " )"
		endfor

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaAsociada( tcEntidad as String ) as Void
		local loItem as object, lcRetorno as string

		for each loItem in this.oListado.oCampos
			if ( !empty( loItem.Tabla ) ) and upper( alltrim( loItem.Entidad ) ) == upper( alltrim( tcEntidad) )
				lcRetorno = loItem.Tabla
				exit
			endif
		endfor
		
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsItemAnalizableDeIncluirEnJoin( toItem as ItemCampo of ItemCampo.prg, tcEntidadSelect as String ) as Boolean
		local llAnalizar as Boolean, lcEntidadSelect 
		lcEntidadSelect = alltrim( upper( tcEntidadSelect ) )
		
		llAnalizar = toItem.ClavePrimaria and !empty( toItem.idCampoGuia ) and ( alltrim( upper( toItem.Entidad ) ) != lcEntidadSelect )
		llAnalizar = llAnalizar and ( alltrim( upper( this.oRelacionCamposYCursores[ transform( toItem.idCampo ) ] ) ) == lcEntidadSelect )
		
		return llAnalizar
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionOrdenadaDeEntidadesParaElJoinSubentidades( tcEntidadSelect as String ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcEntidades as string, loItem as ItemCampo of ItemCampo.prg, ;
			lcEntidadPadre as string, loItemJoin as object, lcTabla as String, lcTablaPadre as string, lcTablaSelect as string, ;
			lcExpresionPadre as String, lcTipoDatoPadre as String, lnLongitudPadre as Integer, lnDecimalesPadre as Integer, ;
			loPadre as ItemCampo of ItemCampo.prg, llPrimeraPasada as Boolean, lnCamposQueRequierenOtraPasada as Integer
		
		loRetorno = _screen.zoo.crearobjeto( "zooColeccion" )
		lcEntidades = "," + upper( alltrim( tcEntidadSelect ) ) + ","
		lcTablaSelect = this.ObtenerTablaAsociada( tcEntidadSelect )
		
		llPrimeraPasada = .t.
		do while llPrimeraPasada or ( lnCamposQueRequierenOtraPasada > 0 )	
			lnCamposQueRequierenOtraPasada = 0
			
			for each loItem in this.oCamposQueRequierenJoin FoxObject
				if this.EsItemAnalizableDeIncluirEnJoin( loItem, tcEntidadSelect )
					lcEntidad = upper( alltrim( loItem.Entidad ) )
					lcEntidadUnicidad = upper( alltrim( loItem.EntidadUnicidad ) )
					
					if ( "," + lcEntidadUnicidad + "," $ lcEntidades )
						loop
					endif
					
					lcTabla = upper( alltrim( loItem.Tabla ) )					
					loPadre = this.ObtenerEntidadPadreInmediato( loItem )
					if isnull( loPadre )
						loop
					else
						lcEntidadPadre =  upper( alltrim( loPadre.Entidad ) )
						lcTablaPadre =  upper( alltrim( loPadre.Tabla ) )
						lcExpresionPadre = upper( alltrim( loPadre.Expresion ) )
						lcTipoDatoPadre = upper( alltrim( loPadre.TipoDato ) )
						lnLongitudPadre = loPadre.Longitud
						lnDecimalesPadre = loPadre.Decimales
					endif
					
					if NOT upper( "," + alltrim( loPadre.EntidadUnicidad ) + "," ) $ upper( lcEntidades  )
						&& Como aún lo fue procesada la entidad del Padre se agregará en las proximas pasadas
						lnCamposQueRequierenOtraPasada = lnCamposQueRequierenOtraPasada + 1 
						loop
					endif
 					
					lcCampoCP = upper( alltrim( getwordnum( alltrim( loItem.Campo ), 1, "+" ) ) )
					lcCampoRel = upper( alltrim( loPadre.Campo ) ) 
				
					loItemJoin = newobject( "ItemJoin" )
					loItemJoin.Entidad = lcEntidad
					loItemJoin.EntidadUnicidad = loItem.EntidadUnicidad
					loItemJoin.EntidadPadre = lcEntidadPadre
					loItemJoin.EntidadUnicidadPadre = iif( isnull( loPadre ), loItem.EntidadUnicidad, loPadre.EntidadUnicidad )
					loItemJoin.Tabla = lcTabla
					loItemJoin.TablaPadre = lcTablaPadre
					loItemJoin.Campo = lcCampoCP
					loItemJoin.CampoRel = lcCampoRel
					loItemJoin.ExpresionPadre = lcExpresionPadre 
					loItemJoin.TipoDatoPadre = lcTipoDatoPadre 
					loItemJoin.LongitudPadre = lnLongitudPadre
					loItemJoin.DecimalesPadre = lnDecimalesPadre
					
					lcEntidades = lcEntidades + lcEntidadUnicidad + ","
					
					loRetorno.agregar( loItemJoin )					
				endif
			endfor
			
			llPrimeraPasada = .f.
		enddo	
		
		*this.GuardarContenidoDeLaColeccion( loRetorno )
		
		return loRetorno
	endfunc 
	
*!*		*-----------------------------------------------------------------------------------------
*!*		lnPasada = 0
*!*		lcReferencia = "While.For"
*!*		protected function GuardarContenidoDeLaColeccion( toColeccion as Collection ) as Void
*!*			local loItem as ItemJoin of GeneradorConsultasListados.prg, lcContenido as String,;
*!*				  lnItem as Integer
*!*			
*!*			this.lnPasada = this.lnPasada + 1 
*!*			lcContenido = "Pasada: " + transform( this.lnPasada ) + chr(13) + chr(10)
*!*			lnItem = 0
*!*			for each loItem in toColeccion foxobject 
*!*				lnItem = lnItem + 1 
*!*				lcContenido = lcContenido + loItem.ToStr( "Item: " + transform( lnItem ) )
*!*			endfor
*!*			lcContenido = lcContenido + chr(13) + chr(10)
*!*			
*!*			strtofile( lcContenido, "C:\Zoo\_CP\ContenidoEnColeccionDeJoins." + this.lcReferencia + ".txt", .t. )
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRelacionCabecera( tcEntidadSelect as String ) as string
		local lcRetorno as String, lcCampoRel as String, lcCampoCP as string, lcEntidad as string,;
			lcAtributoRel as string, loItem as Object, loItemAux as Object,	lcEntidadRel as string
			
		lcRetorno = ""

		*** Buscamos cualquier item campo que tenga como entidad la que se paso por parametros para poder 
		*** obtenr el campo guia. Da igual cualquiera para este caso
		loItem = null
		for each loItemAux in this.oListado.oCampos
			if upper( alltrim( loItemAux.Entidad ) ) == alltrim( upper( tcEntidadSelect ) ) and loItemAux.ClavePrimaria
				loItem = loItemAux
				exit
			endif
		endfor

		if !isnull( loItem )
			lcEntidadDet = upper( alltrim( tcEntidadSelect ) )
			lcCampoDetCP = getwordnum( alltrim( this.ObtenerCampoClavePrimaria( lcEntidadDet ) ), 1, "+" )
			
			loItemAux = this.oListado.ObtenerCampoAsociado( loItem.idCampoGuia )
			lcEntidad = upper( alltrim( loItemAux.Entidad ) )
			lcCampoCP = upper( alltrim( loItemAux.Campo ) )

			lcRetorno = lcRetorno + " " + chr(13) + chr(10) +  replicate( chr( 9 ), 5 ) + ;
				 " INNER JOIN c_List" + lcEntidad + "aux ON c_" + lcEntidadDet + "." + lcCampoDetCP + " == " + ;
												"c_List" + lcEntidad + "aux." + lcEntidad + "_" + lcCampoCP
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ArmarResultadoFinal( tnTab as Integer ) as Void
	
		this.AgregarLinea( "" )
		this.AgregarLinea( "select c_List"+ proper( alltrim( this.cTipo ) ), tnTab )
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarConexionBD( tnTab ) as Void
		local lcTablas as string, lcTabla as string, lcEntidades as string, lcEntidad as string,;
			lcUbicacionDB as String, loItem as ItemCampo of ItemCampo.prg
		
        this.AgregarLinea( "tcSucursal = goServicios.Librerias.ObtenerNombreSucursal( tcSucursal )", tnTab )

		
		lcEntidades = ","
		
		for each loItem in this.oListado.oCampos foxobject
			lcTabla = upper( alltrim( loItem.Tabla ) )
			lcEntidad  = upper( alltrim( loItem.Entidad ) )
			lcUbicacionDB = upper( alltrim( loItem.UbicacionDB ) )
			
			if !empty( lcTabla )
				if "," + loItem.EntidadUnicidad + "," $ lcEntidades 
				else
					this.AbrirTabla( lcTabla, loItem.EntidadUnicidad, lcUbicacionDB, tnTab  )
					lcEntidades = lcEntidades + loItem.EntidadUnicidad + ","
				endif
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarCierreBD( tnTab  ) as Void
		local loItem as ItemCampo of ItemCampo.prg, lcTablas as string, lcTabla as string
		
		lcTablas = ","
		for each loItem in this.oListado.oCampos
			lcTabla = "c_" + alltrim( loItem.EntidadUnicidad )
			if "," + lcTabla + "," $ lcTablas
			else
				this.AgregarLinea( "use in select ( '" + lcTabla + "')", tnTab )
				lcTablas = lcTablas + lcTabla + ","
			endif
		endfor
					
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AbrirTabla( tcTabla as String, tcEntidad as string, tcUbicacionDB as String, tnTab as Integer ) as Void
			
		this.AgregarLinea( "if !this.oListado.UsaNuevaVersionSqlServer()", tnTab )
		this.AgregarLinea( "local lcTabla as string, lcSql as string", tnTab + 1 )
		this.AgregarLinea( "lcTabla = '[' + tcSucursal + ']' + '." + this.oEstrucSqlServer.ObtenerEsquema( tcTabla ) + "." + tcTabla + "'", tnTab + 1 )
		this.AgregarLinea( "lcSql = 'select * from ' + lcTabla + ' as c_" + tcEntidad + "'", tnTab + 1 )
		this.AgregarLinea( "goServicios.Datos.EjecutarSQL( lcSql, 'c_" + tcEntidad + "', this.DataSessionId ) ", tnTab + 1 )
		this.AgregarLinea( "endif" , tnTab )
	endfunc
			
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoClavePrimaria( tcEntidad as String ) as String
		local i as Integer, lcRetorno as string, loItem as object
		
		lcRetorno = ""
		
		loItem = this.oListado.ObtenerItemClavePrimaria( tcEntidad )
		if !isnull( loItem )
			lcRetorno = loItem.Campo 
		endif
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoRelacion( tcEntidad as String ) as String
		local i as Integer, lcRetorno as object, loItem as object, loItemAux as object
		
		lcRetorno = ""
			
		with this
			i = 1
			do while i <= .oListado.oCampos.count and empty( lcRetorno )
				loItem = .oListado.oCampos[ i ]
				if alltrim( upper( loItem.Entidad ) ) == alltrim( upper( tcEntidad ) )
					loItemAux = .oListado.ObtenerCampoAsociado( loItem.idCampoGuia )
					if !isnull( loItemAux )
						lcRetorno = loItemAux.Campo
					endif
				endif
				
				i = i + 1
			enddo
		endwith
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreCampo( toItem as object ) as string
		return this.oListado.ObtenerNombreCampoFinal( toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionDespuesDeObtenerAuxiliar() as Void
		local loItem as Object
		for each loItem in this.oEntidadesSelect foxobject
			this.agregarLinea( "", 1 )
			this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			this.AgregarLinea( "function DespuesDeObtenerAuxiliar_" + loItem + "( toListado as ObjetoListado of ObjetoListado.prg, tcBaseDeDatos as string )", 1 )
			this.AgregarLinea( "*** Hook para ser sobreescrito y agregar modificación o cálculo de datos sobre el cursor auxiliar.", 2 )
			this.AgregarLinea( "endfunc", 1 )
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionAgregarCursoresComplementariosPie() as Void
		this.agregarLinea( "", 1 )
		this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
		this.AgregarLinea( "function AgregarCursoresComplementariosPie( toCursores as Object )", 1 )
		this.AgregarLinea( "*** Hook para ser sobreescrito y agregar modificación o cálculo de datos sobre el cursor complementario para Subinforme en pie.", 2 )
		this.AgregarLinea( "return toCursores", 1)
		this.AgregarLinea( "endfunc", 1 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SerializaroRelacionCamposYCursores() as Void
		local loItem as Object

		this.agregarLinea( "", 1 )
		this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
		this.AgregarLinea( "function ObtenerRelacionCamposYCursores()", 1 )
		this.AgregarLinea( "local loRetorno as zoocoleccion OF zoocoleccion.prg, loItem as CampoCursor of ListadoBase.prg", 2 )
		this.AgregarLinea( "loRetorno = _Screen.zoo.crearobjeto( 'ZooColeccion' )", 2 )		
		this.agregarLinea( "", 1 )
		for each loItem in this.oCamposYCursores
			this.AgregarLinea( "loItem = newobject( 'CampoCursor', 'ListadoBase.prg' )",2 )
			this.AgregarLinea( "loItem.cCampo = '" + loItem.cCampo + "'",2 )
			this.AgregarLinea( "loItem.cCursor = 'c_List" + loItem.cCursor + "'",2 )
			this.AgregarLinea( "loRetorno.Add( loItem, '" + loItem.cCampo + "')",2 )
			this.agregarLinea( "", 1 )
		endfor
		this.AgregarLinea( "return loRetorno", 2 )
		this.AgregarLinea( "endfunc", 1 )					
	endfunc 
		
enddefine


define class ItemJoin as custom
	
	Entidad = ""
	EntidadPadre = ""
	Tabla = ""
	TablaPadre = ""
	Campo = ""
	CampoRel = ""
	ExpresionPadre = ""
	TipoDatoPadre = ""
	LongitudPadre = -1
	DecimalesPadre = -1
	EntidadUnicidad = ""
	EntidadUnicidadPadre = ""
	
	*-----------------------------------------------------------------------------------------
	function ToStr( lcReferencia as String ) as String
		local lcInfo as String
		
		lcInfo = upper( alltrim( transform( lcReferencia ) ) ) + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "Entidad = " + this.Entidad + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "EntidadPadre = " + this.EntidadPadre + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "Tabla = " + this.Tabla + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "TablaPadre = " + this.TablaPadre + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "Campo = " + this.Campo + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "CampoRel = " + this.CampoRel + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "ExpresionPadre = " + this.ExpresionPadre + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "TipoDatoPadre = " + this.TipoDatoPadre + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "LongitudPadre = " + transform( this.LongitudPadre ) + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "DecimalesPadre = " + transform( this.DecimalesPadre ) + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "EntidadUnicidad = " + this.EntidadUnicidad + chr(13) + chr(10)
		lcInfo = lcInfo + chr(9) + "EntidadUnicidadPadre = " + this.EntidadUnicidadPadre + chr(13) + chr(10)
		
		return lcInfo
	endfunc 
	
enddefine


