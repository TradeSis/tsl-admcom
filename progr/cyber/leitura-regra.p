{admcab.i}

def input parameter p-today as date.

def var xdtven as date.
def var qdtven as date.
def var vdtini as date.
def var vdias  as int.
def var vdata  as date.
def var vct    as int.
def var vcontnum  as int.
def var vprocessa as log.
def buffer btitulo for titulo.
pause 0 before-hide.

find Cyber_regras where Cyber_regras.Cyber_Mes = month(p-today) no-lock.
qdtven = date(Cyber_regras.Cyber_MesVecto,
                      21,
                      year(p-today) + Cyber_regras.Cyber_AnoVecto ).
run cyber/busca_data_vencimento.p (input  qdtven,   
                                   output xdtven).
vdtini = date(month(xdtven), 1, year(xdtven)).  

/***
if today = 08/04/2015
then p-today = 06/01/2015.
***/

def temp-table tt-titulo
    field contnum    like fin.contrato.contnum
    field regra      as log init no
    field rec_titulo as recid

    index contnum is primary unique contnum rec_titulo
    index rec_titulo is unique rec_titulo asc.

def temp-table ttclien
    field clicod    like clien.clicod
    index clicod is primary unique clicod desc.

def temp-table tt-contrato
    field empcod    like titulo.empcod
    field titnat    like titulo.titnat
    field modcod    like titulo.modcod
    field etbcod    like titulo.etbcod
    field clifor    like titulo.clifor
    field titnum    like titulo.titnum
    field titdtemi  like titulo.titdtemi
    field arrastar  as log

    index contrato is primary unique 
            empcod titnat modcod etbcod clifor titnum titdtemi.
    
for each tt-titulo.
    delete tt-titulo.
end.
for each ttclien.
    delete ttclien.
end.

/* verifica pagamentos de contratos enviados, pois se houver pagamento, devera
   ser enviado o registro de pagamento ao Cyber
   verificar se cliente deve ser enviado
*/

message vdtini xdtven p-today.
message string(time,"hh:mm:ss") "verifica pagamentos de contratos abertos".
for each cyber_contrato where cyber_contrato.situacao
                        /*** 03/08/2016  and cyber_contrato.banco = "" ***/
                        no-lock.
    if cyber_contrato.clicod <= 1
    then next.

    for each cyber_parcela of cyber_contrato no-lock.
        find titulo of cyber_parcela no-lock no-error.
        if not avail titulo
        then next.

        /* Pagamento */
        if (cyber_parcela.titdtpag = ? and
            titulo.titdtpag <> ?) or
           cyber_parcela.titdtpag >= p-today
        then run cyber/grava_historico.p (input recid(titulo),
                                          input ?,   
                                          input "PAGA",
                                          input ?).
        vprocessa = no.
        find first cyber_parcela_h of cyber_parcela
                           where cyber_parcela_h.DtEnvio < p-today
                           no-lock no-error.

        /*** 27/11/2015 Enviar pagamento ***/
        if not avail cyber_parcela_h and
           titulo.titdtpag <> ? 
        then vprocessa = yes.

        /* Ajustes 29/10/15 - venceram depois de enviar a carga */
        if avail cyber_parcela_h and
           titulo.titdtpag = ? and
           titulo.titdtven < p-today /* atrasado */
        then
            if titulo.titdtven > cyber_parcela_h.DtEnvio
               /* Venceu depois de enviar o lote -> enviar de novo
                  Quando enviou o lote nao estava vencido ainda */
            then vprocessa = yes.

        if vprocessa
        then do.
            find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
            if not avail tt-titulo
            then do.
                create tt-titulo.
                assign tt-titulo.contnum    = int(titulo.titnum)
                       tt-titulo.regra      = yes
                       tt-titulo.rec_titulo = recid(titulo).
            end.
        end.        
    end.

    find clien where clien.clicod = cyber_contrato.clicod no-lock.
    find cyber_clien of clien no-lock no-error.
    if not avail cyber_clien or
       cyber_clien.DtURen = ? or
       cyber_clien.DtURen < clien.datexp or
       cyber_clien.DtURen >= p-today
    then
        run cyber/grava_historico.p (input ?,
                                     input recid(cyber_contrato),    
                                     input "CADAS", 
                                     input ?).
end.

