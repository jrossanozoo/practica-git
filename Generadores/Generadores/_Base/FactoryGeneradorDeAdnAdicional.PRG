define class FactoryGeneradorDeAdnAdicional as Custom

	*-----------------------------------------------------------------------------------------
	function ObtenerGeneradores( tcRutaZoo as String ) as collection
		local lnCantidadDeGeneradores as Integer, i as Integer, loGeneradores as collection, ;
			lcGenerador as String
		
		lnCantidadDeGeneradores = adir( aGeneradores , addbs( tcRutaZoo ) +  "generadores\_base\Generadordeadnadicional*.prg" )
		loGeneradores = newobject( "collection" )

		for i = 1 to lnCantidadDeGeneradores
			lcGenerador = strtran( upper( alltrim ( ageneradores[i,1]) ) , ".PRG" )
			if !inlist( lcGenerador , "GENERADORDEADNADICIONAL", "GENERADORDEADNADICIONALGENERICO", "GENERADORDEADNADICIONALLISTADOSGENERICOS" )
				loGeneradores.Add( newobject( lcGenerador, lcGenerador + ".prg"  ) , lcGenerador )
			endif

		endfor

		return loGeneradores
		
	endfunc 

Enddefine