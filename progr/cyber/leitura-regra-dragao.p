/*********************   
    REGRA DE TITULOS DO L&P COM ATRASO DE 1 DIA
    conectar o dragao para buscar os titulos L&P com 1 dia de atraso 
********************/

{admcab.i}

def input parameter p-today as date.

def var vprocessa as log.
def var vdias  as int.
def var vct    as int.
def var vcontnum as int.

def temp-table tt-titulo
    field contnum like fin.contrato.contnum
    field regra   as log init no
    field rec_titulo    as recid

    index contnum    is primary unique contnum rec_titulo
    index rec_titulo is unique rec_titulo asc.

/* verifica pagamentos de contratos enviados, pois se houver pagamento, devera
   ser enviado o registro de pagamento ao Cyber
   verificar se cliente deve ser enviado
*/
message string(time,"hh:mm:ss") "verifica pagamentos de contratos abertos".
for each cyber_contrato where cyber_contrato.situacao
                          and cyber_contrato.banco = "Dragao"
                        no-lock.
    if cyber_contrato.clicod = 0
    then next.

    for each cyber_parcela of cyber_contrato
                           where cyber_parcela.banco    = "Dragao" no-lock.
        find d.titulo where d.titulo.empcod = cyber_parcela.empcod
                        and d.titulo.titnat = cyber_parcela.titnat
                        and d.titulo.modcod = cyber_parcela.modcod
                        and d.titulo.etbcod = cyber_parcela.etbcod
                        and d.titulo.clifor = cyber_parcela.clifor
                        and d.titulo.titnum = cyber_parcela.titnum
                        and d.titulo.titpar = cyber_parcela.titpar
                      no-lock no-error.
        if not avail d.titulo
        then next.
        if (cyber_parcela.titdtpag = ? and
            d.titulo.titdtpag <> ?) or
           cyber_parcela.titdtpag >= p-today
        then
            run cyber/grava_historico-dragao.p (input recid(d.titulo),
                                         input ?,   
                                         input "PAGA",
                                         input ?).
    end.
end.

/*********************   
    REGRA DE TITULOS DO L&P COM ATRASO DE 1 DIA
    conectar o dragao para buscar os titulos L&P com n dias de atraso 
********************/

for each estab no-lock.

    vprocessa = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_LP"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa = yes.
        else vprocessa = no.

    if not vprocessa
    then next.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_LP"
                       no-lock no-error.
    if not avail tab_ini
    then next.

    vdias = int(tab_ini.valor).

    message string(time,"hh:mm:ss") "Novacao Dragao" estab.etbcod vdias.

    for each d.titulo where d.titulo.empcod   = 19
                        and d.titulo.titnat   = no
                        and d.titulo.modcod   = "CRE"
                        and d.titulo.etbcod   = estab.etbcod
                        and d.titulo.titdtven < p-today - vdias /* a partir */
                        and d.titulo.titsit   = "LIB"
                      no-lock.
        if d.titulo.clifor <= 1 or
           d.titulo.clifor = ? or
           d.titulo.titnum = "" or
           d.titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
        then next.

        find clien where clien.clicod = d.titulo.clifor no-lock no-error. 
        if not avail clien
        then next.

        vcontnum = int(d.titulo.titnum).
        find d.contrato where d.contrato.contnum = vcontnum no-lock no-error.
        if not avail d.contrato
        then next.

        /* verifica se já foi enviado para o Cyber      */ 
        find first cyber_parcela_h of d.titulo
                   where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
        if avail cyber_parcela_h
        then next.

        find tt-titulo where tt-titulo.rec_titulo = recid(d.titulo) no-error.
        if not avail tt-titulo
        then create tt-titulo.
        assign tt-titulo.contnum    = vcontnum 
               tt-titulo.regra      = yes
               tt-titulo.rec_titulo = recid(d.titulo).
    end.
end.

/***
    Atrasados
    Deletar previamente  cyber_parcela_h where tipo     = "PARCE"
***/
/***
if today = 08/05/2015
then do.
    message string(time,"hh:mm:ss") "Atrasados".
    for each cyber_clien no-lock.
        /* ler todos os titulos abertos do cliente para enviar os contratos */
        for each d.titulo where d.titulo.clifor   = cyber_clien.clicod
                            and d.titulo.empcod   = 19
                            and d.titulo.titnat   = no
                            and d.titulo.modcod   = "CRE"
                            and d.titulo.titsit   = "LIB"
                            and d.titulo.titpar   >= 30
                            and d.titulo.titvlcob > 0.01 /*** 02.08.16 ***/
                          use-index  iclicod no-lock.
            if d.titulo.titnum = ""
            then next.

            /* verifica se já foi enviado para o Cyber      */ 
            find first cyber_parcela_h of d.titulo
                       where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
            if avail cyber_parcela_h
            then next.

            vct = vct + 1.
            if vct mod 5000 = 0
            then message string(time,"hh:mm:ss") "Arrasto" vct clien.clicod.

            vcontnum = int(d.titulo.titnum).
            find tt-titulo where tt-titulo.rec_titulo = recid(d.titulo)
                           no-error.
            if not avail tt-titulo
            then do.
                create tt-titulo.
                assign tt-titulo.contnum    = vcontnum 
                       tt-titulo.rec_titulo = recid(d.titulo).
            end.
        end.
    end.
    message string(time,"hh:mm:ss") "Atrasados" vct.
end.
***/
/***
    Fim atrasados
***/

message string(time,"hh:mm:ss") "Historico Dragao" vct.
for each tt-titulo no-lock.
    vct = vct + 1.
    if vct mod 5000 = 0
    then message string(time,"hh:mm:ss") " Historico Dragao" vct.
    run cyber/grava_historico-dragao.p (input tt-titulo.rec_titulo,
                                     input ?,   
                                     input "INCLUI",
                                     input tt-titulo.regra).
end.
message string(time,"hh:mm:ss") "Historico Dragao" vct.

/***
    FIM DRAGAO
***/
