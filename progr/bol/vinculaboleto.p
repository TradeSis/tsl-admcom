/* helio 26072022 Lock na tabela CybAcordo - ajuste por suspeita */
/* helio 20/05/2021 Boleto Caixa */
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

def buffer bbanboleto for banboleto.

vstatus = "S".
vmensagem_erro = "".

find banBoleto where recid(banBoleto) = par-recid-Boleto no-lock.

/** helio 02062022 retirei todos os testes de já existencia de vinculo, deixando gerar o vinculo origemxboleto normalmente
*-find first banbolOrigem 
*-   where banbolorigem.tabelaOrigem = par-tabelaOrigem and
*-          banbolorigem.chaveOrigem  = par-chaveOrigem and
*-         banbolorigem.dadosOrigem  = par-dadosOrigem
*-    no-lock no-error.
*-if avail banBolOrigem
*-then do:
*-    find bbanboleto of banbolOrigem no-lock.
*-        if recid(bbanboleto) <> par-recid-Boleto
*-        then do:
*-    /*
*-            vcontnum =   int(entry(1,par-dadosOrigem)) no-error. 
*-            vtitpar  =   int(entry(2,par-dadosOrigem)) no-error.
*-            find contrato where contrato.contnum = vcontnum no-lock no-error. 
*-            find first  titulo where
*-                    titulo.empcod = 19 and
*-                    titulo.titnat = no and
*-                    titulo.modcod = contrato.modcod and
*-                    titulo.etbcod = contrato.etbcod and
*-                    titulo.clifor = contrato.clicod and
*-                    titulo.titnum = string(contrato.contnum) and
*-                    titulo.titpar = vtitpar
*-                    no-lock no-error.
*-    */
*-            
*-        if bbanboleto.dtbaixa <> ? and 
*-           bbanboleto.situacao = "L"
*-/*       (avail titulo and titulo.titsit <> "LIB") /* baixado aberto */ */
*-        then do:
*-            vstatus = "N".
*-            vmensagem_erro = "Boleto " + 
*-                                string(banbolorigem.nossonumero,"99999999")
*-                             + " foi emitido para esta solicitacao".
*-            par-recid-Boleto = recid(bbanboleto).                         
*-        end.
*-        else do on error undo:
*-            find current bbanboleto exclusive.
*-            bbanboleto.situacao = "E".
*-            vstatus = "S".
*-        /* 15.01.2018 desvincula */
*-        /* 16.01.2018 desvincula tudo, pedido da Vanessa */
*-            for each banbolorigem of bbanboleto.
*-                /* #1  delete banbolorigem. */
*-               /*
*-                banbolorigem.BanCart = ?.
*-                banbolorigem.ChaveOrigem  = ?.
*-                banbolorigem.tabelaorigem = "DESVINCULADO".
*-                */
*-                banbolorigem.tabelaorigem = ?.
*-            
*-            end. 
*-            find banBoleto where recid(banBoleto) = par-recid-Boleto no-lock.
*-        end.
*-    end.
*-    else do on error undo:
*-        find current banbolorigem exclusive.
*-        delete banbolorigem.
*-    end.
*-    
*-end.
*-*/

if vstatus = "S"
then do: /* on error - helio 26072022 Lock na tabela CybAcordo - ajuste por suspeita */



    if par-tabelaOrigem = "CybAcParcela"
    then do:
        find cybacparcela where
            cybacparcela.idacordo = int(entry(1,par-dadosOrigem)) and
            cybacparcela.parcela  = int(entry(2,par-dadosOrigem))
          no-lock no-error.   
        if avail cybacparcela
        then do on error undo:

            /* helio 26072022 Lock na tabela CybAcordo - ajuste por suspeita */
          /*find cybacordo of cybacparcela no-error. */
            find cybacordo of cybacparcela exclusive no-wait no-error. 
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

    /* helio 26072022 Lock na tabela CybAcordo - ajuste por suspeita 
   * if par-tabelaOrigem = "promessa"
   * then do:
   *     for each CSLPromessa where
   *         CSLPromessa.idacordo = int(entry(1,par-dadosOrigem)) and
   *         CSLPromessa.contnum  = int(entry(2,par-dadosOrigem)) and
   *         CSLPromessa.parcela  = int(entry(3,par-dadosOrigem))
   *           no-lock .
   *         find cybacordo of CSLPromessa no-error.
   *         if avail cybacordo
   *         then do:
   *             cybacordo.situacao = "V".
   *             cybacordo.dtvinculo = today.
   *
   *             create banBolOrigem.     
   *             ASSIGN
   *                 banBolOrigem.bancod       = banboleto.bancod
   *                 banBolOrigem.Agencia      = banBoleto.Agencia
   *                 banBolOrigem.ContaCor     = banBoleto.ContaCor
   *                 banBolOrigem.banCart      = banBoleto.banCart
   *                 banBolOrigem.NossoNumero  = banBoleto.NossoNumero
   *                 banBolOrigem.TabelaOrigem = par-TabelaOrigem
   *                 banBolOrigem.ChaveOrigem  = par-ChaveOrigem
   *                 banBolOrigem.DadosOrigem  = par-DadosOrigem /**+ "," + string(CSLPromessa.parcela)**/ .
   *                 banbolorigem.ValorOrigem  = par-valor.
   *
   *             find current banboleto exclusive.
   *             banboleto.situacao = "R". /* Registrado boleto caixa  */
   *
   *         end.
   *     end.
   *     return.
   * end.
   */ 
   
    if par-tabelaOrigem = "promessa"
    then do:

        do on error undo:
            find cybacordo where cybacordo.idacordo = int(entry(1,par-dadosOrigem)) exclusive no-wait no-error.
            if avail cybacordo
            then do:
                cybacordo.situacao = "V".
                cybacordo.dtvinculo = today.
            end. 
            
            find current banboleto exclusive. 
            banboleto.situacao = "R". /* Registrado boleto caixa  */
            
        end.    
        
        for each CSLPromessa where
            CSLPromessa.idacordo = int(entry(1,par-dadosOrigem)) and
            CSLPromessa.contnum  = int(entry(2,par-dadosOrigem)) and
            CSLPromessa.parcela  = int(entry(3,par-dadosOrigem))
              no-lock .

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

        end.
        return.
    end.
    /* helio 26072022 Lock na tabela CybAcordo - ajuste por suspeita */
    

    if vstatus = "S"
    then do on error undo:
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
        banboleto.situacao = "R".
    end.
end.
