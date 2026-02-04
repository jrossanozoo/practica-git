define class GeneradorDinamicoEntidad as GeneradorDinamicoEsqueleto of GeneradorDinamicoEsqueleto.prg

	#if .f.
		local this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
	#endif

	protected oInfoDetalles
	oInfoDetalles = null
	
	cClaseBase = "entidad"
	cCursorClaveCandidata = "c_ClaveCandidata"
	cCursorClaveDeBusqueda = "c_ClaveDeBusqueda"
	lTieneComponentesEnItemYEntidad = .f.
	lGeneracionDeItem = .f.
	cTituloEntidad = ''

	lTieneFuncionalidadDesactivable = .f.
	lTieneFuncionalidadGuardarComo = .f.

	protected oGenAtributosAnulacionerador as generadordinamicoentidadatributosanulacion of generadordinamicoentidadatributosanulacion.prg
	oGenAtributosAnulacionerador = null

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursor() as Void
		return this.ObtenerCursorAtributos( this.cTipo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oGenAtributosAnulacionerador = null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			use in select( .cCursorClaveCandidata )
			use in select( .cCursorClaveDeBusqueda )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenAtributosAnulacionerador_Access() as Void
		if !this.ldestroy and ( vartype( this.oGenAtributosAnulacionerador ) != 'O' or !isnull( this.oGenAtributosAnulacionerador ) )
			this.oGenAtributosAnulacionerador = newobject( "generadordinamicoentidadatributosanulacion", "generadordinamicoentidadatributosanulacion.prg" )
		endif
		return this.oGenAtributosAnulacionerador
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributos() as Void
		dodefault()	
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AgregarLinea( "lPermiteMinusculasPK = .f.", 1 )	
			.AgregarLinea( "cDescripcion =  " + .cDescripcionEntidad, 1 )		
			.AgregarLinea( "lEntidadEditable =  " + .ObtenerlEntidadNoEditable() , 1 )
			if .FuncionalidadNoLoguear()
				.AgregarLinea( "lLoguear = .f.", 1 )
			Endif
			if .lTieneFuncionalidadDesactivable
				.AgregarLinea( "oDesactivador = null", 1 )
				.AgregarLinea( "lDesactivar = .t.", 1 )
				.AgregarLinea( "lActivar = .t.", 1 )
			endif
			.AgregarLinea( "lTieneVendedorComoClaveForanea = " + .TieneVendedorComoClaveForanea(), 1 )
			.AgregarLinea( "cAtributoVendedor = '" + .ObtenerAtributoVendedor() + "'", 1 )

			.GenerarAtributoClaveCandidataODeBusqueda()
			.GenerarAtributoInicializarCodigoSugerido()
			
			.GenerarAtributoFuncionalidadPublica()
			.GenerarAtributoValorComboToolbar()
			.GenerarAtributoValorComboToolbarAnterior()
			.GenerarAtributoDetalleParticipantes()
			
			if .lTieneFuncionalidadGuardarComo
				.AgregarLinea( "lEsGuardarComo = .F." )
				.AgregarLinea( [cCodigoPrevioGuardarComo = ""] )
			endif
		endwith 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarAtributoInicializarCodigoSugerido() as Void
		local lcAux as String
				
		lcAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )
		if !empty( lcAux )
			if upper( this.oFunc.ObtenerValor( "CODIGOSUGERIDO", lcAux ) ) == ".T."
				this.AgregarLinea( "lInicializarCodigoSugeridoHabilitado = .t." , 1 )			
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerlEntidadNoEditable() as String
		return lower( transform( !this.VerificarFuncionalidad( this.cTipo, "ENTIDADNOEDITABLE" ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionalidadNoLoguear() as Boolean
		return this.VerificarFuncionalidad( this.cTipo, "NOLOGUEAR" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
		local lcAux as String
		dodefault()

		this.lTieneFuncionalidadDesactivable = this.TieneFuncionalidadDesactivable( this.cTipo )
		this.lTieneFuncionalidadGuardarComo = this.VerificarFuncionalidad( this.cTipo, "GUARDARCOMO" )

		this.ObtenerDatosClavePrimaria()
		This.lTieneComponentesEnItemYEntidad = This.VerificarComponentesEnItemYEntidad()
		this.lGeneracionDeItem = .f.

		this.cTituloEntidad = upper( alltrim( this.ObtenerTitulo() ) )
		lcAux = this.ObtenerHerencia()
		
		if empty( lcAux )
			this.cClaseBase = "entidad"
		else
			this.cClaseBase = alltrim( lcAux )
		EndIf	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AssignClavePrimaria()
			.AccessAccesoDatos()
			.AccessDetalle()
			.SetearEstadoNuevoEnItems()			
			.SetearEstadoEdicionEnItems()			
			.CambiosDetalle()
			.FuncionValidacionAtributos()
			.FuncionSetearCodigoSugerido()
			.FuncionDebeSugerirCodigo()

			if .VerificaIncluirVotacion()
				.FuncionVotacionCambioEstado()
			endif

			.FuncionValidacionBasica()
			.FuncionValidacionTimestamp()
			.FuncionValidacionDetalles()
	
			if .lTieneComponentesEnItemYEntidad
				.FuncionActualizarEstado()
				.FuncionSetearComponentes()
			endif
			
			.GenerarAssignHabilitarDetalles()
			.FuncionesDeValidacionDeAtributo()
			.FuncionGrabar()
			.Funcion_Nuevo()
			.Funcion_Modificar()
			.Funcion_EliminarSinValidaciones()
			.Funcion_Cancelar()
			if this.VerificarFuncionalidad( this.cTipo, "ANULABLE" )
				.Funcion_Anular()
			endif
			.VerificarOmisionValidarExistencia()			
			.AccessNumeraciones()
			.ObtenerAtributosObligatorios()
			.FuncionBuscar()
			.FuncionGenerarSetearColeccionSentenciasAnterior()
			.FuncionObtenerFuncionalidades()
			.FuncionGuardarComo()
			.FuncionObtenerIdPorClaveCandidata()
			dodefault()			
			.AgregarAccesoDesactivador()
			.AgregarFuncionObtenerDetalleAInsertar()
			.AgregarFuncionObtenerAtributoDetalleAInsertar()
			.AgregarMetodoEsRegistroGuardableComo()
			.AgregarMetodoTieneDetallesConPrePantalla()
			.AgregarMetodoObtenerNombreDetallesConPrePantalla()
			.AgregarAsignarValoresSugeridosAtributosClaveCandidataNoVisibles()
			.AgregarAsignarValoresSugeridosAtributosClaveDeBusquedaNoVisibles()
			.AgregarFuncionLimpiarDatosDetalleAgrupamientoPublicaciones()
			.AgregarFuncionCargarCadenaAgrupamientosParaComboToolbar()
			.AgregarFuncionSeteoValorComboToolbarPorDefecto()
			if this.VerificarFuncionalidad( this.cTipo, "EDICIONPARCIAL" )
				.AgregarFuncionCargarColeccionDeAtributosConEdicionRestringida()
			endif
			.AgregarFuncionObtenerCodigoErrorParaValidacionTimestamp()
			if this.VerificarFuncionalidad( this.cTipo, "MIPYME" )
				.AgregarFuncionesMiPyME()
			endif
			if this.VerificarFuncionalidad( this.cTipo, "LINCE" )
				.AgregarFuncionObtenerCamposSegunEquivalencia()
			endif 
			
			*.AgregarFuncionesKitYParticipantes()	
			if this.VerificarFuncionalidad( this.cTipo, "AGRUPACOMPROBANTES" )
				.AgregarFuncionesComprobantesAgrupados()
			endif
			if This.InformaWebHook()
				.AgregarFuncionesDeWebHook()	
			endif
			if this.EsEntidadPersonalizable()
				.AgregarFuncionSetearDescripcionDeEntidad()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionVotacionCambioEstado() as Void
		local lnTab as Integer, lcCursor as String, lcEventos as String, lcEventoActual as String, lnI as Integer, lnTotWord as Integer ,;
				lcAtributo as String 
		
		lcEventos = "NUEVO,ELIMINAR,MODIFICAR,CANCELAR,GRABAR"

		if this.VerificarFuncionalidad( this.cTipo, "ANULABLE" )
			lcEventos = lcEventos + ",ANULAR"
		endif
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
		
			lnTotWord = getwordcount( lcEventos, "," )
			
			try
				for lnI = 1 to lnTotWord
					lcEventoActual = getwordnum( lcEventos, lnI, "," )
					*******************
					lnTab = 1
					lcCursor = This.ObtenerCursorComponenteRela()
						
					.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
					.AgregarLinea( "function VotacionCambioEstado" + alltrim( lcEventoActual ) + "( tcEstado as string ) as Boolean", lnTab )
					.AgregarLinea( "*!*Se ejecuta antes de hacer el cambio de estado", lnTab + 1 )
					.AgregarLinea( "local llVotacion as boolean", lnTab + 1 )
					.AgregarLinea( "llVotacion = dodefault()", lnTab + 1 )

					select &lcCursor
					scan
						lcAtributo = "oComp" + alltrim( &lcCursor..componente )
						if empty( alltrim( &lcCursor..Atributo ) )
						else
							lcAtributo = alltrim( &lcCursor..Atributo ) + ".oItem." + lcAtributo
						endif
						.AgregarLinea( "llVotacion = llVotacion and this." + lcAtributo + ".votarCambioEstado" + alltrim( lcEventoActual ) + "( tcEstado )" , lnTab + 1 )
						select &lcCursor
					endscan

					.AgregarLinea( "return llVotacion", lnTab + 1 )
					.AgregarLinea( "endfunc", lnTab)
					.AgregarLinea( "", 0)
					use in select( lcCursor )
				endfor
			finally
				use in select( lcCursor )
			endtry
		endwith 	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionActualizarEstado() as Void
		local lnTab as Integer , lcCursor as String 
		
		lnTab = 1
		.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		.AgregarLinea( "function ActualizarEstado() as void", lnTab )
		
		lcCursor = .cCursorComponentes
		select &lcCursor
		scan All
			.AgregarLinea( "", 0 )
			.AgregarLinea( "this.oComp" + alltrim( &lcCursor..componente ) + ".lNuevo = this.lNuevo" , lnTab + 1 )
			.AgregarLinea( "this.oComp" + alltrim( &lcCursor..componente ) + ".lEdicion = this.lEdicion" , lnTab + 1 )
			.AgregarLinea( "this.oComp" + alltrim( &lcCursor..componente ) + ".lEliminar = this.lEliminar" , lnTab + 1 )			
		
			select &lcCursor
		endscan
		.AgregarLinea( "", 0 )
		.AgregarLinea( "endfunc", lnTab )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AccessNumeraciones() as Void
		local lcAccess as String 
		
		lcAccess = ''
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			if .lTieneNumeraciones
				text to lcAccess noshow textmerge
	*-----------------------------------------------------------------------------------------
	function oNumeraciones_Access() as variant
		if !this.ldestroy and ( !vartype( this.oNumeraciones ) = 'O' or isnull( this.oNumeraciones ) )
			this.oNumeraciones = this.CrearObjeto( 'Numeraciones' )
			this.oNumeraciones.Inicializar()
			this.oNumeraciones.SetearEntidad( this )
		endif
		return this.oNumeraciones
	endfunc
				endtext
				.AgregarLinea( lcAccess, 2 )
			endif
		endwith
	endfunc 


	*-----------------------------------------------------------------------------------------
	function GenerarAssignHabilitarDetalles() as Void
		local lcCursor as String, lcAtributo as String , lnTab as Integer 
		lnTab = 1
		lcCursor = this.cCursorAtributos
		select (lcCursor)
		scan for &lcCursor..detalle and &lcCursor..genHabilitar
			lcAtributo = alltrim(&lcCursor..atributo)
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function lHabilitar" + lcAtributo + "_assign( txVal as variant ) as void", lnTab)
			.AgregarLinea( "this.lHabilitar" + lcAtributo + " = txVal", lnTab + 1)
			.AgregarLinea( "this." + lcAtributo + ".habilitarItems( txVal )", lnTab + 1)
			.AgregarLinea( "endfunc", lnTab)
		endscan
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EntidadEnMenuPrincipal() as Boolean
		select * from c_MenuPrincipalItems where upper( alltrim( entidad ) ) = upper( alltrim( this.ctipo ) ) into cursor "c_EntidadEnMenu"
		llRetorno = ( _tally > 0 )
			
		use in select( "c_EntidadEnMenu" )
		
		return _tally > 0

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionInicializar() as Void
		local lcCursor as String 

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AgregarLinea( "", 1 )
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function Inicializar() as Void", 1 )
			.AgregarLinea( "dodefault()", 2 )
			.AgregarLinea( "this.lPermiteMinusculasPK = goParametros.Nucleo.PermiteCodigosEnMinusculas" , 2 )
			.AgregarLinea( "this.Enlazar( 'lNuevo', 'SetearEstadoNuevoEnItems' )", 2) 			
			.AgregarLinea( "this.Enlazar( 'lEdicion', 'SetearEstadoEdicionEnItems' )", 2) 	
			.AgregarLinea( "this.lHabilitaEnviarAlGrabar = " + transform( this.EntidadEnMenuPrincipal() ), 2) 				
					
			.ArmarColeccionClaveCandidata()	

			if this.VerificarFuncionalidad( this.cTipo, "ANULABLE" )
				.AgregarLinea( [this.oProveedorAtributosAnulacion = newobject( "din_entidad] + .cTipo + [AtributosAnulacion", "din_entidad] + .cTipo + [AtributosAnulacion.prg" )], 2)
			endif
			if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
				.AgregarLinea( 'bindevent( This, "Limpiar", this, "SetearValorComboPorDefecto", 1 )', 2 )
			endif
			if this.VerificarFuncionalidad( this.cTipo, "EDICIONPARCIAL" )
				.AgregarLinea( 'this.CargarColeccionDeAtributosConEdicionRestringida()', 2 )
			endif
			lcCursor = this.cCursorAtributos
			select ( lcCursor )
			.AgregarLinea( "this.oColeccionVS = _screen.zoo.CrearObjeto( 'zoocoleccion' )", 2 )
		.AgregarLinea( "this.oColeccionVSFW = _screen.zoo.CrearObjeto( 'zoocoleccion' )", 2 )
		scan for !empty( &lcCursor..ValorSugerido )
				lcAtributo = alltrim( proper ( &lcCursor..Atributo ))
				.AgregarLinea( "this.oColeccionVSFW.agregar('.ValorSugeridoFW" + lcAtributo + "()','" + lcAtributo + "')", 2 )
			endscan
		.AgregarLinea( "oICol = goServicios.SaltosDeCampoYValoresSugeridos.ObtenerValorSugeridoDeUnaEntidadDetalle( '" + alltrim( this.cTipo ) + "', '" + alltrim( this.cSufijo ) + "')", 2 )
		.AgregarLinea( "for each oItmUs in oICol", 2 )
			.AgregarLinea( "this.oColeccionVS.Agregar( '.ValorSugerido' + alltrim(oItmUs.atributo) + '()' )", 3 )
			.AgregarLinea( "try", 3 )			
			.AgregarLinea( [this.oColeccionVSFW.Quitar( alltrim( proper( oItmUs.atributo ) ) )], 4 )
			.AgregarLinea( "catch to loError", 3 )			
			.AgregarLinea( "endtry", 3 )			
		.AgregarLinea( "endfor", 2 )
			
			if this.InformaWebHook()
				.AgregarLinea( "this.lWHIngresar = goServicios.WebHook.TieneQueMandar( '" + alltrim( this.cTipo ) + "', 'INGRESAR' )", 2 )
				.AgregarLinea( "this.lWHModificar = goServicios.WebHook.TieneQueMandar( '" + alltrim( this.cTipo ) + "', 'MODIFICAR' )", 2 )
				.AgregarLinea( "this.lWHEliminar = goServicios.WebHook.TieneQueMandar( '" + alltrim( this.cTipo ) + "', 'ELIMINAR' )", 2 )
			endif
			
			if this.EsEntidadPersonalizable()
				.AgregarLinea( "this.SetearDescripcionDeEntidad()", 2 )
			endif
			
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoNuevoEnItems() as Void
		local lcCursorEntidad as String, lcAtributo as String
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function SetearEstadoNuevoEnItems() as Void", 1 )
			.AgregarLinea( "dodefault()", 2 )
			
			lcCursorEntidad = .cCursorAtributos

			try
				select atributo from &lcCursorEntidad where Detalle into cursor c_detalles

				select c_detalles
				scan
					lcAtributo = alltrim( c_detalles.Atributo )
					.AgregarLinea( "this." + lcAtributo + ".oItem.lNuevo = this.lNuevo" , 2 )
				endscan
			finally
				use in select( "c_detalles" )
			endtry

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoEdicionEnItems() as Void
		local lcCursorEntidad as String, lcAtributo as String
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function SetearEstadoEdicionEnItems() as Void", 1 )
			.AgregarLinea( "dodefault()", 2 )
			
			lcCursorEntidad = .cCursorAtributos

			try
				select atributo from &lcCursorEntidad where Detalle into cursor c_detalles

				select c_detalles
				scan
					lcAtributo = alltrim( c_detalles.Atributo )
					.AgregarLinea( "this." + lcAtributo + ".oItem.lEdicion = this.lEdicion" , 2 )
				endscan
			finally
				use in select( "c_detalles" )
			endtry

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function AssignClavePrimaria() as Void
		local lcCursorEntidad as string, lcCursor as string, lcCP as string, lcFunc as string, lcValorVacio as string,;
			lcTipoDato as String, lcDespuesDeAssign As String, lcIfHabilitacion As String , lcValidacion As String, lnTab as integer
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcIfHabilitacion = ""
			lcDespuesDeAssign = ""
			
			lcCursorEntidad = .cCursorAtributos
			lcCursor = sys( 2015 ) + "_AssignClavPrim"
			
			try
				select * from ( lcCursorEntidad ) ;
					where claveprimaria ;
					into cursor ( lcCursor )

				lcTipoDato  = upper( alltrim( &lcCursor..TipoDato ) )

				lcCp = alltrim( &lcCursor..Atributo )

				if empty( &lcCursor..DespuesDeAsignacion )
				else
					lcDespuesDeAssign = "This." + lcCP + "_DespuesDeAsignar()"
					This.AgregarFuncionDespuesDeAsignar( lcCP + "_DespuesDeAsignar", &lcCursor..DespuesDeAsignacion )
				endif

				lcValidacion = alltrim( proper( &lcCursor..Validacion ) )
				if &lcCursor..genHabilitar or !empty( lcValidacion )
					
					lcIfHabilitacion = ""
					if &lcCursor..genHabilitar
						lcIfHabilitacion = "if this.lHabilitar" + lcCP
					endif
					
					lcIfHabilitacion = .GeneraCondicionAssign( lcIfHabilitacion, lcCP, lcValidacion, .f. )
				endif
				
				lcValorVacio = goLibrerias.ValorAString( goLibrerias.Valorvacioseguntipo( &lcCursor..TipoDato ) )

			*** desde aca empieza a escribir codigo generado			
				lnTab = 1

				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function " + lcCp + "_Assign( txVal as variant ) as void", lnTab)
				.AgregarLinea( "local llConsulta as Boolean, llNuevo as boolean, llEdicion as boolean", lnTab + 1 )
				.AgregarLinea( "with this", lnTab + 1 ) 
				.AgregarLinea( "llEdicion = .EsEdicion()", lnTab + 2 )
				if upper( alltrim( &lcCursor..TipoDato ) ) == "C"
					.AgregarLinea( "if !this.lPermiteMinusculasPK", lnTab + 2 )
						.AgregarLinea( "try", lnTab + 3 )
							.AgregarLinea( "txVal = upper( txVal )", lnTab + 4 )
						.AgregarLinea( "Catch", lnTab + 3 )
						.AgregarLinea( "Endtry", lnTab + 3 )
					.AgregarLinea( "endif", lnTab + 2 )						
				endif
				.AgregarLinea( "if .lLimpiando or .lCargando", lnTab + 2 ) 
					.AgregarLinea( "." + LCCP + " = .TransformarAlAsignar( txVal )", lnTab + 3 ) 
				.AgregarLinea( "else", lnTab + 2 ) 
					.AgregarLinea( "if llEdicion", lnTab + 3 ) 
					.AgregarLinea( "else", lnTab + 3 )
					
					if empty( lcIfHabilitacion )
					else
						.AgregarLinea( lcIfHabilitacion, lnTab + 4 )
					endif
					
					.AgregarLinea( "llNuevo = .EsNuevo()", lnTab + 4 )
					if lcTipoDato = 'A'
						.AgregarLinea( "if llNuevo", lnTab + 4 ) 
							.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'No se puede asignar manualmente el atributo código.' )", lnTab + 5 ) 
						.AgregarLinea( "endif", lnTab + 4 ) 
					endif

					.AgregarLinea( "." + lcCp + " = .TransformarAlAsignar( txVal )", lnTab + 4 ) 
					.AgregarLinea("if empty( txVal ) and !llNuevo", lnTab + 4 ) 
						.AgregarLinea(".Limpiar()", lnTab + 5 ) 
					.AgregarLinea("else", lnTab + 4 ) 

					if lcTipoDato = 'C'
						.AgregarLinea( "if llNuevo", lnTab + 5 ) 
							.AgregarLinea( "if .ValidarIngreso( txVal, llNuevo )", lnTab + 6 ) 
							.AgregarLinea( "else", lnTab + 6 ) 
								.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'Caracter inválido en el código.' )", lnTab + 7 ) 
							.AgregarLinea( "endif", lnTab + 6 ) 
						.AgregarLinea( "endif", lnTab + 5 ) 
					endif
					
						.AgregarLinea( "llConsulta = .oAD.ConsultarPorClavePrimaria()", lnTab + 5 )

	*					if .oFunc.TieneFuncionalidad( "CODIGOSUGERIDO", c_Entidad.Funcionalidades )
						if .oFunc.TieneFuncionalidad( "CODIGOSUGERIDO", this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) ) )
							.AgregarLinea( "if !llConsulta", lnTab + 5 )
							.AgregarLinea( "if !this.lEsSubEntidad and !llNuevo and this.SoportaBusquedaExtendida()", lnTab + 6 )
							.AgregarLinea( "llConsulta = .ConsultarPorClavePrimariaSugerida()", lnTab + 7 )
							.AgregarLinea( "endif", lnTab + 6 )
							.AgregarLinea( "endif", lnTab + 5 )						
						endif
	****  Verificar si esto es para la segunda busqueda.
						
						.AgregarLinea( "do case", lnTab + 5 ) 
							.AgregarLinea( "case !llNuevo and llConsulta", lnTab + 6 ) 
								.AgregarLinea( ".Cargar()", lnTab + 7 ) 
							.AgregarLinea( "case !llNuevo and !llConsulta", lnTab + 6 ) 
								.AgregarLinea( ".Limpiar()", lnTab + 7 ) 
								.AgregarLinea( "goServicios.Errores.LevantarExcepcionTexto( " + .ObtenerMensajeClavePrimaria( "txVal" ) + ", 9001 )", lnTab + 7 ) 
							.AgregarLinea( "case llNuevo and llConsulta", lnTab + 6 ) 
								.AgregarLinea( "." + lcCp + " = " + lcValorVacio, lnTab + 7 ) 
								.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'El código ' + alltrim( transform( txVal ) ) + ' ya existe.' )", lnTab + 7 ) 
						.AgregarLinea( "endcase", lnTab + 5 ) 

					if !empty( lcDespuesDeAssign )
						.AgregarLinea( lcDespuesDeAssign, lnTab + 6 ) 
					endif
							
					.AgregarLinea( "endif", lnTab + 4 )

					if empty( lcIfHabilitacion )
					else
						.AgregarLinea( "else", lnTab + 4 )
							.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'No se puede asignar el atributo código' )", lnTab + 5 )
						.AgregarLinea( "EndIf", lnTab + 4 ) 
					endif
						.AgregarLinea( "endif", lnTab + 3 ) 
					.AgregarLinea( "endif", lnTab + 2 ) 
					.AgregarLinea( "endwith", lnTab + 1 ) 
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			finally
				use in select( lcCursor )
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AccessAccesoDatos() as Void
		local lnTab as Integer

		lnTab = 1
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function oAD_Access() as variant", lnTab )
				.agregarLinea( "if !this.ldestroy and ( !vartype( this.oAD ) = 'O' or isnull( this.oAD ) )", lnTab + 1 )

