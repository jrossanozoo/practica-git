Define Class GeneradorDinamicoTipoDeValores as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoTipoDeValores of GeneradorDinamicoTipoDeValores.prg
	#endif

	cPath = "Generados\"
	
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		local  lcCursor as String 
	
		with this
			.AgregarLinea( "define class Din_TipoDeValores as zoosession of zoosession.prg" )
			.AgregarLinea( "" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		with this
			.AgregarFuncion_GenerarXmlTipoDeValores()
			.AgregarFuncion_ObtenerComponente()
			.AgregarFuncion_ObtenerDescripcion()
			.AgregarFuncion_ObtenerAtributos()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_GenerarXmlTipoDeValores() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function GenerarXmlTipoDeValores()", 1 )

			.AgregarLinea( "local lcNombreCursor as String, lcTipoDeValoresXML as String" , 2)
			.AgregarLinea( "lcNombreCursor = 'c_' + sys( 2015 )" , 2)
			.AgregarLinea( "create cursor &lcNombreCursor( Codigo n(4), Descripcion c(50), Orden n(2,0) )" , 2)
			.AgregarLinea( "" )
			.AgregarInsertDeTipoDeValores()
			.AgregarOrderBy()
			.AgregarLinea( "" )
			.AgregarLinea( "lcTipoDeValoresXML = this.CursorAXml( lcNombreCursor )" , 2)
			.AgregarLinea( "use in select ( lcNombreCursor )" , 2)
			.AgregarLinea( "return lcTipoDeValoresXML" , 2)

			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertDeTipoDeValores() as Void
		local lcCursor as String, lcComprobante as String
		
		lcCursor = This.ObtenerCursorTipoDeValores()

		if reccount( lcCursor ) > 0
			with this
				select &lcCursor
				scan 
					.AgregarLinea( "insert into &lcNombreCursor values( " + transform( Codigo ) + ", '" + alltrim( Descripcion ) + "', " + transform( Orden ) + ")", 2 )
				endscan
			endwith
		endif
		
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarOrderBy() as Void
		with this
			.AgregarLinea( "Index On Orden to &lcNombreCursor", 2 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorTipoDeValores() as VOID
		local lcCursorTest as String
		lcCursorTest = sys( 2015 ) + "_GetTipoDeValores"
		select Codigo,Descripcion,PideCotizacion,Componente,Orden ;
			from c_TipoDeValores ;
			into cursor &lcCursorTest
			
		return lcCursorTest
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerComponente() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerComponente( tnTipoDeValor as integer ) as String", 1 )
				.AgregarLinea( "Local lcRetorno as String", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "lcretorno = ''", 2 )
				.AgregarDoCaseParaObtenerComponente()
				.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDoCaseParaObtenerComponente() as Void
		local lcCursor as String
		
		lcCursor = This.ObtenerCursorTipoDeValores()
		
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					.AgregarLinea( "case tnTipoDeValor = " + transform( Codigo ), 3 )
						.AgregarLinea( "lcRetorno = '" + iif( empty( Componente ), "Valores", alltrim( Componente ) ) + "'", 4 )
				endscan
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
		
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerDescripcion() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
			.AgregarLinea( "function ObtenerDescripcion( tnTipoDeValor as integer ) as String", 1 )
				.AgregarLinea( "Local lcRetorno as String", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "lcretorno = ''", 2 )
				.AgregarDoCaseParaObtenerDescripcion()
				.AgregarLinea( "return lcRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDoCaseParaObtenerDescripcion() as Void
		local lcCursor as String
		
		lcCursor = This.ObtenerCursorTipoDeValores()
		
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					.AgregarLinea( "case tnTipoDeValor = " + transform( Codigo ), 3 )
						.AgregarLinea( "lcRetorno = '" + alltrim( Descripcion ) + "'", 4 )
				endscan
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
		
		use in select( lcCursor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncion_ObtenerAtributos as Void

			with this
				.AgregarLinea( "" )
				.AgregarLinea( "*" + replicate( "-", 89 ), 1 )
				.AgregarLinea( "function ObtenerAtributos( tnTipoDeValor as integer ) as Object", 1 )
					.AgregarLinea( "Local loRetorno as String", 2 )
					.AgregarLinea( "", 2 )
					.AgregarLinea( "loRetorno = newobject( 'empty')", 2 )
					.AgregarDoCasePAraObtenerAtributos()			
					.AgregarLinea( "return loRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
			endwith		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarDoCaseParaObtenerAtributos() as Void
		local lcCursor as String
	
		lcCursor = sys( 2015 ) + "_AddDocAse"
		select * ;
			from c_TipoDeValores ;
			into cursor &lcCursor
			
		if reccount( lcCursor ) > 0
			with this
				.AgregarLinea( "do case", 2 )
				select &lcCursor
				scan 
					.AgregarLinea( "case tnTipoDeValor = " + transform( Codigo ), 3 )
						.AgregarLinea( "addproperty( loRetorno, 'DescripcionEntrega', " + golibrerias.valorastring( DescripcionEntrega )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'Descripcionrecibe', " + golibrerias.valorastring( Descripcionrecibe )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'FechaEntrega', " + golibrerias.valorastring( FechaEntrega )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'FechaRecibe', " + golibrerias.valorastring( FechaRecibe )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'nroInternoEntrega', " + golibrerias.valorastring( nroInternoEntrega )+ " )", 4 )	
						.AgregarLinea( "addproperty( loRetorno, 'nroInternoRecibe', " + golibrerias.valorastring( nroInternoRecibe )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'importeRecibe', " + golibrerias.valorastring( importeRecibe )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'importeEntrega', " + golibrerias.valorastring( importeEntrega )+ " )", 4 )										
						.AgregarLinea( "addproperty( loRetorno, 'PermiteVuelto', " + golibrerias.valorastring( PermiteVuelto )+ " )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'PersonalizarComprobante', " + golibrerias.valorastring( PersonalizarComprobante )+ " )", 4 )
				endscan
				
				.AgregarLinea( "Otherwise", 3 )
						.AgregarLinea( "addproperty( loRetorno, 'DescripcionEntrega', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'Descripcionrecibe', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'FechaEntrega', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'FechaRecibe', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'nroInternoEntrega', .t. )", 4 )	
						.AgregarLinea( "addproperty( loRetorno, 'nroInternoRecibe', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'importeRecibe', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'importeEntrega', .t. )", 4 )			
						.AgregarLinea( "addproperty( loRetorno, 'PermiteVuelto', .t. )", 4 )
						.AgregarLinea( "addproperty( loRetorno, 'PersonalizarComprobante', .t. )", 4 )
						
				.AgregarLinea( "endcase", 2 )
			endwith
		endif
		
		use in select( lcCursor )
	endfunc 
	
enddefine