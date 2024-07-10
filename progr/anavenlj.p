{admcab.i}

def var vrel as char.
def var v-etbcod like estab.etbcod.
def var v-data1  as date format "99/99/9999".
def var v-catcod like categoria.catcod.
def var v-movtdc like tipmov.movtdc.
def var v-tipo as int.
def var vfilial as char.
def var vdt as date.
def var sal-atu as int.
def var vmovtnom like tipmov.movtnom.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].
def var vv as char format "x".
              
def temp-table tt-produ 
    field procod like produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like plani.numero
    field movtdc like plani.movtdc    
    field plano  like plani.pedcod
    field vende  like plani.vencod

    index tt numero desc
             procod desc.
    
def var varquivo as char format "x(20)".
def stream stela.
def var vtipmov like tipmov.movtnom.

def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.

def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vtotpro like plani.platot.

def var vpdf as char no-undo.

              /**** Campo usado para guardar o no. da planilha ****/

form plani.pladat format "99/99/99"
     plani.numero format ">>>>>>9"
     plani.emite column-label "Emite"
     plani.desti column-label "Dest" format ">>>>>>>>>9"
     movim.procod
     produ.pronom format "x(40)"
     movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     movim.movpc  format ">,>>9.99"   column-label "V.Unitár"
     vtotpro      format ">>>,>>9.99" column-label "Total"     
     vtipmov column-label "Movimento" format "x(18)"
     sal-atu column-label "saldo" format "->>>>>9" 
     with frame f-val down no-box width 200.

find estab where estab.etbcod = setbcod no-lock no-error.

for each tt-produ.
    delete tt-produ.
end.

form plani.pladat format "99/99/99"
     plani.numero format ">>>>>>9"
     plani.emite column-label "Emite"
     plani.desti column-label "Dest" format ">>>>>>>>>9"
     movim.procod
     produ.pronom format "x(40)"
     movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     movim.movpc  format ">,>>9.99"
     vtotpro column-label "Total"
     vtipmov column-label "Movimento" format "x(18)"
     sal-atu column-label "saldo" format "->>>>>9" 
     with frame f-val down no-box width 200.

do on error undo:
    v-etbcod = setbcod.
    
    disp v-etbcod label "Filial.........."
         with frame f-analitico1.
         
    update v-data1 label "Data"
           with frame f-analitico1 side-labe centered row 4.

    update v-movtdc label "Cod.Movimentacao" at 1
        help "[5]Venda,[6]Transf,[7]Ajuste Acr,[8]Ajuste Dec,[12]devolucao"
            with frame f-analitico1.
    
    if v-movtdc = 0
    then display "GERAL" @ tipmov.movtnom no-label
         with frame f-analitico1.
    else do:
        find tipmov where tipmov.movtdc = v-movtdc no-lock no-error.
        if not avail tipmov
        then do:
            message "Codigo invalido".
            undo, retry.
        end.
        display tipmov.movtnom no-label with frame f-analitico1.
    end.                    

    update v-catcod label "Departamento"
               with frame f-analitico2 centered side-label.
           
        find categoria where categoria.catcod = v-catcod no-lock no-error.
        if avail categoria
        then disp categoria.catnom no-label
                  with frame f-analitico2.
end.
   
    pause 0.
    
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered.
    v-tipo = frame-index.

    if v-tipo = 1
    then vv = "N".
    else if v-tipo = 2
    then vv = "A".
    else vv = "F".

varquivo = "/admcom/relat/anavenlj" + string(mtime).

{mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "143"
        &Page-Line = "66"
        &Nom-Rel   = ""anavenlj""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  FILIAL"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(setbcod) +
                    ""  - Data: "" + string(v-data1)"
        &Width     = "143"
        &Form      = "frame f-cabcab"}

disp categoria.catcod label "Departamento"
     categoria.catnom no-label with frame f-dep2 side-label.
            
