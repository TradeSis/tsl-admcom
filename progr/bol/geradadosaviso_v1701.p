def input parameter par-banco as int.
def input parameter par-recid-bancarteira as recid.
def input parameter par-tipoIntegracao as char.
def input parameter par-clicod as int.
def input parameter par-numerodocumento as char.
def input parameter par-dtvencimento    as date.
def input parameter par-vlcobrado     as dec.

def input parameter par-cdoperacao   as char.
def output parameter par-recid-aviso as rec.
def output parameter vstatus  as char.
def output parameter vmensagem_erro as char.

def var recatu1 as recid.

vstatus = "S".
vmensagem_erro = "".

if par-recid-bancarteira = ?
then do:
    find first banco where banco.numban = par-banco no-lock no-error.
    if not avail banco
    then do:
        find first bancarteira where
            bancarteira.principal = "PGERAL" no-lock no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_erro  = "Sem parametrizacao da carteira".
        end.
    end.
    else do:
        recatu1 = ?.
        for each banco where 
            banco.numban = par-banco
            no-lock.
            find first bancart where bancart.bancod = banco.bancod and
                       bancart.bancart = "TED"
                no-lock no-error.
            if avail bancarteira
            then recatu1 = recid(bancarteira).
        end.      
                 
        find first bancarteira where recid(bancarteira) = recatu1
                no-lock no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_erro  = 
                    (if avail banco
                    then  ("Banco " + string(par-banco,"999") + " ")
                    else "")
                     + "Sem parametrizacao "
                            + "da carteira".
        end.                  
        else do:
            vmensagem_erro = string(bancarteira.bancod).
        end.
    end.
end.
else do:
    find bancarteira where recid(bancarteira) = par-recid-bancarteira
        no-lock.
end.

if avail bancarteira and vstatus = "S"
then do.
    par-recid-bancarteira = recid(bancarteira).
    if par-cdoperacao = ?
    then do on error undo:
        find bancarteira where recid(bancarteira) = par-recid-bancarteira
            exclusive no-error.
        if not avail bancarteira
        then do:
            vstatus = "N".
            vmensagem_ERRO = "Nao conseguiu obter PROXIMO CODIGO OPERACAO".
        end.    
        else do:
                par-cdoperacao = string(bancarteira.cdoperacaoatual + 1). 
                bancarteira.cdoperacaoatual = int64(par-cdoperacao).        
        end.
    end.        
    find bancarteira where recid(bancarteira) = par-recid-bancarteira
        no-lock.
end.    

if vstatus = "S"
then do on error undo:

    find clien where clien.clicod = par-clicod no-lock.
    find banco of bancarteira no-lock.

       
    find first banavisopag where
        banAvisoPag.bancod         = bancarteira.bancod and
        banAvisoPag.Agencia         = bancarteira.Agencia  and
        banAvisoPag.ContaCor        = bancarteira.ContaCor and
        banAvisoPag.BanCart        = bancarteira.BanCart and
        banAvisoPag.cdoperacao    = par-cdoperacao
    no-lock no-error.
    if avail banavisopag
    then do:
        vstatus = "N".
        vmensagem_erro = "Ted ja existe com o numero " + string(par-cdoperacao).
        return.
    end.        

    create banAvisoPag.
    par-recid-aviso = recid(banAvisoPag).
    ASSIGN
        banAvisoPag.bancod         = bancarteira.bancod
        banAvisoPag.Agencia         = bancarteira.Agencia
        banAvisoPag.ContaCor        = bancarteira.ContaCor
        banAvisoPag.BanCart        = bancarteira.BanCart
        banAvisoPag.cdoperacao    = par-cdoperacao
        banAvisoPag.Situacao       = "A"
        banAvisoPag.tipoIntegracao = par-tipoIntegracao
        banAvisoPag.CliFor         = clien.clicod
        banAvisoPag.CPFCNPJ        = clien.ciccgc
        banAvisoPag.DtVencimento   = par-DtVencimento
        banAvisoPag.VlCobrado      = par-VlCobrado
        banAvisoPag.DtEmissao      = today
        banAvisoPag.DtPagamento    = ?
        banAvisoPag.VlPagamento    = 0
        banAvisoPag.VlJuros        = 0
        banAvisoPag.TpBaixa        = ?.
    
    vmensagem_erro = "Aviso com Codigo " + 
                        string(par-cdoperacao) +
                        " Gerado".
end.
