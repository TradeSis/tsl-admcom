/* #1 20.04.2018 - helio - Quando regra SUBMETER for NAO, muda comportamento para o mesmo de LOJANEURO = no */
/* #2 05.2018 - Helio - melhorias motor pcto 01 */
/* #3 01.06.2018 - helio - agenda - criado registro tab_ini para verificacao se motor esta ATIVO ou com ACESSO */
/* #4 14.12.2018 TP 28232811 */

def input parameter p-etbcod    as int.
def input parameter p-politica  as char.
def input parameter p-clicod    as int.
def input parameter p-vlrvenda  as dec.
def output parameter par-lojaneuro as log.
def output parameter par-neurotech as log.
def var vx as int.

{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-diasultimacompra as dec.
def var var-qtdecont         as int.
def var var-dtultcpa   as date.
def var var-diasultcpa as int.
def var var-dtultpagto as date.
def var var-diasultpagto  as int.
def var var-diasultatu as int.
def var var-parcpag as int.
def var var-qtdparc as int.
def var var-percparcpag as dec.
def var var-qtdnov as int.

/* #2 */
def var var-totalnov as dec.
def var var-vldevolv as dec.

/* #3 */
find first tab_ini where tab_ini.etbcod = 0 and
                         tab_ini.cxacod = 0 and
                         tab_ini.parametro = "MOTOR_NEUROTECH_ATIVO"
    no-lock no-error.
if avail tab_ini
then do:
    if tab_ini.valor = "NAO"
    then do:
        par-neurotech = no.
        par-lojaneuro = no.
        return.
    end.
end.
/* #3 */

find first agfilcre where
        agfilcre.tipo = "NEUROTECH" and
        agfilcre.etbcod = p-etbcod
    no-lock no-error.
if not avail agfilcre
then do:
    par-neurotech = no.
    par-lojaneuro = no.
end.
else do:
    par-lojaneuro = yes.
    par-neurotech = yes.
end.    

if par-neurotech = yes
then do:
    /* outros Testes */

    find first neuclien where neuclien.clicod = p-clicod no-lock no-error.
    if avail neuclien
    then do:
        find clien where clien.clicod = neuclien.clicod no-lock no-error.
        if avail clien
        then do:
            run neuro/comportamento.p (p-clicod,
                                   ?,
                                   output var-propriedades).

            var-atrasoatual = int(pega_prop("ATRASOATUAL")).
            var-salaberto = dec(pega_prop("LIMITETOM")).
            if var-salaberto = ? then var-salaberto = 0.
            var-sallimite  = neuclien.vlrlimite - var-salaberto.
            if var-sallimite = ? then var-sallimite = 0.
            var-qtdecont   = int(pega_prop("QTDECONT")).
            var-dtultcpa   = date(pega_prop("DTULTCPA")).
            if var-dtultcpa = ? 
            then var-diasultcpa = 99999.
            else var-diasultcpa = today - var-dtultcpa.        
            var-dtultpagto  = date(pega_prop("DTULTPAGTO")).
            if var-dtultpagto = ? 
            then var-diasultpagto = 99999.
            else var-diasultpagto = today - var-dtultpagto.        
            var-diasultatu = today - clien.datexp.
            var-parcpag  = int(pega_prop("PARCPAG")).
            var-qtdparc  = int(pega_prop("QTDPARC")).
            var-percparcpag = var-parcpag / var-qtdparc * 100.            
            if var-percparcpag = ?
            then var-percparcpag = 0.
            /* #2 */
            var-totalnov = dec(pega_prop("TOTALNOV")).
            var-vldevolv = 0.
            do vx = 1 to num-entries(pega_prop("VALORCHDEVOLV"),"|").
                var-vldevolv = var-vldevolv + 
                        dec(entry(vx,pega_prop("VALORCHDEVOLV"),"|")).
            end.            
            var-qtdnov   = int(pega_prop("QTDENOV")).
            /* #2 */
        end.   
    end. 
    
    if p-politica = "P1"
    then do:
        run testa ("SUBMETER?",
                   0).
        if par-neurotech = no 
        then par-lojaneuro = no.           
        if par-neurotech
        then do:           
            run testa ("QUANTIDADE CONTRATOS EXISTENTES",
                       var-qtdecont).
        end.
    end.
    if p-politica = "P2"
    then do:
        run testa ("SUBMETER?",
                   0).
        if par-neurotech = no 
        then par-lojaneuro = no.           
        if par-neurotech
        then do:           
            run testa ("QUANTIDADE CONTRATOS EXISTENTES",
                       var-qtdecont).
        end.
    end.
    if p-politica = "P3"
    then do:
        run testa ("SUBMETER?",
                   0).
        if par-neurotech = no 
        then par-lojaneuro = no.           
        if par-neurotech
        then do:           
            run testa ("DIAS ULTIMA COMPRA",
                       var-diasultcpa).
            if par-neurotech = no
            then run testa ("DIAS ULTIMO PAGAMENTO",
                       var-diasultpagto). 
            if par-neurotech = no
            then run testa ("DIAS ULTIMA ATUALIZACAO",
                       var-diasultatu).        
            if par-neurotech = no
            then run testa ("PERCENTUAL PARCELAS PAGAS",
                             var-percparcpag).  
            if par-neurotech = no
            then run testa ("QUANTIDADE PARCELAS PAGAS",
                             var-parcpag).             
        end.
    end.
    if p-politica = "P4"
    then do:
        run testa ("SUBMETER ATUALIZACAO LIMITES?",
                   0). 
        if par-neurotech = no 
        then par-lojaneuro = no.           
        if par-neurotech
        then do:
        end.           
    end.

    if p-politica = "P5" or
       p-politica = "P6" or
       p-politica = "P7" or
       p-politica = "P8"
    then do:
        run testa ("SUBMETER?",
                   0).
        if par-neurotech = no 
        then par-lojaneuro = no.           
        if par-neurotech
        then do:           
            run testa ("VALOR VENDA",
                       p-vlrvenda).

            /* helio 11.06.18 Ajustado para venda - saldo > 0 , testa se eh excedido
                              se for excedido, entao roda testa para ver se o valor excedido
                                testando contra o parametro 
                                */
            if par-neurotech = no and (p-vlrvenda - var-sallimite > 0) 
            then do:
                run testa ("VALOR VENDA > SALDO LIMITE",
                           p-vlrvenda - var-sallimite).
                                 
            end.                            
            if par-neurotech = no and var-salaberto > 0
            then run testa ("SALDO ABERTO",
                            var-salaberto).
            if par-neurotech = no and var-percparcpag > 0
            then run testa ("PERCENTUAL PARCELAS PAGAS",
                             var-percparcpag).  
            if par-neurotech = no and var-parcpag > 0
            then run testa ("QUANTIDADE PARCELAS PAGAS",
                             var-parcpag).             
            /* #2 */                     
            if par-neurotech = no and var-qtdnov > 0 
            then run testa ("QUANTIDADE DE NOVACOES FEITAS",
                             var-qtdnov).             
            if par-neurotech = no and var-totalnov > 0
            then run testa ("VALOR DE NOVACOES EM ABERTO",
                             var-totalnov).             
            if par-neurotech = no and var-atrasoatual > 0
            then run testa ("DIAS DE ATRASO ATUAL",
                             var-atrasoatual).             
            if par-neurotech = no and var-vldevolv > 0
            then run testa ("CHEQUE DEVOLVIDO ABERTO",
                             var-vldevolv).             
            /* #2 */

            /* #4 */
            if not par-neurotech
            then run testa ("DIAS ULTIMA COMPRA", var-diasultcpa).            
        end.            
    end.    
end.


procedure testa.

    def input parameter par-parametro as char.
    def input parameter par-valor     as dec.

    par-neurotech = no.
    find first tabparam where
            tabparam.tipo      = agfilcre.tipo  and 
            tabparam.grupo     = agfilcre.codigo and
            tabparam.aplicacao = p-politica     and
            tabparam.parametro = par-parametro /*"VALOR VENDA"*/
            no-lock no-error.
    if avail tabparam
    then do:
        if trim(tabparam.condicao) = "="
        then do:
            if par-valor = tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end.
        if trim(tabparam.condicao) = "<" 
        then do: 
            if par-valor <= tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end. 
        if trim(tabparam.condicao) = "<=" 
        then do: 
            if par-valor <= tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end. 
        if trim(tabparam.condicao) = ">" 
        then do: 
            if par-valor >= tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end. 
        if trim(tabparam.condicao) = ">=" 
        then do: 
            if par-valor >= tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end. 
        if trim(tabparam.condicao) = "<>" 
        then do: 
            if par-valor <> tabparam.valor    
            then par-neurotech = tabparam.bloqueio.
            else par-neurotech = not tabparam.bloqueio.
        end. 
    end.

end procedure.