for each tipmov where (if v-movtdc = 0
                           then true else tipmov.movtdc = v-movtdc) no-lock:
        
    for each plani where plani.pladat = v-data1       and
                                    plani.movtdc = tipmov.movtdc and
                                    plani.desti  = setbcod       no-lock:
     
        if plani.movtdc = 30
        then next.
                
        for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat 
                               no-lock:
    
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod <> v-catcod
            then next.
        
            if plani.movtdc = 05   or
               plani.movtdc = 12   or
               plani.movtdc = 16   or
               plani.movtdc = 13
            then next.
            
            if (plani.movtdc = 4  or
                plani.movtdc = 1) and setbcod < 96
            then next.
                               
            find first tt-produ where tt-produ.prorec = recid(movim) no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign
                    tt-produ.procod = produ.procod
                    tt-produ.pronom = produ.pronom
                    tt-produ.prorec = recid(movim)
                    tt-produ.numero = plani.numero
                    tt-produ.movtdc = plani.movtdc
                    tt-produ.vende  = plani.vencod
                    tt-produ.plano  = plani.pedcod.
                   
                if tt-produ.movtdc = 06
                then tt-produ.movtdc = 09.
            end.
        end.
    end.
end.

for each tipmov where if v-movtdc = 0
                              then true
                              else tipmov.movtdc = v-movtdc 
                    no-lock:

    for each plani where plani.pladat = v-data1       and
                                plani.movtdc = tipmov.movtdc and
                                plani.etbcod = setbcod no-lock:

        if plani.movtdc = 30
        then next.
     
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
    
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod <> v-catcod
            then next.
        
            if plani.movtdc = 13
            then next.
        
            if (plani.movtdc = 4 or
                plani.movtdc = 1) and v-etbcod < 96
            then next.

            find first tt-produ where tt-produ.prorec = recid(movim) no-error.
            if not avail tt-produ
            then do:                     
                create tt-produ.
                assign tt-produ.procod = produ.procod
                       tt-produ.pronom = produ.pronom
                       tt-produ.prorec = recid(movim)
                       tt-produ.numero = plani.numero
                       tt-produ.movtdc = plani.movtdc
                       tt-produ.vende  = plani.vencod
                       tt-produ.plano  = plani.pedcod.
            end.
        end.
    end.
end.

if vv = "A"
then do:
    for each tt-produ by tt-produ.pronom:
        find movim where recid(movim) = tt-produ.prorec no-lock.
        find produ where produ.procod = movim.procod no-lock.
            
        sal-atu = 0.
        find estoq where estoq.etbcod = v-etbcod and
                         estoq.procod = produ.procod 
                   no-lock no-error.
        if avail estoq
        then sal-atu = estoq.estatual.
            
        find first plani where plani.movtdc = movim.movtdc and
                                      plani.etbcod = movim.etbcod and
                                      plani.placod = movim.placod and
                                      plani.pladat = movim.movdat 
                                        no-lock no-error.
        if not avail plani
        then next.
            
            if plani.emite <> v-etbcod and
               plani.desti <> v-etbcod
            then next.

            if plani.movtdc = 13
            then next.
            
            if (plani.movtdc = 4 or
                plani.movtdc = 1) and v-etbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc 
                        no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = v-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        
            display plani.pladat format "99/99/99"
                    plani.numero format ">>>>>>9"
                    plani.pedcod  format ">>>9" column-label "Plano"
                    plani.vencod  format ">>>>9" column-label "Vend."
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  format ">,>>9.99"   column-label "V.Unitár"
                    vtotpro      format ">>>,>>9.99" column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu column-label "Saldo" format "->>>>>9" 
                    "   " column-label "Con!tag"
                    "   " column-label "Div!erg"
                    with frame f-val1 down no-box width 200.
                    down with frame f-val1.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
    end.
    display vtotmovim label "Total" with frame f-tot1 side-label.
end.
    
if vv = "N"
then do:
    for each tt-produ by tt-produ.procod:
            find movim where recid(movim) = tt-produ.prorec no-lock.
            
            find produ where produ.procod = movim.procod 
                        no-lock no-error.
            
            sal-atu = 0.
            find estoq where 
                        estoq.etbcod = v-etbcod and
                        estoq.procod = produ.procod 
                                                    no-lock no-error.
            if avail estoq
            then sal-atu = estoq.estatual.
            
            find first plani where plani.movtdc = movim.movtdc and
                                      plani.etbcod = movim.etbcod and
                                      plani.placod = movim.placod and
                                      plani.pladat = movim.movdat 
                                no-lock no-error.
            if not avail plani
            then next.
           
            if plani.movtdc = 13 
            then next.
            
            if plani.emite <> v-etbcod and
               plani.desti <> v-etbcod
            then next.

            if (plani.movtdc = 4 or
                plani.movtdc = 1) and v-etbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = v-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).

            display plani.pladat format "99/99/99"
                    plani.numero format ">>>>>>9"
                    plani.pedcod  format ">>>9" column-label "Plano"
                    plani.vencod  format ">>>>9" column-label "Vend."
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  format ">,>>9.99"   column-label "V.Unitár"
                    vtotpro      format ">>>,>>9.99" column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu  column-label "Saldo" format "->>>>>9" 
                    "   " column-label "Con!tag"
                    "   " column-label "Div!erg"
                    with frame f-val2 down no-box width 200.
                    down with frame f-val2.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm).
    end.
    display vtotmovim label "Total" with frame f-tot2 side-label.
