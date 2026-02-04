define class SerializadorFormularioExportacionesAgrupada as SerializadorFormularioExportaciones of SerializadorFormularioExportaciones.prg

	cPath = "Generados\"
	*-----------------------------------------------------------------------------------------
	function ActualizarColSinControlSource( toControl as Object , tnTab as Integer, tcRuta as String  ) as Void
		if alltrim( upper( toControl.Class )) == 'CONTENEDOREXTENSIBLE'
			toControl.cAtributo = ""
			this.ActualizarColConControlSource( toControl, tnTab, tcRuta )
		endif
	endfunc 

enddefine
