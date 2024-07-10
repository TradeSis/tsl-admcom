/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


def var vdec as dec.    
def var vcomprometido   as dec.
def var vsaldoLimite    as dec.
def var setbcod         as int init 0.
def var vpflimite       as dec.
def var vpfsaldo        as dec.
def var parcela-paga    as int init 100.
def var vprof-avencer   as dec.

{/admcom/barramento/metodos/calculaSaldos.i}

/* LE ENTRADA */
lokJSON = hsaldosEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").
          /* 10
          hsaldosEntrada:WRITE-JSON("FILE", "calculaSaldosEntrada.json", true).
          */
create ttstatus.
ttstatus.situacao = "".


find first ttsaldosEntrada no-error.
if not avail ttsaldosEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vdec = dec(ttsaldosEntrada.codigoCliente) no-error.
    if vdec = ? or vdec = 0 
    then do:
        ttstatus.situacao = "CPF INVALIDO " + ttsaldosEntrada.codigoCliente.
    end.
    else do:
        ttstatus.chave  = ttsaldosEntrada.codigoCliente.
        find clien where clien.clicod = int(ttsaldosEntrada.codigoCliente) no-lock no-error.
        if not avail clien
        then do:
            find neuclien where neuclien.cpfcnpj = dec(ttsaldosEntrada.codigoCliente) no-lock no-error.
            if avail neuclien
            then find clien where clien.clicod = neuclien.clicod no-lock. 
        end.    
        else do:
            find neuclien where neuclien.clicod = clien.clicod no-lock no-error. 
        end.
        if not avail neuclien and not avail clien
        then do:
            ttstatus.situacao = "CLIENTE NAO CADASTRADO".
        end.    
    end.
end.    

if ttstatus.situacao = "" and avail ttsaldosEntrada
then do:
    find first ttcredito no-error.
    if avail ttcredito
    then do:
        ttstatus.codigoCliente = ttsaldosEntrada.codigoCliente.
        vcomprometido = 0.
        for each ttmodal of ttcredito.
            vcomprometido = vcomprometido + dec(ttmodal.comprometido).
        end.
        for each ttcomportamento of ttcredito.
        end.
    
        create ttcreditoSaldo.
        
        ttcreditoSaldo.chave         = ttstatus.chave.
        ttcreditoSaldo.limite        = ttcredito.limite.
        ttcreditoSaldo.vctolimite    = ttcredito.vctolimite.
        ttcreditoSaldo.comprometido  = string(vcomprometido).
        vsaldolimite            = dec(ttcredito.limite).
        vsaldolimite            = vsaldoLimite - vcomprometido.
        ttcreditoSaldo.saldolimite   = string(vsaldoLimite).

        find first ttcomportamento where ttcomportamento.atributo = "PARCPAG" no-error.
        parcela-paga = if avail ttcomportamento
                       then dec(ttcomportamento.valorAtributo)
                       else 0.

    for each ttprofin no-lock.
    
        find first profinparam where 
                                     profinparam.fincod  = int(ttprofin.fincod)
                                 and profinparam.etbcod  = setbcod
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
        if not avail profinparam
        then find first profinparam where 
                                    profinparam.fincod = int(ttprofin.fincod)
                                 and profinparam.etbcod  = 0
                                 and profinparam.dtinicial <= today
                                 and (profinparam.dtfinal = ? or
                                      profinparam.dtfinal >= today)
                              no-lock no-error.
        if not avail profinparam
        then do:
            next.
        end.    

        vpflimite = vsaldolimite * (profinparam.perclimite / 100).
        vpfsaldo  = vpflimite.

        if profinparam.vlminimo > vpflimite
        then do:
            vpfsaldo = 0.
        end.    

        if profinparam.parcpagas > 0 and
           profinparam.parcpagas > parcela-paga
        then do:
            vpfsaldo = 0.
        end.    

        /*** Tempo de relacionamento **/
        if profinparam.temporel > 0 and
           clien.dtcad > today - profinparam.temporel
        then do:
            vpfsaldo = 0.
        end.    

        vprof-avencer = 0.
        for each ttmodal where ttmodal.modcod = ttprofin.modcod.
            vprof-avencer = vprof-avencer + dec(ttmodal.comprometido).
        end.

        if vprof-avencer > profinparam.vlmaximo
        then do:
            vpfsaldo = 0.
        end.            

        if vpfsaldo > profinparam.vlmaximo 
        then assign
                vpflimite   = profinparam.vlmaximo.
                
        if vpfsaldo > 0
        then vpfsaldo = vpflimite - vprof-avencer. 
        

    /**
        create tt-profin.
        assign
            tt-profin.codigo        = profin.fincod
            tt-profin.nome          = profin.findesc
            tt-profin.modcod    = profin.modcod
            tt-profin.disponivel = vprof-dispo
            tt-profin.deposito  = profin.obrigadeposito
            tt-profin.token     = par-valor >= profin.limite_token
            tt-profin.saldo     = vprof-saldo
            tt-profin.codsicred = profin.codigo_sicred
            tt-profin.avencer   = vprof-avencer.
            
       **/
                
         create ttsaldoProfin.
            ttsaldoProfin.chave = ttstatus.chave.
            ttsaldoprofin.codigoprofin      = ttprofin.fincod.
            ttsaldoprofin.nomeProFin        = ttprofin.findesc.
            ttsaldoprofin.limite            = string(dec(vpflimite)).
            ttsaldoProfin.saldoDisponivel   = string(dec(vpfsaldo)) .
            
        for each ttprofincond where ttprofincond.pfincod = ttprofin.fincod.
            create ttprofincondSAIDA.
            ttprofincondSAIDA.chave = ttstatus.chave.
            ttprofincondSAIDA.pfincod = ttprofincond.pfincod.
            ttprofincondSAIDA.fincod = ttprofincond.fincod.
            ttprofincondSAIDA.finnom = ttprofincond.finnom.
            ttprofincondSAIDA.finnpc = ttprofincond.finnpc.
            ttprofincondSAIDA.finfat = ttprofincond.finfat.
            ttprofincondSAIDA.txjurosmes = ttprofincond.txjurosmes.
            ttprofincondSAIDA.favorito = ttprofincond.favorito.
            
        end.                
        

        end.
                
    end.
    
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hsaldosSaida:WRITE-JSON("LONGCHAR",  lcJsonSaida, TRUE).
/* 10
          hsaldosSaida:WRITE-JSON("FILE", "calculaSaldosSaida.json", true).
*/
