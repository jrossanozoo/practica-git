define class EstructuraParametrosyRegistrosSqlServer as zoosession of zoosession.prg
	protected cEsquema as string
	cEsquema = ""

	*-----------------------------------------------------------------------------------------
	function init( tnDatasession as integer, tcEsquema as string )
		dodefault()
		this.datasessionId = tnDatasession
		this.cEsquema = tcEsquema
	endfunc

	*-----------------------------------------------------------------------------------------
	function Insertar() as Void
		this.InsertarEstructuraRegistrosCabecera()
		this.InsertarEstructuraRegistrosSucursal()
		this.InsertarEstructuraRegistrosPuesto()
		this.InsertarEstructuraRegistrosOrganizacion()
		this.InsertarEstructuraParametrosCabecera()
		this.InsertarEstructuraParametrosSucursal()
		this.InsertarEstructuraParametrosPuesto()
		this.InsertarEstructuraParametrosOrganizacion()
		this.InsertarEstructuraPuestos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraPuestos() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTOS", "ID", "A", 8, 0, "ORGANIZACION", .T., .F., this.cEsquema )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTOS", "Nombre", "C", 50, 0, "ORGANIZACION", .F., .F., this.cEsquema )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraParametrosCabecera() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "ID", "A", 8, 0, "ORGANIZACION", .T., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "Nombre", "C", 254, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )				
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "IDNODO", "N", 8, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )								
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "PROYECTO", "C", 20, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .T., "PARAMETROS" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraParametrosSucursal() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "IDCABECERA", "N", 8, 0, "SUCURSAL", .T., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "VALOR", "C", 120, 0, "SUCURSAL", .F., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "IDUNICO", "C", 38, 0, "SUCURSAL", .F., .T., "PARAMETROS" )				
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraParametrosPuesto() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDCABECERA", "N", 8, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "VALOR", "C", 120, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )				
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDPUESTO", "N", 8, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraParametrosOrganizacion() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "IDCABECERA", "N", 8, 0, "ORGANIZACION", .T., .F., "PARAMETROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "VALOR", "C", 120, 0, "ORGANIZACION", .F., .F., "PARAMETROS" )					
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .T., "PARAMETROS" )					
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraRegistrosOrganizacion() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "IDCABECERA", "N", 8, 0, "ORGANIZACION", .T., .F., "REGISTROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "VALOR", "C", 120, 0, "ORGANIZACION", .F., .F., "REGISTROS" )			
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "ORGANIZACION", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .T., "REGISTROS" )					
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraRegistrosPuesto() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDCABECERA", "N", 8, 0, "ORGANIZACION", .F., .F., "REGISTROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "VALOR", "C", 120, 0, "ORGANIZACION", .F., .F., "REGISTROS" )				
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDPUESTO", "N", 8, 0, "ORGANIZACION", .F., .F., "REGISTROS" )			
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "PUESTO", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .F., "REGISTROS" )			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraRegistrosSucursal() as Void
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "IDCABECERA", "N", 8, 0, "SUCURSAL", .T., .F., "REGISTROS" )
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "VALOR", "C", 120, 0, "SUCURSAL", .F., .F., "REGISTROS" )				
		insert into c_EstructuraAdn_sqlserver ( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "SUCURSAL", "IDUNICO", "C", 38, 0, "SUCURSAL", .F., .T., "REGISTROS" )				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InsertarEstructuraRegistrosCabecera() as Void
		insert into c_EstructuraAdn_sqlserver( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "ID", "A", 8, 0, "ORGANIZACION", .T., .F., "REGISTROS" )
		insert into c_EstructuraAdn_sqlserver( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "Nombre", "C", 254, 0, "ORGANIZACION", .F., .F., "REGISTROS" )				
		insert into c_EstructuraAdn_sqlserver( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "IDNODO", "N", 8, 0, "ORGANIZACION", .F., .F., "REGISTROS" )								
		insert into c_EstructuraAdn_sqlserver( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "PROYECTO", "C", 20, 0, "ORGANIZACION", .F., .F., "REGISTROS" )
		insert into c_EstructuraAdn_sqlserver( Tabla, Campo, TipoDato, Longitud, Decimales, Ubicacion, esPK, esCC, Esquema ) ;
			values ( "CABECERA", "IDUNICO", "C", 38, 0, "ORGANIZACION", .F., .T., "REGISTROS" )
	endfunc 
enddefine
