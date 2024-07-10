{admcab.i }
def var varquivo            as   char format "x(20)".
def var vreg1               as   char   format "x(200)".
def var vregistro           as   char   format "x(400)".
def var i-cont              as   int.
def var vdtarq              as   char   format "999999".

update varquivo colon 20 label "Arquivo"
       with frame f1 side-label width 80.

unix silent value("cp " + varquivo + " ./retorno.txt").
unix silent value("quoter .\retorno.txt > retorno.d").

input from ./retorno.d no-echo.
repeat:
    set vreg1   format "x(200)"
        with frame fregistro width 255.
    vregistro = vreg1.
    i-cont = i-cont + int(substr(vregistro,195,6)).
    if substr(vregistro,1,1) = "0"
    then run header.
    if substr(vregistro,01,01) = "1" and
       substr(vregistro,42,01) = "0"
    then run saldo-inicial.

    if substr(vregistro,01,01) = "1" and
       substr(vregistro,42,01) = "1"
    then run lancamento.
    if substr(vregistro,01,01) = "1" and
       substr(vregistro,42,01) = "2"
    then run saldo-final.
    if substr(vregistro,1,1) = "9"
    then run trailler.
end.
input close.   

procedure header.
end procedure.

procedure saldo-inicial.
end procedure.


procedure lancamento.
    def var vagencia    like agenc.agecod.
    def var vconta      like ccor.ccornum.
    def var vcateg      as   int format "999".
    def var vcodhist    as   char format "x(4)".
    def var vhistori    as   char format "x(25)".
    def var vnumlanc    as   char format "xxxxxx".
    def var vdtlanc     as   date format "99/99/9999".
    def var vvllanc     as   dec  format ">>>,>>>,>>9.99" .
    vagencia = substr(vregistro,18,04).
    vconta   = substr(vregistro,29,13).
    vcateg   = int(substr(vregistro,43,03)).
    vcodhist = substr(vregistro,46,04).
    vhistori = substr(vregistro,50,25).
    vnumlanc = substr(vregistro,75,06).
    vdtlanc  = date(int(substr(vregistro,83,02)),
                    int(substr(vregistro,85,02)),
                    int("20" + substr(vregistro,81,02)) ).  /* aammdd */
    vvllanc  = dec(substr(vregistro,87,18)) / 100.

    disp vagencia
         vconta  
         vcateg  
         vcodhist
         vhistori
         vnumlanc
         vdtlanc 
         vvllanc
         with 1 column. 

end procedure.