/***
    NOVACAO
    (PARCELAS MAIORES QUE 30) COM ATRASO DE 1 DIA.
    L&P do dragao
***/
message string(time, "hh:mm:ss") "Novacao".
for each estab no-lock.

    vprocessa = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NOVACAO"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa = yes.
        else vprocessa = no.

    if not vprocessa
    then next.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS_NOVACAO"
                       no-lock no-error.
    if not avail tab_ini
    then next.

    vdias = int(tab_ini.valor).
    message string(time, "hh:mm:ss") "Novacao" estab.etbcod vdias.

        for each titulo where titulo.empcod   = 19
                          and titulo.titnat   = no
                          and titulo.modcod   = "CRE"
                          and titulo.etbcod   = estab.etbcod
                          and titulo.titdtven < p-today - vdias /* a partir */

                          and titulo.titsit   = "LIB"
                          and titulo.titpar   > 30
                        no-lock.
            if titulo.clifor <= 1 or
               titulo.clifor = ? or
               titulo.titnum = "" or
               titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
            then next.

            if acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM" /* L&P */
            then next.

            find clien where clien.clicod = titulo.clifor no-lock no-error. 
            if not avail clien
            then next.

            vcontnum = int(titulo.titnum).
            find contrato where contrato.contnum = vcontnum no-lock no-error.
            if not avail contrato
            then next.
            
            /* verifica se já foi enviado para o Cyber      */ 
            find first cyber_parcela_h of titulo
                       where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
            if avail cyber_parcela_h
            then
                if cyber_parcela_h.DtEnvio >= titulo.titdtven /* 29/10/15 */
                then next.

            find ttclien where ttclien.clicod = titulo.clifor no-error.
            if not avail ttclien
            then do.
                create ttclien.
                ttclien.clicod = titulo.clifor.
            end.

            find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
            if not avail tt-titulo
            then do.
                create tt-titulo.
                assign tt-titulo.contnum    = vcontnum 
                       tt-titulo.regra      = yes
                       tt-titulo.rec_titulo = recid(titulo).
            end.
        end.
end.
/***
    FIM DA NOVACAO
***/

/********************
    REGRA DE TITULOS DO L&P COM ATRASO DE 1 DIA
    buscar os titulos L&P com n dias de atraso - era do dragao
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

    message string(time,"hh:mm:ss") "Novacao L&P" estab.etbcod vdias.

    for each titulo where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "CRE"
                      and titulo.etbcod   = estab.etbcod
                      and titulo.titdtven < p-today - vdias /* a partir */

                      and titulo.titsit   = "LIB"
                      and titulo.titpar   > 51
                    no-lock.
        if titulo.clifor <= 1 or
           titulo.clifor = ? or
           titulo.titnum = "" or
           titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
        then next.

        if acha("RENOVACAO",fin.titulo.titobs[1]) <> "SIM" /* L&P */
        then next.

        find clien where clien.clicod = titulo.clifor no-lock no-error. 
        if not avail clien
        then next.

        vcontnum = int(titulo.titnum).
        find contrato where contrato.contnum = vcontnum no-lock no-error.
        if not avail contrato
        then next.
 
        /* verifica se já foi enviado para o Cyber      */ 
        find first cyber_parcela_h of titulo
                   where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
        if avail cyber_parcela_h
        then next.

        find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
        if not avail tt-titulo
        then create tt-titulo.
        assign tt-titulo.contnum    = vcontnum 
               tt-titulo.regra      = yes
               tt-titulo.rec_titulo = recid(titulo).
    end.
end.
/***
    FIM DA L&P
***/

