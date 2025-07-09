** PROGRAMA   : CXC20.PRG
** PROCESO    : VISUALIZAR pagos anteriores
** AUTOR      : JP ABRIL 91 precedente cxc14 abril 88.
#include "dbedit.ch"
#include "SetCurs.Ch"
#include "std.ch"
#include "set.ch"
#include "inkey.ch"
#include "Box.ch"
#include "c2w.ch"


procedure cxc20

Local   NW

Private flag10:=flag:=.F.,xclave,linea:=0,mcargo:=0,VS:=.F.,TOTALE:=0
private recs,deptox:={},mfam,mnom,mfecha_Fac,mcontrarec,MREC,MSUM,MSUMC
private xclave,cAlias,datus,FLAGCH:=.F.,pazo
private paso,gClave,mconcepto,PASO:=4,recorx,xcargo:=0.00


MFECHA3:=MFECHA1:=mfecha_fac:=XFECHA:=pdate
store 0 to control,msum,msumc,dias

dato     = .T.
KONT   = " "
opcion  = " "
MCARGO=0.00
CLOSE DATABASES
CLEAR
datus:=.t.
SELE A
USE (ARCHCAP) ALIAS CAP SHARED
    IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF
Cap->(OrdSetFocus(1))
 cap->(dbgotop())



SELE B
USE (ARCHIVO) ALIAS CLI SHARED
     IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF


CLI->(OrdSetFocus("nombre"))

cAlias:=select()

******************
paso:=4
CXC10BR()
return

PROCEDURE MODIFICA20(RECORX)

CLI->(DBGOTO(RECORX))   //VA AL REGISTRO Y TRAE LOS DATOS

DO WHILE .T.

    CXC20_PAN()

  @ 4,11 SAY Cli->CLAVE  color(fon)
  @ 4,27 SAY Cli->NOMBRE color(fon)
  @ 4,57 say Cli->Saldo_act Picture "9999,999.99" color(Fon)


KONT=" "
 FLAG   := .F.
  
store 0 to msum,msumc
           LINEA  := 8
          MCLAVE := Cli->clave
          Cap->(DBSEEK(MCLAVE))

           IF CAP->(EOF()) 
                ALERT(" NO EXISTEN MOVIMIENTOS PENDIENTES CON ESTE CLIENTE ")
                return
             endif

  DO WHILE Cap->clave = mclave .and. .not. eof()
        

    @ LINEA,2   say Cap->Referencia
    @ linea,10  say cap->serie  picture "9"
    @ LINEA,13  SAY cap->FECHA
    @ LINEA,24  SAY CAP->CLAVE
    @ LINEA,29  SAY cap->CONCEPTO

             
     
              
    @ LINEA,50 SAY cap->CARGO  picture "##,###,###.##"
               MSUMC = MSUMC + CAP->CARGO
                                  
    @ LINEA,64 SAY cap->ABONO  picture "##,###,###.##"
               MSUM = MSUM+CAP->ABONO
            

                cap->(DBskip(1))
                linea++

        IF LINEA>20
               kont:=" "
    @ 23,05 say "SUB-TOTOTAL < Enter > Continuar " COLOR(FON)
    @ 23,35  get kont picture "!"  
    @ 23,50  SAY MSUMC PICTURE "999,999,999.99"
    @ 23,64  SAY MSUM  PICTURE "999,999,999.99"
               read
        @ 8,0 clear
        LINEA=8
                if kont <> "F"
                   LOOP
                else
                   EXIT
                endif
         ENDIF

     ENDDO

       
     alfa = " "
     @ 23,35  SAY MSUMC - MSUM   PICTURE "999,999,999.99"
     @ 23,50  SAY MSUMC PICTURE "999,999,999.99"
     @ 23,65  SAY MSUM  PICTURE "999,999,999.99"
       
 @ 23,10 SAY " < Enter > Continuar  " get alfa
          read
         if alfa = " "
         exit
         endif
 enddo

RETURN NIL

PROCEDURE CXC20_PAN
cls
@ 1,6   SAY MEMPRESA    COLOR(FON)
@ 1,40  SAY " REVISANDO DOCUMENTOS PAGADOS " COLOR(fon)
@  2,6   SAY " USE TAB  para busqueda por palabras"        
          *          1         2         3         4         5         6         7
          * 123456789012345678901234567890123456789012345678901234567890123456789012345678
@ 3,1  SAY "ษอออ[ F4 ]ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
@ 4,1  SAY "บ Clave :           Nombre :                                                บ"
@ 5,1  SAY "ษออออออออออัออออออออัอออออออออออออออออออออออออออออออออออออออออออออออออออออออป"
@ 6,1  SAY "บ  Factura ณFecha/PAGO          CONCEPTOS           CARGOS       ABONOS     บ"
@ 7,1  SAY "บออออออออออุออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออบ"
LINEA := 8
RETURN



