/* helio 31012023 - conversao numero de parcelas */   
/* helio - 12012023 - ajuste em performance */
/* helio - 14122022 - retirar testes de carteira */

{admcab.i}
setbcod = 999.
def var vl as int.
def var vctrpago as int.
def var vparpago as int.
def var vcompgto as log.

def new shared temp-table tt-env no-undo
    field rectit as recid
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field encargos like titulo.titvljur
    field titvldes like titulo.titvldes
    field titvlpag like titulo.titvlpag
    field titdtmov like titulo.titdtpag
    field tp_baixa as char
    index i1 is unique primary clifor titnum titpar
    .

def temp-table tt-cont no-undo
    field contnum like contrato.contnum
    field sit as char
    index i1 is unique primary contnum asc
    .


def temp-table tt-arquivo no-undo
    field arquivo as char .

def var vlinha as char.
/*
def temp-table tt-titulo like titulo.
*/
def var varqini as char.
def var varqfim as char.
def var vdatref as date format "99/99/9999".
def var vdatapag as date format "99/99/9999".
def var vdest as int format ">>" init 1.

def var vcolpadr as char extent 2
       init["Contrato","Situacao"].
def var vlocarc as char.
vlocarc = "L:~\financeira~\arqimport~\".
varqini = "/admcom/financeira/arqimport/".

def var vnomarc as char.


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
def buffer bsicred_pagam for sicred_pagam.
def buffer ctitulo for titulo.

def var vetbcod1 like estab.etbcod.

def var vs as int.

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


disp "Layout padrao do arquivo[Contrato;Situacao]"
     skip
     "Nome do arquivo nao pode conter espacos."
     skip(1)
      with frame f1.
disp vlocarc format "x(30)" label "Local do Arquivo" 
     vnomarc
     vdatref
     vdatapag
     vdest
     " Informar: [1]=Financeira [2]=FIDC-14 [3]=FIDC-16]"
    with frame f1.
update vnomarc label "Nome do arquivo " format "x(50)"
        help "Informe o nome do arquivo levando em conta o tamanho da letra."
        vdatref at 1 label  "Data de referencia   "
        help "Informar a data referencia de pagamento."
        vdatapag at 1 label "Data baixa Financeira"
        help "Informar a data para baixa."
        vdest at 1 label "Destino dos registros"
        with frame f1 side-label width 80.

if vdest < 1 or vdest > 3 then undo.

varqini = varqini + vnomarc.
if search(varqini) = ?
then do:
    bell.
    message color red/with
    "Arquivo nao encontrado."
    view-as alert-box.
    return.
end.

DEF VAR VV AS CHAR FORMAT "x(60)" init "AGUARDE!".

disp " IMPORTANDO ..." at 1  VV
     WITH FRAME F2 down no-label no-box row 12 overlay.

def var vqlinhas as int.
def var verro as char.
def var vq as int.
def var qcolunas as int.
def var vcolunas as char extent 5.

def var q-linha as int.
def var xtime as int.

verro = "".
xtime = time. 

for each tt-env. 
    delete tt-env. 
end.  

