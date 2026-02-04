*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------      COMPLETA ADN DE LISTADOS GENERICOS      --------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarADNListadosGenericos as custom

	#if .f.
		local this as CompletarADNListadosGenericos of CompletarADNListadosGenericos.prg
	#endif
	
	protected oNodosListados, oListados
	protected oCompletaEntidad as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg
	
	nOrdenListadoGenerico = 0
	
	cCursorListados = ""
	cCursorAtributos = ""

	nVersion = 2
	nNodoPadre = 0
	cProyectoActivo = ""
	
	*-----------------------------------------------------------------------------------------
	function init( toListaDeNodos as Collection, toListados as Collection,;
				   tcCursorListados as String, tcCursorAtributos as String )
		local lcCursor as String
		
		if upper( alltrim( this.Class ) ) == "COMPLETARADNLISTADOSGENERICOS"
			return .f.
		endif
		
		if vartype( toListaDeNodos ) == "O" and toListaDeNodos.Class == "Collection"
			this.oNodosListados = toListaDeNodos
		else
			this.oNodosListados = newobject( "Collection" )
		endif
		
		if vartype( toListaDeNodos ) == "O" and toListaDeNodos.Class == "Collection"
			this.oListados = toListados
		else
			this.oListados = newobject( "Collection" )
		endif
		
		&& Cursor para los Listados
		lcCursor = tcCursorListados 
		if empty( lcCursor ) 
			lcCursor = "c_Listados" + sys( 2015 )
		endif
		if !used( lcCursor ) and used( "c_Listados" )
			select * from c_Listados where .f. into cursor &lcCursor readwrite
		endif
		this.cCursorListados = lcCursor 
		
		&& Cursor para los Atributos
		lcCursor = tcCursorAtributos 
		if empty( lcCursor ) 
			lcCursor = "c_Listcampos" + sys( 2015 )
		endif
		if !used( lcCursor ) and used( "c_Listcampos" )
			select * from c_Listcampos where .f. into cursor &lcCursor readwrite
		endif
		this.cCursorAtributos = lcCursor 
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		this.oNodosListados = null
		this.oListados = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CompletarADN( tlAgregarSoloCabeceraYNodos as Boolean ) as Void
		local lcCursor as String, lcEntPpal as String, lcItemDetalle as String,;
			  lcSufijo as String, lcDescripcion as String, lcModulos as String,;
			  lcFiltros as String, lcIDListado as string,;
			  lcXML as String, lcReferencia as String

		lcCursor = this.ObtenerCursorDeEntidadesACompletar()
		
		select( lcCursor )
		scan all 
			lcEntPpal = this.ObtenerEntidadPrincipal( lcCursor )
			lcItemDetalle = this.ObtenerItemDetalle( lcCursor )
			lcDescripcion = this.ObtenerDescripcion( lcCursor )
			lcModulos = this.ObtenerModulos( lcCursor )
			lcSufijo = this.ObtenerSufijo( lcCursor )
			
			lcIDListado = This.AgregarCabeceraDelListado( lcEntPpal, lcDescripcion, lcModulos, "", lcSufijo )
			if !tlAgregarSoloCabeceraYNodos  and !empty( lcIDListado )
				this.AgregarDetalleDelListado( lcEntPpal, lcIDListado, lcItemDetalle )
			endif
		endscan
		
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCabeceraDelListado( tcEntidad as String, tcDescripcion as String, tcModulos as String, tcFiltro as string, tcSufijo as String ) as String
		local lcEntidad as string, lcIDListado as string
		lcEntidad = upper( alltrim( tcEntidad ) )
		lcIDListado = this.ObtenerIDListadoGenerico( tcEntidad, tcSufijo )
				
		if this.ExcluidoPorTaspein( lcIDListado )
			return ""
		endif
				  		
		select( this.cCursorListados )
		locate for upper( alltrim( id ) ) == upper( lcIDListado )
		if !found()
			local lnNodoPadre as Integer, lcTags as String, ;
			  loItemOrdenamiento as ItemOrdenamiento of GeneradorDeAdnAdicionalListadosGenericos.prg,;
			  lcTitulo as String, loError as Exception, loItemSeteoListado AS ItemSeteoListadosGenericos of CompletarADNListadosGenericos.prg		
			  
			if this.oNodosListados.getKey( lcEntidad ) > 0
				loItemOrdenamiento = this.oNodosListados.Item( lcEntidad )
				lnNodoPadre = loItemOrdenamiento.nIdPadre
				*lnOrden = loItemOrdenamiento.nOrden
			else
				&& Entidad sin menú - va a Listados Genericos.
				lnNodoPadre = this.nNodoPadre		
				this.nOrdenListadoGenerico = this.nOrdenListadoGenerico + 1 	
				*lnOrden = this.nOrdenListadoGenerico
			endif	
		
			lcTitulo = this.ObtenerTituloDelListado( tcEntidad, tcDescripcion, tcSufijo )
			
			*** EL FILTRO LO AGREGA EL GeneradorDinamicoObjetoListado automaticamente ***
			loItemSeteoListado = this.ObtenerSeteoListadoGenerico( lcIDListado )
			
			lcTitulo = loItemSeteoListado.ObtenerTitulo( lcTitulo )
			lnNodoPadre = loItemSeteoListado.ObtenerNodo( lnNodoPadre )
			lcModulos = loItemSeteoListado.ObtenerModulos( alltrim( tcModulos ) )
			if !empty( tcSufijo )
				lcModulos = lcModulos + this.ObtenerModulosEntidadCabecera( tcEntidad )
			endif
			lcTags = loItemSeteoListado.ObtenerTags()
			
			
			insert into ( this.cCursorListados ) ( id, Titulo , Orden, idNodo, Version, modulos, tags ) values ;
						( lcIDListado, lcTitulo, 0, lnNodoPadre, this.nVersion, lcModulos, lcTags )
			
			loItemSeteoListado = null
			try
				this.oListados.add( lcIDListado, lcEntidad + tcSufijo )
			catch to loError
				loError.Message = loError.Message + ". Se repite una entidad al generar el listado, entidad: " + lcEntidad
				throw loError
			endtry					
		endif
			
		return lcIDListado
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulosEntidadCabecera( tcEntidad as String ) as String
		local lcCursor as String, lcRetorno as string
		lcCursor = "c_ModuloEnti" + sys(2015)
		select modulos from c_entidad where upper( alltrim( entidad ) ) == alltrim( upper( tcEntidad ) ) into cursor ( lcCursor )
		lcRetorno = upper( alltrim( &lcCursor..Modulos ) )
		use in select( lcCursor )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSeteoListadoGenerico( tcIdListado as String ) as ItemSeteoListadosGenericos of CompletarADNListadosGenericos.prg
		local loItem as ItemSeteoListadosGenericos of CompletarADNListadosGenericos.prg, lcCursor as string, lcValor as string, lcClave as string
		loItem = null
		lcCursor = "c_ObtenerSeteoListadoGenerico" + sys( 2015 )
		
		select * from C_seteoslistadosgenericos where upper( alltrim( idListado ) ) == tcIdListado into cursor ( lcCursor )
		select( lcCursor )
		loItem = newobject( "ItemSeteoListadosGenericos", "CompletarADNListadosGenericos.prg" )
		loItem.cProyectoActivo = this.cProyectoActivo
		scan 
			lcValor = alltrim( &lcCursor..valor )
			lcClave = upper( alltrim( &lcCursor..Clave ) )
			do case
				case lcClave == "TITULO"
					loItem.cTitulo = lcValor
					loItem.lAgregarAlTitulo = &lcCursor..Agregar
					loItem.lReemplazarTitulo = &lcCursor..Reemplazar
				case lcClave == "MODULOS"
					loItem.cModulos = lcValor
					loItem.lReemplazarModulos = &lcCursor..Reemplazar
				case lcClave == "IDNODO"
					loItem.nIdNodo = val( lcValor )
				case lcClave == "TAGS"
					loItem.cTags = lcValor
			endcase
		endscan
		use in select ( lcCursor )
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIDListadoGenerico( tcEntidad as String, tcSufijo as String ) as String
		&& En la tabla Listados el campo ID está definido con un ancho de 60 caracteres
		return left( "GENERICO_" + upper( alltrim( tcEntidad ) ) + upper( alltrim( tcSufijo ) ), 60 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EntidadDebeTenerPrefijoComprobanteEnTitulo( tcEntidadCabecera as String ) as Void
		local llAgregarPrefijo  as Boolean
		
		************  INLIST 1 ************
		llAgregarPrefijo  = !inlist( tcEntidadCabecera, "VENDEDOR", "PALETADECOLORES", "PROVEEDOR", "MONEDA",;
														"CURVADETALLES", "CLIENTE", "TRANSPORTISTA", "VALOR",;
														"NOMBREDEFANTASIA", "AGRUPAMIENTO", "GRUPOVALOR", "COMPROBANTEDECAJA",;
														"ITEMACCIONESAUTOMATICAS", "CIERREDELOTE", "ACCIONESAUTOMATICAS",;
														"COMPROBANTEDERETENCIONES", "COMPROBANTEDERETENCIONESSUSS",;
														"COMPROBANTEDERETENCIONESGANANCIAS" , "COMPROBANTEDERETENCIONESIVA" )
		
		if llAgregarPrefijo		
			************  INLIST 2 ************
			llAgregarPrefijo  = !inlist( tcEntidadCabecera, "CLIENTECHILE", "POS", "OPERADORADETARJETA", "REDONDEODEPRECIOS",;
															"FERIADO", "DATOSFISCALES", "IMPUESTO", "AGRUPAMIENTODEBUZONES",;
															"IMPRESIONDEETIQUETA", "SCRIPT", "MINIMOREPOSICION", "CALCULODEPRECIOS",;
															"CONDICIONDEPAGO", "MODIFICACIONPRECIOS", "CANJEDECUPONES" ) 											
		endif					
		llAgregarPrefijo  = llAgregarPrefijo AND this.TieneDetalles( alltrim( tcEntidadCabecera ) ) 
		return llAgregarPrefijo 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneDetalles( tcEntidadCabecera as String ) as Boolean
		local llRetorno as Boolean, lcEntidad as String, lcAlias as String
		
		lcAlias = select()
		lcEntidad = upper( alltrim( tcEntidadCabecera ) )
		
		select c_Diccionario
		locate for upper( alltrim( c_Diccionario.Entidad )) == lcEntidad;
				and left( upper( alltrim( c_Diccionario.Dominio ) ), 11 ) == "DETALLEITEM";
				and upper( alltrim( atributo ) ) != "AGRUPUBLIDETALLE" 
		llRetorno = found()
		
		select ( lcAlias )	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTituloDelListado( tcEntidad as String, tcDescripcion as string, tcSufijo as string) as String
		local lcRetorno as String, llEsListadoItem as Boolean, llAgregarPrefijo as Boolean

		llEsListadoItem = iif( empty( tcSufijo ), .f., .t. )
		llAgregarPrefijo = !llEsListadoItem AND this.EntidadDebeTenerPrefijoComprobanteEnTitulo( tcEntidad )

		lcRetorno = iif( llAgregarPrefijo, "Comprobantes " + tcDescripcion , tcDescripcion )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExcluidoPorTaspein( tcIDListado as String ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = .f.
		if pemstatus( _screen, "oListadosSeleccionadosParaLaGeneracionDesdeElTaspein", 5 ) ;
			and vartype( _Screen.oListadosSeleccionadosParaLaGeneracionDesdeElTaspein ) = "O"
			try
			 	&& En la tabla Listados el campo ID está definido con un ancho de 60 caracteres
				_Screen.oListadosSeleccionadosParaLaGeneracionDesdeElTaspein.Item[ left( upper( alltrim( tcIDListado ) ), 60 ) ]
			catch	
				llRetorno = .t.
			endtry
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionDeEntidad( tcDescripcionEntidad as String, tcDescripcionItem as string ) as String
		local lcRetorno as String

		lcRetorno = ""
		if empty( tcDescripcionItem )
			lcRetorno = alltrim( tcDescripcionEntidad )
		else
			lcRetorno = alltrim ( tcDescripcionEntidad ) + " - " + alltrim ( tcDescripcionItem )
		endif
		
		return left( lcRetorno, 200 )	&& esta función se utiliza desde una consulta, y el primer registro define el ancho => fuerza 200.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsUnaEntidadListable( tcEntidad as string ) as Boolean
		local llRetorno as Boolean, lcCursor as String,;
			  loItemDiccionario as ItemDiccionario of CompletarADNListadosGenericos.prg
				
		lcCursor = "c_AtributosDeLaEntidad" + sys( 2015 )
		
		llRetorno = .f.
		
		select * from c_diccionario where upper( alltrim( c_diccionario.entidad ) ) == upper( alltrim( tcEntidad ) )  ;
			into cursor ( lcCursor )
		
		loItemDiccionario = newobject( "ItemDiccionario", "ItemDiccionario.prg" )
		
		select( lcCursor )
		scan
			scatter name loItemDiccionario additive 
			if loItemDiccionario.SeDebeListarElAtributo() 		&&this.SeDebeListarElAtributo( loItemDiccionario )
				llRetorno = .t.
				exit
			endif
		endscan
		
		use in select( lcCursor )
		loItemDiccionario = null
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SeDebeListarElAtributo( toItemDiccionario as Object ) as Boolean
		local llRetorno as Boolean
		
		with toItemDiccionario
			llRetorno = ( .Alta or .ClavePrimaria or ( "<FORZARLISTARGENERICO>" $ upper( .Tags ) ) ) 
			llRetorno = llRetorno and !empty( .Campo )
			llRetorno = llRetorno and !( "<NOLISTAGENERICO>" $ upper( .Tags ) )
		endwith 
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeEntidadesACompletar( ) as String
		&& se implementa en la subclase
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPrincipal( tcCursor as String ) as String
		&& se implementa en la subclase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemDetalle( tcCursor as String ) as String
		&& se implementa en la subclase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcion( tcCursor as String ) as String
		&& se implementa en la subclase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulos( tcCursor as String ) as String
		&& se implementa en la subclase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSufijo( tcCursor as String ) as String
		&& se implementa en la subclase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleDelListado( tcEntidad as String, tcIDListado as string, tcEntidadItem as String ) as Void
		&& se implementa en la subclase
	endfunc 
	
enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarADNListadosGenericosDeEntidades as CompletarADNListadosGenericos of CompletarADNListadosGenericos.prg

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeEntidadesACompletar() as String
		local lcCursor as String
				
		lcCursor = "c_ListaDeEntidades" + sys( 2015 )
		
		select upper( alltrim( entidad ) ) as entidad, ;
				upper( alltrim( modulos ) ) as modulos, ;
				left( this.ObtenerDescripcionDeEntidad( Descripcion ) , 200 ) as descripcion ;
		from c_entidad ;
		where upper( Tipo ) == 'E' and !("ADT_" $ upper( alltrim( entidad ) ) ) and ;
			!("<NOLISTAGENERICO>" $ upper( alltrim( funcionalidades ) ) ) and ;
			this.EsUnaEntidadListable( upper( alltrim( entidad ) ) ) ;
		into cursor ( lcCursor )
		
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPrincipal( tcCursor as String ) as String
		return &tcCursor..Entidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemDetalle( tcCursor as String ) as String
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcion( tcCursor as String ) as String
		return &tcCursor..Descripcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulos( tcCursor as String ) as String
		return &tcCursor..modulos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSufijo( tcCursor as String ) as String
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleDelListado( tcEntidad as String, tcIDListado as string, tcEntidadItem as String ) as Void
		if vartype( this.oCompletarEntidad ) != "O"
			this.oCompletaEntidad = newobject( "CompletarAtributosListadosGenericosParaUnaEntidad", "CompletarAtributosListadosGenericos.prg", "",;
												this.cCursorAtributos )
		endif
		 
		this.oCompletaEntidad.AgregarAtributos( tcEntidad, tcIDListado )
	endfunc 
enddefine

*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class CompletarADNListadosGenericosDeEntidadesTipoItem as CompletarADNListadosGenericos of CompletarADNListadosGenericos.prg
	
	protected oCompletaCabecera as CompletarAtributosListadosGenericos of CompletarAtributosListadosGenericos.prg
	
	*-----------------------------------------------------------------------------------------
	protected function CantidadDeListadosDelTipoItemQueTieneLaEntidad( tcCursor as string, tcEntidadCabecera as String ) as Integer
		local lnCantidad as Integer, lcAlias as String, lnRecno as Integer
		
		lcAlias = select()
		lnRecno = recno() 
		try
			select ( tcCursor )
			count for upper( alltrim( &tcCursor..EntidadCabecera )) == upper( alltrim( tcEntidadCabecera ) ) to lnCantidad
		finally		
			select ( lcAlias )	
			go ( lnRecno )
		endtry
		
		return lnCantidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorDeEntidadesACompletar( ) as String
		local lcCursor as String, llAgregarEtiquetaAtributo as Boolean, lcEtiquetaAtributo as string
						
		lcCursor = "c_ItemsDetalleConListadoGenerico" + sys( 2015 )
			
		select upper( alltrim( e.entidad ) ) as itemDetalle, ;
				upper( alltrim( d.entidad ) ) as entidadCabecera, ;
				upper( alltrim( e.modulos ) ) as modulos, ;
				left( alltrim( p.descripcion ), 200 ) as Descripcion,  ;
				upper( alltrim ( d.Etiqueta ) ) as EtiquetaDiccionario, ;
				alltrim ( d.Etiqueta ) as EtiquetaDiccionarioSinUpper ;
		from c_Entidad e ;
				inner join c_Diccionario d on "DETALLE" + upper( alltrim( e.entidad ) ) == upper( alltrim( d.dominio ) ) ;
				left join c_Entidad p on upper( alltrim( p.entidad ) ) == upper( alltrim( d.entidad ) ) ;
			where upper( e.Tipo ) == 'I' and ;
				( ( !("<NOLISTAGENERICO>" $ upper( e.funcionalidades ) ) and !("<NOLISTAGENERICO>" $ upper( p.funcionalidades ) ) ) or ;
				( "<FORZARLISTARGENERICO>" $ upper( e.funcionalidades ) ) ) and ;
				this.EsUnaEntidadListable( upper( alltrim( e.entidad ) ) ) ; 
			group by e.entidad, d.entidad, e.descripcion ; 
			order by e.entidad, d.entidad, e.descripcion ;
		into cursor ( lcCursor ) readwrite
		
		select ( lcCursor )
		
		scan
			llAgregarEtiquetaAtributo = !this.EntidadDebeTenerPrefijoComprobanteEnTitulo( &lcCursor..entidadCabecera )

			&& Se evalua si existe más de un listado tipo item de la misma entidad padre.
			llAgregarEtiquetaAtributo = llAgregarEtiquetaAtributo or ( this.CantidadDeListadosDelTipoItemQueTieneLaEntidad( lcCursor, &lcCursor..entidadCabecera ) >= 2 )
			
			if llAgregarEtiquetaAtributo
				lcEtiquetaAtributo = alltrim( &lcCursor..EtiquetaDiccionarioSinUpper )
			else
				lcEtiquetaAtributo = ""
			endif
			
			replace Descripcion with left( this.ObtenerDescripcionDeEntidad( &lcCursor..Descripcion, lcEtiquetaAtributo ), 200 ) 
		endscan
			
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerEntidadPrincipal( tcCursor as String ) as String
		return &tcCursor..EntidadCabecera
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemDetalle( tcCursor as String ) as String
		return &tcCursor..ItemDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcion( tcCursor as String ) as String
		return &tcCursor..Descripcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModulos( tcCursor as String ) as String
		return &tcCursor..modulos
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSufijo( tcCursor as String ) as String
		return "_" + &tcCursor..ItemDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarDetalleDelListado( tcEntidad as String, tcIDListado as string, tcEntidadItem as String ) as Void
		if vartype( this.oCompletarEntidad ) != "O"
			this.oCompletaEntidad = newobject( "CompletarAtributosListadosGenericosParaUnaEntidad", "CompletarAtributosListadosGenericos.prg", "",;
												this.cCursorAtributos )
		endif
		 
		this.oCompletaEntidad.AgregarAtributos( tcEntidadItem, tcIDListado )
		
		if vartype( this.oCompletaCabecera ) != "O"
			this.oCompletaCabecera = newobject( "CompletarAtributosListadosGenericosParaCabeceraForzada", "CompletarAtributosListadosGenericos.prg", "",;
												this.cCursorAtributos, this.oCompletaEntidad.ProveedorDeIDs, 1 )
		endif
		this.oCompletaCabecera.AgregarAtributos( tcEntidad, tcIDListado )
	endfunc 
enddefine


*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------
define class ItemSeteoListadosGenericos as Custom

	cIdListado = ""
	
	&& Titulo
	cTitulo = ""
	lReemplazarTitulo = .f.
	lAgregarAlTitulo = .f.

	&& Módulos 
	cModulos = ""
	lReemplazarModulos = .f.

	&& Nodo padre - Carpeta
	nIdNodo = 0
	cProyectoActivo = ""
	cTags = ""
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTitulo( tcTitulo as String ) as string 
		local lcRetorno as string
		lcRetorno = alltrim( tcTitulo )
		if !empty( this.cTitulo )
			if this.lReemplazarTitulo
				lcRetorno = this.cTitulo
			else
				if this.lAgregarAlTitulo 
					lcRetorno = lcRetorno + this.cTitulo
				else
					lcRetorno = this.cTitulo + lcRetorno
				endif
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNodo( tnNodoPadre ) as Integer
		local lnRetorno as string
		if this.nIdNodo == 0
			lnRetorno = tnNodoPadre
		else
			lnRetorno = this.nIdNodo
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerModulos( tcModulos as string ) as String 
		local lcRetorno as String
		
		lcRetorno = alltrim( tcModulos )
		if !empty( this.cModulos )
			if this.lReemplazarModulos
				lcRetorno = this.cModulos
			else
				lcRetorno = lcRetorno + this.cModulos
			endif
		endif
		&& Se suma el módulo LISTADOS => Q a todos.
		lcRetorno = upper( lcRetorno )
		do case
			case this.cProyectoActivo == "COLORYTALLE"
				lcModulosListadosBase = "Q"
			case this.cProyectoActivo == "NIKE"
				lcModulosListadosBase = "B"
			otherwise
				lcModulosListadosBase = ""
		endcase
		
		if not ( lcModulosListadosBase $ lcRetorno )
			lcRetorno = lcModulosListadosBase + lcRetorno
		endif
		return lcRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerTags() as String
		return this.cTags
	endfunc 

enddefine
