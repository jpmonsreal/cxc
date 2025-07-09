**** PROGRAMA   : CXC36.PRG
** PROCESO    : REPORTE DE TRANSACCIONES
** FECHA      : DCONVERT AGO 86 JP CLIP5-01 SEPT 91


#include "c2w.ch"
procedure cxc36

Local  tcargos:=tabonos:=tsaldo_act:=gsaldo_act:=gcargos:=gabonos:=0,;
       xcargos:=xabonos:=paso:=hdc:=0,fven:=PDATE,;
       op:=pech:=" ",mclave1,opcion:="N",fdate:=pdate

PRIVATE HOJA,LINEA,NFECHA:=PDATE,PASO:=.F., XLARGO1:=MLARGO

        CLEAR
      
@ 2,2   SAY MEMPRESA    COLOR(fon)
@ 2,45  SAY " REPORTE  DE  TRANSACCIONES "   COLOR(fon)
       
@ 3,2   SAY REPLI("Í",78)
@ 5,2   SAY "FECHA DE IMPRESION"
@ 5,26  SAY RMES
@ 5,37  SAY "DESEA CAMBIAR FECHA->" GET NFECHA
        READ
@ 5,67  SAY "MES->"
@ 5,75  SAY MONTH(NFECHA)
@ 6,37  SAY "DESEA IMPRIMIR TODO EL MES " GET OPCION PICTURE "!"
        READ

SELE A
USE (ARCHIVO) ALIAS CLI SHARED

IF NETERR()
   ALERT("ARCHIVO OCUPADO ")
   RETURN
ENDIF   

cli->(ordSetFocus(1))  


SELE B
USE (ARCHCAP) ALIAS CAP SHARED
IF NETERR()
   ALERT("ARCHIVO OCUPADO")
   RETURN
ENDIF   
 
cap->(ordSetFocus(1))

if opcion = "N"
   set filter to fecha=nfecha  
else
   set filter to MONTH(FECHA)=MONTH(nfecha) .and. Year(fecha)=year(nfecha)
endif

cap->(DBGOTOP())

sele b
         

             PASO:=.T.
             HOJA:=1
             LINEA:=1
             
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



   CXC36_CAB()

 DO WHILE .NOT. Cap->(EOF())
    
      
MCLAVE1=Cap->CLAVE
        Cli->(DBSEEK(MCLAVE1))
    IF  Cli->(Found())
        LINEA++ 
       * LINEA,18,Cli->TIPO
       c2w_printdata(LINEA,20,Cli->CLAVE,"consolas",8)
       c2w_printdata(LINEA,30,Cli->NOMBRE,"consolas",8)
         linea++
       //c2w_printdata(LINEA,30,REPLI("-",LEN(CLI->NOMBRE)),"consolas",8)
     //    LINEA++  
         IF LINEA >= XLARGO1
            C2W_EJECT()
            CXC36_CAB()
         ENDIF
       ELSE
       c2w_printdata(Linea,18," CLIENTE NO REGISTRADO CON MOVIMIENTOS ","consolas",8)
         LINEA++
    ENDIF EOF
 
                     
DO WHILE CAP->CLAVE=MCLAVE1 .AND. .NOT. CAP->(EOF())

           DIAS :=(PDATE-FDATE) - cap->condic
           FVEN :=fdate + CAP->CONDIC

c2w_printdata(LINEA,20, Cap->tipo,"consolas",8)
c2w_printdata(LINEA,24, Cap->REFERENCIA,"consolas",8)
c2w_printdata(LINEA,33, Transform(Cap->fecha,"##-##-####"),"consolas",8)
c2w_printdata(LINEA,45, Transform(Cap->F_vencim,"##-##-####"),"consolas",8)
c2w_printdata(LINEA,57, substr(cap->CONCEPTO,1,23),"consolas",8)
       
c2w_printdata(linea,82, transform(Cap->CARGO,"#####,###.##"),"consolas",8)
           tcargos += Cap->cargo
        
c2w_printdata(linea,98, transform(Cap->ABONO,"#####,###.##"),"consolas",8)
           tabonos += Cap->abono
 

  

       Cap->(DBskip())
          linea++

       IF LINEA >= XLARGO1
          c2w_eject()
          CXC36_CAB()
       ENDIF
	 
 ENDDO

ENDDO

c2w_printdata(LINEA,82,  REPLICATE("-",33),"consolas",8)
	   LINEA ++
c2w_printdata(LINEA,53, "SUMA TOTALES ","consolas",8)
c2w_printdata(LINEA,82, transform(TCARGOS,"####,###.##"),"consolas",8)
c2w_printdata(LINEA,98,  transform(TABONOS,"####,###.##"),"consolas",8)
           
           c2w_endwinprint()
           SET DEVICE  TO SCREEN
          
       
  
  RETURN


PROCEDURE  CXC36_CAB
 
c2w_printdata(1,50,  MEMPRESA,"consolas",8)
c2w_printdata(2,55,  "REPORTE DE TRANSACCIONES","consolas",8)
c2w_printdata(2,95,  "HOJA :","consolas",8)
c2w_printdata(2,105, transform(HOJA,"##"),"consolas",8)
c2w_printdata(3,30,  MCIUDAD,"consolas",8)
c2w_printdata(3,90,  NFECHA,"consolas",8)
c2w_printdata(4,19,  "+----------+----------+----------+----------------------------+---------------+--------------+","consolas",8)
c2w_printdata(5,19,  "|REFERENCIA|FECHA/DOC |FECHA/MOV |     CONCEPTO               |      CARGOS   |    ABONOS    |","consolas",8)
c2w_printdata(6,19,  "+----------+----------+----------+----------------------------+---------------+--------------+","consolas",8)
        HOJA++
        LINEA = 8
   RETURN


return
