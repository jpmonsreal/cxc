*** PROGRAMA   : CXC38.PRG
** PROCESO    : IMPRIME CATALOGO DE CLIENTES SOLO NOMBRES
** AUTOR      : JP-4-88

#include "c2w.ch"
procedure cxc38

  LOCAL   HD:=0,opcion:=space(1)
  private PASO:=.F.,linea,otom:=0
  private  hojax := 0
  PRIVATE XLARGO1:=MLARGO
  CLEAR
      
DO WHILE .T.

SELE A
USE (ARCHIVO) ALIAS CLI  SHARED
if neterr()
   alert(" ARCHIVO EN USO ")
ENDIF
CLI->(OrdSetFocus(2))    
cli->(DBGOTOP())	
 IF !C2W_MSGNOYES("IMPRIMIR LOS DATOS....")
    CLOSE DATABASES
    RETURN
ENDIF

C2W_PRINTMODE("PDFPRINT")
C2W_INITWINPRINT()
  WOP := C2W_SELPRINTER(.T.,.T.)
IF WOP = 0 
   MSGSTOP("IMPRESION CANCELADA SIN IMPRESORA EN LINEA")
    RETURN
ENDIF 
    paso:=.t.
   
    CXC38_cab()

    
DO WHILE .NOT. Cli->(EOF())
 
c2w_printdata(LINEA,10, Cli->CLAVE,,8)
c2w_printdata(LINEA,18, SUBSTR(CLI->NOMBRE,1,35),,8)
c2w_printdata(LINEA,53, CLI->ACTUAL,,8)
c2w_printdata(LINEA,60, transform(CLI->SALDO_ACT,"##,###,###.##"),,8)
                        otom += cli->saldo_act
	        LINEA++ 
             IF LINEA >= XLARGO1
               c2w_eject()
               CXC38_CAB()
	       ENDIF

	 Cli->(DBSKIP())

                            
  ENDDO
        c2w_printdata(linea,60, Transform(otom,"99,999,999.99"),"",8)
	c2w_endwinprint()   
	set device to screen
  EXIT
ENDDO
RETURN  

 PROCEDURE CXC38_CAB
        
	
c2w_printdata(1,35,  MEMPRESA,,8)
c2w_printdata(2,35,  REPLI("-",LEN(MEMPRESA)),,8)
c2w_printdata(3,10,  "LISTADO DE ADEUDOS TODAS LAS CUENTAS ",,8)
c2w_printdata(3,50,  rmes,,8) 
c2w_printdata(3,65,  transform(pdate,"99-99-9999"),,8) 
c2w_printdata(3,78, "PAG",,8)
c2w_printdata(3,85, transform(HOJAX,"###"),,8) 
c2w_printdata(4,14,  "NUMERO",,8)
c2w_printdata(4,25,  "NOMBRE  DEUDOR ",,8)
  LINEA=5	
  hojaX ++         
 
  RETURN
