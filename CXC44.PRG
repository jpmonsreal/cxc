** PROGRAMA  : CXC44.PRG  precedente en cxc30.PRG
** PROCESO    : IMPRIME CATALOGO DE PROVEEDORES   POR GRUPO
** AUTOR      : j.P. 4-88 // CZM JPM 8/98
** mcondic mfcontro variable publica dias gracia

#include "c2w.ch"
procedure cxc44

LOCAL   TSALDO:=TSANT:=TDIAS7:=TDIAS15:=TDIAS30:=TDIAS30M:=0

PRIVATE LINEA,sume:=0,mclave1:=space(4),mfecha:= pdate
private PASO:=.F.,XLARGO1:=MLARGO,hoja:=0,toto
PRIVATE FNOMBRE,MGRUP,MFAM,MNOM,DEPTOX:={}


CLEAR

@ 2,2  SAY MEMPRESA COLOR(fon)
@ 2,40 SAY "IMPRIME TOTALES DOCUMENTOS POR GRUPO" COLOR(fon)

@ 3,2  SAY REPLI("Í",78)
@ 5,8,8,72 box "ÚÄ¿³ÙÄÀ³"
@ 6,10 say "  SE LISTARAN  SALDOS  DE INFORMACION POR  GRUPO"
@ 7,10 SAY "  FECHA DEL REPORTE (DD/MM/AA) "
@ 7,45 SAY  MFECHA picture "##/##/##"

SELE C       
USE (FAMIL)  ALIAS FAM SHARED NEW
IF NETERR()
   ALERT("ARCHIVO EN USO ")
   RETURN
ENDIF  

fam->(ordSetFocus(1)) 
   recs=lastrec()
   for i=1 to recs
       acrec=NUM+" "+NOMBRE
       aadd(deptox,acrec)
       skip
   next
   CLOSE DATABASES

   MFAM=SPACE(3)
Toto:=Savescreen(1,35,16,55) 
DO WHILE .T.
        MFAM=SPACE(3)
    
@ 18,5  SAY " ANOTE LAS TRES LETRAS CLAVE "
@ 1,35,16,55 GET mfam  listbox deptox    //PICTURE "!!!"
        READ
        if mfam="  "
           return
        endif
restScreen(1,35, 16,55,Toto)

@ 18,40 SAY MFAM 

       FNOMBRE = SUBSTR(MFAM,1,3)
       MGRUP    =  SUBSTR(MFAM,4,20)
@ 20,1 SAY FNOMBRE
@ 22,1 SAY MGRUP

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
   
    CXC44_cab()
     EXIT
 ENDDO

SELE A
USE (ARCHIVO) ALIAS CLI
IF NETERR()
   ALERT("ARCHIVO EN USO")
   RETURN
 ENDIF
   cli->(ordSetFocus(2))
   cli->(dbgotop())     //ORDEN ALFABETICO

SELE B
USE (ARCHCAP) ALIAS CAP SHARED
IF NETERR()
   ALERT("ARCHIVO EN USO ")
   RETURN
ENDIF
  cap->(ordSetFocus(2))
  set filter to TIPO=MGRUP
  cap->(dbgotop())

SELE A
DO WHILE .NOT. EOF()
SELE A
   mpvencer:=mdias30:=mdias60:=mdias90:=mdias120m:=mcargo:=mabono:=adetotal:=0
   tcsum:=tcven:=tc30:=tc60:=tc90:=tc120m:=0

   MCLAVE1 := cli->clave
   MNOMBRE := cli->nombre
   ttipo   := cli->tipo
SELE B

   SEEK MCLAVE1

   IF EOF()
       SELE A
       SKIP
       LOOP
   ENDIF

