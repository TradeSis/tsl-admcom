{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.

def var vesc as char format "x(20)" extent 2
init["   Filial  ","   Diario  "].

def var vindex as int.
disp vesc with frame f-esc no-label down centered side-label.
choose field vesc with frame f-esc.
vindex = frame-index.

def temp-table tt-cartcl like ninja.ctcartcl
    /*field devprazo as dec
    field estorno  as dec*/
    field re-caixa as dec
    field re-novacao as dec
    field em-novacao as dec.
def temp-table  tt-datcl like ninja.ctcartcl
    /*field devprazo as dec
    field estorno  as dec*/
    field re-caixa as dec
    field re-novacao as dec
    field em-novacao as dec
    index i1 datref .
    
if vindex = 1
then do:
for each ninja.ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ctcartcl.ETBCOD > 0
                        no-lock:
    find first tt-cartcl where
               tt-cartcl.etbcod = ctcartcl.etbcod and
               tt-cartcl.datref = vdtf
               no-error.
    if not avail tt-cartcl
    then do:
        create tt-cartcl.
        assign
            tt-cartcl.etbcod = ctcartcl.etbcod
            tt-cartcl.datref = vdtf
                    .
    end.               
    assign
        tt-cartcl.avista   = tt-cartcl.avista + ctcartcl.avista
        tt-cartcl.aprazo   = tt-cartcl.aprazo + ctcartcl.aprazo
        tt-cartcl.devolucao = tt-cartcl.devolucao + ctcartcl.devolucao 
        tt-cartcl.ecfvista = tt-cartcl.ecfvista +  ctcartcl.ecfvista
        tt-cartcl.ecfprazo = tt-cartcl.ecfprazo +  ctcartcl.ecfprazo
        tt-cartcl.emissao  = tt-cartcl.emissao  +  ctcartcl.emissao
        tt-cartcl.dec1     = tt-cartcl.dec1 + (ctcartcl.dec1 / 100)
        tt-cartcl.acrescimo = tt-cartcl.acrescimo +  ctcartcl.acrescimo
        tt-cartcl.recebimento = tt-cartcl.recebimento + ctcartcl.recebimento
        tt-cartcl.juro = tt-cartcl.juro +  ctcartcl.juro
        tt-cartcl.dec2 = tt-cartcl.dec2 + ctcartcl.dec2 
        tt-cartcl.dec3 = tt-cartcl.dec3 + ctcartcl.dec3 
        tt-cartcl.dif-ecf-contrato = tt-cartcl.dif-ecf-contrato 
        + ctcartcl.dif-ecf-contrato
        tt-cartcl.devprazo = tt-cartcl.devprazo + ctcartcl.devprazo
        tt-cartcl.estorno = tt-cartcl.estorno + ctcartcl.estorno
        tt-cartcl.emis-financeira = tt-cartcl.emis-financeira +
                            ctcartcl.emis-financeira
        tt-cartcl.rece-financeira  = tt-cartcl.rece-financeira  +
                            ctcartcl.rece-financeira
        .
    for each ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod = ctcartcl.etbcod and
             ctbreceb.datref = ctcartcl.datref
             no-lock:
        if 
           moecod = "CHV" or
           moecod = "REA" or
           moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctbreceb.valor1.
        end.    
        if moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctbreceb.valor1.
        if moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctbreceb.valor1.

     end.
end.

/**
for each contarqm where contarqm.datexp >= vdti and
                        contarqm.datexp <= vdtf and
                        contarqm.situacao = 4
                        .
    find first tt-cartcl where
               tt-cartcl.etbcod = contarqm.etbcod and
               tt-cartcl.datref = vdtf
               no-error.
    if not avail tt-cartcl
    then do:
        create tt-cartcl.
        assign
            tt-cartcl.etbcod = contarqm.etbcod
            tt-cartcl.datref = vdtf
            .
    end.
    tt-cartcl.devprazo = tt-cartcl.devprazo + contarqm.vltotal.
    tt-cartcl.estorno  = tt-cartcl.estorno  + 
                    (/*contarqm.vltotal -*/ contarqm.vlfrete).
end. 
***/

end.

