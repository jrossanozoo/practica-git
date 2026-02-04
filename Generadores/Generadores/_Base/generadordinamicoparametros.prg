define class GeneradorDinamicoParametros as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoParametros of GeneradorDinamicoParametros.prg
	#endif

	cPath = "Generados\"
	oFunciones = null
	nProyecto = 0

	*-----------------------------------------------------------------------------------------
	protected function InstanciarEstructura() as Void
		this.oEstructura = null	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Generar( tcTipo as String, tcXmlParametros as String, tcXmlJerarquias as string, ;
		tnProyecto as integer ) as Void
		

	assert ( pcount() > 2 ) message "Clase: GeneradorDinamicoParametros." + chr( 13 ) + ;
										"Función: Generar." + chr( 13 ) + ;
										"Error: Faltan Parámetros"
		with this
			if vartype( tnProyecto ) = "N"
				.nProyecto = tnProyecto
			endif
	
			.Xmlacursor( tcXmlParametros, "c_Parametros" )
			.Xmlacursor( tcXmlJerarquias, "c_jerarquianodos" )

			dodefault( tcTipo )

			use in select( "c_Parametros" )
			use in select( "jerarquianodos" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClase() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarPieClase() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		this.cArchivo = this.cPath + "Din_" + alltrim( Proper( this.cTipo ) ) + ".prg"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		this.EscribirUnaClase( 0, proper( this.cTipo ), "" )
		
		select distinct proyecto from c_jerarquianodos into cursor c_Proyectos
		scan
			this.EscribirClases( 0, alltrim( c_Proyectos.proyecto ), alltrim( c_Proyectos.proyecto ) )
		endscan
		this.EscribirClaseConsultaParametro()
		
		use in select( "c_Proyectos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EscribirClases( tnNodo as Integer, tcNombre as string, tcProyecto as string ) as Void
		local lcHijos as string

		lcHijos = sys(2015)
		select nodo, nombre, padre from c_jerarquianodos where padre = tnNodo and proyecto = tcProyecto ;
			into cursor ( lcHijos )

		if _tally > 0
			scan
				this.EscribirUnaClase( &lcHijos..Nodo, &lcHijos..Nombre, tcProyecto, tnNodo )
				
				this.EscribirClases( &lcHijos..Nodo, &lcHijos..Nombre, tcProyecto )
				select ( lcHijos )
			endscan
		endif
			
		use in select( lcHijos )

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EscribirClaseConsultaParametro() as Void
		this.AgregarLinea( "" )
		this.AgregarLinea( "*-----------------------------------------------------------------------------------------" )
		this.AgregarLinea( "define class ConsultaParametro as custom" )
		this.AgregarLinea( "Nivel = 0", 1 )
		this.AgregarLinea( "idNodo = 0", 1 )
		this.AgregarLinea( "Parametro = ''", 1 )
		this.AgregarLinea( "Proyecto = ''", 1 )
		this.AgregarLinea( "TipoDato = ''", 1 )
		this.AgregarLinea( "Default = null", 1 )
		this.AgregarLinea( "idCabecera = 0", 1 )
		this.AgregarLinea( "IdUnico = ''", 1 )
		this.AgregarLinea( "enddefine" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCabeceraClaseParametros( tcNombre as String ) as Void
		local loLibrerias as librerias of librerias.prg
		
		loLibrerias = newobject( "librerias", "librerias.prg" )
		with this
			.AgregarLinea( "define class din_" + alltrim( loLibrerias.TransformarCadenaCaracteres( tcNombre ) ) + " as custom" )
		endwith
		loLibrerias = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EscribirUnaClase( tnNodo as Integer, tcNombre as string, tcProyecto as string, tnPadre as integer ) as Void
		local lcHijos, lcParametros, lcValor, lcParam, lcNodo, lcClase, loLibrerias as Object
		
		lcHijos = this.ObtenerHijos( tnNodo, tcProyecto )
		lcParametros = this.ObtenerParametros( tnNodo, tcProyecto )
		loLibrerias = newobject( "librerias", "librerias.prg" )
		with this
			.AgregarLinea( "" )
			if empty( tcProyecto )
				This.GenerarCabeceraClaseParametros( tcNombre )
				.AgregarLinea( "oDatos = null", 1 )
			else
				if tnPadre = 0
					.AgregarLinea( "define class Parametros_" + alltrim( loLibrerias.TransformarCadenaCaracteres( tcNombre ) ) + " as custom" )
				else
					.AgregarLinea( "define class " + alltrim( tcProyecto ) + "_" + alltrim( loLibrerias.TransformarCadenaCaracteres( tcNombre ) ) + " as custom" )
				endif
			endif
			.AgregarLinea( "" )

			.AgregarLinea( "nNodo = " + alltrim( str( tnNodo ) ), 1 )
			.AgregarLinea( "lAccess = .f.", 1 )
			.AgregarLinea( "lDestroy = .f.", 1 )

		************************ Declaracion de nodos
			select ( lcHijos )
			go top
			if reccount() > 0
				.AgregarLinea( "" )
				scan
					lcNodo = alltrim( loLibrerias.TransformarCadenaCaracteres( &lcHijos..Nombre ) )
					.AgregarLinea( lcNodo + " = null", 1 )
				endscan
			endif

			************************ Declaracion de Parametros
			select ( lcParametros )
			go top
			if reccount() > 0
				.AgregarLinea( "" )

				scan
					lcValor = this.TransformarDefault( &lcParametros..Default, &lcParametros..TipoDato )
					if empty( &lcParametros..ParamInt )
						lcParam = loLibrerias.TransformarCadenaCaracteres( alltrim( &lcParametros..Parametro ) )
					else
						lcParam = loLibrerias.TransformarCadenaCaracteres( alltrim( &lcParametros..ParamInt ) )
					endif

					if this.nProyecto = 7 
						lcValor = this.ModificarInicializacionParametrosLince( lcValor, alltrim( &lcParametros..Parametro ) )
					endif
					.AgregarLinea( lcParam + " = " + lcValor, 1 )
				endscan
			endif
			
			************************ Declaracion del Init
			
			.AgregarLinea( "" )

			.AgregarLinea( "function init() as void", 1 )
			.AgregarLinea( "with this", 2 )
			if empty( tcProyecto )
				this.GenerarCreacionAccesoDatos()
			endif

			select ( lcHijos )
			go top
			if reccount() > 0
				scan
					lcNodo = alltrim( loLibrerias.TransformarCadenaCaracteres( &lcHijos..Nombre ) )

					if empty( &lcHijos..Padre )
						.AgregarLinea( "." + lcNodo + ' = newobject( "Parametros_' + lcNodo + '") ', 3 )
					else
						.AgregarLinea( "." + lcNodo + ' = newobject( "' + tcProyecto + "_" + lcNodo + '") ', 3 )
					endif
				endscan
			endif
			.AgregarLinea( "endwith", 2 )		
			.AgregarLinea( "endfunc", 1 )		
			
			************************ Declaracion de losAcces
			select ( lcParametros )
			go top
			if reccount() > 0
				scan
			************************ Declaracion de losAcces
					

					if empty( &lcParametros..ParamInt )
						lcParam = loLibrerias.TransformarCadenaCaracteres( alltrim( &lcParametros..Parametro ) )
					else
						lcParam = loLibrerias.TransformarCadenaCaracteres( alltrim( &lcParametros..ParamInt ) )
					endif
					
					This.GenerarAccess( lcParam , lcParametros )
					
			************************ Declaracion de los Assig
					This.GenerarAssign( lcParam , lcParametros )
				endscan
			endif

			.AgregarLinea( "" )
			.AgregarDestroy()
			.AgregarLinea( "enddefine" )
			.AgregarLinea( "" )
		endwith
		
		use in select( lcHijos ) 
		use in select( lcParametros ) 
		loLibrerias = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarCreacionAccesoDatos() as Void
		this.AgregarLinea( ".oDatos = _Screen.zoo.crearObjeto( 'Datos" + upper( alltrim( this.cTipo )) + "' )", 3 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNivelParametro( toParametros as Object ) as String
		local lcNivel as String

		with toParametros
			do case 
				case val( .Organizacion ) = 1
					lcNivel = "1"
				case val( .Puesto ) = 1
					lcNivel = "2"
				case val( .Sucursal )= 1
					lcNivel = "3"
			endcase 
		endwith

		return lcNivel
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreObjetoDatosParametro( toParametros as Object ) as String
		local lcObjeto as String 

		with toParametros
			do case 
				case val( .Organizacion ) = 1
					lcObjeto = "Organizacion"
				case val( .Puesto ) = 1
					lcObjeto = "Puesto"
				case val( .Sucursal )= 1
					lcObjeto = "Sucursal"
			endcase 
		endwith

		return lcObjeto 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarAccess( tcParam as String , tcParametros as String ) as Void
		local lcNombreObjetoDatos as String

		with this
			.AgregarLinea( "" )
			.AgregarLinea( "function " + tcParam + "_Access() as void", 1 )
			.AgregarLinea( "local loConsultaParametro as ConsultaParametro of ConsultaParametro.prg", 2 )
			.AgregarLinea( "with this", 2 )
			.AgregarLinea( "if .lDestroy", 3 )
			.AgregarLinea( "else", 3 )
			.AgregarLinea( ".lAccess = .t.", 4 )
			
			loParametros = this.ObtenerDatosDelParametro( tcParametros )

			.EscribirObjeto( loParametros, 4 )

			lcNombreObjetoDatos = this.ObtenerNombreObjetoDatosParametro( loParametros )
						
			.AgregarLinea( "with " + iif( this.cTipo == "PARAMETROS", "goParametros", "goRegistry" ) + ".oDatos", 4)
			.AgregarLinea( "if .ExisteConfigurador( loConsultaParametro )", 5 )
			.AgregarLinea( "this." + tcParam + " = .ObtenerConfiguracion( loConsultaParametro )", 6 )
			.AgregarLinea( "else", 5 )
			.AgregarLinea( "this." + tcParam + " = ." + lcNombreObjetoDatos + ".Obtener( loConsultaParametro )", 6 )
			.AgregarLinea( "endif", 5 )
			.AgregarLinea( "endwith", 4 )

			.AgregarLinea( ".lAccess = .f.", 4 )
			.AgregarLinea( "return ." + tcParam, 4 )
			.AgregarLinea( "" )
			.AgregarLinea( "endif", 3 )
			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 


	*-----------------------------------------------------------------------------------------
	function GenerarAssign( tcParam as String , tcParametros as String )as Void
		local lcNombreObjetoDatos as String
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "function " + tcParam + "_Assign( txValor ) as void", 1 )
			.AgregarLinea( "local loConsultaParametro as ConsultaParametro of ConsultaParametro.prg", 2 )
			.AgregarLinea( "with this", 2 )
			.AgregarLinea( "if .lDestroy", 3 )
			.AgregarLinea( "else", 3 )
			.AgregarLinea( "if .lAccess", 4 )
			.AgregarLinea( "else", 4 )
			
			loParametros = this.ObtenerDatosDelParametro( tcParametros )

			.EscribirObjeto( loParametros, 5 )

			lcNombreObjetoDatos = this.ObtenerNombreObjetoDatosParametro( loParametros )

			.AgregarLinea( "with " + iif( this.cTipo == "PARAMETROS", "goParametros", "goRegistry" ) + ".oDatos", 5 )
			.AgregarLinea( "if .ExisteConfigurador( loConsultaParametro )", 6 )
			.AgregarLinea( "this." + tcParam + " = .SetearConfiguracion( txValor, loConsultaParametro )", 7 )
			.AgregarLinea( "else", 6 )
			.AgregarLinea( "this." + tcParam + " = ." + lcNombreObjetoDatos + ".Setear( txValor, loConsultaParametro )", 7 )
			.AgregarLinea( "endif", 6 )
			.AgregarLinea( "endwith", 5 )

			.AgregarLinea( "endif", 4 )
			.AgregarLinea( "." + tcParam + " = txValor ", 4 )
			.AgregarLinea( "return ." + tcParam + "", 4 )
			.AgregarLinea( "" )
			.AgregarLinea( "endif", 3 )
			.AgregarLinea( "endwith", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 



	*-----------------------------------------------------------------------------------------
	function AgregarDestroy() as Void
		local lcDestroy as String 
		
		text to lcDestroy noshow flags 2  
			*-----------------------------------------------------------------------------------------
			function Destroy()
				local lnCantidad as Integer, laPropiedades as array, lnTablaActual as Integer,;
				lnPropiedadActual as Integer, lcPropiedad as String, lcEliminaReferencia as String    
				dimension laPropiedades(1)

				this.lDestroy = .t.

				lnCantidad = Amembers(laPropiedades,this,0,"U" )
				for lnPropiedadActual = 1 to lnCantidad
					lcPropiedad = "this."+ alltrim(laPropiedades(lnPropiedadActual))
					if vartype ( evaluate(lcPropiedad) ) = "O"
						if pemstatus(&lcPropiedad,"release",5)
							lcEliminaReferencia = lcPropiedad + ".release"
							&lcEliminaReferencia
						endif
					endif
				endfor

			endfunc

			*-----------------------------------------------------------------------------------------
			function Release() as Void
				release this 
			endfunc 
		endtext

		this.AgregarLinea( lcDestroy )
			
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function EscribirObjeto( toParametros as Object, tntab as integer ) As Void
		local lcNivel as Character, lcObjeto as String, lcValor as string, loParametros as Object
		
		if vartype( tntab ) # "N"
			tntab = 3
		endif
		
		lcNivel = this.ObtenerNivelParametro( toParametros )
		
		With This
			.AgregarLinea( "loConsultaParametro = newobject('ConsultaParametro')" , tnTab )
			.AgregarLinea( "with loConsultaParametro", tntab )
			tnTab = tnTab + 1
				.AgregarLinea( ".Nivel = " + lcNivel, tntab )
				.AgregarLinea( ".idNodo = " + toParametros.idNodo, tntab )
				.AgregarLinea( ".Parametro = '" + toParametros.Parametro + "'", tntab )
				.AgregarLinea( ".Proyecto = '" + toParametros.Proyecto + "'", tntab )			
				.AgregarLinea( ".TipoDato = '" + toParametros.TipoDato + "'", tntab )
				.AgregarLinea( ".Default = " + toParametros.Default, tntab )					
				.AgregarLinea( ".IdUnico = '" + toParametros.IdUnico + "'", tntab )
				tnTab = tnTab - 1
			.AgregarLinea( "endwith", tntab )
		endwith
		
	Endfunc

	*-----------------------------------------------------------------------------------------
	function TransformarDefault( tcParametro as string, tcTipoDato as string ) as Variant 
		Local lcRetorno as string, ldFecha as Date

		lcRetorno = alltrim( tcParametro )
		tcTipoDato = alltrim( tcTipoDato )

		do case
			case tcTipoDato = "N"
				if empty( lcRetorno )
					lcRetorno = '0'
				endif	
			case tcTipoDato = "D"
				ldFecha = ctod(lcRetorno)
				if empty(ldFecha)
					lcRetorno = "{  /  /    }"
				else
					lcRetorno = "{^"+transform(year(ldFecha))+"-"+transform(month(ldFecha))+"-"+transform(day(ldFecha))+ "}"
				endif
			case tcTipoDato = "L"
				lcRetorno = icase( inlist( upper( lcRetorno ), ".T.", "T" ), ".T.";
						, inlist( upper( lcRetorno ), ".F.", "F" ), ".F." )

			case tcTipoDato = "C"
				lcRetorno = "'" + lcRetorno + "'"
		endcase

		return lcRetorno
	endfunc


	*-----------------------------------------------------------------------------------------
	function ObtenerHijos( tnPadre as integer, tcProyecto as string ) as string
		local lcRetorno as string

		lcRetorno = sys(2015)
		select nodo, nombre, padre from c_jerarquianodos where padre = tnPadre and ;
			iif( empty( tcProyecto ), .t., proyecto = tcProyecto );
			into cursor ( lcRetorno )
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerParametros( tnPadre as integer, tcProyecto as String ) as string
		local lcRetorno as string, lcTabla as string
		lcRetorno = ""

		lcTabla = "c_Parametros"
		
		lcRetorno = sys(2015)
		select * from ( lcTabla ) where idnodo = tnPadre and ;
			iif( empty( tcProyecto ), .t., proyecto = tcProyecto );
			into cursor ( lcRetorno )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDelParametro ( tcParametros as String ) as Object
	
		local loObjeto as Object, lcValor as String
			loObjeto = newobject( "custom" )

			with loObjeto
				.addproperty( 'Organizacion', Alltrim( Str( &tcParametros..Organizacion ) ) )
				.addproperty( 'Sucursal', Alltrim( Str( &tcParametros..Sucursal ) ) )			
				.addproperty( 'Puesto', Alltrim( Str( &tcParametros..Puesto ) ) )
				.addproperty( 'idNodo', Alltrim( Str( &tcParametros..idNodo ) ) )
				.addproperty( "Parametro", Alltrim( &tcParametros..Parametro ) )
				.addproperty( 'Proyecto', Alltrim( &tcParametros..Proyecto ) ) 			
				.addproperty( 'TipoDato', Alltrim( &tcParametros..TipoDato ) ) 
				lcValor = this.TransformarDefault( &tcParametros..Default, &tcParametros..TipoDato )
				.addproperty( 'Default', lcValor ) 
				.addproperty( 'IdUnico', &tcParametros..IdUnico ) 
			endwith	

			with this
				if .nProyecto = 7				
					loObjeto = .VerificarParametrosUsuarioLince( loObjeto )
				endif	
			endwith	
							
			return loObjeto		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarParametrosUsuarioLince( toObjeto as Object ) as Object
		
		local loObjeto as Object
		loObjeto = toObjeto
		
		do case
			case upper( loObjeto.parametro )  = upper ( 'Pregunta Si Imprime Ticket-Factura Al Finalizar' )
				loObjeto.TipoDato = 'N'				
				loObjeto.Default = '1'	
				lcValor = this.TransformarDefault( loObjeto.Default, loObjeto.TipoDato )
				loObjeto.Default = lcValor
					
		endcase

		return loObjeto
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function ModificarInicializacionParametrosLince( tcValor as String, tcParametro as String ) as String
	
		local lcRetorno as String	
		
		do case
			case upper( tcParametro ) = upper ( 'Pregunta Si Imprime Ticket-Factura Al Finalizar' )
				lcRetorno = "1"		
			otherwise
				lcRetorno = tcValor	
		endcase
		
		return lcRetorno		

	endfunc 
	*-----------------------------------------------------------------------------------------	
	

enddefine

