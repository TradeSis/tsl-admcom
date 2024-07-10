{admcab.i}
def new shared var vdti as date.
def new shared var vdtf as date.
def new shared var vetbcod like estab.etbcod.

update vetbcod label "Filial" with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
update vdti at 1 label "Data inicial"
       vdtf label "Data final" 
       with frame f1 1 down width 80 side-label.

def temp-table tt-outcontrato
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(15)"
    field tipo4 as char format "x(15)"
    field vlcontrato as dec   format ">>>,>>>,>>9.99"
    field vlentrada  as dec   format ">>>,>>>,>>9.99"
    field vlprincipal as dec  format ">>>,>>>,>>9.99"
    field vlacrescimo as dec  format ">>>,>>>,>>9.99"
    field vlseguro as dec     format ">>>,>>>,>>9.99"
    field vlorigem as dec     format ">>>,>>>,>>9.99"
    field vlorifin as dec     format ">>>,>>>,>>9.99"
    field vlorileb as dec     format ">>>,>>>,>>9.99"
    field vlabate  as dec     format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4 
    .

def temp-table esf-outcontrato
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(15)"
    field tipo4 as char format "x(15)"
    field vlcontrato as dec   format ">>>,>>>,>>9.99"
    field vlentrada  as dec   format ">>>,>>>,>>9.99"
    field vlprincipal as dec  format ">>>,>>>,>>9.99"
    field vlacrescimo as dec  format ">>>,>>>,>>9.99"
    field vlseguro as dec     format ">>>,>>>,>>9.99"
    field vlorigem as dec     format ">>>,>>>,>>9.99"
    field vlorifin as dec     format ">>>,>>>,>>9.99"
    field vlorileb as dec     format ">>>,>>>,>>9.99"
    field vlabate  as dec     format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4 
    .
     
def temp-table tt-outrecebe
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(15)"
    field tipo4 as char format "x(15)"
    field vlparcela as dec    format ">>>,>>>,>>9.99"
    field vlpago  as dec      format ">>>,>>>,>>9.99"
    field vlprincipal as dec  format ">>>,>>>,>>9.99"
    field vlacrescimo as dec  format ">>>,>>>,>>9.99"
    field vlseguro as dec     format ">>>,>>>,>>9.99"
    field vljuro as dec       format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4 
    .
      
def temp-table tt-outvenda
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(15)"
    field tipo4 as char format "x(25)"
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4
    .
    
def temp-table vol-outvenda
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(10)"
    field tipo4 as char format "x(25)"
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4
    .
    
def temp-table vor-outvenda
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(10)"
    field tipo4 as char format "x(25)"
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4
    .

def temp-table dv-outvenda
    field tipo1 as char format "x(15)"
    field tipo2 as char format "x(15)"
    field tipo3 as char format "x(10)"
    field tipo4 as char format "x(25)"
    field valorigem as dec  format ">>>,>>>,>>9.99"
    field valfrete  as dec  format ">>>,>>9.99"
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    field vlcontrato as dec    format ">>>,>>>,>>9.99"
    field vlprincipal as dec   format ">>>,>>>,>>9.99"
    field vlacrescimo as dec   format ">,>>>,>>9.99"
    field vlseguro as dec      format ">,>>>,>>9.99"
    field vlquitado as dec     format ">>,>>>,>>9.99"
    field vldevolvido as dec   format ">>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4
    .

def temp-table dt-outvenda
    field emite like  outvenda.emite
    field serie like outvenda.serie
    field numero like outvenda.numero
    field pladat like plani.pladat
    field chave  like outvenda.chave
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    index i1 emite serie numero
    .

def var char-crecod as char.
def var vdest as char.

def var vdata as date.
def var vindex as int.
def var vesc as char extent 5 format "x(30)".
vesc[1] = "GERAL TOTAIS".
vesc[2] = "VENDA TOTAIS".
vesc[3] = "CONTRATO TOTAIS".
vesc[4] = "RECEBIMENTO TOTAIS".
vesc[5] = "ANALITICO POR DOCUMENTO".


disp vesc with frame f-esc no-label 1 down 1 column.
choose field vesc with frame f-esc.
vindex = frame-index.
/*
sresp = no.
message "Confirma emitir relatorio " vesc[vindex] "?" update sresp.
if not sresp then undo.

disp "Aguarde relatorio " vesc[vindex]
    with frame f-ag no-box 1 down row 20 side-label no-label
    color message.
*/

if vindex = 5
then do:
    run /admcom/progr/ctb/rel-valores-CTB-AD-0119.p.
end.
else do:
sresp = no.
message "Confirma emitir relatorio " vesc[vindex] "?" update sresp.
if not sresp then undo.

disp "Aguarde relatorio " vesc[vindex]
    with frame f-ag no-box 1 down row 20 side-label no-label
    color message.



for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod else true)
                no-lock:

do vdata = vdti to vdtf:

