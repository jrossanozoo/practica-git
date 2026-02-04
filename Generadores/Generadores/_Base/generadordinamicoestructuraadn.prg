define class GeneradorDinamicoEstructuraAdn as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoEstructuraAdn of GeneradorDinamicoEstructuraAdn.prg
	#endif

	cPath = "Generados\"
	nNivel = 0
	cCursorIndices = ""
	cPrefijoAuditoria = "ADT_"
	cXmlCamposAuditoriaEntidad = ""
	cXmlCamposAuditoriaDetalle = ""	
	oGeneradorNet = null
	nModoDefault = 2
	cCursorEntidadesConListasDePrecios = ""	

	*-----------------------------------------------------------------------------------------
	protected function InstanciarEstructura() as Void
		this.oEstructura = null	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function init( tcRuta as String ) as Void
		dodefault( tcRuta )
		if vartype( "goRegistry" ) = 'O'
			this.cPrefijoAuditoria = alltrim( goregistry.nucleo.prefijotablasauditoria )
		endif
		this.agregarReferencia( "ZooLogicSA.Core.ADN.dll" )
		this.agregarReferencia( "zoologicsa.generadordedatos.dll" )
		this.oGeneradorNet = _screen.zoo.crearobjeto( "ZooLogicSA.GeneradorDeDatos.GeneradorManager" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		local  lcCursor as String

		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------")
			.AgregarLinea( "define class Din_EstructuraAdn as zoosession of zoosession.prg" )
			.AgregarLinea( "cXml = ''", 1 )
			.AgregarLinea( "cXmlIndice = ''", 1 )
			.AgregarLinea( "cXmlOperacionesMenu = ''", 1 )
			.AgregarLinea( "cXmlOperacionesEntidades = ''", 1 )
			.AgregarLinea( "cXmlEstructuraEntidadesMenuPrincipalItems = ''", 1 )			
			.AgregarLinea( "cProyecto = '" + _Screen.Zoo.App.cProyecto + "'", 1 )
			.AgregarLinea( "cXmlRelacionEntreComprobantes = ''", 1 )
			.AgregarLinea( "cCursorFuncionalidades = sys( 2015 )", 1 )
			.AgregarLinea( "cPathBase = ''", 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "*"+replicate('-',90), 1 )
			.AgregarLinea( "function Init() as Void",1 )
			.AgregarLinea( "DoDefault()",2 )
			.AgregarLinea( "this.cPathBase = left(this.classlibrary,rat('\',this.classlibrary))",2 )
			.AgregarLinea( "EndFunc",1 )
			.AgregarLinea( "" )
			.FuncionObtener( )
			.AgregarLinea( "" )
			.FuncionEntidadRecibeModoInseguroCentral()
			.FuncionEntidadRecibeModoInseguroDB()
			.AgregarLinea( "" )
			.FuncionObtenerIndices( )
			.FuncionObtenerOperaciones()
			.FuncionObtenerColeccionOperaciones()
			.FuncionObtenerSucursalesDeSeguridad()
			.FuncionObtenerRutaTablasSeguridad()
			.FuncionObtenerSucursalesDeSeguridadXML()
			.FuncionAgregarItemOper()
			.FuncionAgregarItemMotivoyOrigenDestino()
			.FuncionCargarColeccionAtributosPk()
			.FuncionArmarColeccionEntidadesConMotivo()
			.FuncionArmarColeccionEntidadesConConcepto()
			.FuncionArmarColeccionEntidadesConOrigenDestino()

			.GenerarEstructuraAdnXML()
			Use In Select( "c_OperacionesFinal" )

			.FuncionObtenerVersion()
			.FuncionObtenerFuncionalidades()
			.FuncionVerificarFuncionalidad()
			.FuncionCopiarTablasSucursalNativa()
			.FuncionCopiarTablasSucursalSqlServer()
			.FuncionObtenerColeccionModulosPorEntidad()
			.FuncionObtenerEstructuraPrecios()
			.FuncionObtenerSelectConsultaPrecios()
			.FuncionObtenerSelectPreciosVigentes()
			.FuncionObtenerSelectConsultaPreciosConPrecioActual()
			.FuncionObtenerFuncionPrecioRealDeLaCombinacionConVigencia()
			.FuncionObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia()
			.FuncionObtenerFuncionPrecioRealDelStockConVigencia()
			.FuncionObtenerWhereConsultaPrecios()
			.FuncionObtenerWhereArticuloDeProveedor()
			.FuncionObtenerAgrupamientoyOrdenConsultaPrecios()
			.FuncionObtenerTablasConsultaPrecios()
			.FuncionObtenerTablasParticipantes()
			.FuncionObtenerCampoClaveArticulo()
			.FuncionObtenerLeftJoinsCombinacion()
			.FuncionObtenerLeftJoinsCombinacionPrecios()
			.FuncionObtenerCampoClavePrimariaParticipantes()
			.FuncionObtenerSelectStockArticulo()
			.FuncionObtenerWhereStockArticulo()
			.FuncionObtenerTablasStockArticulo()
			.FuncionObtenerSelectStockArticuloCombinacionConPrecios()
			.FuncionObtenerSelectStockArticuloCombinacion()
			.FuncionObtenerWhereStockArticuloCombinacion()
			.FuncionObtenerTablasStockCombinacion()
			.FuncionObtenerTablasStockArticuloCombinacion()
			.FuncionObtenerSentenciaInsertAtributosArticulos()
			.FuncionObtenerSentenciaInsertAtributosCombinacion()
			.FuncionObtenerCamposEstadosDeStock()
			.FuncionObtenerCamposAtributosCombinacionDeStock
			.FuncionObtenerRelacionEntreComprobantes()
			.FuncionObtenerEntidadesMenuPrincipalItems()
			.FuncionObtenerColeccionEntidadesConMenu()
			.FuncionObtenerCamposAtributosCombinacionConcatenados()
			.ObtenerValidacionesDeFiltrosDeDescuentos()
			.FuncionObtenerAtributosDeFiltrosDeDescuentos()
			.AgregarLinea( "" )
		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarEstructuraAdnXML() as Void
		local lcRuta as String, loParametros as Object
		lcRuta = addbs(addbs(_screen.Zoo.ObtenerRutaTemporal()) + sys(2015))
		md (lcRuta)

		select( 'c_EstructuraAdn_sqlserver' )

		copy to ( lcRuta + "c_EstructuraAdn_sqlserver" )
	
		select( 'c_EstructuraAdn' )
		copy to ( lcRuta + "c_EstructuraAdn" ) 
		
		local lcXmlIndices as String, lcCursor as String
		lcXmlIndices = this.ObtenerEstructuraIndices()
		lcCursor = sys(2015)
		this.xmlacursor( lcXmlIndices, lcCursor )
		select &lcCursor
		copy to ( lcRuta + "c_Indices" )
		use In Select( lcCursor )
		
		select( 'c_OperacionesFinal' )
		copy to ( lcRuta + "c_OperacionesFinal" )

		select e.Entidad, d.Atributo as AtributoMr from c_entidad e left outer join c_diccionario d on e.entidad = d.entidad where e.tipo = 'E' and muestrarelacion into cursor c_atributosMuestraRelacion

		select dic.*,;
			iif( empty( dic.ClaveForanea ), .F., .T. ) as esFc, iif( dic.claveCandidata > 0, .T., .F. ) as esCC, ent.tipo, ent.ubicaciondb, ent.Descripcion as entdesc , Mr.AtributoMr, ent.filtro as entFiltro ;
			from c_diccionario dic ;
			left join c_entidad ent on upper( alltrim( dic.entidad ) ) == upper( alltrim( ent.entidad )) ;
			left outer join c_atributosMuestraRelacion Mr on upper( alltrim ( ent.Entidad ) ) = upper( alltrim( Mr.Entidad ) )  ;
			order by dic.entidad, dic.ClaveForanea ;
			into cursor c_Estructura

		select( 'c_Estructura' )
		copy to ( lcRuta + "c_Estructura" )
		use in select( 'c_Estructura' )
	
		local lcEsquemaDefault as String, lcCursorComprobantes as String
		lcEsquemaDefault = padr( _screen.zoo.app.cSchemaDefault, 20 )
		lcUbicacionDefault = padr( "SUCURSAL", 20 )
		
		lcCursorComprobantes = this.ObtenerIndicesClaveCandidataComprobantes( lcEsquemaDefault )
		
		select Nombre, Tabla, Campos, padr( Ubicacion, 20 ) as Ubicacion, Agregados, Filtros, EsCluster, EsUnique, iif( alltrim( upper( Ubicacion ) ) == "SUCURSAL", lcEsquemaDefault, Ubicacion ) as esquema ;
		from c_Indice_SqlServer ;
		union ( ;
			select distinct "FALTAFW_" + alltrim( upper( d.tabla ) ) as Nombre, upper( d.tabla ) as Tabla, "FALTAFW" as Campos, ;
				iif( empty( e.UbicacionDb ), lcUbicacionDefault, upper( padr( e.UbicacionDb, 20 ) ) ) as Ubicacion, replicate( " ", 250) as Agregados, replicate( " ", 250) as Filtros, .t. as EsCluster, .f. as EsUnique, ;
				iif( alltrim( upper( e.UbicacionDb ) ) == "SUCURSAL" or empty( e.UbicacionDb ), lcEsquemaDefault, e.UbicacionDb ) as esquema ;
			from c_Diccionario d inner join c_entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( d.tabla ) and alltrim( upper( d.campo ) ) == "FALTAFW" and ;
				upper( alltrim( d.tabla ) ) not in ( select alltrim( upper( tabla ) ) from c_Indice_SqlServer where EsCluster ) ;
		) ;
		union ( ;
			select distinct upper( alltrim( d.campo ) ) + "_" + alltrim( upper( d.tabla ) ) as Nombre, upper( d.tabla ) as Tabla, upper( d.campo ) as Campos, ;
				iif( empty( e.UbicacionDb ), lcUbicacionDefault, upper( padr( e.UbicacionDb, 20 ) ) ) as Ubicacion, replicate( " ", 250) as Agregados, replicate( " ", 250) as Filtros, .f. as EsCluster, .f. as EsUnique, ;
				iif( alltrim( upper( e.UbicacionDb ) ) == "SUCURSAL" or empty( e.UbicacionDb ), lcEsquemaDefault, e.UbicacionDb ) as esquema ; 
			from c_Diccionario d inner join c_entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( d.tabla ) and !empty( d.Campo ) and !empty( d.claveForanea ) and  ! "<NOINDEXA>" $ alltrim( upper( d.tags ) ) ;
		);
		union ( ;
			select * from &lcCursorComprobantes ;
		);
		into cursor c_Indice_SqlServerCompleto 

		select('c_Indice_SqlServerCompleto') 
		copy to (lcRuta + "c_Indice_SqlServerCompleto")
		
		select( 'c_Diccionario' )
		copy to ( lcRuta + "DiccionarioNet" )

		select( 'c_Entidad' )
		copy to ( lcRuta + "EntidadNet" )

		select( 'c_Comprobantes' )
		copy to ( lcRuta + "ComprobantesNet" )

		use in select('c_Indice_SqlServerCompleto') 
		use in select( lcCursorComprobantes ) 
		use in select( "c_atributosMuestraRelacion" )
				
		loParametros = _Screen.zoo.crearobjeto( "ZooLogicSA.Core.ADN.ParametroGeneracion" )
		loParametros.Agregar( "Version", This.cNumeroDeVersion)
		loParametros.Agregar( "RutaTablas", lcRuta )
		loParametros.Agregar( "EstructuraXmlSqlServer", "c_EstructuraAdn_sqlserver" )
		loParametros.Agregar( "EstructuraXmlNativa", "c_EstructuraAdn" )
		loParametros.Agregar( "Indices", "c_Indices" )
		loParametros.Agregar( "Indices_SqlServer", "c_Indice_SqlServerCompleto")
		loParametros.Agregar( "Operaciones", "c_OperacionesFinal" )
		loParametros.Agregar( "Estructura", "c_Estructura")
		loParametros.Agregar( "RutaGenerados", this.cPath )

		this.oGeneradorNet.Generar( loParametros )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIndicesClaveCandidataComprobantes( tcEsquemaDefault as String ) as string
		local lcCursor as String, lcCursorRetorno as String, lcNombre as String, lcCampos as String, lcUbicacion as String, lcTabla as String, lcEsquema as String

		lcCursor = sys(2015)
		lcCursorRetorno = sys( 2015 )
		create cursor &lcCursorRetorno ( Nombre c(50), ;
			Tabla c(50), ;
			Campos c(250), ;
			Ubicacion c(20), ;
			Agregados C(250), ;
			Filtros C(250), ;
			EsCluster L, ;
			EsUnique L, ;
			Esquema C(20) )

		select c_comprobantes
		scan
			select d.entidad, d.tabla, d.campo, d.clavecandidata, d.orden, e.ubicacionDb ;
			from c_Diccionario d inner join c_entidad e on alltrim( upper( d.entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( d.clavecandidata ) and alltrim( upper( d.entidad ) ) == alltrim( upper( c_comprobantes.descripcion ) ) and ;
				alltrim( upper( d.tabla ) ) not in ( select tabla from &lcCursorRetorno ) ;
			order by d.entidad, d.clavecandidata ;
			into cursor &lcCursor
			
			if reccount( lcCursor ) > 0
				lcNombre = ""
				lcCampos = ""
				lcTabla = alltrim( upper( &lcCursor..tabla ) )
				lcUbicacion = iif( empty( &lcCursor..ubicacionDb ), "SUCURSAL", alltrim( upper( &lcCursor..ubicacionDb ) ) )
				lcEsquema = iif( lcUbicacion == "SUCURSAL", tcEsquemaDefault, lcUbicacion )
				select( lcCursor )
				scan
					lcNombre = lcNombre + alltrim( &lcCursor..campo ) + "_"
					lcCampos = lcCampos + "," + alltrim( &lcCursor..campo )
				endscan
				lcNombre = upper( lcNombre + lcTabla )
				lcCampos = upper( substr( lcCampos, 2 )	)
				
				insert into &lcCursorRetorno ( nombre, tabla, campos, ubicacion, escluster, esunique, esquema ) values ( ;
					lcNombre, lcTabla, lcCampos, lcUbicacion, .f., .t., lcEsquema )
			endif
			use in select( lcCursor )
		endscan

		return lcCursorRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtener() as Void
		local lcXmlNativa as String, lcXmlSqlServer as String, lcRuta as String 

		with this
			.ObtenerEstructura()

			.ConvertirCamposMemo( .f. )
			.ConvertirCamposGuidASQL()
			.ConvertirTablasParametrosYRegistros( .f. )
			.ConvertirCamposTipoChar()
			.ConvertirCamposTipoDate()
			lcXmlSqlServer = .cursoraxml( 'c_EstructuraAdn_sqlserver' )

			lcArchivo = forceext( this.cPath + 'Din_ADNSqlServer', "xml" )
			.XMLAArchivo( lcXmlSqlServer, lcArchivo)

			.ConvertirCamposMemo( .t. )	
			.ConvertirCamposGuidANativa()
			.ConvertirTablasParametrosYRegistros( .t. )	
			.AgregarCamploBlogregEnTablaObservacion()	

			lcXmlNativa = .cursoraxml( 'c_EstructuraAdn' )

			lcArchivo = forceext( this.cPath + 'Din_ADNNativa', "xml" )
			.XMLAArchivo( lcXmlNativa, lcArchivo)
			
			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerNativa() as String", 1 )
			.AgregarLinea( "Local lcXML as String",2)
			.AgregarLinea( "")
			.AgregarLinea( "lcXML = filetostr(this.cPathBase+'Din_ADNNativa.xml')",2)
			.AgregarLinea( "return lcXml", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")

			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerSQLServer() as String", 1 )
			.AgregarLinea( "Local lcXML as String",2)
			.AgregarLinea( "")
			.AgregarLinea( "lcXML = filetostr(this.cPathBase+'Din_ADNSqlServer.xml')",2)
			.AgregarLinea( "")
			.AgregarLinea( "return lcXml", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
			
			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerCamposAuditoriaEntidad() as Void", 1 )
			.AgregarLinea( "with this" , 2 )
			.AgregarLinea( "")
			.AgregarLinea( "text to .cXml noshow", 3  )
			.AgregarLinea( .cXmlCamposAuditoriaEntidad )
			.AgregarLinea( "endtext", 3 )
			.AgregarLinea( "")
			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "return this.cXml", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
			
			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerCamposAuditoriaDetalle() as Void", 1 )
			.AgregarLinea( "with this" , 2 )
			.AgregarLinea( "")
			.AgregarLinea( "text to .cXml noshow", 3  )
			.AgregarLinea( .cXmlCamposAuditoriaDetalle )
			.AgregarLinea( "endtext", 3 )
			.AgregarLinea( "")
			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "return this.cXml", 2 )
			.AgregarLinea( "endfunc", 1 )			
			.AgregarLinea( "")
		endwith	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionEntidadRecibeModoInseguroCentral() as Void
		local lcCursor as String

		lcCursor = sys( 2015 )
		
		select entidad from c_Entidad where "MODOSEGUROCEN" $ alltrim(upper(funcionalidades)) into cursor &lcCursor

		.AgregarLinea( "*----------------------------------------------",1)
		.AgregarLinea( "Function EntidadRecibeModoInseguroCentral( tcEntidad as string ) as Boolean", 1 )
		.AgregarLinea( "local llRetorno as boolean" , 2 )
		if _tally > 0 
			.AgregarLinea( "do case" , 2 )
		
			select &lcCursor
			scan
				.AgregarLinea( "case upper( alltrim( tcEntidad ) ) = '" + upper( alltrim( &lcCursor..Entidad ) ) + "'", 3 )
				.AgregarLinea( "llRetorno = .F.", 4 )
			endscan		
			
			.AgregarLinea( "otherwise" , 2 )
			.AgregarLinea( "llRetorno = .T." , 3 )
			.AgregarLinea( "endcase" , 2 )
		else 
			.AgregarLinea( "llRetorno = .T." , 3 )
		endif	
		.AgregarLinea( "return llRetorno" , 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionEntidadRecibeModoInseguroDB() as Void
		local lcCursor as String
		
		lcCursor = sys( 2015 )
		
		select entidad from c_Entidad where "MODOSEGURODB" $ alltrim(upper(funcionalidades)) into cursor &lcCursor

		.AgregarLinea( "*----------------------------------------------",1)
		.AgregarLinea( "Function EntidadRecibeModoInseguroDB( tcEntidad as string ) as Boolean", 1 )
		.AgregarLinea( "local llRetorno as boolean" , 2 )
		if _tally > 0 
			.AgregarLinea( "do case" , 2 )
			
			select &lcCursor
			scan
				.AgregarLinea( "case upper( alltrim( tcEntidad ) ) = '" + upper( alltrim( &lcCursor..Entidad ) ) + "'", 3 )
				.AgregarLinea( "llRetorno = .F.", 4 )
			endscan		
			
			.AgregarLinea( "otherwise" , 2 )
			.AgregarLinea( "llRetorno = .T." , 3 )
			.AgregarLinea( "endcase" , 2 )
		else 
			.AgregarLinea( "llRetorno = .T." , 3 )
		endif
		.AgregarLinea( "return llRetorno" , 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConvertirCamposTipoChar() as Void
		replace TipoDato with "V" ;
			for !( EsPK or EsFK or EsCC ) and ;
				upper( alltrim( TipoDato ) ) == "C" ;
			in c_EstructuraAdn_sqlserver
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConvertirCamposTipoDate() as Void
		replace TipoDato with "T" ;
			for upper( alltrim( TipoDato ) ) == "D" ;
			in c_EstructuraAdn_sqlserver
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraSQL() as Void
		select * ;
		from c_estructuraadn;
		where !inlist( alltrim( upper( tabla )), "SYS_S", "SYS_O", "SYS_P", "PARAMETROSSUCURSAL", "PARAMETROSORG", "PARAMETROSPUESTO" ) ;
		into cursor c_EstructuraAdn_sqlserver readwrite
		
		select * ;
			from c_diccionario ;
			where atc( "<IGNORAR_PK>", tags ) > 0 ;
			into cursor c_PksIgnoradas

		* Esta belleza se hace para ignorar claves primarias duplicadas en zl
		* Hay varias entidades con PKs en distintos campos y asignadas a las misma tabla
		select c_PksIgnoradas
		scan 
			update c_EstructuraAdn_sqlserver ;
				set esPk = .f. ;
				where alltrim( upper( tabla ) ) == alltrim( upper( c_PksIgnoradas.Tabla ) ) and ;
					alltrim( upper( campo ) ) == alltrim( upper( c_PksIgnoradas.Campo ) ) 
		endscan
		
		use in select( "c_PksIgnoradas" )
		select c_EstructuraAdn_sqlserver 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstructura() as Void
		with this
			.GenerarCursorEstructuraAdn()
			.CambiarLongitudAutoincremental()
			.CambiarTipoDatoGuid()
		endwith

		if _Screen.Zoo.App.cProyecto == "ZL"
			*Elimino posibles registros repetidos
			select * from c_EstructuraAdn group by tabla, campo into cursor c_EstructuraAdn readwrite
		endif

		*Priorizo los que son clave primaria
		select * ;
			from c_EstructuraAdn ;
			where tabla + Campo in ( select tabla + campo as TablaCampo;
										from c_EstructuraAdn ;
										group by tabla, campo having count(*) > 1 ) and ;
				esPk or esCC ;
			into cursor c_Agrupados

		select c_Agrupados
		scan 		
			delete from c_EstructuraAdn ;
				where 	alltrim( upper( campo ) ) == alltrim( upper( c_Agrupados.campo ) ) and ;
						alltrim( upper( tabla ) ) == alltrim( upper( c_Agrupados.tabla ) ) and !esPk and !esCC
		endscan
		use in select( "c_Agrupados" )

		*Priorizo los que son clave primaria y clave candidata al mismo tiempo, de los que son solo clave primaria
		select * ;
			from c_EstructuraAdn ;
			where tabla + Campo in ( select tabla + campo as TablaCampo;
										from c_EstructuraAdn ;
										group by tabla, campo having count(*) > 1 ) and ;
				esPk and esCC ;
			into cursor c_Agrupados

		select c_Agrupados
		scan 		
			delete from c_EstructuraAdn ;
				where 	alltrim( upper( campo ) ) == alltrim( upper( c_Agrupados.campo ) ) and ;
						alltrim( upper( tabla ) ) == alltrim( upper( c_Agrupados.tabla ) ) and !esCC
		endscan
		use in select( "c_Agrupados" )

		if _Screen.Zoo.App.cProyecto#"ZL"
			*Elimino posibles registros repetidos
			select * from c_EstructuraAdn group by tabla, campo into cursor c_EstructuraAdn readwrite
		endif

		replace esquema with alltrim( upper( ubicacion )) all for alltrim( upper( ubicacion )) != "SUCURSAL" and empty( esquema ) in c_EstructuraAdn
		replace esquema with this.ObtenerSchemaEntidad( c_EstructuraAdn.Tabla ) all for empty( c_EstructuraAdn.esquema ) in c_EstructuraAdn
	endfunc

	*-----------------------------------------------------------------------------------------
	function ConvertirCamposMemo( tlEsNativa as Boolean ) as Void
		local lcTabla as String, lcCursor as String, lnRecno as Integer, lcTipoDato as string

		lcTablas = ""
		lcCursor = sys(2015)
		select c_EstructuraAdn
		
		scan
			if upper( alltrim( c_estructuraAdn.TipoDato ) ) == "M" 
				if tlEsNativa
					lnRecno = recno()
					replace tipoDato with "C", Longitud with 1
					
					select d1.campo, d1.TipoDato, d1.Longitud, d1.Decimales ;
						from c_diccionario d1 ;
						where d1.clavePrimaria and ;
								upper( d1.entidad ) in ( select upper( d2.entidad ) ;
															from c_diccionario d2 ;
															where	alltrim( upper( d2.Tabla ) )== alltrim( upper( c_estructuraAdn.Tabla ) ) and ;
																	alltrim( upper( d2.Campo ) ) == alltrim( upper( c_estructuraAdn.Campo ) ) and ;
																	upper( alltrim( d2.TipoDato ) )= "M" ;
						) into cursor (lcCursor)
					
					lcTabla = alltrim( c_estructuraAdn.Tabla ) + "_" + alltrim( c_estructuraAdn.Campo )

					insert into c_EstructuraAdn ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema, esFK ) ;
						values ( lcTabla, "Id_memo", "A", 9, 0, c_estructuraAdn.Ubicacion, .t., .f., c_estructuraAdn.Esquema, c_estructuraAdn.esFK )
					insert into c_EstructuraAdn ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema, esFK ) ;
						values ( lcTabla, "Orden", "N", 16, 0, c_estructuraAdn.Ubicacion, .f., .f., c_estructuraAdn.Esquema, c_estructuraAdn.esFK )	
					insert into c_EstructuraAdn ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema, esFK ) ;
						values ( lcTabla, "Texto", "C", 80, 0, c_estructuraAdn.Ubicacion, .f., .f., c_estructuraAdn.Esquema, c_estructuraAdn.esFK )
					
					lcTipoDato = upper( &lcCursor..tipoDato )
					
					lcTipoDato = This.ConvertirTipoDato( lcTipoDato )
					insert into c_EstructuraAdn ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema, esFK ) ;
						values ( lcTabla, upper( &lcCursor..campo ), lcTipoDato, &lcCursor..Longitud, &lcCursor..Decimales, c_estructuraAdn.Ubicacion, .f., ;
							.f., c_estructuraAdn.Esquema, c_estructuraAdn.esFK )
					
					use in select( lcCursor )
					select c_EstructuraAdn
					go lnRecno
				else
					replace longitud with 4 in c_EstructuraAdn
				endif
			endif
			
			select c_estructuraAdn	
		endscan
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCursorEstructuraAdn() as Void
		
		local lcEntidadPrincipal as String
		
		if _Screen.Zoo.App.cProyecto == "ZL"
		
			select lower( Tabla ) as Tabla, lower( Campo ) as Campo, padr( lower( Tipo ), 20 ) as TipoDato, Longitud, ;
					Decimales, lower( Ubicacion ) as Ubicacion, .f. as esPK, .f. as esCC, Esquema, .f. as esFK, ;
					space( 40 ) as Entidad, space( 40 ) as Atributo, space( 40 ) as entDet ;
					from c_TablasInternas ;
					where !deleted() and ;
						!empty( c_TablasInternas.Tabla ) and ;
						!empty( c_TablasInternas.Campo ) ;
					union all ;
					select lower( Tabla ) as Tabla, lower( Campo ) as Campo, padr( lower( TipoDato ), 20 ) as TipoDato, Longitud, ;
							Decimales, iif( empty( e.ubicaciondb ), padr( "sucursal", 25 ), lower( e.ubicaciondb ) ) as Ubicacion, ;
							iif( upper( e.tipo ) == "I", .f., ClavePrimaria ) as esPK, ;
							!empty( ClaveCandidata ) as esCC, Esquema, !empty( ClaveForanea ) as esFK, ;
							lower( d.entidad ) as Entidad, lower( d.atributo ) as Atributo, space( 40 ) as entDet;
							 from c_Diccionario d inner join c_entidad e on alltrim(upper(d.entidad)) == alltrim(upper(e.entidad));
								where !deleted() and ;
									!empty( Tabla ) and ;
									!empty( Campo ) ;
				into cursor c_EstructuraAdn readwrite
			
		else
		
			select lower( Tabla ) as Tabla, ;
					lower( Campo ) as Campo, ;
					padr( lower( Tipo ), 20 ) as TipoDato, ;
					Longitud, ;
					Decimales, ;
					lower( Ubicacion ) as Ubicacion, ;
					.f. as esPK, ;
					.f. as esCC, ;
					Esquema,;
					.f. as esFK, ;
					space( 40 ) as Entidad, ;
					space( 40 ) as Atributo, ;
					space( 40 ) as entDet ;
				from c_TablasInternas ;
				where !deleted() and ;
					!empty( c_TablasInternas.Tabla ) and ;
					!empty( c_TablasInternas.Campo ) ;
				union all ;
					select lower( Tabla ) as Tabla, ;
							lower( Campo ) as Campo, ;
							padr( lower( TipoDato ), 20 ) as TipoDato, ;
							Longitud, ;
							Decimales, ;
							iif( empty( e.ubicaciondb ), padr( "sucursal", 25 ), lower( e.ubicaciondb ) ) as Ubicacion, ;
							( ClavePrimaria or ( alltrim(lower( Campo ))=="nroitem" and e.Tipo=="I" ) or (lower(alltrim(tabla))="compafe" and lower(alltrim(campo))="afecta" ) or alltrim(lower(Campo))=="Afecta" ) as esPK, ;
							!empty( ClaveCandidata ) as esCC, Esquema, !empty( ClaveForanea ) as esFK, ;
							lower( d.entidad ) as Entidad, ;
							lower( d.atributo ) as Atributo, ;
							space( 40 ) as entDet;
						 from c_Diccionario d inner join c_entidad e on alltrim(upper(d.entidad)) == alltrim(upper(e.entidad));
							where !deleted() and ;
								!empty( Tabla ) and ;
								!empty( Campo ) ;
			into cursor c_EstructuraAdn readwrite

		endif
			
		select c_EstructuraAdn
		scan all
			lcEntidadPrincipal = this.ObtenerEntidadPrincipal( c_EstructuraAdn.tabla )
			select c_EstructuraAdn
			if upper( alltrim( c_EstructuraAdn.entidad ) ) != upper( alltrim( lcEntidadPrincipal ) )
				replace entDet with lcEntidadPrincipal
			endif
		endscan
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPrincipal( tcTabla as string ) as String
		local lcCursor as String, lcEntidad as String
		lcCursor = sys( 2015 )
		select entidad from c_diccionario where claveprimaria and upper( alltrim( tabla ) ) == upper( alltrim( tcTabla ) ) into cursor ( lcCursor )
		lcEntidad = &lcCursor..entidad
		use in select( lcCursor )
		
		return lcEntidad
	endfunc	

	*-----------------------------------------------------------------------------------------
	function CerrarCursores() as Void

		use in select( "c_EstructuraAdn" )
*		use in select( "c_TablasInternas" )
		
	endfunc

	*-----------------------------------------------------------------------------------------
	Function FuncionObtenerIndices() As Void
		local lcArchivo as String, lcEstructuraXML as String
		lcArchivo = forceext( this.cPath + 'Din_ADNIndices', "xml" )
		With This
			lcEstructuraXML = .ObtenerEstructuraIndices()
			.XMLAArchivo(lcEstructuraXML,lcArchivo)
			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerIndices() as String", 1 )
			.AgregarLinea( "Local lcXML as String",2)
			.AgregarLinea( "")
			.AgregarLinea( "lcXML = filetostr(this.cPathBase+'Din_ADNIndices.xml')",2)
			.AgregarLinea( "return lcXml", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		EndWith	
	endfunc

	*-----------------------------------------------------------------------------------------
	function TransformarSalidaXmlAUtf8( tcTexto as String ) as Void
		local lcDevuelvo as string
		lcDevuelvo = tcTexto 
		lcDevuelvo = strtran( lcDevuelvo ,'encoding="Windows-1252"','encoding="utf-8"' )
		return lcDevuelvo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function FuncionObtenerOperaciones() As Void
		local lcArchivo as String, lcEstructuraXML as String
		lcArchivo = forceext( this.cPath + 'Din_ADNOperaciones', "xml" )	
		With This
			lcEstructuraXML = .ObtenerEstructuraOperacionesMenu()
			.XMLAArchivo( .TransformarSalidaXmlAUtf8(@lcEstructuraXML),lcArchivo )
			.AgregarLinea( "*----------------------------------------------", 1)
			.AgregarLinea( "Function ObtenerOperaciones() As String", 1 )
			.AgregarLinea( "Local lcXML as String",2)
			.AgregarLinea( "lcXML = filetostr(this.cPathBase+'Din_ADNOperaciones.xml')",2)
			.AgregarLinea( "this.cXmlOperacionesMenu = this.ObtenerSucursalesDeSeguridadXML( lcXml )",2 )			
			.AgregarLinea( "return this.cXmlOperacionesMenu", 2 )
			.AgregarLinea( "EndFunc", 1 )
			.AgregarLinea( "" )
		EndWith	
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerRelacionEntreComprobantes() as String
		with this
			.AgregarLinea( "*----------------------------------------------", 1)
			.AgregarLinea( "Function ObtenerRelacionEntreComprobantes() As String", 1 )
			.AgregarLinea( "with this" , 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "text to .cXmlRelacionEntreComprobantes NoShow", 3 )
			.AgregarLinea( .ObtenerEstructuraRelacionEntreComprobantes() )
			.AgregarLinea( "endtext", 3 )
			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "return this.cXmlRelacionEntreComprobantes", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerEntidadesMenuPrincipalItems() as String

		lcArchivo = forceext( this.cPath + 'Din_ADNEntidadesMenu', "xml" )	
		With This
			lcEstructuraXML = .ObtenerEstructuraEntidadesMenuPrincipalItems()
			.XMLAArchivo( .TransformarSalidaXmlAUtf8(@lcEstructuraXML),lcArchivo )
			.AgregarLinea( "*----------------------------------------------", 1)
			.AgregarLinea( "Function ObtenerEntidadesMenuPrincipalItems() As String", 1 )
			.AgregarLinea( "this.cXmlEstructuraEntidadesMenuPrincipalItems = filetostr(this.cPathBase+'Din_ADNEntidadesMenu.xml')", 3 )
			.AgregarLinea( "return this.cXmlEstructuraEntidadesMenuPrincipalItems", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraEntidadesMenuPrincipalItems() as String
		local lcXml as String

		select distinct entidad from c_menuprincipalitems into cursor "c_EntidadesMenu" 

		select e.entidad, e.descripcion, e.Funcionalidades from c_entidad e , c_EntidadesMenu aux where upper( alltrim ( e.entidad ) ) == upper( alltrim ( aux.entidad ) ) ;
			into cursor "c_EntidadesMenuPrincipalItems"

		lcXml = this.CursorAXml( "c_EntidadesMenuPrincipalItems" )
		lcXml = this.TransformarSalidaXmlAUtf8( @lcXml )
		use in select ( "c_EntidadesMenu" )
		use in select ( "c_EntidadesMenuPrincipalItems" )
		
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraRelacionEntreComprobantes() as String
		local lcXml as String
		lcXml = this.CursorAXml( "c_RelaComprobantes" )
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function CerrarCursoresIndices() As Void

		Use In Select( This.cCursorIndices )
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstructuraIndices() As String
		
		Local lcXmlEstructura
		This.GenerarCursorIndices()
		This.AgregarIndicesTransferencias()

		*Elimino posibles registros repetidos
		Select Distinct * From ( This.cCursorIndices ) Into Cursor ( This.cCursorIndices ) Order By 1,6

		Select( This.cCursorIndices )
		lcXmlEstructura = This.cursoraxml( This.cCursorIndices )

		This.CerrarCursoresIndices()

		Return lcXmlEstructura

	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarIndicesTransferencias() as Void
		local lcCursor as String, lcCursorCC as string, lcIdentificador as String, lcExpresionCC as String
		lcCursor = This.cCursorIndices
		lcCursorCC = sys( 2015 )
		select c_entidad
		scan all for tipo = "E"		

				lcIdentificador = this.obtenerIdentificador( c_entidad.entidad )
				select c_diccionario
				locate for alltrim( upper( entidad ) ) == alltrim( upper( c_entidad.entidad )) and clavePrimaria
				if found()
					insert into ( lcCursor ) ( Tabla, Expresion, Filtro, _tag, Ubicacion, ordenTag ) ;
					 values ( c_diccionario.tabla, c_diccionario.campo, alltrim( c_entidad.filtro ) , "_" + lcIdentificador + "PK" , iif( empty( c_entidad.ubicaciondb ), "sucursal", lower( c_entidad.ubicaciondb ) ), 99 )
				endif
				
				lcExpresionCC = this.ObtenerClaveCandidataConcatenada( c_entidad.entidad )
				if !empty( lcExpresionCC )
					lcExpresionCC = strtran( lcExpresionCC, "#tabla#.", "" )
					insert into ( lcCursor ) ( Tabla, Expresion, Filtro, _tag, Ubicacion, ordenTag ) ;
					 values ( c_diccionario.tabla, lcExpresionCC, alltrim( c_entidad.filtro ) , "_" + lcIdentificador + "CC" , iif( empty( c_entidad.ubicaciondb ), "sucursal", lower( c_entidad.ubicaciondb ) ), 99 )
				endif
				
			select c_entidad
		endscan
		
		use in select( lcCursorCC )

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function GenerarCursorIndices() As Void

		Local 	lnLenTabla As Integer, ;
				lnLenCampo As Integer, ;
				lnLenFiltro As Integer, ;
				lnLenTag As Integer, ;
				lcOrdenTag as String, ;
				lnLenTipo as Integer, ;
				lcTabla As String, ;
				lcCursor as String, ;
				i as Integer

		lnLenTabla = Max( Len( c_indice.tabla ), Len( c_Diccionario.tabla ) )
		lnLenCampo = Max( Len( c_indice.Expresion ), Len( c_Diccionario.Campo ) )
		lnLenFiltro = Max( Len( c_indice.Filtro ), Len( c_entidad.filtro ) )
		lnLenTag = Len( c_indice.indice )
		lnLenTipo 	= Len( c_indice.Tipo )		
		This.cCursorIndices = Sys(2015)
		lcCursor = This.cCursorIndices
 		lcOrdenTag = "99"    &&iif( at( "LINCEORGANIC", upper( This.cPath ))>0,  "99" , "00" )

		Select 	Upper( PadR( Alltrim( dic.Tabla ), lnLenTabla ) ) As Tabla, ;
				Upper( PadR( Alltrim( dic.Campo ), lnLenCampo ) ) As Expresion, ;
				Upper( PadR( Alltrim( Ent.Filtro ), lnLenFiltro ) ) As Filtro, ;
				Space( lnLenTag ) As _Tag, ;
				iif(empty(ent.ubicaciondb),padr( "sucursal", 25 ),lower(ent.ubicaciondb)) as Ubicacion ,;
				&lcOrdenTag as ordentag ;
			From c_entidad ent ;
				Inner Join c_diccionario dic On Alltrim( Upper ( dic.entidad  ) ) == Alltrim( Upper( ent.entidad ) ) ;
			Where ( ( Dic.ClavePrimaria .Or. !Empty( dic.ClaveCandidata ) ) .And. ( ent.Tipo = "E" .Or. Ent.Tipo = "I" ) ) and !empty( dic.Tabla ) and !empty( dic.Campo );
		Union ;
			Select  Upper( PadR( Alltrim( c_indice.tabla ), lnLenTabla ) ) As Tabla, ;
					Upper( PadR( Alltrim( c_indice.expresion ), lnLenCampo ) ) As Expresion, ;
					Upper( PadR( Alltrim( c_indice.filtro ), lnLenFiltro ) ) As Filtro, ;
					Upper( Padr( Alltrim( c_indice.indice ), lnLenTag ) ) As _Tag, ;
					Lower( Padr( Alltrim( c_indice.tipo ), lnLenTipo ) ) As ubicacion ,;
					c_indice.ordentag as ordentag ;
				From c_indice ;
			Into Cursor ( lcCursor ) Readwrite ;
			Order By 1

		lcTabla = ""
		Select ( lcCursor )
		
		Scan all
			If lcTabla == &lcCursor..Tabla
				i = i + 1
			Else
				lcTabla = &lcCursor..Tabla
				i = 1
			Endif
			If Empty( &lcCursor.._Tag ) 
				Replace _Tag With ( Left( Alltrim( lcTabla ), lnLenTag - 03 ) + Strtran( Str( i, 03), " ", "0" ) )
			Endif	
			Select ( lcCursor )
		endscan
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEstructuraOperacionesMenu() as String
		Local lnLen As Integer, lnIdPadre as Integer , lcCadena as String, lcRetorno As String, ;
			lcXmlEntidades as String, lcXmlOperAdic as String, lnLenDesc as Integer
		lnIdPadre = 0
		lcCadena = ''

		lnLen = len( c_MenuPrincipalItems.Etiqueta )
		 
		Select	padr( "IT_" + transform( mpi.id ), lnLen ) as id, padr( "ITEM", 10 ) as TipoOpcion, ;
				strtran( Padr( Alltrim( mpi.Etiqueta ) , lnLen ), "\<", "" ) As Item, ;
				padr( "ME_" + transform( mp.id ), lnLen ) as ItemPadre, ;
				mpi.Entidad, iif( mpi.orden = 0, 100999, mpi.orden + 100000 ) as orden, 0 as nivel, ;
				2 as modo ;
			From c_MenuPrincipalItems mpi inner Join c_MenuPrincipal mp ;
					On mpi.idPadre = mp.Id ;
			where mpi.lTieneSeguridad;
		union ;
			( Select padr( "ME_" + transform( id ), lnLen ) as id, padr( "MENU", 10 ) as TipoOpcion, ;
					strtran( Padr( Alltrim( Etiqueta ) , lnLen ), "\<", "" ) As Item, ;
					Space( lnLen ) As ItemPadre, ;
					space( 40 ) as entidad, iif( orden = 0, 100999, orden + 100000 ) as orden, 1 as nivel, ;
					2 as modo ;
				From c_MenuPrincipal ;
				Where empty( idPadre ) and lTieneSeguridad );
		union ;
			( Select padr( "ME_" + transform( id ), lnLen ) as id, padr( "MENU", 10 ) as TipoOpcion, ;
					strtran( Padr( Alltrim( Etiqueta ) , lnLen ), "\<", "" ) As Item, ;
					padr( "ME_" + transform( idPadre ), lnLen ) as ItemPadre, ;
					space( 40 ) as Entidad, iif( orden = 0, 100999, orden + 100000 ) as orden, 0 as nivel, ;
					2 as modo ;
				From c_MenuPrincipal ;
				Where !empty( idPadre ) and lTieneSeguridad ) ;
		Into Cursor c_Operaciones readwrite

		replace all orden with orden - 100000

		lcXmlEntidades = this.ObtenerEstructuraOperacionesEntidades()
		xmltocursor( lcXmlEntidades, "c_OperEntidades", 4 )

		this.AgregarOperacionesTransferencias()
		this.AgregarNodosNivelSeguridadListaDePrecios()
		this.AgregarOperacionesListados()
		this.AgregarNodoNivelSeguridadConsultas()
		
		lcXmlOperAdic = this.ObtenerEstructuraOperacionesAdicionales()
		xmltocursor( lcXmlOperAdic, "c_OperAdic", 4 )
		
		select upper( alltrim( cop.id ) ), cop.entidad, cop.item, cop.itempadre, ;
				cop.tipoopcion, cop.Orden, cop.nivel, space( 40 ) as Operacion, space( 60 ) as Descripcion, space( 200 ) as rama, cop.modo ;
			from c_Operaciones cop ;
		union ( ;
			select alltrim( upper( coe.entidad ) ) + "_" + alltrim( upper( coe.operacion ) ) as id, ;
		 		coe.entidad, space( lnLen ) as item, space( lnLen ) as itempadre, ;
		 		"ENTIDAD" as TipoOpcion, nvl( coe.Orden, nvl( cop.orden, 999 ) ) as orden, 0 as nivel, ;
		 		coe.Operacion, coe.Descripcion, space( 200 ) as rama, cop.modo ;
			from c_Operaciones cop right join c_OperEntidades coe on alltrim( upper( cop.entidad )) == alltrim( upper( coe.entidad ) ) ;
			) ;
		into cursor c_OperacionesFinal readwrite

		this.CompletarNiveles()
		this.xmlACursor( this.ObtenerNivelesOperacionesAdicionales(), "c_OperAdicFinal" )

		select * ;
			from c_OperacionesFinal ;
		union ( ;
			select id, entidad, space( lnLen ) as item, itemPadre, "ADICIONAL" as TipoOpcion, 999 as orden, ;
				nivel, "" as operacion, Descripcion, rama, 2 as modo ;
				from c_OperAdicFinal ;
			) ;
		into cursor c_OperacionesFinal readwrite

		this.CompletarNivelCero()

		select c_OperacionesFinal
		replace Descripcion with item, item with "" for inlist( TipoOpcion, "LISTADOS", "TRANSFEREN", "VERLP" )
		replace Orden with 0 for ( upper( Tipoopcion ) ='TRANSFEREN' and orden != 0 )

		select *, recno() as Indice ;
			from c_OperacionesFinal ;
			order by Nivel, ItemPadre, orden, Descripcion ;
			into cursor c_OperacionesFinal readwrite
		* esto es para colocar el modo por default en deshabilitado
		replace all modo with this.nModoDefault for empty(modo) or isnull(modo) in c_OperacionesFinal		
		
		this.SetearModosDefaultParticulares()
						
	 	lcRetorno = this.CursorAXml( "c_OperacionesFinal" )
		Use In Select( "c_Operaciones" )
		Use In Select( "c_OperEntidades" )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraOperacionesEntidades() as String
		Local lnLen As Integer, lcRetorno As String, lnLenDesc As String

		this.AgregarSeguridadNuevoEnBaseA()
		this.AgregarNodoPrincipalSeguridadListaDePrecios()
		lnLen = len( C_Entidad.Entidad )
		lnLenDesc = max( len( c_Entidad.Descripcion ) , len( c_SeguridadEntidadesDefault.DescripcionOperacion ) )

		Select	Padr( Alltrim( upper( Ent.Entidad ) ), lnLen ) As Entidad, ;
				padr( Alltrim( Sed.Operacion ), lnLen ) As Operacion,  ;
				padr( alltrim( Sed.DescripcionOperacion ), lnLenDesc ) as  DescDefault, ;
				padr( alltrim( Sed.DescripcionOperacion ), lnLenDesc ) as  Descripcion, ;
				nvl( int( val( padl( mad.orden, 3, "0" ) ) ), 999 ) as orden ;
			from c_Entidad ent, c_SeguridadEntidadesDefault Sed ;
			left join c_menuAltasDefault mad on alltrim( upper( mad.Codigo ) ) == alltrim( upper( sed.Operacion ) )  ;
			where ent.Formulario != .f. and alltrim( upper( ent.Tipo ) ) == "E" ;
			into Cursor c_Consulta NoFilter

		select upper( Entidad ) as entidad, Operacion, padr( nvl( DescDefault, "" ), lnLenDesc ) as DescDefault, Descripcion, orden as orden2 ;
			from c_Consulta ;
			where upper( Entidad ) Not In ( ;
						Select upper( Entidad ) From c_SeguridadEntidades where lSacar and empty( Operacion ) ) and ;	
				upper( Entidad + Operacion ) Not In ( ;
						Select upper( Entidad + Operacion ) From c_SeguridadEntidades where lSacar ) ;
		union ;
			select upper( SE.Entidad ) as entidad, SE.Operacion, padr( "", lnLenDesc ) as DescDefault, ;
					padr( nvl( SE.DescripcionOperacion, "" ), lnLenDesc ) as Descripcion, nvl( int( val( padl( mai.orden, 3, "0" ) ) ), 999 ) as orden2 ;
				from c_SeguridadEntidades SE;
				left join c_menuAltasItems mai on alltrim( upper( mai.Codigo ) ) == alltrim( upper( SE.Operacion ) ) and ;
					alltrim( upper( mai.Entidad ) ) == alltrim( upper( SE.Entidad ) ) ;
				where !SE.lSacar ;
			into cursor c_OperacionesEntidad2 nofilter

		*----- Acá traemos el orden que tenga cargado MENUALTASDEFAULT porque seguridadentidades.dbf no posee orden y las deja a todas en 999.
		select coe.entidad, coe.operacion, coe.descdefault, coe.descripcion, ;
				iif( coe.orden2 < 999, coe.orden2, nvl( int( val( padl( mad.orden, 3, "0" ) ) ), 999 )) as Orden ;
			from c_OperacionesEntidad2 coe ;
			left join c_menuAltasDefault mad on alltrim( upper( mad.Codigo ) ) == alltrim( upper( coe.Operacion ) ) ;
			into cursor c_OperacionesEntidad readwrite

		lcRetorno = This.cursoraxml( "c_OperacionesEntidad" )
		use in select( "c_OperacionesEntidad2" )
		Use In Select( "c_OperacionesEntidad" )
		Use In Select( "c_Consulta" )

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraOperacionesAdicionales() as String
		local lcRetorno as String
		
		select id, descripcion, idpadre, upper( entidad ) as entidad, ;
			padr( iif( empty( idmenuprincipal ), iif( empty( idmenuprincipalItem ), space( 40 ), ;
				"IT_" + transform( idmenuprincipalItem ) ), "ME_" + transform( idmenuprincipal ) ), 40, " " ) as idMenuPrincipal, ;
			iif( empty( idmenuprincipal ) and empty( idmenuprincipalItem ) and empty( idPadre ) and empty( entidad ), 2, 0 ) as nivel, ;
			space( 200 ) as rama, idPadre as ItemPadre ;
			from c_SeguridadOperacionesAdicionales ;
			order by Descripcion ;
			into cursor c_OperAdic
		
		lcRetorno = this.CursorAXml( "c_OperAdic" )
		use in select( "c_OperAdic" )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiarLongitudAutoincremental() as Void

		update c_EstructuraAdn set Longitud = 9 where Longitud <> 9 and upper(alltrim(TipoDato)) = "A"

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CambiarTipoDatoGuid() as Void

		update c_EstructuraAdn set TipoDato = 'C' where upper( alltrim( TipoDato ) ) = 'G'

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConvertirCamposGuidASQL() as Void

		update c_EstructuraAdn set tipodato = "u" where upper(campo) = "GUID"
		update c_EstructuraAdn set Longitud = 0 where upper(campo) = "GUID"

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConvertirCamposGuidANativa() as Void

		update c_EstructuraAdn set tipodato = "c" where upper(campo) = "GUID"
		update c_EstructuraAdn set Longitud = 38 where upper(campo) = "GUID"

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerVersion() as Void
		with this
			.AgregarLinea( "*----------------------------------------------", 1)
			.AgregarLinea( "Function ObtenerVersion() as String", 1 )
			.AgregarLinea( "Return '" + this.cNumeroDeVersion + "'", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompletarNiveles() as Integer
		local lnNivel as Integer, lcRama as String, lcEntidad as String, lnReg as Integer

		select * ;
			from c_OperacionesFinal ;
			into cursor c_OperTemp

		select c_OperacionesFinal
		scan
			if c_OperacionesFinal.nivel = 0
				replace nivel with this.ObtenerNivelRecursivo( "c_OperacionesFinal", "c_Opertemp", c_OperacionesFinal.ItemPadre )
			endif
			select c_OperacionesFinal
			if !empty( c_OperacionesFinal.Entidad ) and empty( c_OperacionesFinal.Operacion )
				lnReg = recno()
				lnNivel = c_OperacionesFinal.nivel + 1
				lcRama = alltrim( c_OperacionesFinal.rama ) + "." + alltrim( c_OperacionesFinal.id )
				lcEntidad = alltrim( upper( c_OperacionesFinal.Entidad ) )
				
				replace all nivel with lnNivel, ;
							rama with lcRama ;
							for alltrim( upper( entidad ) ) == lcEntidad and !empty( operacion )
							
				go lnReg
			endif
		endscan

		use in select( "c_OperTemp" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNivelRecursivo( tcCursorFinal as string, tcCursorTemporal as string, tcIdPadre as String ) as Integer
		local lnNivel as Integer

		select ( tcCursorTemporal )
		locate for alltrim( upper( id ) ) == alltrim( upper( tcIdPadre ) )
		if found()
			if &tcCursorTemporal..Nivel = 0
				replace &tcCursorFinal..Rama with "." + alltrim( tcIdPadre ) + alltrim( &tcCursorFinal..Rama )
				lnNivel = this.ObtenerNivelRecursivo( tcCursorFinal, tcCursorTemporal, &tcCursorTemporal..ItemPadre ) + 1
			else
				replace &tcCursorFinal..Rama with alltrim( tcIdPadre ) + alltrim( &tcCursorFinal..Rama )
				lnNivel = &tcCursorTemporal..Nivel + 1
			endif
		else
			** No deberia entrar nunca por aca
			lnNivel = 0
		endif
		
		return lnNivel
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNivelesOperacionesAdicionales() as String
		local lnReg as Integer, lnNivel as Integer, lcRetorno as String

		select * ;
			from c_OperAdic ;
			into cursor c_OperAdicFinal readwrite

		select c_OperAdicFinal
		scan 		
			if !empty( c_OperAdicFinal.ItemPadre )
				lnReg = recno()
				lnNivel = this.ObtenerNivelRecursivo( "c_OperAdicFinal", "c_OperAdic", c_OperAdicFinal.ItemPadre )
				select( "c_OperAdicFinal" )
				go lnReg
				replace nivel 	with lnNivel, ;
						rama 	with "OPER_ADIC." + Rama 
			else
				replace rama with "OPER_ADIC", ;
						ItemPadre with "OPER_ADIC"
				
				if !empty( c_OperAdicFinal.entidad )
					select c_OperacionesFinal
					locate for alltrim( upper( c_OperacionesFinal.Entidad ) ) == alltrim( upper( c_OperAdicFinal.Entidad ) )
					if found()
						select c_OperAdicFinal
						replace nivel 	with c_OperacionesFinal.nivel, ;
								rama 	with c_OperacionesFinal.rama, ;
								ItemPadre with c_OperacionesFinal.ItemPadre
					endif
				endif
				if !empty( c_OperAdicFinal.idMenuPrincipal )
					select c_OperacionesFinal
					locate for alltrim( upper( c_OperacionesFinal.id ) ) == alltrim( upper( c_OperAdicFinal.idMenuPrincipal ) )
					if found()
						select c_OperAdicFinal
						replace nivel 	with c_OperacionesFinal.nivel + 1, ;
								rama 	with iif( empty( c_OperacionesFinal.rama ), "", alltrim( c_OperacionesFinal.rama ) + "." ) + ;
												c_OperAdicFinal.idMenuPrincipal, ;
								ItemPadre with c_OperAdicFinal.idMenuPrincipal											
					endif
				endif
			endif			
		endscan

		insert into c_OperAdicFinal ( id, Descripcion, nivel ) values ( "OPER_ADIC", "Operaciones Adicionales", 1 )

		lcRetorno = this.CursorAXml( "c_OperAdicFinal" )
		use in select( "c_OperAdicFinal" )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompletarNivelCero() as Void
		
		select o.*, ent.Descripcion as descEnt ;
			from c_OperacionesFinal o inner join c_entidad ent on alltrim( upper( o.Entidad ) ) == alltrim( upper( ent.entidad ) ) ;
			where o.nivel = 0 ;
			group by o.entidad ;
			into cursor c_NivelCero

		scan 
			select c_OperacionesFinal
			replace all itempadre with upper( c_NivelCero.Entidad ), ;
						nivel 	with 3, ;
						rama 	with "OPER_ADIC." + alltrim( upper( c_NivelCero.Entidad ) ) ; 
						for alltrim( upper( entidad ) ) == alltrim( upper( c_NivelCero.Entidad ) )

			insert into c_OperacionesFinal ( id, Entidad, ItemPadre, TipoOpcion, nivel, Descripcion, rama, orden ) ;
				values ( upper( c_NivelCero.Entidad ), upper( c_NivelCero.Entidad ), "OPER_ADIC", "ENTIDAD", 2, c_NivelCero.descEnt, "OPER_ADIC", 999 )
		endscan

		
		use in select( "c_NivelCero" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerColeccionOperaciones() as Void
		local lcPadre as String
		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------", 1)
			.AgregarLinea( "Function ObtenerColeccionOperaciones( tnDataSessionId as integer, tcClavePadre as String, toColOperaciones as ZooColeccion of ZooColeccion.prg ) as Void", 1 )
			.AgregarLinea( "local lnData as Integer, loColOperacion as zoocoleccion OF zoocoleccion.prg, lcClavePadre as String, llRetornarCol as Boolean", 2 )
			.AgregarLinea( "lcClavePadre = iif( vartype( tcClavePadre ) == 'C', tcClavePadre, null )", 2 )
			.AgregarLinea( "llRetornarCol = .t.", 2 )
			.AgregarLinea( "lnData = set('Datasession')", 2 )			
			.AgregarLinea( "set datasession to ( tnDataSessionId )", 2 )

			.AgregarLinea( "if vartype( toColOperaciones ) == 'O'", 2 )
			.AgregarLinea( "llRetornarCol = .f.", 3 )			
			.AgregarLinea( "loColOperaciones = toColOperaciones", 3 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "loColOperaciones = _screen.zoo.CrearObjeto( 'ZooColeccion' )", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "this.ObtenerSucursalesDeSeguridad( loColOperaciones, lcClavePadre )", 2 )
			.AgregarLinea( "this.xmlacursor(filetostr(this.cPathBase+'din_ADNOperaciones.xml'),'auxOpe')", 2 )
			.AgregarLinea( "select('auxOpe')",2)
			.AgregarLinea( "scan",2)
			.AgregarLinea( "if empty( alltrim( rama ) )",3)
			.AgregarLinea( "lcPadre = ''",4)
			.AgregarLinea( "else",3)
			.AgregarLinea( "lcPadre = right( alltrim( rama ), len( alltrim( rama )) - rat( '.', alltrim( rama )))",4)
			.AgregarLinea( "endif",3)

			.AgregarLinea( "this.AgregarItemOper( loColOperaciones, alltrim( auxOpe.id ),alltrim( auxOpe.entidad ),alltrim( auxOpe.item ),alltrim( lcPadre );",3)
			.AgregarLinea( ",alltrim( auxOpe.tipoOpcion ),auxOpe.Orden,auxOpe.nivel,alltrim( auxOpe.rama ),alltrim( auxOpe.Operacion ),alltrim( auxOpe.Descripcion );",3)
			.AgregarLinea( ",'',datetime(),lcClavePadre,iif(empty(modo),2,modo), 2 )",3)

			.AgregarLinea( "endscan",2)
			.AgregarLinea( "use in select('auxOpe')",2)
			.AgregarLinea( "set datasession to ( lnData )", 2 )
						
			.AgregarLinea( "if llRetornarCol", 2 )
			.AgregarLinea( "return loColOperaciones", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionAgregarItemOper() as Void
		with this
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function AgregarItemOper( toCol, tcId, tcEntidad, tcItem, tcItemPadre, tcTipoOpcion, tnOrden, tnNivel, tcRama, tcOperacion, tcDescripcion, tcUsuario, ttFecha, tcFiltroPadre, tnModo, tnModoPerfil ) as Void", 1 )
				.AgregarLinea( "local loItem as Custom", 2 )
				.AgregarLinea( "" )
				.AgregarLinea( "if empty(tnModo)", 2 )
				.AgregarLinea( "tnModo = 2", 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "if isnull( tcFiltroPadre ) or alltrim( upper( tcFiltroPadre )) == alltrim( upper( tcItemPadre ))", 2 )
				.AgregarLinea( "loItem = newobject( 'ItemAcceso' )", 3 )
				.AgregarLinea( "loItem.id = tcId", 3 )
				.AgregarLinea( "loItem.entidad = tcEntidad", 3 )
				.AgregarLinea( "loItem.item = tcItem", 3 )
				.AgregarLinea( "loItem.itempadre = tcItemPadre", 3 )
				.AgregarLinea( "loItem.tipoopcion = tcTipoOpcion", 3 )
				.AgregarLinea( "loItem.Orden = tnOrden", 3 )
				.AgregarLinea( "loItem.nivel = tnNivel", 3 )
				.AgregarLinea( "loItem.Rama = tcRama", 3 )
				.AgregarLinea( "loItem.Operacion = tcOperacion", 3 )
				.AgregarLinea( "loItem.Descripcion = tcDescripcion", 3 )
				.AgregarLinea( "loItem.Modo = tnModo", 3 )
				.AgregarLinea( "loItem.ModoPerfil = tnModoPerfil", 3 )
				.AgregarLinea( "loItem.Usuario = ''", 3 )
				.AgregarLinea( "loItem.Fecha = ctot( '' )", 3 )
				.AgregarLinea( "loItem.lEliminar = .f.", 3 )	
				.AgregarLinea( "loItem.dtUltimoAcceso = ctot( '' )", 3 )
				.AgregarLinea( "loItem.nIndice = toCol.Count + 1", 3 )						
				.AgregarLinea( "" )
				.AgregarLinea( "toCol.Agregar( loItem, tcId )", 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "endfunc", 1 )				
				.AgregarLinea( "")
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionAgregarItemMotivoyOrigenDestino() as Void
		with this
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function AgregarItemMotivoyOrigenDestino( toCol, tcEntidad, tcAtributo, tcCampo ) as Void", 1 )
				.AgregarLinea( "local loItem as Custom", 2 )
				.AgregarLinea( "" )

				.AgregarLinea( "loItem = newobject( 'ItemMotivo' )", 2 )
				.AgregarLinea( "loItem.entidad = tcEntidad", 2 )
				.AgregarLinea( "loItem.Atributo = tcAtributo", 2 )
				.AgregarLinea( "loItem.Campo = tcCampo", 2 )
				.AgregarLinea( "" )
				.AgregarLinea( "toCol.Agregar( loItem, tcEntidad)", 2 )

				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSucursalesDeSeguridad() as Void
		local lcString as String
		lcString = ""

		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "Function ObtenerSucursalesDeSeguridad( toColOperaciones, tcClavePadre ) as Void", 1 )
			.AgregarLinea( "local lcXML as String, lcCursor as String, lcTablaSeguridad as String, lcSql as String", 2 )
			.AgregarLinea( "lcCursor = sys( 2015 )", 2 )			
			.AgregarLinea( "if goDatos.EsNativa()", 2 )
			.AgregarLinea( "lcTablaSeguridad = addbs( this.ObtenerRutaTablasSeguridad()) + 'basededatos.dbf'", 3 )				
			.AgregarLinea( "endif", 2 )			
			
			text to lcString textmerge noshow pretext 4+2+1+8
				lcSql = 'Select cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( idDB )) as char(254)) as idDB, cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( NombreDB )) as char(254)) as NombreDB, cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( Usuario )) as char(254)) as Usuario, fecha from ' + goDatos.ObtenerSchemaSeguridad() + 'BaseDeDatos order by NombreDB'
			endtext

			.AgregarLinea( lcString, 2 )
			.AgregarLinea( "if goDatos.EsSqlServer()", 2 )
			.AgregarLinea( "lcXML = goDatos.EjecutarSql( lcSql )", 3 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "lcXML = goDatos.Consultar( lcSQl, lcTablaSeguridad )", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "xmltocursor( lcXML, lcCursor )", 2 )
			.AgregarLinea( "select &lcCursor", 2 )
			.AgregarLinea( "this.AgregarItemOper( toColOperaciones, 'DB1', '', 'Base de datos', '', 'BD', 999, 1, '', 'Base de datos', 'Base de datos', '', datetime(), tcClavePadre,6 )", 3 )
			.AgregarLinea( "scan", 2 )
			.AgregarLinea( "this.AgregarItemOper( toColOperaciones, alltrim( idDB ), '', NombreDB, 'DB1', 'BD', 999, 2, 'DB1', NombreDB, NombreDB, '', datetime(), tcClavePadre )", 3 )
			.AgregarLinea( "endscan", 2 )
			.AgregarLinea( "use in select( lcCursor )", 2 )			
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSucursalesDeSeguridadXML() as Void
		local lcString as String
		lcString = ""

		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "Function ObtenerSucursalesDeSeguridadXML( tcXML as String ) as String", 1 )
			.AgregarLinea( "local lcXML as String, lcCursorOPer as String, lcCursor as String, loItem as Object, lcTablaSeguridad as String, lcSql as String", 2 )
			.AgregarLinea( "" )	
			.AgregarLinea( "lcCursor = sys( 2015 )", 2 )	
			.AgregarLinea( "lcCursorOPer = sys( 2015 )", 2 )	
			.AgregarLinea( "" )	
			.AgregarLinea( "this.XmlACursor( tcXML, lcCursorOPer )", 2 )
			.AgregarLinea( "if goDatos.EsNativa()", 2 )
			.AgregarLinea( "lcTablaSeguridad = addbs( this.ObtenerRutaTablasSeguridad()) + 'basededatos.dbf'", 3 )				
			.AgregarLinea( "endif", 2 )						

			text to lcString textmerge noshow pretext 4+2+1+8
				lcSql = 'Select cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( idDB )) as char(254)) as idDB, cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( NombreDB )) as char(254)) as NombreDB, cast( ' + goDatos.ObtenerSchemaFunciones() + '.DesEncriptar192( ' + goDatos.ObtenerFuncion( 'Alltrim' ) +
						'( Usuario )) as char(254)) as Usuario, fecha from ' + goDatos.ObtenerSchemaSeguridad() + 'BaseDeDatos'
			endtext 
			.AgregarLinea( lcString, 2 )
			.AgregarLinea( "if goDatos.EsSqlServer()", 2 )
			.AgregarLinea( "if goServicios.Librerias.ExisteBaseDeDatosSqlServer( _screen.zoo.app.cNombreBaseDeDatosSql )", 3 )
			.AgregarLinea( "lcXML = goDatos.EjecutarSql( lcSql )", 4 )
			.AgregarLinea( "else", 3 )
			.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'La base de datos ' + _screen.zoo.app.cNombreBaseDeDatosSql + ' no existe' )", 4 )
			.AgregarLinea( "endif", 3 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "lcXML = goDatos.Consultar( lcSQl, lcTablaSeguridad )", 3 )
			.AgregarLinea( "endif", 2 )			
			.AgregarLinea( "this.xmlacursor( lcXML, lcCursor )", 2 )
			.AgregarLinea( "" )	
			.AgregarLinea( "select &lcCursor", 2 )
			.AgregarLinea( "insert into &lcCursorOper ( id, item, itempadre, tipoopcion, orden, nivel, operacion, descripcion, rama ) values ;", 2 )
			.AgregarLinea( "( 'DB1', 'Base de datos', '', 'BD', 999, 1, '', 'Base de datos', 'Base de datos' ) ", 2 )
			.AgregarLinea( "" )	
			.AgregarLinea( "scan", 2 )
			.AgregarLinea( "insert into &lcCursorOper ( id, item, itempadre, tipoopcion, orden, nivel, operacion, descripcion, rama ) values ;", 3 )
			.AgregarLinea( "( &lcCursor..idDB, &lcCursor..NombreDB, 'DB1', 'BD', 999, 2, 'DB1', &lcCursor..NombreDB, &lcCursor..NombreDB ) ", 3 )			
			.AgregarLinea( "endscan", 2 )
			.AgregarLinea( "" )	
			.AgregarLinea( "lcXML = this.CursorAXml( lcCursorOPer )", 2 )	
			.AgregarLinea( "use in select( lcCursor )", 2 )			
			.AgregarLinea( "use in select( lcCursorOPer )", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return lcXML", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerRutaTablasSeguridad() as Void
		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "protected function ObtenerRutaTablasSeguridad() as String", 1 )
			.AgregarLinea( "return _Screen.zoo.app.cRutaTablasSeguridad", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerId( tcItem as String ) as String
		local lcRetorno as String, lcCursor as String, lcItem as String
		select c_Operaciones
		lcRetorno = ""
		lcCursor = sys( 2015 )

		select strtran( Alltrim( Etiqueta ), "\<", "" ) as etiqueta from c_MenuPrincipalItems ;
			where strtran( alltrim( upper( Codigo ) ), "\<", "" ) == alltrim( upper( tcItem ) ) ;
			into cursor &lcCursor
		
		if reccount( lcCursor ) > 0
			lcItem = &lcCursor..etiqueta
			use in select( lcCursor )

			select id from c_operaciones ;
				where alltrim( upper( Item ) ) == alltrim( upper( lcItem ) ) ;
				into cursor &lcCursor
	
			if reccount( lcCursor ) > 0
				lcRetorno = &lcCursor..Id
			endif
		endif
		
		use in select( lcCursor )
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarOperacionesTransferencias() as void
		local lcCursor as String, lcCursorAgrupadas as String, lcCursorCentralizadas as String, ;
			lcCursorRetorno as String, lcXml as String, lnNivel as Integer, lcIdTransferencias as String
		
		lcCursor = sys( 2015 )
		lcCursorAgrupadas = sys( 2015 )
		lcCursorCentralizadas = sys( 2015 )

		lcXml = this.ObtenerXmlTransferencias()
		xmltocursor( lcXml, lcCursor, 4 )

		lcXml = this.ObtenerXmlTransferenciasAgrupadas()
		xmltocursor( lcXml, lcCursorAgrupadas, 4 )
		select transform( id, "999999" ) as Entidad, Descripcion, 999 as orden from &lcCursorAgrupadas into cursor &lcCursorAgrupadas

		lcXml = this.ObtenerXmlTransferenciasCentralizadas()
		xmltocursor( lcXml, lcCursorCentralizadas, 4 )
		
		lcIdTransferencias = this.ObtenerId( "ENVIAR" )

		if !empty( lcIdTransferencias )
			this.AgregarACursorC_Operaciones( lcCursor, "TR_ABDD", "A Bases de datos", "TRANSFEREN", 1, lcIdTransferencias )
			this.AgregarACursorC_Operaciones( lcCursorAgrupadas, "TR_AGRU", "Agrupadas", "TRANSFEREN", 2, lcIdTransferencias )
			this.AgregarACursorC_Operaciones( lcCursorCentralizadas, "TR_ACEN", "A Central", "TRANSFEREN", 3, lcIdTransferencias )
		endif
		
		use in select( lcCursor )
		use in select( lcCursorAgrupadas )
		use in select( lcCursorCentralizadas )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarACursorC_Operaciones( tcCursor as String, tcId as String, ;
			tcDescripcion as String, tcTipo as String, tnOrden as Integer, tcIdTransferencias as String ) as Void
		local lcPrefijo as String

		tcTipo = upper( tcTipo )
		lcPrefijo = tcId + "_"
		select( tcCursor )
		if reccount( tcCursor ) > 0
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, Item, orden ) ;
				values ( tcId, tcTipo, tcIdTransferencias, tcDescripcion, tnOrden )
			
			select( tcCursor )
			scan
				insert into c_Operaciones ( id, TipoOpcion, ItemPadre, Item, orden ) ;
					values ( lcPrefijo + upper( alltrim( &tcCursor..Entidad ) ), tcTipo, ;
						tcId, alltrim( &tcCursor..Descripcion ), &tcCursor..Orden )
						
				if tcDescripcion = "A Bases de datos"
					lcIDPadre = lcPrefijo + upper( alltrim( &tcCursor..Entidad ) )
					insert into c_Operaciones ( id, TipoOpcion, ItemPadre, Item, orden, modo) ;
						values ( lcIDPadre  + "_BUZ" , Tctipo, lcIDPadre, "Buzón", 1, 1)  
					insert into c_Operaciones ( id, TipoOpcion, ItemPadre, Item, orden, modo) ;
						values ( lcIDPadre + "_BDD" , Tctipo, lcIDPadre, "Base de Datos", 2, 1) 
					insert into c_Operaciones ( id, TipoOpcion, ItemPadre, Item, orden, modo) ;
						values ( lcIDPadre + "_RUTA" , Tctipo, lcIDPadre, "Ruta", 3, 1) 
				endif
			endscan
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarOperacionesListados() as void
		local lcIdListados as String, lcCursor as String, lcCursorSecuencial as String, lcCursorAgrupados as String ;
			lcEtiqueta as String, lnidPadre as Integer, lcNodo as String, lcNodoPadre  as String, llAgrupado as Boolean

		lcCursor = sys( 2015 )
		lcCursorAgrupados = sys( 2015 )
		lcCursorSecuencial = sys( 2015 )

		lcXml = this.CrearXmlJerarquiaListados()
		xmltocursor( lcXml, lcCursor, 4 )

		lcXml = this.CrearXmlListadosAgrupados()
		xmltocursor( lcXml, lcCursorAgrupados, 4 )

		lcXml = this.CrearXmlListadosSecuencial()
		xmltocursor( lcXml, lcCursorSecuencial, 4 )
		
		select idNodo, idListado, NombreNodo, idNodoPadre, Orden, " " as tipo from ( lcCursor ) ;
		union ( select idNodo, idListado, NombreNodo, idNodoPadre, Orden, tipo from ( lcCursorAgrupados ) );
		union ( select 000000 as idNodo, LisSecCod as idListado, LisSecDes as NombreNodo, idNodo as idNodoPadre, Orden, "S#" as tipo from ( lcCursorSecuencial ) );			
		order by Orden ;		
		into cursor ( lcCursor )

		use in select( lcCursorSecuencial )
		use in select( lcCursorAgrupados )		

		lcIdListados = this.ObtenerId( "LISTADOS DINÁMICOS" ) && Va y busca la entrada de menu principal esta.
		if !empty( lcIdListados )
			select( lcCursor )
			scan
				llAgrupado = ( &lcCursor..idNodo + &lcCursor..idNodoPadre =  -1 )
				if !llAgrupado && se excluye por el momento (11/2018) el tratamiento de los listados agrupados para seguridad 
					lcEtiqueta = alltrim( &lcCursor..NombreNodo )
					lnidPadre = &lcCursor..idNodoPadre
					
					if empty( &lcCursor..idNodo )
						if alltrim( &lcCursor..tipo ) == "S#"
							lcNodo = "LSECUENCIAL_" + alltrim( &lcCursor..idListado )
						else
							lcNodo = "LI_" +  alltrim( &lcCursor..idListado )
						endif
					else
						lcNodo = "LIP_" +  transform( &lcCursor..idNodo )
					endif

					if lnidPadre > 0 && or llAgrupado
						lcNodoPadre = "LIP_" + transform( lnIdPadre ) 
					else
						lcNodoPadre = lcIdListados 
					endif
					
					lcNodo = upper( alltrim( lcNodo ) )
					insert into c_Operaciones ( 	id,	TipoOpcion, 	ItemPadre, 		 Item, 			  orden ) ;
									    values( lcNodo, "LISTADOS",   lcNodoPadre, lcEtiqueta, &lcCursor..Orden )
									    
				endif				    
			endscan
		endif
		use in select( lcCursor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerFuncionalidades() as Void
		local lcCursor as string, lcEstructuraXML as String
		lcCursor = "c_FuncionObtenerFuncionalidades" + sys( 2015 )
		lcCursor = this.ObtenerCursorFuncionalidad()
		
		lcEstructuraXML = this.CursorAXml( lcCursor )
		use in select( lcCursor )

		local lcArchivo as String, lcEstructuraXML as String &&, lcCursor as String
		lcArchivo = forceext( this.cPath + 'Din_ADNFuncionalidades', "xml" )

		local lcArchivo as String, lcEstructuraXML as String &&, lcCursor as String
		lcArchivo = forceext( this.cPath + 'Din_ADNFuncionalidades', "xml" )

		with this as GeneradorDinamicoEstructuraADN of GeneradorDinamicoEstructuraADN.prg
			.XMLAArchivo(lcEstructuraXML,lcArchivo)

			.AgregarLinea( "*----------------------------------------------", 1 )
			.AgregarLinea( "Function ObtenerFuncionalidades() as String", 1 )
			.AgregarLinea( "Local lcXML as String",2)
			.AgregarLinea( "")
			.AgregarLinea( "lcXML = filetostr(this.cPathBase+'Din_ADNFuncionalidades.xml')",2)
			.AgregarLinea( "return lcXml", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")

		EndWith	

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorFuncionalidad() as String
		local lcCursor as String
		
		lcCursor = "c_ObtenerCursorFuncionalidad" + sys( 2015 )
		select 	upper( e.Entidad ) as Entidad, e.Descripcion, upper( padr( d.tabla, 30 ) ) as tabla, upper( d.atributo ) as atributo, upper( d.campo ) as campo, upper( tipodato ) as tipodato, ;
				e.Funcionalidades as Funcionalidades, upper( e.comportamiento ) as comportamiento, upper( d.tags ) as tags, d.ClavePrimaria, ;
				e.Tipo, e.Formulario, .F. as TieneMenu ;
		from c_Entidad e ; 
		inner join c_diccionario d on alltrim( upper( e.entidad )) == alltrim( upper( d.entidad ));
		where !( empty( d.tabla ) and empty( d.campo )) ;
				and !"DETALLE" $ left( alltrim( d.dominio ), 7 ) ;
		into cursor &lcCursor nofilter readwrite
		
		select ( lcCursor )
		
		update ( lcCursor ) set TieneMenu = .t. where ;
			 alltrim( upper( Entidad ) ) in ( select upper( alltrim( e.Entidad ) ) as entidad ;
									from c_entidad e ;
									left join c_menuprincipalitems menuItems on upper( alltrim( menuItems.entidad ) ) == upper( alltrim( e.entidad ) )  ;
									left join c_menuprincipal menuPrincipal on menuItems.idpadre == menuPrincipal.id where !isnull( menuItems.orden ) )
				
		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionVerificarFuncionalidad() as Void
		.AgregarLinea( "*----------------------------------------------", 1 )
		.AgregarLinea( "function VerificarFuncionalidad( tcEntidad as string, tcFuncionalidad as string ) as boolean", 1 )
		.AgregarLinea( "local llRetorno as boolean, lcCursor as string, lcFuncionalidad as string", 2 )
		.AgregarLinea( "lcCursor = this.cCursorFuncionalidades", 2 )
		.AgregarLinea( "lcFuncionalidad = upper( alltrim( tcFuncionalidad ) )", 2 )
		.AgregarLinea( "if left( lcFuncionalidad, 1 ) # '<'", 2 )
		.AgregarLinea( "lcFuncionalidad = '<' + lcFuncionalidad", 3 )
		.AgregarLinea( "endif", 2 )
		.AgregarLinea( "if right( lcFuncionalidad, 1 ) # '>'", 2 )
		.AgregarLinea( "lcFuncionalidad = lcFuncionalidad + '>'", 3 )
		.AgregarLinea( "endif", 2 )
		.AgregarLinea( "if !used( lcCursor )", 2 )
		.AgregarLinea( "this.XmlACursor( this.ObtenerFuncionalidades(), lcCursor )", 3 )
		.AgregarLinea( "endif", 2 )
		.AgregarLinea( "locate for upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and lcFuncionalidad $ upper( alltrim( Funcionalidades ) )", 2 )
		.AgregarLinea( "llRetorno = found( lcCursor )", 2 )
		.AgregarLinea( "return llRetorno", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionCopiarTablasSucursalNativa() as Void
		local loEstructura as Object, lcXmlFunc as String, lcScript as String, llRetorno as Boolean, loError as zooexception OF zooexception.prg, ;
			lcCursor as String, lcCursorEnt as String, lcCursorAtr as String, lcTablaAnt as String, lcTabla as String, lcCursorMemo as String, lcCursorPk as String
			
		.AgregarLinea( "*----------------------------------------------", 1 )
		.AgregarLinea( "function CopiarTablasSucursalNativa( tcRutaOrigen as String, tcRutaDestino as String, tcSucursalOrigen as String, tcSucursalDestino as String ) as Void", 1 )

		lcCursor = sys( 2015 )		
		lcCursorEnt = sys( 2015 )
		lcCursorAtr = sys( 2015 )	
		lcCursorMemo = sys( 2015 )	
		lcCursorPk = sys( 2015 )	

		try
			lcCursor = this.ObtenerCursorFuncionalidad()
			insert into &lcCursor ( Tabla, Campo, Tipodato, comportamiento ) ;
				select Tabla, Campo, Tipo, "W" from c_TablasInternas ;
					where inlist( alltrim( upper( c_TablasInternas.tabla )), "PARAMETROSSUCURSAL", "SYS_S" )

			select distinct tabla, comportamiento ;
			from &lcCursor ;
			where "W" $ alltrim( upper( comportamiento )) ;
			order by tabla ;
			into cursor &lcCursorEnt
			
			.AgregarLinea( "local loLogCopia as Object, lcMensaje as String, lcSql as String, lcTabla as String, lcTablaOrigen as String, lcTablaDestino as String, lcSucOrigen as string, lcSucDestino as string", 2 )
			.AgregarLinea( "loLogCopia = _Screen.zoo.crearobjeto( 'MostrarCopiaDB' )", 2 )
			.AgregarLinea( "loLogCopia.inicializar( tcSucursalDestino, tcRutaDestino , " + transform( reccount( lcCursorEnt )) + ")", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "lcSucOrigen = 'o_' + strtran( strtran( strtran( alltrim( tcSucursalOrigen ), '-', '' ), ' ', ''), '.', '')", 2 )
			.AgregarLinea( "lcSucDestino = 'd_' + strtran( strtran( strtran( alltrim( tcSucursalDestino ), '-', '' ), ' ', ''), '.', '')", 2 )
			.AgregarLinea( "try", 2 )
				
			select ( lcCursorEnt )
			scan
				.AgregarLinea( "*----------" + alltrim( upper( &lcCursorEnt..tabla )) + "----------------------------", 3 )			
			    .AgregarLinea( "lcTabla = '" + alltrim( upper( &lcCursorEnt..tabla )) + "'", 3 )
			    **Se agrega un prefijo a los nombres de las sucursales para que no pinche al tener suc. que empiecen con numeros
			    .AgregarLinea( "lcTablaOrigen = lcSucOrigen + '_" + alltrim( upper( &lcCursorEnt..tabla )) + "'", 3 )
			    .AgregarLinea( "lcTablaDestino = lcSucDestino + '_" + alltrim( upper( &lcCursorEnt..tabla )) + "'", 3 )
			    .AgregarLinea( "use in 0 addbs( tcRutaDestino ) + '" + alltrim( upper( &lcCursorEnt..tabla )) + "' alias &lcTablaDestino exclusive", 3 )
			    .AgregarLinea( "use in 0 addbs( tcRutaOrigen ) + '" + alltrim( upper( &lcCursorEnt..tabla )) + "' alias &lcTablaOrigen", 3 )

				select distinct campo, tags ;
				from &lcCursor ;
				where alltrim( upper( tabla )) == alltrim( upper( &lcCursorEnt..tabla )) ;
						and alltrim( upper( comportamiento )) == alltrim( upper( &lcCursorEnt..comportamiento )) and !empty( campo ) ;				
				order by campo ;
				into cursor &lcCursorAtr
				
				lcCampos = this.ObtenerCampos( lcCursorAtr )
				.AgregarLinea( "zap in ( lcTablaDestino )", 3 )
				
				.AgregarLinea( "text to lcSql textmerge noshow pretext 7", 3 )
			    .AgregarLinea( "insert into << lcTablaDestino >> " + lcCampos + " select " + strextract( lcCampos, "(", ")" ) + " from << lcTablaOrigen >>", 4 )
				.AgregarLinea( "endtext", 3 )			    
			    .AgregarLinea( "&lcSql", 3 )

				select distinct campo, tabla ;
				from &lcCursor ;
				where alltrim( upper( &lcCursor..tabla )) == alltrim( upper( &lcCursorEnt..tabla )) ;
						and alltrim( upper( comportamiento )) == alltrim( upper( &lcCursorEnt..comportamiento )) ;				
						and alltrim( upper ( &lcCursor..tipodato )) == "M" ;					
				order by &lcCursor..campo ;
				into cursor &lcCursorMemo

				select distinct campo ;
				from &lcCursor ;
				where alltrim( upper( &lcCursor..tabla )) == alltrim( upper( &lcCursorEnt..tabla )) ;
						and alltrim( upper( comportamiento )) == alltrim( upper( &lcCursorEnt..comportamiento )) ;				
						and claveprimaria ;
				into cursor &lcCursorPk
				
			    .AgregarLinea( "use in select( lcTablaOrigen )", 3 )
			    .AgregarLinea( "use in select( lcTablaDestino )", 3 )	
				
				select ( lcCursorMemo )		
				
				scan
					lcTabla = alltrim( upper( &lcCursorMemo..tabla )) + "_" + alltrim( &lcCursorMemo..Campo )
					.AgregarLinea( "try", 3 )
					    .AgregarLinea( "lcTablaOrigen = 'o_" + alltrim( upper( &lcCursorMemo..tabla )) + "_" + alltrim( &lcCursorMemo..Campo ) + "'", 4 )
					    .AgregarLinea( "lcTablaDestino = 'd_" + alltrim( upper( &lcCursorMemo..tabla )) + "_" + alltrim( &lcCursorMemo..Campo ) + "'", 4 )
					    .AgregarLinea( "use in 0 addbs( tcRutaDestino ) + '" + lcTabla + "' alias &lcTablaDestino exclusive", 4 )
					    .AgregarLinea( "use in 0 addbs( tcRutaOrigen ) + '" + lcTabla + "' alias &lcTablaOrigen", 4 )											
						.AgregarLinea( "zap in ( lcTablaDestino )", 4 )
						.AgregarLinea( "lcSql = 'insert into ' + lcTablaDestino + '( " + alltrim( &lcCursorPk..Campo ) + ", Orden, Texto ) ' + ;", 4 )
						.AgregarLinea( "'select  " + alltrim( &lcCursorPk..Campo ) + ", Orden, Texto from ' + lcTablaOrigen", 4 )
					    .AgregarLinea( "&lcSql", 4 )
				    .AgregarLinea( "catch to loError", 3 )
			     		.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", 4 )
					.AgregarLinea( "finally", 3 )			     	
						.AgregarLinea( "use in select( lcTablaDestino ) ", 4 )
						.AgregarLinea( "use in select( lcTablaOrigen ) ", 4 )
					.AgregarLinea( "endtry", 3 )
				endscan			

			    .AgregarLinea( "loLogCopia.Actualizar( lcTabla, 'Copiado ok.' )", 3 )							
				.AgregarLinea( "" )			    				
			endscan
	
			.AgregarLinea( "catch to loError", 2 )
		    .AgregarLinea( "lcMensaje = 'Problemas al generar la nueva base de datos. '", 3 )
		    .AgregarLinea( "lcMensaje= lcMensaje + 'Cierre las aplicaciones relacionadas y verifique los permisos de escritura que posee. Si el problema persiste, póngase en contacto con el administrador.'", 3 )
		    .AgregarLinea( "loLogCopia.Actualizar( lcTabla , 'Error al copiar.' )", 3 )
		    .AgregarLinea( "goServicios.Errores.LevantarExcepcion( lcMensaje )", 3 )
			.AgregarLinea( "finally", 2 )
		    .AgregarLinea( "loLogCopia.Finalizar()", 3 )
		    .AgregarLinea( "release loLogCopia", 3 )
		    .AgregarLinea( "use in select( lcTablaOrigen )", 3 )
		    .AgregarLinea( "use in select( lcTablaDestino )", 3 )
			.AgregarLinea( "endtry", 2 )		
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcCursor )
			use in select( lcCursorEnt )
			use in select( lcCursorAtr )	
			use in select( lcCursorMemo )						
			use in select( lcCursorPk )				
			use in select( "tablasinternas" )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionCopiarTablasSucursalSqlServer() as Void
		local loEstructura as Object, lcXmlFunc as String, lcScript as String, llRetorno as Boolean, loError as zooexception OF zooexception.prg, ;
			lcCursor as String, lcCursorEnt as String, lcCursorAtr as String, lcTablaAnt as String

		.AgregarLinea( "*----------------------------------------------", 1 )
		.AgregarLinea( "function CopiarTablasSucursalSqlServer( tcRutaOrigen as String, tcRutaDestino as String, tcSucursalOrigen as String, tcSucursalDestino as String ) as Void", 1 )

		lcCursor = sys( 2015 )		
		lcCursorEnt = sys( 2015 )
		lcCursorAtr = sys( 2015 )		
		
		try
			lcCursor = this.ObtenerCursorFuncionalidad()

			select distinct tabla, comportamiento ;
			from &lcCursor ;
			where "W" $ alltrim( upper( comportamiento )) ;
			order by tabla ;
			into cursor &lcCursorEnt

			.AgregarLinea( "local loLogCopia as Object, lcMensaje as String, lcSql as String, lcTabla as String, lcTablaOrigen as String, lcTablaDestino as String ", 2 )
			.AgregarLinea( "loLogCopia = _Screen.zoo.crearobjeto( 'MostrarCopiaDB' )", 2 )
			.AgregarLinea( "loLogCopia.inicializar( tcSucursalDestino, 'SqlServer' , " + transform( reccount( lcCursorEnt ) + 2 ) + ")", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "try", 2 )
				
			select ( lcCursorEnt )
			scan
				lcTabla = alltrim( upper( &lcCursorEnt..tabla ))
				lcTabla = "goServicios.Estructura.ObtenerEsquema( '" + lcTabla + "' ) + '." + lcTabla + "'"
				
				.AgregarLinea( "*----------" + lcTabla + "----------------------------", 3 )
			    .AgregarLinea( "lcTabla = " + lcTabla , 3 )
			    .AgregarLinea( "lcTablaOrigen = '[' + goServicios.Librerias.ObtenerNombreSucursal( tcSucursalOrigen ) + ']' + '.' + lcTabla", 3 )
			    .AgregarLinea( "lcTablaDestino = '[' + goServicios.Librerias.ObtenerNombreSucursal( tcSucursalDestino ) + ']' + '.' + lcTabla", 3 )			    

				select distinct campo, tags ;
				from &lcCursor ;
				where alltrim( upper( tabla )) == alltrim( upper( &lcCursorEnt..tabla )) ;
					and alltrim( upper( comportamiento )) == alltrim( upper( &lcCursorEnt..comportamiento )) and !empty( campo ) ;				
				order by campo ;
				into cursor &lcCursorAtr
				
				lcCampos = this.ObtenerCampos( lcCursorAtr )
		
				.AgregarLinea( "text to lcSql textmerge noshow pretext 7", 3 )
			    .AgregarLinea( "insert into << lcTablaDestino >> " + lcCampos + " select " + strextract( lcCampos, "(", ")" ) + " from << lcTablaOrigen >>", 4 )
				.AgregarLinea( "endtext", 3 )			    		
			    .AgregarLinea( "goDatos.EjecutarSql( lcSql )", 3 )
			    .AgregarLinea( "loLogCopia.Actualizar( lcTabla, 'Copiado ok.' )", 3 )
			    .AgregarLinea( "" )			    
			endscan

			select Tabla, Campo, TipoDato, "W", esquema from c_EstructuraAdn_sqlserver ;
				where ( alltrim( upper( c_EstructuraAdn_sqlserver.esquema )) == "PARAMETROS" or alltrim( upper( c_EstructuraAdn_sqlserver.esquema )) == "REGISTROS" ) and ;
				alltrim( upper( c_EstructuraAdn_sqlserver.Ubicacion )) == "SUCURSAL" ;
				order by tabla ;
				into cursor &lcCursor 

			select distinct tabla, esquema ;
				from &lcCursor ;
				order by tabla ;
				into cursor &lcCursorEnt				
				
			select ( lcCursorEnt )
			scan
				lcTabla = alltrim( upper( &lcCursorEnt..esquema )) + "." + alltrim( upper( &lcCursorEnt..tabla ))
				
				.AgregarLinea( "*----------" + lcTabla + "----------------------------", 3 )
			    .AgregarLinea( "lcTabla = '" + lcTabla + "'", 3 )
			    .AgregarLinea( "lcTablaOrigen = '[' + goServicios.Librerias.ObtenerNombreSucursal( tcSucursalOrigen ) + ']' + '.' + lcTabla", 3 )
			    .AgregarLinea( "lcTablaDestino = '[' + goServicios.Librerias.ObtenerNombreSucursal( tcSucursalDestino ) + ']' + '.' + lcTabla", 3 )			    

				select distinct campo, "" as tags ;
				from &lcCursor ;
				where alltrim( upper( tabla )) == alltrim( upper( &lcCursorEnt..tabla )) ;
					and alltrim( upper( esquema )) == alltrim( upper( &lcCursorEnt..esquema )) ;
				order by campo ;
				into cursor &lcCursorAtr
				
				lcCampos = this.ObtenerCampos( lcCursorAtr )
						
				.AgregarLinea( "text to lcSql textmerge noshow pretext 7", 3 )
				.AgregarLinea( "delete from  << lcTablaDestino >> " , 4 )			    
			    .AgregarLinea( "insert into << lcTablaDestino >> " + lcCampos + " select " + strextract( lcCampos, "(", ")" ) + " from << lcTablaOrigen >>", 4 )
				.AgregarLinea( "endtext", 3 )			    		
			    .AgregarLinea( "goDatos.EjecutarSql( lcSql )", 3 )
			    .AgregarLinea( "loLogCopia.Actualizar( lcTabla, 'Copiado ok.' )", 3 )
			    .AgregarLinea( "" )			    
			endscan				
						
			.AgregarLinea( "catch to loError", 2 )
		    .AgregarLinea( "lcMensaje = 'Problemas al generar la nueva base de datos. '", 3 )
		    .AgregarLinea( "lcMensaje= lcMensaje + 'Cierre las aplicaciones relacionadas y verifique los permisos de escritura que posee. Si el problema persiste, póngase en contacto con el administrador.'", 3 )
		    .AgregarLinea( "loLogCopia.Actualizar( lcTabla , 'Error al copiar.' )", 3 )
		    .AgregarLinea( "goServicios.Errores.LevantarExcepcion( lcMensaje )", 3 )
			.AgregarLinea( "finally", 2 )
		    .AgregarLinea( "loLogCopia.Finalizar()", 3 )
		    .AgregarLinea( "release loLogCopia", 3 )
			.AgregarLinea( "endtry", 2 )		
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcCursor )
			use in select( lcCursorEnt )
			use in select( lcCursorAtr )		
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCampos( tcCursorAtr as String ) as String
		local lcRetorno as String, lcCampo as String
		
		lcRetorno = "("

		select ( tcCursorAtr ) 		
		scan for !( this.oFunc.TieneFuncionalidad( "NOCOPIAR" , alltrim( upper( &tcCursorAtr..tags ))))
			lcCampo = alltrim( upper( &tcCursorAtr..campo ) )
			if !empty( lcCampo )
				lcRetorno = lcRetorno + lcCampo + ","
			endif
		endscan
		
		lcRetorno = left( lcRetorno, len( lcRetorno ) - 1 ) + ")"
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CursorAXML( tcNombreCursor ) as String
		Local lcRetorno as String
		
		cursortoxml(tcNombreCursor,"lcRetorno", 3, 0, 0, "1")
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function XmlACursor( tcXml as String, tcNombreCursor as String ) as Void
		xmltocursor( tcXml, tcNombreCursor ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarPieClase() as Void
		dodefault()
		this.AgregarClasesExtra()
		this.AgregarClasesItemMotivo()
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function AgregarClasesItemMotivo() as Void
		with this
			.agregarLinea( "*-----------------------------------------------------------------------------------------" )
			.agregarLinea( "define class ItemMotivo as custom" )
			.agregarLinea( "entidad = ''", 1 )
			.agregarLinea( "Atributo = ''", 1 )
			.agregarLinea( "Campo = ''", 1 )
			.agregarLinea( "enddefine" )
			.AgregarLinea( "")
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarClasesExtra() as Void
		with this
			.agregarLinea( "*-----------------------------------------------------------------------------------------" )
			.agregarLinea( "define class ItemAcceso as custom" )
			.agregarLinea( "id = ''", 1 )
			.agregarLinea( "entidad = ''", 1 )
			.agregarLinea( "item = ''", 1 )
			.agregarLinea( "itempadre = ''", 1 )
			.agregarLinea( "tipoopcion = ''", 1 )
			.agregarLinea( "Orden = 0", 1 )
			.agregarLinea( "nivel = 0", 1 )
			.agregarLinea( "Rama = ''", 1 )
			.agregarLinea( "Operacion = ''", 1 )
			.agregarLinea( "Descripcion = ''", 1 )
			.agregarLinea( "Modo = 2", 1 )
			.agregarLinea( "ModoPerfil = 2", 1 )
			.agregarLinea( "Usuario = ''", 1 )
			.agregarLinea( "Fecha = ctot( '' )", 1 )
			.agregarLinea( "lEliminar = .f.", 1 )
			.agregarLinea( "dtUltimoAcceso = ctot( '' )", 1 )
			.agregarLinea( "nIndice = 0", 1 )
			.agregarLinea( "enddefine" )
			.AgregarLinea( "")
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ConvertirTablasParametrosYRegistros( tlEsNAtiva as Boolean ) as Void	
		local loEstructuraParametrosyRegistros as Object
		
		replace campo with alltrim( upper( campo )) all in c_estructuraadn
		replace tabla with alltrim( upper( tabla )) all in c_estructuraadn

		if !tlEsNativa
			*** Cambiar cuando lo agreguen al adn
			this.ObtenerEstructuraSQL()
			loEstructuraParametrosyRegistros = _screen.zoo.CrearObjeto( ;
				"EstructuraParametrosyRegistrosSqlServer", ;
				"EstructuraParametrosyRegistrosSqlServer.prg", ;
				this.DatasessionId, ;
				_screen.zoo.app.cSchemaDefault )
			loEstructuraParametrosyRegistros.Insertar()
			this.AgregarTablasPropiedadesReplica()
		endif		

		select * ;
		from c_estructuraadn;
		order by ubicacion, esquema, tabla, campo ;
		into cursor c_estructuraadn readwrite
		
		select * ;
		from c_estructuraadn_sqlserver;
		order by ubicacion, esquema, tabla, campo ;
		into cursor c_estructuraadn_sqlserver readwrite		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSchemaEntidad( tcTabla as String ) as Void
		local lcRetorno as String, lcCursor as String, lcAlias as String
		
		lcCursor = sys(2015)
		lcAlias = alias()

		select esquema from c_EstructuraAdn where alltrim( upper( tabla )) == alltrim( upper( tcTabla )) group by tabla into cursor &lcCursor
		
		if _tally > 0
			lcRetorno = &lcCursor..Esquema
		endif
			
		if empty( lcRetorno )
			lcRetorno = _screen.zoo.app.cSchemaDefault
		endif
		
		use in ( lcCursor )
		
		if !empty( lcAlias )
			select ( lcAlias )
		endif
		
		return lcRetorno
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function Compilar() as Void
		
		goServicios.Estructura.Detener()
		if vartype( this.oEstructura ) == "O" and !isnull( this.oEstructura )
			this.oEstructura.Detener()
		endif
        release din_estructuraadn
		dodefault()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerColeccionModulosPorEntidad() as Void

		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "Function ObtenerColeccionModulosPorEntidad() as ZooColeccion of ZooColeccion.prg", 1 )
			.AgregarLinea( "local loColeccion as zoocoleccion OF zoocoleccion.prg", 2 )
			.AgregarLinea( "loColeccion = _screen.zoo.CrearObjeto( 'ZooColeccion' )", 2 )
			select c_Entidad
			scan all for !empty( c_Entidad.Modulos )
				.AgregarLinea( "loColeccion.Agregar( '" + alltrim( c_Entidad.Modulos ) + "','" + alltrim( upper( c_Entidad.Entidad ) )+ "' )", 2 )
			EndScan
			.AgregarLinea( "return loColeccion", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerEstructuraPrecios() as Void
		local lcConsulta as String, lcTablaPrecio  as String 
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")	
				.AgregarLinea( "*------------------------------------------------------------------------------------")
				.AgregarLinea( "Function ObtenerEstructuraPrecios() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
					
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecio = alltrim( c_Diccionario.Tabla )				
				.AgregarLinea( 'lcRetorno = "select * from ' + lcTablaPrecio  + ' where 1 = 0"', 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )					
				.AgregarLinea( "")
			endif 
		endwith 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerAgrupamientoyOrdenConsultaPrecios() as Void
		local loCamposCombinacion as zoocoleccion OF zoocoleccion.prg, lcCampos as String, lcTablaPrecio as String  
		loCamposCombinacion = this.ObtenerAtributosCombinacion()
		
		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "Function ObtenerAgrupamientoyOrdenConsultaPrecios() as String", 1 )		
			.AgregarLinea( "local lcRetorno", 2 )

			select c_Diccionario
			locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
			lcTablaPrecio = alltrim( c_Diccionario.Tabla )				
			lcCampos = ""
			loCamposCombinacion = this.ObtenerAtributosCombinacion()
			for each lcCampo in loCamposCombinacion as FoxObjec 
				lcCampos = lcCampos + lcTablaPrecio + "." + lcCampo + ", "
			endfor 			
			lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
			.AgregarLinea( 'lcRetorno = " group by ' + lcCampos + ' " + ;', 2 )	
			lcCampos = strtran(lcCampos, ", ", " + ")
			.AgregarLinea( '"order by ' + lcCampos + ' "', 5 )	
			.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerSelectConsultaPrecios() as Void
		local lcCampArticulo, lcCampColor, lcCampTalle, lcCampPdirecto, lcCampPdirOri, lcCampCodigo, lcCampListaPre, lcCampFechaVig, lcCampTimest as String, ;
			loCamposCombinacion as zoocoleccion OF zoocoleccion.prg
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")		
		
				loCamposCombinacion = this.ObtenerAtributosCombinacion()

				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectConsultaPrecios( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean ) as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				local lcConsulta as String, lcTablaPrecio as String, lcCampoCodigo as String 

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecio = alltrim( c_Diccionario.Tabla )
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "CODIGO"
				lcCampoCodigo = alltrim( c_Diccionario.Campo )
				lcConsulta = "Select " 
				lcCampos = ""
					
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaPrecio + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				lcConsulta = lcConsulta + lcCampos  + ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PDIRECTO, "
	
				lcConsulta = lcConsulta + "( select Funciones.ObtenerTimestampVigenteDeLaCombinacion(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "') ) as TIMESTAMPA, "
				*lcConsulta = lcConsulta + "'' as CODIGO, "
				
				lcConsulta = lcConsulta + "'" + '" + tcListaPrecios + "' + "' as ListaPre  "

				lcConsulta = lcConsulta + " From " + lcTablaPrecio 
					
				.AgregarLinea( 'lcRetorno = "' +  lcConsulta + '" + ;', 2 )
					
				lcInnerJoins = This.ObtenerInnerJoinsPrecios( lcTablaPrecio, "PRECIODEARTICULO" )
				lcConsulta = lcConsulta + lcInnerJoins
					
				.AgregarLinea( "'" + lcInnerJoins+ "'", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerSelectPreciosVigentes() as Void
		local lcConsulta as String, lcTablaPrecio as String, lcCampos as String, lcCampoSB as String, lcCampoListaDePrecio as String, ;
			lcCampoFechaVigencia as String, lcCampoTimeStampA as String, lcCampoPDirecto as String, loCamposCombinacion as zoocoleccion OF zoocoleccion.prg
			
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")		
		
				loCamposCombinacion = this.ObtenerAtributosCombinacion()

				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectPreciosVigentes( tdFechaVigencia as Date, tcListaPrecios as String ) as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecio = upper( alltrim( c_Diccionario.Tabla ) )
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "LISTADEPRECIO"
				lcCampoListaDePrecio = upper( alltrim( c_Diccionario.Campo ) )
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "FECHAVIGENCIA"
				lcCampoFechaVigencia = upper( alltrim( c_Diccionario.Campo ) )
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "TIMESTAMPALTA"
				lcCampoTimeStampA = upper( alltrim( c_Diccionario.Campo ) )
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "PRECIODIRECTO"
				lcCampoPDirecto = upper( alltrim( c_Diccionario.Campo ) )
				
				lcCampos = ""
				lcCampoSB = ""
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampoSB = lcCampoSB + "SB." + lcCampo + ", "
					lcCampos = lcCampos + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				lcCampoSB = left( lcCampoSB, len( lcCampoSB ) - 2 )
				
				lcConsulta = "Select " 
				lcConsulta = lcConsulta + "SB." + lcCampoListaDePrecio + ", " + lcCampoSB + ", SB." + lcCampoFechaVigencia + ", SB." + lcCampoTimeStampA + ", SB." + lcCampoPDirecto + " "
				.AgregarLinea( 'lcRetorno = "' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = "From ( "
				.AgregarLinea( '"' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = "Select " 
				lcConsulta = lcConsulta + lcCampoListaDePrecio + ", " + lcCampos + ", " + lcCampoFechaVigencia + ", " + lcCampoTimeStampA + ", " + lcCampoPDirecto + " "
				lcConsulta = lcConsulta + ", Row_Number() Over( Partition By " + lcCampoListaDePrecio + ", " + lcCampos + " Order By " + lcCampoFechaVigencia + " Desc, " + lcCampoTimeStampA + " Desc ) Prioridad "
				.AgregarLinea( '"' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = "From " + lcTablaPrecio + " "
				.AgregarLinea( '"' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = "Where " + lcCampoListaDePrecio + ' = [" + tcListaPrecios + "] ' + "and " + lcCampoFechaVigencia + ' <= [" + dtos( tdFechaVigencia ) + "] '
				.AgregarLinea( '"' +  lcConsulta + '"' + " + ;", 2 )
				
				lcConsulta = ") as SB "
				lcConsulta = lcConsulta + "Where SB.Prioridad = 1 "
				.AgregarLinea( '"' +  lcConsulta + '"', 2 )

				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerSelectConsultaPreciosConPrecioActual() as Void
		local lcCampArticulo, lcCampColor, lcCampTalle, lcCampPdirecto, lcCampPdirOri, lcCampCodigo, lcCampListaPre, lcCampFechaVig, lcCampTimest as String, ;
			loCamposCombinacion as zoocoleccion OF zoocoleccion.prg
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")		
		
				loCamposCombinacion = this.ObtenerAtributosCombinacion()

				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectConsultaPreciosConPrecioActual( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				local lcConsulta as String, lcTablaPrecio as String, lcCampoCodigo as String 

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecio = alltrim( c_Diccionario.Tabla )
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "CODIGO"
				lcCampoCodigo = alltrim( c_Diccionario.Campo )
				lcConsulta = "Select distinct " 
				lcCampos = ""
					
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaPrecio + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
				lcConsulta = lcConsulta + lcCampos  + ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PDIRECTO, "
				lcConsulta = lcConsulta + "( select Funciones.ObtenerTimestampVigenteDeLaCombinacion(" + lcCampos + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "') ) as TIMESTAMPA, "
				lcConsulta = lcConsulta + "'" + '" + tcListaPrecios + "' + "' as ListaPre "
				
				.AgregarLinea( 'lcRetorno = "' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PACTUAL "
				lcConsulta = lcConsulta + " From " + lcTablaPrecio 
				.AgregarLinea( '"' +  lcConsulta + '" + ;', 2 )
					
				lcInnerJoins = This.ObtenerInnerJoinsPrecios( lcTablaPrecio, "PRECIODEARTICULO" )
				lcConsulta = lcConsulta + lcInnerJoins
					
				.AgregarLinea( "'" + lcInnerJoins+ "'", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFuncionPrecioRealDeLaCombinacionConVigencia() as Void
		local lcTablaPrecio as String, lcCampoCodigo as String, lcCampos as String, lcConsulta as String, ;
			loCamposCombinacion as zoocoleccion OF zoocoleccion.prg
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")		
		
				loCamposCombinacion = this.ObtenerAtributosCombinacion()

				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerFuncionPrecioRealDeLaCombinacionConVigencia( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				local lcConsulta as String, lcTablaPrecio as String, lcCampoCodigo as String 

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecio = alltrim( c_Diccionario.Tabla )
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "CODIGO"
				lcCampoCodigo = alltrim( c_Diccionario.Campo )
				lcCampos = ""
					
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaPrecio + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
				lcConsulta = "( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PDIRECTO, "
				lcConsulta = lcConsulta + "( select Funciones.ObtenerTimestampVigenteDeLaCombinacion(" + lcCampos + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "') ) as TIMESTAMPA, "
				lcConsulta = lcConsulta + "'" + '" + tcListaPrecios + "' + "' as ListaPre "
				.AgregarLinea( 'lcRetorno = "' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PACTUAL "
				.AgregarLinea( '"' +  lcConsulta + ' "', 2 )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia() as Void
		local loCamposCombinacion as zoocoleccion OF zoocoleccion.prg, loCamposKitYPackCombinacion  as zoocoleccion OF zoocoleccion.prg
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS")		

				loCamposCombinacion = this.ObtenerAtributosCombinacion()
				loCamposKitYPackCombinacion = this.ObtenerAtributosKitYPackCombinacion()

				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerFuncionPrecioRealParticipantesKitsYPacksConVigencia( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				local lcConsulta as String, lcTablaParticipantes as String, lcCampos as String, lcCamposPrecio as String, lcCampoCant as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ITEMPARTICIPANTES" and ClavePrimaria
				lcTablaParticipantes = alltrim( c_Diccionario.Tabla )
				
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ITEMPARTICIPANTES"  and upper( alltrim( Atributo ) ) == "CANTIDAD"
				lcCampoCant = alltrim( c_Diccionario.Campo )
				
				lcCampos = ""
				lcCamposPrecio = ""

				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCamposPrecio = lcCamposPrecio + lcCampo + ", "
				endfor 				
				lcCamposPrecio = left( lcCamposPrecio, len( lcCamposPrecio ) - 2 )
				
				for each lcCampo in loCamposKitYPackCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaParticipantes + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
				lcConsulta = "( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " )"
				lcConsulta = lcConsulta + " * " + lcTablaParticipantes + "." + lcCampoCant + " ) as PDIRECTO, "
				lcConsulta = lcConsulta + "( select Funciones.ObtenerTimestampVigenteDeLaCombinacion(" + lcCamposPrecio + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "') ) as TIMESTAMPA, "
				lcConsulta = lcConsulta + "'" + '" + tcListaPrecios + "' + "' as ListaPre "
				.AgregarLinea( 'lcRetorno = "' +  lcConsulta + '" + ;', 2 )
				
				lcConsulta = ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCamposPrecio + ", '" + '" + tcListaActual + "' + "', ' " + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PACTUAL "
				.AgregarLinea( '"' +  lcConsulta + ' "', 2 )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerFuncionPrecioRealDelStockConVigencia() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerFuncionPrecioRealDelStockConVigencia( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )
				local lcConsulta as String, lcTablaStock as String, lcCampos as String, loCamposCombinacion as zoocoleccion OF zoocoleccion.prg

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcTablaStock = alltrim( c_Diccionario.Tabla )
				
				loCamposCombinacion = this.ObtenerAtributosStockCombinacion()
				
				lcCampos = ""
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaStock + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
				lcConsulta = "( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', '" + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PDIRECTO, '" + '" + tcListaPrecios + "' + "' as ListaPre "
				lcConsulta = lcConsulta + ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaActual + "' + "', '" + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PACTUAL "
				
				.AgregarLinea( 'lcRetorno = "' + lcConsulta + '"', 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerInnerJoinsPrecios( tcTablaPrecio as String, tcEntidad as String ) as String
		local lcInners as String, lcTablaInner as String, lcCampoInner as String, lcCampoPrecio as String
		lcInners = ""

		select * ;
			from c_Diccionario ;
			where upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and !empty( ClaveCandidata ) and !empty( ClaveForanea );
			order by ClaveCandidata ;
			into cursor c_Inners
			
		select c_Inners
		scan all
			select c_Diccionario
			locate for upper( alltrim( Entidad ) ) == upper( alltrim( c_Inners.ClaveForanea ) ) and ClavePrimaria
			if upper( alltrim( c_Diccionario.Tabla ) ) # upper( alltrim( tcTablaPrecio ) )
				lcTablaInner = alltrim( c_Diccionario.Tabla )
				lcCampoInner = alltrim( c_Diccionario.Campo )
				lcCampoPrecio = alltrim( c_Inners.Campo )
				lcTipoJoin = " Left Join "
				do case
					case upper( alltrim( c_Diccionario.Entidad ) ) == upper( alltrim( "LISTADEPRECIOS" ) )
						lcTipoJoin = " Inner Join "
						lcCampoInner = lcCampoInner + " and " + lcTablaInner + "." + lcCampoInner + " = [' + tcListaPrecios + ']"
					case upper( alltrim( c_Diccionario.Entidad ) ) == upper( alltrim( "ARTICULO" ) )
						lcTipoJoin = " Inner Join "
					otherwise 
						lcTipoJoin = " Left Join "

				endcase

				lcInners = lcInners + lcTipoJoin +  lcTablaInner + " on " + tcTablaPrecio + "." + lcCampoPrecio + " = " + lcTablaInner + "." + lcCampoInner
			endif 	
			
			select c_Inners
		endscan

		use in select( "c_Inners" )	
		return lcInners
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerTablasConsultaPrecios() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerTablasConsultaPrecios() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				scan all for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and !empty( claveCandidata ) and !empty( ClaveForanea )
					lcEntidad = alltrim( upper( c_Diccionario.ClaveForanea ) )
					select * from c_Diccionario where upper( alltrim( Entidad ) ) == lcEntidad and ClavePrimaria into cursor c_Foraneas
					.AgregarLinea( "lcRetorno = lcRetorno + '," + alltrim( c_Foraneas.Tabla ) + "'", 2 )
					use in select( "c_Foraneas" )
					select c_Diccionario
				EndScan
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerCampoClaveArticulo() as void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerCampoClaveArticulo() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
				
				local lcCampo as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ARTICULO" and ClavePrimaria
				lcCampo = alltrim( c_Diccionario.Campo )
				
				.AgregarLinea( "lcRetorno = '" + lcCampo + "'", 2 )

				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerLeftJoinsCombinacion() as void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerLeftJoinsCombinacion() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
				
				local lcTablaComb as String, lcCampo as String, lcTablaJoin as String, lcCampoJoin as String, lcJoins as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcTablaComb = alltrim( c_Diccionario.Tabla )
				
				select top 1 * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and !empty( ClaveCandidata ) and !empty( ClaveForanea ) ;
					order by ClaveCandidata ;
					into cursor c_Joins
				
				select c_Joins
				scan all
					lcCampo = alltrim( c_Joins.Campo )
					select c_Joins
				endscan
				use in select( "c_Joins" )	
				
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ARTICULO" and ClavePrimaria
				lcTablaJoin = alltrim( c_Diccionario.Tabla )
				lcCampoJoin = alltrim( c_Diccionario.Campo )
				
				lcJoins = "left join " +  lcTablaComb + " on " + lcTablaComb + "." + lcCampo + " = " + lcTablaJoin + "." + lcCampoJoin 
				.AgregarLinea( "lcRetorno = ' " + lcJoins + " '", 2 )

				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerLeftJoinsCombinacionPrecios() as void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerLeftJoinsCombinacionPrecios() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
				
				local loCamposCombinacionPrecios as zoocoleccion OF zoocoleccion.prg, loCamposCombinacionStock as zoocoleccion OF zoocoleccion.prg, ;
					lcTablaComb as String, lcTablaPrecios as String, lcCampos as String, lnI as Integer, lcJoins as String

				loCamposCombinacionPrecios = this.ObtenerAtributosCombinacion()
				loCamposCombinacionStock = this.ObtenerAtributosStockCombinacion()
				
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcTablaComb = alltrim( c_Diccionario.Tabla )
				
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and ClavePrimaria
				lcTablaPrecios = alltrim( c_Diccionario.Tabla )
				
				lcCampos = ""
				for lnI = 1 to loCamposCombinacionStock.Count
					lcCampos = lcCampos + lcTablaComb + "." + loCamposCombinacionStock.Item[ lnI ] + " = "
					lcCampos = lcCampos + lcTablaPrecios + "." + loCamposCombinacionPrecios.Item[ lnI ] + " and "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 5 )
				
				lcJoins = "left join " +  lcTablaPrecios + " on " + lcCampos
				.AgregarLinea( "lcRetorno = ' " + lcJoins + " '", 2 )

				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerWhereArticuloDeProveedor() as Void
		local lcString as String

		with this
			if .ExisteEntidad( "ARTICULO" )	and .ExisteEntidad( "PROVEEDOR" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerWhereArticuloDeProveedor() as String", 1 )
				lcString = " where "+ .ObtenerTablaAtributo( "ARTICULO", "PROVEEDOR" )+"."+.ObtenerCampoAtributo( "ARTICULO", "PROVEEDOR" )
				.AgregarLinea( 'return "' + lcString +'"', 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerWhereConsultaPrecios() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )		
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerWhereConsultaPrecios() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
				local lcAtributo as String, lcEntidad as String, lcCondicion as String, llPrimera as Boolean, lnCantidad as Integer, lcFiltro as String
				llPrimera = .T.
				lcCondicion = ""
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "CALCULODEPRECIOS" and "_DESDE" $ upper( Atributo ) ;
					into cursor c_CalculoPrecios NoFilter
				lnCantidad = reccount( "c_CalculoPrecios" )
				select c_CalculoPrecios
				scan all
					do Case
						Case occurs( "_" , c_CalculoPrecios.Atributo ) = 2
							lcAtributo = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 2, "_" ) ) )
							lcEntidad = "PRECIODEARTICULO"
							lcFiltro = lcAtributo
						Case occurs( "_" , c_CalculoPrecios.Atributo ) = 3
							lcAtributo = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 3, "_" ) ) )
							lcEntidad = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 2, "_" ) ) )
							lcFiltro = lcEntidad + "_" + lcAtributo
						otherwise
							goServicios.Errores.LevantarExcepcion( "Implementar ObtenerWhereConsultaPrecios para 3 niveles de entidad" )
					endcase
					lcCondicion = This.ObtenerCondicionAtributo( lcEntidad, lcAtributo, lcFiltro, iif( alltrim( upper( Dominio ) ) = "ETIQUETACARACTERDESDEHASTABUSC", .T., .F.) )
					if llPrimera
						llPrimera = .F.
						.AgregarLinea( 'lcRetorno = "' + This.AgregarCondicionParaQueNoPongaPrecioAlArticuloSenia( "PRECIODEARTICULO", "ARTICULO" ) + lcCondicion + iif( recno( "c_CalculoPrecios" ) != lnCantidad, ' and " + ;', '"' ), 2 )
					else
						.AgregarLinea( '"' + lcCondicion + iif( recno( "c_CalculoPrecios" ) != lnCantidad, ' and " + ;', '"' ), 3 )
					EndIf
					select c_CalculoPrecios
				endscan

				lcTablaPrecio = alltrim( c_Diccionario.Tabla )
				this.QuitarCasosDeCombinacionesQueNoExisten("PRECIOAR", "PRECIODEARTICULO" )
				use in select( "c_CalculoPrecios" )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarCondicionParaQueNoPongaPrecioAlArticuloSenia( tcEntidad as String, tcAtributo as String ) as String
		local lcRetorno as String, lcTablaCampo as String
		lcTablaCampo = This.ObtenerTablaAtributo( tcEntidad, tcAtributo ) + "." + This.ObtenerCampoAtributo( tcEntidad, tcAtributo )
		
		lcRetorno = lcTablaCampo + " != [' + rtrim( goRegistry.Felino.CodigoDeArticuloSena ) + '] and "
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionAtributo( tcEntidad as String, tcAtributo as String, tcFiltro as String, tlBuscador as Logical ) as String
		local lcRetorno as String, lcTipoDato as String, lcTablaCampo as String
		use in select( "c_Atributo" )
		select * ;
			from c_Diccionario ;
			where upper( alltrim( Entidad ) ) == tcEntidad and upper( alltrim( Atributo ) ) == tcAtributo ;
			into cursor c_Atributo
		lcTablaCampo = alltrim( c_Atributo.Tabla ) + "." + alltrim( c_Atributo.Campo )
		lcTipoDato = alltrim( upper( c_Atributo.TipoDato ) )
		do Case
			case lcTipoDato = "C"
				lcRetorno = lcTablaCampo + " >= [' + This.f_" + tcFiltro + "_Desde" + iif( tlBuscador, "_PK", "" ) + " + '] and " + lcTablaCampo + " <= [' + This.f_" + tcFiltro + "_Hasta" + iif( tlBuscador, "_PK", "" ) + " + ']"
			case lcTipoDato = "N"
				lcRetorno = lcTablaCampo + " >= ' + transform( This.f_" + tcFiltro + "_Desde ) + ' and " + lcTablaCampo + " <= ' + transform( This.f_" + tcFiltro + "_Hasta ) + '"
			case lcTipoDato = "D"
				lcRetorno = "DTos( " + lcTablaCampo + " ) >= [' + dtos( This.f_" + tcFiltro + "_Desde ) + '] and DTos( " + lcTablaCampo + " ) <= [' + dtos( This.f_" + tcFiltro + "_Hasta ) + ']"
			OtherWise
				goServicios.Errores.LevantarExcepcion( "Implementar ObtenerCondicionAtributo para tipo de dato" + c_Atributo.TipoDato )
		EndCase	

		use in select( "c_Atributo" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSelectStockArticulo() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectStockArticulo() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )
				local lcConsulta as String, lcTablaArticulos as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKARTICULOS" and ClavePrimaria
				lcTablaArticulos = alltrim( c_Diccionario.Tabla )
				
				lcConsulta = "Select " + lcTablaArticulos + ".* "
				lcConsulta = lcConsulta + "From " + lcTablaArticulos
				
				.AgregarLinea( "lcRetorno = '" + lcConsulta + "'", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif 	
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerWhereStockArticulo() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerWhereStockArticulo() as String", 1 )
				.AgregarLinea( "local lcRetorno", 2 )
				local lcAtributo as String, lcEntidad as String, lcCondicion as String, lnCantidad as Integer, lcFiltro as String
				
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKARTICULOS" and ClavePrimaria;
					into cursor c_AtributoClavePrimaria NoFilter
					
				lcAtributo = upper( alltrim( c_AtributoClavePrimaria.Atributo ) )
				lcEntidad = "STOCKARTICULOS"
				lcFiltro = "ARTICULO"
				lcCondicion = This.ObtenerCondicionAtributo( lcEntidad, lcAtributo, lcFiltro, .T. )
				.AgregarLinea( 'lcRetorno = "' + lcCondicion + ' and " + ;', 3 )
					
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "CALCULODEPRECIOS" and "_DESDE" $ upper( Atributo ) and occurs( "_", Atributo ) = 3;
					into cursor c_CalculoPrecios NoFilter
				
				count for occurs( "_", Atributo ) = 3 to lnCantidad	 
				.AgregarLinea( '"' + This.AgregarCondicionParaQueNoPongaPrecioAlArticuloSenia( "ARTICULO", "CODIGO" ) + '" + ;', 3 )
				select c_CalculoPrecios
				scan for  occurs( "_", Atributo ) = 3 
					lcAtributo = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 3, "_" ) ) )
					lcEntidad = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 2, "_" ) ) )
					lcFiltro = lcEntidad + "_" + lcAtributo
					lcCondicion = This.ObtenerCondicionAtributo( lcEntidad, lcAtributo, lcFiltro, iif( alltrim( upper( Dominio ) ) = "ETIQUETACARACTERDESDEHASTABUSC", .T., .F.) )
					.AgregarLinea( '"' + lcCondicion + iif( recno( "c_CalculoPrecios" ) != lnCantidad, ' and " + ;', '"' ), 3 )
					select c_CalculoPrecios
				endscan
				use in select( "c_CalculoPrecios" )
				use in select( "c_AtributoClavePrimaria" )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaAtributo( tcEntidad as String, tcAtributo as String ) as String
		local lcTabla as String
		use in select( "c_Atributo" )
		select * ;
			from c_Diccionario ;
			where upper( alltrim( Entidad ) ) == tcEntidad and upper( alltrim( Atributo ) ) == tcAtributo ;
			into cursor c_Atributo
		lcTabla = alltrim( c_Atributo.Tabla )

		use in select( "c_Atributo" )
		return lcTabla
	endfunc 		

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoAtributo( tcEntidad as String, tcAtributo as String ) as String
		local lcCampo as String
		use in select( "c_Atributo" )
		select * ;
			from c_Diccionario ;
			where upper( alltrim( Entidad ) ) == tcEntidad and upper( alltrim( Atributo ) ) == tcAtributo ;
			into cursor c_Atributo
		lcCampo = alltrim( c_Atributo.Campo )

		use in select( "c_Atributo" )
		return lcCampo
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSentenciaInsertAtributosArticulos() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				local lcCampo1 as String, lcCampo2 as String
				use in select( "c_Atributo" )
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and upper( alltrim( Atributo ) ) == "ARTICULO" ;
					into cursor c_Atributo
				lcCampo1 = alltrim( c_Atributo.Campo )
				use in select( "c_Atributo" )
						
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKARTICULOS" and Claveprimaria  ;
					into cursor c_Atributo
				lcCampo2 = alltrim( c_Atributo.Campo )
				use in select( "c_Atributo" )

				.AgregarLinea( "*------------------------------------------------------------------------------------")
				.AgregarLinea( "Function ObtenerSentenciaInsertAtributosArticulos( tcCursor as String ) as String", 1 )
				.AgregarLinea( "return '( " + lcCampo1 + " ) values ( ' + tcCursor + '.' + '"+ lcCampo2 + " )' " ,2)
				.AgregarLinea( "endfunc", 1 )
			endif	
		endwith
	endfunc 		
			
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerTablasStockArticulo() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerTablasStockArticulo() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKARTICULOS" and ClavePrimaria
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerTablasParticipantes() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerTablasParticipantes() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ITEMPARTICIPANTES" and ClavePrimaria
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerCampoClavePrimariaParticipantes() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerCampoClavePrimariaParticipantes() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "ITEMPARTICIPANTES" and ClavePrimaria
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "." + alltrim( c_Diccionario.Campo ) + "'", 2 )
				
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSelectStockArticuloCombinacionConPrecios() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectStockArticuloCombinacionConPrecios( tdFechaVigencia as Date, tcListaPrecios as String, tlNoVerificarCalculadaAlMomento as Boolean, tcListaActual as String ) as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )
				local lcConsulta as String, lcTablaArticulos as String, lcCampos as String, loCamposCombinacion as zoocoleccion OF zoocoleccion.prg

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcTablaArticulos = alltrim( c_Diccionario.Tabla )
				
				loCamposCombinacion = this.ObtenerAtributosStockCombinacion()
				
				lcCampos = ""
				for each lcCampo in loCamposCombinacion as FoxObjec 
					lcCampos = lcCampos + lcTablaArticulos + "." + lcCampo + ", "
				endfor 				
				lcCampos = left( lcCampos, len( lcCampos ) - 2 )
				
				lcConsulta = "Select " + lcCampos
				lcConsulta = lcConsulta + ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaPrecios + "' + "', '" + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PDIRECTO, '" + '" + tcListaPrecios + "' + "' as ListaPre "
				lcConsulta = lcConsulta + ", ( select Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia(" + lcCampos + ", '" + '" + tcListaActual + "' + "', '" + '" + dtos( tdFechaVigencia ) + "' + "', " + '" + iif(tlNoVerificarCalculadaAlMomento,"1","0") + "' + " ) ) as PACTUAL "
				lcConsulta = lcConsulta + "From " + lcTablaArticulos 
				
				lcInnerJoins = This.ObtenerInnerJoinsPrecios( lcTablaArticulos, "STOCKCOMBINACION" )
				lcConsulta = lcConsulta + lcInnerJoins
				
				.AgregarLinea( 'lcRetorno = "' + lcConsulta + '"', 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSelectStockArticuloCombinacion() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSelectStockArticuloCombinacion() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )
				local lcConsulta as String, lcTablaArticulos as String

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcTablaArticulos = alltrim( c_Diccionario.Tabla )
				
				lcConsulta = "Select " + lcTablaArticulos + ".* "
				lcConsulta = lcConsulta + "From " + lcTablaArticulos 
				
				lcInnerJoins = This.ObtenerInnerJoinsPrecios( lcTablaArticulos, "STOCKCOMBINACION" )
				lcConsulta = lcConsulta + lcInnerJoins
				
				.AgregarLinea( "lcRetorno = '" + lcConsulta + "'", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerWhereStockArticuloCombinacion() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )	
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerWhereStockArticuloCombinacion() as String", 1 )
					.AgregarLinea( "local lcRetorno", 2 )
					local lcAtributo as String, lcEntidad as String, lcCondicion as String, lnCantidad as Integer, lcFiltro as String
					
					.AgregarLinea( 'lcRetorno = ;', 2 )
					.AgregarLinea( '"' + This.AgregarCondicionParaQueNoPongaPrecioAlArticuloSenia( "ARTICULO", "CODIGO" ) + '" + ;', 3 )
					select * ;
						from c_Diccionario ;
						where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0;
						into cursor c_AtributosStockCombinacion NoFilter

					select c_AtributosStockCombinacion
					scan 
						lcAtributo = alltrim(upper(c_AtributosStockCombinacion.Atributo))
						lcEntidad = alltrim(upper(c_AtributosStockCombinacion.Entidad))
						lcFiltro = lcAtributo

						select * ;
							from c_Diccionario ;
							where upper( alltrim( Entidad ) ) == "CALCULODEPRECIOS" and lcFiltro+"_DESDE" $ upper( Atributo );
							into cursor c_CalculoPrecios NoFilter
							if _tally > 0 
								lcCondicion = This.ObtenerCondicionAtributo( lcEntidad, lcAtributo, lcFiltro, iif( alltrim( upper( Dominio ) ) = "ETIQUETACARACTERDESDEHASTABUSC", .T., .F.) )
								.AgregarLinea( '"' + lcCondicion + ' and " + ;', 3 )
							endif	
						use in select( "c_CalculoPrecios"  )	
						select c_AtributosStockCombinacion
					endscan
					use in select( "c_AtributosStockCombinacion"  )
					
					select * ;
						from c_Diccionario ;
						where upper( alltrim( Entidad ) ) == "CALCULODEPRECIOS" and "_DESDE" $ upper( Atributo ) and occurs( "_", Atributo ) = 3;
						into cursor c_CalculoPrecios NoFilter
					
					count for occurs( "_", Atributo ) = 3 to lnCantidad	 
					select c_CalculoPrecios
					scan for  occurs( "_", Atributo ) = 3 
							lcAtributo = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 3, "_" ) ) )
							lcEntidad = upper( alltrim( getwordnum( c_CalculoPrecios.Atributo, 2, "_" ) ) )
							lcFiltro = lcEntidad + "_" + lcAtributo
							lcCondicion = This.ObtenerCondicionAtributo( lcEntidad, lcAtributo, lcFiltro, iif( alltrim( upper( Dominio ) ) = "ETIQUETACARACTERDESDEHASTABUSC", .T., .F.) )
							.AgregarLinea( '"' + lcCondicion + iif( recno( "c_CalculoPrecios" ) != lnCantidad, ' and " + ;', '"' ), 3 )
						select c_CalculoPrecios
					endscan
					use in select( "c_CalculoPrecios" )
					
					.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerTablasStockCombinacion() as Void
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerTablasStockCombinacion() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerTablasStockArticuloCombinacion() as Void
		local lcClavePrimaria as String
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerTablasStockArticuloCombinacion() as String", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String
				select c_Diccionario
				locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				lcClavePrimaria = upper( alltrim( c_Diccionario.Tabla ) )
				.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				scan all for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and !empty( claveCandidata ) and !empty( ClaveForanea )
					lcEntidad = alltrim( upper( c_Diccionario.ClaveForanea ) )
					select * from c_Diccionario where upper( alltrim( Entidad ) ) == lcEntidad and ClavePrimaria into cursor c_Foraneas
					if lcClavePrimaria # upper( alltrim( c_Foraneas.Tabla ) )
						.AgregarLinea( "lcRetorno = lcRetorno + '," + upper( alltrim( c_Foraneas.Tabla ) ) + "'", 2 )
					endif	
					use in select( "c_Foraneas" )
					select c_Diccionario
				endscan
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
			endif	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerSentenciaInsertAtributosCombinacion() as String
		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
				local lcCampo1 as String, lcCampo2 as String, lcNombreCursorString as String

				lcCampo1 = ""
				lcCampo2 = ""
				lcNombreCursorString = "' + tcCursor + '.' + '" 
				
				use in select( "c_Atributo" )
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and clavecandidata > 1 ;
					order by clavecandidata;
					into cursor c_Atributo
				
				select c_Atributo
				scan 
				
					select * ;
						from c_Diccionario ;
						where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0 and ;
						upper( alltrim( atributo ) ) == upper( alltrim( c_Atributo.Atributo ) ) ;
						into cursor c_AtributosStockCombinacion NoFilter
					
					if _tally > 0	
						lcCampo1 = lcCampo1 + alltrim(upper(c_Atributo.Campo)) + ", "
						lcCampo2 = lcCampo2 + lcNombreCursorString + alltrim(upper(c_AtributosStockCombinacion.Campo)) + ", "
					endif		
					select c_Atributo
				endscan
				use in select( "c_Atributo"  )
				use in select( "c_AtributosStockCombinacion"  )
				
				lcCampo1 = substr( lcCampo1, 1, len( lcCampo1 ) - 2 ) 
				lcCampo2 = substr( lcCampo2, 1, len( lcCampo2 ) - 2 ) 
				
				.AgregarLinea( "*------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerSentenciaInsertAtributosCombinacion( tcCursor as String ) as String", 1 )
				.AgregarLinea( "return '( " + lcCampo1 + " ) values ( "+ lcCampo2 + " )' " ,2)
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif	
		endwith
	endfunc 		

	*-----------------------------------------------------------------------------------------
	protected function ExisteEntidad( tcEntidad as String ) as Void
		local llRetorno as Boolean
		select * ;
			from c_Entidad ;
			where upper( alltrim( Entidad ) ) == tcEntidad;
			into cursor c_EntidadBuscada NoFilter
			
		llRetorno = _tally > 0
		use in select( "c_EntidadBuscada"  )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function 	AgregarCamploBlogregEnTablaObservacion( ) as Void
		local lcTabla as String, lcCursorEntConBloqReg as String, lcCursor as String, lcCursorEntidades as String  

		lcTabla = ""
		lcCursor = sys( 2015 )
		lcCursorEntidades = sys( 2015 )

		lcCursorEntConBloqReg = this.ObtenerCursorEntidadesConBloqueaRegistro()
		this.xmlaCursor( lcCursorEntConBloqReg, lcCursorEntidades )
		
		select d1.tabla, d1.campo, d1.esquema, b.ubicacion ;
			from c_diccionario d1 , (lcCursorEntidades) b ;
			where alltrim( upper( d1.entidad ) ) == alltrim( upper( b.entidad ) ) ;
			and upper( alltrim( d1.dominio )) = "OBSERVACION" ;
			into cursor (lcCursor)
			
			select ( lcCursor )
			scan 
				lcTabla = upper(alltrim( &lcCursor..Tabla ) + "_" + alltrim( &lcCursor..Campo ))
				insert into c_EstructuraAdn ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema) ;
					values ( lcTabla, "BLOQREG", "L", 1, 0, iif( empty( &lcCursor..Ubicacion ), "Sucursal", &lcCursor..Ubicacion) , .f., .f., &lcCursor..Esquema )
			endscan 
			use in select( lcCursorEntidades )
			use in select( lcCursor )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorEntidadesConBloqueaRegistro() as String 
		local lcRetorno as String, lcCursor as String 
		lcCursor = sys( 2015 )
		
		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla, ent.ubicaciondb as ubicacion ;
			from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) ;
			where !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "E" and this.oFunc.TieneFuncionalidad( "BLOQUEARREGISTRO", Ent.Funcionalidades ) and est.claveprimaria;
			into cursor ( lcCursor )
			
			lcRetorno = this.cursoraxml( lcCursor )
			use in select( lcCursor )
		
		return lcRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionArmarColeccionEntidadesConMotivo() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerColeccionEntidadesConMotivo() as zoocoleccion", 1 )
		.AgregarLinea( "Local loEntidad as zoocoleccion OF zoocoleccion.prg", 2 )

		.AgregarLinea( "loEntidad  = _screen.zoo.crearObjeto( 'zoocoleccion' )", 3 )
		.AgregarLinea( "with this ", 2 )

		select d.entidad, max( d.atributo ) atributo, max( d.campo ) campo, count(*) cant ;
		 from c_Entidad e ;
		  inner join c_Diccionario d on alltrim( upper( e.entidad ) ) == alltrim( upper( d.entidad ) ) ;
		 where ( 'B' $ e.comportamiento or 'C' $ e.comportamiento ) ;
		   and upper( alltrim( d.claveforanea )) == "MOTIVO" ;
		   and alltrim( upper( d.entidad ) ) <> 'PASAJEDESTOCK' ;
		   and alltrim( upper( d.entidad ) ) <> 'REGLASTRANSFERENCIAS' ;
		 group by d.entidad, d.claveforanea ;
		 having cant = 1 ;
		 into cursor c_motivo

		select c_motivo
		scan
				.AgregarLinea( ".AgregarItemMotivoyOrigenDestino( loEntidad, " + ;
											"'"	+ 	alltrim( c_motivo.entidad) + "'," + ;
											"'" + 	alltrim( c_motivo.Atributo ) 	+ "'," + ;
											"'" + 	alltrim( c_motivo.Campo )		+ "')") 
		endscan

		use in select("c_motivo")
		.AgregarLinea( "endwith", 2 )

		.AgregarLinea( "return loEntidad", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionArmarColeccionEntidadesConConcepto() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerColeccionEntidadesConConcepto() as zoocoleccion", 1 )
		.AgregarLinea( "Local loEntidad as zoocoleccion OF zoocoleccion.prg", 2 )

		.AgregarLinea( "loEntidad  = _screen.zoo.crearObjeto( 'zoocoleccion' )", 3 )
		.AgregarLinea( "with this ", 2 )

		select d.entidad, max( d.atributo ) atributo, max( d.campo ) campo, count(*) cant ;
		 from c_Entidad e ;
		  inner join c_Diccionario d on alltrim( upper( e.entidad ) ) == alltrim( upper( d.entidad ) ) ;
		 where ( 'B' $ e.comportamiento or 'C' $ e.comportamiento ) ;
		   and upper( alltrim( d.claveforanea )) == "CONCEPTOCAJA" ;
		   and alltrim( upper( d.entidad ) ) <> 'CANJEDECUPONES' ;
		   and alltrim( upper( d.entidad ) ) <> 'COMPROBANTEDECAJA' ;
		   and alltrim( upper( d.entidad ) ) <> 'DESCARGADECHEQUES' ;
		   and alltrim( upper( d.entidad ) ) <> 'REGLASTRANSFERENCIAS' ;
		 group by d.entidad, d.claveforanea ;
		 having cant = 1 ;
		 into cursor c_origendestino

		select c_origendestino
		scan
				.AgregarLinea( ".AgregarItemMotivoyOrigenDestino( loEntidad, " + ;
							   "'"	+ 	alltrim( c_origendestino.entidad) + "'," + ;
							   "'" + 	alltrim( c_origendestino.Atributo ) 	+ "'," + ;
							   "'" + 	alltrim( c_origendestino.Campo )		+ "')") 
		endscan

		use in select("c_origendestino")
		.AgregarLinea( "endwith", 2 )

		.AgregarLinea( "return loEntidad", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionArmarColeccionEntidadesConOrigenDestino() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerColeccionEntidadesConOrigenDestino() as zoocoleccion", 1 )
		.AgregarLinea( "Local loEntidad as zoocoleccion OF zoocoleccion.prg", 2 )

		.AgregarLinea( "loEntidad  = _screen.zoo.crearObjeto( 'zoocoleccion' )", 3 )
		.AgregarLinea( "with this ", 2 )

		select d.entidad, max( d.atributo ) atributo, max( d.campo ) campo, count(*) cant ;
		 from c_Entidad e ;
		  inner join c_Diccionario d on alltrim( upper( e.entidad ) ) == alltrim( upper( d.entidad ) ) ;
		 where ( 'B' $ e.comportamiento or 'C' $ e.comportamiento ) ;
		   and upper( alltrim( d.claveforanea )) == "ORIGENDEDATOS" ;
		   and alltrim( upper( d.entidad ) ) <> 'PASAJEDESTOCK' ;
		   and alltrim( upper( d.entidad ) ) <> 'REGLASTRANSFERENCIAS' ;
		 group by d.entidad, d.claveforanea ;
		 having cant = 1 ;
		 into cursor c_origendestino

		select c_origendestino
		scan
				.AgregarLinea( ".AgregarItemMotivoyOrigenDestino( loEntidad, " + ;
							   "'"	+ 	alltrim( c_origendestino.entidad) + "'," + ;
							   "'" + 	alltrim( c_origendestino.Atributo ) 	+ "'," + ;
							   "'" + 	alltrim( c_origendestino.Campo )		+ "')") 
		endscan

		use in select("c_origendestino")
		.AgregarLinea( "endwith", 2 )

		.AgregarLinea( "return loEntidad", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionCargarColeccionAtributosPk() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerColeccionAtributosPk() as zoocoleccion", 1 )
		.AgregarLinea( "Local loAtributosPk as zoocoleccion OF zoocoleccion.prg", 2 )

		.AgregarLinea( "loAtributosPk = _screen.zoo.crearObjeto( 'zoocoleccion' )", 3 )
		.AgregarLinea( "with loAtributosPk", 2 )
		select c_Entidad
		scan for "<CODIGOSUGERIDO" $ upper( alltrim( FUNCIONALIDADES ) )
			select c_Diccionario
			locate for upper( alltrim( ENTIDAD ) ) == upper( alltrim( c_Entidad.entidad ) ) and ClavePrimaria
			if found()
				.AgregarLinea( ".Agregar( '" + transform( c_diccionario.Longitud ) + "','" + upper( alltrim( c_entidad.entidad ) ) + "' )", 3 )
			endif
			
			select c_entidad
		endscan
		.AgregarLinea( "endwith", 2 )

		.AgregarLinea( "return loAtributosPk", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function AgregarTablasPropiedadesReplica() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PROPIEDADESREP", "ATRIBUTO", "C", 100, 0, "SUCURSAL", .T., .F., "ZooLogic" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PROPIEDADESREP", "VALOR", "C", 200, 0, "SUCURSAL", .F., .F., "ZooLogic" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PROPIEDADESREP", "ATRIBUTO", "C", 100, 0, "ORGANIZACION", .T., .F., "ORGANIZACION" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PROPIEDADESREP", "VALOR", "C", 200, 0, "ORGANIZACION", .F., .F., "ORGANIZACION" )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerCamposEstadosDeStock() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerCamposEstadosDeStock() as string", 1 )
		local lcCampos as String
		lcCampos = ""
		select Distinct upper( Stock ) as Stock from c_Comprobantes where !empty( stock ) into cursor c_ver
			
		scan All
			lcCampos = lcCampos + iif( empty( lcCampos ), "", "," ) + alltrim( c_Ver.Stock )
		endscan
		use in select ( "c_Ver" )

		select c_Diccionario
		locate for upper( alltrim( entidad ) ) = upper( alltrim( "StockCombinacion" ) ) and upper( alltrim( atributo ) ) = upper( alltrim( "EnTransito" ) )
		if found()
			lcCampos = lcCampos + iif( empty( lcCampos ), "", "," ) + "ENTRANSITO"
		endif

		.AgregarLinea( "return '" + lcCampos  + "'", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerCamposAtributosCombinacionDeStock() as Void
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerCamposAtributosCombinacionDeStock() as string", 1 )
		local loCamposCombinacion as Object, lcCampo as Object, lcCampos as String
		lcCampos = ""
		loCamposCombinacion = this.ObtenerAtributosStockCombinacion()
		for each lcCampo in loCamposCombinacion as FoxObjec 
			lcCampos = lcCampos + lcCampo + ", "
		endfor 				
		lcCampos = left( lcCampos, len( lcCampos ) - 2 )
		
		.AgregarLinea( "return '" + lcCampos  + "'", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosCombinacion() as zoocoleccion OF zoocoleccion.prg 
		local loCampos as zoocoleccion OF zoocoleccion.prg 
		loCampos = _screen.zoo.crearobjeto( "ZooColeccion" )

		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
			
				use in select( "c_Atributo" )
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and clavecandidata > 1 ;
					order by clavecandidata;
					into cursor c_Atributo
				
				select c_Atributo
				scan 
				
					select * ;
						from c_Diccionario ;
						where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0 and ;
						upper( alltrim( atributo ) ) == upper( alltrim( c_Atributo.Atributo ) ) ;
						into cursor c_AtributosStockCombinacion NoFilter
					
					if _tally > 0	
						loCampos.Agregar( alltrim(upper(c_Atributo.Campo)) )
					endif		
					select c_Atributo
				endscan
				use in select( "c_Atributo"  )
				use in select( "c_AtributosStockCombinacion"  )		
			endif	
		endwith	
		return loCampos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosKitYPackCombinacion() as zoocoleccion OF zoocoleccion.prg 
		local loCampos as zoocoleccion OF zoocoleccion.prg 
		loCampos = _screen.zoo.crearobjeto( "ZooColeccion" )

		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
			
				use in select( "c_Atributo" )
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "PRECIODEARTICULO" and clavecandidata > 2 ;
					order by clavecandidata;
					into cursor c_Atributo
				
				select c_Atributo
				scan 
				
					select * ;
						from c_Diccionario ;
						where upper( alltrim( Entidad ) ) == "ITEMPARTICIPANTES" and ;
						upper( alltrim( atributo ) ) == upper( alltrim( c_Atributo.Atributo ) ) ;
						into cursor c_AtributosKitYPackCombinacion NoFilter
					
					if _tally > 0	
						loCampos.Agregar( alltrim(upper(c_AtributosKitYPackCombinacion.Campo)) )
					endif		
					select c_Atributo
				endscan
				use in select( "c_Atributo"  )
				use in select( "c_AtributosKitYPackCombinacion"  )		
			endif	
		endwith	
		return loCampos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributosStockCombinacion() as zoocoleccion OF zoocoleccion.prg 
		local loCampos as zoocoleccion OF zoocoleccion.prg 
		loCampos = _screen.zoo.crearobjeto( "ZooColeccion" )

		with this
			if .ExisteEntidad( "CALCULODEPRECIOS" )
			
				use in select( "c_Atributo" )
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0 ;
					order by clavecandidata;
					into cursor c_Atributo
				
				select c_Atributo
				scan 
					if _tally > 0	
						loCampos.Agregar( alltrim(upper(c_Atributo.Campo)) )
					endif		
				endscan
				use in select( "c_Atributo"  )
			endif	
		endwith	
		return loCampos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerCamposAtributosCombinacionConcatenados() as Void 
		local lcRetorno as String, loCombinacion as zoocoleccion OF zoocoleccion.prg  
		.AgregarLinea( "*------------------------------------------------------------------------------------",1)
		.AgregarLinea( "Function ObtenerCamposAtributosCombinacionConcatenados() as string", 1 )
		
		loCombinacion = this.ObtenerAtributosCombinacion()
		lcRetorno = ""
		
		for each lcAtributo in loCombinacion as FoxObject
			lcRetorno = lcRetorno + lcAtributo + ", "
		endfor 
		
		lcRetorno = left( lcRetorno, len(lcRetorno) - 2 )
		
		.AgregarLinea( "return '" + lcRetorno + "'", 2 )
		.AgregarLinea( "endfunc", 1 )
		.AgregarLinea( "")
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarSeguridadNuevoEnBaseA() as Void
		
		select C.Descripcion as entidad from c_RelaComprobantes A left join c_Comprobantes C on A.IdComp = C.Id group by A.IdComp ;
		Into Cursor c_EntidadesNuevoEnBaseA readwrite
		
		select c_EntidadesNuevoEnBaseA
		scan
			insert into c_SeguridadEntidades ( Entidad, lSacar, Operacion, DescripcionOperacion, version_exe, version_zoo, version_cli ) ;
						values ( c_EntidadesNuevoEnBaseA.entidad, .f., "NUEVOENBASEA", "Nuevo en base a", 0, 0, 0 )
		endscan
		
		Use In Select( "c_EntidadesNuevoEnBaseA" )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerFiltrosDeDescuentos() as Void
		local lcClavePrimaria as String
		with this
			if .ExisteEntidad( "DESCUENTO" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerFiltrosDeDescuentos() as Object", 1)
				.AgregarLinea( "local lcRetorno", 2 )

				local lcEntidad as String
				select c_Diccionario
				*locate for upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and ClavePrimaria
				*lcClavePrimaria = upper( alltrim( c_Diccionario.Tabla ) )
				*.AgregarLinea( "lcRetorno = '" + alltrim( c_Diccionario.Tabla ) + "'", 2 )
				scan all for upper( alltrim( Entidad ) ) == "DESCUENTO" and !empty( ClaveForanea ) and grupo = 1 and subgrupo > 20
					*lcEntidad = alltrim( upper( c_Diccionario.ClaveForanea ) )
					select * from c_Diccionario where upper( alltrim( Entidad ) ) == lcEntidad and ClavePrimaria into cursor c_Foraneas
					if lcClavePrimaria # upper( alltrim( c_Foraneas.Tabla ) )
						.AgregarLinea( "lcRetorno = lcRetorno + '," + upper( alltrim( c_Foraneas.Tabla ) ) + "'", 2 )
					endif	
					use in select( "c_Foraneas" )
					select c_Diccionario
				endscan
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
			endif	
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionObtenerAtributosDeFiltrosDeDescuentos() as Void
		local lcClavePrimaria as String
		with this
			if .ExisteEntidad( "DESCUENTO" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------")
				.AgregarLinea( "Function ObtenerAtributosDeFiltrosDeDescuentos() as Object", 1)
				.AgregarLinea( "local loRetorno", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "loRetorno = _screen.zoo.crearobjeto( 'ZooColeccion' )", 2 )
				select c_Diccionario
				scan all for upper( alltrim( Entidad ) ) == "DESCUENTO" and !empty( ClaveForanea ) and grupo = 1 and subgrupo > 20
					.AgregarLinea( "loRetorno.add( '" + alltrim( Atributo ) + "' )", 2 )
				endscan
				.AgregarLinea( "", 2 )
				.AgregarLinea( "return loRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValidacionesDeFiltrosDeDescuentos() as Void
		local lcClavePrimaria as String, lcAtributo as String, lcSentencia as String, lcTexto as String
		with this
			if .ExisteEntidad( "DESCUENTO" )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------",1)
				.AgregarLinea( "Function ObtenerValidacionesDeFiltrosDeDescuentos() as String", 1)
				.AgregarLinea( "local lcRetorno as String", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "text to lcRetorno textmerge noshow", 2 )
				select c_Diccionario
				lcTexto = ""
				scan all for upper( alltrim( Entidad ) ) == "DESCUENTO" and !empty( ClaveForanea ) and grupo = 1 and subgrupo > 20 and right( upper( alltrim( Atributo ) ), 5) = "DESDE"
					lcSentencia = "iif( .nEvitar = "
					do case 
					case ClaveForanea = "CLIENTE" or left( upper( Atributo ), 8 ) = "CLIENTE_"  
						lcSentencia = lcSentencia + "1"
					case ClaveForanea = "VENDEDOR" or left( upper( Atributo ), 9 ) = "VENDEDOR_"  
						lcSentencia = lcSentencia + "2"
					case ClaveForanea = "LISTADEPRECIOS" or left( upper( Atributo), 15 ) = "LISTADEPRECIOS_"  
						lcSentencia = lcSentencia + "3"
					endcase
					lcAtrib = alltrim( Atributo )
					lcAtributo = left( lcAtrib , len( lcAtrib ) - 5 )
					do case 
						case TipoDato = "C"
							lcSentencia = lcSentencia + ", .T., this.ValidarCaracteres( ."
						case TipoDato = "N"
							lcSentencia = lcSentencia + ", .T., this.ValidarNumerico( ."
						case TipoDato = "D"
							lcSentencia = lcSentencia + ", .T., this.ValidarFecha( ."
					endcase
					lcSentencia = lcSentencia + lcAtributo + "Desde, ." + lcAtributo + "Hasta, this.oEntidadPadre."
					if atc( "_", Atributo) != 0
 						lcEntidad = alltrim( upper( substr( Atributo, 1, atc( "_", Atributo) - 1 ) ) )
						lcForanea = alltrim( ClaveForanea )
						select Atributo as 'Atrib' from c_Diccionario where upper( alltrim( Entidad ) ) == lcEntidad and ClaveForanea = lcForanea into cursor c_Atributo
						lcSentencia = lcSentencia + lcEntidad + "." + alltrim( C_Atributo.Atrib )
						select c_Diccionario
					else
						lcSentencia = lcSentencia + alltrim( ClaveForanea )
					endif
					lcSentencia = lcSentencia + iif( empty( ClaveForanea), " )", "_PK ) ) and ")
					lcTexto = lcTexto + lcSentencia
				endscan
				lcTexto = lcTexto + ".T."
				.AgregarLinea( lcTexto, 3 )
				.AgregarLinea( "endtext", 2 )
				
				.AgregarLinea( "", 2 )
				.AgregarLinea( "return lcRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "")
			endif
		endwith
		
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function SetearModosDefaultParticulares() as Void
		* Para agregar una operacion nueva y conservarla habilitada para los usuarios que ya la estaban usando;
		 se llama al siguiente metodo, indicando la operacion y el modo,
		* Modo: 1 es habilitado, 2 deshabilitado, 3 con clave, 6 es parcialmente habilitado. 
		* Este mismo metodo se encarga de colocar el mismo modo a los hijos de la operacion si esta tuviera.
		
		*Ejemplo: this.ModificarModoDefault( "TR_ABDD_REMITO", 1 ) me mandaria habilitada la acción de empaquetar remitos;
		 para todos los usuarios que no tenian deshabilitado su padre (si empaquetar datos del tipo "a base de datos", que es el padre,;
		 esta habilitado o habilitado parcialmente para un usuario, empaquetar remitos le quedaría habilitado;
		 Pero si el usuario tenia deshabilitado el padre de la acción, esta se verá deshabilitadoa).

		 this.ModificarModoDefault( "TIINVENTARIOFISICO_TIINVENTARIOFISICO", 1 )
		 this.ModificarModoDefault( "DEVOLUCION_ANULAR", 1 )
		 this.ModificarModoDefault( "MOVIMIENTODESTOCK_MODIFICARREMPAQUETADO", 1 )
		 this.ModificarModoDefault( "MOVIMIENTODESTOCK_ELIMINARREMPAQUETADO", 1 )
		 this.ModificarModoDefault( "MOVIMIENTODESTOCK_ANULARREMPAQUETADO", 1 )
		 this.ModificarModoDefault( "DESCARGADECHEQUES_ANULAR", 1 )
		 this.ModificarModoDefault( "FACTURAAGRUPADA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITOAGRUPADA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITOAGRUPADA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "TICKETFACTURA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "TICKETNOTADECREDITO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "TICKETNOTADEDEBITO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "FACTURAELECTRONICA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITOELECTRONICA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITOELECTRONICA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "FACTURA_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "PRESUPUESTO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "PEDIDO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "REMITO_VALIDARARTICULOSINPRECIO", 1 )
		 this.ModificarModoDefault( "PICKING_CONFIRMARSTOCKCONDIFERENCIAS", 1 )
		 this.ModificarModoDefault( "FACTURA_MOSTRARASISTENTE", 1 )
		 this.ModificarModoDefault( "FACTURAELECTRONICA_MOSTRARASISTENTE", 1 )
		 this.ModificarModoDefault( "TICKETFACTURA_MOSTRARASISTENTE", 1 )
		 this.ModificarModoDefault( "FACTURAAGRUPADA_MOSTRARASISTENTE", 1 )
		 this.ModificarModoDefault( "FACTURAELECTRONICADECREDITO_MOSTRARASISTENTE", 1 )
		 this.ModificarModoDefault( "FACTURA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "REMITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "TICKETFACTURA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "TICKETNOTADECREDITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "TICKETNOTADEDEBITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITOELECTRONICA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITOELECTRONICA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITOELECTRONICADECREDITO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "FACTURAAGRUPADA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADECREDITOAGRUPADA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "NOTADEDEBITOAGRUPADA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "PEDIDO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "PRESUPUESTO_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "FACTURAELECTRONICA_EXPERIENCIADEUSUARIO", 1 )
		 this.ModificarModoDefault( "FACTURA_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "TICKETFACTURA_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "FACTURAAGRUPADA_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "FACTURAELECTRONICA_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "FACTURAELECTRONICADECREDITO_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "FACTURADEEXPORTACION_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "FACTURAELECTRONICAEXPORTACION_MODIFICARVENDEDOR", 2 )
		 this.ModificarModoDefault( "OPERACIONECOMMERCE_ADJUNTARCOMPROBANTE", 1 )
		 this.ModificarModoDefault( "CANJEDECUPONES_ANULAR", 1 )
		 this.ModificarModoDefault( "MODIFICACIONPRECIOS_ANULAR", 1 )
		 this.ModificarModoDefault( "CALCULODEPRECIOS_ANULAR", 1 )
		 this.ModificarModoDefaultSeguridadModificarItemDetalleArticulo()
		 this.ModificarModoDefaultSeguridadPermiteItemCantidadNegativa()
		 this.ModificarModoDefaultSeguridadListasDePrecios()
		 this.ModificarModoDefaultSeguridadListasDePreciosEnConsultas()
		 this.ModificarModoDefaultSeguridadAperturaCajonDeDinero()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ModificarModoDefault( tcId as String, tnModo as Integer ) as Void
		
		update c_OperacionesFinal set modo = tnModo where alltrim( upper( id ) ) = tcId
		this.ModificarModoDefaultHijos( tcId, tnModo )		

	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ModificarModoDefaultHijos( tcId as String, tnModo as integer ) as Void
		local lcCursorAux as String
		
		lcCursorAux = "c_HIJOSDE" + "_" + alltrim( upper( tcid ) )+ + "_" + sys(2015)
		
		select * from c_OperacionesFinal where ItemPadre = tcId into cursor( lcCursorAux )
		select ( lcCursorAux )
		scan
			update c_OperacionesFinal set modo = tnModo where alltrim( upper( id ) ) = &lcCursorAux..id 
			this.ModificarModoDefaultHijos( &lcCursorAux..id , tnModo )
		endscan
		use in select( lcCursorAux )
		 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CursorAArchivoXML( tcCursor as String, tcArchivo as String) as Void
		
		cursortoxml(tcCursor,tcArchivo,3,4+512,0,"1")
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function XMLAArchivo( tcXML as String, tcArchivo as String ) as Void
		strtofile(tcXML,tcArchivo)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarNodoPrincipalSeguridadListaDePrecios() as Void
		local lcPrefijo as String, lcCadena as String, lcEntidad as String 
		 
		this.cCursorEntidadesConListasDePrecios = sys( 2015 )
		lcPrefijo = "VERLP"
		select entidad from c_entidad where ('<ventas>' $ lower(funcionalidades) and entidad in ;
		(select entidad from c_DICCIONARIO where upper(alltrim(claveforanea)) == "LISTADEPRECIOS")) or ;
			(inlist(alltrim(lower(entidad)),'modificacionprecios','calculodeprecios') and tipo = 'E') ;
			into cursor (this.cCursorEntidadesConListasDePrecios)

		select (this.cCursorEntidadesConListasDePrecios)
		scan
			lcEntidad  = upper( alltrim( Entidad ) )
			lcCadena = lcPrefijo +"_"+ upper( alltrim( Entidad ) )
			insert into c_SeguridadEntidades ( Entidad, lSacar, Operacion, DescripcionOperacion, version_exe, version_zoo, version_cli ) ;
						values ( lcentidad, .f., "VERLP", "Visibilidad Lista de Precios", 0, 0, 0 )
			select (this.cCursorEntidadesConListasDePrecios)
		endscan
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarNodosNivelSeguridadListaDePrecios() as Void
		local lcPrefijo as String, lcCadena as String, lcEntidad as String, lcIDPadre as String  
		lcPrefijo = "VERLP"
		lcEntidad  = ""

		select (this.cCursorEntidadesConListasDePrecios)
		scan
			lcCadena = lcPrefijo +"_"+ upper( alltrim( Entidad ) )
			lcIDPadre =  upper( alltrim( Entidad ) )+"_"+lcPrefijo 
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre  + "_N1" , "VERLP", lcIDPadre, "Nivel 1", 1, 0,lcEntidad)  
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre + "_N2" , "VERLP", lcIDPadre, "Nivel 2", 2, 0, lcEntidad) 
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre + "_N3" , "VERLP", lcIDPadre, "Nivel 3", 3, 0, lcEntidad) 
			select (this.cCursorEntidadesConListasDePrecios)
		endscan

	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ModificarModoDefaultSeguridadModificarItemDetalleArticulo() as Void
		local lnModo as Integer
		* Modo: 1 es habilitado, 2 deshabilitado, 3 con clave, 6 es parcialmente habilitado. 
		* Este mismo metodo se encarga de colocar el mismo modo a los hijos de la operacion si esta tuviera.
		lnModo = 1
		this.ModificarModoDefault( "TICKETFACTURA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "TICKETNOTADECREDITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "TICKETNOTADEDEBITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "REMITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "PEDIDO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "PRESUPUESTO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "DEVOLUCION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "PREPARACIONDEMERCADERIA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURADEEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITODEEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITODEEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICADECREDITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICADECREDITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICADECREDITO_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICAEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICAEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICAEXPORTACION_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "FACTURAAGRUPADA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOAGRUPADA_MODIFICARITEMDETALLEARTICULO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOAGRUPADA_MODIFICARITEMDETALLEARTICULO", lnModo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ModificarModoDefaultSeguridadAperturaCajonDeDinero() as Void
		local lnModo as Integer
		* Modo: 1 es habilitado, 2 deshabilitado, 3 con clave, 6 es parcialmente habilitado. 
		* Este mismo metodo se encarga de colocar el mismo modo a los hijos de la operacion si esta tuviera.
		lnModo = 1
		this.ModificarModoDefault( "CANJEDECUPONES_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "COMPROBANTEDECAJA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURAAGRUPADA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURADEEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICADECREDITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICAEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "FACTURA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOAGRUPADA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITODEEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICADECREDITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICAEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADECREDITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOAGRUPADA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITODEEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICADECREDITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICAEXPORTACION_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "RECIBO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "TICKETFACTURA_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "TICKETNOTADECREDITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
		this.ModificarModoDefault( "TICKETNOTADEDEBITO_INICIOCOMANDOABRIRCAJONDEDINERO", lnModo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ModificarModoDefaultSeguridadPermiteItemCantidadNegativa() as Void
		local lnModo as Integer
		* Modo: 1 es habilitado, 2 deshabilitado, 3 con clave, 6 es parcialmente habilitado. 
		* Este mismo metodo se encarga de colocar el mismo modo a los hijos de la operacion si esta tuviera.
		lnModo = 1
		this.ModificarModoDefault( "TICKETFACTURA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "TICKETNOTADECREDITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "TICKETNOTADEDEBITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "REMITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "PEDIDO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "PRESUPUESTO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "DEVOLUCION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "PREPARACIONDEMERCADERIA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURADEEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITODEEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITODEEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICADECREDITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICADECREDITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICADECREDITO_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURAELECTRONICAEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOELECTRONICAEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOELECTRONICAEXPORTACION_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "FACTURAAGRUPADA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADECREDITOAGRUPADA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
		this.ModificarModoDefault( "NOTADEDEBITOAGRUPADA_PERMITEITEMCANTIDADNEGATIVA", lnModo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarNodoNivelSeguridadConsultas() as Void
		local lcPrefijo as String, lcCadena as String, lcEntidad as String, lcIDPadre as String, lcCursor as String  
		lcPrefijo = "VERLP"
		lcEntidad  = ""
		lcCursor = sys(2015)
		select * from c_operaciones where upper(alltrim(itempadre)) == "ME_30" and inlist(ID,"IT_2036","IT_9860") into cursor &lcCursor
		select &lcCursor
		scan
			lcCadena = lcPrefijo +"_"+ upper( alltrim( Entidad ) )
			lcIDPadre =  upper( alltrim( iD ) )+"_"+lcPrefijo 
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre  , "VERLP", upper(alltrim(&lcCursor..id)), "Visibilidad Lista de Precios", 0, 0,lcEntidad)  
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre + "_N1" , "VERLP", lcIDPadre, "Nivel 1", 1, 0,lcEntidad)  
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre + "_N2" , "VERLP", lcIDPadre, "Nivel 2", 2, 0, lcEntidad) 
			insert into c_Operaciones ( id, TipoOpcion, ItemPadre, item, orden, modo, entidad) ;
				values ( lcIDPadre + "_N3" , "VERLP", lcIDPadre, "Nivel 3", 3, 0, lcEntidad) 
			select (lcCursor)
		endscan
		use in select(lcCursor)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ModificarModoDefaultSeguridadListasDePreciosEnConsultas() as Void
		local lcCursor as String 
		lcCursor = sys(2015)
		select upper(alltrim(id)) as idMenu from c_operaciones where upper(alltrim(itempadre)) == "ME_30" and inlist(ID,"IT_2036","IT_9860") into cursor &lcCursor
		select &lcCursor
		scan
			this.ModificarModoDefault(alltrim(idMenu)+"_VERLP", 1 )
		endscan 
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ModificarModoDefaultSeguridadListasDePrecios() as Void
		select ( this.cCursorEntidadesConListasDePrecios )
		scan
			this.ModificarModoDefault( upper( alltrim( entidad ))+"_VERLP", 1 )
			select( this.cCursorEntidadesConListasDePrecios )
		endscan 
		use in select( this.cCursorEntidadesConListasDePrecios )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function QuitarCasosDeCombinacionesQueNoExisten( tcTablaPrecio as String, tcEntidad as String  ) as Void
		local lcRetorno as String, lcTablaInner  as String, lcCampoInner as String, lcCampoPrecio as String
		
		lcRetorno = "lcRetorno = lcRetorno + "
		select * ;
				from c_Diccionario ;
				where upper( alltrim( Entidad ) ) == upper( alltrim( tcEntidad ) ) and !empty( ClaveCandidata ) and !empty( ClaveForanea );
				and upper( alltrim( ClaveForanea ) ) != "LISTADEPRECIOS" and upper( alltrim( ClaveForanea ) ) != "ARTICULO" ;
				order by ClaveCandidata ;
				into cursor c_Filtro_Eliminados
		select c_Filtro_Eliminados
		scan all
			select c_Diccionario
			locate for upper( alltrim( Entidad ) ) == upper( alltrim( c_Filtro_Eliminados.ClaveForanea ) ) and ClavePrimaria
			lcTablaInner = alltrim( c_Diccionario.Tabla )
			lcCampoInner = alltrim( c_Diccionario.Campo )
			lcCampoPrecio = alltrim( c_Filtro_Eliminados.Campo )
			lcRetorno = lcRetorno + [" and ( ] + tcTablaPrecio + "." + lcCampoPrecio + "= [] or " + lcTablaInner + "." + lcCampoInner + [ is not null )" + ]
			select c_Filtro_Eliminados
		endscan
		
		lcRetorno = left( lcRetorno , len( lcRetorno ) - 2 )

		use in select( "c_Filtro_Eliminados" )	
		
		this.AgregarLinea( lcRetorno , 2 ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerColeccionEntidadesConMenu() as Void

		with this
			.AgregarLinea( "*------------------------------------------------------------------------------------",1)
			.AgregarLinea( "Function ObtenerColeccionEntidadesConMenu() as object", 1 )
			.AgregarLinea( "local loColeccion as zoocoleccion OF zoocoleccion.prg", 2 )
			.AgregarLinea( "loColeccion = _screen.zoo.CrearObjeto( 'ZooColeccion' )", 2 )
			select distin( entidad ) as entidad from c_menuprincipalitems where !empty(entidad) order by 1 asc into cursor c_menuent			
			select c_menuent
			scan 
				.AgregarLinea( "loColeccion.Agregar( '" + upper(alltrim( c_menuent.entidad )) + "','" + alltrim( upper( c_menuent.entidad ) )+ "' )", 2 )
			endscan
			use in select("c_menuent")
			.AgregarLinea( "return loColeccion", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")
		endwith

	endfunc 	
	
enddefine
	
