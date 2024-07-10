{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.
def shared var vetbcod like estab.etbcod.
def var vnumero as char format "x(10)".
def var vserie as char format "x(3)" .

/*
update vetbcod label "Filial" with frame f1.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
end.
update vdti at 1 label "Data inicial"
       vdtf label "Data final" 
       with frame f1 1 down width 80 side-label.
*/

def var vmoenom as char.

def temp-table tt-moeda
    field moecod as char
    field valor as dec.

def temp-table dt-ctbcontrato
    field etbcod like contrato.etbcod
    field contnum as int format ">>>>>>>>>9"
    field dtinicial like contrato.dtinicial
    field modcod like contrato.modcod
    field cobcod as int format ">>9"
    field vlcontrato as dec   format ">>>,>>>,>>9.99"
    field vlentrada  as dec   format ">>>,>>>,>>9.99"
    field vlprincipal as dec  format ">>>,>>>,>>9.99"
    field vlacrescimo as dec  format "->>,>>>,>>9.99"
    field vlseguro as dec     format ">>,>>>,>>9.99"
    field vlorigem as dec     format ">>,>>>,>>9.99"
    field vlorifin as dec     format ">>,>>>,>>9.99"
    field vlorileb as dec     format ">>,>>>,>>9.99"
    field vlabate  as dec     format ">>,>>>,>>9.99"
    index i1 dtinicial etbcod contnum
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
      
def temp-table dt-ctbvenda
    field emite like ctbvenda.emite
    field serie like ctbvenda.serie
    field numero like ctbvenda.numero
    field pladat like plani.pladat
    field chave  like ctbvenda.chave
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    field cobcod   as int format ">>9"
    field dtorigem as date
    index i1 emite serie numero
    .

def temp-table dt-ctbvenda-vvi
    field emite like ctbvenda.emite
    field serie like ctbvenda.serie
    field numero like ctbvenda.numero
    field pladat like plani.pladat
    field chave  like ctbvenda.chave
    field Vlmercadoria as dec  format ">>>,>>>,>>9.99"
    field Vlservico as dec     format ">>>,>>>,>>9.99"
    field Vloutras as dec      format ">>>,>>>,>>9.99"
    field Vltotal  as dec      format ">>>,>>>,>>9.99"
    field cobcod   as int format ">>9"
    field moeda    as char
    field valmoeda as dec      format ">>>,>>>,>>9.99"
    index i1 emite serie numero
    .
    

def temp-table dt-ctbrecebe
    field datref as date
    field etbcod as int
    field modcod as char
    field cobcod as char
    field moecod as char
    field titnum as char format "x(15)"
    field titpar as int
    field vlparcela as dec
    field vlpago as dec
    field vlprincipal as dec
    field vlacrescimo as dec
    field vljuro as dec
    field vlseguro as dec
    index i1 datref etbcod modcod cobcod moecod
    .

def var char-crecod as char.
def var vdest as char.

def var vdata as date.
def var vindex as int.
def var vesc as char extent 10 format "x(30)".
vesc[1] = "VENDA VISTA".
vesc[2] = "VENDA PRAZO".
vesc[3] = "VENDA ENTREGA OF VISTA".
vesc[4] = "VENDA ENTREGA OF PRAZO".
vesc[5] = "VENDA RETIRADA OF".
vesc[6] = "VENDA DEVOLUCAO".
vesc[7] = "CONTRATO NORMAL".
vesc[8] = "CONTRATO NOVACAO".
vesc[9] = "CONTRATO OUTROS".
vesc[10] = "RECEBIMENTOS".

def var vescrec as char extent 3 format "x(20)".
vescrec[1] = "ENTRADAS".
vescrec[2] = "PARCELAS".
vescrec[3] = "VENDA VISTA".
 
def var vdsl as char.
def var vxsl as int.

disp vesc with frame f-esc no-label 1 down 1 column column 40.
choose field vesc with frame f-esc.
vindex = frame-index.

def var vsl as char extent 3 format "x(15)"
    init["Entrada","A Prazo","A Vista"].
    
if vindex = 10
then do:
    disp vsl with frame f-sl no-label side-label overlay.
    choose field vsl with frame f-sl.    
    vxsl = frame-index.
    vdsl = vsl[vxsl].
end.
 
sresp = no.
message "Confirma emitir relatorio " vesc[vindex] "?" update sresp.
if not sresp then undo.

disp "Aguarde relatorio " vesc[vindex]
    with frame f-ag no-box 1 down row 20 side-label no-label
    color message.

for each estab where (if vetbcod > 0 then estab.etbcod = vetbcod else true)
                no-lock:
    do vdata = vdti to vdtf:

        if vindex = 1
        then do:
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 and
                        ctbvenda.crecod = 1
                        no-lock:
            
            /********************
            find first titulo where 
                       titulo.titnat = no and
                       titulo.titnum = ctbvenda.serie + 
                                    string(ctbvenda.numero) and
                       titulo.modcod = "VVI" and
                       titulo.etbcod = ctbvenda.emite and
                       titulo.titdtemi = datref
                       no-lock no-error.
            if avail titulo
            then do:
                for each tt-moeda. delete tt-moeda. end.
                run titulo-moeda.
                
                for each tt-moeda where tt-moeda.valor <> 0:
                    find moeda where 
                            moeda.moecod = tt-moeda.moecod no-lock no-error.
                    if avail moeda
                    then vmoenom = tt-moeda.moecod + " - " + moeda.moenom.
                    else do:
                        vmoenom = "Moeda nao cadastrada".
                        if tt-moeda.moecod = "NOV"
                        then vmoenom = "NOV - NOVACAO".
                    end.    
                    create dt-ctbvenda-vvi.
                    
                    assign
                        dt-ctbvenda-vvi.emite = ctbvenda.emite
                        dt-ctbvenda-vvi.serie = ctbvenda.serie
                        dt-ctbvenda-vvi.numero = ctbvenda.numero
                        dt-ctbvenda-vvi.pladat = ctbvenda.datref
                        dt-ctbvenda-vvi.chave = ctbvenda.chave
                        dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                        dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                        dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                        dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras
                        dt-ctbvenda-vvi.moeda = vmoenom 
                        dt-ctbvenda-vvi.valmoeda = tt-moeda.valor
                        .
                end.
            end.
            else*/ do:
                create dt-ctbvenda-vvi.
                assign
                    dt-ctbvenda-vvi.emite = ctbvenda.emite
                    dt-ctbvenda-vvi.serie = ctbvenda.serie
                    dt-ctbvenda-vvi.numero = ctbvenda.numero
                    dt-ctbvenda-vvi.pladat = ctbvenda.datref
                    dt-ctbvenda-vvi.chave = ctbvenda.chave
                    dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                    dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                    dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                    dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
            end.
        end.
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 and
                        ctbvenda.crecod = 1
                        no-lock:

            /************
            find first titulo where 
                       titulo.titnat = no and
                       titulo.titnum = ctbvenda.serie + 
                                    string(ctbvenda.numero) and
                       titulo.modcod = "VVI" and
                       titulo.etbcod = ctbvenda.emite and
                       titulo.titdtemi = ctbvenda.datref
                       no-lock no-error.
            if avail titulo
            then do:
                for each tt-moeda. delete tt-moeda. end.
                run titulo-moeda.
                
                for each tt-moeda where tt-moeda.valor <> 0:
                    find moeda where 
                            moeda.moecod = tt-moeda.moecod no-lock no-error.
                    if avail moeda
                    then vmoenom = tt-moeda.moecod + " - " + moeda.moenom.
                    else do:
                        vmoenom = "Moeda nao cadastrada".
                        if tt-moeda.moecod = "NOV"
                        then vmoenom = "NOV - NOVACAO".
                    end.    
                    create dt-ctbvenda-vvi.
                    
                    assign
                        dt-ctbvenda-vvi.emite = ctbvenda.emite
                        dt-ctbvenda-vvi.serie = ctbvenda.serie
                        dt-ctbvenda-vvi.numero = ctbvenda.numero
                        dt-ctbvenda-vvi.pladat = ctbvenda.datref
                        dt-ctbvenda-vvi.chave = ctbvenda.chave
                        dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                        dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                        dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                        dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras
                        dt-ctbvenda-vvi.moeda = vmoenom 
                        dt-ctbvenda-vvi.valmoeda = tt-moeda.valor
                        .
                end.
            end.
            else do:
                create dt-ctbvenda-vvi.
                assign
                    dt-ctbvenda-vvi.emite = ctbvenda.emite
                    dt-ctbvenda-vvi.serie = ctbvenda.serie
                    dt-ctbvenda-vvi.numero = ctbvenda.numero
                    dt-ctbvenda-vvi.pladat = ctbvenda.datref
                    dt-ctbvenda-vvi.chave = ctbvenda.chave
                    dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                    dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                    dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                    dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
            end.
            ***********/
            
            create dt-ctbvenda-vvi.
                assign
                    dt-ctbvenda-vvi.emite = ctbvenda.emite
                    dt-ctbvenda-vvi.serie = ctbvenda.serie
                    dt-ctbvenda-vvi.numero = ctbvenda.numero
                    dt-ctbvenda-vvi.pladat = ctbvenda.datref
                    dt-ctbvenda-vvi.chave = ctbvenda.chave
                    dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                    dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                    dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                    dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
            
        end.
        end.
        else if vindex = 2
        then
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 and
                        ctbvenda.crecod = 2
                        no-lock:

            create dt-ctbvenda.
            assign
                dt-ctbvenda.emite = ctbvenda.emite
                dt-ctbvenda.serie = ctbvenda.serie
                dt-ctbvenda.numero = ctbvenda.numero
                dt-ctbvenda.pladat = ctbvenda.datref
                dt-ctbvenda.chave = ctbvenda.chave
                dt-ctbvenda.Vlmercadoria = ctbvenda.mercadoria
                dt-ctbvenda.Vlservico    = ctbvenda.servico
                dt-ctbvenda.Vloutras     = ctbvenda.outras
                dt-ctbvenda.vltotal = ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
        end.
        else if vindex = 3
        then
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 and
                        ctbvenda.crecod = 1
                        no-lock:

            /************
            find first titulo where 
                       titulo.titnat = no and
                       titulo.titnum = ctbvenda.serie + 
                                    string(ctbvenda.numero) and
                       titulo.modcod = "VVI" and
                       titulo.etbcod = ctbvenda.emite and
                       titulo.titdtemi = ctbvenda.datref
                       no-lock no-error.
            if avail titulo
            then do:
                for each tt-moeda. delete tt-moeda. end.
                run titulo-moeda.
                
                for each tt-moeda where tt-moeda.valor <> 0:
                    find moeda where 
                            moeda.moecod = tt-moeda.moecod no-lock no-error.
                    if avail moeda
                    then vmoenom = tt-moeda.moecod + " - " + moeda.moenom.
                    else do:
                        vmoenom = "Moeda nao cadastrada".
                        if tt-moeda.moecod = "NOV"
                        then vmoenom = "NOV - NOVACAO".
                    end.    
                    create dt-ctbvenda-vvi.
                    
                    assign
                        dt-ctbvenda-vvi.emite = ctbvenda.emite
                        dt-ctbvenda-vvi.serie = ctbvenda.serie
                        dt-ctbvenda-vvi.numero = ctbvenda.numero
                        dt-ctbvenda-vvi.pladat = ctbvenda.datref
                        dt-ctbvenda-vvi.chave = ctbvenda.chave
                        dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                        dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                        dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                        dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras
                        dt-ctbvenda-vvi.moeda = vmoenom 
                        dt-ctbvenda-vvi.valmoeda = tt-moeda.valor
                        .
                end.
            end.
            else do:
                create dt-ctbvenda-vvi.
                assign
                    dt-ctbvenda-vvi.emite = ctbvenda.emite
                    dt-ctbvenda-vvi.serie = ctbvenda.serie
                    dt-ctbvenda-vvi.numero = ctbvenda.numero
                    dt-ctbvenda-vvi.pladat = ctbvenda.datref
                    dt-ctbvenda-vvi.chave = ctbvenda.chave
                    dt-ctbvenda-vvi.Vlmercadoria = ctbvenda.mercadoria
                    dt-ctbvenda-vvi.Vlservico    = ctbvenda.servico
                    dt-ctbvenda-vvi.Vloutras     = ctbvenda.outras
                    dt-ctbvenda-vvi.vltotal = 
                            ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
            end.
            ***********/
            
            create dt-ctbvenda.
            assign
                dt-ctbvenda.emite = ctbvenda.emite
                dt-ctbvenda.serie = ctbvenda.serie
                dt-ctbvenda.numero = ctbvenda.numero
                dt-ctbvenda.pladat = ctbvenda.datref
                dt-ctbvenda.chave = ctbvenda.chave
                dt-ctbvenda.Vlmercadoria = ctbvenda.mercadoria
                dt-ctbvenda.Vlservico    = ctbvenda.servico
                dt-ctbvenda.Vloutras     = ctbvenda.outras
                dt-ctbvenda.vltotal = ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
            
        end.
        else if vindex = 4
        then
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA OUTRA LOJA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 and
                        ctbvenda.crecod = 2
                        no-lock:

            create dt-ctbvenda.
            assign
                dt-ctbvenda.emite = ctbvenda.emite
                dt-ctbvenda.serie = ctbvenda.serie
                dt-ctbvenda.numero = ctbvenda.numero
                dt-ctbvenda.pladat = ctbvenda.datref
                dt-ctbvenda.chave = ctbvenda.chave
                dt-ctbvenda.Vlmercadoria = ctbvenda.mercadoria
                dt-ctbvenda.Vlservico    = ctbvenda.servico
                dt-ctbvenda.Vloutras     = ctbvenda.outras
                dt-ctbvenda.vltotal = ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.
        

        end.
        else if vindex = 5
        then
        for each ctbvenda where ctbvenda.tipo = "VENDA" and
                        ctbvenda.tipovenda = "VENDA RETIRADA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 40 
                        no-lock:

            create dt-ctbvenda.
            assign
                dt-ctbvenda.emite = ctbvenda.emite
                dt-ctbvenda.serie = ctbvenda.serie
                dt-ctbvenda.numero = ctbvenda.numero
                dt-ctbvenda.pladat = ctbvenda.datref
                dt-ctbvenda.chave = ctbvenda.chave
                dt-ctbvenda.Vlmercadoria = ctbvenda.mercadoria
                dt-ctbvenda.Vlservico    = ctbvenda.servico
                dt-ctbvenda.Vloutras     = ctbvenda.outras
                dt-ctbvenda.vltotal = ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras
                dt-ctbvenda.dtorigem = ctbvenda.pladat-ori               
                                .

        end.
        else if vindex = 6
        then
        for each ctbvenda where ctbvenda.tipo = "DEVOLUCAO VENDA" and
                        ctbvenda.datref = vdata and
                        ctbvenda.etbcod = estab.etbcod and
                        ctbvenda.movseq = 400 
                        no-lock:

            create dt-ctbvenda.
            assign
                dt-ctbvenda.emite = ctbvenda.emite
                dt-ctbvenda.serie = ctbvenda.serie
                dt-ctbvenda.numero = ctbvenda.numero
                dt-ctbvenda.pladat = ctbvenda.datref
                dt-ctbvenda.chave = ctbvenda.chave
                dt-ctbvenda.Vlmercadoria = ctbvenda.mercadoria
                dt-ctbvenda.Vlservico    = ctbvenda.servico
                dt-ctbvenda.Vloutras     = ctbvenda.outras
                dt-ctbvenda.vltotal = ctbvenda.mercadoria + ctbvenda.servico
                                + ctbvenda.outras.

        end.
        else if vindex = 7
        then
        for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 40
                           no-lock:
            create dt-ctbcontrato.
            assign
                dt-ctbcontrato.etbcod    = ctbcontrato.etbcod
                dt-ctbcontrato.contnum   = ctbcontrato.contnum
                dt-ctbcontrato.dtinicial = ctbcontrato.datref
                dt-ctbcontrato.modcod    = ctbcontrato.modcod
                dt-ctbcontrato.cobcod    = ctbcontrato.cobcod
                dt-ctbcontrato.vlcontrato = ctbcontrato.vlcontrato
                dt-ctbcontrato.vlentrada  = ctbcontrato.vlentrada
                dt-ctbcontrato.vlprincipal = ctbcontrato.vlprincipal
                dt-ctbcontrato.vlacrescimo = ctbcontrato.vlacrescimo
                dt-ctbcontrato.vlseguro = ctbcontrato.vlseguro
                dt-ctbcontrato.vlorigem = ctbcontrato.vlorigem
                dt-ctbcontrato.vlorifin = ctbcontrato.vlorifin
                dt-ctbcontrato.vlorileb = ctbcontrato.vlorileb
                dt-ctbcontrato.vlabate = ctbcontrato.vlabate
                .
 
        end.
        else if vindex = 8
        then
        for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 45
                           no-lock:
            create dt-ctbcontrato.
            assign
                dt-ctbcontrato.etbcod    = ctbcontrato.etbcod
                dt-ctbcontrato.contnum   = ctbcontrato.contnum
                dt-ctbcontrato.dtinicial = ctbcontrato.datref
                dt-ctbcontrato.modcod    = ctbcontrato.modcod
                dt-ctbcontrato.cobcod    = ctbcontrato.cobcod
                dt-ctbcontrato.vlcontrato = ctbcontrato.vlcontrato
                dt-ctbcontrato.vlentrada  = ctbcontrato.vlentrada
                dt-ctbcontrato.vlprincipal = ctbcontrato.vlprincipal
                dt-ctbcontrato.vlacrescimo = ctbcontrato.vlacrescimo
                dt-ctbcontrato.vlseguro = ctbcontrato.vlseguro
                dt-ctbcontrato.vlorigem = ctbcontrato.vlorigem
                dt-ctbcontrato.vlorifin = ctbcontrato.vlorifin
                dt-ctbcontrato.vlorileb = ctbcontrato.vlorileb
                dt-ctbcontrato.vlabate = ctbcontrato.vlabate
                .
 
        end.
        else if vindex = 9
        then
        for each ctbcontrato where ctbcontrato.tipo = "CONTRATO" and
                           ctbcontrato.datref = vdata and
                           ctbcontrato.etbcod = estab.etbcod and
                           ctbcontrato.movseq = 46
                           no-lock:
            create dt-ctbcontrato.
            assign
                dt-ctbcontrato.etbcod    = ctbcontrato.etbcod
                dt-ctbcontrato.contnum   = ctbcontrato.contnum
                dt-ctbcontrato.dtinicial = ctbcontrato.datref
                dt-ctbcontrato.modcod    = ctbcontrato.modcod
                dt-ctbcontrato.cobcod    = ctbcontrato.cobcod
                dt-ctbcontrato.vlcontrato = ctbcontrato.vlcontrato
                dt-ctbcontrato.vlentrada  = ctbcontrato.vlentrada
                dt-ctbcontrato.vlprincipal = ctbcontrato.vlprincipal
                dt-ctbcontrato.vlacrescimo = ctbcontrato.vlacrescimo
                dt-ctbcontrato.vlseguro = ctbcontrato.vlseguro
                dt-ctbcontrato.vlorigem = ctbcontrato.vlorigem
                dt-ctbcontrato.vlorifin = ctbcontrato.vlorifin
                dt-ctbcontrato.vlorileb = ctbcontrato.vlorileb
                dt-ctbcontrato.vlabate = ctbcontrato.vlabate
                .
 
        end.
        else if vindex = 10
        then do:
            if vxsl = 1
            then do:
                for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod
                         and ctbrecebe.movseq = 21
                         no-lock:

                    create dt-ctbrecebe.
                    assign
                        dt-ctbrecebe.datref = ctbrecebe.datref
                        dt-ctbrecebe.etbcod = ctbrecebe.etbcod
                        dt-ctbrecebe.modcod = ctbrecebe.modcod
                        dt-ctbrecebe.cobcod = (if ctbrecebe.cobcod = 10
                                              then "Financeira"
                                              else "Lebes")
                        dt-ctbrecebe.moecod = ctbrecebe.moeda
                        dt-ctbrecebe.titnum = ctbrecebe.titnum
                        dt-ctbrecebe.titpar = ctbrecebe.titpar
                        dt-ctbrecebe.vlparcela = ctbrecebe.vlparcela
                        dt-ctbrecebe.vlpago    = ctbrecebe.vlpago
                        dt-ctbrecebe.vlprincipal = ctbrecebe.vlprincipal
                        dt-ctbrecebe.vlacrescimo = ctbrecebe.vlacrescimo
                        dt-ctbrecebe.vljuro = ctbrecebe.vljuro
                        dt-ctbrecebe.vlseguro = ctbrecebe.vlseguro
                        .
                end.
            end.
            else if vxsl = 2
            then do:
                for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod
                         and ctbrecebe.movseq = 31
                         no-lock:
                    create dt-ctbrecebe.
                    assign
                        dt-ctbrecebe.datref = ctbrecebe.datref
                        dt-ctbrecebe.etbcod = ctbrecebe.etbcod
                        dt-ctbrecebe.modcod = ctbrecebe.modcod
                        dt-ctbrecebe.cobcod = (if ctbrecebe.cobcod = 10
                                              then "Financeira"
                                              else "Lebes")
                        dt-ctbrecebe.moecod = ctbrecebe.moeda
                        dt-ctbrecebe.titnum = ctbrecebe.titnum
                        dt-ctbrecebe.titpar = ctbrecebe.titpar
                        dt-ctbrecebe.vlparcela = ctbrecebe.vlparcela
                        dt-ctbrecebe.vlpago    = ctbrecebe.vlpago
                        dt-ctbrecebe.vlprincipal = ctbrecebe.vlprincipal
                        dt-ctbrecebe.vlacrescimo = ctbrecebe.vlacrescimo
                        dt-ctbrecebe.vljuro = ctbrecebe.vljuro
                        dt-ctbrecebe.vlseguro = ctbrecebe.vlseguro
                        .
                end.
            end.
            else if vxsl = 3
            then do:
                for each ctbrecebe where ctbrecebe.tipo = "RECEBIMENTO" and
                         ctbrecebe.datref = vdata  and
                         ctbrecebe.etbcod = estab.etbcod
                         and ctbrecebe.movseq = 52
                         no-lock:

                    create dt-ctbrecebe.
                    assign
                        dt-ctbrecebe.datref = ctbrecebe.datref
                        dt-ctbrecebe.etbcod = ctbrecebe.etbcod
                        dt-ctbrecebe.modcod = ctbrecebe.modcod
                        dt-ctbrecebe.cobcod = (if ctbrecebe.cobcod = 10
                                              then "Financeira"
                                              else "Lebes")
                        dt-ctbrecebe.moecod = ctbrecebe.moeda
                        dt-ctbrecebe.titnum = ctbrecebe.titnum
                        dt-ctbrecebe.titpar = ctbrecebe.titpar
                        dt-ctbrecebe.vlparcela = ctbrecebe.vlparcela
                        dt-ctbrecebe.vlpago    = ctbrecebe.vlpago
                        dt-ctbrecebe.vlprincipal = ctbrecebe.vlprincipal
                        dt-ctbrecebe.vlacrescimo = ctbrecebe.vlacrescimo
                        dt-ctbrecebe.vljuro = ctbrecebe.vljuro
                        dt-ctbrecebe.vlseguro = ctbrecebe.vlseguro
                        .
                end.
            end.
        end.
     end. 
end.
                            
def var varquivo as char.
varquivo = "/admcom/Contabilidade/relat/" + lc(vesc[vindex]) + " " + vdsl 
            + "-" +
            string(vdti,"99999999") + "-" + string(vdtf,"99999999")
            + "-" + string(time) + ".csv".
output to value(varquivo).
disp with frame f1.
disp "Reltorio" vesc[vindex] with no-label. 

def var vsep as char format "x" init ";".

if vindex < 2
then do:
    put "Filial;Serie;Numero;Emissao;Chave;Mercadoria;Servico;Outras;Total"
        skip.
    /*
    put "Filial;Serie;Numero;Emissao;Chave;Mercadoria;Servico;Outras;Total;Moeda;Valor Moeda"
        skip. */
    for each  dt-ctbvenda-vvi where dt-ctbvenda-vvi.numero > 0 no-lock:
        put unformatted
            dt-ctbvenda-vvi.emite
            vsep
            dt-ctbvenda-vvi.serie
            vsep
            dt-ctbvenda-vvi.numero 
            vsep
            dt-ctbvenda-vvi.pladat
            vsep
            dt-ctbvenda-vvi.chave
            vsep
            dt-ctbvenda-vvi.Vlmercadoria 
            vsep
            dt-ctbvenda-vvi.Vlservico 
            vsep
            dt-ctbvenda-vvi.Vloutras 
            vsep
            dt-ctbvenda-vvi.vltotal   
            /*vsep
            dt-ctbvenda-vvi.moeda
            vsep
            dt-ctbvenda-vvi.valmoeda*/   
            skip.
            
    end.            
end.
else if vindex < 7
then do:
    if vindex = 5
    then do:
    put
"Filial;Serie;Numero;Emissao;Chave;Mercadoria;Servico;Outras;Total;DtOrigem"
        skip.
    for each  dt-ctbvenda where dt-ctbvenda.numero > 0 no-lock:
        put unformatted
            dt-ctbvenda.emite
            vsep
            dt-ctbvenda.serie
            vsep
            dt-ctbvenda.numero 
            vsep
            dt-ctbvenda.pladat
            vsep
            dt-ctbvenda.chave
            vsep
            dt-ctbvenda.Vlmercadoria 
            vsep
            dt-ctbvenda.Vlservico 
            vsep
            dt-ctbvenda.Vloutras 
            vsep
            dt-ctbvenda.vltotal   
            vsep
            dt-ctbvenda.dtorigem
            skip.
            
    end.     
    end.
    else do:
    put "Filial;Serie;Numero;Emissao;Chave;Mercadoria;Servico;Outras;Total"
        skip.
    for each  dt-ctbvenda where dt-ctbvenda.numero > 0 no-lock:
        put unformatted
            dt-ctbvenda.emite
            vsep
            dt-ctbvenda.serie
            vsep
            dt-ctbvenda.numero 
            vsep
            dt-ctbvenda.pladat
            vsep
            dt-ctbvenda.chave
            vsep
            dt-ctbvenda.Vlmercadoria 
            vsep
            dt-ctbvenda.Vlservico 
            vsep
            dt-ctbvenda.Vloutras 
            vsep
            dt-ctbvenda.vltotal   
            skip.
            
    end. 
    end.           
end.
else if vindex < 10
then do:
    put "Filial;Contrato;Emissao;Mod;Cob;vlcontrato;vlentrada;vlprincipal;vlacrescimo;vl
seguro;vlorigem;vlorifin;vlorileb;vlabate" skip.
    
    for each dt-ctbcontrato where dt-ctbcontrato.contnum > 0 no-lock:
        put unformatted
                dt-ctbcontrato.etbcod             vsep
                dt-ctbcontrato.contnum            vsep
                dt-ctbcontrato.dtinicial          vsep
                dt-ctbcontrato.modcod             vsep
                dt-ctbcontrato.cobcod             vsep
                dt-ctbcontrato.vlcontrato         vsep
                dt-ctbcontrato.vlentrada          vsep
                dt-ctbcontrato.vlprincipal        vsep
                dt-ctbcontrato.vlacrescimo        vsep
                dt-ctbcontrato.vlseguro           vsep
                dt-ctbcontrato.vlorigem           vsep
                dt-ctbcontrato.vlorifin           vsep
                dt-ctbcontrato.vlorileb           vsep
                dt-ctbcontrato.vlabate            
                skip.
 
    end.
end.
else do:
    put "Filial;Data;Mod;Cob;Moeda;Dcumento;Par;vlparcela;vlpago;vlprincipal;vlacrescimo
;vljuro;vlseguro;Venda;Serie" skip.

    for each dt-ctbrecebe where dt-ctbrecebe.datref <> ? no-lock:
        vnumero = "".
        vserie = "".
        if dt-ctbrecebe.modcod <> "CHQ"
        then do:
            find contrato where 
                 contrato.contnum = int(dt-ctbrecebe.titnum)
                   no-lock no-error.
            if avail contrato
            then do:
                find last contnf where contnf.etbcod = contrato.etbcod and
                                 contnf.contnum = contrato.contnum  
                                 no-lock no-error.
                if avail contnf
                then do:
                    find first plani where
                               plani.etbcod = contnf.etbcod and
                               plani.placod = contnf.placod
                               no-lock no-error.
                    if avail plani
                    then assign
                            vnumero = string(plani.numero)
                            vserie  = plani.serie
                            .
                end.
            end.
            if dt-ctbrecebe.modcod = "VVI"
            then assign
                     vnumero = dt-ctbrecebe.titnum
                     .                        
        end.
        put unformatted 
            dt-ctbrecebe.etbcod            vsep
            dt-ctbrecebe.datref            vsep
            dt-ctbrecebe.modcod            vsep
            dt-ctbrecebe.cobcod            vsep
            dt-ctbrecebe.moecod            vsep
            dt-ctbrecebe.titnum            vsep
            dt-ctbrecebe.titpar            vsep
            dt-ctbrecebe.vlparcela         vsep
            dt-ctbrecebe.vlpago            vsep
            dt-ctbrecebe.vlprincipal       vsep
            dt-ctbrecebe.vlacrescimo       vsep
            dt-ctbrecebe.vljuro            vsep
            dt-ctbrecebe.vlseguro          vsep
            vnumero                        vsep
            vserie  
            skip.
        
    end.
end.


output close.

def var varquivo-csv as char.
varquivo-csv = replace(varquivo,"/admcom","l:").

message color red/with
    varquivo-csv
    view-as alert-box
    title "Arquivo gerado"
    .
    
/*
run visurel.p(varquivo,"").
*/


procedure titulo-moeda:
    /*def var pag-p2k as log.
    pag-p2k = no.*/
    def var vpaga as dec init 0.
    def var vt-paga like titulo.titvlcob.
    def var val-juro as dec.
    vt-paga = 0.
    
    if titulo.moecod = "PDM"
    then do:
        vpaga = 0.
        for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 
            find first tt-moeda where tt-moeda.moecod = titpag.moecod
                    no-error.
            if not avail tt-moeda
            then do:
                create tt-moeda.
                tt-moeda.moecod = titpag.moecod.
            end.        
            tt-moeda.valor = tt-moeda.valor + titpag.titvlpag.
        end.
    end.
    else do:
        find first tt-moeda where tt-moeda.moecod = titulo.moecod
                    no-error.
        if not avail tt-moeda
        then do:
                create tt-moeda.
                tt-moeda.moecod = titulo.moecod.
        end.        
        tt-moeda.valor = tt-moeda.valor + titulo.titvlpag.
    end.
    
end procedure.


