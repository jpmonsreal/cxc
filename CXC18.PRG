
***PROGRAMA   : CXP18.PRG prototiopo
** PROCESO    : CAPTURA DE PAGOS
** mcondic  variable publica dias gracia pago

#include "dbedit.ch"
#include "SetCurs.Ch"
#include "std.ch"
#include "set.ch"
#include "inkey.ch"
#include "Box.ch"
#include "c2w.ch"


procedure cxc18

Local   NW

Private flag10:=flag:=.F.,xclave,linea:=0,mcargo:=0,VS:=.F.,TOTALE:=0
private deptox:={},mfam,mnom,mfecha_Fac,mcontrarec,MREC,MSUM
private xclave,cAlias,datus,FLAGCH:=.F.,pazo,Clirec,nevent:=" "
private paso,gClave,mconcepto,PASO:=3



MFECHA3:=MFECHA1:=mfecha_fac:=XFECHA:=pdate
store 0 to control,msum,dias

dato     = .T.
KONT   = " "
opcion  = " "
MCARGO=0.00
CLOSE DATABASES
CLEAR
datus:=.t.

SELE A
USE (ARCHCAP)  ALIAS CAP SHARED new
    IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF
CAP->(OrdSetFocus(1))
SET FILTER TO .NOT.  ACTUAL   //F status pendiente de pago
cap->(dbgotop())

SELE B
USE (ARCHIVO) ALIAS CLI SHARED new
     IF NETERR()
       ALERT("ARCHIVO EN USO ")
       RETURN
    ENDIF
CLI->(OrdSetFocus("nombre"))
SET FILTER TO  ACTUAL       //  T  status de activo con saldos

cli->(dbgotop())

cAlias:=select()

******************
paso:=3  //FUNCION TBROWSE
SELE  B
CXC10BR()
return

PROCEDURE MODIFICA18(RECORX)

CLI->(DBGOTO(RECORX))



DO WHILE .T.      && Principal

   pant18()

   SELE B
   
   dato     := .T.
   flag      := .f.
   MSUM  := 0
   TOTALE := 0

  @ 3,12 say cli->CLAVE   COLOR(FON)
  @ 3,28 say cli->nombre  COLOR(FON)
  @ 3,65 say Cli->saldo_act  picture "99999,999.99" 
  gClave := Cli->Clave
 cliRec  := cli->(recno())

   IF LASTKEY()=27
      EXIT
   ENDIF

  cap->(dbseek(gclave))
        
     
      DO WHILE cap->Clave = gClave   .AND.  .NOT.  EOF()       
                
         dias = pdate - (CAP->fecha+CAP->condic)
         @ linea,1 say  Cap->(Recno())  picture "#####" 
         @ linea,7  say CAP->tipo
         @ linea,11 say CAP->referencia
         @ linea,19 say CAP->fecha
         * linea,26 say CAP->contrarec 
         @ linea,33 say substr(CAP->concepto,1,20)
         @ linea,64 SAY CAP->cargo     picture "##,###,###.##"
         MSUM += CAP->cargo
         CAP->(DBSKIP())
         linea ++
         @ 22,64 SAY MSUM PICTURE "##,###,###.##"
            
         IF linea > 20
            
            @ 22,1 SAY "[Enter] Siguiente Pagina..." get nevent picture " "
            read
            LINEA:=8
            @ 7,0 CLEAR
         ENDIF

      ENDDO

*************************************** CAPTURA **************
           CAPOP= .T.
      DO WHILE CAPOP

      CAP->(DBGOTOP())
          opter := .F.
      @ 23,0 CLEAR
            MFAM     = SPACE(3)
            MREFEREN = SPACE(5)
            mRec:= 0
            MCARGO = 0.00
            MABONO = 0.00
             
          
           @ 23,15 say "Elija un Registro-> " get mrec picture "99999"
                       read   
           IF MREC > 0
             cap->(dbgoto(mRec))

             IF  CAP->CLAVE <> GCLAVE  .or. cap->actual 
                  ALERT("DATO NO COINCIDENTE  o PAGADO")
                  LOOP
             ENDIF

             @ 23,0 clear
             EXIT
         ELSE 
             RETURN
          ENDIF

   ENDDO // VALIDA REGISTRO CAPOP
**********************************************************************************
   CAPTU =.T.

 DO WHILE CAPTU
      MCARGO=0.00
    @ 1, 12 SAY "   PAGANDO   ADEUDOS   "  color(FONe)
     TOTE=SAVESCREEN(4,8,16,35)
 
    c2w_boxraised(5,8,16,35,"bora")
    HB_Shadow(5,8,16,35) 

