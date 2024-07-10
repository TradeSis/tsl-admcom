/* helio 082023 - CESSÃO BARU - ORQUESTRA 536437 */
{admcab.i}
/**
def input param vcobcodori  as int.
def input param vcobcoddes  as int.  
**/


def var vdesagio as dec.
def var vpasta    as char init "/admcom/import/baru/".
def var varqout as char format "x(65)".

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


def var vtitvlpres as dec.

def temp-table ttcontrato no-undo
    field contnum   like contrato.contnum
    field cobcod    like titulo.cobcod
    index idx is unique primary contnum asc.

def temp-table tt-titulo no-undo
    field rec as recid
    field seq as int
    field titvlpres like vtitvlpres.

def var vtitle as char.
def buffer dcobra for cobra.
/**
find  cobra where  cobra.cobcod = vcobcodori no-lock.
find dcobra where dcobra.cobcod = vcobcoddes no-lock.
**/

vtitle =  /*string(cobra.cobcod,"99")  + "-" +  cobra.cobnom + " -> " + 
         string(dcobra.cobcod,"99") + "-" + dcobra.cobnom + " - CONFIRMACAO FIC"
         */
         "Cessao Baru       - Receber Arquivo Confirmacao ".



disp 
    vtitle format "x(60)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

    
    run get_file.p (vpasta,"csv",output varquivo). /**REM**/
    
do on error undo with frame f-filtro side-label centered
        title " Importar Inclusao baru ".
        
    disp varquivo colon 15 label "Arquivo"   format "x(60)".

    if search(varquivo) = ?
    then do.
        message "Arquivo nao localizado" view-as alert-box.
        return.
    end.
end.

   varqout = "/admcom/tmp/ctb/Cessao-Baru/" + "vendabaru_" + 
                     string(today,"99999999")  + "_" + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
def stream tela.
output stream tela to terminal.
form vctlin label "Linhas Verificadas"
     with frame f-verifica side-label centered.


/**
message "Verificando arquivo...".
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
        
        vtitvlpres = dec(substring(vlinha,193,13)) / 100.

        find contrato where contrato.contnum = int(vtitnum) no-lock no-error.
        if not avail contrato
        then do:
            message "CONTRATO nao encontrado: #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        end.
        
        find first titulo
                    where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = contrato.modcod
                      and titulo.etbcod   = contrato.etbcod 
                      and titulo.clifor   = contrato.clicod  
                      and titulo.titnum   = string(contrato.contnum)
                      and titulo.titpar   = vtitpar
                   no-lock no-error.
        if not avail titulo
        then do.
            message "TITULO nao encontrado: #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        end.

        /**if  vcobcoddes = 16 and /* PARA baru LEBES */
            (titulo.cobcod <> vcobcodori and titulo.cobcod <> 2)  /* ORIGINAL NA LEBES */
        then do.
            message "TITULO nao ESTA NA CARTEIRA LEBES #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        end.
        if  vcobcoddes = 14 and /* PARA baru  */
            titulo.cobcod <> vcobcodori  /* ORIGINAL NA FINANCEIRA */
        then do.
            message "TITULO nao ESTA NA CARTEIRA FINANCEIRA #" vctlin
                    vtitnum "Par=" vtitpar "Emi=" vtitdtemi "Ven=" vtitdtven
                    view-as alert-box.
            verro = yes.
            leave.
        end.
        **/

        create tt-titulo.
        assign
            tt-titulo.rec = recid(titulo)
            tt-titulo.seq = vctlin
            tt-titulo.titvlpres = vtitvlpres.
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
**/

