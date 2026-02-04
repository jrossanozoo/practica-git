define class GeneradorDinamicoAccesoDatosSqlServer as GeneradorDinamicoAccesoDatos of GeneradorDinamicoAccesoDatos.prg

	#if .f.
		local this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
	#endif

	cPrefijo = "AD_SQLServer"
	cHerenciaGenerado = "AccesoDatosEntidad_SqlServer"
	
	*-----------------------------------------------------------------------------------------
	protected function InstanciarEstructura() as Void
		this.oEstructura = this.oAdnAD.oEstructuraSqlServer
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEsquema( tcTabla as string ) as string
		return alltrim( this.oEstructura.ObtenerEsquema( tcTabla ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Obtener_SchemaSelect( tcTabla as string ) as string
		return this.ObtenerEsquema( tcTabla ) + '.'
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarCuerpoClase() as Void
		dodefault()
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.FuncionObtenerMemo()
			.FuncionObtenerDate()
			.FuncionObtenerFechaUltimoUpdateEnTablas()
			.FuncionObtenerIdentificadoresPaginado()
			.FuncionObtenerDatosEntidadPaginado()
			.FuncionObtenerFechaComprobanteRelacionado()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarLineaEjecutarSentencias( tcCursorComp as string ) as Void
		this.agregarLinea( "this.EjecutarSentencias()", 4 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaAperturaMemosyDetalles() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaCierreMemosyDetalles() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaMaximaClavePrimaria() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea("local lcXml as string", 3)
			.agregarLinea( "lxValorClavePrimaria = 0", 3 )
			.agregarLinea('lcXml = this.oConexion.EjecutarSql( "Select max( ' + .cCampoClavePrimaria + ;
				' ) as maximo from ' + this.Obtener_SchemaSelect( .cTabla ) + .cTabla + '" )', 3)
			.agregarLinea("this.xmlACursor( lcXml, 'c_MaxCodigo' )", 3)
			.agregarLinea( "lxValorClavePrimaria = c_MaxCodigo.maximo", 3 )
			.agregarLinea( "use in select( 'c_MaxCodigo' )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaValorClavePrimariaString( tlInsertar as Boolean ) as Void
		if tlInsertar
			this.agregarLinea( "lcValorClavePrimariaString = lxValorClavePrimaria", 3 )
		else
			this.AgregarLineasAsignacionClavePrimariaInsert()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineasUpdateForaneo( tcTabla as string, tcCampo as string, tcNuevoValor as string, tcCampoCodigo as string, tcAtributoPk as string, tcNombreCursor as string ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			tcCampo = '"' + tcCampo + '"'
			if inlist( alltrim( upper( &tcNombreCursor..TipoDato )), "M", "C", "D" ) && caracter
				tcNuevoValor = "'" + tcNuevoValor + "'"
				tcAtributoPk = "'" + tcAtributoPk + "'"
			endif
			.agregarLinea( "this.oConexion.EjecutarSql( [Update " + .Obtener_SchemaSelect( tcTabla ) + tcTabla + " Set " + tcCampo + " = " + tcNuevoValor + [ Where "] + tcCampoCodigo + [" = ] + tcAtributoPk + "] )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaAsignacionVariables( tcNombreCursor as string, tlBlancos as Boolean, tlConvertirAString as Boolean ) as string
		local lcAsignacion as string, lcAtributo as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if upper( alltrim( &tcNombreCursor..Campo ) ) == "TIMESTAMP"
				.lTieneTimestamp = .t.
				lcAsignacion = "goLibrerias.ObtenerTimestamp()"
			else
				if tlBlancos
					lcAsignacion = goLibrerias.ValorAString( goLibrerias.ValorVacioSegunTipo( &tcNombreCursor..TipoDato ) )
				else

 					if &tcNombreCursor..EsEntidad and upper( alltrim( &tcNombreCursor..Dominio ))<>"CLAVECONCUALQUIERCARACTER" 
 						if upper( alltrim( &tcNombreCursor..TipoDato ) ) = "C"
 							lcAsignacion  = " upper( ." + alltrim( &tcNombreCursor..Atributo ) + "_PK ) " 
 						else
 							lcAsignacion  = " ." +alltrim( proper( &tcNombreCursor..Atributo )) + "_PK " 
 						endif								
 					else
						lcAsignacion  = " ." + alltrim( proper( &tcNombreCursor..Atributo ) )
 					endif	
 
 				endif
			endif
		endwith
		return lcAsignacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaCamposSelect( tcCampo as string, tcAtributo as string ) as string
		local lcRetorno as string
		lcRetorno = '"' + tcCampo + '"' + ' as "' + tcAtributo + '", '
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarInsertCabecera() as Void
		local lcSentencia as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcSentencia = 'insert into ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ' ( ' + .cCamposInsert + ' )' + ;
				' values ( ' + .cVariablesInsert + ' )' 
			.AgregarLineasConsultaConTextTo( lcSentencia )
			.AgregarFuncionEjecutar( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarEjecutarSentenciaAuditoria( tcSentencia as String, tlConTextTo as boolean, tnTab as Integer ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.AgregarLineasConsultaConTextTo( lcSentencia )
			if !tlConTextTo
				.AgregarFuncionEjecutar( "" )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarInsertMemos( tlAgregarAColeccion as Boolean ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposUdp( tcCampo as string, tcVariable as string, tcNombreCursor as string ) as string
		local lcRetorno as string
		lcRetorno = '"' + tcCampo + '" = <<'

		if this.EsAtributoAcumulable( this.cTipo, &tcNombreCursor..Atributo )
			lcRetorno = '"' + tcCampo + '" = '
			lcRetorno = lcRetorno + '"' + tcCampo + '" + <<' + this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, "lx" + tcVariable ) + '>>,'
		else
			lcRetorno = lcRetorno + this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, "lx" + tcVariable ) + '>>,'
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCamposUdpColeccion( tcCampo as string, tcVariable as string, tcNombreCursor as string ) as string
		local lcRetorno as string

		if this.EsAtributoAcumulable( this.cTipo, &tcNombreCursor..Atributo )
			lcRetorno = '"' + tcCampo + '" = ' + tcCampo + ' + ( <<' + this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, "lx" + tcVariable ) + '>> ), '
		else
			lcRetorno = '"' + tcCampo + '" = <<' + this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, "lx" + tcVariable ) + '>>, '
		endif

		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerVariablesInsert( tcVariable as string, tcNombreCursor as string, tcPrefijo as string ) as string
		return this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, tcPrefijo + tcVariable )+ [ >>, <<]
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerWhere( tcCampo as string, tcVariable as string, tcNombreCursor as string ) as string
		return '"' + tcCampo + '" = <<'  + this.ObtenerStringSegunTipo( &tcNombreCursor..TipoDato, "lx" + tcVariable ) + '>> and '
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerWhereColeccion( tcCampo as string, tcNombreCursor as string ) as string
		return '"' + tcCampo + '" = ] + lcValorClavePrimariaString + [ and  '
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarInsertinto( tlAgregarAColeccion as string, tcTabla as string ) as string
		local lcRetorno as string
		lcRetorno = replicate( chr(9), 5 ) + "Text to lcCadena noshow textmerge" + chr(13) + chr(10) + replicate( chr(9), 6 )
		lcRetorno = lcRetorno + 'Insert into ' + this.Obtener_SchemaSelect( tcTabla ) + alltrim( tcTabla )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCampo( tcCursor as string ) as string
		return '"' + alltrim( &tcCursor..Campo ) + '",'
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresClavePrimaria( tlAgregarAColeccion as Boolean ) as string
		local lcRetorno as string

		lcRetorno = ""
		if tlAgregarAColeccion
			lcRetorno = "<< lcValorClavePrimariaString >>, "
		else
			lcRetorno = "<<" + this.ObtenerStringSegunTipo( this.cTipoDatoClavePrimaria, "lxValorClavePrimaria" ) + ">>, "
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValores( tcAtributo as string, tcCursor as string ) as string
		return "<<" + this.ObtenerStringSegunTipo( &tcCursor..TipoDato, "lx" + tcAtributo )+ [>>, ]
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAsignacion( tlAgregarAColeccion as Boolean, tcAtributo as string, tcTipoDato as string ) as String 
		local lcRetorno as String, lcAtributo as String 
		if ( upper( alltrim( tcAtributo )) = "BLOQUEARREGISTRO" )
			lcAtributo = "this.oEntidad.BLOQUEARREGISTRO" 
		else
		  	lcAtributo = "loItem." + tcAtributo
		endif  
		lcRetorno = chr( 13 ) + chr( 10 ) + replicate( chr(9), 5 ) + "lx" + tcAtributo + " = " + lcAtributo
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaInsert( tcRetorno as string, tlAgregarAColeccion as Boolean, tcAsignacion as string, tcValues as string, tcCampos as string ) as string
		local lcRetorno as string
		lcRetorno = ""

		lcRetorno = tcAsignacion + chr( 13 ) + chr( 10 ) + tcRetorno + "(" + tcCampos +;
			' ) values ( ' + tcValues + ' ) ' + chr( 13 ) + chr( 10 )
		lcRetorno = lcRetorno + replicate( chr( 9 ), 5 ) + "endtext" + chr( 13 ) + chr( 10 )

		if tlAgregarAColeccion
			lcRetorno = lcRetorno + replicate( chr( 9 ), 5 ) + "loColeccion.Agregar( strtran( lcCadena, chr(9), '' ) )" + chr( 13 ) + chr( 10 )
		else
			lcRetorno = lcRetorno + replicate( chr( 9 ), 5 ) + "this.oConexion.EjecutarSql( strtran( lcCadena, chr(9), '' ) )" + chr( 13 ) + chr( 10 )
			lcRetorno = lcRetorno + replicate( chr( 9 ), 5 ) + "this.ComprobarTransaccion()" + chr( 13 ) + chr( 10 )
		endif

		return lcRetorno
	endfunc
	
	*--------------------
	function AgregarUpdateTriggerDetalle( tnIndice as integer ) as string
		local lcTexto as string
		lcTexto = this.aDetalles[ tnIndice, 13 ] + chr( 13 ) + chr( 10 )
		lcTexto = lcTexto + replicate( chr( 9 ), 6 ) + "this.oConexion.EjecutarSql( strtran( lcCadena, chr(9), '' ) )"
		return lcTexto
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAsignacionAtributoAutoIncDespuesDeInsertar( tcTabla as string, tcCursor as string ) as string
		local lcRetorno as string, lcNombreCursor as string

		lcRetorno = ""
		select ( tcCursor )

		locate for alltrim( &tcCursor..TipoDato ) = 'A'
		if found()
			lcNombreCursor = "c_" + alltrim( tcTabla ) + alltrim( &tcCursor..Campo )
			lcRetorno = "local lcXml as string" + chr( 13 ) + chr( 10 )
			lcRetorno = lcRetorno + [lcXml = this.oConexion.EjecutarSql( "select max( ] + alltrim(&tcCursor..Campo) + [ ) as ] + alltrim(&tcCursor..Campo) + [ from ] + this.Obtener_SchemaSelect( tcTabla ) + alltrim( tcTabla ) + [" )] + chr( 13 ) + chr( 10 )
			lcRetorno = lcRetorno + "this.xmlacursor( lcXml, '" + lcNombreCursor + "' )" + chr( 13 ) + chr( 10 )
			lcRetorno = lcRetorno + "loItem." + alltrim( &tcCursor..Atributo ) + " = " + lcNombreCursor + "." + alltrim(&tcCursor..Campo)+ chr( 13 ) + chr( 10 )
			lcRetorno = lcRetorno + "use in select( '" + lcNombreCursor + "' )"
		endif

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerUpdateDetalle( tcTabla, tcCursor, tcCampo, tlAgregarAColeccion as Boolean ) as string
		local lcRetorno as string, lcCampos as string, lcCampoClaveSecundario as string, ;
			lcAtributo as string

		lcRetorno = ""
		lcCampos = ""
		lcCampoClaveSecundario = iif(empty( tcCampo ), this.cCampoClavePrimaria, alltrim( tcCampo ) )

		if tlAgregarAColeccion
			lcRetorno = 'loColeccion.Agregar( "Update ' + this.Obtener_SchemaSelect( tcTabla ) + alltrim(tcTabla) + " set "
		else
			lcRetorno = 'Update ' + this.Obtener_SchemaSelect( tcTabla ) + alltrim(tcTabla) + " set "
		endif

		select ( tcCursor )
		scan
			lcAtributo = proper( alltrim( &tcCursor..Atributo ) ) + iif( &tcCursor..EsEntidad, "_PK", "" )
			lcCampos = lcCampos + '"' + alltrim( &tcCursor..Campo ) + '" = lx' + lcAtributo + ","
		endscan

		lcRetorno = lcRetorno + left( lcCampos, len( lcCampos ) - 1 ) +;
			" where " + lcCampoClaveSecundario + " = lx" + this.cCampoClavePrimaria

		if tlAgregarAColeccion
			lcRetorno = "loColeccion.Agregar( [" + lcRetorno + "] )"
		endif

		return lcRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	function FuncionHayDatos() as Void
		local lcSentencia as string
		
		with this
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "function HayDatos() as boolean", 1)
			.AgregarLinea( "local llhaydatos as boolean, lcXml as String", 2)
					.agregarLinea(	[ lcXml = this.oConexion.EjecutarSql( "select Top 1 ] + .cCampoClavePrimaria + [ from ] + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
									[ where " + this.ConvertirFuncionesSql( "] + .ObtenerFiltro() + [" ) )], 3 )
					.agregarLinea( "this.xmlacursor( lcXml, 'c_HayDatos' )", 3 )
					.AgregarLinea( "llHayDatos = reccount( 'c_HayDatos' ) > 0 ", 3 )
					.AgregarLinea( "use in select('c_HayDatos')" , 3 )
				.AgregarLinea( "return llHayDatos", 2)
			.AgregarLinea( "endfunc", 1)
			.AgregarLinea( "" )
		endwith
	endfunc 


	*-----------------------------------------------------------------------------------------
	function GenerarLineaSelectHayDatos() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "local lcXml as string", 3 )
			.agregarLinea( [ lcXml = this.oConexion.EjecutarSql( "select count( ] + .cCampoClavePrimaria + [ ) as Total from ] + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				[ where " + this.ConvertirFuncionesSql( "] + .ObtenerFiltro() + [" ) )], 3 )
			.agregarLinea( "this.xmlacursor( lcXml, 'c_HayDatos' )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarLineaSelectVerificarExistenciaClavePrimaria( tcCursor as String ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.AgregarLineasConsultaConTextTo( 'select count( * ) as CantidadDeRegistros from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + .cWhere )
			.AgregarFuncionEjecutar( tcCursor )
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarLineaSelectConsultaPorClavePrimaria() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.AgregarLineasConsultaConTextTo( 'select ' + .ObtenerCamposSelect() + ' from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + .cWhere )
			.AgregarFuncionEjecutar( .cCursorEntidad )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarConsultasMemo() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarWhereConsultarPorClaveCandidata( tcCursor as string ) as Void
		local lcVariable as string
		lcVariable = ""
		lcVariable = this.ObtenerStringSegunTipo( &tcCursor..TipoDato, 'lx' + alltrim( &tcCursor..Tabla ) + alltrim( &tcCursor..Campo ) )
		return alltrim( &tcCursor..Campo ) + [ = <<] + lcVariable + [>> and ]
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaSelectConsultarPorClaveCandidata( tcWhere as string ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.AgregarLineasConsultaConTextTo( 'select ' + .ObtenerCamposSelect() + ' from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + tcWhere )
			.AgregarFuncionEjecutar( .cCursorEntidad )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaSelectConsultarPorAtributoSecundario() as Void
		local lcSentencia as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "lcFiltro = lcCampo + ' = ' + goLibrerias.ValorAString(lxValor) + lcFiltroCodigo", 3 )
			lcSentencia = .fraccionarCadena( '"select ' + .cCampos ) + ' from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + .ObtenerFiltro() + ' and " + lcFiltro'

			.agregarLinea( "local lcXml as string", 3 )
			.agregarLinea( "lcXml = this.oConexion.EjecutarSql( " + lcSentencia + " )", 3 )
			.agregarLinea( "this.xmlacursor( lcXml, lcNombreCursor )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerearLineaSentenciaEliminar() as Void
		local lcWhere as string, lcSentencia as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcWhere = ' where "' + .cCampoClavePrimaria + '" = ] + ' + .ObtenerStringSegunTipo( .cTipoDatoClavePrimaria, ".oEntidad." + .cAtributoClavePrimaria )
			lcSentencia = '[delete from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + lcWhere + "+ goServicios.RealTime.ObtenerTagEstimulo( .oEntidad.cNombre )"
			.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + " )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaAtributosObtenerDatosGenerico( tcTexto as string ) as Void
		.agregarLinea( "text to lcAtributos textmerge noshow", 4 )
		.agregarLinea( tcTexto, 5 )
		.agregarLinea( "endtext", 4 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaSelectConsultasDetalles( tcCamposSelect as String, tcCampoClaveSecundario as String, tcTabla as String, tcDetalle as String, tcOrdenAlCargar as String ) as Void
		local lcSentencia as String, lcOrder as String
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcOrder = "NroItem"
			if empty( tcOrdenAlCargar )
			else
				lcOrder = tcOrdenAlCargar
			Endif
			lcSentencia = 'select ' + tcCamposSelect + ' from ' + .Obtener_SchemaSelect( tcTabla ) + tcTabla + ;
				' where ' + tcCampoClaveSecundario + ' = <<' + ;
				.ObtenerStringSegunTipo( .cTipoDatoClavePrimaria, .cCursorEntidad + '.' + .cAtributoClavePrimaria ) + '>>' + ;
				' Order by ' + lcOrder

			.AgregarLineasConsultaConTextTo( lcSentencia )
			.AgregarFuncionEjecutar( "c_" + alltrim( tcDetalle ) )
			.AgregarLinea( "Replace all NroItem with recno() in c_" + alltrim( tcDetalle ) , 4 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarLineaDeleteEliminacionDetalles( tlAgregarAColeccion as Boolean, tcTabla as string, tcCampoClavePrimaria as string, tcTipoDato as string ) as Void
		local lcSentencia as string, lcWhere as string, lcString as String, lcCondicion as String 

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if tlAgregarAColeccion

				lcWhere = ' where "' + tcCampoClavePrimaria + '" = ] + ' + .ObtenerStringSegunTipo( .cTipoDatoClavePrimaria, ".oEntidad." + .cAtributoClavePrimaria )
				lcSentencia = "loColeccion.Agregar("+ '[delete from ' + .Obtener_SchemaSelect( tcTabla ) + tcTabla + lcWhere + ")"

				.agregarLinea( lcSentencia, 3 )
			else
				if .cTipoDatoClavePrimaria = "N" and tcTipoDato <> "N"
					.agregarLinea( 'this.oConexion.EjecutarSql( [delete from ' + .Obtener_SchemaSelect( tcTabla ) + ;
						tcTabla + ' where "' + tcCampoClavePrimaria + '" = ' +"']"+ ;
						" + transform( .oEntidad." + .cAtributoClavePrimaria  + " )"+ " + ['])", 3 )
				else
					.agregarLinea( [this.oConexion.EjecutarSql( 'delete from ] + .Obtener_SchemaSelect( tcTabla ) + ;
						tcTabla + [ where "] + tcCampoClavePrimaria + [" = ' + ] + ;
						.ObtenerStringSegunTipo( tcTipoDato, ".oEntidad." + .cAtributoClavePrimaria ) + [ )], 3 )
				endif 	
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarLlamadasMemo() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarConexionBD() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarCierreBD() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerVariableSentenciaInsert() as string
		local lcRetorno as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcRetorno = 'insert into ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ' ( ' + .cCamposInsert + ' ) values ( ' + .cVariablesInsert + ' )'
		endwith
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarAsignacion_ObtenerSentenciasInsert() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerVariableSentenciaUpdate() as string
		return 'update ' + this.Obtener_SchemaSelect( this.cTabla ) + this.cTabla + ' set ' + this.cCamposUdpColeccion + ' where << lcFiltro >>'
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarAsignacion_ObtenerSentenciasUpdate() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarLineaDeleteObtenerSentenciasDelete() as Void
		local lcSentencia as string, lcTabla as string
		lcSentencia = ""
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcTabla = alltrim( this.obtenerTabla() )
			lcSentencia =	"loColeccion.Agregar( 'delete from " + .Obtener_SchemaSelect( lcTabla ) + lcTabla + " where ' + lcFiltro )"
			.agregarLinea( lcSentencia, 2 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresAGrabar( tcVariable as string, tcValores as string ) as Void
		local i as integer, lnTotal as integer, lcRetorno as string
		dimension laVariables[1]
		lcRetorno = ""
		lnTotal = alines( laVariables, tcValores, 1 + 4, "," )
		lcRetorno = tcVariable + " = "
		for i = 1 to lnTotal
			lcRetorno = lcRetorno + alltrim( laVariables[i] ) + ', '
		endfor
		lcRetorno = left( lcRetorno, len( lcRetorno ) - 2 )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFiltro( tcEntidad as string ) as string
		local lcRetorno as string, lcSql as string, lcTipoDato as string, lcCondicion as string, lcAux as string, lcFiltroAux as String,;
		 lcTabla as String 

		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif

		lcAux = alltrim( this.oAdnAD.ObtenerValorCampo( "entidad", "Filtro", "Entidad", upper( alltrim( tcEntidad ) ) ) )

		lcTipoDato =  this.ObtenerTipoDatoClavePrimaria( tcEntidad )
		do case
			case inlist( lcTipoDato, "C", "M" )
				lcCondicion = " != ''"

			case inlist( lcTipoDato, "N", "A", "L" )
				lcCondicion = " != 0"

			case lcTipoDato = "D"
				lcCondicion = " != '01/01/1900'"

			otherwise
				lcCondicion = ""
		endcase
		lcTabla = alltrim( this.obtenerTabla( tcEntidad ) ) 
		lcRetorno = " " + lcTabla + "." + alltrim( this.ObtenerCampoClavePrimaria( tcEntidad ) ) + lcCondicion

		if !empty( lcAux ) 
			if at( ".", alltrim( lcAux )) > 0 or at( "(",  lcAux ) > 0
				lcFiltroAux = alltrim( lcAux )
			else
				lcFiltroAux = lcTabla + "." + alltrim( lcAux )
				if this.VerificarFuncionalidad( this.cTipo, "AGRUPACOMPROBANTES" )				
					lcFuncAux = this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) )					
					lcFunc = alltrim( this.oFunc.ObtenerValor( "AGRUPACOMPROBANTES", lcFuncAux ) )
					lnLargo = ALINES(loComprobantes, lcFunc , ";")
					for i = 1 to lnLargo
						lcFiltroAux = lcFiltroAux + " OR " + lcTabla + "." + "FACTTIPO = "+ loComprobantes[i] 			
					endfor
					lcFiltroAux = "(" + lcFiltroAux + ")"
				else
					if this.VerificarFuncionalidad( this.cTipo, "MIPYME" )
						lcFiltroAux = "(" + lcFiltroAux + " OR " + lcTabla + "." + "FACTTIPO = "+ this.ObtenerCodigoMiPyME() + ")"			
					endif
				endif
			endif
			lcRetorno = lcRetorno + " And " + alltrim( lcFiltroAux )
		endif

		lcRetorno = upper( lcRetorno )
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarSelectObtenerCantidadRegistros() as Void
		local lcSentencia as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcSentencia = '"select count( * ) as Total from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + .ObtenerFiltro() + '"'

			.agregarLinea( "local lcXml as string", 3 )
			.agregarLinea( "lcXml = this.oConexion.EjecutarSql( " + lcSentencia + " )", 3 )
			.agregarLinea( "this.xmlacursor( lcXml, 'c_CantReg' )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarSelectObtenerTimestampActual( tcFiltros as string ) as Void
		local lcSentencia as string, lcCondicion as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcCondicion = alltrim( .cCampoClavePrimaria )+ ' = " + ' + ;
				.ObtenerStringSegunTipo( .cTipoDatoClavePrimaria, "this.oEntidad." + alltrim( .cAtributoClavePrimaria ) )+ '+ "'
			lcSentencia = '"select TimeStamp from ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ;
				' where ' + lcCondicion + iif( empty( tcFiltros ), '', ' and ' ) + tcFiltros + '"'

			.agregarLinea( "local lcXml as string", 3 )
			.agregarLinea( "lcXml = this.oConexion.EjecutarSql( " + lcSentencia + " )", 3 )
			.agregarLinea( "this.xmlacursor( lcXml, lcCursor )", 3 )

		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaBeginTransaction() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea("this.oConexion.EjecutarSql( 'BEGIN TRANSACTION' )", 3)
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaEndTransaction() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea("this.oConexion.EjecutarSql( 'COMMIT TRANSACTION' )", 3)
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaRollbackTransaction() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea("this.oConexion.EjecutarSql( 'ROLLBACK TRANSACTION' )", 3)
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentenciaUpdate() as Void
		local lcSentencia as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcSentencia = 'update ' + .Obtener_SchemaSelect( .cTabla ) + .cTabla + ' set ' + .cCamposUdp + ;
				' where ' + .cWhere + " << this.oEntidad.ObtenerWhereAdicionalParaSentenciaUpdate() >>"

			.AgregarLineasConsultaConTextTo( lcSentencia )
			.AgregarFuncionEjecutar( "" )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerMemo() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "*--------------------------------------------------------------------------------------------------------", 1)
			.agregarLinea( "function ObtenerMemo( tcTabla as String ) as string", 1)
			.agregarLinea( "local lcAtributo as string", 2)
			.agregarLinea( "lcAtributo = strtran( tcTabla, 'c_', '' )", 2)
			.agregarLinea( "return " + .cCursorEntidad + ".&lcAtributo", 2 )
			.agregarLinea( "endfunc", 1)
			.agregarLinea( "")
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerDate() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "*--------------------------------------------------------------------------------------------------------", 1)
			.agregarLinea( "protected function ObtenerDate( tcCursor as String, tcAtributo as string ) as date", 1)
			.agregarLinea( "return dtoc( &tcCursor..&tcAtributo )", 2)
			.agregarLinea( "endfunc", 1)
			.agregarLinea( "")
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFechaUltimoUpdateEnTablas() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "*--------------------------------------------------------------------------------------------------------", 1)
			.agregarLinea( "function ObtenerFechaUltimoUpdateEnTablas() as DateTime", 1)

			.agregarLinea( "local lcSentencia as String, ldRetorno as DateTime", 2 )

			lcTabla = this.cTabla
			lcEsquema = this.ObtenerEsquema( lcTabla )

			if !empty( this.cUbicacionDB )
				.agregarLinea( "" )
				.agregarLinea( "local lcNombreBD as String ", 2)
				.agregarLinea( "lcNombreBD = ''", 2)
				.agregarLinea( "lcNombreBD = this.oConexion.ObtenerNombreBD( 'ZOOLOGICMASTER' )", 2)
				.agregarLinea( "lcNombreBD = goLibrerias.EscapeCaracteresSqlServer( lcNombreBD )", 2)
			endif

			.agregarLinea( "" )
			.agregarLinea( "text to lcSentencia textmerge noshow", 2)
			.agregarLinea( "SELECT MAX( last_user_update ) as last_update FROM sys.dm_db_index_usage_stats WHERE database_id = DB_ID("+ iif( !empty( this.cUbicacionDB ), "'<<lcNombreBD>>'", "" ) +") AND OBJECT_ID=OBJECT_ID( '" + iif( !empty( this.cUbicacionDB ), "<<lcNombreBD>>.", "" ) + lcEsquema + "." + lcTabla + "' )", 3)
			.agregarLinea( "endtext", 2 )
			.agregarLinea( "this.oConexion.EjecutarSql( lcSentencia, 'c_last_user_update', set( 'Datasession' ) )", 2 )

			.agregarLinea( "ldRetorno = {^0001-01-01 00:00:00}", 2)

			.agregarLinea( "if reccount( 'c_last_user_update' ) > 0 and !isnull( c_last_user_update.last_update )", 2)
			.agregarLinea( "ldRetorno = c_last_user_update.last_update", 3)
			.agregarLinea( "endif", 2)

			.agregarLinea( "return ldRetorno", 2)
			
			.agregarLinea( "endfunc", 1)
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringSegunTipo( tcTipoDato as string, tcValor as string ) as string
		local lcRetorno as string, lcTipoDato as string

		lcTipoDato = alltrim( upper( tcTipoDato ))
		do case
			case inlist( lcTipoDato, "M", "C", "G" )
				lcRetorno = ["'" + this.FormatearTextoSql( ] + tcValor + [ ) + "'"]

			case lcTipoDato = "D"
				lcRetorno = ["'" + this.ConvertirDateSql( ] + tcValor + [ ) + "'"]

			case lcTipoDato = "L"
				lcRetorno = [iif( ] + tcValor + [, 1, 0 )]

			otherwise && numerico
				if lower( left( tcValor, 2 ) ) == "lx" and lower( tcValor ) != "lxvalorclaveprimaria"
					lcRetorno = tcValor
				else
					lcRetorno = [transform( ] + tcValor + [ )]
				endif
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarLineaDeSentenciaActualizacionTimeStamp() as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "lcRetorno = [update " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " set TimeStamp = ] + transform( lnTimeStamp ) + lcUpdateRealTime + [ where " + ;
				alltrim( c_AtributoCP.Campo ) + " = ] + " +  this.ObtenerStringSegunTipo( c_AtributoCP.TipoDato, "." + alltrim( c_AtributoCP.Atributo ) ) + " + [ and " + ;
				.ObtenerFiltro() + "] + goServicios.RealTime.ObtenerTagEstimulo( .cNombre )", 3 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionEjecutar( tcCursor as String ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if empty( tcCursor )
				.agregarLinea( "this.oConexion.EjecutarSql( lcSentencia  + goServicios.RealTime.ObtenerTagEstimulo( .oEntidad.cNombre ) )", 3 )
			else
				.agregarLinea( "use in select('" + tcCursor + "')", 3 )
				.agregarLinea( "this.oConexion.EjecutarSql( lcSentencia, '" + tcCursor + "', set( 'Datasession' ) )", 3 )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function InterpretarExpresion( tcExpresion as string, tcEntidadDestino as string, tcAtributoDestino as string, tcEntidad as string, tlEnText as Boolean ) as string
		local lcRetorno as string, lnCant as integer, i as integer, lcExpresion as string, lcAtributo as string, lcEntidad as string, ;
			lcEntidadAtributo as string, lcTipoDato as string, llEsEntidad as Boolean, lcDestino as string

		lcExpresion = tcExpresion + " "
		lnCant = occurs( "#", lcExpresion )
		lcRetorno = ""
		llEsEntidad = this.EsEntidad( tcEntidad )


		for i = 1 to lnCant
			lcRetorno = lcRetorno + substr( lcExpresion, 1, at( "#", lcExpresion ) - 1 )
			lcExpresion = substr( lcExpresion, at( "#", lcExpresion ) + 1 )

			lcEntidad = alltrim( substr( lcExpresion, 1, at( ".", lcExpresion ) - 1 ) )
			lcAtributo = alltrim( substr( lcExpresion,  at( ".", lcExpresion ) + 1, at( " ", lcExpresion ) - at( ".", lcExpresion ) ) )
			lcExpresion = substr( lcExpresion, at( " ", lcExpresion ) + 1 )
			lcDestino = iif( llEsEntidad ,"This.oEntidad." , "lx")
			do case
				case upper( alltrim( lcEntidad ) ) == upper( alltrim( tcEntidad ) )
					lcTipoDato = this.ObtenerTipoDatoAtributo( tcEntidadDestino, tcAtributoDestino )
					do case
						case inlist( lcTipoDato, "M", "C", "G" )
							lcEntidadAtributo = iif(tlEnText, ['<<] + lcDestino + lcAtributo + [>>'],  [" + "'" + ] + lcDestino + lcAtributo + [ + "'" + " ])
						case lcTipoDato = "D"
							lcEntidadAtributo = iif(tlEnText,['<<dtos( ] + lcDestino + lcAtributo + [ )>>'], [ cast( '" + dtos( ] + lcDestino + lcAtributo + [ ) + "' as datetime ) ])
						case lcTipoDato = "L"
							lcRetorno = [iif( ] + tcValor + [, 1, 0 )]
						otherwise
							lcEntidadAtributo = iif(tlEnText,[<<Transform( ]+ lcDestino + lcAtributo + [ )>>], [" + Transform( ]+ lcDestino + lcAtributo + [ ) + "])
					endcase

				case upper( alltrim( lcEntidad ) ) == upper( alltrim( tcEntidadDestino ) )
					lcEntidadAtributo = this.obtenerTabla( lcEntidad ) + "." + this.ObtenerCampoAtributo( lcEntidad, lcAtributo ) + " "

			endcase

			lcRetorno = lcRetorno + lcEntidadAtributo

		endfor
		lcRetorno = alltrim( lcRetorno ) + lcExpresion

		return lcRetorno

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaUpdateParaTriggers( tcEntidadDestino as string, tcAtributoDestino as string, tcExpresion as string, tcEntidad as string ) as string
		local lcInstruccion as string, lcTabla as string, lcCampoDestino as string, ;
			lcCondicion as string, lcExpresion as string

		lcTabla = alltrim( this.obtenerTabla( tcEntidadDestino ) )
		lcCampoDestino = this.ObtenerCampoAtributo( tcEntidadDestino, tcAtributoDestino )
		lcExpresion = this.InterpretarExpresion( tcExpresion, tcEntidadDestino, tcAtributoDestino, tcEntidad )
		lcInstruccion = [Update ] + this.Obtener_SchemaSelect( lcTabla ) + lcTabla + [ Set ] + lcCampoDestino + [ = ]
		lcInstruccion = lcInstruccion + lcExpresion + [ Where ]
		lcInstruccion = '"' + lcInstruccion + '" + toCondicionTriggers.Item[ "' + upper( alltrim( tcEntidadDestino ) ) + '" ]'

		return lcInstruccion
	endfunc
	
	*-------------------------------------------------------------------------------------
	function ObtenerSentenciaUpdateParaTriggersDetalle( tcEntidadDestino as string, tcAtributoDestino as string, tcExpresion as string, tcEntidad as string ) as string
		local lcInstruccion as string, lcTabla as string, lcCampoDestino as string, ;
			lcCondicion as string, lcExpresion as string

		lcTabla = alltrim( this.obtenerTabla( tcEntidadDestino ) )
		lcCampoDestino = this.ObtenerCampoAtributo( tcEntidadDestino, tcAtributoDestino )
		lcExpresion = this.InterpretarExpresion( tcExpresion, tcEntidadDestino, tcAtributoDestino, tcEntidad, .t. )
		lcCondicion = this.ObtenerCondicionParaTriggers( this.cTipo, tcEntidadDestino )
		lcInstruccion = "Text to lcCadena noshow textmerge" + chr(13) + chr(10) + replicate( chr(9), 6 )
		lcInstruccion = lcInstruccion + replicate( chr(9), 1 ) + 'Update ' + this.Obtener_SchemaSelect( lcTabla ) + lcTabla + ' Set ' + lcCampoDestino + ' = '
		lcInstruccion = lcInstruccion + lcExpresion + ' Where '
		lcCondicion = this.ObtenerCondicionParaTriggersDetalle( tcEntidad , tcEntidadDestino )
		lcInstruccion = lcInstruccion  + lcCondicion + chr(13) + chr(10)
		lcInstruccion = lcInstruccion + replicate( chr(9), 6 ) + "EndText" + chr(13) + chr(10) + replicate( chr(9), 6 )		
		
		return lcInstruccion
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarCondicionDeIgualdad( tcCursor as string ) as string
		local lcCondicion as string, lcCursor as string, lcCampo as string, lcAtributo as string
		lcCursor = tcCursor
		lcCondicion = ""
		do case
			case c_diccionario.claveprimaria
				lcAtributo = "lxValorClavePrimaria"
			case !empty( c_diccionario.claveforanea)
				lcAtributo = "lx" + alltrim( &lcCursor..Atributo_Origen ) + "_pk"
			otherwise
				lcAtributo = "lx" + alltrim( &lcCursor..Atributo_Origen )
		endcase

		lcCampo = this.ObtenerStringSegunTipo( alltrim( c_diccionario.TipoDato ), lcAtributo )
		if upper( alltrim( c_diccionario.TipoDato ) ) == "C"
			lcCondicion = lcCondicion + this.ObtenerTablaCampo( &lcCursor..Entidad_Destino, &lcCursor..Atributo_Destino ) + ;
				[ = '<<] + lcCampo + [>>']
		else
			lcCondicion = lcCondicion + this.ObtenerTablaCampo( &lcCursor..Entidad_Destino, &lcCursor..Atributo_Destino ) + ;
				[ = <<] +  lcCampo + [>>]
		endif

		return lcCondicion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTablaCampo( tcEntidad as string, tcAtributo as string ) as string
		return alltrim( this.ObtenerCampoAtributo( tcEntidad, tcAtributo ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarUbicacionDB() as Void
		dodefault()
		this.agregarLinea( ".cTipoDB = 'SQLSERVER'" , 4 )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionalidadImportar() as Void
		dodefault()
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.FuncionCrearTablaDeTrabajo()
			.FuncionCrearTablaDeTrabajoDetalles()
			.FuncionCargarTablaDeTrabajo()
			.FuncionCargarTablaDeTrabajoDetalles()
			.FuncionObtenerTriggerDeleteImportacion()
			.FuncionObtenerTriggerDeleteImportacionParaDetalles()
			.FuncionEliminarTablasDeTrabajo()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionEliminarTablasDeTrabajo() as Void
		***tengo que crear en el sqlServer una tabla igual
		local lcXml as string, lcCursor as string, lcTablaTrabajo as string, lcTabla as string
		lcCursor = this.cCursorAtributos

		select &lcCursor
		locate for claveprimaria
		lcTabla = alltrim( &lcCursor..Tabla )
		lcTablaTrabajo = "TablaTrabajo_" + alltrim( &lcCursor..Tabla )

		.agregarLinea( "", 1 )
		.agregarLinea( "*" + replicate( "-", 104 ), 1 )
		.agregarLinea( "protected Function EliminarTablasDeTrabajo( toConexion as Object ) as void", 1 )

		.agregarLinea( "local lcSentencia as string", 2 )

		.agregarLinea( "text to lcSentencia textmerge noshow", 2 )
		.agregarLinea( "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('"+.ObtenerEsquema( lcTabla )+"." + lcTablaTrabajo + "') AND type in ('U')) DROP TABLE "+.ObtenerEsquema( lcTabla )+"." + lcTablaTrabajo, 2 )
		.agregarLinea( "endtext", 2 )

		.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )

		if ( this.VerificarFuncionalidad( this.cTipo, "IMPOBULKCONVALIDACIONES" ) )
			with this
				for lnI = 1 to alen(.aDetalles,1)
					
					if empty( .aDetalles(lnI,2)) 
					else
						lcTabla = alltrim(.aDetalles(lnI,2))
						if !empty( lcTabla )
							.AgregarLinea( "" )
				
							lcTablaTrabajo = "TablaTrabajo_" + lcTabla

							.agregarLinea( "text to lcSentencia textmerge noshow", 2 )
							.agregarLinea( "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('"+.ObtenerEsquema( lcTabla )+"." + lcTablaTrabajo + "') AND type in ('U')) DROP TABLE "+.ObtenerEsquema( lcTabla )+"." + lcTablaTrabajo, 2 )
							.agregarLinea( "endtext", 2 )

							.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )
							
						endif
					endif
				endfor
			endwith
		endif

		.agregarLinea( "endfunc", 1 )
		.agregarLinea( "", 1 )

	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function FuncionCrearTablaDeTrabajo() as Void
		***tengo que crear en el sqlServer una tabla igual
		local loGenerador as object, lcXml as string, lcCursor as string, lcTablaTrabajo as string, lcTabla as string
		lcCursor = this.cCursorAtributos
		select &lcCursor
		locate for claveprimaria
		lcTabla = alltrim( &lcCursor..Tabla )
		lcTablaTrabajo = "TablaTrabajo_" + alltrim( &lcCursor..Tabla )
		lcXml = this.CursorAXml( lcCursor )

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			loGenerador = _screen.zoo.crearobjeto("generadordesentenciassqlsqlserver")
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected Function CrearTablaDeTrabajo( toConexion as Object ) as void", 1 )

			.agregarLinea( "toConexion.EjecutarNonQuery( 'Use [' + goLibrerias.obtenernombresucursal( alltrim( _Screen.zoo.app.cSucursalActiva ) ) + ']' )", 2 )

			.agregarLinea( "local lcSentencia as string", 2 )
			.agregarLinea( "text to lcSentencia textmerge noshow", 2 )
			.agregarLinea( loGenerador.ObtenerSentenciaCreateTableTablaTrabajo( lcXml, .ObtenerEsquema( lcTabla ), lcTablaTrabajo ), 2 )
			.agregarLinea( "endtext", 2 )

			.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )

			.agregarLinea( "********Agrego el trigger a la tabla" , 2)
			.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 2 )
			.agregarLinea( "lcSentencia = this.ObtenerTriggerDeleteTransferencia( '" + lcTablaTrabajo + "' )" , 3)
			.agregarLinea( "else", 2 )
			.agregarLinea( "lcSentencia = this.ObtenerTriggerDeleteImportacion( '" + lcTablaTrabajo + "' )" , 3)
			.agregarLinea( "endif", 2 )
			
			.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )

			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionCrearTablaDeTrabajoDetalles() as Void

		if ( this.VerificarFuncionalidad( this.cTipo, "IMPOBULKCONVALIDACIONES" ) )

			local lnI as Integer, lcTabla as String, lcCampoClaveSecundario as String,;
				  lcCamposValues as String, lcSentencia as String, llAgregaRenumerarDetalle as Boolean, llSoloLectura as Boolean 	    

			lcCursor = this.cCursorAtributos
			select &lcCursor
			locate for claveprimaria
			lcTablaPrincipal = alltrim( &lcCursor..Tabla )

			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "protected function CrearTablaDeTrabajoDetalles( toConexion as Object ) as void", 1 )

			loGenerador = _screen.zoo.crearobjeto("generadordesentenciassqlsqlserver")

			with this
				for lnI = 1 to alen(.aDetalles,1)
					
					if empty( .aDetalles(lnI,2)) 
					else
						lcTabla = alltrim(.aDetalles(lnI,2))
						if !empty( lcTabla ) and !llSoloLectura
							.AgregarLinea( "" )
							
							lcCursorOriginal = .aDetalles( lnI, 7 )
							lcCursorTrabajo = sys(2015)
							
							select * from &lcCursorOriginal into cursor &lcCursorTrabajo readwrite
							insert into &lcCursorTrabajo (tipodato, campo, longitud, decimales ) values ( "N", "Campo0", 20 , 0)
				
							lcXml = this.CursorAXml( lcCursorTrabajo )
				
							lcTablaTrabajo = "TablaTrabajo_" + lcTablaPrincipal + "_" + lcTabla
							.agregarLinea( "* " + lcTablaTrabajo, 2 )
							.agregarLinea( "local lcSentencia as string", 2 )
							.agregarLinea( "text to lcSentencia textmerge noshow", 2 )
							.agregarLinea( loGenerador.ObtenerSentenciaCreateTableTablaTrabajo( lcXml, .ObtenerEsquema( lcTabla ), lcTablaTrabajo ), 2 )
							.agregarLinea( "endtext", 2 )
							.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )

							.agregarLinea( "********Agrego el trigger a la tabla" , 2)
							.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 2 )
							.agregarLinea( "lcSentencia = this.ObtenerTriggerDeleteTransferencia_" + lcTabla + "( '" + lcTablaTrabajo + "' )" , 3)
							.agregarLinea( "else", 2 )
							.agregarLinea( "lcSentencia = this.ObtenerTriggerDeleteImportacion_" + lcTabla + "( '" + lcTablaTrabajo + "' )" , 3)
							.agregarLinea( "endif", 2 )
							.agregarLinea( "toConexion.EjecutarNonQuery( lcSentencia )", 2 )
						endif				
					endif
				endfor
			endwith
			.agregarLinea( "endfunc", 1 )
			.agregarLinea( "", 1 )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionCargarTablaDeTrabajoDetalles() as Void

		if ( this.VerificarFuncionalidad( this.cTipo, "IMPOBULKCONVALIDACIONES" ) )

			***tengo que crear en el sqlServer una tabla igual
			local loGenerador as object, lcXml as string, lcCursor as string, lcTablaTrabajo as string, lcTabla as string
			lcCursor = this.cCursorAtributos
			select &lcCursor
			locate for claveprimaria
			lcTablaPrincipal = alltrim( &lcCursor..Tabla )

			with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg

				loGenerador = _screen.zoo.crearobjeto("generadordesentenciassqlsqlserver")
				.agregarLinea( "*" + replicate( "-", 104 ), 1 )
				.AgregarLinea( "protected function CargarTablaDeTrabajoDetalles( toConexion as Object ) as void", 1 )
				.agregarLinea( "local loManejador as object, lcCursor as string", 2)
				.agregarLinea( "", 2)

				with this
					for lnI = 1 to alen(.aDetalles,1)
						
						if empty( .aDetalles(lnI,2)) 
						else
							lcTabla = alltrim(.aDetalles(lnI,2))
							lcCursor = alltrim(.aDetalles(lnI,7))
							lcTablaTrabajo = "TablaTrabajo_" + lcTablaPrincipal + "_" + alltrim( lcTabla  )

							.agregarLinea( "loManejador = _Screen.DotNetBridge.CrearObjeto( 'ZooLogicSA.ManejadorArchivos.CopiaMasiva' )", 2)
							.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 2 )
							.agregarLinea( "lcCursor = This.oEntidad.cPrefijoRecibir + '" + substr( .aDetalles(lnI,6), 8 ) + "'", 3 )
							.agregarLinea( "else", 2 )
							.agregarLinea( "lcCursor = this.oEntidad.cPrefijoImportar + '" + substr( .aDetalles(lnI,6), 8 ) + "'", 3 )
							.agregarLinea( "endif", 2 )

							.agregarLinea( "if used( lcCursor )", 2 )

							.agregarLinea( "with loManejador", 2 )
							.agregarLinea( ".AgregarMapeo('campo0','campo0')", 3 )
							.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 3 )
							.agregarLinea( "else", 3 )
							.agregarLinea( ".AgregarMapeo('Nrolinea','Nrolinea')", 4 )
							.agregarLinea( "endif", 3 )

							select (lcCursor)
							scan all for !empty( Campo ) and !Detalle 
								.agregarLinea( ".AgregarMapeo('" + lower( alltrim( Campo ) ) + "','" + lower( alltrim( Campo ) ) + "')", 3 )
							endscan
			
							.agregarLinea( ".CadenaConexionOrigen = 'Provider=VFPOLEDB.1;Data Source= ' +  justpath( dbf( lcCursor ) )", 3 )
							.agregarLinea( ".CadenaConexionDestino = this.oConexion.oManagerConexionASql.ObtenerCadenaConexionNet()", 3 )
							.agregarLinea( ".NombreTablaSqlServer = '" + .Obtener_SchemaSelect( lcTabla ) + lcTablaTrabajo + "'", 3 )
							.agregarLinea( ".ConsultaOrigen = 'select * from ' + lcCursor", 3 )
							.agregarLinea( "Select( lcCursor )", 3 )
							.agregarLinea( "Count to This.nCantVeces", 3 )
							.agregarLinea( "This.nCantVeces = ceiling( This.nCantVeces / This.nCantABorrar )", 3 )

							.agregarLinea( "if !this.oEntidad.VerificarContexto( 'CB' )", 3 )
							.agregarLinea( "use in ( lcCursor )", 4 )
							.agregarLinea( "endif", 3 )

							.agregarLinea( ".ImportarMasivamente( toConexion )", 3 )

							.agregarLinea( "", 3 )
							.agregarLinea( "endwith", 2 )

							.agregarLinea( "endif", 2 )

							.agregarLinea( "", 3 )

						endif
					endfor
				endwith
				.AgregarLinea( "endfunc", 1 )
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FuncionCargarTablaDeTrabajo() as Void
		local lcCursor as string, lcTablaTrabajo as string, lcTabla as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcCursor = this.cCursorAtributos
			select( lcCursor )
			locate for claveprimaria
			lcTabla = alltrim( &lcCursor..Tabla )

			lcTablaTrabajo = "TablaTrabajo_" + alltrim( &lcCursor..Tabla )
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected function CargarTablaDeTrabajo( toConexion as Object ) as void", 1 )
			.agregarLinea( "local loManejador as object, lcCursor as string", 2)

			.agregarLinea( "loManejador = _Screen.DotNetBridge.CrearObjeto( 'ZooLogicSA.ManejadorArchivos.CopiaMasiva' )", 2)
			.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 2 )
			.agregarLinea( "lcCursor = This.oEntidad.cPrefijoRecibir + '" + This.cTipo + "'", 3 )
			.agregarLinea( "else", 2 )
			.agregarLinea( "lcCursor = this.oEntidad.cPrefijoImportar + this.oEntidad.ObtenerNombre()", 3 )
			.agregarLinea( "endif", 2 )

			.agregarLinea( "with loManejador", 2 )

			.agregarLinea( "if this.oEntidad.VerificarContexto( 'CB' )", 3 )
			.agregarLinea( "else", 3 )
			.agregarLinea( ".AgregarMapeo('Nrolinea','Nrolinea')", 4 )
			.agregarLinea( "endif", 3 )

			select ( this.cCursorAtributos )
			scan all for !empty( Campo ) and !Detalle 
				.agregarLinea( ".AgregarMapeo('" + lower( alltrim( Campo ) ) + "','" + lower( alltrim( Campo ) ) + "')", 3 )
			endscan
			.agregarLinea( ".CadenaConexionOrigen = 'Provider=VFPOLEDB.1;Data Source= ' +  justpath( dbf( lcCursor ) )", 3 )
			.agregarLinea( ".CadenaConexionDestino = this.oConexion.oManagerConexionASql.ObtenerCadenaConexionNet()", 3 )
			.agregarLinea( ".NombreTablaSqlServer = '" + .Obtener_SchemaSelect( lcTabla ) + lcTablaTrabajo + "'", 3 )
			.agregarLinea( ".ConsultaOrigen = 'select * from ' + lcCursor", 3 )
			.agregarLinea( "Select( lcCursor )", 3 )
			.agregarLinea( "Count to This.nCantVeces", 3 )
			.agregarLinea( "This.nCantVeces = ceiling( This.nCantVeces / This.nCantABorrar )", 3 )

			.agregarLinea( "if !this.oEntidad.VerificarContexto( 'CB' )", 3 )
			.agregarLinea( "use in ( lcCursor )", 4 )
			.agregarLinea( "endif", 3 )

			.agregarLinea( ".ImportarMasivamente( toConexion )", 3 )
			.agregarLinea( "endwith", 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function FuncionObtenerTriggerDeleteImportacion() as Void
		local i as integer, loItem as object, lcWhere as string, lcEsquema as string, lcCamposSelect as String, lcVariablesAuditoria as String
		lcWhere = ""
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), 0 )
			.agregarLinea( "function ObtenerTriggerDeleteImportacion( tcTablaTrabajo ) as String", 1 )
			.agregarLinea( "local lcCadena as String, lcTabla as String, lcEntidad as String, loLogueo as Object, lcDescripcionFW as string", 2 )
			.agregarLinea( "lcTabla = alltrim( Upper( tcTablaTrabajo ) )", 2 )
			.agregarLinea( "loLogueo = this.oLogueo.oInfoLog", 2 )
			.agregarLinea( "lcEntidad = alltrim( Upper( This.oEntidad.ObtenerNombre() ) )", 2 )
			.agregarLinea( 'lcDescripcionFW = "IMPORTACION"', 2 )
			
			if .lInsertaSiempre 	
				this.AgregarTriggerSoloInsertar()
			else
				this.AgregarTriggerGenerico()
			endif 	

			&& LOGUEOS
			if this.oInfoClaveCandidata.count > 0 && solo loguea si hay CC
				.AgregarInsertLogueos( "'La clave principal no es la esperada'" )
				.AgregarFromClaveNoEsperada()
				.AgregarInsertLogueos( "'La clave principal a importar ya existe'" )
				.AgregarFromClaveYaExiste()
			endif
			&& FIN LOGUEOS
			.agregarLinea( "End" , 3 )
			.agregarLinea( "EndText" , 2 )
			.agregarLinea( "Return lcCadena" , 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerTriggerDeleteImportacionParaDetalles() as Void
		local loGenerador as Object, lnI as Integer, lcTabla as String, lcCursor as String, lcTablaTrabajo as String, lcCursorOriginal as String, lcCursorTrabajo as String, lcXml as String

		loGenerador = _screen.zoo.crearobjeto("generadordesentenciassqlsqlserver")

		with this
			for lnI = 1 to alen(.aDetalles,1)
				
				if empty( .aDetalles(lnI,2)) 
				else

					lcTabla = alltrim(.aDetalles(lnI,2))

					.agregarLinea( "" )
					.agregarLinea( "*" + replicate( "-", 104 ), 0 )
					.agregarLinea( "function ObtenerTriggerDeleteImportacion_" + lcTabla + "( tcTablaTrabajo ) as String", 1 )
					.agregarLinea( "" )

					lcCursor = alltrim(.aDetalles(lnI,7))
					lcTablaTrabajo = "TablaTrabajo_" + .cTabla + "_" + alltrim( lcTabla  )


					lcCursorOriginal = .aDetalles( lnI, 7 )
					lcCursorTrabajo = sys(2015)
					
					select * from &lcCursorOriginal into cursor &lcCursorTrabajo readwrite
		*							insert into &lcCursorTrabajo (tipodato, campo, longitud, decimales ) values ( "N", "Campo0", 20 , 0)

					lcXml = this.CursorAXml( lcCursorTrabajo )
					
					.agregarLinea( "Text to lcCadena noshow textmerge" , 2 )
					.agregarLinea( loGenerador.GenerarSentenciasTriggerDeleteImportacion( this.Obtener_SchemaSelect( .cTabla ), .cTabla, lcTabla, lcXml ), 2 )
					.agregarLinea( "EndText" , 2 )

					.agregarLinea( "Return lcCadena" , 2 )
					.AgregarLinea( "endfunc", 1 )

				endif

			endfor
		endwith

	endfunc 

	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerTriggerDeleteTransferencia() as Void
		local i as integer, loItem as object, lcWhere as string, lcEsquema as string, lcCamposSelect as String, lcVariablesAuditoria as String
		lcWhere = ""
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), 0 )
			.agregarLinea( "function ObtenerTriggerDeleteTransferencia( tcTablaTrabajo ) as String", 1 )
			.agregarLinea( "local lcCadena as String, lcTabla as String, lcEntidad as String, loLogueo as Object, lcDescripcionFW as string", 2 )
			.agregarLinea( "lcTabla = alltrim( Upper( tcTablaTrabajo ) )", 2 )
			.agregarLinea( "loLogueo = this.oLogueo.oInfoLog", 2 )
			.agregarLinea( "lcEntidad = alltrim( Upper( This.oEntidad.ObtenerNombre() ) )", 2 )
			.agregarLinea( 'lcDescripcionFW = ""', 2 )
			
			if .lTieneAuditoria
				lcVariablesAuditoria = strtran( .cVariablesInsertAuditoriaCabecera, [<<"'" + this.FormatearTextoSql( lcDescripcionFW ) + "'">>], ;
												 "case when funciones.empty( d.DescFw ) = 1 then '' else d.descFw end" )
				lcCamposSelect = .ParsearYAgregarVariablesAuditoria( lcVariablesAuditoria, "Cabecera", 2, .t. )
			endif
			
			.agregarLinea( "Text to lcCadena noshow textmerge" , 2 )
			lcEsquema = .Obtener_SchemaSelect( .cTabla )
			.agregarLinea( "CREATE TRIGGER " + lcEsquema + "DELETE_<<lcTabla>>" , 3 )
			.agregarLinea( "ON " + lcEsquema +  "<<lcTabla>>" , 4 )
			.agregarLinea( "AFTER DELETE" , 4 )
			.agregarLinea( "As", 3 )
			.agregarLinea( "Begin", 3 )
			.agregarLinea( "" , 0 )

			&& UPDATE
			.agregarLinea( "endtext" , 2 )

			.agregarLinea( "if This.ActualizaEnRecepcion()" , 1 )
			.agregarLinea( "Text to lcCadena noshow textmerge additive" , 2 )
			if .lTieneAuditoria
				.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + .cPrefijoAuditoria + .cTabla + " ( " + .cCamposInsertAuditoria + " ) ", 4 )
				.agregarLinea( "Select " + lcCamposSelect + ", " + this.cVariablesUpdAuditoriaImportacion,  5 )
				.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 6 )
				.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