MCLAVE      := CAP->CLAVE
MTIPO       := CAP->TIPO
MREFERENCIA := CAP->REFERENCIA
MFECHA      :=  CAP->FECHA
MCARGO      := CAP->CARGO
MABONO      := CAP->ABONO
MACTUAL     := CAP->ACTUAL
MCONCEPTO   := SPACE(30)       //CAP->CONCEPTO
MABONO2     := 0

      @ 5,8 CLEAR to 16,35

      @ 6,10  SAY PADL("CLAVE:",11)    + " " + MCLAVE
      @ 7,10  SAY PADL("FAMILIA:",11)  +" " +  MTIPO           
      @ 8,10  say PADL("ACTUAL:",11)  +" " + TRANSFORM(MACTUAL,"L")
      @ 9,10  SAY PADL("REFERENCIA:",11)+" "+ MREFERENCIA                 
      @ 10,10 SAY PADL("FECHA:",11)   +" "+ TRANSFORM(MFECHA,"##-##-####")         
      @ 11,10 SAY PADL("ADEUDO:",11)  +" "+ TRANSFORM(MCARGO,"9999,999.99")            
      @ 12,10 SAY PADL("PAGO:",11)    GET MABONO  PICTURE "9999,999.99" 
                   READ
      @ 13,10  SAY PADL("CONCEPTOS:",11)
      @ 14,10  GET MCONCEPTO PICTURE "@!S25"  
                   READ 
                   MABONO2 := MCARGO - MABONO
     @ 15,10  SAY PADL("PENDIENTE:",11)    
     @ 15,21  SAY MABONO2  PICTURE "9999,999.99"    
                   TOTALE := MSUM - MABONO

                    IF MABONO = 0
                        ALERT("SE REQUIERE REGISTRAR UN PAGO"+CHR(13)+ "MAYOR QUE CERO*****")
                        c2w_deletecontrol("bora")
                        LOOP
                    ENDIF
    

   IF c2w_MSGYESNO(" DESEA GRABAR EL PAGO ","SELECCIONAR UNA OPCION ")
      c2w_deletecontrol("bora")
       ELSE
      c2w_deletecontrol("bora") 
           RETURN
      ENDIF

 
SELE A

     IF CAP->(DBRLOCK())
           CAP->CONCEPTO := MCONCEPTO
           CAP->ABONO    :=MABONO
            CAP->ABONO2  :=MABONO2
           CAP->FECHA    := PDATE    // fecha del sistema para poner al dia 
           cap->ACTUAL   :=  .T.    //  T  staus de PAGADO

            CAP->(FLOCK())
           CAP->(DBCOMMIT())         
      ENDIF                   
                          
       IF MABONO2 > .01

     IF CAP->(FLOCK())
           CAP->(DBAPPEND())
           CAP->CLAVE        := MCLAVE
           CAP->TIPO         := MTIPO
           CAP->REFERENCIA   := MREFERENCIA
           CAP->FECHA        := PDATE           //del sistema   
           CAP->CARGO        := MABONO2    // se crea un saldo pendiete POR HABER DIFERENCIA 
           CAP->CONCEPTO     := "NVO. SALDO"
           CAP->ACTUAL       := .F.                      // status  de saldo pendiente
            CAP->SERIE       :=  2                       // STATUS SERIE SALDO RENOVADA
           CAP->(DBUNLOCK())
           CAP->(DBCOMMIT())
        ENDIF
 ENDIF 

 
   

   IF LINEA>20
         @ 7,0 CLEAR
         LINEA:=8
         ENDIF



 SELE B
            CLI->(DBGOTO(cliRec))
         IF CLI->(DBRLOCK())
            REPLACE CLI->ACTUAL WITH  .T.     //mantiene es status de activo
            REPLACE CLI->SALDO_ACT WITH TOTALE
            UNLOCK
            commit
         ENDIF
      @  3,65 SAY CLI->SALDO_ACT    PICTURE "9999,999.999"
          EXIT
     ENDDO
 
       ENDDO
RETURN



PROCEDURE PANT18
   CLEAR
   @ 1,3  SAY MEMPRESA  color(fon)
   @ 1,40 SAY " MANTENIMIENTO  A COMPROBANTES "  color(fon)
   @ 2,3 say "Fecha:              Condiciones:        Grupo :"
   @ 2,10 say XFECHA
   @ 2,37 SAY MCONDIC   PICTURE  "###"
   @  3, 3 SAY " Clave :        Nombre : "
             *         1         2         3         4         5         6         7
             *1234567890123456789012345678901234567890123456789012345678901234567890123456789
   @  4,3 to 6,79 
   @  5,4 SAY "Rec- Comprob.|Fecha-Ent |   Concepto                        |    Importe     "
    
           linea:=7
RETURN













      

 
          