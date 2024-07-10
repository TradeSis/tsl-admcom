{admcab.i}
def input parameter vperiodo as char format "x(30)".
def var vprocod like produ.procod.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".

def var vpreco like estoq.estvenda.
def var vqtd  as int format "->>9".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".

def var vok as log.

def var i as i.
def var vdata like plani.pladat.
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.
def var vetbcod like estab.etbcod.

do:

    vcont = 0.
    
    update vetbcod label "Filial" colon 18 with frame f1. 
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
                    ""FILIAL "" + string(estab.etbcod) + vperiodo"
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
                    ""FILIAL "" + string(estab.etbcod) + vperiodo"
        &Width     = "160"
        &Form      = "frame f-cab2"}
    end.
    put
        "CODIGO-D DESCRICAO                                   "
  "PROM.  VENDA    QTD   EST   "
        "CODIGO-D DESCRICAO                                 "
  "PROM.    VENDA   QTD    EST " skip
        fill("-",160) format "x(160)" skip.

   input from l:\work\livro.txt.
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
        for each estoq where estoq.procod = produ.procod no-lock.
            vqtd = vqtd + estoq.estatual.
        end.    
        if vcont = 54
        then do:
            put
                "*  NAO MOVIMENTADOS DESDE " at 20 today - vdia 
                    format "99/99/9999" skip
                "P  PRODUTOS EM PROMOCAO" at 20 skip
                "E  PRODUTOS COM ENTRADAS NOS ULTIMOS 10 DIAS" at 20.
            page.

            put
                "CODIGO-D DESCRICAO                                    "
                "PROM.   VENDA   QTD   EST   "
                "CODIGO-D DESCRICAO                                  "
                "PROM.   VENDA   QTD   EST " skip
                    fill("-",160) format "x(160)" skip.
            vcont = 0.
        end.

        if vcol = 1
        then do:
            put
                produ.procod space(1)
                produ.pronom format "x(45)" space(1)
                vtip  format "x(4)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd   space(2)
                vqtdtot space(1).
        end.
        if vcol = 2
        then do:
            put
                produ.procod at 81 space(1)
                produ.pronom format "x(45)" space(1)
                vtip format "x(5)" space(1)
                vpreco format ">,>>9.99" space(2)
                vqtd  space(2)
                vqtdtot skip.
            vcont = vcont + 1.
            vcol = 0.
        end.
    end.
    input close.
    output close.
end.
