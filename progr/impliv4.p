{admcab.i}
def var varquivo as char format "x(20)".

def var vprocod like produ.procod.
def stream stela.
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var v15  like estoq.estvenda.

def var vpreco like estoq.estvenda.
def var vqtd  as int format "->>9".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".

def var vok as log.

def var i as i.
def var vdata like plani.pladat.
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
    
    update vimp with frame f1 side-label centered.

    {confir.i 1 "Livro de Preco"}


    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """impliv"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
        &Saida     = "printer"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """impliv"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.

    


    /*
    varquivo = "l:\relat\liv" + STRING(day(today)) + 
                string(vetbcod,">>9").

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "137"  
        &Page-Line = "66"
        &Nom-Rel   = ""impliv4""  
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""  
        &Tit-Rel   = """LIVRO DE PRECO - FILIAL "" +
                      string(vetbcod,"">>9"")"
        &Width     = "137"
        &Form      = "frame f-cabcab"}
    */
     
    

    
   put "CODIGO DESCRICAO                       " 
         "PROM.   VENDA      15X  QTD   EST   " 
         "CODIGO DESCRICAO                       " 
         "PROM.    VENDA     15X  QTD   EST" skip 
            fill("-",136) format "x(136)" skip.
            
                                                     
   input from l:~\relat~\livro.txt.
                                                  
   repeat:
        import vprocod
               vtip
               vpreco
               vqtdtot
               v15.


        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then next.

        output stream stela to terminal.
            display stream stela estab.etbcod
                                 produ.procod
                                 produ.pronom with frame f-stela 1 down.
            pause 0.
        output stream stela close.

        assign vqtd = 0.
        vcol = vcol + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod  no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
            vqtd = estoq.estatual.
            vpreco = estoq.estvenda.
           
            if estoq.estbaldat <> ?
            then do:
                 if estoq.estbaldat <= today and
                    estoq.estprodat >= today and 
                    vtip = "" 
                 then vtip = string(estoq.estproper).
            end.
            else do:
                if estoq.estprodat <> ?
                then if estoq.estprodat >= today and vtip = "" 
                     then vtip = string(estoq.estproper).
            end.
        end.    
        if vcont = 54
        then do:
            put
                "*  VENDER SOMENTE O ESTOQUE " at 20 skip
                "E  com.produTOS COM ENTRADAS NOS ULTIMOS 20 DIAS" at 20.
            page.

            put "CODIGO DESCRICAO                       " 
                "PROM.   VENDA      15X  QTD   EST   " 
                "CODIGO DESCRICAO                       " 
                "PROM.    VENDA     15X  QTD   EST" skip fill("-",136) format "x(136)" skip.
                                                             
                                                             
            vcont = 0.
        end.

        if vcol = 1
        then do:

             put produ.procod space(1) 
                 produ.pronom format "x(31)" space(1) 
                 vtip  format "x(4)" space(1) 
                 vpreco format ">,>>9.99" space(1) 
                 v15    format ">,>>9.99" 
                 vqtd space(1)
                 vqtdtot.
                                                                                             
            
        end.
        if vcol = 2
        then do:
            put
                produ.procod at 76 space(1)
                produ.pronom format "x(31)" space(1)
                vtip format "x(4)" space(1)
                vpreco format ">,>>9.99" space(1)
                v15    format ">,>>9.99"
                vqtd  space(1)
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
    end.
    input close.
    output close.
    /* {mrod.i} */
    
/*    run visurel.p (input varquivo, input ""). */
               
end.
