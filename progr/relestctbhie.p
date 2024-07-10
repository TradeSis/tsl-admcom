{admcab.i new}
def var vv as int.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vetbcod like estab.etbcod.
def var vmes as int format "99".
def var vano as int format "9999".
def var varquivo as char.
def var vindex as int.
def var vcusto like ger.ctbhie.ctbcus.
def var tip-custo as char extent 2  FORMAT "x(20)"
        initial["CUSTO NOTA","CUSTO MEDIO"].

def temp-table tt-inv no-undo
    field procod like produ.procod
    field etbcod like estab.etbcod
    field codfis like produ.codfis
    field pronom like produ.pronom
    field qtditem as dec
    field valitem as dec
    field totitem as dec
    index i1 procod etbcod
    .

def temp-table tt-ger no-undo
    field procod like produ.procod
    field codfis like produ.codfis
    field pronom like produ.pronom
    field qtditem as dec
    field valitem as dec
    field totitem as dec
    index i1 procod 
    .

def temp-table tt-nfpro
    field procod like produ.procod
    field nforigem as int 
    field Tpdoc  as char
    field movdat like movim.movdat
    field movqtm like movim.movqtm
    field forcod as int
    field forcgc as char
    field ufecod as char
    field chave as char
    field substit as dec
    field basicms as dec
    field aliicms as dec
    field valicms as dec
    index i1 procod 
    .
    
def var vwidth as int.

def var vqtd-pro like movim.movqtm.

def buffer bctbhie for ger.ctbhie.

