{admcab.i}

def buffer bfinan for finan.
def var vlivro as char.
def var vprocod like com.produ.procod.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vcatcod like categoria.catcod.
def var vpreco  like com.estoq.estvenda.
def var v15  like com.estoq.estvenda.

def var vqtd  as int format "->>9".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".

def var vok as log.

def var i as i.
def var vdata like com.plani.pladat.
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def var vetbcod like estab.etbcod.

repeat:

    vcont = 0.
    vimp = yes.

    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
    
    update vcatcod label "Departamento"
                with frame f-dep centered side-label color blue/cyan.
    find categoria where categoria.catcod = vcatcod no-lock.
    disp categoria.catnom no-label with frame f-dep.
    
    vcont = 0.
    
    find bfinan where bfinan.fincod = 17 no-lock no-error.
    
    output to l:\relat\livger.txt.
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.

        output stream stela to terminal.
            display stream stela "Gerando Livro.."
                                 produ.procod
                                 produ.pronom 
                                    with frame f-stela 
                                        1 down no-label centered.
            pause 0.
        output stream stela close.
        
        vqtd = 0.
        vpreco = 0.
 
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        vqtd = estoq.estatual.
        vpreco = estoq.estvenda.

        vtip = "".

        v15 = ((estoq.estvenda * bfinan.finfat) * 15).
        
        if estoq.estprodat <> ?
        then do:
            if estoq.estprodat >= today
            then assign vtip = string(estoq.estproper).
            else vtip = "".
        end.
        
        
        find first simil where simil.procod = produ.procod 
                                no-lock no-error.
        if avail simil
        then vtip = "*" + vtip.
        else do:
            find first movim where movim.datexp >= (today - 20) and
                                   movim.procod = produ.procod and
                                   movim.movtdc = 4 no-lock no-error.
            if avail movim 
            then vtip = "E" + vtip.
        end.
        
        
        if vtip = ""
        then vtip = ".".

 
        

        put produ.procod format "999999" " "
            vtip         format "x(4)"   " "
            vpreco       format ">,>>9.99"  " "
            vqtd         format "->,>>9.99" " "
            v15          format ">,>>9.99"
            skip.

        
    end.
    output close.
    
    varquivo = "l:\relat\livro" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = """livger"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod)"  
        &Width     = "80"
        &Form      = "frame f-cab2"}
    
    put
        "CODIGO DESCRICAO                       "
        "PROM.   VENDA      15X  QTD   "
        "CODIGO DESCRICAO                       "
        "PROM.    VENDA      15X  QTD" skip
                fill("-",136) format "x(136)" skip.
   
   input from l:\relat\livger.txt.
   repeat:

        import vprocod
               vtip
               vpreco
               vqtdtot
               v15.
        

        vqtd = vqtdtot.
        
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then next.
        
        assign vqtd = 0.
        vcol = vcol + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
            vqtd = estoq.estatual.
            vpreco = estoq.estvenda.
            /*if estoq.estprodat <> ?
            then if estoq.estprodat >= today and vtip = "" 
                 then vtip = string(estoq.estproper).*/
        end.    
        
        if vcol = 1
        then do:
            put produ.procod space(1)
                produ.pronom format "x(31)" space(1)
                vtip  format "x(4)" space(1)
                vpreco format ">,>>9.99" space(1)
                v15    format ">,>>9.99"
                vqtdtot.
        end.
        if vcol = 2
        then do:
            put produ.procod at 70 space(1)
                produ.pronom format "x(31)" space(1)
                vtip format "x(5)" space(1)
                vpreco format ">,>>9.99" space(1)
                v15    format ">,>>9.99"
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
    end.
    
    output close.
    {mrod.i}

    /* run visurel.p (input varquivo, input "").*/ 
    
end.
