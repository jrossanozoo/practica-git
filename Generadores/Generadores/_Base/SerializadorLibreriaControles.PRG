*-----------------------------------------------------------------------------------------
Define Class SerializadorLibreriaControles as zooSession of zooSession.prg

	cArchivo = ""
	cPath = "Generados\"
	nArchivo = 0
	cBuffer = ""
	oColProxy = Null
	cTipoDataSession = "2"
	cBufferLib = ""
	cArchivoLib = ""
	oEstilos = null

	*-----------------------------------------------------------------------------------------
	function AgregarLinea( tcTexto, tnTabs ) as Void
		local lcEnter as string, tcTabs as string

		if pcount() = 2 and tnTabs > 0
			tcTabs = replicate( chr( 9 ), tnTabs )
		else
			tcTabs = ""
		endif
		lcEnter = chr( 13 ) + chr( 10 )
		this.cBuffer = this.cBuffer + tcTabs + tcTexto + lcEnter
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarEncabezado() as Void
		with this
			.cBuffer = ""
			.cBufferLib = ""
			.AgregarLinea( "*"+replicate("-",80)+"*", 0 )
			.AgregarLinea( "* "+replicate("-",15)+" Libreria de proxy a controles para formularios "+replicate("-",15)+" *", 0 )
			.AgregarLinea( "*"+replicate("-",80)+"*", 0 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EscribirLibreriaEnDisco() as Void
		* Se hace para evitar que en caso concurrencia de ejecucion de este prg desde Autobuild
		local lnreintentos as Integer, lntope as Integer
		lnreintentos = 1
		lntope = 3
		do while lnreintentos <= lntope 
			try
				=strtofile(this.cBuffer,this.cArchivo,0)
				lnreintentos = lntope + 1
			catch to loError
				lnreintentos = lnreintentos + 1
				if lnreintentos > lntope 
					throw loError
				else
					this.Esperar(500)
				endif
			endtry	
		enddo
	endfunc 

	function Esperar( tnMiliSegundos as Integer ) as Void
		DECLARE Sleep IN Win32API INTEGER nMilliseconds
		=sleep( tnMiliSegundos )
	endfunc

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		this.lDestroy = .t.
		
		this.oColProxy = null
		dodefault()
	endfunc 

	*-------------------------------------------------------------------------
	Function Serializar( toControles as Collection, tcArchivo as string ) as VOID
		with this
			.cArchivo = addbs( addbs( _screen.zoo.cRutaInicial ) + .cPath ) + tcArchivo + ".prg"
			.oColProxy = toControles
			try
				.GenerarEncabezado()
				.AgregarClasesProxys()
				.EscribirLibreriaEnDisco()
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarClasesProxys() as Void
		local lnI as Integer, loProxyClass as String
		for lnI = 1 to This.oColProxy.Count
			loProxyClass = This.oColProxy.Item( lnI )
			This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
			This.AgregarLinea( "Define Class " + loProxyClass.Clase + "Proxy as " + loProxyClass.ClaseBase + " of " + loProxyClass.Archivo + iif(lower(right(loProxyClass.Archivo,4))=".prg","",".prg"), 0 )
			This.AgregarLinea( "", 0 )
			This.AgregarLinea( "lTieneSaltoCampo = .F.", 1 )
			This.AgregarLinea( "lTieneSaltoDeCampoDefinidoPorElUsuario = .F.", 1 )
			This.AgregarLinea( "lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.", 1 )
			This.AgregarLinea( "", 0 )
			This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 1 )
			This.AgregarLinea( "Function Class_Access() as String ", 1 )
			This.AgregarLinea( "Return '" + loProxyClass.Clase + "'" , 2 )
			This.AgregarLinea( "EndFunc", 1 )
			This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 1 )
			This.AgregarLinea( "Function ClassLibrary_Access() as String ", 1 )
			This.AgregarLinea( "Return '" + lower( forceext( loProxyClass.Archivo, '.fxp' ) ) + "'" , 2 )
			This.AgregarLinea( "EndFunc", 1 )
			This.AgregarLinea( "", 0 )
			This.AgregarLinea( "EndDefine", 0 )
			This.AgregarLinea( "", 0 )
		EndFor
	endfunc 

enddefine
