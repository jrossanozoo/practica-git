define class GeneradorDinamicoEstilos as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoEstilos of GeneradorDinamicoEstilos.prg
	#endif
	
	cTipo = "Estilo"
	nEstilo = 0
	cPath = "Generados\"

	*-----------------------------------------------------------------------------------------
	protected function InstanciarEstructura() as Void
		this.oEstructura = null
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		local lcClase as string, lcEstilo as String 
		with this
			lcClase = .cTipo
			.AgregarLinea( "define class Din_"+.cTipo + " as Custom " )
			.AgregarLinea( "" )
			.AgregarLinea( "cPatronLongitud = ''", 1 )
			.AgregarLinea( "nResolucionAlto = 0", 1 )
			.AgregarLinea( "nResolucionAncho = 0", 1 )			
		endwith		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		local lcValor as String , lcSql as String , lcPropiedad as String , lcColumna as String,;
			  lxValor as Variant, loLibrerias as Object
		
		loLibrerias = newobject( "librerias", "librerias.prg" )   

		with this
			.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1)
			.AgregarLinea( "function Init()", 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "this.cPatronLongitud = '" + alltrim( this.oAdnAD.ObtenerValorCampo( "estilos", "patronLongitud", "id", transform( .nEstilo ) ) ) + "'", 2 )
			.AgregarLinea( "this.nResolucionAlto = " + transform( this.oAdnAD.ObtenerValorCampo( "estilos", "ResolucionAlto", "id", transform( .nEstilo ) ) ) , 2 )
			.AgregarLinea( "this.nResolucionAncho = " + transform( this.oAdnAD.ObtenerValorCampo( "estilos", "ResolucionAncho", "id", transform( .nEstilo ) ) ) , 2 )
			lcSql = "select ctrl.descripcion, prop.* "+;
				" from c_estilos as est, c_controles as ctrl, c_propiedades as prop "+;
				" where est.id=" + transform(.nEstilo) + " and est.id = prop.idestilo and ctrl.id=prop.idcontrol into cursor c_TempEstilos"

			&lcSql
		
			select c_TempEstilos
			scan
				lcPropiedad = alltrim(c_TempEstilos.Descripcion)
				
				.AgregarLinea( "this.AddProperty('"+ lcPropiedad +"',createobject('empty'))",2)	

				for lnColumna = 4 to fcount()
					lcColumna = alltrim(field(lnColumna))
					if upper( alltrim( lcColumna ) ) != 'C_IDTABLA'
						lxValor = iif( vartype( &lcColumna ) = "C",	alltrim(&lcColumna),&lcColumna)
						lcValor = loLibrerias.ValorAString(lxValor)
						.AgregarLinea( "AddProperty(this."+lcPropiedad + ",'"+ lcColumna +"',"+ lcValor+")",2)	
					endif
				endfor

			endscan

			use in c_TempEstilos

			.AgregarLinea( "")			
			.AgregarLinea( "endfunc", 1 )
		endwith

	endfunc 

enddefine

