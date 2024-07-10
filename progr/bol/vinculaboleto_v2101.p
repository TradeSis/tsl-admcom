/* #1 - helio 05.18 - erro vinculo, Nao delete mais, coloca null no campo da chave , se ocorrer de novo, podemos achar a origem*/

def input parameter par-recid-boleto as recid.
def input parameter par-tabelaorigem as char.
def input parameter par-chaveorigem as char.
def input parameter par-dadosorigem as char.
def input parameter par-valor       as dec.

def output parameter vstatus  as char.
def output parameter vmensagem_erro as char.

def var vcontnum as int.
 def var vtitpar as int.


vstatus = "S".
vmensagem_erro = "".

find banBoleto where recid(banBoleto) = par-recid-Boleto
        no-lock.


find first banbolOrigem 
    where banbolorigem.tabelaOrigem = par-tabelaOrigem and
          banbolorigem.chaveOrigem  = par-chaveOrigem and
          banbolorigem.dadosOrigem  = par-dadosOrigem
    no-lock no-error.
if avail banBolOrigem
then do:
    find banboleto of banbolOrigem no-lock.

    /*
            vcontnum =   int(entry(1,par-dadosOrigem)) no-error. 
            vtitpar  =   int(entry(2,par-dadosOrigem)) no-error.
            find contrato where contrato.contnum = vcontnum no-lock no-error. 
            find first  titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = contrato.modcod and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum) and
                    titulo.titpar = vtitpar
                    no-lock no-error.
    */
            
    if banboleto.dtbaixa <> ? and 
       banboleto.situacao = "L"
/*       (avail titulo and titulo.titsit <> "LIB") /* baixado aberto */ */
    then do:
        vstatus = "N".
        vmensagem_erro = "Boleto " + 
                            string(banbolorigem.nossonumero,"99999999")
                         + " foi emitido para esta solicitacao".
        par-recid-Boleto = recid(banboleto).                         
    end.
    else do on error undo:
        find current banboleto exclusive.
        banboleto.situacao = "E".
        vstatus = "S".
        /* 15.01.2018 desvincula */
        /* 16.01.2018 desvincula tudo, pedido da Vanessa */
        for each banbolorigem of banboleto.
            /* #1  delete banbolorigem. */
            banbolorigem.tabelaorigem = ?.
        end. 
        find banBoleto where recid(banBoleto) = par-recid-Boleto no-lock.
    end.
    
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
    if par-tabelaOrigem = "promessa"
    then do:
        for each CSLPromessa where
            CSLPromessa.idacordo = int(entry(1,par-dadosOrigem)) and
            CSLPromessa.contnum  = int(entry(2,par-dadosOrigem)) and
            CSLPromessa.parcela  = int(entry(3,par-dadosOrigem))
              no-lock .
            find cybacordo of CSLPromessa no-error.
            if avail cybacordo
            then do:
                cybacordo.situacao = "V".
                cybacordo.dtvinculo = today.

                create banBolOrigem.     
                ASSIGN
                    banBolOrigem.bancod       = banboleto.bancod
                    banBolOrigem.Agencia      = banBoleto.Agencia
                    banBolOrigem.ContaCor     = banBoleto.ContaCor
                    banBolOrigem.banCart      = banBoleto.banCart
                    banBolOrigem.NossoNumero  = banBoleto.NossoNumero
                    banBolOrigem.TabelaOrigem = par-TabelaOrigem
                    banBolOrigem.ChaveOrigem  = par-ChaveOrigem
                    banBolOrigem.DadosOrigem  = par-DadosOrigem /**+ "," + string(CSLPromessa.parcela)**/ .
                    banbolorigem.ValorOrigem  = par-valor.
 /* helio 10.03.2021 */
                find current banboleto exclusive.
                banboleto.situacao = "V".

            end.
        end.
        return.
    end.
    

    if vstatus = "S"
    then do:
        create banBolOrigem.     
        ASSIGN
            banBolOrigem.bancod       = banboleto.bancod
            banBolOrigem.Agencia      = banBoleto.Agencia
            banBolOrigem.ContaCor     = banBoleto.ContaCor
            banBolOrigem.banCart      = banBoleto.banCart
            banBolOrigem.NossoNumero  = banBoleto.NossoNumero
            banBolOrigem.TabelaOrigem = par-TabelaOrigem
            banBolOrigem.ChaveOrigem  = par-ChaveOrigem
            banBolOrigem.DadosOrigem  = par-DadosOrigem
            banbolorigem.ValorOrigem  = par-valor.
        find current banboleto exclusive.
        banboleto.situacao = "V".
    end.
end.