if vindex = 1 or vindex = 2 
then do:
for each outvenda where outvenda.tipo = "VENDA" and
                        outvenda.tipovenda = "VENDA LOJA" and
                        outvenda.datref = vdata and
                        outvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if outvenda.movseq = 20 
    then do:
        find first tt-outvenda where
                   tt-outvenda.tipo1 = "VENDA TOTAL" and
                   tt-outvenda.tipo2 = "" and
                   tt-outvenda.tipo3 = "" and
                   tt-outvenda.tipo4 = ""
                   no-error.
        if not avail tt-outvenda
        then do:
            create tt-outvenda.  
            assign
                tt-outvenda.tipo1 = "VENDA TOTAL" 
                 .
        end.
        assign
            tt-outvenda.vlmercadoria = tt-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            tt-outvenda.vlservico    = tt-outvenda.vlservico +
                                          outvenda.servico
            tt-outvenda.vloutras     = tt-outvenda.vloutras +
                                          outvenda.outras
            tt-outvenda.vltotal       = tt-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +                         outvenda.outras
            .                              
    end.
    if outvenda.movseq = 30
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        
        if outvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outvenda where
                   tt-outvenda.tipo1 = "" and
                   tt-outvenda.tipo2 = char-crecod and
                   tt-outvenda.tipo3 = "" and
                   tt-outvenda.tipo4 = ""
                   no-error.
        if not avail tt-outvenda
        then do:
            create tt-outvenda.  
            assign
                tt-outvenda.tipo1 = "" 
                tt-outvenda.tipo2 = char-crecod
                tt-outvenda.tipo3 = ""
                tt-outvenda.tipo4 = ""
                 .
        end.
        assign
            tt-outvenda.vlmercadoria = tt-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            tt-outvenda.vlservico    = tt-outvenda.vlservico +
                                          outvenda.servico
            tt-outvenda.vloutras     = tt-outvenda.vloutras +
                                          outvenda.outras
            tt-outvenda.vltotal       = tt-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
             .
        find first tt-outvenda where
                   tt-outvenda.tipo1 = "" and
                   tt-outvenda.tipo2 = char-crecod and
                   tt-outvenda.tipo3 = vdest and
                   tt-outvenda.tipo4 = ""
                   no-error.
        if not avail tt-outvenda
        then do:
            create tt-outvenda.  
            assign
                tt-outvenda.tipo1 = "" 
                tt-outvenda.tipo2 = char-crecod
                tt-outvenda.tipo3 = vdest
                tt-outvenda.tipo4 = ""
                 .
        end.
        assign
            tt-outvenda.vlmercadoria = tt-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            tt-outvenda.vlservico    = tt-outvenda.vlservico +
                                          outvenda.servico
            tt-outvenda.vloutras     = tt-outvenda.vloutras +
                                          outvenda.outras
            tt-outvenda.vltotal       = tt-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
             .                                        
    end.
    if outvenda.movseq = 35
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if outvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outvenda where
                   tt-outvenda.tipo1 = "" and
                   tt-outvenda.tipo2 = char-crecod and
                   tt-outvenda.tipo3 = vdest  and
                   tt-outvenda.tipo4 = outvenda.produto
                   no-error.
        if not avail tt-outvenda
        then do:
            create tt-outvenda.  
            assign
                tt-outvenda.tipo1 = "" 
                tt-outvenda.tipo2 = char-crecod
                tt-outvenda.tipo3 = vdest
                tt-outvenda.tipo4 = outvenda.produto
                 .
        end.
        assign
            tt-outvenda.vlmercadoria = tt-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            tt-outvenda.vlservico    = tt-outvenda.vlservico +
                                          outvenda.servico
            tt-outvenda.vloutras     = tt-outvenda.vloutras +
                                          outvenda.outras
            tt-outvenda.vltotal       = tt-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +  
                             outvenda.outras

     
            .                              
    end.
    end.
    
end.
for each outvenda where outvenda.tipo = "VENDA" and
                        outvenda.tipovenda = "VENDA OUTRA LOJA" and
                        outvenda.datref = vdata and
                        outvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if outvenda.movseq = 20 
    then do:
        find first vol-outvenda where
                   vol-outvenda.tipo1 = "VENDA TOTAL" and
                   vol-outvenda.tipo2 = "" and
                   vol-outvenda.tipo3 = "" and
                   vol-outvenda.tipo4 = ""
                   no-error.
        if not avail vol-outvenda
        then do:
            create vol-outvenda.  
            assign
                vol-outvenda.tipo1 = "VENDA TOTAL" 
                 .
        end.
        assign
            vol-outvenda.vlmercadoria = vol-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vol-outvenda.vlservico    = vol-outvenda.vlservico +
                                          outvenda.servico
            vol-outvenda.vloutras     = vol-outvenda.vloutras +
                                          outvenda.outras
            vol-outvenda.vltotal       = vol-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico + 
                                      outvenda.outras
            .                              
    end.
    if outvenda.movseq = 30
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if outvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first vol-outvenda where
                   vol-outvenda.tipo1 = "" and
                   vol-outvenda.tipo2 = char-crecod and
                   vol-outvenda.tipo3 = "" and
                   vol-outvenda.tipo4 = ""
                   no-error.
        if not avail vol-outvenda
        then do:
            create vol-outvenda.  
            assign
                vol-outvenda.tipo1 = "" 
                vol-outvenda.tipo2 = char-crecod
                vol-outvenda.tipo3 = ""
                vol-outvenda.tipo4 = ""
                 .
        end.
        assign
            vol-outvenda.vlmercadoria = vol-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vol-outvenda.vlservico    = vol-outvenda.vlservico +
                                          outvenda.servico
            vol-outvenda.vloutras     = vol-outvenda.vloutras +
                                          outvenda.outras
            vol-outvenda.vltotal       = vol-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
             .
        find first vol-outvenda where
                   vol-outvenda.tipo1 = "" and
                   vol-outvenda.tipo2 = char-crecod and
                   vol-outvenda.tipo3 = vdest and
                   vol-outvenda.tipo4 = ""
                   no-error.
        if not avail vol-outvenda
        then do:
            create vol-outvenda.  
            assign
                vol-outvenda.tipo1 = "" 
                vol-outvenda.tipo2 = char-crecod
                vol-outvenda.tipo3 = vdest
                vol-outvenda.tipo4 = ""
                 .
        end.
        assign
            vol-outvenda.vlmercadoria = vol-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vol-outvenda.vlservico    = vol-outvenda.vlservico +
                                          outvenda.servico
            vol-outvenda.vloutras     = vol-outvenda.vloutras +
                                          outvenda.outras
            vol-outvenda.vltotal       = vol-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
             .                                        
    end.
    if outvenda.movseq = 35
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if outvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first vol-outvenda where
                   vol-outvenda.tipo1 = "" and
                   vol-outvenda.tipo2 = char-crecod and
                   vol-outvenda.tipo3 = vdest and
                   vol-outvenda.tipo4 = outvenda.produto
                   no-error.
        if not avail vol-outvenda
        then do:
            create vol-outvenda.  
            assign
                vol-outvenda.tipo1 = "" 
                vol-outvenda.tipo2 = char-crecod
                vol-outvenda.tipo3 = vdest
                vol-outvenda.tipo4 = outvenda.produto
                 .
        end.
        assign
            vol-outvenda.vlmercadoria = vol-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vol-outvenda.vlservico    = vol-outvenda.vlservico +
                                          outvenda.servico
            vol-outvenda.vloutras     = vol-outvenda.vloutras +
                                          outvenda.outras
            vol-outvenda.vltotal       = vol-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +  
                             outvenda.outras
            .                              
    end.
    end.
