define class GeneradorDinamicoDetalle as GeneradorDinamico of GeneradorDinamico.prg

	#IF .f.
		Local this as GeneradorDinamicoDetalle of GeneradorDinamicoDetalle.prg
	#ENDIF

	cCursorAtributos = ""
	cCursorEntidad = ""
	lCargando = .f.
	lLimpiando = .f.
	cTipoDetalle = ""
	cDominio = ""
	cTags = ""
	lTieneSumarizados = .f.
	
	*-----------------------------------------------------------------------------------------
	function Generar( tcTipo as string, tcAtributo as string, tcTipoDetalle As String, tcDominio as string, tcTags as String ) as Void

		this.cPrefijo = "Detalle"
		this.cSufijo = Proper( alltrim( tcAtributo ) )
		This.cTipoDetalle = proper( alltrim( tcTipoDetalle ) ) 
		this.cDominio = alltrim( upper( tcDominio ) )
		this.cTags = alltrim( upper( tcTags ) )
		
		dodefault( tcTipo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		use in select( this.cCursorAtributos )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarPieClase() as Void
		dodefault()
		this.CrearClaseItemAuxiliar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearClaseItemAuxiliar() as Void
		local lcCursor as String, lcAtributo as string, lxValor as Variant, lcValor as string
		with this
			lcCursor = .cCursorAtributos 

			.AgregarLinea( "")
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 0 )
			.AgregarLinea( "define class ItemAuxiliar as custom", 0 )
			.AgregarLinea( "")			
			select &lcCursor
			scan
				lcAtributo = proper( alltrim( &lcCursor..Atributo ) ) + iif( &lcCursor..EsEntidad, "_PK", "" )

				lxValor =  goLibrerias.ValorVacioSegunTipo( &lcCursor..TipoDato ) 
				lcValor = goLibrerias.valorAstring( lxValor )
				
				.AgregarLinea( lcAtributo + " = " + lcValor , 1 )
			endscan 
			.AgregarLinea("NroItem = 0", 1 )
			if 'ITEMVALOR'$upper(this.cDominio) or 'ITEMCANJE'$upper(this.cDominio)
				locate for 'recibido' = lower(&lcCursor..Atributo)
				.AgregarLinea("lTieneImporteEnRecibido = " + iif(found(),'.t.','.f.'), 1 )
			endif
			.AgregarLinea( "")			
			.AgregarLinea( "enddefine", 0 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionClonarItemAuxiliar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ClonarItemAuxiliar( tnItem as Integer ) as Object", 1 )
			.AgregarLinea( "loItemOrigen = this.Item[tnItem]", 2 )
			.AgregarLinea( "loRetorno = createobject( 'itemAuxiliar' )", 2 )

			.AgregarLinea( "this.CopiarItemaItem( loItemOrigen, loRetorno ) ", 2 )
			.AgregarLinea( "" )	

			.AgregarLinea( "return loRetorno", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionCopiarItemaItem() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function CopiarItemaItem( toItemOrigen as Object, toItemDestino as Object ) as Object", 1 )

			lcCursor = this.cCursorAtributos 
			select &lcCursor
			scan
				lcAtributo = proper( alltrim( &lcCursor..Atributo ) ) + iif( &lcCursor..EsEntidad, "_PK", "" )
				.AgregarLinea( "toItemDestino." + lcAtributo + " = toItemOrigen." + lcAtributo , 2 )
			endscan 

			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionCrearItemAuxiliar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function CrearItemAuxiliar() as Object", 1 )
			.AgregarLinea( "return createobject( 'itemAuxiliar' )", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AntesDeGenerarCodigo() as void
		dodefault()
		this.cCursorAtributos = this.ObtenerCursor()
		this.cCursorEntidad = "c_" + this.cSufijo
		this.lTieneSumarizados = this.TieneAtributosSumarizados()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursor() as string
		local lcsql as string, lcNombreCursor as String, lcEntidad as string

		lcNombreCursor = "c_" + sys(2015)
		lcentidad = upper( alltrim( ( substr( this.cDominio, 8 ) ) ) )

		lcsql = "select dic.Atributo, dic.campo, dic.sumarizar, dic.tipodato, dic.obligatorio, dic.longitud, dic.alta,"+;
				" dic.decimales, dic.unicidad, !empty( Dic.ClaveForanea ) as EsEntidad , dic.dominio as Dominio, dic.tags, dic.Etiqueta, dic.ClaveForanea "+;
				" from c_Diccionario Dic "+;
				" where rtrim(upper(Dic.Entidad)) == '" + upper( alltrim( lcentidad ) ) + "'"+;
				" order by Dic.Orden "+;
				" into cursor " + lcNombreCursor
		&lcsql 
		return lcNombreCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
		with this
			if !empty( This.cTipoDetalle ) and  file( "Detalle" + This.cTipoDetalle + ".Prg" )
				.AgregarLinea( "define class Din_" + .cPrefijo + .cTipo + .cSufijo + " as " + "Detalle" + This.cTipoDetalle + ;
					" of " + "Detalle" + This.cTipoDetalle + ".Prg" )
			Else
				.AgregarLinea( "define class Din_" + .cPrefijo + .cTipo + .cSufijo + " as detalle of detalle.prg" )
			EndIf			
			
			.AgregarLinea( "" )
			.AgregarAtributosSumarizados()
			.AgregarAtributoUnicidad()
			.AgregarAtributosDetalle()
			.AgregarLinea( "cNombre = '" + this.cSufijo + "'", 1 )
			.AgregarLinea( "cEtiqueta = '" + this.ObtenerEtiquetaDelDetalle() + "'", 1 )
			.AgregarLinea( "cMensajeErrorUnicidad = '" + This.ObtenerMensajeErrorUnicidad() + "'", 1 )
			.AgregarLinea( "cNombreVisual = '" + This.ObtenerNombreVisual() + "'", 1 )
			.AgregarLinea( "" )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeErrorUnicidad() as String
		local lcRetorno as String, lcEtiquetas as String, lnCant as Integer
		lnCant = 0
		lcEtiquetas = ""
		select ( this.cCursorAtributos )
		scan all for Unicidad
			lnCant = lnCant + 1 
			lcEtiquetas = lcEtiquetas + " + " + alltrim( Etiqueta )
		endscan
		lcEtiquetas = substr( lcEtiquetas, 4 )
		if lnCant > 1
			lcRetorno = "Las columnas " + lcEtiquetas + " no admiten valores repetidos."
		else
			lcRetorno = "La columna " + lcEtiquetas + " no admite valores repetidos."
		Endif	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreVisual() as String
		local lcRetorno as String
		select c_Diccionario
		locate for upper( alltrim( Dominio )) == This.cDominio
		lcRetorno = Alltrim( c_Diccionario.DescripcionSubGrupo )
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosSumarizados() as Void
		local lcCursor as string, lcAtributo as string, lcEntidad as string, lcConsulta as String
		
		lcConsulta = sys( 2015 )
		
		with this
			lcCursor = .cCursorAtributos

			select sumarizar from ( lcCursor ) ;
					where !empty( sumarizar ) ;
					group by sumarizar ;
				into cursor ( lcConsulta )

			select ( lcConsulta )
			scan
				lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
				.AgregarLinea( "Sum_" + lcAtributo + " = 0" , 1 )
			endscan
			.AgregarLinea( "" )
			
			use in select( lcConsulta )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		with this
			.FuncionInicializar()
			.FuncionCargarItem()
			.FuncionAplanarItemActivo()
			.FuncionModificar()
			if .lTieneSumarizados
				.FuncionSumarizar()
				.FuncionTotalizar()
				.FuncionAcumular()
				.FuncionLimpiar()
			endif
			.AccessItem()
			.FuncionCargar()
			.FuncionValidarExistenciaCamposFijosItemPlano()
			.FuncionValidarFormatoAtributos()
			.FuncionCrearItemAuxiliar()
			.FuncionClonarItemAuxiliar()
			.FuncionCopiarItemaItem()
			.FuncionActualizarPorStock()
			.FuncionVerificarSiElAtributoEstaVacio()
			.FuncionElAtributoEsVerificableComoVacio()
			.FuncionObtenerAtributoPrePantalla()
			.FuncionObtenerFiltro()
			.FuncionObtenerCampoInicialYObligatorioDelDetalle()
			.FuncionAgregarFuncionEventoAgregarKits()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerAtributoPrePantalla() as Void
	
		with this
			lcCursor = .cCursorAtributos
			
			select ( lcCursor )
			scan
				if "<SOPORTAPREPANTALLA>"$&lcCursor..tags
					lcAtributo = alltrim( proper( &lcCursor..Atributo ) ) + iif( !empty(&lcCursor..EsEntidad), "_PK", "" )

					.agregarLinea( "*" + replicate( "-", 104 ), 1 )
					.AgregarLinea( "function ObtenerAtributoPrePantalla() as String", 1 )
					.agregarLinea( "return '" + lcAtributo + "'", 2 )
					.AgregarLinea( "endfunc", 1 )
					.AgregarLinea( "" )	
					exit
				endif
			endscan

		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionSumarizar() as Void
		local lcCursor as string, lcAtributo as string, lcCondicion as String, lcEntidad as string, lcConsulta as String, lcLocales as String, lnTab as Integer, lcLinea as String, lcClaveEnItem as String
		
		lcConsulta = sys( 2015 )
		lnTab = 1

		lcClaveEnItem = this.ObtenerAtributoClaveEnItem()
		
		with this
			lcCursor = .cCursorAtributos

			select sumarizar,campo,tags,empty(campo) as EsVirtual from ( lcCursor ) ;
					where !empty( sumarizar ) ;
					group by sumarizar ;
				into cursor ( lcConsulta )
			
			if _tally > 0
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Sumarizar() as boolean", lnTab )

				lcLocales = "local lnItem as integer, loItem as Object"				

				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcLocales = lcLocales + ", lnSum_" + lcAtributo + " as Number"
				endscan

				lnTab = lnTab + 1
				.AgregarLinea( lcLocales, lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( "with this", lnTab )

				lnTab = lnTab + 1
				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					.AgregarLinea( "lnSum_" + lcAtributo + " = 0" , lnTab )
				endscan
				
				.AgregarLinea( "if this.lEsNavegacion" , lnTab )
				lcLinea = "if select( '" + .cCursorEntidad +"' ) > 0 and reccount( '" + .cCursorEntidad +"' ) > 0"
				
				lnTab = lnTab + 1
				.AgregarLinea( lcLinea, lnTab )
				
				select ( lcConsulta )
				lcLinea = ""
				
				Scan For !Empty(campo)
					lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if empty( lcCondicion )
						lcLinea = Iif(Empty(lcLinea), "sum ", lcLinea+", ") + alltrim( proper( &lcConsulta..sumarizar ) )
					endif
				Endscan
				
				lnTab = lnTab + 1
				If !Empty(lcLinea)
					.AgregarLinea( lcLinea + ";", lnTab )
					lcLinea = " to ;"
					lnTab = lnTab + 1
					.AgregarLinea( lcLinea, lnTab )

					lcLinea = ""
					Scan For !Empty(campo)
						lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
						if empty( lcCondicion )
							lcLinea = lcLinea + " lnSum_" + alltrim( proper( &lcConsulta..sumarizar ) )+","
						endif
					Endscan
					
					lcLinea = Left(lcLinea,Len(lcLinea)-1)
					
					.AgregarLinea( lcLinea, lnTab )
					lnTab = lnTab - 1
				Endif

				Scan For !Empty(campo)
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty( lcCondicion )
						lcCondicion = " for " + strtran(upper(lcCondicion),"{ITEM}",this.cCursorEntidad)
						.AgregarLinea( "sum " + lcAtributo + " to lnSum_" + lcAtributo + lcCondicion , lnTab )
					endif
				Endscan
				
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "this.lEsNavegacion = .f.", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "else" , lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "for lnItem = 1 to this.count" , lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "if .oItem.NroItem = lnItem", lnTab )
				.AgregarLinea( "else", lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "loItem = .Item[ lnItem ]", lnTab )
				.AgregarLinea( "with loItem ", lnTab )
				lnTab = lnTab + 1

				if !empty(lcClaveEnItem)
					.AgregarLinea( "if !empty(."+lcClaveEnItem+"_PK)", lnTab )
					lnTab = lnTab + 1
				endif

				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty( lcCondicion )
						.AgregarLinea( "if " + strtran(upper(lcCondicion),"{ITEM}",""), lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( "lnSum_" + lcAtributo + " = lnSum_" + lcAtributo + " + ." + lcAtributo , lnTab )
					if !empty( lcCondicion )
						lnTab = lnTab - 1
						.AgregarLinea( "endif", lnTab )
					endif
				endscan
				lnTab = lnTab - 1
				if !empty(lcClaveEnItem)
					.AgregarLinea( "endif", lnTab )
					lnTab = lnTab - 1
				endif
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endfor" , lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( "if .oItem.ValidarExistenciaCamposFijos() and .oItem.NroItem<=this.count", lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "loItem = .oItem", lnTab )
				.AgregarLinea( "with loItem ", lnTab )
				lnTab = lnTab + 1
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcCondicionADN = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty( lcCondicionADN )
						.AgregarLinea( "if " + strtran(upper(lcCondicionADN),"{ITEM}","this.oItem"), lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( "lnSum_" + lcAtributo + " = lnSum_" + lcAtributo + " + ." + lcAtributo , lnTab )
					if !empty( lcCondicionADN )
						lnTab = lnTab - 1
						.AgregarLinea( "endif", lnTab )
					endif
				endscan
				lnTab = lnTab - 1
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "" )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )				
					.AgregarLinea( "if .Sum_" + lcAtributo + " != lnSum_" + lcAtributo, lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( ".Sum_" + lcAtributo + " = lnSum_" + lcAtributo, lnTab )
					.AgregarLinea( ".EventoCambioSum_" + lcAtributo + "()", lnTab )
					lnTab = lnTab - 1
					.AgregarLinea( "endif" , lnTab )
				endscan
				.AgregarLinea( "" )
				lnTab = lnTab - 1
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
				this.AgregarEventosCambioSum( lcConsulta )
			endif
			
			use in select( lcConsulta )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionParaSumarizar( tcTags as String ) as String
		local lcRetorno as String, lcTagCondicion as String
		local lcExpresion as String, lcAux as string
		
		if !empty( tcTags ) and ( "<MULTIPLICA:" $ upper( alltrim( tcTags ) ) )
			lcAux = upper( alltrim( tcTags ) )
			lcAux = substr( lcAux, at( "<MULTIPLICA:", lcAux ) + 12 )
			lcAux = alltrim( substr( lcAux, at( ">", lcAux ) + 1 ) )
			tcTags = lcAux

		endif 

		if !empty( tcTags ) and ( "<CONDICIONSUMARIZAR:" $ upper( alltrim( tcTags ) ) ) 
			lcTagCondicion = getwordnum( substr( tcTags, atc( "<CONDICIONSUMARIZAR:", tcTags ) + 1  ), 1, ">" )
			lcRetorno = getwordnum( lcTagCondicion, 2, ":" )
		else
			lcRetorno = ''
		endif		
		
		return lcRetorno
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarEventosCambioSum( tcCursor as String ) as Void
		local lcAtributo as String
		select ( tcCursor )
		scan
			lcAtributo = alltrim( proper( &tcCursor..sumarizar ) )
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function EventoCambioSum_" + lcAtributo + "() as boolean", 1 )
			.AgregarLinea( "** Evento que se dispara cuando cambia el sumarizado", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endscan

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionInicializar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function Inicializar() as boolean", 1 )
			.AgregarLinea( "dodefault()", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionCargarItem() as Void
		local lcNombreCursor as string, lcAtributo as string, lcEntidad as string
		
		with this
			lcNombreCursor = .cCursorAtributos

			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "Protected Function _CargarItem( tnItem as integer )" , 1 )
			.AgregarLinea( "Local loEx as Excepcion, llVacio as Boolean" , 2 )

			.AgregarLinea( "if tnItem <= 0", 2 )
			.AgregarLinea( "loEx = Newobject( 'ZooException', 'ZooException.prg' )", 3 )
			.AgregarLinea( "With loEx", 3 )
			.AgregarLinea( ".Message = 'El item está fuera del rango'", 4 )
			.AgregarLinea( ".Grabar()", 4 )
			.AgregarLinea( ".Throw()", 4 )
			.AgregarLinea( "EndWith", 3 )
			.AgregarLinea( "EndIf", 2 )
			
			.AgregarLinea( "With this.oItem" , 2 )
			.AgregarLinea( "Try" , 3 )
			.AgregarLinea( ".lCargando = .t.", 4 )
			.AgregarLinea( ".NroItem = tnItem", 4 )
		
			.AgregarLinea( "llVacio = .t.", 4 )
			select ( lcNombreCursor )
			scan
				lcAtributo = alltrim( &lcNombreCursor..Atributo ) + iif( &lcNombreCursor..EsEntidad, "_PK", "" )
				.AgregarLinea( "." + lcAtributo + " = this.Item[ tnItem ]." + lcAtributo , 4 )
				if upper( alltrim( lcAtributo ) ) == "NROITEM"
				else
					.AgregarLinea( "llVacio = llVacio and this.VerificarSiElAtributoEstaVacio( '" + lcAtributo + "', ." + lcAtributo + " )" , 4 )
				endif
				.AgregarLinea( "", 3 )
			endscan
			
			.AgregarLinea( ".lCargando = .f.", 4 )
			.AgregarLinea( "if llVacio", 4 )
			.AgregarLinea( "this.oItem.SetearValoresSugeridos()", 5 )
			.AgregarLinea( "endif" , 4 )
			
			.AgregarLinea( "Finally" , 3 )
			.AgregarLinea( ".lCargando = .f.", 4 )
			.AgregarLinea( "EndTry" , 3 )

			.AgregarLinea( "endwith" , 2 )
			.AgregarLinea( "endfunc" , 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionAplanarItemActivo() as Void
		local lcCursor as string, lcAtributo as string
		with this
			lcCursor = .cCursorAtributos
			
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "protected function AplanarItem() as Object", 1 )
			.AgregarLinea( "local loRetorno as object",2 )
			.AgregarLinea( "loRetorno = createobject('ItemAuxiliar')",2 )
			.AgregarLinea( "" )
			.AgregarLinea( "with loRetorno", 2 )

			select &lcCursor
			scan
				lcAtributo = alltrim( &lcCursor..Atributo )
				if 	&lcCursor..Esentidad
					lcAtributo = lcAtributo + "_PK"
				endif
				.agregarlinea("."+ lcAtributo + " = this.oItem." + lcAtributo , 3 )
			endscan 
			.agregarlinea(".NroItem = iif( this.oItem.NroItem = 0, this.Count + 1, this.oItem.NroItem )", 3 )					

			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "return loRetorno", 2)
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionModificar() as Void
		local lcCursor as string, lcAtributo as string
		with this
			lcCursor = .cCursorAtributos
			
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "protected function Modificar() as void", 1 )
			.AgregarLinea( "local lnItem as integer, loEx as Exception", 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "with this", 1 )
				.AgregarLinea( "if .ValidarItem()", 2 )
					.AgregarLinea( "lnItem = .oItem.NroItem", 3 )

					.AgregarLinea( "if lnItem <= 0", 3 )
						.AgregarLinea( ".AgregarInformacion( 'Debe cargar un item para poder modificar' )", 4 )
						.AgregarLinea( "goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )", 4 )
					.AgregarLinea( "endif", 3 )

				.AgregarLinea( "" )
					.AgregarLinea( "if .oItem.ValidarExistenciaCamposFijos()", 3 )
					.AgregarLinea( "else", 3 )					
						.AgregarLinea( ".oItem.Limpiar( .t. )", 4 )
					.AgregarLinea( "endif", 3 )
					.AgregarLinea( "" )
					.AgregarLinea( ".oItem.NroItem = lnItem", 3 )

				select &lcCursor
				scan
					lcAtributo = alltrim( &lcCursor..Atributo ) + iif( &lcCursor..Esentidad, "_PK", "" )
					.agregarlinea(".Item[ lnItem ]."+ lcAtributo + " = .oItem." + lcAtributo , 3 )
				endscan 

				.AgregarLinea( "else", 2 )
					.AgregarLinea( "goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )", 3 )
				.AgregarLinea( "endif", 2 )

			.AgregarLinea( "endwith", 1 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AccessItem() as Void
		local lcNombreCursor as string, lcAtributo as string, lnTab as Integer, lcEntidad as string, ;
			lcNombreDetalle as String

		lnTab = 1
		
		with this
			lcNombreDetalle = "Item" + .cTipo + .cSufijo
	
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function oItem_Access() as variant", lnTab )
			.agregarLinea( "if !this.ldestroy and ( !vartype( this.oItem ) = 'O' or isnull( this.oItem ) )", lnTab + 1 )

			if file( lcNombreDetalle + ".prg" ) or file( lcNombreDetalle + ".fxp" )
				.agregarLinea( "this.oItem = _Screen.zoo.crearobjeto( '" + lcNombreDetalle + "' )", lnTab + 2 )
			else
				.agregarLinea( "this.oItem = _Screen.zoo.crearobjeto( 'Din_" + lcNombreDetalle + "' )", lnTab + 2 )
			endif
			.AgregarBindeosZooSession( 'oItem', lnTab + 2 )			
			.agregarLinea( "this.oItem.inicializar()", lnTab + 2 )
			if .lTieneSumarizados
				.AgregarLinea( "bindevent( this.oItem, 'AcumularSumarizado', this, 'Acumular', 0) ", lnTab + 2 )
				If Lower(.cTipo) == "canjedecupones"
					.AgregarLinea( "bindevent( this.oItem, 'TotalizarSumarizado', this, 'Sumarizar', 0) ", lnTab + 2 )
				else
					.AgregarLinea( "bindevent( this.oItem, 'TotalizarSumarizado', this, 'Totalizar', 0) ", lnTab + 2 )
				endif
				.AgregarLinea( "bindevent( this.oItem, 'CambioSumarizado', this, 'Sumarizar', 0) ", lnTab + 2 )
			endif
			.AgregarLinea( "bindevent( this.oItem, 'EventoDespuesDeSetear', this, 'ValidarCantidadDeItemsEnDetalle' )", lnTab + 2 )
			.agregarLinea( "endif", lnTab + 1 )
			.agregarLinea( "return this.oItem", lnTab + 1 )
			.agregarLinea( "endfunc", lnTab )
			.agregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionCargar() as Void
		local lcCursor as String, lcAtributo as String, lxValor as Variant, lcValor as string
		with this
			lcCursor = .cCursorAtributos 
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "Function Cargar() as Void",1 )
			.AgregarLinea( "local loItem as object, lnI as integer, lcClave as string, lcFiltro as String ",2 )
			.AgregarLinea( "lnI = 1", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "select " + .cCursorEntidad , 2 )
			.AgregarLinea( "lcFiltro = this.ObtenerFiltro()", 2 )			
			.AgregarLinea( "scan for &lcFiltro" , 2 )			
			.AgregarLinea( "loItem = createobject('ItemAuxiliar')", 3 )
			.AgregarLinea( "" )

			select ( lcCursor )

			scan for !empty( &lcCursor..Campo )
				lcAtributo = alltrim( &lcCursor..Atributo )

				if empty( &lcCursor..campo )
					lxValor =  goLibrerias.ValorVacioSegunTipo( &lcCursor..TipoDato ) 
					lcValor = goLibrerias.valorAstring( lxValor )
				endif
				do case 
					case alltrim( &lcCursor..TipoDato ) = "D"
						this.agregarlinea( "loItem."+ lcAtributo + iif( &lcCursor..Esentidad, "_PK", "" ) + " = goLibrerias.ObtenerFechaFormateada( " + ;
							 .cCursorEntidad + "." + lcAtributo + " )", 3 )
					otherwise
						this.agregarlinea( "loItem."+ lcAtributo + iif( &lcCursor..Esentidad, "_PK", "" ) + " = " + ;
							 .cCursorEntidad + "." + lcAtributo , 3 )
				endcase					

			endscan 
			
			.AgregarLinea( "loItem.NroItem = lnI ", 3 )
			.AgregarLinea( "this.AgregarItemPlano( loItem )", 3 )
			.AgregarLinea( "lnI = lnI + 1", 3 )
			.AgregarLinea( "endscan", 2 )
			.AgregarLinea( "" )
			if this.lTieneSumarizados
				.AgregarLinea( "this.Sumarizar()", 2 )
			else
				.AgregarLinea( "this.CambioSumarizado()", 2 )
			endif
			.AgregarLinea( "" )
			.AgregarLinea("endfunc", 1)
			.AgregarLinea( "" )	
		endwith 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FuncionValidarExistenciaCamposFijosItemPlano() as Void
		with this
			.AgregarLinea( "")
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function ValidarExistenciaCamposFijosItemPlano( tnItem as integer ) as Boolean", 1 )
			.AgregarLinea( "Local llRetorno as boolean",2 )	
			.AgregarLinea( "llRetorno = .t.", 2 )			
			.AgregarLinea( "")			
			.ValidarExistenciaCamposFijosItemPlano()
			.AgregarLinea( "return llRetorno", 2)			
			.AgregarLinea( "")			
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "")			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaCamposFijosItemPlano() as Void
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
					lcAtributo = "this.item[ tnItem ]." + lcatributo + iif( &lcConsulta..EsEntidad, "_PK", "" )
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
	Function FuncionValidarFormatoAtributos() as Void
		local lcCursor as string, lcTipoDatoAtributo as String, lcNombreAtributo as string, ;
			lcLongitudAtributo as String, lcDecimalAtributo as String, lcTotalAtributoInt as string, ;
			lcMensajeValidacion as String, lcAtributo as string, lcCursor as string, lcDominio as String, ;
			lcDetalleDelMensaje as String
			
		with this
			lcCursor = .cCursorAtributos

			.AgregarLinea( "" )
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1)
			.AgregarLinea( "Function ValidarFormatoAtributos() as boolean" , 1 )
			.AgregarLinea( "local lnLargoEntero as integer, lnValorDelDecimal as integer, lnLargoDecimal as integer, llRetorno as boolean, lnI as Integer" , 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "llRetorno = dodefault()", 2 )
			
			.AgregarLinea( "for lni = 1 to this.Count" , 2 )		
			
			select ( lcCursor )
			scan

				&& No se validan los atributos virtuales
				if empty(&lcCursor..Campo)
					loop
				endif
				
				&& Esto es la validacion por Atributo 
				lcTipoDatoAtributo = upper( alltrim( &lcCursor..TipoDato ) )
				lcTipoDatoAtributo = iif( lcTipoDatoAtributo = "A", "N", lcTipoDatoAtributo )
				lcTipoDatoAtributo = iif( lcTipoDatoAtributo = "M", "C", lcTipoDatoAtributo )
			
				lcNombreAtributo   = upper( alltrim( &lcCursor..Atributo ) )
				lcAtributo = lcNombreAtributo + iif( &lcCursor..EsEntidad, "_PK", "" )
				lcLongitudAtributo = transform( &lcCursor..Longitud - &lcCursor..Decimales )
				lcDecimalAtributo  = transform( &lcCursor..Decimales )
				lcTotalAtributoInt = transform( &lcCursor..Longitud )
				lcDominio          = upper( alltrim( &lcCursor..Dominio ) )
				
				.AgregarLinea( "", 3 )
				if lcTipoDatoAtributo = 'D'
					.AgregarLinea( "if inlist(vartype( this.Item[lni]." + lcAtributo + "),'D','T')" ,3 )
				else
					.AgregarLinea( "if vartype( this.Item[lni]." + lcAtributo + ") = '" + lcTipoDatoAtributo + "'" ,3 )
				endif

				do case
					case lcTipoDatoAtributo = 'C' and upper( alltrim( &lcCursor..TipoDato ) ) != "M"

						.AgregarLinea( "if len( alltrim( this.Item[lni]." + lcAtributo + " )) <= " + ;
									lcLongitudAtributo ,4 )
						lcMensajeValidacion = "'La longitud del valor del atributo " + lcNombreAtributo + ;
									" del item ' + transform( lni ) + ' es mayor a la permitida (Actual:' + transform( len( alltrim( this.Item[lni]." + lcAtributo + " ))) + ' Máxima:"+lcLongitudAtributo+")"
								
					case lcTipoDatoAtributo = 'N'
						
						.AgregarLinea( "lnLargoEntero = len( transform( int( this.Item[lni]." + ;
									lcAtributo + " ) ) ) " , 4 )

						if lcDominio = 'NUMERICOCONSIGNO'

							lcLongitudAtributo = transform( val( lcLongitudAtributo ) - 2 )

							.AgregarLinea( "if 0 > this.Item[lni]." + lcAtributo + " " , 4 )
								.AgregarLinea( "lnLargoEntero = lnLargoEntero - 1" , 5 )
							.AgregarLinea( "Endif" , 4 )

						endif	

						.AgregarLinea( "lnValorDelDecimal = this.Item[lni]." + lcAtributo + ;
									" - int( this.Item[lni]." + lcAtributo + " )"  , 4 )
																
						.AgregarLinea( "lnLargoDecimal = iif( lnValorDelDecimal = 0, 0, len( transform( lnValorDelDecimal ) ) - 2 )" ,4 )
					
			
							.AgregarLinea( "if lnLargoEntero <= " + lcLongitudAtributo ,4 )
							lcMensajeValidacion = "'La longitud entera del valor del atributo " + lcNombreAtributo + ;
										" del item ' + transform( lni ) + ' es mayor a la permitida (Actual:' + transform(lnLargoEntero) + ' Máxima:"+lcLongitudAtributo+")"
	
				endcase
				
				lcDetalleDelMensaje = ", en el detalle ' + this.cEtiqueta + '.'"
				
				if inlist( lcTipoDatoAtributo, 'C','N' ) and upper( alltrim( &lcCursor..TipoDato ) ) != "M"
					.AgregarLinea( "else", 4 )
					.AgregarLinea( "llRetorno = .F." , 5 )
					.AgregarLinea( "this.AgregarInformacion( " + lcMensajeValidacion + lcDetalleDelMensaje + " )" , 5 )
					.AgregarLinea( "Endif", 4 )
				endif	

				.AgregarLinea( "else", 3 )
				.AgregarLinea( "llRetorno = .F.", 4 )
				.AgregarLinea( "this.AgregarInformacion( 'El tipo de dato para el atributo " + ;
					lcNombreAtributo + " del item ' + transform( lni ) + ' no es el correcto" + lcDetalleDelMensaje + ")" , 4 )
				.AgregarLinea( "Endif", 3 )
			EndScan		
		
			.AgregarLinea( "EndFor" , 2 )		
			.AgregarLinea( "Return llRetorno " , 2 )		
			.AgregarLinea( "Endfunc" , 1 )
			.AgregarLinea( "" )	
		endwith
	Endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAtributoUnicidad() as Void
		local lcAtributos as String, lcCursor as string, lcAtr as string

		with this
			lcCursor = .cCursorAtributos
			select Atributo, EsEntidad ;
				from ( lcCursor ) ;
				where Unicidad ;
				into cursor c_Unicidad NoFilter
		
			if reccount( "c_Unicidad" ) > 0
				lcAtributos = ""
				select c_Unicidad
				scan
					lcAtr = alltrim( c_Unicidad.Atributo ) + iif( c_Unicidad.EsEntidad , "_PK", "" )
					lcAtributos = lcAtributos + iif( empty( lcAtributos ),"", "," ) + lcAtr
				endscan 
				.AgregarLinea( "cAtributosUnicidad = '" + lcAtributos + "'", 1 )
			endif 
			use in select( "c_Unicidad" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosDetalle() as Void
		local lnCantidadItems as Integer

		with this
			lnCantidadItems = this.oAdnAD.ObtenerValorCampo( "DetallesAtributos", "CantidadItems", "Detalle", alltrim( upper( this.cDominio ) ) )
			if empty( lnCantidadItems )
				lnCantidadItems = goControles.ObtenerCantidadDeItemsDeDetallePorDefecto()
			endif 

			.AgregarLinea( "nCantidadItems = " + transform( lnCantidadItems ), 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		
		dodefault()
		with this
			.cArchivo = .cPath + "Din_" + .cPrefijo + alltrim( Proper( .cTipo ) )+ .cSufijo +".prg"
		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionActualizarPorStock() as Void
		local lcEntidad as String
		
		lcEntidad = upper( alltrim( substr( this.cDominio, 8 ) ) )

		if !Empty( this.oAdnAD.ObtenerValorCampo( "relacomponente", "entidad", "Entidad,componente", lcEntidad + ",STOCK" ) )
			with this
				.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				.agregarLinea( "function Actualizar( tcClave as string ) as Void", 1 )
				.agregarLinea( "local lcInformacion as String, loEx as Exception", 2 )
				.agregarLinea( "if this.oItem.TieneDisponible()", 2 )
				if this.EsItemConParticipantes()
					.agregarLinea( "if this.oItem.Comportamiento = 4", 3 )
					.agregarLinea( "if this.oItem.TieneDisponibleDeParticipantes()", 4 )
					.agregarLinea( "this.EventoAgregarKits( this.oItem )", 5 )
					.agregarLinea( "else", 4 )
					.agregarLinea( "if goParametros.Felino.Generales.PermitirPasarSinStock", 5 )	
					.agregarLinea( "this.EventoAgregarKits( this.oItem )", 6 )
					.AgregarLinea( "this.Sumarizar()", 6 )
					.agregarLinea( "else", 5 )	
					.agregarLinea( "goServicios.Errores.LevantarExcepcion( this.oItem.oCompStock.oColErroresParticipantes )", 6 )	
					.agregarLinea( "endif", 5 )
					.agregarLinea( "endif", 4 )
					.agregarLinea( "else", 3 )
					.agregarLinea( "dodefault( tcClave )", 4 )
					.AgregarLinea( "this.Sumarizar()", 4 )
					.agregarLinea( "endif", 3 )
				else
					.agregarLinea( "dodefault( tcClave )", 3 )
					.AgregarLinea( "this.Sumarizar()", 3 )
				endif		
				.agregarLinea( "else", 2 )
				.agregarLinea( "lcInformacion = this.oitem.ocompstock.FormarMensajeCombSegunDisponible( This.oitem )", 3 )
				.agregarLinea( "this.limpiarInformacion()", 3 )
				.agregarLinea( "this.agregarinformacion( lcInformacion )", 3 )
				.agregarLinea( "if goParametros.Felino.Generales.PermitirPasarSinStock", 3 )				
				.agregarLinea( "This.EventoNoHayStock( this.oInformacion )", 4 )
				.agregarLinea( "dodefault( tcClave )", 4 )
				.AgregarLinea( "this.Sumarizar()", 4 )
				.agregarLinea( "else", 3 )
				.agregarLinea( "loEx = newobject( 'zooexception', 'zooexception.prg' )", 4 )
				.agregarLinea( "with loEx", 4 )
				.agregarLinea( ".AgregarInformacion( lcInformacion )", 5 )
				.agregarLinea( "endwith", 4 )
				.agregarLinea( "goServicios.Errores.LevantarExcepcion( loEx )", 4 )
				.agregarLinea( "endif", 3 )
				.agregarLinea( "endif", 2 )				
				.agregarLinea( "endfunc", 1 )
				.AgregarLinea( "" )	
			endwith
		else
			if this.lTieneSumarizados
				.FuncionActualizar()
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionVerificarSiElAtributoEstaVacio() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected function VerificarSiElAtributoEstaVacio( tcAtributo as String, txValor as Variant ) as Boolean", 1 )
			.agregarLinea( "local llRetorno as boolean", 2 )
			.agregarLinea( "llRetorno = .t.", 2 )
			.agregarLinea( "if this.ElAtributoEsVerificableComoVacio( tcAtributo )", 2 )
			.agregarLinea( "llRetorno = empty( txValor )", 3 )
			.agregarLinea( "endif", 2 )
			.agregarLinea( "return llRetorno", 2 )
			.agregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionElAtributoEsVerificableComoVacio() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected function ElAtributoEsVerificableComoVacio( tcAtributo as String ) as Boolean", 1 )
			.agregarLinea( "Return dodefault( tcAtributo ) ", 2 )
			.agregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
	endfunc	
			
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEtiquetaDelDetalle() as Void
		local lcEntidad as String, lcAtributo as String, lcRetorno as String
		
		lcEntidad = upper( alltrim( this.cTipo ) )
		lcAtributo = upper( alltrim( this.cSufijo  ) )
		
		lcRetorno = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Etiqueta", "Entidad,Atributo", lcEntidad + "," + lcAtributo ) ) 
		if empty( lcRetorno )
			lcRetorno = proper( alltrim( lcAtributo ) )
		endif
					
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFiltro() as Void
		local c_tmpVuelto as String
		c_tmpVuelto = sys(2015)
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected function ObtenerFiltro( ) as String", 1 )
			.agregarLinea( "local lcRetorno as String", 2 )
			select atributo from (this.cCursorAtributos) where upper(alltrim(atributo)) = "ESVUELTO" into cursor &c_tmpVuelto
			if reccount(c_tmpVuelto)> 0
				.agregarLinea( "lcRetorno = '!EsVuelto'", 2 )
			else
				.agregarLinea( "lcRetorno = '.T.'", 2 )
			endif
			.agregarLinea( "return lcRetorno", 2 )
			.agregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )	
		endwith
		use in select(c_tmpVuelto)
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerCampoInicialYObligatorioDelDetalle() as Void
	local lcCur as String
		lcCur = sys( 2015 )
		select atributo, orden, iif(!empty(claveforanea),.t.,.f.) as claveforanea from c_Diccionario where Entidad = substr( This.cDominio, 8 ) and Obligatorio and alta order by entidad,orden asc into cursor &lcCur
		if reccount( lcCur ) > 0
			This.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			this.AgregarLinea( "function ObtenerCampoInicialYOBligatorioDelDetalle() as String", 1 )
			this.AgregarLinea( "local lcRetorno as string", 1 )
			this.AgregarLinea( "lcRetorno = '" + alltrim(&lcCur..Atributo) + iif(&lcCur..claveforanea, "_pk", "" ) + "'", 2 )
			this.AgregarLinea( "return lcRetorno", 2 )
			this.AgregarLinea( "endfunc", 1 )
		endif
		use in select( lcCur )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionAgregarFuncionEventoAgregarKits() as Void 
		if this.EsItemConParticipantes()
			This.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			this.AgregarLinea( "function EventoAgregarKits( tcKit as String, tnCantidad as Number, tnPrecio as Number, tnDescuento as Number, tnMontoDescuento as Number ) as Void", 1 )
			this.AgregarLinea( "endfunc", 1 )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsItemConParticipantes() as llRetorno
		local llRetorno as Boolean, lcCursor as String
		lcCursor = this.cCursorAtributos
		llRetorno = this.oFunc.TieneFuncionalidad( "CONPARTICIPANTES", this.cTags ) and this.TieneAtributosCombinacion( lcCursor )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionTotalizar() as Void
		local lcCursor as string, lcAtributo as string, lcCondicion as String, lcEntidad as string, lcConsulta as String, lcLocales as String, lnTab as Integer, lcLinea as String
		
		lcConsulta = sys( 2015 )
		
		lcClaveEnItem = this.ObtenerAtributoClaveEnItem()

		with this
			lcCursor = .cCursorAtributos

			select sumarizar,campo,tags,alta from ( lcCursor ) ;
					where !empty( sumarizar ) ;
					group by sumarizar ;
				into cursor ( lcConsulta )
			
			lnTab = 1
			if _tally > 0
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Totalizar( toItem as Object ) as Void", lnTab  )

				lcLocales = "local lnItem as integer, loItem as Object"				

				select ( lcConsulta )

				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcLocales = lcLocales + ", lnSum_" + lcAtributo + " as Number"
				endscan

				lnTab = lnTab + 1
				.AgregarLinea( lcLocales, lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( "with this", lnTab )

				lnTab = lnTab + 1
				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					.AgregarLinea( "lnSum_" + lcAtributo + " = 0" , lnTab )
				endscan
				.AgregarLinea( "if !this.lEsNavegacion" , lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "for lnItem = 1 to this.count" , lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "if .oItem.NroItem = lnItem", lnTab )
				.AgregarLinea( "else", lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "loItem = .Item[ lnItem ]", lnTab )
				.AgregarLinea( "with loItem ", lnTab )
				lnTab = lnTab + 1

				if !empty(lcClaveEnItem)
					.AgregarLinea( "if !empty(."+lcClaveEnItem+"_PK)", lnTab )
					lnTab = lnTab + 1
				endif

				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty( lcCondicion )
						.AgregarLinea( "if " + strtran(upper(lcCondicion),"{ITEM}",""), lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( "lnSum_" + lcAtributo + " = lnSum_" + lcAtributo + " + ." + lcAtributo , lnTab )
					if !empty( lcCondicion )
						lnTab = lnTab - 1
						.AgregarLinea( "endif", lnTab )
					endif
				endscan
				lnTab = lnTab - 1
				if !empty(lcClaveEnItem)
					.AgregarLinea( "endif", lnTab )
					lnTab = lnTab - 1
				endif
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endfor" , lnTab )
				.AgregarLinea( "" )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "if .oItem.ValidarExistenciaCamposFijos() and .oItem.NroItem<=this.count", lnTab )
				lnTab = lnTab + 1
				.AgregarLinea( "loItem = .oItem", lnTab )
				.AgregarLinea( "with loItem ", lnTab )
				lnTab = lnTab + 1
				if !empty(lcClaveEnItem)
					.AgregarLinea( "if !empty(."+lcClaveEnItem+"_PK)", lnTab )
					lnTab = lnTab + 1
				endif
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcCondicionADN = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty( lcCondicionADN )
						.AgregarLinea( "if " + strtran(upper(lcCondicionADN),"{ITEM}","this.oItem"), lnTab )
						lnTab = lnTab + 1
					endif
					.AgregarLinea( "lnSum_" + lcAtributo + " = lnSum_" + lcAtributo + " + ." + lcAtributo , lnTab )
					if !empty( lcCondicionADN )
						lnTab = lnTab - 1
						.AgregarLinea( "endif", lnTab )
					endif
				endscan
				lnTab = lnTab - 1
				if !empty(lcClaveEnItem)
					.AgregarLinea( "endif", lnTab )
					lnTab = lnTab - 1
				endif
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endif", lnTab )
				.AgregarLinea( "" )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )				
					.AgregarLinea( "if .Sum_" + lcAtributo + " != lnSum_" + lcAtributo, lnTab )
					lnTab = lnTab + 1
					.AgregarLinea( ".Sum_" + lcAtributo + " = lnSum_" + lcAtributo, lnTab )
					.AgregarLinea( ".EventoCambioSum_" + lcAtributo + "()", lnTab )
					lnTab = lnTab - 1
					.AgregarLinea( "endif" , lnTab )
				endscan
				.AgregarLinea( "" )
				lnTab = lnTab - 1
				.AgregarLinea( "endwith", lnTab )
				lnTab = lnTab - 1
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endif
			
			use in select( lcConsulta )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionAcumular() as Void
		local lcCursor as string, lcAtributo as string, lcCondicion as String, lcEntidad as string, lcConsulta as String, lcLocales as String, lnTab as Integer, lcLinea as String
		
		lcConsulta = sys( 2015 )
		
		with this
			lcCursor = .cCursorAtributos

			select sumarizar,campo,tags,alta from ( lcCursor ) ;
					where !empty( sumarizar ) ;
					group by sumarizar ;
				into cursor ( lcConsulta )
			
			lnTab = 1
			if _tally > 0
				.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
				.AgregarLinea( "function Acumular( tlForzar as Boolean, tcAtributo as String, tnValor as Decimal, tnValorAnt as Decimal ) as Void", lnTab  )

				lcLocales = "local lnItem as integer, loItem as Object"				

				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					lcLocales = lcLocales + ", lnSum_" + lcAtributo + " as Number"
				endscan

				lnTab = lnTab +1
				.AgregarLinea( lcLocales, lnTab )
				.AgregarLinea( "" )
				.AgregarLinea( "do case", lnTab )
				.AgregarLinea( "case tnValor = tnValorAnt", lnTab )

				select ( lcConsulta )
				scan
					lcAtributo = alltrim( proper( &lcConsulta..sumarizar ) )
					.AgregarLinea( "case tcAtributo == '"+lcAtributo+"'", lnTab )
					lnTab = lnTab +1
					lcCondicion = this.ObtenerCondicionParaSumarizar( &lcConsulta..Tags )
					if !empty(lcCondicion)
						.AgregarLinea( "if " + strtran(upper(lcCondicion),"{ITEM}","this.oItem"), lnTab )
						lnTab = lnTab +1
					endif
					.AgregarLinea( "this.Sum_"+lcAtributo+" = this.Sum_"+lcAtributo+" - tnValorAnt + tnValor", lnTab )
					.AgregarLinea( "this.EventoCambioSum_"+lcAtributo+"()", lnTab )
					if !empty(lcCondicion)
						lnTab = lnTab -1
						.AgregarLinea( "endif", lnTab )
					endif
					lnTab = lnTab -1
				endscan

				.AgregarLinea( "" )
				.AgregarLinea( "endcase", lnTab )
				lnTab = lnTab -1
				.AgregarLinea( "endfunc", lnTab )
				.AgregarLinea( "" )
			endif
			
			use in select( lcConsulta )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function TieneAtributosSumarizados() as Boolean
		Local llRetorno as Boolean, lcConsulta as String, lcCursor as String
		llRetorno = .f.
		lcConsulta = sys( 2015 )
		
		lcCursor = this.cCursorAtributos

		select sumarizar,campo,tags from ( lcCursor ) ;
				where !empty( sumarizar ) ;
				group by sumarizar ;
			into cursor ( lcConsulta )
		llRetorno = reccount() > 0
		use in ( lcConsulta )
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionLimpiar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "Function Limpiar() as boolean", 1 )
			.AgregarLinea( "DoDefault()", 2 )
			.AgregarLinea( "this.Sumarizar()", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionActualizar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "Function Actualizar( tcClave as String ) as Void", 1 )
			.AgregarLinea( "DoDefault( tcClave )", 2 )
			.AgregarLinea( "this.Sumarizar()", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoClaveEnItem() as String
		local lcRetorno As String, lcNombreCursor as String

		lcRetorno = ""
		if upper(left(this.cDominio,7)) = "DETALLE"
			lcEntidad = substr(this.cDominio,8)
			lcNombreCursor	= "c_" + sys(2015)
			Select upper( dic2.Atributo ) as Atributo, alta ;
				from c_Diccionario Dic2 ;
				where upper( alltrim( Dic2.Entidad ) ) == upper( alltrim( lcEntidad ) ) .And. Dic2.alta .And. !Dic2.SaltoCampo .And. ;
				inlist(alltrim(Dic2.dominio),"CONSOPORTEPREPANTALLA", "CODIGO", "CODIGOVALOR","CLAVECONLECTURACB") .And. Dic2.grupo * 100 + Dic2.orden in ;
				(Select min(Dic3.grupo * 100 + Dic3.orden) from c_Diccionario Dic3 where Dic3.alta .And. upper( alltrim( Dic3.Entidad ) ) == upper( alltrim( lcEntidad ) ) ) ;
				into cursor &lcNombreCursor

			if reccount( lcNombreCursor ) = 1
				lcRetorno = alltrim(&lcNombreCursor..Atributo)
			else
				lcRetorno = ""
			endif
			use in (select(lcNombreCursor))
		endif
		return lcRetorno
	endfunc 

enddefine

