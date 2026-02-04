define class serializador as zooSession of zooSession.prg

	cArchivo = ""
	cSeteos = ""
	cPath = "Generados\"
	oFormulario = null
	cRutaControl = "Thisform."
	cCreacionDeSinglentons = ""
	
	*** nuevas
	cHerencia = "zooForm.vcx"
	nArchivo = 0
	
	cBuffer = ""
	
	*-----------------------------------------------------------------------------------------
	function AgregarLinea( tcTexto, tnTabs ) as Void
		local lcEnter as string, tcTabs as string
		
		if pcount() = 2 and tnTabs > 0
			tcTabs = replicate( chr(9), tnTabs )
		else
			tcTabs = ""
		endif
		
		lcEnter = chr( 13 ) + chr( 10 )

		this.cBuffer = this.cBuffer + lcEnter + tcTabs + tcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function release() as Void
		this.oFormulario = null
		dodefault()
	endfunc 

	*-------------------------------------------------------------------------
	Function Serializar( toFormulario as form, tcArchivo as string ) as VOID
		local lcIcono as string
		with this
			.cArchivo = .cPath + tcArchivo+".prg"
			.oFormulario = toFormulario
			try
				.GenerarArchivo()
				.AgregarCabecera( tcArchivo )			
				.AgregarLinea( "" )

				.SetearIcono()
				.AgregarCuerpo()

				.AgregarLinea( "" )
				.AgregarLinea( "Enddefine", 0 )

			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.CerrarArchivo()
			endtry
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarCuerpo() as Void
		this.AgregarFuncionInit()
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivo() as Void
		this.nArchivo = fcreate( this.cArchivo )
		this.cBuffer = ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarArchivo() as Void