end.

for each outvenda where outvenda.tipo = "VENDA" and
                        outvenda.tipovenda = "VENDA RETIRADA" and
                        outvenda.datref = vdata and
                        outvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if outvenda.movseq = 20 
    then do:
        find first vor-outvenda where
                   vor-outvenda.tipo1 = "VENDA TOTAL" and
                   vor-outvenda.tipo2 = "" and
                   vor-outvenda.tipo3 = "" and
                   vor-outvenda.tipo4 = ""
                   no-error.
        if not avail vor-outvenda
        then do:
            create vor-outvenda.  
            assign
                vor-outvenda.tipo1 = "VENDA TOTAL" 
                vor-outvenda.tipo2 = ""
                vor-outvenda.tipo3 = ""
                vor-outvenda.tipo4 = ""
                 .
        end.
        assign
            vor-outvenda.vlmercadoria = vor-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vor-outvenda.vlservico    = vor-outvenda.vlservico +
                                          outvenda.servico
            vor-outvenda.vloutras     = vor-outvenda.vloutras +
                                          outvenda.outras
            vor-outvenda.vltotal       = vor-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico + 
                                      outvenda.outras
            .                              
    end.
    if outvenda.movseq = 30
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        find first vor-outvenda where
                   vor-outvenda.tipo1 = "" and
                   vor-outvenda.tipo2 = char-crecod and
                   vor-outvenda.tipo3 = "" and
                   vor-outvenda.tipo4 = ""
                   no-error.
        if not avail vor-outvenda
        then do:
            create vor-outvenda.  
            assign
                vor-outvenda.tipo1 = "" 
                vor-outvenda.tipo2 = char-crecod
                vor-outvenda.tipo3 = ""
                vor-outvenda.tipo4 = ""
                 .
        end.
        assign
            vor-outvenda.vlmercadoria = vor-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vor-outvenda.vlservico    = vor-outvenda.vlservico +
                                          outvenda.servico
            vor-outvenda.vloutras     = vor-outvenda.vloutras +
                                          outvenda.outras
            vor-outvenda.vltotal       = vor-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
             .                              
    end.
    if outvenda.movseq = 35
    then do:
        if outvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        find first vor-outvenda where
                   vor-outvenda.tipo1 = "" and
                   vor-outvenda.tipo2 = char-crecod and
                   vor-outvenda.tipo3 = "" and
                   vor-outvenda.tipo4 = outvenda.produto
                   no-error.
        if not avail vor-outvenda
        then do:
            create vor-outvenda.  
            assign
                vor-outvenda.tipo1 = "" 
                vor-outvenda.tipo2 = char-crecod
                vor-outvenda.tipo3 = ""
                vor-outvenda.tipo4 = outvenda.produto
                 .
        end.
        assign
            vor-outvenda.vlmercadoria = vor-outvenda.vlmercadoria +
                                          outvenda.mercadoria
            vor-outvenda.vlservico    = vor-outvenda.vlservico +
                                          outvenda.servico
            vor-outvenda.vloutras     = vor-outvenda.vloutras +
                                          outvenda.outras
            vor-outvenda.vltotal       = vor-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +  
                             outvenda.outras
            .                              
    end.
    end.
end.

