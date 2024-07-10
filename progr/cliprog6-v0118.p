{admcab.i}
def shared var vdti as date.
def shared var vdtf as date.

update vdti at 1 label "Data inicial"
       vdtf label "Data final"
       with frame f1 side-label.

def var vesc as char format "x(20)" extent 2
init["   Filial  ","   Diario  "].

def var vindex as int.
disp vesc with frame f-esc no-label down centered side-label.
choose field vesc with frame f-esc.
vindex = frame-index.

def temp-table tt-cartcl like ct-cartcl
    field re-caixa as dec
    field re-novacao as dec
    field em-novacao as dec.
def temp-table  tt-datcl like ct-cartcl
    field re-caixa as dec
    field re-novacao as dec
    field em-novacao as dec
    index i1 datref .
    
if vindex = 1
then do:
for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.ETBCOD > 0
                        no-lock:
    find first tt-cartcl where
               tt-cartcl.etbcod = ct-cartcl.etbcod and
               tt-cartcl.datref = vdtf
               no-error.
    if not avail tt-cartcl
    then do:
        create tt-cartcl.
        assign
            tt-cartcl.etbcod = ct-cartcl.etbcod
            tt-cartcl.datref = vdtf
                    .
    end.               
    assign
        tt-cartcl.avista   = tt-cartcl.avista + ct-cartcl.avista
        tt-cartcl.aprazo   = tt-cartcl.aprazo + ct-cartcl.aprazo
        tt-cartcl.devvista = tt-cartcl.devvista + ct-cartcl.devvista 
        tt-cartcl.acrescimo = tt-cartcl.acrescimo +  ct-cartcl.acrescimo
        tt-cartcl.recebimento = tt-cartcl.recebimento + ct-cartcl.recebimento
        tt-cartcl.juro = tt-cartcl.juro +  ct-cartcl.juro
        tt-cartcl.devprazo = tt-cartcl.devprazo + ct-cartcl.devprazo
        tt-cartcl.estorno = tt-cartcl.estorno + ct-cartcl.estorno
        tt-cartcl.visa   = tt-cartcl.visa + ct-cartcl.visa
        tt-cartcl.master   = tt-cartcl.master + ct-cartcl.master
        tt-cartcl.banri   = tt-cartcl.banri + ct-cartcl.banri
        .
    for each ctb-receb where
             ctb-receb.rectp  = "PARCELA" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "ACRESCIMO" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if 
           ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "JURO ATRASO" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if 
           ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "ENTRADA" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctb-receb.valor1.

     end.
end.

end.

if vindex = 2
then do:
for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.ETBCOD > 0
                        no-lock:
    find first tt-datcl where
               tt-datcl.etbcod = 0 and
               tt-datcl.datref = ct-cartcl.datref
               no-error.
    if not avail tt-datcl
    then do:
        create tt-datcl.
        assign
            tt-datcl.etbcod = 0
            tt-datcl.datref = ct-cartcl.datref
                    .
    end.               
    assign
        tt-datcl.avista   = tt-datcl.avista + ct-cartcl.avista
        tt-datcl.aprazo   = tt-datcl.aprazo + ct-cartcl.aprazo
        tt-datcl.devvista = tt-datcl.devvista + ct-cartcl.devvista 
        tt-datcl.acrescimo = tt-datcl.acrescimo +  ct-cartcl.acrescimo
        tt-datcl.recebimento = tt-datcl.recebimento + ct-cartcl.recebimento
        tt-datcl.juro = tt-datcl.juro +  ct-cartcl.juro
        tt-datcl.devprazo = tt-datcl.devprazo + ct-cartcl.devprazo
        tt-datcl.estorno = tt-datcl.estorno + ct-cartcl.estorno
        tt-datcl.visa = tt-datcl.visa + ct-cartcl.visa
        tt-datcl.master = tt-datcl.master + ct-cartcl.master
        tt-datcl.banri = tt-datcl.banri + ct-cartcl.banri
        .
    for each ctb-receb where
             ctb-receb.rectp  = "PARCELA" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-datcl.re-caixa = tt-datcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-datcl.re-novacao = tt-datcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-datcl.em-novacao = tt-datcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "ACRESCIMO" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if 
           ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-datcl.re-caixa = tt-datcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-datcl.re-novacao = tt-datcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-datcl.em-novacao = tt-datcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "JURO ATRASO" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if 
           ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-datcl.re-caixa = tt-datcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-datcl.re-novacao = tt-datcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-datcl.em-novacao = tt-datcl.em-novacao + ctb-receb.valor1.

     end.
     for each ctb-receb where
             ctb-receb.rectp  = "ENTRADA" and
             ctb-receb.etbcod = ct-cartcl.etbcod and
             ctb-receb.datref = ct-cartcl.datref
             no-lock:
        if ctb-receb.moecod = "CHV" or
           ctb-receb.moecod = "REA" or
           ctb-receb.moecod = ""
        then do:
            tt-cartcl.re-caixa = tt-cartcl.re-caixa + ctb-receb.valor1.
        end.    
        if ctb-receb.moecod = "NOV"
        then tt-cartcl.re-novacao = tt-cartcl.re-novacao + ctb-receb.valor1.
        if ctb-receb.moecod = "RNG"
        then tt-cartcl.em-novacao = tt-cartcl.em-novacao + ctb-receb.valor1.

     end.

