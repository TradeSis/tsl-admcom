/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
    
def var vdec as dec.    
{/admcom/barramento/metodos/efetivaPagamentoTed.i}

/* LE ENTRADA */
lokJSON = hefetivapagamentotedEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

def var vdtvencimento as date.
def var vidted as char.
def var vvlr_total_pago as dec.
def var par-recid-efetiva as recid.
def var vvlr_pago as dec.
def var vcontnum as int.
 def var vtitpar as int.
def var auxsituacao as char.
def var auxmensagem as char.
def var recatu1 as recid.

def var par-tabelaorigem as char.
def var par-chaveorigem as char.
def var par-dadosorigem as char.
def var par-valorOrigem  as dec.


create ttstatus.
ttstatus.situacao = "".


find first ttefetivapagamentotedEntrada no-error.
if not avail ttefetivapagamentotedEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttefetivapagamentotedEntrada.codigo_cpfcnpj) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttefetivapagamentotedEntrada.codigo_cpfcnpj.
    end.
    else do:
        ttstatus.chave  = ttefetivapagamentotedEntrada.codigo_cpfcnpj.

        find clien where clien.clicod = int(ttefetivapagamentotedEntrada.codigo_cpfcnpj) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttefetivapagamentotedEntrada.codigo_cpfcnpj) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
        else do.
            vidted = ttefetivaPagamentoTedentrada.idted no-error.    
            if vidted = ? or vidted = ""
            then do: 
                ttstatus.situacao = "Id Ted invalido " + ttefetivaPagamentoTedentrada.idted.
            end.

        end.
    end.
end.    
if ttstatus.situacao = "" and avail ttefetivapagamentotedEntrada
then do:
    
    vdtvencimento = today.
    find first banco where
        banco.numban = int(ttEfetivaPagamentoTedEntrada.banco)
        no-lock no-error.

    recatu1 = ?.                              
    if not avail banco
    then find first bancarteira where
            bancarteira.principal = "PGERAL" no-lock no-error.
    else do:
        for each banco where 
            banco.numban = int(ttEfetivaPagamentoTedEntrada.banco)
            no-lock.
            find first bancart where bancart.bancod = banco.bancod and
                        bancart.bancart = "TED"
                no-lock no-error.
            if avail bancarteira
            then recatu1 = recid(bancarteira).
        end.      
        if recatu1 = ?
        then find first bancarteira where
                bancarteira.principal = "PGERAL" no-lock no-error.

        else find first bancarteira where 
                    recid(bancarteira) = recatu1 no-lock no-error.
                
    end.            
      
    find first banavisopag where
        banAvisoPag.bancod         = bancarteira.bancod and
        banAvisoPag.Agencia         = bancarteira.Agencia  and
        banAvisoPag.ContaCor        = bancarteira.ContaCor and
        banAvisoPag.BanCart        = bancarteira.BanCart and
        banAvisoPag.cdoperacao     = ttEfetivaPagamentoTedEntrada.idTed
    exclusive no-wait no-error.
    if avail banavisopag
    then do:
        if ttefetivapagamentotedEntrada.statusted = "E"
        then do:
            banavisopag.situacao = "E". 
            ttstatus.situacao = "FICOU E". 
        end.    
        else do:
            ttstatus.situacao = "FICOU L".
            banavisopag.situacao = "L". 
            banavisopag.dtbaixa = today. 
            banavisopag.hrbaixa = time. 
            banavisopag.dtPagamento = today. /*vdtvencimento.*/
            /*banavisopag.vlPagamento = vvlr_total_pago.*/
            for each banaviorigem of banavisopag.
                find contrato where contrato.contnum = int(entry(1,banaviorigem.dadosorigem))
                    no-lock.
                find first  titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum) and
                    titulo.titpar =  int(entry(2,banaviorigem.dadosorigem))
                    exclusive-lock  no-wait no-error.
                if avail titulo
                then do:
                    titulo.titdtpag = today.
                    titulo.titvlpag = banaviorigem.valororigem.
                    titulo.titjuro  = if titulo.titvlpag > titulo.titvlcob
                                      then titulo.titvlpag - titulo.titvlcob
                                      else 0.
                    titulo.titsit   = "PAG".
                    titulo.etbcobra = 999.
                    titulo.moecod = "BCO".
                    ttstatus.situacao = "Sucesso".
                end.
                else do:
                    ttstatus.situacao = "ITULO NAO ENCONTRATDO".
                end.
                
            end.
        end.            
    end.                    
    else do:
        ttstatus.situacao = "ID Ted Invalido".
    end.

 
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hefetivapagamentotedSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
/* 10
hefetivapagamentotedSaida:WRITE-JSON("FILE","helio_ted.json", true).
*/