*		this.nArchivo = fcreate( this.cArchivo )	
		= fwrite( this.nArchivo, this.cBuffer )
		=fclose( this.nArchivo )
	endfunc 


	*-------------------------------------------------------------------------
	Function SetearIcono() as void
		local lcIcono as string

		lcIcono = "Icono" + alltrim( _Screen.Zoo.App.cProyecto ) + ".ico"
		if !file( lcIcono )
			lcIcono = goControles.ObtenerIconoDefaultDeLosFormularios()
		endif
		
		this.AgregarLinea( "icon = '" + lcIcono + "'", 1 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarCabecera( tcArchivo )			
		with this
			.AgregarLinea( "define class " + tcArchivo + " as " + juststem( .cHerencia ) + " of " + .cHerencia, 0 )
			.AgregarLinea( "ColControles = null", 1 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionInit() as VOID
		with this
			.AgregarLinea( "function Init() as boolean", 1 )
			.AgregarLinea( "this.ColControles = newobject('collection')", 2 )
			
			.GrabarControl( .oFormulario, .f., 2 )
			.AgregarLinea( .cCreacionDeSinglentons )

			.AgregarFinInit( 2 )
			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFinInit( tnTab as Integer ) as VOID
	endfunc	
	
	*-------------------------------------------------------------------------
	protected Function EsSerializable( toControl as object ) as boolean
		return !inlist( alltrim( upper( tocontrol.name ) ), "CBM", "TOOLBAR1", "OPARCHE", "OMEMORIA", "MAINMENU", "POPUP1", "POPUPCOMPLETO", "POPUPAGREGAR") &&, "CommandBarControls" 
	endfunc

	*-------------------------------------------------------------------------
	Function GrabarControl( toControl As Object, tlCreaObjeto as boolean, tnTab as integer ) as void
	 
		Local loctrl As Object, lopage As Object, locolu As Object,	lcclass As Character, ;
			lnkey As Integer, lckey As Character, lnretval As Integer, lnControl as object, ;
			lnPage, lnColumna, lcTabs, loItem
		
		if upper( alltrim( toControl.baseclass ) ) # "FORM"
			this.cRutaControl = this.cRutaControl + alltrim( upper( toControl.name ) )+"."
		endif 	
	
		if this.EsSerializable( toControl )
			This.SerializarControl( toControl, tlCreaObjeto, tnTab )
		endif
		
		lnControl = 1
		For lnControl = 1 to toControl.ControlCount 
			loCtrl = tocontrol.Controls[ lnControl ]
			
			If !Pemstatus( loctrl, "BaseClass", 2 ) and this.EsSerializable( loctrl )
				lcclass = Upper( loctrl.BaseClass )

				Do Case
					Case  lcclass = 'PAGEFRAME'
						this.cRutaControl = this.cRutaControl + alltrim(upper(loCtrl.name ))+"."							
						This.SerializarControl( loCtrl, .t., tnTab+1 )
						
						For lnPage = 1 to loCtrl.PageCount
							loPage = loCtrl.Pages[ lnPage ]
							This.GrabarControl(lopage, .f., tnTab+2 )
							this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
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

					Case Pemstatus(loctrl, 'ControlCount', 5 ) &&or upper( loctrl.Class ) = "OLECONTROL"
						This.GrabarControl(loCtrl, .t., tnTab+1 )
						this.cRutaControl = substr( this.cRutaControl,1,rat(".",this.cRutaControl, 2 ) )
						
					case loctrl.baseclass = "Container" and upper( loctrl.Class ) = "'ZOOGRILLAEXTENSIBLE'"			
						This.SerializarControl( loCtrl, .t., tnTab+1 )
						
					otherwise
						if upper(alltrim(tocontrol.baseclass)) # "FORM"
							this.cRutaControl = this.cRutaControl + alltrim(upper(loCtrl.name ))+"."
						endif 	
				
						This.SerializarControl( loCtrl, .t., tnTab+1 )
						this.FinSerializarControl( loCtrl, tnTab+1 )
				
						if upper(alltrim(tocontrol.baseclass)) # "FORM"
							this.cRutaControl = substr(this.cRutaControl,1,rat(".",this.cRutaControl,2))
						endif 	
				
				
				Endcase
			endif
		endfor
		
		if !inlist(alltrim(upper(tocontrol.name)), "CBM", "TOOLBAR1", "OMEMORIA" )
			this.FinSerializarControl( toControl, tnTab )
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	function SerializarObjeto( tcPropiedad as string, toObjeto as object, tnTab as Integer ) as Void
		local lcTabs, laItem, lcPropiedad, tcTexto, lxValor, lnCantidadItems as integer
		
		dimension laItem(1)
		
		lcTabs = replicate( chr(9), tnTab )
		
		lnCantidadItems = amembers( laItem, toObjeto, 0, "U" )

		if lnCantidadItems > 0
			this.AgregarLinea( "with ." + tcPropiedad, tnTab )

			for each lcPropiedad in laItem
				if vartype( lcPropiedad ) = "C" and this.ValidarPropiedad( lcPropiedad, toObjeto )
					lxValor = toObjeto.&lcPropiedad
					do case
						case isnull( lxValor )
							lcTexto = "." + lcPropiedad + " = null"
								
						case vartype(lxValor)="O"
							lcTexto = "." + lcPropiedad + " = null"
								
						otherwise			
							lcTexto = "." + lcPropiedad + " = " +  goLibrerias.ValorAString( lxValor )
					endcase
					this.AgregarLinea( lcTexto, tnTab + 1 )
				endif
			endfor

			this.AgregarLinea( "endwith", tnTab )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SerializarControl( toControl as object, tlCreaObjeto as boolean, tnTab as integer ) as Void
		local lcTabs, laItem, lcPropiedad, tcTexto, lxValor, lcClase as String, lcClasePadre as String, ;
			  lcPrg as String

		with this		
			local lcTexto, laItem, lcPropiedad, lcTabs
			
			dimension laItem(1)
			
			lcClase = upper(alltrim( toControl.Class ))
			lcClasePadre = upper(alltrim( toControl.ParentClass ))
			lcPrg = lcClase

			if .NoEsSingleton( lcClase, lcClasePadre )
				.AgregarLinea( "" )
				.AgregarLinea( "************* " + toControl.name + "/" + toControl.class + "/" + toControl.baseclass, tnTab )

				if tlCreaObjeto
					.AgregarCreacionDeControl( toControl, tnTab )
				endif
				
				this.ActualizarColeccionControles( toControl, tnTab )
				
				.AgregarLinea( "" )
				if upper( alltrim( toControl.baseclass ) ) # 'FORM'
					.AgregarLinea( "with ." + toControl.name, tnTab )
				else
					.AgregarLinea( "with this", tnTab )
				endif
				
				.SetearValoresPropiedadesIndispensables( toControl, tnTab+1 )
				.AgregarSeteosAntesDeSerializar( toControl, tnTab+1 )
				.AgregarLinea( "" )

				if upper(alltrim(toControl.baseclass)) # 'FORM' and upper( alltrim(toControl.class ) ) # 'OLECONTROL'
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


*			.AgregarEnColeccionConImagenes( toControl )
			
		endwith
	endfunc 

*!*		*-----------------------------------------------------------------------------------------
*!*		protected function AgregarEnColeccionConImagenes( toControl as Object ) as void
*!*			local loItem as Object, llIcon as Boolean, llPicture as boolean
*!*			
*!*			with this
*!*				llIcon =  pemstatus( toControl, "Icon", 5 )
*!*				llPicture =  pemstatus( toControl, "Picture", 5 )
*!*				
*!*				if llPicture or llIcon 
*!*					loItem = newobject( "ItemControl" )
*!*					loItem.TienePicture = llPicture
*!*					loItem.TieneIcon = llIcon

*!*					loItem.Ruta = this.cRutaControl
*!*					if upper( "." + toControl.name + "." ) $ upper( loItem.Ruta ) or toControl.BaseClass = "Form"
*!*						loItem.Ruta = substr( loItem.Ruta, 1, len( loItem.Ruta  ) - 1 )
*!*					else
*!*						loItem.Ruta = loItem.Ruta + toControl.name
*!*					endif
*!*					
*!*					.oControlesConImagenes.Add( loItem )
*!*	 			endif
*!*			endwith
*!*		endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarColeccionControles( toControl as Object, tnTab as Integer ) as Void
		local lcRuta as String 
		
		lcRuta = substr(this.cRutaControl,1,len(this.cRutaControl)- 1)

		if pemstatus(tocontrol,"cAtributo",5) and !empty(toControl.cAtributo) ;
			and !inlist( toControl.baseclass , 'Form')
		
			if pemstatus(tocontrol,"ControlSource",5) 
				this.ActualizarColConControlSource( toControl, tnTab, lcRuta )
			else
	 			this.ActualizarColSinControlSource( toControl, tnTab, lcRuta )	
			endif	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarColConControlSource( toControl as Object , tnTab as Integer, tcRuta as String  ) as Void
		local lcCadena as String , lcAtributo as String 

		lcCadena = "thisform.ColControles.add('" + tcRuta + "','"
		lcAtributo = ""
		
		if toControl.lEsSubentidad
			if !empty( tocontrol.cAtributoPadre ) 
				if "CAMPO_" $ upper( tocontrol.name ) 
					lcAtributo = alltrim( toControl.parent.cAtributo ) + "_" + alltrim( toControl.cAtributoPadre ) + "_" + alltrim( toControl.name ) 
				else
					lcAtributo = alltrim( toControl.cAtributoPadre )
				endif
				
				if !pemstatus( tocontrol, "lClavePrimaria", 5 ) or !toControl.lClavePrimaria
					lcAtributo = lcAtributo + "_" + alltrim( toControl.cAtributo )
				endif
			else
				lcAtributo =  alltrim( toControl.parent.cAtributo ) + "_" + alltrim( tocontrol.cAtributo )
			endif
		else
			if "CAMPO_" $ upper( toControl.name )
				lcAtributo = alltrim( toControl.parent.cAtributo ) + "_" + alltrim( toControl.cAtributo ) + "_" + alltrim( toControl.name )
			else
				if pemstatus(toControl,"cCampoTotal",5)
					lcAtributo = alltrim( toControl.cAtributo )+ alltrim( toControl.cCampoTotal ) + alltrim( toControl.cEntidad ) 
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
		do case
		case pemstatus( toControl, "cDominio", 5 ) and (upper(alltrim( toControl.cDominio )) = 'CABECERASUBGRUPO')		

		case upper( alltrim( toControl.Class )) = "ZOOGRILLAEXTENSIBLE"
			lcAtributo = alltrim( toControl.cAtributo )
		otherwise
			lcAtributo = alltrim( toControl.cAtributo ) + "_" + alltrim( tocontrol.name )
		endcase
		
		if !empty(lcAtributo)
			this.AgregarLinea( lcCadena + upper( lcAtributo )+ "')", tnTab )
		endif


	endfunc 

	*-----------------------------------------------------------------------------------------
	function FinSerializarControl( toControl as Object, tnTab as Object ) as void
		local i as integer, lcControlOrigen as string, lcClase as String, lcClasePadre as String
		
		lcClase = upper(alltrim( toControl.Class ))
		lcClasePadre = upper(alltrim( toControl.ParentClass ))
		
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
					if empty( toControl.aEventos[ i, 1 ] )
					else
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

*!*		*-----------------------------------------------------------------------------------------
*!*		function AgregarEventos( toControl as Object, tnTab as integer ) as void
*!*			local lcDestino as string
*!*			
*!*			with this
*!*				if pemstatus( toControl, "aEventos", 5 ) and alen( toControl.aEventos, 1 ) > 0

*!*					.AgregarLinea( "*------------------ Eventos " + toControl.name, tnTab )
*!*					for i = 1 to alen( toControl.aEventos, 1 ) 
*!*						if !empty( toControl.aEventos[ i, 1 ] )
*!*						
*!*							lcDestino = "." + toControl.name
*!*							if upper( toControl.BASECLASS ) = "FORM"
*!*								lcDestino = "thisform"
*!*							endif
*!*							
*!*							.AgregarLinea( "bindevent( " + alltrim( toControl.aEventos[ i, 1 ] ) + ", " +;
*!*										"'" + alltrim( toControl.aEventos[ i, 2 ] ) + "', " + lcDestino + ", "+ ;
*!*										"'" + alltrim( toControl.aEventos[ i, 3 ] ) + "', " + ;
*!*										goLibrerias.ValorAString( toControl.aEventos[ i, 4 ] ) + " ) " ;
*!*										, tnTab )
*!*						endif
*!*					endfor

*!*				endif
*!*			endwith
*!*		endfunc

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
		local lcTabs as String, lcClase as string, lcBaseClase as string, lcArchivo as String ,;
			lcClasePadre as string, lcOleClass as string
		
		lcClase = upper( alltrim( tocontrol.Class ) )
		lcClasePadre = upper( alltrim( tocontrol.parentClass ) )
		lcBaseClase = upper( alltrim( tocontrol.BaseClass ) )
		lcArchivo = upper( alltrim( justfname( tocontrol.ClassLibrary ) ) )
		
		if type( "tocontrol.OleClass" ) = "C"
			lcOleClass = upper( alltrim( tocontrol.OleClass ) )
		endif

		with this
			.AgregarLinea( "if type( '." + toControl.name + "' ) # 'O'", tnTab )
			do case
				case !empty( lcOleClass )
					.AgregarLinea( ".addObject( '" + toControl.name + "', '" + lcClase + "', '" + lcOleClass + "' )", tnTab + 1 )
			
				case lcClase = lcBaseClase
					.AgregarLinea( ".newobject( '" + toControl.name + "', '" + lcClase + "' )", tnTab + 1 )
			
				otherwise
					if justext( lcArchivo ) != "VCX"
						.AgregarLinea( ".newobject( '" + toControl.name + "', '" + lcClase + "', '" + forceext( lcArchivo, ".prg" ) + "', '', 'NO')", tnTab + 1 )
					else
						.AgregarLinea( ".newobject( '" + toControl.name + "', '" + lcClase + "', '" + lcArchivo + "' )", tnTab + 1 )
					endif
			endcase
			.AgregarLinea( "endif", tnTab )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarPropiedadesNoDefinidas( toControl as Object, tnTab as integer ) as void
		local laItem as Object, lcPropiedad as string, lcValor as variant, ;
			lcTexto as string

		dimension laItem(1)
		
		amembers( laItem, toControl, 0 , "B" )
		for each lcPropiedad in laItem
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
			
*			if pemstatus( toControl, "OENTIDAD", 5 )
*				.SetearValorObjeto( toControl, "OENTIDAD", tnTab )
*			endif

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
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSeteoImagen( tcPropiedad as String, tcImagen as string ) as String
		local lcRetorno as string

*		if at( "\", tcImagen ) > 0
*			tcImagen = substr( tcImagen, rat( "\", tcImagen ) + 1 )
*		endif

		lcRetorno = "." + tcPropiedad + " = '" + justfname( tcImagen ) + "'"

		return lcRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function EsPropiedadIndispensable( tcPropiedad as String ) as boolean
		return inlist( upper( alltrim( tcPropiedad ) ), "THEMES", "TABS", "OENTIDAD", "VISIBLE", "AUTOCENTER", "PICTURE", "DISABLEDPICTURE", "ICON" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValoresPropiedades( toControl as Object, tnTab as integer ) as Void
		local lcTexto as String, lxValor as Variant, laItem as Object,;
			lcPropiedad as string, llEsUnaMatriz as boolean

		dimension laItem(1)
		
		amembers( laItem, toControl )
		for each lcPropiedad in laItem

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
							lcTexto = "." + lcPropiedad + " = " + goLibrerias.ValorAString( lxValor )
							this.AgregarLinea( lcTexto, tnTab )
						
						otherwise
							if upper( alltrim( lcPropiedad ) ) = "AGRILLA"
								this.SerializarMatrizGrilla( lcPropiedad, toControl, tnTab )
							endif

					endcase

				endif
			endif
		endfor

		if pemstatus( toControl, "VISIBLE", 5 ) and upper(alltrim( toControl.baseclass)) # "FORM"
			lcTexto = ".VISIBLE = " + goLibrerias.ValorAString( toControl.Visible )
			this.AgregarLinea( lcTexto, tnTab )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnaMatriz( tcPropiedad as string, toControl as Boolean ) as boolean
		local llRetorno as boolean, lnDimension as boolean, loError as exception
	
		llRetorno = ( type( "alen( toControl.&tcPropiedad )" ) = "N" )
		
		return llRetorno
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
					.AgregarLinea( "loColumna = newobject( '" + lxItem.Class+ "', 'zooGrillaExtensible.prg' )", tnTab )
					.AgregarLinea( "with loColumna", tnTab )
					.AgregarPropiedadesNoDefinidas( lxItem, tnTab )
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
	function SetearValorObjeto( toControl, tcPropiedad, tnTab ) as boolean
		local lcNombre as string, lcSeteos as string, lcClase, llRetorno, lcBaseClase, llSerializar, lcTexto
		lcTexto = ""
		llRetorno = .f.
		
		with this
			lcNombre =  upper(alltrim(toControl.name))
			lcBaseClase =  upper(alltrim(toControl.baseclass))
			lcClase =  upper(alltrim(toControl.class))
			lcSeteos = ""

			do case
				case lcBaseClase # "FORM" and tcPropiedad="OENTIDAD"
					lcTexto = this.ObtenerTextoOrigenDeDatos( toControl )
					
				case lcNombre = "PNLGRUPOS" and tcPropiedad="OSOLAPAS"
					lcSeteos  = "this.pnlGrupos.oSolapas = this.pnlGruposSolapa"

				case lcNombre = "PNLGRUPOSSOLAPA" and tcPropiedad="OPAGEFRAME"
					lcSeteos  = "this.pnlGruposSolapa.oPageFrame = this.pnlGrupos"

				case tcPropiedad="OSERVICIOGRILLA"
					lcTexto  = "_screen.zoo.crearobjeto( 'ServicioGrilla' )"
					llRetorno = .t.

				case lcBaseClase # "ZOOGRILLAEXTENSIBLE" and tcPropiedad="ODETALLE"
					lcTexto  = ".oEntidad.ObtenerValorAtributo( .cAtributo )"

				case tcPropiedad="OAUTOCOMPLETAR"
					lcTexto  = "_screen.zoo.crearobjeto( 'AutoCompletar' )"
					llRetorno = .t.
				
				case inlist( lcClase, 'RUTAARCHIVO', 'IMAGEN' ) and tcPropiedad = 'ODATOS'
					lcTexto  = "_screen.zoo.crearobjeto( 'ManejoArchivos' )"
					llRetorno = .t.

				case inlist( lcClase, 'RUTAARCHIVOTRANSFERENCIAS', 'IMAGEN' ) and tcPropiedad = 'ODATOS'
					lcTexto  = "_screen.zoo.crearobjeto( 'ManejoArchivos' )"
					llRetorno = .t.
			endcase

			.cSeteos  = .cSeteos + iif( !empty(lcSeteos), chr(13) + chr(10) + lcSeteos, "")
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
				if empty( toControl.oItem.Version )
					lcTexto  = lctexto + ".oAtributos."
				else
					lcTexto  = lctexto + "."
				endif

				if pemstatus( toControl, "lDetalle", 5 ) and toControl.lDetalle and ;
					upper( toControl.parent.class ) = "ZOOGRILLAEXTENSIBLE"
					lcTexto = lcTexto + alltrim( toControl.Parent.cAtributo ) + ".oItem."
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
		if vartype( tcCLase ) # "C" or vartype( tcClasePadre ) # "C"
			assert .f. message "Cantida de Parámetros o tipo inválidos"
		endif

		return ( !inlist( tcClase, "AUTOCOMPLETAR" ) and !("kontroler" $ lower( tcClase ) ) )

	endfunc 

enddefine

*************************************************
define class ItemControl as Custom
	TieneIcon = .f.
	TienePicture = .f.
	Ruta = ""
enddefine