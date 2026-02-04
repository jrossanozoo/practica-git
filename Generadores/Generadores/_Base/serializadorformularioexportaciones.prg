define class SerializadorFormularioExportaciones as SerializadorFormularioSinMenu of SerializadorFormularioSinMenu.prg

	cPath = "Generados\"
	EsFormularioConLibreriaProxy = .f.

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerControl( tocontrol as Object, tcatributo as String, tcMinPrimerControlxOrdenFiltro as Integer ) as Void
		return tcMinPrimerControlxOrdenFiltro
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsPropiedadDeClaseProxy( tcPropiedad as String ) as Boolean
		return .f.
	endfunc 
	
enddefine
