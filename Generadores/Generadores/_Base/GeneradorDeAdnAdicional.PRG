define class GeneradorDeAdnAdicional as Custom
	
	#if .f.
		local this as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg
	#endif
	
	protected oGeneradorDeAdnAdicionalListadosGenericos, oGeneradoresAdicionales 

	cPrefijoAuditoria = "ADT_"
	cXmlCamposAuditoriaEntidad = ""
	cXmlCamposAuditoriaDetalle = ""
	nIdPadreAuditoria = 0
	nOrdenListadoAuditoria = 1
	datasession = 1
	oFunc = null
	cSchemaDefault = ""
	nCantidadDeEntidadesConAuditoria = -1
	oGeneradorDeAdnAdicionalListadosGenericos = null
	cGeneradoresHabilitados = null
	lDestroy = .f.
	cRutaZoo = ""
	cProyectoActivo = ""

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()

		this.oFunc = newobject( "funcionalidades", "funcionalidades.prg" )
		this.CrearCursorDeEntidadesDesactivables()
		this.CrearCursorDeEntidadesParaCompletarDesdeVentas()
		this.CrearCursorDeEntidadesParaInsertarDesdeTxt()
		This.CrearCursorDeEntidadesParaPickearComprobante()
		this.oGeneradorDeAdnAdicionalListadosGenericos = newobject( "GeneradorDeAdnAdicionalListadosGenericos", "GeneradorDeAdnAdicionalListadosGenericos.prg" )
		bindevent( this.oGeneradorDeAdnAdicionalListadosGenericos, "Informar", this, "InformarProceso" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializarGeneradores() as Void
		local loFactoryGen as Custom

		loFactoryGen = newobject( "FactoryGeneradorDeAdnAdicional", "FactoryGeneradorDeAdnAdicional.prg" )
		This.oGeneradoresAdicionales = loFactoryGen.ObtenerGeneradores( this.cRutaZoo )
		loFactoryGen = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		use in select( "c_EntidadesDesactivables" )
		use in select( "c_completaventas" )	
		use in select( "c_CopiaDesdeTxt" )
		use in select( "c_PickearComprobante" )
		this.oFunc = null
		release this 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		local lnCantidad as Integer, laPropiedades as array, lnTablaActual as Integer,;
		i as Integer, lcPropiedad as String, lcEliminaReferencia as String    
		dimension laPropiedades(1)

		this.lDestroy = .t.

		use in select( "c_EntidadesDesactivables" )
		use in select( "c_completaventas" )
		use in select( "c_CopiaDesdeTxt" )
		use in select( "c_PickearComprobante" )
		this.oFunc = null
		lnCantidad = Amembers( laPropiedades,this,0,"UG+" )

		for i = 1 to lnCantidad
			lcPropiedad = "this."+ alltrim( laPropiedades[i] )
			if vartype( evaluate( lcPropiedad ) ) = "O"
				if pemstatus(&lcPropiedad,"release",5)
					lcEliminaReferencia = lcPropiedad + ".release"
					&lcEliminaReferencia
				endif
			endif
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeGenerarTransferencias() as Boolean
		local lcAux as String, llRetorno as Boolean 
		
		llRetorno = .f.
		lcAux = this.cGeneradoresHabilitados

		if 'A' $ lcAux or 'B' $ lcAux or 'D' $ lcAux 
			llRetorno = .t.
		endif
	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cGeneradoresHabilitados_Assign( txVal as variant ) as void
		this.cGeneradoresHabilitados = txVal
		if vartype( this.oGeneradorDeAdnAdicionalListadosGenericos ) == "O" and ;
			pemstatus( this.oGeneradorDeAdnAdicionalListadosGenericos, "cGeneradoresHabilitados", 5 )
			this.oGeneradorDeAdnAdicionalListadosGenericos.cGeneradoresHabilitados = this.cGeneradoresHabilitados
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function cGeneradoresHabilitados_Access() as variant
	
		if !this.ldestroy and vartype( this.cGeneradoresHabilitados ) != 'C'
			this.cGeneradoresHabilitados = this.ObtenerGeneradoresHabilitados()
			this.oGeneradorDeAdnAdicionalListadosGenericos.cGeneradoresHabilitados = this.cGeneradoresHabilitados			
		endif
		return this.cGeneradoresHabilitados
	endfunc

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerGeneradoresHabilitados() As String
		Local lcGeneradores As String, laRutaPrincipal( 1 ) As Array, lcProyecto as string, lcRutaBase as String

		lcGeneradores = ""
		lcProyecto = lower( alltrim( this.cProyectoActivo )	)
		lcRutaBase = addbs( this.ObtenerRutaInicial() )
		if file( addbs(_screen.zoo.cRutaInicial) + "data\proyectos.dbf" )
			lcRutaBase = addbs(_screen.zoo.cRutaInicial) + "data\"
		else
			lcRutaBase = lcRutaBase + "taspein\data\"
		endif	
		use ( lcRutaBase + "proyectos.dbf" ) in 0 again alias c_ProyectosParaAdnAdicional

		Select Generadore from c_ProyectosParaAdnAdicional ;
			where lower( alltrim( c_ProyectosParaAdnAdicional.Nombre ) ) == lcProyecto ;
			into Array laRutaPrincipal

		If _Tally > 0
			lcGeneradores = Alltrim( laRutaPrincipal( 1 ) )
		endif
		use in select( "c_ProyectosParaAdnAdicional" )
		
		Return lcGeneradores
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaInicial() as string

		local lcRetorno as String
		lcRetorno = addbs( this.cRutaZoo )
		if vartype( _screen.zoo ) == "O"
			lcRetorno = addbs( _Screen.zoo.cRutaInicial ) + "..\"
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function CrearCursorDeEntidadesDesactivables() as Void
		if used( "c_Diccionario" )
			select e.entidad, d.tabla ;
				from c_entidad e ;
				left join c_Diccionario d on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) and d.ClavePrimaria;
				where this.oFunc.Tienefuncionalidad("DESACTIVABLE", e.Funcionalidades ) ;
				into cursor c_EntidadesDesactivables
		else
			select e.entidad ;
				from c_entidad e ;
				where this.oFunc.Tienefuncionalidad("DESACTIVABLE", e.Funcionalidades ) ;
				into cursor c_EntidadesDesactivables
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function CrearCursorDeEntidadesParaCompletarDesdeVentas() as Void
		if used( "c_Diccionario" )
			select e.entidad, d.tabla ;
				from c_entidad e ;
				left join c_Diccionario d on upper( alltrim( e.entidad ) ) == upper( alltrim( d.entidad ) ) and d.ClavePrimaria;
				where this.oFunc.Tienefuncionalidad("COMPLETADESDEVENTAS", e.Funcionalidades ) ;
				into cursor c_completaventas
		else
			select e.entidad ;
				from c_entidad e ;
				where this.oFunc.Tienefuncionalidad("COMPLETADESDEVENTAS", e.Funcionalidades ) ;
				into cursor c_completaventas
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function CrearCursorDeEntidadesParaInsertarDesdeTxt() as Void
		select entidad ;
			from c_Diccionario ;
			where "COPIADESDETXT" $ upper(tags) ;
			into cursor c_CopiaDesdeTxt
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarCabeceras() as Void
		*** Este metodo sólo se utiliza para visualizar la informacion mas rápido en el taspein.
		with this as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg
			.cXmlCamposAuditoriaEntidad = .ObtenerXmlCamposAuditoriaEntidad()
			.AgregarDatosAuditoria()
			.oGeneradorDeAdnAdicionalListadosGenericos.AgregarListadosGenericos( .t. )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Procesar() as void
		this.InformarProceso( "Procesando" )
		with This as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg
			.cXmlCamposAuditoriaEntidad = .ObtenerXmlCamposAuditoriaEntidad()
			.cXmlCamposAuditoriaDetalle = .ObtenerXmlCamposAuditoriaDetalle()
			replace all Entidad with upper( entidad ) in c_diccionario 
			
			.InformarProceso( "AgregarAtributoDeActivacionDesactivacion" )
			.AgregarAtributoDeActivacionDesactivacion()
			
			.InformarProceso( "ProcesarGeneradoresDeAdnAdicional" )
			.ProcesarGeneradoresDeAdnAdicional()

			.InformarProceso( "AgregarDatosAuditoria" )
			.AgregarDatosAuditoria()

			.InformarProceso( "AgregarAtributosGenericosEntidades" )
			.AgregarAtributosGenericosEntidades() 

			.InformarProceso( "AgregarDetalleUnificadoDeCoprobantesAfectados" )
			.AgregarDetalleUnificadoDeCoprobantesAfectados()
			
			.InformarProceso( "AgregarDetalleGenericoDeCoprobantesAfectados" )
			.AgregarDetalleGenericoDeCoprobantesAfectados()
			
			.InformarProceso( "AgregarMenuDeComprobantesAfectantes" )
			.AgregarMenuDeComprobantesAfectantes()

			.InformarProceso( "AgregarAccionesDeMenuDeComprobantesAfectantes" ) && Acciones -> Afectar comprobante
			.AgregarAccionesDeMenuDeComprobantesAfectantes()

			.InformarProceso( "AgregarMenuDeActivacionDesactivacion" )
			.AgregarMenuDeActivacionDesactivacion()
			
			.InformarProceso( "AgregarMenuCompletarDesdeVentas" )
			.AgregarMenuCompletarDesdeVentas()

			.InformarProceso( "AgregarMenuInsetarDesdeTxt" )
			.AgregarMenuInsertarDesdeTxt()
			
			.InformarProceso( "AgregarMenuPickearComprobante" )
			.AgregarMenuPickearComprobante()

			.InformarProceso( "AgregarSeguridadDeActivacionDesactivacion" )
			.AgregarSeguridadDeActivacionDesactivacion()
			
			.InformarProceso( "AgregarAtributoGuid" )
			.AgregarAtributoGuid()	

			.InformarProceso( "AgregarAtributoTimeStamp" )
			.AgregarAtributoTimeStamp()	
			
			.InformarProceso( "ReemplazarAtributoMantenerenRecepcion" )
			.ReemplazarAtributoMantenerenRecepcion()
			
			.InformarProceso( "ReemplazarTipoGuidEnDiccionario" )
			.ReemplazarTipoGuidEnDiccionario()

			.InformarProceso( "AgregarAtributoBloquearRegistro" )
			.AgregarAtributoBloquearRegistro()

            .InformarProceso( "AgregarAtributoOcultarNodoExportacion" )
            .AgregarAtributoOcultarNodoExportacion()
			
			.InformarProceso( "AgregarAtributosCAI" )
			.AgregarAtributosCAI()
			
			.InformarProceso( "ActualizarEsquemas" )
			.ActualizarEsquemas()
			
			.InformarProceso( "VerificarFormatoDescripcion" )
			.VerificarFormatoDescripcion()
			
			.InformarProceso( "AgregarTransferenciasNovedades" )
			.AgregarTransferenciasNovedades()
			
			.InformarProceso( "AgregarDetalleGenericoDeAgrupamientoPublicaciones" )
			.AgregarDetalleGenericoDeAgrupamientoPublicaciones()
			
			.InformarProceso( "AgregarComponenteKitDeArticulos" )
			.AgregarComponenteKitDeArticulos()
			
			.InformarProceso( "GenerarListados" )
			.GenerarListados()
			
			use in select( "c_EntidadesDesactivables" )
			use in select( "c_completaventas" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarEsquemas() as Void
		local lcCursor as String, lcTabla as String, lnLargoPrefijoAuditoria as Number, ;
			lcTablaAObtenerEsquema as String, lcUbicacion as String
		lcCursor = sys(2015)

		select distinct a.tabla, b.ubicaciondb ubicacion ;
		from c_Diccionario a ;
		inner join c_Entidad b on alltrim( upper( a.Entidad )) == alltrim( upper( b.Entidad )) ;
		where !empty( tabla ) ;
		group by tabla, ubicacion ;
		order by tabla, ubicacion ;
		into cursor &lcCursor
		
		scan 
			lcTabla = alltrim( upper( &lcCursor..Tabla ))
			lcUbicacion = alltrim( upper( &lcCursor..Ubicacion ))
			
			lnLargoPrefijoAuditoria = len( this.cPrefijoAuditoria )
			
			if upper( alltrim( left( lcTabla, lnLargoPrefijoAuditoria ) ) ) ==  upper( alltrim( this.cPrefijoAuditoria ) )
				lcTablaAObtenerEsquema = substr( lcTabla, lnLargoPrefijoAuditoria + 1 )
			else
				lcTablaAObtenerEsquema = lcTabla
			endif
			
			lcEsquema = this.ObtenerSchema( lcTablaAObtenerEsquema, lcUbicacion )
			
			replace esquema with lcEsquema in c_Diccionario all for alltrim( upper( tabla )) == lcTabla
		endscan
		
		use in select( lcCursor )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleUnificadoDeCoprobantesAfectados() as Void
		local lcCursor as String

		lcCursor = sys( 2015 )

		select distinct a.descripcion as entidad ;
				from c_relacomprobantes b ;
				left join c_comprobantes a on a.id = b.idcomp or a.id = b.idcompafectado ;
				into cursor &lcCursor

		** busco la clave primaria para saber el tipo de dato
		select atributo, TipoDato, Longitud ;
			from c_Diccionario ;
			where alltrim( upper( entidad ) ) == alltrim( upper( "ITEMCOMPROBANTE" ) ) and ;
					ClavePrimaria ;
		into cursor c_CPEntidad
		select( lcCursor )
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Tabla, Dominio  ) values ;
				( upper( &lcCursor..Entidad ), "COMPAFEC", "Codigo", c_CPEntidad.TipoDato, c_CPEntidad.Longitud, "CompAfe", "DETALLEITEMCOMPROBANTE" )
		endscan
		use in select( "c_CPEntidad" )

		use in select( lcCursor )
	endfunc 

	* -----------------------------------------------------------------------------------------
	function AgregarMenuDeComprobantesAfectantes() as Void
		local lcCursor as String, lnId as integer, lcCursor2 as String, lcAcceso as String

		lcCursor = sys( 2015 )
		lcCursor2 = sys( 2015 )
		lnId = this.ObtenerMaximoIdDeMenu()

		select C.Descripcion as entidad ;
				from c_RelaComprobantes A ;
				left join c_Comprobantes C on A.IdComp = C.Id ;
				group by A.IdComp ;
			into cursor &lcCursor
		
		scan
			select AccesoRapido from c_MenuAltasItems ;
				where upper( alltrim( entidad ) ) == upper( alltrim( &lcCursor..Entidad ) ) ;
					and upper( alltrim( AccesoRapido ) ) == "CTRL+O" ;
				into cursor &lcCursor2

			lnId = lnId + 1
			this.InsertarOpcionDeMenuAltas( lnId, "Nuevo en base a...", iif( reccount( lcCursor2 ) > 0, "", "CTRL+O" ), ;
				"thisform.oKontroler.ejecutar('CargaNuevoEnBaseEn')", 38, 1, 11, .T., "NuevoEnBaseA", upper( &lcCursor..Entidad ), .F., "","" )
			
			use in select( lcCursor2 )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributoDeActivacionDesactivacion() as Void
		select c_EntidadesDesactivables
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Tabla, Dominio, Auditoria, MantenerEnRecepcion, Etiqueta, EtiquetaAutodescriptiva, Etiquetacorta, Tags ) values ;
				( c_EntidadesDesactivables.Entidad, "INACTIVOFW", "InactivoFW", "L", 1, c_EntidadesDesactivables.tabla, "SINOBOOL", .t., .f., "Inactivo","Inactivo","Inactivo", "<FORZARLISTARGENERICO>;<FORZARREST>" )
		endscan
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarMenuDeActivacionDesactivacion() as Void
		local lnId as Integer

		lnId = this.ObtenerMaximoIdDeMenu()

		select c_EntidadesDesactivables
		scan 
			lnId = lnId + 1
			this.InsertarOpcionDeMenuAltasActivable( lnId, "Activar", 10, .t., c_EntidadesDesactivables.Entidad, "Ctrl+Shift+A" )
			lnId = lnId + 1
			this.InsertarOpcionDeMenuAltasActivable( lnId, "Desactivar", 11, .f., c_EntidadesDesactivables.Entidad, "Ctrl+Shift+D" )
		endscan
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarMenuCompletarDesdeVentas() as Void
		local lnId as Integer

		lnId = this.ObtenerMaximoIdDeMenu()

		select c_completaventas
		scan 
			lnId = lnId + 1
			this.InsertarOpcionDeMenuAltas( lnId, "Completar desde ventas", "Ctrl+Shift+F7", "thisform.oKontroler.completarDesdeVentas()", 0, 3, 70, .f., "completardesdeventas",;
											c_completaventas.entidad , .f., "thisform.oentidad.lnuevo or thisform.oentidad.ledicion", "")		
		endscan
		use in select( "c_completaventas" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarMenuInsertarDesdeTxt() as Void
		local lnId as Integer, lcEtiqueta as String
		lnId = this.ObtenerMaximoIdDeMenu()
		select c_copiaDesdeTxt
		scan 
			lnId = lnId + 1
			lcEtiqueta = iif( upper( c_copiaDesdeTxt.entidad ) = "PICKING", "Cargar artículos controlados desde txt" , "Cargar detalle desde txt" )
			if !inlist ( alltrim ( upper ( c_copiaDesdeTxt.entidad ) ), "MOVIMIENTOSTOCKAPRODUCC", "MOVIMIENTOSTOCKDESDEPRODUCC","MOVIMIENTOSTOCKAINVENT") 
				this.InsertarOpcionDeMenuAltas( lnId, lcEtiqueta, "CTRL+SHIFT+T", "thisform.oKontroler.insertardesdetxt()", 0, 3, 97, .f., "insertardesdetxt", c_copiaDesdeTxt.entidad, .f., "", "")
			endif			
		endscan
		use in select( "c_copiaDesdeTxt" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarSeguridadDeActivacionDesactivacion() as Void
		select c_EntidadesDesactivables
		scan
			this.InsertarOpcionDeMenuAltasActivableEnSeguridadEntidades( "Activar", c_EntidadesDesactivables.Entidad )
			this.InsertarOpcionDeMenuAltasActivableEnSeguridadEntidades( "Desactivar", c_EntidadesDesactivables.Entidad )
		endscan
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function InsertarOpcionDeMenuAltasActivable( tnId as integer, tcCodigo as String, tnOrden as Integer, ;
		tlComienzaGrupo as Boolean, tcEntidad as String, tcAccesoRapido as String ) as Void
		this.InsertarOpcionDeMenuAltas( tnId, "\<" + tcCodigo, tcAccesoRapido, "thisform.oKontroler.ejecutar('" + tcCodigo + "')", ;
			0, 3, tnOrden, .F., tcCodigo, tcEntidad, tlComienzaGrupo, "thisform.lDeshabilitar" + tcCodigo, "" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function InsertarOpcionDeMenuAltasActivableEnSeguridadEntidades( tcCodigo as String, tcEntidad as String ) as Void
		insert into c_SeguridadEntidades ( entidad, operacion, DescripcionOperacion ) values ( tcEntidad, tcCodigo, tcCodigo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerMaximoIdDeMenu() as Integer
		local lcCursor as String, lnId as integer

		lcCursor = sys( 2015 )
		
		select max( Id ) as Id from c_MenuAltasItems ;
		union all ;
		select max( Id ) as Id from c_menuAltasDefault  ;
		into cursor &lcCursor
		
		select max( Id ) as Id from &lcCursor into cursor &lcCursor
			
		lnId = &lcCursor..Id 
		use in select( lcCursor )
		
		return lnId
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function InsertarOpcionDeMenuAltas( tnId as integer, tcEtiqueta as String, tcAccesoRapido as String, tcComando as String, ;
		tnIdImagen as Integer, tnIdPadre as Integer, tnOrden as Integer, tlAgregarAToolbar as Boolean, tcCodigo as String, ;
		tcEntidad as String, tlComienzaGrupo as Boolean, tcSkipFor as String, tcCondicion as String ) as Void

		insert into c_MenuAltasItems ( Id, Etiqueta, AccesoRapido, comando, idimagen, idpadre, orden, toolbar, codigo, entidad, comienzagrupo, skipfor, condicion ) values ;
			( tnId, tcEtiqueta, tcAccesoRapido, tcComando, tnIdImagen, tnIdPadre, tnOrden, tlAgregarAToolbar, tcCodigo, tcEntidad, tlComienzaGrupo, tcSkipFor, tcCondicion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosGenericosEntidades() as void
		local llEsSoloLectura as Boolean

		llEsSoloLectura = .f.

		** Atributos para actualizar
		select distinct d1.entidad, agen1.* ;
			from c_AtributosGenericos Agen1 ;
					inner join c_diccionario d1 on alltrim( upper( Agen1.Atributo ) ) == alltrim( upper( d1.atributo ) ) ;
					inner join c_entidad e on alltrim( upper( d1.entidad ) ) == alltrim( upper( e.Entidad ) )  ;
			where ( e.Tipo = "E" and atc( "E", agen1.tipo ) > 0 ) or ( e.Tipo = "I" and atc( "I", agen1.tipo ) > 0 ) ;
		into cursor c_AtribGenParaActualizar

		select c_AtribGenParaActualizar

		scan
			update c_diccionario set Campo = c_AtribGenParaActualizar.Campo, ;
									TipoDato = c_AtribGenParaActualizar.TipoDato, ;
									Longitud = c_AtribGenParaActualizar.Longitud, ;
									Decimales = c_AtribGenParaActualizar.Decimales, ;
									MantenerEnRecepcion = c_AtribGenParaActualizar.MantenerEnRecepcion, ;
									Etiqueta = iif( empty( Etiqueta ), c_AtribGenParaActualizar.Etiqueta, Etiqueta ), ;
									EtiquetaCorta = iif( empty( EtiquetaCorta ), c_AtribGenParaActualizar.EtiquetaCorta, EtiquetaCorta ), ;
									Tags = alltrim( Tags ) + iif( empty( alltrim( Tags) ), "", ";" ) + alltrim( c_AtribGenParaActualizar.Tags ), ;
									Atributo = c_AtribGenParaActualizar.Atributo ;
				where alltrim( upper( atributo ) ) == alltrim( upper( c_AtribGenParaActualizar.Atributo ) ) and ;
					alltrim( upper( entidad ) ) == alltrim( upper( c_AtribGenParaActualizar.entidad ) )
		endscan

		use in select( "c_AtribGenParaActualizar" )

		** Atributos para agregar
		select distinct d1.entidad, agen1.*, ( select Tabla from c_diccionario d3 where d3.entidad == d1.entidad and claveprimaria ) as tabla ;
			from c_AtributosGenericos Agen1, c_diccionario d1 inner join c_entidad e on alltrim( upper( d1.entidad ) ) == alltrim( upper( e.Entidad ) )  ;
			where e.Tipo = "E" and atc( "E", agen1.tipo ) > 0 and ;
				alltrim( upper( agen1.atributo ) ) not in ( select alltrim( upper( d2.atributo ) ) ;
															from c_diccionario d2 inner join c_AtributosGenericos agen2 on alltrim( upper( d2.atributo ) ) == alltrim( upper( agen2.atributo ) ) ;
															where atc( "E", agen2.tipo ) > 0 and d2.entidad = d1.entidad );
		union( ;
			select distinct d1.entidad, agen1.*, ( select Tabla from c_diccionario d3 where d3.entidad == d1.entidad and claveprimaria ) as tablaAux ;
				from c_AtributosGenericos Agen1, c_diccionario d1 inner join c_entidad e on alltrim( upper( d1.entidad ) ) == alltrim( upper( e.Entidad ) )  ;
				where e.Tipo = "I" and atc( "I", agen1.tipo ) > 0 and ;
					alltrim( upper( agen1.atributo ) ) not in ( select alltrim( upper( d2.atributo ) ) ;
																from c_diccionario d2 inner join c_AtributosGenericos agen2 on alltrim( upper( d2.atributo ) ) == alltrim( upper( agen2.atributo ) ) ;
																where atc( "I", agen2.tipo ) > 0 and d2.entidad = d1.entidad ) ;
				having !empty( tablaAux ) ;
			) ;
		into cursor c_AtribGenParaAgregar readwrite

		update c_AtribGenParaAgregar set tags = alltrim(tags) + ";<QUITAR>" where alltrim( upper( entidad ) ) in ( select alltrim( upper( e.entidad) ) from c_entidad as e where this.oFunc.Tienefuncionalidad("SINATRIBUTOSFW", e.Funcionalidades ) ) and !inlist( alltrim(upper( atributo ) ),"FECHAMODIFICACIONFW","HORAMODIFICACIONFW")
		select c_AtribGenParaAgregar
		
		scan
			if atc( "I", c_AtribGenParaAgregar.Tipo ) > 0
				llEsSoloLectura = this.EsDetalleSoloLectura( c_AtribGenParaAgregar.Entidad )
			endif
			
			insert into c_diccionario ;
				( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio, Ajustable, SaltoCampo, MantenerEnRecepcion, Tags, ;
				Etiqueta, EtiquetaCorta ) values ;
				( 	upper( c_AtribGenParaAgregar.Entidad ), ;
					upper( c_AtribGenParaAgregar.Atributo ), ;
					upper( c_AtribGenParaAgregar.Campo ), ;
					upper( c_AtribGenParaAgregar.TipoDato ), ;
					c_AtribGenParaAgregar.Longitud, ;
					c_AtribGenParaAgregar.Decimales, ;
					c_AtribGenParaAgregar.tablaAux, ;
					icase( upper( c_AtribGenParaAgregar.TipoDato ) = "D", "FECHA", upper( c_AtribGenParaAgregar.TipoDato ) = "L", "SINOBOOL", upper( c_AtribGenParaAgregar.TipoDato ) = "N", "NUMERICO", "CARACTER" ), ;
					iif( atc( "I", c_AtribGenParaAgregar.Tipo ) > 0, .t., .f. ), ;
 					llEsSoloLectura, c_AtribGenParaAgregar.MantenerEnRecepcion, c_AtribGenParaAgregar.Tags, c_AtribGenParaAgregar.Etiqueta, ;
 					c_AtribGenParaAgregar.EtiquetaCorta )					
					
			llEsSoloLectura = .f.
		endscan

		use in select( "c_AtribGenParaAgregar" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsDetalleSoloLectura( tcDetalle as String ) as boolean
		local llRetorno as Boolean, lcCursor as String  
		
		llRetorno = .F.		
		lcCursor = sys(2015)
		select atributo ;
			from c_diccionario ;
			where upper( alltrim( entidad )) = upper(alltrim( tcDetalle )) and !saltocampo ;
			into cursor &lcCursor
			
		if reccount( lcCursor ) = 0
			llRetorno = .T.
		endif 
		use in select( lcCursor ) 

		return	llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributoGuid() as void
		
		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper( alltrim( Est.tabla ) ) tabla ;
			from c_Diccionario Est, c_entidad Ent ;
			where alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) and !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "E" and "G" $ Ent.Comportamiento and est.claveprimaria;
			into cursor c_EntidadesGuid

		select c_EntidadesGuid
		scan

			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio, ValorSugerido, Dominio ) values ;
				( upper( c_EntidadesGuid.Entidad ), "GUID", "GUID", "C", 38, 0, upper( c_EntidadesGuid.Tabla ), "CARACTER", "=iif(.VerificarContexto( 'CB' ),.Guid,goLibrerias.ObtenerGuid())" , "CARACTER" )
		endscan
		use in select ( "c_EntidadesGuid" )

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributoTimeStamp() as void
		
		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
			from c_Diccionario Est, c_entidad Ent ;
			where alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) and !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "E" and "T" $ Ent.Comportamiento and est.claveprimaria;
			into cursor c_EntidadesTimeStamp

		select c_EntidadesTimeStamp
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio, tags ) values ;
				( upper( c_EntidadesTimeStamp.Entidad ), "TIMESTAMP", "TIMESTAMP", "N", 20, 0, upper( c_EntidadesTimeStamp.Tabla ), "NUMERICO", "<ATRIBUTOANULACION>" )
		endscan
		use in select ( "c_EntidadesTimeStamp" )

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarAtributoMantenerenRecepcion() as void
		
		select c_diccionario
		update c_diccionario set mantenerenrecepcion = .f. where "<NOMANTENERENRECEPCION>" $ upper(c_diccionario.tags)

	endfunc
    
    *-----------------------------------------------------------------------------------------
    protected function AgregarAtributoOcultarNodoExportacion() as void

        select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
            from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) ;
            where !empty( Est.tabla ) and ;
            alltrim( upper( ent.tipo ) ) == "E" and this.oFunc.Tienefuncionalidad("OCULTARNODOEXPO", Ent.Funcionalidades ) and est.claveprimaria;
            into cursor c_EntidadesRegistroModificable

        select c_EntidadesRegistroModificable
        scan
            insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
                ( upper( c_EntidadesRegistroModificable.Entidad ), "OCULTARNODOEXPO", "SINNODO", "L", 1, 0, upper( c_EntidadesRegistroModificable.Tabla ), "SINOBOOL" )
        endscan
        
        select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
            from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.dominio ) ) == "DETALLE" + alltrim( upper( ent.entidad ) ) ;
                inner join c_EntidadesRegistroModificable b on alltrim( upper( est.entidad ) ) == alltrim( upper( b.entidad ) ) ;
            where !empty( Est.tabla ) and ;
            alltrim( upper( ent.tipo ) ) == "I";
            into cursor c_EntidadesRegistroModificable

        select c_EntidadesRegistroModificable
        scan
            insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
                ( upper( c_EntidadesRegistroModificable.Entidad ), "OCULTARNODOEXPO", "SINNODO", "L", 1, 0, upper( c_EntidadesRegistroModificable.Tabla ), "SINOBOOL" ) 
        endscan
                
        use in select ( "c_EntidadesRegistroModificable" )

    endfunc
	

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributoBloquearRegistro() as void

		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
			from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) ;
			where !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "E" and this.oFunc.Tienefuncionalidad("BLOQUEARREGISTRO", Ent.Funcionalidades ) and est.claveprimaria;
			into cursor c_EntidadesRegistroModificable

		select c_EntidadesRegistroModificable
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
				( upper( c_EntidadesRegistroModificable.Entidad ), "BLOQUEARREGISTRO", "BLOQREG", "L", 1, 0, upper( c_EntidadesRegistroModificable.Tabla ), "SINOBOOL" )
		endscan
		
		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
			from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.dominio ) ) == "DETALLE" + alltrim( upper( ent.entidad ) ) ;
				inner join c_EntidadesRegistroModificable b on alltrim( upper( est.entidad ) ) == alltrim( upper( b.entidad ) ) ;
			where !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "I" ;
			into cursor c_EntidadesRegistroModificable

		select c_EntidadesRegistroModificable
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
				( upper( c_EntidadesRegistroModificable.Entidad ), "BLOQUEARREGISTRO", "BLOQREG", "L", 1, 0, upper( c_EntidadesRegistroModificable.Tabla ), "SINOBOOL" )
		endscan
				
		use in select ( "c_EntidadesRegistroModificable" )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosCAI() as void
		select distinct upper( alltrim( Ent.Entidad ) ) as Entidad, upper(alltrim(Est.tabla)) tabla ;
			from c_Diccionario Est inner join c_entidad Ent on alltrim( upper( est.entidad ) ) == alltrim( upper( ent.entidad ) ) ;
			where !empty( Est.tabla ) and ;
			alltrim( upper( ent.tipo ) ) == "E" and this.oFunc.TieneFuncionalidad( "CAI" , Ent.Funcionalidades ) and est.claveprimaria;
			into cursor c_EntidadesConCAI

		select c_EntidadesConCAI
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
				( upper( c_EntidadesConCAI.Entidad ), "CAI", "CAI", "N", 14, 0, upper( c_EntidadesConCAI.Tabla ), "NUMERICO" )
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
				( upper( c_EntidadesConCAI.Entidad ), "FechaVToCAI", "VtoCAI", "D", 8, 0, upper( c_EntidadesConCAI.Tabla ), "FECHA" )
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Decimales, Tabla, Dominio ) values ;
				( upper( c_EntidadesConCAI.Entidad ), "CodigoBarraAutoImpresor", "CBAutoImp", "C", 40, 0, upper( c_EntidadesConCAI.Tabla ), "CARACTER" )

		endscan

		use in select ( "c_EntidadesConCAI" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdTransferenciaAgrupada( tcTransferencia as String, tlForzarCargaAuditoria as Boolean ) as Integer 
		local lnRetorno as Integer 
		lnRetorno = 0	
		
		if this.DebeGenerarTransferencias()
			select c_transferenciasAgrupadas
			locate for upper( alltrim( descripcion ) ) == upper( tcTransferencia)
			if found()
				lnRetorno = c_transferenciasAgrupadas.id
			else
				if tlForzarCargaAuditoria 	
					calculate max( id ) to lnRetorno
					lnRetorno = lnRetorno + 1

					insert into c_transferenciasAgrupadas ( id, descripcion ) values ( lnRetorno, tcTransferencia )
				endif
			endif
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorDeEntidadesConAuditoria() as String
		local lcCursor as String
		lcCursor = sys( 2015 )
		select ( "c_Entidad" )
		select * from c_entidad where this.oFunc.TieneFuncionalidad( "AUDITORIA", Funcionalidades ) and Tipo = 'E' into cursor ( lcCursor )
		return lcCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeEntidadesConAuditoria() as Integer
		local lcCursor as String, lnHayAuditoria as Integer

		if this.nCantidadDeEntidadesConAuditoria = -1
			lcCursor = sys( 2015 )
			select ( "c_Entidad" )
			count for this.oFunc.TieneFuncionalidad( "AUDITORIA", Funcionalidades ) and Tipo = 'E' to lnHayAuditoria
			
			this.nCantidadDeEntidadesConAuditoria = lnHayAuditoria
		endif			
		return this.nCantidadDeEntidadesConAuditoria
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected Function AgregarDatosAuditoria() as Void
		local lcUbicacionTabla as String , lcCursor as String, lcIdListado as string, llPrimeraAuditoria as Boolean, lnAgrupadaAuditoria as Integer,;
		 lnAgrupadaResumen as Integer, lnAgrupadaCompra as Integer, lnAgrupadaVenta as Integer 
		
		llPrimeraAuditoria = .T.
		lnAgrupadaAuditoria = 0
		lnAgrupadaResumen = 0
		lnAgrupadaCompra = 0
		lnAgrupadaVenta = 0
		lcIdListado = ""
		
		lcCursor = this.ObtenerCursorDeEntidadesConAuditoria()

		This.AgregarListadoAuditoriaNodo()

		if reccount( lcCursor ) > 0
			lnAgrupadaResumen = this.ObtenerIdTransferenciaAgrupada( "RESUMEN DEL DÍA" )
			lnAgrupadaCompra = this.ObtenerIdTransferenciaAgrupada( "RESUMEN DE COMPRAS DIARIO" )
			lnAgrupadaVenta = this.ObtenerIdTransferenciaAgrupada( "RESUMEN DE VENTAS DIARIO" )
			lnAgrupadaAuditoria  = this.ObtenerIdTransferenciaAgrupada( "AUDITORIAS", .T. )
		endif		
		select( lcCursor )

		scan all  

			lcUbicacionTabla = iif( empty( &lcCursor..ubicaciondb ), "sucursal", lower( &lcCursor..ubicaciondb ) )

			This.AgregarAuditoriaEntidad( &lcCursor..Entidad, lcUbicacionTabla, &lcCursor..Descripcion, &lcCursor..Identificador )
			This.AgregarAuditoriaAtributos( &lcCursor..Entidad )

			if this.DebeGenerarListadosAuditoria( &lcCursor..Entidad )
				lcIdListado = This.AgregarListadoAuditoriaCabecera( lcCursor )
				This.nOrdenListadoAuditoria = This.nOrdenListadoAuditoria + 1
				This.AgregarListadoAuditoriaDetalle( &lcCursor..Entidad, lcIdListado )			
			endif 

			*****Transferencia de auditorias
			this.AgregarTransferenciaFiltrosAuditoria( &lcCursor..Entidad )

			insert into c_transferenciasagrupadasitems ( id, entidad, tipo ) values ( lnAgrupadaAuditoria, .ObtenerNombreEntidadAuditoria( &lcCursor..Entidad ) , "C" )

			if !empty( lnAgrupadaCompra )
				insert into c_transferenciasagrupadasitems ( id, entidad, tipo ) values ( lnAgrupadaCompra, .ObtenerNombreEntidadAuditoria( &lcCursor..Entidad ) , "C" )
			endif
			
			if !empty( lnAgrupadaVenta )
				insert into c_transferenciasagrupadasitems ( id, entidad, tipo ) values ( lnAgrupadaVenta, .ObtenerNombreEntidadAuditoria( &lcCursor..Entidad ) , "C" )
			endif
			
			if !empty( lnAgrupadaResumen )
				insert into c_transferenciasagrupadasitems ( id, entidad, tipo ) values ( lnAgrupadaResumen, .ObtenerNombreEntidadAuditoria( &lcCursor..Entidad ) , "C" )
			endif
			
			this.AgregarTransferenciaFiltrosAuditoria( &lcCursor..Entidad, "A", 1 )

			select ( lcCursor )
		endscan

		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeGenerarListadosAuditoria( tcEntidad as String ) as Boolean
		return !inlist( upper( alltrim( tcEntidad ) ), "STOCKARTICULOS" )	&& No agregar el listado de auditoría de stock artículos. && Se reemplazó por el de adt_stockcombinacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarTransferenciaFiltrosAuditoria( tcEntidad as String, tcTipo as String, tnGrupo as Integer ) as Void
		local lcNombreAuditoria as String 

		if empty( tcTipo )
		 	tcTipo = ""
		endif
		if empty( tnGrupo )
		 	tnGrupo = 0
		endif
		
		with this as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg
			lcNombreAuditoria = .ObtenerNombreEntidadAuditoria( tcEntidad )
			insert into c_TransferenciasFiltros ( entidad, atributo, tipo, grupo ) values ( lcNombreAuditoria, this.cPrefijoAuditoria + "FECHA", tcTipo, tnGrupo )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function AgregarListadoAuditoriaNodo() as VOID
		local lnHayAuditoria as Integer, lnOrdenAuditoria as Integer, lnOrdenResumen as Integer, lnIdAuditoria as Integer, ;
			  lnIdResumen as Integer

		select c_Entidad
		lnHayAuditoria = this.ObtenerCantidadDeEntidadesConAuditoria()

		if lnHayAuditoria > 0
			select c_nodoslistados
			locate for upper( alltrim( NombreNodo ) ) == "AUDITORIA"
			if found()
				This.nIdPadreAuditoria = c_nodoslistados.idNodo
			else
				calculate max( orden ) to lnOrdenAuditoria
				calculate max( idNodo ) to lnIdAuditoria
				
				This.nIdPadreAuditoria = lnIdAuditoria + 1
				insert into c_nodoslistados ( idNodo, NombreNodo , Orden ) values ;
							( This.nIdPadreAuditoria , "Auditoria", lnOrdenAuditoria + 1 )
			endif
		endif
	Endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarListadoAuditoriaCabecera( tcCursor as String ) as string
		local lcModulos as String, lcId as String

		lcModulos = this.ObtenerModulosListado( tcCursor )
		lcId = "ADT_" + upper( alltrim( &tcCursor..Entidad ) )
		
		select c_Listados.id from c_Listados where alltrim( upper( c_Listados.id ) ) = lcId into cursor c_Auxiliar
		if _tally == 0
			insert into c_Listados ( id, Titulo , Orden, idNodo, Version, modulos ) values ;
					( lcId, "Auditoría de " + &tcCursor..Descripcion , This.nOrdenListadoAuditoria , This.nIdPadreAuditoria, 2, lcModulos )
		endif			
		use in c_Auxiliar
		return lcId
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulosListado( tcCursor as String ) as string
		local lcModulos as String
		
		lcModulos = this.oFunc.Obtenervalor( "MODULOSLISTADO", &tcCursor..funcionalidades  )
		return lcModulos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarListadoAuditoriaDetalle( tcEntidad as String, tcIdListado as String ) as Void
		local lnOrden as Integer, lnOrdenFiltro as Integer, lcEntidad as String, lnIdCampo as Integer, lcAtributo as String, lcEtiqueta as String, ;
				lnLongitud as Integer, llVisible as Boolean, lnOrdenFiltroEspecifico as Integer, lcTipoFiltro as string, llVisibleFiltro
		
		lnOrden = 1 
		lnOrdenFiltro = 50
		lnOrdenFiltroEspecifico = 0
		lcEntidad = This.ObtenerNombreEntidadAuditoria( tcEntidad )
		select c_Diccionario
		scan for upper( alltrim( Entidad ) ) = upper( alltrim( lcEntidad ) )
			lcTipoFiltro = ""
			lcAtributo = upper( alltrim( c_Diccionario.Atributo ) )
			lcEtiqueta = iif( !empty( c_Diccionario.EtiquetaAutodescriptiva ) , c_Diccionario.EtiquetaAutodescriptiva , c_Diccionario.Etiqueta )
			lnLongitud = 0
			llVisible = .T.

			lnOrdenFiltroEspecifico = iif( c_diccionario.alta,lnOrdenFiltro, 0 )

			do case 
				case lcAtributo == "ADT_COD"
					llVisible = .F.
					lnOrdenFiltroEspecifico = 0
				case lcAtributo == "ADT_ENT"
					llVisible = .F.
					lnOrdenFiltroEspecifico = 0
				case lcAtributo == "ADT_SERIE"
					lnLongitud = 4
				case lcAtributo == "ADT_FECHA"
					lnLongitud = 6
					lnOrdenFiltroEspecifico = 1
				case lcAtributo == "ADT_HORA"
					lnLongitud = 4
				case lcAtributo == "ADT_USR"
					lnLongitud = 9
				case lcAtributo == "ADT_COMP"
					lnLongitud = 26
				case lcAtributo == "ADT_VERS"
					lnLongitud = 7
				case lcAtributo == "ADT_ADN"
					lnLongitud = 2
				case lcAtributo == "ADT_EXT"
					llVisible = .F.
					lnLongitud = 1
					lnOrdenFiltroEspecifico = 99
					lcTipoFiltro = "SINOBOOL"
				otherwise
					if alltrim( upper( c_Diccionario.TipoDato ) ) == "L"
						lcTipoFiltro = "SINOBOOL"
					endif
			endcase
			
			select c_listCampos
			locate for upper( alltrim( c_listCampos.IdFormato ) ) == upper( alltrim( tcIdListado ) );
					and upper( alltrim( c_listCampos.Entidad ) ) == lcEntidad;
					and upper( alltrim( c_listCampos.Atributo ) ) == lcAtributo

			if !found()
				calculate max( id ) to lnIdCampo
				llVisibleFiltro = iif( lnOrdenFiltroEspecifico > 0, .t., .f. )
				insert into c_ListCampos ;
					( id, idFormato, Entidad, Atributo, Etiqueta, Orden, OrdenFiltro, TipoFiltro, EtiquetaReporte, Visible, LongitudReporte, VisibleFiltro ) ;
				Values ;
					( lnIdCampo + 1 , tcIdListado, lcEntidad, lcAtributo, lcEtiqueta, lnOrden, lnOrdenFiltroEspecifico, lcTipoFiltro, lcEtiqueta, llVisible, lnLongitud, llVisibleFiltro )
				
				lnOrden = lnOrden + 1
				lnOrdenFiltro = lnOrdenFiltro + 1
			endif
		endscan
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected Function AgregarAuditoriaEntidad( tcEntidad as String, tcUbicacion as String, tcDescripcion as String, tcIdentificadorEntidad as String ) as Void
		local lcEntidad as String, lcIdentificador as String
		lcEntidad = This.ObtenerNombreEntidadAuditoria( tcEntidad )
		lcIdentificador = This.ObtenerIdentificadorEntidadAuditoria( tcIdentificadorEntidad )
		insert into c_entidad ( Entidad, Titulo, Descripcion, Formulario, Tipo, Version, Ubicaciondb, Comportamiento, identificador ) values ;
			( lcEntidad, "Auditoria " + tcDescripcion , "Auditoria " + tcDescripcion, .f.	, "E", 2 , tcUbicacion, "C", lcIdentificador )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAuditoriaAtributos( tcEntidad as String ) as Void

		with This as GeneradorDeAdnAdicional of GeneradorDeAdnAdicional.prg
			.AgregarAuditoriaAtributosFijos( tcEntidad )
			.AgregarAuditoriaAtributosClaves( tcEntidad )			
			.AgregarAuditoriaAtributosDinamicos( tcEntidad )
		endwith

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected Function AgregarAuditoriaAtributosFijos( tcEntidad as String ) as Void
		local lcEntidad as String , lcXml as String , lcCursor as String , lcTabla as String

		lcCursor = sys( 2015 )
		lcEntidad = This.ObtenerNombreEntidadAuditoria( tcEntidad )
		lcXml = this.cXmlCamposAuditoriaEntidad
		lcTabla = this.cPrefijoAuditoria + This.ObtenerTabla( tcEntidad )

		this.xmlACursor( lcXml, lcCursor )

		select ( lcCursor )
		scan all
			select c_Diccionario
			
			insert into c_Diccionario ( Entidad , Atributo , Tabla, Campo, TipoDato, Longitud, Decimales, Dominio, ;
										ClavePrimaria, Etiqueta, BusquedaOrdenamiento, AdmiteBusqueda, MuestraRelacion, alta, tiposubgrupo, ayuda, etiquetacorta ) values ;
				( lcEntidad, &lcCursor..Campo, lcTabla, &lcCursor..Campo, &lcCursor..TipoDato, &lcCursor..Longitud, ;
				&lcCursor..Decimales, &lcCursor..Dominio, &lcCursor..espk, &lcCursor..Etiqueta, &lcCursor..BusquedaOrdenamiento, &lcCursor..AdmiteBusqueda,;
				&lcCursor..MuestraRelacion, .T., 1, ".", "." )

			select ( lcCursor )
		endscan
		
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function AgregarAuditoriaAtributosClaves( tcEntidad as String ) as Void
		local lcCursor as String, lcTipoDato as String, lnLongitud as Integer, lcEntidadFormateada as String, ;
				lcTablas as String, lcClaveForanea As String, lcEtiquetaClaveForanea as String, lcEtiquetaClaveForaneaCorta as String
		lcCursor = sys( 2015 )
		lcEntidadFormateada = This.ObtenerNombreEntidadAuditoria( tcEntidad )
		lcTabla = this.cPrefijoAuditoria + This.ObtenerTabla( tcEntidad )

		select d.* from c_diccionario d ;
			where upper( alltrim( d.entidad ) ) == upper( alltrim( tcEntidad ) ) and ( claveprimaria or !empty( claveCandidata ) ) ;
			into cursor ( lcCursor )
		
		select( lcCursor )
		scan
			if alltrim( &lcCursor..TipoDato ) == "A"
				lcTipoDato = "N"
				lnLongitud = 9
			else
				lcTipoDato = &lcCursor..TipoDato
				lnLongitud = &lcCursor..Longitud
			endif

			if &lcCursor..ClavePrimaria
				lcClaveForanea = tcEntidad
			else
				lcClaveForanea = &lcCursor..ClaveForanea
			endif

			if !empty( lcClaveForanea ) and inlist( alltrim( upper( &lcCursor..Etiqueta ) ), "CODIGO", "CÓDIGO")
				select c_entidad
				locate for alltrim( upper( c_entidad.entidad ) )== alltrim( upper( lcClaveForanea ) )

				if found()
					lcEtiquetaClaveForanea = alltrim( c_entidad.titulo )
					lcEtiquetaClaveForaneaCorta = alltrim( c_entidad.titulo )
					lcEtiquetaAutodescriptivaClaveForanea = alltrim( c_entidad.titulo )
				endif
			else
				lcEtiquetaClaveForanea      = &lcCursor..Etiqueta
				lcEtiquetaClaveForaneaCorta = &lcCursor..EtiquetaCorta
				lcEtiquetaAutodescriptivaClaveForanea = &lcCursor..EtiquetaAutodescriptiva
			endif
			
			lcEtiquetaAutodescriptivaClaveForanea = lcEtiquetaAutodescriptivaClaveForanea

			select c_Diccionario

			lcEtiquetaAutoDescriptiva = alltrim( &lcCursor..EtiquetaAutodescriptiva )
			if empty( lcEtiquetaAutoDescriptiva )
				lcEtiquetaAutoDescriptiva = alltrim( &lcCursor..Etiqueta )
			endif

			insert into c_Diccionario ( Entidad , Atributo , Tabla, Campo, TipoDato, Longitud, Decimales, Dominio, Etiqueta, EtiquetaAutodescriptiva, EtiquetaCorta,; 
					     ClaveForanea, alta, tiposubgrupo, ayuda, etiquetacorta ) values ;
				( lcEntidadFormateada, &lcCursor..Atributo, lcTabla, &lcCursor..Campo, lcTipoDato, lnLongitud, &lcCursor..Decimales, &lcCursor..Dominio, ;
						lcEtiquetaClaveForanea, lcEtiquetaAutodescriptivaClaveForanea, lcEtiquetaClaveForaneaCorta, lcClaveForanea, &lcCursor..alta, 1, ".", "." )

		endscan
		
		use in select( lcCursor )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAuditoriaAtributosDinamicos( tcEntidad as String ) as Void
		local lcCursor as String, lcEntidadFormateada as String , lcTabla as String

		lcCursor = sys( 2015 )

		lcEntidadFormateada = This.ObtenerNombreEntidadAuditoria( tcEntidad )
		lcTabla = this.cPrefijoAuditoria + This.ObtenerTabla( tcEntidad )
		
		select d.* from c_diccionario d ;
			where upper( alltrim( d.entidad ) ) == upper( alltrim( tcEntidad ) ) and auditoria and not( claveprimaria or !empty( claveCandidata ) ) ;
			into cursor ( lcCursor )

		select( lcCursor )
		scan 
			select c_Diccionario
			lcEtiquetaAutoDescriptiva = alltrim( &lcCursor..EtiquetaAutodescriptiva )
			if empty( lcEtiquetaAutoDescriptiva )
				lcEtiquetaAutoDescriptiva = alltrim( &lcCursor..Etiqueta )
			endif
			
			insert into c_Diccionario ( Entidad , Atributo , Tabla, Campo, TipoDato, Longitud, Decimales, Dominio, Etiqueta, EtiquetaAutodescriptiva, EtiquetaCorta, ;
					ClaveForanea, alta, tiposubgrupo, DescripcionSubgrupo, ayuda, MuestraRelacion ) values ( lcEntidadFormateada, &lcCursor..Atributo, lcTabla, &lcCursor..Campo, ;
				&lcCursor..TipoDato, &lcCursor..Longitud, &lcCursor..Decimales, &lcCursor..Dominio, &lcCursor..Etiqueta, lcEtiquetaAutoDescriptiva, ;
				&lcCursor..EtiquetaCorta, &lcCursor..ClaveForanea, &lcCursor..alta, 1, "" , ".", &lcCursor..MuestraRelacion )

		select( lcCursor )
		endscan

		use in select( lcCursor )
				
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreEntidadAuditoria( tcEntidad as String ) as String
		return This.cPrefijoAuditoria + upper( alltrim( tcEntidad ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdentificadorEntidadAuditoria( tcIdentificadorEntidad as String ) as String
		local lcRetorno as String

		lcRetorno = 'AUD' + padl( alltrim( tcIdentificadorEntidad ), 3 )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTabla( tcEntidad as String ) as String
		local lcRetorno as String, lcSql as string
		
		lcSql = "select Distinct Tabla from c_Diccionario where Alltrim( upper( Entidad ) ) == '" + ;
				alltrim( upper( tcEntidad ) ) + "'" + ;
					" and !empty( atributo ) " + ;
					" and !empty( Entidad ) " + ;
					" and ClavePrimaria " + ;
				" into cursor c_Tabla "
		
		&lcSql
		lcRetorno = alltrim( upper( c_Tabla.Tabla ) )
		use in c_Tabla
		return lcRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlCamposAuditoriaEntidad() as String
		local lcRetorno as String, lcCursor as String, lcPrefijo as String
		lcCursor = sys( 2015 )
		lcPrefijo = this.cPrefijoAuditoria

		create cursor &lcCursor ( Campo C( 10 ), TipoDato C( 10 ), Dominio C( 20 ),Longitud N( 3 ), Decimales N( 2 ), esPk L, esCC L, ;
				Valor C( 254 ), Etiqueta C( 200 ) , EtiquetaReporte c( 200 ), BusquedaOrdenamiento L, AdmiteBusqueda N( 10 ), MuestraRelacion L )

		insert into &lcCursor ;
				values ( lcPrefijo + "Cod"  , "G", "CODIGO", 38 , 0, .t., .f., "goLibrerias.ObtenerGuidPk()", "Código", "Código", .T., 1, .F. )				
		insert into &lcCursor ;
				values ( lcPrefijo + "Fecha", "D", "FECHA", 8 , 0, .f., .f., "golibrerias.obtenerfechaformateada( golibrerias.obtenerfecha() )", "Fecha", "Fecha", .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Hora" , "C", "CARACTER", 8 , 0, .f., .f., "golibrerias.obtenerhora()", "Hora", "Hora", .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Serie", "C", "CARACTER", 20, 0, .f., .f., "alltrim( _screen.zoo.app.cSerie )", "Serie", "Serie" , .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Usr"  , "C", "CARACTER", 100, 0, .f., .f., "goServicios.Seguridad.cUsuarioLogueado", "Usuario", "Usuario" , .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Ent"  , "C", "CARACTER", 40, 0, .f., .f., "this.oEntidad.ObtenerNombre()", "Entidad", "Entidad"  , .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Comp" , "C", "CARACTER", 254, 0, .f., .f., "lcDescripcionFW", "Descripción", "Descripción" , .F., 0, .T. )
		insert into &lcCursor ;
				values ( lcPrefijo + "ADN"  , "C", "CARACTER", 10, 0, .f., .f., "alltrim('1.00')", "ADN", "ADN", .F., 0, .F. )
		insert into &lcCursor ;
				values ( lcPrefijo + "Vers" , "C", "CARACTER", 13, 0, .f., .f., "_Screen.zoo.app.obtenerversion()", "Versión", "Versión" , .F., 0, .F. )	
		insert into &lcCursor ;
				values ( lcPrefijo + "Ext" , "L", "SINOBOOL", 1, 0, .f., .f., ".F.", "Información remota", "Información remota" , .F., 0, .F. )	

		lcRetorno = this.cursorAXml( lcCursor )		
		use in select( lcCursor )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlCamposAuditoriaDetalle() as String
		local lcRetorno as String, lcCursor as String, lcPrefijo as String
		lcCursor = sys( 2015 )
		lcPrefijo = this.cPrefijoAuditoria
	
		create cursor &lcCursor ( Campo C( 10 ), TipoDato C( 10 ), Longitud N( 3 ), Decimales N( 2 ), esPk L, esCC L, valor C( 254 ), ;
				Etiqueta C( 200 ) , EtiquetaReporte c( 200 ) )
		
		insert into &lcCursor ;
				values ( lcPrefijo + "Cod" , "N", 9 , 0, .f., .f., "", "Codigo", "Codigo" )
					
		lcRetorno = this.cursorAXml( lcCursor )		
		use in select( lcCursor )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarTipoGuidEnDiccionario() as Void
		select *, iif( upper( alltrim( TipoDato ) ) == "G", .T., .F. ) as EsGuid from c_diccionario into cursor c_diccionario readwrite
		update c_diccionario set TipoDato = "C" where upper( alltrim( TipoDato ) ) == "G"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSchema( tcTabla as String, tcUbicacion as String ) as Void
		local lcRetorno as String, lcCursor
		
		lcCursor = sys(2015)

		select esquema from c_diccionario ;
			where alltrim( upper( tabla )) == tcTabla and !empty(esquema) ;
			group by tabla into cursor &lcCursor
		
		lcRetorno = &lcCursor..Esquema
			
		if empty( lcRetorno )
			if !( empty( tcUbicacion ) or alltrim( upper( tcUbicacion ) ) == "SUCURSAL" )
				lcRetorno = alltrim( upper( tcUbicacion ) )
			else
				lcRetorno = this.cSchemaDefault
			endif
		endif
		
		use in ( lcCursor )
		return alltrim( lcRetorno )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function cSchemaDefault_Access() as string
		if !this.lDestroy and empty( this.cSchemaDefault ) and pemstatus( _screen, "zoo", 5 ) 
			if !isnull( _screen.zoo ) and pemstatus( _screen.zoo, "app", 5 ) and !isnull( _screen.zoo.app )
				this.cSchemaDefault = _screen.zoo.app.cSchemaDefault
			endif
		endif
		return this.cSchemaDefault
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarFormatoDescripcion() as Void
		select d.* ;
			from c_diccionario d inner join c_entidad e on alltrim( upper( d.Entidad ) ) == alltrim( upper( e.entidad ) ) ;
			where !empty( e.FormatoDescripcion ) and d.ClavePrimaria ;
			into cursor c_TmpFormatoDescripcion

		scan 
			insert into c_diccionario ( entidad, atributo, tabla, campo, TipoDato, Longitud, Dominio, alta, esquema ) values ;
				( c_TmpFormatoDescripcion.Entidad, "DescripcionFW", c_TmpFormatoDescripcion.Tabla, "DescFW", "C", 200, "CARACTER", ;
				.f., c_TmpFormatoDescripcion.Esquema )
		endscan
		
		use in select( "c_TmpFormatoDescripcion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarTransferenciasNovedades() as Void
		local lnIdTransferencias as Number, lcTipoDeTransferencias as String

		if this.DebeGenerarTransferencias()
			select distinct upper( alltrim( Entidad ) ) as Entidad ;
				from c_Entidad  ;
				where alltrim( upper( tipo ) ) == "E" and this.oFunc.Tienefuncionalidad( "TRANSFERALTAS", Funcionalidades ) ;
				into cursor c_EntidadesNovedades


			select id from c_TRANSFERENCIASAGRUPADAS where upper( alltrim( descripcion ) ) = "ALTAS Y ALTAS DE CONFIGURACIÓN" ;
			into cursor "c_TransAgrup"

			if _tally > 0
				lnIdTransferencias = c_TransAgrup.id

				lcTipoDeTransferencias = "B"
				select c_EntidadesNovedades
				scan
					insert into c_TRANSFERENCIASAGRUPADASITEMS ( id , entidad , Tipo ) ;
					values ( lnIdTransferencias , c_EntidadesNovedades.Entidad , upper( alltrim( lcTipoDeTransferencias ) ) )
				endscan
			endif
				
			use in select( "c_EntidadesNovedades" )
			use in select( "c_TransAgrup" )
		endif
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function CursorAXML( tcNombreCursor) as String
		Local lcRetorno as String
		
		cursortoxml(tcNombreCursor,"lcRetorno", 3, 4, 0, "1")
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function XmlACursor( tcXml as String, tcNombreCursor as String ) as Void
		xmltocursor( tcXml, tcNombreCursor, 4 ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarGeneradoresDeAdnAdicional() as Void
		This.InicializarGeneradores()
		for each loGenerador in this.oGeneradoresAdicionales
			loGenerador.Procesar()
		endfor

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleGenericoDeCoprobantesAfectados() as Void
		local lcCursor as String

		lcCursor = sys( 2015 )
		select distinct entidad ;
				from c_entidad  ;
				where "<INFOADICIONAL>" $ upper(funcionalidades);
				into cursor &lcCursor

		** busco la clave primaria para saber el tipo de dato
		select atributo, TipoDato, Longitud ;
			from c_Diccionario ;
			where alltrim( upper( entidad ) ) == alltrim( upper( "ITEMCOMPROBANTE" ) ) and ;
					ClavePrimaria ;
		into cursor c_CPEntidad
		select( lcCursor )
		scan
			insert into c_Diccionario ( Entidad, Atributo, Campo, TipoDato, Longitud, Tabla, Dominio  ) values ;
				( upper( &lcCursor..Entidad ), "COMPAFEC", "Codigo", c_CPEntidad.TipoDato, c_CPEntidad.Longitud, "CompAfe", "DETALLEITEMCOMPROBANTE" )
		endscan
		use in select( "c_CPEntidad" )

		use in select( lcCursor )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleGenericoDeAgrupamientoPublicaciones() as Void
		local lcCursorEntConTag as String, lcCurAtributoDetalle as String, lcCurItemsGenericos as String,;
			  lcCurEntidad as String, lcReferenciaATablaFiltroDePublicaciones as String
		
		lcCursorEntConTag = sys( 2015 )
		lcCurAtributoDetalle = sys( 2015 )
		lcCurItemsGenericos = sys( 2015 )
		lcCurEntidad = sys( 2015 )

		select distinct ent.entidad, dic.tabla, ent.identificador, dic.esquema, dic.tipodato, dic.longitud, dic.ClavePrimaria ;
				from c_entidad ent  ;
				left join c_diccionario dic on alltrim( upper( ent.entidad ) ) == alltrim( upper( dic.entidad ) ) ;
				where "<PUBLICA>" $ upper(funcionalidades) and !empty( dic.tabla ) and dic.ClavePrimaria;
				into cursor &lcCursorEntConTag

		select dic.* ;
			from c_Diccionario dic ;
			where (alltrim( upper( dic.entidad ) ) = "AGRUPAMIENTOPUBLICACIONES" and ; 
				alltrim( upper( dic.ATRIBUTO ) ) = "AGRUPUBLIDETALLE") ;
		into cursor &lcCurAtributoDetalle

		select dic.* ;
			from c_Diccionario dic ;
			where alltrim( upper( dic.entidad ) ) == "ITEMAGRUPAPUBLIC" ;
		into cursor &lcCurItemsGenericos

		select * from c_Entidad where alltrim( upper( entidad ) ) == "ITEMAGRUPAPUBLIC" ;
		into cursor &lcCurEntidad
		
		select( lcCursorEntConTag )
		scan
			lcReferenciaATablaFiltroDePublicaciones = "AgruPub" + alltrim( upper( &lcCursorEntConTag..Identificador ) )
			
			*Primero va el atributo de la referencia del detalle en la cabecera
			select &lcCurAtributoDetalle
			scatter memvar memo
			select c_diccionario
			append blank
			gather memvar memo
			replace c_diccionario.Entidad with upper( &lcCursorEntConTag..Entidad ) in c_diccionario
			replace c_diccionario.Atributo with &lcCurAtributoDetalle..Atributo in c_diccionario
			replace c_diccionario.Tabla with lcReferenciaATablaFiltroDePublicaciones in c_diccionario
			replace c_diccionario.Dominio with alltrim( &lcCurAtributoDetalle..Dominio ) + alltrim( upper( &lcCursorEntConTag..Identificador ) ) in c_diccionario
			replace c_Diccionario.Alta with .F. in c_Diccionario
			replace c_Diccionario.tags with alltrim(c_Diccionario.tags) + "<NOLISTAGENERICO>" in c_Diccionario
			replace c_Diccionario.TipoDato with &lcCursorEntConTag..TipoDato in c_Diccionario
			replace c_Diccionario.Longitud with &lcCursorEntConTag..Longitud in c_Diccionario



			*Inserto atributo para persistencia de la posicion del valor seleccionado en el combo de la toolbar.
			insert into c_diccionario (Entidad, Atributo, Tabla, Campo, TipoDato, Longitud, Dominio, Esquema, Tags ) values ;
				( upper( &lcCursorEntConTag..Entidad ), "tipoagrupamientopublicaciones", &lcCursorEntConTag..Tabla, "tipagrupub", "N", 1, "NUMERICO", &lcCursorEntConTag..Esquema, "<FORZARREST>" )
			
			*Agrego al cursor Entidad el item
			select &lcCurEntidad
			scatter memvar memo
			select c_Entidad
			append blank in c_Entidad
			gather memvar memo
			replace c_Entidad.Entidad with alltrim( upper( &lcCurEntidad..Entidad ) ) + alltrim( upper( &lcCursorEntConTag..Identificador ) ) in c_Entidad
			replace c_Entidad.Descripcion with alltrim( &lcCurEntidad..Descripcion ) + " de " + alltrim( &lcCursorEntConTag..Entidad ) in c_Entidad
			replace c_Entidad.Titulo with alltrim( &lcCurEntidad..Descripcion ) + " de " + alltrim( &lcCursorEntConTag..Entidad ) in c_Entidad
			replace c_Entidad.Funcionalidades with alltrim( &lcCurEntidad..Funcionalidades ) + "<NOLISTAGENERICO>" in c_Entidad

			*Agrego el Dominio de este nuevo detalle a la tabla dominio
			insert into c_dominio (Dominio, Detalle) values ( alltrim( &lcCurAtributoDetalle..Dominio ) + alltrim( upper( &lcCursorEntConTag..Identificador ) ), .T. )
			
			*Agrego los atributos del item
			select ( lcCurItemsGenericos )
			scan
				scatter memvar memo
				select c_Diccionario
				append blank in c_Diccionario
				gather memvar memo
				replace c_Diccionario.Entidad with alltrim( &lcCurItemsGenericos..Entidad ) + alltrim( upper( &lcCursorEntConTag..Identificador ) ) in c_Diccionario
				replace c_Diccionario.Tabla with "AgruPub" + alltrim( upper( &lcCursorEntConTag..Identificador ) ) in c_Diccionario
				if alltrim( upper( &lcCurItemsGenericos..Atributo ) ) = 'CODIGO' and alltrim( upper( &lcCursorEntConTag..Entidad ) ) != "MINIMOREPOSICION"
					replace c_Diccionario.TipoDato with &lcCursorEntConTag..TipoDato in c_Diccionario
					replace c_Diccionario.Longitud with &lcCursorEntConTag..Longitud in c_Diccionario
				endif
				replace c_Diccionario.Alta with .F. in c_Diccionario
			endscan
		endscan

		use in select( lcCursorEntConTag )
		use in select( lcCurAtributoDetalle )
		use in select( lcCurItemsGenericos )
		use in select( lcCurEntidad )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarListados() as Void
		
		this.oGeneradorDeAdnAdicionalListadosGenericos.cProyectoActivo = upper( alltrim( this.cProyectoActivo ) )
		if pemstatus(_screen, "oRegimenSimplificadoDeADNAdicionalDesdeFormularioTaspein", 5 ) and vartype( _Screen.oRegimenSimplificadoDeADNAdicionalDesdeFormularioTaspein ) = "O"	
			_Screen.RemoveObject( "oRegimenSimplificadoDeADNAdicionalDesdeFormularioTaspein" )
			&& Solo la tabla Listados.dbf, excluye la definición de los listados ListCampos.dbf
			this.oGeneradorDeAdnAdicionalListadosGenericos.AgregarListadosGenericos( .t. ) 
		else
			this.oGeneradorDeAdnAdicionalListadosGenericos.AgregarListadosGenericos()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InformarProceso( tcMensaje as Integer ) as Void
		local lcMensaje as String
		lcMensaje = "Generando ADN Adicional: " + tcMensaje + " (" + transform( datetime() ) + ")"
		this.Informar( lcMensaje )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Informar( tcMensaje as Integer ) as Void
		&& Bindear para obtener avances
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAccionesDeMenuDeComprobantesAfectantes() as Void
		local lcCursor as String, lnId as integer, lnOrden as Integer, lnIdCompA as Integer, lcCursor1 as String

		lcCursor1 = sys( 2015 )
		lcCursor = sys( 2015 )
		lnId = this.ObtenerMaximoIdDeMenu()
		lnOrden = 0
		lnIdcompA = 0
		select A.IdCompAfectado, A.IdComp, C.Descripcion as Entidad, space(100) as Descripcion, space(100) as EntAfectada, M.orden, m.Idpadre  ;
			from c_RelaComprobantes A ;
			left join c_Comprobantes C on A.idComp = C.Id ;
			left join c_menuprincipalitems M on upper(alltrim(C.Descripcion)) = alltrim(upper(m.entidad ));
			order by IdCompAfectado asc, idpadre, Orden asc ;
		into cursor &lcCursor readwrite
		
		
		select C.id, E.Descripcion as Descripcion, C.Descripcion as Entidad;
			from c_Comprobantes C ;
			inner join c_Entidad E on upper( alltrim( C.Descripcion ) ) == upper( alltrim( E.Entidad ) ) ;
			into cursor &lcCursor1 readwrite
		index on Id tag IndId
		
		select &lcCursor
		scan
			if seek( &lcCursor..IdComp, lcCursor1 )
				replace &lcCursor..Descripcion with &lcCursor1..Descripcion
			endif
			if seek( &lcCursor..IdcompAfectado, lcCursor1 )
				replace &lcCursor..EntAfectada with &lcCursor1..Entidad
			endif
		endscan
		
		go top in &lcCursor
		scan
			lnId = lnId + 1
			lnOrden = lnOrden + 1 
			if lnIdCompA != &lcCursor..IdCompAfectado && cambia de entidad
				lnIdCompA = &lcCursor..IdCompAfectado
				lnOrden = 1
			endif
			this.InsertarOpcionDeMenuAltas( lnId, &lcCursor..Descripcion, "", "thisform.oKontroler.GenerarComprobante( '" + alltrim( upper( &lcCursor..Entidad ) ) + "' )", 0, 7, lnOrden, .F., "AfectarComprobante"+alltrim( upper( &lcCursor..Entidad ) ), upper( &lcCursor..EntAfectada ) , .F.,;
				 "", "goServicios.Modulos.EntidadHabilitada( '" + alltrim( upper( &lcCursor..Entidad ) ) + "' ) and goServicios.Seguridad.HabilitaAccesoMenu( '" + alltrim( upper( &lcCursor..Entidad ) ) + "_NUEVOENBASEA' )" ) 
		endscan
		use in select( lcCursor )
		use in select( lcCursor1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function CrearCursorDeEntidadesParaPickearComprobante() as Void
		select entidad ;
			from c_Entidad ;
			where "PICKING" $ upper(Funcionalidades) ;
			into cursor c_PickearComprobante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarMenuPickearComprobante() as Void
		local lnId as Integer, lcEtiqueta as String
		lnId = this.ObtenerMaximoIdDeMenu()
		select c_PickearComprobante
		scan 
			lnId = lnId + 1
			lcEtiqueta = "Realizar picking"
			this.InsertarOpcionDeMenuAltas( lnId, lcEtiqueta, "CTRL+SHIFT+P", "thisform.oKontroler.GenerarPicking()", 0, 3, 98, .f., "PickearComprobante", c_PickearComprobante.entidad, .f., "", "goServicios.Modulos.EntidadHabilitada( 'PICKING' ) and goServicios.Seguridad.HabilitaAccesoMenu( 'PICKING_NUEVO' )" )		
		endscan
		use in select( "c_PickearComprobante" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarComponenteKitDeArticulos() as Void
		local loAtributos, lcSentencia as String, lcAtributo as String, lcEntidad as String, loColEntidades as Object

		loAtributos = this.ObtenerAtributosCombinacion()
		if loAtributos.Count > 0	
			lcSentencia = ""
			loColEntidades = _Screen.zoo.CrearObjeto("zoocoleccion")
			select entidad, atributo, dominio from c_diccionario where "DETALLE" = substr( upper(dominio), 1, 7 ) and alta and "<CONPARTICIPANTES>" $ tags into cursor "c_entidadesConDetalle" ReadWrite
			select "c_entidadesConDetalle"
			scan
				lcEntidad = upper(alltrim(entidad))
			
				lcDominio = strtran( alltrim ( upper( dominio ) ), "DETALLE", "")
				select atributo, alta, claveforanea from c_diccionario where alltrim( upper( entidad ) ) = alltrim( upper( lcDominio ) ) into cursor "c_atributosDetalle" ReadWrite
				
				lcSentencia = "select * from 'c_atributosDetalle' t2 where " 	
				for each lcAtributo in loAtributos
					lcAtributo = upper( lcAtributo )
					lcSentencia = lcSentencia + "( upper( atributo ) = '" + lcAtributo + "' and upper( claveforanea ) = '" + lcAtributo + "' and alta ) or "
				endfor
				lcSentencia = Substr( lcSentencia, 1, Len( lcSentencia ) - 3 ) + " into cursor '" + "c_DetallesConAtributosCombinacion" + "'"
				&lcSentencia
				
				select "c_DetallesConAtributosCombinacion"
				
				if _tally = loAtributos.Count
					if !loColEntidades.Buscar(lcEntidad )
						loColEntidades.Agregar(lcEntidad , lcEntidad )
					endif
				endif		
			endscan

			use in select ("c_entidadesConDetalle")
			use in select ("c_atributosDetalle")
			use in select ("c_DetallesConAtributosCombinacion")
					
			for each lcEntidad in loColEntidades
				select * from c_relaComponente where upper(componente) = "KITDEARTICULOS" and upper(entidad) = lcEntidad into cursor "temp"
				if _tally = 0
					insert into c_relacomponente( Entidad, Componente ) values ( lcEntidad, "KITDEARTICULOS" )
				endif
			endfor
			use in select ("temp")		
		endif
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosCombinacion() as Void
		local loCampos as zoocoleccion OF zoocoleccion.prg 
		loCampos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with this		
			use in select( "c_Atributo" )
			select * ;
				from c_Diccionario ;
				where upper( alltrim( Entidad ) ) == "ITEMARTICULOSVENTAS" ;
				order by clavecandidata;
				into cursor c_Atributo		
			select c_Atributo
			scan 			
				select * ;
					from c_Diccionario ;
					where upper( alltrim( Entidad ) ) == "STOCKCOMBINACION" and clavecandidata > 0 and !empty(claveforanea) and ;
					upper( alltrim( atributo ) ) == upper( alltrim( c_Atributo.Atributo ) ) ;
					into cursor c_AtributosStockCombinacion NoFilter
				
				if _tally > 0	
					loCampos.Agregar( alltrim( upper( c_Atributo.Atributo) ) )
				endif		
				select c_Atributo
			endscan
			use in select( "c_Atributo"  )
			use in select( "c_AtributosStockCombinacion" )		
		endwith	
		return loCampos 
	endfunc 


enddefine
