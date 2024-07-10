{admcab.i new}

def var vrel as char.
def var v-etbcod like estab.etbcod.
def var v-data1  as date format "99/99/9999".
/*def var v-data2  as date format "99/99/9999".*/
def var v-catcod like categoria.catcod.
def var v-movtdc like tipmov.movtdc.
def var v-tipo as int.

def var vfilial as char.

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
    
    index tt numero desc
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




def var vtitulo as char.
def var vopcao as int.
def var vescolha as char format "x(50)" extent 2
        initial [" 1. POSICAO FINANCEIRA VENCIDOS/A VENCER ",
                 " 2. ANALITICO                            "].
    

def var vsaida              as      log format "Impressora/Tela".
def var vprograma           as      char.
def var varq-retorno        as      char.
def var varq-retorno-zip    as      char.
def var vparametros         as      char.
def var vdatref             as      date format "99/99/9999".


vtitulo = "ANALITICO".

find estab where estab.etbcod = setbcod no-lock no-error.
/*
disp estab.etbcod   label "Estabelecimento"
     estab.etbnom   no-label 
     with frame f-dados width 80 row 4 side-labels.
vsaida = yes.
update vsaida       no-label
       help " [ I ]   Impressora     [ T ]   Tela       "
       with frame f-dados.
*/
vsaida = no.
    for each tt-produ.
        delete tt-produ.
    end.

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

    v-etbcod = setbcod.
    
    disp v-etbcod label "Filial.........."
         with frame f-analitico1.
         
    update v-data1 label "Data"
          /* v-data2 label "A " */
           with frame f-analitico1 side-labe centered row 4.

    update v-movtdc label "Cod.Movimentacao" at 1
        help "[5]Venda,[6]Transf,[7]Ajuste Acr,[8]Ajuste Dec,[12]devolucao"
            with frame f-analitico1.
    
    if v-movtdc = 0
    then display "GERAL" @ com.tipmov.movtnom no-label
         with frame f-analitico1.
    else do:
        find com.tipmov where com.tipmov.movtdc = v-movtdc no-lock no-error.
        if not avail com.tipmov
        then do:
            message "Codigo invalido".
            undo, retry.
        end.
        display com.tipmov.movtnom no-label with frame f-analitico1.
    end.                    

    do on error undo:

        update v-catcod label "Departamento"
               with frame f-analitico2 centered side-label.
           
        find com.categoria where
             com.categoria.catcod = v-catcod no-lock no-error.
        
        if avail com.categoria
        then disp com.categoria.catnom no-label
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


    varquivo = "/admcom/relat/analitico_" + string(setbcod,"999") + "." +
                 string(day(v-data1),"99") +
                 string(month(v-data1),"99") +
                 string(year(v-data1),"9999").
                /* + "_" +
                 string(day(v-data2),"99") +
                 string(month(v-data2),"99") +
                 string(year(v-data2),"9999")    
                 .*/

    {/admcom/progr/mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""anaven2""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  FILIAL"""
        &Tit-Rel   = """CONFERENCIA DAS NOTAS DE TRANSFERENCIA NA "" +
                    ""FILIAL "" + string(setbcod) +
                    ""  - Data: "" + string(v-data1,""99/99/9999"")"
        &Width     = "160"
        &Form      = "frame f-cabcab"}

    
    disp com.categoria.catcod label "Departamento"
         com.categoria.catnom no-label with frame f-dep2 side-label.

            
    for each com.tipmov where if v-movtdc = 0
                              then true
                              else com.tipmov.movtdc = v-movtdc no-lock:
        
        /*do vdt = v-data1 to v-data2:*/
        
            for each com.plani where com.plani.pladat = v-data1       and
                                    com.plani.movtdc = com.tipmov.movtdc and
                                    com.plani.desti  = setbcod       no-lock:
     
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
                    if com.produ.catcod <> v-catcod
                    then next.
        
                    if com.plani.movtdc = 05   or
                       com.plani.movtdc = 12   or
                       com.plani.movtdc = 16   or
                       com.plani.movtdc = 13
                    then next.
            
                    if (com.plani.movtdc = 4  or
                        com.plani.movtdc = 1) and setbcod < 96
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
    
   /* end.*/
            
    for each com.tipmov where if v-movtdc = 0
                              then true
                              else com.tipmov.movtdc = v-movtdc 
                                        no-lock:
        
       /* do vdt = v-data1 to v-data2:*/

        
        for each com.plani where com.plani.pladat = v-data1       and
                                com.plani.movtdc = com.tipmov.movtdc and
                                com.plani.etbcod = setbcod no-lock:

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
        if com.produ.catcod <> v-catcod
        then next.
        
        if com.plani.movtdc = 13
        then next.
        
        if (com.plani.movtdc = 4 or
            com.plani.movtdc = 1) and v-etbcod < 96
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
       /* end.*/
    end.

    
    if vv = "A"
    then do:
        for each tt-produ by tt-produ.pronom:
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                    no-lock no-error.
            
            
            sal-atu = 0.
            
            find com.estoq where 
                        com.estoq.etbcod = v-etbcod and
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
            
            if com.plani.emite <> v-etbcod and
               com.plani.desti <> v-etbcod
            then next.

            if com.plani.movtdc = 13
            then next.
            
            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and v-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                        no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = v-etbcod
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
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm~).
        end.
        display vtotmovim label "Total" with frame f-tot1 side-label.
    end.
    
    if vv = "N"
    then do:
        for each tt-produ by tt-produ.procod:
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                        no-lock no-error.
            
            sal-atu = 0.
            
            find com.estoq where 
                        com.estoq.etbcod = v-etbcod and
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
            
            
            if com.plani.emite <> v-etbcod and
               com.plani.desti <> v-etbcod
            then next.

            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and v-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                        no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = v-etbcod
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
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm~).
        end.
        display vtotmovim label "Total" with frame f-tot2 side-label.
    end.

    
    if vv = "F"                       
    then do:                              
        
        
        for each tt-produ by tt-produ.numero
                          by tt-produ.procod   :
                          
                          
            find com.movim where recid(com.movim) = tt-produ.prorec no-lock.
            
            find com.produ where com.produ.procod = com.movim.procod 
                        no-lock no-error.
            
            sal-atu = 0.
            
            
            find com.estoq where 
                        com.estoq.etbcod = v-etbcod and
                        com.estoq.procod = com.produ.procod 
                                                    no-lock no-error.
            if avail com.estoq
            then sal-atu = com.estoq.estatual.
            
            find first com.plani where com.plani.etbcod = com.movim.etbcod and
                                      com.plani.placod = com.movim.placod and
                                      com.plani.movtdc = com.movim.movtdc and
                                      com.plani.pladat = com.movim.movdat 
                                use-index plani no-lock no-error.     
                                                
            if not avail plani
            then next.
           
            if com.plani.emite <> v-etbcod and
               com.plani.desti <> v-etbcod
            then next.

            if com.plani.movtdc = 13
            then next.
            
            
            if (com.plani.movtdc = 4 or
                com.plani.movtdc = 1) and v-etbcod < 96
            then next.

            find com.tipmov where com.tipmov.movtdc = com.plani.movtdc 
                            no-lock no-error.
            if not avail com.tipmov
            then next.

            if com.plani.movtdc = 6
            then if com.plani.emite = v-etbcod
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
                    vtotmovim = vtotmovim + (com.movim.movpc * com.movim.movqtm~).
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

    sresp = yes.
    /*if setbcod = 189
    then*/ do:
    run mensagem.p (input-output sresp,
                    input "A opcao ENVIAR enviara o arquivo " +
                     entry(4,varquivo,"/") + 
                     " para sua filial para ser visualizado" +
                     " ou impresso via PORTA RELATORIOS"
                     + "!!" 

                                  + "         O QUE DESEJA FAZER ? ",
                                                                   input "",
                                                                                                    input "Visualizar",
                                                     input "Enviar ").
    end.
    if sresp = yes
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        unix silent value("sudo scp -p " + varquivo + /*".z" +*/
                        " filial" + string(setbcod,"999") +
                        ":/usr/admcom/porta-relat").
        message "ARQUIVO ENVIADO... " VARQUIVO. PAUSE. 
    end.
   
