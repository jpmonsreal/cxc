**PROGRAMA   : CXP14.PRG
** PROCESO    : CAPTURA DE CONTRA-RECIBOS
** mcondic  variable publica dias gracia pago


#include "SetCurs.Ch"
#include "std.ch"
#include "set.ch"
#include "inkey.ch"
#include "Box.ch"
#include "c2w.ch"
#INCLUDE "ACHOICE.CH"

procedure cxc14

private   NW

Private flag10:=flag:=.F.,linea:=0,mcargo:=0,VS:=.F.,TOTALE:=0
private recs,deptox:={},mfam,mnom,mfecha_Fac,mcontrarec,MREC,MSUM,NUM,NOMBRE
private xclave,cAlias,datus,FLAGCH:=.F.,pazo,acrec,xdepto,pato,NEVENT:=" "
private paso,gClave,mconcepto,paco:=SPACE(3),TABARE:=.F.
 
set key -3 to CXC14BAJO()

SET(_SET_EVENTMASK,INKEY_ALL)

MSETCURSOR( .T. )

MFECHA3:=MFECHA1:=mfecha_fac:=XFECHA:=pdate
store 0 to control,msum,dias

dato     = .T.
KONT   = " "
opcion  = " "
MCARGO=0.00

CLEAR
datus:=.t.
   USE (FAMIL) ALIAS FAM SHARED NEW
  IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF

  FAM->(ordSetFocus(1))
   recs=lastrec()
   FAM->(DBGOTOP())
   for i=1 to recs
       acrec = FAM->NUM + "|" +SUBSTR(FAM->NOMBRE,1,20) 
       aadd(deptox,acrec)
       skip
   next

   CLOSE DATABASES

**************************************************************************
SELE A
USE (ARCHCAP) ALIAS CAP SHARED
    IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF
cap->(ordSetFocus(1))

SET FILTER TO  .NOT.  ACTUAL    // DOCUMENTOS O SALDOS PENDIENTES DE PAGO
cap->(dbgotop())
**************************************************************************
SELE B
USE (ARCHIVO) ALIAS CLI SHARED
     IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF
cli->(ordSetFocus(2))


******************************************************************************************
paso:=2   //FUNCION TBROWSE

CXC10BR()
return


STATIC PROCEDURE MODIFICA14(RECORX)

CLI->(DBGOTO(RECORX))

DO WHILE .T.      && Principal

   pant14()

   SELE B
   pazo =space(3)
   dato:= .T.
   flag:= .f.
   MSUM:= 0
   PACO:= SPACE(3)

  @ 3,12 say  cli->CLAVE color(fone) 
  @ 3,28 say  cli->nombre color(fone)
  @ 3,70 SAY  CLI->ACTUAL COLOR(FONE)

  gClave := Cli->Clave
  mRec   := cli->(recno())

   IF LASTKEY()=27
      EXIT
   ENDIF

  cap->(dbseek(gclave))
        
     
      DO WHILE cap->Clave = gClave   .AND.  .NOT.  EOF()       
          
        @ linea,1  say CAP->tipo       COLOR(FONE)
        @ linea,5  say cap->REFERENCIA 
        @ linea,15 say cap->fecha_cap  picture "99-99-9999"
        @ linea,30 say CAP->concepto   picture "@!S30"
        @ linea,64 SAY CAP->cargo      picture "#####,###.##"
          
         paco = cap->tipo
         MSUM += CAP->cargo
         CAP->(DBSKIP())
         linea ++
        @ 22,47 SAY "Total Adeudo $"
        @ 22,64 SAY MSUM PICTURE "##,###,###.##"
         IF linea > 20
            @ 21,1 SAY "[Enter] Siguiente Pagina..." GET NEVENT PICTURE " "
            READ
            LINEA:=8
            @ 7,0 CLEAR
         ENDIF

      IF LASTKEY()=27
       EXIT
      ENDIF

      ENDDO

*********************** CAPTURA **************

IF c2w_MSGYESNO("DESEA CAPTURAR REGISTROS","SELECCIONAR UNA OPCION ")
            MFAM     = SPACE(3)
            MREFEREN = SPACE(7)
            MCARGO = 0.00
            @ 23,0 clear  
           
    IF CLI->SALDO_ACT<>MSUM
          IF CLI->(DBRLOCK())
          REPLACE CLI->SALDO_ACT WITH MSUM 
          ENDIF
          UNLOCK
          COMMIT
    ENDIF
 ELSE
     RETURN
ENDIF
   

*******************AGREGAR MAS CUENTAS*********************
CAPTU =.T.
          
