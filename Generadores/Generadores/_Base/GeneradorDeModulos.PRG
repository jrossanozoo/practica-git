define class GeneradorDeModulos as GeneradorEstructuraDeModulosV2 of GeneradorEstructuraDeModulosV2.prg

	cXml = ""
	cStringConnection = ""

	*-----------------------------------------------------------------------------------------
	function CleanUp() as void
		delete file (this.cXml)
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarObjetosConModulosHaciaZL( oParent ) as integer
		local lnConn as Number, loError as Exception, loCollDetalle as Object, lcMensajeError AS String, lnRetVal as Integer
		local lloguear as Boolean
		lnConn = 0
		lnRetVal = 0
		lloguear = pemstatus(oParent,"oSqlRepository",5) and !isnull(oParent.oSqlRepository)
		try
			if lloguear 
				loCollDetalle = oParent.oSqlRepository.CrearDetalle( "", "ActModZL" )
			endif

			lnConn = this.AbrirConexionSQL()
			lnRetVal = this.EjecutarSP_InsertarDatosEnEntidadENTLISTEXPPRODUCTOS( lnConn )

			if lnRetVal < 0
				local array aerrores[01]
				=aerror(aerrores)

				lcMensajeError = "Nro. error: " + transform(aerrores[01]) + " - Mensaje: " + transform(aerrores[02])
				
				if lloguear 
					oParent.oSQLRepository.GrabarErrorEnDetalle( loCollDetalle , lcMensajeError  )
					oParent.oSQLRepository.MarcarDetalleEnRojo( loCollDetalle )
					oParent.oSQLRepository.FinalizarDetalle( loCollDetalle )
				endif
			else
				if lloguear 
					oParent.oSQLRepository.FinalizarDetalle( loCollDetalle )
				endif
			endif
		catch to loError
			lcMensajeError = oParent.DesgloseError( loError )
			if lloguear 
				oParent.oSQLRepository.ModificarDetalle( loCollDetalle , 4, lcMensajeError )
				oParent.oSQLRepository.FinalizarDetalle( loCollDetalle )
			endif
		finally
			this.CerrarConexionSQL( lnConn )
		endtry

		return lnRetVal
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarObjetosConModulosDesdeZL( oParent, tcProyecto ) as Void
		local lnConn as Number, lcCursorCompletoDeModulosDesdeZL as String, lcCursorCompletoDeModulosConEquivalencias as String, ;
			lcCursorCompletoDeModulosConEquivalenciasFinal as String, lnSelect as Integer, loCollDetalle as Object, lcMensajeError  as String, lcMensaje as String
		local llDevuelvo as Boolean, lloguear as Boolean
		llDevuelvo = .t.
		lloguear = pemstatus(oParent,"oSqlRepository",5) and !isnull(oParent.oSqlRepository)
		with this
			try
				if lloguear
					loCollDetalle = oParent.oSqlRepository.CrearDetalle( "", "ActProdMod" )
				endif
				
				set datasession to (this.DataSessionId)
				
				if goServicios.Modulos.EsProductoModularizado()
					&& Conectamos al ZL
					lnConn = .AbrirConexionSQL()

					&& Obtenemos un cursor completo con las asignaciones de módulos
					lcCursorCompletoDeModulosDesdeZL = .ObtenerCursorCompletoDeModulosDesdeZL( lnConn )

					&& Cerramos la conexión
					.CerrarConexionSQL( lnConn )

					&& Creamos un objeto con los módulos del proyecto
					.CrearListaModulos()

					&& Al cursor completo le agregamos las equivalencias de los módulos
					lcCursorCompletoDeModulosConEquivalencias = .AgregarEquivalenciasDeModulos( lcCursorCompletoDeModulosDesdeZL )

					&& Procesamos el cursor para obtener un registro por objeto con sus módulos concatenados
					lcCursorCompletoDeModulosConEquivalenciasFinal = .ProcesarCursorUnSoloRegistroPorObjeto( lcCursorCompletoDeModulosConEquivalencias )

					&& Procesamos los módulos en la tabla Entidad del ADN
					.ProcesarModulosEnTablaEntidad( lcCursorCompletoDeModulosConEquivalenciasFinal )

					&& Procesamos los módulos en la tabla Listados del ADN
					.ProcesarModulosEnTablaListados( lcCursorCompletoDeModulosConEquivalenciasFinal )

					&& Procesamos los módulos en la tabla MenuPrincipal del ADN
					.ProcesarModulosEnTablaMenuPrincipal( lcCursorCompletoDeModulosConEquivalenciasFinal )

					&& Procesamos los módulos en la tabla MenuPrincipalItems del ADN
					.ProcesarModulosEnTablaMenuPrincipalItems( lcCursorCompletoDeModulosConEquivalenciasFinal )
				endif

				if lloguear
					oParent.oSQLRepository.FinalizarDetalle( loCollDetalle )
				endif
				
			catch to loError
				llDevuelvo = .f.
				lcMensajeError = oParent.DesgloseError( loError )

				if lloguear
					oParent.oSQLRepository.GrabarErrorEnDetalle( loCollDetalle , lcMensajeError  )
					oParent.oSQLRepository.MarcarDetalleEnRojo( loCollDetalle )
					oParent.oSQLRepository.FinalizarDetalle( loCollDetalle )
				endif

			finally
				.CerrarCursor( lcCursorCompletoDeModulosDesdeZL )
				.CerrarCursor( lcCursorCompletoDeModulosConEquivalencias )
				.CerrarCursor( lcCursorCompletoDeModulosConEquivalenciasFinal )
			endtry
		endwith
		
		&& Dejo el Data Session donde estaba
		if pemstatus(oParent,"DataSessionId",5)
			set datasession to (oParent.DataSessionId)
		endif
		return llDevuelvo
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AbrirConexionSQL() as Number
		local lnConn as Number, loex as Exception

		lnConn = SQLStringConnect( this.cStringConnection )
		
		if lnConn <= 0
			loex = newobject(  "exception" )
			loex.message = "No se pudo establecer conexión con la base de datos de ZL."
			loex.details = loex.message
			throw loEx
		endif

		return lnConn
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarConexionSQL( tnConn as Number ) as Void
		local lnConn as Number

		lnConn = tnConn
		if lnConn > 0
			SQLDisconnect( lnConn )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EjecutarSP_InsertarDatosEnEntidadENTLISTEXPPRODUCTOS( tnConn as Number ) as integer
		local lnConn as Number, lcDetalleModulos as String, lcSQL as String, lnRetVal as Integer

		lnConn = tnConn
		lcDetalleModulos = filetostr( this.cXml )
		lcSQL = "exec [ZL].[SP_InsertarDatosEnEntidadENTLISTEXPPRODUCTOS] '" + padl( _screen.zoo.app.cproducto, 4, "0" ) + "', " + lcDetalleModulos
		lnRetVal = SQLExec( lnConn, lcSQL, "" )
		return lnRetVal
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EjecutarSP_InsertarDatosEnEntidadASIGMODAENTLISTEXP( tnConn as Number ) as Void
		local lnConn as Number, lcXml as String, lcDetalleModulos as String, lcSQL as String

		lnConn = tnConn
		if this.ASIGMODAENTLISTEXPNoTieneDatos( lnConn )
			lcXml = "C:\Zoo\" + upper( alltrim( _screen.zoo.app.cproyecto ) ) + "\Ayuda\ModulosAsig.XML"
			lcDetalleModulos = filetostr( lcXml )
			lcSQL = "exec [ZL].[SP_Insertar_Datos_En_Entidad_ASIGMODAENTLISTEXP_Por_Unica_Vez] '" + padl( _screen.zoo.app.cproducto, 4, "0" ) + "', " + lcDetalleModulos
			SQLExec( lnConn, lcSQL, "" )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ASIGMODAENTLISTEXPNoTieneDatos( tnConn as Number ) as Boolean
		local lnConn as Number, llRetorno as Boolean, lcCursor as String, lcSQL as String

		llRetorno = .t.
		lnConn = tnConn
		lcCursor = "C" + sys( 2015 )
		lcSQL = "select * from ZL.ASIGMODULOS"
		SQLExec( lnConn, lcSQL, lcCursor )

		if used( lcCursor ) and reccount( lcCursor ) > 0
			llRetorno = .f.
		endif
		use in select( lcCursor )

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorCompletoDeModulosDesdeZL( tnConn as Number ) as String
		local lnConn as Number, lcCursor as String, lcSQL as String, lnRetorno as Integer, loEx as Exception

		lnConn = tnConn
		lcCursor = "C" + sys( 2015 )
		lcSQL = "select d.CODMODU, e.OBJETO, e.TIPOMOD, '          ' as LETRAMODU, '                                                    ' as MODULOS, 0 as C " + ;
				"from ZL.ENTPROD e " + ;
				"inner join ZL.ASIGMODULOS a on a.CODIGO = e.CODIGO and a.NUMERO in (select max(NUMERO) as NUMERO from ZL.ASIGMODULOS group by CODIGO) " + ;
				"inner join ZL.DETASIGMOD d on d.CODMOD = a.NUMERO " + ;
				"where e.PRODUCTO = '" + padl( _screen.zoo.app.cproducto, 4, "0" ) + "' order by e.OBJETO, d.CODMODU"
		lnRetorno = SQLExec( lnConn, lcSQL, lcCursor )

		if lnRetorno < 0
			loEx = newobject("Exception")
			loex.Message = "Existe un error de permisos o conexión al ejecutar sentencia"
			throw loex
		endif 

		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEquivalenciasDeModulos( tcCursor as String ) as String
		local loModulos as zoocoleccion of zoocoleccion.prg, loItem as Object

		loModulos = this.oModulos
		select( tcCursor )
		for each loItem in loModulos foxobject
			replace &tcCursor..LetraModu with alltrim( loItem.cLetra ) for &tcCursor..CodModu == alltrim( loItem.cCodigoDeModuloEnZl )
		endfor

		return tcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarCursorUnSoloRegistroPorObjeto( tcCursor as String ) as String
		local lcCursor as String, lcObjeto as String, lcModulos as String

		lcCursor = "C" + sys( 2015 )
		lcObjeto = ""
		lcModulos = ""

		select( tcCursor )
		go top
		scan
			if lcObjeto <> &tcCursor..Objeto
				lcObjeto = &tcCursor..Objeto
				lcModulos = ""
			endif
			replace &tcCursor..Modulos with alltrim( lcModulos ) + alltrim( &tcCursor..Letramodu )
			lcModulos = &tcCursor..Modulos
			replace &tcCursor..C with len( alltrim( lcModulos ) )
		endscan

		select &tcCursor..Objeto, &tcCursor..Tipomod, &tcCursor..Modulos ;
		from ( tcCursor ) ;
		inner join ( select Objeto, max( C ) as C from ( tcCursor ) group by Objeto, Tipomod ) s on s.Objeto = &tcCursor..Objeto and s.C = &tcCursor..C ;
		into cursor ( lcCursor )

		use in select( tcCursor )

		return lcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarModulosEnTablaEntidad( tcCursor as String ) as Void
		update e set e.Modulos = "" from c_Entidad  e
		update e set e.Modulos = alltrim( i.Modulos ) from c_Entidad e inner join ( tcCursor ) i on upper(alltrim(i.Objeto)) == upper(alltrim(e.Entidad)) where i.Tipomod = "EN"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarModulosEnTablaListados( tcCursor as String ) as Void
		update e set e.Modulos = "" from c_Listados e
		update e set e.Modulos = alltrim( i.Modulos ) from c_Listados e inner join ( tcCursor ) i on upper(alltrim(i.Objeto)) == upper(alltrim(e.Id)) where i.Tipomod = "LI"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarModulosEnTablaMenuPrincipal( tcCursor as String ) as Void
		update e set e.Condicion = strtran( e.Condicion, substr( e.Condicion, at( "@", e.Condicion, 1 ), at( "@", e.Condicion, 2 ) - at( "@", e.Condicion, 1 ) + 1 ), ".T." ) + iif(empty( e.Condicion ), "", " and ") + "@" + alltrim( i.Modulos ) + "@" from c_MenuPrincipal e inner join ( tcCursor ) i on val( i.Objeto ) == e.Id where i.Tipomod = "MN"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProcesarModulosEnTablaMenuPrincipalItems( tcCursor as String ) as Void
		update e set e.Condicion = strtran( e.Condicion, substr( e.Condicion, at( "@", e.Condicion, 1 ), at( "@", e.Condicion, 2 ) - at( "@", e.Condicion, 1 ) + 1 ), ".T." ) + iif(empty( e.Condicion ), "", " and ") + "@" + alltrim( i.Modulos ) + "@" from c_MenuPrincipalItems e inner join ( tcCursor ) i on val( i.Objeto ) == e.Id where i.Tipomod = "MI"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CerrarCursor( tcCursor as String ) as Void
		if vartype( tcCursor ) == "C" and used( tcCursor )
			use in select( tcCursor )
		endif
	endfunc
enddefine