end.
    
if vv = "F"                       
then do:                              
    for each tt-produ by tt-produ.numero
                          by tt-produ.procod   :
        find movim where recid(movim) = tt-produ.prorec no-lock.
            
        find produ where produ.procod = movim.procod no-lock no-error.
            
        sal-atu = 0.
        find estoq where 
                        estoq.etbcod = v-etbcod and
                        estoq.procod = produ.procod
                   no-lock no-error.
            if avail estoq
            then sal-atu = estoq.estatual.
            
            find first plani where plani.etbcod = movim.etbcod and
                                      plani.placod = movim.placod and
                                      plani.movtdc = movim.movtdc and
                                      plani.pladat = movim.movdat 
                                use-index plani no-lock no-error.     
            if not avail plani
            then next.
           
            if plani.emite <> v-etbcod and
               plani.desti <> v-etbcod
            then next.

            if plani.movtdc = 13
            then next.
            
            if (plani.movtdc = 4 or
                plani.movtdc = 1) and v-etbcod < 96
            then next.

            find tipmov where tipmov.movtdc = plani.movtdc no-lock no-error.
            if not avail tipmov
            then next.

            if plani.movtdc = 6
            then if plani.emite = v-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(tipmov.movtnom,"x(18)").

            vtotpro = (movim.movpc * movim.movqtm).
        
            display plani.pladat format "99/99/99"
                    plani.numero format ">>>>>>9"
                    plani.pedcod  format ">>>9" column-label "Plano"
                    plani.vencod  format ">>>>9" column-label "Vend."
                    plani.emite column-label "Emite"
                    plani.desti column-label "Dest" format ">>>>>>>>>9"
                    movim.procod
                    produ.pronom when avail produ format "x(25)"
                    movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    movim.movpc  format ">,>>9.99"   column-label "V.Unitár"
                    vtotpro      format ">>>,>>9.99" column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu column-label "Saldo" format "->>>>>9" 
                    "   " column-label "Con!tag"
                    "   " column-label "Div!erg"
                    with frame f-val3 down no-box width 200.
                    down with frame f-val3.
                    vtotmovim = vtotmovim + (movim.movpc * movim.movqtm~).
        end.
        display vtotmovim label "Total" with frame f-tot3 side-label.
    end.

    for each tt-produ break by tt-produ.movtdc:
        find movim where recid(movim) = tt-produ.prorec no-lock.
        find tipmov where tipmov.movtdc = movim.movtdc no-lock no-error.
        if not avail tipmov
        then vmovtnom = "".
        else vmovtnom = tipmov.movtnom.
        if tt-produ.movtdc = 09
        then vmovtnom = "TRANSFERENCIA DE ENTRADA".
        if tt-produ.movtdc = 06
        then vmovtnom = "TRANSFERENCIA DE SAIDA  ".
        
        vtot = vtot + (movim.movpc * movim.movqtm).
        
        if last-of(tt-produ.movtdc)
        then do:
            display vmovtnom
                    vtot(total) no-label with frame f-tot down.
            vtot = 0.
    end.
end. 
        
disp skip(5)
         "Quem fez:"       space(30) 
         "Quem conferiu:"  skip(4) 
         fill("-",30)      format "x(30)" space(9) 
         fill("-",30)      format "x(30)"
         skip 
         "Assinatura"         at 11 
         "Assinatura Gerente" at 47 
         with frame f-ass.

output close.

sresp = yes.
run mensagem.p (input-output sresp,
                input "Visualizar o relatorio ou gerar PDF?"  + "!!" +
                      "         O QUE DESEJA FAZER ?",
                input "",
                input "Visualizar",
                input "PDF").

if sresp
then run visurel.p(varquivo,"").
else run pdfout.p (input varquivo,
                  input "/admcom/kbase/pdfout/",
                  input "anavenlj" + string(mtime) + ".pdf",
                  input "Portrait",
                  input 7,
                  input 1,
                  output vpdf).