if vindex = 2
then do:
for each ninja.ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ctcartcl.ETBCOD > 0
                        no-lock:
    find first tt-datcl where
               tt-datcl.etbcod = 0 and
               tt-datcl.datref = ctcartcl.datref
               no-error.
    if not avail tt-datcl
    then do:
        create tt-datcl.
        assign
            tt-datcl.etbcod = 0
            tt-datcl.datref = ctcartcl.datref
                    .
    end.               
    assign
        tt-datcl.avista   = tt-datcl.avista + ctcartcl.avista
        tt-datcl.aprazo   = tt-datcl.aprazo + ctcartcl.aprazo
        tt-datcl.devolucao = tt-datcl.devolucao + ctcartcl.devolucao 
        tt-datcl.ecfvista = tt-datcl.ecfvista +  ctcartcl.ecfvista
        tt-datcl.ecfprazo = tt-datcl.ecfprazo +  ctcartcl.ecfprazo
        tt-datcl.emissao  = tt-datcl.emissao  +  ctcartcl.emissao
        tt-datcl.dec1     = tt-datcl.dec1 + (ctcartcl.dec1 / 100)
        tt-datcl.acrescimo = tt-datcl.acrescimo +  ctcartcl.acrescimo
        tt-datcl.recebimento = tt-datcl.recebimento + ctcartcl.recebimento
        tt-datcl.juro = tt-datcl.juro +  ctcartcl.juro
        tt-datcl.dec2 = tt-datcl.dec2 + ctcartcl.dec2 
        tt-datcl.dec3 = tt-datcl.dec3 + ctcartcl.dec3 
        tt-datcl.dif-ecf-contrato = tt-datcl.dif-ecf-contrato 
        + ctcartcl.dif-ecf-contrato
        tt-datcl.devprazo = tt-datcl.devprazo + ctcartcl.devprazo
        tt-datcl.estorno = tt-datcl.estorno + ctcartcl.estorno
        tt-datcl.rece-financeira = tt-datcl.rece-financeira +
                        ctcartcl.rece-financeira
        tt-datcl.emis-financeira = tt-datcl.emis-financeira +
                        ctcartcl.emis-financeira
        .
    for each ninja.ctbreceb where
             ctbreceb.rectp  = "RECEBIMENTO" and
             ctbreceb.etbcod = ctcartcl.etbcod and
             ctbreceb.datref = ctcartcl.datref
             no-lock:
        if 
           moecod = "CHV" or
           moecod = "REA" or
           moecod = ""
        then do:
            tt-datcl.re-caixa = tt-datcl.re-caixa + ctbreceb.valor1.
        end.    
        if moecod = "NOV"
        then tt-datcl.re-novacao = tt-datcl.re-novacao + ctbreceb.valor1.
        if moecod = "RNG"
        then tt-datcl.em-novacao = tt-datcl.em-novacao + ctbreceb.valor1.

     end.

end.
/***
for each contarqm where contarqm.datexp >= vdti and
                        contarqm.datexp <= vdtf and
                        contarqm.situacao = 4
                        .
    find first tt-datcl where
               tt-datcl.etbcod = 0 and
               tt-datcl.datref = contarqm.datexp
               no-error.
    if not avail tt-datcl
    then do:
        create tt-datcl.
        assign
            tt-datcl.etbcod = 0
            tt-datcl.datref = contarqm.datexp
                    .
    end.
    tt-datcl.devprazo = tt-datcl.devprazo + contarqm.vltotal.
    tt-datcl.estorno  = tt-datcl.estorno  + 
                    (/*contarqm.vltotal -*/ contarqm.vlfrete).
