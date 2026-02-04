*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*-----------------      COMPLETA LOS ATRIBUTOS DE LOS LISTADOS GENERICOS      ----------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*	Este objetivo se logra a partir de la clase CompletarAtributosListadosGenericos y sus
*	clases derivadas:
*					- CompletarAtributosListadosGenericosParaUnaEntidad
*					- CompletarAtributosListadosGenericosParaUnItemDetalle 
*					- CompletarAtributosListadosGenericosParaUnaSubEntidad 
*					- CompletarAtributosListadosGenericosParaCabeceraForzada 
*---------------------------------------------------------------------------------------------

define class CompletarAtributosListadosGenericos as Custom 

	#if .f.
		local this as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg
	#endif
	
	protected nCantidadDeFiltrosClaveForaneaVisibles as Integer
	nCantidadDeFiltrosClaveForaneaVisibles = 10
	
	cCursorAtributos = ""
	nIDCampoGuia = 0
	cRamaDePertenencia = ""
	lEstablecerBanda = .f.
	cBandaDominante = ""
	lAgregadoPorLTSA = .f.
	lIncluirAtributosFW = .t.	&& Las entidades base listan los atributos genéricos, las subentidades "NO"
	lExcluirFiltros = .f.
	ProveedorDeIDs = null

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		this.ProveedorDeIDs = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function init( tcCursorAtributos as String,;
				   toProveedorDeIDs as ProveedorDeIDDeItemListadosGenericos of ProveedorDeIDDeItemListadosGenericos.prg,;
				   tnCampoGuia as Integer, tcRamaDePertenencia as String, tlEstablecerBanda as Boolean, tcBandaDominante as String,;
				   tlAgregadoPorLTSA as Boolean, tlIncluirAtributosFW as Boolean, tlExcluirFiltros as Boolean )
		local lcCursor as String
		
		if upper( alltrim( this.Class ) ) == "CompletarAtributosListadosGenericos"
			return .f.
		endif
		
		lcCursor = tcCursorAtributos 
		if empty( lcCursor ) 
			lcCursor = "c_Listcampos" + sys( 2015 )
		endif
		if !used( lcCursor )
			select * from c_Listcampos where .f. into cursor &lcCursor readwrite
		endif
		this.cCursorAtributos = lcCursor 
		
		if ( vartype( toProveedorDeIDs ) == "O" ) and ( upper( alltrim( toProveedorDeIDs.Class ) ) == "PROVEEDORDEIDDEITEMLISTADOSGENERICOS" )
			this.ProveedorDeIDs = toProveedorDeIDs
		else
			this.ProveedorDeIDs = newobject( "ProveedorDeIDDeItemListadosGenericos", "ProveedorDeIDDeItemListadosGenericos.prg" )
		endif
		
		if vartype( tnCampoGuia ) == "N" 
			this.nIDCampoGuia = tnCampoGuia
		endif
		
		if vartype( tcRamaDePertenencia ) == "C"
			this.cRamaDePertenencia = tcRamaDePertenencia
		else
			this.cRamaDePertenencia = this.ObtenerRamaDePertenenciaIncorporandoElCampoGuia( this.nIDCampoGuia )
		endif
		 
		this.lEstablecerBanda = tlEstablecerBanda
		this.cBandaDominante = iif( !empty( tcBandaDominante ), tcBandaDominante, "" )
		
		this.lAgregadoPorLTSA = tlAgregadoPorLTSA
		if this.lAgregadoPorLTSA
			this.lIncluirAtributosFW = tlIncluirAtributosFW
			this.lExcluirFiltros = tlExcluirFiltros
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeAtributos( tcEntidad as String ) as String
		local lcCursor as String, lcEntidad as String
						
		lcEntidad = upper( alltrim( tcEntidad ) )
		lcCursor = "c_AtributosDe" + lcEntidad + sys( 2015 )
		
		select * from c_Diccionario ;
				where upper( alltrim( Entidad ) ) == lcEntidad ;
				order by ClavePrimaria desc,Grupo, Subgrupo, Orden ;
			into cursor ( lcCursor )
			
		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarElTagNoPersonalizaFiltroEnLasFuncionalidades( tcFuncionalidades as String ) as String
		local lcFuncionalidades as String
		
		lcFuncionalidades = upper( alltrim( tcFuncionalidades ) )
		
		if !( "<NOPERZONALIZAFILTRO>" $ lcFuncionalidades )
			lcFuncionalidades = "<NOPERZONALIZAFILTRO>;" + lcFuncionalidades
		endif
		
		return lcFuncionalidades
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAtributos( tcEntidad as String, tcIDListado as string ) as Void
		local lcCursorItems as String, lnIdClavePrimaria as Integer,;
			  loItemListable as ItemListable of ItemListable.prg,;
			  loItemDiccionario as ItemDiccionario of ItemDiccionario.prg,;
			  llDebeEstarEnElListado as Boolean, llEnlazaConOtraEntidad as Boolean,;
			  llEsAtributoGenerico as Boolean
			  
		loItemDiccionario = newobject( "ItemDiccionario", "ItemDiccionario.prg" )
		
		this.ProveedorDeIDs.Reiniciar( tcIDListado, this.cCursorAtributos )
		
		lcCursorItems = this.ObtenerCursorDeAtributos( tcEntidad )
		
		select( lcCursorItems )
		scan all 
			scatter name loItemDiccionario memo additive
			llEsAtributoGenerico = loItemDiccionario.EsAtributoGenerico()
			
			if !this.lIncluirAtributosFW and llEsAtributoGenerico
				&& Se excluye el atributo por ser genérico ( atributo de framework )
				loop
			endif
			
			llDebeEstarEnElListado = loItemDiccionario.SeDebeListarElAtributo()
			llEnlazaConOtraEntidad = .f.
			
			loItemListable = this.ObtenerItemListable( tcIDListado, loItemDiccionario )
			
			if !llDebeEstarEnElListado and loItemDiccionario.EsAtributoConClaveForanea()
				llDebeEstarEnElListado = ( ( loItemListable.id > 0 ) and loItemListable.listarTodosSusAtributos )
				llEnlazaConOtraEntidad = llDebeEstarEnElListado
			endif		
			
			if !llDebeEstarEnElListado
				&& No estará disponible en el listado
				loop
			endif

			if loItemListable.id == 0
				with loItemListable
					.Entidad 			= this.ReferenciaAEntidad( loItemDiccionario )
					.TipoDeEntidad 		= .ObtenerTipoDeEntidad()
					.id 				= this.ProveedorDeIDs.ProximoID( loItemDiccionario )
					.idFormato 			= tcIdListado
					.TipoFiltro 		= loItemDiccionario.ObtenerTipoDeFiltro()
					.Atributo 			= upper( alltrim( loItemDiccionario.Atributo ) )
					.Etiqueta 			= loItemDiccionario.ObtenerEtiqueta()
					.EtiquetaReporte 	= .Etiqueta
					.Orden				= this.ObtenerNumeroDeOrden( loItemListable, loItemDiccionario )
					.OrdenFiltro 		= .Orden
					.Ajustable 			= loItemDiccionario.EsAtributoAjustable()
					.Visible 			= loItemDiccionario.SeDebeVisibilizarElAtributo()
					.VisibleFiltro 		= loItemDiccionario.ObtenerVisibilidadDeUnFiltro( this.ProveedorDeIDs, this.nCantidadDeFiltrosClaveForaneaVisibles )
					
					.ClaveForanea		= loItemDiccionario.ClaveForanea
					.CampoGuia 			= this.nIDCampoGuia
					.RamaDePertenencia	= this.cRamaDePertenencia
					.LongitudReporte 	= 0

						if this.EsUnaExcepciónALaCantidadDeDecimales( loItemDiccionario )
							.DecimalesReporte = loItemDiccionario.Decimales
						else
							.DecimalesReporte 	= iif( loItemDiccionario.Decimales > 2, 2, loItemDiccionario.Decimales )							
						endif
	
					.Banda 				= this.ObtenerNombreBanda( loItemDiccionario.Entidad )
					.Expresion 			= loItemDiccionario.ObtenerExpresion()
					
					.EsAtributoGenerico = llEsAtributoGenerico
					.Funcionalidades 	= loItemDiccionario.ObtenerFuncionalidadDelAtributo( this.lAgregadoPorLTSA )
					.EstablecerParametrosParaLaGeneracion()

					if this.lExcluirFiltros or !empty( .Banda )
						.Funcionalidades = this.AgregarElTagNoPersonalizaFiltroEnLasFuncionalidades( .Funcionalidades )
					endif
				endwith
				
				if !loItemDiccionario.EsDominioDetalle()	&& No se agregan los item detalle
					if loItemDiccionario.Dominio = "IMAGENCONRUTADINAMICA"
						if loItemListable.Etiqueta = "Imagen"
							loItemListable.Etiqueta = "Archivo"
						endif
						if loItemListable.EtiquetaReporte = "Imagen"
							loItemListable.EtiquetaReporte = "Archivo"
						endif
					endif
					this.IngresarItemListable( loItemListable )
				endif
			endif
			
			if loItemDiccionario.Dominio = "IMAGENCONRUTADINAMICA"
				this.AgregarCampoImagen( loItemListable, loItemDiccionario )
			else			
				if loItemDiccionario.ClavePrimaria or llEnlazaConOtraEntidad 
					lnIdClavePrimaria = loItemListable.id
				endif
				
				this.AgregarAtributosDerivadosDelItem( loItemListable, loItemDiccionario, lnIdClavePrimaria )
			endif
			
			if inlist( upper( _screen.zoo.app.cProyecto ), "COLORYTALLE" )
				** si es COLOR o TALLE agregar el Orden de la Paleta Colores / Curva de Talles
				this.InsertarItemsCurvaTallesYPaletaColores( loItemListable , loItemDiccionario , tcIDListado )
			endif
		endscan
		
		use in select( lcCursorItems )
		
		loItemDiccionario = null
		loItemListable = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarCampoImagen( toItemListable as itemlistable of itemlistable.prg, toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Void
		local loNuevoItem as itemlistable of itemlistable.prg
		
		if this.NoSeAgregoLaImagen( toItemListable )		
			loNuevoItem = toItemListable.ObtenerCopia()
			
			with loNuevoItem as ItemListable of ItemListable.prg
				.id = this.ProveedorDeIDs.ProximoID( toItemDiccionario )
				.Orden = .id
				.OrdenFiltro = .id
				*ATENCION: al Identificador se le agregará el sufijo "_IMG", en este momento el identificador está vacio
				.EsImagen = .t.
				.Etiqueta = "Imagen"
				.EtiquetaReporte = .Etiqueta
				.Funcionalidades = this.AgregarElTagNoPersonalizaFiltroEnLasFuncionalidades( .Funcionalidades )
			endwith
			this.IngresarItemListable( loNuevoItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnaExcepciónALaCantidadDeDecimales( toItemDiccionario as objetc ) as Void
		llReturn = .f.

		* Func. 4919 se debe agregar 4 decimales a los Precios de los listados de Compras
		if "ITEMARTICULOS"$ upper( toItemDiccionario.entidad ) and "COMPRA" $ upper( toItemDiccionario.entidad ) and upper( alltrim( toItemDiccionario.Atributo )) = 'PRECIO'
			llReturn = .t.
		endif
		return llReturn 
	endfunc 


	*-----------------------------------------------------------------------------------------
	function InsertarItemsCurvaTallesYPaletaColores( toItemListable as Object , toItemDiccionario as Object , tcIDListado as String ) as Void
		
		** se agrega el Orden en la Paleta/Curva de Colores/Talle

		do case 
		case upper( alltrim( toItemDiccionario.Atributo ) ) = 'COLOR' and ! inlist( upper( alltrim( toItemDiccionario.entidad  ) ), "PALETADECOLORES", "ITEMCOLORES") ;
			and !inlist( upper( alltrim( toItemDiccionario.entidad ) ), "ITEMGESTIONINSUMO", "ITEMORDENINSUMO", "ITEMORDENCURVA", "ITEMMODELOINSUMO", "ITEMGESTIONINSDESC", "ITEMGESTIONDESCARTE", "ITEMGESTIONCURVA", "STOCKINVENTARIO" ) ;
			and !inlist( upper( alltrim( toItemDiccionario.entidad ) ), "ITEMCURVADEPRODUCCION", "ITEMORDENSALIDA" , "ITEMMODELOSALIDA", "ITEMMODCOSTOPROD")
			
			lcFuncion = "Funciones.ObtenerOrdenEnLaPaletaDeColores( #Articulo , #Color , #Articulo.Paletadecolores , #Articulo.Grupo )"
			
			if upper( alltrim( toItemDiccionario.entidad  ) ) = "ITEMDIMENSIONESECOM"
				if upper( alltrim( toItemListable.banda ) ) = ""
					lcFuncion = "Funciones.ObtenerOrdenEnLaPaletaDeColores( #Codigo , #Color , #Articulo.Paletadecolores , #Articulo.Grupo )"
				else
					lcFuncion = "Funciones.ObtenerOrdenEnLaPaletaDeColores( #Codigo , #Color , c_articulo_cabecera.PALCOL, c_articulo_cabecera.GRUPO )"
				endif
			endif
			
			with toItemListable
				.Entidad 			= this.ReferenciaAEntidad( toItemDiccionario )
				.TipoDeEntidad 		= .ObtenerTipoDeEntidad()
				.id 				= this.ProveedorDeIDs.ProximoID( toItemDiccionario )
				.idFormato 			= tcIdListado
				.TipoFiltro 		= toItemDiccionario.ObtenerTipoDeFiltro()
				.Atributo 			= "OrdenPaletaColores                      "
 				.Etiqueta 			= "Orden en la paleta de colores           "
				.EtiquetaReporte 	= ""
				.Orden				= .id
				.OrdenFiltro 		= .id
				.Ajustable 			= .f.
				.Visible 			= .t.
				.VisibleFiltro 		= .t.
				.tipodato		 	= "N"
				.longitud 			= 3
				.decimales       	= 0
				.Funcionalidades 	= ""
				.Expresion 			= lcFuncion
				.CampoGuia			= this.nIDCampoGuia
				.RamaDePertenencia	= this.cRamaDePertenencia
			endwith
			this.IngresarItemListable( toItemListable )		
				
		case upper( alltrim( toItemDiccionario.Atributo ) ) = 'TALLE' and ! inlist( upper( alltrim( toItemDiccionario.entidad  ) ), "CURVADETALLES", "ITEMTALLES" ) ;
			and !inlist( upper( alltrim( toItemDiccionario.entidad ) ), "ITEMGESTIONINSUMO", "ITEMORDENINSUMO", "ITEMORDENCURVA", "ITEMMODELOINSUMO", "ITEMGESTIONINSDESC", "ITEMGESTIONDESCARTE", "ITEMGESTIONCURVA", "STOCKINVENTARIO" );
			and !inlist( upper( alltrim( toItemDiccionario.entidad ) ), "ITEMCURVADEPRODUCCION", "ITEMORDENSALIDA", "ITEMMODELOSALIDA", "ITEMMODCOSTOPROD")

			lcFuncion = "Funciones.ObtenerOrdenEnLaCurvaDeTalle(  #Articulo , #Talle , #Articulo.Curvadetalles , #Articulo.Grupo )"
			
			if upper( alltrim( toItemDiccionario.entidad  ) ) = "ITEMDIMENSIONESECOM"
				if upper( alltrim( toItemListable.banda )) = ""
					lcFuncion = "Funciones.ObtenerOrdenEnLaCurvaDeTalle(  #Codigo , #Talle , #Articulo.Curvadetalles , #Articulo.Grupo )"
				else
					lcFuncion = "Funciones.ObtenerOrdenEnLaCurvaDeTalle(  #Codigo , #Talle , c_articulo_cabecera.CURTALL, c_articulo_cabecera.GRUPO )"
				endif
			endif
			
			with toItemListable
				.Entidad 			= this.ReferenciaAEntidad( toItemDiccionario )
				.TipoDeEntidad 		= .ObtenerTipoDeEntidad()
				.id 				= this.ProveedorDeIDs.ProximoID( toItemDiccionario )
				.idFormato 			= tcIdListado
				.TipoFiltro 		= toItemDiccionario.ObtenerTipoDeFiltro()
				.Atributo 			= "OrdenCurvaTalles                        "                      
 				.Etiqueta 			= "Orden en la curva de talles             "           
				.EtiquetaReporte 	= ""
				.Orden				= .id
				.OrdenFiltro 		= .id
				.Ajustable 			= .f.
				.Visible 			= .t.
				.VisibleFiltro 		= .t.
				.tipodato		 	= "N"
				.longitud 			= 3
				.decimales       	= 0
				.Funcionalidades 	= ""					
				.Expresion 			= lcFuncion
				.CampoGuia			= this.nIDCampoGuia
				.RamaDePertenencia	= this.cRamaDePertenencia
			endwith
			this.IngresarItemListable( toItemListable )			
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReferenciaAEntidad( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as String
		return upper( alltrim( toItemDiccionario.Entidad ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerRamaDePertenenciaIncorporandoElCampoGuia( tnIDCampoGuia as Integer ) as String
		local lcRamaDePertenencia as String
		
		if empty( tnIDCampoGuia )
			lcRamaDePertenencia = ""
		else
			lcRamaDePertenencia = this.cRamaDePertenencia
			lcRamaDePertenencia = lcRamaDePertenencia + ">>" + transform( tnIDCampoGuia )
		endif
		
		return lcRamaDePertenencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IngresarItemListable( toItem as ItemListable of ItemListable.prg ) as Void
		insert into ( this.cCursorAtributos ) ;
			( id, idformato, iddiccionario, entidad, TipoDeEntidad, atributo, etiqueta, esopcional, ClaveForanea, campoguia, atributoguia, aperturarango, adicionalcod, adicionallabel, ;
			orden, ordenfiltro, tipofiltro, quecontenga, calculo, tipodato, EsImagen, longitud, decimales, visible, visibleFiltro, expresion, grupofx, secgrupo, printwhen, grupovisual, ;
			agrupapor, banda, posicionrelativa, subtotaliza, mostrarceros, longitudreporte, decimalesreporte, etiquetareporte, ajustable, ;
			RamaDePertenencia, EsAtributoGenerico, ListarTodosSusAtributos, AgregadoPorLTSA, IncluirAtributosFW, excluirFiltros, funcionalidades ) ;
		Values ;
			( toItem.id, toItem.idformato, toItem.iddiccionario, toItem.entidad, toItem.TipoDeEntidad, toItem.atributo, toItem.etiqueta, ;
			toItem.esopcional, toItem.ClaveForanea, toItem.campoguia, toItem.atributoguia, toItem.aperturarango, toItem.adicionalcod, ;
			toItem.adicionallabel, toItem.orden, toItem.ordenfiltro, toItem.tipofiltro, toItem.quecontenga, ;
			toItem.calculo, toItem.tipodato, toItem.EsImagen, toItem.longitud, toItem.decimales, toItem.visible, toItem.VisibleFiltro, toItem.expresion, ;
			toItem.grupofx, toItem.secgrupo, toItem.printwhen, toItem.grupovisual,toItem.agrupapor, toItem.banda, ;
			toItem.posicionrelativa, toItem.subtotaliza, toItem.mostrarceros, toItem.longitudreporte, ;
			toItem.decimalesreporte, toItem.etiquetareporte, toItem.ajustable, toItem.RamaDePertenencia, toItem.EsAtributoGenerico, ;
			toItem.ListarTodosSusAtributos, this.lAgregadoPorLTSA, this.lIncluirAtributosFW, this.lExcluirFiltros, toItem.funcionalidades )			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributosDerivadosDelItem( toItemListable as ItemListable of ItemListable.prg,;
														 toItemDiccionario as ItemDiccionario of ItemDiccionario.prg,;
														 tnIDClavePrimaria as Integer ) as Void
		local lcEntidad as String, lcIDListado as string, lnIDCampoGuia as Integer, lcRamaDePertenencia as String, llEstablecerBanda as Boolean,;
			  lcBandaDominante as String, lcAgregaAtributos as String, loAgregaSubEntidad as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg,;
			  llListarTodosSusAtributos as Boolean, llAgregadoPorLTSA as Boolean, llIncluirAtributosFW as Boolean, llExcluirFiltros as Boolean
		
		if this.DebeCompletarLosAtributosDeDetalle( toItemDiccionario )
			lcEntidad = toItemDiccionario.ObtenerNombreEntidadDetalle()
			lnIDCampoGuia = tnIDClavePrimaria
			llEstablecerBanda = .t.
			lcBandaDominante = ""
			lcAgregaAtributos = "CompletarAtributosListadosGenericosParaUnItemDetalle"
		else
			if this.DebeCompletarLosAtributosDeLaSubEntidad( toItemListable, toItemDiccionario )
				lnIDCampoGuia = toItemListable.id
				lcEntidad = upper( alltrim( toItemDiccionario.ClaveForanea ) )
				
				llEstablecerBanda = !empty( toItemListable.Banda ) and ( left( upper( alltrim( toItemListable.Banda ) ), 7 ) == "DETALLE" )
	 			lcBandaDominante = iif( llEstablecerBanda, upper( alltrim( toItemListable.Banda ) ), "" )
	 			
	 			llAgregadoPorLTSA = .t. 	&& Si entró aquí es porque el ItemListable o la entidad referenciada
	 										&& en la clave foranea del ItemDiccionario tiene el tag <LISTARTODOSSUSATRIBUTOS>
	 			
	 			llIncluirAtributosFW = .f. 	&& Por las últimas definiciones esto queda duro, antes dependia de 
	 										&& toItemListable.IncluirAtributosFW que se resolvía según los TAGs de
	 										&& funcionalidad del ItemListable.
	 			
	 			llExcluirFiltros = toItemListable.excluirFiltros
	 			
				lcAgregaAtributos = "CompletarAtributosListadosGenericosParaUnaSubEntidad"
			else
				lcEntidad = ""
				lcAgregaAtributos = ""				
			endif
		endif
		
		if !empty( lcEntidad ) and !empty( lcAgregaAtributos )
			lcIDListado = upper( alltrim( toItemListable.idFormato ) )
			lcRamaDePertenencia = this.ObtenerRamaDePertenenciaIncorporandoElCampoGuia( lnIDCampoGuia )
			
			loAgregaSubEntidad = newobject( lcAgregaAtributos, "CompletarAtributosListadosGenericos.prg", "",;
											this.cCursorAtributos, this.ProveedorDeIDs, lnIDCAmpoGuia, lcRamaDePertenencia,;
											llEstablecerBanda, lcBandaDominante,;
											llAgregadoPorLTSA, llIncluirAtributosFW, llExcluirFiltros )
											
			loAgregaSubEntidad.AgregarAtributos( lcEntidad, lcIDListado )
			loAgregaSubEntidad = null
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeDetalle( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return !empty( toItemDiccionario.ObtenerNombreEntidadDetalle() )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeLaSubEntidad( toItemListable as ItemListable of ItemListable.prg,;
																toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		local llDebeCompletar as boolean, llEsClaveForanea as Boolean

		llEsClaveForanea = toItemDiccionario.EsAtributoConClaveForanea() 
		llDebeCompletar = ( llEsClaveForanea and toItemListable.listarTodosSusAtributos )
		
		if !llDebeCompletar and llEsClaveForanea
			local lcEntidad as String, lcAlias as String
			
			lcEntidad = upper( alltrim( toItemDiccionario.ClaveForanea ) )
			lcAlias = select()
			
			select c_Entidad
			locate for upper( alltrim( entidad ) ) == lcEntidad
			
			if found()
				llDebeCompletar = ( "LISTARTODOSSUSATRIBUTOS" $ upper( alltrim( c_Entidad.funcionalidades ) ) )
			endif
			
			select ( lcAlias )
		endif
		
		return llDebeCompletar 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroDeOrden( toItemListable as ItemListable of ItemListable.prg,;
											 toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Integer
		if toItemDiccionario.EsAtributoGenerico()
			return 998
		else
			return this.ProveedorDeIDs.CuentaDeIDsProvistos()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreBanda( tcEntidad as String ) as String
		local lcBanda as String
		
		if this.lEstablecerBanda
			if !empty( this.cBandaDominante )
				lcBanda = this.cBandaDominante 
			else
				lcBanda = "DETALLE" + upper( alltrim ( tcEntidad ) )
			endif
		else
			lcBanda = ""
		endif
		
		return lcBanda
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemListable( tcIDListado as String, toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as ItemListable of ItemListable.prg
		local loItemListable as ItemListable of ItemListable.prg, lcAlias as String,;
			  lcCursor as String, lcFuncionalidades as String
		
		lcAlias = select()
		
		loItemListable = newobject( "ItemListable", "ItemListable.prg"  )
		lcCursor = this.cCursorAtributos
		
		select( lcCursor )
		locate for upper( alltrim( &lcCursor..idformato ) ) == upper( alltrim( tcIDListado ) ) and ;
					goServicios.Librerias.EntidadPura( &lcCursor..entidad ) == upper( alltrim( toItemDiccionario.entidad ) ) and ;
					upper( alltrim( &lcCursor..atributo ) ) == upper( alltrim( toItemDiccionario.atributo ) )
					
		&& IMPORTANTE:
		&& Debiera considerar el CampoGuia en la busqueda puesto que si una entidad tiene dos o más referencias a la misma
		&& subEntidad solo incorpora los atributos de la primera referencia que encuentra.
					
		if found()
			scatter name loItemListable memo additive
			
			loItemListable.RamaDePertenencia = this.cRamaDePertenencia
			loItemListable.TipoDeEntidad = loItemListable.ObtenerTipoDeEntidad()
			loItemListable.EsAtributoGenerico = toItemDiccionario.EsAtributoGenerico()
			loItemListable.Claveforanea = toItemDiccionario.Claveforanea
			
			lcFuncionalidades = loItemListable.Funcionalidades + ";" + toItemDiccionario.ObtenerFuncionalidadDelAtributo( this.lAgregadoPorLTSA )
			lcFuncionalidades = toItemDiccionario.LimpiarTagsRepetidos( lcFuncionalidades )
			loItemListable.Funcionalidades = lcFuncionalidades 
			loItemListable.EstablecerParametrosParaLaGeneracion()
			
			replace RamaDePertenencia with loItemListable.RamaDePertenencia
			replace ListarTodosSusAtributos with loItemListable.ListarTodosSusAtributos
			replace TipoDeEntidad with loItemListable.TipoDeEntidad
			replace Claveforanea with loItemListable.Claveforanea
		endif
		
		select ( lcAlias )	
		
		return loItemListable
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function NoSeAgregoLaImagen( toItemListable as itemlistable of itemlistable.prg ) as Boolean
		local lcAlias as String, lcCursor as String, llNoSeEncontro as Boolean
		
		lcAlias = select()
		lcCursor = this.cCursorAtributos
		
		select( lcCursor )
		locate for upper( alltrim( &lcCursor..idformato ) ) == upper( alltrim( toItemListable.IDFormato ) ) and ;
					goServicios.Librerias.EntidadPura( &lcCursor..entidad ) == goServicios.Librerias.EntidadPura( toItemListable.Entidad ) and ;
					upper( alltrim( &lcCursor..atributo ) ) == upper( alltrim( toItemListable.Atributo ) ) and;
					&lcCursor..EsImagen
					
		llNoSeEncontro = !found()
		
		select ( lcAlias )	
		
		return llNoSeEncontro
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CursorAXML( tcNombreCursor ) as String
		Local lcRetorno as String
		
		cursortoxml(tcNombreCursor, "lcRetorno", 3, 4, 0, "1")
		
		return lcRetorno
	endfunc 
enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarAtributosListadosGenericosParaUnaEntidad as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg
	&& Redefinir los métodos aquí
enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarAtributosListadosGenericosParaUnItemDetalle as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeAtributos( tcEntidad as String ) as String
		local lcCursor as String, lcEntidad as String
						
		lcEntidad = upper( alltrim( tcEntidad ) )
		lcCursor = "c_AtributosDe" + lcEntidad + sys( 2015 )
		
		select * from c_Diccionario where upper( alltrim( Entidad ) ) == lcEntidad ;
		into cursor ( lcCursor )
			
		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeDetalle( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeLaSubEntidad( toItemListable as ItemListable of ItemListable.prg,;
																toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroDeOrden( toItemListable as ItemListable of ItemListable.prg,;
											 toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Integer
		if toItemDiccionario.EsAtributoGenerico()
			return 998
		else
			return 997
		endif
	endfunc 

enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarAtributosListadosGenericosParaUnaSubEntidad as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeAtributos( tcEntidad as String ) as String
		local lcCursor as String, lcEntidad as String
						
		lcCursor = "c_AtributosDe" + upper( alltrim( tcEntidad ) ) + sys( 2015 )
		
		lcEntidad = upper( alltrim( tcEntidad ) )
			
		select * from c_Diccionario ;
		where upper( alltrim( Entidad ) ) == lcEntidad ;
		  and !MuestraRelacion and !ClavePrimaria ;
		into cursor ( lcCursor )

		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeDetalle( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeLaSubEntidad( toItemListable as ItemListable of ItemListable.prg,;
																toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return !empty( toItemDiccionario.ClaveForanea ) and toItemListable.listarTodosSusAtributos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroDeOrden( toItemListable as ItemListable of ItemListable.prg,;
											 toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Integer
		if toItemDiccionario.EsAtributoGenerico()
			return 998
		else
			return 997
		endif
	endfunc 

enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarAtributosListadosGenericosParaCabeceraForzada as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg
	
	*-----------------------------------------------------------------------------------------
	protected function ReferenciaAEntidad( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as String
		return "Ent#" + upper( alltrim( toItemDiccionario.Entidad ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeCompletarLosAtributosDeDetalle( toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroDeOrden( toItemListable as ItemListable of ItemListable.prg,;
											 toItemDiccionario as ItemDiccionario of ItemDiccionario.prg ) as Integer
		if toItemDiccionario.EsAtributoGenerico()
			return 998
		else
			return toItemListable.id
		endif
	endfunc 

enddefine
