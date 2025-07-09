*** ARCHIVO: CXC52.PRG
*** NOTA: PROGRAMA PARA INDEXAR
*** MODIFICADO: 11/SEP/98

#include "c2w.ch"

procedure cxc52

PRIVATE VAS,SN,KON1,KON2,KON3,POT,PCT,TOT,CAMPO,CADENA,xeva,msaldo,msaldo2

CLEAR
SN='N'

@ 1,40-LEN(MEMPRESA)/2 SAY MEMPRESA color(fon)

xeva:=10
pot:=1
KON1:=KON2:=KON3:=KON4:=" "

DO WHILE pot > 0
   @  3,16 to 6,60  double
   @  8,24 to 14,50 double 
   @  21,2 to 23,16 double color(fon)
   @  4,25  SAY "MODULO PARA CREACION DE INDICES" color(fon)
   @  5,30  SAY "Modo Exclusivo"
   @  21,7  SAY "Titulo"
   @  22,3  SAY "(û) Ejecutado"
   @  9,25  PROMPT "1.-ARCHIVO CLIENTES    "+KON1
   @ 10,25  PROMPT "2.-ARCHIVO MOVIMIENTOS "+KON2
   @ 11,25  PROMPT "3.-ARCHIVO  GRUPOS     "+KON3
   @ 12,25  prompt "4.-Revisar Consistencia"+KON4
  
  
   SETCOLOR(oldcolor)
   MENU TO POT
   DO CASE
      CASE POT=1
           IF KON1<>" "
              ALERT(" TRABAJO REALIZADO ")
              LOOP
           ENDIF
       SET AUTOPEN OFF
           USE (ARCHIVO) ALIAS CLI EXCLUSIVE
           IF NETERR()
               alert("ARCHIVO OCUPADO ")
               RETURN
            ENDIF
            VAS=LASTREC()
            Ferase((ARCHIVO)+".cdx")
          
              ind()
              Index on Clave tag clave TO (ARCHIVO) Eval { ||INDICA() }
         
              cli->(dbGotop())
              IND()
            
              Index on NOMBRE tag nombre TO (ARCHIVO) Eval { ||INDICA() }
              CLOSE SELECT((ARCHIVO))       
              SET AUTOPEN ON
              KON1="û"


      CASE POT=2
           IF KON2<>" "
              ALERT(" TRABAJO REALIZADO ")
              LOOP
           ENDIF
       SET AUTOPEN OFF
           USE (ARCHCAP) ALIAS CAP EXCLUSIVE new
           IF NETERR()
               alert("ARCHIVO OCUPADO ")
               RETURN
            ENDIF
        
         Ferase((ARCHCAP)+".cdx")

           VAS=LASTREC()
           IND()

            
              Index on clave+tipo+Referencia TAG CLAVE  TO (ARCHCAP) Eval { ||INDICA() }
              CAP->(DBGOTOP())
              ind()
          
              Index on clave+dtos(fecha)+tipo-referencia TAG REFERENCIA TO (ARCHCAP) Eval { ||INDICA() }
              KON2="û"
              CLOSE SELECT((ARCHCAP))       
              SET AUTOPEN ON
      CASE POT=3
            SET AUTOPEN OFF
            USE (FAMIL) ALIAS FAM EXCLUSIVE new
                if neterr()
                   Alert(" ARCHIVO OCUPADO ")
                   return
                endif

                go top
                IND()
                Ferase((FAMIL)+".cdx")
                INDEX ON NOMBRE TAG  NOMBRE TO (FAMIL)  Eval { ||INDICA() }
                KON3="û"

                CLOSE SELECT((FAMIL)) 
                SET AUTOPEN ON
            
 case pot = 4


           conta=0
            @ 14,0 CLEAR

            SELE A
            USE (ARCHIVO)   ALIAS CLI SHARED
            ORDSETFOCUS(1)
            VAS=LASTREC()
            @ 16,1 say "REGISTROS"
            IF NETERR()
               ALERT("ARCHIVO OCUPADO ")
               RETURN
            ENDIF


            @ 16,12 say VAS PICTURE "#####"
            DO WHILE .NOT. cli->(EOF())
               IF CLI->(DBRLOCK())
                  cli->ACTUAL:= .f.
                  cli->SALDO_ACT:= 0.00
                  cli->saldo_ant:= 0.00
                  COMMIT 
                  UNLOCK
               ENDIF
                  CONTA ++
                  @ 16,18 SAY CONTA
                  CLI->(DBSKIP())
             ENDDO
             GO TOP
             INKEY(.15)

           

          SELE B
            CONTA=0

            USE (ARCHCAP) ALIAS CAP SHARED
            ORDSETFOCUS(1)
            VAS=LASTREC()
            IF NETERR()
               ALERT("ARCHIVO OCUPADO ")
               RETURN
            ENDIF
            SET FILTER TO  .NOT.  ACTUAL  //   LOS QUE NO ESTAN PAGADOS 
            CAP->(DBGOTOP())

              INKEY(.2)
             
              SELE B
           DO WHILE .NOT. CAP->(EOF())
              MSALDO := 0
              MSALDO2 :=0
              MCLAVE := CAP->CLAVE

              SELE CLI
              CLI->(DBSEEK(MCLAVE))
                   IF CLI->(EOF())
                      @ 24,10 SAY "NO EXISTE CUENTA "+MCLAVE
                      INKEY(.2)
                        
                       SKIP                
                      LOOP
                   ENDIF

                   REC := CLI->(RECNO())
                 DO WHILE MCLAVE = CAP->CLAVE
                                                        //CARGA EL SALDO PENDIENTE DE PAGO A  CLIENTES
                      MSALDO  += CAP->CARGO
                     
                    CAP->(DBSKIP()) 
                 ENDDO

               SELE A
                    GOTO REC
                    IF cli->(DBRLOCK())
                       CLI->ACTUAL :=.T.
                       CLI->SALDO_ACT := msaldo
                       
                       
                       CLI->(DBUNLOCK())
                       CLI->(DBCOMMIT())
                    ENDIF
                    CONTA ++
                  SELE B
                    
                  @ 16,18 SAY CONTA
           KON4="û"
         
        ENDDO

   ENDCASE
@ 15,11 CLEAR TO 19,68


ENDDO
RETURN


STATIC PROCEDURE IND
@ 14,11 CLEAR TO 19,68
@ 15,11,19,68 BOX "ÚÄ¿³ÙÄÀ³"
@ 18,14 SAY "0..........25..........50............75..........100"
@ 17,15 SAY SPACE(50)
@ 17,14 SAY "Þ"
RETURN

STATIC FUNC INDICA
Pct = round((RECNO()/lastrec())*100,0)
*@ 14,50 SAY PCT PICTURE "###."
IF PCT<100
   @ 17,15 SAY REPLICATE("Û",(Pct/2)+1)
ENDIF
RETURN .T.
           