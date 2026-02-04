define class GeneradorFormulariosEntidades as GeneradorFormularios of GeneradorFormularios.prg
	
	#if .f.
		local this as GeneradorFormulariosEntidades of GeneradorFormulariosEntidades.prg
	#endif
	
	protected oGenMenu as Object
	oGenMenu = null

	cPrefijo = "ABM"

	cPath = "Generados\"
	
	cClaseSerializador = "SerializadorFormulario"
	cClaseInterprete = "InterpreteMetadataEdicion"

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oGenMenu = null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EliminarMetadata() as void
		*Se piza para podr reutilizar la metadata  cuando se generan los dos estilos
		*El que mata la metadata es el procesodinamico
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oGenMenu_Access() as Void
		if !this.ldestroy and !vartype( this.oGenMenu ) = 'O'
			this.oGenMenu = _screen.zoo.crearobjeto( "generadordinamicomenualtas" )
		endif
		return this.oGenMenu
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Serializar( toFormulario as Form ) as Void
		this.AgregarAtributosMenu( toFormulario )
		dodefault( toFormulario )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAtributosMenu( toFormulario as Form ) as Void
		local loEstructura as object, lcCursor as String
		lcCursor = sys( 2015 )
		
		with this

			this.oGenMenu.cTipo = "MENUABM" + .cTipo
			loEstructura = this.oGenMenu.ObtenerEstructura() 
			
			this.xmlACursor( loEstructura.cMenu, lcCursor )
			select( lcCursor )
			scan
				lcPropiedad = goLibrerias.TransformarCadenaCaracteres( alltrim( &lcCursor..codigo ) )
				toFormulario.AddProperty( "lDesHabilitar"+lcPropiedad, .f. )
			endscan

			if pemstatus( toFormulario, "lDesHabilitarGuardar", 5 )
				toFormulario.lDesHabilitarGuardar = .T.
			endif
			
			if pemstatus( toFormulario, "lDesHabilitarEliminar", 5 )
				toFormulario.lDesHabilitarEliminar = .T.
			endif
			
			if pemstatus( toFormulario, "lDesHabilitarCancelar", 5 )
				toFormulario.lDesHabilitarCancelar = .T.
			endif
			

		endwith
		
		use in select( lcCursor )
	endfunc 


enddefine

