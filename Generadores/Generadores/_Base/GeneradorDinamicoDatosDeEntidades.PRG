define class GeneradorDinamicoDatosDeEntidades as GeneradorDinamico of GeneradorDinamico.prg

	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void

		select rtrim(Entidad) as entidad, identificador as identificador from c_Entidad ;
		where upper( alltrim( tipo ) ) == "E" 	;
		into cursor C_NombreEntidades

		.AgregarLinea( "define class Din_" + alltrim( Proper( this.cTipo ) ) + this.cPrefijo + this.cSufijo + " as Custom" )
		.AgregarLinea( "" )		
		select C_NombreEntidades
		.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
		.AgregarLinea( "function ObtenerIdentificadorDeEntidad( tcEntidad as string ) as string", 1 )
		.AgregarLinea( "local lcRetorno as string, lcEntidad as string", 2 )
		.AgregarLinea( "lcRetorno = ''", 2 )
		.AgregarLinea( "lcEntidad = upper( alltrim( tcEntidad ) )", 2 )
		.AgregarLinea( "do case", 2 )
		scan 		
			.AgregarLinea( "case lcEntidad == '" + upper( alltrim( C_NombreEntidades.Entidad ) ) + "'", 3 )
			.AgregarLinea( "lcRetorno = '" + alltrim( C_NombreEntidades.Identificador ) + "'", 4 )
		endscan
		.AgregarLinea( "endcase", 2 )
		.AgregarLinea( "" )	
		.AgregarLinea( "return lcRetorno", 2 )	
		.AgregarLinea( "endfunc", 1 )	
		use in select( "C_NombreEntidades" )
	endfunc 
	
enddefine
