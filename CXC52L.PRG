** JPM MID 73 OLD NOVO 

#include "c2w.ch"

PROCEDURE CXC52L

private xclave,flag,rtipo,mentidad,PAZO,OPC,Recorx,PASOS,mnoparte
 private cAlias,Acol,mucho,pre,PASO

 clear
use (FAMIL) alias FAM shared
 IF NETERR()
   ALERT(" ARCHIVO EN USO ")
   RETURN
 ENDIF
SET FILTER TO .NOT. ACTUAL
FAM->(OrdSetFocus(1))

 FAM->(DBGOTOP())

rtipo := " NOMBRE  DE FAMILIAS "

  cALIAS:=Select()
  PASO:=5

  fam12()
 
  RETURN


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

 PROCEDURE MODIFICA52L(RECORX)
LOCAL cBotaoNovo := .t.
LOCAL cBotaoGravar := .t.
LOCAL cBotaoSair := .t.
LOCAL cLetraBotao := ""
Private cCordoGet:=("N+")
Private cCordoBotao := ("N/G,W+/G,GR+/N,GR+/G")


Fam->(DBGOTO(RECORX))

VUELTA=.t.
DO WHILE VUELTA
     
CLS
@ 1, 12 SAY " MANTENIMIENTO  FAMILIAS "  color("N+/W")
  

  c2w_boxraised(2,12,12,63,"cuadre")
  HB_Shadow(2, 12, 12, 63) 

  xnum:=fam->num
  xnombre:=fam->nombre
  xactual:=fam->actual
@  4,14 SAY PADL(" Clave:",10) get xnum    PICTURE "!!!"
@  6,14 say padl("Nombre:",10) get xnombre PICTURE "@!"
@  8,14 SAY PADL("Actual:",10) get xactual PICTURE "L"      


@ 11,20 GET cBotaoNovo      PushButton CAPTION "&Alta"      Color cCordoBotao    STATE {||Peta52('A')}
@ 11,30 GET cBotaoGravar    PushButton CAPTION "&Grabar "   Color cCordoBotao    STATE {||Peta52('G')}
@ 11,45 GET cBotaoSair      PushButton CAPTION "&Salir"     Color cCordoBotao    STATE {||Peta52('S')}
    
 READ 

  SET CURSOR OFF

  IF LASTKEY() = K_ESC
    c2w_deletecontrol("cuadre")
      RETURN .F.  
   ENDIF

ENDDO


static Function Peta52(cLetraBotao)
 
DO CASE

        CASE Upper(cLetraBotao) == "A"

  IF .NOT. MSGYESNO("CREACION DE NUEVO REGISTRO"," NUEVO REGISTRO ")
            KEYBOARD CHR(3)
            RETURN
       ENDIF

        CXC52LALTA()

       KEYBOARD(Chr(K_ESC))
        
        RETURN
       

 CASE Upper(cLetraBotao) == "G"

      IF .NOT. MSGYESNO("SEGURO QUE DESEA MODIFICAR DATOS","MODIFICANDO")
            KEYBOARD(CHR(3))
          RETURN
       ENDIF
            

    IF Fam->(DBRLOCK())
 Fam->Num     := xnum
 Fam->Nombre  := xNombre 
 Fam->Actual  := xActual

      Fam->(DBCOMMIT())
      Fam->(DBUNLOCK())
      
   ENDIF
     KEYBOARD(Chr(K_ESC))
   
       RETURN 


   CASE Upper(cLetraBotao) == "S"
             Alert( "SIN MODIFICACIONES",{"UNO","DOS"})
           
               KEYBOARD(Chr(K_ESC))
            
ENDCASE
  
  
RETURN .F.




PROCEDURE CXC52LALTA
CLEAR GETS
CLS
@ 1,12 SAY " ALTA NUEVO GRUPO O FAMILIA "  
@ 2,12,12,63 BOX B_DOUBLE   

         ZNOMBRE:=SPACE(30)
         ZNUME  := SPACE(3)
@  4,14  SAY PADL(" Clave:",10)  get Znume   picture "!!!" 
@  6,14  say padl("Nombre:",10)  get ZNOMBRE picture "@!" 
      
         read

if empty(ZNume) .or. empty(ZNOMBRE)
    ALERT("Se requieren los datos completos Y no duplicar")
    KEYBOARD CHR(3)
    c2w_deletecontrol("cuadre")
  return
ENDIF

 IF .NOT. MSGYESNO("SEGURO ** CONFIRMACION **")
            KEYBOARD CHR(3)
            
           RETURN
  ENDIF  

FAM->(DBgobottom())

 IF  FAM->(FLOCK())
       FAM->(DBAPPEND())
       FAM->NUM    := zNUME
       FAM->NOMBRE := zNOMBRE
       
       FAM->(DBCOMMIT())
       FAM->(DBUNLOCK())
      
 ENDIF
        
        FAM->(DBgotop())
        c2w_deletecontrol("cuadre")
RETURN
      