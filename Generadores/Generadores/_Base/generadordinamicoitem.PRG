define class GeneradorDinamicoItem as GeneradorDinamicoEsqueleto of GeneradorDinamicoEsqueleto.prg
	
	#IF .f.
		Local this as GeneradorDinamicoItem of GeneradorDinamicoItem.prg
	#ENDIF

	cClaseBase = "ItemActivo"
	cCursorCambioSumarizado = ""
	cCursorCambioCombinacion = ""
	lGeneracionDeItem = .t.
	cDominio = ""
	lGenHabilitar = .f.
	lTieneAtributosSumarizados = .f.
	cAtributoClaveEnItem = ""
	lDetalleConAtributosCombinacion = .f.
	lDebeAgregarValidacionesKit = .f.
	lDebeAgregarValidarArticuloTipoKit = .f.

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
		dodefault()
		
		this.lGeneracionDeItem = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		use in select( this.cCursorCambioSumarizado )
		use in select( this.cCursorCambioCombinacion )
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function Generar( tcTipo as string, tcAtributo as string, tcTipoDetalle as String, tcDominio as string, tlGenHabilitar as boolean) as Void
		local lcTipoDetalle as String		
		lcTipoDetalle =  alltrim( tcTipoDetalle )
		if !empty( lcTipoDetalle ) and file( "Item" + lcTipoDetalle + ".prg" )		
			This.cClaseBase = "Item" + lcTipoDetalle
		else
			This.cClaseBase = "ItemActivo"
		endif
		this.cPrefijo = "Item"
		this.cSufijo = Proper( alltrim( tcAtributo ) )
		this.cDominio = alltrim( upper( tcDominio ) )
		this.lGenHabilitar = tlGenHabilitar		
		
		dodefault( tcTipo )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		with this
			dodefault()
			.FuncionValidarExistenciaCamposFijos()
			.GenerarFuncionHabilitar()
			.AgregarMetodoObtenerNombre()						

			if this.lDebeAgregarValidacionesKit
				.AgregarFuncionDespuesDeAsignacionKit()
				.AgregarFuncionValidaColorYTalleConKit()
			endif
			
			if this.lDebeAgregarValidarArticuloTipoKit	
				.AgregarFuncionValidaArticuloTipoKit()
			endif	
			
			if this.lTieneAtributosSumarizados and !empty(this.cAtributoClaveEnItem)
				this.AgregarFuncionPuedeEjecutarCambioSumarizado()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarVariableHaCambiado( tcAtributo As String, tnTab As Integer ) as String
		return this.DeclararYResguardarVariablesValorViejo( tcAtributo, tnTab )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarIfHaCambiado( tnTab As Integer ) As Void
		This.AgregarLinea( "If lxValOld != lxVal" , tnTab)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEndIfHaCambiado( tnTab As Integer ) as Void
		This.AgregarLinea( "EndIf" , tnTab)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursor() as string
		local lcNombreCursor as string, lcEntidad as String

		lcentidad = substr( this.cDominio, 8 )
		
		with this
			lcNombreCursor = .ObtenerCursorAtributos( lcEntidad )
			.cCursorCambioSumarizado = .ObtenerCursorAtributosCambioSumarizado( lcEntidad )
			.cCursorCambioCombinacion = .ObtenerCursorAtributosCambioCombinacion( lcEntidad )
			.cAtributoClaveEnItem = .ObtenerAtributoClaveEnItem( lcEntidad )
		endwith

		if this.lGenHabilitar
			replace all genHabilitar with .T. in (lcNombreCursor) 
		endif 
		
		return lcNombreCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCursorComponentes() as String
		local lcAlias As String, lcEntidad as string

		lcentidad = substr( this.cDominio, 8 )


		lcAlias = sys( 2015 )
		select comp.* from c_Componente comp inner join c_RelaComponente rel ;
				on upper( alltrim( comp.Componente ) ) == upper( alltrim( rel.Componente ) ) ;
			where alltrim( upper( rel.Entidad ) ) == alltrim( upper( lcEntidad ) ) ;
			into cursor &lcAlias
			
		return lcAlias
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributosCambioSumarizado( tcItem as String ) as String
		local	lcNombreCursor As String

		lcNombreCursor	= "c_" + sys(2015)
		Select upper( dic2.Atributo ) as Atributo, alta, empty(campo) as EsVirtual ;
			from c_Diccionario Dic2 ;
			where !empty( Sumarizar ) .And. upper( alltrim( Entidad ) ) == upper( alltrim( tcItem ) ) ;
			into cursor &lcNombreCursor
		
		this.lTieneAtributosSumarizados = reccount(lcNombreCursor) > 0
		return lcNombreCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributosCambioCombinacion( tcItem as String ) as String
		local	lcEntidad As String, lcNombreCursor As String, lcEntComp As String, lcRelaComp as String,;
			lcCursorCambioSumarizado as string 
			
		lcEntidad = upper( alltrim( This.cTipo ) )
		lcNombreCursor	= "c_" + sys(2015)
		lcEntComp		= "c_" + sys(2015)
		lcRelaComp		= "c_" + sys(2015)
		lcCursorCambioSumarizado = this.cCursorCambioSumarizado
		
		select Distinct upper( Componente ) As Componente ;
			from C_RelaComponente ;
			where upper( alltrim( Entidad ) ) == lcEntidad or upper( alltrim( Entidad ) ) == upper( alltrim( tcItem ) ) ;
			into cursor &lcRelaComp Nofilter

		select Distinct upper( Comp.Entidad ) As Entidad, Rela.Componente, Comp.Orden  ;
			from C_Componente comp inner join &lcRelaComp rela ;
				on upper( alltrim( Comp.Componente ) ) == upper( alltrim( Rela.Componente) ) ;
			into cursor &lcEntComp Nofilter

		select Distinct upper( dic.Atributo ) as Atributo, Ent.Componente, Ent.Orden ;
			from c_Diccionario Dic inner join &lcEntComp ent ;
					on upper( alltrim( Dic.Entidad ) ) == upper( alltrim( ent.Entidad ) ) ;
			into cursor &lcNombreCursor	;
			order by 3

		use in select( lcEntComp )
		use in select( lcRelaComp )
		
		return lcNombreCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionInicializar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function Inicializar() as boolean", 1 )
			.AgregarLinea( "dodefault()", 2 )
			lcCursor = this.cCursorAtributos
			select ( lcCursor )
			.AgregarLinea( "this.oColeccionVSFW = _screen.zoo.CrearObjeto( 'zoocoleccion' )", 2 )
			.AgregarLinea( "this.oColeccionVS = _screen.zoo.CrearObjeto( 'zoocoleccion' )", 2 )
			scan for !empty( &lcCursor..ValorSugerido )
				lcAtributo = alltrim( proper ( &lcCursor..Atributo ))
				.AgregarLinea( "this.oColeccionVSFW.agregar('.ValorSugeridoFW" + lcAtributo + "()','" + lcAtributo + "')", 2 )
			endscan
			.AgregarLinea( "oICol = goServicios.SaltosDeCampoYValoresSugeridos.ObtenerValorSugeridoDeUnaEntidadDetalle( '" + alltrim( this.cTipo ) + "', '" + alltrim( this.cSufijo ) + "')", 2 )
			.AgregarLinea( "for each oItmUs in oICol", 2 )
			.AgregarLinea( "this.oColeccionVS.Agregar( '.ValorSugerido' + alltrim(oItmUs.atributo) + '()' )", 3 )
			.AgregarLinea( "try", 3)			
			.AgregarLinea( [this.oColeccionVSFW.Quitar( alltrim( proper( oItmUs.atributo ) ) )], 4)
			.AgregarLinea( "catch to loError", 3)			
			.AgregarLinea( "endtry", 3)
			.AgregarLinea( "endfor", 2)
			
			this.lDetalleConAtributosCombinacion = this.DetalleConAtributosCombinacion( this.cDominio )		
			this.lDebeAgregarValidarArticuloTipoKit = this.DebeAgregarValidarArticuloTipoKit( this.cDominio, this.cTipo )	
			this.lDebeAgregarValidacionesKit = this.DebeAgregarValidacionesKit( this.cDominio, this.cTipo )	
			 
			if this.lDebeAgregarValidacionesKit
				.AgregarLinea( "this.lKitPermiteColorYTalle = goParametros.Felino.GestionDeVentas.HabilitarColorTalleKits", 2 )			
			endif
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function AgregarSeteoFlagCargandoSugeridos( tcFlag as String  , tnTabulado as Integer  ) as Void
		this.agregarLinea( ".lEstaSeteandoValorSugerido = " + tcFlag , tnTabulado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionValidarExistenciaCamposFijos() as Void
		with this
			.AgregarLinea( "")
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ValidarExistenciaCamposFijos() as Boolean", 1 )
			.AgregarLinea( "Local llRetorno as boolean",2 )	
			.AgregarLinea( "llRetorno = .t.", 2 )			
			.AgregarLinea( "")			
			.ValidarExistenciaCamposFijos()
			.AgregarLinea( "return llRetorno", 2)			
			.AgregarLinea( "")			
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaCamposFijos() as Void
		local lcAtributo as String , lnI as Integer , lncant as Integer , lcCondicion as String, ;
			lcCursor as String, lcConsulta as string
			
		with this
			lcCursor = .cCursorAtributos
			lcConsulta = sys( 2015 )
			lcCondicion = ""
			
			select * from ( lcCursor ) where Obligatorio into cursor ( lcConsulta )
			
			if _tally > 0
				select ( lcConsulta  )
				scan
					lcAtributo = proper( alltrim( &lcConsulta..Atributo ) )
					lcAtributo = "this." + lcatributo + iif( &lcConsulta..EsEntidad, "_PK", "" )
					lcCondicion =	lcCondicion + iif( empty( lcCondicion ), "", replicate( chr( 9 ), 3 ) ) + ;
									" empty( " + lcAtributo  + " ) or ; " + chr(13) 
				endscan
				
				lcCondicion = left( lcCondicion, len( lcCondicion ) - 6 )
				
				this.AgregarLinea( "if " + lcCondicion , 2 )
				this.AgregarLinea( "llRetorno = .F.", 3 )
				this.AgregarLinea( "endif ", 2 )
				
			endif 
		
			use in select( lcConsulta )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEventoCambioSumarizado( tcAtributo As String, tnTab As Integer, tlEsPk As Boolean, tlEsObligatorio as Boolean, tnTipoAtributo as Integer ) as Void
		local lnBaseAct as Integer, lcAtributo As String, lcAtribAnt as String, lcAtribPos as String 

		if this.lTieneAtributosSumarizados
			lcAtributo = alltrim( tcAtributo ) + iif( tlEsPk, "_Pk", "" )
			if tlEsPk
				do case
				case lower(alltrim(tcAtributo)) == lower(alltrim(this.cAtributoClaveEnItem))
					This.AgregarLinea( "If Not (lxVal == lxValOld) And This.PuedeEjecutarCambioSumarizado()", tnTab )
					this.AgregarLinea( "this.TotalizarSumarizado()", tnTab + 1 )
					This.AgregarLinea( "EndIf", tnTab )
				case tnTipoAtributo = 2
					This.AgregarLinea( "If This.PuedeEjecutarCambioSumarizado()", tnTab )
					this.AgregarLinea( "this.CambioSumarizado()", tnTab + 1 )
					This.AgregarLinea( "EndIf", tnTab )
				endcase		
			else
				lnBaseAct =	select()
				select ( This.cCursorCambioSumarizado )
				locate for upper( alltrim( Atributo ) ) = upper( alltrim( tcAtributo ) )
				if found()
					This.AgregarLinea( "If Not (lxVal == lxValOld) And This.PuedeEjecutarCambioSumarizado()", tnTab )
					this.AgregarLinea( "this.AcumularSumarizado( .t., '"+lcAtributo+"', lxVal, lxValOld)", tnTab + 1 )
					This.AgregarLinea( "EndIf", tnTab )
				endif
				select ( lnBaseAct )
			endif
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------	
	protected function AgregarEventoHaCambiado( tcAtributo As String, tnTab As Integer, tlEsPk As Boolean ) as Void
		local lnBaseAct as Integer, lcAtributo As String
		lcAtributo = alltrim( tcAtributo ) + iif( tlEsPk, "_Pk", "" )
		this.AgregarLinea( "If This.PuedeEjecutarHaCambiado()", tnTab )
			this.AgregarLinea( "this.HaCambiado( '" + lcAtributo + "', This )", tnTab + 1 )
		this.AgregarLinea( "Endif", tnTab )
	endfunc 	

	*-----------------------------------------------------------------------------------------	
	protected function 	AgregarEventoAntesDeSetear( tcAtributo as String, tnTab as Integer, tlEsPk as Boolean ) as Void
		local lnBaseAct as Integer, lcAtributo As String
		lcAtributo = alltrim( tcAtributo ) + iif( tlEsPk, "_Pk", "" )
	
		this.AgregarLinea( "this.EventoAntesDeSetear( This, '" + lcAtributo + "', lxValOld, lxVal  )", tnTab )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------	
	protected function 	AgregarEventoDespuesDeSetear( tcAtributo as String, tnTab as Integer, tlEsPk as Boolean ) as Void
		local lcAtributo As String
		lcAtributo = alltrim( tcAtributo ) + iif( tlEsPk, "_Pk", "" )
	
		this.AgregarLinea( "this.EventoDespuesDeSetear( This, '" + lcAtributo + "', lxValOld, lxVal  )", tnTab )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarFuncionHabilitar() as Void
		local lntab as Integer, lcCursor as string, lcAtributo as String
		lnTab = 1
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea("function habilitar( tlHabilitar as boolean ) as void", lnTab)
			lcCursor = .cCursorAtributos

			select (lcCursor)
			scan for &lcCursor..genHabilitar
				lcAtributo = alltrim( &lcCursor..atributo ) + iif( &lcCursor..EsEntidad, "_PK", "" )				
				.AgregarLinea( "this.lHabilitar" + lcAtributo + " = tlHabilitar", lnTab + 1)
			endscan
			
			.AgregarLinea("endfunc", lnTab)
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AssignFuncionalidadAtributos() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string

		lnTab = 1
		
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for !&lcNombreCursor..esEntidad and !&lcNombreCursor..detalle .and. !&lcNombreCursor..claveprimaria
				this.EscribirAssignAtributo( lcNombreCursor )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeGenerarAssign( tcCursor as String )  as Boolean 
		local llRetorno As Boolean
		llRetorno = !&tcCursor..ClavePrimaria and !&tcCursor..esEntidad and !&tcCursor..detalle
		if llRetorno
			llRetorno = &tcCursor..genHabilitar
			llRetorno = llRetorno  or !empty( &tcCursor..Validacion )
			llRetorno = llRetorno  or !empty( &tcCursor..DespuesDeAsignacion )
			select ( This.cCursorCambioSumarizado )
			locate for upper( alltrim( Atributo ) ) == upper( alltrim( &tcCursor..Atributo ) )
			llRetorno = llRetorno  or found()
			select ( This.cCursorCambioCombinacion )
			locate for upper( alltrim( Atributo ) ) == upper( alltrim( &tcCursor..Atributo ) )
			llRetorno = llRetorno  or found()
			select &tcCursor
		Endif	
		llRetorno = llRetorno or ( &tcCursor..ValidarDominio and !&tcCursor..esEntidad )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		dodefault()
		with this
			.cArchivo = .cPath + "Din_" + .cPrefijo + alltrim( Proper( .cTipo ) )+ .cSufijo +".prg"
		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		local lcCursor as String
		with this
			.AgregarLinea( "define class Din_" + .cPrefijo + .cTipo + .cSufijo + " as " +;
													 .cClaseBase + " of " + .cClaseBase + ".prg" )
			.AgregarLinea( "" )
			.AgregarAtributos()

			if 'ITEMVALOR'$upper(this.cDominio) or 'ITEMCANJE'$upper(this.cDominio)
				lcCursor = this.cCursorAtributos
				select ( lcCursor )
				locate for 'recibido' = lower(&lcCursor..Atributo)
				.AgregarLinea("lTieneImporteEnRecibido = " + iif(found(),'.t.','.f.'), 1 )
			endif
			.AgregarComponentes()
			.AgregarLinea( "oColeccionVS = null", 1 )
			.AgregarLinea( "oColeccionVSFW = null", 1 )
			.AgregarLinea( "lKitPermiteColorYTalle = .f.", 1 )
			.AgregarRestauracionGenHabilitar()
			.AgregarLinea( "" )
		endwith		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoBlanqueable( tcAtributo as String ) as boolean
		return !( "NROITEM" == upper( alltrim( tcAtributo ) ) )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarMetodoObtenerNombre() as Void
		local lnTab as Integer

		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ObtenerNombre() as String", lnTab )
			.AgregarLinea( "return [" + upper( alltrim( substr( this.cDominio, 8 ) ) ) + "]", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionDespuesDeAsignacionKit() as Void
		local lnTab as Integer, loAtributos as Object, lcAtributo as String
		loAtributos = this.ObtenerAtributosCombinacion()
		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function LimpiarColorYTalle() as void", lnTab )
			.AgregarLinea( "if this.Articulo.Comportamiento = 4 and !this.lKitPermiteColorYTalle", lnTab + 1 )		
			for each lcAtributo in loAtributos
				if upper(lcAtributo) != "ARTICULO"
					.AgregarLinea( "this." + lcAtributo + "_pk = ''", lnTab + 2 )
				endif
			endfor	
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeAgregarValidacionesKit( tcDominio as String, tcTipo as String ) as Boolean
		return this.lDetalleConAtributosCombinacion and !this.lDebeAgregarValidarArticuloTipoKit
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionValidaArticuloTipoKit() as Void		
		local lnTab as Integer
		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ValidaArticuloTipoKit() as void", lnTab )
			.AgregarLinea( "if this.Articulo.Comportamiento = 4", lnTab + 1 )		
			.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'No se pueden ingresar artículos de tipo kit.' )", lnTab + 2 )		
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionValidaColorYTalleConKit() as Void
		local lnTab as Integer
		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ValidaColorYTalleConKit( txVal ) as void", lnTab )
			.AgregarLinea( "if !empty( txVal ) and this.Articulo.Comportamiento = 4 and !this.lKitPermiteColorYTalle", lnTab + 1 )		
			.AgregarLinea( "goServicios.Errores.LevantarExcepcion( 'No se pueden ingresar colores o talles en kits.' )", lnTab + 2 )		
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeAgregarValidarArticuloTipoKit( tcDominio as String, tcEntidad as String ) as Boolean
		return this.DetalleConAtributosCombinacion( tcDominio ) and ;
		   ( !this.TieneTagNoValidaKit( tcEntidad , tcDominio ) and !this.TieneTagConParticipantes( tcEntidad , tcDominio ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionLimpiar() as Void
		local lcAtributo as String, lcNombreCursor as String, lcAtributoAux as string, lcValorVacio as string, ;
			lnTab as integer, lcCursorEntidad as String, llSetearValoresSugeridos as Boolean, llTieneSumarizado as Boolean

		lnTab = 1
		llSetearValoresSugeridos = .f.
		lcNombreCursor = This.cCursorAtributos
		llTieneSumarizado = .f.

		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )

			.AgregarLinea( "function Limpiar( tlForzar as boolean ) as void", lnTab )
				.AgregarLinea( "local loError as Exception", lnTab + 1 )
				.AgregarLinea( "with this", lnTab + 1 )
					.AgregarLinea( "Try", lnTab + 2 )
						.AgregarLinea( ".lLimpiando = .t.", lnTab + 3 )
						.AgregarLinea( "dodefault( tlForzar )", lnTab + 3 )
						.AgregarLinea( ".LimpiarFlag()", lnTab + 3 )
						.AgregarLinea( "" )
						
						lcAtributo = ""
						select ( lcNombreCursor )
						scan for !empty( Tabla )
							.AgregarBlanqueoAtributo( lcNombreCursor, lnTab )
							if !empty(&lcNombreCursor..Sumarizar)
								llTieneSumarizado = .T.
							endif
						endscan
						.AgregarLinea( ".LimpiarAtributosVirtuales()", lnTab + 3 )
						.GenerarLimpiarAD( lnTab + 3 )
					.AgregarLinea( "catch to loError", lnTab + 2 )
						.AgregarLinea( 'goServicios.Errores.LevantarExcepcion( loError )', lnTab + 3 )
					.AgregarLinea( "finally", lnTab + 2 )
						.AgregarLinea( ".lLimpiando = .f.", lnTab + 3 )
						
						select ( lcNombreCursor )
						go top
						locate for !empty( &lcNombreCursor..ValorSugerido ) 
						llSetearValoresSugeridos = found()
						
						.AgregarLinea( "if tlForzar", lnTab + 3 )
						.AgregarLinea( "else", lnTab + 3 )							
						.AgregarLinea( ".SetearValoresSugeridos()", lnTab + 4 )
						.AgregarLinea( "endif", lnTab + 3 )

						if llTieneSumarizado
							.AgregarLinea( "if tlForzar", lnTab + 3 )
							.AgregarLinea( ".CambioSumarizado()", lnTab + 4 )
							.AgregarLinea( "endif", lnTab + 3 )
						endif
					.AgregarLinea( "EndTry", lnTab + 2 )
				.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab)
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoPKEnItemConSumarizado( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lcEntidad as String, lnAreaActual as Integer

		if upper(left(this.cDominio,11)) = "DETALLEITEM"
			lnAreaActual = select()
			lcEntidad = upper(alltrim(substr(this.cDominio,8)))
			select entidad, atributo, dominio, claveforanea, grupo, orden from c_diccionario where alta and entidad + str(orden) in ;
					(select entidad + str(min(orden)) from c_diccionario where upper(left(entidad,4)) = "ITEM" and alta and entidad ;
					in (select entidad from c_diccionario where upper(left(entidad,4)) = "ITEM" and !empty(sumarizar)) group by entidad) ;
					into cursor clClaveEnItem

			locate for entidad = lcEntidad and atributo = tcAtributo and !empty(claveforanea)
			llRetorno = found()
			use in (select("clClaveEnItem"))
			select (lnAreaActual)
		else
			llRetorno = .f.
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoClaveEnItem( tcItem as String ) as String
		local lcRetorno As String, lcNombreCursor as String
		lcNombreCursor	= "c_" + sys(2015)
		Select upper( dic2.Atributo ) as Atributo, alta ;
			from c_Diccionario Dic2 ;
			where upper( alltrim( Dic2.Entidad ) ) == upper( alltrim( tcItem ) ) .And. Dic2.alta .And. !Dic2.SaltoCampo .And. ;
			inlist(alltrim(Dic2.dominio),"CONSOPORTEPREPANTALLA", "CODIGO", "CODIGOVALOR","CLAVECONLECTURACB") .And. Dic2.grupo * 100 + Dic2.orden in ;
			(Select min(Dic3.grupo * 100 + Dic3.orden) from c_Diccionario Dic3 where Dic3.alta .And. upper( alltrim( Dic3.Entidad ) ) == upper( alltrim( tcItem ) ) ) ;
			into cursor &lcNombreCursor
		
		if reccount( lcNombreCursor ) = 1
			lcRetorno = alltrim(&lcNombreCursor..Atributo)
		else
			lcRetorno = ""
		endif
		use in (select(lcNombreCursor))
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionPuedeEjecutarCambioSumarizado() as Void
		local lnTab as Integer
		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function PuedeEjecutarCambioSumarizado() as boolean", lnTab )
			lnTab = lnTab + 1
			.AgregarLinea( "local llRetorno as Boolean", lnTab )
			.AgregarLinea( "llRetorno = !empty(this."+this.cAtributoClaveEnItem+"_PK) and dodefault()", lnTab )
			.AgregarLinea( "return llRetorno", lnTab )
			lnTab = lnTab - 1
			.AgregarLinea( "endfunc", lnTab)
		endwith
	endfunc 

enddefine
