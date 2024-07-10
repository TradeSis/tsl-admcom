{admcab.i}

def var vtot-etb-qtd like movim.movqtm.
def var vtot-etb-val like movim.movpc.

def var vtipo as char.

def var v1 like movim.movqtm.
def var v2 like movim.movpc.

def var vetbqtd-pre like movim.movqtm.
def var vetbval-pre like movim.movpc.
def var vetbqtd-pos like movim.movqtm.
def var vetbval-pos like movim.movpc.

def var vtipo2 as char.

def var vtot-ven-qtd like movim.movqtm.
def var vtot-ven-val like movim.movpc.

def var vtdma as log format "Sim/Nao".

def var vdata    as   date format "99/99/9999".
def var vdtin    as   date format "99/99/9999".
def var vdtfi    as   date format "99/99/9999".
def var varquivo as   char.
def var vetbcod  like estab.etbcod.
def var vvencod   like plani.vencod.

def temp-table ttcel
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field procod like produ.procod
    field pronom like produ.pronom
    field celular like habil.celular
    field vencod like plani.vencod
    field vennom like func.funnom
    field qtd    like movim.movqtm
    field pre    like movim.movpc
    field tipo   as    char .
    
def temp-table tt-pro
    field procod like produ.procod
    field pronom like produ.pronom
    field tipo   as   char.

form 
    with frame  fxx width 130.
    