end.
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
        &Width     = "180"
        &Form      = "frame f-cabcab"}

if vindex = 1
then
for each tt-cartcl where tt-cartcl.datref = vdtf no-lock:
    disp tt-cartcl.etbcod       column-label "FIL"        
         tt-cartcl.avista(total)     column-label "Venda!a vista"
                    format ">>,>>>,>>9.99"
         tt-cartcl.aprazo(total)     column-label "Venda!a prazo"
                    format ">>,>>>,>>9.99"
         /*tt-cartcl.dec1 / 100 (total)         column-label "ENTRADA"   
                    FORMAT ">,>>>,>>9.99" */
         tt-cartcl.acrescimo(total)    column-label "Acrescimo"
                    format ">>,>>>,>>9.99"
         tt-cartcl.recebimento(total)  column-label "Recebimento"
                    format ">>,>>>,>>9.99"
         tt-cartcl.re-caixa(total)  column-label "Recebe!Caixa"
                             format ">>,>>>,>>9.99"
         tt-cartcl.juro(total)         column-label "Juro!Atraso"
                    format ">,>>>,>>9.99"
         tt-cartcl.devprazo(total)         column-label "Devol.!a prazo"
                    format ">,>>>,>>9.99"
         tt-cartcl.estorno(total)         column-label "Estorno"
                    format ">>>,>>9.99"
         tt-cartcl.devvista(total)         column-label "Devo.!a vista"
                    format ">,>>>,>>9.99"
         tt-cartcl.visa(total)             column-label "Visa"
                    format ">,>>>,>>9.99"
         tt-cartcl.master(total)           column-label "Master"
                    format ">,>>>,>>9.99"       
         tt-cartcl.banri(total)           column-label "Banri"
                    format ">,>>>,>>9.99"     
         with frame f-disp down width 240.
    down with frame f-disp.
end.
    
