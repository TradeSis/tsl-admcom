def input param pcontnum        as int.
def input param pidBiometria    as char.
def input param pversaocomponente as char.
def input param pnomecomponente as char.
def input param ppdvmov         as recid.
def output parameter pboletavel as LOG.
def output parameter pmotivo    as char.
if pidbiometria = "" then pidbiometria = ?.

def var vidade as int format "999".
    find pdvmov     where recid(pdvmov) = ppdvmov NO-LOCK NO-ERROR.
    if AVAIL pdvmov then do:
        find cmon of pdvmov no-lock.    
    end.
    
    find contrato   where contrato.contnum = pcontnum no-lock.
    
    pboletavel = no.
    /* helio 24082024 - teste elegivel boletagem */
    find first titulo where titulo.contnum = contrato.contnum and
                            titulo.titpar  >= 1
                            no-lock no-error.
    if avail titulo 
    then do:

        find clien of contrato  no-error.
        if not avail clien
        then next.
    
        pboletavel = yes.

        if titulo.etbcod = 188 or 
           titulo.etbcod = 13
        then.
        else do:
            pmotivo = "NAO EH LOJA PILOTO".
            pboletavel = no.
        end.
                 
        if pboletavel
        then do:
        vidade = (today - clien.dtnasc) / 365.
        if vidade = ? then vidade = 0.

        find first boletagparam where 
            boletagparam.listamodalidades matches "*" + contrato.modcod + "*" and
            boletagparam.dtinivig <= today and
            boletagparam.dtfimvig = ?
            no-lock no-error.
        if not avail boletagparam 
        then pboletavel = no.
        else do:
            if vidade >= boletagparam.idademin and
               vidade <= boletagparam.idademax
            then.
            else do:
                pmotivo = ("IDADE " + string(vidade)).
                pboletavel = no.
            end.
            if pboletavel
            then do:                        
                if contrato.nro_parcelas >= boletagparam.qtdparcmin and
                contrato.nro_parcelas <= boletagparam.qtdparcmax
                then.
                else do:
                    pmotivo =  ("QTD PARCELAS " + string(contrato.nro_parcelas)).
                    pboletavel = no.
                end.
            end.
            if pboletavel
            then do:                        
                if titulo.titdtven - today >= boletagparam.DiasPrimeiroVencMin and
                    titulo.titdtven - today <= boletagparam.DiasPrimeiroVencMax
                then.
                else do:
                    pmotivo =  ("DIAS PRIM VENCIMENTO" + string(titulo.titdtven - today)).
                    pboletavel = no.
                end.
            end.
            if pboletavel
            then do:                        
                if titulo.titvlcob >= boletagparam.valorParcelMin and
                    titulo.titvlcob <= boletagparam.valorparcelamax
                then.
                else do:
                    pmotivo =  ("VALOR PARCELAS " + trim(
                                            string(titulo.titvlcob,">>>>>>>>9.99"))).
                    pboletavel = no.
                end.
            end.
            if pboletavel
            then do:                        
                if boletagparam.listaCarterias <> ? and
                    boletagparam.listacarterias <> ""
                then do:
                    if lookup(string(titulo.cobcod),boletagparam.listaCarterias) <> 0
                    then .
                    else do:
                        pmotivo =  "CARTEIRA " + string(titulo.cobcod).
                        pboletavel = no.
                    end.
                end.
            end.
            if pboletavel
            then do:                        
                if boletagparam.listaPlanos <> ? and
                   boletagparam.listaPlanos <> ""
                then do:
                    if lookup(string(contrato.crecod),boletagparam.listaPlanos) <> 0
                    then.
                    else do:
                        pmotivo =  ("PLANO " + string(contrato.crecod)).
                        pboletavel = no.
                    end.
                end.
            end.
            
            if boletagparam.assinaturadigital = "TODOS"
            then.
            else do:
                if pboletavel
                then do:                        
                    if boletagparam.assinaturadigital = "SIM" 
                    then do:
                        if pidbiometria <> ?
                        then.
                        else do:
                            pmotivo =  ("SEM ASSINATURA").
                            pboletavel = no.
                        end.
                    end.
                    if boletagparam.assinaturadigital = "NAO"
                    then do:
                        if pidbiometria = ?
                        then.
                        else do:
                            pmotivo =  ("COM ASSINATURA").
                            pboletavel = no.
                        end.
                    end.
                end.
            end.
        end.
        end. /* Piloto */
    end.

    /* */
    if pboletavel or pidBiometria <> ?
    then do on error undo:
        find contrassin where contrassin.contnum = contrato.contnum exclusive no-error.
        if not avail contrassin
        then do:
            create contrassin.
            contrassin.contnum     = contrato.contnum.
        end.
        contrassin.clicod      = contrato.clicod.
        
        contrassin.idBiometria = pidBiometria.
        
        contrassin.dtinclu     = contrato.dtinicial.
        contrassin.hrincl      = IF AVAIL pdvmov THEN pdvmov.horamov ELSE TIME.
        contrassin.dtproc      = ?.             /* helio 24082024 - boletagem - dtproc é para assinatura */
        contrassin.hrproc      = ?.
        contrassin.etbcod      = contrato.etbcod.
        contrassin.cxacod      = IF AVAIL cmon THEN cmon.cxacod ELSE ? NO-ERROR.
        contrassin.ctmcod      = IF AVAIL pdvmov THEN pdvmov.ctmcod ELSE "".
        contrassin.nsu         = IF AVAIL pdvmov THEN pdvmov.sequencia ELSE ?.
        if AVAIL pdvmov then do:
            contrassin.hash1 = sha1-digest(string(contrassin.contnum),"CHARACTER") no-error.
            contrassin.hash2 = sha1-digest(string(contrassin.contnum) + contrassin.idbiometria,"CHARACTER") no-error.
        end.
        /* dpge ip - 03072024 */
        contrassin.versaocomponente = pversaocomponente.
        contrassin.nomecomponente = pnomecomponente.

        contrassin.boletavel   = pboletavel.             /* helio 24082024 - boletagem - campo indica se é ou não boletavel */
        contrassin.dtboletagem = ?.
        contrassin.naoboletavelmotivo = pmotivo.

    end.



