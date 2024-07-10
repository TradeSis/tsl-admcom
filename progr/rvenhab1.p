{admcab.i new}

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
def var vopecod as int.
def buffer bprodu for produ.

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
    field tipo   as    char 
    field tipviv as int
    field codviv as int
    field numero like plani.numero
    field pladat like plani.pladat.
    
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

        vopecod = 0.         
        update skip vopecod label "Operadora." 
               with frame f-dados side-labels.

        if vopecod = 0
        then disp "Geral" @ operadoras.openom with frame f-dados.
        else do:
            find operadoras where operadoras.opecod = vopecod no-lock no-error.
            if not avail operadoras
            then do:
                message "Operadora nao Cadastrada".
                undo.
            end.
            else disp operadoras.openom no-label with frame f-dados.
        end.
    end. 
    
    vdtfi = today.
    vtdma = yes.
    
    update skip
           vdtin    label "Dt.Inicial.."
           vdtfi    label "Dt.Final"
           with frame f-dados.
    
    for each produ where (if vopecod = 1
                          then produ.clacod = 107 
                          else produ.clacod = 201)
                           no-lock:
        
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
                
                find produ where produ.procod = movim.procod no-lock.
                
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
                                   and ttcel.vencod = plani.vencod
                                   and ttcel.numero = plani.numero
                                   no-error.
                if not avail ttcel
                then do:
                    create ttcel.
                    assign
                        ttcel.etbcod = estab.etbcod
                        ttcel.etbnom = estab.etbnom
                        ttcel.procod = movim.procod
                        ttcel.pronom = tt-pro.pronom
                        ttcel.vencod = plani.vencod
                        ttcel.vennom = func.funnom
                        ttcel.numero = plani.numero
                        ttcel.pladat = plani.pladat
                        ttcel.tipo   = tt-pro.tipo
                        ttcel.tipviv = int(
                        acha("TIPVIV" + string(produ.procod),plani.notobs[3]))
                        ttcel.codviv = int(
                        acha("CODVIV" + string(produ.procod),plani.notobs[3]))
                    .
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
    /**
    if vopecod <> 0
        then do:
            find promoviv where promoviv.opecod = vopecod
                            and promoviv.tipviv = habil.tipviv 
                            and promoviv.exportado = yes
                            no-lock no-error.
            if not avail promoviv
            then next.
        end.
    **/
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
                         by ttcel.pladat
                         by ttcel.numero:

        
        if first-of(ttcel.etbcod)
        then do:
            disp ttcel.etbcod label "Filial"
                 ttcel.etbnom no-label
                 with frame f-t1 side-label width 80 no-box.
        end.
        if first-of(ttcel.vencod)
        then do:
            disp ttcel.vencod label "Vendedor"
                 ttcel.vennom no-label
                 with frame f-t2 side-label width 80 no-box.
        end.

        disp ttcel.pladat  column-label "Data"
             ttcel.numero  column-label "Venda"   format ">>>>>>>>9"
             ttcel.procod  column-label "Codigo"
             ttcel.pronom       column-label "Produto"  format "x(30)"
             ttcel.codviv          column-label "Plano" 
             ttcel.tipviv          column-label "Promocao"     
             with frame f-t3 down width 150.
        down with frame f-t3.

        if last-of(ttcel.vencod)
        then do:
            for each habil where habil.etbcod = ttcel.etbcod and
                                 habil.habdat >= vdtin and
                                 habil.habdat <= vdtfi and
                                 habil.vencod = ttcel.vencod /* and
                                 habil.opecod = vopecod    */
                                 no-lock:
                                 /*
                find first tt-pro where
                           tt-pro.procod = habil.procod no-lock no-error.
                if not avail tt-pro
                then next.         */  
                find bprodu where 
                    bprodu.procod = habil.procod no-lock no-error.
                disp habil.procod  column-label "Produto"
                     bprodu.pronom format "x(30)"   when avail bprodu
                                column-label "Descricao"
                     habil.ciccgc   column-label "CGC/CPF"
                     habil.habdat   column-label "Data"
                     habil.codviv   column-label "Plano" format ">>>>9"
                     with frame f-ab down width 80 no-box.
                down with frame f-ab.     
            end.
                                     
        end.

    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.       
end.           
