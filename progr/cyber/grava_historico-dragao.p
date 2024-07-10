/* cyber/grava_historico.p              */

def input parameter rec_titulo as recid.
def input parameter rec_cyber_contrato as recid.
def input parameter par-acao   as char.
def input parameter tit-regra  as log.

def var vsaldo      like d.contrato.vltotal.
def var vtipo       as char.
def var vtitvlcob   like d.titulo.titvlcob.
def var vtitvlpag   like d.titulo.titvlpag.
def buffer btitulo for d.titulo.

if par-acao = "INCLUI"
then vtipo = "CONTR".
if par-acao = "PAGA"
then vtipo = "PAGTO".

find d.titulo where recid(d.titulo) = rec_titulo no-lock no-error.
if avail d.titulo
then do on error undo:
    find clien where clien.clicod = d.titulo.clifor no-lock.

    find d.contrato where d.contrato.contnum = int(d.titulo.titnum)
                    no-lock no-error.
    if not avail d.contrato
    then message "NAO ACHEI CONTRATO => "
                " recid(d.titulo) = " recid(d.titulo)
                " " d.titulo.titnum "/" d.titulo.titpar.

    /* historico de envio da parcela (d.titulo)                               */
/*    find cyber_parcela of d.titulo no-lock no-error. */
    find cyber_parcela where cyber_parcela.empcod = d.titulo.empcod
                         and cyber_parcela.titnat = d.titulo.titnat
                         and cyber_parcela.modcod = d.titulo.modcod
                         and cyber_parcela.etbcod = d.titulo.etbcod
                         and cyber_parcela.clifor = d.titulo.clifor
                         and cyber_parcela.titnum = d.titulo.titnum
                         and cyber_parcela.titpar = d.titulo.titpar
                         and cyber_parcela.titdtemi = d.titulo.titdtemi
                       no-lock no-error.
    if not avail cyber_parcela
    then do.
        find first cyber_parcela_h of d.titulo where
                            cyber_parcela_h.DtEnvio  = ?
                            NO-LOCK no-error.
        if not avail cyber_parcela_h
        then do.
            create cyber_parcela_h.
            ASSIGN
                cyber_parcela_h.empcod   = d.titulo.empcod 
                cyber_parcela_h.modcod   = d.titulo.modcod 
                cyber_parcela_h.HrEnvio  = ? 
                cyber_parcela_h.CliFor   = d.titulo.CliFor 
                cyber_parcela_h.titnum   = d.titulo.titnum 
                cyber_parcela_h.titpar   = d.titulo.titpar 
                cyber_parcela_h.titnat   = d.titulo.titnat 
                cyber_parcela_h.etbcod   = d.titulo.etbcod 
                cyber_parcela_h.titdtemi = d.titulo.titdtemi 
                cyber_parcela_h.DtEnvio  = ?
                cyber_parcela_h.tipo     = "PARCE"
                cyber_parcela_h.contnum  = int(d.titulo.titnum) 
                cyber_parcela_h.regra    = tit-regra.
        end.

        create cyber_parcela.
        ASSIGN cyber_parcela.empcod   = cyber_parcela_h.empcod 
               cyber_parcela.modcod   = cyber_parcela_h.modcod 
               cyber_parcela.CliFor   = cyber_parcela_h.CliFor 
               cyber_parcela.titnum   = cyber_parcela_h.titnum 
               cyber_parcela.titpar   = cyber_parcela_h.titpar 
               cyber_parcela.titnat   = cyber_parcela_h.titnat 
               cyber_parcela.etbcod   = cyber_parcela_h.etbcod 
               cyber_parcela.titdtemi = cyber_parcela_h.titdtemi
               cyber_parcela.contnum  = int(d.titulo.titnum) 
               cyber_parcela.tipo     = "PARCE"
               cyber_parcela.regra    = tit-regra
               cyber_parcela.banco    = "Dragao"
               cyber_parcela.titvlcob = d.titulo.titvlcob
               cyber_parcela.titdtven = d.titulo.titdtven.
    end.      

    /* na carga enviar os produtos do contrato */
    if vtipo = "CONTR" and avail d.contrato
    then do.
        find d.contnf where d.contnf.etbcod  = d.contrato.etbcod and
                            d.contnf.contnum = d.contrato.contnum
                      no-lock no-error.
        if avail d.contnf
        then do.
            find plani where plani.etbcod = d.contnf.etbcod and
                             plani.placod = d.contnf.placod no-lock no-error.
            if avail plani
            then for each movim where movim.etbcod = plani.etbcod 
                                  and movim.placod = plani.placod no-lock.
                find first cyber_movim where cyber_movim.PlaCod  = movim.PlaCod
                                   and cyber_movim.contnum = d.contrato.contnum
                                   and cyber_movim.etbcod  = movim.etbcod
                                   and cyber_movim.movseq  = movim.movseq
                                   and cyber_movim.procod  = movim.procod
                                   and cyber_movim.DtEnvio = ?
                                        NO-LOCK no-error.
                if not avail cyber_movim
                then do.
                    create cyber_movim.
                    ASSIGN cyber_movim.PlaCod   = movim.PlaCod 
                           cyber_movim.contnum  = d.contrato.contnum 
                           cyber_movim.DtEnvio  = ?
                           cyber_movim.HrEnvio  = ?
                           cyber_movim.etbcod   = movim.etbcod 
                           cyber_movim.LtCreCod = ?
                           cyber_movim.movseq   = movim.movseq 
                           cyber_movim.procod   = movim.procod. 
                end.
            end.
        end.    
    end.
    
    /* historico de envio do contrato                                       */
    if avail d.contrato 
    then find first cyber_contrato_h of d.contrato where       
                        cyber_contrato_h.tipo     = vtipo and
                        cyber_contrato_h.DtEnvio  = ?
                        NO-LOCK no-error.
    else find first cyber_contrato_h where 
                        cyber_contrato_h.contnum  = int(d.titulo.titnum) and
                        cyber_contrato_h.tipo     = vtipo and
                        cyber_contrato_h.DtEnvio  = ?
                        NO-LOCK no-error.
    
    if not avail cyber_contrato_h
    then do.
        create cyber_contrato_h.
        ASSIGN
            cyber_contrato_h.clicod   = d.titulo.clifor
            cyber_contrato_h.contnum  = int(d.titulo.titnum)
            cyber_contrato_h.DtEnvio  = ? 
            cyber_contrato_h.HrEnvio  = ? 
            cyber_contrato_h.tipo     = vtipo.
    end.

    find cyber_contrato where cyber_contrato.contnum = cyber_contrato_h.contnum
                        no-error.
    if not avail cyber_contrato
    then do.
        create cyber_contrato.
        ASSIGN cyber_contrato.clicod  = cyber_contrato_h.clicod        
               cyber_contrato.contnum = cyber_contrato_h.contnum
               cyber_contrato.banco   = "Dragao"
               cyber_contrato.etbcod  = d.titulo.etbcod.

        if avail contrato
        then
            assign
                cyber_contrato.vlentra   = d.contrato.vlentra
                cyber_contrato.dtinicial = d.contrato.dtinicial.
    end.
    cyber_contrato.Situacao = yes.

    /* historico de envio de cliente                                        */

    find first cyber_clien_h of clien where       
                        cyber_clien_h.DtEnvio  = ?
                        NO-LOCK no-error.
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

    /* quando tem pagamento enviar MANUTENCAO FINANCEIRA  */     
    if vtipo = "PAGTO"
    then do.
        find first cyber_contrato_h where       
                        cyber_contrato_h.contnum  = int(d.titulo.titnum) and
                        cyber_contrato_h.tipo     = "FINAN" and
                        cyber_contrato_h.DtEnvio  = ?
                        NO-LOCK no-error.
        if not avail cyber_contrato_h
        then do.
            create cyber_contrato_h.
            ASSIGN
                cyber_contrato_h.clicod   = d.titulo.clifor 
                cyber_contrato_h.contnum  = int(d.titulo.titnum)
                cyber_contrato_h.DtEnvio  = ? 
                cyber_contrato_h.HrEnvio  = ? 
                cyber_contrato_h.tipo     = "FINAN".
        end.

        find cyber_contrato where cyber_contrato.contnum  = int(d.titulo.titnum)
                                                    no-error.
        cyber_contrato.Situacao = yes.

        /* enviar parcelas novamente */
        find first cyber_parcela_h of d.titulo where
                            cyber_parcela_h.DtEnvio  = ?
                            NO-LOCK no-error.
        if not avail cyber_parcela_h
        then do.
            create cyber_parcela_h.
            ASSIGN
                cyber_parcela_h.empcod   = d.titulo.empcod 
                cyber_parcela_h.modcod   = d.titulo.modcod 
                cyber_parcela_h.HrEnvio  = ? 
                cyber_parcela_h.CliFor   = d.titulo.CliFor 
                cyber_parcela_h.titnum   = d.titulo.titnum 
                cyber_parcela_h.titpar   = d.titulo.titpar 
                cyber_parcela_h.titnat   = d.titulo.titnat 
                cyber_parcela_h.etbcod   = d.titulo.etbcod 
                cyber_parcela_h.titdtemi = d.titulo.titdtemi 
                cyber_parcela_h.DtEnvio  = ?
                cyber_parcela_h.tipo     = "PARCE"
                cyber_parcela_h.contnum  = int(d.titulo.titnum) 
                cyber_parcela_h.regra    = no.
        end.

        find cyber_parcela of cyber_parcela_h.
        cyber_parcela.regra = no.
        cyber_parcela.titdtpag = d.titulo.titdtpag.
        /* envia PAGTO */
        do.
            find first cyber_contrato_h where       
                            cyber_contrato_h.contnum  = int(d.titulo.titnum) and
                            cyber_contrato_h.tipo     = "PAGTO" and
                            cyber_contrato_h.DtEnvio  = ?
                            no-error.
            if not avail cyber_contrato_h
            then do.
                create cyber_contrato_h.
                ASSIGN
                    cyber_contrato_h.clicod   = d.titulo.clifor
                    cyber_contrato_h.contnum  = int(d.titulo.titnum)
                    cyber_contrato_h.DtEnvio  = ? 
                    cyber_contrato_h.HrEnvio  = ? 
                    cyber_contrato_h.tipo     = "PAGTO"
                    .
            end.
            assign        
                    cyber_contrato_h.titdtpag = d.titulo.titdtpag
                    cyber_contrato_h.titvlpag = d.titulo.titvlpag.

            find cyber_contrato where 
                        cyber_contrato.contnum  = int(d.titulo.titnum) no-error.
            cyber_contrato.Situacao = yes.
        end.
        
        vsaldo = 0. vtitvlcob = 0. vtitvlpag = 0.
        for each btitulo where btitulo.empcod = d.titulo.empcod           and 
                               btitulo.titnum = d.titulo.titnum           and 
                               btitulo.titnat = d.titulo.titnat           and 
                               btitulo.clifor = d.titulo.clifor           and 
                               btitulo.modcod = d.titulo.modcod           and 
                               btitulo.etbcod = d.titulo.etbcod           
                               no-lock.
            vtitvlcob = vtitvlcob + btitulo.titvlcob.
            vtitvlpag = vtitvlpag + btitulo.titvlpag.
        end.
        vsaldo = vtitvlcob - vtitvlpag.
        /* quando tem pagamento e saldo contrato ficar zerado enviar BAIXA */ 
        if vsaldo <= 0
        then do.
            find first cyber_contrato_h where       
                            cyber_contrato_h.contnum  = int(d.titulo.titnum) and
                            cyber_contrato_h.tipo     = "BAIXA" and
                            cyber_contrato_h.DtEnvio  = ?
                            NO-LOCK no-error.
            if not avail cyber_contrato_h
            then do.
                create cyber_contrato_h.
                ASSIGN
                    cyber_contrato_h.clicod   = d.titulo.clifor 
                    cyber_contrato_h.contnum  = int(d.titulo.titnum)
                    cyber_contrato_h.DtEnvio  = ? 
                    cyber_contrato_h.HrEnvio  = ? 
                    cyber_contrato_h.tipo     = "BAIXA"
                    cyber_contrato_h.titdtpag = d.titulo.titdtpag.
            end.

            do on error undo.
                find cyber_contrato where 
                     cyber_contrato.contnum  = int(d.titulo.titnum) no-error.
                cyber_contrato.Situacao = no.
            end.
        end.
    end.
    run cyber/sinc_cyber.p (input d.titulo.CliFor).
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
                cyber_contrato_h.titdtpag = d.titulo.titdtpag 
                cyber_contrato_h.titvlpag = d.titulo.titvlpag
                .

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
    find first cyber_clien_h of clien where
                        cyber_clien_h.DtEnvio  = ?
                        NO-LOCK no-error.
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
