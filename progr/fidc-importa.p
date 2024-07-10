/* 09022023 helio ID 155965 - motivo */
/* #04082022 helio - ID 138135 - Relatório Cedidos carteira para FIDC
    estava no, mas tem que ser yes pois troca carteira mesmo de titulo pago */ 

/***
    helio 23022022 - Ajuste no menu ADMCOM FIDC
    Projeto FIDC: junho,julho/2018
    Importar CNAB444 com titulos que foram para o FIDC 
***/
{admcab.i}
def input param ptitle as char.
def input param pcobcodori as int.
def input param pcobcoddes as int.

def var vpasta    as char.
def var varquivo  as char.
def var vlinha    as char.
def var vctlin    as int.
def var vheader   as int.
def var vtrailer  as int.
def var vdetalhe  as int.
def var verro     as log.
def var vtrtotreg as int.
def var vetbcod   as int.
def var vtitnum   as char.
def var vtitpar   as int.
def var vtitdtemi as date.
def var vtitdtven as date.
def var vlote     as int.
def var vlottip   as char init "IMPORTA".
def var vlotqtde  as int.
def var vlottotal as dec.
def buffer blotefidc for lotefidc.

def temp-table tt-titulo
    field rec as recid
    field seq as int.

run le_tabini.p (0, 0, "FIDC - PASTA", output vpasta).

do on error undo with frame f-filtro side-label centered width 80
        title ptitle.
    disp vpasta       colon 15 label "Diretorio" format "x(30)".
    update varquivo colon 15 label "Arquivo"   format "x(30)".

    if search(vpasta + varquivo) = ?
    then do.
        message "Arquivo nao localizado" view-as alert-box.
        undo.
    end.
end.

def stream tela.
output stream tela to terminal.
form vctlin label "Linhas Verificadas"
     with frame f-verifica side-label centered.

message "Verificando arquivo...".
varquivo = vpasta + varquivo.
input from value(varquivo).
repeat.
    vctlin = vctlin + 1.
    if vctlin mod 75 = 0
    then disp stream tela vctlin label "Linhas Verificadas"
              with frame f-verifica side-label centered.
    pause 0.
    import unformatted vlinha.

    /* Header */
    if substr(vlinha, 1, 1) = "0"
    then do.
        vheader = vheader + 1.

        if not vlinha begins "01REMESSA01COBRANCA"
        then do.
            message "HEADER invalido" view-as alert-box.
            verro = yes.
            leave.
        end.
    end.

    /* Linha Detalhe */
    else if substr(vlinha, 1, 1) = "1"
    then do.
        vdetalhe = vdetalhe + 1.

        vetbcod = int(substr(vlinha, 38, 3)).  /* campo 10 */
        vtitnum = string(int(substr(vlinha, 41, 10))). /* campo 10 */
        vtitpar = int(substr(vlinha, 51, 3)).  /* campo 10 */
        
        vtitdtven = date(substr(vlinha, 121, 6)).
        vtitdtemi = date(substr(vlinha, 151, 6)).

        find first titulo
                    where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "CRE"
                      and titulo.titdtemi = vtitdtemi
                      and titulo.etbcod   = vetbcod
                      
                      and titulo.titnum   = vtitnum
                      and titulo.titpar   = vtitpar
                      and titulo.titdtven = vtitdtven
                   no-lock no-error.
        if not avail titulo
        then do.
            message "TITULO nao encontrado: #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        end.

        /* verifica se esta no FIDC */
        find first envfidc where envfidc.empcod = titulo.empcod
                             and envfidc.titnat = titulo.titnat
                             and envfidc.modcod = titulo.modcod
                             and envfidc.etbcod = titulo.etbcod
                             and envfidc.clifor = titulo.clifor
                             and envfidc.titnum = titulo.titnum
                             and envfidc.titpar = titulo.titpar
                             and envfidc.lottip = vlottip
                           no-lock no-error.

        if titulo.cobcod <> pcobcodori
        then do:
            message "TITULO nao ESTA NA CARTEIRA FINANCEIRA #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        
        end.


        create tt-titulo.
        assign
            tt-titulo.rec = recid(titulo)
            tt-titulo.seq = vctlin.
        assign
            vlotqtde  = vlotqtde + 1
            vlottotal = vlottotal + titulo.titvlcob.
    end.

    /* Trailer */
    else if substr(vlinha, 1, 1) = "9"
    then do.
        vtrailer = vtrailer + 1.
        vtrtotreg = int(substr(vlinha, 439, 6)).
    end.
end.
input close.
hide frame f-verifica no-pause.

if not verro
then run erro (output verro).
if verro
then return.

sresp = no.
message "Confirma processar" vdetalhe "TITULOS?" update sresp.
if not sresp
then return.

DO ON ERROR UNDO.
    find last blotefidc where blotefidc.lottip = vlottip no-lock no-error.
    create lotefidc.
    assign lotefidc.lotnum  = (if avail blotefidc 
                             then blotefidc.lotnum + 1
                             else 1)
          lotefidc.lottip  = vlottip
          /***lotefidc.aux-ch  = "FINANCEIRA - EXPORTA CONTRATOS"***/
          lotefidc.data    = today
          lotefidc.hora    = time
          lotefidc.funcod  = sfuncod
          lotefidc.arquivo = varquivo.
          
    assign vlote = lotefidc.lotnum.                         
