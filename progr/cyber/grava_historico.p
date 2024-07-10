/* cyber/grava_historico.p              */
def input parameter rec_titulo as recid.
def input parameter rec_cyber_contrato as recid.
def input parameter par-acao   as char.
def input parameter par-regra  as log.

def var vsaldo      like contrato.vltotal.
def var vtipo       as char.
def var vcontnum    as int.
def buffer btitulo for titulo.

if par-acao = "INCLUI"
then vtipo = "CONTR".
else if par-acao = "PAGA"
then vtipo = "PAGTO".

find titulo where recid(titulo) = rec_titulo no-lock no-error.
if avail titulo
then do on error undo:
    vcontnum = int(titulo.titnum).

    find clien where clien.clicod = titulo.clifor no-lock.

    find contrato where contrato.contnum = vcontnum no-lock no-error.
    if not avail contrato
    then message "NAO ACHEI CONTRATO => "
                " recid(titulo) = " recid(titulo)
                " " titulo.titnum "/" titulo.titpar titulo.etbcod.

    /***
        historico de envio da parcela (titulo)
    ***/
    find cyber_parcela of titulo no-lock no-error.
    if not avail cyber_parcela
    then do.
        create cyber_parcela.
        ASSIGN cyber_parcela.empcod   = titulo.empcod
               cyber_parcela.titnat   = titulo.titnat
               cyber_parcela.modcod   = titulo.modcod
               cyber_parcela.etbcod   = titulo.etbcod 
               cyber_parcela.CliFor   = titulo.CliFor 
               cyber_parcela.titnum   = titulo.titnum 
               cyber_parcela.titpar   = titulo.titpar 
               cyber_parcela.titdtemi = titulo.titdtemi
               cyber_parcela.contnum  = vcontnum 
               cyber_parcela.tipo     = "PARCE"
               cyber_parcela.regra    = par-regra
               cyber_parcela.banco    = ""
               cyber_parcela.titvlcob = titulo.titvlcob
               cyber_parcela.titdtven = titulo.titdtven.
    end.

    find first cyber_parcela_h of titulo where cyber_parcela_h.DtEnvio  = ?
                               no-lock no-error.
    if not avail cyber_parcela_h
    then do.
        create cyber_parcela_h.
        ASSIGN cyber_parcela_h.empcod   = titulo.empcod
               cyber_parcela_h.titnat   = titulo.titnat
               cyber_parcela_h.modcod   = titulo.modcod 
               cyber_parcela_h.etbcod   = titulo.etbcod
               cyber_parcela_h.CliFor   = titulo.CliFor
               cyber_parcela_h.titnum   = titulo.titnum
               cyber_parcela_h.titpar   = titulo.titpar
               cyber_parcela_h.titdtemi = titulo.titdtemi
               cyber_parcela_h.HrEnvio  = ? 
               cyber_parcela_h.DtEnvio  = ?
               cyber_parcela_h.tipo     = "PARCE"
               cyber_parcela_h.contnum  = vcontnum 
               cyber_parcela_h.regra    = par-regra.
    end.      

    /***
        CONTRATO
    ***/
    find cyber_contrato where cyber_contrato.contnum = vcontnum no-error.
    if not avail cyber_contrato
    then do.
        create cyber_contrato.
        ASSIGN cyber_contrato.clicod  = titulo.clifor
               cyber_contrato.contnum = vcontnum
               cyber_contrato.banco   = ""
               cyber_contrato.etbcod  = titulo.etbcod.

        if avail contrato
        then assign
                cyber_contrato.vlentra   = contrato.vlentra
                cyber_contrato.dtinicial = contrato.dtinicial.

        /***
            na carga enviar os produtos do contrato
        ***/
        if vtipo = "CONTR" and avail contrato
        then do.
            find contnf where contnf.etbcod  = contrato.etbcod and
                              contnf.contnum = contrato.contnum 
                        no-lock no-error.
            if avail contnf
            then do.
                find plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod no-lock no-error.
                if avail plani
                then
                    for each movim where movim.etbcod = plani.etbcod 
                                      and movim.placod = plani.placod
                                      and movim.movtdc = plani.movtdc
                                    no-lock.
                        find first cyber_movim where
                                         cyber_movim.contnum = contrato.contnum
                                     and cyber_movim.etbcod  = movim.etbcod
                                     and cyber_movim.PlaCod  = movim.PlaCod
                                     and cyber_movim.procod  = movim.procod
                                     and cyber_movim.movseq  = movim.movseq
                                     and (cyber_movim.DtEnvio = ? or
                                          cyber_movim.DtEnvio = today)
                                       no-error.
                        if not avail cyber_movim
                        then do.
                            create cyber_movim.
                            ASSIGN
                                cyber_movim.contnum = contrato.contnum
                                cyber_movim.etbcod  = movim.etbcod
                                cyber_movim.PlaCod  = movim.PlaCod
                                cyber_movim.procod  = movim.procod
                                cyber_movim.movseq  = movim.movseq.
                        end.
                        assign
                            cyber_movim.DtEnvio  = ?
                            cyber_movim.HrEnvio  = ?
                            cyber_movim.LtCreCod = ?.
                    end.
            end.    
        end.
    end.
    assign
        cyber_contrato.banco    = ""
        cyber_contrato.Situacao = yes.
    
    /***
        historico de envio do contrato
    ***/
    find first cyber_contrato_h where 
                        cyber_contrato_h.contnum  = vcontnum and
                        cyber_contrato_h.tipo     = vtipo and
                        cyber_contrato_h.DtEnvio  = ?
                        NO-LOCK no-error.
    if not avail cyber_contrato_h
    then do.
        create cyber_contrato_h.
        ASSIGN
            cyber_contrato_h.contnum  = vcontnum
            cyber_contrato_h.tipo     = vtipo
            cyber_contrato_h.clicod   = titulo.clifor
            cyber_contrato_h.DtEnvio  = ?
            cyber_contrato_h.HrEnvio  = ?.
    end.

    /***
        historico de envio de cliente
    ***/
    find first cyber_clien_h where cyber_clien_h.clicod   = clien.clicod
                               and cyber_clien_h.DtEnvio = ?
                             NO-LOCK no-error.
    if not avail cyber_clien_h
    then do.
        create cyber_clien_h.
        ASSIGN
            cyber_clien_h.clicod   = clien.clicod 
            cyber_clien_h.DtEnvio  = ?
            cyber_clien_h.tipo     = cyber_contrato_h.tipo
            cyber_clien_h.DtEnvio  = ?
            cyber_clien_h.HrEnvio  = ?.
    end.

    find cyber_clien of cyber_clien_h no-error.
    if not avail cyber_clien
    then do.
        create cyber_clien.
        ASSIGN
            cyber_clien.clicod   = cyber_clien_h.clicod
            cyber_clien.DtURen   = clien.datexp.
    end.
    assign
        cyber_clien.Situacao = yes. 

    /***
        quando tem pagamento enviar MANUTENCAO FINANCEIRA
    ***/
    if vtipo = "PAGTO"
    then do.
        find first cyber_contrato_h where       
                        cyber_contrato_h.contnum  = vcontnum and
                        cyber_contrato_h.tipo     = "FINAN" and
                        cyber_contrato_h.DtEnvio  = ?
                        NO-LOCK no-error.
        if not avail cyber_contrato_h
        then do.
            create cyber_contrato_h.
            ASSIGN
                cyber_contrato_h.contnum = vcontnum
                cyber_contrato_h.tipo    = "FINAN"
                cyber_contrato_h.DtEnvio = ?
                cyber_contrato_h.HrEnvio = ?
                cyber_contrato_h.clicod  = titulo.clifor.
        end.

        find cyber_contrato where cyber_contrato.contnum  = vcontnum.
        cyber_contrato.Situacao = yes.

        /* enviar parcelas novamente */
        find first cyber_parcela_h of titulo where cyber_parcela_h.DtEnvio  = ?
                            no-error.
        if not avail cyber_parcela_h
        then do.
            create cyber_parcela_h.
            ASSIGN
                cyber_parcela_h.empcod   = titulo.empcod
                cyber_parcela_h.modcod   = titulo.modcod
                cyber_parcela_h.CliFor   = titulo.CliFor
                cyber_parcela_h.titnum   = titulo.titnum
                cyber_parcela_h.titpar   = titulo.titpar
                cyber_parcela_h.titnat   = titulo.titnat
                cyber_parcela_h.etbcod   = titulo.etbcod
                cyber_parcela_h.titdtemi = titulo.titdtemi
                cyber_parcela_h.DtEnvio  = ?
                cyber_parcela_h.HrEnvio  = ?
                cyber_parcela_h.tipo     = "PARCE"
                cyber_parcela_h.contnum  = vcontnum.
        end.
        assign
            cyber_parcela_h.regra    = no.

        find cyber_parcela of cyber_parcela_h.
        assign
            cyber_parcela.regra    = no
            cyber_parcela.titdtpag = titulo.titdtpag.

        /* envia PAGTO */
        /* foi usado o shared-lock*/
        find first cyber_contrato_h where       
                            cyber_contrato_h.contnum  = vcontnum and
                            cyber_contrato_h.tipo     = "PAGTO" and
                            cyber_contrato_h.DtEnvio  = ?
                            no-error.
        if not avail cyber_contrato_h
        then do.
            create cyber_contrato_h.
            ASSIGN
                cyber_contrato_h.contnum  = vcontnum
                cyber_contrato_h.tipo     = "PAGTO"
                cyber_contrato_h.DtEnvio  = ?
                cyber_contrato_h.HrEnvio  = ?
                cyber_contrato_h.clicod   = titulo.clifor.
        end.        
        assign
            cyber_contrato_h.titdtpag = titulo.titdtpag
            cyber_contrato_h.titvlpag = titulo.titvlpag.

        find cyber_contrato where cyber_contrato.contnum  = vcontnum.
        cyber_contrato.Situacao = yes.
        
        vsaldo    = 0.
        for each btitulo where btitulo.empcod = titulo.empcod
                           and btitulo.titnat = titulo.titnat
                           and btitulo.modcod = titulo.modcod
                           and btitulo.etbcod = titulo.etbcod
                           and btitulo.clifor = titulo.clifor
                           and btitulo.titnum = titulo.titnum
                           and btitulo.titsit = "LIB"   /* 30/10/15 */
                           and btitulo.titdtven < today /* 30/10/15 */
                         no-lock.
            vsaldo = vsaldo + btitulo.titvlcob - btitulo.titvlpag.
        end.
        /* quando tem pagamento e saldo contrato ficar zerado enviar BAIXA */ 
        if vsaldo <= 0
        then do.
            find first cyber_contrato_h where       
                            cyber_contrato_h.contnum  = vcontnum and
                            cyber_contrato_h.tipo     = "BAIXA" and
                            cyber_contrato_h.DtEnvio  = ?
                            NO-LOCK no-error.
            if not avail cyber_contrato_h
            then do.
                create cyber_contrato_h.
                ASSIGN
                    cyber_contrato_h.clicod   = titulo.clifor 
                    cyber_contrato_h.contnum  = vcontnum
                    cyber_contrato_h.DtEnvio  = ? 
                    cyber_contrato_h.HrEnvio  = ? 
                    cyber_contrato_h.tipo     = "BAIXA"
                    cyber_contrato_h.titdtpag = titulo.titdtpag.

                find cyber_contrato where cyber_contrato.contnum  = vcontnum.
                cyber_contrato.Situacao = no.
            end.
        end.
        run cyber/sinc_cyber.p (input titulo.CliFor).
    end. /* Pagto */