for each estab no-lock.

    /* regra GERAL - com base na data de processamento, conforme 
       vdtini e xdtven retornadas do programa cyber/busca_data_vencimento.p
       seleciona titulos abertos e cria a 
       temp-table tt-titulo e ttclien
    */
    
    vprocessa = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_GERAL"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa = yes.
        else vprocessa = no.

    if vprocessa   /* regra geral */
    then do.
        message string(time,"hh:mm:ss") "REGRA GERAL" estab.etbcod vprocessa.
        do vdata = vdtini to xdtven.
            for each titulo where titulo.empcod   = 19
                              and titulo.titnat   = no
                              and titulo.modcod   = "CRE"
                              and titulo.etbcod   = estab.etbcod
                              and titulo.titdtven = vdata
                              and titulo.titsit   = "LIB"
                            no-lock.
                if titulo.clifor <= 1 or
                   titulo.clifor = ? or
                   titulo.titnum = "" or
                   titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
                then next.

                find clien where clien.clicod = titulo.clifor no-lock no-error. 
                if not avail clien
                then next.

                vcontnum = int(titulo.titnum).
                find contrato where contrato.contnum = vcontnum
                              no-lock no-error.
                if not avail contrato
                then next.

                /* verifica se já foi enviado para o Cyber      */ 
                find first cyber_parcela_h of titulo
                           where cyber_parcela_h.DtEnvio < p-today
                           no-lock no-error.
                if avail cyber_parcela_h
                then
                    if cyber_parcela_h.DtEnvio >= titulo.titdtven /*29/10/15*/
                    then next.

                find ttclien where ttclien.clicod = titulo.clifor no-error.
                if not avail ttclien
                then do.
                    create ttclien.
                    ttclien.clicod = titulo.clifor.
                end.

                find tt-titulo where tt-titulo.rec_titulo = recid(titulo) 
                               no-error.
                if not avail tt-titulo
                then do.
                    create tt-titulo.
                    assign tt-titulo.contnum    = vcontnum 
                           tt-titulo.regra      = yes
                           tt-titulo.rec_titulo = recid(titulo).
                end.
            end.  
        end.
    end.

    /* regra de numero de dias em atraso, conforme lojas parametrizadas 
       seleciona titulos abertos e cria a 
       temp-table tt-titulo e ttclien
    */
    
    vprocessa = no.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini and
       tab_ini.valor = "SIM"
    then vprocessa = yes.

    find first tab_ini where tab_ini.etbcod    = estab.etbcod and
                             tab_ini.parametro = "CYBER_REGRA_NDIAS"
                       no-lock no-error.
    if avail tab_ini 
    then
        if tab_ini.valor = "SIM"
        then vprocessa = yes.
        else vprocessa = no.

    if not vprocessa
    then next.

    find first tab_ini where tab_ini.etbcod    = 0 and
                             tab_ini.parametro = "CYBER_NDIAS"
                       no-lock no-error.
    if not avail tab_ini
    then next.
    vdias  = int(tab_ini.valor).

    message string(time,"hh:mm:ss") "N dias" estab.etbcod vdias "dias".
    
    for each titulo where titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "CRE"
                      and titulo.etbcod   = estab.etbcod
                      and titulo.titdtven < p-today - vdias /* a partir */
                      and titulo.titsit   = "LIB"
                    no-lock.
        if titulo.clifor <= 1 or
           titulo.clifor = ? or
           titulo.titnum = "" or
           titulo.titvlcob <= 0.01 /*** 02.08.16 ***/
        then next.

        vcontnum = int(titulo.titnum).
        find contrato where contrato.contnum = vcontnum no-lock no-error.
        if not avail contrato
        then next.
      
        find clien where clien.clicod = titulo.clifor no-lock no-error. 
        if not avail clien
        then next.

        /* verifica se já foi enviado para o Cyber      */
        find first cyber_parcela_h of titulo
                           where cyber_parcela_h.DtEnvio < p-today
                           no-lock no-error.
        if avail cyber_parcela_h
        then
            if cyber_parcela_h.DtEnvio >= titulo.titdtven /*29/10/15*/
            then next. 

        find ttclien where ttclien.clicod = titulo.clifor no-lock no-error.
        if not avail ttclien
        then do.
            create ttclien.
            ttclien.clicod = titulo.clifor.
        end.

        find tt-titulo where tt-titulo.rec_titulo = recid(titulo)
                       no-lock no-error.
        if not avail tt-titulo
        then do.
            create tt-titulo.
            assign tt-titulo.contnum    = vcontnum 
                   tt-titulo.regra      = yes
                   tt-titulo.rec_titulo = recid(titulo).
        end.
    end.
end.