message "Importando arquivo...".
input from value(varquivo).
repeat.
    vctlin = vctlin + 1.
    if vctlin mod 75 = 0
    then disp stream tela vctlin label "Linhas Verificadas"
              with frame f-verifica side-label centered.
    pause 0.
    import delimiter ";" vtitnum vtitpar.

        find contrato where contrato.contnum = int(vtitnum) no-lock no-error.
        if not avail contrato
        then do:
            message "CONTRATO nao encontrado: #" vctlin
                    vtitnum "Par=" vtitpar 
                    view-as alert-box.
            verro = yes.
            leave.
        end.
        
        find first titulo
                    where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = contrato.modcod
                      and titulo.etbcod   = contrato.etbcod 
                      and titulo.clifor   = contrato.clicod  
                      and titulo.titnum   = string(contrato.contnum)
                      and titulo.titpar   = vtitpar
                   no-lock no-error.
        if not avail titulo
        then do.
            message "TITULO nao encontrado: #" vctlin
                    vtitnum "Par=" vtitpar 
                    view-as alert-box.
            verro = yes.
            leave.
        end.
        vdetalhe = vdetalhe + 1.

        create tt-titulo.
        assign
            tt-titulo.rec = recid(titulo)
            tt-titulo.seq = vctlin
            tt-titulo.titvlpres = vtitvlpres.
        assign
            vlotqtde  = vlotqtde + 1
            vlottotal = vlottotal + titulo.titvlcob.
     
end.
input close.


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

    if true /**titulo.cobcod <> vcobcoddes**/
    then do:

        /**vcobcodori = titulo.cobcod.**/
        find first ttcontrato where ttcontrato.contnum = int(titulo.titnum) no-error.
        if not avail ttcontrato
        then do:
            create ttcontrato.
            ttcontrato.contnum = int(titulo.titnum).
            /**ttcontrato.cobcod = vcobcodori.**/
        end.

        /**run finct/trocacart.p (vcobcoddes, /* 09022023 helio ID 155965 - motivo*/
                               today, 
                               yes ,  /* #04082022 helio - estava no, mas tem que ser yes pois troca carteira mesmo de titulo pago */ 
                               int(titulo.titnum),
                               titulo.titpar,
                               "Troca Carteira de " +  string(vcobcodori) + "->" + string(vcobcoddes) + " - lote baru " + string(vlote)
                                    + " (PROGRAMA:finct/trocobbaruconf.p) "
                                ). /* 09022023 */
        **/
        /**    
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
            titulolog.campo   = "BARU"
            titulolog.valor   = "CESSAO".
            titulolog.obs     = "Cessao Baru - lote " + string(vlote).

        /**assign titulo.cobcod = vcobcoddes.**/

        find first titulolog where
            titulolog.empcod = titulo.empcod and
            titulolog.titnat = titulo.titnat and
            titulolog.modcod = titulo.modcod and
            titulolog.etbcod = titulo.etbcod and
            titulolog.clifor = titulo.clifor and
            titulolog.titnum = titulo.titnum and
            titulolog.titpar = titulo.titpar and
            titulolog.campo   = "Desagio"
            no-error.
        if not avail titulolog
        then do:
            create titulolog.
            assign
                titulolog.empcod = titulo.empcod
                titulolog.titnat = titulo.titnat
                titulolog.modcod = titulo.modcod
                titulolog.etbcod = titulo.etbcod
                titulolog.clifor = titulo.clifor
                titulolog.titnum = titulo.titnum
                titulolog.titpar = titulo.titpar.
                titulolog.campo   = "Desagio".
        end.            
        assign
            titulolog.data   = today
            titulolog.hora   = time
            titulolog.funcod = sfuncod
            titulolog.valor  = string(tt-titulo.titvlpres).
            titulolog.obs    = "Cessao Baru - Desagio ".
        **/


        titulo.cessaobaru = yes.
        
    end.
    
end.

run outcontratos.

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



message "Processo concluido." varqout.
do on endkey undo.
pause 2.
end.

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




procedure outcontratos.

    def var ccarteira as char.
    def var dcarteira as char.
    def buffer dcobra for cobra.    
    def var cmodnom   as char.
   def var vi as int. def var ctpcontrato as char.
    
   def var vdtout  as date format "99/99/9999" label "Data" init today. 
   def var varqin  as char format "x(65)".

