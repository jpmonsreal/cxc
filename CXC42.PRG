    
** PROGRAMA   : CXC42.PRG  
** PROCESO    : ESTADO DE CUENTAS CON ANTIGUEDAD DE SALDOS
** AUTOR      : JP-4-88                   


#include "c2w.ch"
procedure cxc42   

PRIVATE  HOJA:=MPVENCER:=MDIAS30:=MDIAS60:=MDIAS90:=MDIAS120M:=0,;
   ADETOTAL:=SPVENCER:=SDIAS30:=SDIAS60:=SDIAS90:=SDIAS120M:=0,;
   SDETOTAL:=CDETOTAL:=LINEA:=HD:=mcargos:=mabonos:=dias:=ct:=0,;
     OPCION:=" ",ADETOT:="ADEUDO TOTAL",MCLIENTE:=SPACE(4),;
      LETRA:="ADEUDOS PENDIENTES"
private paso:=.f.,HOJAX,MCLAVE1
	 
       CLEAR
          
@ 2,1  SAY MEMPRESA    COLOR(fon)
@ 2,40 SAY "ESTADO DE CUENTA CLIENTE SELECCIONADO "   COLOR(fon)
      

SELE A

USE (ARCHIVO) ALIAS CLI SHARED

IF NETERR()
   ALERT("ARCHIVO EN USO ")
   RETURN
ENDIF
CLI->(OrdSetFocus(1)) 
CLI->(DBGOTOP())
SELE B
USE (ARCHCAP) ALIAS CAP SHARED 

IF NETERR()
   ALERT("ARCHIVO EN USO ")
   RETURN
ENDIF   
Cap->(OrdSetFocus(1))   
Cap->(DBGOTOP())

DO WHILE .T.
  mcliente=space(4)                 
 
@ 5,5  SAY "FECHA DE TRABAJO"
@ 5,25 SAY PDATE
@ 5,35 SAY RMES
@ 6,5 SAY "ANOTAR CLAVE CLIENTE" GET MCLIENTE PICTURE "!!!!"
      READ
      IF MCLIENTE=SPACE(4)
        set exact on
        RETURN 
      ENDIF

    Cli->(DBSEEK(MCLIENTE))
      IF Cli->(EOF())
         Alert(" CLIENTE NO REGISTRADO ")
         LOOP   
       ENDIF
 @ 7,3  SAY Cli->TIPO
 @ 7,5  say Cli->clave+space(2)+Cli->nombre
       MCLAVE1    :=Cli->CLAVE 
       XNOMBRE    :=Cli->NOMBRE 
       XDIRECCION :=Cli->DIRECCION
       XCIUDAD    :=Cli->CIUDAD 
       XTIPO      :=Cli->TIPO

  Cap->(DBSEEK(MCLAVE1))
      IF Cap->(EOF())
         alert(" NO TIENE MOVIMIENTOS PENDIENTES ")
         LOOP
      ENDIF   

  
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

    HOJAX:=1
    paso:=.t.
    
    CXC42_print()



DO WHILE Cap->CLAVE = MCLAVE1 .AND. .NOT. Cap->(EOF())

    ref=substr(Cap->referencia,1,3)

   

  IF  (Cap->CARGO - (Cap->ABONO + cap->abono2)) = 0
     skip
     LOOP
  ENDIF

            
           if mfcontrol
              fdate:=iif(month(cap->fecha_cap)=0,cap->fecha,cap->fecha_cap)
           else
              fdate:= cap->fecha
           endif
           DIAS :=PDATE-FDATE

           FVEN :=fdate+CAP->CONDIC

c2w_printdata(LINEA,6, SUBSTR(Cap->REFERENCIA,1,3),"CONSOLAS",8)
c2w_printdata(LINEA,13, SUBSTR(Cap->REFERENCIA,4,5),"CONSOLAS",8)
c2w_printdata(LINEA,21, transform(fdate,"##-##-####"),"CONSOLAS",8)                 
c2w_printdata(LINEA,32, transform(FVEN, "##-##-####"),"CONSOLAS",8)
           mcargo :=Cap->cargo
           mabono :=Cap->abono
   DO CASE
CASE DIAS<MD1 
     col2     :=43 
     mpvencer += mcargo
     spvencer += mcargo

