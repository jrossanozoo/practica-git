Define Class colaboradoragrupadordeentidades as custom

	*-----------------------------------------------------------------------------------------
	function AnalizarArchivo( toArchivo as Object ) as Object
		Local loRetorno as Object
		
		loArchivo = newobject( "ArchivoEscrito" )
		loArchivo.cArchivo = toArchivo.Nombre
		loArchivo.cEntidad = toArchivo.Entidad
		loArchivo.cTipo = toArchivo.TipoComprobante
*!*			loArchivo.lHerencia = toArchivo.Herencia
		lcArchivoAux = sys( 2015 )
		create cursor ( lcArchivoAux ) ( txt C(250) )
		append from ( loArchivo.cArchivo ) type SDF
		lClase = .f.
		lCabecera = .f.
		lMetodo = .f.
		
		loItemMetodo = null
		select ( lcArchivoAux )
		go top
		scan
			lEnBlanco = .f.
			lcTxt = this.LimpiarLinea( txt ) &&iif(left(alltrim(txt),1) = chr(9),substr(alltrim(txt),2),alltrim(txt))
			if len(lctxt) = 0
				llEnBlanco = .t. 
			endif			
			DO CASE
				CASE left(upper(lcTxt),12 ) = "DEFINE CLASS"
				   lClase = .t.
				   lPropiedades = .t.
				CASE left(upper(lcTxt),8 ) = "FUNCTION" or left(upper(lcTxt),9 ) = "PROTECTED" or left(upper(lcTxt),6 ) = "HIDDEN"
				  lMetodo = .t.
				  if lPropiedades
				  	lPropiedades = .f.
				  endif
				  loItemMetodo = newobject("ItemMetodoEscrito","","",lcTxt,loArchivo.cEntidad , loArchivo.cTipo)
				CASE lMetodo and left(upper(lcTxt),6 ) = "RETURN"
				  loItemMetodo.VariableRetorno = alltrim( right( lcTxt, len(lctxt) - 6 ) )
				CASE lMetodo and left(upper( lcTxt ),7 ) = "ENDFUNC"
				  lMetodo = .f.
				  loArchivo.oColeccionDeMetodos.agregar( loItemMetodo, loItemMetodo.NombreDelMetodo )
			  	CASE lclase and left(upper(lcTxt),9 ) = "ENDDEFINE"
				  lClase = .f.
				otherwise
					if lClase
						if lMetodo
							loItemMetodo.AgregarCuerpo( lctxt )
						else
							if lPropiedades and atc( "=", lcTxt ) > 0 and left( lcTxt , 6) != "*MOCK*"
								loItemProp = newobject( "Propiedades","","", lcTxt )
								loArchivo.oColeccionDePropiedades.agregar( loItemProp )
							endif
						endif
					endif
			endcase
		endscan
		
		use in select( lcArchivoAux )
		
		return loArchivo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function LimpiarLinea( lcLinea as String ) as Object
		lcRetorno = alltrim( lcLinea )
		if !empty( lcRetorno )
			for j = 1 to len( lclinea )
				if left( lcRetorno, 1 ) = chr(9) or left( lcRetorno, 1 ) = chr(32) 
					lcRetorno = substr( lcLinea, j)
				else
					exit
				endif
			endfor
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReOrdenarDatosPorMetodo( toArchivos as Object ) as Object
		loMetodos = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		loParametros = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		llYaPasoInicializar = .f.
		for each oArchivo in toArchivos
			llEsKontroler = atc( "KONTROLER", upper( oarchivo.carchivo ) ) > 0
			lcNombreArchivo = oArchivo.cArchivo
			oArchivo.oColeccionDePropiedades.AddProperty( "TipoComprobante", oArchivo.cTipo  )
			oArchivo.oColeccionDePropiedades.AddProperty( "Entidad", oArchivo.cEntidad )
			loParametros.agregar( oArchivo.oColeccionDePropiedades , oArchivo.cArchivo )
			* aca me fijo los metodos del archivo, si no esta en la nueva coleccion de metodos, creo un item y lo agrego
			* si esta, agrego el nuevo
			* tengo q ademas agregar los datos aca
			for each oMetodo in oArchivo.oColeccionDeMetodos
				lcNombreMetodo = oMetodo.NombreDelMetodo
				if loMetodos.buscar( oMetodo.NombreDelMetodo )
					loExistente = loMetodos.Item[oMetodo.NombreDelMetodo]
					llYaPasoInicializar = this.AjustarMetodoInicializar( oMetodo, llYaPasoInicializar )
					loExistente.Agregar( oMetodo, lcNombreArchivo )
				else
					loColArchivo = _screen.zoo.CrearObjeto( 'zoocoleccion' )
					llYaPasoInicializar = this.AjustarMetodoInicializar( oMetodo, llYaPasoInicializar )
					loColArchivo.agregar( oMetodo, lcNombreArchivo )
					loMetodos.Agregar( loColArchivo, lcNombreMetodo )
				endif
			endfor
		endfor
		loRetorno = newobject("CodigoOrdenado","","",loMetodos,loParametros)
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AjustarMetodoInicializar( toMetodo as Object, tlYaPaso as Boolean, tlKontroler as boolean ) as Object
		llRetorno = .f.
		if !tlYaPaso and alltrim( upper( toMetodo.NombreDelMetodo ) )= "INICIALIZAR"
			toMetodo.NombreDelMetodo = toMetodo.NombreDelMetodo + "GeneradoSegunEntidades"
			llRetorno = .t.
		endif
		return llRetorno
	endfunc
	
	
