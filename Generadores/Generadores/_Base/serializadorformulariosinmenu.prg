define class SerializadorFormularioSinMenu as SerializadorFormulario of SerializadorFormulario.prg

	#if .f.
		local this as SerializadorFormularioSinMenu  of SerializadorFormularioSinMenu.prg
	#endif

	cPath = ""
	cMinPrimerControlxOrdenFiltro = 99999999
	EsFormularioConLibreriaProxy = .f.

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributos() as Void
		with this
			.AgregarLinea( "ColControles = null", 1 )
			.AgregarLinea( "cPrimerControl = Space(0) ", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	
	*-------------------------------------------------------------------------
	Function Serializar( toFormulario as form, toMetadata as object, tcArchivo as string ) as VOID
		this.cHerencia = toFormulario.Class
		dodefault( toFormulario, toMetadata, tcArchivo )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarCuerpo() as Void
		with this
			.cMinPrimerControlxOrdenFiltro = 99999999
						
			.AgregarLinea( "" )
			
			.AgregarCabeceraInit()
			.AgregarLinea( "this.ColControles = newobject('collection')", 2 )
			
			.GrabarControl( .oFormulario, .f., 2 )

			.AgregarLinea( .cCreacionDeSinglentons )
			.AgregarLinea( .cSeteos, 0 )

			.AgregarLinea( "" )

			.SetearNombre( .oMetadata.Titulo )
			.SetearIcono()
			.SetearTitulo()
			
			if !empty( This.oFormulario.cPrimerControl )	
				.AgregarLinea( "" )					
				.AgregarLinea( "Thisform.cPrimerControl = '" + This.oFormulario.cPrimerControl + "'", 2 )
				.AgregarLinea( "" )
			endif

			this.AgregarInstanciacionDeKontroler()

			.AgregarPieDelInit()

			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarInstanciacionDeKontroler() as Void
		this.AgregarLinea( "this.newobject( 'oKontroler', '" + this.oMetadata.cClaseKontroler + "', '" + this.oMetadata.cClaseKontroler + ".prg' )", 2 )
		this.AgregarLinea( "this.oKontroler.Inicializar()", 2 )
	endfunc 

	*-------------------------------------------------------------------------
	Function SetearNombre( tcTitulo as string ) as void
		local lcIcono as string
		with this
			.AgregarLinea( "this.name = '" + goLibrerias.TransformarCadenaCaracteres( tcTitulo ) + "'", 2 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarColConControlSource( toControl as Object , tnTab as Integer, tcRuta as String  ) as Void
		local lcCadena as String , lcAtributo as String 

		lcCadena = "thisform.ColControles.add('" + tcRuta + "','"
		lcAtributo = ""
		
		if toControl.lEsSubentidad
			if ( pemstatus( tocontrol, "lClavePrimaria", 5 ) and toControl.lClavePrimaria )
				lcAtributo = alltrim( toControl.cClaveForanea )
			else
				lcAtributo = alltrim( toControl.cEntidad )
			endif

			lcAtributo = lcAtributo + "_" + alltrim( toControl.cAtributo ) + right( toControl.name, len( toControl.name ) - 3 )
		else
			if upper( alltrim( toControl.cAtributo ) ) = alltrim( upper( toControl.name ) )
				lcAtributo = alltrim( toControl.cAtributo )
			else
				lcAtributo = alltrim( toControl.cAtributo ) + right( toControl.name, len( toControl.name ) - 3 )
			endif
		endif
				
		This.AgregarLinea( lcCadena + upper( lcAtributo )+ "')", tnTab )

		This.ObtenerPrimerControl( tocontrol, upper( lcAtributo ), This.cMinPrimerControlxOrdenFiltro )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarColSinControlSource( toControl as Object , tnTab as Integer, tcRuta as String  ) as Void
		local lcCadena as String , lcAtributo as String 
	
		if pemstatus( toControl, "cAtributo", 5 ) and !empty( toControl.cAtributo )
			lcCadena = "thisform.ColControles.add('" + tcRuta + "','"
			lcAtributo = alltrim( toControl.cAtributo )

			if pemstatus( toControl, "cEntidad", 5 ) and !empty( toControl.cEntidad )
				lcAtributo = alltrim( toControl.cEntidad ) + lcAtributo 
			endif

			this.AgregarLinea( lcCadena + upper( lcAtributo )+ "')", tnTab )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTextoOrigenDeDatos( toControl as Object ) as String
		local lcTexto as String
		lcTexto = "null"
		return lcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValoresPropiedadesIndispensables( toControl as Object, tnTab as integer ) as Void
		local lcTexto as String
		with this
			if pemstatus( toControl , "CPRIMERCONTROL", 5 )
			else
				dodefault( toControl, tntab )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsPropiedadIndispensable( tcPropiedad as String ) as boolean
		return dodefault( tcPropiedad  ) or inlist( upper( alltrim( tcPropiedad ) ), "CPRIMERCONTROL" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsPropiedadDeClaseProxy( tcPropiedad as String ) as Boolean
		return .f.
	endfunc 

enddefine