{admcab.i}
def var vlivro as char.
def var vprocod like com.produ.procod.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var v15  like com.estoq.estvenda.

def var vpreco like com.estoq.estvenda.
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
    /*
    update vimp colon 18 with frame f1 side-label width 80.
    */
    {liv.i}
    vlivro =  substring(vliv,35,21).

    
    
    varquivo = "/usr/admcom/relat/liv".
    {confir.i 1 "Livro de Preco"}


    if vimp = no
    then do:
    {mdadm080.i
        &Saida     = "/usr/admcom/relat/liv"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """impliv"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod) + "" livro.txt -->"" +
                      string(vlivro,""x(21)"")"
        &Width     = "160"
        &Form      = "frame f-cab"}
    end.
    else do:
    {mdadm132.i
        &Saida     = "/usr/admcom/relat/liv"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """impliv"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod) + "" livro.txt -->"" + 
                      string(vlivro,""x(21)"")"
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.

    put "CODIGO DESCRICAO                       " 
         "PROM.   VENDA      15X  QTD   EST   " 
         "CODIGO DESCRICAO                       " 
         "PROM.    VENDA     15X  QTD   EST" skip 
            fill("-",136) format "x(136)" skip.
                                                     
   input from ../import/livro.txt.
   repeat:
        import vprocod
               vtip
               vpreco
               vqtdtot
               v15.


        find com.produ where com.produ.procod = vprocod no-lock no-error.
        if not avail com.produ
        then next.

        output stream stela to terminal.
            display stream stela estab.etbcod
                                 com.produ.procod
                                 com.produ.pronom with frame f-stela 1 down.
            pause 0.
        output stream stela close.

        assign vqtd = 0.
        vcol = vcol + 1.
        find commatriz.estoq where 
                         commatriz.estoq.etbcod = estab.etbcod and
                         commatriz.estoq.procod = com.produ.procod 
                                no-lock no-error.
        if not avail commatriz.estoq
        then vqtd = 0.
        else do:
            vqtd = commatriz.estoq.estatual.
            vpreco = commatriz.estoq.estvenda.
           
            if commatriz.estoq.estbaldat <> ?
            then do:
                 if commatriz.estoq.estbaldat <= today and
                    commatriz.estoq.estprodat >= today and 
                    vtip = "" 
                 then vtip = string(commatriz.estoq.estproper).
            end.
            else do:
                if commatriz.estoq.estprodat <> ?
                then if commatriz.estoq.estprodat >= today and vtip = "" 
                     then vtip = string(commatriz.estoq.estproper).
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

             put com.produ.procod space(1) 
                 com.produ.pronom format "x(31)" space(1) 
                 vtip  format "x(4)" space(1) 
                 vpreco format ">,>>9.99" space(1) 
                 v15    format ">,>>9.99" 
                 vqtd space(1)
                 vqtdtot.
                                                                                             
            
        end.
        if vcol = 2
        then do:
            put
                com.produ.procod at 76 space(1)
                com.produ.pronom format "x(31)" space(1)
                vtip format "x(4)" space(1)
                vpreco format ">,>>9.99" space(1)
                v15    format ">,>>9.99"
                vqtd  space(1)
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
    end.
    output close.
    os-command silent /fiscal/lp  /usr/admcom/relat/liv.
               
end.