def var vtitvlpag as dec.
def var vvlrpago  as dec.        
def var vtitvlabe as dec.
   def var vcp  as char init ";".

 
    output to value(varqout). 
    put unformatted 
        "Codigo" vcp 
        "Nome"   vcp 
        "CPF"    vcp 
        "Emissão" vcp 
        "Contrato" vcp  
        /*
        "Parcela"  vcp
        */
        "Carteira original" vcp 
        "Data Realocacao" vcp
        "Carteira" vcp 
        "Modalidade"  vcp 
        "Filial"  vcp 
        "Tipo de cobrança" vcp 
        /*
        "Vencimento" vcp
        */
        "Entrada" vcp
        "Principal"  vcp
        "Acrescimo"  vcp
        "Seguro" vcp
        "Total" vcp
        
        /*
        "Dt Pag" vcp
        */
        "Vlr Pago" vcp
        "Vlr Juros Atr" vcp
        "Vlr Tot Pago" vcp
        "Vlr Aberto" vcp
        "Desagio" vcp 
        skip.
                                                
                                                
    for each ttcontrato.
        
        find contrato where contrato.contnum = ttcontrato.contnum no-lock no-error.
        if not avail contrato then next.
        find clien where clien.clicod = contrato.clicod no-lock no-error.

            find cobra where cobra.cobcod = ttcontrato.cobcod no-lock no-error.
            /**find dcobra where dcobra.cobcod = vcobcoddes no-lock.**/
        
            find modal where modal.modcod = contrato.modcod no-lock no-error.
            ccarteira = (if ttcontrato.cobcod <> ? 
                     then string(ttcontrato.cobcod) + if avail cobra 
                                               then ("-" + cobra.cobnom)
                                               else ""
                     else "-").
            /**dcarteira = (if vcobcoddes <> ? 
                     then string(vcobcoddes) + if avail dcobra 
                                               then ("-" + dcobra.cobnom)
                                               else ""
                     else "-").**/

            ctpcontrato = if contrato.tpcontrato <> ? 
                    then if contrato.tpcontrato = "F"
                         then "FEIRAO"
                         else if contrato.tpcontrato = "N"
                              then "NOVACAO"
                              else if contrato.tpcontrato = "L"
                                   then "LP "
                                   else "normal"
                    else     "-".

            cmodnom = if contrato.modcod <> ? 
                    then contrato.modcod + if avail modal then "-" + modal.modnom else ""
                    else "-".
                    
            put unformatted
                contrato.clicod     vcp
                if avail clien then clien.clinom else "-"       vcp
                if avail clien then clien.ciccgc else "-"       vcp
                contrato.dtinicial  format "99/99/9999" vcp
                contrato.contnum    vcp
                ccarteira      vcp 
                vdtout             format "99/99/9999"  vcp
                dcarteira           vcp
                cmodnom             vcp
                contrato.etbcod     vcp
                ctpcontrato         vcp
                trim(string(contrato.vlentra,">>>>>9.99")) vcp
                trim(string(contrato.vlf_principal,">>>>>9.99")) vcp
                trim(string(contrato.vlf_acrescimo,">>>>>9.99")) vcp
                trim(string(contrato.vlseguro,">>>>>9.99")) vcp
                trim(string(contrato.vltotal,">>>>>9.99")) vcp .
        
        vtitvlpag = 0.
        vvlrpago  = 0.
        vtitvlabe = 0.
        vdesagio = 0.
        for each  titulo where
            titulo.empcod = 19 and titulo.titnat = no and titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum)

            no-lock.

            if titulo.titpar = 0 then next.
                      
            if titulo.titsit = "LIB"
            then do:
                vtitvlabe = vtitvlabe + titulo.titvlcob.
            end.
            if titulo.titsit = "PAG"
            then do:
                vtitvlpag = vtitvlpag + titulo.titvlpag.
                vvlrpago  = vvlrpago  + titulo.titvlcob.
            end.    

            find first titulolog where
                titulolog.empcod = titulo.empcod and
                titulolog.titnat = titulo.titnat and
                titulolog.modcod = titulo.modcod and
                titulolog.etbcod = titulo.etbcod and
                titulolog.clifor = titulo.clifor and
                titulolog.titnum = titulo.titnum and
                titulolog.titpar = titulo.titpar and
                titulolog.campo   = "Desagio"
                no-lock no-error.
            if avail titulolog
            then do:
                vdesagio = vdesagio + titulo.titvlcob - dec(titulolog.valor).
            end.
                                  

        end.
        put unformatted 
            trim(string(vvlrpago,">>>>>9.99")) vcp
            trim(string(vtitvlpag - vvlrpago,">>>>>9.99")) vcp
            trim(string(vtitvlpag,">>>>>9.99")) vcp
            trim(string(vtitvlabe,">>>>>9.99")) vcp
            trim(string(vdesagio,">>>>>9.99")) vcp


            skip.
                
    end.
    output close.
end procedure.    




