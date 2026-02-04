define class ControlarTablasAbiertas as Custom

	protected oMensajes, oColTablasAbiertas, cClasePadre, nSessionPadre, cArchivoLog, cTipo, lLoguear, oColTablasQueDebenQuedarAbiertas 
	oMensajes = null
	oColTablasAbiertas = null
	oColTablasQueDebenQuedarAbiertas = null
	Dimension laSesiones(1)	
	cClasePadre = ""
	nSessionPadre = 0
	cArchivoLog = "c:\LogDeTablasAbiertasPorGenerador.LOG"
	cTipo = ""
	lLoguear = .f.
		
	*-----------------------------------------------------------------------------------------
	function IniciaControl( toClase as Session )
		this.cClasePadre = toClase.class
		this.cTipo = iif( type( "toClase.cTipo" ) == "C", toClase.cTipo, "Desconocido" )
		this.nSessionPadre = toClase.DataSessionId
		this.oMensajes = newobject( "Collection" )
		this.oColTablasAbiertas = newobject( "Collection" )
		this.oColTablasQueDebenQuedarAbiertas = newobject( "Collection" )
		this.CargarTablasAbiertasSegunSesion( this.nSessionPadre )		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function FinalizaControl() as Void
		this.ChequearTablasAbiertas( this.nSessionPadre )
		if this.lLoguear
			this.GrabarMensajesEnLog()	
		endif
		local loTabla as Object
		for each loTabla in this.oColTablasAbiertas foxobject
			loTabla.remove(-1)
		endfor
		this.oColTablasAbiertas.remove(-1)
		this.oColTablasQueDebenQuedarAbiertas.remove(-1)
		this.oMensajes.remove(-1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarTablaQueDebeQuedarAbierta( tcTabla as String ) as Void
		try
			this.oColTablasQueDebenQuedarAbiertas.add( tcTabla, upper( alltrim( tcTabla ) ) )	
		catch
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GrabarLogEnArchivo( TcMensaje as String ) as Void
		local lcMensaje as String
		lcMensaje = tcMensaje + chr(13) + chr(10)
		strtofile( lcMensaje, this.cArchivoLog, 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GrabarMensajesEnLog() as Void
		local lcMensaje as String, lcItem as String
		lcMensaje = ""
		for each lcItem in this.oMensajes foxobject
			lcMensaje = lcMensaje + lcItem + chr( 13 ) + chr( 10 )
		endfor
		if !empty( lcMensaje )
			this.GrabarLogEnArchivo( transform( this.cClasePadre ) + " (" + this.cTipo + "): " + chr( 13 ) + chr( 10 ) + lcMensaje )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarTablasAbiertasSegunSesion( tnSesion as Integer ) as Void
		local lnCant as Integer, i as Integer, lcClave as String
		local array laTablas[1]
		
		lnCant = aused( laTablas, tnSesion )
		lcClave = alltrim( transform( tnSesion ) )
		
		if this.oColTablasAbiertas.GetKey( lcClave ) > 0
			this.oColTablasAbiertas.Remove( lcClave )
		endif
		
		this.oColTablasAbiertas.Add( newobject( "Collection" ), lcClave )
		
		for i = 1 to lnCant
			this.oColTablasAbiertas.Item[ lcClave ].Add( laTablas[i, 1], alltrim( upper( laTablas[i, 1] ) ) )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ChequearTablasAbiertas( tnSesion as integer ) as Void
		local i as Integer, lnSesiones as Integer
		local array aSessiones[1]
		
		with this
			if empty( tnSesion )
				lnSesiones = asessions( aSesiones )
				for i = 1 to lnSesiones
					this.ChequearTablasAbiertasSegunSesion( aSesiones[ i ])
				endfor
			else
				this.ChequearTablasAbiertasSegunSesion( tnSesion )			
			endif
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ChequearTablasAbiertasSegunSesion( tnSesion as Integer ) as Void
		local lnCant as Integer, i as Integer, lcClave as String, lnSesion as Integer, lcTabla as string
		local array laTablas[1]
		
		lnCant = aused( laTablas, tnSesion )
		lcClave = alltrim( transform( tnSesion ) )
		lnSesion = set( "Datasession" )
		if this.oColTablasAbiertas.GetKey( lcClave ) > 0
			for i = 1 to lnCant
				lcTabla = alltrim( upper( laTablas[i, 1] ) )
				if this.oColTablasAbiertas.Item[ lcClave ].GetKey( lcTabla ) == 0 &&No existia
					if this.oColTablasQueDebenQuedarAbiertas.GetKey( lcTabla ) == 0 && No Debe quedar abierta.
						this.AgregarMensaje( "La tabla/cursor " + lcTabla + " de la sesión" + lcClave + " quedo abierta despues de generar." )
						if tnSesion == lnSesion
							use in select( laTablas[i, 1] )
						else
							set datasession to tnSesion
							use in select( laTablas[i, 1] )
							set datasession to lnSesion
						endif
					endif
				endif
			endfor
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarMensaje( tcMensaje ) as Void
		if this.lLoguear
			this.oMensajes.Add( tcMensaje )
		endif
	endfunc 

enddefine
