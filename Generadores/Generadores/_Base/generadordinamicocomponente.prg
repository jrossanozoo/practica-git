define class GeneradorDinamicoComponente as GeneradorDinamico of GeneradorDinamico.prg

	#if .f.
		local this as GeneradorDinamicoComponente of GeneradorDinamicoComponente.prg
	#endif

	cPrefijo = "Componente"
	cSufijo = ""
	cNombreEntidadRelacionada = ""
	lOld = .f.
	cCursorComponente = ""

	*-----------------------------------------------------------------------------------------
	protected function GenerarCuerpoClase() as Void
		this.AgregarFuncionInicializar()
		this.AgregarEntidadRelacionada()
		this.AgregarEntidadRelacionada2()		
		This.AgregarComponentesRelacionados()
		This.AgregarFuncionDestroy()
		This.AgregarFuncionGrabar()
		This.FuncionSetearColeccionSentenciasAnterior_todas()
		This.AgregarFuncionRecibir()
		use in select( This.cCursorComponente )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarCabeceraClase() as Void
		local lcCursor as String,lcHerencia as String, lnCantidadEntidades as Integer, i as Integer, lnCantidadComponentes as Integer, lcEntida as String, lcComponente as String
		with this
			lcCursor= This.cCursorComponente 
			select( lcCursor )
			if empty( &lcCursor..Herencia )
				lcHerencia = "Componente"
			else
				lcHerencia = alltrim( &lcCursor..Herencia )
			Endif	
			.AgregarLinea( "define class Din_" + .cPrefijo + .cTipo + .cSufijo + " as " + lcHerencia + " of " + lcHerencia + ".prg" )

			scan all
				lnCantidadEntidades = getwordcount( alltrim( upper( &lcCursor..Entidad ) ),"," )
				for i = 1 to lnCantidadEntidades
					lcEntidad = getwordnum( alltrim( upper( &lcCursor..Entidad ) ), i,"," )
					.AgregarLinea( "o" + lcEntidad + " = NULL", 1 )
				endfor
			endscan
			select( lcCursor )
			scan all
				lnCantidadComponentes = getwordcount( alltrim( upper( &lcCursor..ComponentesRelacionados ) ),"," )
				for i = 1 to lnCantidadComponentes 
					lcComponente = getwordnum( alltrim( upper( &lcCursor..ComponentesRelacionados ) ), i,"," )
					.AgregarLinea( "oComp" + lcComponente + " = NULL", 1 )
				endfor
			endscan
			if !empty( .cNombreEntidadRelacionada )
				.AgregarLinea( "oEntidad = NULL", 1 )
				.AgregarLinea( "", 1 )
			endif 
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNombreArchivo as void
		with this
			.cArchivo = .cPath + "Din_" + .cPrefijo + alltrim( Proper( .cTipo ) ) + .cSufijo +".prg"
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionInicializar() as Void
		local lnTab as integer
		lnTab = 1
		with this
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
			.AgregarLinea( "Function Inicializar() as void", lnTab )
			.AgregarLinea( "dodefault()", lnTab + 1 )
			.AgregarLinea( "" )
			.AgregarLinea( "with this", lnTab + 1 )
			.LlenarCombinacion( lnTab + 2 )
			.AgregarLinea( "endwith", lnTab + 1 )
			.AgregarLinea( "endfunc", lnTab )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarCombinacion( tnTab as integer ) as Void
		local lcCursor as String
		
		with this
			lcCursor = sys( 2015 ) + "_LlenarCombinacion"
			
			select com.componente, dic.entidad, dic.atributo, dic.claveforanea, dic.TipoDato from c_componente com, c_diccionario dic ;
					where alltrim( upper( com.componente ) ) == alltrim( upper( .cTipo ) ) and ;
							alltrim( upper( com.combinacion ) ) == alltrim( upper( dic.entidad) ) and ;
							!empty( dic.clavecandidata ) ;
				into cursor ( lcCursor )
			
			if _tally > 0
				.agregarLinea( ".oCombinacion = _screen.zoo.crearobjeto( 'zooColeccion' )", tnTab )
				
				select ( lcCursor )
				scan
					.agregarLinea( ".oCombinacion.Add( '" + alltrim( &lcCursor..Atributo ) + iif( empty( &lcCursor..ClaveForanea ),"","_Pk") + "' )", tnTab )
				endscan
			endif
			
			use in select( lcCursor )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AntesDeGenerarCodigo() as Void
		local lcCursor as String

		dodefault()
	
		with this
			lcCursor = sys( 2015 ) + "_AntesDeGenerarCodigo"
			select com.combinacion, com.Entidad, com.ComponentesRelacionados, com.Herencia  from c_componente com ;
				where alltrim( upper( com.componente ) ) == alltrim( upper( .cTipo ) ) ;
				into cursor ( lcCursor )

			This.cCursorComponente = lcCursor
			
			if _tally > 0
				.cNombreEntidadRelacionada = &lcCursor..combinacion
			endif 

		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEntidadRelacionada( tcEntidad as String ) as Void
		local lcEntidad as String, lnTab as Integer, lcoEntidad as String

			lnTab = 1
			with this
				if empty( tcEntidad )
					lcEntidad = alltrim( .cNombreEntidadRelacionada )
					lcoEntidad = "oEntidad"
				else
					lcEntidad = tcEntidad
					lcoEntidad = "o" + alltrim( lcEntidad )
				EndIf	
				if !empty( lcEntidad )
					.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
					.AgregarLinea( "Function " + lcoEntidad + "_Access()", lnTab )
					.agregarLinea( "if !this.ldestroy and !vartype( this." + lcoEntidad + " ) = 'O'", lnTab + 1 )
					.agregarLinea( "this." + lcoEntidad + "= _screen.zoo.InstanciarEntidad( '" + lcEntidad + "' )", lnTab + 2 )
					.AgregarBindeosZooSession( lcoEntidad, lnTab + 2 )
					.agregarLinea( "endif", lnTab + 1 )
					.AgregarLinea( "Return this." + lcoEntidad , lnTab + 1 )
					.AgregarLinea( "EndFunc", lnTab )
					.agregarLinea( "" )
				endif 
			endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarComponentesRelacionados( ) as Void
		local lcComponente as String, lnTab as Integer, lcoComponente as String, i As Integer, lnCantidadComponentes  as Integer

		with This
			lnTab = 1
			lcCursor= This.cCursorComponente 
			select( lcCursor )
			scan all
				lnCantidadComponentes = getwordcount( alltrim( upper( &lcCursor..ComponentesRelacionados ) ),"," )
				for i = 1 to lnCantidadComponentes 
					lcComponente = getwordnum( alltrim( upper( &lcCursor..ComponentesRelacionados ) ), i,"," )
					lcoComponente = "oComp" + alltrim( lcComponente )
					.AgregarLinea( "*" + replicate( "-", 104 ), lnTab )
					.AgregarLinea( "Function " + lcoComponente + "_Access()", lnTab )
					.agregarLinea( "if !this.ldestroy and !vartype( this." + lcoComponente + " ) = 'O'", lnTab + 1 )
					.agregarLinea( "this." + lcoComponente + " = _screen.zoo.InstanciarComponente( 'Componente" + lcComponente + "' )", lnTab + 2 )
					.AgregarBindeosZooSession( lcoComponente, lnTab + 2 )
					.agregarLinea( "endif", lnTab + 1 )
					.AgregarLinea( "Return this." + lcoComponente , lnTab + 1 )
					.AgregarLinea( "EndFunc", lnTab )
					.agregarLinea( "" )
				endfor
			endscan
		endwith 			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarEntidadRelacionada2() as Void
		local lcCursor as String , lnCantidadEntidades as Integer, lcEntidad as String 

		with this
			lcCursor = This.cCursorComponente
			select ( lcCursor )
			scan all
				lnCantidadEntidades = getwordcount( alltrim( upper( &lcCursor..Entidad ) ),"," )
				for i = 1 to lnCantidadEntidades
					lcEntidad = getwordnum( alltrim( upper( &lcCursor..Entidad ) ), i,"," )
					This.AgregarEntidadRelacionada( lcEntidad )
				endfor
			endscan
		endwith
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionDestroy() as Void
		local	lnTab as Integer, lcCursor as String , lcEntidad as String, lcComponente as String, ;
				lnCantidadEntidades As Integer, i as Integer, lnCantidadComponentes as Integer
		lnTab = 1		
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab)
			.AgregarLinea( "function Destroy() as void", lntab  )
			.AgregarLinea( "" )
			.AgregarLinea( "this.lDestroy = .t.", lntab + 1 )			
			.AgregarLinea( "" )

			lcCursor = This.cCursorComponente
			select ( lcCursor )
			scan all
				lnCantidadEntidades = getwordcount( alltrim( upper( &lcCursor..Entidad ) ),"," )
				for i = 1 to lnCantidadEntidades
					lcEntidad = getwordnum( alltrim( upper( &lcCursor..Entidad ) ), i,"," )

					.AgregarLinea( "if type( 'This.o" + lcEntidad + "' ) = 'O' and !isnull( This.o" + lcEntidad + " )", lntab + 1 )
					.AgregarLinea( "this.o" + lcEntidad + ".Release()", lntab + 2 )
					.AgregarLinea( "endif", lntab + 1 )

				endfor
			endscan
			lcCursor = This.cCursorComponente
			select ( lcCursor )
			scan all
				lnCantidadComponentes = getwordcount( alltrim( upper( &lcCursor..ComponentesRelacionados ) ),"," )
				for i = 1 to lnCantidadComponentes
					lcComponente = getwordnum( alltrim( upper( &lcCursor..ComponentesRelacionados ) ), i,"," )
					.AgregarLinea( "if type( 'This.oComp" + lcComponente + "' ) = 'O' and !isnull( This.oComp" + lcComponente + " )", lntab + 1 )
					.AgregarLinea( "this.oComp" + lcComponente + ".Release()", lntab + 2 )
					.AgregarLinea( "endif", lntab + 1 )
				endfor
			endscan

			.AgregarLinea( "" )
			.AgregarLinea( "dodefault()", lntab + 1 )
			.AgregarLinea( "EndFunc", lntab )
			.AgregarLinea( "" )
				
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarFuncionGrabar() as Void
		local	lnTab as Integer, lcCursor as String , lcEntidad as String, lcComponente as String, ;
				lnCantidadEntidades As Integer, i as Integer, lnCantidadComponentes as Integer
		lnTab = 1		
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab)
			.AgregarLinea( "function Grabar() as ZooColeccion of ZooColeccion.prg", lntab  )
			.AgregarLinea( "" )
			.AgregarLinea( "Local loColeccion as ZooColeccion of ZooColeccion.Prg", lnTab + 1)
			.AgregarLinea( "loColeccion = dodefault()", lnTab + 1)
			.AgregarLineasComponentesQueGraban( lnTab + 1 )