*					.agregarLinea( "if upper( alltrim( _screen.zoo.app.TipoDeBase )) == 'NATIVA'", lnTab + 2 )
*						.agregarLinea( "this.oAD = this.crearobjeto( 'Din_Entidad" + this.cTipo + "AD' )", lnTab + 3 )
*					.agregarLinea( "else", lnTab + 2 )
						.agregarLinea( "this.oAD = this.crearobjeto( 'Din_Entidad" + this.cTipo + "AD_' + alltrim( _screen.zoo.app.TipoDeBase ))", lnTab + 2 )
*					.agregarLinea( "endif", lnTab + 2 )
				
					.agregarLinea( "this.oAD.InyectarEntidad( this )",  lnTab + 2 )
					.agregarLinea( "this.oAD.Inicializar()",  lnTab + 2 )			
				.agregarLinea( "endif", lnTab + 1 )
				.agregarLinea( "return this.oAD", lnTab + 1 )
			.agregarLinea( "endfunc", lnTab )
			.agregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsEntidadPuesto( tcEntidad as String ) as Boolean
		return alltrim( upper( this.ObtenerUbicacion( tcEntidad ) )) == "PUESTO"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUbicacion( tcEntidad as String ) as String
		return upper( alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "UbicacionDB", "Entidad", upper( alltrim( this.cTipo ) ) ) ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerInfoDetalles() as zooColeccion
		return this.oInfoDetalles
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemInfoDetalles( tcAtributo as String, tcDominio as string, tlGenHabilitar as Boolean, tcTags as String ) as object
		local loRetorno as object
		
		loRetorno = _screen.zoo.CrearObjeto( "zoocustom" )
		loRetorno.AddProperty( "Atributo", tcAtributo )
		loRetorno.AddProperty( "Dominio", tcDominio )
		loRetorno.AddProperty( "EntidadItem", substr( tcDominio, 8 ) )
		loRetorno.AddProperty( "Tipo", this.ObtenerHerenciaDetalle( loRetorno.EntidadItem )	)
		loRetorno.AddProperty( "GenHabilitar", tlGenHabilitar )
		loRetorno.AddProperty( "Tags", tcTags )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerenciaDetalle( tcTipo as String ) as String
		return alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Herencia", "Entidad,Tipo", upper( alltrim( tcTipo ) ) + ",I" ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerencia() as String
		return alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Herencia", "Entidad,Tipo", upper( alltrim( this.cTipo ) ) + ",E" ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTitulo() as String
		return alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Titulo", "Entidad,Tipo", upper( alltrim( this.cTipo ) ) + ",E" ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AccessDetalle() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string, lcNombreDetalle as String, loInfoDetalle as Object

		lnTab = 1
		
		this.oInfoDetalles = null
		this.oInfoDetalles = _screen.Zoo.crearObjeto( "zooColeccion" )
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for &lcNombreCursor..Detalle
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )
				loInfoDetalle = .ObtenerItemInfoDetalles( lcAtributo, alltrim( upper( &lcNombreCursor..Dominio ) ), &lcNombreCursor..GenHabilitar, &lcNombreCursor..Tags )
				.oInfoDetalles.Agregar( loInfoDetalle, lcAtributo )
				lcNombreDetalle = "Detalle" + lcEntidad + lcAtributo
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function " + lcAtributo + "_Access() as variant", lnTab )
				.agregarLinea( "if !this.ldestroy and ( !vartype( this." + lcAtributo +" ) = 'O' or isnull( this." + lcAtributo +" ) )", lnTab + 1 )
				if file( lcNombreDetalle + ".prg" ) or file( lcNombreDetalle + ".fxp" )
					.agregarLinea( "this." + lcAtributo + " = this.crearobjeto( '" + lcNombreDetalle + "' )", lnTab + 2 )
				else
					.agregarLinea( "this." + lcAtributo + " = this.crearobjeto( 'Din_" + lcNombreDetalle + "' )", lnTab + 2 )
				endif
				.agregarLinea( "this." + lcAtributo + ".inicializar()", lnTab + 2 )
				
				if this.oFunc.TieneFuncionalidad("OBLIGATORIO", upper( &lcNombreCursor..Tags ) )
					.agregarLinea( "this." + lcAtributo + ".lPermitirDetalleVacio = .F.", lnTab + 2 )
				endif 	
				
				.AgregarBindeosZooSession( lcAtributo, lnTab + 2 )
				.AgregarLinea( "bindevent( this." + lcAtributo  + ", 'CambioSumarizado', this, 'CambiosDetalle" + lcAtributo + "', 1) ", lnTab + 2 )
				.AgregarLinea( "this.enlazar( '" + alltrim( lcAtributo )  + ".EventoAdvertirLimitePorDiseno', 'EventoAdvertirLimitePorDiseno') ", lnTab + 2 )
				.AgregarLinea( "this.enlazar( '" + alltrim( lcAtributo )  + ".EventoCancelarCargaLimitePorDiseno', 'EventoCancelarCargaLimitePorDiseno') ", lnTab + 2 )
				if &lcNombreCursor..Alta and this.VerificarComportamiento( "D", this.cTipo )
						.AgregarLinea( "this." + lcAtributo + ".lVerificarLimitesEnDisenoImpresion = .t." , lnTab + 2 )
				endif
				if this.oFunc.TieneFuncionalidad( "COPIADETALLE", upper( &lcNombreCursor..Tags ) )
					.agregarLinea( "this." + lcAtributo + ".lHabilitaInsertarDetalle = .t." , lnTab + lnTab + 2 )
				endif
				
				lcCursorItemDetalle = this.ObtenerCursorAtributos( loInfoDetalle.EntidadItem )
				if this.oFunc.TieneFuncionalidad( "CONPARTICIPANTES", upper( &lcNombreCursor..Tags ) ) and this.TieneAtributosCombinacion( lcCursorItemDetalle )
					.agregarLinea( "This.BindearEvento( This." + lcAtributo + ", 'EventoAgregarKits' , This, 'AgregarKits' )" , lnTab + 2 )	
				endif
				
				if alltrim( upper( &lcNombreCursor..Dominio ) ) = "DETALLEITEMKITS"
					.AgregarLinea( "this.enlazar( '" + alltrim( lcAtributo )  + ".EventoAgregarKits', 'AgregarParticipantes') ", lnTab + 2 )  
					.AgregarLinea( "this.enlazar( '" + alltrim( lcAtributo )  + ".EventoErrorParticipante', 'ErrorParticipante') ", lnTab + 2 )  
				endif				
				
				use in select ( lcCursorItemDetalle )
				
				.agregarLinea( "endif", lnTab + 1 )

				.agregarLinea( "return this." + lcAtributo, lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
				.agregarLinea( "" )
			endscan
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function CambiosDetalle() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer

		lnTab = 1
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for &lcNombreCursor..Detalle
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function CambiosDetalle" + lcAtributo + "() as void", lnTab )
				.agregarLinea( "dodefault()", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
				.agregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionValidacionAtributos() as Void
		local lcCursorEntidad as String , lcTipoDatoAtributo as String, lcNombreAtributo as String, ;
			lcLongitudAtributo as String, lcDecimalAtributo as String

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursorEntidad = .cCursorAtributos

			try
				select * from &lcCursorEntidad where !EsEntidad and !Detalle into cursor c_acotados

				.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function ValidacionAtributos() as Boolean", 1 )
				.AgregarLinea( "local lnLargoDecimal as integer, lnLargoEntero as Integer, lnLargoDecimal as integer, llRetorno as boolean ",1 )
				.AgregarLinea( "llRetorno = .T.", 2 )
				.AgregarLinea( "" )

				select c_acotados
				scan
					lcTipoDatoAtributo = upper( alltrim( c_acotados.TipoDato ) )

					lcTipoDatoAtributo = This.ConvertirTipoDato( lcTipoDatoAtributo )
					lcNombreAtributo   = upper( alltrim( c_acotados.Atributo ) )
					lcLongitudAtributo = transform( c_acotados.Longitud - c_acotados.Decimales )
					lcDecimalAtributo  = transform( c_acotados.Decimales )
					lnTotalAtributoInt = transform( c_acotados.Longitud )

					.AgregarLinea( " " ,2 )

					if lcTipoDatoAtributo = 'M'
						.AgregarLinea( "if ( vartype( this." + alltrim( c_acotados.Atributo ) + ") = 'C' ) " , 2 )
					else
						.AgregarLinea( "if ( vartype( this." + alltrim( c_acotados.Atributo ) + ") = '"  + lcTipoDatoAtributo + "' )" , 2 )
					endif

					lcMensajeValidacion = ""
					do case
						case lcTipoDatoAtributo = 'C'

							.AgregarLinea( "if len( alltrim( this." + lcNombreAtributo + " ) ) > " + lcLongitudAtributo ,3 )
							lcMensajeValidacion = "La longitud del valor del atributo " + lcNombreAtributo + " es mayor a la permitida." 
									
						case lcTipoDatoAtributo = 'N'
							.AgregarLinea( "lnLargoEntero  = len( transform( int( this." + lcNombreAtributo + " ) ) ) " , 3 )
							.AgregarLinea( "lnValorDelDecimal = this." + lcNombreAtributo + " - int( this." + lcNombreAtributo + ")"  , 3 )
							.AgregarLinea( "lnLargoDecimal = iif( lnValorDelDecimal = 0, 0, len( transform( lnValorDelDecimal ) ) - 2 )" ,3 )

							.AgregarLinea( "if lnLargoEntero > " + lcLongitudAtributo ,3 )
		
							lcMensajeValidacion = "La longitud entera del valor del atributo " + lcNombreAtributo + " es mayor a la permitida."
		
					endcase

					if empty( lcMensajeValidacion )
					else
						.AgregarLinea( "This.AgregarInformacion( '" + lcMensajeValidacion + "' )" , 4 )
						.AgregarLinea( "llRetorno = .F." , 4 )
						.AgregarLinea( "Endif", 3 )
					endif	

					.AgregarLinea( "else", 2 )
					.AgregarLinea( "This.AgregarInformacion( 'El tipo de dato para el atributo " + lcNombreAtributo + " no es el correcto.')" , 3 )
					.AgregarLinea( "llRetorno = .F." , 3 )
					.AgregarLinea( "Endif", 2 )

				endscan

				.AgregarLinea( "" )
				.AgregarLinea( "Return llRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )
			finally
				use in select( "c_Acotados" )
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionValidacionTimestamp() as Void
		local lcCursorEntidad as String
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursorEntidad = .cCursorAtributos

			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ValidacionTimestamp() as Boolean", 1 )
			
			try
				select * from &lcCursorEntidad where upper(alltrim( campo)) == "TIMESTAMP" into cursor c_usatimestamp
				if _tally > 0
					.AgregarLinea( "Local lnTimestampactual as integer, llRetorno as boolean", 2 )
					.AgregarLinea( "llRetorno = .T.", 2 )
					.AgregarLinea( "if !this.EsNuevo() and this.EsEdicion()", 2)
					
					.AgregarLinea( "lnTimestampactual = this.oAd.ObtenerTimestampActual()", 3 )
					.AgregarLinea( "if lnTimestampactual = this.Timestamp", 3 )	
					.AgregarLinea( "else",3)
					.AgregarLinea( "llRetorno = .F.",4)
					.AgregarLinea( "this.AgregarInformacion( 'El registro fue modificado, no se pudo actualizar', this.ObtenerCodigoErrorParaValidacionTimestamp() )" , 4 )
					.AgregarLinea( "Endif", 3 )
					.AgregarLinea( "Endif", 2 )
					.AgregarLinea( "" )
					.AgregarLinea( "Return llRetorno", 2 )
					.AgregarLinea( "endfunc", 1 )
				endif
			finally
				use in select( "c_usatimestamp" )
			endtry
			
			.AgregarLinea( "" )
		endwith 	
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionValidacionBasica() as Void

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ValidacionBasica() as boolean", 1 )
			.AgregarLinea( "Local llRetorno as boolean, llVotacion as boolean", 2 )
			.AgregarLinea( "llRetorno = .T.", 2 )
			.AgregarLinea( "llVotacion = .T.", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault()", 2 )
			.AgregarLinea( "")	
			.AgregarLinea( "With This", 2 )
			.AgregarValidacionesDeAtributos()
			.AgregarLinea( "llRetorno = .ValidacionAtributos() and llRetorno" , 3 )

			.AgregarLinea( "llRetorno = .ValidacionDetalles() and llRetorno" , 3 )

			if .VerificaIncluirVotacion()
				.GenerarLineaVotacionCambioEstado( 3, "Grabar" )
			endif
						
			.AgregarLinea( "if .VerificarContexto( 'CB' )", 3 )
			.AgregarLinea( "else", 3 )
			.AgregarLinea( "llRetorno = .ValidacionTimestamp() and llRetorno" , 4 )
			.AgregarLinea( "endif", 3)
			.AgregarLinea( "EndWith", 2)						
			.AgregarValidacionDeCodigoVacio( 2 )
			.AgregarLinea( "return llRetorno and llVotacion", 3 )			
			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionDeCodigoVacio( tnTab as Integer ) as Void
		if this.cTipoDatoClavePrimaria != 'A'
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.AgregarLinea( "" )
				.AgregarLinea( "If Empty( this." + alltrim( .cAtributoClavePrimaria ) + " )", tnTab )
				.AgregarLinea( "llRetorno = .F.", tnTab + 1 )
				.AgregarLinea( "This.AgregarInformacion( 'No se puede grabar. Código Vacío', 0 )", tnTab + 1 )
				.AgregarLinea( "Endif", tnTab )
				.AgregarLinea( "if This.ValidarIngreso( transform( this." + alltrim( .cAtributoClavePrimaria ) + " ) )", tnTab )
				.AgregarLinea( "else", tnTab )
				.AgregarLinea( "llRetorno = .F.", tnTab + 1 )
				.AgregarLinea( "this.AgregarInformacion( 'Caracteres Inválidos en el código', 0 )", tnTab + 1 )
				.AgregarLinea( "EndIf", tnTab )
			endwith
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionesDeAtributos() as Void
		local lcCursor as String
	
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = .cCursorAtributos
			try
				select * from &lcCursor where ( Obligatorio or EsEntidad ) and !ClavePrimaria into cursor c_validaciones
				scan
					if upper(c_validaciones.Dominio) = "ETIQUETACARACTERDESDEHASTABUSC"
					else
						.AgregarLinea( "llRetorno = .Validar" + alltrim( proper( Atributo ) ) + "() and llRetorno", 3 )
					endif
				endscan
			finally
				use in select( "c_validaciones" )
			endtry
		endwith

	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function FuncionesDeValidacionDeAtributo() as Void
	
		this.GenerarValidacionAtributosNoSubentidadyObligatorios()
		this.GenerarValidacionAtributosSubentidades()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarValidacionAtributosNoSubentidadyObligatorios( tcCursor ) as Void
		local lcCursor as String 
		
		lcCursor = this.cCursorAtributos

		try		
			select * from &lcCursor where Obligatorio and !EsEntidad and !ClavePrimaria into cursor c_acotados
			scan 
				this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				this.agregarLinea( "function Validar"+ alltrim( c_acotados.Atributo ) + "() as boolean", 1)
				this.agregarLinea( "local llRetorno as boolean", 2 )
				this.agregarLinea( "llRetorno = dodefault()", 2 )			
				this.agregarLinea( "if empty( this." + alltrim( c_acotados.Atributo ) + " )", 2 )
				this.LlenarValidacionObligatorios( iif( !empty( c_acotados.EtiquetaAutodescriptiva ) , c_acotados.EtiquetaAutodescriptiva , c_acotados.Etiqueta ) , c_acotados.Atributo )
				this.agregarLinea( "endif", 2 )
				this.agregarLinea( "return llRetorno", 2 )
				this.agregarLinea( "endfunc", 1)
				this.agregarLinea( "" )
			endscan
		finally
			use in select( "c_acotados" )	
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarValidacionAtributosSubentidades( tcCursor ) as Void
		local lcCursor as String, lcEtiqueta as String, lcAtributo as String, lcSubEntidad as String 

		lcCursor = this.cCursorAtributos
		try
			select C.* from &lcCursor as C where C.EsEntidad and !C.ClavePrimaria into cursor c_acotados
			scan
				lcEtiqueta = iif( !empty( c_acotados.EtiquetaAutodescriptiva ) , alltrim( c_acotados.EtiquetaAutodescriptiva ) , alltrim( c_acotados.Etiqueta ) ) 
				lcAtributo = alltrim( c_acotados.Atributo )
				this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				this.agregarLinea( "function Validar" + lcAtributo  + "() as boolean", 1)
					this.agregarLinea( "local llRetorno as boolean", 2 )
					this.agregarLinea( "llRetorno = dodefault()", 2 )
					this.agregarLinea( "if empty( this." + lcAtributo  + "_PK )", 2 )
					if c_acotados.Obligatorio
						this.LlenarValidacionObligatorios( lcEtiqueta, lcAtributo )				
					Endif
					this.agregarLinea( "else", 2 )
						this.agregarLinea( "If this." + lcAtributo + ".oAD.ConsultarPorClavePrimaria()", 3 )
						this.AgregarValidacionEntidadDesactivada( lcAtributo, lcEtiqueta, c_acotados.cEntidad )
						this.agregarLinea( "Else", 3 )
						lcSubEntidad = padr( This.ObtenerNombreSubentidadParaMensaje( c_acotados.ClaveForanea ), len(c_acotados.Titulo), ' ' )
						this.agregarLinea( "this.AgregarInformacion( 'El dato buscado ' + alltrim(transform( this."+ alltrim(lcAtributo) + "_PK ))+ " + "' de la entidad ' +  upper( this." + lcAtributo + ".cDescripcion ) + ' no existe.')" , 4 )
							this.agregarLinea( "llRetorno = .F.", 4 )
						this.agregarLinea( "endif", 3 )
					this.agregarLinea( "endif", 2 )
					this.agregarLinea( "Return llRetorno", 2 )				
				this.agregarLinea( "endfunc", 1)
				this.agregarLinea( "" )
			endscan
		finally
			use in select( "c_acotados" )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreSubentidadParaMensaje( tcEntidad as String ) as String
		local lcRetorno as String, lcCursor as String, lnSelect as Integer 
		lnSelect = select()
		lcRetorno = ''
		lcCursor = 'C' + sys( 2015 )
		
		select top 1 Titulo from c_entidad where rtrim(upper(Entidad)) == rtrim(upper(tcEntidad)) into cursor &lcCursor. order by Entidad

		if used( lcCursor ) and reccount( lcCursor ) > 0
			lcRetorno = alltrim( upper( &lcCursor..Titulo ) )
		endif 
		use in select( lcCursor )
		select( lnSelect )
		
		retu lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionEntidadDesactivada( tcAtributo as String, tcEtiqueta as String, tcEntidad as String ) as Void
		local lcTexto as String 
		if this.TieneFuncionalidadDesactivable( tcEntidad )
			text to lcTexto textmerge pretext 2 noshow 
				This.<<alltrim(tcAtributo)>>.oDesactivador.ValidarEstadoActivacion( this.<<alltrim(tcAtributo)>>_PK , goLibrerias.Valorvacioseguntipo( vartype(this.<<alltrim(tcAtributo)>>_PK ) ), this.lnuevo, this.ledicion )
			endtext
			this.agregarLinea( lcTexto, 4 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function LlenarValidacionObligatorios( tcEtiqueta as String, tcAtributo as String ) as Void
		this.agregarLinea( "this.AgregarInformacion( 'Debe cargar el campo " + iif( !empty( tcEtiqueta ), alltrim( tcEtiqueta ), alltrim( tcAtributo ) ) +"', 9005, '" + alltrim( tcAtributo ) + "' )", 3 )
		this.agregarLinea( "llRetorno = .F.", 3 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionValidacionDetalles() as Void
		local lcCursorEntidad as String , lcTipoDatoAtributo as String, lcNombreAtributo as String, ;
			lcLongitudAtributo as String, lcDecimalAtributo as String, lcEtiqueta as String

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursorEntidad = .cCursorAtributos

			try
				select * from &lcCursorEntidad where Detalle into cursor c_detalles
			
				.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function ValidacionDetalles() as Boolean", 1 )
				.AgregarLinea( "local llRetorno as boolean, llValAux as boolean", 2 )
				.AgregarLinea( "llRetorno = dodefault()", 2 )

				select c_detalles
				scan
					lcAtributo = alltrim( c_detalles.Atributo )
					lcEtiqueta = iif( !empty( c_detalles.EtiquetaAutodescriptiva ) , alltrim( c_detalles.EtiquetaAutodescriptiva ) , iif( empty( c_detalles.Etiqueta ), lcAtributo, alltrim( c_detalles.Etiqueta ))) 
					.AgregarLinea( "llRetorno = This.ValidarUnDetalle( this." + lcatributo + ", '" + lcEtiqueta + "' ) and llRetorno", 2 )
				endscan
				.AgregarLinea( "return llRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )
			finally
				use in select( "c_detalles" )
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionSetearComponentes() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function SetearComponentes() as Void", 1 )

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarAtributoClaveCandidataoDeBusqueda() as Void
		local lcCursorEntidad as String 
		
		lcCursorEntidad = This.cCursorAtributos

		select atributo, esEntidad ;
			from &lcCursorEntidad ;
			where ClaveCandidata > 0  ;
			order by ClaveCandidata	;
			into cursor ( this.cCursorClaveCandidata )
		
		select atributo, esEntidad ;
			from &lcCursorEntidad ;
			where upper(alltrim(Dominio))=="CLAVEDEBUSQUEDA" ;
			into cursor ( this.cCursorClaveDeBusqueda )
					
		if reccount( this.cCursorClaveCandidata ) > 0 or reccount( this.cCursorClaveDeBusqueda ) > 0
			this.AgregarLinea( "oAtributosCC =  Null" , 1 )		
		endif 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarColeccionClaveCandidata() as Void
		local lcCursorClaveCandidata as String 

		if reccount( this.cCursorClaveCandidata ) = 0
			lcCursorClaveCandidata = this.cCursorClaveDeBusqueda
		else
			lcCursorClaveCandidata = this.cCursorClaveCandidata
		endif 

		if reccount( lcCursorClaveCandidata ) > 0
			this.AgregarLinea( "this.oAtributosCC = _screen.zoo.crearobjeto( 'ZooColeccion' )", 2 )

			select( lcCursorClaveCandidata )
			scan
				this.AgregarLinea( 'this.oAtributosCC.add( "' + alltrim( &lcCursorClaveCandidata..atributo ) + ;
					iif( &lcCursorClaveCandidata..EsEntidad, "_pk", "" ) + '" )'  , 2 )		
			endscan
		endif 

	*-----------------------------------------------------------------------------------------
	function FuncionGrabar() as VOID 
		local lcCursorEntidad as string, lcCursor as string, lcCP as string,;
			lcllEsNuevoYAutoIncremental1 as String,	lcllEsNuevoYAutoIncremental2 as String,;
			lcllEsNuevoYAutoIncremental3 as String 
			
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursorEntidad = .cCursorAtributos
			lcCursor = sys( 2015 ) + "_FuncGrabar"
			
			try
				select * from ( lcCursorEntidad ) ;
					where claveprimaria  and tipodato = "A" ;
					into cursor ( lcCursor )	
				
				if reccount( lcCursor ) = 1
					lcllEsNuevoYAutoIncremental1  = " , llEsNuevoYAutoIncremental as Boolean "
					lcllEsNuevoYAutoIncremental2  = "llEsNuevoYAutoIncremental = .F."
					lcllEsNuevoYAutoIncremental3 = "llEsNuevoYAutoIncremental = .T."
				else
					lcllEsNuevoYAutoIncremental1 = ""
					lcllEsNuevoYAutoIncremental2  = ""
					lcllEsNuevoYAutoIncremental3  = ""
				endif 
					
				.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "Function Grabar() As Void", 1 )

				.AgregarLinea( "Local llRetorno As Boolean, llValidar as boolean, ;", 1 )
				.AgregarLinea( "loEx As Exception, loError As Exception, llNuevo as Boolean, llEdicion as Boolean, llErrorAlValidar as Boolean " + lcllEsNuevoYAutoIncremental1, 1 )
				.AgregarLinea( "" )
				.AgregarLinea( "llValidar = .F.", 1 )
				.AgregarLinea( "This.LimpiarRegistrosDeActividadAlGrabar()", 1 )
				.AgregarLinea( lcllEsNuevoYAutoIncremental2, 1 )
				.AgregarLinea( "" )
				.AgregarLinea( "With This", 1 )
					.AgregarLinea( "llNuevo = .EsNuevo()", 2 )
					.AgregarLinea( "llEdicion = .EsEdicion()", 2 )			
					.AgregarLinea( "if llNuevo or llEdicion", 2 )
						.AgregarLinea( "try", 3 ) 			
							.AgregarLinea( ".lProcesando = .T.", 4 )
							.AgregarLinea( "this.ActualizarProgressBar( 20 )", 4 )
							.AgregarLinea( ".LimpiarInformacion()", 4 )
							.AgregarLinea( "this.ActualizarProgressBar( 30 )", 4 )
							.AgregarLinea( "local lcAgrupadorDeActividad as String", 4 )
							.AgregarLinea( "lcAgrupadorDeActividad = '<GDA:' + sys( 2015 ) + '>'", 4 )
							if This.EsComprobante()	
								.AgregarLinea( "This.IniciarRegistroDeActividad( 'Grabar' )", 4 )
								.AgregarLinea( "goServicios.RegistroDeActividad.HabilitarTrazaExtendidaMensajeria()", 4 )
							Else
								.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'Grabar' )", 4 )
							Endif	
							.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'AntesDeGrabar' )", 4 )
							.AgregarLinea( "If .AntesDeGrabar()", 4 )
								.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'AntesDeGrabar' )", 5 )
								.AgregarLinea( "this.ActualizarProgressBar( 40 )", 5 )
								*!* Validar -------------------------------------------------------------------------------
								.AgregarLinea( "try", 4 )
									.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'Validar' )", 5 )
									.AgregarLinea( "llValidar = .Validar()", 5 )
									.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'Validar' )", 5 )
								.AgregarLinea( "Catch To loError", 4 )
									.AgregarLinea( "llErrorAlValidar = .t.", 5 )
									.AgregarLinea( ".ErrorAlValidar()", 5 )
									.AgregarLinea( "This.EliminarRegistrosDeActividad()", 5 )
									.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", 5 )
								.AgregarLinea( "finally", 4 )
									.AgregarLinea( "if !llErrorAlValidar and !llValidar", 5 )
									.AgregarLinea( ".ErrorAlValidar()", 6 )
									.AgregarLinea( "endif", 5 )
								.AgregarLinea( "endtry", 4 )
								*-----------------------------------------------------------------------------------------
								.AgregarLinea( "this.ActualizarProgressBar( 60 )", 5 )
								.AgregarLinea( "If llValidar", 5 )
									.AgregarLinea( "try", 6 )
										.AgregarLinea( "this.ActualizarProgressBar( 70 )", 7 )
										if .lTieneComponentesEnItemYEntidad
											.AgregarLinea( ".SetearComponentes()", 7 )
										endif
										.AgregarLinea( "this.ActualizarProgressBar( 80 )", 7 )
											.AgregarLinea( "if llNuevo", 7 )
												.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'oAD_Insertar' )", 8 )
												if This.EsComprobante()	
													.AgregarLinea( "this.EventoPorInsertar()", 8 )	
												endif 											
												.AgregarLinea( "lxCodigo = .oAD.Insertar()", 8 )
												.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'oAD_Insertar' )", 8 )
												.AgregarLinea( lcllEsNuevoYAutoIncremental3, 8 )
											.AgregarLinea( "else", 7 )
												.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'oAD_Actualizar' )", 8 )	
												.AgregarLinea( ".oAD.Actualizar()", 8 )
												.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'oAD_Actualizar' )", 8 )												
											.AgregarLinea( "endif", 7 )
										.AgregarLinea( "this.ActualizarProgressBar( 90 )", 7 )
									.AgregarLinea( "Catch To loError", 6 )
										.AgregarLinea( "This.EliminarRegistrosDeActividad()", 7 )
										if this.EsComprobante()
											.AgregarLinea( ".ErrorAlGrabar()", 7 )
										endif
										.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", 7 )
									.AgregarLinea( "Finally", 6 )
									.AgregarLinea( "EndTry", 6 )

								if reccount( lcCursor ) = 1
									.AgregarLinea( "if llEsNuevoYAutoIncremental" , 6 )
										.Agregarlinea( "local llCargandoTemp as boolean", 7 )
										.Agregarlinea( "llCargandoTemp = .lCargando", 7 )
										.Agregarlinea( ".lCargando = .T.", 7 )
										.Agregarlinea( "." + alltrim( &lcCursor..Atributo ) + " = lxCodigo", 7 )
										.Agregarlinea( ".lCargando = llCargandoTemp", 7 )
									.AgregarLinea( "Endif",  6 )
									.AgregarLinea( "" )
								endif 
									.AgregarLinea( "This.IniciarRegistroDeActividadExtendido( 'DespuesDeGrabar' )", 6 )

									.AgregarLinea( "Try" , 6 )
										.AgregarLinea( "llValidar = .DespuesDeGrabar()" , 7 )
									.AgregarLinea( "Catch to loError" , 6 )
										.AgregarLinea( "llValidar = .T." , 7 )
										.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 7 )
										.AgregarLinea( "loEx.Grabar( loError )", 7 )										
										.AgregarLinea( "This.oMensaje.Advertir( 'Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.')" , 7 )
									if This.InformaWebHook()
										.AgregarLinea( "Finally" , 6 )
										.AgregarLinea( ".InformarWebHook()" , 7 )
									endif
									.AgregarLinea( "EndTry" , 6 )
									.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'DespuesDeGrabar' )", 6 )
									.AgregarLinea( "Store .F. To .lEdicion , .lNuevo" , 6 )

								if .lTieneComponentesEnItemYEntidad
									.AgregarLinea( ".actualizarEstado()" , 6 )
								endif
								
								.AgregarLinea( "endif", 5 )
						.AgregarLinea( "endif", 4 )
						.AgregarLinea( "Catch To loError", 3 )
							.AgregarLinea( "This.EliminarRegistrosDeActividad()", 4 )
							.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 4 )
							.AgregarLinea( "With loEx", 4 )
								.AgregarLinea( ".Grabar( loError )", 5 )
								.AgregarLinea( ".Throw()", 5 )
							.AgregarLinea( "EndWith", 4 )
						.AgregarLinea( "finally", 3 )
							.AgregarLinea( ".lProcesando = .F.", 4 )
						.AgregarLinea( "EndTry", 3 )				
					.AgregarLinea( "else", 2 )
						.AgregarLinea( "This.EliminarRegistrosDeActividad()", 3 )
						.AgregarLinea( "local loEx as Object", 3 )
						.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 3 )
						.AgregarLinea( "With loEx", 3 )
								.AgregarLinea( ".Message = 'Error al intentar Grabar'", 4 )
								.AgregarLinea( ".Details = 'No se puede grabar sin estar en estado NUEVO o EDICION'", 4 )
								.AgregarLinea( ".Grabar()", 4 )
								.AgregarLinea( ".Throw()", 4 )
						.AgregarLinea( "endwith", 3 )
					.AgregarLinea( "endif", 2 )
					.AgregarLinea( "", 2 )

					.AgregarLinea( "If llValidar", 2 )
						if this.EsComprobante()
							.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividad( 'Grabar' )", 3 )
							.AgregarLinea( "goServicios.RegistroDeActividad.DeshabilitarTrazaExtendidaMensajeria()", 3 )
						else
							.AgregarLinea( "This.EstablecerTiemposEnRegistroDeActividadExtendido( 'Grabar' )", 3 )
						Endif	
						.AgregarLinea( "lcAgrupadorDeActividad = lcAgrupadorDeActividad + '<PK:' + transform( This." + This.ObtenerAtributoClavePrimaria( this.cTipo ) + " ) + '>'", 3 )
						.AgregarLinea( "This.FinalizarRegistrosDeActividad( lcAgrupadorDeActividad )", 3 )
					.AgregarLinea( "else", 2 )
						.AgregarLinea( "This.EliminarRegistrosDeActividad()", 3 )
						.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 3 )
						.AgregarLinea( "loEx.oInformacion = .ObtenerInformacion()", 3 )
						.AgregarLinea( "loEx.Throw()", 3 )
					.AgregarLinea( "Endif", 2 )

					if empty( .cAtributosGen )
					else
						.AgregarLinea( ".RestaurarGenHabilitar()", 2 )
					endif


				.AgregarLinea( "Endwith", 1 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )
			finally
				use in select( lcCursor )
			endtry
		endwith
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		dodefault()
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.cArchivo = .cPath + "Din_Entidad" + alltrim( Proper( .cTipo ) )+ .cPrefijo + .cSufijo +".prg"
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarObtencionNumero( tcAtributo as String ) as boolean
		local lcCursor as String, lcAtributo as String, llRetorno as boolean

		llRetorno = .f.
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			if .lTieneNumeraciones
				lcCursor = .cCursorRelaNum
				select ( lcCursor )		
				locate for !( "@" $ &lcCursor..Talonario ) and !( "#" $ &lcCursor..Talonario )and empty( &lcCursor..Dependencia ) and alltrim( upper( &lcCursor..Atributo ) ) == alltrim( upper( tcAtributo ) )
				if found()
					lcAtributo = alltrim( &lcCursor..Atributo )
					.AgregarLinea( "if .EsNuevo() and !.VerificarContexto( 'CB' )", 4 )
					.AgregarLinea( "." + lcAtributo + " = .oNumeraciones.ObtenerNumero('" + lcAtributo + "')" , 5 )
					.AgregarLinea( "else", 4 )
					.AgregarLinea( "." + lcAtributo + " = iif( vartype( this." + lcAtributo + " ) = 'C', '', 0 )", 5 )
					.AgregarLinea( "endif", 4 )
					
					llRetorno = .t.
				endif
			endif
		endwith

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarNumeracionRelacionada( tcAtributo ) as Void
		local lcCursor as String, lcAtributo as String, lcAtributosAsignados as  string, lnTab as integer  

		lnTab = 4
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			if .lTieneNumeraciones
				lcAtributosAsignados = ""
				
				lcCursor = sys( 2015 ) + "_NumeracionRelacion"
				
				try
					select Atributo, talonario, dependencia from ( .cCursorRelaNum ) ;
						where !empty( Talonario ) and ;
							  "#" + alltrim( upper( tcAtributo ) ) + "@" $ alltrim( upper( talonario ) ) ;
					union ;
					select Atributo, talonario, dependencia from ( .cCursorRelaNum ) ;
						where !empty( Dependencia ) and ;
							  alltrim( upper( Dependencia ) ) == alltrim( upper( tcAtributo ) );
					into cursor ( lcCursor )
							  
					select ( lcCursor )		
					scan 
						lcAtributo = alltrim( &lcCursor..Atributo )
						if ( "," + lcAtributo + "," ) $ lcAtributosAsignados
						else
							if upper( tcAtributo ) = "LETRA" and inlist( upper( alltrim( this.cTipo ) ), "TICKETFACTURA", "TICKETNOTADECREDITO" )
								.AgregarLinea( "if this.esNuevo()", lnTab )
							else
								.AgregarLinea( "if !empty( lxVal ) and this.esNuevo()", lnTab )
							endif
								.AgregarLinea( "if this.VerificarContexto( 'CB' )", lnTab + 1 )
								.AgregarLinea( "else", lnTab + 1 )
									.AgregarLinea( "this.lCargando = .t." , lnTab + 2 )
									.AgregarLinea( "" )
									.AgregarLinea( "local loError as exception", lnTab + 2 )
									.AgregarLinea( "try" , lnTab + 2 )
										.AgregarLinea( "this." + lcAtributo + " = this.oNumeraciones.ObtenerNumero('" + lcAtributo + "')" , lnTab + 3 )
									.AgregarLinea( "catch to loError" , lnTab + 2 )
									.AgregarLinea( "local loEx as Object" , lnTab + 3 )
									.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )" , lnTab + 3 )
									.AgregarLinea( "With loEx" , lnTab + 3 )
									.AgregarLinea( ".Grabar( loError )" , lnTab + 4 )
									.AgregarLinea( ".Throw()" , lnTab + 4 )
									.AgregarLinea( "endwith" , lnTab + 3 )
									.AgregarLinea( "finally" , lnTab + 2 )
										.AgregarLinea( "this.lCargando = .f." , lnTab + 3 )
									.AgregarLinea( "endtry" , lnTab + 2 )
								.AgregarLinea( "endif", lnTab + 1 )
							.AgregarLinea( "endif", lnTab )
							lcAtributosAsignados = lcAtributosAsignados + "," + lcAtributo + ","
						endif
					endscan
				finally
					use in select ( lcCursor )
				endtry
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCuerpoDestroy( tnTab as integer) as Void
		dodefault( tnTab )

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AgregarLinea( "use in select( '" + .cCursorEntidad + "' )", tnTab + 1 )
			
			if reccount( .cCursorClaveCandidata ) > 0 or reccount( .cCursorClavedeBusqueda ) > 0
				.AgregarLinea( "" )		
				.AgregarLinea( "this.oAtributosCC =  Null" , tnTab + 1 )
			endif 
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosObligatorios() as Void
		local lcCursor as string 
		
		lcCursor = this.cCursorAtributos
		
		try
			select * from &lcCursor where Obligatorio into cursor c_acotados
			
			this.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			this.agregarLinea( "function obtenerAtributosObligatorios() as ZooColeccion", 1 )
			this.agregarLinea( "local loAtributosObligatorios as ZooColeccion", 2 )
			this.agregarLinea( "loAtributosObligatorios = _screen.zoo.CrearObjeto( 'zoocoleccion' )", 2)

			scan 
				this.agregarLinea( "loAtributosObligatorios.add( '" + alltrim( upper( c_Acotados.Atributo ) ) + "' )", 2 )			
			endscan

			this.agregarLinea( "return loAtributosObligatorios" , 2)
			this.agregarLinea( "" )
			this.agregarLinea( "endfunc", 1)
		finally
			use in select( "c_acotados" )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Funcion_Nuevo() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Protected Function _Nuevo() As Boolean", 1 )
			.agregarLinea( "" )
				.agregarLinea( "if this.EsNuevo()", 2 )
					.agregarLinea( [goServicios.Errores.LevantarExcepcion( "Cancele o grabe antes de intentar hacer 'Nuevo'." )], 3 )
				.agregarLinea( "else", 2 )
					.agregarLinea( "With This", 3 )
					if .VerificaIncluirVotacion()
						.GenerarVotacionNuevo( 4 )
					endif
											
						.agregarLinea( ".lEdicion = .F.", 4 )
						.agregarLinea( ".lAnular = .F.", 4 )
						.agregarLinea( ".lNuevo = .T.", 4 )

						if .lTieneFuncionalidadGuardarComo 
							.agregarLinea( ".lEsGuardarComo = .F.", 4 )
						endif

						.agregarLinea( ".limpiar()", 4 )

						select( .cCursorAtributos )
						locate for ClavePrimaria and EsGuid
						if found()
							.agregarLinea( "." + alltrim( Atributo ) + " = goLibrerias.ObtenerGuidPk() ", 4 )
						EndIf	

						if .lTieneComponentesEnItemYEntidad
							.agregarLinea( ".actualizarEstado()", 4 )
							.agregarLinea( ".SetearColeccionSentenciasAnterior_NUEVO()", 4 )
						endif
					.agregarLinea( "endwith", 3 )
				.agregarLinea( "endif", 2 )
				.agregarLinea( "" )
				.agregarLinea( "dodefault()", 2 )
				.agregarLinea( "This.InicializarComponentes( .T. )", 2 )			

			.agregarLinea( "" )
			.agregarLinea( "endfunc", 1)
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarVotacionNuevo( tnTab as Integer ) as Void
		With this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "" )
			.agregarLinea( "Local llVotacion as boolean", tnTab )
			.GenerarLineaVotacionCambioEstado( tnTab, "Nuevo" )

			.agregarLinea( "" )
			.agregarLinea( "if llVotacion", tnTab )
			.agregarLinea( "else", tnTab )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( this.oInformacion )", tnTab + 1 )
			.agregarLinea( "Endif", tnTab )				
			.agregarLinea( "" )
		EndWith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarLineaVotacionCambioEstado( tcTab as Integer, tcAccion as String ) as Void
		This.agregarLinea( "llVotacion = .VotacionCambioEstado" + alltrim( tcAccion ) + "( .ObtenerEstado() )", tcTab )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Funcion_EliminarSinValidaciones() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg

			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Protected function _EliminarSinValidaciones() as Void", 1 )
			.agregarLinea( "Local llValidacion as boolean, llVotacion as boolean, loEx as exception", 2 )
			.agregarLinea( "llVotacion = .T.", 2 )
			.agregarLinea( "With This", 2 )
			.agregarLinea( "if .lEliminar", 3 )
			.agregarLinea( "llValidacion = .ValidarPK()", 4 )
			
			.agregarLinea( "If llValidacion", 4 )

			.AgregarCodigoParaVotacion( "Eliminar", .t., 5 )

			.agregarLinea( ".SetearColeccionSentenciasAnterior_Eliminar()", 4 )
			.agregarLinea( "Store .F. To .lEdicion, .lNuevo", 5 )
			.agregarLinea( ".oAD.Eliminar()", 5 )
			
			if .lTieneComponentesEnItemYEntidad
				.agregarLinea( ".actualizarEstado()", 5 )
			endif
			
			.agregarLinea( "else", 4 )
			.agregarLinea( "loEx = _screen.zoo.crearObjeto( 'zooException' )", 5 )
			.agregarLinea( "loEx.oInformacion = this.oInformacion", 5 )
			.agregarLinea( "loEx.throw()", 5 )
			.agregarLinea( "endif", 4 )
			.agregarLinea( "endif", 3 )
			.agregarLinea( "Endwith", 2 )
			.agregarLinea( "" )
			.agregarLinea( "dodefault()", 1 )
			.agregarLinea( "" )
			.agregarLinea( "Endfunc", 1 )
			
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Funcion_Modificar() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Protected Function _Modificar() As void", 1 )
			.agregarLinea( "Local llValidacion as boolean, llVotacion as boolean, loEx as exception", 2 )
			.agregarLinea( "" )
			.agregarLinea( "With This", 2 )
			.agregarLinea( "llValidacion = .ValidarPK()", 3 )

			.agregarLinea( "If llValidacion", 3 )
			.agregarLinea( ".Buscar()", 4 )
			.agregarLinea( ".Cargar()", 4 )

			.AgregarCodigoParaVotacion( "Modificar", .t., 4 )

			.agregarLinea( ".SetearColeccionSentenciasAnterior_MODIFICAR()", 4 )
			.agregarLinea( ".lEdicion = .T.", 4 )
			.agregarLinea( ".lNuevo = .F.", 4 )
			.agregarLinea( ".lAnular = .F.", 4 )

			if this.VerificarFuncionalidad( this.cTipo, "ANULABLE" )
				.agregarLinea( "*****Esta linea se genera solo para entidades anulables", 4 )			
				.agregarLinea( ".Anulado = .F.", 4 )
			endif
			
			if .lTieneComponentesEnItemYEntidad
				.agregarLinea( ".actualizarEstado()", 4 )
			endif
			
			.agregarLinea( "else", 3 )
			.agregarLinea( "loEx = _screen.zoo.crearObjeto( 'zooException' )", 4 )
			.agregarLinea( "loEx.oInformacion = this.oInformacion", 4 )
			.agregarLinea( "loEx.Throw()", 4 )
			.agregarLinea( "Endif", 3 )
			.agregarLinea( "Endwith", 2 )
			.agregarLinea( "" )
			.agregarLinea( "dodefault()", 1 )
			.agregarLinea( "" )
			.agregarLinea( "Endfunc", 1 )

		EndWith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Funcion_Cancelar() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg

			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Protected Function _Cancelar() As void", 1 )
			.agregarLinea( "local loEx As zooException of zooException.prg ", 2 )
			.agregarLinea( "" )
			.agregarLinea( "With This", 2 )
			.agregarLinea( "" )

			.AgregarCodigoParaVotacion( "Cancelar", .f., 3 )

			.agregarLinea( "Do Case", 3 )
			.agregarLinea( "case .lNuevo", 4 )
			.agregarLinea( "Store .F. To .lEdicion, .lNuevo", 5 )
			.agregarLinea( ".limpiar()", 5 )
			.agregarLinea( "" )
			.agregarLinea( "case !.lNuevo and !.lEdicion", 4 )
			.agregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 5 )
			.agregarLinea( "With loEx", 5 )
			.agregarLinea( ".Message = 'Error al intentar hacer cancelar'", 6 )
			.agregarLinea( [.Details = "Para hacer 'Cancelar' debe estar en modo Nuevo o Edicion"], 6 )
			.agregarLinea( ".Grabar()", 6 )
			.agregarLinea( ".Throw()", 6 )
			.agregarLinea( "endwith", 5 )
			.agregarLinea( "" )
			.agregarLinea( "otherwise", 4 )
			.agregarLinea( ".Buscar()", 5 )
			.agregarLinea( ".Cargar()", 5 )
			.agregarLinea( "Store .F. To .lEdicion, .lNuevo", 5 )
			.agregarLinea( "" )
			.agregarLinea( "EndCase", 3 )

			if empty( .cAtributosGen )
			else
				.AgregarLinea( ".RestaurarGenHabilitar()", 3 )
			endif
			
			if .lTieneComponentesEnItemYEntidad
				.agregarLinea( ".actualizarEstado()", 3 )
			endif
			
			.agregarLinea( "EndWith", 2 )
			.agregarLinea( "" )
			.agregarLinea( "dodefault()", 2 )
			.agregarLinea( "" )
			.agregarLinea( "Endfunc", 1 )
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarCodigoParaVotacion( tcEvento as String, tlIniciaComponentes as Boolean, tnTab as Integer ) as Void

		if .VerificaIncluirVotacion()
			if tlIniciaComponentes
				.agregarLinea( ".InicializarComponentes()", 5 )
			Endif
			.GenerarLineaVotacionCambioEstado( tnTab, tcEvento )
			.agregarLinea( "if llVotacion", tnTab )
			.agregarLinea( "else", tnTab )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( this.oInformacion )", tnTab + 1 )
			.agregarLinea( "Endif", tnTab )				
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificaIncluirVotacion() as Boolean
		local lnCantidadRegistos as Integer, lcCursorRela as String 
	
		lcCursorRela = This.ObtenerCursorComponenteRela()
		
		try
			select &lcCursorRela
			count to lnCantidadRegistos
		finally
			use in select( lcCursorRela )
		endtry
		
		return ( lnCantidadRegistos > 0 )		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorComponenteRela() as String
		local lcCursorTemp as String, lcCursorDetalles as String , lcCondicion as String 
		lcCursorTemp = sys( 2015 ) + "_CursorCompRela1"
		lcCursorDetalles = sys( 2015 ) + "_CursorCompRela2"

		lcCondicion = "upper( alltrim( Entidad ) ) == '" + upper( alltrim ( This.cTipo ) ) + "'"

		try
			select substr( dominio , 8 ) as dominio, atributo ;
				from c_diccionario ;
				where &lcCondicion and ;
					upper( alltrim( Left( dominio, 7 ) ) ) = "DETALLE" ;
				into cursor &lcCursorDetalles 

			select componente, space( 40 ) as atributo from c_relacomponente ;
				where &lcCondicion  ;
			union all ;
				select r.componente, d.Atributo from c_relacomponente r inner join &lcCursorDetalles D ;
					on upper( alltrim( r.Entidad ) ) = upper( alltrim( d.Dominio ) ) ;
			into cursor &lcCursorTemp	
		finally
			use in select( lcCursorDetalles )
		endtry
		
		return lcCursorTemp	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarComponentesEnItemYEntidad() as Boolean
		local lcCursorTemp as String, llRetorno as Boolean, lcCondicion as String

		lcCursorTemp = sys( 2015 ) + "_ComponenteEnItemYEnt1"
		lcCursorRela = sys( 2015 ) + "_ComponenteEnItemYEnt2"
		lcCondicion = "upper( alltrim( Entidad ) ) == '" + upper( alltrim ( This.cTipo ) ) + "'"
		
		try
			select distinc upper( entidad ) as entidad from c_entidad ;
					where &lcCondicion  ;
				union all;
					select distinc upper( entidad ) as entidad from c_diccionario ;
						where upper( entidad ) in ( select upper( substr( dominio, 8 ) ) as dominio ;
											from c_diccionario where left(dominio,7) == "DETALLE" and &lcCondicion );
				Into Cursor &lcCursorTemp
		
			select Entidad from c_relacomponente where upper( Entidad ) in ( select entidad from &lcCursorTemp ) into cursor &lcCursorRela

			llRetorno = reccount( lcCursorTemp ) > 0
		finally
			use in select( lcCursorTemp )
			use in select( lcCursorRela )
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionBuscar() as VOID
		local lnTab as Integer
		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "Protected Function _Buscar() As void", lnTab )
				.agregarLinea( "local llRetorno as Boolean, loEx as Exception, lcAtributo as String, lcMensaje as String", lnTab + 1 )
				.agregarLinea( "" )
				.agregarLinea( "lcAtributo = This.ObtenerAtributoClavePrimaria()", lnTab + 1 )
				.agregarLinea( "if empty( This.&lcAtributo )", lnTab + 1 )
				.agregarLinea( "llRetorno = this.oAD.ConsultarPorClaveCandidata()", lnTab + 2 )
				if reccount( .cCursorClavedeBusqueda ) > 0
					.agregarLinea( "lcMensaje = " + .ObtenerMensajeClavePrimaria() , lnTab + 2 )
				else
					.agregarLinea( "lcMensaje = " + .ObtenerMensajeClaveCandidata() , lnTab + 2 )
				endif
				.agregarLinea( "else", lnTab + 1 )
					.agregarLinea( "llRetorno = this.oAD.ConsultarPorClavePrimaria()", lnTab + 2 )
					.agregarLinea( "lcMensaje = " + This.ObtenerMensajeClavePrimaria(), lnTab + 2 )
				.agregarLinea( "endif", lnTab + 1 )
				.agregarLinea( "if llRetorno", lnTab + 1 )
				.agregarLinea( "else", lnTab + 1 )
					.agregarLinea( "goServicios.Errores.LevantarExcepcion( lcMensaje )", lnTab + 2 )
				.agregarLinea( "endif", lnTab + 1 )
			.agregarLinea( "endfunc	", lnTab )
		endwith
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeClavePrimaria( tcVal as String ) as String
		local lcRetorno As String

		if pcount() = 0
			lcRetorno = "'El dato buscado ' + alltrim( transform( This."  + This.cAtributoClavePrimaria  + " ) ) + ' de la entidad ' + upper( this.cDescripcion ) + ' no existe.'"
		else
			lcRetorno = "'El dato buscado ' + alltrim( transform( "  + tcVal  + " ) ) + ' de la entidad ' + upper( this.cDescripcion ) + ' no existe.'"			
		endif
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeClaveCandidata() as String
		local lcCursor As String, lcAtributoBusqueda as String, lcRetorno as String

		lcCursor = sys( 2015 ) + "_MensajeClavCandidata"
		lcRetorno = ""
		lcAtributoBusqueda  = ""

		try
			select * ;
				from ( this.cCursorAtributos ) ;
				into cursor &lcCursor nofilter ;
				where !ClavePrimaria and !empty( ClaveCandidata ) and !empty(Campo) and !detalle And alltrim( upper( Tabla ) ) == upper( alltrim( This.cTabla ) ) ; 
				order by ClaveCandidata
				
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				select( lcCursor )
				scan
					lcAtributoBusqueda = lcAtributoBusqueda + upper( alltrim( iif( empty( alltrim( etiqueta ) ), atributo, etiqueta ) ) ) + " ' + transform( This." ;
											+ alltrim( atributo ) + iif( EsEntidad,"_Pk", "" ) + " ) + ', "
					select( lcCursor )
				endscan
				lcAtributoBusqueda = substr( lcAtributoBusqueda , 1, len( lcAtributoBusqueda ) - 2 ) 
				lcRetorno = "'El dato buscado " + alltrim( lcAtributoBusqueda ) + " de la entidad ' + upper( this.cDescripcion ) + ' no existe.'"
			endwith
		finally
			use in select( lccursor )
		endtry
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionAuditoria() as zoocoleccion OF zoocoleccion.prg
		local loCol as zoocoleccion OF zoocoleccion.prg
		loCol = _screen.zoo.crearobjeto( "zoocoleccion" )
		
		select c_Entidad
		scan for this.oFunc.TieneFuncionalidad( "AUDITORIA" , c_Entidad.Funcionalidades )
			loCol.Agregar( upper( alltrim( c_Entidad.Entidad ) ) )
		endscan
		return loCol
	Endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionGenerarSetearColeccionSentenciasAnterior() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.FuncionSetearColeccionSentenciasAnterior( "NUEVO" )
			.FuncionSetearColeccionSentenciasAnterior( "MODIFICAR" )
			.FuncionSetearColeccionSentenciasAnterior( "ANULAR" )
			.FuncionSetearColeccionSentenciasAnterior( "ELIMINAR" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionSetearColeccionSentenciasAnterior( tcEstado as String ) as Void
		local lcCursor as String, lcAtributo as String 

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			try
				lcCursor = This.ObtenerCursorComponenteRela()
				
				select &lcCursor
				go top
				.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function SetearColeccionSentenciasAnterior_" + upper( alltrim( tcEstado ) ) + "() as Void", 1 )
				.AgregarLinea( "" , 1 )	
				.AgregarLinea( "dodefault()" , 2 )	
				scan
					lcAtributo = "oComp" + alltrim( &lcCursor..componente )
					if empty( alltrim( &lcCursor..Atributo ) )
					else
						lcAtributo = alltrim( &lcCursor..Atributo ) + ".oItem." + lcAtributo
					endif
					.AgregarLinea( "this." + lcAtributo + ".SetearColeccionSentenciasAnterior_" + upper( alltrim( tcEstado ) ) + "()" , 2 )
					select &lcCursor
				endscan
				.AgregarLinea( "" , 1 )	
				.AgregarLinea( "Endfunc", 1 )
			finally
				use in select( lcCursor )
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Funcion_Anular() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Protected Function _Anular() As void", 1 )
			.agregarLinea( "with this", 2 )
			.agregarLinea( ".buscar()", 3 )
			.agregarLinea( ".Cargar()", 3 )
			.agregarLinea( "if pemstatus( this, 'oCompEnBaseA', 5 )", 3 )
			.agregarLinea( ".ValidarComprobantesAfectantes( 'Anular' )", 4 )
			.agregarLinea( "endif", 3 )
			.agregarLinea( ".InicializarComponentes()", 3 )
			.agregarLinea( "if .VotacionCambioEstadoAnular( .ObtenerEstado() )", 3 )
			.agregarLinea( "else", 3 )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( this.oInformacion )", 4 )
			.agregarLinea( "endif", 3 )
			.agregarLinea( "endwith", 2 )
			.agregarLinea( "endfunc", 1 )
			.Funcion_ObtenerAtributosAnulacion()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Funcion_ObtenerAtributosAnulacion() as Void
		this.oGenAtributosAnulacionerador.Generar( this.cTipo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Funcion_ObtenerAtributosAnulacionVieja() as Void
		local lcCurAtributos as String 

		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Function ObtenerAtributosAnulacion() As void", 1 )
			.agregarLinea( "Dodefault()", 2 )
			.agregarLinea( "with this", 2 )
			
			lcCurAtributos = .cCursorAtributos
			select( lcCurAtributos )
			scan for &lcCurAtributos..ClavePrimaria or !empty( &lcCurAtributos..ClaveCandidata )
				.agregarLinea( "loItem = _screen.zoo.CrearObjeto( 'ItemAtributoAnulacion', 'Entidad.prg' )", 3 )
				.agregarLinea( "loItem.cAtributo = '" + alltrim( &lcCurAtributos..atributo ) + "'", 3 )
				.agregarLinea( "loItem.xValor = ." + alltrim( &lcCurAtributos..atributo ) , 3 )
				.agregarLinea( ".oAtributosAnulacion.Add( loItem )", 3 )
			endscan		
			
			select ( lcCurAtributos )
			go top
			locate for alltrim( upper( campo ) ) == alltrim( upper( "TIMESTAMP" ))
			if found()
				.agregarLinea( "loItem = _screen.zoo.CrearObjeto( 'ItemAtributoAnulacion', 'Entidad.prg' )", 3 )
				.agregarLinea( "loItem.cAtributo = 'Timestamp'", 3 )
				.agregarLinea( "loItem.xValor = .Timestamp", 3 )
				.agregarLinea( ".oAtributosAnulacion.Add( loItem )", 3 )
			endif
				
			.agregarLinea( "loItem = _screen.zoo.CrearObjeto( 'ItemAtributoAnulacion', 'Entidad.prg' )", 3 )
			.agregarLinea( "loItem.cAtributo = 'Anulado'", 3 )
			.agregarLinea( "loItem.xValor = .T.", 3 )
			.agregarLinea( ".oAtributosAnulacion.Add( loItem )", 3 )
			
			select c_atributosGenericos
			scan for tipo = "E"
				.agregarLinea( "loItem = _screen.zoo.CrearObjeto( 'ItemAtributoAnulacion', 'Entidad.prg' )", 3 )
				.agregarLinea( "loItem.cAtributo = '" + alltrim( c_atributosGenericos.atributo ) + "'", 3 )
				.agregarLinea( "loItem.xValor = ." + alltrim( c_atributosGenericos.atributo ) , 3 )
				.agregarLinea( ".oAtributosAnulacion.Add( loItem )", 3 )
			endscan
			
			.agregarLinea( "endwith", 2 )
			.agregarLinea( "endfunc", 1 )
		
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFuncionalidades() as Void
		local lcFuncionalidades as string, llContinuar as Boolean, lcLinea as String


		lcFuncionalidades = upper( this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) ) )
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ObtenerFuncionalidades() as String", 1 )
			if len( lcFuncionalidades ) > 250
				lcLinea = "return "
				llContinuar = .t.
				do while llContinuar
					lnAt = at( "><", lcFuncionalidades ) 
					if lnAt > 0
						lcAux = substr( lcFuncionalidades, 1, lnAt )
						lcFuncionalidades = right( lcFuncionalidades, len( lcFuncionalidades ) - len( lcAux ) )
						lcLinea = lcLinea + "'" + lcAux + "' + "
					else
						lcLinea = lcLinea + "'" + lcFuncionalidades + "' + "
						llContinuar = .f.
					endif
				enddo
				.AgregarLinea( left( lcLinea , len( lcLinea ) - 2 ) , 2 )								
			else
				.AgregarLinea( "return '" + lcFuncionalidades + "'" , 2 )			
			endif
			.AgregarLinea( "Endfunc", 1 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarLimpiarAD( tnTab as Integer ) as Void
		dodefault( tnTab )
		this.AgregarLinea( ".oAD.Limpiar()", tnTab)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionGuardarComo() as Void
		if this.lTieneFuncionalidadGuardarComo
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function GuardarComo() as void", 1 )
				.AgregarLinea( "if !this.ValidarPK()", 2 )
				.AgregarLinea( [goServicios.Errores.LevantarExcepcion( "Seleccione un registro antes de intentar hacer 'Guardar como...'.")], 3 )
				.AgregarLinea( "else", 2 )
				.AgregarLinea( "With This", 3 )
				.AgregarLinea( "._EsRegistroGuardableComo()", 4 )
				.AgregarLinea( ".lEdicion = .F.", 4 )
				.AgregarLinea( ".lEsGuardarComo = .T.", 4 )
				.AgregarLinea( ".cCodigoPrevioGuardarComo = this."+This.cAtributoClavePrimaria, 4 )
				.AgregarLinea( ".lAnular = .F.", 4 )
				.AgregarLinea( ".lNuevo = .T.", 4)

				if this.VerificarFuncionalidad( this.cTipo, "BLOQUEARREGISTRO" )
					.AgregarLinea( ".BLOQUEARREGISTRO = .f." , 4)
				endif
				.AgregarLinea( "if this.DebeSugerirCodigo()" , 4 )
				.AgregarLinea( "this.SetearCodigoSugerido()" , 5 )
				.AgregarLinea( "endif" , 4 )
				.AgregarLinea( ".actualizarEstado()", 4 )
				.AgregarLinea( ".SetearColeccionSentenciasAnterior_NUEVO()", 4 )
				.AgregarLinea( "endwith", 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "dodefault()", 2 )
				.AgregarLinea( "This.InicializarComponentes( .T. )", 2 )
				.AgregarLinea( "This.Zadsfw = ''", 2 )
				.AgregarLinea( "endfunc", 1 )
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarSeteoFlagCargandoSugeridos( tcFlag as String  , tnTabulado as Integer  ) as Void
		this.agregarLinea( ".lEstaSeteandoValorSugerido = " + tcFlag , tnTabulado )
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionSetearCodigoSugeridoEnLimpiar() as Void
		local lnTab as Number
		lnTab = 1
		if this.VerificarFuncionalidad( this.cTipo, "CODIGOSUGERIDO" )
			.agregarLinea( "if this.EsNuevo() and this.DebeSugerirCodigo() and this.EstaEnProceso()", lnTab + 2 )
			.agregarLinea( "this.SetearCodigoSugerido()", lnTab + 3 )
			.agregarLinea( "endif", lnTab + 2 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	 function FuncionSetearCodigoSugerido() as Void
		local lnTab as integer, lcAtributoClavePrimaria as String 

		lnTab = 1
		if this.VerificarFuncionalidad( this.cTipo, "CODIGOSUGERIDO" )
			lcAtributoClavePrimaria = This.ObtenerAtributoClavePrimaria( this.cTipo )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function SetearCodigoSugerido() as void", lnTab )
				.agregarLinea( "this." + alltrim( lcAtributoClavePrimaria ) + " = This.oComportamientoCodigoSugerido.ObtenerCodigoDisponible( this )", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
			endwith
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	 function FuncionDebeSugerirCodigo() as Void
		local lnTab as integer

		lnTab = 1
		if this.VerificarFuncionalidad( this.cTipo, "CODIGOSUGERIDO" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function DebeSugerirCodigo() as Boolean", lnTab )
				.agregarLinea( "return this.oComportamientoCodigoSugerido.Sugerir", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
			endwith
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarOmisionValidarExistencia() 
		local lcCursor as String, lcFuncion as String    
		
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = sys( 2015 ) + "_OmisionValidarExistencia"
			lcCursorEntidad = .cCursorAtributos	

			try
				select c_Ent.atributo ;
				from ( lcCursorEntidad ) c_Ent, ( .cCursorRelaNum ) c_Num ;
				where claveprimaria and alltrim( upper( c_Ent.Atributo ) ) == alltrim( upper( c_Num.Atributo ) ) ;
				into cursor ( lcCursor )

				if reccount( lcCursor ) > 0
					text to lcFuncion noshow 
	*-----------------------------------------------------------------------------------------
	protected Function ValidarExistencia() As Boolean
		local llRetorno as Boolean
		if This.EsNuevo()
			llRetorno = .F.
		else
			llRetorno = dodefault()
		endif
		return llRetorno
	endfunc	
					endtext
				
					.AgregarLinea( lcFuncion , 4)
				endif
			finally
				use in select( lcCursor )
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerIdPorClaveCandidata() as string
		local lcAtributoClavePrimaria as String
		
		if reccount( this.cCursorClaveCandidata ) > 0 or reccount( this.cCursorClaveDeBusqueda ) > 0
			lnTab = 1
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function ObtenerIdPorClaveCandidata() as variant", lnTab )
				.agregarLinea( "return this.oAd.ObtenerIdPorClaveCandidata()", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function AgregarAccesoDesactivador() as Void
		local lnTab as Integer

		lnTab = 1
		if this.lTieneFuncionalidadDesactivable 
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "" )
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "function oDesactivador_Access() as object", lnTab )
					.agregarLinea( "if !this.ldestroy and ( !vartype( this.oDesactivador ) = 'O' or isnull( this.oDesactivador ) )", lnTab + 1 )
						.agregarLinea( [this.oDesactivador = desactivadorfactory( this )], lnTab + 2 )
					.agregarLinea( "endif", lnTab + 1 )
					.agregarLinea( "return this.oDesactivador", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
			endwith
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtenerDetalleAInsertar() as Void
		local lnTab as Integer, lcCursor as String

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = this.cCursorAtributos
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerDetalleaInsertar() as detalle of detalle.prg", lnTab )
				select atributo from &lcCursor dic where "<COPIADETALLE>" $ dic.tags into cursor "c_atributodetalleinsertar"
				if _tally > 0
					.agregarLinea( "return this." + alltrim( c_atributodetalleinsertar.Atributo ) , lnTab + 1 )
				endif
			.agregarLinea( "endfunc", lnTab )
			use in select( "c_atributodetalleinsertar" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarMetodoObtenerNombreDetallesConPrePantalla() as Void
		local lnTab as Integer, lcCursor as String

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = this.cCursorAtributos
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerNombreDetallesConPrePantalla() as ZooColeccion of ZooColeccion.prg", lnTab )

				.agregarLinea( [local loRetorno as ZooColeccion OF ZooColeccion.prg], lnTab + 1 )
				.agregarLinea( [loRetorno = _screen.zoo.CrearObjeto("ZooColeccion")], lnTab + 1 )

				select atributo from &lcCursor dic where "<SOPORTAPREPANTALLA>" $ dic.tags into cursor "c_atributodetalleprepantalla"
				if _tally > 0
					select c_atributodetalleprepantalla
					scan
						.agregarLinea( [loRetorno.Agregar("] + alltrim( c_atributodetalleprepantalla.Atributo ) + [")], lnTab + 1 )
					endscan
				endif

				.agregarLinea( [return loRetorno], lnTab + 1 )

			.agregarLinea( "endfunc", lnTab )
			use in select( "c_atributodetalleinsertar" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarMetodoTieneDetallesConPrePantalla() as Void
		local lnTab as Integer, lcCursor as String

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = this.cCursorAtributos
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function TieneDetallesConPrePantalla() as Boolean", lnTab )

				.agregarLinea( [local llRetorno as Boolean], lnTab + 1 )

				select atributo from &lcCursor dic where "<SOPORTAPREPANTALLA>" $ dic.tags into cursor "c_atributodetalleprepantalla"
				if _tally > 0
					.agregarLinea( [llRetorno = .t.], lnTab + 1 )
				else
					.agregarLinea( [llRetorno = .f.], lnTab + 1 )
				endif

				.agregarLinea( [return llRetorno], lnTab + 1 )

			.agregarLinea( "endfunc", lnTab )
			use in select( "c_atributodetalleinsertar" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtenerAtributoDetalleAInsertar() as Void
		local lnTab as Integer, lcCursor as String

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = this.cCursorAtributos
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerAtributoDetalleaInsertar() as detalle of detalle.prg", lnTab )
				select atributo from &lcCursor dic where "<COPIADETALLE>" $ dic.tags into cursor "c_atributodetalleinsertar"
				if _tally > 0
					.agregarLinea( "return '" + alltrim( c_atributodetalleinsertar.Atributo ) + "'" , lnTab + 1 )
				endif
			.agregarLinea( "endfunc", lnTab )
			use in select( "c_atributodetalleinsertar" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function AgregarMetodoEsRegistroGuardableComo() as Void
		local lnTab as Integer

		lnTab = 1
		if this.lTieneFuncionalidadGuardarComo
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "" )
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.agregarLinea( "protected function _EsRegistroGuardableComo() as Void", lnTab )
					.agregarLinea( "local lcMotivo as String", lnTab + 1 )
					.agregarLinea( "", lnTab + 1 )
					.agregarLinea( "lcMotivo = ''", lnTab + 1 )
					.agregarLinea( "if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )", lnTab + 1 )
						.agregarLinea( "lcMotivo = ' porque pertenece a una base réplica.'", lnTab + 2 )
					.agregarLinea( "endif", lnTab + 1 )
					.agregarLinea( "if !empty( lcMotivo )", lnTab + 1 )
						.agregarLinea( "goServicios.Errores.LevantarExcepcion( 'El registro de la entidad ' + alltrim( this.cDescripcion ) + ' no puede guardarse como' + lcMotivo )", lnTab + 2 )
					.agregarLinea( "endif", lnTab + 1 )
				.agregarLinea( "endfunc", lnTab )
			endwith
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function AgregarAsignarValoresSugeridosAtributosClaveCandidataNoVisibles() as Void
		local lnTab as Integer

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function AsignarValoresSugeridosAtributosClaveCandidataNoVisibles() as Void", lnTab )
			
			lcCursor = this.cCursorAtributos
			
			select atributo from &lcCursor dic where !alta and !empty( valorsugerido ) and clavecandidata > 0 into cursor "c_atributoCandidata"
			if _tally > 0
				select c_atributoCandidata
				scan
					.agregarLinea( "This.ValorSugerido" + alltrim( c_atributoCandidata.atributo ) + "()", lnTab + 1 )
				endscan
			endif
			use in select( "c_atributoCandidata" )
			
			.agregarLinea( "endfunc", lnTab )
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function AgregarAsignarValoresSugeridosAtributosClaveDeBusquedaNoVisibles() as Void
		local lnTab as Integer

		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function AsignarValoresSugeridosAtributosClaveDeBusquedaNoVisibles() as Void", lnTab )
			
			lcCursor = this.cCursorAtributos
			
			select atributo from &lcCursor dic where !alta and !empty( valorsugerido ) and upper(alltrim(dominio))=="CLAVEDEBUSQUEDA" into cursor "c_atributoBusqueda"
			if _tally > 0
				select c_atributoBusqueda
				scan
					.agregarLinea( "This.ValorSugerido" + alltrim( c_atributoBusqueda.atributo ) + "()", lnTab + 1 )
				endscan
			endif
			use in select( "c_atributoBusqueda" )
			
			.agregarLinea( "endfunc", lnTab )
		endwith

	endfunc	
	
	*
	* Funciones que generan los atributos para el manejo del combo de agrupamientos en la toolbar
	*-----------------------------------------------------------------------------------------
	protected function GenerarAtributoFuncionalidadPublica() as Void
		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarLinea( "" )
				.agregarlinea( "lUsaAgrupamientoPublicaciones = .T.", 1 )
			endwith 
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarAtributoValorComboToolbar() as Void
		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarlinea( "cValorComboToolbar = ''", 1 )	
			endwith 
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarAtributoValorComboToolbarAnterior() as Void
		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.agregarlinea( "cValorComboToolbarAnterior = 'Todas'", 1 )	
			endwith 
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCargarCadenaAgrupamientosParaComboToolbar() as Void
		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.AgregarLinea( "", 1 )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
				.agregarlinea( "function CargarCadenaAgrupamientosParaComboToolbar( tnOpcion as Integer ) as String", 1 )
				.AgregarLinea( "local cCadenaAgrupamientos as String, lnItem as Integer, llHayDatos as Boolean", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "cCadenaAgrupamientos = ''", 2 )
				.AgregarLinea( "llHayDatos = .F.", 2 )
				.AgregarLinea( "for lnItem = 1 to This.AgruPubliDetalle.Count", 2 )
				.AgregarLinea( "if !empty( alltrim( This.AgruPubliDetalle.Item[lnItem].Agrupamiento_PK ) )", 3 )
				.AgregarLinea( "cCadenaAgrupamientos = cCadenaAgrupamientos + alltrim( This.AgruPubliDetalle.Item[lnItem].Agrupamiento_PK ) + '; '", 4 )
				.AgregarLinea( "llHayDatos = .T.", 4 )
				.AgregarLinea( "endif", 3 )
				.AgregarLinea( "endfor", 2 )
				.AgregarLinea( "if llHayDatos", 2 )
				.AgregarLinea( "cCadenaAgrupamientos = left( cCadenaAgrupamientos , len( cCadenaAgrupamientos ) - 2 )", 3 )
				.AgregarLinea( "if tnOpcion == 1", 3 )
				.AgregarLinea( "if len( cCadenaAgrupamientos ) > 21", 4 )
				.AgregarLinea( "cCadenaAgrupamientos = substr( cCadenaAgrupamientos, 1, 21 ) + '...'", 5 )
				.AgregarLinea( "endif", 4 )
				.AgregarLinea( "endif", 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "", 2 )
				.AgregarLinea( "Return cCadenaAgrupamientos", 2 )
				.AgregarLinea( "endfunc", 1 )
			endwith 
		endif
	endfunc
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionLimpiarDatosDetalleAgrupamientoPublicaciones() as Void	
		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.AgregarLinea( "", 1 )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
				.agregarlinea( "function LimpiarDatosDetalleAgrupamientoPublicaciones() as Void", 1 )
				.AgregarLinea( "local lnItem as Integer", 2 )
				.AgregarLinea( "for lnItem = 1 to This.AgruPubliDetalle.Count", 2 )
				.AgregarLinea( "This.AgruPubliDetalle.oItem.Limpiar()", 3 )
				.AgregarLinea( "This.AgruPubliDetalle.CargarItem( lnItem )", 3 )
				.AgregarLinea( "This.AgruPubliDetalle.oItem.Limpiar()", 3 )
				.AgregarLinea( "endfor", 2 )
				.AgregarLinea( "endfunc", 1 )
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionSeteoValorComboToolbarPorDefecto() as Void

		if This.VerificarFuncionalidad( This.cTipo, "PUBLICA" )
			with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
				.AgregarLinea( "", 1 )
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
				.AgregarLinea( "protected function SetearValorComboPorDefecto() as Void", 1 )
				.AgregarLinea( "this.EventoSetearValorComboPorDefecto()", 2 )
				.AgregarLinea( "Endfunc", 1 )
				
				.AgregarLinea( "", 1 )	
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
				.AgregarLinea( "function EventoSetearValorComboPorDefecto() as Void", 1 )
				.AgregarLinea( "endfunc", 1 )
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCargarColeccionDeAtributosConEdicionRestringida() as Void
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.AgregarLinea( "", 1 )
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "protected function CargarColeccionDeAtributosConEdicionRestringida() as Void", 1 )
			this.CargarColeccionDeAtributosConEdicionRestringida( 2 )
			.AgregarLinea( "Endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarColeccionDeAtributosConEdicionRestringida( tnTab as Integer ) as Void
		local lcNombreAtributo as String
		select atributo ;
			from c_diccionario ;
			where entidad = this.cTipo and "<EDICIONPARCIAL>" $ upper( tags ) ;
			into cursor c_AtributosEditables
		select c_AtributosEditables
		scan
			lcNombreAtributo = alltrim( upper( c_AtributosEditables.Atributo ) )
			.AgregarLinea( "this.oAtributosConEdicionRestringida.Agregar( '" + lcNombreAtributo + "', '" + lcNombreAtributo + "')", tnTab )
		endscan
		use in c_AtributosEditables
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtenerCodigoErrorParaValidacionTimestamp() as Void
		local lnTab as Integer
		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			lcCursor = this.cCursorAtributos
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerCodigoErrorParaValidacionTimestamp() as Integer", lnTab )
				.agregarLinea( "return goServicios.Errores.ObtenerCodigoErrorParaValidacionTimestamp()" , lnTab + 1 )
			.agregarLinea( "endfunc", lnTab )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneVendedorComoClaveForanea() as String
		local lcRetorno as Boolean
		
		lcRetorno = ".f."
		select atributo ;
			from c_diccionario ;
			where entidad = this.cTipo and upper( alltrim( ClaveForanea ) ) = "VENDEDOR" ;
			into cursor c_AtributosVendedor
		if reccount( "c_AtributosVendedor" ) > 0
			lcRetorno = ".t."
		endif
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoVendedor() as String
		local lcRetorno as String
		
		lcRetorno = ""
		select atributo ;
			from c_diccionario ;
			where entidad = this.cTipo and upper( alltrim( ClaveForanea ) ) = "VENDEDOR" ;
			into cursor c_AtributosVendedor
		if reccount( "c_AtributosVendedor" ) > 0
			select c_AtributosVendedor
			scan
				lcRetorno = alltrim( upper( c_AtributosVendedor.Atributo ) ) + "_PK"
			endscan
			use in c_AtributosVendedor
		endif
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesMiPyME() as Void
		local lnTab as Integer
		
		lcCodigoMiPyME = this.ObtenerCodigoMiPyME()
		lcCodigoComprobante = this.ObtenerCodigoNormal()
		lcNombreEntidad = this.ObtenerNombre()
		if this.VerificarFuncionalidad( this.cTipo, "AGRUPACOMPROBANTES" )	
			lcCodigoComprobante = this.ObtenerCodigoNormal()
			lcNombreEntidad = alltrim( this.oAdnAD.ObtenerValorCampo( "comprobantes", "descripcion", "id",  upper( lcCodigoComprobante ) ) )
		endif
		
		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg

		.agregarLinea( "" )
		.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		.agregarLinea( "function SetearTipoComprobanteMiPyME( tlOriginal as Boolean ) as Integer", lnTab )
		.agregarLinea( "local lnRetorno as Number", lnTab + 1)
		.agregarLinea( "")
		.agregarLinea( "if tlOriginal", lnTab + 1 )
		.agregarLinea( "this.TipoComprobante = " + lcCodigoComprobante , lnTab + 2 )
		.agregarLinea( "else", lnTab + 1 )
		.agregarLinea( "this.TipoComprobante = " + lcCodigoMiPyME , lnTab + 2 ) 
		.agregarLinea( "endif", lnTab + 1 )
		.agregarLinea( "" )
		.agregarLinea( "return lnRetorno", lnTab + 1 )
		.agregarLinea( "endfunc", lnTab )
		.agregarLinea( "" )
		.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		.agregarLinea( "function ObtenerNombreMiPyME( tlOriginal as Boolean ) as Integer", lnTab )
		.agregarLinea( "local lcRetorno as String", lnTab + 1 )
		.agregarLinea( "" )
		.agregarLinea( "lcRetorno = '" + lcNombreEntidad + "'", lnTab + 1 )
		.agregarLinea( "", lnTab )
		.agregarLinea( "if !tlOriginal", lnTab + 1 )
		.agregarLinea( "lcRetorno = '" + lcNombreEntidad + "DECREDITO'", lnTab + 2 )
		.agregarLinea( "endif", lnTab + 1 )
		.agregarLinea( "" )
		.agregarLinea( "return lcRetorno", lnTab + 1 )
		.agregarLinea( "endfunc", lnTab )
		.agregarLinea( "" )
		.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		.agregarLinea( "function ObtenerNombreOriginal() as String", lnTab )
		.agregarLinea( "" )
		.agregarLinea( "return '" + this.ObtenerNombre() + "'", lnTab + 1 )
		.agregarLinea( "endfunc", lnTab )		
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetalleConParticipantes() as String		
		local lcNombreCursor as String, lcDetalle as String, lcAtributo as String, lcEntidad as String, lcEntidadItem as String, lcCursorItemDetalle as String
		lcDetalle = ""
		lcNombreCursor = .cCursorAtributos		
		select ( lcNombreCursor )
		scan for &lcNombreCursor..Detalle
			lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
			lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )			
			lcEntidadItem = substr( &lcNombreCursor..Dominio, 8 )	
			lcCursorItemDetalle = this.ObtenerCursorAtributos( lcEntidadItem )
			if this.oFunc.TieneFuncionalidad( "CONPARTICIPANTES", upper( &lcNombreCursor..Tags ) ) and this.TieneAtributosCombinacion( lcCursorItemDetalle )
				lcDetalle = upper( alltrim( lcAtributo ) )
			endif					
		endscan
		return lcDetalle
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarAtributoDetalleParticipantes() as Void
		local lcDetalleConParticipantes as String
		lcDetalleConParticipantes = this.ObtenerDetalleConParticipantes()
		if !empty( lcDetalleConParticipantes )
			.AgregarLinea( "cDetalleParticipantes = '" + lcDetalleConParticipantes + "'", 1 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarFuncionObtenerCamposSegunEquivalencia() as Void
		local lnTab as Integer, lcAtributosGenericos as String
		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerCamposSegunEquivalencia( taEst ) as Integer", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "local loTransformacionLince as object, loColMatcheos as object, lnI as integer, lcCadena as string, lnPos as integer, lcFrameWork as string ", lnTab )
			.agregarLinea( "lcCadena = ''", lnTab )
			.agregarLinea( "loTransformacionLince = _screen.zoo.instanciarentidad('DISENOTRANSFORMACIONLINCE' )", lnTab )
			.agregarLinea( "loTransformacionLince.entiDAD = this.cNombre", lnTab )
			lcAtributosGenericos = this.ObtenerCamposDeAtributosGenericos()
			lcAtributosGenericos = lcAtributosGenericos + ",'BLOQREG','TIMESTAMP'"
			.agregarLinea( 'lcFrameWork = "' + lcAtributosGenericos +'"',lnTab )
			.agregarLinea( "if loTransformacionLince.EstablecerSegunEntidad( loTransformacionLince.Entidad )", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "loColMatcheos = loTransformacionLince.ObtenerColeccionMatcheos()", lnTab )
			.agregarLinea( "for lnI = 1 to loColMatcheos.count", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "lnPos = ASCAN(taEst,loColMatcheos.item(lnI).campoOrganic,1)", lnTab )
			.agregarLinea( "if lnPos != 0", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "taest(lnpos) = ''", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endif", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endfor ", lnTab )
			.agregarLinea( "for lnI = 1 to alen( taest,1)", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "if !empty(taEst(lnI,1)) and !inlist( upper( taEst(lnI,1) ),&lcFramework)", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "lcCadena = lcCadena + taEst(lnI,1) + ' with curseek.' + taEst(lnI,1) + ', '", lnTab ) 
			lnTab = lnTab - 1	
			.agregarLinea( "endif", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endfor ", lnTab )
			.agregarLinea( "lcCadena = substr( lcCadena,1, len( lcCadena ) - 2 )", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endif", lnTab )	
			.agregarLinea( "loTransformacionLince.release()", lnTab )
			.agregarLinea( "", lnTab )
			.agregarLinea( "return lcCadena ", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endfunc ", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposDeAtributosGenericos() as String
		local lcRetorno as String
		lcRetorno = ""
		select c_atributosGenericos
		scan for tipo = "E"
			lcRetorno = lcRetorno + "'" + upper( alltrim( c_atributosGenericos.campo )) + "',"
		endscan
		lcRetorno = substr(lcRetorno, 1, len( lcRetorno ) - 1)
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesComprobantesAgrupados() as Void
		local lnTab as IntegerAgregarFuncionesComprobantesAgrupados

		loDatosAGenerar = this.ObtenerDatosAGenerar()
		lnTab = 1
		with this as GeneradorDinamicoEntidad of GeneradorDinamicoEntidad.prg
			for each ometodo in loDatosAGenerar.oMetodos
				loMetodoUno = oMetodo.Item[1]
				.agregarLinea( "" )
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				lcLineaFirma = iif( empty(loMetodoUno.Modificador), loMetodoUno.Modificador + " ", "" )  + "function " + loMetodoUno.NombreDelMetodo
				lcLineaFirma = lcLineaFirma + "(" + this.ObtenerParametros( loMetodoUno.Parametros ) + ") as " + loMetodoUno.TipoDeRetorno 
				.agregarLinea( lcLineaFirma , lnTab )
				.agregarLinea( "" , lnTab )
				.AgregarLinea( "do case", lnTab ) 
				for each oEntidad in oMetodo
					.AgregarLinea( "case this.Tipocomprobante = " + oEntidad.TipoComprobante, lnTab + 1 ) 
					for each cLineaCuerpo in oEntidad.Cuerpo
						.agregarLinea( ALLTRIM( cLineaCuerpo ) , lnTab + 2)
					endfor
				endfor
				.AgregarLinea( "otherwise", lnTab +1  )
				lcDodefault = iif( !empty( loMetodoUno.VariableRetorno ), loMetodoUno.VariableRetorno + " = ", "")
				lcDodefault =  lcDodefault + "dodefault("
				for each lParam in loMetodoUno.ParametrosUso
						lcDodefault = lcDodefault + ALLTRIM( lParam ) + " ," 
				endfor	
				if loMetodoUno.ParametrosUso.Count > 0
					lcDodefault = substr( lcDodefault, 1, len ( lcDodefault ) - 2 )
				endif
				.AgregarLinea(  lcDodefault + ")", lnTab + 2 ) 
				.AgregarLinea( "EndCase", lnTab)
				if !empty( loMetodoUno.VariableRetorno )
					.AgregarLinea( "return " + loMetodoUno.VariableRetorno , lnTab )
				endif
				.AgregarLinea( "endfunc" , lnTab )
			endfor
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "protected function AgregarParametrosInicializar()" , lnTab )
			lnTab = lnTab + 1
			for each oParametros in loDatosAGenerar.oParametros
				if oParametros.Count > 0
					for each oParametro in oParametros
						lcLinea = "this.AddProperty( '" + oParametro.cNombre + "', " + oParametro.cValor + ")"
						.agregarLinea( lcLinea,  lnTab ) 
					endfor
				endif
			ENDFOR
			lnTab = lnTab - 1
			.AgregarLinea( "endfunc" , lnTab )
		endwith
	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InformaWebHook() as Boolean
		return this.VerificarFuncionalidad( this.cTipo, "WEBHOOK" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesDeWebHook() as void
		local lnTab as Integer
		.agregarLinea( "" )
		lnTab = 1
		.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
		.agregarLinea( "protect function InformarWebHook()" , lnTab )
		*.agregarLinea( "protected function InformarWebHook()" , lnTab )
		lnTab = lnTab + 1
		.agregarLinea( "if this.lWHIngresar and this.lNuevo", lnTab )
			lnTab = lnTab + 1
			.agregarLinea("goServicios.WebHook.Enviar( this, 'INGRESAR')", lnTab )
			lnTab = lnTab - 1
		.agregarLinea( "else", lnTab )
			lnTab = lnTab + 1
			.agregarLinea( "if this.lWHModificar and this.lEdicion", lnTab )
			lnTab = lnTab + 1
				.agregarLinea( "goServicios.WebHook.Enviar( this, 'MODIFICAR')", lnTab )
			lnTab = lnTab - 1
			.agregarLinea( "endif", lnTab )
			lnTab = lnTab - 1
		.agregarLinea( "endif", lnTab )
		lnTab = lnTab - 1
		.AgregarLinea( "endfunc" , lnTab )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametros( toParametros as Object ) as string
		local lnTab as Integer
		lcRetorno = ""
		llPrimero = .t.
		for each lParametro in toParametros
			lcRetorno = lcRetorno + iif( llPrimero, "", ", ") + lParametro
			llPrimero = .f.
		endfor
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPrefijo() as string
		return "Ent"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCodigo() as Void
		this.lTieneAtributosSumarizados = this.TieneAtributosSumarizadosEnItems()
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneAtributosSumarizadosEnItems() as Boolean
		local llRetorno as Boolean
		Select entidad, atributo, sumarizar from c_diccionario where lower(left(entidad,4)) = "item" and !empty(sumarizar) and "DETALLE"+upper(alltrim(entidad)) in (select dominio from c_diccionario where entidad = this.cTipo) into cursor clSumarizados
		llRetorno = reccount("clSumarizados") > 0
		use in select("clSumarizados")
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsEntidadPersonalizable() as Void
		return this.VerificarFuncionalidad( this.cTipo, "PERSONALIZA" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionSetearDescripcionDeEntidad() as Void
		local lnTab as Integer, lcAtributosGenericos as String
		lnTab = 1
		with this 
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function SetearDescripcionDeEntidad() as Void", lnTab )
			.AgregarLinea( "local lcDescripcion as String", lnTab + 1)
			.AgregarLinea( "lcDescripcion = goServicios.PersonalizacionDeEntidades.ObtenerDenominacionPluralDeEntidad( this.cNombre )", lnTab + 1 )
			.AgregarLinea( "if !empty( lcDescripcion )", lnTab + 1 )
			.AgregarLinea( "this.cDescripcion = lcDescripcion", lnTab + 2 )
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "lcDescripcion = goServicios.PersonalizacionDeEntidades.ObtenerDenominacionSingularDeEntidad( this.cNombre )", lnTab + 1 )
			.AgregarLinea( "if !empty( lcDescripcion )", lnTab + 1 )
			.AgregarLinea( "this.cDescripcionSingular = lcDescripcion", lnTab + 2 )
			.AgregarLinea( "else", lnTab + 1 )
			.AgregarLinea( "this.cDescripcionSingular = lower( this.cNombre )", lnTab + 2 )
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc

enddefine
