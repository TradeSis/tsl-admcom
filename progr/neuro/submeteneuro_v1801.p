/* #1 20.04.2018 - helio - Quando regra SUBMETER for NAO, muda comportamento para o mesmo de LOJANEURO = no */

def input parameter p-etbcod    as int.
def input parameter p-politica  as char.
def input parameter p-clicod    as int.
def input parameter p-vlrvenda  as dec.
def output parameter par-lojaneuro as log.
def output parameter par-neurotech as log.


{acha.i}            /* 03.04.2018 helio */
{neuro/achahash.i}  /* 03.04.2018 helio */
{neuro/varcomportamento.i} /* 03.04.2018 helio */

def var var-diasultimacompra as dec.
def var var-qtdecont         as int.
def var var-dtultcpa    as date.
def var var-diasultcpa as int.
def var var-dtultpagto as date.
def var var-diasultpagto  as int.
def var var-diasultatu as int.
def var var-parcpag as int.
def var var-qtdparc as int.
def var var-percparcpag as dec.


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

            if par-neurotech = no
            then run testa ("VALOR VENDA > SALDO LIMITE",
                            p-vlrvenda - var-sallimite).
            if par-neurotech = no
            then  run testa ("SALDO ABERTO",
                            var-salaberto).
            if par-neurotech = no
            then run testa ("PERCENTUAL PARCELAS PAGAS",
                             var-percparcpag).  
            if par-neurotech = no
            then run testa ("QUANTIDADE PARCELAS PAGAS",
                             var-parcpag).             

        end.            
    end.
    
end.



procedure testa.
def input parameter par-parametro as char.
def input parameter par-valor     as dec.

       find first tabparam where
            tabparam.tipo      = agfilcre.tipo  and 
            tabparam.grupo     = agfilcre.codigo and
            tabparam.aplicacao = p-politica     and
            tabparam.parametro = par-parametro /*"VALOR VENDA"*/
            no-lock no-error.
        if avail tabparam
        then do:
            if tabparam.condicao = "="
            then do:
                if par-valor = tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end.
            if tabparam.condicao = "<" 
            then do: 
                if par-valor < tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end. 
            if tabparam.condicao = "<=" 
            then do: 
                if par-valor <= tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end. 
            if tabparam.condicao = ">" 
            then do: 
                if par-valor > tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end. 
            if tabparam.condicao = ">=" 
            then do: 
                if par-valor >= tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end. 
            if tabparam.condicao = "<>" 
            then do: 
                if par-valor <> tabparam.valor    
                then par-neurotech = tabparam.bloqueio.
                else par-neurotech = not tabparam.bloqueio.
            end. 
        end.                    


end procedure.