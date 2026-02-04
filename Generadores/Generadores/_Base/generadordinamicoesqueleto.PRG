define class GeneradorDinamicoEsqueleto as generadordinamico of generadordinamico.prg

	#IF .f.
		Local this as GeneradorDinamicoEsqueleto of GeneradorDinamicoEsqueleto.prg
	#ENDIF

	cCursorAtributos = ""
	cCursorEntidad = ""
	cClaseBase = ""
	cCursorComponentes = ""	
	cCursorRelaNum = ""
	oDespuesDeAssign = Null	
	oColValidacionesDominios = Null
	oColDominiosAValidar = Null
	cAtributosGen = ""
	
	lTieneNumeraciones = .f.
	lGeneracionDeItem = .f.
	lTieneComponenteEnBaseA = .f.
	
	cDescripcionEntidad = ""
	lTieneFuncionalidadDesactivable = .f.
	lTieneFuncionalidadPromocion = .F.
	lTieneFuncionalidadActualizarEmail = .F.
	cEntidadPromoPrincipal = ""
	
	cCursorAtributosPromociones = ""
	lTieneAtributosSumarizados = .f.
	
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		if ( This.Class # "Generadordinamicoesqueleto" ) and dodefault( tcRuta )
		Else
			return .f.
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		with this
			use in select( .cCursorAtributos )
			use in select( .cCursorEntidad )
			use in select( .cCursorComponentes )
			use in select( .cCursorRelaNum )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
		dodefault()

		with this
			.lTieneFuncionalidadDesactivable = this.TieneFuncionalidadDesactivable( .cTipo )
			.lTieneFuncionalidadPromocion = This.TieneFuncionalidadPromocion( .cTipo )
			.lTieneFuncionalidadActualizarEmail = this.TieneFuncionalidadActualizarEmail( .cTipo )
			.cEntidadPromoPrincipal = This.ObtenerEntidadPromoPrincipal()
			.cCursorAtributos = ""
			.cCursorEntidad = ""
			.cCursorComponentes = ""	
			.cCursorRelaNum = ""
			.oDespuesDeAssign = Null	
			.oColValidacionesDominios = Null
			.oColDominiosAValidar = Null
			.cAtributosGen = ""
			
			.lTieneNumeraciones = .f.
			.lTieneComponenteEnBaseA = .f.
		
			.oDespuesDeAssign = newobject( "Collection" )
			.oColValidacionesDominios = _Screen.zoo.Crearobjeto( "ZooColeccion" )
			.oColDominiosAValidar = _Screen.zoo.Crearobjeto( "ZooColeccion" )
			
			.ObtenerColeccionDominiosAValidar()

			.cCursorAtributos   = .ObtenerCursor()
			.cCursorComponentes = .ObtenerCursorComponentes()		&& Solo los componentes relacionados a la cabecera
			.cCursorRelaNum     = .ObtenerCursorComponenteNumeraciones()
			.cCursorEntidad     = "c_" + .cTipo
			
			.cDescripcionEntidad = .ObtenerDescripcion()
			if empty( .cDescripcionEntidad )
				.cDescripcionEntidad = goLibrerias.ValorAString( this.cTipo )
			endif
			
			if this.lTieneFuncionalidadPromocion
				this.CargarCursorAtributosPromociones()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionalidadPromocion( txTipo as Variant ) as Boolean
		return this.VerificarFuncionalidad( txTipo, "PROMO" ) or this.VerificarFuncionalidad( txTipo, "PROMO_PRINCIPAL" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionalidadActualizarEmail( txTipo as Variant ) as Boolean
		return this.VerificarFuncionalidad( txTipo, "ACTUALIZAEMAILCLIENTE" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPromoPrincipal() as String
		select c_Entidad
		locate for "<PROMO_PRINCIPAL>" $ upper( alltrim( Funcionalidades ) )
		return upper( alltrim( c_Entidad.Entidad ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcion() as String
		return goLibrerias.ValorAString( alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Descripcion", "Entidad", upper( alltrim( this.cTipo ) ) ) ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursor() as string
		*** esta funcion se sobrecarga
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarCursorAtributosPromociones() as Void
	
		lcNombreCursor = "c_" + sys(2015)
		
		select dic.Entidad, dic.Atributo from c_diccionario as Dic ;
			where dic.Atributo IN ( ;
				select dic2.Atributo from c_diccionario as Dic2 ;
					left join c_entidad as ent2 on alltrim(upper(ent2.entidad)) == alltrim(upper(dic2.Entidad)) ;
					where "<PP>" $ upper( dic2.Tags ) and "<PROMO_PRINCIPAL>" $ upper( ent2.Funcionalidades ) and subst( upper(dic2.dominio), 1, 7 )<>"DETALLE" ;
				) and dic.Entidad in ( ;
					select ent3.Entidad from c_entidad as ent3 ;
						where ( "<PROMO_PRINCIPAL>" $ upper( ent3.Funcionalidades ) or "<PROMO>" $ upper( ent3.Funcionalidades ) ) ;
					) ;
		union ;
		select dic.Entidad,dic.Atributo from c_diccionario as Dic ;
			left join c_entidad as ent on alltrim(upper(ent.entidad)) == alltrim(upper(dic.Entidad)) ;
			where dic.entidad IN ( select subst( upper(dic.dominio), 8 ) from c_diccionario as Dic ;
										where "<PP>" $ upper( dic.Tags ) and subst( upper(dic.dominio), 1, 7 )=="DETALLE" ) ;
							and "<PP>" $ upper( dic.Tags ) ;
		into cursor &lcNombreCursor

		this.cCursorAtributosPromociones = lcNombreCursor 
							
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributos( tcEntidad as String ) as string
		local lcNombreCursor, lcsql as String 

		lcNombreCursor = "c_" + sys(2015)

		lcsql = "select dic.Atributo,"+;
			" iif( !empty(Dic.ClaveForanea) ,Dic.ClaveForanea, dic.Entidad) as cEntidad,"+;
			" iif(empty(Dic.TipoDato), dom.TipoDato, Dic.TipoDato) as tipoDato,"+;
			" !empty(Dic.ClaveForanea) as EsEntidad, "+;
			" dom.detalle, "+;
			" dic.tabla, "+;
			" dic.campo, "+;
			" dic.claveprimaria, "+;
			" dic.Etiqueta, " +;
			" Dic.EtiquetaAutodescriptiva, " + ;
			" dic.Obligatorio, " + ;
			" dic.Longitud, " + ;
			" dic.Decimales, " + ;
			" dic.Sumarizar, " + ;
			" dic.ValorSugerido, " + ;
			" Dic.AtributoForaneo, " + ;
			" Dic.genHabilitar, " + ;
			" Dic.dominio, " + ;			
			" Dic.Validacion, " + ;
			" Dic.DespuesDeAsignacion, " + ;
			" Dic.ClaveCandidata, " + ;
			" Dic.validaComp, " + ;
			" Dic.EsGuid, " + ;
			" Dic.Tags, " + ;
			" Dic.ClaveForanea, " + ;
			" Dic.Alta, " + ;
			" ent.Funcionalidades, " + ;
			" ent.Titulo, " + ;
			" Dic.SaltoCampo " + ;
			" from c_dominio dom, c_entidad ent, c_Diccionario Dic " + ;
			" where alltrim(upper(Dic.Entidad)) == '" + upper( alltrim( tcEntidad ) ) + "'"+;
			" and alltrim(upper(Dic.Entidad)) == alltrim(upper(ent.Entidad)) "+;
			" and !empty(dic.atributo) " +;
			" and !empty(dic.Entidad)" +;
			" and alltrim(upper(dic.dominio)) == alltrim(upper(dom.dominio)) "+;
			" order by Dic.Orden "+;
			" into cursor " + lcNombreCursor + " readwrite"

		&lcsql 

		return lcNombreCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		with this
			.AgregarLinea( "define class Din_Entidad" + .cTipo + .cPrefijo + .cSufijo + " as " +;
													 .cClaseBase + " of " + .cClaseBase + ".prg" )
			.AgregarLinea( "" )
			.AgregarAtributos()
			.AgregarComponentes()
			.AgregarValoresSugeridos()
			.AgregarRestauracionGenHabilitar()
			.AgregarLinea( "" )
		endwith		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarComponentes() as Void
		local lcCursor As String, llSoportaKits as Boolean 

		with this
			lcCursor = .cCursorComponentes
			select &lcCursor
			scan All
				.AgregarLinea( "oComp" + alltrim( &lcCursor..componente ) + " = null" , 1 )
				if upper(alltrim( &lcCursor..componente )) == "KITDEARTICULOS"
					llSoportaKits = .t.
				endif
				select &lcCursor
			endscan
			
			if this.VerificarSiUsaComponenteEnBaseA()
				.AgregarLinea( "oCompEnBaseA = null" , 1 )
			endif
			if llSoportaKits
				.AgregarLinea( "lSoportaKits = .t." , 1 )
			endif
			lcCursor = .cCursorRelaNum
			select &lcCursor

			if reccount( lcCursor ) > 0
				.lTieneNumeraciones = .t.
			else
				.lTieneNumeraciones = .f.
			endif			

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarValoresSugeridos() as Void

		with this
			.AgregarLinea( "oColeccionVS = null", 1 )
			.AgregarLinea( "oColeccionVSFW = null",  1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarSiUsaComponenteEnBaseA() as Boolean
		local lcCursorEnBaseA as String, lnOrden as Integer

		lcCursorEnBaseA = sys( 2015 )
		select distinct B.descripcion ;
			from c_RelaComprobantes A ;
			left join C_Comprobantes B on B.Id = A.IdComp or B.Id = A.IdCompAfectado ;
			where upper( alltrim( B.Descripcion ) ) == upper( alltrim( this.cTipo ) ) ;
			into cursor &lcCursorEnBaseA
		
		if reccount( lcCursorEnBaseA ) > 0
			this.lTieneComponenteEnBaseA = .t.
		endif
		
		use in select( lcCursorEnBaseA )
		
		return this.lTieneComponenteEnBaseA
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorComponentes() as String
		local lcAlias As String

		lcAlias = sys( 2015 )
		select comp.* from c_Componente comp inner join c_RelaComponente rel ;
				on upper( alltrim( comp.Componente ) ) == upper( alltrim( rel.Componente ) ) ;
			where alltrim( upper( rel.Entidad ) ) == alltrim( upper( This.cTipo ) ) ;
			into cursor &lcAlias
			
		return lcAlias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCursorComponenteNumeraciones() as String
		local lcAlias As String

		lcAlias = sys( 2015 )

		select distinct Entidad, Atributo, Talonario, Dependencia from c_RelaNumeraciones num ;		
			where upper( alltrim( num.entidad ) ) == upper( alltrim( This.cTipo ) ) ;
			into cursor &lcAlias			
			
		return lcAlias
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributos() as Void
		local lcNombreCursor as string, lcAtributo as string, lcEntidad as string 
		
		with this
		
			.AgregarLinea( "cNombre = '" + .ObtenerNombre() + "'" , 1 )

			lcNombreCursor = .cCursorAtributos

			select ( lcNombreCursor )
			scan
				lcAtributo = alltrim( &lcNombreCursor..Atributo )
				lcEntidad = alltrim( &lcNombreCursor..cEntidad )

				do case
					case &lcNombreCursor..ClavePrimaria
						.AgregarLinea( "cAtributoPK = '" + lcAtributo + "'" , 1 )
						.AgregarLinea( lcatributo + " = " + goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( &lcNombreCursor..TipoDato ) ), 1 )
				
					case &lcNombreCursor..EsEntidad or &lcNombreCursor..detalle
						if &lcNombreCursor..EsEntidad
							.AgregarLinea( lcAtributo + "_PK = " + goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( &lcNombreCursor..TipoDato ) ), 1 )
						endif
						.AgregarLinea( lcAtributo + " = null", 1 )
					otherwise
						.AgregarLinea( lcAtributo + " = " + goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( &lcNombreCursor..TipoDato ) ), 1 )
				endcase
				
				if &lcNombreCursor..genHabilitar
					.AgregarLinea( "lHabilitar" + lcAtributo + iif( &lcNombreCursor..EsEntidad, "_PK", "") + " = .T." , 1)
					.cAtributosGen = .cAtributosGen + ("lHabilitar" + lcAtributo + iif( &lcNombreCursor..EsEntidad, "_PK", "")+";")
				endif 
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarRestauracionGenHabilitar() as Void
		local lnI as Integer 
		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function RestaurarGenHabilitar() as Void", 1 )
			for lnI = 1 to GetWordCount(this.cAtributosGen, ";" )
				.AgregarLinea( "this." + alltrim( getwordnum( this.cAtributosGen, lnI,';')) +" = .T." , 2 )
			endfor
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		with this
			.FuncionInicializar()
			.AssignAtributosPK()
			.SetearAtributosPK()
			.ValidarAtributosPK()
			.AssignFuncionalidadAtributos()
			.SetearAtributos()
			.ValidarAtributos()
			.GenerarValidacionADNAtributos()
			.AccessSubentidades()
			.AccessComponentes()
			.AccessDescripcionFW()
			.FuncionCargar()
			.FuncionLimpiar()
			.FuncionSetearValoresSugeridos()
			.FuncionesValorSugeridosYFW()
			.FuncionEventoSeteandoValorSugerido()
			.FuncionesDespuesDeAssign()
			.FuncionCargaManual()
			.GenerarValidacionesDominios()
			.AgregarDestroy()
			.AgregarValidarAtributoComponente()
			.FuncionLimpiarAtributosVirtuales()
			.FuncionObtenerAtributosCombinacion()
			if this.lTieneFuncionalidadPromocion 
				.FuncionValidarSiCambioElValorDelAtributo()
				.FuncionEventoCambioParticipantePromocion()
			endif
			if this.lTieneFuncionalidadActualizarEmail 
				.FuncionEventoActualizarEmail()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionEventoCambioParticipantePromocion() as Void
		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function EventoCambioParticipantePromocion() as Void", 1 )
			.AgregarLinea( "*", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionEventoActualizarEmail() as Void
		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function EventoActualizarEmail() as Void", 1 )
			.AgregarLinea( "*", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionCargaManual() as Void
		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function CargaManual() as Boolean", 1 )
			.AgregarLinea( "return !this.lLimpiando and !this.lCargando and !this.lDestroy", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionInicializar() as Void
		*** esta funcion se sobrecarga
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AssignAtributosPK() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string, lcAsignacion as String ,;
				lcLineaCondicion as String , lcValidacion as String, lcValOld as string, lnTipoAtributo as Integer

		lnTab = 1
		
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for &lcNombreCursor..EsEntidad
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )
				lcAsignacion = "this." + lcAtributo + "." + this.ObtenerAtributoClavePrimaria( lcEntidad ) + " = lxVal"
				lcValidacion = alltrim( proper( &lcNombreCursor..Validacion ) )
				
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )

				.AgregarLinea( "function " + lcAtributo + "_PK_Assign( txVal as variant ) as void", lnTab )

				.AgregarLinea( "" )
				lcValOld = .AgregarVariableHaCambiado( lcAtributo + "_PK", lnTab + 1 )
				.AgregarLinea( "local lxVal as Variant", lnTab + 1 )
				.AgregarLinea( "local loSugerido as Object", lnTab + 1 )
				.AgregarLinea( "", lnTab + 1 )

				if This.VerificarFuncionalidad( &lcNombreCursor..ClaveForanea, "CODIGOSUGERIDO" )
					.AgregarLinea( "if txVal = lxValOld or empty( txVal )", lnTab + 1 )
						.AgregarLinea( "lxVal = txVal", lnTab + 2 )					
					.AgregarLinea( "else", lnTab + 1 )
					.AgregarLinea( "this.lBuscandoCodigo = .t." , lnTab + 2 )
					.AgregarLinea( "if !this.lEsSubEntidad and ( this.EsNuevo() or this.EsEdicion() )" , lnTab + 2 )
					.AgregarLinea( "lxVal = This." + alltrim( lcAtributo ) + ".oComportamientoCodigoSugerido.ObtenerPKaAsignar( txVal, This." + alltrim( lcAtributo ) + " )", lnTab + 3 )
					.AgregarLinea( "else" , lnTab + 2 )
					.AgregarLinea( "lxVal = txVal", lnTab + 3 )
					.AgregarLinea( "endif" , lnTab + 2 )
					.AgregarLinea( "this.lBuscandoCodigo = .f." , lnTab + 2 )
					.AgregarLinea( "endif", lnTab + 1 )
				else
					.AgregarLinea( "lxVal = txVal", lnTab + 1 )
				endif

				if alltrim( &lcNombreCursor..TipoDato ) == "C"
					.AgregarLinea( "lxVal = iif( len( lxVal ) < " + transform( &lcNombreCursor..Longitud ) ;
						+ ", padr( lxVal, " + transform( &lcNombreCursor..Longitud ) + " ), lxVal )", lnTab + 1 )
				endif		
				.AgregarLinea( "this." + lcAtributo + "_PK = lxVal", lnTab + 1 )
				.AgregarLinea( "" )
				if upper( &lcNombreCursor..Dominio ) != "ETIQUETACARACTERDESDEHASTABUSC"
					.AgregarLinea( "if this.Validar_" + lcAtributo + "( lxVal" + lcValOld + " )", lnTab + 1 )
			
					if &lcNombreCursor..genHabilitar or !empty( lcValidacion )
						lcLineaCondicion = ""
						if &lcNombreCursor..genHabilitar
							lcLineaCondicion = "if ( this.lHabilitar" + lcAtributo + "_PK or this.lEstaSeteandoValorSugerido" +" or lxValOld == lxVal )"
						endif
						lcLineaCondicion = this.GeneraCondicionAssign( lcLineaCondicion, lcAtributo, lcValidacion, .t. )

						.AgregarLinea( lcLineaCondicion , lnTab + 2)
						.AgregarValidacionDominio( lcNombreCursor, lnTab + 2 )
						.AgregarEventoAntesDeSetear( lcAtributo, lnTab + 3, .T. )
						.AgregarLinea( "This.Setear_" + lcAtributo + "( lxVal )" , lnTab + 3)
						.AgregarEventoDespuesDeSetear( lcAtributo, lnTab + 3, .T. )
						&&lcAsignacion					
						if empty( &lcNombreCursor..DespuesDeAsignacion )
						else
							.AgregarLinea( "This." + lcAtributo + "_PK_DespuesDeAsignar()", lnTab + 3 )
							This.AgregarFuncionDespuesDeAsignar( lcAtributo + "_PK_DespuesDeAsignar", &lcNombreCursor..DespuesDeAsignacion )
						endif
						lnTipoAtributo = iif(!empty(&lcNombreCursor..Sumarizar),1,0)
						do case
						case !empty(&lcNombreCursor..Sumarizar)
							lnTipoAtributo = 1
						case this.EsAtributoPKEnItemConSumarizado( lcAtributo )
							lnTipoAtributo = 2
						endcase
						.AgregarEventoCambioSumarizado( lcAtributo , lnTab + 3, .T., &lcNombreCursor..Obligatorio, lnTipoAtributo )
						
						.VerificarAtributosForaneos( .F. )
						
						.AgregarIfHaCambiado( lnTab + 3 )
						.AgregarEventoHaCambiado( lcAtributo , lnTab + 4, .T. )
						if this.lTieneFuncionalidadPromocion and this.EsAtributoParticipanteDePromocion( lcAtributo )
							this.AgregarLinea( "this.EventoCambioParticipantePromocion()" , lnTab + 3)
						endif
						.AgregarEndIfHaCambiado( lnTab + 3 )

						**.VerificarAtributosForaneos( .F. )
						.AgregarLinea( "else" , lnTab + 2 )
						.AgregarLinea( "this." + lcAtributo + "_PK = lxValOld", lnTab + 3 )
						.AgregarLinea( 'goServicios.Errores.LevantarExcepcion( "No se puede cambiar este valor (Entidad: ' + evaluate( .cDescripcionEntidad ) + ' - Atributo: ' + lcAtributo + ')" )', lnTab + 3 )
						.AgregarLinea( "endif " , lnTab + 2)
					else
						.AgregarValidacionDominio( lcNombreCursor, lnTab + 2 )
						.AgregarEventoAntesDeSetear( lcAtributo, lnTab + 2, .T. )
						.AgregarLinea( "This.Setear_" + lcAtributo + "( lxVal )" , lnTab + 2 )
						.AgregarEventoDespuesDeSetear( lcAtributo, lnTab + 2, .T. )
						&&lcAsignacion					
						if empty( &lcNombreCursor..DespuesDeAsignacion )
						else
							.AgregarLinea( "This." + lcAtributo + "_PK_DespuesDeAsignar()", lnTab + 2 )
							This.AgregarFuncionDespuesDeAsignar( lcAtributo + "_PK_DespuesDeAsignar", &lcNombreCursor..DespuesDeAsignacion )
						EndIf
						lnTipoAtributo = iif(!empty(&lcNombreCursor..Sumarizar),1,0)
						do case
						case !empty(&lcNombreCursor..Sumarizar)
							lnTipoAtributo = 1
						case this.EsAtributoPKEnItemConSumarizado( lcAtributo )
							lnTipoAtributo = 2
						endcase
						.AgregarEventoCambioSumarizado( lcAtributo, lnTab + 2, .T., &lcNombreCursor..Obligatorio, lnTipoAtributo )
						
						.VerificarAtributosForaneos( .F. )
						
						.AgregarIfHaCambiado( lnTab + 2 )
						.AgregarEventoHaCambiado( lcAtributo , lnTab + 3, .T. )
						.AgregarEndIfHaCambiado( lnTab + 2 )
			
					endif 
					
					if this.lTieneFuncionalidadPromocion and this.EsAtributoParticipanteDePromocion( lcAtributo )
						This.AgregarLinea( "If lxValOld != lxVal" , lnTab + 2 )
						this.AgregarLinea( "this.EventoCambioParticipantePromocion()" , lnTab + 3 )
						This.AgregarLinea( "endif" , lnTab + 2)
					endif
					
					if this.lTieneFuncionalidadActualizarEmail and alltrim( upper( lcAtributo ) ) = "CLIENTE" 
						This.AgregarLinea( "If lxValOld != lxVal and alltrim( lxVal ) != ''" , lnTab + 2)
						this.AgregarLinea( "this.EventoActualizarEmail()" , lnTab + 3)
						This.AgregarLinea( "endif" , lnTab + 2)
					endif
					
					.AgregarLinea( "endif", lnTab + 1 )	
				endif 
				.VerificarAtributosForaneos( .T. )
				.AgregarLinea( "dodefault( lxVal )" , lnTab + 1)
				.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsAtributoParticipanteDePromocion( tcAtributo as String ) as Boolean
		local lcCursorPromo as String, lcNombreEntidadPromoPrincipal as String, lcEntidadABuscar as String, lcCursor as String

		lcCursor = sys( 2015 )

		lcCursorPromo = this.cCursorAtributosPromociones 
		lcNombreEntidadPromoPrincipal = this.ObtenerEntidadPromoPrincipal()
		
		if vartype( this.cDominio ) <> 'U' and substr( this.cDominio, 1, 7 )== "DETALLE"
			lcEntidadABuscar = substr( this.cDominio, 8 )
		else
			lcEntidadABuscar = this.cTipo
		endif
		
		select Atributo from &lcCursorPromo as cur ;
			where rtrim(upper( cur.Atributo ))= rtrim(upper( tcAtributo )) ;
				and rtrim(upper( cur.Entidad ))= rtrim(upper( lcEntidadABuscar )) ;
			into cursor (lcCursor)
	
		return ( _tally > 0 )
				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarAtributosPK() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcLinea as String 
		lnTab = 1
		lcLinea = ""
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for &lcNombreCursor..EsEntidad
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Validar_" + lcAtributo + "( txVal as variant, txValOld as variant ) as Boolean", lnTab )
				.AgregarLinea( "" )
				lcLinea =  "Return This.CargaManual() and dodefault( txVal, txValOld )"
				if This.TieneTagPromocion( lcAtributo )
					lcLinea = lcLinea + " and This.ValidarAtributoParticipanteDePromo( '" + lcAtributo + "_Pk', txVal, txValOld )"
				Endif
				if This.lGeneracionDeItem and &lcNombreCursor..validaComp
					lcLinea = lcLinea + " and This.ValidarAtributoComponente( txVal, '" + lcAtributo + "' ) "
				endif

				if This.VerificarFuncionalidad( &lcNombreCursor..ClaveForanea, "DESACTIVABLE" )
					lcLinea = lcLinea + " and This." + lcAtributo + ".oDesactivador.ValidarEstadoActivacion( txVal, txValOld, this.lnuevo, this.ledicion) "
				endif

				if This.lGeneracionDeItem and this.DebeValidarKit( this.cDominio, lcAtributo, this.cTipo )
					lcLinea = lcLinea + " and This.ValidaArticuloTipoKit() "
				endif

				if This.lGeneracionDeItem and this.DebeControlarColorYTalleEnKit( this.cDominio, lcAtributo, this.cTipo )
					lcLinea = lcLinea + " and This.ValidaColorYTalleConKit( txVal ) "
				endif

				.AgregarLinea( lcLinea , lnTab + 1 )

				.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneTagPromocion( tcAtributo as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		if this.lTieneFuncionalidadPromocion
			select c_diccionario
			locate for alltrim( upper( entidad ) ) == This.cEntidadPromoPrincipal and upper( alltrim( Atributo ) ) == upper( alltrim( tcAtributo ) )
			llRetorno =  "<PP>" $ upper( Tags )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarAtributos() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcLinea as String
		lnTab = 1
		
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for !&lcNombreCursor..esEntidad and !&lcNombreCursor..detalle .and. !&lcNombreCursor..claveprimaria
				lcLinea = ""
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Validar_" + lcAtributo + "( txVal as variant ) as Boolean", lnTab )
				.AgregarLinea( "" )
				if upper( alltrim( &lcNombreCursor..centidad ) ) == upper( alltrim( This.cTipo )) and This.TieneTagPromocion( lcAtributo )
					lcLinea = " and This.ValidarAtributoParticipanteDePromo( '" + lcAtributo + "', txVal, this." + lcAtributo + " )"
				Endif

				if This.lGeneracionDeItem and &lcNombreCursor..validaComp
					.AgregarLinea( "Return dodefault( txVal ) and This.ValidarAtributoComponente( txVal, '" + lcAtributo + "' ) " + lcLinea , lnTab + 1 )
				else
					.AgregarLinea( "Return dodefault( txVal ) "  + lcLinea , lnTab + 1 )
				endif

				.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosPK() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string, lcAsignacion as String				

		lnTab = 1
		with this
			lcNombreCursor = .cCursorAtributos
			select ( lcNombreCursor )
			scan for &lcNombreCursor..EsEntidad
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )
				lcAsignacion = "this." + lcAtributo + "." + this.ObtenerAtributoClavePrimaria( lcEntidad ) + " = txVal"
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Setear_" + lcAtributo + "( txVal as variant ) as void", lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( lcAsignacion , lnTab + 1)
				.AgregarLinea( "dodefault( txVal )" , lnTab + 1)
				.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributos() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer

		lnTab = 1
		with this
			lcNombreCursor = .cCursorAtributos
			select ( lcNombreCursor )
			scan for !&lcNombreCursor..esEntidad and !&lcNombreCursor..detalle .and. !&lcNombreCursor..claveprimaria
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				lcAsignacion = "this." + lcAtributo + " = txVal"
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Setear_" + lcAtributo + "( txVal as variant ) as void", lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( lcAsignacion , lnTab + 1)
				.AgregarLinea( "dodefault( txVal )" , lnTab + 1)
				.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarVariableHaCambiado( tcAtributo As String, tnTab As Integer ) as String
		local lcRetorno as String

		lcRetorno = this.DeclararYResguardarVariablesValorViejo( tcAtributo, tnTab )
		if right( alltrim( tcAtributo ), 3 ) == "_PK"
		else
			lcRetorno = ""
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DeclararYResguardarVariablesValorViejo( tcAtributo As String, tnTab As Integer ) as String
		With this
			.AgregarLinea( "Local lxValOld As Variant", tnTab )
			.AgregarLinea( "lxValOld = this." + tcAtributo , tnTab )
		endwith
		
		return ", lxValOld"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarIfHaCambiado( tnTab As Integer ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEndIfHaCambiado( tnTab As Integer ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AssignFuncionalidadAtributos() as Void
		local lcNombreCursor as string
		with this
			lcNombreCursor = .cCursorAtributos
			select ( lcNombreCursor )
			go top 
			
			scan for !&lcNombreCursor..esEntidad and !&lcNombreCursor..detalle .and. !&lcNombreCursor..claveprimaria
				this.EscribirAssignAtributo( lcNombreCursor )
				select ( lcNombreCursor )
			endscan

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EscribirAssignAtributo( tcNombreCursor as String ) as Void
		local lcAtributo as string, lnTab as Integer, lcEntidad as string, lcValidacion as String, ;
			lcLineaCondicion as String, lcComparacionGenHabilitar as String

		lnTab = 1

		lcAtributo = alltrim( proper ( &tcNombreCursor..Atributo ) )
		lcEntidad =  alltrim( proper( &tcNombreCursor..cEntidad ) )
		lcValidacion = alltrim( proper( &tcNombreCursor..Validacion ) )

		with This
			if !empty( &tcNombreCursor..DespuesDeAsignacion )
				.AgregarFuncionDespuesDeAsignar( lcAtributo + "_DespuesDeAsignar", &tcNombreCursor..DespuesDeAsignacion )
			EndIf		
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function " + lcAtributo + "_Assign( txVal as variant ) as void", lnTab )
			.AgregarLinea( "" )
			.AgregarVariableHaCambiado( lcAtributo, lnTab + 1 )

			.AgregarLinea( "local lxVal as Variant", lnTab + 1 )
			.AgregarLinea( "lxVal = txVal", lnTab + 1 )
			
			.AgregarLinea( "" )
			.AgregarLinea( "if This.CargaManual()", lnTab + 1)
				.AgregarLinea( "if this.Validar_" + lcAtributo + "( lxVal )", lnTab + 2)
					lcLineaCondicion = ""
					if &tcNombreCursor..genHabilitar
						if &tcNombreCursor..TipoDato = "C"
							lcComparacionGenHabilitar = "alltrim( lxValOld ) == alltrim( lxVal )"
						else
							lcComparacionGenHabilitar = "lxValOld == lxVal"
						endif
						lcLineaCondicion = lcLineaCondicion + "if ( this.lHabilitar" + lcAtributo + " or this.lEstaSeteandoValorSugerido or " + lcComparacionGenHabilitar + ")"
					endif
					if empty( &tcNombreCursor..Validacion )
					else
						lcLineaCondicion = this.GeneraCondicionAssign( lcLineaCondicion, lcAtributo, lcValidacion, .f. )
					endif
					
					if &tcNombreCursor..genHabilitar or !empty( &tcNombreCursor..Validacion )
						.AgregarVerificacionHabilitacionAtributos( lcAtributo, lnTab + 1, lcLineaCondicion, tcNombreCursor )
					else
						.AgregarDespuesDeAsignar( lcAtributo, lnTab + 1, lcLineaCondicion, tcNombreCursor )
					endif
				
					.AgregarNumeracionRelacionada( lcAtributo )
				.AgregarLinea( "EndIf", lnTab + 2)
			*Agregar si tiene numeracion asociada y es condicion el atributo para que obtenga el numero
			.AgregarLinea( "Else", lnTab + 1)
				.AgregarLinea( "This.Setear_" + lcAtributo + "( lxVal ) ", lnTab + 2)
				
				if this.lTieneFuncionalidadPromocion and this.EsAtributoParticipanteDePromocion( lcAtributo )
					*This.AgregarLinea( "If lxValOld != lxVal" , lnTab + 2)
					This.AgregarLinea( "If this.ValidarSiCambioElValorDelAtributo( '" + lcAtributo + "', lxValOld, lxVal )" , lnTab + 2)
					if upper( alltrim( &tcNombreCursor..centidad ) ) == upper( alltrim( This.cTipo )) and This.TieneTagPromocion( lcAtributo )
						this.AgregarLinea( "This.ValidarAtributoSecundarioParticipanteDePromo( '" + lcAtributo + "', lxVal, lxValOld )", lnTab + 3)
					endif
					this.AgregarLinea( "this.EventoCambioParticipantePromocion()" , lnTab + 3)
					This.AgregarLinea( "endif" , lnTab + 2)
				endif				
			.AgregarLinea( "EndIf", lnTab + 1)

			.AgregarLinea( "dodefault( lxVal )" , lnTab + 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )

		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HayQueAgregarCondicionDeCargaManual( tcNombreCursor as String ) as Boolean
		return &tcNombreCursor..genHabilitar or ;
			   This.ValidarDominio( &tcNombreCursor..dominio ) or ;
			   !empty( &tcNombreCursor..Validacion ) or ;
			   !empty( &tcNombreCursor..DespuesDeAsignacion ) or ;
			   this.lTieneNumeraciones or ;
			   this.lGeneracionDeItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarNumeracionRelacionada( tcAtributo ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarVerificacionHabilitacionAtributos( tcAtributo as String, tnTab as Integer, tcLineaCondicion as String, tcNombreCursor as String ) as Void
		local lcEntidad as String
		
		with This
			.AgregarLinea( tcLineaCondicion, tnTab + 2 )
			.AgregarDespuesDeAsignar ( tcAtributo, tnTab + 1, tcLineaCondicion, tcNombreCursor )
			.AgregarLinea( "else" , tnTab + 2)
			.AgregarLinea( "this." + tcAtributo + " = lxValOld", tnTab + 3 )
			.AgregarLinea( 'goServicios.Errores.LevantarExcepcion( "No se puede cambiar este valor (Entidad: ' + evaluate( .cDescripcionEntidad ) + ' - Atributo: ' + tcAtributo + ')" )', tnTab + 3 )
			.AgregarLinea( "endif " , tnTab + 2 )
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDespuesDeAsignar( tcAtributo as String, tnTab as Integer, tcLineaCondicion as String, tcNombreCursor as String ) as Void
		local lnTab as Integer, lnTipoAtributo as Integer
		
			lnTab = 0
			if this.HayQueAgregarCondicionDeCargaManual( tcNombreCursor )
				lnTab = 2
			endif
			
			.AgregarValidacionDominio( tcNombreCursor, tnTab + lnTab )
			.AgregarEventoAntesDeSetear( tcAtributo, tnTab + 2, .F. )
			.AgregarLinea( "this.Setear_" + tcAtributo + "( lxVal )" , tnTab + 2)
			.AgregarEventoDespuesDeSetear( tcAtributo, lnTab + 2, .F. )
			if empty( &tcNombreCursor..DespuesDeAsignacion )
			else
				.AgregarLinea( " This." + tcAtributo + "_DespuesDeAsignar()", tnTab + 2 )
			endif
			lnTipoAtributo = iif(!empty(&tcNombreCursor..Sumarizar),1,0)
			.AgregarEventoCambioSumarizado( tcAtributo, tnTab + 2 , .F., &tcNombreCursor..Obligatorio, lnTipoAtributo )

			.AgregarIfHaCambiado( tnTab + 2 )

			.AgregarEventoHaCambiado( tcAtributo, tnTab + 3 , .F. )
			
					if this.lTieneFuncionalidadPromocion and this.EsAtributoParticipanteDePromocion( tcAtributo )
						This.AgregarLinea( "If this.ValidarSiCambioElValorDelAtributo( '" + tcAtributo + "', lxValOld, lxVal )" , lnTab + 3)
						this.AgregarLinea( "this.EventoCambioParticipantePromocion()" , lnTab + 4)
						This.AgregarLinea( "EndIf" , lnTab + 3)
					endif
			.AgregarEndIfHaCambiado( tnTab + 2 )
	endFunc

	*-----------------------------------------------------------------------------------------
	function GeneraCondicionAssign( tcLineaCondicion as string, tcAtributo as string , tcValidacion as String , tlEsPk as Boolean ) as String
		local lcCondicionAsign as String, lcParametros as String , lcCondicionValidacion as String , lcAtributo as String 
			
			lcLineaCondicion = tcLineaCondicion
			lcCondicionValidacion  = ""
			lcAtributo = iif( tlEsPk , tcAtributo + "_PK" , tcAtributo )
			
			if empty( tcValidacion )
			else
				if upper( "this." + lcAtributo + " " ) $ upper( tcValidacion )
					lcParametros = "( txVal )"
				else
					lcParametros = "()"
				endif
				lcCondicionValidacion = "This.Validacion_" + lcAtributo + lcParametros

				if empty( lcLineaCondicion )
					lcLineaCondicion = "if " + lcCondicionValidacion
				else
					lcLineaCondicion = lcLineaCondicion + " and " + lcCondicionValidacion
				endif
			endif
			
		return lcLineaCondicion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarValidacionADNAtributos() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string, ;
				lcValidacion as String

		lnTab = 1
		
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for !empty( &lcNombreCursor..Validacion ) and !&lcNombreCursor..detalle

				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) ) 
				if &lcNombreCursor..EsEntidad
					lcAtributo = lcAtributo+ "_PK"
				endif

				lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )
				lcValidacion = alltrim(( &lcNombreCursor..Validacion ) )
				lcParametro = ""
				if upper( "This." + lcAtributo ) $ upper( lcValidacion )
					lcParametro = " lxValorAtributo as Variant "
					do while( upper( "This." + lcAtributo + " " ) $ upper( lcValidacion ) )
						lcValidacion = strtran(  upper( lcValidacion ) , upper( "This." + lcAtributo + " " ), "lxValorAtributo" )
					enddo
				endif

				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function " + "Validacion_" + lcAtributo + "( " + lcParametro + " ) as boolean", lnTab )
					.AgregarLinea( "local llRetorno as boolean", lnTab + 1 )
						.AgregarLinea( "try", lnTab + 2)					
							.AgregarLinea( "llRetorno = ( " + lcValidacion + " ) ", lnTab + 3 )
						.AgregarLinea( "Catch to loError" , lnTab + 2 )
							.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )" , lnTab + 3)
							.AgregarLinea( 'With loEx', lnTab + 3)
								.AgregarLinea( '.Grabar( loError )', lnTab + 4)
								.AgregarLinea( '.Throw()', lnTab + 4)
							.AgregarLinea( 'EndWith', lnTab + 3)

						.AgregarLinea( "EndTry" , lnTab + 2)
					.AgregarLinea( "Return llRetorno" , lnTab + 1)
					.AgregarLinea( "" )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )

			endscan
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarDestroy() as Void
		local lnTab as Integer
		
		lnTab = 1

		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( 'function Destroy()', lnTab )
			.AgregarLinea( "" )
			.AgregarLinea( 'this.lDestroy = .t.', lnTab + 1 )
			.AgregarCuerpoDestroy( lnTab )
			.AgregarLinea( 'dodefault()', lnTab + 1 )
			.AgregarLinea( 'endfunc', lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCuerpoDestroy( tnTab as integer) as Void
		local lcCursor As String

		with this
			lcCursor = This.cCursorComponentes
			select &lcCursor
			if reccount()>0
				scan All
					.AgregarLinea( "this.oComp" + alltrim( &lcCursor..componente ) + " = null" , tnTab + 1 )
					select &lcCursor
				endscan
			endif
		
			if .lTieneComponenteEnBaseA and alltrim( upper( this.cprefijo ) ) # 'ITEM'
				.AgregarLinea( "this.oCompEnBaseA = null" , tnTab + 1 )
			endif
			
			if this.lTieneNumeraciones and alltrim( upper( this.cprefijo ) ) # 'ITEM'
				lcCursor = This.cCursorRelaNum
				select &lcCursor
				if reccount()>0
					.AgregarLinea( 'if vartype( this.oNumeraciones ) == "O" and !isnull( this.oNumeraciones )', tnTab + 1 )
					.AgregarLinea( "this.oNumeraciones.Release()", tnTab + 2 )
					.AgregarLinea( "endif", tnTab + 1 )										
					.AgregarLinea( "this.oNumeraciones = null" , tnTab + 1 )
				endif
			endif
			
			if this.lTieneFuncionalidadDesactivable and alltrim( upper( this.cprefijo ) ) # 'ITEM'
				.AgregarLinea( "this.oDesactivador = null" , tnTab + 1 )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarAtributosForaneos( tlEsVirtual ) as Void
		local lcConsulta As String, lcAtributo AS String, lcCursor As String ,lnTab as Integer
		lnTab = iif( tlEsVirtual, 1, 2 )
		lcConsulta = sys( 2015 )
		lcCursor = This.cCursorAtributos
		lcAtributo = alltrim( Upper ( &lcCursor..Atributo ) )
		select * ;
			from &lcCursor ;
			where	lcAtributo == upper( getwordnum( AtributoForaneo, 1, "." ) ) .And. ;
					empty( Campo ) = tlEsVirtual ;
			into cursor &lcConsulta Nofilter
		select &lcConsulta

		scan All
			This.AgregarLinea( "If lxValOld != lxVal or empty( this." + alltrim( proper ( &lcConsulta..Atributo ) ) ;
				+ iif( &lcConsulta..EsEntidad,"_PK","")+" ) " , lnTab + 1 )
				if &lcConsulta..EsEntidad
					.AgregarLinea( "this." + alltrim( proper ( &lcConsulta..Atributo ) ) + "_Pk = " + ;
					"This." + alltrim( &lcConsulta..AtributoForaneo ) + "_PK" , lnTab + 2 )
				else
					.AgregarLinea( "this." + alltrim( proper ( &lcConsulta..Atributo ) ) + " = This." + alltrim(  &lcConsulta..AtributoForaneo ), lnTab + 2 )
				endif
			This.AgregarLinea( "endif", lnTab + 1)
		endscan
		use in select( lcConsulta )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEventoCambioSumarizado( tcAtributo as String, tnTab as Integer, TlEsPk as Boolean, tlEsObligatorio as Boolean, tnTipoAtributo as Integer ) as Void

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarEventoHaCambiado( tcAtributo as String, tnTab as Integer, TlEsPk as Boolean ) as Void

	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function 	AgregarEventoAntesDeSetear( tcAtributo as String, tnTab as Integer, TlEsPk as Boolean ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEventoDespuesDeSetear( tcAtributo as String, tnTab as Integer, TlEsPk as Boolean ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AccessSubentidades() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string

		lnTab = 1
		
		with this
			lcNombreCursor = .cCursorAtributos
			
			select ( lcNombreCursor )
			scan for &lcNombreCursor..EsEntidad
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ) )
				lcEntidad =  alltrim( proper( &lcNombreCursor..cEntidad ) )
			
				.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function " + lcAtributo + "_Access() as variant", lnTab )
				.AgregarLinea( "if this.ldestroy", lnTab + 1 )
				.AgregarLinea( "else", lnTab + 1 )				
				.AgregarLinea( "if This.lInstanciarSubEntidadaDemanda", lnTab + 2 )
				.AgregarLinea( "if ( !vartype( this." + lcAtributo +" ) = 'O' or isnull( this." + lcAtributo +" ) )", lnTab + 3 )
				.AgregarLinea( "this." + lcAtributo + " = _Screen.zoo.instanciarentidad( '" + lcEntidad + "' )", lnTab + 4 )
				.AgregarLinea( "this." + lcAtributo + ".lEsSubEntidad = .t.", lnTab + 4 )
				.AgregarBindeosZooSession( lcAtributo, lnTab + 4 )
				.AgregarLinea( "endif", lnTab + 3 )
				.AgregarLinea( "if !this.lBuscandoCodigo", lnTab + 3 )
				.AgregarLinea( "if this." + lcAtributo + "." + this.ObtenerAtributoClavePrimaria( lcEntidad ) + " # this." + lcAtributo + "_PK", lnTab + 4 )
				.AgregarLinea( "this." + lcAtributo + "." + this.ObtenerAtributoClavePrimaria( lcEntidad ) + " = this." + lcAtributo + "_PK", lnTab + 5 )
				.AgregarLinea( "endif", lnTab + 4 )
				.AgregarLinea( "endif", lnTab + 3 )				
				.AgregarLinea( "endif", lnTab + 2 )
				.AgregarLinea( "endif", lnTab + 1 )
				.AgregarLinea( "return this." + lcAtributo, lnTab + 1 )
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AccessComponentes() as Void
		local lcNombreCursor as string, lcAtributo as string, lcComponente as string

		with this
			lcNombreCursor = .cCursorComponentes
			
			select ( lcNombreCursor )
			scan
				lcComponente =  alltrim( proper( &lcNombreCursor..componente) )
				lcAtributo = alltrim( "oComp" + alltrim( lcComponente ) )
			
				.AgregarCodigoAccessComponentes( lcComponente, lcAtributo ) 
			endscan
			
			if .lTieneComponenteEnBaseA
			.AgregarCodigoAccessComponentes( "EnBaseA", "oCompEnBaseA" )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCodigoAccessComponentes( tcComponente, tcAtributo ) as Void
		local lcComponente as String, lcAtributo as string, lnTab as Integer
		
		lnTab = 1
		lcComponente = tcComponente
		lcAtributo = tcAtributo
		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function " + lcAtributo + "_Access() as variant", lnTab )
			.AgregarLinea( "if !this.ldestroy and ( !vartype( this." + lcAtributo +" ) = 'O' or isnull( this." + lcAtributo +" ) )", lnTab + 1 )
						
			if lcComponente = "Facturacionelectronica"
				.AgregarLinea( "if this.lEsCAEUruguay ", lnTab + 2 )      
				.AgregarLinea( 	"this." + lcAtributo + " = _Screen.zoo.InstanciarComponente( 'Componente" + lcComponente + "Uruguay' )", lnTab + 3 )
				.AgregarLinea( "if goServicios.Parametros.Felino.GestiondeVentas.FacturacionElectronica.Uruguay.ENVIARUNIDADDEMEDIDACONFIGURADAENELARTICULO ", lnTab + 3)
				.AgregarLinea("bindevent( this.facturadetalle, 'EventoCargarUnidadDeMedida', this." + lcAtributo + ", 'CargarUnidadDeMedidaPorArticulo') ", lnTab + 4)
				.AgregarLinea( "bindevent( this, 'Limpiar', this." + lcAtributo + ", 'LimpiarColecciondeUnidades') ", lnTab + 4)
				.AgregarLinea( "endif ", lnTab + 3)
				.AgregarLinea( "else", lnTab + 2 )   
				.AgregarLinea( "this." + lcAtributo + " = _Screen.zoo.InstanciarComponente( 'Componente" + lcComponente + "' )", lnTab + 3 )
				.AgregarLinea( "endif", lnTab + 2 )
			else
				.AgregarLinea( 	"this." + lcAtributo + " = _Screen.zoo.InstanciarComponente( 'Componente" + lcComponente + "' )", lnTab + 2 )		
			endif
			
			.AgregarLinea( "this.oComp" + lcComponente + ".Inicializar()", 2 )
			.AgregarBindeosZooSession( lcAtributo, 2 )
			.AgregarLinea( "endif", lnTab + 1 )
			.AgregarLinea( "return this." + lcAtributo, lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionValidarSiCambioElValorDelAtributo() as Void
		local lcAtributo as String, lcNombreCursor as String, lcAtributoAux as string, lcValorVacio as string, ;
			lnTab as integer, lcCursorEntidad as String, llSetearValoresSugeridos as Boolean, llTieneSumarizado as Boolean

		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )

			.AgregarLinea( "function ValidarSiCambioElValorDelAtributo( tcAtributo as String, txValOld as variant, txVal as variant ) as Boolean", lnTab )
				.AgregarLinea( "local llRetorno as Boolean", lnTab + 1 )
				.AgregarLinea( "llRetorno = dodefault( tcAtributo, txValOld, txVal )", lnTab + 1 )
				.AgregarLinea( "if pemstatus( this, 'NroItem', 5 ) and this.NroItem > 0 and pemstatus( this, 'oDetalle', 5 ) and type( 'this.oDetalle' ) = 'O'", lnTab + 1 )
					.AgregarLinea( "local lcCondicion as String", lnTab + 2 )
					.AgregarLinea( "lcCondicion = 'this.oDetalle.Item[ this.NroItem ].' + tcAtributo + ' != txVal'", lnTab + 2 )
					.AgregarLinea( "llRetorno = llRetorno and ( &lcCondicion )", lnTab + 2 )
				.AgregarLinea( "endif", lnTab + 1 )
				.AgregarLinea( "return llRetorno", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab)
			
			.AgregarLinea( "" )
		endwith
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

						if this.lTieneAtributosSumarizados
							.AgregarLinea( ".CambioSumarizado()", lnTab + 3 )
						endif
					.AgregarLinea( "EndTry", lnTab + 2 )
				.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab)
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarLimpiarAD( tnTab as Integer ) as Void
		dodefault( tnTab )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionSetearCodigoSugeridoEnLimpiar() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionSetearValoresSugeridos() as Void
		local lcAtributo as String, lcNombreCursor as String, lcAtributoAux as string, lcValorVacio as string, ;
			lnTab as integer, lcTexto as String

		lnTab = 1

		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "Function SetearValoresSugeridos() as Void", lnTab )
			lnTab = lnTab + 1
			.AgregarLinea( "With This", lnTab )
			lnTab = lnTab + 1
			.AgregarSeteoFlagCargandoSugeridos( ".T." , lnTab )

			This.FuncionSetearCodigoSugeridoEnLimpiar()

			lcNombreCursor = .cCursorAtributos
			select ( lcNombreCursor )
			scan for !empty( &lcNombreCursor..ValorSugerido )
				if lnTab = 3
					lcTexto = "If .EsNuevo()" 
					if .lGeneracionDeItem
						lcTexto = lcTexto + " or .EsEdicion()"
					endif
					.AgregarLinea( lcTexto, lnTab )
					lnTab = lnTab + 1
				endif
			endscan
			if !This.lGeneracionDeItem
				.AgregarLinea( 'if !this.lEsSubEntidad', 4 )
			endif
			.AgregarLlamadaValoresSugeridosUsuario()
			if lnTab = 4
				.AgregarLlamadaValoresSugeridosFramework()
				lnTab = lnTab - 1
				.AgregarLinea( "EndIf", lnTab )
			endif
			if !This.lGeneracionDeItem
				.AgregarLinea( 'endif', 4 )
			endif
			.AgregarSeteoFlagCargandoSugeridos( ".F." , lnTab )
			lnTab = lnTab - 1
			.AgregarLinea( "EndWith", lnTab )
			lnTab = lnTab - 1
			.AgregarLinea( "EndFunc", lnTab )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarSeteoFlagCargandoSugeridos( tcFlag as String , tnTabulado as Integer ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaValoresSugeridosUsuario() as Void
		local lcTexto as String
		
		with this
		.AgregarLinea( 'if this.oColeccionVSFW.Buscar( "Fecha" )', 4 )
			.AgregarLinea( 'lcValorSugeridoFecha = this.oColeccionVSFW.Item[ "Fecha" ]', 5 )
			.AgregarLinea( '&lcValorSugeridoFecha', 5 )
		.AgregarLinea( 'endif', 4 )		
		.AgregarLinea( 'if this.oColeccionVSFW.Buscar( "Listadeprecios" )', 4 )
			.AgregarLinea( 'lcValorSugeridoListaDePrecios = this.oColeccionVSFW.Item[ "Listadeprecios" ]', 5 )
			.AgregarLinea( '&lcValorSugeridoListaDePrecios', 5 )
		.AgregarLinea( 'endif', 4 )
		
		.AgregarLinea( "for each ValorSugeridoPorEntidadSaltoDeCampo in this.oColeccionVS", 4 )
			.AgregarLinea( "&ValorSugeridoPorEntidadSaltoDeCampo", 4 + 1 )
		.AgregarLinea( "endfor", 4 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaValoresSugeridosFramework() as Void
		local lcTexto as String
		
		with this
		.AgregarLinea( "for each ValorSugeridoDeFramework in this.oColeccionVSFW", 4 )
			.AgregarLinea( 'if ( upper( alltrim( ValorSugeridoDeFramework ) ) == ".VALORSUGERIDOFWLISTADEPRECIOS()" and !empty( this.ListaDePrecios_PK )) or ;', 5 )
			.AgregarLinea( '   ( upper( alltrim( ValorSugeridoDeFramework ) ) == ".VALORSUGERIDOFWFECHA()" and !empty( this.Fecha ))', 5 )
			.AgregarLinea( 'else',5 )
				.AgregarLinea( "&ValorSugeridoDeFramework", 6 )
			.AgregarLinea( 'endif', 5 )
		.AgregarLinea( "endfor", 4 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLlamadaValorSugeridoFW( tcAtributo as string, tnTab as Integer ) as Void
		local lcTexto as String
		
		with this
			.AgregarLinea( ".ValorSugerido" + tcAtributo + "()", 1 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarBlanqueoAtributo( tcCursor as String, tnTab as integer ) as void
		local lcAtributo as string, lcValorVacio  as string, lcAtributoAux  as String
		
		with this
			lcAtributo = alltrim( proper ( &tcCursor..Atributo ))
			if .AgregarObtencionNumero( lcAtributo ) or !.EsAtributoBlanqueable( lcAtributo )
			else
				lcValorVacio = goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( alltrim( &tcCursor..TipoDato ) ) )
				if &tcCursor..Detalle
					.AgregarLinea( "." + lcAtributo + ".Limpiar()" , tnTab + 3 )
				else
					lcAtributoAux = "." + lcAtributo + iif( &tcCursor..EsEntidad, "_PK", "" )
					.AgregarLinea( lcAtributoAux + " = " + lcValorVacio, tnTab + 3 )					
				endif
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarObtencionNumero( tcAtributo as String ) as boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoBlanqueable( tcAtributo as String ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneValorSugerido( tcCursor as string ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = !empty( &tcCursor..ValorSugerido ) or ;
							( &tcCursor..Alta and !(&tcCursor..ClavePrimaria) and !(&tcCursor..saltocampo) and ;
								!this.oFunc.TieneFuncionalidad( "NOSALTODECAMPO", &tcCursor..Tags ) and ;
								substr( upper( &tcCursor..Dominio ), 1, 7 ) != "DETALLE" )

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionesValorSugeridosYFW() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcValorVacio as string,;
		 lcValorSugerido as String, lcNombreFuncion as String, lcAtributoAux as string, llTieneValorSugeridoDeFramework as Boolean, llPuedeTenerValorSugeridoPorElUsuario as Boolean, ;
		 	llEsEntidad as Boolean, lcDetalle as String, lcTipoDeDato as String, lcMensajeAgregarInformacion as String

		lnTab = 1
	
		with this
			lcNombreCursor = .cCursorAtributos
			lcDetalle = this.cSufijo
			select ( lcNombreCursor )
			scan for this.TieneValorSugerido( lcNombreCursor )
				llTieneValorSugeridoDeFramework = !empty( &lcNombreCursor..ValorSugerido )
				llPuedeTenerValorSugeridoPorElUsuario = !this.oFunc.TieneFuncionalidad( "NOSALTODECAMPO", &lcNombreCursor..Tags ) and !&lcNombreCursor..SaltoCampo and &lcNombreCursor..Alta
				llEsEntidad = (&lcNombreCursor..EsEntidad)
				lcValorSugerido = alltrim(&lcNombreCursor..ValorSugerido)
				lcAtributo = alltrim( proper ( &lcNombreCursor..Atributo ))
				lcAtributoAux = "." + lcAtributo + iif( &lcNombreCursor..EsEntidad, "_PK", "" )
				lcValorVacio = goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( alltrim( &lcNombreCursor..TipoDato ) ) )
				lcTipo = left( lcValorSugerido, 1 )
				lcTipoDato = alltrim( &lcNombreCursor..TipoDato )
				do case
					case inlist( lcTipo, "@" )
						lcNombreFuncion = alltrim( substr( lcValorSugerido, 2 ) )
						lcNombreFuncion = lcNombreFuncion + iif( at( '(', lcNombreFuncion ) = 0, '()', '' )

						lcVal = "this." + lcNombreFuncion

					case inlist( left( lcValorSugerido, 1 ), "=" )
						lcVal = substr( lcValorSugerido, 2 )

					case lcTipoDato = "N"
						lcVal = alltrim( lcValorSugerido )
					
					case lcTipoDato = "D"
						lcVal = substr( lcValorSugerido, 2 )
					
					otherwise
						lcVal = "'" + lcValorSugerido + "'"

				endcase
				lcTipoDeDato = upper( alltrim( &lcNombreCursor..TipoDato ) )
				lcTipoDeDato = iif( lcTipoDeDato = "G" or lcTipoDeDato = "M", "C", lcTipoDeDato )
				
				if llPuedeTenerValorSugeridoPorElUsuario
					.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
					.AgregarLinea( "Function ValorSugerido" + lcAtributo + "() as void", lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( "local lcExpresionValorSugeridoDefinidoPorElUsuario as String, lvValorSugeridoDefinidoPorElUsuario as Variant, loError as Object, loEx as Object, loExTipoDato as Object", lnTab )
					.AgregarLinea( "lcExpresionValorSugeridoDefinidoPorElUsuario = null", lnTab )
					.AgregarLinea( "with this", lnTab )
					lnTab = lnTab + 1

					if (llEsEntidad)
						.AgregarLinea( "try", lnTab )
						lnTab = lnTab + 1
					endif
				
					.AgregarLinea( [lcExpresionValorSugeridoDefinidoPorElUsuario = goServicios.SaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( "] + this.cTipo + [", "] + lcDetalle +  [", "] + lcAtributo + [" )], lnTab )
					.AgregarLinea( [if !isnull( lcExpresionValorSugeridoDefinidoPorElUsuario )], lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( [if !empty( lcExpresionValorSugeridoDefinidoPorElUsuario )], lnTab )
					lnTab = lnTab + 1
					if !(llEsEntidad)
						.AgregarLinea( [try], lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( "lvValorSugeridoDefinidoPorElUsuario = " + [&lcExpresionValorSugeridoDefinidoPorElUsuario], lnTab )
					.AgregarLinea( [if vartype( lvValorSugeridoDefinidoPorElUsuario ) # "] + lcTipoDeDato + ["] , lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( [loExTipoDato = newobject("zooexception", "zooexception.prg" )], lnTab )
					.AgregarLinea( [loExTipoDato.Message = "Error de tipo de dato."], lnTab )
					.AgregarLinea( [loExTipoDato.Throw()], lnTab )
					lnTab = lnTab - 1
					.AgregarLinea( [endif], lnTab )
					.AgregarLinea( [This.EventoEstaSeteandoValorSugerido( '] + substr( lcAtributoAux, 2 ) + [' )], lnTab )
					.AgregarLinea( lcAtributoAux + " = lvValorSugeridoDefinidoPorElUsuario", lnTab )
					if !(llEsEntidad)
						lnTab = lnTab - 1
						.AgregarLinea( [catch to loError], lnTab )
						lnTab = lnTab + 1
						.AgregarLinea( [loEx = newobject("zooexception", "zooexception.prg" )], lnTab )
						.AgregarLinea( [loEx.Grabar( loError )], lnTab )
						.AgregarLinea( [loEx.AgregarInformacion( iif( type( "loError.UserValue.Message" ) == "C", loError.UserValue.Message, loError.Message ) )], lnTab )
						lcMensajeAgregarInformacion = this.ObtenerExcepcionPorValorSugeridoDefinidoPorElUsuario( "lcExpresionValorSugeridoDefinidoPorElUsuario", lcDetalle, &lcNombreCursor..Titulo, &lcNombreCursor..Etiqueta, lcTipoDeDato )
						.AgregarLinea( [loEx.AgregarInformacion( ] + lcMensajeAgregarInformacion + [ )], lnTab )
						.AgregarLinea( [goServicios.Errores.LevantarExcepcion( loEx )], lnTab )
						lnTab = lnTab - 1
						.AgregarLinea( [endtry], lnTab )
					endif
					if (llEsEntidad)
						.AgregarLinea( "." + lcAtributo + "." + .ObtenerAtributoClavePrimaria( &lcNombreCursor..cEntidad ) + " = " + lcAtributoAux, lnTab )
					endif
					lnTab = lnTab - 1
					.AgregarLinea( [endif], lnTab )
					if llTieneValorSugeridoDeFramework
						lnTab = lnTab - 1
						.AgregarLinea( [else], lnTab )
						lnTab = lnTab + 1
						.AgregarLinea( ".ValorSugeridoFW" + lcAtributo + "()", lnTab )
					endif

					if (llEsEntidad)
						lnTab = lnTab - 1
						.AgregarLinea( [endif], lnTab )
						lnTab = lnTab - 1
						.AgregarLinea( "Catch to loError", lnTab )
						lnTab = lnTab + 1
						.AgregarLinea( lcAtributoAux + "=" + lcValorVacio, lnTab )
						.AgregarLinea( [loEx = newobject("zooexception", "zooexception.prg" )], lnTab )
						.AgregarLinea( [loEx.Grabar( loError )], lnTab )
						.AgregarBloqueDeExcepcionPorValorSugeridoDefinidoPorElUsuario( "lcExpresionValorSugeridoDefinidoPorElUsuario", lcDetalle, &lcNombreCursor..Titulo, &lcNombreCursor..Etiqueta, lcTipoDeDato, lnTab )
						lnTab = lnTab - 1
						.AgregarLinea( "endtry ", lnTab )
					else
						lnTab = lnTab - 1
						.AgregarLinea( [endif], lnTab )
					endif

					lnTab = lnTab - 1
					.AgregarLinea( "endwith", lnTab )
					lnTab = lnTab - 1
					.AgregarLinea( "endfunc", lnTab )
					.AgregarLinea( "" )
				endif
				if llTieneValorSugeridoDeFramework 
					.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
					.AgregarLinea( "Function ValorSugeridoFW" + lcAtributo + "() as void", lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( "with this", lnTab )
					lnTab = lnTab + 1
					if (llEsEntidad)
						.AgregarLinea( "try", lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( lcAtributoAux + " = " + lcVal, lnTab )

					if (llEsEntidad)
						if upper( &lcNombreCursor..Dominio ) != "ETIQUETACARACTERDESDEHASTABUSC"
							.AgregarLinea( "." + lcAtributo + "." + .ObtenerAtributoClavePrimaria( &lcNombreCursor..cEntidad ) + " = " + lcAtributoAux, lnTab )
						endif
						lnTab = lnTab - 1
						.AgregarLinea( "Catch to loError", lnTab )
						lnTab = lnTab + 1
						.AgregarLinea( lcAtributoAux + "=" + lcValorVacio, lnTab )
						.AgregarLinea( [loEx = newobject("zooexception", "zooexception.prg" )], lnTab )
						.AgregarLinea( [loEx.Grabar( loError )], lnTab )
						lnTab = lnTab - 1
						.AgregarLinea( "endtry ", lnTab )
					endif
					lnTab = lnTab - 1
					.AgregarLinea( "endwith", lnTab )
					lnTab = lnTab - 1
					.AgregarLinea( "endfunc", lnTab )
					.AgregarLinea( "" )
					if !llPuedeTenerValorSugeridoPorElUsuario
						.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
						.AgregarLinea( "Function ValorSugerido" + lcAtributo + "() as void", lnTab )
						.AgregarLinea( "with this", lnTab + 1)
						.AgregarLinea( ".ValorSugeridoFW" + lcAtributo + "()", lnTab + 2 )
						.AgregarLinea( "endwith", lnTab + 1)
						.AgregarLinea( "endfunc", lnTab )
					endif
				endif
			endscan
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarBloqueDeExcepcionPorValorSugeridoDefinidoPorElUsuario( tcVariableExpresionValorSugerido as String, tcDetalle as String, tcTituloDeEntidad as String, tcEtiquetaDeAtributo as String, tcTipoDeDato as String, tnTabulacion as Integer ) as void
		local lcMensajeAgregarInformacion as String
		
		this.AgregarLinea( "if !isnull( " + tcVariableExpresionValorSugerido + " )", tnTabulacion )
		this.AgregarLinea( [loEx.AgregarInformacion( iif( type( "loError.UserValue.Message" ) == "C", loError.UserValue.Message, loError.Message ) )], tnTabulacion + 1 )
		this.AgregarLinea( [], tnTabulacion + 1 )
		lcMensajeAgregarInformacion = this.ObtenerExcepcionPorValorSugeridoDefinidoPorElUsuario( "lcExpresionValorSugeridoDefinidoPorElUsuario", tcDetalle, tcTituloDeEntidad, tcEtiquetaDeAtributo, tcTipoDeDato )
		this.AgregarLinea( [loEx.AgregarInformacion( ] + lcMensajeAgregarInformacion + [ )], tnTabulacion + 1 )
		this.AgregarLinea( "goServicios.Errores.LevantarExcepcion( loEx )", tnTabulacion + 1 )
		this.AgregarLinea( "endif", tnTabulacion )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarExcepcionPorValorSugeridoDefinidoPorElUsuario( tcVariableExpresionValorSugerido as String, tcDetalle as String, tcTituloDeEntidad as String, tcEtiquetaDeAtributo as String, tcTipoDeDato as String, tnTabulacion as Integer ) as void
		local lcMensaje as String &&, lcEntidadODetalle as String, lcTituloDeEntidadODetalle as String, lcCursor as String, lcDato as String
		lcMensaje = this.ObtenerExcepcionPorValorSugeridoDefinidoPorElUsuario( tcVariableExpresionValorSugerido, tcDetalle, tcTituloDeEntidad, tcEtiquetaDeAtributo, tcTipoDeDato )
		this.AgregarLinea( "goServicios.Errores.LevantarExcepcion( " + lcMensaje + " )", tnTabulacion )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerExcepcionPorValorSugeridoDefinidoPorElUsuario( tcVariableExpresionValorSugerido as String, tcDetalle as String, tcTituloDeEntidad as String, tcEtiquetaDeAtributo as String, tcTipoDeDato as String ) as String
		local lcMensaje as String, lcEntidadODetalle as String, lcTituloDeEntidadODetalle as String, lcCursor as String, lcDato as String
		if empty( tcDetalle )
			lcEntidadODetalle = "la entidad"
			lcTituloDeEntidadODetalle = tcTituloDeEntidad
		else
			lcCursor = sys( 2015 )
			lcTituloDeEntidadODetalle = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", ;
				"Etiqueta", "Entidad,Atributo ", upper( alltrim( this.cTipo ) ) + "," + upper( alltrim( tcDetalle ) ) ) )

			lcEntidadODetalle = "el detalle"
		endif
		lcMensaje = ["Se produjo un error al intentar asignar el valor sugerido " + ] + tcVariableExpresionValorSugerido + [ + " del atributo ] + alltrim( tcEtiquetaDeAtributo ) + [ para ] + lcEntidadODetalle + [ ] + alltrim( lcTituloDeEntidadODetalle ) + [." + chr( 10 ) + "Verifique el valor especificado en la entidad Comportamiento de atributos."]
		do case
			case tcTipoDeDato = "C"
				lcDato = "caracter"
			case tcTipoDeDato = "N"
				lcDato = "numérico"
			case tcTipoDeDato = "L"
				lcDato = "lógico"
			case tcTipoDeDato = "D"
				lcDato = "fecha"
			otherwise				
				lcDato = tcTipoDeDato
		EndCase		
		lcMensaje = lcMensaje + [ + chr( 10 ) + "El tipo de dato del atributo es ] + lcDato + [."]
		
		return lcMensaje
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionCargar() as Void
		***
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombre() as String
		return alltrim( upper( this.cTipo ) ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionDespuesDeAsignar( tcNombreFuncion As String, tcContenido As String )
		local loCustom As Custom
		loCustom = newobject( "Custom" )
		loCustom.AddProperty( "cFuncion", tcNombreFuncion )
		loCustom.AddProperty( "cContenido", tcContenido )
		This.oDespuesDeAssign.Add( loCustom )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionesDespuesDeAssign() as Void
		local loItem As Custom
		for each loItem in This.oDespuesDeAssign
			This.GenerarFuncionDespuesDeAsignar( loItem.cFuncion, loItem.cContenido )
		EndFor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarFuncionDespuesDeAsignar( tcNombreFuncion As String, tcContenido As String )
		local lnCantidad as Integer, lnI as Integer
		local array laFunciones[ 1 ]
		with This
			.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function " + tcNombreFuncion + "() as void", 1 )			
				lnCantidad = alines( laFunciones, tcContenido, "&" ) 
				for lnI = 1 to lnCantidad				
					.AgregarLinea( laFunciones[ lnI], 2 )
				endfor
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		EndWith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarValidacionesDominios() as Void
		local lcCursor as String, lcParametros as String

		with this
			lcCursor = .cCursorAtributos
			select( lcCursor )

			scan for !&lcCursor..Detalle and .ValidarDominio( &lcCursor..dominio ) and !.oColValidacionesDominios.Buscar( &lcCursor..Dominio ) 
				.AgregarLinea( "" )
				.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function ValidarDominio_" + proper( alltrim( &lcCursor..Dominio ) ) + ;
						"( txVal as variant ) as void", 1 )
				.AgregarLinea( "" )

				if this.oColDominiosAValidar( upper( alltrim( &lcCursor..Dominio ) ) ).RecepcionaParametroEntidad
					lcParametros = "( txVal, This )"
				else
					lcParametros = "( txVal )"
				endif

				.AgregarLinea( "if This.oValidacionDominios.ValidarDominio_" + ;
						proper( alltrim( &lcCursor..Dominio ) ) + lcParametros, 2 )
				.AgregarLinea( "else", 2 )				
				.AgregarLinea( "goServicios.Errores.LevantarExcepcion( This.oValidacionDominios.ObtenerInformacion() )" , 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "endfunc", 1 )
				
				.oColValidacionesDominios.Agregar( &lcCursor..Dominio, &lcCursor..Dominio )
			Endscan
			
			.oColValidacionesDominios.destroy()
			.oColValidacionesDominios = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionDominio( tcNombreCursor as string, tnTab as Integer ) as Void
		if This.ValidarDominio( &tcNombreCursor..dominio )
			.AgregarLinea( "this.ValidarDominio_" + proper( alltrim( &tcNombreCursor..Dominio ) ) + ;
					"( lxVal )", tnTab )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionDominiosAValidar() as Void
		Local 	loDominio As dominios Of dominios.prg, ;
				lnCant As Integer, ;
				x As Integer, ;
				lcFuncion As String, ;
				lcTipo As String, ;
				lcFuncionConParametros as String, ;
				loItem as Object

		Local Array laMembers[01]

		loDominio = Newobject( "dominios", "dominios.prg" )
		lnCant = AMembers( laMembers, loDominio, 03)

		For x = 1 To lnCant
			lcFuncion 	= Upper( Alltrim( laMembers[x, 01] ) )
			lcTipo		= Upper( Alltrim( laMembers[x, 02] ) )
			lcFuncionConParametros 	= Upper( Alltrim( laMembers[x, 03] ) )

			If lcTipo == "METHOD" .And. Left( lcFuncion, 15 ) == "VALIDARDOMINIO_"
				loItem = this.ObtenerObjetoItem()
				loItem.NombreDominio = Substr( lcFuncion, 16 )
				loItem.RecepcionaParametroEntidad = this.ExisteParametroEntidadEnFuncion( lcFuncionConParametros )
				This.oColDominiosAValidar.Agregar( loItem, upper( loItem.NombreDominio ) )
			EndIf
		Next x

		loDominio = Null

	EndFunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoItem() as Object
		local loItem as Object
		loItem = Newobject( "custom" )
		loItem.AddProperty( "NombreDominio", "" )
		loItem.AddProperty( "RecepcionaParametroEntidad", .F. )
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteParametroEntidadEnFuncion( tcFuncionConParametros as String ) as Boolean
		return occurs( ',', tcFuncionConParametros ) = 1 and upper( "toEntidad" ) $ upper( substr( tcFuncionConParametros, at( ',', tcFuncionConParametros ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarDominio( tcNombreDominio As String ) as Boolean 

		Return This.oColDominiosAValidar.Buscar( Upper( Alltrim( tcNombreDominio ) ) )

	Endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidarAtributoComponente() as Void
		local lcCursor As String

		with this
			lcCursor = This.cCursorComponentes
			select &lcCursor
			if this.lGeneracionDeItem
				.AgregarLinea( "" )
				.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function ValidarAtributoComponente( txVal as variant, tcAtributo as string ) as boolean", 1 )
					.AgregarLinea( "local llRetorno as Boolean" , 2 )		
					.AgregarLinea( "llRetorno = .T." , 2 )
					.AgregarLinea( "" , 2 )
				if reccount()>0
					scan All
						if alltrim( upper( this.cprefijo ) ) = 'ITEM'
							.AgregarLinea( "If this.oComp" + alltrim( &lcCursor..componente ) + ".ValidarAtributo( txVal, tcAtributo )" , 2 )
							.AgregarLinea( "else" , 2 )
								.AgregarLinea( "llRetorno = .F." , 3 )							
							.AgregarLinea( "endif" , 2 )	
							.AgregarLinea( "" , 2 )
						endif 
						select &lcCursor
					endscan
					.AgregarLinea( "if llRetorno" , 2 )
					.AgregarLinea( "else" , 2 )					
						.AgregarLinea( "goServicios.Errores.LevantarExcepcion( This.ObtenerInformacion() )" , 3 )
					.AgregarLinea( "endif" , 2 )						
				endif
					.AgregarLinea( "" , 2 )
					.AgregarLinea( "Return llRetorno", 2 )
				.AgregarLinea( "endfunc", 1 )
	
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionLimpiarAtributosVirtuales() as Void
		local lcAtributo as String, lcNombreCursor as String, lcAtributoAux as string, lcValorVacio as string, ;
			lnTab as integer
		lnTab = 1
		with this
			lcNombreCursor = .cCursorAtributos
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function LimpiarAtributosVirtuales() as void", lnTab )
			.AgregarLinea( "dodefault()", lnTab + 1 )
			.AgregarLinea( "with this", lnTab + 1 )
				select ( lcNombreCursor )
				scan for empty( Tabla )
					.AgregarBlanqueoAtributo( lcNombreCursor, lnTab - 1)
				endscan
			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab)
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerAtributosCombinacion() as Void
		local lcAtributo as String, lcNombreCursor as String, lcAtributoAux as string, lcValorVacio as string, ;
			lnTab as integer, lcCursor as String
		lnTab = 1
		with this
			lcNombreCursor = .cCursorAtributos
			lcCursor = sys( 2015 )
			.AgregarLinea( "", lnTab )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "function ObtenerAtributosCombinacion() as object", lnTab )
			.AgregarLinea( "local loColRetorno as object", lnTab + 1 )
			.AgregarLinea( "", lnTab + 1 )
			.AgregarLinea( "loColRetorno = _screen.zoo.CrearObjeto( 'zooColeccion' )", lnTab + 1 )

			select atributo, EsEntidad from &lcNombreCursor where "<combinacion" $ lower( tags ) order by ;
				tags into cursor &lcCursor

			scan
				.AgregarLinea( "loColRetorno.add( '" + alltrim( &lcCursor..atributo ) + iif( &lcCursor..EsEntidad, ;
					"_pk'", "'" ) + " )", lnTab + 1 )				
			endscan
			
			use in select( lcCursor )

			.AgregarLinea( "return loColRetorno", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab)
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AccessDescripcionFW() as Void
		select * ;
			from c_entidad ;
			where alltrim( upper( entidad ) ) == alltrim( upper( this.cTipo )) and !empty( FormatoDescripcion ) ;
			into cursor c_TmpFormatoDescripcion
		
		if reccount( "c_TmpFormatoDescripcion" ) > 0
			with this
				.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "function DescripcionFW_Access() as variant", 1 )
					.AgregarLinea( "If This.lDestroy", 2 )
					.AgregarLinea( "Else", 2 )
						.AgregarLinea( "this.DescripcionFW = alltrim( transform( " + alltrim( c_TmpFormatoDescripcion.FormatoDescripcion ) + " ) )", 3 )
					.AgregarLinea( "Endif", 2 )
					.AgregarLinea( "return this.DescripcionFW", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )
			endwith
		endif
				
		use in select( "c_TmpFormatoDescripcion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionEventoSeteandoValorSugerido() as Void
		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function EventoEstaSeteandoValorSugerido( lcAtributo as String ) as Void", 1 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneCantidad( lcCursor as String) as Boolean
		local llRetorno as Boolean, lnRegistro as Number
		llRetorno = .f.
		
		select &lcCursor
		lnRegistro = recno( lcCursor )
		scan
			if alltrim( &lcCursor..Atributo ) = "CANTIDAD"
				llRetorno = .T.
			endif
		endscan
		goto lnRegistro
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsItemDeDetalleConParticipantes( tcEntidad as String, tcDominio as String ) as Void
		local llRetorno as Boolean
		llRetorno = this.DetalleConAtributosCombinacion( tcDominio ) and this.TieneTagConParticipantes( tcEntidad, tcDominio )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TieneTagConParticipantes( tcEntidad as String, tcDominio as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		select c_diccionario
		locate for alltrim( upper( entidad ) ) == alltrim( upper( tcEntidad ) ) and upper( alltrim( dominio ) ) == upper( alltrim( tcDominio ) )
		llRetorno =  "<CONPARTICIPANTES>" $ upper( Tags )			
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DetalleConAtributosCombinacion( tcDominio as String ) as Boolean
		local llRetorno as Boolean, loAtributos as Object, lcCursor as String
		loAtributos = this.ObtenerAtributosCombinacion()
		lcCursor = this.ObtenerCursorAtributos( strtran( upper( tcDominio ) , "DETALLE", "" ) )
		llRetorno = this.TieneAtributosCombinacion( lcCursor )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeValidarKit( tcDominio as String, lcAtributo as String, tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = upper( lcAtributo ) = "ARTICULO" and this.DetalleConAtributosCombinacion( tcDominio ) and ;
			( !this.TieneTagNoValidaKit( tcEntidad , tcDominio ) and !this.TieneTagConParticipantes( tcEntidad , tcDominio ) )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeControlarColorYTalleEnKit( tcDominio as String, lcAtributo as String, tcEntidad as String ) as Void
		local llRetorno as Boolean
		llRetorno = inlist( upper( lcAtributo ), "COLOR", "TALLE" ) and this.DetalleConAtributosCombinacion( tcDominio ) and ;
			( this.TieneTagNoValidaKit( tcEntidad , tcDominio ) or  this.EsItemDeDetalleConParticipantes( tcEntidad , tcDominio ) )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function TieneTagNoValidaKit( tcEntidad as String, tcDominio as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		select c_diccionario
		locate for alltrim( upper( entidad ) ) == alltrim( upper( tcEntidad ) ) and upper( alltrim( dominio ) ) == upper( alltrim( tcDominio ) )
		llRetorno =  "<NOVALIDAKIT>" $ upper( Tags )			
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoPKEnItemConSumarizado( tcAtributo as String ) as Boolean
		return .f.
	endfunc 

enddefine
