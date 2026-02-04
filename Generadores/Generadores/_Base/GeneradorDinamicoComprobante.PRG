define class GeneradorDinamicoComprobante as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoComprobante of GeneradorDinamicoComprobante.prg
	#endif
	
	protected oGeneradorDeFuncionesSql, cCodigosDeVentasFiscalesConValores
	cTipo = "Comprobante"
	cPrefijo = ""
	cSufijo = ""
	cCursorComprobante = ""
	oGeneradorDeFuncionesSql = null
	cCodigosDeVentasFiscalesConValores = ""
		
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		dodefault( tcRuta )
		
		this.agregarreferencia( "zoologicsa.generadorfuncionessql.dll" )
		this.oGeneradorDeFuncionesSql = _screen.zoo.crearobjeto( "zoologicsa.generadorfuncionessql.Generador" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Generar() as Void
		this.cTipo = "Componente" + proper( this.cTipo )
		
		if reccount( "c_comprobantes" ) = 0
			this.release()
		else
			dodefault( this.cTipo )	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		with this
			.AgregarLinea( "define class Din_" + .cTipo + " as ZooSession of ZooSession.prg" )
			.AgregarLinea( "oComprobantes = null", 1 )
			.AgregarLinea( "" )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		local loError as zooexception OF zooexception.prg
		with this
			try		
				.ObtenerCursorDeComprobantes()
				.AgregarFuncion_Init()
				.AgregarFuncion_ObtenerIdentificadorDeComprobante()
				.AgregarFuncion_ObtenerIdentificadorDeComprobanteSql()
				.AgregarFuncion_ObtenerNombreDeComprobanteDeVentas()
				.AgregarFuncion_ObtenerNombreDeComprobanteDeVentasSql()
				.AgregarFuncion_GenerarXmlComprobantes()
				.AgregarFuncion_ObtenerCadenaComprobantes()
				.AgregarFuncion_ObtenerEntidadDeComprobanteDeVentas()
				.AgregarFuncion_ObtenerNumeroComprobante()
				.AgregarFuncion_ObtenerNumeroComprobanteSql()
				.AgregarFuncion_ObtenerEstadoDeStockDeComprobante()
				.AgregarFuncion_ObtenerEstadosDeStock()
				.GenerarCombosXml()
				.AgregarFuncion_ObtenerCodigosDeVentasFiscalesConValores
			catch to loError
				throw loError
			finally
				use in select( This.cCursorComprobante )
			Endtry				
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerEstadoDeStockDeComprobante() as Void
		local lcCursor as String 

		lcCursor = this.cCursorComprobante

		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerEstadoDeStockDeComprobante( tcEntidad as string ) as string", 1 )
			.AgregarLinea( "Local lcRetorno as string", 2 )
			.AgregarLinea( "", 2 )
			.AgregarLinea( "lcRetorno = ''", 2 )
				
				
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					.AgregarLinea( "case upper(tcEntidad) = '" + allt( upper( DescComp ) ) + "'", 3 )
					.AgregarLinea( "lcRetorno = '" + alltrim( Stock ) + "'", 4 )
				endscan

				.AgregarLinea( "endcase", 2 )
				
				
			.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerEstadosDeStock() as Void
		local lcCursor as String, lcCursorComprobantes as String  
		
		lcCursor = sys(2015)
		lcCursorComprobantes = this.cCursorComprobante
		select distinct( stock ) as stock ;
			from  &lcCursorComprobantes  ;
			into cursor &lcCursor 
			
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerEstadosDeStock( ) as zoocoleccion", 1 )
			.AgregarLinea( "Local lcolEstados as zoocoleccion ", 2 )
			.AgregarLinea( "", 2 )
			.AgregarLinea( "lcolEstados = _screen.zoo.crearobjeto('zoocoleccion')", 2 )

				select &lcCursor
				scan 
					if !empty( alltrim( Stock ) )
						this.AgregarLinea( [lcolEstados.Agregar( "] + alltrim( Stock ) + [")], 2 )					
					endif
				endscan
				this.AgregarLinea( [lcolEstados.Agregar( "] + "EntregaPen" + [")], 2 )
				this.AgregarLinea( [lcolEstados.Agregar( "] + "CompraPen" + [")], 2 )
				
			use in select( lcCursor )		
			.AgregarLinea( "", 2 )
			.AgregarLinea( "return lcolEstados", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerNumeroComprobante() as Void
		local lcCursor as String 
		
		lcCursor = this.cCursorComprobante

		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerNumeroComprobante( tcEntidad as string ) as Integer", 1 )
			.AgregarLinea( "Local lnRetorno as integer", 2 )
			.AgregarLinea( "", 2 )
			.AgregarLinea( "lnRetorno = 0", 2 )
				
				
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					.AgregarLinea( "case upper(tcEntidad) = '" + allt( upper( DescComp ) ) + "'", 3 )
					.AgregarLinea( "lnRetorno = " + transform( Id ), 4 )
				endscan

				.AgregarLinea( "endcase", 2 )
				
				
			.AgregarLinea( "return lnRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerNumeroComprobanteSql() as Void
		local lcCursor as String, lcContenido as String
		
		lcCursor = this.cCursorComprobante
		
		this.oGeneradorDeFuncionesSql.tipo = "ESCALAR"
		this.oGeneradorDeFuncionesSql.ruta = this.cPath
		this.oGeneradorDeFuncionesSql.ubicacion = "SUCURSAL"
		this.oGeneradorDeFuncionesSql.esquema = "Funciones"
		this.oGeneradorDeFuncionesSql.nombre = "ObtenerTipoDeComprobanteAsociadoALaEntidad"
		this.oGeneradorDeFuncionesSql.parametros = "@Entidad varchar(40)"
		this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno = "numeric(2,0)"
		
		lcContenido = "declare @retorno " + this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno + chr( 13 ) + chr( 10 )
		lcContenido = lcContenido +"set @retorno = " + chr( 13 ) + chr( 10 ) 
		lcContenido = lcContenido +"case upper(@Entidad)" + chr( 13 ) + chr( 10 ) 
		
		select &lcCursor
		scan 
			lcContenido = lcContenido + "	when '" + transform( upper( alltrim( DescComp ) ) ) + "' then " + transform( Id ) + chr( 13 ) + chr( 10 ) 
		endscan
		
		lcContenido = lcContenido +"	else 0" + chr( 13 ) + chr( 10 ) 
		lcContenido = lcContenido +"end" + chr( 13 ) + chr( 10 ) 
		lcContenido = lcContenido +"return @retorno" + chr( 13 ) + chr( 10 )   			
			
		this.oGeneradorDeFuncionesSql.contenido = lcContenido
		this.oGeneradorDeFuncionesSql.Ejecutar()
	endfunc 
			
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerNombreDeComprobanteDeVentas() as Void
		This.ObtenerGenericoDeComprobanteDeVentas( "ObtenerNombreDeComprobanteDeVentas", "AgregaCaseNombreComprobante" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerEntidadDeComprobanteDeVentas() as Void
		This.ObtenerGenericoDeComprobanteDeVentas( "ObtenerEntidadDeComprobanteDeVentas", "AgregaCaseEntidadDeComprobante" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerIdentificadorDeComprobante() as Void
		This.ObtenerGenericoDeComprobanteDeVentas( "ObtenerIdentificadorDeComprobante", "AgregaCaseIdentificadorDeComprobante" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerGenericoDeComprobanteDeVentas( tcNombreMetodo as String, tcCase as String ) as Void
		local lcCase as String
		
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function " + tcNombreMetodo + "( tnTipoComprobante as integer ) as String", 1 )
			.AgregarLinea( "Local lcRetorno as String", 2 )
			.AgregarLinea( "", 2 )
			.AgregarLinea( "lcretorno = ''", 2 )
				
			lcCase = "." + tcCase + "()"
			&lcCase

			.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregaCaseNombreComprobante() as Void
		local lcCursor as String, lcComprobante as String
		
		lcCursor = This.cCursorComprobante
		
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					lcComprobante = iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
						alltrim( proper( DescEntidad ) ) )
					.AgregarLinea( "case tnTipoComprobante = " + transform( Id ), 3 )
					.AgregarLinea( "lcRetorno = '" + alltrim( proper( lcComprobante ) ) + "'", 4 )
				endscan
				.AgregarLinea( "otherwise", 3 )
				.AgregarLinea( "lcRetorno = '[' + transform( tnTipoComprobante ) + '] Comprobante Desconocido'", 4 )
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregaCaseEntidadDeComprobante() as Void
		local lcCursor as String, lcComprobante as String
		
		lcCursor = This.cCursorComprobante
		
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					lcComprobante = iif( isnull( DescComp ) or empty( DescComp ), alltrim( proper( DescEntidad ) ), ;
						alltrim( proper( DescComp ) ) )
					.AgregarLinea( "case tnTipoComprobante = " + transform( Id ), 3 )
					.AgregarLinea( "lcRetorno = '" + alltrim( proper( lcComprobante ) ) + "'", 4 )
				endscan
				.AgregarLinea( "otherwise", 3 )
				.AgregarLinea( "lcRetorno = '[' + transform( tnTipoComprobante ) + '] Comprobante Desconocido'", 4 )
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregaCaseIdentificadorDeComprobante() as Void
		local lcCursor as String, lcComprobante as String
		
		lcCursor = This.cCursorComprobante
		
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					lcComprobante = &lcCursor..Identificador
						
					.AgregarLinea( "case tnTipoComprobante = " + transform( Id ), 3 )
					.AgregarLinea( "lcRetorno = '" + alltrim( proper( lcComprobante ) ) + "'", 4 )
				endscan
				.AgregarLinea( "otherwise", 3 )
				.AgregarLinea( "lcRetorno = 'XXX'", 4 )
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_GenerarXmlComprobantes() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function GenerarXmlComprobantes()", 1 )

			.AgregarLinea( "local lcNombreCursor as String, lcComprobantesXML as String, lnPais as integer" , 2)
			.AgregarLinea( "lnPais = goparametros.nucleo.datosgenerales.pais" , 2)
			.AgregarLinea( "lcNombreCursor = 'c_' + sys( 2015 )" , 2)
			.AgregarLinea( "create cursor &lcNombreCursor( id n(4), Comprobante c(60), Entidad C(40) )" , 2)
			.AgregarLinea( "" )
			.AgregarLinea( "insert into &lcNombreCursor values( -1 , 'Todos', '')", 2 )
			.AgregarInsertDeComprobantes()
			.AgregarLinea( "" )
			.AgregarLinea( "lcComprobantesXML = this.CursorAXml( lcNombreCursor )" , 2)
			.AgregarLinea( "use in select ( lcNombreCursor )" , 2)
			.AgregarLinea( "return lcComprobantesXML" , 2)

			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertDeComprobantes() as Void
		local lcCursor as String, lcComprobante as String
		
		lcCursor = This.cCursorComprobante

		if reccount( lcCursor ) > 0
			with this

				select &lcCursor
				scan for !this.oFunc.TieneFuncionalidad("PAIS", funcionalidades ) 
				
					lcComprobante = iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
							alltrim( proper( DescEntidad ) ) )
				
					.AgregarLinea( "insert into &lcNombreCursor values( " + transform( Id ) + ", '" + alltrim( proper( lcComprobante ) ) + "', '" + upper(alltrim( DescComp )) + "')", 4 )
				endscan
					
				.AgregarLinea( "do case", 2 )
				.AgregarLinea( "case lnPais = 1", 3 )
				
				scan for this.oFunc.ObtenerValor( "PAIS", funcionalidades ) == "1"
					lcComprobante = iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
						alltrim( proper( DescEntidad ) ) )

					.AgregarLinea( "insert into &lcNombreCursor values( " + transform( Id ) + ", '" + alltrim( proper( lcComprobante ) ) + "', '" + upper(alltrim( DescComp )) + "')", 4 )
				endscan						
				
				.AgregarLinea( "case lnPais = 2", 3 )
				scan for this.oFunc.ObtenerValor( "PAIS", funcionalidades ) == "2" 
					lcComprobante = iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
						alltrim( proper( DescEntidad ) ) )
					.AgregarLinea( "insert into &lcNombreCursor values( " + transform( Id ) + ", '" + alltrim( proper( lcComprobante ) ) + "', '" + upper(alltrim( DescComp )) + "')", 4 )
				endscan	
				
				.AgregarLinea( "case lnPais = 3", 3 )
				scan for this.oFunc.ObtenerValor( "PAIS", funcionalidades ) == "3" 
					lcComprobante = iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
						alltrim( proper( DescEntidad ) ) )
					.AgregarLinea( "insert into &lcNombreCursor values( " + transform( Id ) + ", '" + alltrim( proper( lcComprobante ) ) + "', '" + upper(alltrim( DescComp )) + "')", 4 )
				endscan						
									
				.AgregarLinea( "endcase", 2 )		
			endwith
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeComprobantes() as VOID
	
		local lcCursorTest as String
		lcCursorTest = sys( 2015 )
		select B.id, D.Descripcion as DescEntidad, B.Descripcion as DescComp, D.Identificador, D.Funcionalidades, B.stock;
			from c_Comprobantes B ;
			inner join c_Entidad D on upper( alltrim( B.Descripcion ) ) == upper( alltrim( D.Entidad ) ) order by ID ;
			into cursor &lcCursorTest
	
		This.cCursorComprobante = lcCursorTest

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_Init() as Void
		this.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
		this.AgregarLinea( "function Init( t1, t2, t3, t4 ) As Boolean", 1 )
		this.AgregarLinea( "local llRetorno as boolean, loex as exception", 2 )
		this.AgregarLinea( "llRetorno = dodefault()", 2 )
		this.AgregarLinea( [this.oComprobantes = _screen.zoo.CrearObjeto( "ZooColeccion" )], 2 )
		this.AgregarLinea( "if llRetorno", 2 )
		this.AgregarCadenasAColeccion()
		this.AgregarLinea( "endif", 2 )
		this.AgregarLinea( "" )
		this.AgregarLinea( "return llRetorno", 2 )
		this.AgregarLinea( "endfunc", 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCadenasAColeccion() as Void
		local lcCompVtas as String, lcCompVtasFcl as String, lcCompVtasFclSdr as String, ;
			lcCompCmp as String, lcCompCmpFcl as String, lcCompCmpFclSdr as String, lcCursor as String, ;
			lcCompCE as String, lcTicketFiscales as string  
		
		store "" to lcCompVtas, lcCompVtasFcl, lcCompVtasFclSdr, lcCompCmp, lcCompCmpFcl, lcCompCmpFclSdr, lcCompCE
		store "" to lcTicketFiscales, lcElectronicos, lcExportacion, lcManuales
		lcCursor = this.cCursorComprobante
		select ( lcCursor )

		scan
			if this.oFunc.TieneFuncionalidad("VENTAS", funcionalidades )
				lcCompVtas = lcCompVtas + ", " + transform( &lcCursor..id )
				if this.oFunc.TieneFuncionalidad("FISCAL", funcionalidades )
					lcCompVtasFcl = lcCompVtasFcl + ", " + transform( &lcCursor..id )
					if this.oFunc.TieneFuncionalidad("CONVALORES", funcionalidades )
						lcCompVtasFclSdr = lcCompVtasFclSdr + ", " + transform( &lcCursor..id )
						do case 
						case this.oFunc.TieneFuncionalidad("CF", funcionalidades )
						 	lcTicketFiscales = lcTicketFiscales + ", " + transform( &lcCursor..id )
						case this.oFunc.TieneFuncionalidad("CE", funcionalidades )
						 	lcElectronicos = lcElectronicos + ", " + transform( &lcCursor..id )
						case this.oFunc.TieneFuncionalidad("CAI", funcionalidades )
						 	lcManuales = lcManuales + ", " + transform( &lcCursor..id )
						otherwise 
						 	lcExportacion = lcExportacion + ", " + transform( &lcCursor..id )
						endcase
					endif
					if this.oFunc.TieneFuncionalidad( "CE", Funcionalidades )
						lcCompCE = lcCompCE + ", " + transform( &lcCursor..id )
					Endif
				endif
			else
				lcCompCmp = lcCompCmp + ", " + transform( &lcCursor..id )
				if this.oFunc.TieneFuncionalidad("FISCAL", funcionalidades )
					lcCompCmpFcl = lcCompCmpFcl + ", " + transform( &lcCursor..id )
					if this.oFunc.TieneFuncionalidad("CONVALORES", funcionalidades )
						 lcCompCmpFclSdr = lcCompCmpFclSdr + ", " + transform( &lcCursor..id )
					endif
				endif
			endif
		endscan

		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompVtas         , 3 ) + [", "VENTAS" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompVtasFcl      , 3 ) + [", "VENTASFISCAL" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompVtasFclSdr   , 3 ) + [", "VENTASFISCALCONVALORES" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompCE           , 3 ) + [", "VENTASFISCALCE" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompCmp          , 3 ) + [", "COMPRAS" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompCmpFcl       , 3 ) + [", "COMPRASFISCAL" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompCmpFclSdr    , 3 ) + [", "COMPRASFISCALCONVALORES" )], 3 )
		*** para listado específico 158 - Subdiario de Caja Compras
		this.AgregarLinea( [this.oComprobantes.Agregar( "-1, ] + substr( lcCompCmpFclSdr, 3 ) + [", "COMPRASFISCALSUBDIARIOIVACOMPRAS" )], 3 )
		*** nuevo combo, con agrupados
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcCompVtasFclSdr, 3 )    + [", "VENTASFISCALCONVALORESAGRUPADOS" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcTicketFiscales   , 3 ) + [", "VENTASTICKETFISCALESCONVALOR" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcElectronicos     , 3 ) + [", "VENTASELECTRONICOSCONVALOR" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcExportacion      , 3 ) + [", "VENTASTEXPORTACIONCONVALOR" )], 3 )
		this.AgregarLinea( [this.oComprobantes.Agregar( "] + substr( lcManuales         , 3 ) + [", "VENTASMANUALESLESCONVALOR" )], 3 )
		*** 
		
		this.cCodigosDeVentasFiscalesConValores = substr( lcCompVtasFclSdr, 3 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCombosXml() as Void

		local lcRutaTemporal as String, lcCursor as String, loError as Exception
		
		lcRutaTemporal = addbs( _Screen.Zoo.ObtenerRutaTemporal() )
		lcCursor = sys( 2015 )
		select c.id, DescEntidad as descrip, funcionalidades as funcional, m.orden ;
			from ( This.cCursorComprobante ) c ;
			inner join c_MenuPrincipalItems m on upper( alltrim( DescComp ) ) == upper( alltrim( m.Entidad ) ) ;
			inner join c_MenuPrincipal mp on mp.id == m.idPadre ;
			order by mp.orden, m.orden ;
			into table ( lcRutaTemporal + lcCursor )
		use in select( lcCursor )

		try
			this.agregarReferencia( "zoologicsa.Core.ADN.dll" )
			this.agregarReferencia( "ZooLogicSA.GeneradorDeDatos.dll" )
			loGeneradorNet = _Screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.GeneradorDeDatos.Combos.GeneradorComboComprobantesProxyFactory", "Obtener" )
			loParametros = _Screen.zoo.crearobjeto( "ZooLogicSA.Core.ADN.ParametroGeneracion" )
			loParametros.Agregar( "RutaTabla", lcRutaTemporal )
			loParametros.Agregar( "Tabla", lcCursor )
			loParametros.Agregar( "RutaXml", this.cPath )
			loGeneradorNet.Generar( loParametros )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			loGeneradorNet = null
			delete file ( lcCursor )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerCadenaComprobantes() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerCadenaComprobantes( tcClave as string ) as String", 1 )
			.AgregarLinea( "Local lcRetorno as String", 2 )
			.AgregarLinea( "", 2 )
			.AgregarLinea( "lcRetorno = []", 2 )
			.AgregarLinea( "if this.oComprobantes.Buscar( tcClave )", 2 )
			.AgregarLinea( "lcRetorno = this.oComprobantes.Item[ tcClave ]", 3 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( [loex = newobject(  "zooexception", "zooexception.prg" )], 3 )
			.AgregarLinea( [loex.message = "El tipo de filtro no posee comprobantes asociados (" + tcClave + ")"], 3 )
			.AgregarLinea( [loex.details = loex.message], 3 )
			.AgregarLinea( [goServicios.Errores.LevantarExcepcion( loEx )], 3 )
			.AgregarLinea( "endif", 2 )
			
			.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerIdentificadorDeComprobanteSql() as Void
		local lcCursor as String, lcComprobante as String, lcContenido as String
		
		lcCursor = This.cCursorComprobante
		
		if reccount( lcCursor ) > 0
			this.oGeneradorDeFuncionesSql.tipo = "ESCALAR"
			this.oGeneradorDeFuncionesSql.ruta = this.cPath
			this.oGeneradorDeFuncionesSql.ubicacion = "SUCURSAL"
			this.oGeneradorDeFuncionesSql.esquema = "Funciones"
			this.oGeneradorDeFuncionesSql.nombre = "ObtenerIdentificadorDeComprobante"
			this.oGeneradorDeFuncionesSql.parametros = "@TipoDeComprobante int"
			this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno = "varchar (3)"		
			
			lcContenido = ""
			lcContenido = lcContenido +"declare @retorno varchar(3)" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"set @retorno =" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"case @TipoDeComprobante" + chr( 13 ) + chr( 10 ) 
			select &lcCursor
			scan 
				lcComprobante = alltrim( upper( &lcCursor..Identificador ) )
				lcContenido = lcContenido + "	when " + transform( Id ) + " then '" + ;
					lcComprobante + "'" + chr( 13 ) + chr( 10 ) 				
			endscan
			lcContenido = lcContenido +"	when 96 then 'AJC'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	when 98 then 'CC'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	when 99 then 'ADC'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	when 999 then 'LIQ'" + chr( 13 ) + chr( 10 ) 			
			lcContenido = lcContenido +"	when 888 then 'COP'" + chr( 13 ) + chr( 10 ) 			
			lcContenido = lcContenido +"	else 'XXX'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"end" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"return @retorno" + chr( 13 ) + chr( 10 )   
						
			this.oGeneradorDeFuncionesSql.contenido = lcContenido
			this.oGeneradorDeFuncionesSql.Ejecutar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerNombreDeComprobanteDeVentasSql() as Void
		local lcCursor as String, lcComprobante as String, lnLargoMaximo as String, lcContenido as String
		
		lcCursor = This.cCursorComprobante
		lnLargoMaximo = 0
		if reccount( lcCursor ) > 0
			this.oGeneradorDeFuncionesSql.tipo = "ESCALAR"
			this.oGeneradorDeFuncionesSql.ruta = this.cPath
			this.oGeneradorDeFuncionesSql.ubicacion = "SUCURSAL"
			this.oGeneradorDeFuncionesSql.esquema = "Funciones"
			this.oGeneradorDeFuncionesSql.nombre = "ObtenerNombreDeComprobanteDeVentas"
			this.oGeneradorDeFuncionesSql.parametros = "@TipoDeComprobante int"
			this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno = "varchar (" + transform( max( lnLargoMaximo, 254 ) ) + ")"
			
			lcContenido = ""
			lcContenido = lcContenido +"declare @retorno " + this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno + chr( 13 ) + chr( 10 )
			lcContenido = lcContenido +"set @retorno =" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"case @TipoDeComprobante" + chr( 13 ) + chr( 10 ) 
			select &lcCursor
			scan 
				lcComprobante = alltrim( proper( iif( isnull( DescEntidad ) or empty( DescEntidad ), alltrim( proper( DescComp ) ), ;
					alltrim( proper( DescEntidad ) ) ) ) )
				lcContenido = lcContenido + "	when " + transform( Id ) + " then '" + ;
					lcComprobante + "'" + chr( 13 ) + chr( 10 ) 	
				if lnLargoMaximo < len( lcComprobante )
					lnLargoMaximo = len( lcComprobante )
				endif
			endscan
			lcContenido = lcContenido +"	when 96 then 'Ajuste de Caja'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	when 98 then 'Comprobante de caja'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	when 99 then 'Apertura de Caja'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"	else '[' + CONVERT(VARCHAR(19), @TipoDeComprobante) + '] Comprobante Desconocido'" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"end" + chr( 13 ) + chr( 10 ) 
			lcContenido = lcContenido +"return @retorno" + chr( 13 ) + chr( 10 )  
			 			
			this.oGeneradorDeFuncionesSql.contenido = lcContenido
			this.oGeneradorDeFuncionesSql.Ejecutar()
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerCodigosDeVentasFiscalesConValores() as Void
		local lcCursor as String, lcComprobante as String, lnLargoMaximo as String, lcContenido as String
		
		if !empty( this.cCodigosDeVentasFiscalesConValores )
			this.oGeneradorDeFuncionesSql.tipo = "ESCALAR"
			this.oGeneradorDeFuncionesSql.ruta = this.cPath
			this.oGeneradorDeFuncionesSql.ubicacion = "SUCURSAL"
			this.oGeneradorDeFuncionesSql.esquema = "Funciones"
			this.oGeneradorDeFuncionesSql.nombre = "ObtenerCodigosDeVentasFiscalesConValores"
			this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno = "varchar (" + transform( len( this.cCodigosDeVentasFiscalesConValores ) ) + ")"
			
			lcContenido = "declare @retorno " + this.oGeneradorDeFuncionesSql.tipoDeDatoDeRetorno + chr( 13 ) + chr( 10 )
			lcContenido = lcContenido + "set @retorno = '" + this.cCodigosDeVentasFiscalesConValores + "'" + chr( 13 ) + chr( 10 )
			lcContenido = lcContenido +"return @retorno" + chr( 13 ) + chr( 10 )
			
			this.oGeneradorDeFuncionesSql.contenido = lcContenido
			this.oGeneradorDeFuncionesSql.Ejecutar()
		endif		
	endfunc 
			
enddefine