for each outvenda where outvenda.tipo = "DEVOLUCAO VENDA" and
                        outvenda.datref = vdata and
                        outvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
        if outvenda.movseq = 100
        then do:
            find first dv-outvenda where
                   dv-outvenda.tipo1 = "DEVOLUCAO TOTAL" and
                   dv-outvenda.tipo2 = "" and
                   dv-outvenda.tipo3 = "" and
                   dv-outvenda.tipo4 = ""
                   no-error.
            if not avail dv-outvenda
            then do:
                create dv-outvenda.  
                assign
                    dv-outvenda.tipo1 = "DEVOLUCAO TOTAL" 
                    .
            end.
            assign
                dv-outvenda.valorigem = dv-outvenda.valorigem +
                                        outvenda.valorigem
                dv-outvenda.valfrete  = dv-outvenda.valfrete +
                                        outvenda.valfrete
                dv-outvenda.vlmercadoria = dv-outvenda.vlmercadoria +
                                          outvenda.mercadoria
                dv-outvenda.vlservico    = dv-outvenda.vlservico +
                                          outvenda.servico
                dv-outvenda.vloutras     = dv-outvenda.vloutras +
                                          outvenda.outras
                dv-outvenda.vltotal       = dv-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico + 
                                          outvenda.outras
                dv-outvenda.vlcontrato    = dv-outvenda.vlcontrato +
                                                outvenda.valcontrato
                dv-outvenda.vlprincipal   = dv-outvenda.vlprincipal +
                                            outvenda.valprincipal
                dv-outvenda.vlacrescimo   = dv-outvenda.vlacrescimo +
                                            outvenda.valacrescimo
                dv-outvenda.vlseguro      = dv-outvenda.vlseguro +
                                            outvenda.valseguro
                dv-outvenda.vlquitado  = dv-outvenda.vlquitado +
                              outvenda.valquitado.
                dv-outvenda.vldevolvido = dv-outvenda.vldevolvido +
                              outvenda.valdevolvido
                .                              
        end.
        else if outvenda.movseq = 200
        then do:
            if outvenda.crecod = 1
            then char-crecod = "DEVOLUCAO VISTA".
            else char-crecod = "DEVOLUCAO PRAZO".

            if outvenda.cobcod = 200
            then vdest = "ECOMMERCE".
            else if outvenda.cobcod = 10
                then vdest = "FINANCEIRA".
                else if outvenda.cobcod = 14
                    then vdest = "FIDC".
                    else vdest = "LEBES".

            find first dv-outvenda where
                   dv-outvenda.tipo1 = "" and
                   dv-outvenda.tipo2 = char-crecod and
                   dv-outvenda.tipo3 = "" and
                   dv-outvenda.tipo4 = ""
                   no-error.
            if not avail dv-outvenda
            then do:
                create dv-outvenda.  
                assign
                    dv-outvenda.tipo1 = "" 
                    dv-outvenda.tipo2 = char-crecod
                    dv-outvenda.tipo3 = ""
                    .
            end.
            assign
                dv-outvenda.valorigem = dv-outvenda.valorigem +
                                        outvenda.valorigem
                dv-outvenda.valfrete  = dv-outvenda.valfrete +
                                        outvenda.valfrete
                dv-outvenda.vlmercadoria = dv-outvenda.vlmercadoria +
                                          outvenda.mercadoria
                dv-outvenda.vlservico    = dv-outvenda.vlservico +
                                          outvenda.servico
                dv-outvenda.vloutras     = dv-outvenda.vloutras +
                                          outvenda.outras
                dv-outvenda.vltotal       = dv-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
                dv-outvenda.vlcontrato    = dv-outvenda.vlcontrato +
                                            outvenda.valcontrato
                dv-outvenda.vlprincipal   = dv-outvenda.vlprincipal +
                                            outvenda.valprincipal
                dv-outvenda.vlacrescimo   = dv-outvenda.vlacrescimo +
                                            outvenda.valacrescimo
                dv-outvenda.vlseguro      = dv-outvenda.vlseguro +
                                            outvenda.valseguro
                dv-outvenda.vlquitado  = dv-outvenda.vlquitado +
                              outvenda.valquitado.
                dv-outvenda.vldevolvido = dv-outvenda.vldevolvido +
                              outvenda.valdevolvido
                . 
                
            find first dv-outvenda where
                   dv-outvenda.tipo1 = "" and
                   dv-outvenda.tipo2 = char-crecod and
                   dv-outvenda.tipo3 = vdest and
                   dv-outvenda.tipo4 = ""
                   no-error.
            if not avail dv-outvenda
            then do:
                create dv-outvenda.  
                assign
                    dv-outvenda.tipo1 = "" 
                    dv-outvenda.tipo2 = char-crecod
                    dv-outvenda.tipo3 = vdest
                    .
            end.
            assign
                dv-outvenda.valorigem = dv-outvenda.valorigem +
                                        outvenda.valorigem
                dv-outvenda.valfrete  = dv-outvenda.valfrete +
                                        outvenda.valfrete
                dv-outvenda.vlmercadoria = dv-outvenda.vlmercadoria +
                                          outvenda.mercadoria
                dv-outvenda.vlservico    = dv-outvenda.vlservico +
                                          outvenda.servico
                dv-outvenda.vloutras     = dv-outvenda.vloutras +
                                          outvenda.outras
                dv-outvenda.vltotal       = dv-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
                dv-outvenda.vlcontrato    = dv-outvenda.vlcontrato +
                                            outvenda.valcontrato
                dv-outvenda.vlprincipal   = dv-outvenda.vlprincipal +
                                            outvenda.valprincipal
                dv-outvenda.vlacrescimo   = dv-outvenda.vlacrescimo +
                                            outvenda.valacrescimo
                dv-outvenda.vlseguro      = dv-outvenda.vlseguro +
                                            outvenda.valseguro
                dv-outvenda.vlquitado  = dv-outvenda.vlquitado +
                              outvenda.valquitado.
                dv-outvenda.vldevolvido = dv-outvenda.vldevolvido +
                              outvenda.valdevolvido
                .                                  
        end.
        else if outvenda.movseq = 221
        then do:
            if outvenda.crecod = 1
            then char-crecod = "DEVOLUCAO VISTA".
            else char-crecod = "DEVOLUCAO PRAZO".

            if outvenda.cobcod = 200
            then vdest = "ECOMMERCE".
            else if outvenda.cobcod = 10
                then vdest = "FINANCEIRA".
                else if outvenda.cobcod = 14
                    then vdest = "FIDC".
                    else vdest = "LEBES".

            find first dv-outvenda where
                   dv-outvenda.tipo1 = "" and
                   dv-outvenda.tipo2 = char-crecod and
                   dv-outvenda.tipo3 = vdest and
                   dv-outvenda.tipo4 = outvenda.produto
                   no-error.
            if not avail dv-outvenda
            then do:
                create dv-outvenda.  
                assign
                    dv-outvenda.tipo1 = "" 
                    dv-outvenda.tipo2 = char-crecod
                    dv-outvenda.tipo3 = vdest
                    dv-outvenda.tipo4 = outvenda.produto
                    .
            end.
            assign
                dv-outvenda.valorigem = dv-outvenda.valorigem +
                                        outvenda.valorigem
                dv-outvenda.valfrete  = dv-outvenda.valfrete +
                                        outvenda.valfrete
                dv-outvenda.vlmercadoria = dv-outvenda.vlmercadoria +
                                          outvenda.mercadoria
                dv-outvenda.vlservico    = dv-outvenda.vlservico +
                                          outvenda.servico
                dv-outvenda.vloutras     = dv-outvenda.vloutras +
                                          outvenda.outras
                dv-outvenda.vltotal       = dv-outvenda.vltotal + 
                        outvenda.mercadoria + outvenda.servico +    
                           outvenda.outras
                dv-outvenda.vlcontrato    = dv-outvenda.vlcontrato +
                                            outvenda.valcontrato
                dv-outvenda.vlprincipal   = dv-outvenda.vlprincipal +
                                            outvenda.valprincipal
                dv-outvenda.vlacrescimo   = dv-outvenda.vlacrescimo +
                                            outvenda.valacrescimo
                dv-outvenda.vlseguro      = dv-outvenda.vlseguro +
                                            outvenda.valseguro
                dv-outvenda.vlquitado  = dv-outvenda.vlquitado +
                              outvenda.valquitado.
                dv-outvenda.vldevolvido = dv-outvenda.vldevolvido +
                              outvenda.valdevolvido
                .                                  
        end.
    end.

