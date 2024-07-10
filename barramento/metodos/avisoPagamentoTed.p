DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/avisoPagamentoTed.i}

/* LE ENTRADA */
lokJSON = havisopagamentotedEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

def var vdtvencimento as date.
def var vidted as char.
def var vvlr_total_pago as dec.
def var par-recid-aviso as recid.
def var vvlr_pago as dec.
def var vcontnum as int.
 def var vtitpar as int.
def var auxsituacao as char.
def var auxmensagem as char.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


create ttstatus.
ttstatus.situacao = "".


find first ttavisopagamentotedEntrada no-error.
if not avail ttavisopagamentotedEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttavisopagamentotedEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttavisopagamentotedEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttavisopagamentotedEntrada.codigo_cpfcnpj.

        find clien where clien.clicod = int(ttavisopagamentotedEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttavisopagamentotedEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
        else do.
            vidted = ttAvisoPagamentoTedentrada.idted no-error.    
            if vidted = ? or vidted = ""
            then do: 
                ttstatus.situacao = "Id Ted invalido " + ttAvisoPagamentoTedentrada.idted.
            end.

            vvlr_total_pago = 0.
        
            if ttstatus.situacao = ""
            then 
                for each ttParcelasEntrada.    
                    vcontnum =   int(ttparcelasEntrada.numero_contrato) no-error.
                    vtitpar  =   int(ttparcelasEntrada.seq_parcela) no-error.
            
                    if vcontnum <> 0 and vcontnum <> ?
                    then do:
                        find contrato where contrato.contnum = vcontnum no-lock no-error.
                    end.
                    if not avail contrato
                    then do:
                        assign
                            ttstatus.situacao = "Contrato " + 
                                    ttparcelasEntrada.numero_contrato + 
                                    " nao encontrado.".
                    end.    
                    else do:
                        find first  titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.modcod = contrato.modcod and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titpar = vtitpar
                            no-lock no-error.
                        if not avail titulo
                        then do:
                            assign
                                ttstatus.situacao = "Contrato " + 
                                        ttparcelasEntrada.numero_contrato + 
                                        " Parcela " +
                                        ttparcelasEntrada.seq_parcela + 
                                        " nao encontrada.".
                        end.        
                        else do:
                            if titulo.titdtpag <> ? or
                               titulo.titsit   <> "LIB"
                            then do:
                                ttstatus.situacao = "Contrato " + 
                                        ttParcelasEntrada.numero_contrato + 
                                        " Parcela " +
                                        ttParcelasEntrada.seq_parcela + 
                                        " ja liquidada.".
                            end.   
                            else do:
                                vvlr_total_pago = vvlr_total_pago +
                                    titulo.titvlcob.
                            end.
                        
                        end.
                    end.
                end. /* each ttparcelasEntrada */
                if ttstatus.situacao = ""
                then 
                    for each ttparcelasentrada.
                        vcontnum =  int(ttParcelasentrada.numero_contrato) no-error.
                        vtitpar  =  int(ttparcelasentrada.seq_parcela) no-error.

                            par-tabelaorigem = "titulo". 
                            par-chaveOrigem  = "contnum,titpar". 
                            par-dadosOrigem  = string(int(ttparcelasEntrada.numero_contrato)) + "," + 
                                                string(int(ttparcelasEntrada.seq_parcela)).
                            find first banaviorigem where
                                banaviorigem.tabela = par-tabelaorigem and
                                banaviorigem.chaveorigem = par-chaveOrigem and
                                banaviorigem.dadosOrigem = par-dadosOrigem
                                exclusive no-error.
                            find banavisopag of banaviorigem no-lock no-error.
                            if avail banavisopag
                            then do:
                                if banavisopag.situacao = "E"
                                then delete banaviorigem.
                            end.
                    end.
             
        end.
    end.
end.    
if ttstatus.situacao = "" and avail ttavisopagamentotedEntrada
then do:
    
    vdtvencimento = today.
 
    find first banco where banco.numban = int(ttAvisoPagamentoTedEntrada.banco) no-lock no-error.
             
    run bol/geradadosaviso_v1701.p (
                    input if avail banco then banco.numban else ?, /* Banco do Boleto */
                    input ?,      /* Bancarteira especifico */
                    input "WSTED",
                    input clien.clicod,
                    input "",
                    input vdtvencimento,
                    input  vvlr_total_pago,
                    input vidted,
                    output par-recid-aviso,
                    output auxsituacao,
                    output auxmensagem).

    find banavisopag where recid(banavisopag) = par-recid-aviso no-lock no-error.     
    if not avail banavisopag
    then do:
        ttstatus.situacao = if auxmensagem = ""
                        then "Erro ao Criar Aviso na Base de Dados."
                        else auxmensagem.
    end.

    if ttstatus.situacao = "" and avail banavisopag
    then for each ttparcelasEntrada.
 
        vcontnum =  int(ttparcelasEntrada.numero_contrato) no-error.
        vtitpar  =  int(ttparcelasEntrada.seq_parcela) no-error.
        vvlr_pago =  dec(ttparcelasEntrada.vlr_parcela_pago) no-error.
        find contrato where contrato.contnum = vcontnum no-lock no-error.
        find first  titulo where
                titulo.empcod = 19 and
                titulo.titnat = no and
                titulo.modcod = contrato.modcod and
                titulo.etbcod = contrato.etbcod and
                titulo.clifor = contrato.clicod and
                titulo.titnum = string(contrato.contnum) and
                titulo.titpar = vtitpar
                exclusive no-error.
        if avail titulo
        then do:  
            par-tabelaorigem = "titulo". 
            par-chaveOrigem  = "contnum,titpar". 
            par-dadosOrigem  = string(contrato.contnum) + "," + 
                                string(titulo.titpar).

            run bol/vinculaaviso_v1701.p (
                        input recid(banavisopag),
                        input par-tabelaorigem,
                        input par-chaveorigem,
                        input par-dadosorigem,
                        input vvlr_pago,
                        output auxsituacao,
                        output auxmensagem).
            
            if auxmensagem = ""
            then ttstatus.situacao = "Sucesso".
                                                                
                        
        end.
    end.

 
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = havisopagamentotedSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).

havisopagamentotedSaida:WRITE-JSON("FILE","helio_ted.json", true).

