define class SerializadorFormDuros as Serializador of Serializador.prg
	#if .f.
		local this as SerializadorFormDuros of SerializadorFormDuros.prg
	#endif

	cPath = "Generados\"

	cHerencia = "zooFormDuro.vcx"

	*-----------------------------------------------------------------------------------------
	protected function AgregarCabecera( tcArchivo )			
		with this
		
		**** esto hay que descomentarlo para que herede de los forms

			if file( .oFormulario.ParentClass + ".vcx" )
				.cHerencia = .oFormulario.ParentClass + ".vcx"
			endif
			dodefault( tcArchivo )

			this.AgregarLinea( "oAspectoAplicacion = null", 1 )

		
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarCuerpo() as Void

			this.AgregarLinea( "*-----------------------------------------------------------------------------------------", 1 )
			this.AgregarLinea( "function oAspectoAplicacion_Access() as Void", 1 )
			this.AgregarLinea( [if (type("this.oAspectoAplicacion") <> "O" or isnull(this.oAspectoAplicacion))], 2 )
			this.AgregarLinea( [this.oAspectoAplicacion = _screen.zoo.CrearObjetoPorProducto("AspectoAplicacion")], 3 )
			this.AgregarLinea( "endif", 2 )
			this.AgregarLinea( "Return this.oAspectoAplicacion", 2 )
			this.AgregarLinea( "endfunc", 1 )

		this.AgregarFuncionSeteosVisuales()
		this.AgregarFuncionUnLoad()
*		this.AgregarFuncionDestroy()
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function AgregarFuncionSeteosVisuales() as VOID
		with this
			.AgregarLinea( "function SeteosVisuales() as boolean", 1 )
			.AgregarLinea( "this.ColControles = newobject('collection')", 2 )
			
			.AgregarLinea( "this.icon = this.oAspectoAplicacion.ObtenerIconoDeLaAplicacion()", 2 )

*			.AgregarLinea( "dodefault()", 2 )
			
			.GrabarControl( .oFormulario, .f., 2 )

			.AgregarLinea( .cCreacionDeSinglentons )

			.AgregarFinSeteosVisuales( 2 )

			.AgregarLinea( "" )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarFuncionUnLoad() as Void
		with this
			.AgregarLinea( "" )
			.AgregarLinea( "function unload() as Variant", 1 )
			.AgregarLinea( "local lcVar", 2 )
			.AgregarLinea( "lcVar = this.cVariableRetorno ", 2 )
			.AgregarLinea( "&lcVar = dodefault()", 2 )
			.AgregarLinea( "return &lcVar", 2 )
			.AgregarLinea( "endfunc", 1 )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarFinSeteosVisuales( tnTab as Integer ) as VOID
		with this
			.AgregarLinea( "this.AgregarBarraDeEstado()" , tnTab)
			.AgregarLinea( "" )
			.AgregarLinea( "this.MaxButton = .f.", tnTab )
			.AgregarLinea( "this.MinButton = .t.", tnTab )
			.AgregarLinea( "this.Closable = .t.", tnTab )
			.AgregarLinea( "this.ControlBox = .t.", tnTab )
			.AgregarLinea( "this.BorderStyle = 0", tnTab )
			.AgregarLinea( "this.Showtips = .t.", tnTab )
			.AgregarLinea( "this.Autocenter = .t.", tnTab )
		endwith
	endfunc	
enddefine