end.

end.
if vindex = 1 or vindex = 3 
then do:
for each outcontrato where outcontrato.tipo = "CONTRATO" and
                           outcontrato.datref = vdata and
                           outcontrato.etbcod = estab.etbcod
                           no-lock:
    if outcontrato.movseq = 0  
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "CONTRATO TOTAL GERAL"
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "CONTRATO TOTAL GERAL".
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 10
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NORMAL" AND
               tt-outcontrato.tipo3 = "" AND
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NORMAL".
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
                            
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 20
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NORMAL" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NORMAL".
            tt-outcontrato.tipo3 = outcontrato.modcod.
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 30
    THEN DO:
        
        if outcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NORMAL" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = vdest
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NORMAL".
            tt-outcontrato.tipo3 = outcontrato.modcod.
            tt-outcontrato.tipo4 = vdest.

        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    
    /*** novação **/
    if outcontrato.movseq = 15
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NOVACAO" AND
               tt-outcontrato.tipo3 = "" AND
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NOVACAO".
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 25
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NOVACAO" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NOVACAO".
            tt-outcontrato.tipo3 = outcontrato.modcod.
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 35
    THEN DO:
        if outcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO NOVACAO" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = vdest
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO NOVACAO".
            tt-outcontrato.tipo3 = outcontrato.modcod.
            tt-outcontrato.tipo4 = vdest.

        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
        
    end.
    /** contrato outros ***/
    if outcontrato.movseq = 16
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO OUTROS" AND
               tt-outcontrato.tipo3 = "" AND
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO OUTROS".
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 26
    THEN DO:
        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO OUTROS" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = ""
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO OUTROS".
            tt-outcontrato.tipo3 = outcontrato.modcod.
        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 36
    THEN DO:
        if outcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outcontrato where
               tt-outcontrato.tipo1 = "" and
               tt-outcontrato.tipo2 = "CONTRATO OUTROS" and
               tt-outcontrato.tipo3 = outcontrato.modcod and
               tt-outcontrato.tipo4 = vdest
               no-error.
        if not avail tt-outcontrato
        then do:
            create tt-outcontrato.
            tt-outcontrato.tipo1 = "".
            tt-outcontrato.tipo2 = "CONTRATO OUTROS".
            tt-outcontrato.tipo3 = outcontrato.modcod.
            tt-outcontrato.tipo4 = vdest.

        end.
        assign
            tt-outcontrato.vlcontrato = tt-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            tt-outcontrato.vlentrada  = tt-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            tt-outcontrato.vlprincipal = tt-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            tt-outcontrato.vlacrescimo = tt-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            tt-outcontrato.vlseguro    = tt-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            tt-outcontrato.vlorigem    = tt-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            tt-outcontrato.vlorifin    = tt-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            tt-outcontrato.vlorileb    = tt-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            tt-outcontrato.vlabate     = tt-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if tt-outcontrato.vlabate < 0
        then tt-outcontrato.vlabate = 0.
        
    end.  