end.    
****/
end.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/procli" + string(time).
else varquivo = "l:/relat/procli" + string(time).

    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""acr_fin""
        &Nom-Sis   = """SISTEMA CONTABIL/FISCAL"""
        &Tit-Rel   = """ CLIENTES "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "210"
        &Form      = "frame f-cabcab"}

if vindex = 1
then
for each tt-cartcl where tt-cartcl.datref = vdtf no-lock:
    disp tt-cartcl.etbcod       column-label "FIL"        
         tt-cartcl.ecfvista(total)     column-label "ECF-V"
                    format ">>,>>>,>>9.99"
         tt-cartcl.ecfprazo(total)     column-label "ECF-P"
                    format ">>,>>>,>>9.99"
         /*tt-cartcl.dec1 / 100 (total)         column-label "ENTRADA"   
                    FORMAT ">,>>>,>>9.99" */
         tt-cartcl.acrescimo(total)    column-label "ACRESCIMO"
                    format ">>,>>>,>>9.99"
         tt-cartcl.recebimento(total)  column-label "RECEBIMENTO"
                    format ">>,>>>,>>9.99"
         tt-cartcl.re-caixa(total)  column-label "REC. CAIXA"
                             format ">>,>>>,>>9.99"
         tt-cartcl.juro(total)         column-label "JURO"
                    format ">,>>>,>>9.99"
         tt-cartcl.devprazo(total)         column-label "DEV PRAZO"
                    format ">,>>>,>>9.99"
         tt-cartcl.estorno(total)         column-label "ESTORNO"
                    format ">>>,>>9.99"
         tt-cartcl.devolucao(total)         column-label "DEV VISTA"
                    format ">,>>>,>>9.99"
         tt-cartcl.avista(total)         column-label "BANRI"
                    format ">,>>>,>>9.99"
         tt-cartcl.aprazo(total)         column-label "VISA"
                    format ">,>>>,>>9.99"
         tt-cartcl.emissao(total)         column-label "MASTER"
                    format ">,>>>,>>9.99"
         tt-cartcl.emis-financeira
         /*tt-cartcl.dif-ecf-contrato(TOTAL)*/       column-label "EMI FINAN"
                          format ">>,>>>,>>9.99"
         tt-cartcl.rece-financeira
         /*tt-cartcl.dec2 / 100  (total)*/          column-label "REC FINAN"
                    format ">>,>>>,>>9.99"
         /*tt-cartcl.emis-novacao
         /*tt-cartcl.re-novacao  (total)*/          column-label "REC NOVACAO"
                    format ">>,>>>,>>9.99"
         tt-cartcl.rec-novacao           
         /*tt-cartcl.em-novacao  (total)*/       column-label "EMI NOVACAO"                           format ">>,>>>,>>9.99"
          */
         /*tt-cartcl.recebimento + (tt-cartcl.dec2 / 100)  (total)
                    column-label "REC.TOTAL"
                    format ">>,>>>,>>9.99" */
         with frame f-disp down width 240.
    down with frame f-disp.
end.
    
if vindex = 2
then
for each tt-datcl where tt-datcl.datref >= vdti and
                        tt-datcl.datref <= vdtf and
                        tt-datcl.etbcod = 0 no-lock:
    disp tt-datcl.datref       column-label "Data"  format "99/99/99"      
         tt-datcl.ecfvista(total)     column-label "ECF-V"
                    format ">>,>>>,>>9.99"
         tt-datcl.ecfprazo(total)     column-label "ECF-P"
                    format ">>,>>>,>>9.99"
         /*tt-datcl.dec1 / 100 (total)         column-label "ENTRADA"   
                    FORMAT ">,>>>,>>9.99" */
         tt-datcl.acrescimo(total)    column-label "ACRESCIMO"
                    format ">>,>>>,>>9.99"
         tt-datcl.recebimento(total)  column-label "RECEBIMENTO"
                    format ">>,>>>,>>9.99"
         tt-datcl.re-CAIXA(total)  column-label "REC. CAIXA"
                                        format ">>,>>>,>>9.99"
         tt-datcl.juro(total)         column-label "JURO"
                    format ">,>>>,>>9.99"
         tt-datcl.devprazo(total)         column-label "DEV PRAZO"
                    format ">,>>>,>>9.99"
         tt-datcl.estorno(total)         column-label "ESTORNO"
                    format ">>>,>>9.99"
         tt-datcl.devolucao(total)         column-label "DEV VISTA"
                    format ">,>>>,>>9.99"
         tt-datcl.avista(total)         column-label "BANRI"
                    format ">,>>>,>>9.99"
         tt-datcl.aprazo(total)         column-label "VISA"
                    format ">,>>>,>>9.99"
         tt-datcl.emissao(total)         column-label "MASTER"
                    format ">,>>>,>>9.99"
         tt-datcl.emis-financeira
         /*tt-datcl.dif-ecf-contrato(TOTAL)*/       column-label "EMI FINAN"
                          format ">>,>>>,>>9.99"
         tt-datcl.rece-financeira
         /*tt-datcl.dec2 / 100  (total)*/          column-label "REC FINAN"
                    format ">>,>>>,>>9.99"
         tt-datcl.re-novacao  (total)          column-label "REC NOVACAO"
                    format ">>,>>>,>>9.99"
         tt-datcl.em-novacao  (total)          column-label "EMI NOVACAO"                          format ">>,>>>,>>9.99"
          /*tt-datcl.recebimento + (tt-datcl.dec2 / 100)  (total)
                    column-label "REC.TOTAL"
                    format ">>,>>>,>>9.99" */
         with frame f-disp1 down width 240.
    down with frame f-disp1.

end.

    def var valor as dec.    
    put skip(2).
    put "VENDA VISTA POR MOEDA" skip .
    valor = 0.

    for each ninja.ctbreceb where
             ctbreceb.rectp = "VENDA" and
             ctbreceb.datref >= vdti  and
             ctbreceb.datref <= vdtf
             no-lock break by ctbreceb.moecod:
        valor = valor + ctbreceb.valor1.
        if last-of(ctbreceb.moecod)
        then do:
            disp ctbreceb.moecod column-label "MOEDA"
                 valor(total) column-label "VALOR"  format ">>>,>>>,>>9.99"
            with frame f-moe down.
            down with frame f-moe.
            valor = 0.
        end.
    end.
                                                                       
    put skip(2).
    put "ENTRADA POR MOEDA" SKIP.
    valor = 0.
    for each ninja.ctbreceb where
             ctbreceb.rectp = "ENTRADA" and
             ctbreceb.datref >= vdti  and
             ctbreceb.datref <= vdtf
             no-lock break by ctbreceb.moecod:
        valor = valor + ctbreceb.valor1.
        if last-of(ctbreceb.moecod)
        then do:
            disp ctbreceb.moecod column-label "MOEDA"
                valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
                with frame f-moe1 down.
                down with frame f-moe1.
            valor = 0.
        end.
    end.
                                                                       
    put skip(2).
    put "TROCA POR MOEDA" SKIP.
    valor = 0.
    for each ninja.ctbreceb where
             ctbreceb.rectp = "TROCA" and
             ctbreceb.datref >= vdti  and
             ctbreceb.datref <= vdtf
             no-lock break by ctbreceb.moecod:
        valor = valor + ctbreceb.valor1.
        if last-of(ctbreceb.moecod)
        then do:
            disp ctbreceb.moecod column-label "MOEDA"
                valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe2 down.
            down with frame f-moe2.
            valor = 0.
        end.
    end.
                                                                       
    put skip(2).
                                                                                   put "RECEBIMENTO POR MOEDA" SKIP.
    valor = 0.
    for each ninja.ctbreceb where
             ctbreceb.rectp = "RECEBIMENTO" and
             ctbreceb.datref >= vdti  and
             ctbreceb.datref <= vdtf
             no-lock break by ctbreceb.moecod:
       valor = valor + ctbreceb.valor1.
       if last-of(ctbreceb.moecod)
       then do:
           disp ctbreceb.moecod column-label "MOEDA"
              valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe3 down.
           down with frame f-moe3.
           valor = 0.
       end.
    end.
                                                      
output close.

/*
if vindex = 2
then do:
    output to /admcom/relat/recebimento.csv.
    
    for each tt-datcl where tt-datcl.datref >= vdti and
                        tt-datcl.datref <= vdtf and
                        tt-datcl.etbcod = 0 no-lock:
    
        put tt-datcl.datref   ";"      
            tt-datcl.recebimento format ">>,>>>,>>9.99"
            ";"
            tt-datcl.juro format ">,>>>,>>9.99"
            skip.

    end.
    output close.
end.
*/ 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
        {mrod.i}
    end.
