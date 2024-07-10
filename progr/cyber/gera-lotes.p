{admcab.i}

def shared temp-table ttlote
    field rec as recid.

def var par-lotcre as recid.

def temp-table c_contrato
    field rec   as recid
    field tipo  as char.

def temp-table c_parcela
    field rec   as recid
    field tipo  as char.

def temp-table c_movim
    field rec   as recid
    field tipo  as char.

def temp-table tt-interface
    field tipo as char

    index tipo is primary unique tipo.
        
/*  gera lotes referente a tabela de contratos */ 
for each c_contrato.
    delete c_contrato.
end.
for each tt-interface.
    delete tt-interface.
end. 

/* contratos nao enviados */
hide message no-pause.
message string(time,"hh:mm:ss") "contratos nao enviados".
for each cyber_contrato_h where cyber_contrato_h.dtenvio = ? 
                        use-index cyber_contrato_h1 no-lock.
    create c_contrato.
    assign c_contrato.rec   = recid(cyber_contrato_h)
           c_contrato.tipo  = cyber_contrato_h.tipo.

    find tt-interface where tt-interface.tipo = c_contrato.tipo no-error.
    if not avail tt-interface
    then do.
        create tt-interface.
        assign tt-interface.tipo = c_contrato.tipo.
    end.
end.
hide message no-pause.

message string(time,"hh:mm:ss") "Gerando lote contratos".
for each tt-interface.
    message string(time,"hh:mm:ss") tt-interface.tipo.
    par-lotcre = ?.
    find lotcretp where lotcretp.LtCreTCod = "CYBER_" + tt-interface.tipo
                  no-lock.
    /* verifica se existe lote sem envio (sem geracao de arquivo)         */
    /* falta indice */
    find first lotcre of lotcretp where lotcre.ltdtenvio = ? no-lock no-error.
    if avail lotcre
    then par-lotcre = recid(lotcre).

    if par-lotcre = ?  
    then do.  
        do on error undo.  
            find cyber_sequencias where cyber_sequencias.cyber_sigla = 
                                        tt-interface.tipo no-error.
            cyber_sequencias.Cyber_sequencia = 
                                        cyber_sequencias.Cyber_sequencia + 1.
            cyber_sequencias.Cyber_DtProces = today.
        end.  
        run lotcria (cyber_sequencias.Cyber_sequencia,
                     output par-lotcre).
        find current cyber_sequencias no-lock.
    end.  

    find lotcre where recid(lotcre) = par-lotcre no-lock.

    for each c_contrato of tt-interface.
        find cyber_contrato_h where recid(cyber_contrato_h) = c_contrato.rec.
        find cyber_contrato of cyber_contrato_h no-lock.

        run lotcontrato_cria.
        run lotcliente_cria (input cyber_contrato.clicod). 
        assign
            cyber_contrato_h.DtEnvio  = today
            cyber_contrato_h.HrEnvio  = time
            cyber_contrato_h.LtCreCod = lotcre.LtCreCod.
    end.    
end.

/*
    gera lotes referente a tabela de parcelas
*/ 
hide message no-pause.
message string(time,"hh:mm:ss") "gera lotes referente a tabela de parcelas".
for each c_parcela.
    delete c_parcela.
end.
for each tt-interface.
    delete tt-interface.
end. 

/* parcelas nao enviadas */
for each cyber_parcela_h where cyber_parcela_h.dtenv = ? 
                    use-index cyber_parcela_h1 no-lock.
    create c_parcela.
    assign c_parcela.rec  = recid(cyber_parcela_h)
           c_parcela.tipo = cyber_parcela_h.tipo.

    find tt-interface where tt-interface.tipo = c_parcela.tipo no-error.
    if not avail tt-interface
    then do.
        create tt-interface.
        assign tt-interface.tipo = c_parcela.tipo.
    end.
end.

hide message no-pause.
message string(time,"hh:mm:ss") "Gerando lote Parcelas".
for each tt-interface.
    par-lotcre = ?.
    find lotcretp where lotcretp.LtCreTCod = "CYBER_" + tt-interface.tipo
                  no-lock.
    /* verifica se existe lote sem envio (sem geracao de arquivo)         */
    find first lotcre of lotcretp where lotcre.ltdtenvio = ? no-lock no-error.
    if avail lotcre
    then par-lotcre = recid(lotcre).

    if par-lotcre = ?  
    then do.  
        do on error undo.  
            find cyber_sequencias where cyber_sequencias.cyber_sigla = 
                                        tt-interface.tipo no-error.
            cyber_sequencias.Cyber_sequencia = 
                                cyber_sequencias.Cyber_sequencia + 1.
            
            cyber_sequencias.Cyber_DtProces = today.
        end.  
        run lotcria (cyber_sequencias.Cyber_sequencia,
                     output par-lotcre). 
        find current cyber_sequencias no-lock.
    end.  

    find lotcre where recid(lotcre) = par-lotcre no-lock.
    
    for each c_parcela of tt-interface.
        find cyber_parcela_h where recid(cyber_parcela_h) = c_parcela.rec.
        find cyber_parcela of cyber_parcela_h no-lock.

        run lotcliente_cria (input cyber_parcela.clifor).

        find lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod
                         and lotcretit.clfcod   = cyber_parcela.clifor
                         and lotcretit.modcod   = cyber_parcela.modcod
                         and lotcretit.etbcod   = cyber_parcela.etbcod
                         and lotcretit.titnum   = cyber_parcela.titnum
                         and lotcretit.titpar   = cyber_parcela.titpar
                       no-lock no-error.
        if not avail lotcretit
        then do on error undo:
            create lotcretit.
            assign
                lotcretit.ltcrecod  = lotcre.ltcrecod
                lotcretit.clfcod    = cyber_parcela.clifor
                lotcretit.modcod    = cyber_parcela.modcod
                lotcretit.etbcod    = cyber_parcela.etbcod
                lotcretit.titnum    = cyber_parcela.titnum
                lotcretit.titpar    = cyber_parcela.titpar.
        end.
        /* */
        assign
            cyber_parcela_h.DtEnvio  = today
            cyber_parcela_h.HrEnvio  = time
            cyber_parcela_h.LtCreCod = lotcre.LtCreCod.
    end.    
