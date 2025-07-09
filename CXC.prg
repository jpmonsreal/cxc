
#include "dbedit.ch"
#include "std.ch"
#include "set.ch"
#include "inkey.ch"
#include "Dbstruct.ch"
#include "fileio.ch"
#include "error.ch"
#include "box.ch"
#include "common.ch"
#include "SetCurs.ch"
#include "Ord.ch"
#include "rddsys.ch"
#include "OOHG.ch"
#include "c2w.ch"

 function main()

// Inicializacion RDD DBFCDX Nativo

        ANNOUNCE RDDSYS
	REQUEST DBFCDX , DBFFPT
	RDDSETDEFAULT( "DBFCDX" )
	REQUEST HB_LANG_ES
	HB_LANGSELECT("ES")



SET DATE FRENCH
SET DATE FORMAT "DD-MM-YYYY"
SET ALTERNATE OFF
SET BELL    OFF
SET EXACT   ON
SET DELETED ON
SET ESCAPE  ON
SET WRAP    ON
SET EXACT  ON


PUBLIC  ARCHIVO,ARCHVX,ARCHCAP,CLAVX,FAMIL,FOLIOS,FACT2,MRFC,CHAC,MEMPRESA,MCIUDAD,;
        MCAMINO,MD1,MD2,MD3,MD4,PCAMBIO,MSIS,EMPREC,MNIVEL,tclave

PUBLIC  cmclave,mclave,opcion,mcont,fo,fon,fon_a,fos,fone,tex,;
        pant,mulT,pdate,xfecha,rmes,mtim,frame,frame1,tor,;
        nx1,nx2,nx3,tio,mtipo,catex,oldcolor,mfcontrol,PDATE,mold

PUBLIC  pitch,estilov,times,MIVA,MEDO,MCONTRO,mlargo,mcondic,usua,recusua



c2w_init(22,25,80)

DO WHILE .T.
   close all
   clear
   
   cmclave:=space(3)

   rmes:=space(10)
  

    c2w_setwintitle("   APLICACION  DE       Seleccione un Usuario  ")
   
     VECES=.T.

   USE USUARIO SHARED NEW

        DO WHILE VECES

         CUENTA=1
         XCLAVE=SPACE(8)
         TCLAVE=SPACE(4)
       
       @ 6,0  CLEAR
       @ 5,5,10,65 box replicate(chr(219),9) color "B+"
                   HB_SHADOW(5,5,10,65)
       @ 6,8 SAY padl("Usuario #",10)  GET TCLAVE PICTURE "@!"
   
              READ
              IF TCLAVE=SPACE(4) .OR. LASTKEY()=27
                 QUIT
              ENDIF

              locate for idclave=tclave
              IF EOF()
                 ALERT(" NO EXISTE CLAVE USUARIO ")
                 LOOP
              ENDIF
        
         @ 6,30 SAY NOMBREUSER
                recusua:= recno()
                usua   := nombreuser
                ALIAX  := ALIAS
                MNIVEL := CLAVE2
                CMCLAVE:= EMPRE1
         @ 9,8 SAY "Anotar Clave Secreta"

         c2w_settooltip(9,10,10,40,"Con Letra Minuscula")
         XCLAVE:=GETCRIP(@XCLAVE,9,33)

         rclave:=crip(alltrim(lower(xclave)))

         IF TRIM(CLAVE) != RCLAVE
           
            ALERT("LA CLAVE NO COINCIDE REINTENTAR")
            CUENTA ++
            if cuenta=4
               quit
            endif
            LOOP
         ELSE
            EXIT
         ENDIF
    ENDDO USER


   
 omenue:=mimenut()   //// se crea un nuevo menu propio.