end.

if par-acao = "CADAS"
then vtipo = par-acao.

find cyber_contrato where recid(cyber_contrato) = rec_cyber_contrato
                    no-lock no-error.
if avail cyber_contrato
then do on error undo.
    /* historico de envio do contrato                                       */
    find clien of cyber_contrato no-lock.
    find first cyber_contrato_h of cyber_contrato where       
                    cyber_contrato_h.tipo     = vtipo and
                    cyber_contrato_h.DtEnvio  = ?
                    NO-LOCK no-error.
    if not avail cyber_contrato_h
    then do.
        create cyber_contrato_h.
        ASSIGN
            cyber_contrato_h.clicod   = cyber_contrato.clicod 
            cyber_contrato_h.contnum  = cyber_contrato.contnum 
            cyber_contrato_h.DtEnvio  = ? 
            cyber_contrato_h.HrEnvio  = ? 
            cyber_contrato_h.tipo     = vtipo. 
        if vtipo = "PAGTO"
        then assign
                cyber_contrato_h.titdtpag = titulo.titdtpag 
                cyber_contrato_h.titvlpag = titulo.titvlpag.
    end.

/***
    find cyber_contrato of contrato no-error.
    if not avail cyber_contrato
    then do.
        create cyber_contrato.
        ASSIGN cyber_contrato.clicod   = cyber_contrato_h.clicod        
               cyber_contrato.contnum  = cyber_contrato_h.contnum .
        cyber_contrato.Situacao = yes.
    end.
***/
    /* historico de envio de cliente                                        */
    find first cyber_clien_h of clien where cyber_clien_h.DtEnvio  = ?
                        no-lock no-error.
    if not avail cyber_clien_h
    then do.
        create cyber_clien_h.
        ASSIGN
            cyber_clien_h.clicod   = clien.clicod 
            cyber_clien_h.DtEnvio  = ?
            cyber_clien_h.HrEnvio  = ?
            cyber_clien_h.tipo     = cyber_contrato_h.tipo.
    end.

    find cyber_clien of cyber_clien_h no-error.
    if not avail cyber_clien
    then create cyber_clien.
    ASSIGN cyber_clien.clicod   = cyber_clien_h.clicod 
           cyber_clien.DtURen   = clien.datexp
           cyber_clien.Situacao = yes.
    run cyber/sinc_cyber.p (input cyber_clien.clicod).
end.

