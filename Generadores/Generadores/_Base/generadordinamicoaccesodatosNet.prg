define class GeneradorDinamicoAccesoDatosNet as GeneradorDinamico of GeneradorDinamico.prg

	cHerenciaGenerado = "AccesoDatosEntidad_NET"
	cSufijo = "AD_Net"
	cUbicacionDB = ""
	cCursorAtributos = ""
	*-----------------------------------------------------------------------------------------
	protected function AntesDeGenerarCodigo() as void
		dodefault()
		with this
			.cCursorAtributos = .ObtenerCursorAtributos()
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		dodefault()
		with this
			.cArchivo = .cPath + "Din_Entidad" + alltrim( Proper( .cTipo ) ) + .cSufijo + ".prg"
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorAtributos() as String 
		local lcNombreCursor as String, lcSql as String  
		
		lcNombreCursor = "c_" + sys(2015)
			
		lcsql = "select dic.Atributo,"+;
			" iif( !empty(Dic.ClaveForanea) ,Dic.ClaveForanea, dic.Entidad) as cEntidad,"+;
			" iif(empty(Dic.TipoDato), dom.TipoDato, Dic.TipoDato) as tipoDato,"+;
			" !empty(Dic.ClaveForanea) as EsEntidad, "+;
			" dom.detalle, "+;
			" dic.tabla, "+;
			" dic.campo, "+;
			" dic.longitud, "+;
			" dic.claveprimaria, "+;
			" dic.Etiqueta, " +;
			" dic.ValorSugerido, "+;
			" dic.Obligatorio, "+;
			" dic.Decimales, " + ;
			" dic.AtributoForaneo, " + ;
			" dic.ClaveForanea, " + ;
			" ent.UbicacionDB, " + ;
			" Dic.ClaveCandidata, " + ;
			" Dic.Auditoria, " + ;
			" Dic.MantenerEnRecepcion, " + ;
			" Dic.ordenNavegacion " + ;
			" from c_Diccionario Dic, c_dominio dom, c_entidad ent "+;
			" where rtrim(upper(Dic.Entidad)) == '" + this.cTipo + "'"+;
			" and rtrim(upper(Dic.Entidad)) == rtrim(upper(ent.Entidad)) "+;
			" and !empty(dic.atributo) " +;
			" and !empty(dic.Entidad)" +;
			" and rtrim(upper(dic.dominio)) == rtrim(upper(dom.dominio)) "+;
			" order by Dic.Orden "+;
			" into cursor " + lcNombreCursor

		&lcsql 

		return lcNombreCursor
	endfunc 

		
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		with this
			.AgregarLinea( "define class Din_Entidad" + .cTipo + .cSufijo + " as " + .cHerenciaGenerado + " of " + .cHerenciaGenerado + ".prg" )
			.AgregarLinea( "" )

		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void

		with this
			.FuncionInicializar()
			.FuncionAsignarAtributos()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	protected function FuncionInicializar() as Void
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function Inicializar() as boolean", 1 )
				.AgregarLinea( "" )			
				.AgregarLinea( "If dodefault()", 2)
					.AgregarLinea( "this.oDAL = this.CrearObjetoDal( '" + alltrim( .cTipo ) + "' )", 3 )
					.AgregarUbicacionDB( 3 )
				.AgregarLinea( "endIf", 2 )	
				.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )		
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearUbicacionDB() as Void
		
		select c_Entidad
		locate for alltrim( upper( Entidad ) ) == alltrim( upper( This.cTipo ) )
		This.cUbicacionDB =  upper( alltrim( c_Entidad.UbicacionDB ) )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarUbicacionDB( tnTab ) as Void
		this.AgregarLinea( "this.cUbicacionDB = '" + this.cUbicacionDB + "'" , tnTab )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function FuncionAsignarAtributos() as Void
		local lcAtributo as String
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function AsignarAtributos( toOrigen as Object, toDestino as Object ) as Void", 1 )
				.AgregarLinea( "local llOrigenEntidad as boolean", 2 )
				.AgregarLinea( "" )
				.AgregarLinea("*Si el destino es el objeto Net, entonces el origen es una entidad")
				.AgregarLinea( "llOrigenEntidad = this.EsObjetoNet( toDestino )", 2 )
				.AgregarLinea( "" )
				.AgregarLinea( "With toDestino", 2)
				select ( .cCursorAtributos )
				scan for !empty( campo ) and !detalle
					lcAtributo = proper( alltrim( Atributo ) )
					
					if empty( claveForanea )
						if alltrim( upper( TipoDato ) ) = "D"
							.AgregarLinea( "." + lcAtributo + " = This.ParsearFechaNet( toDestino, toOrigen." + lcAtributo + " )", 3 )
						Else
							.AgregarLinea( "." + lcAtributo + " = toOrigen." + lcAtributo, 3 )
						Endif	
					else
						.AgregarLinea( "if llOrigenEntidad", 3 )
							.AgregarLinea( "." + lcAtributo + " = toOrigen." + lcAtributo + ".oAd.oDto" , 4)
						.AgregarLinea( "else", 3 )
							.AgregarLinea( "if isnull( toOrigen." + lcAtributo + " )" , 4)
								.AgregarLinea( "." + lcAtributo + "_pk = " + goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( TipoDato ) ) , 5)
							.AgregarLinea( "else" , 4)
								.AgregarLinea( "." + lcAtributo + "_pk = toOrigen." + lcAtributo + "." + .ObtenerAtributoClavePrimaria( claveForanea ), 5)
							.AgregarLinea( "endif" , 4)
						.AgregarLinea( "endif", 3 )					
					endif
					select ( .cCursorAtributos )
				Endscan
				.AgregarLinea( "EndWith", 2)
			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )		
		endwith


	endfunc 

endDefine