end.

hide message no-pause.
message string(time,"hh:mm:ss") "gera lotes referente a tabela de movim".
for each c_movim.
    delete c_movim.
end.
for each tt-interface.
    delete tt-interface.
end. 

/* movim nao enviados */
for each cyber_movim where cyber_movim.dtenv = ? 
                    use-index cyber_movim1 no-lock.
    create c_movim.
    assign c_movim.rec  = recid(cyber_movim)
           c_movim.tipo = "MERCA".

    find tt-interface where tt-interface.tipo = c_movim.tipo no-error.
    if not avail tt-interface
    then do.
        create tt-interface.
        assign tt-interface.tipo = c_movim.tipo.
    end.
end.

hide message no-pause.
message string(time,"hh:mm:ss") "Gerando lote movim".
for each tt-interface.
    par-lotcre = ?.
    find lotcretp where lotcretp.LtCreTCod = "CYBER_" + tt-interface.tipo
                  no-lock.
    /* verifica se existe lote sem envio (sem geracao de arquivo)         */
    find first lotcre of lotcretp where lotcre.ltdtenvio = ? no-lock no-error.
    if avail lotcre
    then par-lotcre = recid(lotcre).

    if par-lotcre = ?  
    then do.  
        do on error undo.  
            find cyber_sequencias where cyber_sequencias.cyber_sigla = 
                                        tt-interface.tipo no-error.
            cyber_sequencias.Cyber_sequencia = 
                                cyber_sequencias.Cyber_sequencia + 1.
            
            cyber_sequencias.Cyber_DtProces = today.
        end.  
        run lotcria (cyber_sequencias.Cyber_sequencia,
                     output par-lotcre). 
        find current cyber_sequencias no-lock.
    end.  

    find lotcre where recid(lotcre) = par-lotcre no-lock.

    for each c_movim of tt-interface.
        find cyber_movim where recid(cyber_movim) = c_movim.rec.
        find cyber_contrato of cyber_movim no-lock.
        run lotcontrato_cria.
        run lotcliente_cria (input cyber_contrato.clicod).
        assign
            cyber_movim.DtEnvio  = today
            cyber_movim.HrEnvio  = time
            cyber_movim.LtCreCod = lotcre.LtCreCod.
    end.    
end.
hide message no-pause.

message string(time,"hh:mm:ss") "Exportando lotes".
for each lotcretp where lotcretp.LtCreTCod begins "CYBER_" no-lock.
    for each lotcre of lotcretp where lotcre.ltdtenvio = ?.
        disp search(lotcretp.remessa) format "x(50)".  pause 0.
        if search(lotcretp.remessa) <> ?
        then do.
            message string(time,"hh:mm:ss") lotcretp.remessa.
            run value(lotcretp.remessa) (input recid(lotcre)).
            create ttlote.
            assign ttlote.rec = recid(lotcre).
        end.
    end.    
end.    


procedure lotcria.

def input  parameter par-sequencia like cyber_sequencias.Cyber_sequencia.
def output parameter par-lotcre    as recid.

def buffer blotcre for lotcre.
find last blotcre  where blotcre.ltcrecod > (setbcod * 1000000)
                     and blotcre.ltcrecod < (setbcod + 1) * 1000000
                  no-error.
create lotcre.
ASSIGN lotcre.ltcrecod  = if avail blotcre
                          then blotcre.ltcrecod + 1
                          else (setbcod * 1000000) + 1
       lotcre.ltcredt   = today
       lotcre.ltcrehr   = time
       lotcre.funcod    = sfuncod
       lotcre.ltcretcod = lotcretp.ltcretcod
       lotcre.etbcod    = setbcod
       lotcre.ltselecao = ""
       lotcre.LtSeqCyber = par-sequencia.

assign par-lotcre = recid(lotcre).

end procedure.


procedure lotcliente_cria.

/* cyber/lotcliente_cria.p                                          */
def input parameter  par-clicod  like clien.clicod.

do on error undo.
    find lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod
                    and lotcreag.clfcod   = par-clicod
                  NO-LOCK no-error.
    if not avail lotcreag
    then do:
        create lotcreag.
        assign
            lotcreag.ltcrecod = lotcre.ltcrecod
            lotcreag.clfcod   = par-clicod.
    end.
end.

end procedure.


procedure lotcontrato_cria.

    find LotCreContrato where LotCreContrato.ltcrecod = lotcre.ltcrecod
                          and LotCreContrato.contnum  = cyber_contrato.contnum
                        no-lock no-error.
    if not avail LotCreContrato
    then do on error undo:
        create LotCreContrato.
        assign
            LotCreContrato.ltcrecod   = lotcre.ltcrecod
            LotCreContrato.contnum    = cyber_contrato.contnum.
    end.

end procedure.
