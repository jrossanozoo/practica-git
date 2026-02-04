*-----------------------------------------------------------------------------------------
Define Class AplicacionGeneradores As AplicacionBase of AplicacionBase.prg

	Nombre = "Generadores"
	NombreProducto = "GENERADORES"
	cProyecto = 'GENERADORES'

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "Vedettes"
	endfunc 

Enddefine
