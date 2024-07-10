{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.
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

def temp-table tt-ctbcontrato
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

def temp-table esf-ctbcontrato
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
     
def temp-table tt-ctbrecebe
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
      
def temp-table tt-ctbvenda
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
    
def temp-table vol-ctbvenda
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
    
def temp-table vor-ctbvenda
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

def temp-table dv-ctbvenda
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
    field vlprincipal as dec   format ">>,>>>,>>9.99"
    field vlacrescimo as dec   format ">,>>>,>>9.99"
    field vlseguro as dec      format ">,>>>,>>9.99"
    field vlquitado as dec     format ">>,>>>,>>9.99"
    field vldevolvido as dec   format ">>,>>>,>>9.99"
    index i1 tipo1 tipo2 tipo3 tipo4
    .

def temp-table dt-ctbvenda
    field emite like 
    ctbvenda.emite
    field serie like ctbvenda.serie
    field numero like ctbvenda.numero
    field pladat like plani.pladat
    field chave  like ctbvenda.chave
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
for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if ctbvenda.movseq = 20 
    then do:
        find first tt-ctbvenda where
                   tt-ctbvenda.tipo1 = "VENDA TOTAL" and
                   tt-ctbvenda.tipo2 = "" and
                   tt-ctbvenda.tipo3 = "" and
                   tt-ctbvenda.tipo4 = ""
                   no-error.
        if not avail tt-ctbvenda
        then do:
            create tt-ctbvenda.  
            assign
                tt-ctbvenda.tipo1 = "VENDA TOTAL" 
                 .
        end.
        assign
            tt-ctbvenda.vlmercadoria = tt-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            tt-ctbvenda.vlservico    = tt-ctbvenda.vlservico +
                                          ctbvenda.servico
            tt-ctbvenda.vloutras     = tt-ctbvenda.vloutras +
                                          ctbvenda.outras
            tt-ctbvenda.vltotal       = tt-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +                         ctbvenda.outras
            .                              
    end.
    if ctbvenda.movseq = 30
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        
        if ctbvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbvenda where
                   tt-ctbvenda.tipo1 = "" and
                   tt-ctbvenda.tipo2 = char-crecod and
                   tt-ctbvenda.tipo3 = "" and
                   tt-ctbvenda.tipo4 = ""
                   no-error.
        if not avail tt-ctbvenda
        then do:
            create tt-ctbvenda.  
            assign
                tt-ctbvenda.tipo1 = "" 
                tt-ctbvenda.tipo2 = char-crecod
                tt-ctbvenda.tipo3 = ""
                tt-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            tt-ctbvenda.vlmercadoria = tt-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            tt-ctbvenda.vlservico    = tt-ctbvenda.vlservico +
                                          ctbvenda.servico
            tt-ctbvenda.vloutras     = tt-ctbvenda.vloutras +
                                          ctbvenda.outras
            tt-ctbvenda.vltotal       = tt-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
             .
        find first tt-ctbvenda where
                   tt-ctbvenda.tipo1 = "" and
                   tt-ctbvenda.tipo2 = char-crecod and
                   tt-ctbvenda.tipo3 = vdest and
                   tt-ctbvenda.tipo4 = ""
                   no-error.
        if not avail tt-ctbvenda
        then do:
            create tt-ctbvenda.  
            assign
                tt-ctbvenda.tipo1 = "" 
                tt-ctbvenda.tipo2 = char-crecod
                tt-ctbvenda.tipo3 = vdest
                tt-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            tt-ctbvenda.vlmercadoria = tt-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            tt-ctbvenda.vlservico    = tt-ctbvenda.vlservico +
                                          ctbvenda.servico
            tt-ctbvenda.vloutras     = tt-ctbvenda.vloutras +
                                          ctbvenda.outras
            tt-ctbvenda.vltotal       = tt-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
             .                                        
    end.
    if ctbvenda.movseq = 35
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if ctbvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbvenda where
                   tt-ctbvenda.tipo1 = "" and
                   tt-ctbvenda.tipo2 = char-crecod and
                   tt-ctbvenda.tipo3 = vdest  and
                   tt-ctbvenda.tipo4 = ctbvenda.produto
                   no-error.
        if not avail tt-ctbvenda
        then do:
            create tt-ctbvenda.  
            assign
                tt-ctbvenda.tipo1 = "" 
                tt-ctbvenda.tipo2 = char-crecod
                tt-ctbvenda.tipo3 = vdest
                tt-ctbvenda.tipo4 = ctbvenda.produto
                 .
        end.
        assign
            tt-ctbvenda.vlmercadoria = tt-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            tt-ctbvenda.vlservico    = tt-ctbvenda.vlservico +
                                          ctbvenda.servico
            tt-ctbvenda.vloutras     = tt-ctbvenda.vloutras +
                                          ctbvenda.outras
            tt-ctbvenda.vltotal       = tt-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +  
                             ctbvenda.outras

     
            .                              
    end.
    end.
    
end.
for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if ctbvenda.movseq = 20 
    then do:
        find first vol-ctbvenda where
                   vol-ctbvenda.tipo1 = "VENDA TOTAL" and
                   vol-ctbvenda.tipo2 = "" and
                   vol-ctbvenda.tipo3 = "" and
                   vol-ctbvenda.tipo4 = ""
                   no-error.
        if not avail vol-ctbvenda
        then do:
            create vol-ctbvenda.  
            assign
                vol-ctbvenda.tipo1 = "VENDA TOTAL" 
                 .
        end.
        assign
            vol-ctbvenda.vlmercadoria = vol-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vol-ctbvenda.vlservico    = vol-ctbvenda.vlservico +
                                          ctbvenda.servico
            vol-ctbvenda.vloutras     = vol-ctbvenda.vloutras +
                                          ctbvenda.outras
            vol-ctbvenda.vltotal       = vol-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico + 
                                      ctbvenda.outras
            .                              
    end.
    if ctbvenda.movseq = 30
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if ctbvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first vol-ctbvenda where
                   vol-ctbvenda.tipo1 = "" and
                   vol-ctbvenda.tipo2 = char-crecod and
                   vol-ctbvenda.tipo3 = "" and
                   vol-ctbvenda.tipo4 = ""
                   no-error.
        if not avail vol-ctbvenda
        then do:
            create vol-ctbvenda.  
            assign
                vol-ctbvenda.tipo1 = "" 
                vol-ctbvenda.tipo2 = char-crecod
                vol-ctbvenda.tipo3 = ""
                vol-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            vol-ctbvenda.vlmercadoria = vol-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vol-ctbvenda.vlservico    = vol-ctbvenda.vlservico +
                                          ctbvenda.servico
            vol-ctbvenda.vloutras     = vol-ctbvenda.vloutras +
                                          ctbvenda.outras
            vol-ctbvenda.vltotal       = vol-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
             .
        find first vol-ctbvenda where
                   vol-ctbvenda.tipo1 = "" and
                   vol-ctbvenda.tipo2 = char-crecod and
                   vol-ctbvenda.tipo3 = vdest and
                   vol-ctbvenda.tipo4 = ""
                   no-error.
        if not avail vol-ctbvenda
        then do:
            create vol-ctbvenda.  
            assign
                vol-ctbvenda.tipo1 = "" 
                vol-ctbvenda.tipo2 = char-crecod
                vol-ctbvenda.tipo3 = vdest
                vol-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            vol-ctbvenda.vlmercadoria = vol-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vol-ctbvenda.vlservico    = vol-ctbvenda.vlservico +
                                          ctbvenda.servico
            vol-ctbvenda.vloutras     = vol-ctbvenda.vloutras +
                                          ctbvenda.outras
            vol-ctbvenda.vltotal       = vol-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
             .                                        
    end.
    if ctbvenda.movseq = 35
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".

        if ctbvenda.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbvenda.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first vol-ctbvenda where
                   vol-ctbvenda.tipo1 = "" and
                   vol-ctbvenda.tipo2 = char-crecod and
                   vol-ctbvenda.tipo3 = vdest and
                   vol-ctbvenda.tipo4 = ctbvenda.produto
                   no-error.
        if not avail vol-ctbvenda
        then do:
            create vol-ctbvenda.  
            assign
                vol-ctbvenda.tipo1 = "" 
                vol-ctbvenda.tipo2 = char-crecod
                vol-ctbvenda.tipo3 = vdest
                vol-ctbvenda.tipo4 = ctbvenda.produto
                 .
        end.
        assign
            vol-ctbvenda.vlmercadoria = vol-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vol-ctbvenda.vlservico    = vol-ctbvenda.vlservico +
                                          ctbvenda.servico
            vol-ctbvenda.vloutras     = vol-ctbvenda.vloutras +
                                          ctbvenda.outras
            vol-ctbvenda.vltotal       = vol-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +  
                             ctbvenda.outras
            .                              
    end.
    end.
end.

for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA RETIRADA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
    if ctbvenda.movseq = 20 
    then do:
        find first vor-ctbvenda where
                   vor-ctbvenda.tipo1 = "VENDA TOTAL" and
                   vor-ctbvenda.tipo2 = "" and
                   vor-ctbvenda.tipo3 = "" and
                   vor-ctbvenda.tipo4 = ""
                   no-error.
        if not avail vor-ctbvenda
        then do:
            create vor-ctbvenda.  
            assign
                vor-ctbvenda.tipo1 = "VENDA TOTAL" 
                vor-ctbvenda.tipo2 = ""
                vor-ctbvenda.tipo3 = ""
                vor-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            vor-ctbvenda.vlmercadoria = vor-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vor-ctbvenda.vlservico    = vor-ctbvenda.vlservico +
                                          ctbvenda.servico
            vor-ctbvenda.vloutras     = vor-ctbvenda.vloutras +
                                          ctbvenda.outras
            vor-ctbvenda.vltotal       = vor-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico + 
                                      ctbvenda.outras
            .                              
    end.
    if ctbvenda.movseq = 30
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        find first vor-ctbvenda where
                   vor-ctbvenda.tipo1 = "" and
                   vor-ctbvenda.tipo2 = char-crecod and
                   vor-ctbvenda.tipo3 = "" and
                   vor-ctbvenda.tipo4 = ""
                   no-error.
        if not avail vor-ctbvenda
        then do:
            create vor-ctbvenda.  
            assign
                vor-ctbvenda.tipo1 = "" 
                vor-ctbvenda.tipo2 = char-crecod
                vor-ctbvenda.tipo3 = ""
                vor-ctbvenda.tipo4 = ""
                 .
        end.
        assign
            vor-ctbvenda.vlmercadoria = vor-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vor-ctbvenda.vlservico    = vor-ctbvenda.vlservico +
                                          ctbvenda.servico
            vor-ctbvenda.vloutras     = vor-ctbvenda.vloutras +
                                          ctbvenda.outras
            vor-ctbvenda.vltotal       = vor-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
             .                              
    end.
    if ctbvenda.movseq = 35
    then do:
        if ctbvenda.crecod = 1
        then char-crecod = "VENDA A VISTA".
        else char-crecod = "VENDA A PRAZO".
        find first vor-ctbvenda where
                   vor-ctbvenda.tipo1 = "" and
                   vor-ctbvenda.tipo2 = char-crecod and
                   vor-ctbvenda.tipo3 = "" and
                   vor-ctbvenda.tipo4 = ctbvenda.produto
                   no-error.
        if not avail vor-ctbvenda
        then do:
            create vor-ctbvenda.  
            assign
                vor-ctbvenda.tipo1 = "" 
                vor-ctbvenda.tipo2 = char-crecod
                vor-ctbvenda.tipo3 = ""
                vor-ctbvenda.tipo4 = ctbvenda.produto
                 .
        end.
        assign
            vor-ctbvenda.vlmercadoria = vor-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
            vor-ctbvenda.vlservico    = vor-ctbvenda.vlservico +
                                          ctbvenda.servico
            vor-ctbvenda.vloutras     = vor-ctbvenda.vloutras +
                                          ctbvenda.outras
            vor-ctbvenda.vltotal       = vor-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +  
                             ctbvenda.outras
            .                              
    end.
    end.
end.

for each ctbvenda where ctbvenda.tipo = "DEVOLUCAO VENDA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod
                        no-lock:
    if vindex <> 3
    then do:
        if ctbvenda.movseq = 100
        then do:
            find first dv-ctbvenda where
                   dv-ctbvenda.tipo1 = "DEVOLUCAO TOTAL" and
                   dv-ctbvenda.tipo2 = "" and
                   dv-ctbvenda.tipo3 = "" and
                   dv-ctbvenda.tipo4 = ""
                   no-error.
            if not avail dv-ctbvenda
            then do:
                create dv-ctbvenda.  
                assign
                    dv-ctbvenda.tipo1 = "DEVOLUCAO TOTAL" 
                    .
            end.
            assign
                dv-ctbvenda.valorigem = dv-ctbvenda.valorigem +
                                        ctbvenda.valorigem
                dv-ctbvenda.valfrete  = dv-ctbvenda.valfrete +
                                        ctbvenda.valfrete
                dv-ctbvenda.vlmercadoria = dv-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
                dv-ctbvenda.vlservico    = dv-ctbvenda.vlservico +
                                          ctbvenda.servico
                dv-ctbvenda.vloutras     = dv-ctbvenda.vloutras +
                                          ctbvenda.outras
                dv-ctbvenda.vltotal       = dv-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico + 
                                          ctbvenda.outras
                dv-ctbvenda.vlcontrato    = dv-ctbvenda.vlcontrato +
                                                ctbvenda.valcontrato
                dv-ctbvenda.vlprincipal   = dv-ctbvenda.vlprincipal +
                                            ctbvenda.valprincipal
                dv-ctbvenda.vlacrescimo   = dv-ctbvenda.vlacrescimo +
                                            ctbvenda.valacrescimo
                dv-ctbvenda.vlseguro      = dv-ctbvenda.vlseguro +
                                            ctbvenda.valseguro
                dv-ctbvenda.vlquitado  = dv-ctbvenda.vlquitado +
                              ctbvenda.valquitado.
                dv-ctbvenda.vldevolvido = dv-ctbvenda.vldevolvido +
                              ctbvenda.valdevolvido
                .                              
        end.
        else if ctbvenda.movseq = 200
        then do:
            if ctbvenda.crecod = 1
            then char-crecod = "DEVOLUCAO VISTA".
            else char-crecod = "DEVOLUCAO PRAZO".

            if ctbvenda.cobcod = 200
            then vdest = "ECOMMERCE".
            else if ctbvenda.cobcod = 10
                then vdest = "FINANCEIRA".
                else if ctbvenda.cobcod = 14
                    then vdest = "FIDC".
                    else vdest = "LEBES".

            find first dv-ctbvenda where
                   dv-ctbvenda.tipo1 = "" and
                   dv-ctbvenda.tipo2 = char-crecod and
                   dv-ctbvenda.tipo3 = "" and
                   dv-ctbvenda.tipo4 = ""
                   no-error.
            if not avail dv-ctbvenda
            then do:
                create dv-ctbvenda.  
                assign
                    dv-ctbvenda.tipo1 = "" 
                    dv-ctbvenda.tipo2 = char-crecod
                    dv-ctbvenda.tipo3 = ""
                    .
            end.
            assign
                dv-ctbvenda.valorigem = dv-ctbvenda.valorigem +
                                        ctbvenda.valorigem
                dv-ctbvenda.valfrete  = dv-ctbvenda.valfrete +
                                        ctbvenda.valfrete
                dv-ctbvenda.vlmercadoria = dv-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
                dv-ctbvenda.vlservico    = dv-ctbvenda.vlservico +
                                          ctbvenda.servico
                dv-ctbvenda.vloutras     = dv-ctbvenda.vloutras +
                                          ctbvenda.outras
                dv-ctbvenda.vltotal       = dv-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
                dv-ctbvenda.vlcontrato    = dv-ctbvenda.vlcontrato +
                                            ctbvenda.valcontrato
                dv-ctbvenda.vlprincipal   = dv-ctbvenda.vlprincipal +
                                            ctbvenda.valprincipal
                dv-ctbvenda.vlacrescimo   = dv-ctbvenda.vlacrescimo +
                                            ctbvenda.valacrescimo
                dv-ctbvenda.vlseguro      = dv-ctbvenda.vlseguro +
                                            ctbvenda.valseguro
                dv-ctbvenda.vlquitado  = dv-ctbvenda.vlquitado +
                              ctbvenda.valquitado.
                dv-ctbvenda.vldevolvido = dv-ctbvenda.vldevolvido +
                              ctbvenda.valdevolvido
                . 
                
            find first dv-ctbvenda where
                   dv-ctbvenda.tipo1 = "" and
                   dv-ctbvenda.tipo2 = char-crecod and
                   dv-ctbvenda.tipo3 = vdest and
                   dv-ctbvenda.tipo4 = ""
                   no-error.
            if not avail dv-ctbvenda
            then do:
                create dv-ctbvenda.  
                assign
                    dv-ctbvenda.tipo1 = "" 
                    dv-ctbvenda.tipo2 = char-crecod
                    dv-ctbvenda.tipo3 = vdest
                    .
            end.
            assign
                dv-ctbvenda.valorigem = dv-ctbvenda.valorigem +
                                        ctbvenda.valorigem
                dv-ctbvenda.valfrete  = dv-ctbvenda.valfrete +
                                        ctbvenda.valfrete
                dv-ctbvenda.vlmercadoria = dv-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
                dv-ctbvenda.vlservico    = dv-ctbvenda.vlservico +
                                          ctbvenda.servico
                dv-ctbvenda.vloutras     = dv-ctbvenda.vloutras +
                                          ctbvenda.outras
                dv-ctbvenda.vltotal       = dv-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
                dv-ctbvenda.vlcontrato    = dv-ctbvenda.vlcontrato +
                                            ctbvenda.valcontrato
                dv-ctbvenda.vlprincipal   = dv-ctbvenda.vlprincipal +
                                            ctbvenda.valprincipal
                dv-ctbvenda.vlacrescimo   = dv-ctbvenda.vlacrescimo +
                                            ctbvenda.valacrescimo
                dv-ctbvenda.vlseguro      = dv-ctbvenda.vlseguro +
                                            ctbvenda.valseguro
                dv-ctbvenda.vlquitado  = dv-ctbvenda.vlquitado +
                              ctbvenda.valquitado.
                dv-ctbvenda.vldevolvido = dv-ctbvenda.vldevolvido +
                              ctbvenda.valdevolvido
                .                                  
        end.
        else if ctbvenda.movseq = 221
        then do:
            if ctbvenda.crecod = 1
            then char-crecod = "DEVOLUCAO VISTA".
            else char-crecod = "DEVOLUCAO PRAZO".

            if ctbvenda.cobcod = 200
            then vdest = "ECOMMERCE".
            else if ctbvenda.cobcod = 10
                then vdest = "FINANCEIRA".
                else if ctbvenda.cobcod = 14
                    then vdest = "FIDC".
                    else vdest = "LEBES".

            find first dv-ctbvenda where
                   dv-ctbvenda.tipo1 = "" and
                   dv-ctbvenda.tipo2 = char-crecod and
                   dv-ctbvenda.tipo3 = vdest and
                   dv-ctbvenda.tipo4 = ctbvenda.produto
                   no-error.
            if not avail dv-ctbvenda
            then do:
                create dv-ctbvenda.  
                assign
                    dv-ctbvenda.tipo1 = "" 
                    dv-ctbvenda.tipo2 = char-crecod
                    dv-ctbvenda.tipo3 = vdest
                    dv-ctbvenda.tipo4 = ctbvenda.produto
                    .
            end.
            assign
                dv-ctbvenda.valorigem = dv-ctbvenda.valorigem +
                                        ctbvenda.valorigem
                dv-ctbvenda.valfrete  = dv-ctbvenda.valfrete +
                                        ctbvenda.valfrete
                dv-ctbvenda.vlmercadoria = dv-ctbvenda.vlmercadoria +
                                          ctbvenda.mercadoria
                dv-ctbvenda.vlservico    = dv-ctbvenda.vlservico +
                                          ctbvenda.servico
                dv-ctbvenda.vloutras     = dv-ctbvenda.vloutras +
                                          ctbvenda.outras
                dv-ctbvenda.vltotal       = dv-ctbvenda.vltotal + 
                        ctbvenda.mercadoria + ctbvenda.servico +    
                           ctbvenda.outras
                dv-ctbvenda.vlcontrato    = dv-ctbvenda.vlcontrato +
                                            ctbvenda.valcontrato
                dv-ctbvenda.vlprincipal   = dv-ctbvenda.vlprincipal +
                                            ctbvenda.valprincipal
                dv-ctbvenda.vlacrescimo   = dv-ctbvenda.vlacrescimo +
                                            ctbvenda.valacrescimo
                dv-ctbvenda.vlseguro      = dv-ctbvenda.vlseguro +
                                            ctbvenda.valseguro
                dv-ctbvenda.vlquitado  = dv-ctbvenda.vlquitado +
                              ctbvenda.valquitado.
                dv-ctbvenda.vldevolvido = dv-ctbvenda.vldevolvido +
                              ctbvenda.valdevolvido
                .                                  
        end.
    end.

end.

end.
if vindex = 1 or vindex = 3 
then do:
for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod
                           no-lock:
    if ctbcontrato.movseq = 0  
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL"
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL".
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 10
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NORMAL" AND
               tt-ctbcontrato.tipo3 = "" AND
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NORMAL".
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
                            
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 20
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NORMAL" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NORMAL".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 30
    THEN DO:
        
        if ctbcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NORMAL" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = vdest
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NORMAL".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
            tt-ctbcontrato.tipo4 = vdest.

        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    
    /*** novação **/
    if ctbcontrato.movseq = 15
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO" AND
               tt-ctbcontrato.tipo3 = "" AND
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 25
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 35
    THEN DO:
        if ctbcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = vdest
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
            tt-ctbcontrato.tipo4 = vdest.

        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
        
    end.
    /** contrato outros ***/
    if ctbcontrato.movseq = 16   
    THEN DO:
        
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO OUTROS" AND
               tt-ctbcontrato.tipo3 = "" AND
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO OUTROS".
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 26
    THEN DO:
        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO OUTROS" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = ""
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO OUTROS".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
        
    end.
    if ctbcontrato.movseq = 36
    THEN DO:
        if ctbcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbcontrato where
               tt-ctbcontrato.tipo1 = "" and
               tt-ctbcontrato.tipo2 = "CONTRATO OUTROS" and
               tt-ctbcontrato.tipo3 = ctbcontrato.modcod and
               tt-ctbcontrato.tipo4 = vdest
               no-error.
        if not avail tt-ctbcontrato
        then do:
            create tt-ctbcontrato.
            tt-ctbcontrato.tipo1 = "".
            tt-ctbcontrato.tipo2 = "CONTRATO OUTROS".
            tt-ctbcontrato.tipo3 = ctbcontrato.modcod.
            tt-ctbcontrato.tipo4 = vdest.

        end.
        assign
            tt-ctbcontrato.vlcontrato = tt-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            tt-ctbcontrato.vlentrada  = tt-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            tt-ctbcontrato.vlprincipal = tt-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            tt-ctbcontrato.vlacrescimo = tt-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            tt-ctbcontrato.vlseguro    = tt-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            tt-ctbcontrato.vlorigem    = tt-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            tt-ctbcontrato.vlorifin    = tt-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            tt-ctbcontrato.vlorileb    = tt-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            tt-ctbcontrato.vlabate     = tt-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if tt-ctbcontrato.vlabate < 0
        then tt-ctbcontrato.vlabate = 0.
        
    end.  
end.
for each ctbcontrato where ctbcontrato.tipo = "ESTORNO FINANCEIRA" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod
                           no-lock:
    if ctbcontrato.movseq = 0  
    THEN DO:
        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL"
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL".
        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
            .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
    end.
    if ctbcontrato.movseq = 10
    THEN DO:
        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NORMAL" AND
               esf-ctbcontrato.tipo3 = "" AND
               esf-ctbcontrato.tipo4 = ""
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NORMAL".
        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
        
    end.
    if ctbcontrato.movseq = 20
    THEN DO:
        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NORMAL" and
               esf-ctbcontrato.tipo3 = ctbcontrato.modcod and
               esf-ctbcontrato.tipo4 = ""
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NORMAL".
            esf-ctbcontrato.tipo3 = ctbcontrato.modcod.
        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
        
    end.
    if ctbcontrato.movseq = 30
    THEN DO:
        if ctbcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NORMAL" and
               esf-ctbcontrato.tipo3 = ctbcontrato.modcod and
               esf-ctbcontrato.tipo4 = vdest
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NORMAL".
            esf-ctbcontrato.tipo3 = ctbcontrato.modcod.
            esf-ctbcontrato.tipo4 = vdest.

        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
    end.
    
    /*** novação **/
    if ctbcontrato.movseq = 15
    THEN DO:
        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO" AND
               esf-ctbcontrato.tipo3 = "" AND
               esf-ctbcontrato.tipo4 = ""
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
        
    end.
    if ctbcontrato.movseq = 25
    THEN DO:
        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO" and
               esf-ctbcontrato.tipo3 = ctbcontrato.modcod and
               esf-ctbcontrato.tipo4 = ""
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
            esf-ctbcontrato.tipo3 = ctbcontrato.modcod.
        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
        
    end.
    if ctbcontrato.movseq = 35
    THEN DO:
        if ctbcontrato.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbcontrato.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first esf-ctbcontrato where
               esf-ctbcontrato.tipo1 = "" and
               esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO" and
               esf-ctbcontrato.tipo3 = ctbcontrato.modcod and
               esf-ctbcontrato.tipo4 = vdest
               no-error.
        if not avail esf-ctbcontrato
        then do:
            create esf-ctbcontrato.
            esf-ctbcontrato.tipo1 = "".
            esf-ctbcontrato.tipo2 = "CONTRATO NOVACAO".
            esf-ctbcontrato.tipo3 = ctbcontrato.modcod.
            esf-ctbcontrato.tipo4 = vdest.

        end.
        assign
            esf-ctbcontrato.vlcontrato = esf-ctbcontrato.vlcontrato +
                                        ctbcontrato.vlcontrato
            esf-ctbcontrato.vlentrada  = esf-ctbcontrato.vlentrada +
                                        ctbcontrato.vlentrada
            esf-ctbcontrato.vlprincipal = esf-ctbcontrato.vlprincipal +
                                        ctbcontrato.vlprincipal
            esf-ctbcontrato.vlacrescimo = esf-ctbcontrato.vlacrescimo +
                                        ctbcontrato.vlacrescimo
            esf-ctbcontrato.vlseguro    = esf-ctbcontrato.vlseguro +
                                        ctbcontrato.vlseguro
            esf-ctbcontrato.vlorigem    = esf-ctbcontrato.vlorigem +
                                        ctbcontrato.vlorigem
            esf-ctbcontrato.vlorifin    = esf-ctbcontrato.vlorifin +
                                        ctbcontrato.vlorifin
            esf-ctbcontrato.vlorileb    = esf-ctbcontrato.vlorileb +
                                        ctbcontrato.vlorileb
            esf-ctbcontrato.vlabate     = esf-ctbcontrato.vlabate +
                                        ctbcontrato.vlabate
             .
        if esf-ctbcontrato.vlabate < 0
        then esf-ctbcontrato.vlabate = 0.
    end. 
end.
end.

if vindex = 1 or vindex = 4
then
for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod
                         no-lock:
    if ctbrecebe.movseq = 0
    then do:
        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "RECEBIMENTO TOTAL"
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "RECEBIMENTO TOTAL".
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 10 and ctbrecebe.cobcod = ? 
    then do:
        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "" and
                   tt-ctbrecebe.tipo4 = ""
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 20 and ctbrecebe.moeda = ?
    then do:
        if ctbrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "ENTRADA " + vdest  and
                   tt-ctbrecebe.tipo4 = ""
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "ENTRADA " + vdest.
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 20 and ctbrecebe.moeda <> ?
    then do:
        if ctbrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "ENTRADA " + vdest  and
                   tt-ctbrecebe.tipo4 = ctbrecebe.moeda
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "ENTRADA " + vdest.
            tt-ctbrecebe.tipo4 = ctbrecebe.moeda.
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 30 and ctbrecebe.moeda = ?
    then do:
        if ctbrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".
 
        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "PARCELA " + vdest and
                   tt-ctbrecebe.tipo4 = ""
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "PARCELA " + vdest.
            tt-ctbrecebe.tipo4 = "" .
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 30 and ctbrecebe.moeda <> ?
    then do:
        if ctbrecebe.cobcod = 10
        then vdest = "FINANCEIRA".
        else if ctbrecebe.cobcod = 14
            then vdest = "FIDC".
            else vdest = "LEBES".

         find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "PARCELA " + vdest  and
                   tt-ctbrecebe.tipo4 = ctbrecebe.moeda
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "PARCELA " + vdest.
            tt-ctbrecebe.tipo4 = ctbrecebe.moeda.
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 50 and ctbrecebe.moeda = ?
    then do:
        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = ""  and 
                   tt-ctbrecebe.tipo4 = ""
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "".
            tt-ctbrecebe.tipo4 = "".
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.
    if ctbrecebe.movseq = 51 and ctbrecebe.moeda <> ?
    then do:
        find first tt-ctbrecebe where 
                   tt-ctbrecebe.tipo1 = "" and
                   tt-ctbrecebe.tipo2 = ctbrecebe.modcod and
                   tt-ctbrecebe.tipo3 = "VENDA A VISTA" and
                   tt-ctbrecebe.tipo4 = ctbrecebe.moeda
                    no-error.
        if not avail tt-ctbrecebe
        then do:
            create tt-ctbrecebe.
            tt-ctbrecebe.tipo1 = "" .
            tt-ctbrecebe.tipo2 = ctbrecebe.modcod .
            tt-ctbrecebe.tipo3 = "VENDA A VISTA" .
            tt-ctbrecebe.tipo4 = ctbrecebe.moeda.
        end.                        
        assign
            tt-ctbrecebe.vlparcela = tt-ctbrecebe.vlparcela +
                                       ctbrecebe.vlparcela
            tt-ctbrecebe.vlpago   = tt-ctbrecebe.vlpago +
                                       ctbrecebe.vlpago
            tt-ctbrecebe.vlprincipal = tt-ctbrecebe.vlprincipal +
                                         ctbrecebe.vlprincipal
            tt-ctbrecebe.vlacrescimo = tt-ctbrecebe.vlacrescimo +
                                         ctbrecebe.vlacrescimo
            tt-ctbrecebe.vlseguro    = tt-ctbrecebe.vlseguro +
                                         ctbrecebe.vlseguro
            tt-ctbrecebe.vljuro      = tt-ctbrecebe.vljuro +
                                         ctbrecebe.vljuro
            .
    end.

end.
end.        
end.
                            
                            
def var varquivo as char.
varquivo = "/admcom/relat/res-teste.cl." + string(time).
output to value(varquivo).
disp with frame f1.
disp "Reltorio" vesc[vindex] with no-label. 

for each tt-ctbvenda:
    disp tt-ctbvenda.tipo1 when tt-ctbvenda.tipo2 = "" 
                            column-label "VENDA"
         tt-ctbvenda.tipo2 when tt-ctbvenda.tipo3 = "" 
                            column-label "Tipo"
         tt-ctbvenda.tipo3 when tt-ctbvenda.tipo4 = "" 
                            column-label ""
         tt-ctbvenda.tipo4  column-label "Produto"                                    tt-ctbvenda.vlmercadoria
         tt-ctbvenda.vlservico
         tt-ctbvenda.vloutras
         tt-ctbvenda.vltotal
         with frame f-ff down width 200.
    down with frame f-ff.     

end.
put skip(2).
for each vol-ctbvenda:
    disp vol-ctbvenda.tipo1 when vol-ctbvenda.tipo2 = "" 
                            column-label "VENDA OUTRA LOJA"
         vol-ctbvenda.tipo2 when vol-ctbvenda.tipo3 = "" 
                            column-label "Tipo"
         vol-ctbvenda.tipo3 when vol-ctbvenda.tipo4 = "" 
                            column-label ""
         vol-ctbvenda.tipo4 column-label "Produto"
         vol-ctbvenda.vlmercadoria
         vol-ctbvenda.vlservico
         vol-ctbvenda.vloutras
         vol-ctbvenda.vltotal
         with frame f-ff3 down width 200.
    down with frame f-ff3.     

end.
put skip(2).
for each vor-ctbvenda:
    disp vor-ctbvenda.tipo1 when vor-ctbvenda.tipo2 = "" 
                            column-label "VENDA RETIRADA"
         vor-ctbvenda.tipo2 when vor-ctbvenda.tipo4 = "" 
                            column-label "Tipo"
         vor-ctbvenda.tipo3 when vor-ctbvenda.tipo4 = "" 
                            column-label ""
         vor-ctbvenda.tipo4 column-label "Produto"
         vor-ctbvenda.vlmercadoria
         vor-ctbvenda.vlservico
         vor-ctbvenda.vloutras
         vor-ctbvenda.vltotal
         with frame f-ff2 down width 200.
    down with frame f-ff2.     

end.
put skip(2).
for each dv-ctbvenda:
    disp dv-ctbvenda.tipo1 when dv-ctbvenda.tipo2 = "" 
                            column-label "DEVOLUCAO VENDA"
         dv-ctbvenda.tipo2 when dv-ctbvenda.tipo3 = "" 
                            column-label "Tipo"
         dv-ctbvenda.tipo3 when dv-ctbvenda.tipo4 = "" 
                            column-label ""
         dv-ctbvenda.tipo4  column-label "Produto" no-label
         dv-ctbvenda.valorigem
         dv-ctbvenda.valfrete
         dv-ctbvenda.vlservico
         dv-ctbvenda.vloutras
         dv-ctbvenda.vlmercadoria
         dv-ctbvenda.vlcontrato
         dv-ctbvenda.vlprincipal
         dv-ctbvenda.vlacrescimo
         dv-ctbvenda.vlseguro
         dv-ctbvenda.vlquitado
         dv-ctbvenda.vldevolvido
         with frame f-ff1 down width 230.
    down with frame f-ff1.     

end.
put skip(2). 
put "C O N T R A T O" skip.
form tt-ctbcontrato.tipo2 with frame f-fc.
for each tt-ctbcontrato where 
            tt-ctbcontrato.tipo1 <> "CONTRATO TOTAL GERAL":
    disp /*tt-ctbcontrato.tipo1 when tt-ctbcontrato.tipo2 = ""
                                    column-label "CONTRATO"*/
         tt-ctbcontrato.tipo2 when tt-ctbcontrato.tipo3 = ""
                                    column-label "Tipo"
         tt-ctbcontrato.tipo3 when tt-ctbcontrato.tipo4 = "" 
                                    column-label "Modalidade"
         tt-ctbcontrato.tipo4       column-label "Local"    
         tt-ctbcontrato.vlcontrato      format ">>>,>>>,>>9.99"
         tt-ctbcontrato.vlentrada       format ">,>>>,>>9.99"
         tt-ctbcontrato.vlprincipal     format ">>>,>>>,>>9.99"
         tt-ctbcontrato.vlacrescimo     format "->>,>>>,>>9.99"
         tt-ctbcontrato.vlabate         format ">>>,>>9.99"
         tt-ctbcontrato.vlseguro        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlorigem        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlorifin        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlorileb        format ">,>>>,>>9.99"
         with frame f-fc down width 200.
    down with frame f-fc.
end.
put skip.
for each tt-ctbcontrato where 
            tt-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL":
    disp "CONTRATO TOTAL" @ tt-ctbcontrato.tipo2 
         tt-ctbcontrato.vlcontrato      format ">>>,>>>,>>9.99"
         tt-ctbcontrato.vlentrada       format ">,>>>,>>9.99"
         tt-ctbcontrato.vlprincipal     format ">>,>>>,>>9.99"
         tt-ctbcontrato.vlacrescimo     format "->>,>>>,>>9.99"
         tt-ctbcontrato.vlseguro        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlabate         format ">>>,>>9.99"
         tt-ctbcontrato.vlorigem        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlorifin        format ">,>>>,>>9.99"
         tt-ctbcontrato.vlorileb        format ">,>>>,>>9.99"
         with frame f-fc down width 200.
    down with frame f-fc.
end.

put skip(2). 
put "ESTORNO FINANCEIRA" skip.
form with frame f-fce1.
for each esf-ctbcontrato where
         esf-ctbcontrato.tipo1 <> "CONTRATO TOTAL GERAL":
    disp /*esf-ctbcontrato.tipo1 when esf-ctbcontrato.tipo2 = ""
                                    column-label "ESTORNO FINANCEIRA"*/
         esf-ctbcontrato.tipo2 when esf-ctbcontrato.tipo3 = ""
                                    column-label "Tipo"
         esf-ctbcontrato.tipo3 when esf-ctbcontrato.tipo4 = "" 
                                    column-label "Modalidade"
         esf-ctbcontrato.tipo4       column-label "Local" 
         esf-ctbcontrato.vlcontrato   format ">>>,>>>,>>9.99"
         esf-ctbcontrato.vlentrada    format ">,>>>,>>9.99"
         esf-ctbcontrato.vlprincipal  format ">>,>>>,>>9.99"
         esf-ctbcontrato.vlacrescimo  format ">>,>>>,>>9.99"
         esf-ctbcontrato.vlseguro     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlabate      format ">>>,>>9.99"
         esf-ctbcontrato.vlorigem     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlorifin     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlorileb     format ">,>>>,>>9.99"
         with frame f-fce1 down width 200.
    down with frame f-fce1.
end.
for each esf-ctbcontrato where
         esf-ctbcontrato.tipo1 = "CONTRATO TOTAL GERAL":
    disp "ESTORNO TOTAL" @ esf-ctbcontrato.tipo2
         esf-ctbcontrato.vlcontrato   format ">>>,>>>,>>9.99"
         esf-ctbcontrato.vlentrada    format ">,>>>,>>9.99"
         esf-ctbcontrato.vlprincipal  format ">>,>>>,>>9.99"
         esf-ctbcontrato.vlacrescimo  format ">>,>>>,>>9.99"
         esf-ctbcontrato.vlseguro     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlabate      format ">>>,>>9.99"
         esf-ctbcontrato.vlorigem     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlorifin     format ">,>>>,>>9.99"
         esf-ctbcontrato.vlorileb     format ">,>>>,>>9.99"
         with frame f-fce1 down width 200.
    down with frame f-fce1.
end. 
     
put skip(2).
for each tt-ctbrecebe:
    disp tt-ctbrecebe.tipo1 when tt-ctbrecebe.tipo2 = "" 
                            column-label "RECEBIMENTO"
         tt-ctbrecebe.tipo2 when tt-ctbrecebe.tipo3 = "" 
                            column-label "Modalidade"  format "x(12)"
         tt-ctbrecebe.tipo3 when (tt-ctbrecebe.tipo4 = "" or
                                 tt-ctbrecebe.tipo4 = "EMISSAO" or
                                 tt-ctbrecebe.tipo4 = "NOVACAO")
                            column-label "Tipo"        format "x(18)"
         tt-ctbrecebe.tipo4                              
                            column-label "Moeda"
         tt-ctbrecebe.vlparcela   format ">>>,>>>,>>9.99"
         tt-ctbrecebe.vlpago      format ">>>,>>>,>>9.99"
         tt-ctbrecebe.vlprincipal format ">>>,>>>,>>9.99"
         tt-ctbrecebe.vlacrescimo format ">>,>>>,>>9.99"
         tt-ctbrecebe.vljuro      format ">,>>>,>>9.99"
         tt-ctbrecebe.vlseguro    format ">,>>>,>>9.99"
         with width 200.
end.    

/*******
for each dt-ctbvenda where dt-ctbvenda.emite > 0:
    disp dt-ctbvenda.emite
         dt-ctbvenda.serie
         dt-ctbvenda.numero
         dt-ctbvenda.pladat
         dt-ctbvenda.chave
         dt-ctbvenda.vlmercadoria
         dt-ctbvenda.vlservico
         dt-ctbvenda.vltotal - dt-ctbvenda.vloutras
         with frame f-doc down width 200.
end.
******/

output close.

run visurel.p(varquivo,"").

end.