procedure saldo-final.
end procedure.
procedure  trailler. 
end procedure.


                         /*
    assign vcodcedente  =     substr(vregistro,018,012)
           vtitcod      =     substr(vregistro,038,025)
           vnumtitpor   =     substr(vregistro,063,010)
           verro1       =     substr(vregistro,083,003)
           verro2       =     substr(vregistro,086,003)
           verro3       =     substr(vregistro,089,003)
           verro4       =     substr(vregistro,092,003)
           vocorr       =     substr(vregistro,109,002)
           vdtocor      =     substr(vregistro,111,006)
           vtitnum      =     substr(vregistro,117,010)
           vtitvecto    =     substr(vregistro,147,006)
           vtitvalor    =     substr(vregistro,153,013)
           vbanpago     =     substr(vregistro,166,003)
           vvlpago      =     substr(vregistro,254,013)
           vdtcred      =     substr(vregistro,296,006)
           i-cont       = i-cont + int(substr(vregistro,395,6)).
    find titulo where titulo.titcod = int(vtitcod) no-error.
    create wfcrit.
    assign wfcrit.tipo          = vocorr.
    assign
               wfcrit.titnum    = vtitnum
               wfcrit.numtitpor = vnumtitpor
               wfcrit.erro1     = verro1
               wfcrit.erro2     = verro2
               wfcrit.erro3     = verro3
               wfcrit.erro4     = verro4
               wfcrit.ocorr     = vocorr
               wfcrit.dtocor    = vdtocor
               wfcrit.titvecto  = vtitvecto
               wfcrit.titvalor  = vtitvalor
               wfcrit.banpago   = vbanpago
               wfcrit.vlcobra   = vvlcobra
               wfcrit.vlout     = vvlout
               wfcrit.vlabat    = vvlabat
               wfcrit.vldesc    = vvldesc
               wfcrit.vlpago    = vvlpago
               wfcrit.vlmora    = vvlmora
               wfcrit.vlmulta   = vvlmulta
               wfcrit.dtcred    = vdtcred.
    if not avail titulo
    then find first titulo where
                    titulo.bancod = 041 and
                    titulo.numtitpor = vnumtitpor no-error.
    if not avail titulo
    then do:
        if index(vtitnum,"/") > 1
        then do:
            ctitnum = substring(vtitnum,1,index(vtitnum,"/") - 1).
            ctitpar = int(substring(vtitnum,index(vtitnum,"/") + 1)).
            find first titulo where
                    titulo.titnat = no and
                    titulo.titnum = ctitnum and
                    titulo.titpar = ctitpar no-error.
        end.
    end.
    if not avail titulo
    then do:
        assign wfcrit.tipo      = "SEM REGISTRO NO SISTEMA"
               wfcrit.rec       = ?.
    end.
    else do:
        find banlote of titulo no-error.
        if avail banlote
        then
            if banlote.titdtret = ?
            then
                banlote.titdtret = today.
        wfcrit.rec       = recid(titulo).
        if titulo.titdtpag <> ?
        then do:
            assign wfcrit.tipo  = "JA LIQUIDADO"
               wfcrit.dtocor    = vdtocor
               wfcrit.titvecto  = vtitvecto
               wfcrit.titvalor  = vtitvalor
               wfcrit.banpago   = vbanpago
               wfcrit.vlcobra   = vvlcobra
               wfcrit.vlout     = vvlout
               wfcrit.vlabat    = vvlabat
               wfcrit.vldesc    = vvldesc
               wfcrit.vlpago    = vvlpago
               wfcrit.vlmora    = vvlmora
               wfcrit.vlmulta   = vvlmulta
               wfcrit.dtcred    = vdtcred.
        end.
        else do:
        if vocorr = "02"   /* Confirmacao de entrada */
        then do:
            find ocorren where ocorren.bancod   = 041 and
                             ocorren.codocorr = vocorr no-lock no-error.
            assign
                   titulo.titobs[1] = "Cod. Cedente : " + vcodcedente
                   titulo.numtitpor = vnumtitpor
                   titulo.titdtret  = today
                   titulo.titdtban  = if titulo.titdtban = ?
                                      then today
                                      else titulo.titdtban
                   titulo.carcod    = if avail banlote
                                      then banlote.carcod
                                      else titulo.carcod
                   titulo.cobcod    = if avail banlote
                                      then wempre.cobcod-banco
                                      else titulo.cobcod
                   titulo.bancod    = 41
                   wfcrit.tipo      = "ENTRADA"
                   vhistorico       = wfcrit.tipo + " - " +
                                             (if avail ocorren
                                              then ocorren.ocornom
                                              else "").
            run fgtitcob.p (input recid(titulo),
                            input titulo.modcod,
                            input titulo.carcod,
                            input titulo.cobcod,
                            input titulo.bancod,
                            input titulo.numtitpor,
                            input 4,    /* Confirmacao de Entrada */
                            input titulo.blocod).
        end.
        if vocorr = "03"  /* Entrada rejeitada */
        then do:
            find ocorren where ocorren.bancod   = 041 and
                             ocorren.codocorr = vocorr no-lock no-error.
            assign
                   titulo.cobcod    = 1
                   titulo.carcod    = 1
                   titulo.bancod    = 0
                   titulo.numtitpor = ""
                   titulo.titobs[1] = "".
            run fgtitcob.p (input recid(titulo),
                            input titulo.modcod,
                            input titulo.carcod,
                            input titulo.cobcod,
                            input titulo.bancod,
                            input titulo.numtitpor,
                            input 5,    /* ENTRADA REJEITADA */
                            input titulo.blocod).
                assign
                   titulo.bancod    = 0
                   titulo.titdtret  = today
                   titulo.titdtban  = ?
                   vhistorico       =
                                             (if avail ocorren
                                              then ocorren.ocornom
                                              else "").
            pause 1 no-message.
            assign
                   wfcrit.tipo      = "REJEITADO"
                   wfcrit.erro1     = verro1
                   wfcrit.erro2     = verro2
                   wfcrit.erro3     = verro3
                   wfcrit.erro4     = verro4
                   vhistorico       = wfcrit.tipo + " - " +
                                             (if avail ocorren
                                              then ocorren.ocornom
                                              else "").
            pause 1 no-message.
        end.
        if vocorr = "10" or     /* Baixado conforme Instrucoes */
           vocorr = "40" or     /* baixa de titulo protestado */
           vocorr = "09"        /* Devolucao Automatica        */
        then do:
            find ocorren where ocorren.bancod   = 041 and
                             ocorren.codocorr = vocorr no-lock no-error.
            assign
                   titulo.cobcod    = 1
                   titulo.carcod    = 1
                   titulo.bancod    = 0
                   titulo.numtitpor = ""
                   titulo.titobs[1] = "".
            run fgtitcob.p (input recid(titulo),
                            input titulo.modcod,
                            input titulo.carcod,
                            input titulo.cobcod,
                            input titulo.bancod,
                            input titulo.numtitpor,
                            input (if vocorr = "10"
                                   then 42  /* baixado conforme instrucoes */
                                   else
                                   if vocorr = "40"
                                   then 43  /* Baixa de Titulo Protestado */
                                   else
                                   if vocorr = "09"
                                   then 44  /* Devolucao Automatica */
                                   else 8), /* DEVOLUCAO / BAIXADO CFE INSTR */
                            input titulo.blocod).
            assign
                   titulo.bancod    = 0
                   titulo.titdtret  = today
                   vhistorico       =
                                             (if avail ocorren
                                              then ocorren.ocornom
                                              else "").
                assign
                   wfcrit.tipo      = "BAIXA"
                   wfcrit.erro1     = verro1
                   wfcrit.erro2     = verro2
                   wfcrit.erro3     = verro3
                   wfcrit.erro4     = verro4
                   vhistorico       = wfcrit.tipo + " - " +
                                             (if avail ocorren
                                              then ocorren.ocornom
                                              else "").
            pause 1 no-message.
        end.
        if vocorr = "06" or         /* Liquidacao normal  */
           vocorr = "07" or         /* Liquidacao Parcial */
           vocorr = "08" or         /* Baixa por pgto, liquidacao pelo saldo */
           vocorr = "15" or         /* Pagamento em cartorio */
           vocorr = "30"            /* Cabranca a creditar */
        then
            if titulo.titdtpag = ?
            then do:
                create wfselecao.
                wfselecao.titcod = titulo.titcod.
                assign
                   titulo.titobs[1] = "Cod. Cedente : " + vcodcedente
                       titulo.titdtpag = if substr(vdtcred,5,2) <= "30"
                                         then (
                                  date(int(substr(string(vdtcred),3,2)),
                                       int(substr(string(vdtcred),1,2)),
                                       int(string("20" + substr(vdtcred,5,2))))
                                              )
                                         else (
                                  date(int(substr(string(vdtcred),3,2)),
                                       int(substr(string(vdtcred),1,2)),
                                       int(string("19" + substr(vdtcred,5,2))))
                                               )
                       titulo.titvlpag = dec(vvlpago) / 100
                       titulo.titdesc  = if titulo.titvlpag < titulo.titvlcob
                                         then titulo.titvlcob - titulo.titvlpag
                                         else 0
                       titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                         then titulo.titvlpag - titulo.titvlcob
                                         else 0
                       titulo.titsit   = "PAG"
                       wfcrit.tipo     = if vocorr = "30"
                                         then "LIQ CRED30"
                                         else "LIQUIDACAO"
               wfcrit.dtocor    = vdtocor
               wfcrit.titvecto  = vtitvecto
               wfcrit.titvalor  = vtitvalor
               wfcrit.banpago   = vbanpago
               wfcrit.vlcobra   = vvlcobra
               wfcrit.vlout     = vvlout
               wfcrit.vlabat    = vvlabat
               wfcrit.vldesc    = vvldesc
               wfcrit.vlpago    = vvlpago
               wfcrit.vlmora    = vvlmora
               wfcrit.vlmulta   = vvlmulta
               wfcrit.dtcred    = vdtcred
               vhistorico       = wfcrit.tipo + " - " +
                                         (if avail ocorren
                                          then ocorren.ocornom
                                           else "").
            pause 1 no-message.
            end.
            else
                assign wfcrit.tipo  = "JA LIQUIDADO"
               wfcrit.dtocor    = vdtocor
               wfcrit.titvecto  = vtitvecto
               wfcrit.titvalor  = vtitvalor
               wfcrit.banpago   = vbanpago
               wfcrit.vlcobra   = vvlcobra
               wfcrit.vlout     = vvlout
               wfcrit.vlabat    = vvlabat
               wfcrit.vldesc    = vvldesc
               wfcrit.vlpago    = vvlpago
               wfcrit.vlmora    = vvlmora
               wfcrit.vlmulta   = vvlmulta
               wfcrit.dtcred    = vdtcred.
        end.
    end.
