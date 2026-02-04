define class ColaboradorEstructuraObjeto as session
	
	cNumeroDeVersion = ""
	oEntBase = null
	oADNEntidad = null
	oSubEntidadYaEsta = null
	oSetDatos = null

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.oEntBase			= _screen.zoo.crearobjeto("Zoocoleccion")
		this.oADNEntidad		= _screen.zoo.crearobjeto("Zoocoleccion")
		this.oSubEntidadYaEsta	= _screen.zoo.crearobjeto("Zoocoleccion")
		this.oSetDatos = newobject( "AccesoDatosADN", "AccesoDatosADN.prg" )
		this.DataSessionId = this.oSetDatos.DataSessionId
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.oSetDatos = null
		use in select("ADN")
		use in select("Ent")
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function Generar() as Void
		public array lapila(1)
		lapila(1) = "#"
		public cEntVirtuales as String
		cEntVirtuales = ""

		select S.Entidad, S.dominio, S.ClaveForanea as ClaveForanea, NVL(E.VersionMinimaDeRecepcion,"") as VersionMinimaDeRecepcion, NVL(E.VersionMinimaDeEmision,"") as VersionMinimaDeEmision, NVL(E.tipo,"") as tipo, "0" as Indice from c_diccionario as S;
			 left join c_Entidad as E on upper(S.entidad)=upper(E.entidad) ;
			 left join c_dominio as D on upper(S.dominio)=upper(D.dominio) ;
			 where D.detalle and left(upper(S.Entidad),4)!="ADT_" ;
			 order by S.entidad,S.dominio ;
			 into cursor StructDetalle readwrite

		select S.Entidad, S.dominio, S.ClaveForanea as ClaveForanea, NVL(E.VersionMinimaDeRecepcion,"") as VersionMinimaDeRecepcion, NVL(E.VersionMinimaDeEmision,"") as VersionMinimaDeEmision, NVL(E.tipo,"") as tipo, "1" as Indice from c_diccionario as S;
			 left join c_Entidad as E on upper(S.entidad)=upper(E.entidad) ;
			 where !empty(S.claveforanea) and !empty(S.campo) and left(upper(S.Entidad),4)!="ADT_" ;
			 order by S.entidad,S.claveforanea ;
			 into cursor StructSubEntidad readwrite
			 
		select upper(c1.descripcion) as entidad, "" as Dominio, upper(c2.descripcion) as claveforanea, E.VersionMinimaDeRecepcion, E.VersionMinimaDeEmision, E.tipo, "3" as Indice from c_relacomprobantes as r ;
			left join c_comprobantes as c1 on r.idcomp=c1.id ;
			left join c_comprobantes as c2 on r.idcompafectado=c2.id;
			left join c_entidad as E on upper(c2.descripcion)=upper(E.entidad);
			order by c1.descripcion,c2.descripcion ;
			into cursor StructEnBasea

		* Las entidades que no tienen subentidades o detalle dependientes de la misma
		select Entidad,"" as dominio,"" as ClaveForanea, NVL(VersionMinimaDeRecepcion,"") as VersionMinimaDeRecepcion, NVL(VersionMinimaDeEmision,"") as VersionMinimaDeEmision, NVL(tipo,"") as tipo, "8" as Indice from (;
			select distinct D.*,E.VersionMinimaDeRecepcion,E.VersionMinimaDeEmision,E.tipo from c_diccionario as D ;
				left join c_Entidad as E on upper(D.entidad)=upper(E.entidad) ;
			) as T ;
			where T.entidad not in ( select entidad from StructDetalle ) and T.entidad not in ( select entidad from StructSubEntidad ) ;
			group by T.Entidad ;
			into cursor StructSolas

		select * from StructDetalle union ( select * from StructSubEntidad ) into cursor StructFull readwrite
		select * from StructFull union ( select * from StructEnBasea ) into cursor StructFull readwrite
		select * from StructFull union ( select * from StructSolas ) order by entidad,indice into cursor StructFull readwrite
		
		select StructFull
		index on entidad	tag entidad
		set order to entidad
		
		select distinct S.entidad,S.tipo from StructFull as S group by S.Entidad into cursor tpila
		select tpila
		
		do while !eof()
			lsEntidad = alltrim( entidad )
			this.AgregarEn( this.oEntBase, lsEntidad )
			select tpila
			skip
		enddo

		select tpila
		go top
		do while !eof()
			lsEntidad = upper( alltrim( Entidad ) )
			if Tipo="E"
				this.AgregarAPila( lsEntidad )
				this.oSubEntidadYaEsta.remove(-1)
				do while this.CantidadDePila()>1
					lsSubEnt = this.LeerPila()
					select StructFull
					if seek( lsSubEnt )
						if this.oSubEntidadYaEsta.GetKey( lsSubEnt ) = 0
							this.ArmarXML( lsEntidad, lsSubEnt )
							select StructFull
							do while !eof() and lsSubEnt==alltrim( Entidad )
								lcIndice = iif( left(upper(dominio),7) == "DETALLE", alltrim(substr(dominio,8)), alltrim(claveforanea))
								lcIndice = upper( lcIndice )
								if lcIndice != ""
									this.AgregarAPila( lcIndice )
								endif
								select StructFull
								skip
							enddo
						endif
					else
						if at( lsSubEnt+",", cEntVirtuales ) = 0
							cEntVirtuales = cEntVirtuales + lsSubEnt + "," + chr(13) + chr(10)
						endif
					endif
				enddo
				lcDepe = ""
				for subind=1 to this.oSubEntidadYaEsta.Count
					lcDepe = lcDepe + ", '" + this.oSubEntidadYaEsta.item[subind].nombre + "'"
				endfor
				with this.oADNENtidad.item( lsEntidad )
					.dependencias = substr( lcDepe, 3 )
					.xml = this.FirmaDeProyecto( .xml )
				endwith
			endif
			select tpila
			skip
		enddo
		use in select("StructDetalle") 
		use in select("StructSubEntidad") 
		use in select("StructSolas") 
		use in select("StructEnBasea") 
		use in select("StructFull")
		use in select("Tpila") 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarEn( toColeccion as zoocoleccion OF zoocoleccion.prg, tcEntidad ) as Void
		local loItem as Object, lpaso as Boolean
		local lcYaEstan as String
		lcYaEstan = ""
		tcEntidad = upper( alltrim( tcEntidad ) )
		select StructFull
		if seek( tcEntidad )
			if this.oEntBase.GetKey( tcEntidad ) = 0
				loItemEnt = createobject("DataEntidad")
				loItemEnt.nombre = tcEntidad
				loItemEnt.xml = this.StringRama( alltrim( tcEntidad ), alltrim( StructFull.VersionMinimaDeRecepcion ), alltrim( StructFull.VersionMinimaDeEmision ) )
				this.oEntBase.Agregar( loItemEnt, tcEntidad )
			endif
			select StructFull
			do while !eof() and tcEntidad==alltrim( upper( Entidad ) )
				lcAtributo = iif( left(upper(dominio),7) == "DETALLE", strtran(alltrim(upper(dominio)),"DETALLE",""), alltrim(claveforanea))
				if lcAtributo != "" and at(","+lcAtributo+",",lcYaEstan)=0
					with this.oEntBase.item( tcEntidad )
						.xml = .xml + this.StringHoja( alltrim( lcAtributo ) )
					endwith 
					lpaso = .t.
					lcYaEstan = lcYaEstan + ","+lcAtributo+","
				endif
				skip
			enddo
			with this.oEntBase.item( tcEntidad )
				if lpaso
					.xml = .xml + chr(9) + "</Entidad>" + chr(13) + chr(10)
				else
	 				.xml = strtran(.xml ,">","/>")
				endif
			endwith
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function StringRama(tcEntidad, tcV1, tcV2, tlSinHojas ) as String 
		return chr(9) + '<Entidad Nombre="' + upper( tcEntidad ) + '" VersionMinimaDeRecepcion="' + tcV1 + '" VersionMinimaDeEmision="' + tcV2 + '"' + iif( tlSinHojas, '/', '' ) + '>' + chr(13) + chr(10)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function StringHoja(tcEntidad ) as String 
		return chr(9) + chr(9) + '<EntidadesHojas Nombre="' + upper( tcEntidad ) + '"/>' + chr(13) + chr(10)
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function FirmaDeProyecto( tcXml ) as String
		local lcString as String