repeat:
    
    for each ttcel: delete ttcel. end.
    for each tt-pro: delete tt-pro. end.
    
    assign vetbcod = 0
           vvencod = 0
           vdtin   = ?
           vdtfi   = ?
           vtot-ven-qtd = 0
           vtot-ven-val = 0
           vtot-etb-qtd = 0
           vtot-etb-val = 0
           v1 = 0 v2 = 0
           vtipo = "" vtipo2 = "".
           
    do on error undo:
        
        update vetbcod label "Filial......"
            help "Informe o Codigo da Filial ou Zero para Todas"
           with frame f-dados side-labels width 80.
    
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao Cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Todas" @ estab.etbnom with frame f-dados.
           
    end.
    
    do on error undo:
        update skip
               vvencod  label "Vendedor...."
               with frame f-dados side-labels.

        if vvencod <> 0
        then do:
            if vetbcod <> 0
            then do:
                find func where func.etbcod = vetbcod
                            and func.funcod = vvencod no-lock no-error.
                if not avail func
                then do:
                    message "Vendedor nao cadastrado para esta filial.".
                    undo.
                end.
                else disp func.funnom no-label with frame f-dados.
            end.
            else do:
                find first func where func.funcod = vvencod no-lock no-error.
                if not avail func
                then do:
                    message "Vendedor nao cadastrado.".
                    undo.
                end.
                else disp func.funnom no-label with frame f-dados.
            end.
        end.
        else disp "TODOS" @ func.funnom with frame f-dados.
    end.
    
    vdtfi = today.
    vtdma = yes.
    
    update skip
           vtdma    label "Somente TDMA" skip
           vdtin    label "Dt.Inicial.."
           vdtfi    label "Dt.Final"
           with frame f-dados.
    
    for each produ where produ.clacod = 101 no-lock:
        
        if vtdma
        then do:
            if not produ.pronom matches "*TDMA*"
            then next.
        end.
        
        find tt-pro where tt-pro.procod = produ.procod no-error.
        if not avail tt-pro
        then do:
            create tt-pro.
            assign tt-pro.procod = produ.procod
                   tt-pro.pronom = produ.pronom.

            if produ.pronom matches "*POS*"
            then tt-pro.tipo = "POS".
            else 
            if produ.pronom matches "*PRE*"
            then tt-pro.tipo = "PRE".
        end.
    end.
    
    
    for each tt-pro where tt-pro.tipo = "": delete tt-pro. end.

    do vdata = vdtin to vdtfi:
        for each tt-pro:
            for each estab where if vetbcod = 0 
                                 then true
                                 else estab.etbcod = vetbcod no-lock,
                each movim where movim.etbcod = estab.etbcod
                             and movim.movtdc = 5
                             and movim.procod = tt-pro.procod
                             and movim.movdat = vdata no-lock:
                             
                find first plani where plani.etbcod = movim.etbcod
                                   and plani.placod = movim.placod
                                   and plani.movtdc = movim.movtdc
                                   and plani.pladat = movim.movdat
                                   no-lock no-error.
                if not avail plani
                then next.
                
                find func where func.etbcod = estab.etbcod
                            and func.funcod = plani.vencod no-lock no-error.

                find clien where clien.clicod = plani.desti no-lock no-error.
                /*if avail clien
                then find first habil where 
                          habil.ciccgc = clien.ciccgc and
                          habil.procod = movim.procod
                          no-lock no-error.*/
                
                find first ttcel where ttcel.etbcod = movim.etbcod
                                   and ttcel.procod = movim.procod
                                   and ttcel.vencod = plani.vencod no-error.
                if not avail ttcel
                then do:
                    create ttcel.
                    assign
                        ttcel.etbcod = estab.etbcod
                        ttcel.etbnom = estab.etbnom
                        ttcel.procod = movim.procod
                        ttcel.pronom = tt-pro.pronom
                        ttcel.vencod = plani.vencod
                        ttcel.tipo   = tt-pro.tipo.
                    
                    /*if avail habil
                    then ttcel.celular = habil.celular.*/
                    
                    if avail func
                    then ttcel.vennom = func.funnom.
                    
                end.
                assign ttcel.qtd = ttcel.qtd + movim.movqtm
                       ttcel.pre = ttcel.pre + movim.movpc.
            end.       
        end.
    end.
    
    if opsys = "UNIX"
    then varquivo = "../relat/venviv" + string(time).
    else varquivo = "..\relat\venviv" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "0"
        &Nom-Rel   = ""kitpre""
        &Nom-Sis   = """SISTEMA DE VENDA""" 
        &Tit-Rel   = """RELATORIO VIVO "" + "" FILIAL ""
                        + string(vetbcod) + "" PERIODO DE: "" +
                        string(vdtin,""99/99/9999"") + 
                      "" ATE "" + string(vdtfi,""99/99/9999"") " 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    
    
    for each ttcel break by ttcel.etbcod
                         by ttcel.vencod
                         by ttcel.tipo
                         by ttcel.pronom:

        
        if first-of(ttcel.etbcod)
        then do:
            assign vtot-etb-val = 0
                   vtot-etb-qtd = 0
                   vetbval-pre  = 0
                   vetbqtd-pre  = 0
                   vetbval-pos  = 0
                   vetbqtd-pos  = 0.
                   
            disp ttcel.etbcod label "Filial"
                 ttcel.etbnom  no-label
                 skip(1)
                 with frame f-t side-labels.
        end.
        
        if first-of(ttcel.vencod)
        then do:
            assign vtot-ven-val = 0
                   vtot-ven-qtd = 0.
            
            disp ttcel.vencod label "Vendedor" at 3
                 ttcel.vennom no-label
                 skip(1)
                 with frame f-v side-labels.
        end.
        
        if first-of(ttcel.tipo)
        then do:

            disp CAPS(ttcel.tipo) label "Tipo" at 5
                 skip
                 with frame f-ta side-labels.
                 
        end.
        
        assign vtot-etb-qtd = vtot-etb-qtd + ttcel.qtd
               vtot-ven-qtd = vtot-ven-qtd + ttcel.qtd
               vtot-etb-val = vtot-etb-val + ttcel.pre
               vtot-ven-val = vtot-ven-val + ttcel.pre
               v1 = v1 + ttcel.qtd
               v2 = v2 + ttcel.pre.
               
        if ttcel.tipo = "PRE"
        then
               assign vetbqtd-pre = vetbqtd-pre + ttcel.qtd
                      vetbval-pre = vetbval-pre + ttcel.pre.
        if ttcel.tipo = "POS"
        then
               assign vetbqtd-pos = vetbqtd-pos + ttcel.qtd
                      vetbval-pos = vetbval-pos + ttcel.pre.
               
                    
        disp ttcel.procod at 8 column-label "Codigo"
             ttcel.pronom       column-label "Produto"
             ttcel.qtd          column-label "Qtd. Vendida" 
             ttcel.pre          column-label "Valor"     
             with frame f-c width 100 down.
        down with frame f-c.

        vtipo = "".
        vtipo = "TOTAL POR VENDEDOR - " + ttcel.tipo.
        
        if last-of(ttcel.tipo)
        then do:
            put  skip(1)
                 "------------" to 77
                 "--------------" to 92 skip
                 vtipo format "x(50)" at 15
                 v1                   to 77
                 v2                   to 92
                 skip.
            v1 = 0. v2 = 0.
        end.
        
        if last-of(ttcel.vencod)
        then do:
            put  skip(1)
                 "------------" to 77
                 "--------------" to 92 skip
                 "TOTAL POR VENDEDOR - PRE+POS" at 15
                 vtot-ven-qtd                   to 77
                 vtot-ven-val                   to 92
                 skip.
            vtot-ven-qtd = 0. vtot-ven-val = 0.     
        end.
        if last-of(ttcel.etbcod)
        then do:
            put 
                 skip(1)
                 "TOTAL POR FILIAL - PRE" at 15
                 vetbqtd-pre                 to 77
                 vetbval-pre                 to 92
                 skip
                 "TOTAL POR FILIAL - POS" at 15
                 vetbqtd-pos                 to 77
                 vetbval-pos                 to 92
                 skip
                 "------------" to 77
                 "--------------" to 92 skip
                             
                 skip
                 "TOTAL POR FILIAL - PRE+POS" at 15
                 vtot-etb-qtd                 to 77
                 vtot-etb-val                 to 92
                 skip(2).
            vetbqtd-pre = 0. vetbval-pre = 0.
            vetbqtd-pos = 0. vetbval-pos = 0.
            vtot-etb-qtd = 0. vtot-etb-val = 0.
        end.
        
    end.

    if opsys = "UNIX"
    then do:
        output close.
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.       
end.           
