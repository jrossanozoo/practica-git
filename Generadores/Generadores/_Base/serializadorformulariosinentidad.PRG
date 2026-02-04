define class serializadorformulariosinentidad as serializadorformulario of serializadorformulario.prg

	cHerencia = "zooFormulario"
	EsFormularioConLibreriaProxy = .f.

	*-----------------------------------------------------------------------------------------
	protected function AgregarAtributos() as Void
		with this
			.AgregarLinea( "oEntidad = null", 1 )
			.AgregarLinea( "ColControles = null", 1 )
			.AgregarLinea( "MinButton = .f.", 1 )
			.AgregarLinea( "" )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarCuerpo() as VOID
		with this
			.AgregarLinea( "function Init() as boolean", 1 )

			.GrabarControl( .oFormulario, .f., 2 )

			.SetearIcono()
			.SetearTitulo()

			.AgregarLinea( "" )
			.AgregarLinea( .cSeteos, 0 )

			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ActualizarColeccionControles( toControl as Object, tnTab as Integer ) as Void
	endfunc	

	*-----------------------------------------------------------------------------------------
	function ObtenerTextoOrigenDeDatos( toControl as Object ) as String
		return "null"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SerializarControl( toControl as object, tlCreaObjeto as boolean, tnTab as integer ) as Void
		local lcTabs, laItem, lcPropiedad, tcTexto, lxValor, lcClase as String, lcClasePadre as String, ;
			  lcPrg as String

		with this		
			local lcTexto, laItem, lcPropiedad, lcTabs
			
			dimension laItem(1)
			
			lcClase = upper(alltrim( toControl.Class ))
			lcClasePadre = upper(alltrim( toControl.ParentClass ))
			lcPrg = lcClase
			
			if .NoEsSingleton( lcClase, lcClasePadre )
				.AgregarLinea( "" )
				.AgregarLinea( "************* " + toControl.name + "/" + toControl.class + "/" + toControl.baseclass, tnTab )

				if tlCreaObjeto
					.AgregarCreacionDeControl( toControl, tnTab )
				endif
				
				this.ActualizarColeccionControles( toControl, tnTab )
				
				.AgregarLinea( "" )
				if upper( alltrim( toControl.baseclass ) ) # 'FORM'
					.AgregarLinea( "with ." + toControl.name, tnTab )
				else
					.AgregarLinea( "with this", tnTab )
				endif
				
				.SetearValoresPropiedadesIndispensables( toControl, tnTab+1 )
				.AgregarSeteosAntesDeSerializar( toControl, tnTab+1 )
				.AgregarLinea( "" )

				if upper(alltrim(toControl.baseclass)) # 'FORM'
					.AgregarPropiedadesNoDefinidas( toControl, tnTab+1 )
					if !inlist(upper(alltrim(toControl.baseclass)), 'LABEL','LINE','SHAPE','PAGE','PAGEFRAME') or ;
							( upper(alltrim(toControl.baseclass)) = 'LABEL' and ;
								upper(alltrim(toControl.parent.class )) = 'BOTONBUSCAR')
						.AgregarLinea( ".Enabled = .F.", tnTab+1 )
					endif
					.AgregarLinea( "" )
				endif

				.SetearValoresPropiedades( toControl, tnTab+1 )
			endif
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEventos( toControl as Object, tnTab as integer ) as void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsPropiedadDeClaseProxy( tcPropiedad as String ) as Boolean
		return .f.
	endfunc 

enddefine