end.

form vlote label "Lote"
     vctlin label "Linhas Processadas"
     with frame f-processa side-label centered.

vctlin = 0.
for each tt-titulo no-lock.
    vctlin = vctlin + 1.
    if vctlin mod 15 = 0
    then disp vlote label "Lote" vctlin label "Linhas Processadas"
              with frame f-processa side-label centered.
    pause 0.

    find titulo where recid(titulo) = tt-titulo.rec exclusive.

    /* arquivo de controle */    
    find envfidc where envfidc.empcod = titulo.empcod
                   and envfidc.titnat = titulo.titnat
                   and envfidc.modcod = titulo.modcod
                   and envfidc.etbcod = titulo.etbcod
                   and envfidc.clifor = titulo.clifor
                   and envfidc.titnum = titulo.titnum
                   and envfidc.titpar = titulo.titpar

                   and envfidc.lottip = vlottip
                   and envfidc.lotnum = vlote
                   no-lock no-error.
    if not avail envfidc
    then do: 
         create envfidc.
         assign envfidc.empcod = titulo.empcod
                envfidc.titnat = titulo.titnat
                envfidc.modcod = titulo.modcod
                envfidc.etbcod = titulo.etbcod
                envfidc.clifor = titulo.clifor
                envfidc.titnum = titulo.titnum
                envfidc.titpar = titulo.titpar
                envfidc.lottip = vlottip
                envfidc.lotnum = vlote
                envfidc.lotseq = tt-titulo.seq.
    end.

/***
    assign envfinan.envdtinc = today
           envfinan.envhora = time
           envfinan.datexp  = today
           envfinan.txjuro = txjuro
           envfinan.envcet = dvalorcetanual
           envfinan.enviof = viof
           envfinan.lotinc = vlote
           envfinan.lotpag = 0
           envfinan.lotcan = 0 .
***/

/*
    find current envfidc no-lock.
    run grava-cobcod (input recid(titulo)).
*/
        

        create titulolog.
        assign
            titulolog.empcod = titulo.empcod
            titulolog.titnat = titulo.titnat
            titulolog.modcod = titulo.modcod
            titulolog.etbcod = titulo.etbcod
            titulolog.clifor = titulo.clifor
            titulolog.titnum = titulo.titnum
            titulolog.titpar = titulo.titpar
            titulolog.data   = today
            titulolog.hora   = time
            titulolog.funcod = sfuncod
            titulolog.campo   = "CobOri,CobCod"
            titulolog.valor   = string(titulo.cobcod) + "," + string(pcobcoddes).
            titulolog.obs    = "Troca Carteira - lotefidc " + string(vlote).

        /* helio 15122021 - melhorias cr fase ii - registra ctbtrocart */
        
        run finct/trocacart.p (pcobcoddes, /* 09022023 helio ID 155965 - motivo */ 
                               today, 
                               yes ,  /* #04082022 helio - estava no, mas tem que ser yes pois troca carteira mesmo de titulo pago */ 
                               int(titulo.titnum),
                               titulo.titpar,
                               "Troca Carteira de " +  string(titulo.cobcod) + "->" + string(pcobcoddes) + " - lote fidc " + string(vlote)
                                    + " (PROGRAMA:fidc-importa.p) "
                                ). /* 09022023 */
                               
                               
         assign
            titulo.cobcod = pcobcoddes.


end.

do on error undo.
    find lotefidc where lotefidc.lottip = vlottip
                    and lotefidc.lotnum = vlote
                  exclusive-lock no-error.
    if not avail lotefidc
    then do:
        create lotefidc.
        assign lotefidc.lotnum = vlote
               lotefidc.lottip = vlottip.
    end.
    assign lotefidc.data = today
           lotefidc.hora = time
           lotefidc.lotqtd = vlotqtde
           lotefidc.lotvlr = vlottotal.
    find current lotefidc no-lock.
end.

disp vlote label "Lote" vctlin label "Linhas Processadas"
              with frame f-processa side-label centered.
message "Processo concluido".
pause.

procedure erro.

    def output parameter par-erro as log init no.

    def var verro as char.

    if vheader <> 1
    then verro = "Quantidade de registro HEADER invalida:" + string(vheader).

    else if vtrailer <> 1
    then verro = "Quantidade de registro TRAILER invalida:" + string(vtrailer).

    else if vdetalhe < 1
    then verro = "Quantidade de registro DETALHE invalida:" + string(vdetalhe).

    else if vheader + vtrailer + vdetalhe <> vtrtotreg
    then verro = "Quantidade de registros invalido: INFORMADO:" +
            string(vtrtotreg) +
            " LIDOS:" + string(vheader + vtrailer + vdetalhe).

    if verro <> ""
    then do.
        message verro view-as alert-box title " ERRO ".
        par-erro = yes.
    end.

end procedure.

