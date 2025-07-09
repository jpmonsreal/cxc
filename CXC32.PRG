*** PROGRAMA  : CXC32.PRG  
** PROCESO    : REPORTE DE ANTIGUEDAD DE SALDOS
** AUTOR      : JP 4-88  //jp 2010 
    
#include "c2w.ch"
procedure cxc32

LOCAL COL2:=MCARGO:=MABONO:=DIAS:=MDIAS:=MDIAS30:=0
LOCAL MDIAS60:=MDIAS90:=MDIAS120M:=MDETOTAL:=0,FVEN
LOCAL TDIAS:=TDIAS30:=TDIAS60:=TDIAS90:=TDIAS120M:=TDETOTAL:=0 
LOCAL MES:=SPACE(10), LOPCION:=SPACE(1)
LOCAL GUION:='--------------',mclave1, OP

PRIVATE mfecha:=pdate,letrero:="LISTANDO ANTIGUEDAD DE SALDOS "
private Paso:=.f.,linea:=1,XLARGO1:=mlargo,hoja:=1
CLEAR

DO WHILE .T.
  

   SELE A
   USE (ARCHIVO) SHARED ALIAS CLI
   cli->(OrdSetFocus(2))
    //SET FILTER TO     ACTUAL
    cli->(DBGOTOP())

  SELE B
   USE (ARCHCAP) SHARED ALIAS CAP
   CAP->(ordSetFocus(1))

   SET FILTER TO  .NOT.   ACTUAL
   GO TOP
      
            
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
  cxc32_cab()
      
   DO WHILE .NOT. EOF()
      SELE A
      MCLAVE1:=CLI->CLAVE
      MNOMBRE:=CLI->NOMBRE
      MMTIPO:= CLI->TIPO
      SELE B
       SET SOFTSEEK ON
       SEEK MCLAVE1
   
  IF clave <> mclave1
       SELE A
       SKIP
       LOOP
   ENDIF
         linea ++

       IF linea >= xLARGO1
          c2w_eject()
          CXC32_CAB() 
      ENDIF

        c2w_printdata(linea,8,MCLAVE1,"consolas",8)

       IF MMTIPO="D"
         c2w_printdata(linea,14, MNOMBRE+" **","consolas",8)
       ELSE
        c2w_printdata(linea,14,MNOMBRE,"consolas",8) 
       ENDIF
  
         linea ++

      IF linea >= xLARGO1
         c2w_eject()
         CXC32_CAB() 
      ENDIF

      MDETOTAL:=MDIAS:=MDIAS30:=MDIAS60:=MDIAS90:=MDIAS120M:=0
      DOLDIAS:=DOLS:=DOLS30:=DOLS60:=DOLS90:=DOLS120M:=0

      SELE B
   DO WHILE MCLAVE1 = CLAVE .AND. .NOT. EOF()
           if mfcontrol
              fdate:=iif(month(fecha_cap)=0,cap->fecha,cap->fecha_cap)
           else
              fdate:=cap->fecha
           endif
           
         
         c2w_printdata(linea,8,TIPO,"consolas",8) 
         c2w_printdata(linea,12,REFERENCIA,"consolas",8)
         c2w_printdata(linea,20,Transform(FECHA,"##-##-##"),"consolas",8)
           DIAS     = (PDATE-FDATE)- cap->condic
           FVEN     = cap->FECHA+cap->CONDIC
         c2w_printdata(linea,31,Transform(FVEN,"##-##-##"),"consolas",8)
           MCARGO   = CARGO // - ABONO     
           MCONCEPTO = CONCEPTO 

         DO CASE
            CASE DIAS < MD1
                 MDIAS += MCARGO
                 TDIAS += MCARGO
                 COL2  :=43
            CASE DIAS >= MD1 .AND. DIAS <= MD2
                 MDIAS30 += MCARGO
                 TDIAS30 += MCARGO
                 COL2    :=59
            CASE DIAS >= MD2 .AND. DIAS <= MD3
                 MDIAS60 += MCARGO              
                 TDIAS60 += MCARGO
                 COL2    :=75
            CASE DIAS >= MD3 .AND. DIAS <= MD4
                 MDIAS90 += MCARGO                     
                 TDIAS90 += MCARGO
                 COL2    :=91
            CASE DIAS >= MD4             
                 MDIAS120M += MCARGO                     
                 TDIAS120M += MCARGO
                 COL2      := 107
         ENDCASE
         MDETOTAL += MCARGO
         TDETOTAL += MCARGO

         c2w_printdata(linea,COL2,Transform(MCARGO,"####,###.##"),"consolas",8)

         linea ++

         IF linea >= xLARGO1
           c2w_eject()
           CXC32_CAB()
        ENDIF

       SKIP
   ENDDO

      c2w_printdata(linea,43,  GUION,"consolas",8)
      c2w_printdata(linea,59,  GUION,"consolas",8)
      c2w_printdata(linea,75,  GUION,"consolas",8)
      c2w_printdata(linea,91,  GUION,"consolas",8)
      c2w_printdata(linea,107, GUION,"consolas",8)
      linea++ 
        
      IF linea >= xLARGO1
         c2w_eject() 
         CXC32_CAB()        
      ENDIF

      c2w_printdata(linea,26,  transform(MDETOTAL,"####,###.##"),"consolas",8)
      c2w_printdata(linea,43,  transform(MDIAS,  "####,###.##"),"consolas",8)
      c2w_printdata(linea,59,  transform(MDIAS30,"####,###.##"),"consolas",8)
      c2w_printdata(linea,75,  transform(MDIAS60,"####,###.##"),"consolas",8)
      c2w_printdata(linea,91,  transform(MDIAS90,"####,###.##"),"consolas",8)
      c2w_printdata(linea,107, transform(MDIAS120M,"####,###.##"),"consolas",8)

        IF MMTIPO="D"
           linea ++

            IF linea >= xLARGO1 
              CXC32_CAB()        
            ENDIF

       DOLSTOTAL:= MDETOTAL  * (PCAMBIO -1.00)     
       DOLS     := MDIAS     * (PCAMBIO -1.00)
       DOLS30   := MDIAS30   * (PCAMBIO -1.00)
       DOLS60   := MDIAS60   * (PCAMBIO -1.00)
       DOLS90   := MDIAS90   * (PCAMBIO -1.00) 
       DOLS120M := MDIAS120M * (PCAMBIO -1.00) 
           
      c2w_printdata(linea,8,  "CAMBIOS Dl -1" ,"consolas",8)  
      c2w_printdata(linea,26, transform(DOLSTOTAL,"####,###.##"),"consolas",8)     
      c2w_printdata(linea,43, transform(DOLS,     "####,###.##"),"consolas",8)
      c2w_printdata(linea,59, transform(DOLS30,   "####,###.##"),"consolas",8)
      c2w_printdata(linea,75, transform(DOLS60,   "####,###.##"),"consolas",8)
      c2w_printdata(linea,91, transform(DOLS90,   "####,###.##"),"consolas",8)
      c2w_printdata(linea,107,transform(DOLS120M, "####,###.##"),"consolas",8)


          TDETOTAL  += DOLSTOTAL      
          TDIAS     += DOLS     
          TDIAS30   += DOLS30   
          TDIAS60   += DOLS60   
          TDIAS90   += DOLS90  
          TDIAS120M += DOLS120M
     ENDIF

      linea ++ 
    
        IF linea >= xLARGO1
            c2w_eject()
            CXC32_CAB()          
        ENDIF
   
     SELE A     // AQUI AVANZA EL ARCHIVO DE CLIENTES
        SKIP
 ENDDO

   linea ++ 
   c2w_printdata(linea,43, GUION,"consolas",8)
   c2w_printdata(linea,59, GUION,"consolas",8)
   c2w_printdata(linea,75, GUION,"consolas",8)
   c2w_printdata(linea,91, GUION,"consolas",8)
   c2w_printdata(linea,107,GUION,"consolas",8)
   linea ++                                             
   c2w_printdata(linea,10, "TOTAL GENERAL","consolas",8)
   c2w_printdata(linea,26, transform(TDETOTAL,"####,###.##"),"consolas",8)
   c2w_printdata(linea,43, transform(TDIAS,   "####,###.##"),"consolas",8)
   c2w_printdata(linea,59, transform(TDIAS30, "####,###.##"),"consolas",8)
   c2w_printdata(linea,75, transform(TDIAS60, "####,###.##"),"consolas",8)
   c2w_printdata(linea,91, transform(TDIAS90, "####,###.##"),"consolas",8)
   c2w_printdata(linea,107,transform(TDIAS120M,"####,###.##"),"consolas",8)
 
     c2w_endwinprint()             
     SET DEVICE TO SCREEN   
  
   EXIT
