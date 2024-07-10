def temp-table tt-cont
    field agencia as int
    field contnum like contrato.contnum
    field titpar like titulo.titpar
    field titdtven like titulo.titdtven
    index i1 contnum
    .

def var vlinha as char.
def temp-table tt-titulo like titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.

def var vdata-arq as date.
update vdata-arq label "Data" format "99/99/9999"
        with frame f1 width 80.

def var varqini as char.
def var varqfim as char.
varqini = "/admcom/financeira/ultima_pmt_aberta.csv".


update varqini label "Arquivo" format "x(60)"
        with frame f1 side-label.
        
if search(varqini) = ?
then do:
    message color red/with "Arquivo nao encontrado." view-as alert-box.
    return.
end. 
DEF VAR VV AS CHAR FORMAT "x(10)" init "AGUARDE!".

disp "IMPORTANDO DADOS DO ARQUIVO... " at 1  VV
     WITH FRAME F2 down no-label no-box row 10 overlay.
pause 0.
    
def var q-linha as int.
input from value(varqini).
repeat:
    q-linha = q-linha + 1.
    import vlinha.
    if q-linha > 1
    then do:
        create tt-cont.
        assign
            tt-cont.agencia  = int(entry(1,vlinha,";"))
            tt-cont.contnum  = int(entry(2,vlinha,";"))
            tt-cont.titpar   = int(entry(3,vlinha,";"))
            tt-cont.titdtven = date(entry(4,vlinha,";"))
            .
    end.

    IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "".
    DISP VV WITH FRAME F2.
    pause 0.
end.
input close.

VV = "".
DISP VV WITH FRAME F2.
pause 0.    
disp "VALIDANDO DADOS DO ARQUIVO.... "
    AT 1 WITH FRAME F3 down no-label no-box row 11 overlay.
pause 0.
IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "" .
    DISP VV WITH FRAME F3.
pause 0.
def buffer ctitulo for titulo.
for each tt-cont where tt-cont.contnum > 0 :
    find contrato where contrato.contnum = tt-cont.contnum 
    NO-LOCK no-error.
    if not avail contrato then next.
    /*disp contrato.contnum contrato.crecod contrato.clicod
    tt-cont.titpar tt-cont.titdtven.
    */
    find titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titpar = tt-cont.titpar
                      no-lock no-error.
    if not avail titulo
    then do:
        find ctitulo where ctitulo.empcod = 19 and
                      ctitulo.titnat = no and
                      ctitulo.modcod = contrato.modcod and
                      ctitulo.etbcod = contrato.etbcod and
                      ctitulo.clifor = contrato.clicod and
                      ctitulo.titnum = string(contrato.contnum) and
                      ctitulo.titpar = 0
                      no-lock no-error.
        
        if avail ctitulo
        then do:
            find first titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titdtven = tt-cont.titdtven
                       no-lock no-error.
            if avail titulo
            then do:
                /*disp titulo.titdtven titulo.titpar titulo.titsit.
                */
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titpar = tt-cont.titpar.
            end.
            else do:
                find first titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titpar = (tt-cont.titpar + 30) - 1
                       no-lock no-error.
                if avail titulo
                then do:
                    /*disp titulo.titdtven titulo.titpar titulo.titsit.
                    */
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    tt-titulo.titpar = tt-cont.titpar.
                end.
            end.
        end.
    end.
    else do:
        /*disp titulo.titdtven titulo.titpar titulo.titsit. 
        */
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
    end. 
    IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "" .
    DISP VV WITH FRAME F3.
    pause 0.
end.                          

{admcab.i }
setbcod = 999.

def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def buffer btitulo for titulo.

def var varquivo as char.
def var varqexp  as char.

def var vseq as int.
def var vqtoper  as int.
def var vtotal   as dec.
def var vetbcod like estab.etbcod.
def var vlote as int.
def var vdti     like plani.pladat.
def var vdtf     like plani.pladat.
def var vclicod  like clien.clicod.
def var vclinom  like clien.clinom.

varqexp = "pg" + string(today,"999999") + ".rem".

FUNCTION f-troca returns character
    (input cpo as char).
    def var v-i as int.
    def var v-lst as char extent 60
       init ["@",":",";",".",",","*","/","-",">","!","'",'"',"[","]"].
         
    if cpo = ?
    then cpo = "".
    else do v-i = 1 to 30:
         cpo = replace(cpo,v-lst[v-i],"").
    end.
    return cpo. 
end FUNCTION.

def stream st.

VV = "".
DISP VV WITH FRAME F3.
pause 0.    

output stream st to terminal .
disp stream st "GERANDO ARQUIVO DE RETORNO.... "
    AT 1 WITH FRAME F4 down no-label no-box row 12 overlay.
pause 0.

IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "".
    DISP stream st VV WITH FRAME F4.