enddefine

*-----------------------------------------------------------------------------------------
define class ItemMetodoEscrito as Custom

	FirmaCompleta = ""
	Modificador = ""
	TipoDeRetorno = ""
	NombreDelMetodo = ""
	Parametros = null
	ParametrosUso = null
	Cuerpo = null
	VariableRetorno = ""
	Entidad = ""
	TipoComprobante = ""
	*-----------------------------------------------------------------------------------------
	function Init( lcFirma as String, tcEntidad as String, tcTipo ) as Object
		lcEmpiezaNombreFuncion = atc( "function ", lcFirma) && +9 empieza el nombre, asi termina el modificador
		lcParametrosApertura = atc( "(", lcFirma ) + 1
		lcAs = atc( " as ", lcFirma ) 
		lcParametrosCierre = atc( ")", lcFirma )
		this.FirmaCompleta = lcFirma
		this.Modificador = iif( lcEmpiezaNombreFuncion > 3, alltrim( substr( lcFirma, 1, lcEmpiezaNombreFuncion - 1 ) ), "" )
		this.TipoDeRetorno = this.ObtenerTipoRetorno( lcFirma )
		this.NombreDelMetodo = substr( lcFirma, lcEmpiezaNombreFuncion + 9, lcParametrosApertura - ( lcEmpiezaNombreFuncion + 10 ) ) 
		this.ObtenerParametros( substr( lcFirma, lcParametrosApertura , lcParametrosCierre - lcParametrosApertura ) )
		this.Entidad = tcEntidad 
		this.TipoComprobante = tcTipo 
		this.Cuerpo = _screen.zoo.CrearObjeto( 'zoocoleccion' )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AsignarRetorno( tcRetorno as String ) as Object
		this.Variableretorno = substr( tcRetorno, atc( "return ", tcRetorno) + 8 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarCuerpo( tcCuerpo as String ) as Void
		this.Cuerpo.Agregar( tcCuerpo )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	PROTECTED function ObtenerParametros( tcParametros as String ) as Object
		loParams = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		loParamsUso = _screen.zoo.CrearObjeto( 'zoocoleccion' )
		alines( laParametros, tcParametros, ",")
		FOR EACH lcitem IN laParametros
			IF !EMPTY(lcItem )
				loParams.Agregar( lcItem )
				lcSinDefinicion = substr( lcItem,1,at(" as",lcItem )-1)
				if !empty( lcItem ) 
					if !empty( lcSinDefinicion )
						loParamsUso.Agregar( lcSinDefinicion )
					else
						loParamsUso.Agregar( lcItem )
					endif	
				endif
			endif
		endfor
		this.Parametros = loParams
		this.ParametrosUso = loParamsUso
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoRetorno( tcFirma as String ) as Void
		lcRetorno = ""
		lnPosUltimoDefinicion = ratc( " as", tcFirma ) + 3
		lnPosCierreParentesis = ratc( ")", tcFirma )
		if lnPosUltimoDefinicion > lnPosCierreParentesis
			lcRetorno = alltrim( substr( tcFirma, lnPosUltimoDefinicion ) )
		endif

		return lcRetorno
	endfunc
	
enddefine



*-----------------------------------------------------------------------------------------
define class ArchivoEscrito as Custom

	cArchivo = ""
	cEntidad = ""
	cTipo = ""
	lHerencia = .f. 
	oColeccionDePropiedades = null
	oColeccionDeMetodos = null
	
	*-----------------------------------------------------------------------------------------
	function Init() as Object
		this.oColeccionDePropiedades= _screen.zoo.crearobjeto( "ZooColeccion" )
		this.oColeccionDeMetodos = _screen.zoo.crearobjeto( "ZooColeccion" )
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class CodigoOrdenado as Custom

	oMetodos = null
	oParametros = null
	
	*-----------------------------------------------------------------------------------------
	function Init( toMetodos as Object, toParametros as Objects ) as Object
		this.oMetodos = toMetodos
		this.oParametros = toParametros
	endfunc
ENDDEFINE

*-----------------------------------------------------------------------------------------
define class Propiedades as Custom

	cNombre = ""
	cValor = ""
	
	*-----------------------------------------------------------------------------------------
	function Init( tcDeclaracion as string ) as Object
		alines( laPropiedades, tcDeclaracion, "=")
		this.cNombre = ALLTRIM( laPropiedades[1] )
 		this.cValor = ALLTRIM( laPropiedades[2] )
	endfunc
enddefine