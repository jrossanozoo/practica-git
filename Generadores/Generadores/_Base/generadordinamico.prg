define class GeneradorDinamico as Generador of Generador.prg

	#IF .f.
		Local this as GeneradorDinamico of GeneradorDinamico.prg
	#ENDIF

	protected cNumeroDeVersion
	cPath = "Generados\"
	cTabla	= ""
	cAtributoClavePrimaria = ""
	cCampoClavePrimaria = ""
	cAtributoMuestraRelacion = ""
	cTipoDatoClavePrimaria = ""
	cPrefijoAuditoria = "ADT_"
	cXmlCamposAuditoriaEntidad = ""
	cXmlCamposAuditoriaDetalle = ""
	nIdPadreAuditoria = 0
	nOrdenListadoAuditoria = 1
	cEsquema = ""
	oEstructura = null
	cNumeroDeVersion = ""
	
	oFunc = null
	oAdnAD = null
	oCacheFunc = null
	oColaboradorAgrupados = null
	oCamposCombinacion = null
	
	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String ) as Void
		dodefault( tcRuta )

		this.oFunc = newobject( "funcionalidades", "funcionalidades.prg" )

		this.oAdnAD = newobject( "AccesoDatosADN", "AccesoDatosADN.prg" )
		this.DataSessionId = this.oAdnAD.DataSessionId

		this.oCacheFunc = newobject( "CacheFunciones", "CacheFunciones.prg" )

		with this
			.cPrefijoAuditoria = .oAdnAD.cPrefijoAuditoria 
			.cXmlCamposAuditoriaEntidad = .oAdnAD.cXmlCamposAuditoriaEntidad 
			.cXmlCamposAuditoriaDetalle = .oAdnAD.cXmlCamposAuditoriaDetalle 
		endwith
		
		this.InstanciarEstructura()
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarCache() as Void
		this.oCacheFunc.Limpiar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InstanciarEstructura() as Void
		if _screen.zoo.app.TipoDeBase = "NATIVA"
			this.oEstructura = this.oAdnAD.oEstructuraNativa
		else
			this.oEstructura = this.oAdnAD.oEstructuraSqlServer
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.lDestroy = .t.
		
		this.oEstructura = null

		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oEstructura = null

		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEntidadesAuditoria() as String
		local lcCursor as String , lcXml as String 
		
		lcCursor = sys( 2015 ) + "_EntiAuditoria"
		
		try
			select Entidad from c_entidad ;
					where upper( tipo ) == "E" and this.oFunc.TieneFuncionalidad( "AUDITORIA" , Funcionalidades ) ;
				into cursor &lcCursor

			lcXml = this.cursoraxml( lcCursor )	
		finally
			use in select( lcCursor )
		endtry
		
		return lcXml
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		with this
			.cArchivo = .cPath + "Din_" + alltrim( Proper( .cTipo ) )+ .cPrefijo + .cSufijo +".prg"
		endwith
	endfunc 
				
	*-----------------------------------------------------------------------------------------
	function EsComprobante() as Boolean
		return !empty( this.oAdnAD.ObtenerValorCampo( "Comprobantes", "Descripcion", "Descripcion", upper( this.cTipo ) ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsDetalle( tcEntidad as String ) as Boolean
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		return !empty( this.oAdnAD.ObtenerValorCampo( "Dominio", "Dominio", "Dominio", "DETALLE" + upper( alltrim( tcEntidad ) ) ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCampoClavePrimaria( tcEntidad as String ) as string
		local lcSql As String, lcCampoClavePrimaria As String

		store "" to lcCampoClavePrimaria, lcSql

		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		lcCampoClavePrimaria = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "ObtenerCampoClavePrimaria", upper( alltrim( tcEntidad ) ) )
		if isnull( lcCampoClavePrimaria )
			lcCampoClavePrimaria = ""
			
			try
				lcSql = "select Campo from c_Diccionario where Alltrim( upper( Entidad ) ) == '" + ;
						alltrim( upper( tcEntidad ) ) + "'" + ;
							" and !empty( atributo ) " + ;
							" and !empty( Entidad ) " + ;
							" and ClavePrimaria " + ;
						" into cursor c_ClavePrimaria "
				
				&lcSql
					
				select c_ClavePrimaria
				scan
					lcCampoClavePrimaria = lcCampoClavePrimaria + "+" + alltrim( c_ClavePrimaria.Campo )
				endscan

				lcCampoClavePrimaria = substr( lcCampoClavePrimaria, 2 )
			finally
				use in select ( "c_ClavePrimaria" )
			endtry

			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "ObtenerCampoClavePrimaria", upper( alltrim( tcEntidad ) ), lcCampoClavePrimaria )
		endif

		return lcCampoClavePrimaria
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoDatoClavePrimaria( tcEntidad as String ) as string
		local lcSql As String, lcTipoDatoClavePrimaria As String

		store "" to lcTipoDatoClavePrimaria, lcSql

		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		lcTipoDatoClavePrimaria = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "ObtenerTipoDatoClavePrimaria", upper( alltrim( tcEntidad ) ) )
		if isnull( lcTipoDatoClavePrimaria )
			lcTipoDatoClavePrimaria = ""
			
			try
				lcSql = "select TipoDato from c_Diccionario where Alltrim( upper( Entidad ) ) == '" + ;
						alltrim( upper( tcEntidad ) ) + "'" + ;
							" and !empty( atributo ) " + ;
							" and !empty( Entidad ) " + ;
							" and ClavePrimaria " + ;
						" into cursor c_TipoDato "
				
				&lcSql
					
				select c_TipoDato
				scan
					lcTipoDatoClavePrimaria = lcTipoDatoClavePrimaria + "+" + alltrim( c_TipoDato.TipoDato )
				endscan

				lcTipoDatoClavePrimaria = substr( lcTipoDatoClavePrimaria, 2 )
			finally
				use in select( "c_TipoDato" )
			endtry

			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "ObtenerTipoDatoClavePrimaria", upper( alltrim( tcEntidad ) ), lcTipoDatoClavePrimaria )
		endif
				
		return lcTipoDatoClavePrimaria
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFiltro( tcEntidad as String ) as string
		local lcRetorno as String, lcSql as string, lcAux as string
		
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif
		lcRetorno = " !empty( " + This.ObtenerCampoClavePrimaria( tcEntidad ) + " )"
		
		lcAux = alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Filtro", "Entidad", upper( alltrim( tcEntidad ) ) ) )
		
		if !empty( lcAux )
			lcRetorno = lcRetorno + " .And. " + lcAux 
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarTablaFiltro( lcAux as String ) as String
		local lcRetorno as String, lnPosicion as Integer
		
		lnPosicion = at( " ", alltrim( lcAux ) )
		if lnPosicion > 0
			if at( ".", substr( alltrim( lcAux ), 1, lnPosicion -1 ) ) > 0 or at( "(", substr( alltrim( lcAux ), 1, lnPosicion -1 ) ) > 0
				lcRetorno = alltrim( lcAux )
			else
				lcRetorno = This.cTabla + "." + alltrim( lcAux )
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTabla( tcEntidad as String ) as String
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif
		
		return alltrim( upper( this.oAdnAD.ObtenerValorCampo( "diccionario", "Tabla", "Entidad,ClavePrimaria", upper( alltrim( tcEntidad ) ) + ",.t." ) ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEsquema( tcTabla as String ) String
		local lcRetorno as string
		
		lcRetorno = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "ObtenerEsquema", upper( alltrim( tcTabla ) ) )
		if isnull( lcRetorno )
			lcRetorno = this.oEstructura.ObtenerEsquema( tcTabla )
			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "ObtenerEsquema", upper( alltrim( tcTabla ) ), lcRetorno )
		endif
		
		return lcRetorno 
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function ObtenerVersion( tcEntidad as String ) as integer
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		return this.oAdnAD.ObtenerValorCampo( "diccionario", "Version", "Entidad", upper( alltrim( tcEntidad ) ) ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoClavePrimaria( tcEntidad as String ) as string
		local lcSql As String, lcAtributoClavePrimaria As String

		store "" to lcAtributoClavePrimaria, lcSql

		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		lcAtributoClavePrimaria = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "ObtenerAtributoClavePrimaria", upper( alltrim( tcEntidad ) ) )
		if isnull( lcAtributoClavePrimaria )
			lcAtributoClavePrimaria = ""
			
			try
				lcsql = "select Atributo from c_Diccionario " + ;
					" where Alltrim( upper( Entidad ) ) == '" + alltrim( upper( tcEntidad ) ) + "'" + ;
						" and !empty( atributo ) " + ;
						" and !empty( Entidad ) " + ;
						" and ClavePrimaria " + ;
					" into cursor c_Atributo "
				
				&lcSql
					
				select c_Atributo
				scan
					lcAtributoClavePrimaria = lcAtributoClavePrimaria + "+" + alltrim( c_Atributo.Atributo )
				endscan

				lcAtributoClavePrimaria = upper( alltrim( substr( lcAtributoClavePrimaria, 2 ) ) )
			finally
				use in select( "c_Atributo" )
			endtry

			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "ObtenerAtributoClavePrimaria", upper( alltrim( tcEntidad ) ), lcAtributoClavePrimaria )
		endif
		
		return lcAtributoClavePrimaria
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoMuestraRelacion( tcEntidad as String ) as string
		return alltrim( upper( this.oAdnAD.ObtenerValorCampo( "diccionario", "Atributo", "Entidad,muestrarelacion", upper( alltrim( tcEntidad ) ) + ",.t." ) ) ) 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosClavePrimaria() as Void
		This.cAtributoClavePrimaria = This.ObtenerAtributoClavePrimaria()
		This.cCampoClavePrimaria = This.ObtenerCampoClavePrimaria()
		this.cTipoDatoClavePrimaria = this.ObtenerTipoDatoClavePrimaria()
		
		if empty( This.cAtributoClavePrimaria )
			local loEx as Exception

			loEx = Newobject(  "ZooException", "ZooException.prg" )
			With loEx

				.Details = "No se encontró el atributo clave primaria de la entidad "+ ;
							alltrim(this.cTipo)+"."+ chr(13) + "Verifique el diccionario."
				.Grabar()
				.Throw()
			endwith 
		endif
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarEstructura( tcEntidades as string ) as void
		with this
			 .AgregarLinea( "text to .cEstructura noshow ", 3)
			 .AgregarLinea( .ObtenerEstructuraEntidadXml( tcEntidades ) )
			 .AgregarLinea( "Endtext", 3 )
			 .AgregarLinea( "" )
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEstructuraDetalle( tcEntidades as string ) as void
		local lcResultado as String

		lcResultado = this.ObtenerEstructuraDetalleXml( tcEntidades )
		if len(lcResultado)>0
			with this
				 .AgregarLinea( "text to .cEstructuraDetalle noshow ", 3)
				 .AgregarLinea( .ObtenerEstructuraDetalleXml( tcEntidades ) )
				 .AgregarLinea( "Endtext", 3 )
				 .AgregarLinea( "" )
			endwith 
		endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function AgregarBindeosZooSession( tcString as String, tnTab as Integer ) as Void
	
		with This
			.AgregarLinea( "this.enlazar( '" + tcString + ".EventoObtenerLogueo', 'inyectarLogueo' )", tnTab )
			.AgregarLinea( "this.enlazar( '" + tcString + ".EventoObtenerInformacion', 'inyectarInformacion' )", tnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstructuraEntidadXml( tcEntidades as string ) as String
		return This.ObtenerEstructuraXml( tcEntidades )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstructuraXml( tcEntidades as string ) as String
		local lcSql as string, lcXml as string, lcNombreCursor as string, lcAnsi As String, lnInd as Integer
		lcAnsi = set( "Ansi" )
		set ansi on
		
		if empty( tcEntidades )
			tcEntidades = "'" + this.cTipo + "'"
		endif

		try
			lcsql = "select dic.Entidad,dic.Atributo, dic.Tabla, dic.Campo, dic.ClavePrimaria, dic.MuestraRelacion, " + ;
				" alltrim(dic.dominio)=='CLASE' as PermiteModificar, " + ;
				" !empty(Dic.ClaveForanea) as EsEntidad, " + ;
				" Dic.ClaveForanea, " + ;
				" iif(empty(Dic.TipoDato), dom.TipoDato, Dic.TipoDato) as tipoDato," + ;
				" iif(empty(Dic.Longitud), dom.Longitud, Dic.Longitud) as Longitud ," + ;
				" iif(empty(Dic.Decimales), Dom.Decimales, Dic.Decimales) as Decimales," + ;
				" Dic.ValorSugerido, " + ;
				" Dic.Obligatorio, " + ;
				" cast(Dic.AdmiteBusqueda as N(3)) as AdmiteBusqueda, " + ;
				" iif( !empty(Dic.EtiquetaAutodescriptiva), Dic.EtiquetaAutodescriptiva, Dic.Etiqueta) as Etiqueta, " + ;
				" Dom.dominio ," + ;
				" Dom.Detalle ," + ;
				" Ent.Tipo," + ;
				" Dic.AtributoForaneo," + ;
				" Dic.ClaveCandidata," + ;
				" Dic.Mascara," + ;
				" '' as oFuncionalidad, "+ ;
				" space(254) as relaciones, "+ ;
				" Dic.FiltroBuscador ," + ;
				" Dic.Grupo ," + ;
				" Dic.SubGrupo ," + ;
				" Dic.Orden , " + ;
				" Dic.Alta, " + ;
				" iif( This.oFunc.TieneFuncionalidad( 'INCLUIRENBUSCADOR' , alltrim( upper( Dic.Tags ) ) ), .T., .F.) as IncluirAtrib, " + ;
				" iif( This.oFunc.TieneFuncionalidad( 'EXCLUIRDELBUSCADOR' , alltrim( upper( Dic.Tags ) ) ) or left(alltrim(upper(Dom.Dominio)),7) = 'DETALLE', .T., .F.) as ExcluirAtrib, " + ;				
				" iif( This.oFunc.TieneFuncionalidad( 'ADMITEBUSQUEDASUBENTIDAD', alltrim( upper( Dic.Tags ) ) ), .T., .F.) as IncluirBusSubEnt, " + ;
				" .F. as UtilizaMismaRelacion " + ;
				" from c_Diccionario Dic, c_Dominio Dom, c_entidad ent " + ;
				" where rtrim(upper(Dic.Entidad)) in ( " + upper( tcEntidades ) + ") " + ;
				" and rtrim(upper(ent.Entidad)) == rtrim(upper(Dic.Entidad)) " + ;
				" and !empty(dic.atributo) " + ;
				" and !empty(dic.Entidad)" + ;
				" and rtrim(upper(dic.dominio)) == rtrim(upper(dom.dominio)) " + ;
				" order by Dic.Orden " + ;
				" into cursor c_EstrucXml ReadWrite"

				&lcSql  
			set ansi &lcAnsi
			lnInd = 200
			scan for AdmiteBusqueda = 0 and Alta
				replace AdmiteBusqueda with lnInd in c_EstrucXML
				lnInd = lnInd + 1 
			endscan

			Replace all Atributo with upper( Atributo ), ;
						Tabla with iif(empty(tabla) and !empty(atributoforaneo),this.obtenerTablaAsociada(atributoforaneo),upper( Tabla )), ;
						Relaciones with iif(!empty(atributoforaneo) and empty(campo),this.ObtenerRelaciones(atributoforaneo),''),;
						Campo with iif(empty(campo) and !empty(atributoforaneo),THIS.obtenerCampoAsociado(atributoforaneo),upper( Campo )) ;
						 in c_EstrucXML
			
			lcXml = this.CursorAXml("c_EstrucXml")
		finally
			use in select( "c_EstrucXml" )
		endtry
		
		return lcXml
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTablaAsociada( tcAtributo as String ) as string 
		local lnCAnt as Integer , i as Integer , lcEntidad as String , lcatributo as String , lcRetorno as String , lcTablaAux as string

		lnCant = occurs( ".", tcatributo )
		lcEntidad = upper( alltrim( c_EstrucXml.entidad ) )
		lcAtributo = getwordnum( tcatributo, 1, '.' )
		
		for i = 1 to lncant

			lcEntidad = upper( alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "claveforanea", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) ) ) )
				
			lcTablaAux  = this.oAdnAD.ObtenerValorCampo( "diccionario", "tabla", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) )

			if i = lncant
				lcTablaAux  = this.oAdnAD.ObtenerValorCampo( "diccionario", "tabla", "Entidad,Atributo", ;
					lcEntidad + "," + upper( alltrim( substr( tcatributo, rat( ".", tcAtributo ) + 1 ) ) ) )
			else
				lcAtributo = getwordnum( tcAtributo, i + 1, '.' )		
			endif
		endfor

		lcRetorno = upper( alltrim( lcTablaAux ) )

		select c_EstrucXML

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRelaciones( tcAtributo as String ) as string 
		local lnCAnt as Integer , i as Integer , lcEntidad as String , lcatributo as String , lcRetorno as String, ;
			lcTabla as String, lcCampo as string, llRelacionVacia as Logical
		lnCant = occurs( ".", tcatributo )
		lcEntidad = upper( alltrim( c_EstrucXml.entidad ) )
		lcAtributo = getwordnum( tcatributo, 1, '.' )
		llRelacionVacia = .F.
		if empty( alltrim( c_EstrucXml.campo )  ) 
			try
				select tabla,campo from c_EstrucXml ;
					where upper( alltrim( atributo ) ) = upper( alltrim( lcAtributo ) ) ;
				into cursor c_campos
				lcRetorno = alltrim( c_campos.Tabla ) + "." + alltrim( c_campos.campo ) + " = "
				if lcRetorno=". ="
					llRelacionVacia =.T. 
				endif
			finally
				use in select( "c_campos" )
			endtry
			
			select c_EstrucXml
		else 
			lcRetorno = alltrim( c_EstrucXml.Tabla ) + "." + alltrim( c_EstrucXml.campo ) + " = "
		endif
		
		for i = 1 to lncant
			lcEntidad = upper( alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "claveforanea", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) ) ) )

			lcTabla = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Tabla", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) ) )
				
			lcCampo = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Campo", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) ) )

			if i = lncant
				lcTabla  = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Tabla", "Entidad,ClavePrimaria", ;
					lcEntidad + ",.T." ) )
					
				lcCampo = alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Campo", "Entidad,ClavePrimaria", ;
					lcEntidad + ",.T." ) )

				lcRetorno = " left join " + lcTabla  + " on " + lcRetorno + ;
							lcTabla  + "." + lcCampo 
			else
				lcRetorno = lcRetorno + lcTabla  + "." + lcCampo + " and " + lcTabla  + "." + lcCampo + " = "

				lcAtributo = getwordnum( tcAtributo, i + 1, '.' )
			endif
		endfor

		select c_EstrucXML
		
		if llRelacionVacia
			lcRetorno = ''
		endif
		
		return lcRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerCampoAsociado( tcAtributo as String ) as Void
		local lnCAnt as Integer , i as Integer , lcEntidad as String , lcatributo as String , lcRetorno as String, lcCampoAux as string

		lnCant = occurs( ".", tcatributo )
		lcEntidad = upper( alltrim( c_EstrucXml.entidad ) )
		lcAtributo = getwordnum( tcatributo, 1, '.' )

		for i = 1 to lncant
			lcEntidad = upper( alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "claveforanea", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) ) ) )

			lcCampoAux = this.oAdnAD.ObtenerValorCampo( "diccionario", "campo", "Entidad,Atributo", ;
				lcEntidad + "," + upper( alltrim( lcAtributo ) ) )

			if i = lncant
				lcCampoAux = this.oAdnAD.ObtenerValorCampo( "diccionario", "campo", "Entidad,Atributo", ;
					lcEntidad + "," + upper( alltrim( substr( tcatributo, rat( ".", tcAtributo ) + 1 ) ) ) )
			else
				lcAtributo = getwordnum( tcAtributo, i + 1, '.' )
			endif
		endfor

		lcRetorno = upper( alltrim( lcCampoAux ) )

		select c_EstrucXML	

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcion( tcEntidad as String ) as string
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		return alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Descripcion", "Entidad", upper( alltrim( tcEntidad ) ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIdentificador( tcEntidad as String ) as string
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		return alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Identificador", "Entidad", upper( alltrim( tcEntidad ) ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarComportamiento( tcComportamiento as string, tcEntidad as String ) as boolean
		local llRetorno as boolean, lcSql as string
		
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		llRetorno = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "VerificarComportamiento", tcComportamiento + "," + alltrim( tcEntidad ) )
		if isnull( llRetorno )
			llRetorno = .f.
			
			try
				select Ent.Entidad, Ent.Comportamiento from c_entidad Ent ;
						where	upper( alltrim( tcComportamiento ) ) $ upper( alltrim( Ent.Comportamiento ) ) and ;
								Alltrim( upper( Ent.Entidad ) ) == alltrim( upper( tcEntidad ) ) ;
					into cursor c_EntidadesGuid

				llRetorno = ( _Tally > 0 )
			finally
				use in select ( "c_EntidadesGuid" )
			endtry

			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "VerificarComportamiento", tcComportamiento + "," + alltrim( tcEntidad ), llRetorno  )
		endif

		return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlTransferenciasCentralizadas() as Void
		local lcCursor as String , lcXml as String 
		
		lcCursor = sys( 2015 ) + "_XmlTransCentral"
		try
			select Entidad, Descripcion, orden, Funcionalidades ;
					from c_entidad ;
					where upper( tipo ) == "E" and !deleted() and "C" $ Comportamiento ; 
					order by Descripcion, orden ;
				into cursor &lcCursor

			lcXml = this.cursoraxml( lcCursor )	
		finally
			use in select( lcCursor )
		endtry
		
		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlTransferenciasAgrupadas() as Void
		local lcCursor as String , lcXml as String 
		
		lcCursor = sys( 2015 ) + "_TransferAgrupa"
		
		try
			select 	id, ;
					Descripcion ;
					from c_TransferenciasAgrupadas ;
					where !deleted() ;
					order by Descripcion ;
				into cursor &lcCursor

			lcXml = this.cursoraxml( lcCursor )	
		finally		
			use in select( lcCursor )
		endtry

		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlTransferencias() as Void
		local lcCursor as String , lcXml as String 
		
		lcCursor = sys( 2015 ) + "_Transferexml"
		
		try
			select Entidad, Descripcion, orden, Funcionalidades ;
					from c_entidad ;
					where upper( tipo ) == "E" and !deleted() and "B" $ Comportamiento ;  
				union all select codigo as entidad, descrip as descripcion, orden, Funcionalidades from c_transferencias where !deleted() ;
					order by Descripcion, orden ;
			into cursor &lcCursor

			lcXml = this.cursoraxml( lcCursor )	
		finally
			use in select( lcCursor )
		endtry

		return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearXmlJerarquiaListados() as String
		local lcCursor as String, lcXml as String 
		
		lcCursor = sys( 2015 ) + "_jerarquialistados"

		try
			select ;
				padr( id, 254, " " ) as idListado, ;
				padr( titulo, 254, " " ) as NombreNodo, ;
				IdNodo as IdNodoPadre, ;
				iif( empty( Orden ), 00000999999, Orden ) as Orden, ;
				000000 as IdNodo, ;
				IdNodo as IdNodoReal, ;
				padr( Modulos, 255, " " ) as Modulos, ;
				"LI" as Tipo ;
			from c_Listados ;
			where !( upper( alltrim( c_Listados.id ) ) == "00" ) and !"<NOGENERAPRESENTACION>" $ upper( c_Listados.tags ) ;
			union ;
			select ;
				replicate( " ", 254 ) as idListado, ;
				padr( NombreNodo, 254, " " ) as NombreNodo, ;
				IdNodoPadre, ;
				iif( empty( Orden ), 00000999999, Orden ) as Orden, ;
				IdNodo, ;
				IdNodo as IdNodoReal, ;
				space(255) as Modulos, ;
				"LN" as Tipo ;
			from c_NodosListados ;
			into cursor( lcCursor ) 
			
			select * from ( lcCursor ) order by IdNodoPadre, NombreNodo into cursor ( lcCursor ) readwrite

			lcXml = this.cursoraxml( lcCursor )	
		finally		
			use in select( lcCursor )
		endtry

		return lcXml
	endfunc 

	*------------------------------------------------------------------------------
	function CrearXmlListadosAgrupados() as Void
		local lcCursor as String , lcXml as String, loEntidadAgrupados as Object, lcXml as String,;
			lcCursor as String, lcCursorAgrupados as String

		lcCursorAgrupados = sys( 2015 ) + "_ListadosAgrupados"

		try	
			select ;
				padr( id, 254, " " ) as idListado, ;
				padr( titulo, 254, " " ) as NombreNodo, ;
				0 as IdNodoPadre, ;
				00000999999 as Orden, ;
				(-1) as IdNodo, ;
				(-1) as IdNodoReal, ;
				space(255) as Modulos, ;
				"LI" as Tipo ;
			from c_Listados ;
			where  upper( alltrim( c_Listados.id ) ) == "00";
			into cursor( lcCursorAgrupados ) 			
			
			lcXml = this.cursoraxml( lcCursorAgrupados )	
		finally
			use in select( lcCursorAgrupados )
			
			loEntidadAgrupados = null 
		endtry

		Return lcXml
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerHerenciaDeListado( tcListadoId as String ) as String
		local lcCursor as String, lcHerencia as String, lcTag as String

		lcCursor = sys( 2015 )	 + "_herenciaDeListado"
		lcHerencia = ""
		try
			if used( "c_Listados" )
				select tags from c_Listados ;
					where upper( alltrim( id ) ) == upper( alltrim( transform( tcListadoId ) ) ) ;
					into cursor ( lcCursor )
				if reccount( lcCursor ) > 0
					select ( lcCursor )
					lcTag = upper( alltrim( &lcCursor..tags ) )
					if this.oFunc.TieneFuncionalidad( "HERENCIA", lcTag )
						lcHerencia = this.oFunc.ObtenerValor( "HERENCIA", lcTag )
					endif
				endif
			endif
		finally		
			use in select( lcCursor )
		endtry
		
		return lcHerencia
	endfunc 

	*------------------------------------------------------------------------------
	function CrearXmlListadosSecuencial() as Void
		local lcCursor as String , lcXml as String 

		lcCursor = sys( 2015 ) + "_ListadosSecuencial"

		try		
			select ;
				LisSecCod as LisSecCod , ;
				LisSecdes as LisSecdes , ;
				iif( empty( Orden ), 00000999999, Orden ) as orden, ;
				idNodo as idNodo ;
				from c_ListSec ;
					into cursor( lcCursor ) ;
				order by IdNodo

			lcXml = this.cursoraxml( lcCursor )	
		finally
			use in select( lcCursor )
		endtry

		Return lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConvertirTipoDato( tcTipoDato as String ) as String
		local lcTipoDato as String , lcRetorno as String 
		
		lcTipoDato = upper( alltrim( tcTipoDato ) )
		if lcTipoDato = "A" 
			lcRetorno = "N"
		else
			lcRetorno = lcTipoDato
		Endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneClaveCandidata( tcCursor as String ) as Boolean
		select * ;
			from ( this.cCursorAtributos ) ;
			into cursor &tcCursor nofilter ;
			where !empty( ClaveCandidata ) and !empty(Campo) and !detalle And alltrim( upper( Tabla ) ) == upper( alltrim( This.cTabla ) ) ; 
			order by ClaveCandidata

		return reccount( tcCursor ) > 0

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorClaveCandidata( tcEntidad as String ) as String
		local lcCursor as string, lcEntidad as String 

		lcCursor = sys( 2015 ) + "_ClavCandiCursor"
		lcEntidad = upper( alltrim( tcEntidad ) )

		select dic.campo, dic.tipodato, dic.longitud, dic.decimales, dom.detalle, dic.ClaveCandidata ;
			from c_Diccionario Dic, c_dominio dom ;
			where rtrim(upper(Dic.Entidad)) == lcEntidad ;
				and rtrim(upper(dic.dominio)) == rtrim(upper(dom.dominio));
				and !empty( dic.ClaveCandidata ) and !empty(dic.Campo) and !detalle ; 
			into cursor &lcCursor nofilter ;
			order by dic.ClaveCandidata

		return lcCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerClaveCandidataConcatenada( tcEntidad as String ) as String
		local lcRetorno as String, lcCursor as string, lcEntidad as String 

		lcRetorno = ""
		if pcount() > 0
			lcEntidad = upper( alltrim( tcEntidad ) )
		else
			lcEntidad = this.cTipo
		endif

		lcRetorno = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "ObtenerClaveCandidataConcatenada", tcEntidad )
		if isnull( lcRetorno )
			lcRetorno = ""
			
			lcCursor = this.ObtenerCursorClaveCandidata( lcEntidad )
			try
				if reccount( lcCursor ) > 0
					select &lcCursor
					scan all
						do case
						case inlist( alltrim( &lcCursor..tipoDato ), "C", "G" )
							lcRetorno = lcRetorno + " + #tabla#." + alltrim( &lcCursor..Campo )
						case alltrim( &lcCursor..tipoDato ) == "L"
							lcRetorno = lcRetorno + " + iif( #tabla#." + alltrim( &lcCursor..Campo ) + " , '1', '0' )"
						case alltrim( &lcCursor..tipoDato ) == "D"
							lcRetorno = lcRetorno + " + dtos( #tabla#." + alltrim( &lcCursor..Campo ) + " )"				
						case inlist( alltrim( &lcCursor..tipoDato ), "N", "A" )
							lcRetorno = lcRetorno + " + str( #tabla#." + alltrim( &lcCursor..Campo ) + ", " + allt( transform( &lcCursor..Longitud ) ) + ", " + allt( transform( &lcCursor..Decimales ) ) + ")"
						otherwise
							assert .f. message "Tipo de dato no soportado"
						endcase
						select &lcCursor
					EndScan	
					lcRetorno = substr( lcRetorno, 4 )
				endif
			finally
				use in select( lcCursor )
			endtry

			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "ObtenerClaveCandidataConcatenada", tcEntidad, lcRetorno )
		endif
				
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionalidadDesactivable( txTipo as Variant ) as Boolean
		return this.VerificarFuncionalidad( txTipo, "DESACTIVABLE" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarFuncionalidad( tcEntidad as string, tcFuncionalidad as string ) as Boolean
		local lcAux as String, llRetorno as Boolean, lcFuncionalidades as string
		
		llRetorno = this.oCacheFunc.Obtener( "GENERADORDINAMICO", "VerificarFuncionalidad", tcEntidad + "," + tcFuncionalidad )
		if isnull( llRetorno )
			lcFuncionalidades = this.ObtenerFuncionalidades( tcEntidad  )	
			llRetorno = this.oFunc.TieneFuncionalidad( upper( alltrim( tcFuncionalidad ) ), lcfuncionalidades )		
			this.oCacheFunc.Agregar( "GENERADORDINAMICO", "VerificarFuncionalidad", tcEntidad + "," + tcFuncionalidad, llRetorno )
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFuncionalidades( tcEntidad as String ) as String
		local lcRetorno as String	
		select c_Entidad
		locate for upper( alltrim( Entidad ) ) = upper( alltrim( tcEntidad ) )
		lcRetorno = funcionalidades
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUbicacionSucursal( tcUbicacion as String ) as Boolean
		if empty( tcUbicacion )
			tcUbicacion = this.cUbicacionDB 
		endif
		
		return ( empty( tcUbicacion ) or alltrim( upper( tcUbicacion ) ) == "SUCURSAL" )
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function EsTablaSucursal( tcTabla as String ) as boolean
		local llRetorno as Boolean, lcAux as string

		if upper( alltrim( tcTabla ) ) == upper( alltrim( This.cTabla ) )
			llRetorno = This.EsUbicacionSucursal()
		else
			lcAux = upper( alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Entidad", "Tabla,ClavePrimaria", upper( alltrim( tcTabla ) ) + ",.T." ) ) )
			lcAux = this.oAdnAD.ObtenerValorCampo( "Entidad", "UbicacionDB", "Entidad", lcAux )
			llRetorno = This.EsUbicacionSucursal( lcAux )
		endif
			
		return llRetorno	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoDesdeExpresion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCampoAtributo( tcEntidad as String , tcAtributo as String ) As String
		return alltrim( this.oAdnAD.ObtenerValorCampo( "diccionario", "Campo", "Entidad,Atributo", upper( alltrim( tcEntidad ) ) + "," + upper( alltrim( tcAtributo ) ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AntesDeGenerarCodigo() as Void
		dodefault()
		This.SetearTabla_Y_Esquema()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearTabla_Y_Esquema() as Void
		This.cTabla = This.ObtenerTabla( this.cTipo )
		if empty( This.cTabla )
			This.cEsquema = ""
		else
			This.cEsquema = this.ObtenerEsquema( This.cTabla )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearNumeroDeVersion( tcNumeroDeVersion as String ) as VOID
		this.cNumeroDeVersion = tcNumeroDeVersion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoMiPyME() as string
		local lcAux as String, lcRetorno as string
		lcRetorno = ""
		*lcAux = this.oAdnAD.ObtenerValorCampo( "entidad", "funcionalidades", "entidad",  upper( alltrim( this.cTipo ) ) )
		lcAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )
		if !empty( lcAux )
			lcRetorno = alltrim( this.oFunc.ObtenerValor( "MIPYME", lcAux ) )
		endif
		return lcRetorno
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oCamposCombinacion_Access() as variant
		if !this.ldestroy and !vartype( this.oCamposCombinacion ) = 'O'
			this.oCamposCombinacion = _screen.zoo.crearobjeto( "ZooColeccion" )		
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
					this.oCamposCombinacion.Agregar( alltrim( upper( c_Atributo.Atributo) ) )
				endif		
				select c_Atributo
			endscan
			use in select( "c_Atributo"  )
			use in select( "c_AtributosStockCombinacion" )		
		endif
		return this.oCamposCombinacion
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosCombinacion() as Object
		return this.oCamposCombinacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneAtributosCombinacion( tcCursor as String ) as Boolean
		local lcSentencia as String, lcAtributo as String, loAtributos as Object, llRetorno as Boolean, lcCursorDetalle as String
		lcCursorDetalle = sys(2015)
		llRetorno = .F.
			loAtributos = this.ObtenerAtributosCombinacion()
			if loAtributos.Count > 0
			lcSentencia = "select atributo from " + tcCursor + " det where "
			for each lcAtributo in loAtributos
				lcAtributo = upper( lcAtributo )
				lcSentencia = lcSentencia + "( upper( atributo ) = '" + lcAtributo + "' and upper( claveforanea ) = '" + lcAtributo + "' and alta ) or "
			endfor
			lcSentencia = Substr( lcSentencia, 1, Len( lcSentencia ) - 3 ) + " into cursor '" + lcCursorDetalle + "'"
			&lcSentencia
			llRetorno = ( _tally = loAtributos.Count )
		endif
		use in select( lcCursorDetalle )		
		return llRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoNormal() as string
		local lcAux as String, lcRetorno as string
		lcRetorno = ""

		*lcAux = this.oAdnAD.ObtenerValorCampo( "entidad", "funcionalidades", "entidad",  upper( alltrim( this.cTipo ) ) )
		lcAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )
		if !empty( lcAux )
			lcRetorno = alltrim( this.oFunc.ObtenerValor( "MIPYMEORIGINAL", lcAux ) )
		endif
		if empty( lcRetorno )
			lcRetorno = alltrim( str( this.oAdnAD.ObtenerValorCampo( "comprobantes", "id", "descripcion",  upper( alltrim( this.cTipo ) ) ) ) )
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatosAGenerar() as object
		local lcAux as String, lcRetorno as string
		loColPrgs = this.ObtenerArchivosAMergear()
		loColArchivos = this.ObtenerFirmasYContenido( loColPrgs )
		loColMetodosAgrupados = this.oColaboradorAgrupados.ReOrdenarDatosPorMetodo( loColArchivos )
		return this.ModificarMetodosEspecificos( loColMetodosAgrupados ) 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ModificarMetodosEspecificos( toCol as Object) as object
		return toCol
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSeteos( loCol as object ) as object
		local lcAux as String, loColeccionComprobantes as Object, lcFunc as String, lnLargo as Number
		
		*lcAux = this.oAdnAD.ObtenerValorCampo( "entidad", "funcionalidades", "entidad",  upper( alltrim( this.cTipo ) ) )
		lcAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )
		loColeccionComprobantes = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		
		if !empty( lcAux )
			lcFunc = alltrim( this.oFunc.ObtenerValor( "AGRUPACOMPROBANTES", lcAux ) )
		endif
		lnLargo = ALINES(loComprobantes, lcFunc , ";")
		
		for i = 1 to lnLargo
			loColeccionComprobantes.agregar( "ent_" + this.oAdnAD.ObtenerValorCampo( "comprobantes", "descripcion", "id",  loComprobantes[i] ) )
		endfor
		return loColeccionComprobantes		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerArchivosAMergear() as object
		local lcAux as String, loColeccionComprobantes as Object, lcFunc as String, lnLargo as Number
		
		*lcAux = this.oAdnAD.ObtenerValorCampo( "entidad", "funcionalidades", "entidad",  upper( alltrim( this.cTipo ) ) )
		lcAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )
		
		if !empty( lcAux )
			lcFunc = alltrim( this.oFunc.ObtenerValor( "AGRUPACOMPROBANTES", lcAux ) )
		endif
		lnLargo = ALINES(loComprobantes, lcFunc , ";")
		
		loColeccionComprobantes = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		lcPrefijo = this.ObtenerPrefijo()
		lcVa = iif( lcPrefijo = "Ent", "_", "" )
		for i = 1 to lnLargo
			lcEntidad = alltrim( this.oAdnAD.ObtenerValorCampo( "comprobantes", "descripcion", "id",  loComprobantes[i] ) )
			lcNombre = lcPrefijo + _screen.zoo.app.cProyecto + "_" + upper( lcEntidad ) + ".prg"
			if file( lcNombre )
				loItemAuxHer = newobject( "Custom" )
				loItemAuxHer.addproperty( "Nombre", lcNombre )
				loItemAuxHer.addproperty( "Entidad", lcEntidad )
				loItemAuxHer.addProperty( "TipoComprobante", loComprobantes[i] )
				loColeccionComprobantes.agregar( loItemAuxHer )
			endif
			lcNombre = lcPrefijo + lcVa + lcEntidad + ".prg"
			if file( lcNombre )
				loItemAux = newobject( "Custom" )
				loItemAux.addproperty( "Nombre", lcNombre )
				loItemAux.addproperty( "Entidad", lcEntidad )
				loItemAux.addProperty( "TipoComprobante", loComprobantes[i] )
				loColeccionComprobantes.agregar( loItemAux )
			endif
		endfor
		
		return loColeccionComprobantes
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPrefijo() as string
		return ""
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFirmasYContenido( loCol as object) as object
		local lcAux as String, loColeccionComprobantes as Object, lcFunc as String, lnLargo as Number
		
		this.oColaboradorAgrupados = newobject( "colaboradoragrupadordeentidades", "colaboradoragrupadordeentidades.prg") 
		loColeccionComprobantes = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		for i = 1 to loCol.count
			loColeccionComprobantes.agregar( this.oColaboradorAgrupados.AnalizarArchivo( loCol.Item[i] ) )
		endfor 		
		
		return loColeccionComprobantes		
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsEntidadAnulable( tcEntidad as String ) as Boolean
		local lcAlias as String, llRetorno as Boolean
		
		lcAlias = alias()
		llRetorno = .f.
		select c_Entidad
		locate for alltrim(upper(entidad))==alltrim(upper(tcEntidad))
		if found()
			llRetorno = at('<ANULABLE>', funcionalidades)>0
		endif
		if !empty( lcAlias )
			select &lcAlias
		endif
		return llRetorno	
	endfunc 
enddefine