/***
    ARRASTO
***/
message string(time,"hh:mm:ss") "Arrasto".
vct = 0.
/*
    esta leitura da temp-table gerada serve para que sejam enviados TODOS os 
    contratos abertos dos clientes selecionados (em atraso conforme regra) ,
    pois o Cyber precisa ter TODA A DIVIDA DO CLIENTE
    ARRASTO
    20/06/2016 - Arrastar somente contratos VENCIDOS
*/
for each ttclien where ttclien.clicod > 1.   
    find clien of ttclien no-lock no-error.
    if not avail clien
    then next.

    /* ler todos os titulos abertos do cliente para enviar os contratos */
    for each titulo where titulo.clifor   = clien.clicod
                      and titulo.empcod   = 19
                      and titulo.titnat   = no
                      and titulo.modcod   = "CRE"
                      and titulo.titsit   = "LIB"
                      and titulo.titvlcob > 0.01 /*** 02.08.16 ***/
                    use-index  iclicod no-lock.
        vcontnum = int(titulo.titnum) no-error.
        if vcontnum = 0 /*** titulo.titnum = "" ***/
        then next.

        /* verifica se já foi enviado para o Cyber      */ 
        find first cyber_parcela_h of titulo
                       where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
        if avail cyber_parcela_h
        then
            /* Venceu depois de enviar o lote -> enviar de novo */
            if cyber_parcela_h.DtEnvio >= titulo.titdtven /* 29/10/15 */
            then next.

        /*** 20/06/2016 ***/
        find tt-contrato where tt-contrato.empcod = titulo.empcod
                           and tt-contrato.titnat = titulo.titnat
                           and tt-contrato.modcod = titulo.modcod
                           and tt-contrato.etbcod = titulo.etbcod
                           and tt-contrato.clifor = titulo.clifor
                           and tt-contrato.titnum = titulo.titnum
                           and tt-contrato.titdtemi = titulo.titdtemi
                         no-lock no-error.
        if not avail tt-contrato
        then do.
            create tt-contrato.
            assign
                tt-contrato.empcod = titulo.empcod
                tt-contrato.titnat = titulo.titnat
                tt-contrato.modcod = titulo.modcod
                tt-contrato.etbcod = titulo.etbcod
                tt-contrato.clifor = titulo.clifor
                tt-contrato.titnum = titulo.titnum
                tt-contrato.titdtemi = titulo.titdtemi.

            find contrato where contrato.contnum = vcontnum no-lock no-error.
            if avail contrato
            then do.
                /* Procurar uma parcela VENCIDA no contrato */
                find first btitulo where btitulo.empcod = titulo.empcod
                                     and btitulo.titnat = titulo.titnat
                                     and btitulo.modcod = titulo.modcod
                                     and btitulo.etbcod = titulo.etbcod
                                     and btitulo.clifor = titulo.clifor
                                     and btitulo.titnum = titulo.titnum
                                     and btitulo.titdtemi = titulo.titdtemi

                                     and btitulo.titdtpag = ?
                                     and btitulo.titsit <> "PAG"
                                     and btitulo.titdtven <= p-today
                                   no-lock no-error.
                if avail btitulo
                then tt-contrato.arrastar = yes.
            end.
        end.
        if not tt-contrato.arrastar
        then next.

        vct = vct + 1.
        if vct mod 5000 = 0
        then message string(time,"hh:mm:ss") "Arrasto" vct clien.clicod.

        find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
        if not avail tt-titulo
        then do.
            create tt-titulo.
            assign tt-titulo.contnum    = vcontnum 
                   tt-titulo.rec_titulo = recid(titulo).
        end.
    end.
end.
message string(time,"hh:mm:ss") "Arrasto" vct.

/***
if today = 01/21/2016
then
    for each cyber_contrato where cyber_contrato.situacao no-lock.
        if cyber_contrato.clicod = 0
        then next.

        for each cyber_parcela of cyber_contrato no-lock.
            find titulo of cyber_parcela no-lock no-error.
            if not avail titulo
            then next.

            find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
            if not avail tt-titulo
            then do.
                create tt-titulo.
                assign tt-titulo.contnum    = int(titulo.titnum)
                       tt-titulo.regra      = yes
                       tt-titulo.rec_titulo = recid(titulo).
            end.
        end.
    end.
***/

/***
    Atrasados
    Deletar previamente  cyber_parcela_h where tipo     = "PARCE"
if today = 08/05/2015
then do.
    message string(time,"hh:mm:ss") "Atrasados".
    for each cyber_clien no-lock.
        /* ler todos os titulos abertos do cliente para enviar os contratos */
        for each titulo where titulo.clifor = cyber_clien.clicod
                          and titulo.empcod = 19
                          and titulo.titnat = no
                          and titulo.modcod = "CRE"
                          and titulo.titsit = "LIB"
                          and titulo.titpar >= 30
                        use-index  iclicod no-lock.
            if titulo.titnum = ""
            then next.

            /* verifica se já foi enviado para o Cyber      */ 
            find first cyber_parcela_h of titulo
                       where cyber_parcela_h.DtEnvio < p-today no-lock no-error.
            if avail cyber_parcela_h
            then next.

            vct = vct + 1.
            if vct mod 5000 = 0
            then message string(time,"hh:mm:ss") "Arrasto" vct clien.clicod.

            vcontnum = int(titulo.titnum).
            find tt-titulo where tt-titulo.rec_titulo = recid(titulo) no-error.
            if not avail tt-titulo
            then do.
                create tt-titulo.
                assign tt-titulo.contnum    = vcontnum 
                       tt-titulo.titpar     = titulo.titpar
                       tt-titulo.rec_titulo = recid(titulo).
            end.
        end.
    end.
    message string(time,"hh:mm:ss") "Atrasados" vct.
end.
    Fim atrasados
***/

message string(time,"hh:mm:ss") "Historico".
vct = 0.
    for each tt-titulo use-index contnum no-lock.
        vct = vct + 1.
        if vct mod 5000 = 0
        then message string(time,"hh:mm:ss") "Historico" vct.
        run cyber/grava_historico.p (input tt-titulo.rec_titulo,
                                     input ?,   
                                     input "INCLUI",
                                     input tt-titulo.regra).
    end.
message string(time,"hh:mm:ss") "Historico" vct.

