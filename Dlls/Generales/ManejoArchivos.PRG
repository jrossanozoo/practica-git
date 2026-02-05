define class ManejoArchivosCore as custom

	#IF .f.
		Local this as ManejoArchivosCore of ManejoArchivosCore.prg
	#ENDIF

	oZoo = null
	
	*-----------------------------------------------------------------------------------------
	function oZoo_Access() as Object
		if vartype( this.oZoo ) != "O"
			this.oZoo = newobject( "zoo", "zoo.PRG" )
		endif
		return this.oZoo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File para verificar existencia
	function ExisteArchivo( tcArchivo as String ) as Boolean
		local loFile as Object
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			return loFile.Exists( tcArchivo )
		catch
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Directory para verificar existencia
	function ExisteDirectorio( tcDirectorio as String ) as Boolean
		local loDirectory as Object
		try
			loDirectory = this.oZoo.CrearObjeto( "System.IO.Directory" )
			return loDirectory.Exists( tcDirectorio )
		catch
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Directory.CreateDirectory (crea toda la jerarquía)
	function CrearCarpeta( tcCarpeta as String ) as Boolean
		local loDirectory as Object, loDirectoryInfo as Object
		try
			loDirectory = this.oZoo.CrearObjeto( "System.IO.Directory" )
			if !loDirectory.Exists( tcCarpeta )
				loDirectoryInfo = loDirectory.CreateDirectory( tcCarpeta )
				return loDirectoryInfo.Exists
			endif
			return .t.
		catch to loEx
			this.LoguearError( "Error al crear carpeta: " + tcCarpeta + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Directory.Delete con recursividad
	function BorrarCarpeta( tcDirectorio as String ) as Boolean
		local loDirectory as Object
		try
			loDirectory = this.oZoo.CrearObjeto( "System.IO.Directory" )
			if loDirectory.Exists( tcDirectorio )
				loDirectory.Delete( tcDirectorio, .t. ) && true para recursivo
			endif
			return .t.
		catch to loEx
			this.LoguearError( "Error al borrar carpeta: " + tcDirectorio + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.Delete
	function BorrarArchivo( tcArchivo as String ) as Boolean
		local loFile as Object
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			if loFile.Exists( tcArchivo )
				loFile.Delete( tcArchivo )
			endif
			return .t.
		catch to loEx
			this.LoguearError( "Error al borrar archivo: " + tcArchivo + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.Copy
	function CopiarArchivo( tcOrigen as String, tcDestino as String, tlSobreEscribir as Boolean ) as Boolean
		local loFile as Object
		if vartype( tlSobreEscribir ) != "L"
			tlSobreEscribir = .f.
		endif
		
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			loFile.Copy( tcOrigen, tcDestino, tlSobreEscribir )
			return .t.
		catch to loEx
			this.LoguearError( "Error al copiar archivo: " + tcOrigen + " -> " + tcDestino + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.Move
	function MoverArchivo( tcOrigen as String, tcDestino as String, tlSobreEscribir as Boolean ) as Boolean
		local loFile as Object
		if vartype( tlSobreEscribir ) != "L"
			tlSobreEscribir = .f.
		endif
		
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			
			* Si existe el destino y se permite sobreescribir, lo eliminamos primero
			if tlSobreEscribir and loFile.Exists( tcDestino )
				loFile.Delete( tcDestino )
			endif
			
			loFile.Move( tcOrigen, tcDestino )
			return .t.
		catch to loEx
			this.LoguearError( "Error al mover archivo: " + tcOrigen + " -> " + tcDestino + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.ReadAllText con encoding UTF-8
	function LeerArchivo( tcRuta as String, tcEncoding as String ) as String
		local loFile as Object, loEncoding as Object, lcContenido as String
		if vartype( tcEncoding ) != "C" or empty( tcEncoding )
			tcEncoding = "UTF8"
		endif
		
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			loEncoding = this.oZoo.CrearObjeto( "System.Text.Encoding" )
			
			do case
				case upper( tcEncoding ) = "UTF8"
					lcContenido = loFile.ReadAllText( tcRuta, loEncoding.UTF8 )
				case upper( tcEncoding ) = "ASCII"
					lcContenido = loFile.ReadAllText( tcRuta, loEncoding.ASCII )
				case upper( tcEncoding ) = "UNICODE"
					lcContenido = loFile.ReadAllText( tcRuta, loEncoding.Unicode )
				otherwise
					lcContenido = loFile.ReadAllText( tcRuta )
			endcase
			
			return lcContenido
		catch to loEx
			this.LoguearError( "Error al leer archivo: " + tcRuta + " - " + loEx.Message )
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.WriteAllText con encoding UTF-8
	function EscribirArchivo( tcRuta as String, tcContenido as String, tcEncoding as String ) as Boolean
		local loFile as Object, loEncoding as Object
		if vartype( tcEncoding ) != "C" or empty( tcEncoding )
			tcEncoding = "UTF8"
		endif
		
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			loEncoding = this.oZoo.CrearObjeto( "System.Text.Encoding" )
			
			do case
				case upper( tcEncoding ) = "UTF8"
					loFile.WriteAllText( tcRuta, tcContenido, loEncoding.UTF8 )
				case upper( tcEncoding ) = "ASCII"
					loFile.WriteAllText( tcRuta, tcContenido, loEncoding.ASCII )
				case upper( tcEncoding ) = "UNICODE"
					loFile.WriteAllText( tcRuta, tcContenido, loEncoding.Unicode )
				otherwise
					loFile.WriteAllText( tcRuta, tcContenido )
			endcase
			
			return .t.
		catch to loEx
			this.LoguearError( "Error al escribir archivo: " + tcRuta + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Path para manipulación de rutas multiplataforma
	function CombinarRutas( tcRuta1 as String, tcRuta2 as String, tcRuta3 as String, tcRuta4 as String ) as String
		local loPath as Object, lcRuta as String
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			
			lcRuta = loPath.Combine( tcRuta1, tcRuta2 )
			
			if vartype( tcRuta3 ) = "C" and !empty( tcRuta3 )
				lcRuta = loPath.Combine( lcRuta, tcRuta3 )
			endif
			
			if vartype( tcRuta4 ) = "C" and !empty( tcRuta4 )
				lcRuta = loPath.Combine( lcRuta, tcRuta4 )
			endif
			
			return lcRuta
		catch to loEx
			this.LoguearError( "Error al combinar rutas - " + loEx.Message )
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Path para obtener información de rutas
	function ObtenerDirectorioPadre( tcRuta as String ) as String
		local loPath as Object
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			return loPath.GetDirectoryName( tcRuta )
		catch
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreArchivo( tcRuta as String, tlSinExtension as Boolean ) as String
		local loPath as Object
		if vartype( tlSinExtension ) != "L"
			tlSinExtension = .f.
		endif
		
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			if tlSinExtension
				return loPath.GetFileNameWithoutExtension( tcRuta )
			else
				return loPath.GetFileName( tcRuta )
			endif
		catch
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerExtension( tcRuta as String ) as String
		local loPath as Object
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			return loPath.GetExtension( tcRuta )
		catch
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.FileInfo para obtener información detallada
	function ObtenerInformacionArchivo( tcRuta as String ) as Object
		local loFileInfo as Object, loInfo as Object
		try
			loFileInfo = this.oZoo.CrearObjeto( "System.IO.FileInfo", .f., tcRuta )
			
			* Crear objeto con información básica
			loInfo = createobject( "Empty" )
			addproperty( loInfo, "Existe", loFileInfo.Exists )
			addproperty( loInfo, "Nombre", loFileInfo.Name )
			addproperty( loInfo, "NombreSinExtension", this.ObtenerNombreArchivo( tcRuta, .t. ) )
			addproperty( loInfo, "Extension", loFileInfo.Extension )
			addproperty( loInfo, "DirectorioPadre", loFileInfo.DirectoryName )
			addproperty( loInfo, "Tamaño", loFileInfo.Length )
			addproperty( loInfo, "FechaCreacion", loFileInfo.CreationTime )
			addproperty( loInfo, "FechaModificacion", loFileInfo.LastWriteTime )
			addproperty( loInfo, "FechaAcceso", loFileInfo.LastAccessTime )
			addproperty( loInfo, "SoloLectura", loFileInfo.IsReadOnly )
			
			return loInfo
		catch to loEx
			this.LoguearError( "Error al obtener información del archivo: " + tcRuta + " - " + loEx.Message )
			return null
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Directory.GetFiles con patrones
	function ObtenerArchivosEnDirectorio( tcDirectorio as String, tcPatron as String, tlRecursivo as Boolean ) as zooColeccion OF zooColeccion.prg
		local loDirectory as Object, loFiles as Object, loCol as zooColeccion OF zooColeccion.prg
		local lnSearchOption as Integer, lnI as Integer
		
		if vartype( tcPatron ) != "C" or empty( tcPatron )
			tcPatron = "*.*"
		endif
		if vartype( tlRecursivo ) != "L"
			tlRecursivo = .f.
		endif
		
		try
			loCol = this.oZoo.CrearObjeto( "ZooColeccion" )
			loDirectory = this.oZoo.CrearObjeto( "System.IO.Directory" )
			
			* SearchOption: 0 = TopDirectoryOnly, 1 = AllDirectories
			lnSearchOption = iif( tlRecursivo, 1, 0 )
			
			loFiles = loDirectory.GetFiles( tcDirectorio, tcPatron, lnSearchOption )
			
			for lnI = 1 to alen( loFiles )
				loCol.Agregar( loFiles( lnI ) )
			endfor
			
			return loCol
		catch to loEx
			this.LoguearError( "Error al obtener archivos del directorio: " + tcDirectorio + " - " + loEx.Message )
			return this.oZoo.CrearObjeto( "ZooColeccion" )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Directory.GetDirectories
	function ObtenerDirectoriosEnDirectorio( tcDirectorio as String, tcPatron as String, tlRecursivo as Boolean ) as zooColeccion OF zooColeccion.prg
		local loDirectory as Object, loDirectories as Object, loCol as zooColeccion OF zooColeccion.prg
		local lnSearchOption as Integer, lnI as Integer
		
		if vartype( tcPatron ) != "C" or empty( tcPatron )
			tcPatron = "*"
		endif
		if vartype( tlRecursivo ) != "L"
			tlRecursivo = .f.
		endif
		
		try
			loCol = this.oZoo.CrearObjeto( "ZooColeccion" )
			loDirectory = this.oZoo.CrearObjeto( "System.IO.Directory" )
			
			* SearchOption: 0 = TopDirectoryOnly, 1 = AllDirectories
			lnSearchOption = iif( tlRecursivo, 1, 0 )
			
			loDirectories = loDirectory.GetDirectories( tcDirectorio, tcPatron, lnSearchOption )
			
			for lnI = 1 to alen( loDirectories )
				loCol.Agregar( loDirectories( lnI ) )
			endfor
			
			return loCol
		catch to loEx
			this.LoguearError( "Error al obtener directorios: " + tcDirectorio + " - " + loEx.Message )
			return this.oZoo.CrearObjeto( "ZooColeccion" )
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File para atributos (más simple y multiplataforma)
	function SetearAtributosSoloLectura( tcArchivo as String, tlSoloLectura as Boolean ) as Boolean
		local loFile as Object, loFileInfo as Object
		if vartype( tlSoloLectura ) != "L"
			tlSoloLectura = .t.
		endif
		
		try
			loFileInfo = this.oZoo.CrearObjeto( "System.IO.FileInfo", .f., tcArchivo )
			loFileInfo.IsReadOnly = tlSoloLectura
			return .t.
		catch to loEx
			this.LoguearError( "Error al setear atributos: " + tcArchivo + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.Path.GetTempPath() y System.IO.Path.GetTempFileName()
	function ObtenerRutaTemporal() as String
		local loPath as Object
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			return loPath.GetTempPath()
		catch
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerArchivoTemporal() as String
		local loPath as Object
		try
			loPath = this.oZoo.CrearObjeto( "System.IO.Path" )
			return loPath.GetTempFileName()
		catch
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Modernizado: Usa System.IO.File.WriteAllBytes y ReadAllBytes para archivos binarios
	function LeerArchivoBinario( tcRuta as String ) as String
		local loFile as Object, loBytes as Object, lcContenido as String, lnI as Integer
		try
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			loBytes = loFile.ReadAllBytes( tcRuta )
			
			* Convertir bytes a string (para compatibilidad con VFP)
			lcContenido = ""
			for lnI = 1 to alen( loBytes )
				lcContenido = lcContenido + chr( loBytes( lnI ) )
			endfor
			
			return lcContenido
		catch to loEx
			this.LoguearError( "Error al leer archivo binario: " + tcRuta + " - " + loEx.Message )
			return ""
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EscribirArchivoBinario( tcRuta as String, tcDatos as String ) as Boolean
		local loFile as Object, loBytes as Object, lnI as Integer
		try
			* Convertir string a array de bytes
			loBytes = createobject( "Collection" )
			for lnI = 1 to len( tcDatos )
				loBytes.Add( asc( substr( tcDatos, lnI, 1 ) ) )
			endfor
			
			loFile = this.oZoo.CrearObjeto( "System.IO.File" )
			loFile.WriteAllBytes( tcRuta, loBytes )
			
			return .t.
		catch to loEx
			this.LoguearError( "Error al escribir archivo binario: " + tcRuta + " - " + loEx.Message )
			return .f.
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Mejorado: Sistema de logging unificado
	protected function LoguearError( tcMensaje as String ) as Void
		local lcMensaje as String, lcRutaLog as String
		
		lcMensaje = "[" + dtoc( date() ) + " " + time() + "] " + tcMensaje
		lcRutaLog = this.CombinarRutas( this.ObtenerRutaTemporal(), "ManejoArchivosCore.log" )
		
		try
			* Intentar usar el sistema de logging principal
			if type( "goServicios.logueos" ) == "O"
				goServicios.logueos.Loguear( lcMensaje )
			else
				* Fallback: escribir directamente al archivo de log
				this.EscribirArchivo( lcRutaLog, lcMensaje + chr(13) + chr(10), "UTF8" )
			endif
		catch
			* Si todo falla, no hacer nada para evitar errores en cascada
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Métodos de compatibilidad con la clase original (wrappers)
	*-----------------------------------------------------------------------------------------
	function ObtenerArchivo( tcExtension as String, tcTexto as String ) as string
		if vartype( tcExtension ) # 'C'
			tcExtension = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = ''
		endif
		return getFile( tcExtension, tcTexto )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerImagen( tcExtension as String, tcTexto as String ) as string
		if vartype( tcExtension ) # 'C'
			tcExtension = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = ''
		endif
		return getPict( tcExtension, tcTexto )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCarpeta( tcDirectorio as String, tcTexto as String ) as string
		if vartype( tcDirectorio ) # 'C'
			tcDirectorio = ''
		endif
		if vartype( tcTexto ) # 'C'
			tcTexto = 'Seleccione la carpeta y haga click en el botón Aceptar'
		endif	
		return getdir( tcDirectorio, tcTexto, "Carpeta", 16+64)
	endfunc

enddefine
