{admcab.i}
def var forne-vendedor as int   format ">>>>>>>>9".
def var forne-gerente  as int   format ">>>>>>>>9".
def var forne-supervisor as int format ">>>>>>>>9".
def var forne-promotor as int   format ">>>>>>>>9".
def var cod-forne as int        format ">>>>>>>>9".

def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "../relat/prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
    else varquivo = "..\relat\prom" + string(day(today),"99") 
                                       + string(month(today),"99") 
                                       + string(year(today),"9999")
                                       + "." + string(time).
                                  
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""ctpromoc"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """LISTAGEM DE PROMOCOES""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

for each ctpromoc where dtfim >= today and
        linha = 0 and
        geradespesa = yes
         no-lock      .

    assign
        cod-forne = int(acha("FORNECEDOR",ctpromoc.campochar[2]))
        forne-vendedor   = int(acha("FORNE-VENDEDOR",ctpromoc.campochar[2]))
        forne-gerente    = int(acha("FORNE-GERENTE",ctpromoc.campochar[2]))
        forne-supervisor = int(acha("FORNE-SUPERVISOR",ctpromoc.campochar[2]))
        forne-promotor   = int(acha("FORNE-PROMOTOR",ctpromoc.campochar[2]))
        .                                              

    disp ctpromoc.sequencia    no-label
         ctpromoc.descricao[1] no-label format "x(65)"
         ctpromoc.descricao[2] at 12 no-label    format "x(65)"
         with frame f-disp .
    if cod-forne <> ?
    then do:
        find foraut where foraut.forcod = cod-forne no-lock no-error.
        put "FORNECEDOR GERAL      :" cod-forne " - ".
        if avail foraut
        then  put foraut.fornom.
        put skip.
    end.
    if forne-vendedor <> ?
    then do:
        find foraut where foraut.forcod = forne-vendedor no-lock no-error.
        put "FORNECEDOR VENDEDOR   :" forne-vendedor " - ".
        if avail foraut
        then  put foraut.fornom.
        put skip.
    end.
    if forne-gerente <> ?
    then do:
        find foraut where foraut.forcod = forne-gerente no-lock no-error.
        put "FORNECEDOR GERENTE    :"forne-gerente " -" .
        if avail foraut
        then  put foraut.fornom.
        put skip.
    end.
    if forne-supervisor <> ?
    then do:
        find foraut where foraut.forcod = forne-supervisor no-lock no-error.
        put "FORNECEDOR SUPERVISOR :" forne-supervisor " - ".
        if avail foraut
        then  put foraut.fornom.
        put skip.
    end.
    if forne-promotor <> ?
    then do:
        find foraut where foraut.forcod = forne-promotor no-lock no-error.
        put "FORNECEDOR PROMOTOR   :" forne-promotor " - ".
        if avail foraut
        then  put foraut.fornom.
        put skip.
    end.
end.

output close.
    
    IF opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"") .
    end.
    else do:
        {mrod.i}
    end.
