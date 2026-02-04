define class GeneradorDeSentenciasSql as ZooSession of zoosession.prg
	cCC = ""
	cPK = ""
	cBaseDeDatos = ""
	cUbicacion = ""
	lEsMaster = .f.
	cMaster = ""

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaCreateTable( tcXml as String, tcXmlEstructura as string, tnCantidadSentencias as Integer, tcLineasDiferencias as String ) as String
		** Debe devolver la sentencia de creacion de tabla segun el motor de BDD utilizado.
		return "" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaAddColumn() as String
		** Debe devolver la sentencia de agregado de campos segun el motor de BDD utilizado.
		return "" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaAlterColumn() as String
		** Debe devolver la sentencia de modificación de campos segun el motor de BDD utilizado.
		return "" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaAlterTable( tcXml as String,  tcXmlEstructura as string, tnCantidadSentencias as Integer, tcLineasDiferencias as String ) as Void
		** Debe devolver la sentencia de modificación de campos segun el motor de BDD utilizado.
		return "" 	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerLineaLogueo( tcUbicacion as String, tcTabla as String, tlConProblema as Boolean, tlEsSinonimo as Boolean ) as Void
		local lcRetorno as String, lcSucursal as String
	
		if tlEsSinonimo
			lcRetorno = "Base de datos: " + alltrim( tcUbicacion ) + " - Sinonimo: " + proper( this.ObtenerNombreTablaSinExtension( tcTabla ))
		else
			lcRetorno = "Base de datos: " + alltrim( tcUbicacion ) + " - Tabla: " + proper( this.ObtenerNombreTablaSinExtension( tcTabla ))
		endif
		
		lcSucursal = " en la base de datos"
		
		if tlConProblema
			lcRetorno = lcRetorno + " - Problema: Deberia existir" + lcSucursal + "."
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreTablaSinExtension( tcRutaTabla as String ) as Void
		return alltrim( juststem( tcRutaTabla ))
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarClaves( tcTabla as String, tcEsquema as string ) as Void
		local lcCursor as String
		
		this.cCC = ""
		this.cPK = ""
		lcCursor = sys(2015)
		try
			select * from c_indices ;
			where alltrim( upper( c_indices.Tabla )) == alltrim( upper( tcTabla ));
				and alltrim( upper( c_indices.Esquema )) == alltrim( upper( tcEsquema ));
			into cursor &lcCursor

			scan
				if &lcCursor..esPK
					this.cPK = this.cPK + ", " + alltrim( &lcCursor..Campo )
				else
					if &lcCursor..esCC
						this.cCC = this.cCC + ", " + alltrim( &lcCursor..Campo )
					endif
				endif
			endscan
			
			this.cCC = substr( this.cCC, 3 )
			this.cPK = substr( this.cPK, 3 )
			
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( lcCursor )
		endtry 		
	endfunc 			
enddefine
