 ***PROGRAMA : cxc50.prg datps empresa
** PROCESO  : DATOS DE LA EMPRESA
** AUTOR    : JP 4-88
*** VARIABLE MODIFICA ES PRIVADA VIENE DEL PRINCIPAL POP

#include "c2w.ch"
procedure cxc50

Local REC,OPCION,VUELTA,CONTE,VASO,TONT,AL,AM,AQ,XREC,AX,LIN,XCLA
Local CBotaoNovo:=cBotaoGravar:=cBotaoSalir:=.t.
local cLetraBotao:=" "

private NomCamp,NomeVar,Mnombre
Private cCordoBotao := ("N/G,W+/G,GR+/N,GR+/G")
    TONT:=" "

USE EMPRESAS ALIAS EMP SHARED NEW



conte=" "
  go emprec

   regs:=Emp->(Fcount())    
       For i=1 to regs
         IF TYPE(FIELD(I)) # "U"
            NOMECAMP=FIELDNAME(I)
            NOMEVAR="M"+NOMECAMP
            private &NOMEVAR
            &NOMEVAR = &NOMECAMP
          ENDIF
       Next 
     

c2w_boxraised(2,10,19,60,"bora")
HB_Shadow(2, 10, 19, 60) 

lcancel:=.f.
itex := 1   
opc:=3   


go emprec


VUELTA=.t.

DO WHILE VUELTA
  
//@  7,20 SAY  padl("Sistema",10) get msistemma
@  3,12 SAY  padl("CLAVE",10) + " " +  mclave    COLOR(FON)   
@  4,12 SAY  padl("NOMBRE",10)    get mnombre    PICTURE "@!"  
@  5,12 SAY  padl("DIRECCION",10) get mdireccion   PICTURE "@!" 
@  6,12 SAY  padl("CIUDAD",10)    get mciudad      PICTURE "@!" 
@  7,12 SAY  padl("RFC",10)       get mrfc                PICTURE "@!" 
@  8,12 SAY  padl("IMP_IVA",10)   get mimp_iva      
@  8,32 SAY  padl("FILE_1",10)    get mfile1           PICTURE "@!" 
@  9,12 SAY  padl("Dias_1",10)    get mdias_1       PICTURE "9999" 
@  9,32 SAY  padl("FILE_2",10)    get mfile2           PICTURE "@!" 
@ 10,12 SAY  padl("Dias_2",10)    get mdias_2      PICTURE "9999"
@ 10,32 SAY  padl("FILE_3",10)    get mfile3         PICTURE "@!" 
@ 11,12 SAY  padl("Dias_3",10)    get mdias_3      PICTURE "9999"
@ 11,32 SAY  padl("FILE_4",10)    get mfile4          PICTURE "@!" 
@ 12,12 SAY  padl("Dias_4",10)    get mdias_4      PICTURE "9999"
@ 12,32 SAY  padl("FILE_5",10)    get mfile5           PICTURE "@!" 
@ 13,12 SAY  padl("IMP_EDO",10)   get mimp_edo 
@ 13,32 SAY  padl("FILE_6",10)    get mfile6           PICTURE "@!" 
@ 14,12 SAY  padl("Cambia",10)    get mcambia  picture "9999.99"
@ 14,32 SAY  padl("E_FECHA",10)   get me_fecha   picture "99-99-9999"
@ 15,12 SAY  padl("Colore",10)    get mcolore  
@ 15,32 SAY  padl("Color2",10)    get mcolon  
@ 16,12 say  padl("Largo",10)     get mlargo
@ 16,32 say  padl("Folio",10)     get mfolio       PICTURE "9999" 
@ 17,12 SAY  padl("Control",10)   get mcontrol 
@ 17,32 say  padl("Dgracia",10)   get mdgracia   PICTURE "999"
@ 18,12 say  padl("Camini",10)    get mcamino picture "@!" 
          
 @ 19,22 GET cBotaoNovo     PushButton CAPTION " &Grabar "  Color cCordoBotao  STYLE "[]"  STATE {||Seta50('N') }
 @ 19,45 GET cBotaoSalir    PushButton CAPTION " &Salir "   Color cCordoBotao  STYLE "[]" STATE {||Seta50('S')}
    
 READ
  SET CURSOR OFF
  IF LASTKEY() = K_ESC
  c2w_deletecontrol("bora")
     RETURN .F. 
  ENDIF

Enddo
Function Seta50(cLetraBotao)

DO CASE
   CASE Upper(cLetraBotao) == "S"
               c2w_deletecontrol("bora")
               clear gets
               CLS
               close databases
              Keyboard(chr(K_ESC))   


   CASE Upper(cLetraBotao) == "N"
 
  if !msgyesno("Seguro que quiere modificar Datos"," Modificar Datos ")
       KEYBOARD Chr(3)
       Return
  Endif
           go emprec
           IF Emp->(DBRLOCK())
              For i=1 to regs
                IF TYPE(FIELD(I)) # "M"
                   NOMECAMP=FIELD(I)
                   NOMEVAR  = "M"+ NOMECAMP
                    IF TYPE("&NOMEVAR") # "U"
                       REPLACE &NOMECAMP WITH &NOMEVAR
                    ENDIF
               ENDIF
                  NEXT
                  Emp->(Dbcommit())
                  Emp->(Dbunlock())
     
                  
               
              ENDIF
      

KEYBOARD Chr(3)

ENDCASE

Return




