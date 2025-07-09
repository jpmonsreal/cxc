#include "dbedit.ch"
#include "SetCurs.Ch"
#include "std.ch"
#include "set.ch"
#include "inkey.ch"
#include "Box.ch"
#include "c2w.ch"

procedure cxc10

Local   ENT:=1,OPZ,ONT:=ENT:=1,regs,XREC,ara:={},opc
private FLAG:=.F.,nomevar,nomecamp,mfecha3:=pdate,xclave
PRIVATE cALIAS,paso,PUERTA := .F.,mactual


SELE A

USE (ARCHIVO) ALIAS CLI SHARED new
 IF neterr()
    alert("ARCHIVO EN USO ")
    RETURN
 ENDIF
CLI->(Ordsetfocus("nombre"))
 
 
 rtipo := " ENTIDADES  DEUDORAS  "

@ 1, 12 SAY  " MANTENIMIENTO ENTIDADES       "  

PUERTA=.F.

  cALIAS:=Select()

 paso:=1   //VER FUNCIONES TBROSE

  CXC10BR()

  RETURN


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STATIC PROCEDURE MODIFICA10(RECORX)
LOCAL cBotaoNovo   := .t.
LOCAL cBotaoGravar := .t.
LOCAL cBotaoSair  := .t.
local cBotaoNuevo := .t.
LOCAL cLetraBotao := ""
 
Private cCordoGet:=("N+")
Private cCordoBotao := ("N/G,W+/G,GR+/N,GR+/G")
Private cCordoBotao2 := ("N/G,W+/G,GR*+/N,GR*+/G")
PUERTA :=.T.

CLI->(DBGOTO(RECORX))

VUELTA=.t.
DO WHILE VUELTA
     
Toto:=saveScreen(4,10,10,50)
 @ 4,8 CLEAR TO 16,72
c2w_boxraised(4,8,16,72,"cuadre") 
HB_Shadow(4, 10, 16, 72) 

MTIPO      := CLI->TIPO
MCLAVE     := CLI->CLAVE
MNOMBRE    := CLI->NOMBRE
MDIRECCION := CLI->DIRECCION
MCIUDAD    := CLI->CIUDAD
MTELEFONO  := CLI->TELEFONO
MSALDO_ACT := CLI->SALDO_ACT
MSALDO_ANT := CLI->SALDO_ANT
MRFC       := CLI->RFC
MACTUAL    := CLI->ACTUAL
MPARCIAL   := CLI->PARCIAL

 
      @ 5,10  SAY PADL("CLAVE:",10)  + " " + MCLAVE                    
      @ 6,10  SAY PADL("TIPO:",10)      GET MTIPO      PICTURE "!"            
      @ 7,10  say PADL("ACTUAL:",10)    GET MACTUAL    PICTURE "L"
      @ 8,10  SAY PADL("NOMBRE:",10)    GET MNOMBRE    PICTURE "@!"                 
      @ 9,10  SAY PADL("DIRECCION:",10) GET MDIRECCION PICTURE "@!"             
      @10,10  SAY PADL("CIUDAD:",10)    GET MCIUDAD    PICTURE "@!"                
      @11,10  SAY PADL("TELEFONO:",10)  GET MTELEFONO  PICTURE "@9"              
      @12,10  say PADL("RFC:",10)       GET MRFC       PICTURE "@!"   
      @12,50  SAY PADL("PARCIAL",10)    GET MPARCIAL   PICTURE "99,999.99"           
      @13,10  SAY PADL("SALDO ACT:",10) GET MSALDO_ACT PICTURE "9,999,999.99"

@ 15,60 GET cBotaoSair   PushButton CAPTION " Salir "    Color cCordoBotao2  STATE {||Peta10('S')} 
@ 15,20 GET cBotaoSair   PushButton CAPTION "<Nuevo>"    Color cCordoBotao   STATE {||Peta10('N')}   
@ 15,40 GET cBotaoGravar PushButton CAPTION "<Grabar>"  Color cCordoBotao    STATE {||Peta10('G')}
   
  
 READ 

  

  IF LASTKEY() = K_ESC
    c2w_deletecontrol("cuadre")
    restScreen(4,10,10,50,Toto)
    RETURN 
  ENDIF

ENDDO


static Function PETA10(cLetraBotao)

DO CASE

 CASE Upper(cLetraBotao) == "G"

    IF .NOT. MSGYESNO("SEGURO QUE DESEA MODIFICAR DATOS","MODIFICANDO")
      KEYBOARD(CHR(3))
      RETURN
    ENDIF
            

    IF cli->(DBRLOCK())
            //cli->CLAVE     := MCLAVE
            cli->NOMBRE    := MNOMBRE
            cli->DIRECCION := MDIRECCION
            cli->CIUDAD    := MCIUDAD
            cli->TELEFONO  := MTELEFONO
            cli->TIPO      := MTIPO
            cli->RFC       := Mrfc
            cli->ACTUAL    := mactual
            cli->SALDO_ACT := msaldo_act
            cli->parcial   := mparcial
        Cli->(DBCOMMIT())
        Cli->(DBUNLOCK())
        Cli->(DBGOTOP())
   ENDIF
      

  CASE Upper(cLetraBotao) == "S"
        Alert( "SIN MODIFICACIONES")
        KEYBOARD(Chr(K_ESC))

  CASE Upper(cLetraBotao) == "N"
        cls
        Cxc10Alt()
        KEYBOARD(Chr(K_ESC))

ENDCASE
  

RETURN .F.
//+++++++++++++++++++++++++++++++++++++++++++++++++++


procedure  cxc10alt()

     CLS
     clear gets
     @ 4,10 clear to 16,72
     @ 4,8,16,72 BOX B_DOUBLE    

        RCLAVE  := CLI->(LASTREC()) + 1
  IF .NOT. MSGYESNO("SEGURO QUE DESEA NUEVO REGISTRO","ALTA")
            KEYBOARD CHR(3)
           RETURN nil
       ENDIF

//Toto:=saveScreen(4,10,10,50)


         xclave  := LTRIM(str(rclave))
         xNOMBRE := space(30)

@  6,10  SAY PADL("Clave:",10)   + XCLAVE 
@  7,10  say padl("Nombre:",10)  get XNOMBRE PICTURE "@!"  
   
          READ
        


if empty(XNOMBRE) 
    MSGYESNO("Se requiere UN NOMBRE * * * * * *")
   return
endif 
     //restScreen(4,10,10,50,Toto)

    CLI->(DBgobottom())

 IF  CLI->(FLOCK())
     CLI->(DBAPPEND())
     CLI->CLAVE  := xCLAVE
     CLI->NOMBRE := xNOMBRE
     CLI->TIPO   := "M" 
     CLI->(DBCOMMIT())
     CLI->(DBUNLOCK())
      
 ENDIF
        
        CLI->(DBgotop())
 
RETURN nil      