end.
for each outcontrato where outcontrato.tipo = "ESTORNO FINANCEIRA" and
                           outcontrato.datref = vdata and
                           outcontrato.etbcod = estab.etbcod
                           no-lock:
    if outcontrato.movseq = 0  
    THEN DO:
        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "CONTRATO TOTAL GERAL"
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "CONTRATO TOTAL GERAL".
        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
            .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
    end.
    if outcontrato.movseq = 10
    THEN DO:
        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NORMAL" AND
               esf-outcontrato.tipo3 = "" AND
               esf-outcontrato.tipo4 = ""
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NORMAL".
        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 20
    THEN DO:
        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NORMAL" and
               esf-outcontrato.tipo3 = outcontrato.modcod and
               esf-outcontrato.tipo4 = ""
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NORMAL".
            esf-outcontrato.tipo3 = outcontrato.modcod.
        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 30
    THEN DO:
        if outcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NORMAL" and
               esf-outcontrato.tipo3 = outcontrato.modcod and
               esf-outcontrato.tipo4 = vdest
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NORMAL".
            esf-outcontrato.tipo3 = outcontrato.modcod.
            esf-outcontrato.tipo4 = vdest.

        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
    end.
    
    /*** novação **/
    if outcontrato.movseq = 15
    THEN DO:
        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NOVACAO" AND
               esf-outcontrato.tipo3 = "" AND
               esf-outcontrato.tipo4 = ""
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NOVACAO".
        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 25
    THEN DO:
        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NOVACAO" and
               esf-outcontrato.tipo3 = outcontrato.modcod and
               esf-outcontrato.tipo4 = ""
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NOVACAO".
            esf-outcontrato.tipo3 = outcontrato.modcod.
        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
        
    end.
    if outcontrato.movseq = 35
    THEN DO:
        if outcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first esf-outcontrato where
               esf-outcontrato.tipo1 = "" and
               esf-outcontrato.tipo2 = "CONTRATO NOVACAO" and
               esf-outcontrato.tipo3 = outcontrato.modcod and
               esf-outcontrato.tipo4 = vdest
               no-error.
        if not avail esf-outcontrato
        then do:
            create esf-outcontrato.
            esf-outcontrato.tipo1 = "".
            esf-outcontrato.tipo2 = "CONTRATO NOVACAO".
            esf-outcontrato.tipo3 = outcontrato.modcod.
            esf-outcontrato.tipo4 = vdest.

        end.
        assign
            esf-outcontrato.vlcontrato = esf-outcontrato.vlcontrato +
                                        outcontrato.vlcontrato
            esf-outcontrato.vlentrada  = esf-outcontrato.vlentrada +
                                        outcontrato.vlentrada
            esf-outcontrato.vlprincipal = esf-outcontrato.vlprincipal +
                                        outcontrato.vlprincipal
            esf-outcontrato.vlacrescimo = esf-outcontrato.vlacrescimo +
                                        outcontrato.vlacrescimo
            esf-outcontrato.vlseguro    = esf-outcontrato.vlseguro +
                                        outcontrato.vlseguro
            esf-outcontrato.vlorigem    = esf-outcontrato.vlorigem +
                                        outcontrato.vlorigem
            esf-outcontrato.vlorifin    = esf-outcontrato.vlorifin +
                                        outcontrato.vlorifin
            esf-outcontrato.vlorileb    = esf-outcontrato.vlorileb +
                                        outcontrato.vlorileb
            esf-outcontrato.vlabate     = esf-outcontrato.vlabate +
                                        outcontrato.vlabate
             .
        if esf-outcontrato.vlabate < 0
        then esf-outcontrato.vlabate = 0.
    end. 
end.
end.

if vindex = 1 or vindex = 4
then
for each outrecebe where outrecebe.tipo = "RECEBIMENTO" and
                         outrecebe.datref = vdata  and
                         outrecebe.etbcod = estab.etbcod
                         no-lock:
    if outrecebe.movseq = 0
    then do:
        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "RECEBIMENTO TOTAL"
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "RECEBIMENTO TOTAL".
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 10 and outrecebe.cobcod = ? 
    then do:
        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "" and
                   tt-outrecebe.tipo4 = ""
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 20 and outrecebe.moeda = ?
    then do:
        if outrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "ENTRADA " + vdest  and
                   tt-outrecebe.tipo4 = ""
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "ENTRADA " + vdest.
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 20 and outrecebe.moeda <> ?
    then do:
        if outrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "ENTRADA " + vdest  and
                   tt-outrecebe.tipo4 = outrecebe.moeda
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "ENTRADA " + vdest.
            tt-outrecebe.tipo4 = outrecebe.moeda.
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 30 and outrecebe.moeda = ?
    then do:
        if outrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".
 
        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "PARCELA " + vdest and
                   tt-outrecebe.tipo4 = ""
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "PARCELA " + vdest.
            tt-outrecebe.tipo4 = "" .
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 30 and outrecebe.moeda <> ?
    then do:
        if outrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if outrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

         find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "PARCELA " + vdest  and
                   tt-outrecebe.tipo4 = outrecebe.moeda
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "PARCELA " + vdest.
            tt-outrecebe.tipo4 = outrecebe.moeda.
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 50 and outrecebe.moeda = ?
    then do:
        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = ""  and 
                   tt-outrecebe.tipo4 = ""
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "".
            tt-outrecebe.tipo4 = "".
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.
    if outrecebe.movseq = 51 and outrecebe.moeda <> ?
    then do:
        find first tt-outrecebe where 
                   tt-outrecebe.tipo1 = "" and
                   tt-outrecebe.tipo2 = outrecebe.modcod and
                   tt-outrecebe.tipo3 = "VENDA A VISTA" and
                   tt-outrecebe.tipo4 = outrecebe.moeda
                    no-error.
        if not avail tt-outrecebe
        then do:
            create tt-outrecebe.
            tt-outrecebe.tipo1 = "" .
            tt-outrecebe.tipo2 = outrecebe.modcod .
            tt-outrecebe.tipo3 = "VENDA A VISTA" .
            tt-outrecebe.tipo4 = outrecebe.moeda.
        end.                        
        assign
            tt-outrecebe.vlparcela = tt-outrecebe.vlparcela +
                                       outrecebe.vlparcela
            tt-outrecebe.vlpago   = tt-outrecebe.vlpago +
                                       outrecebe.vlpago
            tt-outrecebe.vlprincipal = tt-outrecebe.vlprincipal +
                                         outrecebe.vlprincipal
            tt-outrecebe.vlacrescimo = tt-outrecebe.vlacrescimo +
                                         outrecebe.vlacrescimo
            tt-outrecebe.vlseguro    = tt-outrecebe.vlseguro +
                                         outrecebe.vlseguro
            tt-outrecebe.vljuro      = tt-outrecebe.vljuro +
                                         outrecebe.vljuro
            .
    end.