end.
input close.

vlpag = 0.
for each wfselecao.
    find titulo where titulo.titcod = wfselecao.titcod no-lock.
    vlpag = vlpag + titulo.titvlpag.
end.
if vlpag > 0
then do:

do on error undo.
    find caixa where caixa.cxbcod = 10.
    caixa.cxadt = today.
end.
find opcaixa where opcaixa.ocxcod = 803 no-lock.
run gercxm.p (  input recid(caixa),
                input opcaixa.opcnat,
                input vlpag,
                input 0,
                output rec-cxmov).

for each wfselecao,
    titulo where titulo.titcod = wfselecao.titcod:
    run gercxo.p (input recid(opcaixa),
                  input opcaixa.cxaass,
                  input rec-cxmov,
                  input recid(caixa),
                  input recid(titulo),
                  input titulo.titvlpag,
                  input "LIQUIDACAO ARQUIVO BANCARIO",
                  input "",
                  output recatu1).
end.

run gercxr.p (input rec-cxmov,
              input "RET",
              input ?,
              input vlpag).
end.

varqsai = "../impress/banris." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "161"
    &Page-Line = "66"
    &Nom-Rel   = ""BANRISRET""
    &Nom-Sis   = """SISTEMA FINANCEIRO - COMUNICACAO BANCARIA"""
    &Tit-Rel   = """RETORNO DO ARQUIVO "" + caps(varquivo) + "" - Banrisul"""
    &Width     = "161"
    &Form      = "frame f-cabcab"}