case dias>=MD1 .and. dias<=MD2
     col2     :=59 
     mdias30  += mcargo
     sdetotal += mcargo

case dias>=MD2 .and. dias<=MD3
     col2    :=75
     mdias60 += mcargo
     sdias60 += mcargo

case dias>=MD3 .and. dias<=MD4
     col2    :=91
     mdias90 += mcargo
     sdias90 += mcargo

case dias>=MD4              
     col2      :=107 
     mdias120m += mcargo
     sdias120m += mcargo

ENDCASE
     adetotal += mcargo
     cdetotal += mcargo
  c2w_printdata(linea,col2, transform(MCARGO,"####,###.##"),"consolas",8)

      Cap->(DBSKIP())

         LINEA++
      IF LINEA >= mlargo
         c2w_eject()
         cxc42_print()
      ENDIF

ENDDO

c2w_printdata(@ LINEA,9,replicate("-",114),"CONSOLAS",8)
            LINEA ++ 
c2w_printdata(LINEA,10, ADETOT,"CONSOLAS",8)
c2w_printdata(LINEA,26, TRANSFORM(ADETOTAL,"####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,43, TRANSFORM(MPVENCER,"####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,59, TRANSFORM(MDIAS30,"####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,75, TRANSFORM(MDIAS60,"####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,91, TRANSFORM(MDIAS90,"####,###.##"),"CONSOLAS",8)
c2w_printdata(LINEA,107,TRANSFORM( MDIAS120M,"####,###.##"),"CONSOLAS",8)
            LINEA += 2 
            ADETOTAL:=MPVENCER:=MDIAS30:=MDIAS60:=MDIAS90:=MDIAS120M:=0

 c2w_printdata(LINEA,9, "FAVOR DE PAGAR SALDOS VENCIDOS EN MONEDA NACIONAL","CONSOLAS",8)
  
    linea ++

   C2W_ENDWINPRINT()
   SET DEVICE TO SCREEN
   
    LOOP
    ENDDO   
     
RETURN  


procedure cxc42_print
          
      ct=(120-len(mempresa))/2
C2W_PRINTDATA(1,ct, mempresa,"CONSOLAS",8)
C2W_PRINTDATA(2,5,  mclave1,"CONSOLAS",8)
C2W_PRINTDATA(2,10, xNOMBRE,"CONSOLAS",8)
C2W_PRINTDATA(3,10,  letra,"CONSOLAS",8)   
C2W_PRINTDATA(4,10,  TRANSFORM(PDATE,"##-##-####"),"CONSOLAS",8)
C2W_PRINTDATA(4,45,  RMES,"CONSOLAS",8)
C2W_PRINTDATA(4,65,  "HOJA :","CONSOLAS",8)
C2W_PRINTDATA(4,75,  TRANSFORM(hoja,"###"), "CONSOLAS",8)                                                                                                
C2W_PRINTDATA(5,9,   "------------------------------------------------------------------------------------------------------------------+","CONSOLAS",8)
C2W_PRINTDATA(6,9,  "|   INVOICE|  FECHA   |FECHA LIMI|      POR      | VENCIDO DIAS  |  VENCIDO DIAS |  VENCIDO DIAS |   VENCIDO DIAS |","CONSOLAS",8)
C2W_PRINTDATA(7,9,  "|No.FACTURA| ENTRADA  |TE DE VENC|    VENCER     |","consolas",8)
C2W_PRINTDATA(7,63,  TRANSFORM(MD1,"###"),"CONSOLAS",8)
C2W_PRINTDATA(7,74,  "|","CONSOLAS",8)
C2W_PRINTDATA(7,78,  TRANSFORM(MD2,"###"),"CONSOLAS",8)
C2W_PRINTDATA(7,90,   "|","CONSOLAS",8)
C2W_PRINTDATA(7,95,  TRANSFORM(MD3,"###"),"CONSOLAS",8)
C2W_PRINTDATA(7,106,  "|","consolas",8)
C2W_PRINTDATA(7,111, TRANSFORM(MD4,"###"),"CONSOLAS",8)
C2W_PRINTDATA(7,123,  "|","CONSOLAS",8)
C2W_PRINTDATA(8,9,    "+-----------------------------------------------------------------------------------------------------------------+","CONSOLAS",8) 
    LINEA = 10
    HOJAX++
 
RETURN