ENDDO
RETURN


PROCEDURE CXC32_CAB

 
c2w_printdata(1,36, MEMPRESA,"consolas",8)
c2w_printdata(2,36, REPLI("-",LEN(MEMPRESA)),"consolas",8)
c2w_printdata(3,8,   "DIAS/GRACIA","consolas",8)
c2w_printdata(3,23,  transform(MCONDIC,"###"),"consolas",8)
c2w_printdata(3,35,  LETRERO,"consolas",8) 
c2w_printdata(3,69,  "T.C.","consolas",8)
c2w_printdata(3,74,  transform(PCAMBIO,"###.##"),"consolas",8)
c2w_printdata(3,84,  transform(PDATE ,"##-##-####"),"consolas",8)                                                        
c2w_printdata(3,100, "HOJA","consolas",8)
c2w_printdata(3,107, transform(HOJA,"###"),"consolas",8)     
//              1         2         3         4         5         6         7         8         9        10        11        12
//     1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
c2w_printdata(4,8,    "+-----------+----------+----------+------------+---------------+---------------+---------------+----------------+","consolas",8)
c2w_printdata(5,8,    "|   No. DE  |  FECHA   | FECHA DE |    DIAS    |  VENCIDO DIAS |  VENCIDO DIAS |  VENCIDO DIAS |VENCIDO DIAS    |","consolas",8)
c2w_printdata(6,8,    "|  FACTURA  | SERVICIO | VENCIMTO |  VENCIDO   |","consolas",8)
c2w_printdata(6,61,   transform(MD1, "####"),"consolas",8)
c2w_printdata(6,77,   transform(MD2, "####"),"consolas",8)
c2w_printdata(6,93,   transform(MD3, "####"),"consolas",8)
c2w_printdata(6,106,  transform(MD4, "####"),"consolas",8)
c2w_printdata(6,120,  "|","consolas",8)
c2w_printdata(7,8,    "+-----------+----------+----------+------------+--------------+----------------+----------------+---------------+","consolas",8)
  linea = 8     
  hoja++ 
RETURN 
   

