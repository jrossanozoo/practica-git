define class generadordinamicokontroler as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as generadordinamicokontroler of generadordinamicokontroler.prg
	#endif

	cPath = "Generados\"
	oDetalles = null
	cAtributos = ''
	coItem = ''
	oColAtributosParaBindeo = ""
	
	lTieneFuncionalidadDesactivable = .f.

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
		dodefault()

		this.lTieneFuncionalidadDesactivable = this.TieneFuncionalidadDesactivable( this.cTipo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		local lcClase as string

		lcClase = this.ObtenerHerencia()

		with this
			.AgregarLinea( "define class Din_Kontroler" + .cTipo + " as " + lcClase + " of " + lcClase + ".prg" )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearNombreArchivo() as void
		this.cArchivo = .cPath + "DIN_Kontroler" + proper( .cTipo ) + ".prg"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributos( tcTipo as String ) as string
		local lcNombreCursor, lcsql as String 

		lcNombreCursor = "c_" + sys(2015)

		lcsql = "select dic.Atributo,"+;
					" iif( !empty(Dic.ClaveForanea) ,Dic.ClaveForanea, dic.Entidad) as cEntidad," + ;
					" iif(empty(Dic.TipoDato), dom.TipoDato, Dic.TipoDato) as tipoDato," + ;
					" Dic.ClaveForanea," + ;
					" dic.alta, " + ;
					" dom.detalle, " + ;
					" dic.tabla, " + ;
					" dic.campo, " + ;
					" dic.dominio, " + ;
					" dic.sumarizar, " + ;
					" dic.entidad, " + ;
					" iif( dic2.claveprimaria, dic2.Atributo, space( 255 ) ) as AtributoCP, " +;
					" iif( dic3.muestrarelacion, dic3.Atributo, space( 255 ) )as AtributoMR, " +;
					" iif( dic3.muestrarelacion, dic3.TipoDato, space( 1 ) ) as TipoDatoMR, " +;
					" dic.genHabilitar, " + ;
					" ( dic2.EsGuid and alltrim( upper( dic.dominio )) = 'CODIGO' and dic.alta and !empty( Dic.ClaveForanea ) ) as EsClaveCandidata, " + ;
					" iif( !isnull(dic4.Atributo), .t., .f. ) as EsClaveDeBusqueda, " + ;
					" dic.Tags " + ;
				" from c_dominio dom, c_entidad ent," + ;
					" c_Diccionario Dic left join c_Diccionario dic2 on alltrim( upper( dic.ClaveForanea ) ) == alltrim( upper( dic2.Entidad ) ) and dic2.claveprimaria " + ;
					" left join c_Diccionario dic3 on alltrim( upper( dic.ClaveForanea ) ) == alltrim( upper( dic3.Entidad ) ) and dic3.muestrarelacion" + ;
					" left join c_Diccionario dic4 on alltrim( upper( dic.ClaveForanea ) ) == alltrim( upper( dic4.Entidad ) ) and alltrim( upper( dic4.dominio ) ) == 'CLAVEDEBUSQUEDA'" + ;
				" where rtrim(upper(Dic.Entidad)) == '" + tcTipo + "'" +;
					" and rtrim(upper(Dic.Entidad)) == rtrim(upper(ent.Entidad)) " +;
					" and !empty(dic.atributo) " +;
					" and !empty(dic.Entidad)" +;
					" and rtrim(upper(dic.dominio)) == rtrim(upper(dom.dominio)) " +;
					" and !( dom.detalle and !dic.alta ) " +;
				" order by Dic.Orden " +;
				" into cursor " + lcNombreCursor

		&lcsql 
		return lcNombreCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		local lcCursor as string

		this.oColAtributosParaBindeo = ""

		with this
			lcCursor = .ObtenerCursorAtributos( .cTipo )
			.ArmarColeccionDeDetalles( lcCursor )
			.AgregarLinea( "" )
			.AgregarLinea( "cAtributoAsignando = ''", 1 )
			.AgregarLinea( "cAtributoObteniendo = ''", 1 )
			.AgregarLinea( "oColControlesVisuales = Null", 1 )
			.AgregarAtributoHabilitaInsertarDetalle( lcCursor )
			.AgregarAtributosSumarizables( lcCursor )
			.AgregarDefinicionAtributos( lcCursor )
			.AgregarLinea( "" )
			.AgregarAssign( lcCursor )
			.AgregarAccess( lcCursor )
			.AgregarLinea( "" )
			.AgregarInicializar( lcCursor )
			.AgregarLinea( "" )
			.AgregarSeters( lcCursor )
			.AgregarLinea( "" )
			.AgregarValidacionesAntesDeSetear( lcCursor )
			.AgregarResolverHabilitacion( lcCursor )
			.AgregarFuncionBindeosMuestraRelacion()
			.AgregarLostFocusDetalles( lcCursor )
			.AgregarFuncionCrearColeccionAtributosVisuales()
			.AgregarFuncionCrearColeccionDeControlesVisuales()
			.AgregarFuncionesMiPyME()
			.AgregarRefrescarComboToolbar()	
			.AgregarFuncionHabilitarComboToolbar()
			.AgregarFuncionSeteoValorComboToolbarPorDefecto()
			.AgregarFuncionObtenerDetalleParaIngresoLecturaTxt()
			.AgregarFuncionesCondicionFocoKitYParticipantes()
			.AgregarFuncionesFormateoFilasKitYParticipantes()
			.AgregarFuncionalidadPersonalizacionDeComprotante()
			if this.VerificarFuncionalidad( this.cTipo, "AGRUPACOMPROBANTES" )
				.AgregarFuncionesComprobantesAgrupados()
			endif
			use in select( lcCursor )
			
			.EliminarColeccionDeDetalles()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCrearColeccionAtributosVisuales() as Void
		with this
			.AgregarLinea( replicate( "*", 100 ), 1 )
			.AgregarLinea( "Function CrearColeccionAtributosVisuales() as ZooColeccion of ZooColeccion.prg", 1 )
				.AgregarLinea( "local loColeccion as ZooColeccion of ZooColeccion.prg", 2 )
				.AgregarLinea( "loColeccion = _Screen.zoo.CrearObjeto( 'ZooColeccion' )", 2 )
				select Atributo from c_diccionario ;
					where alltrim( upper( entidad ) ) == alltrim( upper( This.cTipo ) ) and alta and !Saltocampo and !( Grupo = 0 and TipoSubgrupo = 3 ) ;
					order by CampoInicial desc,Grupo,Subgrupo,Orden ;
					into cursor c_ver
				scan All
					.AgregarLinea( "loColeccion.Add( '" + alltrim( upper( c_Ver.Atributo ) ) + "' )", 2 )
					select c_Ver
				endscan
				select Atributo from c_diccionario ;
					where alltrim( upper( entidad ) ) == alltrim( upper( This.cTipo ) ) and alta and !Saltocampo and Grupo = 0 and TipoSubgrupo = 3 ;
					order by CampoInicial desc,Grupo,Subgrupo,Orden ;
					into cursor c_ver
				scan All
					.AgregarLinea( "loColeccion.Add( '" + alltrim( upper( c_Ver.Atributo ) ) + "' )", 2 )
					select c_Ver
				endscan
				use in select( "c_Ver" )
				.AgregarLinea( "Return loColeccion", 2 )
			.AgregarLinea( "EndFunc", 1 )
		EndWith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosSumarizables( tcCursor as String ) as boolean
		local llRetorno as boolean

		select atributo, sumarizar ;
				from ( tcCursor ) ;
				where detalle ;
			into cursor c_sumarizan
				
		llRetorno = reccount( "c_sumarizan" ) > 0
		if llRetorno
			scan
				.AgregarLinea( "l" + alltrim( proper( Atributo ) ) + "TieneSumarizables = " + transform( !empty( Sumarizar ) ), 1 )
			endscan
		endif
		
		use in select( "c_sumarizan" )
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarColeccionDeDetalles( tcCursor as String ) as Void
		local lcCursor as string
		with this
			.oDetalles = _Screen.zoo.crearobjeto( "ZooColeccion" )
			
			select ( tcCursor )
			
			scan for detalle
				lcCursor = .ObtenerCursorAtributos( strtran( Dominio, "DETALLE", "" ) )
				
				select ( tcCursor )
				.oDetalles.Add( lcCursor, alltrim( &tcCursor..Atributo ) )
			endscan
		endwith
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarColeccionDeDetalles() as Void
		local lcCursor as string
		with this
			for each lcCursor in .oDetalles
				use in select( lcCursor )
			endfor
			
			.oDetalles.remove( -1 )
		endwith
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarDefinicionAtributos( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan
				if Detalle
					lcCursor = .oDetalles( alltrim( Atributo ) )
					select ( lcCursor )

					scan
						.AgregarDefinicionAtributosEspecificos( lcCursor, alltrim( &tcCursor..Atributo ) )
					endscan
					select ( tcCursor )
				else
					.AgregarDefinicionAtributosEspecificos( tcCursor, tcPrefijo  )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDefinicionAtributosEspecificos( tcCursor as String, tcPrefijo as string ) as Void
		local lcValorMR as string, lcCursor as string, lcValorCP as string

		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif
		
		with this
			lcValorCP = goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( TipoDato ) )

			if empty( ClaveForanea )
				.AgregarLinea( iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + alltrim( Atributo ) + ' = ' + lcValorCP, 1 )
			else
				.AgregarLinea( iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
						alltrim( Atributo )+ "_PK" + ' = ' + lcValorCP, 1 )

				if empty( tcPrefijo ) and this.EsDominioCodigo( Dominio )
					lcValorMR = goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( TipoDatoMR ) )
					.AgregarLinea( alltrim( Atributo )+ "_" + alltrim( AtributoMR ) + ' = ' + lcValorMR , 1 )
				endif
			endif

			if empty( tcPrefijo ) or empty( Sumarizar )
			else
				.AgregarLinea( tcPRefijo + "_Sum_" + alltrim( Sumarizar ) + ' = ' + lcValorCP, 1 )
			endif

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAssign( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String, llDetalleConSoporteDePrepantalla as Boolean, llAtributoConSoporteDePrePantalla as Boolean
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan
				if Detalle
					llDetalleConSoporteDePrepantalla = this.oFunc.TieneFuncionalidad( "SOPORTAPREPANTALLA", &tcCursor..Tags )
					lcCursor = .oDetalles( alltrim( Atributo ) )
					select ( lcCursor )
					scan
						if llDetalleConSoporteDePrepantalla
							llAtributoConSoporteDePrePantalla = this.oFunc.TieneFuncionalidad( "SOPORTAPREPANTALLA", &lcCursor..Tags )
						else
							llAtributoConSoporteDePrePantalla = .f.
						endif
						.AgregarAssignEspecificos( lcCursor, alltrim( &tcCursor..Atributo ), llAtributoConSoporteDePrePantalla )
					endscan
					select ( tcCursor )
				else
					.AgregarAssignEspecificos( tcCursor, tcPrefijo, .f. )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAssignEspecificos( tcCursor as String, tcPrefijo as string, tlAtributoConSoporteDePrePantalla as Boolean ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_PK" ) 

			lcAtributo = "thisform.oEntidad" + .cAtributos + "."
			if empty( tcPrefijo )
				lcAtributo = lcAtributo + alltrim( Atributo )
			else
				lcAtributo = lcAtributo + tcPrefijo + .coItem + "." + alltrim( Atributo )
			endif

			lcAtributo = lcAtributo + iif( empty( ClaveForanea ), "", "_PK" )
			
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )			
			.AgregarLinea( "function " + lcAtributoKontroler + '_assign( txValor as variant ) as void', 1 )
			.AgregarLinea( "local loError as Exception, loEx as Exception", 2 )

			if tlAtributoConSoporteDePrePantalla
				.AgregarLinea( 'local llProcesarPrePantalla as Boolean', 2 )
				.AgregarLinea( 'llProcesarPrePantalla = this.lProcesarPrePantalla', 2 )
				.AgregarLinea( 'this.lProcesarPrePantalla = .f.', 2 )
			endif

			.AgregarLinea( "if this.cAtributoObteniendo == '" + lcAtributoKontroler + "'", 2 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "this.cAtributoAsignando = '" + lcAtributoKontroler + "'", 3 )
			.AgregarLinea( "" )
			.AgregarLinea( "try", 3 )
			.AgregarLinea( lcAtributo + ' = txValor', 4 )
			.AgregarLinea( "Catch To loError", 3 )
			.AgregarLinea( 'loEx = Newobject( "ZooException", "ZooException.prg" )' , 4 )
			.AgregarLinea( 'With loEx' , 4 )
			.AgregarLinea( '.Grabar( loError )' , 5 )
			.AgregarLinea( '.Throw()', 5 )
			.AgregarLinea( 'EndWith' , 4 )
			.AgregarLinea( 'Finally', 3 )
			.AgregarLinea( "this.cAtributoAsignando = ''", 4 )
			.AgregarLinea( 'endtry', 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "this." + lcAtributoKontroler + " = " + lcAtributo, 2 )
			if !empty( &tcCursor..ClaveForanea )
				.AgregarLinea( "this.DesactivarAdvertenciaEnControlAsociado( '" + alltrim( &tcCursor..Atributo ) + "' )", 2 )
			endif

			if tlAtributoConSoporteDePrePantalla
				.AgregarLinea( 'if ( llProcesarPrePantalla ) and !empty( this.' + lcAtributoKontroler + ' )' , 2 )
				.AgregarLinea( 'if this.ProcesarPrePantalla( "' + tcPrefijo + '", this.' + lcAtributoKontroler + ' )', 3 )
				.AgregarLinea( 'local loControl as Object', 4 )
				.AgregarLinea( 'loControl = this.ObtenerControl( "' + tcPrefijo + '" )', 4 )
				.AgregarLinea( 'loControl.RefrescarGrilla()', 4 )
				.AgregarLinea( 'endif', 3 )
				.AgregarLinea( 'endif', 2 )
			endif

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarAccess( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan for !Detalle and !empty( AtributoMR )
				.AgregarAccessEspecificos( tcCursor, tcPrefijo  )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAccessEspecificos( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = alltrim( Atributo ) + "_" + alltrim( AtributoMR )

			lcAtributo = "thisform.oentidad." +  alltrim( Atributo ) + "." + alltrim( AtributoMR )

			.AgregarLinea( "function " + lcAtributoKontroler + '_Access() as void', 1 )
			.AgregarLinea( "local lxVal as variant", 2 )
			.AgregarLinea( "if this.lDestroy", 2 )
			.AgregarLinea( "else", 2 )			
				.AgregarLinea( "if this.oEntidad.lInstanciarSubEntidadaDemanda" , 3 )
					.AgregarLinea( "lxVal = " + lcAtributo, 4 )
					.AgregarLinea( "if this." + lcAtributoKontroler + " # lxVal", 4 )
						.AgregarLinea( "this." + lcAtributoKontroler + " = lxVal", 5 )
					.AgregarLinea( "endif", 4 )
				.AgregarLinea( "endif", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "return this." + lcAtributoKontroler, 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInicializar( tcCursor as String, tcPrefijo as string  ) as Void
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif
		
		with this
			.AgregarLinea( "function Inicializar() as void", 1 )
			.AgregarLinea( "local loControl as object, loAtributo as object", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "dodefault()", 2 )
			.AgregarLinea( "" )
			.AgregarBindeos( tcCursor , tcPrefijo )
			.AgregarBindeosHabilitar( tcCursor , tcPrefijo )
			.AgregarBindeosDeFuncionalidadDesactivable()
			.AgregarBindeoFuncionalidadAgrupamientoPublicaciones()
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarBindeos( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String, lcAtrKont as string, lcAtributo as String, lcAtributoCP as string, ;
			lcAtrEnt as string

		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			.AgregarLinea( "bindevent( thisform.oEntidad.oMensaje, 'EventoMensaje', this, 'EventoMensaje' )", 2 )
			
			select ( tcCursor )
			scan
				lcAtributo = alltrim( &tcCursor..Atributo )
				lcAtributoCP = alltrim( &tcCursor..AtributoCP )

				if Detalle
					.AgregarLinea( "bindevent( thisform.oEntidad." + alltrim( lcAtributo ) + ".oMensaje, 'EventoMensaje', this, 'EventoMensaje' )", 2 )
					.AgregarLinea( "bindevent( thisform.oEntidad." + alltrim( lcAtributo ) + alltrim( .coItem ) + ".oMensaje, 'EventoMensaje', this, 'EventoMensaje' )", 2 )						
						
					lcCursor = .oDetalles[ lcAtributo ]
					select ( lcCursor )
					scan
						.AgregarBindeosEspecificos( lcCursor, lcAtributo )
					endscan

					select ( tcCursor )
				else
					.AgregarBindeosEspecificos( tcCursor, tcPrefijo  )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------------
	protected function AgregarBindeosEspecificos( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String, lcentidad as string, lcAtributo as string, lcAtributoCP  as string, ;
			lcAtributoMR  as string, lcAtributoKontroler as String

		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			lcAtributo = alltrim( Atributo )
			lcAtributoCP =  alltrim( AtributoCP )

			lcEntidad = .ObtenerRutaEntidad( tcPrefijo, lcAtributo, &tcCursor..ClaveForanea )
			lcAtributoEntidad = .ObtenerAtributoEntidad( lcAtributoCP, lcAtributo, &tcCursor..ClaveForanea )
			lcAtributoKontroler = .ObtenerAtributoKontroler( tcPrefijo, lcAtributoCP, lcAtributo, &tcCursor..ClaveForanea )

			if empty( tcPrefijo ) and alta
				.AgregarLinea( "loControl = this.ObtenerControl( '" + lcAtributo + "' )", 2 )
				.AgregarLinea( "bindevent( this, '" + lcAtributoKontroler + "', loControl, 'Actualizar', 1 )", 2 )
			endif

			.AgregarLinea( "loAtributo = " + lcEntidad, 2 )
			.AgregarLinea( "bindevent( loAtributo, '" + lcAtributoEntidad + "', this, 'set_" + lcAtributoKontroler + "', 1 )", 2 )
			
			**** Descripcion

			if !empty( ClaveForanea ) and empty( tcPrefijo ) and this.EsDominioCodigo( Dominio ) and alta and !EsClaveCandidata ; 
				and !( upper( alltrim( AtributoMR ) ) = upper( alltrim( AtributoCP ) ) ) and !EsClaveDeBusqueda

				lcAtributoMR =  alltrim( &tcCursor..AtributoMR )
				lcAtributoKontrolerMR = lcAtributo + "_" + lcAtributoMR
				.AgregarLinea( "if this.oEntidad.lInstanciarSubEntidadaDemanda", 2 )
				.AgregarLinea( "This.BindeoMuestraRelacion_" + alltrim( lcAtributo ) + "()", 3 )
				.AgregarLinea( "Endif", 2 )				
				.AgregarBindeoParaGenerar( lcAtributo, lcAtributoMR , lcAtributoKontrolerMR, lcEntidad )
			endif

			if empty( tcPrefijo ) or empty( Sumarizar )
			else
				lcAtributo = alltrim( Atributo ) + "Sum_" + alltrim( Sumarizar ) + alltrim( Entidad )
				lcAtributoEntidad = "Sum_" + alltrim( Sumarizar )
				lcAtributoKontroler = tcPRefijo + "_Sum_" + alltrim( Sumarizar )
				
				if alta
					.AgregarLinea( "loControl = this.ObtenerControl( '" + lcAtributo +"' )", 2 )
					.AgregarLinea( "bindevent( this, '" + lcAtributoKontroler + "', loControl, 'Actualizar', 1 )", 2 )
				endif
				
				.AgregarLinea( "loAtributo = thisform.oEntidad" + .cAtributos + "." + tcPrefijo, 2 )
				.AgregarLinea( "bindevent( loAtributo, '" + lcAtributoEntidad + "', this, 'set_" + lcAtributoKontroler + "', 1 )", 2 )
			endif
			
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarBindeosHabilitar( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String, lcAtrKont as string, lcAtributo as String, lcAtributoCP as string, ;
			lcAtrEnt as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan for &tcCursor..genHabilitar and &tcCursor..Alta
				lcAtributo = alltrim( &tcCursor..Atributo )
				
				.AgregarLinea( 'this.enlazar( "oentidad.lHabilitar' + lcAtributo + iif( !empty( &tcCursor..claveforanea ), '_PK', '' ) + '", "resolverHabilitacion' + lcAtributo ;
					+ iif( !empty( &tcCursor..claveforanea ), '_PK', '' ) + '" )', 2 )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRutaEntidad( tcPrefijo as String, tcAtributo as String, tcClaveForanea as String ) as String
		local lcRetorno as String
		
		with this
			lcRetorno = "thisform.oEntidad" + .cAtributos
			if empty( tcPrefijo )
			else
				lcRetorno = lcRetorno + "." + tcPrefijo + .coItem
			endif
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoEntidad( tcAtributoCP as String , tcAtributo as String, tcClaveForanea as String ) as String
		local lcRetorno as string

		with this
			lcRetorno = tcAtributo

			if empty( tcClaveForanea )
			else
				lcRetorno = lcRetorno + "_PK"
			endif
		endwith
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoKontroler( tcPrefijo as String , tcAtributoCP as String , tcAtributo as String , ;
					tcClaveForanea as String ) as String
		local lcRetorno as string

		with this
		
			lcRetorno = tcAtributo

			if empty( tcPrefijo )
			else
				lcRetorno =  tcPrefijo + "_" + lcRetorno
			endif
			
			if empty( tcClaveForanea )
			else
				lcRetorno =  lcRetorno + "_PK"
			endif
		
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------------
	protected function ObtenerHerencia() as string
		local lcRetorno as String, lcAux as string

		lcAux = alltrim( this.oAdnAD.ObtenerValorCampo( "Entidad", "Kontroler", "Entidad", upper( alltrim( this.cTipo ) ) ) )
			
		if empty( lcAux )
			lcRetorno = this.ObtenerHerenciaBase()
		else
			lcRetorno = "Kontroler" + proper( alltrim( _screen.zoo.app.cProyecto ) ) + "_" + lcAux
			if !file( lcRetorno + ".prg" )
				lcRetorno = "Kontroler" + lcAux
			endif
		endif
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------------
	protected function ObtenerHerenciaBase() as string
		local lcKontroler as string

		select dom.detalle from c_Diccionario Dic, c_dominio dom ;
			 where rtrim( upper( Dic.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				 and rtrim(upper(dic.dominio)) == rtrim( upper( dom.dominio ) ) ;
				 and dom.detalle ;
			into cursor cVer

		if _tally  > 0
			lcKontroler = "KontrolerConDetalle"
		else			 
			lcKontroler = "KontrolerAltas"
		endif
		use in select( "cVer" )
	
		return lcKontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSeters( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan
				if Detalle
					lcCursor = .oDetalles( alltrim( Atributo ) )
					select ( lcCursor )
					scan
						.AgregarSetersEspecificos( lcCursor, alltrim( &tcCursor..Atributo ) )
					endscan
					select ( tcCursor )
				else
					.AgregarSetersEspecificos( tcCursor, tcPrefijo  )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarSetersEspecificos( tcCursor as String, tcPrefijo as string ) as Void
		local lcatributoKontrolerAux as String, lcAtributoKontroler  as string, lcAtributo  as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_PK" )
								
			lcAtributo = "thisform.oentidad" + .cAtributos + "."
			if empty( tcPrefijo )
				lcAtributo = lcAtributo + alltrim( Atributo )
			else
				lcAtributo = lcAtributo + tcPrefijo + .coItem + "." + alltrim( Atributo )
			endif

			lcAtributo = lcAtributo + iif( empty( ClaveForanea ), "", "_PK" )

			.AgregarLinea( "function set_" + lcAtributoKontroler + '() as void', 1 )
			.AgregarLinea( "if this.cAtributoAsignando == '" + lcAtributoKontroler + "' or vartype( thisform.oentidad ) # 'O'", 2 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "this.cAtributoObteniendo = '" + lcAtributoKontroler + "'", 3 )
			.AgregarLinea( "this." + lcAtributoKontroler + " = " + lcAtributo , 3 )
			.AgregarLinea( "this.cAtributoObteniendo = ''", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )


			if empty( ClaveForanea )
			else
				.AgregarLinea( "" )
				if empty( tcPrefijo ) and this.EsDominioCodigo( Dominio )
					lcatributoKontrolerAux = alltrim( Atributo ) + '_' + alltrim( AtributoMR )
				**** Descripcion
					.AgregarLinea( "function set_" + lcatributoKontrolerAux + '() as void', 1 )
					.AgregarLinea( "if this.cAtributoAsignando == '" + lcatributoKontrolerAux + "' or vartype( thisform.oentidad ) # 'O'", 2 )
					.AgregarLinea( "else", 2 )
					.AgregarLinea( "this.cAtributoObteniendo = '" + lcatributoKontrolerAux + "'", 3 )
					.AgregarLinea( "this." + lcatributoKontrolerAux + " = thisform.oentidad" + .cAtributos + "." + alltrim( Atributo ) + .cAtributos + '.' + alltrim( AtributoMR ), 3 )
					.AgregarLinea( "this.cAtributoObteniendo = ''", 3 )
					.AgregarLinea( "endif", 2 )
					.AgregarLinea( "endfunc", 1 )
					.AgregarLinea( "" )
				endif
			endif

			if empty( tcPrefijo ) or empty( Sumarizar )
			else
				lcatributoKontrolerAux = tcPrefijo + '_Sum_' + alltrim( Sumarizar )
				.AgregarLinea( "function set_" + lcatributoKontrolerAux + '() as void', 1 )
				.AgregarLinea( "if this.cAtributoAsignando == '" + lcatributoKontrolerAux + "' or vartype( thisform.oentidad ) # 'O'", 2 )
				.AgregarLinea( "else", 2 )
				.AgregarLinea( "this.cAtributoObteniendo = '" + lcatributoKontrolerAux + "'", 3 )
				.AgregarLinea( "this." + lcatributoKontrolerAux + " = thisform.oentidad" + .cAtributos + "." + tcPrefijo + ".Sum_" + alltrim( Sumarizar ), 3 )
				.AgregarLinea( "this.cAtributoObteniendo = ''", 3 )
				.AgregarLinea( "endif", 2 )
				.AgregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )
			endif

		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsDominioCodigo( tcDominio as String ) as boolean
		return inlist( upper( alltrim( tcDominio ) ), "CODIGO","CODIGOVENDEDOR" ,"CODIGONUMERICO", "CODIGOSOLONUMEROS", "CLAVECONCUALQUIERCARACTER", "CODIGOSINALTA", "CODIGOUSUARIOZL", "CODIGOCLIENTEPRESUP" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionesAntesDeSetear( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan
				if Detalle
					lcCursor = .oDetalles( alltrim( Atributo ) )
					select ( lcCursor )
					scan
						.AgregarValidacionesAntesDeSetearEspecificas( lcCursor, alltrim( &tcCursor..Atributo ) )
						.AgregarValidarDespuesDeSetearEspecificas( lcCursor, alltrim( &tcCursor..Atributo ) )
						.AgregarProcesarDespuesDeValidarEspecificas( lcCursor, alltrim( &tcCursor..Atributo ) )
						.AgregarDespuesDelValidEspecificas( lcCursor, alltrim( &tcCursor..Atributo ) )
					endscan
					select ( tcCursor )
				else
					.AgregarValidacionesAntesDeSetearEspecificas( tcCursor, tcPrefijo  )
					.AgregarValidarDespuesDeSetearEspecificas( tcCursor, tcPrefijo )
					.AgregarProcesarDespuesDeValidarEspecificas( tcCursor, tcPrefijo )
					.AgregarDespuesDelValidEspecificas( tcCursor, tcPrefijo )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarResolverHabilitacion( tcCursor as String, tcPrefijo as string ) as Void
		local lcCursor as String
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			scan for &tcCursor..genHabilitar and &tcCursor..Alta
				if Detalle
					.AgregarResolverHabilitacionEspecificas( tcCursor, tcPrefijo  )

					lcCursor = .oDetalles( alltrim( Atributo ) )
					select ( lcCursor )
					scan for &lcCursor..genHabilitar and &lcCursor..Alta
						.AgregarResolverHabilitacionEspecificas( lcCursor, alltrim( &tcCursor..Atributo ) )
					endscan
					select ( tcCursor )
				else
					.AgregarResolverHabilitacionEspecificas( tcCursor, tcPrefijo  )
				endif
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarResolverHabilitacionEspecificas( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcComando as string, lcControl as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( &tcCursor..Atributo ) + iif( empty( &tcCursor..ClaveForanea ), "", "_PK" )

			lcComando = "this.oEntidad." + iif( empty( tcPrefijo ), "", tcPrefijo + "." ) + ;
					"lHabilitar" + alltrim( &tcCursor..Atributo ) + iif( empty( &tcCursor..ClaveForanea ), "", "_PK" )
			
			lcControl = upper( alltrim( &tcCursor..Atributo ) )
			
			if &tcCursor..Detalle or This.EsBloque( &tcCursor..Dominio ) or upper( alltrim( &tcCursor..Dominio ) ) == "OBSERVACION" or this.EsControlNet(&tcCursor..Dominio)
			else
				lcControl = lcControl + "_" + upper( .cTipo ) + lcControl
			endif
			
			.AgregarLinea( "function ResolverHabilitacion" + lcAtributoKontroler + '() as boolean', 1 )
			.AgregarLinea( "local llRetorno as boolean", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "if " + lcComando, 2 )
			.AgregarLinea( "this.HabilitarControl( this.ObtenerControl( '" + lcControl + "' ) )", 3 )
			.AgregarLinea( "else", 2 )
			.AgregarLinea( "this.DeshabilitarControl( this.ObtenerControl( '" + lcControl + "' ) )", 3 )
			.AgregarLinea( "endif", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return llRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsControlNet( tcDominio as String ) as Boolean 
		select c_Dominio
		locate for upper( alltrim( Dominio ) ) == upper( alltrim( tcDominio ) )
		return c_Dominio.EsControlNet
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsBloque( tcDominio As String ) as Boolean

		select c_Dominio
		locate for upper( alltrim( Dominio ) ) == upper( alltrim( tcDominio ) )
		return c_Dominio.EsBloque
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function AgregarValidacionesAntesDeSetearEspecificas( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_" + alltrim( AtributoCP ) )

			.AgregarLinea( "function ValidarAntesDeSetear_" + lcAtributoKontroler + '( toControl as Object ) as boolean', 1 )
			.AgregarLinea( "local llRetorno as boolean", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault( toControl )", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return llRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarValidarDespuesDeSetearEspecificas( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_" + alltrim( AtributoCP ) )

			.AgregarLinea( "function ValidarDespuesDeSetear_" + lcAtributoKontroler + '() as boolean', 1 )
			.AgregarLinea( "local llRetorno as boolean", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault()", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return llRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarProcesarDespuesDeValidarEspecificas( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_" + alltrim( AtributoCP ) )

			.AgregarLinea( "function ProcesarDespuesDeValidar_" + lcAtributoKontroler + '( tlValido as boolean ) as boolean', 1 )
			.AgregarLinea( "local llRetorno as boolean", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault( tlValido )", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return llRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc


	*-----------------------------------------------------------------------------------------
	protected function AgregarDespuesDelValidEspecificas( tcCursor as String, tcPrefijo as string ) as Void
		local lcAtributoKontroler as string, lcAtributos as string
		
		if vartype( tcPrefijo ) = "L"
			tcPrefijo = ""
		endif

		with this
			select ( tcCursor )
			
			lcAtributoKontroler = iif( empty( tcPrefijo ), "", tcPrefijo + "_" ) + ;
					alltrim( Atributo ) + iif( empty( ClaveForanea ), "", "_" + alltrim( AtributoCP ) )

			.AgregarLinea( "function DespuesDelValid_" + lcAtributoKontroler + '() as boolean', 1 )
			.AgregarLinea( "local llRetorno as boolean", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault()", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return llRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeGenerarCodigo() as Void
		dodefault()
		with this 
			.cAtributos = ''
			.coItem = '.oItem'
		endwith 
	endfunc 


	*-----------------------------------------------------------------------------------------
	Function AgregarLostFocusDetalles( tcCursor as String ) as Void
		
		.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )		
		.AgregarLinea( 'function HacerLostFocusDeGrillas() as void', 1 )
		.AgregarLinea( 'local loControl as object', 2 )
			select ( tcCursor )
			scan for detalle and Alta
				.AgregarLinea( "loControl = This.ObtenerControl( '" + alltrim( &tcCursor..Atributo ) + "' )", 2 )
				.AgregarLinea( "loControl.lostfocus()", 2 )
			endscan

		.AgregarLinea( 'endfunc', 1 )

	Endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarBindeosDeFuncionalidadDesactivable() as Void
		.AgregarLinea( "this.lEntidadConRegistrosDesactivables = " + transform( this.lTieneFuncionalidadDesactivable ), 2 )
		if this.lTieneFuncionalidadDesactivable
			.AgregarLinea( [this.enlazar( "oEntidad.InactivoFW", "SetearEtiquetaAlPie" )], 2 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributoHabilitaInsertarDetalle( tcCursor as String )	as Void
		local llRetorno as Boolean
		
		select atributo ;
				from ( tcCursor ) ;
				where detalle and "<COPIADETALLE>" $ TAGS;
			into cursor c_DetalleConTags
				
		llRetorno = reccount( "c_DetalleConTags" ) > 0
		if llRetorno
			.AgregarLinea( "HabilitarInsertarDetalle = .t.", 1 )
		endif
		
		use in select( "c_DetalleConTags" )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionBindeosMuestraRelacion() as Void
		local lcCursor as String, lcAtrKont as string, lcAtributo as String, lcAtributoCP as string, ;
			lcAtrEnt as string

		with this
			for each loObjetoBindeo in this.oColAtributosParaBindeo
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )		
				.AgregarLinea( "Function BindeoMuestraRelacion_" + alltrim( loObjetoBindeo.Atributo ) + "() as void", 1 )
				.AgregarLinea( "local loControl as object, loAtributo as object", 1 )
				.AgregarLinea( "loAtributo = " + loObjetoBindeo.Entidad , 2 )
				.AgregarLinea( "loControl = this.ObtenerControl( '" + loObjetoBindeo.AtributoKontrolerMR +"' )", 2 )
				.AgregarLinea( "bindevent( loAtributo." + loObjetoBindeo.Atributo + ", '" + loObjetoBindeo.AtributoMR + "', this, 'set_" + loObjetoBindeo.AtributoKontrolerMR + "', 1 )", 2 )
				.AgregarLinea( "bindevent( this, '" + loObjetoBindeo.AtributoKontrolerMR + "', loControl, 'Actualizar', 1 )", 2 )
				.AgregarLinea( "endfunc", 1 )			
			endfor
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarBindeoParaGenerar( tcAtributo as String, tcAtributoMR as String , tcAtributoKontrolerMR as String, tcEntidad as String ) as Void
		local loItemAtributoaBindear as Object

		loItemAtributoaBindear = newobject( "ItemAtributoBindeo" )
		loItemAtributoaBindear.Atributo = tcAtributo
		loItemAtributoaBindear.AtributoMR = tcAtributoMR
		loItemAtributoaBindear.AtributoKontrolerMR = tcAtributoKontrolerMR
		loItemAtributoaBindear.Entidad = tcEntidad
		This.oColAtributosParaBindeo.add( loItemAtributoaBindear )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColAtributosParaBindeo_access() as Void

		if !vartype( this.oColAtributosParaBindeo ) = 'O'
			this.oColAtributosParaBindeo = newobject( "collection" )
		endif

		return this.oColAtributosParaBindeo

	endfunc 

	*Funciones para la implementacion de funcionalidad <PUBLICA>. Funcionalidad 3193
	*-----------------------------------------------------------------------------------------
	protected function AgregarRefrescarComboToolbar() as Void
		local lcFuncionalidadPublica as String, lcFunPublica as String
		lcFunPublica = sys( 2015 )
		
		select c_Ent.funcionalidades from c_entidad c_Ent ;
				where rtrim( upper( c_Ent.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				into cursor &lcFunPublica
		lcFuncionalidadPublica = &lcFunPublica..Funcionalidades
		use in select( "lcFunPublica" )
		
		if This.oFunc.TieneFuncionalidad( "PUBLICA", lcFuncionalidadPublica )
			This.AgregarLinea( "", 1 )
			This.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			This.AgregarLinea( "protected function RefrescarComboToolbar() as void", 1 )
		
			This.AgregarLinea( "do case", 2 )
			
			This.AgregarLinea( "case This.oEntidad.TipoAgrupamientoPublicaciones = 1 or This.oEntidad.TipoAgrupamientoPublicaciones = 0", 3 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.RowSource = 'Publicación: Todas,Publicación: Ninguna,Personalizado'", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ReQuery()", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 2", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 1", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ToolTipText = 'Destino para publicaciones: Todas'", 4 )
			
			This.AgregarLinea( "case This.oEntidad.TipoAgrupamientoPublicaciones = 2", 3 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.RowSource = 'Publicación: Todas,Publicación: Ninguna,Personalizado'", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ReQuery()", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 1", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 2", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ToolTipText = 'Destino para publicaciones: Ninguna'", 4 )
			
			This.AgregarLinea( "case This.oEntidad.TipoAgrupamientoPublicaciones = 3", 3 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.RowSource = 'Publicación: Todas,Publicación: Ninguna,Personalizado,' + alltrim( This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 1 ) )", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ReQuery()", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 2", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 4", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ToolTipText = 'Destino para publicaciones: '+ alltrim( This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 2 ) )", 4 )
			This.AgregarLinea( "This.oEntidad.cValorComboToolbar = alltrim( This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 1 ) )", 4 )
			
			This.AgregarLinea( "otherwise", 3 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.RowSource = 'Publicación: Todas,Publicación: Ninguna,Personalizado'", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ReQuery()", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 2", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ListIndex = 1", 4 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.ToolTipText = 'Destino para publicaciones: Todas'", 4 )
			
			This.AgregarLinea( "endcase", 2 )
			This.AgregarLinea( "endfunc", 1 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarBindeoFuncionalidadAgrupamientoPublicaciones() as Void
		local lcFuncionalidadPublica as String, lcFunPublica as String
		lcFunPublica = sys( 2015 )
		
		select c_Ent.funcionalidades from c_entidad c_Ent ;
				where rtrim( upper( c_Ent.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				into cursor &lcFunPublica
		lcFuncionalidadPublica = &lcFunPublica..Funcionalidades
		use in select( "lcFunPublica" )
		
		if This.oFunc.TieneFuncionalidad( "PUBLICA", lcFuncionalidadPublica )
			This.AgregarLinea( "", 2 )
			This.AgregarLinea( "bindevent( This.oEntidad, 'Cargar', This, 'RefrescarComboToolbar', 1 )", 2 )
			This.AgregarLinea( 'bindevent( this.oEntidad, "EventoSetearValorComboPorDefecto", this, "SetearValorComboPorDefecto" )', 2 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionHabilitarComboToolbar() as Void
		local lcFuncionalidadPublica as String, lcFunPublica as String
		lcFunPublica = sys( 2015 )
		
		select c_Ent.funcionalidades from c_entidad c_Ent ;
				where rtrim( upper( c_Ent.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				into cursor &lcFunPublica
		lcFuncionalidadPublica = &lcFunPublica..Funcionalidades
		use in select( "lcFunPublica" )
		
		if This.oFunc.TieneFuncionalidad( "PUBLICA", lcFuncionalidadPublica )
			This.AgregarLinea( "", 1 )
			This.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			This.AgregarLinea( "protected function ActualizarBarraOpcionesNoGenericas( tcEstado as String ) as Void", 1 )
			This.AgregarLinea( "dodefault( tcEstado )", 2 )
			This.AgregarLinea( "Thisform.oToolbar.Combo_bases.enabled = this.oEntidad.lNuevo or this.oEntidad.lEdicion", 2 )
			This.AgregarLinea( "endfunc", 1 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionSeteoValorComboToolbarPorDefecto() as Void
		local lcFuncionalidadPublica as String, lcFunPublica as String
		lcFunPublica = sys( 2015 )
		
		select c_Ent.funcionalidades from c_entidad c_Ent ;
				where rtrim( upper( c_Ent.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				into cursor &lcFunPublica
		lcFuncionalidadPublica = &lcFunPublica..Funcionalidades
		use in select( "lcFunPublica" )
		
		if This.oFunc.TieneFuncionalidad( "PUBLICA", lcFuncionalidadPublica )
			This.AgregarLinea( "", 1 )
			This.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			This.AgregarLinea( "Function SetearValorComboPorDefecto() as Void", 1 )
			This.AgregarLinea( "This.RefrescarComboToolbar()", 2 )
			This.AgregarLinea( "Endfunc", 1 )
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionObtenerDetalleParaIngresoLecturaTxt() as Void
		local lnTab as Integer, lcCursor as String

		lnTab = 1
		with this as GeneradorDinamicoKontroler of GeneradorDinamicoKontroler.prg
			lcCursor = this.ObtenerCursorAtributos( .cTipo )
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerDetalleParaIngresoLecturaTxt() as detalle of detalle.prg", lnTab )
				select atributo from &lcCursor dic where "<COPIADESDETXT>" $ dic.tags into cursor "c_atributodetalles"
				if _tally > 0
					.agregarLinea( "return this.oEntidad." + alltrim( c_atributodetalles.Atributo ) , lnTab + 1 )
				endif
			.agregarLinea( "endfunc", lnTab )
			use in select( "c_atributodetalles" )
		endwith

	endfunc
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesMiPyME() as Void
		local lnTab as Integer, lcCursor as String
		lcTipo = this.ctipo
		lnTab = 1
		with this as GeneradorDinamicoKontroler of GeneradorDinamicoKontroler.prg
		if this.VerificarFuncionalidad( this.cTipo, "MIPYME" ) 
			lcCaptionMiPyME = this.ObtenerDescripcion( lctipo + "DECREDITO" )
			lcCaptionComun = this.ObtenerDescripcion( lctipo )
			lcCodigoMipyme = this.ObtenerCodigoMiPyME()
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function TituloComprobanteDeCredito() as Void", lnTab )	
			.agregarLinea( "local lcTitConsig as String", lnTab + 1)	
			.agregarLinea( "lcTitConsig = ''", lnTab + 1)	
			.agregarLinea( "if pemstatus(this.oEntidad, 'MercaderiaConsignacion',5) and This.oEntidad.MercaderiaConsignacion", lnTab + 1)
			if  at( "NOTADECREDITO", lcTipo ) > 0 
				.agregarLinea( "lcTitConsig = ' (En consignación)'", lnTab + 2)
			else
				.agregarLinea( "lcTitConsig = ' (Liquidación de Consignaciones)'", lnTab + 2)
			endif
			.agregarLinea( "endif", lnTab + 1 )		
			if !this.VerificarFuncionalidad( this.cTipo, "AGRUPACOMPROBANTES" )	
				.agregarLinea( "if this.oEntidad.tipoComprobante = " + lcCodigoMipyme, lnTab + 1 )
				.agregarLinea( "thisform.Caption = '" + alltrim( lcCaptionMiPyME ) + "' + lcTitConsig", lnTab + 2 )
				.agregarLinea( "else", lnTab + 1 )
				.agregarLinea( "thisform.Caption = '" + alltrim( lcCaptionComun ) + "' + lcTitConsig", lnTab + 2 )
				.agregarLinea( "endif", lnTab + 1 )
			endif
			.agregarLinea( "endfunc", lnTab )
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ActualizarFormulario() As Void", lnTab )
			.agregarLinea( "dodefault()", lnTab + 1 )
			.agregarLinea( "this.TituloComprobanteDeCredito()", lnTab + 1 )
			.agregarLinea( "if goParametros.Nucleo.DatosGenerales.Pais = 3", lnTab + 1 )
			.agregarLinea( "this.ActualizarTituloComprobanteUruguay()", lnTab + 2 )
			.agregarLinea( "endif", lnTab + 1 )
			.agregarLinea( "endfunc", lnTab )
		endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesCondicionFocoKitYParticipantes() as Void
		local lcDetalles as String, llAgregar as Boolean
		lcDetalles = this.ObtenerDetallesParticipantes()	
		if !empty( lcDetalles )
			this.AgregarFuncionCondicionDeFoco( lcDetalles )
			this.AgregarFuncionVerificarCondicionFocoPorKit()
			*this.AgregarFuncionVerificarCondicionFocoPorParticipante()
			this.AgregarFuncionEsArticuloTipoKit()
			this.AgregarFuncionEsAtributosADeshabilitarParaArticuloTipoKit()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCondicionDeFoco( tcDetalles as String ) as Void
		local lcDetallesConTag as String
		lcDetallesConTag = this.ObtenerDetallesParticipantes( .T. )		
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "function CondiciondeFoco( tcTipoDetalle as String , tnFila as Integer , tnColumna as Integer ) as Boolean", 1 )
			.agregarLinea( "local llRetorno as boolean, loControl as Object, lcAtributoDetalle as String, lcIdItem as String", 2 )	
			.agregarLinea( "llRetorno  = dodefault( tcTipoDetalle, tnFila, tnColumna )", 2 )	
			.agregarLinea( "if llRetorno and inlist( alltrim( upper( tcTipoDetalle ) ), " + tcDetalles + " ) and This.ExisteControl( tcTipoDetalle )", 2 )
			.agregarLinea( "loControl = This.ObtenerControl( tcTipoDetalle )", 3 )
			.agregarLinea( "llRetorno = llRetorno and This.VerificarCondicionFocoPorKit( tnFila, tnColumna, loControl, tcTipoDetalle )", 3 )
			if !empty( lcDetallesConTag )
				.agregarLinea( "llRetorno = llRetorno and This.VerificarCondicionFocoPorParticipante( tnFila, tcTipoDetalle )", 3 )	
			endif
			.agregarLinea( "endif", 2 )	
			.agregarLinea( "return llRetorno", 2 ) 		
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionVerificarCondicionFocoPorKit() as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1  )	
			.agregarLinea( "protected function VerificarCondicionFocoPorKit( tnFila as Integer, tnColumna as Integer, toControl as Object, tcDetalle as String ) as Boolean", 1  )
			.agregarLinea( "local llRetorno as Boolean", 2 )
			.agregarLinea( "llRetorno = .T.", 2 )
			.agregarLinea( "if this.EsArticuloTipoKit( tnFila, tcDetalle )", 2 )
			.agregarLinea( "llRetorno = !this.EsAtributosADeshabilitarParaArticuloTipoKit( toControl.aGrilla[ tnColumna + 1 ].cAtributo )", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "return llRetorno", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc
	
*!*		*-----------------------------------------------------------------------------------------
*!*		protected function AgregarFuncionVerificarCondicionFocoPorParticipante() as Void
*!*			lcDetalles = this.ObtenerDetallesParticipantes( .T. )
*!*			if !empty( lcDetalles )
*!*				with this
*!*					.agregarLinea( "" )	
*!*					.agregarLinea( "*" + replicate( "-", 104 ), 1  )	
*!*					.agregarLinea( "protected function VerificarCondicionFocoPorParticipante( tnFila as Integer, tcDetalle as String ) as Boolean", 1  )
*!*					.agregarLinea( "local llRetorno as Boolean, lcReferenciaItem as String", 2 )
*!*					.agregarLinea( "if upper( tcDetalle ) = 'KITSDETALLE'", 2 )
*!*					.agregarLinea( "llRetorno = .t.", 3 )
*!*					.agregarLinea( "else", 2 )
*!*					.agregarLinea( "lcReferenciaItem = iif( tnFila > 0, 'item[ tnFila ]', 'oItem' )", 3 )
*!*					.agregarLinea( "llRetorno = evaluate( 'empty( this.oEntidad.' + tcDetalle + '.' + lcReferenciaItem + '.IdKit )' )", 3 )
*!*					.agregarLinea( "endif", 2 )				
*!*					.agregarLinea( "return llRetorno", 2 )
*!*					.agregarLinea( "endfunc", 1 )
*!*				endwith
*!*			endif
*!*		endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionEsArticuloTipoKit() as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )	
			.agregarLinea( "protected function EsArticuloTipoKit( tnFila as Integer, tcDetalle as String ) as Boolean", 1 )
			.agregarLinea( "local lcAtributoDetalle as String, llRetorno as Boolean, lcReferenciaItem as String", 2 )
			.agregarLinea( "lcReferenciaItem = iif( tnFila > 0, 'item[ tnFila ]', 'oItem' )", 2 )
			.agregarLinea( "llRetorno = evaluate( 'this.oEntidad.' + tcDetalle + '.' + lcReferenciaItem + '.Comportamiento' ) = 4", 2 )
			.agregarLinea( "return llRetorno", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionEsAtributosADeshabilitarParaArticuloTipoKit() as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )	
				.agregarLinea( "protected function EsAtributosADeshabilitarParaArticuloTipoKit( tcAtributo as String ) as Boolean", 1 )
			.agregarLinea( "*si no son estos casos se deberia sobreescribir en el kontroler que corresponda", 2 )
			.agregarLinea( "if goParametros.Felino.GestionDeVentas.HabilitarColorTalleKits", 2 )
			.agregarLinea( "return .f.", 3 )
			.agregarLinea( "else", 2 )
			.agregarLinea( "return ( !inlist( upper( alltrim( tcAtributo ) ), 'ARTICULO', 'ARTICULODETALLE', 'CANTIDAD', 'PRECIO', 'MONTO', 'MONTODESCUENTO', 'DESCUENTO' ) )", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionesFormateoFilasKitYParticipantes() as Void
		local lcDetalles as String
		lcDetalles = this.ObtenerDetallesParticipantes( .T. )
		if !empty( lcDetalles )
			this.AgregarFuncionVerificarFormateosDeLaFilaActiva( lcDetalles )
			this.AgregarFuncionVerificarFormateosDeLaFilaPlana( lcDetalles )
			this.AgregarFuncionVerificarCondicionDeFocoPrimeraColumnaAccesible( lcDetalles )
		endif
	endfunc
	
	*----------------------------------------------------------------------------------------
	protected function AgregarFuncionVerificarFormateosDeLaFilaActiva( tcDetalles as String ) as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )	
			.agregarLinea( "function VerificarFormateosDeLaFilaActiva( tcDetalle as string, toControl as Object ) as Void", 1 )
			.agregarLinea( "local lcIdItem as String", 2 )
			.agregarLinea( "toControl.FontItalic = .F.", 2 )
			.agregarLinea( "toControl.FontBold = .F.", 2 )			
			.agregarLinea( "dodefault( tcDetalle, toControl )", 2 )
			.agregarLinea( "if inlist( alltrim( upper( tcDetalle ) ), " + tcDetalles + " )", 2 )
			.agregarLinea( "lcIdItem = This.ObtenerValorAtributoItemActivoSegunAtributo( tcDetalle, 'IdKit' )", 3 )
			.agregarLinea( "if !isnull( lcIdItem ) and !empty( lcIdItem )", 3 )
			.agregarLinea( "toControl.FontItalic = .T.", 4 )
			.agregarLinea( "toControl.FontBold = .T.", 4 )
			.agregarLinea( "endif", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionVerificarFormateosDeLaFilaPlana( tcDetalles as String ) as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )	
			.agregarLinea( "function VerificarFormateosDeLaFilaPlana( tcDetalle as string, toControl as Object, tnRegistroIncioPantalla as integer ) as void", 1 )
			.agregarLinea( "local lcIdItem as String, llFaltaArt as Boolean", 2 )
			.agregarLinea( "toControl.FontItalic = .F.", 2 )
			.agregarLinea( "toControl.FontBold = .F.", 2 )	
			.agregarLinea( "dodefault( tcDetalle, toControl, tnRegistroIncioPantalla )", 2 )
			.agregarLinea( "if inlist( alltrim( upper( tcDetalle ) ), " + tcDetalles + " )", 2 )
			.agregarLinea( "lcIdItem = This.ObtenerValorAtributoPlanoSegunAtributoFila( tcDetalle, toControl.nFila, 'IdKit', tnRegistroIncioPantalla )", 3 )
			.agregarLinea( "if !isnull( lcIdItem ) and !empty( lcIdItem )", 3 )
			.agregarLinea( "toControl.FontItalic = .T.", 4 )
			.agregarLinea( "toControl.FontBold = .T.", 4 )
			.agregarLinea( "endif", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarFuncionVerificarCondicionDeFocoPrimeraColumnaAccesible( tcDetalles as String ) as Void
		with this
			.agregarLinea( "" )	
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )	
			.agregarLinea( "function VerificarCondicionDeFocoPrimeraColumnaAccesible( tcDetalle as String, tnFila as Integer ) as Boolean", 1 )
			.agregarLinea( "local llRetorno as Boolean", 2 )
			.agregarLinea( "llRetorno = dodefault( tcDetalle, tnFila )", 2 )
			.agregarLinea( "if inlist( alltrim( upper( tcDetalle ) ), " + tcDetalles + " )", 2 )
			.agregarLinea( "llRetorno = llRetorno and This.VerificarCondicionFocoPorParticipante( tnFila, tcDetalle )", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "return llRetorno", 2 )			
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDetallesParticipantes( tlFiltraPorTag ) as String
		local lcCursorEntidad as String, lcCursorDetalle as String, loAtributos as Object, lcSentencia as String
		lcDetalles = ""	

		loAtributos = this.ObtenerAtributosCombinacion()
		lcCursor = this.ObtenerCursorAtributos( this.cTipo )
		lcSentencia = 'select atributo from &lcCursor dic where Detalle and alta '
		if tlFiltraPorTag 
			lcSentencia = lcSentencia + ' and "<CONPARTICIPANTES>" $ Tags '
		endif
		lcSentencia = lcSentencia + ' into cursor "c_detalleConParticipantes" '
		&lcSentencia
		scan		
			lcCursorDetalle = this.oDetalles( alltrim( Atributo ) )
			select ( lcCursorDetalle )
			
			llAgregar = this.TieneAtributosCombinacion( lcCursorDetalle )			
			
			if llAgregar
				&&dejar solo los que tienen atributos con claveforanea "ARTICULO", "COLOR" y "TALLE" y se llaman igual
				lcDetalles = lcDetalles + "'" + upper( alltrim( c_detalleConParticipantes.Atributo) ) + "'" + ","
			endif
			
			select ( "c_detalleConParticipantes" )
		endscan
		lcDetalles = Substr( lcDetalles, 1, Len( lcDetalles ) - 1 )
		use in select( "c_detalleConParticipantes" )
		return lcDetalles
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionesComprobantesAgrupados() as Void
		local lnTab as IntegerAgregarFuncionesComprobantesAgrupados

		loDatosAGenerar = this.ObtenerDatosAGenerar()
		lnTab = 1
		with this as GeneradorDinamicoKontroler of GeneradorDinamicoKontroler.prg
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
					.AgregarLinea( "case this.oEntidad.Tipocomprobante = " + oEntidad.TipoComprobante, lnTab + 1 ) 
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
		return "Kontroler"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ModificarMetodosEspecificos( toCol as Object) as object
		loRetorno = dodefault( toCol )
		loMetodos = loRetorno.oMetodos
		loColBindeos = _Screen.zoo.crearobjeto( "ZooColeccion" )
		if loMetodos.Buscar("Inicializar")
			loInicializar = loMetodos.Item["Inicializar"]
			for each oMetodo in loInicializar
				for each oLinea in oMetodo.Cuerpo
					if this.EsBindeo( oLinea )
						loColBindeos.agregar( newobject("ItemDesBindeo","","",oLinea, oMetodo.TipoComprobante ) )
					endif 
				endfor
			endfor
			for each oMetodo in loInicializar
				loNuevoCuerpo = _Screen.zoo.crearobjeto( "ZooColeccion" )
				loColDesbindeos = loColBindeos.Filtrar( 'UPPER( ALLTRIM ( #ITEM.TipoComprobante ) ) != "'+ alltrim( upper( oMetodo.TipoComprobante ) ) + '"')	
				for each oDesb in loColDesbindeos
					loNuevoCuerpo.AgregarRango( oDesb.linea )
				endfor
				loNuevoCuerpo.AgregarRango( oMetodo.Cuerpo )
				oMetodo.Cuerpo = loNuevoCuerpo
			endfor
		endif
		for i = loMetodos.count to 1 step -1
			algo=loMetodos.Item[i]
			if algo.Item[1].NombreDelMetodo == "ArticulosSeniadosDetalle_Articulo_PK_assign"
				lometodos.Quitar(i)
				exit
			endif
		endfor
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EsBindeo( tcLineaBindeo ) as boolean
		return atc( "BINDEAREVENTO", upper( tcLineaBindeo )) > 0 or atc( "ENLAZAR", upper( tcLineaBindeo )) > 0
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionCrearColeccionDeControlesVisuales() as Void
		with this
			.AgregarLinea( replicate( "*", 100 ), 1 )
			.AgregarLinea( "Function CrearColeccionDeControlesVisuales() as ZooColeccion of ZooColeccion.prg", 1 )
				.AgregarLinea( "local loColeccion as ZooColeccion of ZooColeccion.prg", 2 )
				.AgregarLinea( "loColeccion = _Screen.zoo.CrearObjeto( 'ZooColeccion' )", 2 )
				select Atributo from c_diccionario ;
					where alltrim( upper( entidad ) ) == alltrim( upper( This.cTipo ) ) and alta ;
					order by CampoInicial desc,Grupo,Subgrupo,Orden ;
					into cursor c_ver
				scan All
					.AgregarLinea( "loColeccion.Add( '" + alltrim( upper( c_Ver.Atributo ) ) + "' )", 2 )
					select c_Ver
				endscan
				use in select( "c_Ver" )
				.AgregarLinea( "Return loColeccion", 2 )
			.AgregarLinea( "EndFunc", 1 )
		EndWith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionalidadPersonalizacionDeComprotante() as Void
		local lcFuncionalidadPersonaliza as String, lcFunPersonaliza as String
		lcFunPersonaliza = sys( 2015 )
		select c_Ent.funcionalidades from c_entidad c_Ent ;
				where rtrim( upper( c_Ent.Entidad ) ) == upper( trim( this.cTipo ) ) ;
				into cursor &lcFunPersonaliza
		lcFuncionalidadPersonaliza = &lcFunPersonaliza..Funcionalidades
		use in (select('lcFunPersonaliza'))
		if This.oFunc.TieneFuncionalidad( "PERSONALIZA", lcFuncionalidadPersonaliza )
			with this
				.AgregarLinea( "", 1 )
				.AgregarLinea( replicate( "*", 100 ), 1 )
				.AgregarLinea( "protected Function ObtenerDenominacionPersonalizaPluralDeEntidad() as String", 1 )
					.AgregarLinea( "local lcTitulo as String", 2 )
					.AgregarLinea( "lcTitulo = goServicios.PersonalizacionDeEntidades.ObtenerDenominacionPluralDeEntidad( this.oEntidad.cNombre )", 2 )
					.AgregarLinea( "return lcTitulo", 2 )
				.AgregarLinea( "EndFunc", 1 )
			EndWith
		endif
	endfunc

enddefine 

*-----------------------------------------------------------------------------------------
define class ItemAtributoBindeo as Custom

	Atributo = ""
	AtributoKontrolerMR = ""
	AtributoMR = ""
	Entidad = ""

enddefine

*-----------------------------------------------------------------------------------------
define class ItemDesBindeo as Custom

	TipoComprobante = ""
	Linea = ""
	Original = ""
	
	*-----------------------------------------------------------------------------------------
	function Init( tcLinea as String, tcTipoComprobante ) as Object
		this.TipoComprobante = tcTipoComprobante
		this.Linea = this.ObtenerDesbindeo( tcLinea )
		this.original = alltrim( tcLinea )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDesbindeo( tcLinea as String ) as String
		return this.ObtenerStringDesbindeo(tcLinea)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function obtenerStringDesbindeo( tcLineaBindeo as String ) as String
		lcRetorno = _Screen.zoo.crearobjeto( "ZooColeccion" )
		if atc( "BINDEAREVENTO", upper( tcLineaBindeo )) > 0
			lcRetorno.Agregar( "if pemstatus( " + this.ObtenerObjeto( tcLineaBindeo ) + [,] + this.ObtenerEvento( tcLineaBindeo ) + [,5)] )
			lcRetorno.Agregar( strtran( tcLineaBindeo , "BindearEvento", "DesBindearEvento" ) )
			lcRetorno.Agregar( "endif" )
		else
			if atc( "ENLAZAR", upper( tcLineaBindeo )) > 0
				alines( laParametros, substr( tcLineaBindeo , at( "(", tcLineaBindeo ) + 1, at( ")", tcLineaBindeo ) - at( "(", tcLineaBindeo ) - 1 ), "," )
				lcDelegando = alltrim( strtran( laParametros[1], '"', "") )
				lcDelegado = alltrim( strtran( laParametros[2], '"', "") )
				if substr( lcDelegando, 1, 1 ) = "."
					lcDelegando = alltrim( substr( lcDelegando, 2 ))
				endif
				lnPunto  = at( ".", lcDelegando )
				if lnPunto = 0
					lcObjeto = "this"
				else
					lcObjeto = "this." + substr( alltrim( lcDelegando ) , 1, at( ".", lcDelegando ) - 1 )
				endif
				lcEvento = substr( lcDelegando , lnPunto + 1 )
				lcRetorno.Agregar( "if pemstatus( " + lcObjeto + [,"] + lcEvento + [",5)] )
				lcRetorno.Agregar( "this.DesbindearEvento( " + lcObjeto + [, "] + lcEvento + [", this, "] +  lcDelegado + [" )] )
				lcRetorno.Agregar( "endif" )
			endif
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerObjeto( tcLinea as String ) as object
		alines( laParametros, substr( tcLinea, at( "(", tcLinea ) + 1, at( ")", tcLinea ) - at( "(", tcLinea ) - 1 ), "," )
		return laParametros[1]
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEvento( tcLinea as String ) as object
		alines( laParametros, substr( tcLinea, at( "(", tcLinea ) + 1, at( ")", tcLinea ) - at( "(", tcLinea ) - 1 ), "," )
		return laParametros[2]
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerParametros( tcLinea as String ) as object
		dimension laParametros(4)
		alines( laParametros, substr( tcLinea, at( "(", tcLinea ) + 1, at( ")", tcLinea ) - at( "(", tcLinea ) - 1 ), "," )
		return laParametros
	endfunc
enddefine
