propath = "/admcom/progr,/usr/dlc".


{/admcom/progr/admcab-batch.i new}

def var vfilial as char.
def var /*input  parameter*/ p-parametros as char.
def var /*output parameter*/ p-arquivo as char.

p-parametros = SESSION:PARAMETER.

def /*input parameter*/ var p-etbcod like estab.etbcod.
def /*input parameter*/ var p-data1  as date format "99/99/9999".
def /*input parameter*/ var p-data2  as date format "99/99/9999".
def /*input parameter*/ var p-catcod like categoria.catcod.
def /*input parameter*/ var p-movtdc like tipmov.movtdc.
def /*input parameter*/ var p-tipo as int.

p-etbcod = (int(acha("ETBCOD", p-parametros))).
p-data1  = (date(acha("DATINI", p-parametros))).
p-data2  = (date(acha("DATFIN", p-parametros))).
p-catcod = (int(acha("CATCOD", p-parametros))).
p-movtdc = (int(acha("MOVTDC", p-parametros))).
p-tipo   = (int(acha("TIPO", p-parametros))).


def var vdt as date.

def var sal-atu as int.
def var vmovtnom like com.tipmov.movtnom.
def var vtip as char format "x(20)" extent 3 
        initial ["Numerico","Alfabetico","Nota Fiscal"].
        
        
def var vv as char format "x".
def var fila as char.
              
def temp-table tt-produ 
    field procod like com.produ.procod
    field pronom as char format "x(20)"
    field prorec as recid
    field numero like com.plani.numero
    field movtdc like com.plani.movtdc
    
    field plano like plani.pedcod
    field vende like plani.vencod
    index i1 prorec
    index i2 pronom
    index i3 procod
    index i4 movtdc
    index i5 numero desc
             procod desc.
    
def var varquivo as char format "x(20)".
def stream stela.
def var vtipmov like com.tipmov.movtnom.

def var vtotdia like com.plani.platot.
def var vtot  like com.movim.movpc.
def var vtotg like com.movim.movpc.
def var vtotgeral like com.plani.platot.

def var vtotal like com.plani.platot.
def var vtoticm like com.plani.icms.
def var vtotmovim   like com.movim.movpc.
def var vtotpro like com.plani.platot.

              /**** Campo usado para guardar o no. da planilha ****/