*				for i = 1 to this.oInfoClaveCandidata.count
*					loItem = this.oInfoClaveCandidata.item[i]
*					.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
*				endfor
				.agregarLinea( " and ( ( d.FMODIFW > t.FMODIFW ) or ( d.FMODIFW = t.FMODIFW and d.HMODIFW>t.HMODIFW )  )",7)
				select( this.cCursorAtributos )
				scan all for auditoria
					lcWhere = lcWhere + " or ( d." + alltrim( Campo ) + " is not null and d." + alltrim( Campo ) + " <> t." + alltrim( Campo ) + " )"
				endscan
				.agregarLinea( "where " + substr( lcWhere, 5 ), 5 )
			endif
			if !.FuncionalidadNoLoguear()
				.AgregarInsertLogueoActualizado()
				.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
				.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
				endfor
			endif
			.agregarLinea( "Update t Set " +  .cCamposUpdNullYDefault , 4 )
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
*			for i = 1 to this.oInfoClaveCandidata.count
*				loItem = this.oInfoClaveCandidata.item[i]
*				.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
*			endfor
			.agregarLinea( " and ( ( d.FMODIFW > t.FMODIFW ) or ( d.FMODIFW = t.FMODIFW and d.HMODIFW>t.HMODIFW )  )",7)
			.agregarLinea( "-- Fin Updates" , 4 )
			.agregarLinea( "" , 0 )
			.agregarLinea( "endtext" , 2 )
			.agregarLinea( "else" , 1 )
			.agregarLinea( "Text to lcCadena noshow textmerge additive" , 2 )
			.AgregarInsertLogueoNoActualizaRecepcion()
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
			endfor
			.agregarLinea( "" , 0 )
			.agregarLinea( "endtext" , 2 )
			.agregarLinea( "endif" , 1 )
			&& FIN UPDATE

			&& INSERT
			.agregarLinea( "Text to lcCadena noshow textmerge additive" , 2 )