end.
end.        
end.
                            
                            
def var varquivo as char.
varquivo = "/admcom/relat/res-teste.cl".
output to value(varquivo).
disp with frame f1.
disp "Reltorio" vesc[vindex] with no-label. 

for each tt-outvenda:
    disp tt-outvenda.tipo1 when tt-outvenda.tipo2 = "" 
                            column-label "VENDA"
         tt-outvenda.tipo2 when tt-outvenda.tipo3 = "" 
                            column-label "Tipo"
         tt-outvenda.tipo3 when tt-outvenda.tipo4 = "" 
                            column-label ""
         tt-outvenda.tipo4  column-label "Produto"                                    tt-outvenda.vlmercadoria
         tt-outvenda.vlservico
         tt-outvenda.vloutras
         tt-outvenda.vltotal
         with frame f-ff down width 200.
    down with frame f-ff.     

end.
put skip(2).
for each vol-outvenda:
    disp vol-outvenda.tipo1 when vol-outvenda.tipo2 = "" 
                            column-label "VENDA OUTRA LOJA"
         vol-outvenda.tipo2 when vol-outvenda.tipo3 = "" 
                            column-label "Tipo"
         vol-outvenda.tipo3 when vol-outvenda.tipo4 = "" 
                            column-label ""
         vol-outvenda.tipo4 column-label "Produto"
         vol-outvenda.vlmercadoria
         vol-outvenda.vlservico
         vol-outvenda.vloutras
         vol-outvenda.vltotal
         with frame f-ff3 down width 200.
    down with frame f-ff3.     

end.
put skip(2).
for each vor-outvenda:
    disp vor-outvenda.tipo1 when vor-outvenda.tipo2 = "" 
                            column-label "VENDA RETIRADA"
         vor-outvenda.tipo2 when vor-outvenda.tipo4 = "" 
                            column-label "Tipo"
         vor-outvenda.tipo3 when vor-outvenda.tipo4 = "" 
                            column-label ""
         vor-outvenda.tipo4 column-label "Produto"
         vor-outvenda.vlmercadoria
         vor-outvenda.vlservico
         vor-outvenda.vloutras
         vor-outvenda.vltotal
         with frame f-ff2 down width 200.
    down with frame f-ff2.     

end.
put skip(2).
for each dv-outvenda:
    disp dv-outvenda.tipo1 when dv-outvenda.tipo2 = "" 
                            column-label "DEVOLUCAO VENDA"
         dv-outvenda.tipo2 when dv-outvenda.tipo3 = "" 
                            column-label "Tipo"
         dv-outvenda.tipo3 when dv-outvenda.tipo4 = "" 
                            column-label ""
         dv-outvenda.tipo4  column-label "Produto" no-label
         dv-outvenda.valorigem
         dv-outvenda.valfrete
         dv-outvenda.vlservico
         dv-outvenda.vloutras
         dv-outvenda.vlmercadoria
         dv-outvenda.vlcontrato
         dv-outvenda.vlprincipal
         dv-outvenda.vlacrescimo
         dv-outvenda.vlseguro
         dv-outvenda.vlquitado
         dv-outvenda.vldevolvido
         with frame f-ff1 down width 230.
    down with frame f-ff1.     

end.
put skip(2). 
put "C O N T R A T O" skip.
form tt-outcontrato.tipo2 with frame f-fc.
for each tt-outcontrato where 
            tt-outcontrato.tipo1 <> "CONTRATO TOTAL GERAL":
    disp /*tt-outcontrato.tipo1 when tt-outcontrato.tipo2 = ""
                                    column-label "CONTRATO"*/
         tt-outcontrato.tipo2 when tt-outcontrato.tipo3 = ""
                                    column-label "Tipo"
         tt-outcontrato.tipo3 when tt-outcontrato.tipo4 = "" 
                                    column-label "Modalidade"
         tt-outcontrato.tipo4       column-label "Local"    
         tt-outcontrato.vlcontrato      format ">>>,>>>,>>9.99"
         tt-outcontrato.vlentrada       format ">,>>>,>>9.99"
         tt-outcontrato.vlprincipal     format ">>>,>>>,>>9.99"
         tt-outcontrato.vlacrescimo     format ">>,>>>,>>9.99"
         tt-outcontrato.vlabate         format ">>>,>>9.99"
         tt-outcontrato.vlseguro        format ">,>>>,>>9.99"
         tt-outcontrato.vlorigem        format ">>,>>>,>>9.99"
         tt-outcontrato.vlorifin        format ">,>>>,>>9.99"
         tt-outcontrato.vlorileb        format ">,>>>,>>9.99"
         with frame f-fc down width 200.
    down with frame f-fc.