sele B

   DO WHILE MCLAVE1 = CLAVE  .and. .not. eof()

           if mfcontrol
              fdate:= iif(month(cap->fecha_cap) = 0,cap->fecha,cap->fecha_cap)
              
           else
              fdate:= cap->fecha
           endif

      dias   = (pdate-fdate) - mcondic

      mcargo = cap->cargo - cap->abono
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
      SELE B
      SKIP

   ENDDO
   sume := mpvencer+mdias30+mdias60+mdias90+mdias120m

   IF sume <> 0
   C2W_PRINTDATA(LINEA,3,   mclave1,"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,8,   mnombre,"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,40,  TRANSFORM(SUME,"####,###.##"),"CONSOLAS",8)  //SUMA DE TOTALES
   C2W_PRINTDATA(LINEA,54,  TRANSFORM(mpvencer,"####,###.##"),"CONSOLAS",8)  // PENDIENTE DE VENCER
   C2W_PRINTDATA(LINEA,68,  TRANSFORM( mdias30, "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,82,  TRANSFORM(mdias60, "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,96,  TRANSFORM( mdias90, "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,110, TRANSFORM(mdias120m,"####,###.##"),"CONSOLAS",8)

     IF ttipo="D"
        linea ++
        
        tcsum  = iif(sume >0,sume       * (pcambio -1.00),0)
        tcven  = iif(tcven>0,mpvencer   * (pcambio -1.00),0)
        tc30   = iif(tc30 >0,mdias30    * (pcambio -1.00),0)
        tc60   = iif(tc60 >0,mdias60    * (pcambio -1.00),0) 
        tc90   = iif(tc90 >0,mdias90    * (pcambio -1.00),0)
        tc120m = iif(tc120m>0,mdias120m * (pcambio -1.00),0)

   C2W_PRINTDATA(LINEA,8,   " Dif por cambios --->","CONSOLAS",8)
   C2W_PRINTDATA(LINEA,40,  TRANSFORM( tcsum, "####,###.##"),"CONSOLAS",8)  //SUMA DE TOTALES
   C2W_PRINTDATA(LINEA,54,  TRANSFORM(tcven, "####,###.##"),"CONSOLAS",8) // PENDIENTE DE VENCER
   C2W_PRINTDATA(LINEA,68,  TRANSFORM(tc30,  "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,82,  TRANSFORM(tc60,  "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,96,  TRANSFORM(tc96,  "####,###.##"),"CONSOLAS",8)
   C2W_PRINTDATA(LINEA,110, TRANSFORM(tc120m,"####,###.##"),"CONSOLAS",8)

      Endif
      TSALDO   += sume      + tcsum
      TSANT    += mpvencer  + tcven
      TDIAS7   += mdias30   + tc30
      TDIAS15  += mdias60   + tc60
      TDIAS30  += mdias90   + tc90
      TDIAS30M += mdias120m + tc120m

      LINEA ++

   IF LINEA >= Xlargo1
      C2W_EJECT()
      cxc44_cab()
   ENDIF
 Endif sume 

SELE A
   SKIP

ENDDO

C2W_PRINTDATA(LINEA,40,  REPLICATE("-",85),"CONSOLAS",8)
LINEA ++
C2W_PRINTDATA(LINEA,30,  "TOTALES->","CONSOLAS",8)
C2W_PRINTDATA(LINEA,40,  TRANSFORM(TSALDO,  "####,###.##"),"CONSOLAS",8)
C2W_PRINTDATA(LINEA,54,  TRANSFORM(TSANT,   "####,###.##"),"CONSOLAS",8)
C2W_PRINTDATA(LINEA,68,  TRANSFORM(TDIAS7,  "####,###.##"),"CONSOLAS",8)
C2W_PRINTDATA(LINEA,82,  TRANSFORM(TDIAS15, "####,###.##"),"CONSOLAS",8) 
C2W_PRINTDATA(LINEA,96,  TRANSFORM(TDIAS30, "####,###.##"),"CONSOLAS",8)
C2W_PRINTDATA(LINEA,110,  TRANSFORM(TDIAS30M, "####,###.##"),"CONSOLAS",8)
CLOSE DATABASES

C2W_ENDWINPRINT()
SET DEVICE TO SCREEN
 


  
RETURN



PROCEDURE cxc44_cab
   
     
  c2w_printdata(1,66-LEN(MEMPRESA)/2, MEMPRESA, "CONSOLAS",8)
  c2w_printdata(2,65-LEN(MEMPRESA)/2, REPLI("-",LEN(MEMPRESA)),"CONSOLAS",8)
  c2w_printdata(2,10, "Tipo de Cambio ->","CONSOLAS",8)
  c2w_printdata(2,40, transform(pcambio,"###.##"),"CONSOLAS",8)
  //c2w_printdata(2,85, transform("FECHA->"DTOC(MFECHA),"CONSOLAS",8)
  c2w_printdata(2,115, "PAGINA->","CONSOLAS",8)
  c2w_printdata(2,124, transform(HOJA,"###"),"CONSOLAS",8)
  c2w_printdata(3,5,   " GRUPO->  " + FNOMBRE,"CONSOLAS",8)
  c2w_printdata(3,50, "DIAS-GRACIA","CONSOLAS",8)
  c2w_printdata(3,70,  transform(MCONDIC,"###"),"CONSOLAS",8)
  c2w_printdata(4,0,   REPLI("-",125),"CONSOLAS",8)
  c2w_printdata(5,4,  "CLAVE","CONSOLAS",8)
  c2w_printdata(5,12,"NOMBRE  ACREEDOR","CONSOLAS",8)
  c2w_printdata(5,42, "  TOTAL  ","CONSOLAS",8)
  c2w_printdata(5,54, " POR VENCER  ","CONSOLAS",8)
  c2w_printdata(5,75, transform(MD1,"####"),"CONSOLAS",8)
  c2w_printdata(5,87, transform(MD2,"####"),"CONSOLAS",8)
  c2w_printdata(5,101,transform(MD3,"####"),"CONSOLAS",8)
  c2w_printdata(5,115,transform(MD4,"####"),"CONSOLAS",8)
  c2w_printdata(6,0, REPLICATE ("-",125),"CONSOLAS",8)

    LINEA = 7 
     hoja ++
 
RETURN


