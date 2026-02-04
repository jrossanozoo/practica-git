define class GeneradorDinamicoMocks as Generador of Generador.prg

	#if .f.
		local this as GeneradorFormularios of GeneradorFormularios.prg
	#endif

	cPath = "Generados\"
	oFunciones = null
	cPropiedadesExcluidas = ""
	cPropiedadesExcluidasOrig = ""

	cPropiedadesManteniendoValorReal = ""
	cPropiedadesManteniendoValorRealOrig = ""
	
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		with this
			.lDestroy = .t.
			if vartype( .oFunciones ) = "O"
				.oFunciones.release()
			endif
			dodefault()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFunciones() as Void
		This.oFunciones.add( "Class_Access" )	
		This.oFunciones.add( "ParentClass_Access" )	
		This.oFunciones.add( "ClassLibrary_Access" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oFunciones_Access() as Void
		if !this.ldestroy and !vartype( this.oFunciones ) = 'O'
			this.oFunciones = _Screen.zoo.crearobjeto( 'zooColeccion' )
		endif
		return this.oFunciones
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReestablecerEstadoInicial() as Void
		dodefault()

		local loError as Exception, loEx as Exception
		with this
			.lDestroy = .t.
			try
				if vartype( .oFunciones ) = "O"
					.oFunciones.release()
				endif
				.oFunciones = null
			Catch To loError
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			Finally
				.lDestroy = .f.
			EndTry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Generar( tcTipo as String ) as Void
		with this
			lcClase = .ObtenerMock( tcTipo )
			dodefault( lcClase )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstadoInicial() as Void
		dodefault()

		with this
			.cPropiedadesExcluidas = .cPropiedadesExcluidasOrig
			.cPropiedadesManteniendoValorReal = .cPropiedadesManteniendoValorRealOrig
			.SetearFunciones()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMock( tcClase as String ) as string
		local lcClase as string, lnItem as integer
		*-------------------------------------------------------------------
		*Instanciación de Mocks
		if pemstatus(_screen, "Mocks", 5 ) and vartype( _Screen.Mocks ) = "O"
			lnItem = _Screen.Mocks.BuscarMock( upper( tcClase ) )
			if !empty( lnItem )
				lcClase = _Screen.Mocks.Item[lnItem].cNombreClaseMock
			else 
				lcClase = tcClase
			endif
		else
			lcClase = tcClase
		endif
		*-------------------------------------------------------------------
		
		return lcClase
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		with this
			.cArchivo = .cPath + "Mock_" + ;
				alltrim( Proper( .cTipo ) ) +;
				.cPrefijo + .cSufijo + ".prg"
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		local lcClase as string, lcTipo as String
		with this
			.GenerarInclude()
			.AgregarLinea( "define class Mock_" + this.cTipo + this.cPrefijo + " as MockBase of MockBase.prg" )
			.AgregarLinea( "" )
			.AgregarLinea( "cClase = '" + .cTipo + "'" , 1 )
			.AgregarLinea( "" )
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		local lcArchivo as String, lcArchivoAnt as string, lcArchivoHerencia as string, ;
			lcArchivoAux as string, lcPropiedadesAux as String,;
			lcPropiedadesAnt as String, lcPropiedades as String 
		
		with this
			lcArchivoHerencia = .ObtenerHerencia()

			lcArchivoAnt = ""
			lcPropiedadesAnt = ""
			
			select ( lcArchivoHerencia )
			go top
			scan
				lcPropiedades = .ObtenerPropiedades( &lcArchivoHerencia..Nombre )
			
				if !empty( lcPropiedadesAnt )
					lcPropiedadesAux = .UnirFunciones( lcPropiedadesAnt, lcPropiedades )
					use in select( lcPropiedadesAnt )
					use in select( lcPropiedades )
					lcPropiedadesAnt = lcPropiedadesAux
				else
					lcPropiedadesAnt = lcPropiedades
				endif
			
				lcArchivo = .ObtenerFunciones( &lcArchivoHerencia..Nombre )
			
				if !empty( lcArchivoAnt )
					lcArchivoAux = .UnirFunciones( lcArchivoAnt, lcArchivo )
					use in select( lcArchivoAnt )
					use in select( lcArchivo )
					lcArchivoAnt = lcArchivoAux
				else
					lcArchivoAnt = lcArchivo
				endif
			endscan
			
			.EscribirPropiedades( lcPropiedadesAnt )		
			.GenerarFuncionInicializar()
			.GenerarInciarPropiedades()
			.GenerarFuncionRelease()
			.EscribirFunciones( lcArchivoAnt )

			if !empty( lcPropiedadesAnt )
				use in select( lcPropiedadesAnt )
			endif					

			if !empty( lcArchivoAux )
				use in select( lcArchivoAux )
			endif		

			if !empty( lcArchivo )
				use in select( lcArchivo )
			endif

			if !empty( lcPropiedades )
				use in select( lcPropiedades )
			endif			
			use in select( lcArchivoAnt )	
			use in select( lcArchivoHerencia )	
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFuncionRelease() as Void
		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			.AgregarLinea( "function Release() as Void", 1 )
			.AgregarLinea( "dodefault()", 2 )
			.AgregarLinea( "release this", 2 )
			.AgregarLinea( "endfunc", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarFuncionInicializar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function UnirFunciones( tcArchivo1 as string, tcArchivo2 as string) as string
		local lcRetorno as String

		lcRetorno = sys( 2015 )

		if !empty( tcArchivo2 )

			select * ;
				from ( tcArchivo1 );
				where lower( Nombre ) not in ( select lower( nombre ) from ( tcArchivo2 ) );
					union ;
					select * ;
						from ( tcArchivo2 ) ;
				into cursor ( lcRetorno ) ;
				readwrite

		else
			lcRetorno = tcArchivo1
		endif

		this.BorrarFunciones( lcRetorno )

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BorrarFunciones( tcArchivo as string ) as Void
		delete from ( tcArchivo ) where "release" = lower( nombre )
		delete from ( tcArchivo ) where "destroy" = lower( nombre )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EscribirPropiedades( tcArchivo as string ) as Void
		local lcPro as string
		
		with this

			select ( tcArchivo )
			go top
			.AgregarLinea( "" , 1 )

			scan for !deleted()
				lcProp = strtran( &tcArchivo..Nombre, " = NULL", "" )

				if ( "," + alltrim( upper( lcProp ) ) + "," $ "," + .cPropiedadesExcluidas + "," )
				else
					if ( "," + alltrim( upper( lcProp ) ) + "," $ "," + .cPropiedadesManteniendoValorReal + "," )
						.AgregarLinea( &tcArchivo..ValorReal , 1 )
					else
						.AgregarLinea( &tcArchivo..Nombre , 1 )
					endif
				endif
			endscan
			.AgregarLinea( "" , 1 )

		endwith 			
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EscribirFunciones( tcArchivo as string ) as Void
	
		with this

			select ( tcArchivo )
			go top
			scan for !deleted()
				.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1)
				.AgregarLinea( &tcArchivo..Firma, 1 )

				.EscribirCuerpo( tcArchivo )

				.AgregarLinea( "EndFunc", 1 )
				.AgregarLinea( "" )
			endscan
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EscribirCuerpo( tcArchivo as string) as Void
		with this
			do case
				case alltrim(lower( &tcArchivo..Nombre )) == "init"
					.EscribirCuerpoInit()
					
				case !empty( &tcArchivo..Cuerpo )
					.AgregarLinea( alltrim(&tcArchivo..Cuerpo), 2 )
					
				otherwise
					.EscribirCodigoDefaultMock( tcArchivo )
			endcase
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EscribirCuerpoInit() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EscribirCodigoDefaultMock( tcArchivo as String ) as Void
		local lnId as integer, lcParametros as String, lnParametros as integer

		with this
			.AgregarLinea( "local lcParametros as string, lcParam as string, lni as integer, lnParametros as integer", 2 )

			lcParametros = ""

			lnParametros = this.ObtenerCantidadParametros( tcArchivo )
			if lnParametros > 0
				for lnId = 1 to lnParametros
					lcParametros = lcParametros + iif( !empty( lcParametros ), ", ", "" ) +;
								 "lxParam" + alltrim( str( lnId ) )
				endfor
				.AgregarLinea( "local " + lcParametros, 2 )
			endif
		
			.AgregarLinea( "" )
			.AgregarLinea( "lnParametros = pcount()", 2 )

			local lcNombre as String
			for lnId = 1 to lnParametros
				lcNombre = this.ObtenerNombreParametro( tcArchivo, lnId )
				.AgregarLinea( "lxParam" + alltrim( str( lnId ) )+ " = " + lcNombre , 2 )
			endfor

			.AgregarLinea( "" )
			.AgregarLinea( "lcParametros = ''", 2 )
			
			if lnParametros > 0
				.AgregarLinea( "for lni = 1 to lnParametros", 2 )
				.AgregarLinea( "lcParam = 'lxParam' + alltrim(str(lni))", 3 )
				.AgregarLinea( "lcParametros = lcParametros + iif( !empty(lcParametros),',','') + " +;
					[iif( vartype( &lcParam ) = 'O' or isnull(&lcParam), "'*OBJETO'", goLibrerias.ValorAString( &lcParam ) )], 3 )
				.AgregarLinea( "endfor", 2 )
			endif
		
			.AgregarLinea( "" )
			.AgregarLinea( "return this.ObtenerResultado( '" + alltrim(&tcArchivo..Nombre) + "', lcParametros )", 2 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadParametros( tcArchivo as String ) as integer
		local lnCantidadComas as integer, lcFirma as string
		
		lcFirma = alltrim( &tcArchivo..FirmaSinEspacios )
		
		lnCantidadComas = occurs( ",", &tcArchivo..FirmaSinEspacios )
		lnCantidadParametros = 0
		
		if lnCantidadComas = 0
			if at( "(", lcFirma ) > 0 and at( "()", lcFirma ) = 0
				lnCantidadParametros = 1
			endif
		else
			lnCantidadParametros = lnCantidadComas + 1
		endif
		
		return lnCantidadParametros
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreParametro( tcArchivo as string, tnNumParametro as Integer ) as String
		assert vartype( tnNumeroParametro ) # "N" or tnNumeroParametro < 1 message "La cantidad de parametros debe ser mayor a 1"
		
		local lcParametro as String, lcFirma as String, lnPrimerParentesis as Integer, lnUltimoParentesis as Integer

		
		lcFirma = alltrim( &tcArchivo..Firma )
		lnPrimerParentesis = at( "(", lcFirma )
		lnUltimoParentesis = at( ")", lcFirma )
		
		lcFirma = substr( lcFirma, lnPrimerParentesis + 1, lnUltimoParentesis - lnPrimerParentesis - 1 )
		lcFirma = alltrim( lcFirma )
		lcParametro = GETWORDNUM(lcFirma,tnNumParametro,",")
				
		if at( " as", lcParametro ) > 1
			lcParametro = alltrim( substr( lcParametro, 1, at( " as", lcParametro ) - 1 ) )
		endif

		
		return alltrim( lcParametro )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFunciones( tcArchivo as string ) as string
		local lcFuncion as string
				
		tcArchivo = alltrim( tcArchivo )
			
		with this
			create cursor ( tcArchivo ) ( txt C(250), cuerpo M, registro N(5) )
			append from ( tcArchivo + ".prg" ) type SDF
			
			delete for left( alltrim( txt ), 1) = "*" or ;
					left( alltrim( txt ), 2) = chr(38)+chr(38)		
			replace registro with recno() all
			
			locate for lower(  alltrim( txt ) ) == "enddefine" or lower( alltrim( txt ) ) == "endd"
			delete rest

			index on registro tag registro
		
			select lower( strtran( strtran( strtran( txt, chr( 13 ), "" ), chr( 10 ), "" ), chr( 9 ), "" ) ) as Firma ,;
					lower( strtran( strtran( strtran( txt, chr( 13 ), "" ), chr( 10 ), "" ), chr( 9 ), "" ) ) as FirmaSinEspacios ,;
					space( 250 ) as Nombre, ;
					cuerpo, registro ;
				from ( tcArchivo ) ;
					where	( "function" $ lower( txt ) and !( '"function' $ lower( txt ) )  and !( "'function" $ lower( txt ) ) ) or ;
							( "procedure" $ lower( txt ) and !( ".procedure" $ lower( txt ) or "set procedure" $ lower( txt ) or;
							!( "set('Procedure')" $ lower( txt )) ) );
							into cursor ( tcArchivo+"funciones" ) readwrite

			.CompletarFirmaDeFuncion( tcArchivo + "funciones", tcArchivo )

			replace Nombre with proper( alltrim( substr( firmaSinEspacios, at( "function", firmaSinEspacios ) + 8,iif( at( "(", firmaSinEspacios )>0 , at( "(", firmaSinEspacios ) - at( "function", firmaSinEspacios ) - 8, len( FirmaSinEspacios ))))) ,;
						FirmaSinEspacios with strtran( FirmaSinEspacios, " ", "") for "function" $ firmaSinEspacios  

			replace Nombre with proper( alltrim( substr( firmaSinEspacios, at( "procedure", firmaSinEspacios ) + 9,iif( at( "(", firmaSinEspacios )>0 , at( "(", firmaSinEspacios ) - at( "procedure", firmaSinEspacios ) - 9, len( FirmaSinEspacios ))))) ,;
						FirmaSinEspacios with strtran( FirmaSinEspacios, " ", "") for "procedure" $ firmaSinEspacios  


			.AntesDeObtenerCuerpoFunciones( tcArchivo+"funciones" )
			if vartype( .oFunciones ) = "O"
				for each lcFuncion in .oFunciones
					.ObtenerCuerpoFunciones( tcArchivo, tcArchivo + "funciones", lcFuncion )
				endfor
			endif
			use in ( tcArchivo )
		endwith
		return tcArchivo + "Funciones"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AntesDeObtenerCuerpoFunciones( tcArchivo ) as VOID
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPropiedades( tcArchivo as string ) as string
		local lcPropiedad as string, lcArchivo as String , lcValorReal as string, lcNombre as String,;
			lcReemplazo as String, loError as Exception 

		try
			lcArchivo = alltrim( tcArchivo ) + "Propiedades"
				
			with this
				create cursor Cur_Prop (  Nombre C(250), cuerpo M, valorreal C(250) )
				append from ( alltrim( tcArchivo ) + ".prg" ) type SDF

				select( "Cur_Prop" ) 
				go top 
				scan while at( "FUNCTION", upper( Nombre ) ) < 1 and at( "PROCEDURE", upper( Nombre ) ) < 1
					if at( "=", Nombre ) > 0 
						if at( "NIVELACTUAL", upper( Nombre ) ) = 0 
							lcNombre = Nombre
							if at( "'", lcNombre, 1 ) > 0 and at( "'", lcNombre, 2 ) > 0 and at( "PK", lcNombre ) > 0
								lcReemplazo = substr( lcNombre, at( "'", lcNombre ) + 1, at( "'", lcNombre, 2 ) - at( "'", lcNombre ) - 1 )
								lcNombre = strtran( lcNombre, lcReemplazo, "" )
								lcNombre = strtran( lcNombre, "'", '"' )
							endif
							lcNombre = strtran( lcNombre, "]", '"' )
							lcNombre = strtran( lcNombre, "[", '"' )
						else
							lcNombre = left( nombre, at( "=", Nombre ) ) + '3'
						endif

						lcNombre = strtran( lcNombre, chr( 9 ), "" )
						lcNombre = strtran( lcNombre, chr( 10 ), "" )
						lcNombre = strtran( lcNombre, chr( 13 ), "" )
						lcNombre = strtran( lcNombre, "*MOCK*", "" )
						lcNombre = alltrim( lcNombre )

						lcValorReal = strtran( nombre, chr( 9 ), "" )
						lcValorReal = strtran( lcValorReal, chr( 10 ), "" )
						lcValorReal = strtran( lcValorReal, chr( 13 ), "" )
						lcValorReal = strtran( lcValorReal, "*MOCK*", "" ) 
						lcValorReal = alltrim( lcValorReal)

						replace nombre with lcNombre, ;
								ValorReal with lcValorReal
					else
						delete	
					endif 
				endscan 
				delete rest 
				
			endwith

			select distinct ;
				nombre, valorreal ;
				from Cur_prop ;
				where alltrim( upper( nombre ) ) # "DATASESSION" ;
				into cursor ( lcArchivo ) readwrite ;
				order by 1 
		catch to loError
			loError.Message = lcArchivo + ": " + loError.Message
			throw loError
		endtry
		use in select( "Cur_prop" )
		return( lcArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerHerencia() as string
		local lcArchivo as string, lcArchivoAux as string

		tcArchivo = this.ObtenerNombreArchivo()

		lcArchivoRetorno = tcArchivo + "herencia"
	
		lcArchivoAux = sys( 2015 )
		create cursor ( lcArchivoAux ) ( Nombre C(100), Numero N(10) )
		select ( lcArchivoAux )
		append blank
		replace Nombre	with tcarchivo ,;
				Numero	with 0
		
		with this
			lcPadre = tcArchivo
			lni = 1
			do while .t.
				lcPadre = this.ObtenerNombrePadre( lcPadre )
				if empty( lcPadre )
					exit
				endif
				
				select ( lcArchivoAux )
				append blank
				replace Nombre with lcPadre, ;
						Numero	with lnI
				
				lnI = lnI + 1
			enddo
		endwith
		
		select Numero, Nombre from ( lcArchivoAux );
			order by Numero desc into cursor ( lcArchivoRetorno )
		
		use in select( lcArchivoAux )
		
		return lcArchivoRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreArchivo() as string
 		return this.cTipo 
 	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombrePadre( tcArchivo )
		local lcArchivo as String, lcArchivoAux as string, lcRetorno as string
		
		tcarchivo = alltrim( tcarchivo )
	
		lcRetorno = ""
		if file( tcArchivo + ".prg" )
			lcArchivoAux = sys( 2015 )
			create cursor ( lcArchivoAux ) ( txt C(250) )
			append from ( tcArchivo + ".prg" ) type SDF
			
			lcArchivo = tcArchivo+"Padre"		

			select strtran( strtran( alltrim( substr( lower( txt ), at( " of", lower( txt ) ) + 3 ) ) , ".prg", "" ), "olepublic", "" ) as Nombre ;
				from ( lcArchivoAux ) where "define class" $ lower( txt ) into cursor ( lcArchivo ) readwrite
		
			lcRetorno = iif( at( "class", &lcArchivo..Nombre ) > 1, "", &lcArchivo..Nombre )
			
			use in select( lcArchivoAux )
			use in select( lcArchivo )
		endif
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCuerpoFunciones( tcArchivo as string, tcDestino as string, tcFuncion as string ) as Void
		local lcCuerpo as String
		
		lcCuerpo = ""
		
		select ( tcDestino )
		locate for lower( alltrim( nombre ) ) = lower( alltrim( tcFuncion ) )
		if found()
			select ( tcArchivo )
			seek &tcDestino..registro
			skip

			lcCuerpo = this.ObtenerCodigoDeParametros( tcDestino, tcFuncion ) + chr(13) + chr(13)
			scan while !( "endfunc" $ lower( txt ) ) and !( "endproc" $ lower( txt ) )
				lcCuerpo = alltrim(lcCuerpo) + iif( !empty(lcCuerpo ), chr(13), "" ) + alltrim( txt )
			endscan
		
			select ( tcDestino )
			replace cuerpo with lcCuerpo
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeParametros( tcArchivo as String, tcFuncion as String ) as String
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CompletarFirmaDeFuncion( tcArchivofunciones as string, tcArchivo as string ) as Void
		local lnAreaActual as Integer, lcFirma as String, lcFirmaSinEspacios as string, lcFirmaSinEspacios as String, lcFirmaSinEspaciosNueva as String
		lnAreaActual = select()
		select ( tcArchivoFunciones	)

		scan for right( alltrim ( firma ), 1) = ";"
			lcFirma = alltrim( firma )
			lcFirmaSinEspacios = alltrim( FirmaSinEspacios )
			lnLinea = registro
			select ( tcArchivo )
			
			locate for registro = lnLinea + 1
			do while not eof() and right( alltrim( lcFirmaSinEspacios ), 1) = ";"					
				lcFirmaNueva = alltrim( lower( strtran( strtran( strtran( txt, chr( 13 ), "" ), chr( 10 ), "" ), chr( 9 ), "" ) ) )
				lcFirmaSinEspaciosNueva = alltrim( lower( strtran( strtran( strtran( txt, chr( 13 ), "" ), chr( 10 ), "" ), chr( 9 ), "" ) ) )
				lcFirma = strtran( lcFirma, ";", " ") + lcFirmaNueva
				lcFirmaSinEspacios = strtran( lcFirmaSinEspacios, ";", " ") + lcFirmaSinEspaciosNueva
				skip
			enddo		
			
			select ( tcArchivoFunciones )
			replace Firma with lcFirma, FirmaSinEspacios with lcFirmaSinEspacios
		endscan	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarInciarPropiedades() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarInclude()
		local lcArchivoHerencia as String

		lcArchivoHerencia = .ObtenerHerencia()
		select ( lcArchivoHerencia )
		go top
		scan
			.ProcesarInclude( &lcArchivoHerencia..Nombre )	
			select ( lcArchivoHerencia )
		endscan
		use in select( lcArchivoHerencia )	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarInclude( tcArchivo ) as Void
		local lcCursor as String, loError as Exception 
		
		try
			lcCursor = sys( 2015 )
			create cursor &lcCursor (  Nombre C(250), cuerpo M, valorreal C(250) )
			append from ( alltrim( tcArchivo ) + ".prg" ) type SDF
			select( "&lcCursor" ) 

			go top 
			scan
				if "#" + "INCLUDE" $ upper( &lcCursor..Nombre )
					.AgregarLinea( alltrim( upper( &lcCursor..Nombre ) ) )
				endif
			endscan
			use in select ( "&lcCursor" )
		catch to loError
			loError.Message = tcArchivo + ": " + loError.Message
			throw loError
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneFuncionalidadDesactivable( txTipo as Variant ) as Boolean
		return .f.
	endfunc
	
enddefine