
#include "c2w.ch"
#include "box.ch"
#include "inkey.ch"


PROCEDURE CXC52LR

LOCAL cVar:=space(6),Opc:=0,rtipo
FIELD IDCLAVE,NOMUSER,CLAVE,CLAVE2,ALIAS,EMPRE1
private xclave,cAlias,PASO




IF RECUSUA <> 1  .AND. MNIVEL <> 999

  ALERT("Solo con Clave del Administrador")
  	RETURN
 ENDIF

 USE usuario  ALIAS USUA new SHARED
    IF NETERR()
        ALERT( "ARCHIVO EN USO ")
        RETURN
    ENDIF
 
 rtipo := " NOMBRE  DE USUARIOS "

  cALIAS:=Select()
  PASO:=6

  USUARIO52()
 
  RETURN


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

STATIC PROCEDURE MODIFICA52LR(RECORX)
LOCAL cBotaoNovo := .t.
LOCAL cBotaoGravar := .t.
LOCAL cBotaoSair := .t.
LOCAL cBotaoCrip := .t.
LOCAL cBotaoMod := .t.

 
Private cCordoGet:=("N+")
Private cCordoBotao := ("N/G,W+/G,GR+/N,GR+/G")

USUA->(DBGOTO(RECORX))

VUELTA=.t.
DO WHILE VUELTA
     
cls
@ 1, 12 SAY " MANTENIMIENTO USUARIOS "  color "N+/W"
    

 c2w_boxraised(2,12,12,63,"cuadra") 
  HB_Shadow(2, 12, 12, 63) 

midclave:=USUA->Idclave
mnombre :=USUA->Nombreuser
mclave  :=USUA->Clave
mclave2 :=USUA->Clave2
mAlias  :=USUA->Alias
mempre1 :=USUA->Empre1    
@ 4,17  say Padl("Empresa",10)    Get mEmpre1   Picture "!!!"
@ 5,17  SAY Padl("ID_CLAVE",10)   + space(1) + usua->idclave  
@ 6,17  SAY Padl("Nomuser",10)    get mnombre   Picture "@!"
@ 7,17  SAY Padl("Clave-crip",10)  
@ 7,28  say mclave    
//@ 8,17  SAY Padl("Clave-2",10)    get mclave2   Picture "999999"
@ 8,17  say Padl("Alias",10)      get mAlias    Picture "!!!!"  

@ 11,15 GET cBotaoNovo      PushButton CAPTION "&Alta...."   Color cCordoBotao    STATE {||Peta52lc('N')}
@ 11,30 GET cBotaoGravar    PushButton CAPTION "&Grabar.."   Color cCordoBotao    STATE {||Peta52lc('G')}
@ 11,42 GET cBotaoMod       PushButton CAPTION "&Modifica"   Color cCordoBotao    STATE {||Peta52lc('C')}
@ 11,54 GET cBotaoSair      PushButton CAPTION "&Salir..."   Color cCordoBotao    STATE {||Peta52lc('S')}

 READ    
 

  SET CURSOR OFF

  IF LASTKEY() = K_ESC
    c2w_deletecontrol("cuadra")
    RETURN .F. 
  ENDIF

ENDDO


static Function Peta52lc(cLetraBotao)

DO CASE
CASE Upper(cletraBotao) == "C"  //solo puede modificar el aministrador

                    XCLAVE:=GETCRIP(@mCLAVE,7,28)
                    mclave:=crip(alltrim(mclave))
                    @ 7,28  say space(8)
                    @ 7,28  say mclave  

 CASE Upper(cLetraBotao) == "N"  //solo el administrador

  IF .NOT. MSGYESNO("SEGURO QUE DESEA NUEVO REGISTRO","ALTA")
            KEYBOARD CHR(3)
           RETURN
       ENDIF

CXC52LRALTA()


 

       
 CASE Upper(cLetraBotao) == "G"

      IF .NOT. MSGYESNO("SEGURO QUE DESEA MODIFICAR DATOS","MODIFICANDO")
            KEYBOARD(CHR(3))
           RETURN
       ENDIF
            

    IF USUA->(DBRLOCK())
 //USUA->Idclave  := midclave
 USUA->Nombreuser  := mNombre
 USUA->clave    := mClave
 //USUA->clave2   := mclave2
 USUA->Alias    := mAlias
 USUA->Empre1   := mEmpre1
      USUA->(DBCOMMIT())
      USUA->(DBUNLOCK())
      
ENDIF
          KEYBOARD(Chr(K_ESC))
        


   CASE Upper(cLetraBotao) == "S"
             Alert( "SIN MODIFICACIONES")
               KEYBOARD(Chr(K_ESC))
            
ENDCASE
  

RETURN .F.


PROCEDURE CXC52LRALTA()

           cls
           clear gets

@ 3, 12 SAY " ALTA USUARIO NUEVOS " COLOR("W/N+") 
         
         
         xidclave:=space(4)
         xnomuser:=space(30)
         
USUA->(DBgobottom())
XIDCLAVE := ltrim(str(RECNO()+1))

@  5,17  SAY PADL(" Clave:",10)  get xidclave picture "999" 
@  6,17  say padl("Nombre:",10)  get xnomuser picture "@!"  
      
         read

if empty(xidclave) .or. empty(xnomuser)
    ALERT("Se requieren los datos completos")
    c2w_deletecontrol("cuadra")
    KEYBOARD CHR(3)
   return
endif 

    USUA->(DBgoBOTTOM())
    
 IF  USUA->(FLOCK())
     USUA->(DBAPPEND())
     USUA->IdClave  := xiDCLAVE
     USUA->NOMBREUSER := xnomUSER
       
       USUA->(DBCOMMIT())
       USUA->(DBUNLOCK())
      
 ENDIF
        
        USUA->(DBgotop())
       c2w_deletecontrol("cuadra")
      KEYBOARD(Chr(K_ESC))

   RETURN
    








