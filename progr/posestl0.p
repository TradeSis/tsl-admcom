{admcab.i}

def var fila as char.
def var recimp as recid.

def var vetbcod like estab.etbcod.
def var vcatcod like categoria.catcod.
def var varquivo as char.

repeat:

    update vetbcod with frame f1 side-label centered color white/red row 7.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp estab.etbnom no-label skip(1) with frame f1.

    update vcatcod with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    
    disp categoria.catnom no-label with frame f1.

    if opsys = "UNIX"
    then do:
        varquivo = "../relat/neg" + string(time).
   
        /*
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do: 
            run acha_imp.p (input recid(impress),  
                            output recimp). 
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp).
        end.    
        */
    end.        
    else varquivo = "..\relat\neg" + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = """POSESTL0"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE NEGATIVO - ""
                      + estab.etbnom + ""  "" + categoria.catnom "
        &Width     = "80"
        &Form      = "frame f-cab"}

    for each produ no-lock by pronom.

        if produ.catcod <> categoria.catcod
        then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        if estoq.estatual >= 0
        then next.

        if produ.procod >= 10000000
        then next.
        
        display produ.procod column-label "Codigo"
                produ.pronom FORMAT "x(35)"
                estoq.estatual (TOTAL) column-label "Qtd." format "->>>>>>>9"
                estoq.estcusto column-label "Pc.Custo" format ">>,>>9.99"
                (estoq.estatual * estoq.estcusto) (TOTAL) column-label "Total"
                                                       format "->>,>>>,>>9.99"
                with frame f2 down width 90.
    end.
    output close.

    if opsys = "UNIX"
    then do:
        /*
        os-command silent lpr value(fila + " " + varquivo).
        */
        
        run visurel.p(varquivo,"").
        
    end.
    else do:
        fila = "".
        {mrod.i}.
    end.    
end.