pause 0.

def var vetbcod1 like estab.etbcod.
def var vs as int.    
def var vqtd as int.
repeat:    

vs = vs + 1.
vqtd = 0.

varquivo = "/admcom/financeira/pg" + string(vs,"99") + "-" +
                 string(today,"999999") + ".rem".

output to value(varquivo) page-size 0.

run p-registro-00.


assign vqtoper = 0
       vtotal = 0.

IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "" .
    DISP stream st VV WITH FRAME F4.
    pause 0.

for each tt-titulo where tt-titulo.etbcod > 0 and
            tt-titulo.titsit = "PAG":
            /***********
    find titulo where 
             titulo.empcod = tt-titulo.empcod and
             titulo.titnat = tt-titulo.titnat and
             titulo.modcod = tt-titulo.modcod and
             titulo.etbcod = tt-titulo.etbcod and
             titulo.clifor = tt-titulo.clifor and
             titulo.titnum = tt-titulo.titnum and
             titulo.titpar = tt-titulo.titpar
             no-lock no-error.
     if not avail titulo then next.
                          
     if titulo.titsit <> "PAG"
     then next.
     
     find first envfinan where envfinan.empcod = titulo.empcod
                        and envfinan.titnat = titulo.titnat
                        and envfinan.modcod = titulo.modcod
                        and envfinan.etbcod = titulo.etbcod
                        and envfinan.clifor = titulo.clifor
                        and envfinan.titnum = titulo.titnum
                        and envfinan.titpar = titulo.titpar
                        no-lock no-error.
     if not avail envfinan
     then do:
         create envfinan.
         assign envfinan.empcod = titulo.empcod
                envfinan.titnat = titulo.titnat
                envfinan.modcod = titulo.modcod
                envfinan.etbcod = titulo.etbcod
                envfinan.clifor = titulo.clifor
                envfinan.titnum = titulo.titnum
                envfinan.titpar = titulo.titpar
                envfinan.envdtinc = today
                .
     end.   
     ************/
          
     find first clien where clien.clicod = tt-titulo.clifor no-lock.
                
     run p-registro-10.    
                     
    delete tt-titulo.                 
    
    IF VV = ""
    THEN VV = "AGUARDE!".
    ELSE VV = "" .
    DISP stream st VV WITH FRAME F4.
    pause 0.
    vqtd = vqtd + 1.
    if vqtd = 40000 /*and vs < 5*/
    then leave.
end.    
run p-registro-99.

output close.

def var varq as char.
varq = "/admcom/relat/pg." + string(time).
output to value(varq).
unix silent unix2dos value(varquivo).
output close.

VV = "".
DISP stream st VV WITH FRAME F4.
pause 0.
    
if opsys = "unix"
then do.
       unix silent chmod 777 value(varquivo).
end.

if vqtd = 0 then leave.
/*
if vs = 5
then leave.*/
end.

output stream st close.

disp "ARQUIVOS DE RETORNO GERADOS.... "
    AT 1 WITH FRAME F5 down no-label no-box row 13 overlay.
pause 0.
disp "FIM DO PROCESSO.... "
    AT 1 WITH FRAME F6 down no-label no-box row 14 overlay.
pause .


/* header */
procedure p-registro-00.

     def buffer blotefin for lotefin.
     vseq = 1.
     put unformat skip
         "00"                      /* 001-002 */
         varqexp format "x(08)"    /* 003-010 */
          string(today,"99999999") /* 011-018 */
          " " format "x(776)"      /* 019-794  */
          vseq format "999999" /* NUMERICO  Sequencia  */
          .

   find last Blotefin use-index lote exclusive-lock no-error.

   create lotefin.
   assign lotefin.lotnum = (if avail Blotefin 
                             then Blotefin.lotnum + 1
                             else 1)
          lotefin.lottip = "PAG".
          
   assign vlote = lotefin.lotnum.                         
   
end procedure.