end.
put skip.
for each tt-outcontrato where 
            tt-outcontrato.tipo1 = "CONTRATO TOTAL GERAL":
    disp "CONTRATO TOTAL" @ tt-outcontrato.tipo2 
         tt-outcontrato.vlcontrato      format ">>>,>>>,>>9.99"
         tt-outcontrato.vlentrada       format ">,>>>,>>9.99"
         tt-outcontrato.vlprincipal     format ">>>,>>>,>>9.99"
         tt-outcontrato.vlacrescimo     format ">>,>>>,>>9.99"
         tt-outcontrato.vlseguro        format ">,>>>,>>9.99"
         tt-outcontrato.vlabate         format ">>>,>>9.99"
         tt-outcontrato.vlorigem        format ">>,>>>,>>9.99"
         tt-outcontrato.vlorifin        format ">,>>>,>>9.99"
         tt-outcontrato.vlorileb        format ">,>>>,>>9.99"
         with frame f-fc down width 200.
    down with frame f-fc.
end.

put skip(2). 
put "ESTORNO FINANCEIRA" skip.
form with frame f-fce1.
for each esf-outcontrato where
         esf-outcontrato.tipo1 <> "CONTRATO TOTAL GERAL":
    disp /*esf-outcontrato.tipo1 when esf-outcontrato.tipo2 = ""
                                    column-label "ESTORNO FINANCEIRA"*/
         esf-outcontrato.tipo2 when esf-outcontrato.tipo3 = ""
                                    column-label "Tipo"
         esf-outcontrato.tipo3 when esf-outcontrato.tipo4 = "" 
                                    column-label "Modalidade"
         esf-outcontrato.tipo4       column-label "Local" 
         esf-outcontrato.vlcontrato   format ">>>,>>>,>>9.99"
         esf-outcontrato.vlentrada    format ">,>>>,>>9.99"
         esf-outcontrato.vlprincipal  format ">>,>>>,>>9.99"
         esf-outcontrato.vlacrescimo  format ">>,>>>,>>9.99"
         esf-outcontrato.vlseguro     format ">,>>>,>>9.99"
         esf-outcontrato.vlabate      format ">>>,>>9.99"
         esf-outcontrato.vlorigem     format ">,>>>,>>9.99"
         esf-outcontrato.vlorifin     format ">,>>>,>>9.99"
         esf-outcontrato.vlorileb     format ">,>>>,>>9.99"
         with frame f-fce1 down width 200.
    down with frame f-fce1.
end.
for each esf-outcontrato where
         esf-outcontrato.tipo1 = "CONTRATO TOTAL GERAL":
    disp "ESTORNO TOTAL" @ esf-outcontrato.tipo2
         esf-outcontrato.vlcontrato   format ">>>,>>>,>>9.99"
         esf-outcontrato.vlentrada    format ">,>>>,>>9.99"
         esf-outcontrato.vlprincipal  format ">>,>>>,>>9.99"
         esf-outcontrato.vlacrescimo  format ">>,>>>,>>9.99"
         esf-outcontrato.vlseguro     format ">,>>>,>>9.99"
         esf-outcontrato.vlabate      format ">>>,>>9.99"
         esf-outcontrato.vlorigem     format ">,>>>,>>9.99"
         esf-outcontrato.vlorifin     format ">,>>>,>>9.99"
         esf-outcontrato.vlorileb     format ">,>>>,>>9.99"
         with frame f-fce1 down width 200.
    down with frame f-fce1.
end. 
     
put skip(2).
for each tt-outrecebe:
    disp tt-outrecebe.tipo1 when tt-outrecebe.tipo2 = "" 
                            column-label "RECEBIMENTO"
         tt-outrecebe.tipo2 when tt-outrecebe.tipo3 = "" 
                            column-label "Modalidade"  format "x(12)"
         tt-outrecebe.tipo3 when (tt-outrecebe.tipo4 = "" or
                                 tt-outrecebe.tipo4 = "EMISSAO" or
                                 tt-outrecebe.tipo4 = "NOVACAO")
                            column-label "Tipo"        format "x(18)"
         tt-outrecebe.tipo4                              
                            column-label "Moeda"
         tt-outrecebe.vlparcela   format ">>>,>>>,>>9.99"
         tt-outrecebe.vlpago      format ">>>,>>>,>>9.99"
         tt-outrecebe.vlprincipal format ">>>,>>>,>>9.99"
         tt-outrecebe.vlacrescimo format ">>,>>>,>>9.99"
         tt-outrecebe.vljuro      format ">,>>>,>>9.99"
         tt-outrecebe.vlseguro    format ">,>>>,>>9.99"
         with width 200.
end.    

/*******
for each dt-outvenda where dt-outvenda.emite > 0:
    disp dt-outvenda.emite
         dt-outvenda.serie
         dt-outvenda.numero
         dt-outvenda.pladat
         dt-outvenda.chave
         dt-outvenda.vlmercadoria
         dt-outvenda.vlservico
         dt-outvenda.vltotal - dt-outvenda.vloutras
         with frame f-doc down width 200.
end.
******/

output close.

run visurel.p(varquivo,"").

end.