input from value(varqini).
repeat:
    q-linha = q-linha + 1.
    import unformatted vlinha.
    vlinha = replace(vlinha,"~"","").
    vqlinhas = vqlinhas + 1.
    if q-linha = 1
    then do:
        qcolunas = num-entries(vlinha,";").
        if qcolunas <> 2
        then do:
            verro =
            "Numero de colunas do arquivo na linha " +
            string(vqlinhas) +
            " difere do layout padrao".
            leave.
        end.
        else do vq = 1 to qcolunas:
            vcolunas[vq] = entry(vq,vlinha,";").
            if vcolunas[vq] <> vcolpadr[vq]
            then do:
                verro = "Nome das colunas do arquivo na linha " +
                string(vqlinhas) +
                " difere do layout padrao".
            end.
        end.
        if verro <> "" then leave.
    end.
    else if q-linha > 1
    then do:
        qcolunas = num-entries(vlinha,";").
        if qcolunas <> 2
        then do:
            verro =
            "Numero de colunas do arquivo na linha " +
            string(vqlinhas) +
            " difere do layout padrao".
            leave.
        end.
        
        create tt-cont.
        assign
            tt-cont.contnum = int(entry(1,vlinha,";"))
            tt-cont.sit   = entry(2,vlinha,";")
            .

    end.
    
    if vqlinhas = 1 or vqlinhas mod 100000 =  0
    then  do:
        VV = "Importando " + string(vqlinhas) + " (" +  string(time - xtime,"HH:MM:SS") + ")" .
        DISP VV WITH FRAME F2.
        pause 0.

    end.

            
end.
input close.

VV = "Importou " + string(vqlinhas) + " (" +  string(time - xtime,"HH:MM:SS") + ")" .
disp vv with frame f2.
/*
message  "fim fase 1" string(time - xtime,"HH:MM:SS") string(time - ttime,"HH:MM:SS").
pause.
*/
vl = 0.
pause 0.
disp "PROCESSANDO ..." AT 1 WITH FRAME F3 down no-label no-box row 13 overlay.
     
pause 0.
vctrpago = 0.
for each tt-cont.
        
        vl = vl + 1.
        
        find contrato where contrato.contnum = tt-cont.contnum
                no-lock no-error.
        if not avail contrato then next.
        
        vcompgto = no.
        
        for each titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod and
                      titulo.titnum = string(contrato.contnum)
                      no-lock :
            if titulo.titsit <> "PAG" and titulo.dtultpgparcial = ?
            then next.

            if vdatref < titulo.titdtpag or
               vdatref < titulo.dtultpgparcial
            then next.
            
            vcompgto = yes.
            release pdvdoc.
            release pdvmov.
            
            if titulo.dtultpgparcial <> ? and titulo.titsit = "LIB"
            then do:
                find first sicred_pagam where
                     sicred_pagam.contnum = int(titulo.titnum) and
                     sicred_pagam.titpar  = titulo.titpar
                     no-lock no-error.
                if avail sicred_pagam
                then do:
                    for each bsicred_pagam where
                         bsicred_pagam.contnum = sicred_pagam.contnum and
                         bsicred_pagam.titpar  = sicred_pagam.titpar
                         no-lock:
                        if bsicred_pagam.operacao <> "NOVACAO" and
                           bsicred_pagam.operacao <> "PAGAMENTO" and
                           bsicred_pagam.operacao <> "CANCELAMENTO"
                        then next.
                        release pdvdoc.
                        find first pdvmov where
                            pdvmov.etbcod = bsicred_pagam.etbcod and
                            pdvmov.cmocod = bsicred_pagam.cmocod and
                            pdvmov.datamov = bsicred_pagam.datamov and
                            pdvmov.sequencia = bsicred_pagam.sequencia
                            no-lock no-error.
                        if avail pdvmov
                        then do:    
                            find pdvdoc of pdvmov where
                                pdvdoc.seqreg = bsicred_pagam.seqreg
                                no-lock no-error.
                            if avail pdvdoc
                            then run gera-tt-env.
                            else run gera-tt-env.
                        end.
                        else run gera-tt-env.        
                    end.
                end.
                else run gera-tt-env.
            end.
            else run gera-tt-env.
        end.
        if vcompgto 
        then vctrpago = vctrpago + 1.

    if vl = 1 or vl = 100 or vl mod 1000 = 0 
    then  do:
        VV = "Processando (parc=" + string(vparpago) + ") : " + string(vl) + "/" + string(vqlinhas) + " (" +  string(time - xtime,"HH:MM:SS") + ")" .
        DISP VV WITH FRAME F3.
        pause 0.
    end.

    if vparpago >= 100000
    then do:

        run geraarquivo.
        
    
    end.

end.

run geraarquivo.

hide message no-pause.
message  "fim " string(time - xtime,"HH:MM:SS").

disp "ARQUIVO(s) GERADO(s):" skip
    with frame f7 no-label down.
for each tt-arquivo:
    disp tt-arquivo.arquivo format "x(70)"
    with frame f7.
    down with frame f7.
end.
pause.

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
def var vtitpar as int.
    vseq = vseq + 1.
    vtitpar = if tt-env.titpar >= 51 then tt-env.titpar - 50 else if tt-env.titpar >= 31 then tt-env.titpar - 30 else tt-env.titpar.
    
    put unformat skip
      "10"                          /* 001-002  TIPO  FIXO <96>1 */
      "0001"                        /* 003-006 AGÃCIA        */
      dec(tt-env.titnum) format "9999999999"       /* 007-016 Contrato */
      vtitpar format "999"                 /* 017-019 Parcela  */
      tt-env.titvlcob * 100 format "99999999999999999" /* 020-036 Vlr Par*/
      tt-env.encargo * 100 format "99999999999999999" /* 037-053 Encargos */
      tt-env.titvldes * 100 format "99999999999999999" /* 054-070 Desc */
      tt-env.titvlpag * 100 format "99999999999999999" /* 071-087 valor pago */
      "00000000000000000"                        /* 088-104 CPMF */
      "00000000000000000"                        /* 105-121 Taxas */
      "000000000000000"                          /* 122-136 Comissão */
      tt-env.titvlpag * 100 format "99999999999999999" /* 137-153 Vl repass. */
      "01"                                       /* 154-155 tipo pagto */
      tt-env.titdtmov format "99999999"          /* 156-163 dat pag */
      tt-env.tp_baixa format "x(2)"
      "00000000"                                 /* 166-173 */
      "00000"                                    /* 174-178 */
      " "                                        /* 179-179 */
      "N"                                        /* 180-180 */
      "   "                                      /* 181-183 */
      " " format "x(6)"                          /* 184-189 */
      " " format "x(30)"                         /* 190-219 */
      " " format "x(575)"                        /* 220-794 */
      vseq format    "999999"                    /* 795-800 */.

    assign vqtoper = vqtoper + 1
           vtotal = vtotal + tt-env.titvlcob.

end procedure.

/* Trailer */
procedure p-registro-99.
  vseq = vseq + 1.

  put unformat skip
     "99"                                 /* 01-02 fixo "99" */
     varqexp format "x(6)"                /* 03-08 Nome do arquivo */
     string(today,"99999999")             /* 09-16 data movimento */
     vqtoper format "9999999999"          /* 17-26 QTD DE OPERAÃES */
     vtotal  format "99999999999999999"   /* 27-43 VLR TOTAL das OPERAÃES */
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

procedure gera-tt-env:
        def var vparcela like titulo.titpar.
        vparcela = titulo.titpar.
        def var vparcial as log.
        vparcial = no.
        def var par-ori like titulo.titpar.
        def var pag-tipo as log.
        def var p-retorno as char.
        p-retorno = "".
        par-ori = titulo.titpar.
        pag-tipo = yes.
        /**
        if  acha("PARCIAL",titulo.titobs[1]) <> ? or
            acha("PAGAMENTO-PARCIAL",titulo.titobs[1]) <> ?
        then do:
            vparcial = yes.
            run protituloparcial.p (input recid(titulo),
                                    output p-retorno).
            par-ori = int(acha("PARCELA-ORIGEM",p-retorno)).
            if dec(acha("VALOR-ABERTO",p-retorno)) > 0
            then pag-tipo = no.
        end.

        vparcela = par-ori.
        **/
        
        if vparcela > 0
        then do:
            find first tt-env where  
                tt-env.clifor = titulo.clifor and
                tt-env.titnum = titulo.titnum and
                tt-env.titpar = vparcela
                no-error.
            if avail tt-env then return.
            
            create tt-env.
            assign
                tt-env.rectit = recid(titulo)
                tt-env.clifor = titulo.clifor
                tt-env.titnum = titulo.titnum
                tt-env.titpar = vparcela
                tt-env.titvlcob = titulo.titvlpag
                tt-env.encargos = 0
                tt-env.titvldes = 0
                tt-env.titvlpag = titulo.titvlpag
                tt-env.titdtmov = vdatapag
                tt-env.tp_baixa =
                        if vparcial and titulo.titvlcob > titulo.titvlpag
                        then "12" else "10"
                .

            if avail pdvdoc
            then assign
                    tt-env.titvlcob = pdvdoc.titvlcob
                    tt-env.encargos = pdvdoc.valor_encargo
                    tt-env.titvldes = pdvdoc.desconto
                    tt-env.titvlpag = pdvdoc.valor
                    tt-env.titdtmov = vdatapag
                    tt-env.tp_baixa = if pdvdoc.pago_parcial = "S"
                                      then "12" else "10"
                    .
            vparpago = vparpago + 1.
        end.
        
end procedure.

procedure ger-arq-financeira:

    varquivo = "/admcom/financeira/arqexport" + string(vs,"99") + "-" +
                     string(vdatapag,"99999999") + ".rem".
                     
    output to value(varquivo) page-size 0.

    run p-registro-00.

    assign vqtoper = 0
           vtotal = 0.

    for each tt-env where tt-env.clifor > 0 and
                          tt-env.titpar > 0 no-lock:
            find clien where clien.clicod = tt-env.clifor no-lock no-error.
            run p-registro-10.
    end.
    run p-registro-99.

    output close.
    /* helio 05042023 */
    unix silent value("unix2dos -q " + varquivo).
    
end procedure.    
 



procedure geraarquivo.

        VV = "Processando (parc=" + string(vparpago) + ") : " + string(vl) + "/" + string(vqlinhas) + " (" +  string(time - xtime,"HH:MM:SS") + ")" .
        DISP VV WITH FRAME F3.
        pause 0.
        vs = vs + 1.
        disp "GERANDO ARQ ..."        
            AT 1 VV WITH FRAME F4 1 down no-label no-box row 14 overlay.
        pause 0.
        
        VV = "Arquivo " + string(vs) + " (" +  string(time - xtime,"HH:MM:SS") + ")" .
        DISP VV WITH FRAME F4.
        pause 0.
    
        if vdest = 1
        then do:
            run ger-arq-financeira.
        end.
        else do:
            run fidc-exportagerpagto.p (input vs, input vdest, output varquivo) .
        end.
    
        create tt-arquivo.
        tt-arquivo.arquivo = varquivo.
    
        if opsys = "unix"
        then unix silent chmod 777 value(varquivo).
        
        for each tt-env.
            delete tt-env.
        end. 
        vctrpago = 0.
        vparpago = 0.
        hide frame f4 no-pause.


end procedure.