*			.AgregarLinea( "This.AgregarColeccionAColeccion( loColeccion , Componentes hijosdodefault()", lnTab )

			.AgregarLinea( "Return loColeccion", lnTab + 1)
			.AgregarLinea( "EndFunc", lntab )
			.AgregarLinea( "" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	&&SAcar y subir a generador dinamico cuando no joda a nadie en el sprint
	protected function ObtenerArbolDeComponentes( tcCursor as String ) as Void

		select Componente as Padre, Graba, Componente as Hijo ;
			from c_Componente into cursor &tcCursor readwrite ;
			where .F.

		Select	c_Componente
		scan all
			if empty( ComponentesRelacionados )
				insert into &tcCursor ( Padre, Graba ) values ( upper( c_Componente.Componente ), c_Componente.Graba )
			else
				for i = 1 to getwordcount( alltrim( c_Componente.ComponentesRelacionados ), "," )
					lcHijo = alltrim( upper( getwordNum( alltrim( c_Componente.ComponentesRelacionados ), i, "," ) ) )
					insert into &tcCursor ( Padre, Graba, Hijo ) values ( upper( c_Componente.Componente ), c_Componente.Graba, lcHijo )
				endfor
			Endif
			Select	c_Componente	
		EndScan

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponentesQueGraban( tcCursor as String ) as Void
		local i as Integer, lcHijo as Integer, lcArbol as String
		lcArbol = sys( 2015 ) + "_ComponentesQueGraban"
		This.ObtenerArbolDeComponentes( lcArbol )

		select distinct Hijo as Componente from &lcArbol ;
			where	alltrim( upper( Padre ) ) == alltrim( upper( This.cTipo ) ) and ;
					Hijo In ( select Padre from &lcArbol where Graba ) and ;
					!empty( Hijo ) ;
			into cursor &tcCursor

		if lower(this.cTipo) = "cajero"
			Select Componente, this.ObtenerOrdenEnComponente(Componente,recno() ) as orden ;
					from &tcCursor into cursor BaseOrdenada order by 2
			select Componente from BaseOrdenada into cursor &tcCursor
		endif
		use in select( lcArbol )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarLineasComponentesQueGraban( tnTab as Integer ) as Void
		local lcCursor as String
		lcCursor = sys( 2015 ) + "_LineasComponentesQueGraban"
		This.ObtenerComponentesQueGraban( lcCursor )
		select &lcCursor
		scan all
			This.AgregarLinea( "This.AgregarColeccionAColeccion( loColeccion , This.oComp" + alltrim( &lcCursor..Componente ) + ".Grabar() )", tnTab )
			select &lcCursor
		EndScan	
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FuncionSetearColeccionSentenciasAnterior_todas() as Void
		with this
			.FuncionSetearColeccionSentenciasAnterior( "MODIFICAR" )
			.FuncionSetearColeccionSentenciasAnterior( "ANULAR" )
			.FuncionSetearColeccionSentenciasAnterior( "ELIMINAR" )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FuncionSetearColeccionSentenciasAnterior( tcEstado as String ) as Void
		local lcCursor as String, lcComponente as String, lcoComponente as String, lnIndG

		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), 1 )
			.AgregarLinea( "Function SetearColeccionSentenciasAnterior_" + upper( alltrim( tcEstado ) ) + "() as Void", 1 )
			.AgregarLinea( "" , 1 )	
			.AgregarLinea( "dodefault()" , 2 )	

			lcCursor = This.cCursorComponente 
			select( lcCursor )
			scan
				lnCantidadComponentes = getwordcount( alltrim( upper( &lcCursor..ComponentesRelacionados ) ),"," )
				for lnIndG = 1 to lnCantidadComponentes 
					lcComponente = getwordnum( alltrim( upper( &lcCursor..ComponentesRelacionados ) ), lnIndG,"," )
					lcoComponente = "oComp" + alltrim( lcComponente )
					.AgregarLinea( "this." + lcoComponente + ".SetearColeccionSentenciasAnterior_" + upper( alltrim( tcEstado ) ) + "()" , 2 )
				endfor
			endscan
			.AgregarLinea( "Endfunc", 1 )
		endwith
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarFuncionRecibir() as Void
		local lnTab as Integer, lcCursor as String , lcEntidad as String, lcComponente as String, ;
			lnCantidadEntidades As Integer, i as Integer, lnCantidadComponentes as Integer
		lnTab = 1
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "*" + replicate( "-", 104 ), lnTab)
			.AgregarLinea( "function Recibir( toEntidad as object, tcAtributoDetalle as string, tcCursorDetalle as string, tcCursorCabecera as string ) as void", lnTab  )
			.AgregarLinea( "dodefault( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )", lnTab + 1 )
			.AgregarLineasComponentesQueReciben( lnTab + 1 )

			.AgregarLinea( "endfunc", lntab )
			.AgregarLinea( "" )
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarLineasComponentesQueReciben( tnTab as Integer ) as Void
		local lcCursor as String
		lcCursor = sys( 2015 ) + "_AgregarLineasComponentesQueReciben"
		This.ObtenerComponentesQueGraban( lcCursor )
		select &lcCursor
		scan all
			This.AgregarLinea( "This.oComp" + alltrim( &lcCursor..Componente ) + ".Recibir( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )", tnTab )
			select &lcCursor
		EndScan	
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerOrdenEnComponente( tcComponente as String, tnOrden as Integer ) as Integer
		Local lnRetorno as Integer
		lnRetorno = 0
		do case
		case lower(tcComponente) = 'cuentacorrientevalores'
			lnRetorno = 701
		case lower(tcComponente) = 'ajustedecupones'
			lnRetorno = 702
		otherwise
			lnRetorno = tnOrden
		endcase
		Return lnRetorno
	EndFunc 

enddefine