/* OPERACAO */
procedure p-registro-10.
  def buffer benvfinan for envfinan.
  /*********
  find btitulo where btitulo.empcod = titulo.empcod
                 and btitulo.titnat = titulo.titnat
                 and btitulo.modcod = titulo.modcod
                 and btitulo.etbcod = titulo.etbcod
                 and btitulo.clifor = titulo.clifor
                 and btitulo.titnum = titulo.titnum 
                 and btitulo.titpar > titulo.titpar
                 no-lock no-error.
  */
  def var v-data-comerc as log.
  def var v-data-vecto as date.
  def var vdata-retorno as date.
  assign v-data-comerc = yes.
  v-data-vecto = tt-titulo.titdtpag. /*btitulo.titdtven*/ 
  run p-verif-data (input v-data-vecto, 
                    output vdata-retorno, 
                    output v-data-comerc).
  if v-data-comerc = no and vdata-retorno <> ?
  then assign v-data-vecto = vdata-retorno.
 
  /*v-data-vecto = 10/25/2010.*/
  v-data-vecto = vdata-arq.
  
  vseq = vseq + 1.
  put unformat skip 
      "10"                          /* 001-002  TIPO  FIXO –1 */
      "0001"                        /* 003-006 AGÊNCIA        */
      dec(tt-titulo.titnum) format "9999999999"       /* 007-016 Contrato */
      tt-titulo.titpar format "999"                 /* 017-019 Parcela  */
      /********************************
      tt-titulo.titvlcob * 100 format "99999999999999999" /* 020-036 Vlr Par */
      tt-titulo.titvljur * 100 format "99999999999999999" /* 037-053 Encargos */
      tt-titulo.titvldes * 100 format "99999999999999999" /* 054-070 Desc */
      tt-titulo.titvlpag * 100 format "99999999999999999" /* 071-087 valor pago */
      *********************************/
      0                     format "99999999999999999" /* 020-036 Vlr Par */
      0                     format "99999999999999999" /* 037-053 Encargos */
      0                     format "99999999999999999" /* 054-070 Desc */
      tt-titulo.titvlpag * 100 format "99999999999999999" /* 071-087 valor pago */
      "00000000000000000"                        /* 088-104 CPMF */
      "00000000000000000"                        /* 105-121 Taxas */
      "000000000000000"                          /* 122-136 Comissão */
      /***************
      "00000000000000000"                        /* 137-153 Vlr repassado */
      ***************/
      tt-titulo.titvlpag * 100 format "99999999999999999" /* 137-153 Vl repass. */
      "01"                                       /* 154-155 tipo pagto */
      v-data-vecto format "99999999"          /* 156-163 dat pag */
      (if avail btitulo then "12" else "10")     /* 164-165 total/parcial */
      "00000000"                                 /* 166-173 */
      "00000"                                    /* 174-178 */
      " "                                        /* 179-179 */ 
      "N"                                        /* 180-180 */
      "   "                                      /* 181-183 */
      " " format "x(6)"                          /* 184-189 */
      " " format "x(30)"                         /* 190-219 */
      " " format "x(575)"                        /* 220-794 */
      vseq format    "999999"                    /* 795-800 */
     .
  
  assign vqtoper = vqtoper + 1
         vtotal = vtotal + tt-titulo.titvlcob.
  find benvfinan where rowid(benvfinan) = rowid(envfinan) 
                exclusive-lock no-error.
  if avail benvfinan
  then assign benvfinan.lotpag = vlote
              benvfinan.envsit = "PAG".  

end procedure.

/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.

  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(6)"                /* 03-08 Nome do arquivo */
     string(today,"99999999")             /* 09-16 data movimento */
     vqtoper format "9999999999"          /* 17-26 QTD DE OPERAÇÕES */
     vtotal  format "99999999999999999"   /* 27-43 VLR TOTAL das OPERAÇÕES */
     " " format "x(751)"                  /* 44-794 FILLER */
     vseq format    "999999" skip.

   find lotefin where lotefin.lotnum = vlote exclusive-lock no-error.
   if not avail lotefin
   then do:
        create lotefin.
        assign lotefin.lotnum = vlote
               lotefin.lottip = "PAG".
   end.
   assign lotefin.datexp = today
          lotefin.hora = time
          lotefin.lotqtd = vqtoper
          lotefin.lotvlr = vtotal.

end procedure.


/*
def var vx as char.
input from /admcom/financeira/pg120109.rem.
repeat:
    import unformat vx.
    disp vx format "x(20)"
         substring(vx,790,20) format "x(20)"
         length(vx).
end.
*/

procedure p-verif-data.

def input  parameter p-data-verifica as date.
def output parameter p-data-retorno  as date.
def output parameter p-data-comerc as logical.
def var vdata-aux as date.
def var vdia as int.


assign  p-data-comerc = yes
        vdia = weekday(p-data-verifica)
        p-data-retorno = ?.

/* 1) Verifica especial */

if vdia = 1 or vdia = 7 /* Sabado ou Domingo */
then assign p-data-comerc = no.
else do:               /*  Feriado */
    find first dtextra where dtextra.exdata = p-data-verifica no-lock no-error.
    if avail dtextra then p-data-comerc = no.
end.

/* 2) Acha Proxima Data Comercial */
if p-data-comerc = no
then do vdata-aux = (p-data-verifica + 1) to (p-data-verifica + 30) :
         find first dtextra where dtextra.exdata = vdata-aux no-lock no-error.
         if avail dtextra then next.
         if weekday(vdata-aux) = 1 or weekday(vdata-aux) = 7 then next.
         assign p-data-retorno = vdata-aux.
         leave. 
     end.

end procedure.