form com.plani.pladat format "99/99/9999"
     com.plani.numero format ">>>>>>9"
     com.plani.emite column-label "Emite"
     com.plani.desti column-label "Dest" format ">>>>>>>>>9"
     com.movim.procod
     com.produ.pronom format "x(40)"
     com.movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
     com.movim.movpc  format ">,>>9.99"
     vtotpro column-label "Total"
     vtipmov column-label "Movimento" format "x(18)"
     sal-atu column-label "saldo" format "->>>>>9" 
                        with frame f-val down no-box width 200.



    vtotmovim = 0.
    vtotgeral = 0.
    
    for each tt-produ.
        delete tt-produ.
    end.
    
    find com.categoria where com.categoria.catcod = p-catcod no-lock no-error.
    
    if p-movtdc <> 0
    then
        find com.tipmov where com.tipmov.movtdc = p-movtdc no-lock no-error.
            
    /***
    display vtip with frame f-tip no-label.
    choose field vtip with frame f-tip centered row 4.
    ***/
    
    if p-tipo = 1
    then vv = "N".
    else if p-tipo = 2
         then vv = "A".
         else vv = "F".

    varquivo = "/admcom/connect/retorna-rel/anaven_" + string(p-etbcod,"999") 
             + ".rel".

    p-arquivo = varquivo.
    
    {/admcom/progr/mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""anaven2""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  FILIAL"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(p-etbcod) +
                    ""  - Data: "" + string(p-data1,""99/99/9999"") + "" A "" +
                        string(p-data2,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cabcab"}

    
    disp com.categoria.catcod label "Departamento"
         com.categoria.catnom no-label with frame f-dep2 side-label.

            
    for each com.tipmov where if p-movtdc = 0
                              then true
                              else com.tipmov.movtdc = p-movtdc no-lock:
        
        do vdt = p-data1 to p-data2:
        
            for each com.plani where com.plani.pladat = vdt       and
                                    com.plani.movtdc = com.tipmov.movtdc and
                                    com.plani.desti  = p-etbcod       no-lock:
     
                if com.plani.movtdc = 30
                then next.
                
                for each com.movim where com.movim.etbcod = com.plani.etbcod and
                                        com.movim.placod = com.plani.placod and
                                        com.movim.movtdc = com.plani.movtdc and
                                        com.movim.movdat = com.plani.pladat 
                                    no-lock:
    
                    find com.produ where com.produ.procod = com.movim.procod 
                        no-lock no-error.
                    if not avail com.produ
                    then next.
                    if com.produ.catcod <> p-catcod
                    then next.
        
                    if com.plani.movtdc = 05   or
                       com.plani.movtdc = 12   or
                       com.plani.movtdc = 16   or
                       com.plani.movtdc = 13
                    then next.
            
                    if (com.plani.movtdc = 4  or
                        com.plani.movtdc = 1) and p-etbcod < 96
                    then next.

                               
                    find first tt-produ 
                        where tt-produ.prorec = recid(com.movim) no-error.
                    if not avail tt-produ
                    then do:
                         
                        create tt-produ.
                        assign tt-produ.procod = com.produ.procod
                               tt-produ.pronom = com.produ.pronom
                               tt-produ.prorec = recid(com.movim)
                               tt-produ.numero = com.plani.numero
                               tt-produ.movtdc = com.plani.movtdc
                               tt-produ.vende  = com.plani.vencod
                               tt-produ.plano  = com.plani.pedcod.
                   
                        if tt-produ.movtdc = 06
                        then tt-produ.movtdc = 09.
                   
        
                    end.
                end.    
            end.    
        end.    
    
    end.
            
    for each com.tipmov where if p-movtdc = 0
                              then true
                              else com.tipmov.movtdc = p-movtdc 
                                        no-lock:
        
        do vdt = p-data1 to p-data2:

        
        for each com.plani where com.plani.pladat = vdt       and
                                com.plani.movtdc = com.tipmov.movtdc and
                                com.plani.etbcod = p-etbcod no-lock:

                if com.plani.movtdc = 30
                then next.
     
        for each com.movim where com.movim.etbcod = com.plani.etbcod and
                            com.movim.placod = com.plani.placod and
                            com.movim.movtdc = com.plani.movtdc and
                            com.movim.movdat = com.plani.pladat no-lock:
    
        find com.produ where com.produ.procod = com.movim.procod 
                    no-lock no-error.
        if not avail com.produ
        then next.
        if com.produ.catcod <> p-catcod
        then next.
        
        if com.plani.movtdc = 13
        then next.
        
        if (com.plani.movtdc = 4 or
            com.plani.movtdc = 1) and p-etbcod < 96
        then next.

        
        find first tt-produ where tt-produ.prorec = recid(com.movim) no-error.
        if not avail tt-produ
        then do:                     
                         
            create tt-produ.
            assign tt-produ.procod = com.produ.procod
                   tt-produ.pronom = com.produ.pronom
                   tt-produ.prorec = recid(com.movim)
                   tt-produ.numero = com.plani.numero
                   tt-produ.movtdc = com.plani.movtdc
                   tt-produ.vende  = com.plani.vencod
                   tt-produ.plano  = com.plani.pedcod.

        
        end.
        end.
        end.
        end.
    end.

    
    if vv = "A"
    then do:
        for each tt-produ use-index i2:
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                    no-lock no-error.
            
            
            sal-atu = 0.
            
            find com.estoq where 
                        com.estoq.etbcod = p-etbcod and
                        com.estoq.procod = com.produ.procod 
                                                    no-lock no-error.
            if avail com.estoq
            then sal-atu = com.estoq.estatual.
            
            find first com.plani where com.plani.movtdc = com.movim.movtdc and
                                      com.plani.etbcod = com.movim.etbcod and
                                      com.plani.placod = com.movim.placod and
                                      com.plani.pladat = com.movim.movdat 
                                        no-lock no-error.
    
            if not avail com.plani
            then next.
            
            if com.plani.emite <> p-etbcod and
               com.plani.desti <> p-etbcod
            then next.

            if com.plani.movtdc = 13
            then next.
            
            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and p-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                        no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = p-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(com.tipmov.movtnom,"x(18)").

            vtotpro = (com.movim.movpc * com.movim.movqtm).
        
            display com.plani.pladat format "99/99/9999"
                    com.plani.numero format ">>>>>>9"
                    com.plani.pedcod  format ">>>9" column-label "Plano"
                    com.plani.vencod  format ">>>9" column-label "Vend."
                    com.plani.emite column-label "Emite"
                    com.plani.desti column-label "Dest" format ">>>>>>>>>9"
                    com.movim.procod
                    com.produ.pronom when avail produ format "x(30)"
                    com.movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    com.movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu column-label "Saldo" format "->>>>>9" 
                    "___" column-label "Con!tag"
                    "___" column-label "Div!erg"
                                with frame f-val1 down no-box width 200.
                    down with frame f-val1.
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot1 side-label.
    end.
    
    if vv = "N"
    then do:
        for each tt-produ use-index i3:
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                        no-lock no-error.
            
            sal-atu = 0.
            
            find com.estoq where 
                        com.estoq.etbcod = p-etbcod and
                        com.estoq.procod = com.produ.procod 
                                                    no-lock no-error.
            if avail com.estoq
            then sal-atu = com.estoq.estatual.
            
            find first com.plani where com.plani.movtdc = com.movim.movtdc and
                                      com.plani.etbcod = com.movim.etbcod and
                                      com.plani.placod = com.movim.placod and
                                      com.plani.pladat = com.movim.movdat 
                                no-lock no-error.

            if not avail plani
            then next.
           
            if com.plani.movtdc = 13 
            then next.
            
            
            if com.plani.emite <> p-etbcod and
               com.plani.desti <> p-etbcod
            then next.

            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and p-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                        no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = p-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(com.tipmov.movtnom,"x(18)").

            vtotpro = (com.movim.movpc * com.movim.movqtm).
        

            display com.plani.pladat format "99/99/9999"
                    com.plani.numero format ">>>>>>9"
                    com.plani.pedcod  format ">>>9" column-label "Plano"
                    com.plani.vencod  format ">>>9" column-label "Vend."
                    com.plani.emite column-label "Emite"
                    com.plani.desti column-label "Dest" format ">>>>>>>>>9"
                    com.movim.procod
                    com.produ.pronom when avail produ format "x(30)"
                    com.movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    com.movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu  column-label "Saldo" format "->>>>>9" 
                    "___" column-label "Con!tag"
                    "___" column-label "Div!erg"

                        with frame f-val2 down no-box width 200.
                    down with frame f-val2.
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot2 side-label.
    end.

    
    if vv = "F"                       
    then do:                              
        
        
        for each tt-produ use-index i5:
                          
                          
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                        no-lock no-error.
            
            sal-atu = 0.
            
            
            find com.estoq where 
                        com.estoq.etbcod = p-etbcod and
                        com.estoq.procod = com.produ.procod 
                                                    no-lock no-error.
            if avail com.estoq
            then sal-atu = com.estoq.estatual.
            
            find first com.plani where com.plani.etbcod = com.movim.etbcod and
                                      com.plani.placod = com.movim.placod and
                                      com.plani.movtdc = com.movim.movtdc and
                                      com.plani.pladat = com.movim.movdat 
                                 no-lock no-error.     
                                                
            if not avail plani
            then next.
           
            if com.plani.emite <> p-etbcod and
               com.plani.desti <> p-etbcod
            then next.

            if com.plani.movtdc = 13
            then next.
            
            
            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and p-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                            no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = p-etbcod
                 then vtipmov = "TRANSFERENCIA DE SAIDA".
                 else vtipmov = "TRANSFERENCIA DE ENTRADA".
            else vtipmov = string(com.tipmov.movtnom,"x(18)").

            vtotpro = (com.movim.movpc * com.movim.movqtm).
        
            display com.plani.pladat format "99/99/9999"
                    com.plani.numero format ">>>>>>9"
                    com.plani.pedcod  format ">>>9" column-label "Plano"
                    com.plani.vencod  format ">>>9" column-label "Vend."
                    com.plani.emite column-label "Emite"
                    com.plani.desti column-label "Dest" format ">>>>>>>>>9"
                    com.movim.procod
                    com.produ.pronom when avail produ format "x(30)"
                    com.movim.movqtm format ">>>>9" COLUMn-LABEL "QTD"
                    com.movim.movpc
                    vtotpro  column-label "Total"
                    vtipmov column-label "Movimento" format "x(12)"
                    sal-atu column-label "Saldo" format "->>>>>9" 
                    "___" column-label "Con!tag"
                    "___" column-label "Div!erg"

                                with frame f-val3 down no-box width 200.
                    down with frame f-val3.
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm).
        end.
        display vtotmovim label "Total" with frame f-tot3 side-label.
    end.

    for each tt-produ break by tt-produ.movtdc:
        find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
        find com.tipmov where tipmov.movtdc = com.movim.movtdc no-lock no-error.
        if not avail com.tipmov
        then vmovtnom = "".
        else vmovtnom = com.tipmov.movtnom.
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

vfilial = "filial" + string(p-etbcod,"999").

os-command silent
   /home/drebes/scripts/job-rel value(varquivo) value(vfilial) " & ".
    
