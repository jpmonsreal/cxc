** PROGRAMA  : CXC30.PRG  precedente en cxc30.bix
** PROCESO    : IMPRIME CATALOGO DE PROVEEDORES
** AUTOR      : j.P. 4-88

#include "c2w.ch"

procedure cxc30

local  TSALDO:=TSANT:=TDIAS7:=TDIAS15:=TDIAS30:=TDIAS30M:=0
PRIVATE HOJA,linea,sume:=0,mclave1:=space(4),mfecha:=pdate
private noprinto:=mcamino+"catprove.txt",paso:=.f.,XLARGO
clear


   paso:=.t.
   LINEA:=1
   HOJA:=1
   
SELE A
use (ARCHIVO) alias CLI shared
 IF NETERR()
   ALERT(" ARCHIVO EN USO ")
   RETURN
 ENDIF

cli->(OrdSetFocus(2))

  //SET FILTER TO  CLI->ACTUAL
 cli->(DBGOTOP())

SELE B
USE (ARCHCAP) ALIAS CAP SHARED
IF NETERR()
  ALERT(" ARCHIVO EN USO ")
   RETURN
ENDIF
  CAP->(OrdSetFocus(1))
 
   SET FILTER TO  .NOT.   ACTUAL
   CAP->(DBGOTOP())           


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

 cxc30_cab()

