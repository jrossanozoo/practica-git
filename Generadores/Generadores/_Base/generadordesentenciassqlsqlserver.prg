define class GeneradorDeSentenciasSqlSQLServer as GeneradorDeSentenciasSql of GeneradorDeSentenciasSql.prg

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaCreateTable( tcXml as String, tcXmlEstructura as string, tnCantidadSentencias as Integer, tcLineasDiferencias as String ) as String
		local lcSentencia as String, lcTabla as String, lcLogueo as String, i as Integer, lcCampo as String, loError as zooexception OF zooexception.prg,;
			lcCampos as String, lcVariables as String, lcUbicacion as String, loRetorno as Object, lcCampoAux as String
		
		this.xmlaCursor( tcXml, "c_Estructura" )
		this.xmlaCursor( tcXmlEstructura, "c_indices" )		

		lcSentencia = ""
		lcTabla = ""
		lcLogueo = ""
		lcCampos = ""
		lcSchema = ""
		lcVariables = ""
		lcUbicacion = ""
		select c_estructura
		try
			scan
				if alltrim( upper( c_Estructura.Tabla ) ) != alltrim( upper( lcTabla ) ) or alltrim( upper( c_Estructura.Esquema ) ) != alltrim( upper( lcSchema ) )
					if !empty( lcTabla )
						loRetorno = this.ProcesarTablaCreate( lnCant, lcCampos, lcUbicacion, lcTabla, lcSchema, lcLogueo, lcCampoAux )
						lcSentencia = lcSentencia + loRetorno.cSentencia
						tcLineasDiferencias = tcLineasDiferencias + chr(13) + chr(10) + loRetorno.cLineaDiferencia
						tnCantidadSentencias = tnCantidadSentencias + 1 
						lcCampos = ""
						lcLogueo = ""						
					endif
					lnCant = 0
					lcTabla = proper( alltrim( c_Estructura.Tabla ) )	
					lcSchema = proper( alltrim( c_Estructura.Esquema ) )
					lcUbicacion = proper( alltrim( c_Estructura.Ubicacion ) )		
					this.CargarClaves( lcTabla, lcSchema )
					select c_estructura
				endif
				
				lcCampoAux = proper( alltrim( c_Estructura.Campo ))
				
				lnCant = lnCant + 1 
						
				lcCampo = this.AgregarCampo()
				
				lcCampos = lcCampos + "lcVar" + transform( lnCant ) + " = '" + lcCampo + ", '" + chr(13) + chr(10)
			endscan

			if !empty( lcTabla )
				loRetorno = this.ProcesarTablaCreate( lnCant, lcCampos, lcUbicacion, lcTabla, lcSchema, lcLogueo, lcCampoAux )
				lcSentencia = lcSentencia + loRetorno.cSentencia
				tcLineasDiferencias = tcLineasDiferencias + chr(13) + chr(10) + loRetorno.cLineaDiferencia
				tnCantidadSentencias = tnCantidadSentencias + 1 
			endif		
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( "c_Estructura" )
		endtry 		

		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaAlterTable( tcXml as String, tcXmlIndices as string, tnCantidadSentencias as Integer, tcLineasDiferencias as String ) as Void
		local lcSentencia as String, lcTabla as String, lcSchema as String, lcProblema as String, lcDefault as String, ;
			lcTipoDato as String, lcEsPk as String, lcEsCC as String, llEsAlter as Boolean, lcXmlEstruc as String, lcXmlInd as String, lcCursor as String

		lcSentencia = ""
		lcTabla = ""
		lcSchema = ""
		lcCursor = sys(2015)
		this.xmlaCursor( tcXml, "c_Estructura" )
		this.xmlaCursor( tcXmlIndices, "c_indices" )		

		select c_estructura
						
		scan for !empty( c_estructura.campo )
			if alltrim( upper( lcTabla ))!= alltrim( upper( c_Estructura.Tabla )) or alltrim( upper( c_Estructura.Esquema ) ) != alltrim( upper( lcSchema ) )
				if !empty( lcTabla )
					lcSentencia = lcSentencia + this.ObtenerSentenciaEstructuraTablas( lcSchema, lcTabla )
					lcSentencia = lcSentencia + this.ObtenerSentenciaIndicesTablas( lcSchema, lcTabla )
					lcSentencia = lcSentencia + [this.Ejecutar( "funciones.spu_modificartabla '" + lcXmlEstructura + "','" + lcXmlIndices + "', '] + lcSchema + [','] + lcTabla + ['", .t. )] + chr( 13 ) + chr( 10 )
				endif

				tnCantidadSentencias = tnCantidadSentencias + 1
				lcTabla = alltrim( c_Estructura.Tabla )
				lcSchema = alltrim( c_Estructura.Esquema )
				lcSentencia = lcSentencia + "This.LoguearExterno( replicate( chr( 32 ), 6 ) + '" + this.ObtenerLineaLogueo( c_Estructura.Ubicacion, alltrim( upper( lcTabla ))) + "', 'Modificado' )" + chr(13) + chr(10)
			endif

			llEsAlter = !( isnull( c_estructura.campo_a ) or empty( c_estructura.campo_a ))

			if llEsAlter 
				lcSentencia = lcSentencia + chr( 9 ) + "This.LoguearExterno( replicate( chr( 32 ), 12 ) + 'Campo: " + alltrim( proper( c_Estructura.campo )) + "', 'Modificado' )" + chr( 13 ) + chr( 10 )					
				lcProblema = "Diferencia de estructura"
			else
				lcSentencia = lcSentencia + chr( 9 ) + "This.LoguearExterno( replicate( chr( 32 ), 12 ) + 'Campo: " + proper( alltrim( c_Estructura.campo )) + "', 'Agregado' )" + chr( 13 ) + chr( 10 )
				lcProblema = "Inexistente"
			endif

			tcLineasDiferencias = tcLineasDiferencias + chr( 13 ) + chr( 10 ) + replicate( chr( 9 ), 2 ) + ;
					"loColDiferencias.Agregar( '" + this.ObtenerLineaLogueo( c_Estructura.Ubicacion, alltrim( upper( c_Estructura.Tabla )) ) + ;
					" - Campo: " + alltrim( c_Estructura.campo ) + " - Problema: " + lcProblema + ".' )"
			
			tnCantidadSentencias = tnCantidadSentencias + 1
		endscan
		
		if !empty( lcTabla )
			lcSentencia = lcSentencia + this.ObtenerSentenciaEstructuraTablas( lcSchema, lcTabla )
			lcSentencia = lcSentencia + this.ObtenerSentenciaIndicesTablas( lcSchema, lcTabla )			
			lcSentencia = lcSentencia + [this.Ejecutar( "funciones.spu_modificartabla '" + lcXmlEstructura + "','" + lcXmlIndices + "', '] + lcSchema + [','] + lcTabla + ['", .t. )] + chr( 13 ) + chr( 10 )
		endif
						
		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaEstructuraTablas( tcEsquema as string, tcTabla as String ) as String
		local lcSentencia as String, lcCursor as String, lcXmlEstruc as String
		
		lcCursor = sys(2015)
		
		select esquema, tabla, campo, tipodato, longitud, decimales, espk, escc, esfk ;
		from c_Estructura ;
		where alltrim( upper( tcTabla ))== alltrim( upper( c_Estructura.Tabla )) ;
				and alltrim( upper( c_Estructura.Esquema ) ) == alltrim( upper( tcEsquema ) );
		into cursor &lcCursor 
		
		cursortoxml( lcCursor, "lcXmlEstruc", 3 ) 
		
		lcSentencia = "text to lcXmlEstructura noshow pretext 1+2+4+8" + chr(13) + chr(10)
		lcSentencia = lcSentencia + lcXmlEstruc + chr(13) + chr(10)			
		lcSentencia = lcSentencia + "endtext" + chr(13) + chr(10)						
		
		use in select( lcCursor )
		
		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSentenciaIndicesTablas( tcEsquema as string, tcTabla as String ) as String
		local lcSentencia as String, lcCursor as String, lcXmlIndice as String
		
		lcCursor = sys(2015)
		
		select esquema, tabla, campo, espk, escc ;
		from c_indices ;
		where alltrim( upper( tcTabla ))== alltrim( upper( c_indices.Tabla )) ;
				and alltrim( upper( c_indices.Esquema ) ) == alltrim( upper( tcEsquema ) );
		into cursor &lcCursor 
		
		cursortoxml( lcCursor, "lcXmlIndice", 3 ) 
		
		lcSentencia = "text to lcXmlIndices noshow pretext 1+2+4+8" + chr(13) + chr(10)
		lcSentencia = lcSentencia + lcXmlIndice + chr(13) + chr(10)			
		lcSentencia = lcSentencia + "endtext" + chr(13) + chr(10)						
		
		use in select( lcCursor )
		
		return lcSentencia
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	* Recibe un cursor con los campos de la tabla y arma los constraints que debe ejecutar
	protected function CrearIndicesPk_CC( tcEsquema as String, tcTabla as String ) as String
		local lcSentencias as String

		lcSentencias = ""
		tcTabla = alltrim( tcTabla )
		tcEsquema = alltrim( tcEsquema )
		with this
			if !empty( this.cCC )
				lcSentencias = lcSentencias + chr( 9 ) + "try" + chr(13) + chr(10)
				lcSentencias = lcSentencias + [This.Ejecutar( "funciones.Spu_exec_crearIndicesPKCC '] + tcEsquema + [','] + tcTabla + [', '] + this.cCC + [', 2", .t. )] + chr( 13 ) + chr( 10 )
				lcSentencias = lcSentencias + chr( 9 ) + "catch to loError" + chr(13) + chr(10)				
				lcSentencias = lcSentencias + "This.LoguearExterno( replicate( chr( 32 ), 6 ) + 'Se produjo un error al asignar las claves candidatas.' + loError.Message, 'Creado' )" + chr( 13 ) + chr( 10 )
				lcSentencias = lcSentencias + chr( 9 ) + "endtry" + chr(13) + chr(10)								
			endif

			if !empty( this.cPK )
				lcSentencias = lcSentencias + chr( 9 ) + "try" + chr(13) + chr(10)
				lcSentencias = lcSentencias + [This.Ejecutar( "funciones.Spu_exec_crearIndicesPKCC '] + tcEsquema + [','] + tcTabla + [', '] + this.cPk + [', 1", .t. )] + chr( 13 ) + chr( 10 )
				lcSentencias = lcSentencias + chr( 9 ) + "catch to loError" + chr(13) + chr(10)								
				lcSentencias = lcSentencias + "This.LoguearExterno( replicate( chr( 32 ), 6 ) + 'Se produjo un error al asignar la clave primaria.', 'Creado' )" + chr( 13 ) + chr( 10 )
				lcSentencias = lcSentencias + chr( 9 ) + "endtry" + chr(13) + chr(10)								
			endif
		endwith
		
		return lcSentencias
	endfunc

	*-----------------------------------------------------------------------------------------
	function obtenerSentenciaCreateTableTablaTrabajo( tcXml as String, tcEsquema as String, tcTablaTrabajo as String ) as Void
	***Llamamos TablaTrabajo a la tabla usada para la importacion en el sqlServer
		local lcSentencia as String, lcCampo as string
		
		this.xmlaCursor( tcXml, "c_Estructura" )

		lcSentencia = "IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID('" + ;
			tcEsquema + "." + tcTablaTrabajo + "') AND type in ('U')) DROP TABLE " + tcEsquema + "." + tcTablaTrabajo + chr(13) + chr(10)

		lcSentencia = lcSentencia + "Create Table " + tcEsquema + "." + tcTablaTrabajo + " ( " + chr( 13 ) + chr( 10 )

		lcSentencia = lcSentencia + [ "Nrolinea" numeric( 20, 0 ) null, ] + chr( 13 ) + chr( 10 )

		select c_Estructura
		scan for !empty( campo ) and !Detalle
			lcCampo = this.AgregarCampo( .t. )
			lcSentencia = lcSentencia + lower( lcCampo ) + ", " + chr( 13 ) + chr( 10 )
		endscan
		
		lcSentencia = left( lcSentencia, len( lcSentencia ) - 4 ) + " )" 

		use in select( "c_Estructura" )

		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCampo( tlEsAlter as Boolean ) as String
		local lcRetorno As String, lcTipo as string, lcTabla as String, lcTipoSql as String, ;
			llEsCampoPK as Boolean
		
		lcTipo = alltrim( upper( c_estructura.TipoDato ) )
		lcRetorno = '"' + proper( alltrim( c_estructura.Campo ) ) + '" ' 
		llEsCampoPK = this.EsCampoPK( c_estructura.Campo, lcTipo )

		lcRetorno = lcRetorno + this.ObtenerTipoDato( lcTipo ) 
		
		if lcTipo != 'A' or empty( lcTipo )
			lcRetorno = lcRetorno + this.ArmarConstraintDefault( tlEsAlter )
		endif

		if llEsCampoPK
			lcRetorno = lcRetorno + " not null"
		else
			lcRetorno = lcRetorno + " null"
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoDato( tcTipo as String ) as String
		local lcTipoSql as String, lcRetorno as String
		
		lcRetorno = ""
		
		do Case
			case tcTipo = "C"
				lcTipoSql = "char"
				lcRetorno = lcTipoSql + "( " + transform( c_estructura.Longitud ) + " ) " 
			case tcTipo = "V"
				lcTipoSql = "varchar"
				lcRetorno = lcTipoSql + "( " + transform( c_estructura.Longitud ) + " ) "
			case tcTipo = "A"
				lcRetorno = "int identity(1,1)"
			case tcTipo = "N"
				lcRetorno = "numeric( " + transform( c_estructura.Longitud ) + ", " + transform( c_estructura.Decimales ) + " ) "
			case tcTipo = "L"
				lcRetorno = "bit "
			case inlist( tcTipo , "D", "T" )
				lcRetorno = "datetime "
			case tcTipo = "M"
				lcRetorno = "varchar(max) "
			case tcTipo = "U"
				lcRetorno = "uniqueidentifier "
		EndCase
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCampoPK( tcCampo as String, tcTipo as String ) as Boolean
		return this.LaCadenaEstaContenida( tcCampo, this.cPK ) or tcTipo = "A"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function LaCadenaEstaContenida( tcCadenaBuscada as String, tcCadenaContenedora as String ) as Boolean
		return ( "," + alltrim( upper( tcCadenaBuscada ) ) + "," $ "," + upper( strtran( tcCadenaContenedora, " ", "" ) ) + ",")
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarConstraintDefault( tlEsAlter as Boolean ) as String
		local lcRetorno as String
		lcRetorno = ''
		
		if !tlEsAlter
			lcRetorno = "constraint cons_" + proper( alltrim( c_estructura.Tabla )) + "_" + proper( alltrim( c_estructura.Campo )) + " " + this.ObtenerStringValorDefault( alltrim( upper( c_estructura.TipoDato )))
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerStringValorDefault( tcTipoDato as String ) as String
		local lcDefault as String
		lcDefault = "default " + this.ObtenerValorDefault( tcTipoDato )
		return lcDefault
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorDefault( tcTipoDato as String ) as String
		local lcDefault as String
		do Case
			case inlist( upper( tcTipoDato ), "C", "V", "M", "D" )
				lcDefault = "space(0)"
			case inlist( upper( tcTipoDato ), "N", "L" )
				lcDefault = "0"
			case inlist( upper( tcTipoDato ), "U" )
				lcDefault = "newid()"
			otherwise 
				lcDefault = ""
		endcase 
		return lcDefault
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreTablaSinExtension( tcRutaTabla as String ) as Void
		return alltrim( tcRutaTabla )
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ProcesarTablaCreate( tnCant as Integer, tcCampos as String, tcUbicacion as String, tcTabla as String, tcSchema as String, tcLogueo as String, tcCampo as String ) as Custom
		local lcVariables as String, i as Integer, lcSentencias as String, lcLineasDiferencias as String, lcLineasDiferencias as Integer
		lcVariables = ""
		tcCampos = left( tcCampos , len( tcCampos ) - 5 )
		lcSentencias = ""
								
		for i = 0 to tnCant 
			lcVariables = lcVariables + "lcVar" + transform( i ) + " + "
		endfor
				
		lcVariables = left( lcVariables, len( lcVariables ) - 3 )																		
		
		if empty( tcCampo )
			lcSentencia = this.GenerarSinonimo( tcUbicacion, tcTabla, tcSchema )
		else
			lcSentencia = this.GenerarTabla( tcUbicacion, tcTabla, tcSchema, tcCampos, tcLogueo, lcVariables )
		endif

		lcLineasDiferencias = replicate( chr( 9 ), 2 ) + "loColDiferencias.Agregar( '" + this.ObtenerLineaLogueo( tcUbicacion, tcTabla, .t., empty( tcCampo )) + ".' )"
		
		loRetorno = newobject( "empty" )
		
		addproperty( loRetorno, "cSentencia", lcSentencia )
		addproperty( loRetorno, "cLineaDiferencia", lcLineasDiferencias )
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarTabla( tcUbicacion as String, tcTabla as String, tcSchema as String, tcCampos as String, tcLogueo as String, tcVariables as String ) as Void
		local lcSentencia as String
		
		lcSentencia = ""
		
		text to lcSentencia textmerge noshow pretext 2 additive 
			This.LoguearExterno( replicate( chr( 32 ), 6 ) + '<< this.ObtenerLineaLogueo( tcUbicacion, alltrim( upper( tcTabla ))) >>', 'Creado' )
			this.CrearEsquema( '<< alltrim( tcSchema ) >>' )
			lcVar0 = 'Create Table << alltrim( tcSchema ) >>.<< alltrim( upper( tcTabla ) ) >> ( '
			<<tcCampos>> ) ON [PRIMARY]'
			<< tcLogueo >>
			This.Ejecutar( << tcVariables >>, .t. )
			<< this.CrearIndicesPk_CC( tcSchema, tcTabla ) >>
			use in select( '<< juststem( tcTabla ) >>' )
			
		endtext
		
		return lcSentencia
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarSinonimo( tcUbicacion as String, tcTabla as String, tcSchema as String ) as Void
		local lcSentencia as String
		
		lcSentencia = ""
		text to lcSentencia textmerge noshow pretext 2 additive 
			This.LoguearExterno( replicate( chr( 32 ), 6 ) + '<< this.ObtenerLineaLogueo( tcUbicacion, alltrim( upper( tcTabla )), .f., .t. ) >>', 'Creado' )
			this.CrearEsquema( '<< alltrim( tcSchema ) >>' )
			lcVar0 = 'create synonym << alltrim( tcSchema ) >>.<< alltrim( tcTabla ) >> for << alltrim( upper( this.cMaster )) >>.<< alltrim( tcSchema ) >>.<< alltrim( tcTabla ) >> '
			This.Ejecutar( lcVar0, .t. )
			
		endtext
		
		return lcSentencia
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function GenerarSentenciasTriggerDeleteImportacion( tcSchema_Select as String, tcTabla as String, tcTablaDetalle as String, tcXml as String ) as Void
		local lcSentencia as String

		this.xmlaCursor( tcXml, "c_Estructura" )

		lcEsquema = tcSchema_Select 

		lcSentencia = ""
		lcSaltoLinea = chr(13) + chr(10)

		lcTablaTrabajo = "TablaTrabajo_" + tcTabla + "_" + tcTablaDetalle 

		select c_estructura
		try
		
			lcSentencia = lcSentencia + "CREATE TRIGGER " + lcEsquema + "DELETE_" + lcTablaTrabajo  + lcSaltoLinea
			lcSentencia = lcSentencia + "ON " + lcEsquema + lcTablaTrabajo + lcSaltoLinea
			lcSentencia = lcSentencia + "AFTER DELETE"  + lcSaltoLinea
			lcSentencia = lcSentencia + "As" + lcSaltoLinea
			lcSentencia = lcSentencia + "Begin" + lcSaltoLinea
			
			lcSentencia = lcSentencia + "Update t Set " + lcSaltoLinea
			
			scan
				*if alltrim( upper( c_Estructura.Tabla ) ) != alltrim( upper( lcTabla ) ) or alltrim( upper( c_Estructura.Esquema ) ) != alltrim( upper( lcSchema ) )
					
					lcCampo = upper( alltrim( c_Estructura.Campo ) )
					lcUpdate = "t." + lcCampo + " = isnull( d." + lcCampo + ", t." + lcCampo + " )"

					lcSentencia = lcSentencia + lcUpdate + iif( recno()!=recc(), ',', '' ) + lcSaltoLinea
		
				*endif
			endscan

			lcSentencia = lcSentencia + "from " + tcSchema_Select + tcTablaDetalle + " t inner join deleted d "  + lcSaltoLinea