for each wfcrit break by wfcrit.ocorr.
    if first-of(wfcrit.ocorr)
    then do:
        find ocorren where ocorren.bancod   = 041 and
                         ocorren.codocorr = wfcrit.ocorr no-lock no-error.
        display wfcrit.ocorr column-label "Ocor"
                ocorren.ocornom when avail ocorren format "x(35)"
                with frame flin no-box.
    end.
    find titulo where recid(titulo) = wfcrit.rec no-error.
    if avail titulo
    then
        find agcom of titulo no-lock.
    verro = "".
    if wfcrit.erro1 <> ""
    then do:
        find taberros where taberros.bancod = 041 and
                            taberros.errocod = wfcrit.erro1 no-error.
        verro[1] = taberros.erronom.
    end.
    if wfcrit.erro2 <> ""
    then do:
        find taberros where taberros.bancod = 041 and
                            taberros.errocod = wfcrit.erro2 no-error.
        verro[2] = taberros.erronom.
    end.
    if wfcrit.erro3 <> ""
    then do:
        find taberros where taberros.bancod = 041 and
                            taberros.errocod = wfcrit.erro3 no-error.
        verro[3] = taberros.erronom.
    end.
    if wfcrit.erro4 <> ""
    then do:
        find taberros where taberros.bancod = 041 and
                            taberros.errocod = wfcrit.erro4 no-error.
        verro[4] = taberros.erronom.
    end.

    vvlpag = dec(wfcrit.vlpago) / 100.
    display wfcrit.tipo
            agcom.cgccpf    when avail titulo
            if avail titulo
            then titulo.titnum
            else wfcrit.titnum  @ titulo.titnum
            titulo.titpar when avail titulo
            wfcrit.numtitpor column-label "Numero Banco"
            wfcrit.dtocor     column-label "Dta Proc" format "99/99/9999"
            wfcrit.titvecto   column-label "Venc" format "99/99/9999"
            dec(wfcrit.titvalor) / 100 @
            wfcrit.titvalor   column-label "Vlr Cobra" format "x(15)"
            vvlpag    column-label "Vlr Pago" format ">>>,>>9.99"
                                            (total by wfcrit.ocorr)
            wfcrit.dtcred     column-label "Dta Cred"
            with frame flin down width 200.
    down with frame flin.
    /*
    if verro[2] <> ""
    then do:
        display verro[2] @ verro[1]
                 with frame flin.
        down with frame flin.
    end.
    if verro[3] <> ""
    then do:
        display verro[3] @ verro[1]
                 with frame flin.
        down with frame flin.
    end.
    if verro[4] <> ""
    then do:
        display verro[4] @ verro[1]
                with frame flin.
        down with frame flin.
    end.
    */
end.

{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """BANRIRET"""
    &Page-Size = "64"
    &Width     = "130"
    &Traco     = "80"
    &Form      = "frame f-rod3"}.
unix silent value("cp " + varquivo + " /usr/cpd/banrisul/" + "v041" +
                    string(today,"999999") + "." + string(time,"HH:MM")).
unix silent value("rm " + varquivo + " ./retorno.txt ./retorno.d").

*/
