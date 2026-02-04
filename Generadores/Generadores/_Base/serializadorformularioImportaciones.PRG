define class SerializadorFormularioImportaciones as SerializadorFormularioSinMenu of SerializadorFormularioSinMenu.prg

	cPath = "Generados\"
	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerControl( tocontrol as Object, tcatributo as String, tcMinPrimerControlxOrdenFiltro as Integer ) as Void
		return tcMinPrimerControlxOrdenFiltro
	endfunc
enddefine