DO WHILE .NOT. EOF()
   SELE A
   mpvencer:=mdias30:=mdias60:=mdias90:=mdias120m:=mcargo:=mabono:=adetotal:=0
   tcsum:=tcven:=tc30:=tc60:=tc90:=tc120m:=0
   MCLAVE1 := cli->clave
   MNOMBRE := cli->nombre
   ttipo   := cli->tipo
      SELE B
       SET SOFTSEEK ON
       SEEK MCLAVE1

   IF clave <> mclave1
       SELE A
       SKIP
       LOOP
   ENDIF

   SELE B
   DO WHILE MCLAVE1 = CLAVE  .and. .not. eof()
      
      dias   = pdate - cap->fecha
      mcargo = cap->cargo //- cap->abono
      do case
         case dias < md1
              mpvencer += mcargo
         case dias >= md1 .and. dias <= md2
              mdias30  += mcargo
         case dias >= md2 .and. dias <= md3
              mdias60  += mcargo
         case dias >= md3 .and. dias <= md4
              mdias90  += mcargo
         case dias >= md4
              mdias120m += mcargo
      endcase
      SKIP
   ENDDO
   
   sume := mpvencer+mdias30+mdias60+mdias90+mdias120m

  IF sume <> 0
   //c2w_printdata(linea,1,ttipo,"CONSOLAS",8)
   c2w_printdata(LINEA,3,mclave1,"CONSOLAS",8)
     if ttipo="D"
       c2w_printdata(LINEA,8,SUBSTR(mnombre,1,25)+"**", "CONSOLAS",8)
     else
       c2w_printdata(LINEA,8,SUBSTR(mnombre,1,25) , "CONSOLAS",8) 
     endif

   c2w_printdata(LINEA,40,TRANSFOR(SUME,"####,###.##"),"CONSOLAS",8)  //SUMA DE TOTALES
   c2w_printdata(LINEA,54,TRANSFOR(mpvencer,"####,###.##"),"CONSOLAS",8)  // PENDIENTE DE VENCER
   c2w_printdata(LINEA,68,TRANSFOR(mdias30,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,82,TRANSFOR(mdias60,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,96,TRANSFOR(mdias90,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,108,TRANSFOR(mdias120m,"####,###.##"),"CONSOLAS",8)

     IF ttipo="D"
        linea ++
        
        tcsum  = sume       * (pcambio -1.00)
        tcven  = mpvencer   * (pcambio -1.00)
        tc30   = mdias30    * (pcambio -1.00)
        tc60   = mdias60    * (pcambio -1.00) 
        tc90   = mdias90    * (pcambio -1.00)
        tc120m = Mdias120m  * (pcambio -1.00)
 
   c2w_printdata(LINEA,8, " Dif por cambios Dls -1 --->","CONSOLAS",8)
   c2w_printdata(LINEA,40,  TRANSFORM(tcsum,"####,###.##"),"CONSOLAS",8)  //SUMA DE TOTALES
   c2w_printdata(LINEA,54,  TRANSFORM(tcven,"####,###.##"),"CONSOLAS",8) // PENDIENTE DE VENCER
   c2w_printdata(LINEA,68,  TRANSFORM(tc30,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,82,  TRANSFORM(tc60,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,96,  TRANSFORM(tc90,"####,###.##"),"CONSOLAS",8)
   c2w_printdata(LINEA,108, TRANSFORM(tc120m,"####,###.##"),"CONSOLAS",8)

      Endif

   TSALDO   += sume      + tcsum
   TSANT    += mpvencer  + tcven
   TDIAS7   += mdias30   + tc30
   TDIAS15  += mdias60   + tc60
   TDIAS30  += mdias90   + tc90
   TDIAS30M += mdias120m + tc120m

  LINEA++
  
   IF LINEA >= MLARGO
       C2W_EJECT()
       cxc30_cab()
   ENDIF

  Endif sume
       SELE A
         skip

ENDDO

c2w_printdata(LINEA,40,REPLICATE("-",85),"CONSOLAS",8)
              LINEA ++
c2w_printdata(LINEA,30,"TOTALES->","CONSOLAS",8)
c2w_printdata(LINEA,40, TRANSFORM(TSALDO,  "####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,54, TRANSFORM(TSANT,   "####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,68, TRANSFORM(TDIAS7,  "####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,82, TRANSFORM(TDIAS15, "####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,96, TRANSFORM(TDIAS30, "####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,108,TRANSFORM(TDIAS30M,"####,###.##"),"CONSOLAS",8)

CLOSE DATABASES

C2W_ENDWINPRINT()

SET DEVICE TO SCREEN



RETURN


PROCEDURE cxc30_cab
  
    hoja ++
  c2w_printdata(1,46-LEN(MEMPRESA)/2,MEMPRESA,"consolas",12,.T.)
  c2w_printdata(2,45-LEN(MEMPRESA)/2,REPLI("-",LEN(MEMPRESA)),"CONSOLAS",12)
  c2w_printdata(3,1,   "Fecha del Reporte:"+dtoc(date()),"CONSOLAS",8)
  c2w_printdata(4,1,   "FECHA DEL SISTEMA:"+DTOC(MFECHA),"CONSOLAS",8)
  c2w_printdata(4,45,  "LISTADO DE PARTIDAS PEND. PAGO POR ENTIDAD","CONSOLAS",8)
  c2w_printdata(4,95,  "T:C","CONSOLAS",8)
  c2w_printdata(4,99,  TRANSFORM(pcambio,"###.##"),"CONSOLAS",8)
  c2w_printdata(4,107, "PAG #","CONSOLAS",8)
  c2w_printdata(4,114, TRANSFORM(HOJA,"###"),"CONSOLAS",8)
  c2w_printdata(5,0,    REPLI("-",120),"CONSOLAS",8)
   c2w_printdata(6,4,   "CLAVE","CONSOLAS",8)
  c2w_printdata(6,12,  "NOMBRE DE LA ENTIDAD","CONSOLAS",8)
  c2w_printdata(6,42,  "  TOTAL  ","CONSOLAS",8)
  c2w_printdata(6,54,  " POR VENCER  ","CONSOLAS",8)
  c2w_printdata(6,75,  TRANSFORM(MD1,"####"),"CONSOLAS",8)
  c2w_printdata(6,87,  TRANSFORM(MD2,"####"),"CONSOLAS",8)
  c2w_printdata(6,101, TRANSFORM(MD3,"####"),"CONSOLAS",8)
  c2w_printdata(6,115, TRANSFORM(MD4,"####"),"CONSOLAS",8)
  c2w_printdata(7,0,   REPLICATE ("-",120),"CONSOLAS",8)
    LINEA := 8
    
  
RETURN