*			lcSentencia = lcSentencia + " on t." + .cCampoClavePrimaria + " = d." + .cCampoClavePrimaria  + lcSaltoLinea
			lcSentencia = lcSentencia + " on t.CODIGO = d.CODIGO" + lcSaltoLinea

			lcSentencia = lcSentencia + "-- Fin Updates"  + lcSaltoLinea


			lcSentencia = lcSentencia + "insert into " + tcSchema_Select + tcTablaDetalle + lcSaltoLinea
			lcSentencia = lcSentencia + "( " + lcSaltoLinea

			scan
				*if alltrim( upper( c_Estructura.Tabla ) ) != alltrim( upper( lcTabla ) ) or alltrim( upper( c_Estructura.Esquema ) ) != alltrim( upper( lcSchema ) )
					
					lcCampo = upper( alltrim( c_Estructura.Campo ) )
					lcUpdate = ["]+lcCampo+["]

					lcSentencia = lcSentencia + lcUpdate + iif( recno()!=recc(), ',', '' ) + lcSaltoLinea
		
				*endif
			endscan
			
			lcSentencia = lcSentencia + " )" + lcSaltoLinea

			lcSentencia = lcSentencia + "Select " + lcSaltoLinea
			scan
				*if alltrim( upper( c_Estructura.Tabla ) ) != alltrim( upper( lcTabla ) ) or alltrim( upper( c_Estructura.Esquema ) ) != alltrim( upper( lcSchema ) )
					
					lcCampo = upper( alltrim( c_Estructura.Campo ) )
					lcUpdate = "d." + lcCampo

					lcSentencia = lcSentencia + lcUpdate + iif( recno()!=recc(), ',', '' ) + lcSaltoLinea
		
				*endif
			endscan
			
			lcSentencia = lcSentencia + "From deleted d left join " + tcSchema_Select + tcTablaDetalle + " pk "  + lcSaltoLinea
			lcSentencia = lcSentencia + " on d.CODIGO = pk.CODIGO"  + lcSaltoLinea

*			if this.oInfoClaveCandidata.count > 0
*
*				lcSentencia = lcSentencia + " left join " + .Obtener_SchemaSelect( .cTabla ) + .cTabla + " cc ", 6 )
*
*				for i = 1 to this.oInfoClaveCandidata.count
*					loItem = this.oInfoClaveCandidata.item[i]
*					.agregarLinea( iif( i = 1, " on ", " and " ) + " d." + alltrim( loItem.Campo ) + " = cc." + alltrim( loItem.Campo ), 7 )
*				endfor

*			endif
			lcSentencia = lcSentencia + "Where pk.CODIGO Is Null " + lcSaltoLinea

*			for i = 1 to this.oInfoClaveCandidata.count
*				loItem = this.oInfoClaveCandidata.item[i]
*				.agregarLinea( " and cc." + alltrim( loItem.Campo ) + " Is Null ", 7 )
*			endfor

			lcSentencia = lcSentencia + "-- Fin Inserts"  + lcSaltoLinea

			lcSentencia = lcSentencia + "End" + lcSaltoLinea
			
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		finally
			use in select( "c_Estructura" )
		endtry 		
		
				
		return lcSentencia
	
	endfunc 

enddefine
