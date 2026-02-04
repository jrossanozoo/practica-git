define class GeneradorFormularios as Generador of Generador.prg

	#if .f.
		local this as GeneradorFormularios of GeneradorFormularios.prg
	#endif

	cPath = ""

	cModo = ""
	nEstilo = 0

	cClaseInterprete = ""
	cClaseSerializador = ""
	
	oMetadata = null
	oInterprete = null
	oSerializador = null
	oDibujantes = null

	lReutilizaMetadata = .f.
	
	nTiempoMetadata = 0
	nTiempoDibujar = 0
	nTiempoSerializar = 0
	oLibControles = null
	EsFormularioConLibreriaProxy = .f.
		
	*-------------------------------------------------------------------------------------------------
	Function Init( tcRuta as String ) As Boolean
		Local llRetorno As Boolean
		llRetorno = ( "Generadorformularios" != This.Class )
		if llRetorno
			llRetorno = DoDefault( tcRuta )
		endif

		this.oDibujantes = _screen.zoo.crearobjeto( "zooColeccion" )

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		with this
			.lDestroy = .t.
			if vartype( .oInterprete ) = "O"
				.oInterprete.release()
			endif
			.oInterprete = null

			.EliminarMetadata()

			if vartype( .oSerializador ) = "O"
				.oSerializador.release()
			endif
			.oSerializador = null
			
			if vartype( .oDibujantes ) = "O"
				.oDibujantes.release()
			endif
			.oDibujantes = null
		endwith
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Generar( txTipo as variant, tcModo as string, tnEstilo as integer ) as Void
		local loError as Exception
		with this
			if vartype( txTipo ) != "C"
				txTipo = transform( txTipo )
			endif
			
			.lReutilizaMetadata = !empty( txTipo ) and alltrim( lower( txTipo ) )== alltrim( lower( this.cTipo ) ) and ( tcModo == this.cModo )
			
			.cModo = tcModo
			.nEstilo = tnEstilo
			
			dodefault( txTipo )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo() as void
		this.cArchivo = this.cPath + "Din_" + proper( this.cPrefijo ) + ;
				proper( this.cTipo ) + proper( this.cSufijo ) + proper( this.cModo ) + "Estilo" + alltrim( str( this.nEstilo ) ) +".prg"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCodigo() as Void
		local loFormulario as object
		
		with this
			try
				.ObtenerMetadata()
				loFormulario = .Dibujar()
				.Serializar( loFormulario )
			catch to loerror
				goServicios.Errores.LevantarExcepcion( loError )
			finally	
				if vartype( loFormulario ) = "O"
					loFormulario.release()
				endif
				loFormulario = null
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarMetadata() as void
		with this
			if !isnull( .oMetadata )
				.oMetadata.release()
			endif
			.oMetadata = null
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMetadata() as object
		if this.lReutilizaMetadata
		else
			this.EliminarMetadata()
			this.oMetadata = this.oInterprete.ObtenerDatos ( this.cTipo, this.cModo )
		endif			
	endfunc

	*-----------------------------------------------------------------------------------------
	function oInterprete_Access() as Void
		if !this.ldestroy and !vartype( this.oInterprete ) = 'O' and isnull( this.oInterprete )
			this.oInterprete = _screen.zoo.crearobjeto( this.cClaseInterprete )
		endif
		return this.oInterprete
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oSerializador_Access() as Void
		if !this.ldestroy and !vartype( this.oSerializador ) = 'O' and isnull( this.oSerializador )
			this.oSerializador = _screen.zoo.crearobjeto( this.cClaseSerializador )
			this.oSerializador.cPath = this.cPath
		endif
		return this.oSerializador
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Dibujar() as form
		local loRetorno as Form, loDibujante as Dibujante of Dibujante.prg

		loDibujante = this.ObtenerDibujante()
		loRetorno = loDibujante.Dibujar( this.oMetadata, this.nEstilo )
		loDibujante.oMetadataDibujante = null
		
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDibujante() as Dibujante of Dibujante.prg
		local loDibujante as Dibujante of Dibujante.prg, lcClase as string

		loDibujante = null

		if !isnull( this.oMetadata )
			lcClase = upper( alltrim( this.oMetadata.cClaseDibujante ) )

			if this.oDibujantes.Buscar( lcClase )
				loDibujante = this.oDibujantes.Item[ lcClase ]
			endif
		endif

		if isnull( loDibujante )
			loDibujante = _screen.zoo.crearobjeto( lcClase )
			this.oDibujantes.Agregar( loDibujante, lcClase )
		else
			loDibujante.Inicializar()
		endif

		loDibujante.lTieneMenuYToolbar = pemstatus( this.oMetadata, "lTieneMenuYToolbar", 5 ) and this.oMetadata.lTieneMenuYToolbar
		
		return loDibujante
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Serializar( toForm as Form ) as Void
		this.oSerializador.lTieneMenuYToolbar = pemstatus( this.oMetadata, "lTieneMenuYToolbar", 5 ) and this.oMetadata.lTieneMenuYToolbar
		if this.GeneraFormularioConLibreriaProxy()
			this.EsFormularioConLibreriaProxy = .t.
			this.oSerializador.EsFormularioConLibreriaProxy = .t.
			this.oSerializador.oLibControles = this.oLibControles
		endif
		this.oSerializador.Serializar( toForm, this.oMetadata, strtran( justfname( this.cArchivo ), ".prg", "" ))
		this.oSerializador.oMetadata = null
		this.oSerializador.oFormulario = null
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GeneraFormularioConLibreriaProxy() as Boolean
		local llRetorno as Boolean
		llRetorno = inlist(lower(this.Class),lower('Generadorformularios'),lower('Generadorformulariosentidades'),lower('generadorformulariossinentidad'))
		return llRetorno
	endfunc 


enddefine
