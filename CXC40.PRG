**** PROGRAMA   : CXC40            
** PROCESO    : REPORTE DE HISTORICO DE FACTURAS PAGADAS
** AUTOR      : JP-4-88 

     
#include "c2w.ch"

procedure cxc40

LOCAL gsaldo_act:=gcargos:=gabonos:=tcargos:=tabonos:=tsaldo_act:=0,;
      opcion:=" ",m_clave,mclave1,OP

  private FLAG:=.F.,XCLAVE,PASO:=.F.,MCARGOX:=0.00
  PRIVATE HOJA,LINEA,pas:=1

 

      CLEAR
      SET EXACT OFF
      OPCION  :="?"
      FLAG    :=" "
      XCLAVE  :=SPACE(4)
      M_CLAVE :=SPACE(4)

SELE A
USE (ARCHIVO) ALIAS CLI SHARED
IF NETERR()
   ALERT("ARCHIVO OCUPADO ")
   RETURN
ENDIF
Cli->(OrdSetFocus(1))   
Cli->(dbgotop())  

SELE B
USE (ARCHCAP) ALIAS CAP SHARED
IF NETERR()
   ALERT("ARCHIVO OCUPADO ")
   RETURN
ENDIF   
Cap->(OrdSetFocus(1))   
Cap->(dbgotop())  
         
  @ 2,2   SAY MEMPRESA COLOR(fon)
  @ 2,45  SAY "REPORTE HISTORICO DE DOCUMENTOS" COLOR(fon)
          
  @ 5,2   SAY " FECHA DE IMPRESION "
  @ 5,25  SAY RMES
  @ 5,37  SAY PDATE



  cALIAS:=Select()

  DO WHILE .T.
       xclave=space(4)               
       FLAG:=.F.
       @ 12,15 SAY "<ANOTAR CLAVE ENTIDAD" GET XCLAVE PICTURE "!!!!"
	 READ
       FLAG:=.T.
               if xclave=space(4)
                  return
               endif

	 Cli->(DBSEEK(XCLAVE))

	       IF Cli->(EOF())
                alert(" ENTIDAD NO REGISTRADA ")
                LOOP
	     ENDIF
         M_CLAVE=Cli->CLAVE
  @ 14,0
  @ 14,15 SAY Cli->CLAVE
  @ 14,21 SAY Cli->NOMBRE
  @ 14,52 say Cli->Saldo_act picture "9999,999.99"
	 
   CAP->(DBSEEK(M_CLAVE,.T.))
   IF CAP->(EOF())
      ALERT("NO SE ENCONTRARON MOVIMIENTOS LIGADOS")
      LOOP
   ENDIF
 FLAG="*"
	
      
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
    HIJA:=1
     HOJA  :=0
     store 0 to Tcagos,Tabonos

           

   C40_PN()

DO WHILE CAP->CLAVE=M_CLAVE .AND. .NOT. CAP->(EOF())

c2w_printdata(LINEA,16, SUBSTR(Cap->REFERENCIA,1,3),"consolas",8)
c2w_printdata(LINEA,20, SUBSTR(Cap->REFERENCIA,4,5),"consolas",8)
c2w_printdata(LINEA,28, transform(Cap->FECHA,"99-99-9999"),"consolas",8)
c2w_printdata(LINEA,42, Cap->FECHA_CAP,"consolas",8)
c2w_printdata(LINEA,60, cap->CONCEPTO,"consolas",8)

          IF cap->SERIE = 2
     c2w_printdata(linea,84,transform(MCARGOX,"####,###.##"),"consolas",8)
          ELSE
     c2w_printdata(linea,84,transform(Cap->CARGO,"####,###.##"),"consolas",8)
           tcargos  += Cap->cargo
          ENDIF
        
      c2w_printdata(LINEA,104,transform(CAP->ABONO,"####,###.##"),"consolas",8)
           tabonos += Cap->abono
             LINEA ++ 
         Cap->(Dbskip())
     
	     IF LINEA >= mLARGO  // publica
               c2w_eject()
               c40_pn()         
	     ENDIF

	                           

   ENDDO


              linea ++ 
c2w_printdata(Linea,84,   "-----------","consolas",8)
c2w_printdata(linea,104,  "-----------","consolas",8)
             linea ++ 
c2w_printdata(LINEA,20, "SUMA  TOTAL","consolas",8)
c2w_printdata(linea,50, transform(tcargos-tabonos,"####,###.##"),"consolas",8)
c2w_printdata(linea,84, transform(TCARGOS,"####,###.##"),"consolas",8)
c2w_printdata(linea,104,transform(TABONOS,"####,###.##"),"consolas",8)
             
             c2w_endwinprint()
             SET DEVICE TO SCREEN

      
     EXIT
  ENDDO
  
   RETURN


procedure c40_pn
c2w_printdata(1,20, MEMPRESA,"consolas",8)
c2w_printdata(2,20, MDIRECC,"consolas",8)
c2w_printdata(2,55, "REPORTE HISTORICO DE DOCUMENTOS ","consolas",8)
c2w_printdata(2,95, "HOJA :","consolas",8)
c2w_printdata(2,105, transform(HOJA,"##"),"consolas",8)
c2w_printdata(3,20,  MCIUDAD,"consolas",8)
c2w_printdata(3,90,  transform(PDATE,"##-##-####"),"consolas",8)
c2w_printdata(4,20,  CLI->CLAVE+"  "+CLI->NOMBRE+" "+transform(cli->saldo_act,"9999,999.99"),"consolas",8)                                                                        
c2w_printdata(5,16,  "+--------------------------------------------------------------------------------------------------+","consolas",8)
c2w_printdata(6,16,  "|REFERENCIA³  FECHA   ³F.ENTRADA ³     CONCEPTO                      ³   CARGOS    ³    ABONOS     |","consolas",8)
c2w_printdata(7,16,   "+-------------------------------------------------------------------------------------------------+","consolas",8)
    LINEA = 8     
    Hoja++
   RETURN



