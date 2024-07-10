{admcab.i }
def var vperiodo as char format "x(30)".
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def stream stela.
def var varquivo as char format "x(20)".
DEF VAR vdia as int format ">99".
def var vimp as log format "80/132" label "Tipo de Impressao".
def var vok as log.
def var vpreco like estoq.estvenda.
def var i as i.
def var vdata like plani.pladat.
def var vqtd  as int format "->>9".
def var vclacod like produ.clacod.
def var vetb2  as int format ">>99" extent 40.
DEF VAR VDPT AS I FORMAT "99" LABEL "Departamento".
DEF VAR VQTDTOT AS INT FORMAT "->>>9" label "TOT.".
def var vcont   as int initial 0.
def var vtip    as char format "XX".
def var vcol as i format ">".
def buffer bestoq for estoq.
def var vesc as int.

    vdata = ?.
    message "Deseja Gerar livro" update sresp.
    
    if sresp = no
    then leave.
    
    if search("/usr/admcom/relat/livro") <> ?
    then do:
        input from /usr/admcom/relat/livro.
        repeat:
            import vdata.
        end.
        input close.
    end.
    
    if vdata = today
    then do:

       os-command silent /fiscal/lp  /usr/admcom/relat/liv. 
       return.
    end.

   
   
    vesc = 0.  
    display "L I V R O   D E   P R E C O" 
            with frame f-cabe side-label centered row 5.
    
    vperiodo = "  GERAL".

    vcont = 0.
    vdia = 90.
    
    find categoria where categoria.catcod = 31 no-lock.
    vcont = 0.
    
    {mdadm132.i
        &Saida     = "/usr/admcom/relat/liv"
        &Page-Size = "64"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = """precoli5.p"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """LIVRO DE PRECO  "" +
                    ""FILIAL "" + string(estab.etbcod)"
        &Width     = "160"
        &Form      = "frame f-cab2"}
         
    for each produ where produ.catcod = categoria.catcod
                                 no-lock break by pronom.
    
        vqtdtot = 0.
        
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
        vok = no.
        vqtdtot = 0.
        for each estab no-lock:
            find bestoq where bestoq.etbcod = estab.etbcod and
                              bestoq.procod = produ.procod no-lock no-error.
                              
            if avail bestoq and bestoq.etbcod >= 95
            then VQTDTOT = VQTDTOT + bestoq.estatual.
            if avail bestoq and bestoq.estatual <> 0 
            then vok = yes.
        end.

        IF VOK = NO 
        THEN NEXT.


        vcol = vcol + 1.
        find estoq where estoq.etbcod = setbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then vqtd = 0.
        else do:
           vqtd = estoq.estatual.
           vpreco = estoq.estvenda.
        end.
        vtip = "".

        find first movim where movim.movdat > (today - vdia) and
                               movim.procod = produ.procod and
                               (movim.movtdc = 4 or
                               movim.movtdc = 5) no-lock no-error.
        if avail movim
        then vtip = "".
        else vtip = "*".

        find first movim where movim.datexp >= (today - 10) and
                               movim.procod = produ.procod and
                               movim.movtdc = 4 no-lock no-error.
        if avail movim
        then vtip = "E".
        if estoq.estprodat <> ?
        then do:
            if estoq.estprodat >= today
            then vtip = string(estoq.estproper).
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
    output close.
    
    
    os-command silent /fiscal/lp  /usr/admcom/relat/liv. 
        
    
    output to /usr/admcom/relat/livro.
        put chr(34) today format "99/99/9999" chr(34).
    output close.

    
    hide frame f-stela no-pause.