def var vi as int.
def var vdatref as date.
def var vtit-rel as char.
repeat:
    update vetbcod with frame f1 side-label.
    if vetbcod > 0
    then do:
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f1.
    end.
    else disp "G E R A L " @ estab.etbnom with frame f1.
    find last ger.ctbhie where ctbhie.etbcod = 1 no-lock no-error.
    if avail ctbhie
    then assign
            vmes = ctbhie.ctbmes
            vano = ctbhie.ctbano
            .
    update vmes label "MES"
           vano label "ANO"
                with frame f1 width 80.
    vdatref = date(if vmes = 12 then 01 else vmes + 1, 01,
                   if vmes = 12 then vano + 1 else vano) .

    vindex = 2.
    
    sresp = no.
    if vetbcod = 0
    then message "Relatorio GERAL por filial?" update sresp.
    
    {confir.i 1 "Listagem de inventario"}
    
    for each ctbhie where (if vetbcod > 0
                            then ctbhie.etbcod = vetbcod 
                            else ctbhie.etbcod > 0) and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano 
                             no-lock:

        if ctbhie.ctbest < 1
        then next.
        if ctbhie.ctbcus <= 0
        then next.
        find produ where produ.procod = ctbhie.procod no-lock no-error.
        if not avail produ
        then next.

        find clafis where clafis.codfis = produ.codfis no-lock no-error.
        
        vcusto = ctbhie.ctbcus.
        find last bctbhie where bctbhie.etbcod = 0 and
                                bctbhie.procod = produ.procod and
                                bctbhie.ctbano <= vano
                                no-lock no-error.
        if avail bctbhie and vindex = 2
        then vcusto = bctbhie.ctbcus.
        
        if vcusto = ?
        then vcusto = 0.      

        if vcusto = 0 then next.
        /*
        vcusto = vcusto - (vcusto * .1617).
        */
        create tt-inv.
        assign
            tt-inv.procod = produ.procod
            tt-inv.etbcod = ctbhie.etbcod
            tt-inv.codfis = produ.codfis
            tt-inv.pronom = produ.pronom
            tt-inv.qtditem = ctbhie.ctbest    
            tt-inv.valitem = vcusto
            tt-inv.totitem = (vcusto * ctbhie.ctbest)
            .

        find first tt-ger where
                   tt-ger.procod = produ.procod 
                   no-error.
        if not avail tt-ger
        then do:
            create tt-ger.
            tt-ger.procod = produ.procod.
            tt-ger.codfis = produ.codfis.
            tt-ger.pronom = produ.pronom.
            tt-ger.valitem = vcusto.
        end.
        tt-ger.qtditem = tt-ger.qtditem + ctbhie.ctbest.           

    end.
    if vetbcod = 0 and not sresp
    then
    for each tt-ger:
        find produ where produ.procod = tt-ger.procod no-lock.
        tt-ger.totitem = tt-ger.valitem * tt-ger.qtditem. 
        vqtd-pro = 0.
        find last movim where
                  movim.procod = produ.procod and
                  /*movim.desti = vetbcod and */
                  movim.movdat < vdatref and
                  movim.movtdc = 4 /*
                  movim.movtdc <> 5 and
                  movim.movtdc <> 30 and
                  movim.movtdc <> 65 and
                  movim.movtdc <> 45 and
                  movim.movtdc <> 76 and
                  movim.movtdc <> 18 and
                  movim.movtdc <> 8  */
                  no-lock no-error.
        if avail movim
        then repeat:          
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat
                             no-lock no-error.
            if avail plani 
            then do:
                find tipmov where tipmov.movtdc = plani.movtdc no-lock.
                find forne where forne.forcod = plani.emite no-lock
                        no-error.
                create tt-nfpro.
                assign 
                    tt-nfpro.procod = produ.procod
                    tt-nfpro.nforigem = plani.numero
                    tt-nfpro.tpdoc  = substr(tipmov.movtnom,1,5)
                    tt-nfpro.movdat = movim.movdat
                    tt-nfpro.movqtm = movim.movqtm
                    tt-nfpro.forcod = if avail forne then forne.forcod
                                        else 0
                    tt-nfpro.forcgc = if avail forne then forne.forcgc
                                        else ""
                    tt-nfpro.ufecod = if avail forne then forne.ufecod
                                        else ""
                    tt-nfpro.chave  = plani.ufdes
                    /*tt-nfpro.substit = plani.icmssubst
                    tt-nfpro.basicms = plani.bicms
                    tt-nfpro.aliicms = movim.movalicms
                    tt-nfpro.valicms = movim.movicms*/
                    tt-nfpro.substit = movim.movsubst
                    tt-nfpro.basicms = movim.movpc * movim.movqtm
                    tt-nfpro.aliicms = movim.movalicms
                    tt-nfpro.valicms = movim.movicms
                     .
                if tt-nfpro.chave = ""
                then do:
                    find a01_infnfe where
                         a01_infnfe.emite = plani.emite and
                         a01_infnfe.serie = plani.serie and
                         a01_infnfe.numero = plani.numero
                         no-lock no-error.
                    if avail a01_infnfe
                    then tt-nfpro.chave = a01_infnfe.id.     
                end.                       
            end.
            
            vqtd-pro = vqtd-pro + movim.movqtm.
            
            if vqtd-pro >= tt-ger.qtditem
            then leave.
            
            find prev movim where
                  movim.procod = produ.procod and
                  /*movim.desti = vetbcod and*/
                  movim.movdat < vdatref and
                  movim.movtdc = 4 /*
                  movim.movtdc <> 5 and
                  movim.movtdc <> 30 and
                  movim.movtdc <> 65 and
                  movim.movtdc <> 45 and
                  movim.movtdc <> 76 and
                  movim.movtdc <> 18 and
                  movim.movtdc <> 8  */
                  no-lock no-error.
            if not avail movim then leave.
        end.
    end.

    varquivo = "/admcom/relat/relest_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + "." + string(time).
    if vetbcod > 0
    then assign
             vwidth = 120
             vtit-rel = estab.etbnom.
    else do:
        if sresp then vwidth = 120.
                 else vwidth = 225.
            vtit-rel = "G E R A L".
    end. 
     {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = vwidth
        &Page-Line = "66"
        &Nom-Rel   = """."""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ESTOQUE "" + vtit-rel + ""  "" +
                        "" Periodo: "" + string(vmes,""99"") +
                        ""/"" + string(vano,""9999"")"
        &Width     = vwidth
        &Form      = "frame f-cab"}

     if vetbcod = 0 and not sresp
     then 
     for each tt-ger:
        
        find produ where produ.procod = tt-ger.procod no-lock no-error.
        if avail produ
        then do: 
            display produ.procod column-label "Produto" 
                produ.codfis column-label "NCM" format ">>>>>>>>9"
                produ.pronom FORMAT "x(30)" column-label "Descricao do Produto"
                tt-ger.qtditem format ">>>>>>9" 
                                column-label "Quntidade!Estoque" 
                tt-ger.valitem column-label "Valor!Custo" format ">,>>>,>>9.99"
                tt-ger.totitem(total) column-label "Valor!Total" format ">>>,>>>,>>9.99"
                with frame f2 down width 255.
            for each tt-nfpro where tt-nfpro.procod = produ.procod:
                disp 
                    tt-nfpro.nforigem format ">>>>>>>>9" 
                                            column-label "Documento!Origem"
                    /*tt-nfpro.tpdoc format "x(5)"         column-label "TpDoc"
                    tt-nfpro.movdat                      column-label "DtMov"
                    */
                    tt-nfpro.movqtm   format ">>>>>9"    column-label "QtMov"
                    tt-nfpro.forcod   format ">>>>>>9"   column-label "Fornec"
                    tt-nfpro.forcgc   format "x(13)"     column-label "CNPJ"
                    tt-nfpro.ufecod   format "xx"
                    tt-nfpro.substit  column-label "ST"
                    tt-nfpro.basicms  column-label "Base!ICMS" 
                                        format ">>,>>>,>>9.99"
                    tt-nfpro.aliicms  column-label "Aiq!ICMS"
                    tt-nfpro.valicms  column-label "Val!ICMS"
                    tt-nfpro.chave    format "x(44)"
                    with frame f2
                    .
                down with frame f2.
            end.    
            down with frame f2.
        end.        
    end.
    if vetbcod = 0 and sresp
    then 
    for each tt-inv:
        
        find produ where produ.procod = tt-inv.procod no-lock no-error.
        if avail produ
        then do: 
            display tt-inv.etbcod column-label "Fil"
                produ.procod column-label "Produto" 
                produ.codfis column-label "NCM" format ">>>>>>>>9"
                produ.pronom FORMAT "x(30)" column-label "Descricao do Produto"
                tt-inv.qtditem format ">>>>>>9" 
                                column-label "Quntidade!Estoque" 
                tt-inv.valitem column-label "Valor!Custo" format ">,>>>,>>9.99"
                tt-inv.totitem(total) column-label "Valor!Total" format ">>>,>>>,>>9.99"
                with frame f3 down width 120.
                .
            down with frame f3.
        end.        
    end.  
    if vetbcod > 0
    then
    for each tt-inv where tt-inv.etbcod = vetbcod:
        
        find produ where produ.procod = tt-inv.procod no-lock no-error.
        if avail produ
        then do: 
            display 
                produ.procod column-label "Produto" 
                produ.codfis column-label "NCM" format ">>>>>>>>9"
                produ.pronom FORMAT "x(30)" column-label "Descricao do Produto"
                tt-inv.qtditem format ">>>>>>9" 
                                column-label "Quntidade!Estoque" 
                tt-inv.valitem column-label "Valor!Custo" format ">,>>>,>>9.99"
                tt-inv.totitem(total) column-label "Valor!Total" format ">>>,>>>,>>9.99"
                with frame f4 down width 120.
                .
            down with frame f4.
        end.        
    end. 
    output close.
    run visurel.p(varquivo,"").        
    leave. 
end. 
