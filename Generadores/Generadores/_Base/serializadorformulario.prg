define class serializadorformulario as zooSession of zooSession.prg

	cArchivo = ""
	cSeteos = ""
	cPath = "Generados\"
	oFormulario = null
	cRutaControl = "Thisform."
	cCreacionDeSinglentons = ""
	oMetadata = null
	cHerencia = "FormularioEdicion"
	nArchivo = 0
	lTieneMenuYToolbar = .t.
	cBuffer = ""
	oColProxy = Null
	cTipoDataSession = "2"
	oLibControles = null
	EsFormularioConLibreriaProxy = .f.
	
	*-----------------------------------------------------------------------------------------
	function AgregarLinea( tcTexto, tnTabs ) as Void
		local lcEnter as string, tcTabs as string
	
		if pcount() = 2 and tnTabs > 0
			tcTabs = replicate( chr( 9 ), tnTabs )
		else
			tcTabs = ""
		endif
		lcEnter = chr( 13 ) + chr( 10 )
		this.cBuffer = this.cBuffer + lcEnter + tcTabs + tcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivo() as Void
		this.nArchivo = fcreate( this.cArchivo )
		this.cBuffer = ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarArchivo() as Void
		=fwrite( this.nArchivo, this.cBuffer )
		=fclose( this.nArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function destroy() as Void
		this.lDestroy = .t.
		
		this.oFormulario = null
		this.oMetadata = null
		dodefault()
	endfunc 
	
	*-------------------------------------------------------------------------
	Function Serializar( toFormulario as form, toMetadata as object, tcArchivo as string ) as VOID
		with this
			.oColProxy = _Screen.Zoo.CrearObjeto( "zooColeccion" )
			.cArchivo = .cPath + tcArchivo + ".prg"
			.oFormulario = toFormulario
			.oMetadata = toMetadata
			.cSeteos = ""
			.cCreacionDeSinglentons = ""
			try
				.GenerarArchivo()
				.AgregarLinea( "define class " + tcArchivo + " as " + .cHerencia + " of " + .cHerencia + ".prg", 0 )
				.AgregarAtributos()
				.AgregarCuerpo()
				.AgregarLinea( "" )
				.AgregarLinea( "Enddefine", 0 )
				.AgregarLinea( "" )
				.AgregarLinea( "*"+replicate('-',60) )
				.AgregarClasesProxys()
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.CerrarArchivo()
			endtry

		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributos() as Void
		with this
			.AgregarLinea( "DataSession = " + this.cTipoDataSession, 1 ) &&Este formulario genera un nuevo DataSessionID privado.
			.AgregarLinea( "oEntidad = null", 1 )
			.AgregarLinea( "ColControles = null", 1 )
			.AgregarLinea( "lHayDatos = .F.", 1 )
			.AgregarLinea( "" )
			.AgregarAtributosMenu()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarCuerpo() as VOID
		with this
			.AgregarLinea( "" )
			.AgregarCabeceraInit()
			.AgregarLinea( "this.oEntidad = _screen.zoo.instanciarentidad( '" + .oMetadata.cEntidad + "' )", 2 )
			.AgregarLinea( "this.ColControles = newobject('collection')", 2 )
			.GrabarControl( .oFormulario, .f., 2 )
			.AgregarLinea( .cCreacionDeSinglentons )
			.AgregarLinea( .cSeteos, 0 )
			.AgregarLinea( "" )
			.SetearNombre( .oMetadata.Titulo )
			.SetearIcono()
			.SetearTitulo()
			.AgregarLinea( "this.NewObject( 'oAutocompletar', 'AutocompletarProxy' )", 2 )
			.AgregarProxy( "AutoCompletar", "AutoCompletar" )
			.AgregarLinea( "this.newobject( 'oKontroler', '" + .oMetadata.cClaseKontroler + "Proxy' )", 2 )
			.AgregarProxy( .oMetadata.cClaseKontroler, .oMetadata.cClaseKontroler )
			.AgregarLinea( "" )
			.AgregarLinea( "this.oKontroler.SetearEntidad( This.oEntidad )", 2 )
			.AgregarLinea( "this.oKontroler.Inicializar()", 2 )
			.AgregaroParche()
			if this.lTieneMenuYToolbar
				.AgregarLinea( "this.AgregarMenuYToolbar() ", 2 )
			else
				.AgregarLinea( "this.AgregarMenuYToolbarBasico() ", 2 )
			endif
			.AgregarLinea( "" )
			.AgregarLinea( "this.oKontroler.SetearPropiedadesDeComportamientoDeAtributos( this )", 2 )
			.AgregarLinea( "this.oKontroler.ActualizarFormulario()", 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "this.lHaydatos = this.oKontroler.HayDatos()", 2 )
			.AgregarLinea( "this.oKontroler.ActualizarBarra()", 2 )
			.AgregarPieDelInit()
			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCabeceraInit() as Void
		this.AgregarLinea( "function Init() as boolean", 1 )
		if this.cTipoDataSession == "2"	
			&& El DataSession = 2 abre una nueva Session, con un nuevo DataSessionID y es por esto que se tiene que
			&& Volver a reconfigurar todos los SET que en la mayoria de los casos hace el ZooSession
			this.AgregarLinea( "ConfigurarSeteosPrivadosDeLaSesion()", 2 )
		endif
		if this.EsFormularioConLibreriaProxy
			this.AgregarLinea( "if at(upper('LibProxyControles'),upper(set('proc'))) = 0", 2)
			this.AgregarLinea( "set procedure to LibProxyControles add", 3 )
			this.AgregarLinea( "endif", 2)
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function AgregarPieDelInit() Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "this.DespuesDelInit()", 2 )
			.AgregarLinea( "this.AgregarStatusBar()", 2 )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregaroParche()  as Void
		with this
			.AgregarLinea( "this.Newobject( 'oParche', 'TextBox' )", 2 )
			.AgregarLinea( "With this.oParche", 2 )
			.AgregarLinea( ".Width = 0", 3 )
			.AgregarLinea( ".Height = 0", 3 )
			.AgregarLinea( ".Top = -100", 3 )
			.AgregarLinea( ".Left = -100", 3 )
			.AgregarLinea( ".Visible = .T.", 3 )
			.AgregarLinea( "Endwith", 2 )
		endwith

	endfunc 

	*-------------------------------------------------------------------------
	Function SetearNombre( tcTitulo as string ) as void
		this.AgregarLinea( "this.name = '" + alltrim( strtran( strtran( strtran( tcTitulo, "-", "" ), " ", "" ), "/", "" ) ) + "'", 2 )
	endfunc

	*-------------------------------------------------------------------------
	Function SetearIcono() as void
		local lcIcono as string
		lcIcono = "Icono" + alltrim( _Screen.Zoo.App.cProyecto ) + ".ico"

		if !file( lcIcono )
			lcIcono = goControles.ObtenerIconoDefaultDeLosFormularios()
		endif
		
		this.AgregarLinea( "this.icon = _screen.zoo.app.oAspectoAplicacion.ObtenerIconoDeLaAplicacion()", 2 )
	endfunc
	
	*-------------------------------------------------------------------------
	Function SetearTitulo() as void
		local lcTitulo as String
		
		with this
			lcTitulo = alltrim( .oMetadata.Titulo )
			.AgregarLinea( "this.caption = '" + lcTitulo + "'", 2 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SePuedeSerializar( toControl as Object ) as boolean
		local llRetorno as boolean
		
		llRetorno = !inlist( alltrim( upper( toControl .name ) ), "CBM", "MAINMENU", "TOOLBAR1", "OPARCHE", "OMEMORIA" ) and ;
					!inlist( alltrim( upper( toControl .Class ) ), "ZOOBARRADESPLAZAMIENTO" ) and ;
					!inlist( alltrim( upper( toControl .Class ) ), "ZOOBARRADESPLAZAMIENTOCONTENEDOR" )

		return llRetorno 
	endfunc 
		
	*-------------------------------------------------------------------------
	Function GrabarControl( toControl As Object, tlCreaObjeto as boolean, tnTab as integer ) as void
		Local loctrl As Object, lopage As Object, locolu As Object,	lcclass As Character, ;
			lnkey As Integer, lckey As Character, lnretval As Integer, lnControl as object, ;
			lnPage, lnColumna, lcTabs, loItem
		
		if upper(alltrim(toControl.baseclass)) # "FORM"
			this.cRutaControl = this.cRutaControl + alltrim(upper(toControl.name ))+"."
		endif 	
	
		if this.SePuedeSerializar( toControl )
			This.SerializarControl( toControl, tlCreaObjeto, tnTab )
		endif
		
		lnControl = 1
		For lnControl = 1 to toControl.ControlCount 
			loctrl = toControl.Controls[ lnControl ]
			
			If !Pemstatus( loctrl, "BaseClass", 2 )
				if this.SePuedeSerializar( loctrl )
					lcclass = Upper(loctrl.BaseClass)

					Do Case
						Case  lcclass = 'PAGEFRAME'
							this.cRutaControl = this.cRutaControl + alltrim(upper(loCtrl.name ))+"."							
							This.SerializarControl( loCtrl, .t., tnTab+1 )
							
							For lnPage = 1 to loCtrl.PageCount
								loPage = loCtrl.Pages[ lnPage ]
								This.GrabarControl(lopage, .f., tnTab+2 )
								this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
								this.AgregarLinea( "thisform.ColControles.add('" + this.cRutaControl + loPage.Name + "','" + ;
										strtran( alltrim( upper( loPage.Caption ) ), " ", "_" ) + "_" + alltrim( upper( loPage.Name ) )+ "')", tnTab )
							endfor
							if occurs(".",this.cRutaControl) >1
								this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
							endif
							this.FinSerializarControl( loCtrl, tnTab+1 )

						Case lcclass = 'GRID'
							This.SerializarControl( loCtrl, .t., tnTab+1 )

							lnCantidadColumnas = iif( lower( loCtrl.class ) = "grillatalle", 1, 2)

							For lnColumn = lnCantidadColumnas to loCtrl.ColumnCount 
								loColu = loCtrl.Columns[ lnColumn ]
								This.GrabarControl(locolu, .f., tnTab+2 )
								this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
							endfor

							if occurs(".",this.cRutaControl) >1 and lower( loCtrl.class ) != "grillatalle"
								this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
							endif

							this.FinSerializarControl( loCtrl, tnTab+1 )

						Case Pemstatus(loctrl, 'ControlCount', 5)
							This.GrabarControl(loCtrl, .t., tnTab+1 )
							
							this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
							
						case loctrl.baseclass = "Container" and inlist( upper( loctrl.Class  ), "'ZOOGRILLAEXTENSIBLE'", "'GRILLAEXTCOMPECOMMERCE'" ) 
									
							This.SerializarControl( loCtrl, .t., tnTab+1 )

						otherwise
							if upper(alltrim(toControl.baseclass)) # "FORM"
								this.cRutaControl = this.cRutaControl + alltrim(upper(loCtrl.name ))+"."
							endif 	
					
							This.SerializarControl( loCtrl, .t., tnTab+1 )
							this.FinSerializarControl( loCtrl, tnTab+1 )
					
							if upper(alltrim(toControl.baseclass)) # "FORM"
								this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
							endif 	
					
					Endcase
				endif
			Endif
		endfor
		
		if this.SePuedeSerializar( toControl )
			this.FinSerializarControl( toControl, tnTab )
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	function SerializarObjeto( tcPropiedad as string, toObjeto as object, tnTab as Integer ) as Void
		local lcTabs, laItem, lcPropiedad, tcTexto, lxValor, lnCantidadItems as integer
		local lcClase, oBaseClass
		dimension laItem(1)
		
		lcTabs = replicate( chr(9), tnTab )
		
		lnCantidadItems = amembers( laItem, toObjeto, 0, "U" )


		if lnCantidadItems > 0

			this.AgregarLinea( "with ." + tcPropiedad, tnTab )
			lcClase = upper( alltrim( toObjeto.Class ) )
			oBaseClass = this.ObtenerBaseClass( lcClase , toObjeto.ClassLibrary )

			for each lcPropiedad in laItem foxobject
				if vartype( lcPropiedad ) = "C" and this.ValidarPropiedad( lcPropiedad, toObjeto )
					lxValor = toObjeto.&lcPropiedad

					if isnull( lxValor ) or vartype(lxValor)="O"
						lcTexto = "." + lcPropiedad + " = null"
					else
						if pemstatus(oBaseClass, lcPropiedad, 5) and vartype(oBaseClass.&lcPropiedad) = vartype( lxValor ) and oBaseClass.&lcPropiedad = lxValor
							&& es igual al default se salta
						else
							lcTexto = "." + lcPropiedad + " = " +  goLibrerias.ValorAString( lxValor )
						endif
					endif
					
					this.AgregarLinea( lcTexto, tnTab + 1 )
				endif
			endfor

			this.AgregarLinea( "endwith", tnTab )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SerializarControl( toControl as object, tlCreaObjeto as boolean, tnTab as integer ) as Void
		local lcTabs, laItem, lcPropiedad, tcTexto, lxValor, lcClase as String, lcClasePadre as String, ;
			  lcPrg as String, lcClaseBase, lcTexto, laItem, lcPropiedad, lcTabs

		with this		
			
			dimension laItem(1)
			
			lcClase = upper(alltrim( toControl.Class ) )
			lcClasePadre = upper(alltrim( toControl.ParentClass ) )
			lcClaseBase = upper(alltrim( toControl.BaseClass ) )
			
			lcPrg = lcClase
			
			if .NoEsSingleton( lcClase, lcClasePadre )
				.AgregarLinea( "" )
				.AgregarLinea( "************* " + toControl.name + "/" + toControl.class + "/" + toControl.baseclass, tnTab )

				if tlCreaObjeto
					.AgregarCreacionDeControl( toControl, tnTab )
				endif
				
				this.ActualizarColeccionControles( toControl, tnTab )
				
				.AgregarLinea( "" )
				if lcClaseBase == 'FORM'
					.AgregarLinea( "with this", tnTab )
				else
					.AgregarLinea( "with ." + toControl.name, tnTab )
				endif
				
				.SetearValoresPropiedadesIndispensables( toControl, tnTab+1 )
				.AgregarSeteosAntesDeSerializar( toControl, tnTab+1 )
				.AgregarLinea( "" )

				if lcClaseBase # 'FORM'
					.AgregarPropiedadesNoDefinidas( toControl, tnTab+1 )
					.AgregarLinea( "" )
				endif

				.SetearValoresPropiedades( toControl, tnTab+1 )
				.AgregarSeteosDespuesDeSerializar( toControl, tnTab+1 )
			else				 
				.cCreacionDeSinglentons = .cCreacionDeSinglentons + "" + chr( 13 )
				.cCreacionDeSinglentons = .cCreacionDeSinglentons + ;
					chr( 9 ) + chr( 9 ) + "************* " + toControl.name + "/" + toControl.class + "/" + ;
					toControl.baseclass + chr( 13 )
				.cCreacionDeSinglentons = .cCreacionDeSinglentons + ;
					chr( 9 ) + chr( 9 ) + "this.newobject( '" + toControl.name + "', '" + lcClase + "', '"+lcPrg +".prg')" + chr( 13 )
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarColeccionControles( toControl as Object, tnTab as Integer ) as Void
		local lcRuta as String 
		
		lcRuta = substr(this.cRutaControl,1,len(this.cRutaControl)- 1)

		if pemstatus(toControl,"cAtributo",5) and !empty(toControl.cAtributo) and !inlist( toControl.baseclass , 'Form')
			if pemstatus(toControl,"ControlSource",5) 
				this.ActualizarColConControlSource( toControl, tnTab, lcRuta )
			else
	 			this.ActualizarColSinControlSource( toControl, tnTab, lcRuta )	
			endif	

		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarColConControlSource( toControl as Object , tnTab as Integer, tcRuta as String ) as Void
		local lcCadena as String , lcAtributo as String 
		lcCadena = "thisform.ColControles.add('" + tcRuta + "','"
		lcAtributo = ""
		if toControl.lEsSubentidad
			if empty( toControl.cAtributoPadre ) 
				lcAtributo =  alltrim( toControl.parent.cAtributo ) + "_" + alltrim( toControl.cAtributo )
			else
				if "CAMPO_" $ upper( toControl.name ) 
					lcAtributo = alltrim( toControl.parent.cAtributo ) + "_" + alltrim( toControl.cAtributoPadre ) + "_" + alltrim( toControl.name ) 
				else
					lcAtributo = alltrim( toControl.cAtributoPadre )
				endif
				
				if pemstatus( toControl, "lClavePrimaria", 5 ) and toControl.lClavePrimaria
				else
					lcAtributo = lcAtributo + "_" + alltrim( toControl.cAtributo )
				endif
			endif
		else
			if "CAMPO_" $ upper( toControl.name )
				lcAtributo = alltrim( toControl.parent.cAtributo ) + "_" + alltrim( toControl.cAtributo ) + "_" + alltrim( toControl.name )
			else
				if pemstatus(toControl,"cCampoTotal",5)
					lcAtributo = alltrim( toControl.cAtributo ) + alltrim( toControl.cCampoTotal ) + alltrim( toControl.cEntidad ) 
				else
					lcAtributo = alltrim( toControl.cAtributo )
				endif	
			endif	
		endif
		this.AgregarLinea( lcCadena + upper( lcAtributo )+ "')", tnTab )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarColSinControlSource( toControl as Object , tnTab as Integer, tcRuta as String  ) as Void
		local lcCadena as String , lcAtributo as String 
		
		lcCadena = "thisform.ColControles.add('" + tcRuta + "','"
		lcAtributo = ""
		
		if inlist( upper( alltrim( toControl.Class )), "ZOOGRILLAEXTENSIBLE", "GRILLAEXTCOMPECOMMERCE" ) or pemstatus( toControl, "cAssembly", 5 )		
			lcAtributo = alltrim( toControl.cAtributo )
		else
			lcAtributo = alltrim( toControl.cAtributo ) + "_" + alltrim( toControl.name )
		endif

		if !empty( lcAtributo )
			this.AgregarLinea( lcCadena + upper( lcAtributo )+ "')", tnTab )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FinSerializarControl( toControl as Object, tnTab as Object ) as void
		local i as integer, lcControlOrigen as string, lcClase as String, lcClasePadre as String
		
		lcClase = upper( alltrim( toControl.Class ) )
		lcClasePadre = upper( alltrim( toControl.ParentClass ) )
		with this
			if .NoEsSingleton( lcClase, lcClasePadre )
				.AgregarLinea( "" )
				.AgregarLinea( "endwith", tnTab )
				.AgregarEventos( toControl, tnTab )
				.AgregarLinea( "" )
			endif
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarEventos( toControl as Object, tnTab as integer ) as void
		local lcDestino as string, lcControl as string, lcOrigen as String, lcDestino as string
		
		with this
			if pemstatus( toControl, "aEventos", 5 ) and alen( toControl.aEventos, 1 ) > 0
				.AgregarLinea( "*------------------ Eventos " + toControl.name, tnTab )
				
				for i = 1 to alen( toControl.aEventos, 1 ) 
					if !empty( toControl.aEventos[ i, 1 ] )
						if upper( toControl.baseclass ) == "FORM"
							lcControl = "thisform"
						else
							lcControl = "." + toControl.name
						endif
						
						lcOrigen = alltrim( toControl.aEventos[ i, 1 ] )
						if left( lower( lcOrigen ), 8 ) != "thisform"
							lcOrigen = lcControl + lcOrigen 
						endif
						
						lcDestino = alltrim( toControl.aEventos[ i, 3 ] )
						if left( lower( lcDestino ), 8 ) != "thisform"
							lcDestino = lcControl + lcDestino 
						endif
						
						.AgregarLinea( "bindevent( " + ;
									lcOrigen + ", " +;
									"'" + alltrim( toControl.aEventos[ i, 2 ] ) + "', " + ;
									lcDestino + ", " + ;
									"'" + alltrim( toControl.aEventos[ i, 4 ] ) + "', " + ;
									goLibrerias.ValorAString( toControl.aEventos[ i, 5 ] ) + " ) " ;
									, tnTab )
					endif
				endfor
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarSeteosAntesDeSerializar( toControl, tnTab ) as Void
		local lcTexto as string 
		if pemstatus( toControl, "AntesDeSerializar", 5 )
			lcTexto = toControl.AntesDeSerializar()
			.AgregarLinea( lcTexto )
		endif

	endfunc 
	*-----------------------------------------------------------------------------------------
	function AgregarSeteosDespuesDeSerializar( toControl, tnTab ) as Void
		local lcTexto as string 
		if pemstatus( toControl, "DespuesDeSerializar", 5 )
			lcTexto = toControl.DespuesDeSerializar()
			.AgregarLinea( lcTexto )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarCreacionDeControl( toControl as object, tnTab as integer ) as void
		local lcTabs as String, lcClase as string, lcBaseClase as string, lcClasePadre as string
		
		lcClase = upper(alltrim(toControl.Class))
		lcClasePadre = upper(alltrim(toControl.parentClass))
		lcBaseClase = upper(alltrim(toControl.BaseClass))
		with this
			if lcClase = lcBaseClase
				.AgregarLinea( "if type( '." + toControl.name + "' ) # 'O'", tnTab )
				.AgregarLinea( ".newobject( '" + toControl.name + "', '" + lcClase + "' )", tnTab )
				.AgregarLinea( "endif", tnTab )
			else
				if upper(alltrim( lcClase)) = "NETBASECONTROL"
					.AgregarLinea( "_screen.NetExtender.AgregarControlVisual( loControl, '" + toControl.name + "', '" + toControl.ccontrolclass +"' ,'"+ toControl.cassembly+"')", tnTab )			
				else
					.AgregarLinea( .ComandoDeCreacionConProxy( toControl ), tnTab )
					.AgregarProxy( lcClase, lcClase, toControl )
					if pemstatus( toControl, "cAssembly", 5 )
						.AgregarLinea( "local loControl ", tnTab )
						.AgregarLinea( "loControl = ." + alltrim( toControl.name ), tnTab )				
					endif 		
				endif	
			endif
		endwith

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ComandoDeCreacionConProxy( toControl as object ) as String
		local lcComando as String, lcClaseProxy as String
		lcClaseProxy = upper(alltrim(toControl.Class))+ "Proxy"
		lcComando = ".newobject( '" + toControl.name + "', '" + lcClaseProxy + "',, '', 'NO')"
		
		return lcComando
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadesNoDefinidas( toControl as Object, tnTab as integer ) as void
		local laItem as Object, lcPropiedad as string, lcValor as variant, ;
			lcTexto as string

		dimension laItem(1)
		
		amembers( laItem, toControl, 0 , "B" )

		for each lcPropiedad in laItem foxobject
			if vartype( lcPropiedad ) = "C"
				lxValor = toControl.&lcPropiedad
				
				do case
					case isnull( lxValor )
						lcTexto = ".addproperty( '" + lcPropiedad + "', null )"
						this.AgregarLinea( lcTexto, tnTab )
							
					case vartype(lxValor)="O"
						lcTexto = ".addproperty( '" + lcPropiedad + "', null )"
						this.AgregarLinea( lcTexto, tnTab )

						if this.SetearValorObjeto( toControl, lcPropiedad, tnTab )
							this.SerializarObjeto( lcPropiedad, lxValor, tnTab )
						endif
							
					otherwise			
						lcTexto = ".addproperty( '" + lcPropiedad + "', " + goLibrerias.ValorAString( lxValor ) + ")"
						this.AgregarLinea( lcTexto, tnTab )
				endcase
			endif
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearValoresPropiedadesIndispensables( toControl as Object, tnTab as integer ) as Void
		local lcTexto as String

		with this
			if pemstatus( toControl, "THEMES", 5 )
				lcTexto = ".THEMES = " + goLibrerias.ValorAString( toControl.THEMES )
				.AgregarLinea( lcTexto, tnTab )
			endif

			if pemstatus( toControl, "TABS", 5 )
				lcTexto = ".TABS = " + goLibrerias.ValorAString( toControl.TABS )
				.AgregarLinea( lcTexto, tnTab )
			endif
			
			if pemstatus( toControl, "OENTIDAD", 5 )
				.SetearValorObjeto( toControl, "OENTIDAD", tnTab )
			endif

			if pemstatus( toControl, "DISABLEDPICTURE", 5 )
				lcTexto = .ObtenerSeteoImagen( "DISABLEDPICTURE", toControl.DisabledPicture )
				.AgregarLinea( lcTexto, tnTab )
			endif

			if pemstatus( toControl, "PICTURE", 5 )
				if Pemstatus( toControl, "cExpresionRutaDinamica", 5 ) and !empty( toControl.cExpresionRutaDinamica )
					lcTexto = ".PICTURE = " + toControl.cExpresionRutaDinamica
				else
					lcTexto = .ObtenerSeteoImagen( "PICTURE", toControl.Picture )
				endif
				.AgregarLinea( lcTexto, tnTab )
			endif

			if pemstatus( toControl, "ICON", 5 ) and toControl.baseclass # "Form"
				lcTexto = .ObtenerSeteoImagen( "ICON", toControl.Icon )
				.AgregarLinea( lcTexto, tnTab )
			endif
			
			if pemstatus( toControl, "CATRIBUTOPADRE", 5 )
				lcTexto = ".CATRIBUTOPADRE= " + goLibrerias.ValorAString( toControl.CATRIBUTOPADRE)
				.AgregarLinea( lcTexto, tnTab )
			endif
			if pemstatus( toControl, "NCANTIDADITEMSVISIBLES", 5 )
				lcTexto = ".NCANTIDADITEMSVISIBLES= " + goLibrerias.ValorAString( toControl.NCANTIDADITEMSVISIBLES)
				.AgregarLinea( lcTexto, tnTab )
			endif			

		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerSeteoImagen( tcPropiedad as String, tcImagen as string ) as String
		local lcRetorno as string
		lcRetorno = "." + tcPropiedad + " = '" + justfname( tcImagen ) + "'"

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsPropiedadIndispensable( tcPropiedad as String ) as boolean
		return inlist( upper( alltrim( tcPropiedad ) ), "THEMES", "TABS", "OENTIDAD", "VISIBLE", "AUTOCENTER", "PICTURE", "DISABLEDPICTURE", "ICON", "LGUARDAMEMORIA","CATRIBUTOPADRE","NCANTIDADITEMSVISIBLES")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValoresPropiedades( toControl as Object, tnTab as integer ) as Void
		local lcTexto as String, lxValor as Variant, laItem as Object,;
			lcPropiedad as string, llEsUnaMatriz as boolean, lcClase as String
		local oBaseClass as Object, lSaltarSeteoPorSerIgualADefault as Boolean, lcClase as string 
		dimension laItem( 1 )
		amembers( laItem, toControl )

		lcClase = upper( alltrim( toControl.Class ) )
		oBaseClass = this.ObtenerBaseClass( lcClase , toControl.ClassLibrary )

		for each lcPropiedad in laItem foxobject
			if !this.EsPropiedadIndispensable( lcPropiedad )
				llEsUnaMatriz = this.EsUnaMatriz( lcPropiedad, toControl )
				if llEsUnaMatriz or this.ValidarPropiedad( lcPropiedad, toControl )
					lxValor = toControl.&lcPropiedad
					do case
						case isnull( lxValor )
							lcTexto = "." + lcPropiedad + " = null"
							this.AgregarLinea( lcTexto, tnTab )

						case vartype( lxValor ) = "O" and !llEsUnaMatriz
							if this.SetearValorObjeto( toControl, lcPropiedad, tnTab )
								this.SerializarObjeto( lcPropiedad, lxValor, tnTab )
							endif

						case llEsUnaMatriz = .f.
							try
								lSaltarSeteoPorSerIgualADefault = .f.
								lcTexto = lcPropiedad + " = " + goLibrerias.ValorAString( lxValor )
								if pemstatus(oBaseClass, lcPropiedad, 5) and vartype(oBaseClass.&lcPropiedad) = vartype( lxValor ) and oBaseClass.&lcPropiedad = lxValor
										lSaltarSeteoPorSerIgualADefault = .t.
								endif

								if this.ClaseEnLibreriaProxy( lcClase ) or !this.ClaseEnProxyLocal(lcClase) or !this.EsPropiedadDeClaseProxy( lcPropiedad ) && or  && this.oLibControles.GetKey[lcClase] # 0
									if !lSaltarSeteoPorSerIgualADefault 
										this.AgregarLinea( "." + lcTexto, tnTab )
									*else
									*	strtofile(lcClase+":"+lcPropiedad+chr(13)+chr(10),"c:\temp\pruebaserializacion.log",1)
									endif
								else
									this.IncluirPropiedadEnProxy( toControl.Class, lcTexto )
								endif
								
							catch to llEr
								goServicios.Errores.LevantarExcepcion( llEr )
							endtry
						otherwise
							if upper( alltrim( lcPropiedad ) ) = "AGRILLA"
								this.SerializarMatrizGrilla( lcPropiedad, toControl, tnTab )
							endif
					endcase
				endif
			endif
		endfor
		if pemstatus( toControl, "VISIBLE", 5 ) and upper(alltrim( toControl.baseclass ) ) # "FORM"
			lcTexto = ".VISIBLE = " + goLibrerias.ValorAString( toControl.Visible )
			this.AgregarLinea( lcTexto, tnTab )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerBaseClass( tcClaseBase, tcClaseLibrary )
		local lxRetorno, loClaseX, lxEx, lxObjeto
		try 
			if pemstatus(_screen, "oFormTemSerializador",5 )
				if isnull(_screen.oFormTemSerializador)
					_screen.oFormTemSerializador = createobject( "form" ) 
				endif
			else
				_screen.AddProperty("oFormTemSerializador", createobject( "form" ) )
			endif
				
			if pemstatus(_screen, "oFormTemSerializador",5 ) and !isnull(_screen.oFormTemSerializador) and !pemstatus(_screen.oFormTemSerializador, tcClaseBase,5) 
				_screen.oFormTemSerializador.newobject(tcClaseBase, tcClaseBase, strtran(lower(tcClaseLibrary),".fxp",".prg"),, 'NO')
			endif
			
			lxRetorno = _screen.oFormTemSerializador.&tcClaseBase
			
		catch to lxEx
			&& en caso que no logre instanciar la clase o devolver su singleton, devuelve una clase de tipo empty
			&& para evitar errores en la serializacion
			lxRetorno = createobject("empty")
		endtry
		return lxRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsUnaMatriz( tcPropiedad as string, toControl as Boolean ) as boolean
		return type( "alen( toControl.&tcPropiedad )" ) = "N" 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SerializarMatrizGrilla( tcPropiedad as string, toControl as Object, tnTab as integer ) as Void
		local loElemento as object, i as integer, lnCantidad as Integer, lxItem as variant
		with this
			.AgregarLinea( "Dimension ." + tcPropiedad + "( " + goLibrerias.ValorAString( alen( toControl.&tcPropiedad ) ) + " )", tnTab )
			lnCantidad = alen( toControl.&tcPropiedad, 1 )
			for i = 1 to lnCantidad
				lxItem = toControl.&tcPropiedad[ i ]
				.AgregarLinea( "local loColumna", tnTab )
				if vartype( lxItem ) = "O"
					.AgregarLinea( "loColumna = newobject( '" + lxItem.Class+ "Proxy' )", tnTab )
					.AgregarProxy( lxItem.Class, 'zooGrillaExtensible' )
					.AgregarLinea( "with loColumna", tnTab )
					.AgregarPropiedadesNoDefinidas( lxItem, tnTab + 1 )
					.SetearValoresPropiedades( lxItem, tnTab+1 )
					.AgregarLinea( "endwith", tnTab )
					.AgregarLinea( "." + tcPropiedad + "[ " + goLibrerias.ValorAString( i ) + " ] = loColumna", tnTab )
				else
					this.AgregarLinea( "." + tcPropiedad + "[ " + goLibrerias.ValorAString( i ) + " ] = " + goLibrerias.ValorAString( lxItem ), tnTab )
				endif
			endfor
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearValorObjeto( toControl as Object, tcPropiedad as String, tnTab as Integer ) as boolean
		local	lcNombre as string, lcSeteos as string, lcClase as String, llRetorno as Boolean,  lcBaseClase as String, ;
				llSerializar as Boolean, lcTexto As String
		lcTexto = ""
		llRetorno = .f.
		
		with this
			lcNombre	= upper( alltrim( toControl.name ) )
			lcBaseClase	= upper( alltrim( toControl.baseclass ) )
			lcClase		= upper( alltrim( toControl.class ) )
			lcSeteos	= ""
			do case
				case lcBaseClase # "FORM" and tcPropiedad = "OENTIDAD"
					lcTexto = this.ObtenerTextoOrigenDeDatos( toControl )
					
				case lcNombre = "PNLGRUPOS" and tcPropiedad = "OSOLAPAS"
					lcSeteos  = "this.pnlGrupos.oSolapas = this.pnlGruposSolapa"

				case lcNombre = "PNLGRUPOSSOLAPA" and tcPropiedad = "OPAGEFRAME"
					lcSeteos  = "this.pnlGruposSolapa.oPageFrame = this.pnlGrupos"

				case tcPropiedad = "OSERVICIOGRILLA"
					lcTexto  = "_screen.zoo.crearobjeto( 'ServicioGrilla' )"
					llRetorno = .t.

				case !inlist( lcBaseClase, "ZOOGRILLAEXTENSIBLE", "GRILLAEXTCOMPECOMMERCE" ) and tcPropiedad = "ODETALLE"				
					lcTexto  = ".oEntidad.ObtenerValorAtributo( .cAtributo )"

				case tcPropiedad = "OAUTOCOMPLETAR"
					lcTexto  = "_screen.zoo.crearobjeto( 'AutoCompletar' )"
					llRetorno = .t.
				
				case inlist( lcClase, 'RUTAARCHIVO', 'IMAGEN', 'RUTAARCHIVOIMAGENDINAMICA' ) and tcPropiedad = 'ODATOS'
					lcTexto  = "_screen.zoo.crearobjeto( 'ManejoArchivos' )"
					llRetorno = .t.

				case inlist( lcClase, 'RUTAARCHIVOTRANSFERENCIAS', 'IMAGEN' ) and tcPropiedad = 'ODATOS'
					lcTexto  = "_screen.zoo.crearobjeto( 'ManejoArchivos' )"
					llRetorno = .t.
			endcase

			.cSeteos  = .cSeteos + iif( !empty( lcSeteos ), chr( 13 ) + chr( 10 ) + lcSeteos, "" )
		endwith
		
		if !empty( lcTexto )
			lcTexto = "." + tcPropiedad + " = " + lcTexto
			this.AgregarLinea( lcTexto, tnTab )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTextoOrigenDeDatos( toControl as Object ) as String
		local lcTexto as String
		
		if pemstatus( toControl, "oEntidad", 5 )
			lcTexto  = "thisform.oEntidad"
			if toControl.lEsSubEntidad
				lcTexto  = lcTexto + "."
				if pemstatus( toControl, "lDetalle", 5 ) and toControl.lDetalle and inlist( upper( toControl.parent.class ), "ZOOGRILLAEXTENSIBLE", "GRILLAEXTCOMPECOMMERCE" )
					lcTexto = lcTexto + alltrim( toControl.Parent.cAtributo )
					lcTexto  = lctexto + ".oItem."
				endif
				if !empty( tocontrol.cAtributoPadre ) 
					lcTexto  = lcTexto + alltrim( toControl.cAtributoPadre )
				else 
					lcTexto  = lcTexto + alltrim( toControl.parent.cAtributo )
				endif
			endif
		else
			lcTexto = "null"
		endif
		
		return lcTexto
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ValidarPropiedad( tcPropiedad as string, toControl as object ) as boolean
		local llRetorno as Boolean
		llRetorno = .t.
		try
			if llRetorno and pemstatus( toControl, tcPropiedad, 1 )
				llRetorno = .f.
			endif
			if llRetorno and pemstatus( toControl, tcPropiedad, 2 )
				llRetorno = .f.
			endif
			if llRetorno and !pemstatus( toControl, tcPropiedad, 0 )
				llRetorno = .f.
			endif
		catch
			llRetorno = .f.
		endtry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function NoEsSingleton( tcClase as String, tcClasePadre as String ) as Boolean
		return ( !inlist( tcClase, "AUTOCOMPLETAR" ) and !( "kontroler" $ lower( tcClase ) ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarAtributosMenu() as Void
		local laItem as Object, lcPropiedad as string, lxValor as variant, lcTexto as string

		with this
			dimension laItem(1)
			amembers( laItem, .oFormulario , 0 , "B" )

			for each lcPropiedad in laItem foxobject
				if vartype( lcPropiedad ) = "C" and upper( left( lcPropiedad, 13 ) ) == "LDESHABILITAR"
					if pemstatus( .oFormulario, lcPropiedad, 5 )
						lxValor = .oFormulario.&lcPropiedad
						lcTexto = lcPropiedad + " = " + goLibrerias.ValorAString( lxValor )
						this.AgregarLinea( lcTexto, 2 )
					endif
				endif
			endfor
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarProxy( tcClase as String, tcLibreria as String, toControl as Object ) as Void
		local lcClaseProxy as String, lcClase as String, lcLibreria as String, loProxyClass as Custom
		lcClaseProxy = upper( tcClase ) + "PROXY"
		if This.oColProxy.Buscar( lcClaseProxy )
		else
			loProxyClass = newobject( "ProxyClass" )
			loProxyClass.cClaseProxy = lcClaseProxy
			loProxyClass.cClaseProxy = lcClaseProxy
			loProxyClass.cClase = tcClase
			loProxyClass.cLibreria = tcLibreria + ".prg"
			if ( vartype( toControl ) == "O" ) and pemstatus( toControl, "oItem", 5 ) and ( vartype( toControl.oItem ) == "O" )
				loProxyClass.lContieneMetadata = .t.
				loProxyClass.oMetadata = toControl.oItem
			endif
			loProxyClass.oSeteoInicial = newobject( "zoocoleccion", "zoocoleccion.prg" )
			This.oColProxy.Agregar( loProxyClass, lcClaseProxy )
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarClasesProxys() as Void
		local lnI as Integer, loProxyClass as Object, lcClase as String
		for lnI = 1 to This.oColProxy.Count
			loProxyClass = This.oColProxy.Item( lnI )
			lcClase = upper(alltrim(loProxyClass.cClase))
			if !this.EsFormularioConLibreriaProxy or !this.ClaseEnLibreriaProxy(lcClase) && this.oLibControles.GetKey[lcClase] = 0
				This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
			This.AgregarLinea( "Define Class " + loProxyClass.cClaseProxy + " as " + loProxyClass.cClase + " of " + loProxyClass.cLibreria, 0 )
				This.AgregarLinea( "", 0 )
				This.AgregarLinea( "lTieneSaltoCampo = .F.", 1 )
				This.AgregarLinea( "lTieneSaltoDeCampoDefinidoPorElUsuario = .F.", 1 )
				This.AgregarLinea( "lEsAtributoNoEditableEnEntidadConEdicionRestringida = .F.", 1 )
				if loProxyClass.oSeteoInicial.Count > 1
					for each lcSeteoPropidad in loProxyClass.oSeteoInicial FOXOBJECT
						This.AgregarLinea(lcSeteoPropidad,1)
					next
				endif
				This.AgregarLinea( "Function Class_Access() as String ", 1 )
					This.AgregarLinea( "Return '" + loProxyClass.cClase + "'" , 2 )
				This.AgregarLinea( "EndFunc", 1 )
			This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
				This.AgregarLinea( "Function ClassLibrary_Access() as String ", 1 )
					This.AgregarLinea( "Return '" + lower( forceext( loProxyClass.cLibreria, '.fxp' ) ) + "'" , 2 )
				This.AgregarLinea( "EndFunc", 1 )
			This.AgregarLinea( "*------------------------------------------------------------------------------------------------------------", 0 )
				This.AgregarLinea( "Function ParentClass_Access() as String ", 1 )
					This.AgregarLinea( "Local Array laInfoClase[ 1 ]" , 2 )
					This.AgregarLinea( "aclass( laInfoClase, this )" , 2 )
					This.AgregarLinea( "Return laInfoclase[ 3 ]" , 2 )
				This.AgregarLinea( "EndFunc", 1 )
				This.AgregarLinea( "", 0 )
			This.AgregarLinea( "EndDefine", 0 )
			endif
		EndFor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsPropiedadDeClaseProxy( tcPropiedad as String ) as Boolean
		local llRetorno
		llRetorno = inlist( tcPropiedad,"BACKCOLOR","BACKSTYLE","BORDERCOLOR","BORDERSTYLE","DISABLEDBACKCOLOR","DISABLEDFORECOLOR","FONTBOLD","FONTITALIC","FONTNAME","FONTSIZE","FORECOLOR","NBACKCOLORCLARO","NBACKCOLORCONFOCO","NBACKCOLORNORMAL","NBACKCOLOROBLIGSINFOCO","NBACKCOLORSINFOCO","NDISABLEDBACKCOLORCLARO","NDISABLEDBACKCOLORNORMAL","NFORECOLORCONFOCO","NFORECOLOROBLIGSINFOCO","NFORECOLORSINFOCO","SELECTEDBACKCOLOR","SELECTONENTRY","SPECIALEFFECT")
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IncluirPropiedadEnProxy( tcClase as String, tcPropiedad as String ) as Void
		local lcClaseProxy as String
		lcClaseProxy = upper( tcClase ) + "PROXY"
		if This.oColProxy.Buscar( lcClaseProxy )
			loControlProxy = This.oColProxy(lcClaseProxy)
			if !loControlProxy.oSeteoInicial.Buscar( tcPropiedad )
				loControlProxy.oSeteoInicial.Agregar( tcPropiedad, tcPropiedad )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ClaseEnLibreriaProxy( tcClase as String) as Boolean
		local llRetorno as Boolean, lcClase as String
		lcClase = alltrim(tcClase)
		llRetorno = type( "this.oLibControles" ) = "O" and !isnull(this.oLibControles) and this.oLibControles.GetKey[lcClase] # 0
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ClaseEnProxyLocal( tcClase as String) as Boolean
		local llRetorno as Boolean, lcClase as String
		lcClase = upper(tcClase + "PROXY")
		llRetorno = type( "this.oColProxy" ) = "O" and !isnull(this.oColProxy) and this.oColProxy.Buscar( lcClase )
		return llRetorno
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
define class ProxyClass as Custom
	cClaseProxy = ""
	cClase = ""
	cLibreria = ""
	lContieneMetadata = .f.
	oMetadata = null
	oSeteoInicial = null
enddefine
