def input parameter par-recid-aviso as recid.
def input parameter par-tabelaorigem as char.
def input parameter par-chaveorigem as char.
def input parameter par-dadosorigem as char.
def input parameter par-valor       as dec.

def output parameter vstatus  as char.
def output parameter vmensagem_erro as char.


vstatus = "S".
vmensagem_erro = "".

find banaviso where recid(banaviso) = par-recid-aviso
        no-lock.


find first banAviOrigem 
    where banAviOrigem.tabelaOrigem = par-tabelaOrigem and
          banAviOrigem.chaveOrigem  = par-chaveOrigem and
          banAviOrigem.dadosOrigem  = par-dadosOrigem
    no-lock no-error.
if avail banAviOrigem
then do:
    find banaviso of banAviOrigem no-lock.
    if banaviso.dtpagamento <> ?
    then do:
        vstatus = "N".
        vmensagem_erro = "IDTed " + 
                        banAviOrigem.cdoperacao
                     + " foi emitido para esta solicitacao".
    end.
    else do:
        vstatus = "S".
        /* 15.01.2018 desvincula */
        /* 16.01.2018 desvincula tudo */
        for each banaviorigem of banaviso.
            delete banaviorigem.
        end.    
        find banaviso where recid(banaviso) = par-recid-aviso no-lock.
    end.
    /**
    par-recid-aviso = recid(banaviso).                         
    **/
end.

if vstatus = "S"
then do on error undo:


    if par-tabelaOrigem = "CybAcParcela"
    then do:
        find cybacparcela where
            cybacparcela.idacordo = int(entry(1,par-dadosOrigem)) and
            cybacparcela.parcela  = int(entry(2,par-dadosOrigem))
          no-lock no-error.   
        if avail cybacparcela
        then do:
            find cybacordo of cybacparcela no-error.
            if avail cybacordo
            then do:
                cybacordo.situacao = "V".
                cybacordo.dtvinculo = today.
            end.
        end.

        if not avail cybacparcela or
           not avail cybacordo
        then do:
            vstatus = "N".
            vmensagem_erro = "Nao foi possivel associar Origem".
        end.
    end.

    if vstatus = "S"
    then do:
        create banAviOrigem.     
        ASSIGN
            banAviOrigem.bancod       = banaviso.bancod
            banAviOrigem.Agencia      = banaviso.Agencia
            banAviOrigem.ContaCor     = banaviso.ContaCor
            banAviOrigem.banCart      = banaviso.banCart
            banAviOrigem.cdoperacao  = banaviso.cdoperacao
            banAviOrigem.TabelaOrigem = par-TabelaOrigem
            banAviOrigem.ChaveOrigem  = par-ChaveOrigem
            banAviOrigem.DadosOrigem  = par-DadosOrigem
            banAviOrigem.ValorOrigem  = par-valor.
        find current banaviso exclusive.
        banaviso.situacao = "V".
    end.
end.