*!*				if .lTieneAuditoria
*!*					.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + this.cPrefijoAuditoria + this.cTabla + " ( " + this.cCamposInsertAuditoria + " ) ", 4 )
*!*					.agregarLinea( "Select " + lcCamposSelect + ", " + this.cVariablesInsertAuditoriaImportacion ,  5 )
*!*					.agregarLinea( "From deleted d left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " pk ", 6 )
*!*					.agregarLinea( " on d." + .cCampoClavePrimaria + " = pk." + .cCampoClavePrimaria , 7 )
*!*					if this.oInfoClaveCandidata.count > 0
*!*						.agregarLinea( " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
*!*						for i = 1 to this.oInfoClaveCandidata.count
*!*							loItem = this.oInfoClaveCandidata.item[i]
*!*							.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
*!*						endfor
*!*					endif
*!*					.agregarLinea( "Where pk." + .cCampoClavePrimaria + " Is Null ", 6 )
*!*					for i = 1 to this.oInfoClaveCandidata.count
*!*						loItem = this.oInfoClaveCandidata.item[i]
*!*						.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
*!*					endfor
*!*				endif

			.AgregarInsertLogueoAlta()
			.agregarLinea( "From deleted d left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " pk ", 6 )
			.agregarLinea( " on d." + .cCampoClavePrimaria + " = pk." + .cCampoClavePrimaria , 7 )
			if this.oInfoClaveCandidata.count > 0
				.agregarLinea( " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
				endfor
			endif
			.agregarLinea( "Where pk." + .cCampoClavePrimaria + " Is Null ", 6 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
			endfor


			.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + "(" + strtran( .cCamposInsert, '"', "" ) + ")" , 4 )
			.agregarLinea( "Select " + .cCamposInsertNullYDefault , 5 )
			.agregarLinea( "From deleted d left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " pk ", 6 )
			.agregarLinea( " on d." + .cCampoClavePrimaria + " = pk." + .cCampoClavePrimaria , 7 )
			if this.oInfoClaveCandidata.count > 0
				.agregarLinea( " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
				endfor
			endif
			.agregarLinea( "Where pk." + .cCampoClavePrimaria + " Is Null ", 6 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
			endfor


			.agregarLinea( "-- Fin Inserts" , 4 )
			&& FININSERT

			&& LOGUEOS
			if this.oInfoClaveCandidata.count > 0 && solo loguea si hay CC
				.AgregarInsertLogueos( "'La clave principal no es la esperada'" )
				.AgregarFromClaveNoEsperada()
				.AgregarInsertLogueos( "'La clave principal a importar ya existe'" )
				.AgregarFromClaveYaExiste()
			endif
			&& FIN LOGUEOS
			.agregarLinea( "End" , 3 )
			.agregarLinea( "EndText" , 2 )
			.agregarLinea( "Return lcCadena" , 2 )
			.agregarLinea( "endfunc", 1 )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertLogueos( tcExcepcion as string ) as Void
		local loItem as object, lcMensaje as string, i as integer
		
		
		lcMensaje = "No se pudo importar la entidad <<lcEntidad>>:"
		for i = 1 to this.oInfoClaveCandidata.count
			loItem = this.oInfoClaveCandidata.item[i]
			lcMensaje = lcMensaje + " " + upper( alltrim( loItem.Etiqueta ) )
			lcMensaje = lcMensaje + " ' + cast( d." + alltrim( loItem.Campo ) 
			lcMensaje = lcMensaje + " as Varchar(" + transform( loItem.Longitud ) + ") ) + ',"
		endfor
		lcMensaje = left( lcMensaje, len( lcMensaje ) - 1 )
			
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg		
			.agregarLinea( "Insert into " + _screen.zoo.app.cSchemaDefault + ".Logueos ( Fecha, Nivel, Logger, Accion, BaseDeDatos, ", 4 )
			.agregarLinea( "EstadoDelSistema, Aplicacion, Version, ", 5 )
			.agregarLinea( "Serie, Usuario, NombrePc, ", 5 )
			.agregarLinea( "UsuarioPc, OrigenLogueo, Mensaje, Excepcion)", 5 )
			.agregarLinea(	"select GetDate(), 'INFO', '', 'Importación <<lcEntidad>>','<<loLogueo.BaseDatos>>',", 4 )
			.agregarLinea( "<<loLogueo.EstadoSistema>>,'<<loLogueo.Aplicacion>>','<<loLogueo.Version>>',", 5 )
			.agregarLinea( "'<<loLogueo.Serie>>','<<loLogueo.Usuario>>','<<loLogueo.NombrePc>>',", 5 )
			.agregarLinea( "'<<loLogueo.UsuarioPc>>','<<loLogueo.OrigenLogueo>>','" + lcMensaje + "'," + tcExcepcion , 5 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertLogueoTransferencia( tcMensaje as String ) as Void
		local loItem as object, lcMensaje as string, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "Insert into " + _screen.zoo.app.cSchemaDefault + ".Logueos ( Fecha, Nivel, Logger, Accion, BaseDeDatos, ", 4 )
			.agregarLinea( "EstadoDelSistema, Aplicacion, Version, ", 5 )
			.agregarLinea( "Serie, Usuario, NombrePc, ", 5 )
			.agregarLinea( "UsuarioPc, OrigenLogueo, Mensaje, Excepcion)", 5 )
			.agregarLinea(	"select GetDate(), 'INFO', '', 'Recepción <<lcEntidad>>','<<loLogueo.BaseDatos>>',", 4 )
			.agregarLinea( "<<loLogueo.EstadoSistema>>,'<<loLogueo.Aplicacion>>','<<loLogueo.Version>>',", 5 )
			.agregarLinea( "'<<loLogueo.Serie>>','<<loLogueo.Usuario>>','<<loLogueo.NombrePc>>',", 5 )
			.agregarLinea( "'<<loLogueo.UsuarioPc>>', '<<loLogueo.OrigenLogueo>>','" + tcMensaje + "', ''", 5 )

		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertLogueoNoActualizaRecepcion() as Void
		local loItem as object, lcMensaje as string, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcMensaje = "<<lcEntidad>> - "
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				lcMensaje = lcMensaje + " " + upper( alltrim( loItem.Etiqueta ) ) + " ' + cast( d." + alltrim( loItem.Campo ) + " as Varchar(" + transform( loItem.Longitud ) + ") ) + ' - "
			endfor
			lcMensaje = left( lcMensaje, len( lcMensaje ) - 2 )

			lcMensaje = lcMensaje + "no se pudo recibir porque ya existe y el mismo no actualiza en recepción."

			
			this.AgregarInsertLogueoTransferencia( lcMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertLogueoActualizado() as Void
		local loItem as object, lcMensaje as string, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg

			lcMensaje = "<<lcEntidad>> - "
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				lcMensaje = lcMensaje + " " + upper( alltrim( loItem.Etiqueta ) ) + " ' + cast( d." + alltrim( loItem.Campo ) + " as Varchar(" + transform( loItem.Longitud ) + ") ) + ' - "
			endfor
			lcMensaje = left( lcMensaje, len( lcMensaje ) - 2 )

			lcMensaje = lcMensaje + "recibido ( modifica existente )."
			
			this.AgregarInsertLogueoTransferencia( lcMensaje )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInsertLogueoAlta() as Void
		local loItem as object, lcMensaje as string, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg

			lcMensaje = "<<lcEntidad>> - "
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				lcMensaje = lcMensaje + " " + upper( alltrim( loItem.Etiqueta ) ) + " ' + cast( d." + alltrim( loItem.Campo ) + " as Varchar(" + transform( loItem.Longitud ) + ") ) + ' - "
			endfor
			lcMensaje = left( lcMensaje, len( lcMensaje ) - 2 )

			lcMensaje = lcMensaje + "recibido ( alta )."
			
			this.AgregarInsertLogueoTransferencia( lcMensaje )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFromClaveNoEsperada() as Void
		local loItem as object, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( iif( i = 1, "on ", " and" ) + "  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
			endfor
			.agregarLinea( "left join deleted h " , 6 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = h." + .cCampoClavePrimaria , 7 )
			.agregarLinea( " where h." + .cCampoClavePrimaria + " is null " , 7 )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFromClaveYaExiste() as Void
		local loItem as object, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
			.agregarLinea( "left join deleted h " , 6 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( iif( i = 1, "on ", " and " ) + "  t." + alltrim( loItem.Campo ) + " = h." + alltrim( loItem.Campo ), 7 )
			endfor
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( iif( i = 1, "where ", " and " ) + "  h." + alltrim( loItem.Campo ) + " is null ", 7 )
			endfor
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarFromExiste() as Void
		local loItem as object, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
			.agregarLinea( "left join deleted h " , 6 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = h." + .cCampoClavePrimaria , 7 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = h." + alltrim( loItem.Campo ), 7 )
			endfor
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorDefaultSegunTipo( tcTipoDato as string ) as string
		local lcRetorno as string, lcTipoDato as string
		lcTipoDato = alltrim( upper( tcTipoDato ))
		do case
			case inlist( lcTipoDato, "M", "C", "G","D" )
				lcRetorno = ['']
			otherwise
				lcRetorno = [0]
		endcase
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoUPDNullYDefault( tcCampo as string ) as string
		local lcCampo as string, lcRetorno as string
		lcCampo = upper( alltrim( tcCampo ) )
		lcRetorno = "t." + lcCampo + " = isnull( d." + lcCampo + ", t." + lcCampo + " ),"
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCampoInsertNullYDefault( tcCampo as string , tcTipoDato as string  ) as string
		local lcRetorno as string
		lcCampo = upper( alltrim( tcCampo ) )
		do case
			case lcCampo = "FALTAFW"
				lcRetorno =  "CONVERT(datetime, convert(varchar(10),getdate(),112) ),"
			case lcCampo = "HALTAFW"
				lcRetorno = "convert( char(8), getdate(), 108 ),"
			case lcCampo = "TIMESTAMPA"
				lcRetorno = "[funciones].ObtenerTimestamp() + row_number() OVER (ORDER BY d." + alltrim( this.cCampoClavePrimaria ) + "),"
			otherwise
				lcRetorno = "isnull( d." + lcCampo + "," + this.ObtenerValorDefaultSegunTipo( tcTipoDato ) + "),"
		endcase
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneValorSugerido( tcCursor as string ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = !empty( &tcCursor..ValorSugerido ) or ;
							( &tcCursor..Alta and !(&tcCursor..ClavePrimaria) and ;
								!this.oFunc.TieneFuncionalidad( "NOSALTODECAMPO", &tcCursor..Tags ) and ;
								substr( upper( &tcCursor..Dominio ), 1, 7 ) != "DETALLE" )

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionAplicarReglaDeNegocioTablaDeTrabajo() as Void
		local lcCursor as string, lcTablaTrabajo as string, loColeccion AS zoocoleccion OF zoocoleccion.prg
		
		lcCursor = this.cCursorAtributos
		select( lcCursor )
		locate for claveprimaria
		lcTablaTrabajo = "TablaTrabajo_" + alltrim( &lcCursor..Tabla )
		lcTablaTrabajoConSchema = this.Obtener_SchemaSelect( &lcCursor..Tabla ) + lcTablaTrabajo
		loColeccion = _Screen.Zoo.Crearobjeto( "ZooColeccion" )
		local lcFuncionValidacionBasicaObligatorioFK as String 
		
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "protected function AplicarReglaDeNegocioTablaDeTrabajo( toConexion as Object ) As Void", 1 )
			.agregarLinea( "local llEjecutarRollback as Boolean, lcCursor as String, llNoVienePorDiseño as Boolean", 2 )
			.agregarLinea( "llEjecutarRollback = .F.", 2 )
			.agregarLinea( "try", 2 )

			.agregarLinea( "", 3 )
			.agregarLinea( "toConexion.EjecutarNonQuery( 'DISABLE TRIGGER ALL ON " + lcTablaTrabajoConSchema + "' )", 3 )
			.agregarLinea( "", 3 )
			.agregarLinea( "lcCursor = this.oentidad.cprefijoimportar + this.oentidad.cnombre", 3 )
			.agregarLinea( "this.AbrirCursores( PcXmlDatos, this.oEntidad.cPrefijoImportar )", 3 )
			.agregarLinea( "select (lcCursor)", 3 )
			.agregarLinea( "", 3 )
			

*-Valores Sugeridos---------------
			select (lcCursor)

			scan
				if !EsEntidad and this.TieneValorSugerido( lcCursor )				
					.agregarLinea( [*** Valor sugerido ] + alltrim(atributo), 3 )
					.agregarLinea( [lcExpresionValorSugeridoDefinidoPorElUsuario = goServicios.SaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( "]+alltrim( cEntidad )+[", "", "]+alltrim(atributo)+[" )], 3 )
					if upper(alltrim( tipodato )) = "L"
						.agregarLinea( [llNoVienePorDiseño = isnull(&] + [lcCursor..] + alltrim(campo) + [ ) &] + [&El atributo no está definido en el diseño de importación. Ésta condicion es solamente para atributos boleanos], 3)										
					endif
					.agregarLinea( [if !empty( NVL( lcExpresionValorSugeridoDefinidoPorElUsuario, "" ) )] + iif(upper(alltrim( tipodato )) = "L", [ and llNoVienePorDiseño ], ""), 3 )
					.agregarLinea( [lvValor = &lcExpresionValorSugeridoDefinidoPorElUsuario], 4 )
					.agregarLinea( [toConexion.EjecutarNonQuery( "UPDATE ] + lcTablaTrabajoConSchema + [ SET ] + alltrim( campo ) + [ = " + golibrerias.ValorAStringSegunTipoBase( lvValor  ) + " WHERE Funciones.Empty( ] + alltrim(campo) + [ ) = 1" )], 4 )
					.agregarLinea( [endif], 3 )
					.agregarLinea( [], 3 )
				endif
			endscan
			
			.agregarLinea( "use in ( lcCursor )", 3 )
			.agregarLinea( "", 3 )

			go top && :(
			.agregarLinea( "lcInsertBaseLogueo = [INSERT INTO ZooLogic.Logueos ( Fecha, Nivel, Logger, Accion, BaseDeDatos, EstadoDelSistema, Aplicacion, Version, Serie, Usuario, NombrePc, UsuarioPc, OrigenLogueo, Mensaje, Excepcion ) ]", 3 )

			.agregarLinea( "lcCamposLogueo = [Fecha, Nivel, Logger, Accion, BaseDeDatos, EstadoDelSistema, Aplicacion, Version, Serie, Usuario, NombrePc, UsuarioPc, OrigenLogueo, Excepcion, Mensaje]", 3 )

			.agregarLinea( "lcBD = goServicios.Seguridad.cBaseDeDatosSeleccionada", 3 )
			.agregarLinea( "lcApp = _Screen.Zoo.App.Nombre", 3 )
			.agregarLinea( "lcVersion = _Screen.Zoo.App.ObtenerVersion()",  3 )
			.agregarLinea( "lcSerie = _Screen.Zoo.App.cSerie", 3 )
			.agregarLinea( "lcUsuario = goServicios.Seguridad.cUsuarioLogueado", 3 )
			.agregarLinea( "lcValuesLogueoComunes = [SELECT GetDate(), 'INFO', '', 'Validacion IMPO','] + lcBD + [',0,'] + lcApp + [','] + lcVersion + [','] + lcSerie  + [','] + lcUsuario +[','NOMBREPC','USUARIOPC','ORIGENLOGUEO','',]", 3 )
			.agregarLinea( "", 3 )
*---------------------------------

*-Validacion Dominions -----------

			local loColDominiosAValidar as zoocoleccion OF zoocoleccion.prg 
			
			loColDominiosAValidar = _screen.zoo.crearobjeto("zoocoleccion")

			Local Array laMembers[01]

			loDominio = Newobject( "dominios", "dominios.prg" )
			lnCant = AMembers( laMembers, loDominio, 03)

			For x = 1 To lnCant

				lcFuncion 	= Upper( Alltrim( laMembers[x, 01] ) )
				lcTipo		= Upper( Alltrim( laMembers[x, 02] ) )

				If lcTipo == "METHOD" .And. Left( lcFuncion, 15 ) == "VALIDARDOMINIO_"
					loColDominiosAValidar.Agregar( Substr( lcFuncion, 16 ), Substr( lcFuncion, 16 ) )
				EndIf
			Next x

			loDominio = Null
			
			select (lcCursor)
			scan for !&lcCursor..Detalle and loColDominiosAValidar.Buscar( Upper( Alltrim( &lcCursor..Dominio ) ) )
				.agregarLinea( "this.oEntidad.oValidacionDominios.ValidarDominioBloqueImportacion_" + proper( alltrim( &lcCursor..Dominio ) ) + "( '" + lcTablaTrabajoConSchema + "','ZooLogic.TablaTrabajoErroresValidacion_" + alltrim( &lcCursor..Tabla ) + "', '" + alltrim( &lcCursor..Campo ) + "', toConexion )", 3 )
			Endscan
			.AgregarLinea( "" )
			go top && :(
*---------------------------------

*- Validaciones Basicas (obligatorio, FK) ----------
				select d .campo as campoForaneo, d.tabla as TablaForanea, a.EsEntidad, a.campo, a.Tabla, a.atributo, a.claveforanea ;
				from &lcCursor a ;
				left join c_diccionario d on upper( alltrim( a.claveforanea ) ) = upper( alltrim( d.entidad ) ) and d.claveprimaria ;
				where a.Obligatorio ;
					and !a.ClavePrimaria ;
					and !empty( a.tabla ) ;
					and !empty( a.campo ) ;
				into cursor c_validaciones
			
			scan
				lcClaveforanea =""
				lcSubqueryFK = ""
				lcNombreMetodo = ""

				if EsEntidad 
					lcEsquemaForanea = this.ObtenerEsquema( TablaForanea )
					lcSubqueryFK = "or " + alltrim( campo )+ " NOT IN ( SELECT " + alltrim( campoForaneo) + " from " + lcEsquemaForanea + "." + alltrim( TablaForanea ) + " )"
				endif
				.AgregarLinea( "* " + alltrim( atributo ) + " obligatorio" + iif( EsEntidad, " y FK ", "" ), 3 )
				
				lcWhere = "WHERE Funciones.Empty( " + alltrim( campo ) + " ) = 1 " + lcSubqueryFK
				lcExpresionMensaje = "[CASE WHEN Funciones.Empty( " + alltrim( campo ) + " ) = 1 THEN 'Debe cargar el campo " + alltrim( atributo ) + ".' ELSE 'El dato buscado ' + RTRIM( CAST( " + alltrim( campo ) +" AS VARCHAR(255) ) ) + ' de la entidad " + alltrim( claveforanea ) + " no existe.' END]"
				
				.AgregarLinea( [lcWhere = '] + lcWhere + ['], 3 )
				.AgregarLinea( [lcExpresionMensaje  = ] + lcExpresionMensaje, 3 )

				lcNombreMetodo = "ValidacionBasicaObligatorioFK" + alltrim( atributo )
				.AgregarLinea(	"this."+ lcNombreMetodo + "( toConexion, lcExpresionMensaje, lcWhere, lcCamposLogueo, lcValuesLogueoComunes ) ", 3)
				.AgregarLinea ( "" )
				
				lcTablaAct = alltrim( &lcCursor..Tabla )		
				text to lcFuncionValidacionBasicaObligatorioFK textmerge noshow
function <<lcNombreMetodo>>( toConexion, lcExpresionMensaje, lcWhere, lcCamposLogueo, lcValuesLogueoComunes ) as void
		toConexion.EjecutarNonQuery( [INSERT INTO ZooLogic.TablaTrabajoErroresValidacion_<<lcTablaAct>> ( NroLinea, Motivo ) SELECT NroLinea, ] + lcExpresionMensaje + [ FROM <<lcTablaTrabajoConSchema>> ] + lcWhere )
		toConexion.EjecutarNonQuery( [INSERT INTO ZooLogic.Logueos ( ] + lcCamposLogueo + [ ) ] + lcValuesLogueoComunes + lcExpresionMensaje + [ FROM <<lcTablaTrabajoConSchema >> ] + lcWhere )
		toConexion.EjecutarNonQuery( [DELETE FROM <<lcTablaTrabajoConSchema>> ] + lcWhere )
	endfunc
				endtext
				
				loColeccion.Add(lcFuncionValidacionBasicaObligatorioFK)
			endscan
			*---------------------------------

			*- Validaciones Basicas (FK) ----------
			select d.campo as campoForaneo, d.tabla as TablaForanea, a.EsEntidad, a.campo, a.Tabla, a.atributo, a.claveforanea ;
					from &lcCursor a ;
					inner join c_diccionario d on upper( alltrim( a.claveforanea ) ) = upper( alltrim( d.entidad ) ) and d.claveprimaria ;
					where !a.Obligatorio and a.EsEntidad ;
							and !a.ClavePrimaria ;
							and !empty( a.tabla ) ;
							and !empty(a.campo) ;
					into cursor c_validaciones

			scan
				.AgregarLinea( "* " + alltrim( atributo ) + " FK ", 3 )
				lcEsquemaForanea = this.ObtenerEsquema( TablaForanea)
				lcSubqueryFK = "AND  " + alltrim( campo )+ " NOT IN ( SELECT " + alltrim( campoForaneo) + " FROM " + lcEsquemaForanea + "." + alltrim( TablaForanea ) + " )"
				
				lcWhere = "WHERE Funciones.Empty( " + alltrim( campo ) + " ) = 0 " + lcSubqueryFK
				lcExpresionMensaje = "['El dato buscado ' + RTRIM( CAST( " + alltrim( campo ) +" AS VARCHAR(255) ) ) + ' de la entidad " + alltrim( claveforanea ) + " no existe.']"
				
				.AgregarLinea( [lcWhere = '] + lcWhere + ['], 3 )
				.AgregarLinea( [lcExpresionMensaje  = ] + lcExpresionMensaje, 3 )
				
				.AgregarLinea( "toConexion.EjecutarNonQuery( [INSERT INTO ZooLogic.TablaTrabajoErroresValidacion_" + alltrim( &lcCursor..Tabla ) +" ( NroLinea, Motivo ) SELECT NroLinea, ] + lcExpresionMensaje  + [ FROM " + lcTablaTrabajoConSchema + " ] + lcWhere )", 3 )
				.AgregarLinea( "toConexion.EjecutarNonQuery( [INSERT INTO ZooLogic.Logueos ( ] + lcCamposLogueo + [ ) ] + lcValuesLogueoComunes + lcExpresionMensaje  + [ FROM " + lcTablaTrabajoConSchema + " ] + lcWhere )", 3 )
				.AgregarLinea( "toConexion.EjecutarNonQuery( [DELETE FROM " + lcTablaTrabajoConSchema + " ] + lcWhere )", 3 )
				.AgregarLinea( "", 3 )
			endscan
			*----------------------------

			.agregarLinea( "this.oEntidad.EjecutarReglaDeNegocioPersonalizadaImportacion( toConexion )", 3 )

			.agregarLinea( "toConexion.EjecutarNonQuery( 'ENABLE TRIGGER ALL ON " + lcTablaTrabajoConSchema + "' )", 3 )
			
			.agregarLinea( "catch to loError", 2 )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", 3 )
			.agregarLinea( "endtry", 2 )
			.agregarLinea( "EndFunc", 1 )
			.agregarLinea( "" )
			
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
					
			for i=1 to loColeccion.Count
					.agregarLinea ( loColeccion.Item[i],1)
					.agregarLinea ( "" )
					.agregarLinea ( "*" + replicate( "-", 104 ), 1 )
			endfor
		endwith
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function FuncionImportarTablaDeTrabajo() as Void
		local lcCursor as string, lcTablaTrabajo as string

		lcCursor = this.cCursorAtributos
		select( lcCursor )
		locate for claveprimaria
		lcTablaTrabajo = "TablaTrabajo_" + alltrim( &lcCursor..Tabla )
		lcTablaTrabajoConSchema = this.Obtener_SchemaSelect( &lcCursor..Tabla ) + lcTablaTrabajo

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "*" + replicate( "-", 104 ), 1 )
			.agregarLinea( "Function ImportarTablaDeTrabajo( toConexion as Object ) As Void", 1 )
			.agregarLinea( "local llEjecutarRollback as Boolean", 2 )
			.agregarLinea( "llEjecutarRollback = .F.", 2 )
			.agregarLinea( "try", 2 )
		
			.agregarLinea( "do While this.nCantVeces > 0", 3 )
			.agregarLinea( "this.nCantVeces = this.nCantVeces - 1", 4 )

			.agregarLinea( "" )
			.agregarLinea( "this.InicializarMensajesConexion()", 4 )
				
			.agregarLinea( "" )
			.agregarLinea( [toConexion.EjecutarNonQuery( 'Delete top (' + transform( This.nCantABorrar ) + ') From ] + lcTablaTrabajoConSchema + [')], 4 )
				
			.agregarLinea( "" )
			.agregarLinea( "if this.oMensajesConexion.Count>0", 4 )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( this.ObtenerMensajesConexion() )", 5 )
			.agregarLinea( "endif", 4 )
			.agregarLinea( "" )


			.agregarLinea( "enddo", 3 )
			.agregarLinea( "catch to loError", 2 )
			.agregarLinea( "goServicios.Errores.LevantarExcepcion( loError )", 3 )
			.agregarLinea( "endtry", 2 )
			.agregarLinea( "EndFunc", 1 )
			.agregarLinea( "" )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarDeletesDetallesActualiza( tnTab as integer ) as Void

		local i as integer, lcCampoClavePrimaria as string, lcTabla as string, lcSentencia as string, llTengoDetalle as Boolean
		llTengoDetalle = .f.
		for i = 1 to alen( .aDetalles, 1 )
			if empty( .aDetalles( i, 2 ) )
			else
				llTengoDetalle = .t.
				exit
			endif
		endfor
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if llTengoDetalle
				.agregarLinea( "Local lcIn as String, lcCantRegistros as Integer" , tnTab )
				.agregarLinea( "Select( lcCursor )" , tnTab )
				.agregarLinea( "Count to lcCantRegistros" , tnTab )
				.agregarLinea( "If lcCantRegistros > 0" , tnTab )
				.agregarLinea( "lcIn = This.ObtenerInSqlServer( lcCursor, '" + .cCampoClavePrimaria  + "','" + .cTipoDatoClavePrimaria + "')" , tnTab + 1 )
				
				.agregarLinea( "lnFragmento = goRegistry.nucleo.cantidadDeElementosEnSentenciaInSQL", tnTab + 1 )
				.agregarLinea( "loIn = this.ObtenerColeccionInSqlServer( lcCursor,'','" + .cCampoClavePrimaria  + "')", tnTab + 1 )
				.agregarLinea( "llEjecutaEnTransaccion = loIn.count > 0", tnTab + 1 )
				.agregarLinea( "if llEjecutaEnTransaccion", tnTab + 1 )
				.agregarLinea( "this.oConexion.EjecutarSQL( 'BEGIN TRANSACTION' )", tnTab + 2 )
				.agregarLinea( "endif", tnTab + 1 )
				
				.agregarLinea( "for i = 1 to loIn.count step lnFragmento", tnTab + 1 )
				.agregarLinea( "lcIn = this.ObtenerFragmentoColeccionInSqlServer( loIn, i, lnFragmento )", tnTab + 2 )

				for i = 1 to alen( .aDetalles, 1 )
					if empty( .aDetalles( i, 2 ) )
					else
						lcCampoClavePrimaria =  iif(empty(.aDetalles(i,3)), .cCampoClavePrimaria, alltrim(.aDetalles(i,3)))
						lcTabla = .aDetalles( i, 2 )
						lcSentencia = "[Delete From " + .Obtener_SchemaSelect( lcTabla ) + lcTabla + " Where " + lcCampoClavePrimaria + '] + lcIn '
						.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + " )", tnTab + 1 )
					endif
				endfor

				.agregarLinea( "endfor", tnTab + 1 )

				.agregarLinea( "if llEjecutaEnTransaccion", tnTab + 1 )
				.agregarLinea( "this.oConexion.EjecutarSQL( 'COMMIT TRANSACTION' )", tnTab + 2 )
				.agregarLinea( "endif", tnTab + 1 )

				.agregarLinea( "EndIf" , tnTab )
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarRecepcionInsertDetalles( tnTab as integer ) as Void
		local i as integer, lcCampoClavePrimaria as string, lcTabla as string, ;
			lcSentencia as string, loCamposInsert as object,loCampo as object, lcCamposInsertOrigen as string, ;
			lcCamposInsertDestino as string, lcCampo as string 
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg

			for i = 1 to alen( .aDetalles, 1 )
				if empty( .aDetalles( i, 2 ) )
				else
					lcCampoClavePrimaria =  iif(empty( .aDetalles( i, 3 ) ), .cCampoClavePrimaria, alltrim( .aDetalles( i, 3 ) ) )
					if !empty( .cTipoDatoClavePrimaria ) and .cTipoDatoClavePrimaria <> .aDetalles( i, 11 )
						lcCampo = " transform( " + .cCampoClavePrimaria+ " )"
					else 
						lcCampo = .cCampoClavePrimaria
					endif  
					lcTabla = alltrim( .aDetalles( i, 2 ) ) 
					.agregarLinea( "lcDetalle = This.oEntidad.cPrefijoRecibir + '" + substr( alltrim( .aDetalles( i, 6 ) ), 8 ) + "'", tnTab )
					.agregarLinea( "Select * From &lcDetalle into cursor cDetallesExistentes ;", tnTab )
					.agregarLinea( "where " + alltrim( lcCampoClavePrimaria ) + " in ( select " + alltrim( lcCampo ) + " from &lcCursor )", tnTab + 1 )

					lcSentencia = "[Insert into " + .Obtener_SchemaSelect( lcTabla ) + lcTabla + " ( ] + lcCamposInsert + [ ) values ( ] + "
					lcSentencia = lcSentencia + .aDetalles( i, 14 )
					lcSentencia = lcSentencia + " + ' )' "
					.agregarLinea( "select cDetallesExistentes", tnTab )
					.agregarLinea( "Scan All", tnTab )
					.agregarLinea( "Text to lcCamposInsert noShow", tnTab + 1 )
					.agregarLinea(  .aDetalles( i, 12 ), tnTab + 2 )
					.agregarLinea( "endText", tnTab + 1 )
					.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + " )", tnTab + 1 )
					.agregarLinea( "select cDetallesExistentes", tnTab + 1 )
					.agregarLinea( "EndScan", tnTab )
					.agregarLinea( "Use in select( 'cDetallesExistentes' )", tnTab )
				endif
			endfor
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirRecepcion_IF_Campo_Anulable( tnTab as integer, tcCampoAnulado as string ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "if curSeek." + tcCampoAnulado , tnTab )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function TablaDeRecepcionParaComparaciones() as String
		return "CurSeek"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirRecepcion_Insert( tnTab as integer ) as Void
		local lcSentencia as string, loCamposInsert as object,loCampo as object, lcCamposInsertOrigen as string, lcCamposInsertDestino as string
		local lcDataEntry as String, lcDataEntryFinal as String
		
		lcCamposInsertOrigen = ""
		lcCamposInsertDestino = ""
		lcDataEntry = ""
		lcDataEntryFinal = "local lcValoresCampos as string" + chr(13) + chr(10) + "lcValoresCampos = ''" + chr(13) + chr(10)
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			loCamposInsert = .ObtenerCamposTransferenciaInsert()
			for each loCampo in loCamposInsert
				lcCamposInsertOrigen =  " + ',' + " + .ObtenerStringSegunTipoRecepcion( loCampo.TipoDato, "&lcCursor.." + loCampo.Campo )
				lcDataEntry = lcDataEntry + lcCamposInsertOrigen 
				if len(lcDataEntry)>400
					lcDataEntryFinal = lcDataEntryFinal + "lcValoresCampos = lcValoresCampos " + lcDataEntry + chr(13)+chr(10)
					lcDataEntry = ""
				endif
				lcCamposInsertDestino = lcCamposInsertDestino + ", " + loCampo.Campo
			endfor

			if len(lcDataEntry)>0
				lcDataEntryFinal = lcDataEntryFinal + "lcValoresCampos = lcValoresCampos " + lcDataEntry + chr(13)+chr(10)
				lcDataEntry = ""
			endif
			
			lcDataEntryFinal = lcDataEntryFinal + "lcValoresCampos = substr(lcValoresCampos,2) "+ chr(13)+chr(10)
			lcCamposInsertDestino = substr( lcCamposInsertDestino, 2 )


			.agregarLinea( "Text to lcCampos noShow", tnTab )
			.agregarLinea( lcCamposInsertDestino, tnTab + 1 )
			.agregarLinea( "EndText", tnTab )

			.agregarLinea( lcDataEntryFinal, tnTab )

			lcSentencia = "this.oConexion.EjecutarSql( [Insert into " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " ( ] + lcCampos + [ ) values ( ] + lcValoresCampos +[ ) ] + goServicios.RealTime.ObtenerTagEstimulo( .oEntidad.cNombre )  )"
			.agregarLinea( lcSentencia, tnTab )
			
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirRecepcion_IF_Seek_ClavePrimaria( tnTab as integer ) as Void
		local lcSentencia as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcSentencia = "[Select * From " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " Where " + .cCampoClavePrimaria + ' = ] + ' + .ObtenerStringSegunTipoRecepcion( .cTipoDatoClavePrimaria, "&lcCursor.." + .cCampoClavePrimaria )
			.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + ", 'curSeek', this.datasessionid )", tnTab)
			.agregarLinea( "if reccount( 'curSeek' ) > 0", tnTab )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirRecepcion_Replace( tnTab as integer, tlUsaClaveCandidata as Boolean, tlEsEdicionParcial as Boolean ) as Void
		local loCamposReplaces as object, loItem as object, lcCamposReplaces as string, lcSentencia as string 
		lcCamposReplaces = ""
		lcSentencia = ""

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			loCamposReplaces = .ObtenerCamposTransferenciaReplace( tlEsEdicionParcial )
			for each loItem in loCamposReplaces
				if .EsAtributoAcumulable( this.cTipo, loItem.Atributo )
					lcCamposReplaces = lcCamposReplaces + "+ [, " + loItem.Campo + " = " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + "." + loItem.Campo + " + ] + " + .ObtenerStringSegunTipoRecepcion( loItem.TipoDato, "&lcCursor.." + loItem.Campo )
				else
					lcCamposReplaces = lcCamposReplaces + "+ [, " + loItem.Campo + " = ] + "  + .ObtenerStringSegunTipoRecepcion( loItem.TipoDato, "&lcCursor.." + loItem.Campo )
				endif
			endfor
			lcCamposReplaces = substr( lcCamposReplaces, 5 )
			lcSentencia = "[UPDATE " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " set " + lcCamposReplaces + " + [ Where " + .cCampoClavePrimaria + ' = ] + '&& + .ObtenerStringSegunTipoRecepcion( .cTipoDatoClavePrimaria, "&lcCursor.." + .cCampoClavePrimaria )
			if tlUsaClaveCandidata
				lcSentencia = lcSentencia +  .ObtenerStringSegunTipoRecepcion( .cTipoDatoClavePrimaria, "lcValorABuscar" )
			else			
				lcSentencia = lcSentencia +  .ObtenerStringSegunTipoRecepcion( .cTipoDatoClavePrimaria, "&lcCursor.." + .cCampoClavePrimaria )
			endif
			.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + " )", tnTab)
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirRecepcion_IF_CoincidenClavePrimaria( tnTab as integer ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "if lxValorClavePK == curSeek." + alltrim( .cCampoClavePrimaria )+ " or this.oEntidad.lIgnorarClaveprimariaEnRecepcionBD ", tnTab )
			.agregarLinea( "if lxValorClavePK != curSeek."+ alltrim( .cCampoClavePrimaria )+ " and this.oEntidad.lIgnorarClaveprimariaEnRecepcionBD ", tnTab +1  )
			.agregarLinea( "lcValorABuscar = curSeek." + alltrim( .cCampoClavePrimaria ), tnTab +2)
			.agregarLinea( "else ", tnTab +1)
			.agregarLinea( "lcValorABuscar = lxValorClavePK ", tnTab +2)
			.agregarLinea( "endif ", tnTab +1)		
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EscribirIf_Seek_Clave_Candidata( tnTab as integer ) as Void
		local lcSentencia as string, loItem as object, i as integer
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			lcSentencia = "[Select * From " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " Where "
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				lcSentencia = lcSentencia + iif( i = 1, " ", " + [ and " ) + alltrim( loItem.Campo ) + " = ] + " + .ObtenerStringSegunTipoRecepcion( loItem.TipoDato, "&lcCursor.." + loItem.Campo )
			endfor
			.agregarLinea( "this.oConexion.EjecutarSql( " + lcSentencia + ", 'curSeek', this.datasessionid )", tnTab)
			.agregarLinea( "if reccount( 'curSeek' ) > 0", tnTab )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarAuditoria( tnTab as integer ) as Void
		local lcCampoAcumula as string

		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if .lTieneAuditoria
				.AgregarLinea( "lcSentencia = this.ObtenerSentenciasInsertAuditoria()", 3 )
				.AgregarLinea( "this.oConexion.EjecutarSql( lcSentencia )", 3 )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInsertDetalleRecepcion( tcCursor as string ) as string
		local lcCampos as string
		store "" to lcCampos
		select ( tcCursor )
		scan  for alltrim( &tcCursor..TipoDato ) != 'A'
			lcCampos = lcCampos + " + ',' + " + this.ObtenerStringSegunTipoRecepcion( &tcCursor..TipoDato, "cDetallesExistentes." + &tcCursor..Campo )
		endscan
		lcCampos = substr( lcCampos, 9 )
		return lcCampos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarTriggersDetalles( tnI ) as string
		local lcCadena as string , lcItem as string
		lcCadena = ""
		if !empty( this.aDetalles[ tnI,6 ])
			lcItem = upper( alltrim( strtran( upper( this.aDetalles[ tnI,6 ]), "DETALLE", '' ) ) )
			this.VerificarTriggersEnEntidad( lcItem, "I" )
			if this.lTieneTriggersEnDetalleInsertar
				lcCadena = this.GenerarSentenciasTriggerDetalle( "INSERTAR", lcItem )
			endif

		endif
		return lcCadena
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringSegunTipoRecepcion( tcTipoDato as string, tcValor as string ) as string
		local lcRetorno as string
		lcRetorno = this.ObtenerStringSegunTipo( tcTipoDato, tcValor )
		if upper( alltrim( tcTipoDato ) ) == "L"
			lcRetorno = "Transform( " + lcRetorno + ")"
		endif
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCurSeek() as string
		return "curSeek"
	endfun

	*-----------------------------------------------------------------------------------------
	protected function AgregarLineasAsignacionClavePrimariaInsert() as Void
		local lcCadenaAsignacion as string
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if .cTipoDatoClavePrimaria = "C"
				.agregarLinea( [lcValorClavePrimariaString = "'" + this.oEntidad.] + .cAtributoClavePrimaria + [ + "'"], 3 )
			else
				.agregarLinea( [lcValorClavePrimariaString = transform( this.oEntidad.] + .cAtributoClavePrimaria + [ )], 3 )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarAuditoriaRecepcion( tnTab as integer ) as Void
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if .lTieneAuditoria
				.AgregarLinea( "lcSentencia = this.ObtenerSentenciasInsertAuditoria( lcCursor )", tnTab )
				.AgregarLinea( "this.oConexion.EjecutarSql( lcSentencia )", tnTab )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVariableInsertAuditoria( tcVariable as String, tcTipoDato as String, tcPrefijo as String ) as String
		return "<<" + this.obtenerStringseguntipo( tcTipoDato, tcPrefijo + tcVariable ) + ">>"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFiltroSubEntidad( tcEntidad as String ) as string
		local lcRetorno as String, lcSql as string, lcTipoDato as String, lcCondicion as String
		
		lcRetorno = ""
		if empty( tcEntidad )
			tcEntidad = this.cTipo
		endif
			
		if this.oFunc.TieneFuncionalidad( "DESACTIVABLE", 		this.ObtenerFuncionalidades( upper( alltrim( this.cTipo ) ) ) )
			lcCampoDestino = This.ObtenerCampoAtributo( tcEntidad, "INACTIVOFW" )
			lcRetorno = " ( " + alltrim( This.ObtenerTabla( tcEntidad ) ) + "." + alltrim( lcCampoDestino ) + " = 0)"
		endif
		
		return lcRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaComparacionDeFechaAuditable( tcAtributo as String, tcPk as String ) as String 
		local lcRetorno as String 
		lcRetorno =   " this.ConvertirDateSql( .oEntidad.oAtributosAuditoria." + tcAtributo + ") != this.ConvertirDateSql( .oEntidad." + tcAtributo + tcPk + ")"
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarTriggerGenerico() as Void
		local i as integer, loItem as object, lcWhere as string, lcEsquema as string, lcCamposSelect as String, lcVariablesAuditoria as String
		lcWhere = ""	
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			if .lTieneAuditoria
				lcVariablesAuditoria = strtran( .cVariablesInsertAuditoriaCabecera, [<<"'" + this.FormatearTextoSql( lcDescripcionFW ) + "'">>], ;
												 "case when funciones.empty( d.DescFw ) = 1 then 'IMPORTACION' else d.descFw end" )
				lcCamposSelect = .ParsearYAgregarVariablesAuditoria( lcVariablesAuditoria, "Cabecera", 2, .t. )
			endif
			
			.agregarLinea( "Text to lcCadena noshow textmerge" , 2 )
			lcEsquema = .Obtener_SchemaSelect( .cTabla )
			.agregarLinea( "CREATE TRIGGER " + lcEsquema + "DELETE_<<lcTabla>>" , 3 )
			.agregarLinea( "ON " + lcEsquema +  "<<lcTabla>>" , 4 )
			.agregarLinea( "AFTER DELETE" , 4 )
			.agregarLinea( "As", 3 )
			.agregarLinea( "Begin", 3 )

			&& UPDATE

			if .lTieneAuditoria
				.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + .cPrefijoAuditoria + .cTabla + " ( " + .cCamposInsertAuditoria + " ) ", 4 )
				.agregarLinea( "Select " + lcCamposSelect + ", " + this.cVariablesUpdAuditoriaImportacion,  5 )
				.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 6 )
				.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
				endfor
				select( this.cCursorAtributos )
				scan all for auditoria
					lcWhere = lcWhere + " or ( d." + alltrim( Campo ) + " is not null and d." + alltrim( Campo ) + " <> t." + alltrim( Campo ) + " )"
				endscan
				.agregarLinea( "where " + substr( lcWhere, 5 ), 5 )
			endif

			.agregarLinea( "Update t Set " +  .cCamposUpdNullYDefault , 4 )
			.agregarLinea( "from " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " t inner join deleted d " , 5 )
			.agregarLinea( " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria , 7 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and  t." + alltrim( loItem.Campo ) + " = d." + alltrim( loItem.Campo ), 7 )
			endfor

			.agregarLinea( "-- Fin Updates" , 4 )
			&& FIN UPDATE

			&& INSERT

			if .lTieneAuditoria
				.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + this.cPrefijoAuditoria + this.cTabla + " ( " + this.cCamposInsertAuditoria + " ) ", 4 )
				.agregarLinea( "Select " + lcCamposSelect + ", " + this.cVariablesInsertAuditoriaImportacion ,  5 )
				.agregarLinea( "From deleted d left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " pk ", 6 )
				.agregarLinea( " on d." + .cCampoClavePrimaria + " = pk." + .cCampoClavePrimaria , 7 )
				if this.oInfoClaveCandidata.count > 0
					.agregarLinea( " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
					for i = 1 to this.oInfoClaveCandidata.count
						loItem = this.oInfoClaveCandidata.item[i]
						.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
					endfor
				endif
				.agregarLinea( "Where pk." + .cCampoClavePrimaria + " Is Null ", 6 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
				endfor
			endif

			.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + "(" + strtran( .cCamposInsert, '"', "" ) + ")" , 4 )
			.agregarLinea( "Select " + .cCamposInsertNullYDefault , 5 )
			.agregarLinea( "From deleted d left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " pk ", 6 )
			.agregarLinea( " on d." + .cCampoClavePrimaria + " = pk." + .cCampoClavePrimaria , 7 )
			if this.oInfoClaveCandidata.count > 0
				.agregarLinea( " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
				for i = 1 to this.oInfoClaveCandidata.count
					loItem = this.oInfoClaveCandidata.item[i]
					.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
				endfor
			endif
			.agregarLinea( "Where pk." + .cCampoClavePrimaria + " Is Null ", 6 )
			for i = 1 to this.oInfoClaveCandidata.count
				loItem = this.oInfoClaveCandidata.item[i]
				.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
			endfor


			.agregarLinea( "-- Fin Inserts" , 4 )
			&& FININSERT
		endwith 	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarTriggerSoloInsertar() as Void
		local i as integer, loItem as object, lcWhere as string, lcEsquema as string, lcCamposSelect as String, lcVariablesAuditoria as String
		lcWhere = ""	
		with this as GeneradorDinamicoAccesoDatosSqlServer of GeneradorDinamicoAccesoDatosSqlServer.prg
			.agregarLinea( "Text to lcCadena noshow textmerge" , 2 )
			lcEsquema = .Obtener_SchemaSelect( .cTabla )
			.agregarLinea( "CREATE TRIGGER " + lcEsquema + "DELETE_<<lcTabla>>" , 3 )
			.agregarLinea( "ON " + lcEsquema +  "<<lcTabla>>" , 4 )
			.agregarLinea( "AFTER DELETE" , 4 )
			.agregarLinea( "As", 3 )
			.agregarLinea( "Begin", 3 )
					 
			&& INSERT
			.agregarLinea( "insert into " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + "(" + strtran( .cCamposInsert, '"', "" ) + ")" , 4 )
			.agregarLinea( "Select " + .cCamposInsertNullYDefault , 5 )
			.agregarLinea( "From deleted d ", 6 )
			.agregarLinea( "-- Fin Inserts" , 4 )
			&& FININSERT
		endwith 	
	endfunc 	
	*-----------------------------------------------------------------------------------------
	protected function FuncionalidadNoLoguear() as Boolean
		return this.VerificarFuncionalidad( this.cTipo, "NOLOGUEAR" )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerIdentificadoresPaginado() as Void
		local lcCampoPK as String, lcEsquemaTabla as String
		
		.agregarLinea( "*-----------------------------------------------------------------------------------------" , 1 )
		.agregarLinea( "function ObtenerIdentificadoresPaginado( tcOrderBy as String, tcFiltro as String, tnCantidad as Integer, tnPagina as Integer )  as String" , 1 )
		.agregarLinea( "local lcOrderBy as String, lnCuantos as Integer, lnPagina as Integer, lnTope as Integer, lnDesde as Integer, lcSQL as String, lcCursor as String, lcXml as String" , 2 )

		lcCampoPK = this.cCampoClavePrimaria
		lcEsquemaTabla = this.Obtener_SchemaSelect( this.cTabla ) + this.cTabla
		
		.agregarLinea( [lcOrderBy = iif( !empty( tcOrderBy ), tcOrderBy + ",", "" ) + "] + lcCampoPK + ["] , 2 )
		.agregarLinea( [] , 2 )

		.agregarLinea( [lnCuantos = tnCantidad] , 2 )
		.agregarLinea( [lnPagina = tnPagina] , 2 )
		.agregarLinea( [lnTope = lnCuantos  * lnPagina ] , 2 )
		.agregarLinea( [lnDesde = lnCuantos  * ( lnPagina - 1 ) + 1] , 2 )
		.agregarLinea( [] , 2 )
		
		.agregarLinea( [text to lcSQL textmerge noshow] , 2 )
		.agregarLinea( [		SELECT nro,totalRegistros,] + lcCampoPK + [ as Id] , 2  )
		.agregarLinea( [		FROM ( ], 3 )
		.agregarLinea( [		    select row_number() over (Order By <<lcOrderBy>>) as nro,] , 2 )
		.agregarLinea( [		    count(1) over() as totalRegistros,] , 2 )
		.agregarLinea( [		    ] + lcCampoPK + [ from (] , 2 )
		.agregarLinea( [					select * ], 2 )
		.agregarLinea( [						from ] + lcEsquemaTabla + [ ], 2 )
		.agregarLinea( [						Where  ] + this.ObtenerFiltro( this.cTipo ) , 2 )
		.agregarLinea( [							and <<tcFiltro>>] , 2 )
		.agregarLinea( [					 ) a], 2 )
		.agregarLinea( [			 ) b], 2 )
		.agregarLinea( [			 WHERE nro between <<lnDesde>> and <<lnTope>>], 2 )
		.agregarLinea( [endtext] , 2 )
		.agregarLinea( [] , 2 )
				
		.agregarLinea( [lcCursor = sys( 2015 )] , 2 )
		.agregarLinea( [this.oConexion.EjecutarSentencias( lcSQL, "] + this.cTabla+ [", "", lcCursor, set("Datasession") )] , 2 )
		.agregarLinea( [lcXml = this.CursorAXml( lcCursor )] , 2 )
		.agregarLinea( [] , 2 )
		
		.agregarLinea( [use in select( lcCursor )] , 2 )
		.agregarLinea( [] , 2 )

		.agregarLinea( [Return lcXml ], 2 )
		.agregarLinea( [] , 2 )
				
		.agregarLinea( [endfunc] , 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerDatosEntidadPaginado() as Void
		local lcCampoPK as String, lcEsquemaTabla as String
		
		.agregarLinea( "*-----------------------------------------------------------------------------------------" , 1 )
		.agregarLinea( "function ObtenerDatosEntidadPaginado( tcOrderBy as String, tcFiltro as String, tnCantidad as Integer, tnPagina as Integer )  as String" , 1 )
		.agregarLinea( "local lcOrderBy as String, lnCuantos as Integer, lnPagina as Integer, lnTope as Integer, lnDesde as Integer, lcSQL as String, lcCursor as String, lcXml as String" , 2 )

		lcCampoPK = this.cCampoClavePrimaria
		lcEsquemaTabla = this.Obtener_SchemaSelect( this.cTabla ) + this.cTabla
		
		.agregarLinea( [lcOrderBy = iif( !empty( tcOrderBy ), tcOrderBy + ",", "" ) + "] + lcCampoPK + ["] , 2 )
		.agregarLinea( [] , 2 )

		.agregarLinea( [lnCuantos = tnCantidad] , 2 )
		.agregarLinea( [lnPagina = tnPagina] , 2 )
		.agregarLinea( [lnTope = lnCuantos  * lnPagina ] , 2 )
		.agregarLinea( [lnDesde = lnCuantos  * ( lnPagina - 1 ) + 1] , 2 )
		.agregarLinea( [] , 2 )

		.agregarLinea( [	text to lcAtributos textmerge noshow] , 2 )
		.agregarLinea( this.ObtenerCamposSelect(), 3 )
		.agregarLinea( [	endtext] , 2 )
			
		.agregarLinea( [text to lcSQL textmerge noshow] , 2 )
		.agregarLinea( [		SELECT <<lcAtributos>>] , 2  )
		.agregarLinea( [		FROM ( ], 3 )
		.agregarLinea( [		    select row_number() over (Order By <<lcOrderBy>>) as nro,] , 2 )
		.agregarLinea( [		    count(1) over() as totalRegistros,] , 2 )
		.agregarLinea( [		    * from (] , 2 )
		.agregarLinea( [					select * ], 2 )
		.agregarLinea( [						from ] + lcEsquemaTabla + [ ], 2 )
		.agregarLinea( [						Where  ] + this.ObtenerFiltro( this.cTipo ) , 2 )
		.agregarLinea( [							and <<tcFiltro>>] , 2 )
		.agregarLinea( [					 ) a], 2 )
		.agregarLinea( [			 ) b], 2 )
		.agregarLinea( [			 WHERE nro between <<lnDesde>> and <<lnTope>>], 2 )
		.agregarLinea( [endtext] , 2 )
		.agregarLinea( [] , 2 )
				
		.agregarLinea( [lcCursor = sys( 2015 )] , 2 )
		.agregarLinea( [this.oConexion.EjecutarSql( lcSQL, lcCursor, set("Datasession") )] , 2 )
		.agregarLinea( [lcXml = this.CursorAXml( lcCursor )] , 2 )
		.agregarLinea( [] , 2 )
		
		.agregarLinea( [use in select( lcCursor )] , 2 )
		.agregarLinea( [] , 2 )

		.agregarLinea( [Return lcXml ], 2 )
		.agregarLinea( [] , 2 )
				
		.agregarLinea( [endfunc] , 1 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FuncionObtenerFechaComprobanteRelacionado() as string
		lnTab = 1
		if this.VerificarFuncionalidad( this.cTipo, "MIPYME" )
			lcTabla = alltrim( this.obtenerTabla() )
			.agregarLinea( "" )
			.agregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.agregarLinea( "function ObtenerFechaComprobanteRelacionado() as string", lnTab )
			.agregarLinea( "")
			.agregarLinea( "lcRetorno = ''", lnTab + 1 )
			.agregarLinea( "lcPtoVta = alltrim( str( this.oEntidad.PuntoDeVentaCpteRelacionado ) )", lnTab + 1 )
			.agregarLinea( "lcTipoComp = alltrim( str( this.oEntidad.TipoCpteRelacionado ) )", lnTab + 1 )
			.agregarLinea( "lcNumero = alltrim( str( this.oEntidad.NumeroCpteRelacionado))", lnTab + 1 )
			.agregarLinea( "lcLetra = this.oEntidad.LetraCpteRelacionado", lnTab + 1 )
			.agregarLinea( [lcWhere = " where facttipo = " + lcTipoComp + " and fptoven =" + lcPtoVta + " and fletra = '" + lcLetra + "' and fnumcomp = " + lcNumero], lnTab + 1 )
			.agregarLinea( "lcXml = this.ObtenerDatos( 'Ffch as Fecha', '', '', '', lcWhere, '" + lcTabla + "', '', 1 )", lnTab + 1 )
			.agregarLinea( "xmltocursor(lcXml,'c_cursorFecha')", lnTab + 1 )
			.agregarLinea( "IF RECCOUNT( 'c_cursorFecha') > 0", lnTab + 1 )
			.agregarLinea( "lcRetorno = dtos(c_cursorFecha.Fecha)", lnTab + 1 )
			.agregarLinea( "endif", lnTab + 1 )
			.agregarLinea( "return lcRetorno", lnTab + 1 )
			.agregarLinea( "endfunc", lnTab )
		endif
enddefine