DO WHILE CAPTU
 FLAG:= .T.
      MCARGO=0.00
      TREF:=LTRIM(STR(CAP->(LASTREC())))
       mcontrarec=space(6)
       mconcepto= space(30)
       mreferen := SPACE(7)

                 
      @ linea,1  GET paco        
      @ linea,5  GET mreferen    
                 read     
      IF MREFEREN = SPACE(7) .OR. PACO = SPACE(3)
         OPC:=ALERT("SE REQUIERE ANOTAR REFERENCIA O GRUPO " ,{"SALIR","CONTINUAR"})
          IF OPC=1
             TABARE:=.T.
             EXIT
          ELSE
          LOOP
         ENDIF
      ENDIF

      @ linea,1  SAY paco        
      @ linea,5  SAY mreferen    PICTURE "#######"
                            

      @ linea,15 GET mfecha_fac  PICTURE "99-99-9999"
      @ linea,30 GET mconcepto   picture "@!S30"
      @ LINEA,64 GET MCARGO      PICTURE "#####,###.##"
        read

                IF LASTKEY()=27
                 captu := .f.
                ENDIF



      cap->(DBSETORDER(1))
      cap->(dbgotop())
      CAP->(DBSEEK(MREFEREN)) 


      IF cap->(found())
         ALERT(" Ya existe esta factura " + cap->(clave)+" "+cap->tipo+" "+cap->(referencia))

         @ 23,45   SAY SPACE(40)
         @ linea,7 SAY SPACE(10)
            LOOP
      ENDIF


        mfecha1 = mfecha_fac + mcondic

        if mcargo=0.00
           ALERT(" No procede alta con  0.00  <Enter> ")
           @ linea,3 say space(59)
           Flagch=.f.
           exit
        Endif

      @ linea,64 SAY mcargo PICT "#####,###.##"
       
       IF C2W_msgyesno("GRABAR DATOS")
         ELSE
        @ linea,7 say space(59)
         return
       Endif

******************grabando en base de datos**************      
      @ 23,0
      SELE A
      cap->(dbgobottom())
         IF CAP->(FLOCK())
            APPEND BLANK
            cap->REFERENCIA:= MREFEREN
            cap->TIPO      := PACO
            cap->CLAVE     := gClave
            cap->fecha_cap := mfecha_fac
            cap->FECHA     := mfecha3
            cap->CARGO     := MCARGO
            cap->CONDIC    := MCONDIC    //variable publica
            cap->contrarec := mcontrarec
            cap->CONCEPTO  := MCONCEPTO
            cap->actual    := .F.                        //falso no esta pagado
            cap->serie     := 1                        // Status nueva serie
           // cap->user    := TCLAVE
            UNLOCK
            commit
         ENDIF
         
      sele A
      LINEA++
      TOTALE :=MSUM + MCARGO 
   
      IF LINEA>20
         @ 7,0 CLEAR
         LINEA:=8
      ENDIF
  
     SELE CLI
           
            CLI->(DBGOTO(MREC))
         IF CLI->(DBRLOCK())
            REPLACE CLI->ACTUAL WITH  .T.     //mantiene es status de activo
            REPLACE CLI->SALDO_ACT WITH CLI->SALDO_ACT + MCARGO
            UNLOCK
            commit
         ENDIF
   

      *@  3,65 SAY CLI->SALDO_ACT    PICTURE "9999,999.99"
       @ 22,64 SAY TOTALE            PICTURE "9999,999.99"
   ENDDO
   
  IF TABARE
LOOP
  ENDIF

ENDDO

RETURN

*************************************************************************

PROCEDURE PANT14
   CLEAR
   @ 1,3  SAY MEMPRESA  color(fon)
   @ 1,40 SAY " REGISTRO DE CUENTAS POR COBRAR "  color(fon)
   @ 2,3  say "Fecha:             Condiciones:        Grupo<F4>:"
   @ 2,10 say XFECHA
   @ 2,36 SAY MCONDIC   PICTURE  "###"
   @ 3,3  SAY " Clave :        Nombre : "
              *         1         2         3         4         5         6         7
              *1234567890123456789012345678901234567890123456789012345678901234567890123456789
   @  4,0 to 6,79 
   @  5,1 SAY "Referencia |Fecha Documento| Concepto                       |     Importe     "
    
           linea:=7
RETURN


**********CATALOGO DE CLAVES DEPARTAMENTOS EMPRESA******************


/*
procedure cxc14bajo
   IF FLAG
       @ linea,3 say space(9)
         Toto:=saveScreen(2,48,16,78)
   
              
 @ 2,48,15,75 GET mFam LISTBOX deptox DROPDOWN  COLOR "W/W*,N/W*,N+/W*,W+/N,W/W*,N/W,B+/W,W+/N" 
             READ
             paco=substr(mfam,1,3)
             pazo = substr(mfam,1,3)
             mnom= substr(mfam,4,20)
             @ 2,48    say pazo + MNOM 
             restScreen(2,48,15,78,Toto)
              FLAG:= .F.
             @linea,1 say paco
        ENDIF

Return
*/


function cxc14BAJO  
    local al,pos
    pase:=.f.
       al=savescreen(1,40,18,69)
       @ 1,40 clear to 18,69
       @ 1,40 TO 18,69 COLOR(FON)
      
       pacho=achoice(2,42,16,68,deptox,"tus")
     
       if pase
          paco:=substr(deptox[pacho],1,3)
         
      
         restscreen(1,40,18,69,al)
         @linea,1 say paco
       endif

 return NIL
***************************************

function tus(mode,gas)

if lastkey()==13 .OR. LASTKEY() == 1006
   pase:=.t.
   return(1)
elseif lastkey()=27
   return(1)
endif

return(2)

return