if vindex = 2
then
for each tt-datcl where tt-datcl.datref >= vdti and
                        tt-datcl.datref <= vdtf and
                        tt-datcl.etbcod = 0 no-lock:
    disp tt-datcl.datref       column-label "Data"  format "99/99/99"      
         tt-datcl.avista(total)     column-label "Venda!a vista"
                    format ">>,>>>,>>9.99"
         tt-datcl.aprazo(total)     column-label "Venda!a prazo"
                    format ">>,>>>,>>9.99"
         tt-datcl.acrescimo(total)    column-label "Acrescimo"
                    format ">>,>>>,>>9.99"
         tt-datcl.recebimento(total)  column-label "Recebimento"
                    format ">>,>>>,>>9.99"
         tt-datcl.re-CAIXA(total)  column-label "Receb!Caixa"
                                        format ">>,>>>,>>9.99"
         tt-datcl.juro(total)         column-label "Juro!Atrazo"
                    format ">,>>>,>>9.99"
         tt-datcl.devprazo(total)         column-label "Devol.!a prazo"
                    format ">,>>>,>>9.99"
         tt-datcl.estorno(total)         column-label "Estorno"
                    format ">>>,>>9.99"
         tt-datcl.devvista(total)         column-label "Devol.!a vista"
                    format ">,>>>,>>9.99"
         tt-cartcl.visa(total)             column-label "Visa"
                    format ">,>>>,>>9.99"
         tt-cartcl.master(total)           column-label "Master"
                    format ">,>>>,>>9.99"       
         tt-cartcl.banri(total)           column-label "Banri"
                    format ">,>>>,>>9.99"  
         with frame f-disp1 down width 240.
    down with frame f-disp1.

end.

    def var valor as dec.    
    put skip(2).
    put "VENDA VISTA POR MOEDA" skip .
    valor = 0.

    for each ctb-receb where
             ctb-receb.rectp = "VENDA A VISTA" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
        valor = valor + ctb-receb.valor1.
        if last-of(ctb-receb.moecod)
        then do:
            disp ctb-receb.moecod column-label "MOEDA"
                 valor(total) column-label "VALOR"  format ">>>,>>>,>>9.99"
            with frame f-moe down.
            down with frame f-moe.
            valor = 0.
        end.
    end.
                                                                       
    put skip(2).
    put "ENTRADA POR MOEDA" SKIP.
    valor = 0.
    for each ctb-receb where
             ctb-receb.rectp = "ENTRADA" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
        valor = valor + ctb-receb.valor1.
        if last-of(ctb-receb.moecod)
        then do:
            disp ctb-receb.moecod column-label "MOEDA"
                valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
                with frame f-moe1 down.
                down with frame f-moe1.
            valor = 0.
        end.
    end.
    
    /*********                                                                     put skip(2).
    put "TROCA POR MOEDA" SKIP.
    valor = 0.
    for each ctb-receb where
             ctb-receb.rectp = "TROCA" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
        valor = valor + ctb-receb.valor1.
        if last-of(ctb-receb.moecod)
        then do:
            disp ctb-receb.moecod column-label "MOEDA"
                valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe2 down.
            down with frame f-moe2.
            valor = 0.
        end.
    end.
    ******/
                                                                       
    put skip(2).
                                                                                   put "RECEBIMENTO PARCELA" SKIP.
    valor = 0.
    for each ctb-receb where
             ctb-receb.rectp = "PARCELA" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
       valor = valor + ctb-receb.valor1.
       if last-of(ctb-receb.moecod)
       then do:
           disp ctb-receb.moecod column-label "MOEDA"
              valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe3 down.
           down with frame f-moe3.
           valor = 0.
       end.
    end.

    put skip(2).
    put "RECEBIMENTO ACRESCIMO" SKIP.
    valor = 0.
    for each ctb-receb where
             ctb-receb.rectp = "ACRESCIMO" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
       valor = valor + ctb-receb.valor1.
       if last-of(ctb-receb.moecod)
       then do:
           disp ctb-receb.moecod column-label "MOEDA"
              valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe4 down.
           down with frame f-moe4.
           valor = 0.
       end.
    end.
    put skip(2).
    put "RECEBIMENTO JURO ATRASO" SKIP.
    valor = 0.
    for each ctb-receb where
             ctb-receb.rectp = "JURO ATRASO" and
             ctb-receb.datref >= vdti  and
             ctb-receb.datref <= vdtf
             no-lock break by ctb-receb.moecod:
       valor = valor + ctb-receb.valor1.
       if last-of(ctb-receb.moecod)
       then do:
           disp ctb-receb.moecod column-label "MOEDA"
              valor(total) column-label "VALOR" format ">>>,>>>,>>9.99"
              with frame f-moe5 down.
           down with frame f-moe5.
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
