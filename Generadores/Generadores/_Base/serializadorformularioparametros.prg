define class SerializadorFormularioParametros as SerializadorFormularioSinMenu of SerializadorFormularioSinMenu.prg

	cPath = "Generados\"
	
	*-------------------------------------------------------------------------
	Function SetearTitulo() as void
		local lcTitulo as String
		
		with this
			lcTitulo = alltrim( .oMetadata.Titulo )
			.AgregarLinea( "this.caption = '" + alltrim( _screen.Zoo.app.Nombre ) +  " - " + alltrim( lcTitulo )  + "'", 2 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarCabeceraInit() as Void
		with this
			.AgregarLinea( "function Init( tcCursor as string ) as boolean", 1 )
			.AgregarLinea( "this.cCursor = tcCursor", 2 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarPieDelInit() as Void
		with this
			*** Se le saco el dodefault() a proposito para que no agregue la statusbar
*			dodefault()

			.AgregarLinea( "" )
			.AgregarLinea( "this.DespuesDelInit()",2)
			.AgregarLinea( "this.InicializaControles()" )
			.AgregarLinea( "this.oKontroler.DespuesDeInicializaControles()" )
		endwith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerPrimerControl( tocontrol as Object, tcatributo as String, tcMinPrimerControlxOrdenFiltro as Integer ) as Void
		return tcMinPrimerControlxOrdenFiltro
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EsPropiedadDeClaseProxy( tcPropiedad as String ) as Boolean
		local llRetorno
		llRetorno = inlist( tcPropiedad,"BACKCOLOR","BACKSTYLE","BORDERCOLOR","BORDERSTYLE","DISABLEDBACKCOLOR","DISABLEDFORECOLOR","FONTITALIC","FONTNAME","FONTSIZE","NBACKCOLORCLARO","NBACKCOLORCONFOCO","NBACKCOLORNORMAL","NBACKCOLOROBLIGSINFOCO","NBACKCOLORSINFOCO","NDISABLEDBACKCOLORCLARO","NDISABLEDBACKCOLORNORMAL","NFORECOLORCONFOCO","NFORECOLOROBLIGSINFOCO","NFORECOLORSINFOCO","SELECTEDBACKCOLOR","SELECTONENTRY","SPECIALEFFECT")
		return llRetorno
	endfunc 
		
enddefine