c2w_aplmenu(omenue)  /// se aplica el nuevo menu para que no se vea el menu por defecto
   
   @  5,0   CLEAR
   @ 5,5,12,65 box replicate(chr(219),9) color "B+"
                   HB_SHADOW(5,5,12,65)
   @  6,10 say "Fecha de Hoy "
   @  6,31 SAY mdy(date()) 
   @  8,10 say "Anotar Clave Empresa" GET cmclave PICTURE "!!!"
           READ
   IF cmclave="   "
      cls
      QUIT
   ENDIF

    USE empresas ALIAS EMP SHARED NEW


   LOCATE FOR emp->clave=(cmclave)
   IF  EOF()
       alert(" EMPRESA  NO REGISTRADA EN SISTEMA ")
       CLOSE DATABASES
       LOOP
   ENDIF

   EMPREC=Emp->(RECNO())
   mEmpresa=Nomine(CMCLAVE)
   ** nomine(cmclave)
   mdirecc  := emp->direccion
   mciudad  := emp->ciudad
   mrfc     := emp->rfc

   mcamino  := rtrim(emp->camino)
   archivo  := mcamino+rtrim(emp->file1)
   archcap  := mcamino+rtrim(emp->file2)
   famil     := mcamino+rtrim(EMP->file3)

   folios   := mcamino+rtrim(emp->file5)
   fact2    := mcamino+rtrim(emp->file6)

   pcambio  := emp->cambia
   msis     := emp->sistema
   md1      := emp->dias_1
   md2      := emp->dias_2
   md3      := emp->dias_3
   md4      := emp->dias_4
   mtim     := 4
   MIVA     := emp->IMP_IVA
   MEDO     := emp->IMP_EDO
   pdate    := emp->E_fecha
   mcontrol := emp->control
   mcondic  := emp->dgracia       //dias gracia pago doctos
   opcion   := "*"
   pant     := 0
   mlargo   := EMP->largo
   
      fone:=rtrim(emp->colon)
      fon :=rtrim(emp->colore)
      mold:="N/W+"
   IF month(pdate)=0
      pdate=date()
   ENDIF
 

   @  9,20 say "Empresa-> " 
   @  9,31 say  mempresa  color fone
   @ 10,10 say "Ultima Fecha Trabajada " 
   @ 10,40 say pdate
   @ 10,55 get pdate PICTURE "99-99-9999"
   READ
   rmes=nmes()
   Goto EMPREC
   IF loc()
      replace emp->e_fecha with pdate
      unlock
   ENDIF
   CLEAR
   CLOSE databases
   menucito()
 
ENDDO 

return nil

//PROGRAMAS DE UTILERIAS
//VERSION original  para DOS CLIPPER 5.01  VERANO 1991 COZUMEL JPINA




static FUNCTION NOMINE(NOM)
   DO CASE
    
      CASE NOM="FUN"
           PAS="CONTROL  DE  CONSUMOS"
    CASE NOM="PRE"
           PAS=" CONTROL PRESTAMOS "
      OTHERWISE
           PAS=" E M P R E S A    P I R A T A  "
   ENDCASE

RETURN rtrim(pas)



FUNCTION LOC
   LOCAL vuelta:=1
   IF RLOCK()
      RETURN (.T.)
   ENDIF
   DO WHILE VUELTA >0
      msg (24," REGISTRO OCUPADO  INTENTO DE LECTURA ->"+STR(VUELTA,1),3)
      vuelta=+1
      IF RLOCK()
         RETURN (.T.)
      ENDIF
      IF VUELTA > 5
         CLEAR
         msg(14," ARCHIVO  CERRADO --> POR seguridad salimos al DOS",3)
         CLEAR
         QUIT
      ENDIF
   ENDDO
RETURN (.F.)





FUNCTION NMES
     LOCAL ONK,VPOS,MEC,ME
     me:={"ENERO","FEBRERO","MARZO","ABRIL","MAYO","JUNIO","JULIO","AGOSTO",;
         "SEPTIEMBRE","OCTUBRE","NOVIEMBRE","DICIEMBRE"}
     VPOS=MONTH(PDATE)
     MEC=ME[VPOS]
RETURN MEC




 FUNCTION MSG(lin,mens,tos)
     LOCAL POS,BOR
     POS=(80-LEN(MENS))/2
     BOR=SPACE(LEN(MENS))
     DO CASE
        CASE TOS=0
          
             @ lin,pos say mens
         
        CASE tos=1
         
             @ lin,pos say mens
        
             inkey(mtim)
             @ lin,pos say bor
        CASE tos=2
        
             @ lin,pos say mens
          
        CASE tos=3
        
             @ lin,pos say mens
             INKEY(MTIM)
     
             @ lin,pos say bor
     ENDCASE
RETURN  NIL


*-------------------------
Function mimenut()
*-------------------------
Local oMenue
Local oSubMenue
g_oMenuBar := c2w_menu()
oMenue := c2w_menu()
oMenue:Caption := "menu inicial"
oMenue:AddItem( "Calc"     ,  {||  shellexecute(0,'open','calc.exe') }  )
oMenue:AddItem( "Version", {|| msgbox(c2w_version())} )
oMenue:AddItem( "-" )
oMenue:AddItem( "Salir"      , {|| c2w_exit(.T.) } )
g_oMenuBar:addItem( "",oMenue )
RETURN g_oMenuBar









#INCLUDE "CXC10.PRG"
#INCLUDE "CXC14.PRG" 
#INCLUDE "CXC18.PRG"
#INCLUDE "CXC20.PRG"
#INCLUDE "CXC30.PRG"
#INCLUDE "CXC32.PRG"
#INCLUDE "CXC36.PRG"
#INCLUDE "CXC38.PRG"
#INCLUDE "CXC40.PRG"
#INCLUDE "CXC42.PRG"
#INCLUDE "CXC44.PRG"
#INCLUDE "CXC50.PRG"
#INCLUDE "CXC52.PRG"
#INCLUDE "CXC52L.PRG"
#INCLUDE "CXC52LR.PRG"
#INCLUDE "CXCFUNC.PRG"
#INCLUDE "CXCMENU.PRG"