*		lcString = '<EstructuraEntidades Version="' + _Screen.zoo.App.ObtenerVersion() + '" Proyecto="' + _screen.zoo.App.ObtenerNombreProyecto() + '" Producto="' + _screen.zoo.App.ObtenerNombre() + '">' + chr(13) + chr(10)
		lcString = '<EstructuraEntidades Version="' + this.cNumeroDeVersion + '" Proyecto="' + _screen.zoo.App.ObtenerNombreProyecto() + '" Producto="' + _screen.zoo.App.ObtenerNombre() + '">' + chr(13) + chr(10)
		lcString = lcString + tcXml 
		lcString = lcString + '</EstructuraEntidades>' + chr(13) + chr(10)
		return lcString
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CantidadDePila() as integer
		return alen(lapila,1)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LeerPila() as String
		local lValor as String, lnCant as Integer
		lnCant = this.CantidadDePila()
		lValor = lapila( lnCant )
		dimension lapila( lnCant-1 )
		return lValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarAPila( tcValor ) as Void
		local lnCant as Integer
		lnCant = this.CantidadDePila()+1
		dimension lapila( lnCant )
		lapila( lnCant ) = tcValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarXML( tcPadre, tcEntidad ) as Void
		tcEntidad = upper(tcEntidad)
		if this.oSubEntidadYaEsta.GetKey( tcEntidad ) = 0
			loItem = createobject("DataEntidad")
			loItem.nombre = tcEntidad
			this.oSubEntidadYaEsta.Agregar( loItem, tcEntidad )
			if this.oADNEntidad.GetKey( tcPadre ) = 0
				loItemEnt = createobject("DataEntidad")
				loItemEnt.nombre = tcEntidad
				loItemEnt.xml = this.oEntBase.item( tcEntidad ).xml
				this.oADNEntidad.Agregar( loItemEnt, tcPadre )
			else
				with this.oADNEntidad.item( tcPadre )
					.xml = .xml + this.oEntBase.item( tcEntidad ).xml
				endwith
			endif
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerEnCursores() as Void
		local oItem as Object
		select 0 
		create cursor Ent ( codigo C(40), xml M)
		index on codigo	tag codigo
		set order to codigo
		create cursor ADN ( codigo C(40), xml M, dependencias M, oldxml M, CantDepe N(4))
		index on codigo	tag codigo
		set order to codigo
		select Ent
		for each oItem in this.oEntBase
			append blank
			replace codigo	with oItem.nombre
			replace xml		with oItem.xml
		endfor
		select Adn
		for each oItem in this.oADNEntidad
			append blank
			replace codigo			with oItem.nombre
			replace xml				with oItem.xml
			replace dependencias	with oItem.dependencias
			replace CantDepe		with GetWordCount(dependencias,",")
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarTodo() as Void
		this.VerEnCursores()
		for each oItem in this.oADNEntidad
			this.VerificarEntidad( alltrim( oItem.nombre ) )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarEntidad( tcEntidad )
		local lcNoEstan as String, lcNoCoinciden as String, tcEntidad as String, lfile as String
		local ObjetoViejo as Object, Yu as Integer, nInicia as Integer
		local lcLoqueBusco as String, lcQueComparar as String, lcSubEntidad as String
		set memowidth to 1024
		tcEntidad = upper( tcEntidad )
		lcNoCoinciden = ""
		lcNoEstan = ""
		lfile = "din_transferencia"+tcEntidad+"objeto.prg"
		if file(lfile,1)
			ObjetoViejo = _screen.zoo.crearobjeto(strtran(lfile,".prg",""),lfile)
			select Adn
			if seek( tcEntidad )
				replace oldxml	with ObjetoViejo.ObtenerADNEntidad()
				for Yu=1 to GetWordCount(dependencias,",")
					lcSubEntidad = chrtran(alltrim(GETWORDNUM(dependencias, Yu,",")),"'","")
					lcLoqueBusco = this.oEntBase.item(lcSubEntidad).xml
					nInicia = at(lcLoqueBusco,oldxml)
					if nInicia>0
						replace oldxml with strtran(oldxml,lcLoqueBusco,"")
					else
						nInicia = at(mline(lcLoqueBusco,1),oldxml)
						if nInicia>0
							lcQueComparar = substr(oldxml,nInicia,len(lcLoqueBusco))
							if this.CheckSum( lcLoqueBusco ) = this.CheckSum( lcQueComparar )
								replace oldxml with strtran(oldxml,lcQueComparar,"")
							else
								lcNoCoinciden = lcNoCoinciden +", "+ lcSubEntidad + str(this.CheckSum( lcLoqueBusco ))+" : "+str(this.CheckSum( lcQueComparar ))
							endif
						else
							lcNoEstan = lcNoEstan +", "+ lcSubEntidad
						endif
					endif
				endfor
			endif
			replace oldxml	with oldxml+chr(13)+chr(10)+"No coinciden"+chr(13)+chr(10)+lcNoCoinciden+chr(13)+chr(10)+"No estan"+chr(13)+chr(10)+lcNoEstan
			ObjetoViejo.release
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CheckSum( tcString ) as Void
		local lnRetorno as Integer, upo as Integer
		lnRetorno = 0
		for upo=1 to len(tcString)
			lnRetorno = lnRetorno + asc( substr( tcString, upo, 1 ) )
		endfor
		return lnRetorno
	endfunc 

enddefine

define class DataEntidad as custom
	nombre = ""
	xml = ""
	dependencias = ""
enddefine
