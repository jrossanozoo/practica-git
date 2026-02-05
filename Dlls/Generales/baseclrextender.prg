**************************************************
*-- Class Library:  c:\zoo\dlls\generales\netclrclasses.vcx
**************************************************


**************************************************
*-- Class:        baseclrextender (c:\zoo\dlls\generales\netclrclasses.vcx)
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Time Stamp:   03/02/09 03:47:02 PM
*
DEFINE CLASS baseclrextender AS custom


	Height = 78
	Width = 164
	*-- The link between VFP and the VFP IDE
	oidelink = (NULL)
	lnetpublic = .T.
	Name = "baseclrextender"
	oextender = .F.

	*-- The root dir for the files
	crootdir = .F.

	*-- Project file to compile
	cprojectfile = .F.

	*-- The  project object
	oactiveproject = .F.
	DIMENSION libs[1]


	ADD OBJECT olibs AS localobjcollection WITH ;
		Name = "oLibs"


	ADD OBJECT oservice AS baseprogrammingservice WITH ;
		Top = 31, ;
		Left = 73, ;
		Name = "oService"


	*-- Adds the tcClassLib to the search path
	PROCEDURE setclasslibrary
		LPARAMETERS m.tcLib,m.tlAdditive
		IF NOT m.tlAdditive
			THIS.Libs.RemoveAll()
		ENDIF
		m.tcLib = LOWER(m.tcLib)
		IF THIS.Libs.Find(m.tcLib,"cLibraryName") != -1
			RETURN .F.
		ENDIF
		IF "/" $ m.tcLib OR "\" $ m.tcLIb OR ":" $ m.tcLib
			IF NOT FILE(m.tcLib)
				ERROR "File not found: "+m.tcLib
				RETURN .F.
			ENDIF
		ENDIF
		LOCAL oExtender, oAssembly
		oExtender = THIS.getextender()
		*!*	oAssembly = oExtender.FindAssembly(m.tcLib)
		*!*	IF ISNULL(oAssembly)
		*!*		RETURN
		*!*	ENDIF
		LOCAL oLibInfo as basenetclasslibinfo
		oLibInfo = NEWOBJECT("basenetClassLibInfo",THIS.ClassLibrary,"",m.oExtender)
		oLibInfo.cLibraryName = m.tcLib
		*!*	oLibInfo.oAssembly = m.oAssembly
		THIS.Libs.Add(m.oLibInfo)
		RETURN .T.
	ENDPROC


	*-- Creates a net object
	PROCEDURE createclrobject
		LPARAMETERS m.tcType, m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10,m.teParam11,m.teParam12,m.teParam13,m.teParam14,m.teParam15
		LOCAL nParameters
		nParameters = PCOUNT()-1
		LOCAL oExtender, cType, cLib, i
		oextender = THIS.Getextender()
		IF ISNULL(oExtender)
			RETURN NULL
		ENDIF
		cType = STRTRAN(m.tcType,"::",".")
		m.cLib = THIS.GetContaininglib(m.cType)
		IF EMPTY(m.cLib )
			ERROR "Could not find type: "+m.tcType
			RETURN NULL
		ENDIF
		IF nParameters < 0
			ERROR 11, "Invalid parameters count"
			RETURN NULL
		ENDIF

		DO CASE
			CASE m.nParameters = 0
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType)
			CASE m.nParameters = 1
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1)
			CASE m.nParameters = 2
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2)
			CASE m.nParameters = 3
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3)
			CASE m.nParameters = 4
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4)
			CASE m.nParameters = 5
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
			CASE m.nParameters = 6
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
			CASE m.nParameters = 7
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
			CASE m.nParameters = 8
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
			CASE m.nParameters = 9
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
			CASE m.nParameters = 10
				 RETURN THIS.oExtender.CreateObject(m.cLib,m.cType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
		ENDCASE
		RETURN NULL
	ENDPROC


	PROCEDURE libs_access
		*To do: Modify this routine for the Access method
		LPARAMETERS  m.tnIndex1
		IF VARTYPE(m.tnIndex1) <> "N"
			RETURN THIS.oLibs
		ELSE
			RETURN THIS.oLibs.Data(m.tnIndex1)
		ENDIF
	ENDPROC


	PROCEDURE libs_assign
		*To do: Modify this routine for the Assign method
		LPARAMETERS m.tvValue, m.tnIndex1
		IF VARTYPE(m.tnIndex1) <> "N"
			THIS.oLibs = m.tvValue
		ELSE
			THIS.oLibs.Data(m.tnIndex1) = m.tvValue
		ENDIF
	ENDPROC


	PROCEDURE getextender
		LOCAL oCreator
		IF VARTYPE(THIS.oExtender) = "O"
			RETURN THIS.oExtender
		ELSE
			LOCAL oCreator, aFunctions(1)
			IF NOT "netclrclasses.vcx" $ LOWER(SET("Classlib"))
				SET CLASSLIB TO (THIS.ClassLibrary) ADDITIVE
			ENDIF
			= ADLLS(aFunctions)
			IF ASCAN(aFunctions,"CreateNetExtender",-1,-1,1,1) = 0
				DECLARE LONG CreateNetExtender IN "COMWrapper4Managed.dll"
			ENDIF
			oCreator = CreateNetExtender()
			IF m.oCreator = 0
				ERROR "Could not create the NET Extender Object"
				RETURN NULL
			ENDIF
			oCreator = SYS(3096,m.oCreator)
			THIS.oExtender = m.oCreator

			RETURN THIS.oExtender
		ENDIF
	ENDPROC


	*-- Creates a new object using the tcAssembly and tcClass
	PROCEDURE newclrobject
		LPARAMETERS m.tcType, m.tcAssembly, m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10
		LOCAL nParameters
		nParameters = PCOUNT()-2
		IF m.nParameters < 0
			ERROR 11, "Invalid parameters count"
			RETURN NULL
		ENDIF
		m.tcType = STRTRAN(m.tcType,"::",".")
		DO CASE
			CASE m.nParameters = 0
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,)
			CASE m.nParameters = 1
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1)
			CASE m.nParameters = 2
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2)
			CASE m.nParameters = 3
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3)
			CASE m.nParameters = 4
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4)
			CASE m.nParameters = 5
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5)
			CASE m.nParameters = 6
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6)
			CASE m.nParameters = 7
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7)
			CASE m.nParameters = 8
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8)
			CASE m.nParameters = 9
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9)
			CASE m.nParameters = 10
				 RETURN THIS.oExtender.CreateObject(m.tcAssembly,m.tcType,m.teParam1,m.teParam2,m.teParam3,m.teParam4,m.teParam5,m.teParam6,m.teParam7,m.teParam8,m.teParam9,m.teParam10)
		ENDCASE
		RETURN NULL
	ENDPROC


	*-- Loads the given tcType from the optional tcAssembly
	PROCEDURE loadtypereference
		LPARAMETERS m.tcType, m.tcAssembly
		LOCAL cLib, cType
		cLib = m.tcAssembly
		cType = STRTRAN(m.tcType,"::",".")
		IF NOT EMPTY(m.tcAssembly) AND NOT THIS.CheckAssemblyExists(m.tcAssembly)
			RETURN NULL
		ENDIF
		IF EMPTY(m.cLib)
			m.cLib = THIS.GetContaininglib(m.cType)
			IF EMPTY(m.cLib)
				RETURN NULL
			ENDIF
		ENDIF
		RETURN THIS.oExtender.LoadTypeReference(m.cLib,m.cType)
	ENDPROC


	*-- Returns the cLib wich containst the tcType
	PROCEDURE getcontaininglib
		LPARAMETERS m.tcType
		LOCAL cLib, i, cType
		cLib = ""
		cType = STRTRAN(m.tcType,"::",".")
		FOR m.i = 1 TO THIS.Libs.Count()
			IF THIS.Libs(m.i).ContainsType(m.cType)
				m.cLib = THIS.Libs(m.i).oAssembly.Location
				EXIT
			ENDIF
		ENDFOR
		RETURN m.cLib
	ENDPROC


	*-- Loads a type (System.Type) object
	PROCEDURE loadtype
		LPARAMETERS m.tcType, m.tcAssembly
		LOCAL cLib, cType
		cLib = m.tcAssembly
		m.cType = STRTRAN(m.tcType,"::",".")
		IF EMPTY(m.cLib)
			m.cLib = THIS.GetContaininglib(m.cType)
			IF EMPTY(m.cLib)
				RETURN NULL
			ENDIF
		ENDIF
		RETURN THIS.oExtender.LoadType(m.cLib,m.cType)
	ENDPROC


	*-- Compiles the active window to the tcTarget output
	PROCEDURE compileactivewindow
		LPARAMETERS m.tcTarget, m.tcOutput
		IF EMPTY(m.tcTarget)
			m.tcTarget = "library"
		ENDIF
		LOCAL lcfxtoollib, laEnv, cOutput, aCommand(1), oApp, lnWinhdl

		lcfxtoollib = SYS(2004)+"FOXTOOLS.FLL"
		IF !FILE(lcfxtoollib)
			= MESSAGEBOX("Could not find foxtools.fll")
			RETURN .F.
		ENDIF
		SET LIBRARY TO (m.lcfxtoollib) ADDITIVE

		lnWinHdl = _WONTOP()
		_wselect(lnWinHdl)

		DIMENSION laEnv[25]
		_EdGetEnv(lnWinHdl ,@laEnv)
		lcStr = _EDGETSTR(lnWinHdl , 0, laEnv(2))
		cOutput = IIF(EMPTY(m.tcOutput),laEnv(1),m.cOutput)
		IF EMPTY(m.cOutput)
			WAIT WINDOW "Can't figure out the output file" NOWAIT
			RETURN
		ENDIF
		LOCAL oUtil as objUtil, cFile
		oUtil = NEWOBJECT("localobjUtil",THIS.ClassLibrary)
		cFile = oUtil.GetTempfile("prg")
		cFile = JUSTPATH(m.cFile)+"\"+m.cOutput
		= STRTOFILE(m.lcStr,m.cFile)
		cOutput = m.cFile
		IF UPPER(m.tcTarget) == "LIBRARY"
			m.cOutput = FORCEEXT(m.cOutput,"DLL")
		ELSE
			m.cOutput = FORCEEXT(m.cOutput,"EXE")
		ENDIF
		m.cOutput = PUTFILE("Save Assembly as ",JUSTFNAME(m.cOutput),JUSTEXT(m.cOUtput))
		DIMENSION aCommand(4)
		aCommand(1) = "-target:"+m.tcTarget
		aCommand(2) = "-debug"
		aCommand(3) = "-output:"+m.cOutput
		aCommand(4) = m.cFile

		*oApp = CLRNEWOBJECT(THIS.oService.Getbindirectory()+"VFPCOMPILER.EXE","VFP.LANG.COMPILER.CommandLineApp")
		LOCAL oAssembly
		*!*	oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\comsupport.dll")
		*!*	oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\vfp.runtime.dll")
		*!*	oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\vfp.runtime3.dll")

		oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp",THIS.cRootdir+"\bin\VFPCOMPILER.EXE")
		*IF "SALVA" = LEFT(SYS(0),5)
		*	oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp","C:\Archivos de programa\MyProjects\VFPControl\VFP.Runtime\bin\Debug\VFPCOMPILER.EXE")
		*ENDIF

		oApp.Run(@aCommand)
		IF m.oApp.CompilerInfo.Errors.Count > 0
			LOCAL oForm as form
			oForm = NEWOBJECT("vfpCompilerErrorsForm",THIS.ClassLibrary,"",oApp)
			oForm.Show(1)
			RETURN
		ENDIF

		WAIT WINDOW "Compilation was successful, result is "+m.cOutput NOWAIT
	ENDPROC


	*-- If tcAssembly hast path information make sure it exists
	PROCEDURE checkassemblyexists
		LPARAMETERS m.tcAssembly
		IF "/" $ m.tcAssembly OR "\" $ m.tcAssembly
			IF FILE(m.tcAssembly)
				RETURN .T.
			ELSE
				ERROR "File: " + m.tcAssembly + " not found"
				RETURN .F.
			ENDIF
		ENDIF
		IF FILE(m.tcAssembly)
			RETURN .T.
		ENDIF
		RETURN .T.
	ENDPROC


	*-- Creates registration info
	PROCEDURE createregistrationinfo
		LOCAL oForm
		IF RECCOUNT("UserRegistrationInfo") = 0
			INSERT INTO "UserRegistrationInfo" ;
				(cPublicID) VALUES ("")
		ELSE
			GO TOP IN "UserRegistrationInfo"
		ENDIF
		oForm = NEWOBJECT("FormRegistration",THIS.ClassLibrary)
		oForm.Show()
	ENDPROC


	*-- Compiles active project or some project to .NET
	PROCEDURE compileactiveproject
		LOCAL cProjectFile
		IF _VFP.Projects.Count = 0
			cProjectFile = GETFILE("pjx","Locate project to compile")
			IF EMPTY(m.cProjectFile)
				WAIT WINDOW "Open a project first"
				RETURN .F.
			ENDIF
		ELSE
			m.cProjectFile = _VFP.ActiveProject.Name 
		ENDIF
		*_VFP.ActiveProject.Close()
		DO FORM this.crootdir+"\Forms\CompileProject.scx" WITH m.cProjectFile, THIS
	ENDPROC


	PROCEDURE crootdir_access
		*To do: Modify this routine for the Access method
		*RETURN HOME()+"tools"
		RETURN THIS.crootdir
	ENDPROC


	*-- Compiles the project
	PROCEDURE compileproject
		LPARAMETERS m.tcProjectFile, toListener
		m.cProjectFile = m.tcProjectfile
		LOCAL oTable as objTableGeneric, cMainFile, nProgCount, aProgs(1),i
		oTable = CREATEOBJECT("objTableGeneric")
		oTable.Table = m.cProjectfile
		oTable.lReadonly = .T.
		oTable.Exclusive = .F.
		oTable.Open()
		oTable.Select(.T.)
		m.cMainFile = ""
		COUNT FOR (Type $ "P,K,V" AND NOT EXCLUDE OR type $ "d") AND NOT DELETED() TO m.nProgCount 
		LOCATE FOR MainProg AND NOT DELETED()
		IF FOUND()
			cMainFile = FULLPATH(Name,m.cProjectFile)
			aProgs(1) = m.cMainFile
			i = 2
		ELSE
			i = 1
		ENDIF

		IF m.nProgCount = 0
			WAIT WINDOW "Only programs, VCX, SCX can be compiled"
			RETURN 0
		ENDIF
		DIMENSION aProgs(m.nProgCount)
		SCAN FOR (Type $ "P,K,V" AND NOT EXCLUDE OR type $ "d") AND NOT DELETED()
			IF m.cMainFile == FULLPATH(Name,m.cProjectFile)
				LOOP
			ENDIF
			DO CASE
			CASE Type $ "K,V"
				aProgs(m.i) = THIS.ConvertToProgram(FULLPATH(Name,m.cProjectFile),m.toListener.lRebuildFiles)
			CASE Type $ "d"
				aProgs(m.i) = THIS.Convertdatabasetoprogram(FULLPATH(Name,m.cProjectFile),m.toListener.lRebuildFiles)
			OTHERWISE
				aProgs(m.i) = FULLPATH(Name,m.cProjectFile)
			ENDCASE

			m.i = m.i+1
		ENDSCAN
		LOCAL aParams, aRefs(1), aResources(1), nLen
		DIMENSION aParams(5)
		aParams(1) = "-o:"+FULLPATH(ProjectSettings.cOutFile,m.tcProjectFile)
		aParams(2) = "-debug"+IIF(ProjectSettings.lDebugInfo,"+","-")
		IF ALLTRIM(ProjectSettings.cTarget) != "Web Site"
			aParams(3) = "-target:"+LOWER(ALLTRIM(ProjectSettings.cTarget))
		ELSE
			aParams(3) = "-target:"+"Library"
		ENDIF
		IF ProjectSettings.lParse
			aParams(4) = IIF(ProjectSettings.lParse,"-parse","")
		ELSE
			DIMENSION aParams(ALEN(m.aParams)-1)
		ENDIF
		IF ProjectSettings.l4Abbrev
			aParams(ALEN(m.aParams)) = "-enableabbrevs"
		ELSE
			DIMENSION aParams(ALEN(m.aParams)-1)
		ENDIF


		IF NOT EMPTY(ProjectSettings.References)
			LOCAL m.cRefs
			m.cRefs = ""
			= ALINES(aRefs,ProjectSettings.References,.T.)
			FOR i = 1 TO ALEN(aRefs)
				IF EMPTY(aRefs(m.i))
					LOOP
				ENDIF
				m.cRefs = m.cRefs+ aRefs(m.i) + CHR(13) + CHR(10)
			ENDFOR
			= ALINES(aRefs,m.cRefs,.T.)
			FOR i = 1 TO ALEN(aRefs)
				IF EMPTY(aRefs(m.i))
					LOOP
				ENDIF
				aRefs(m.i) = "-reference:"+LOWER(aRefs(m.i))
			ENDFOR
			nLen = ALEN(aParams)
			DIMENSION aParams(nLen + ALEN(aRefs))
			= ACOPY(aRefs,aParams,1,-1,nLen+1)
		ENDIF

		IF NOT EMPTY(ProjectSettings.Resources)
			= ALINES(aResources,ProjectSettings.Resources,.T.)
			FOR i = 1 TO ALEN(aResources)
				aResources(m.i) = "-resource:"+aResources(m.i)
			ENDFOR
			nLen = ALEN(aParams)
			DIMENSION aParams(nLen + ALEN(aResources))
			= ACOPY(aResources,aParams,1,-1,nLen+1)
		ENDIF
		IF NOT EMPTY(ProjectSettings.cExtras)
			= ALINES(aResources,ProjectSettings.cExtras,.T.)
			nLen = ALEN(aParams)
			DIMENSION aParams(nLen + ALEN(aResources))
			= ACOPY(aResources,aParams,1,-1,nLen+1)
		ENDIF


		nLen = ALEN(aParams)
		DIMENSION aParams(nLen + ALEN(aProgs))
		= ACOPY(aProgs, aParams, 1, -1, nLen+1)

		LOCAL oApp

		IF "SALVA" = LEFT(SYS(0),5) 
			oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp","C:\Archivos de programa\MyProjects\VFPControl\VFP.Runtime\bin\Debug\VFPCOMPILER.exe")
		ELSE
			oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp",THIS.cRootdir+"\bin\VFPCOMPILER.exe")
		ENDIF

		IF NOT ISNULL(m.toListener)
			CLRBindEvent(oApp,"BeforeStep",toListener,"BeforeStepHandler")
		ENDIF
		LOCAL oException
		oApp.Run(@aParams)
		TRY
			CLRUnBindEvents(oApp)

			GO TOP IN ProjectSettings
			IF m.oApp.CompilerInfo.Errors.Count > 0
				PUBLIC __oFormCompilerErrors as form
				__oFormCompilerErrors = NEWOBJECT("vfpCompilerErrorsForm",THIS.ClassLibrary,"",oApp)
				__oFormCompilerErrors.Show()
				RETURN
			ENDIF
			LOCAL cOutDir
			LOCAL cBinDir, cSafety
			cSafety = SET("Safety")
			SET SAFETY OFF

			cOutDir = JUSTPATH(FULLPATH(ProjectSettings.cOutFile,THIS.cProjectfile))
			WAIT WINDOW "Compilation was successful" NOWAIT
			IF ProjectSettings.lcopyrt

				cBindir = THIS.oservice.Getbindirectory()
				cOutDir = JUSTPATH(FULLPATH(ProjectSettings.cOutFile,THIS.cProjectFile))
				THIS.CopyRuntimeFiles(m.cOutDir)

			ENDIF

			IF ProjectSettings.lCopyRef
				LOCAL cFile, cRef
				FOR i = 1 TO ALEN(aRefs)
					cRef = SUBSTR(aRefs(m.i),AT(":",aRefs(m.i))+1)
					cFile = THIS.oService.GetBindirectory()+m.cRef
					IF NOT FILE(m.cFile)
						cFile = m.cRef
					ENDIF
					IF FILE (m.cFile)
						COPY FILE (m.cFile) TO (m.cOutDir)
						LOOP
					ENDIF
					WAIT WINDOW "Skipping copy of"+aRefs(m.i) NOWAIT 
				ENDFOR
			ENDIF
			IF m.cSafety = "ON"
				SET SAFETY ON
			ENDIF


		CATCH TO oException
			WAIT WINDOW "Compilation Failed" NOWAIT
		ENDTRY
	ENDPROC


	*-- Loads the project info, if not project info exists then it creates the info
	PROCEDURE loadprojectinfo
		LOCAL cFile, cXML, cXML2
		LOCAL cTable
		cFile = THIS.cProjectfile+".net"
		IF NOT FILE(m.cFile)
			LOCAL cTable
			cTable = THIS.cRootdir+"\Data\ProjectSettings.dbf"
			SELECT 0
			USE (m.cTable) NOUPDATE
			CURSORTOXML(ALIAS(),"cXML",1,0,0,"1")
			STRTOFILE(m.cXML,m.cFile)
			USE
		ENDIF
		IF NOT FILE(m.cFile)
			WAIT WINDOW "Error loading project info" NOWAIT
			RETURN .F.
		ENDIF
		LOCAL cTemp
		cTemp = SYS(2015)
		m.cXML = FILETOSTR(m.cFile)

		cTable = THIS.cRootdir+"\Data\ProjectSettings.dbf"
		SELECT 0
		USE (m.cTable) NOUPDATE
		CURSORTOXML(ALIAS(),"cXML2",1,0,0,"1")
		USE

		= XMLTOCURSOR(m.cXML,m.cTemp)
		= XMLTOCURSOR(m.cXML2,"ProjectSettings")

		IF NOT USED("projectSettings")
			RETURN .F.
		ENDIF
		SELECT "ProjectSettings"
		IF RECCOUNT(m.cTemp) > 0
			APPEND FROM DBF(m.cTemp)
		ENDIF
		USE IN (m.cTemp)
		GOTO TOP
		SET MULTILOCKS ON
		CURSORSETPROP("Buffering",5)
		IF RECCOUNT() = 0
			LOCAL cOutExe
			APPEND BLANK
			cOutExe = FORCEEXT(THIS.cProjectfile,"exe")
			cOutExe = SYS(2014,m.cOutExe,THIS.cProjectfile)
			REPLACE cOutFile WITH m.cOutExe
			REPLACE cTarget WITH "Exe"
			REPLACE lDebugInfo WITH .T.
			REPLACE lCopyRT WITH .T.
			REPLACE lCopyRef WITH .T.
			REPLACE references WITH "vfp.runtime.classes.dll"+CHR(13)+CHR(10)+ ;
					"vfp.runtime.dbc.dll"

		ENDIF
	ENDPROC


	*-- Saves the project info to the .NET file
	PROCEDURE saveprojectinfo
		LOCAL cFile, cXML
		cFile = THIS.cProjectfile +".net"
		SELECT "ProjectSettings"
		= TABLEUPDATE(.T.,.T.,"ProjectSettings")
		SELECT "ProjectSettings"
		= CURSORTOXML(ALIAS(),"cXML",1,0,0,"1")
		STRTOFILE(m.cXML,m.cFile)
		GO TOP
	ENDPROC


	*-- Converts a VCX / SCX to a Program file for the compiler
	PROCEDURE converttoprogram
		LPARAMETERS m.tcFile, tlrebuildFiles
		IF NOT FILE(m.tcFile)
			RETURN .F.
		ENDIF


		LOCAL cName, cID, oInfo1, oInfo2, OiNFO3
		cID = "_26B0TA39K"
		cName = ADDBS(JUSTPATH(m.tcFile))+"Generated_"+m.cID+"_"+JUSTFNAME(m.tcFile)
		m.cName = m.cName+".prg"
		oINfo1 = CLRCreateObject("system::io::fileInfo", m.tcFile)
		oInfo2 = CLRCreateObject("system::io::fileInfo", m.cName)
		IF UPPER(JUSTEXT(m.tcFile)) == "VCX"
			oInfo3 = CLRCreateObject("system::io::fileInfo", FORCEEXT(m.tcFile,"VCT"))
		ELSE
			oInfo3 = oInfo1
		ENDIF
		IF NOT FILE(m.cName) OR ;
			m.oInfo1.LastWriteTime.op_GreaterThanOrEqual(m.oInfo1.LastWriteTime, m.oINfo2.LastWriteTime) OR ;
			m.oInfo1.LastWriteTime.op_GreaterThanOrEqual(m.oInfo3.LastWriteTime, m.oINfo2.LastWriteTime) OR ;
			m.tlRebuildFiles

			DO (THIS.cRootdir+"\bin\CodeGenerator.app") WITH "","",.F.,"",0,.f.,.t.
			ADDPROPERTY(m.__oBrowser,"oCompilerTool")
			m.__oBrowser.oCompilerTool = CLRNewObject("vfp::lang::compiler::BinaryToProgram",THIS.cRootdir+"\bin\vfpCompilerTools.dll")
			*DO ("c:\other\vfpsource\browser\CodeGenerator.app") WITH "","",.F.,"",0,.f.,.t.
			m.__oBrowser.AddFile(m.tcFile)
			m.__oBrowser.ExportClass(.F.,m.cName)
			m.__oBrowser.Release()
		ENDIF
		RETURN m.cName
	ENDPROC


	PROCEDURE launchpageeditor
		LPARAMETERS tcFile
		DO FORM (THIS.oService.Getrootdirectory()+"forms\web-editor_ie.scx")
	ENDPROC


	*-- Runs the active program window
	PROCEDURE runactiveprogram
		LPARAMETERS m.tcTarget, m.tcOutput
		IF EMPTY(m.tcTarget)
			m.tcTarget = "exe"
		ENDIF
		LOCAL lcfxtoollib, laEnv, cOutput, aCommand(1), oApp, lnWinhdl

		lcfxtoollib = SYS(2004)+"FOXTOOLS.FLL"
		IF !FILE(lcfxtoollib)
			= MESSAGEBOX("Could not find foxtools.fll")
			RETURN .F.
		ENDIF
		SET LIBRARY TO (m.lcfxtoollib) ADDITIVE

		lnWinHdl = _WONTOP()
		_wselect(lnWinHdl)

		DIMENSION laEnv[25]
		_EdGetEnv(lnWinHdl ,@laEnv)
		lcStr = _EDGETSTR(lnWinHdl , 0, laEnv(2))
		cOutput = IIF(EMPTY(m.tcOutput),laEnv(1),m.cOutput)
		IF EMPTY(m.cOutput)
			WAIT WINDOW "Can't figure out the output file" NOWAIT
			RETURN
		ENDIF
		LOCAL oUtil as objUtil, cFile
		oUtil = NEWOBJECT("localobjUtil",THIS.ClassLibrary)
		cFile = oUtil.GetTempfile("prg")
		cFile = JUSTPATH(m.cFile)+"\"+m.cOutput
		= STRTOFILE(m.lcStr,m.cFile)
		cOutput = m.cFile
		IF UPPER(m.tcTarget) == "LIBRARY"
			m.cOutput = FORCEEXT(m.cOutput,"DLL")
		ELSE
			m.cOutput = FORCEEXT(m.cOutput,"EXE")
		ENDIF
		*m.cOutput = PUTFILE("Save Assembly as ",JUSTFNAME(m.cOutput),JUSTEXT(m.cOUtput))
		DIMENSION aCommand(4)
		aCommand(1) = "-target:"+m.tcTarget
		aCommand(2) = "-debug"
		aCommand(3) = "-output:"+m.cOutput
		aCommand(4) = m.cFile

		LOCAL aInfo(1), oColl, i, cLine, nPos
		EXTERNAL ARRAY oColl
		= ALINES(aInfo, m.lcStr)
		oColl = CREATEOBJECT("collection")
		FOR i = 1 TO ALEN(aInfo,1)
			IF LEFT(aInfo(m.i),1) = "*"
				cLine = SUBSTR(aInfo(m.i),2)
				IF NOT "#references " $ LOWER(m.cLIne)
					LOOP
				ENDIF
				nPos = AT("#references ", LOWER(m.cLIne))
				nPos = m.nPos + LEN("#references ")
				m.cLIne = ALLTRIM(SUBSTR(m.cLIne, m.nPos))
				IF NOT EMPTY(m.cLine)
					oColl.Add(m.cLine)
				ENDIF
			ENDIF
		ENDFOR
		IF m.oColl.Count > 0
			nPos = ALEN(aCommand,1)
			DIMENSION aCommand(m.nPos+ m.oColl.count+1)
			aCommand(m.nPos+1) = "-r:vfp.runtime.classes.dll"

			FOR i = 1 TO m.oColl.Count
				aCommand(m.npos+i+1) = "-r:"+m.oColl(m.i)
			ENDFOR
		ENDIF

		*oApp = CLRNEWOBJECT(THIS.oService.Getbindirectory()+"VFPCOMPILER.EXE","VFP.LANG.COMPILER.CommandLineApp")
		LOCAL oAssembly
		*!*	oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\comsupport.dll")
		*!*	oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\vfp.runtime.dll")
		*oAssembly = CLRFindAssembly(HOME()+"tools\etecnologiaNetExtender\bin\vfp.runtime.classes.dll")

		oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp",THIS.cRootdir+"\bin\VFPCOMPILER.EXE")
		*IF "SALVA" = LEFT(SYS(0),5)
		*	oApp = CLRNEWOBJECT("VFP.LANG.COMPILER.CommandLineApp","C:\Archivos de programa\MyProjects\VFPControl\VFP.Runtime\bin\Debug\VFPCOMPILER.EXE")
		*ENDIF

		oApp.Run(@aCommand)
		IF m.oApp.CompilerInfo.Errors.Count > 0
			LOCAL oForm as form
			oForm = NEWOBJECT("vfpCompilerErrorsForm",THIS.ClassLibrary,"",oApp)
			oForm.Show(1)
			RETURN
		ENDIF

		WAIT WINDOW "Compilation was successful, result is "+m.cOutput NOWAIT
		THIS.CopyRuntimeFiles(JUSTPATH(m.cOutput))
		= clrinvokestaticmethod("system::diagnostics::process",  ;
		        "start",  ;
		       m.cOutput )
	ENDPROC


	*-- Copies the runtime files to the output directory
	PROCEDURE copyruntimefiles
		LPARAMETERS cOutDir
		LOCAL cBinDir
		cBinDir = THIS.oService.Getbindirectory()
				COPY FILE (m.cBinDir+"vfp.runtime.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"vfp.runtime4.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"vfp.runtime5.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"vfp.runtime.dbc.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"CLI.Table64Layer.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"VFP.Runtime.Classes.dll") TO (m.cOutDir)
				COPY FILE (m.cBinDir+"VFPCompiler.dll") TO (m.cOutDir)
	ENDPROC


	*-- Generates a web service according to the toService info object
	PROCEDURE generatewebservice
		LPARAMETERS toInfo
		LOCAL cResult, cNameSpace
		cNameSpace = JUSTSTEM(THIS.cProjectfile)

		SET TEXTMERGE ON NOSHOW
		TEXT TO m.cResult

		USING NAMESPACE System::Web
		USING NAMESPACE System::Web::Services

		DEFINE NAMESPACE <<m.cNameSpace>>
			[WebService] ;

		ENDTEXT
		IF m.toInfo.lEnableAjaxJson
			TEXT TO m.cResult ADDITIVE
			[System::Web::Script::Services::ScriptService ] ;

			ENDTEXT
		ENDIF
		TEXT TO m.cResult ADDITIVE
			DEFINE CLASS <<ALLTRIM(m.toInfo.cWebServiceName)>> AS System::Web::Services::WebService

				[WebMethod] ;
				PROCEDURE MyWebMethod as string
				TPARAMETERS tcInfo as string
				RETURN "Hello from Fox"


			ENDDEFINE

		ENDNAMESPACE
		ENDTEXT

		LOCAL cOutFile
		cOutFile = FORCEEXT(FULLPATH(m.toInfo.cWebServiceName,THIS.cProjectfile), "prg")
		IF NOT FILE(m.cOUtFile)
			= STRTOFILE(m.cResult, m.cOutFile)
		ELSE
			MESSAGEBOX(m.cOutFile +" is not being written choose another name")
		ENDIF
		IF FILE(m.cOUtFile)
			THIS.oActiveProject.Files.Add(m.cOutFile)
		ENDIF


		cOutFile = FORCEEXT(FULLPATH(m.toInfo.cWebServiceName,THIS.cProjectfile), "asmx")

		m.cResult = ""
		TEXT TO m.cResult
		<%@ WebService Language="VFP" Class="<< m.cNameSpace+"."+ALLTRIM(m.toInfo.cWebserviceName) >>" %>
		ENDTEXT

		IF NOT FILE(m.cOUtFile)
			= STRTOFILE(m.cResult, m.cOutFile)
		ELSE
			MESSAGEBOX(m.cOutFile +" is not being written choose another name")
		ENDIF
	ENDPROC


	*-- Generates a web page
	PROCEDURE generatewebpage
		LPARAMETERS toInfo
		LOCAL cResult, cNameSpace
		cNameSpace = JUSTSTEM(THIS.cProjectfile)

		SET TEXTMERGE ON NOSHOW
		TEXT TO m.cResult

		USING NAMESPACE System
		USING NAMESPACE System::Web
		USING NAMESPACE System::Web::UI

		DEFINE NAMESPACE <<m.cNameSpace>>


		ENDTEXT
		TEXT TO m.cResult ADDITIVE
			DEFINE CLASS <<ALLTRIM(m.toInfo.cWebServiceName)>> AS VFP::Runtime::Web::VFPPage

				PROTECTED PROCEDURE Page_Load as VOID
				* Call base procedure to have ViewState handling 
				DODEFAULT()

				PROCEDURE OpenTables
				* Open tables relative to the WebApplication directory
				* And Adds tracking to deal with record repositioning

				USE (ADDBS(THIS.cDataDirectory)+"MyTable.dbf") ALIAS "MyAlias"
				THIS.TrackWorkArea("MyAlias")


			ENDDEFINE

		ENDNAMESPACE
		ENDTEXT

		LOCAL cOutFile
		cOutFile = FORCEEXT(FULLPATH(m.toInfo.cWebServiceName,THIS.cProjectfile), "prg")
		IF NOT FILE(m.cOUtFile)
			= STRTOFILE(m.cResult, m.cOutFile)
		ELSE
			MESSAGEBOX(m.cOutFile +" is not being written choose another name")
		ENDIF
		IF FILE(m.cOUtFile)
			THIS.oActiveProject.Files.Add(m.cOutFile)
		ENDIF


		cOutFile = FORCEEXT(FULLPATH(m.toInfo.cWebServiceName,THIS.cProjectfile), "html")

		IF NOT m.toInfo.lEnableAjaxJson
			m.cResult = FILETOSTR(THIS.oService.getTemplatesdirectory()+"asp.net-ajax\VFP Form.html")
		ELSE
			m.cResult = FILETOSTR(THIS.oService.getTemplatesdirectory()+"asp.net-ajax\VFP Form-Ajax.html")
		ENDIF

		m.cResult = STRTRAN(m.cResult,"eTecnologia::ClassPage",m.cNameSpace+"."+ALLTRIM(m.toInfo.cWebServiceName))

		IF NOT FILE(m.cOUtFile)
			= STRTOFILE(m.cResult, m.cOutFile)
		ELSE
			MESSAGEBOX(m.cOutFile +" is not being written choose another name")
		ENDIF
	ENDPROC


	PROCEDURE convertdatabasetoprogram
		LPARAMETERS m.tcFile, tlrebuildFiles
		LOCAL oBuilder, aInfo(1), i, cTable, m.cResult, nCount
		OPEN DATABASE (m.tcFile)  NOUPDATE SHARED
		SET DATABASE TO (m.tcfile)
		nCount = ADBOBJECTS(aInfo,"TABLE")
		m.cResult = ""
		FOR i = 1 TO m.nCount
			m.cTable = DBGETPROP(aInfo(m.i),"TABLE","Path")
			m.cTable = FULLPATH(m.cTable,m.tcFile)
			TRY
				oBuilder = CLRNewObject("vfp::runtime::data::vfpTableBuilder",THIS.oservice.getbindirectory()+"vfp.runtime.dbc.dll")
				m.cResult = m.cResult + oBuilder.BuildClass(m.cTable) + REPLICATE(CHR(13) + CHR(10),2)
			CATCH
				= MESSAGEBOX("Error creating vfptablebuilder for" +m.cTable +" in "+THIS.oservice.getbindirectory())
			ENDTRY

		ENDFOR

		LOCAL cID, cName, cSafety
		cSafety = SET("Safety")
		SET SAFETY OFF
		cID = "_26B0TA39K"
		cName = ADDBS(JUSTPATH(m.tcFile))+"Generated_"+m.cID+"_"+JUSTFNAME(m.tcFile)+".prg"
		= STRTOFILE(m.cResult,m.cName)
		IF m.cSafety = "ON"
			SET SAFETY ON
		ENDIF
		RETURN m.cName
	ENDPROC


	*-- Runs and attach to the process
	PROCEDURE runanddebug
		LPARAMETERS m.tcFile, tcArgs
		LOCAL cDir
		IF ISNULL(THIS.oIDELink) OR NOT THIS.oIDELink.lIDERunning
			cDir = ADDBS(THIS.oservice.GETRootdirectory())+"SharpDevelop\"
			*cDir = "f:\other\sharpdevelop\"
			this.oideLInk = CLRNewObject("idelink",m.cDir+"bin\vfpdevenv.exe")
			THIS.oIDELink.cAddInsDIR = m.cDir+"AddIns"
			THIS.oIDELink.cIDEBinDir = m.cDir+"bin"
			THIS.oIDELink.StartIDE(nULL)
			*WAIT WINDOW "Starting VFPDev Studio" TIMEOUT 3
		ENDIF
		TRY
			THIS.oIDELink.RunAndDebug(m.tcFile,m.tcArgs)
		CATCH
			= MESSAGEBOX("An error happened when trying to run/debug " + m.tcfile+" try again",0)
		ENDTRY
	ENDPROC


	PROCEDURE Init
		THIS.Setclasslibrary("system.dll",.T.)
		THIS.SetClasslibrary("mscorlib.dll",.T.)
		THIS.SetClasslibrary("system.xml.dll",.T.)
		THIS.SetClasslibrary("system.data.dll",.T.)
		THIS.SetClasslibrary("system.drawing.dll",.T.)
		THIS.SetClasslibrary("system.windows.forms.dll",.T.)
	ENDPROC


	*-- Goes to the home page
	PROCEDURE gotohomepage
	ENDPROC


ENDDEFINE
*
*-- EndDefine: baseclrextender
**************************************************
