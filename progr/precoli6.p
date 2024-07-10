{admcab.i}
def var vlivro as char.
def var vprocod like com.produ.procod.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".

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


    varquivo = "..\relat\livro" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = """precoli5"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod)"  
        &Width     = "80"
        &Form      = "frame f-cab2"}
    
    put
        "CODIGO-D DESCRICAO                             "
        "PROM.  VENDA    QTD    EST      "
        "CODIGO-D DESCRICAO                              "
        "PROM.    VENDA   QTD    EST " skip
                fill("-",148) format "x(148)" skip.

   input from ..\relat\livro.txt.
   repeat:
        import vprocod
               vtip
               vpreco
               vqtdtot.

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
                         estoq.procod = com.produ.procod no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
            vqtd = estoq.estatual.
            vpreco = estoq.estvenda.
            if estoq.estprodat <> ?
            then if estoq.estprodat >= today and vtip = "" 
                 then vtip = string(estoq.estproper).
        end.    
        /*
        if vcont = 60
        then do:
            /*
            put
                "*  VENDER SOMENTE O ESTOQUE " at 20 skip
                "E  PRODUTOS COM ENTRADAS NOS ULTIMOS 20 DIAS" at 20.
            
            page.
            */
            
            put SKIP
                "CODIGO-D DESCRICAO                         "
                "PROM.   VENDA    QTD   EST    "
                "CODIGO-D DESCRICAO                                "
                "PROM.   VENDA   QTD   EST " skip
                    fill("-",148) format "x(148)" skip.
            vcont = 0.
        end.
        */
        
        if vcol = 1
        then do:
            put
                produ.procod space(1)
                produ.pronom format "x(40)" 
                vtip  format "x(4)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd   space(2)
                vqtdtot space(1).
        end.
        if vcol = 2
        then do:
            put
                produ.procod at 81 space(1)
                produ.pronom format "x(40)" 
                vtip format "x(5)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd  space(2)
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
    end.
    output close.
    {mrod.i}
               
end.
