Define Class CacheFunciones As Custom

	oSingle = null
	ldestroy = .f.
	
	*-----------------------------------------------------------------------------------------
	Function Init( toContenedor As Object ) As Boolean
		local loSingle As CacheFuncionesSingleton of CacheFunciones.prg

		dodefault()

		this.oSingle = This.obtenerInstanciaSingleton( toContenedor )
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.oSingle = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Obtener( tcClase as String, tcFuncion as String, tcClave as String ) as Variant
		return this.oSingle.Obtener( tcClase, tcFuncion, tcClave )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Agregar( tcClase as String, tcFuncion as String, tcClave as String, txValor as Variant ) as Variant
		return this.oSingle.Agregar( tcClase, tcFuncion, tcClave, txValor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Variant
		return this.oSingle.Limpiar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Hidden Function ObtenerInstanciaSingleton( toContenedor as Object ) as Object
		local loContenedor as Object, loSingle As CacheFuncionesSingleton of CacheFunciones.prg

		loContenedor = null
		if type( "toContenedor" ) = "O" and !isnull( toContenedor )
			loContenedor = toContenedor 
		else
			if type( "_screen.zoo.app" ) == "O" and !isnull( _screen.zoo.app )
				loContenedor = _Screen.zoo.app
			endif
		endif
		* Descripción:	Método que devuelve una referencia a la instancia única (Singleton) de tipo CacheFuncionesSingleton.

		* Se chequea si existe la propiedad que almacena la referencia Singleton, si la misma es de tipo objeto
		* y si el tipo de objeto concuerda con el Singleton (CacheFuncionesSingleton.
		If !isnull( loContenedor ) 
			if Pemstatus( loContenedor, "oCacheFunciones", 5 )
				if ( Vartype( loContenedor.oCacheFunciones ) != "O" and isnull( loContenedor.oCacheFunciones ) ) or ;
					( Upper( Alltrim( loContenedor.oCacheFunciones.Class ) ) != "CACHEFUNCIONESSINGLETON" )
					
					loContenedor.oCacheFunciones = Createobject("CacheFuncionesSingleton", loContenedor )
				endif
			else
				loContenedor.AddProperty( "oCacheFunciones", Createobject("CacheFuncionesSingleton", loContenedor ) )
			endif
		Endif

		* Se verifica el posible retorno. Si se pudo crear una instancia correcta, se la retorna, sino se arroja una excepción.
		If !isnull( loContenedor ) and Vartype( loContenedor.oCacheFunciones ) == "O" And Upper( Alltrim( loContenedor.oCacheFunciones.Class ) ) == "CACHEFUNCIONESSINGLETON"
			return loContenedor.oCacheFunciones
		Else
			Throw "Error de instanciación de la Clase única"
		Endif
	endfunc

Enddefine


Define Class CacheFuncionesSingleton As Custom

	protected oCache
	oCache = null

	ldestroy = .f.
	
	*-----------------------------------------------------------------------------------------
	Function Init( toContenedor As Object ) As Boolean
		if this.Existo( toContenedor )
			return .f.
		endif
		
		this.oCache = Createobject( "Cache" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	hidden function Existo( toContenedor as Object ) as Boolean
		local loContenedor as object, llRetorno as Boolean 
		
		llRetorno = .f.

		if type( "toContenedor.oCacheFunciones.Class" ) == "C" ;
				and toContenedor.oCacheFunciones.Class == this.Class ;
				and toContenedor.oCacheFunciones == this
				
			llRetorno = .t.
		endif

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Destroy() As Void
		this.ldestroy = .t.

		if type( "this.oCache" ) = "O" and !isnull( this.oCache )
			this.oCache.Remove( -1 )
		endif
		this.oCache = null

		DoDefault()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Agregar( tcClase as String, tcFuncion as String, tcClave as String, txValor as Variant ) as Void
		local loClase as Cache of ClaseFunciones.prg, loFuncion as Cache of ClaseFunciones.prg

		loClase = this.oCache.Obtener( upper( alltrim( tcClase ) ) )
		if isnull( loClase )
			loClase = Createobject( "Cache" ) 
			this.oCache.Agregar( tcClase, loClase )
		endif
		
		loFuncion = loClase.Obtener( upper( alltrim( tcFuncion ) ) )
		if isnull( loFuncion )
			loFuncion = Createobject( "Cache" ) 
			loClase.Agregar( tcFuncion, loFuncion )
		endif

		loFuncion.Agregar( tcClave, txValor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Obtener( tcClase as String, tcFuncion as String, tcClave as String ) as Variant
		local loRetorno as Cache of CacheFunciones.prg, loClase as Cache of ClaseFunciones.prg, loFuncion as Cache of ClaseFunciones.prg

 		loRetorno = null
 		
		try
			loClase = this.oCache.Obtener( upper( alltrim( tcClase ) ) )
			loFuncion = loClase.Obtener( upper( alltrim( tcFuncion ) ) )
			loRetorno = loFuncion.Obtener( upper( alltrim( tcClave ) ) )
		catch to loError
		endtry
						
		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.oCache.Limpiar()
	endfunc 

Enddefine

*-----------------------------------------------------------------------------------------
define class Cache as collection

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.Remove(-1)
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Obtener( tcClave as String ) as Variant
		local lxRetorno as Variant
		
		try
			lxRetorno = this.Item[ upper( alltrim( tcClave ) ) ]
		catch
			lxRetorno = null
		endtry
		
		return lxRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Agregar( tcClave as String, txDato as Variant ) as void
		local loError as Exception 

		try
			this.Add( txDato, upper( alltrim( tcClave ) ) )
		catch to loError
			loError.Message = "No se puede agregar la clave " + tcClave + " en el cache de funciones. " + loError.Message
			throw loError
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.Remove( -1 )

enddefine

*-----------------------------------------------------------------------------------------
function ContarExitos( toCache, tcNombre ) as Void
	if type( "gnRecu" ) = "N"
		gnRecu = gnRecu + 1
	else
		public gnRecu 
		gnRecu = 0
	endif
	return tcNombre + " - exito " + transform( gnRecu ) &&+ " de " + transform( toCache.Count )
endfunc 

