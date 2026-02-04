define class GeneradorFormulariosDuros as Generador of generador.prg
	#if .f.
		local this as GeneradorFormulariosDuros of GeneradorFormulariosDuros.prg
	#endif

	cPath = "Generados\"
	cRuta = ""
	nEstilo = 0
	
	*-----------------------------------------------------------------------------------------
	function Generar( tcForm as variant, tcRuta as string, tnEstilo as integer ) as Void
		local loError as Exception
		
		with this
			.cRuta = tcRuta
			.nEstilo = tnEstilo
			.cSufijo = "Estilo" + transform( tnEstilo )
			
			dodefault( tcForm )
			
			if upper( justext( tcForm ) ) = "VCX"
				clear classlib ( tcForm )
				clear classlib _argCommandBarsBase
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarCodigo() as Void
		local loFormulario as object

		with this
			loFormulario = .Dibujar()
			.Serializar( loFormulario )

			.EventoMensajeProceso( "Generando FRM Duro " + .cTipo + ". Finalizando Proceso...")

			loformulario.release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		with this
			.cArchivo = .cPath + "Frm_" + alltrim( proper( .cPrefijo  ) ) + ;
					alltrim( Proper( juststem( .cTipo ) ) ) + alltrim( proper( .cSufijo ) ) + ".prg"
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Dibujar() as Form
		local loRetorno as form, loDib as Object

		loDib = _screen.zoo.crearobjeto( "DibujanteFormDuros" )
		loRetorno = loDib.Dibujar( this.cTipo, this.cRuta, this.nEstilo )

		loDib.release()
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Serializar( toForm as Form )  as Void
		local loSerializador as object

		loSerializador = _screen.zoo.crearobjeto( "SerializadorFormDuros" )
		loSerializador.cPath = this.cPath
		loSerializador.Serializar( toForm, strtran( justfname( this.cArchivo ), ".prg", "" ) )
		loSerializador.release()
	endfunc 
enddefine

