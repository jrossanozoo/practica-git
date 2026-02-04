define class SerializadorFormularioListados as SerializadorFormularioSinMenu of SerializadorFormularioSinMenu.prg

	cPath = "Generados\"

	*-------------------------------------------------------------------------
	Function Serializar( toFormulario as form, toMetadata as object, tcArchivo as string ) as VOID
		toFormulario.WindowType = 1
*		toFormulario.BorderStyle = 0
		dodefault( toFormulario, toMetadata, tcArchivo )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerControl( tocontrol as Object, tcatributo as String, tcMinPrimerControlxOrdenFiltro as Integer ) as Void

		if min( toControl.oItem.OrdenFiltro, This.cMinPrimerControlxOrdenFiltro ) > 0 and ;
			toControl.oItem.OrdenFiltro < This.cMinPrimerControlxOrdenFiltro
		    This.cMinPrimerControlxOrdenFiltro = toControl.oItem.OrdenFiltro
			This.oFormulario.cPrimerControl    = tcAtributo
		endif
		return tcMinPrimerControlxOrdenFiltro
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SerializarMatrizGrilla( tcPropiedad as string, toControl as Object, tnTab as integer ) as Void
		local lnI as integer, lnJ as Integer, lnFilas as Integer, lnColumnas as Integer, lcValor as String
		with this
			lnFilas = alen( toControl.&tcPropiedad, 1 )
			lnColumnas = alen( toControl.&tcPropiedad, 2 )
			if lnColumnas = 0
				.AgregarLinea( "Dimension ." + tcPropiedad + "( " + goLibrerias.ValorAString( lnFilas ) + " )", tnTab )
				.AgregarLinea( "local loColumna", tnTab )
				for lnI = 1 to lnFilas
					lcValor = toControl.&tcPropiedad[ lnI ]
					this.AgregarLinea( "." + tcPropiedad + "[ " + goLibrerias.ValorAString( lnI ) + " ] = " + goLibrerias.ValorAString( lcValor ), tnTab )
				endfor
			Else
				.AgregarLinea( "Dimension ." + tcPropiedad + "( " + goLibrerias.ValorAString( lnFilas ) + "," +  goLibrerias.ValorAString( lnColumnas ) + " )", tnTab )
				.AgregarLinea( "local loColumna", tnTab )
				for lnI = 1 to lnFilas
					for lnJ = 1 to lnColumnas
						lcValor = toControl.&tcPropiedad[ lnI,lnJ ]
						this.AgregarLinea( "." + tcPropiedad + "[ " + goLibrerias.ValorAString( lnI ) + "," + goLibrerias.ValorAString( lnJ ) + " ] = " + goLibrerias.ValorAString( lcValor ), tnTab )
					Endfor
				endfor
			Endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInstanciacionDeKontroler() as Void
		this.AgregarLinea( "local loFactoryDeListados as Object, lcClaseKontroler as Object", 2 )
		this.AgregarLinea( "loFactoryDeListados = goServicios.Listados.ObtenerFactoryDeListados()", 2 )

		this.AgregarLinea( "lcClaseKontroler = loFactoryDeListados.ObtenerNombreDeClase( '"+ this.oMetadata.cListado + "', 'Kontroler' )", 2 )
		this.AgregarLinea( "loFactoryDeListados = null", 2  )
		this.AgregarLinea( "" )
		this.AgregarLinea( "this.newobject( 'oKontroler', lcClaseKontroler , lcClaseKontroler + '.prg' )", 2 )
		this.AgregarLinea( "this.oKontroler.Inicializar()", 2 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ComandoDeCreacionConProxy( toControl as object ) as String
		local lcComando as String, lcClaseProxy as String, lcModulo as String
		
		if this.oformulario.clistado == "00"
			lcClaseProxy = upper(alltrim(toControl.Class))+ "Proxy"
			lcModulo = ""	&& Aqui se podria definir um módulo que proveea todos los proxis por ejemplo:
							&& 		ProveedorDeControlesVisualesParaFormulariosDeListados.prg
			lcComando = ".newobject( '" + toControl.name + "', '" + lcClaseProxy + "', '" + lcModulo + "', '', 'NO')"
		else
			lcComando = dodefault( toControl )
		endif
		
		return lcComando
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarClasesProxys() as Void
		local lnI as Integer, loProxyClass as ProxyClass of SerializadorFormulario.prg
		
		if this.oformulario.clistado == "00"
			for each loProxyClass in This.oColProxy foxobject
				This.AgregarLinea( "", 0 )
				This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
				if loProxyClass.lContieneMetadata 
					This.AgregarLinea( "*    Contiene Metadata ( " + loProxyClass.oMetadata.Class + " ) ---> redefine el método SetearControl( toItem )", 0 )
				endif
				This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
				This.AgregarLinea( "Define Class " + loProxyClass.cClaseProxy + " as " + loProxyClass.cClase + " of " + loProxyClass.cLibreria, 0 )
					This.AgregarLinea( "*--------------------------------------------------------------------------------------------------------", 1 )
					This.AgregarLinea( "Function Class_Access() as String ", 1 )
						This.AgregarLinea( "Return '" + loProxyClass.cClase + "'" , 2 )
					This.AgregarLinea( "EndFunc", 1 )
					
					This.AgregarLinea( "*--------------------------------------------------------------------------------------------------------", 1 )
					This.AgregarLinea( "Function ClassLibrary_Access() as String ", 1 )
						This.AgregarLinea( "Return '" + lower( forceext( loProxyClass.cLibreria, '.fxp' ) ) + "'" , 2 )
					This.AgregarLinea( "EndFunc", 1 )
					
					This.AgregarLinea( "*--------------------------------------------------------------------------------------------------------", 1 )
					This.AgregarLinea( "Function ParentClass_Access() as String ", 1 )
						This.AgregarLinea( "Local Array laInfoClase[ 1 ]" , 2 )
						This.AgregarLinea( "aclass( laInfoClase, this )" , 2 )
						This.AgregarLinea( "Return laInfoclase[ 3 ]" , 2 )
					This.AgregarLinea( "EndFunc", 1 )
				
				if loProxyClass.lContieneMetadata	
					This.AgregarLinea( "*--------------------------------------------------------------------------------------------------------", 1 )
					This.AgregarLinea( "Protected Function RecrearMetadata() as Object ", 1 )
						this.SerializarMetadata( loProxyClass.oMetadata )
						This.AgregarLinea( "Return null" , 2 )
					This.AgregarLinea( "EndFunc", 1 )
					
					This.AgregarLinea( "*--------------------------------------------------------------------------------------------------------", 1 )
					This.AgregarLinea( "Function SetearControl( toItem as Object ) as Void ", 1 )
						This.AgregarLinea( "Local loMetadata as Object" , 2 )
						This.AgregarLinea( "loMetadata = this.RecrearMetadata()" , 2 )
						This.AgregarLinea( "If vartype( loMetadata ) == 'O'" , 2 )
						This.AgregarLinea( "dodefault( loMetadata )" , 3 )
						This.AgregarLinea( "else" , 2 )
						This.AgregarLinea( "dodefault( toItem )" , 3 )
						This.AgregarLinea( "endif" , 2 )
					This.AgregarLinea( "EndFunc", 1 )
				endif
					
				This.AgregarLinea( "EndDefine", 0 )
			endfor
		else
			dodefault()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SerializarMetadata( toMetadata as Object ) as Void
		This.AgregarLinea( "*** Aquí debe estar serializada la estructura Metadata ***" , 2 )
	endfunc 

enddefine
