{admcab.i}

def var vdias as int format ">>>9" label "Dias" initial 90.

def var vabc like produ.proabc initial " ".

def var vestdep like estoq.estatual.
def var vprocod like produ.procod.
def var vclacod like clase.clacod.
def var vqtd    like movim.movqtm.
def var vqtdest like movim.movqtm.
def var vqtdtot like movim.movqtm.
def var totven  like movim.movqtm.
def var vdata   like plani.pladat.
def var totper  like estoq.estatual.
def var totdis  like estoq.estatual.
def var totdisest like estoq.estatual.

def var varquivo as char format "x(20)".
def var ii as int. 
def var i as int.

def temp-table tt-estab
    field etbcod   like estab.etbcod
    field proper   like distr.proper
    field estatual like estoq.estatual
    field qtddis   like estoq.estatual
    field qtdven   like estoq.estatual
    field qtddisest like estoq.estatual
    field cobert   as int
    index ind-1 proper.

def var vetb-est like estab.etbcod.
def var vopc as char format "x(10)" extent 2 initial["Produto","Classe"].    

repeat:
                  
    assign vqtd    = 0
           vprocod = 0
           vclacod = 0
           totven  = 0.
    

    display vopc no-label with frame f-opcao centered.
    choose field vopc with frame f-opcao.
    if frame-index = 1
    then do:
       

        update vprocod at 6 label "Produto" with frame f1 side-label width 80.
        find produ where produ.procod = vprocod no-lock.
        display produ.pronom format "x(30)" no-label with frame f1.
        
    end.
    else do:
        update vclacod at 7 label "Classe" with frame f1 side-label width 80.
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom no-label with frame f1.
    end.
    
    update vabc  at 3
           vqtd  at 28 label "Quantidade" 
           vdias to 60
           with frame f1.
    
        
    for each tt-estab:
        delete tt-estab.
    end.

    for each estab where estab.etbcod < 900 and
            {conv_difer.i estab.etbcod} and
                         estab.etbcod <> 22 no-lock:

        if vprocod <> 0
        then do:
        
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
                             
            if not avail estoq
            then next.
            
            find first tt-estab where tt-estab.etbcod = estab.etbcod no-error.
            if not avail tt-estab
            then do:
            
                create tt-estab.
                assign tt-estab.etbcod   = estab.etbcod
                       tt-estab.estatual = estoq.estatual.
            end.    
            else tt-estab.estatual = tt-estab.estatual + estoq.estatual.
                       
            do vdata = today - vdias to today:
                for each movim where movim.etbcod = estab.etbcod and
                                     movim.movtdc = 05           and
                                     movim.procod = produ.procod and
                                     movim.movdat = vdata no-lock:
                    
                    find first tt-estab where tt-estab.etbcod = movim.etbcod
                                                                no-error.
                    if avail tt-estab
                    then do:
                        assign tt-estab.qtdven = tt-estab.qtdven + 
                                                 movim.movqtm.
                        totven = totven + movim.movqtm.                         
                    end.
                                                                
                    display movim.etbcod
                            movim.movdat with frame f-dis1 centered side-label.
                    pause 0.        
                                            
                end.
            end.
            
        end.
        else do:
            for each produ where produ.clacod = vclacod no-lock:
               
                if vabc <> " "
                then if produ.proabc <> vabc
                     then next.
            
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                             
                if not avail estoq
                then next.
            
                find first tt-estab where tt-estab.etbcod = estab.etbcod                                 no-error.
                if not avail tt-estab
                then do:
            
                    create tt-estab.
                    assign tt-estab.etbcod   = estab.etbcod
                           tt-estab.estatual = estoq.estatual.
                end.    
                else tt-estab.estatual = tt-estab.estatual + estoq.estatual.
                                    
                do vdata = today - vdias to today:
                    for each movim where movim.etbcod = estab.etbcod and
                                         movim.movtdc = 05           and
                                         movim.procod = produ.procod and
                                         movim.movdat = vdata no-lock:
                    
                        find first tt-estab where tt-estab.etbcod = movim.etbcod
                                                                no-error.
                        if avail tt-estab
                        then do:
                            assign tt-estab.qtdven = tt-estab.qtdven + 
                                                     movim.movqtm.
                            totven = totven + movim.movqtm.                         
                        end.
                                                                
                        display movim.etbcod
                            movim.movdat with frame f-dis3 centered side-label.
                        pause 0.        
                                            
                    end.
                end.
            

                
            end.
        end.
        
    end.
    vqtdest = 0.
    for each tt-estab /*where tt-estab.qtdven > 0*/ no-lock:
    
        vqtdest = vqtdest + tt-estab.estatual.
    
    end.
    
    vestdep = 0.
    if vprocod <> 0
    then do:
    
        for each estoq where estoq.procod = vprocod and
                             estoq.etbcod >= 900 no-lock:

            vestdep = vestdep + estoq.estatual.

        end.
        /*
        do vetb-est = 90 to 99:
            if vetb-est <> 93 and
               vetb-est <> 95 and
               vetb-est <> 96 and
               vetb-est <> 98 and
               vetb-est <> 99
             then next.
             for each estoq where estoq.procod = vprocod and
                             estoq.etbcod = vetb-est no-lock:

                vestdep = vestdep + estoq.estatual.

            end.
        end.       
        */
    end.
    else do:
    
        for each produ where produ.clacod = vclacod no-lock:
 
            for each estoq where estoq.procod = produ.procod and
                                 estoq.etbcod >= 900 no-lock:

                vestdep = vestdep + estoq.estatual.

            end.
            /*
            do vetb-est = 90 to 99:
                if vetb-est <> 93 and
                    vetb-est <> 95 and
                    vetb-est <> 96 and
                    vetb-est <> 98 and
                    vetb-est <> 99
                then next.
                for each estoq where estoq.procod = vprocod and
                             estoq.etbcod = vetb-est no-lock:

                    vestdep = vestdep + estoq.estatual.

                end.
            end.     
            */
        end.
    end.
    
    vqtdtot = vqtd + vqtdest.
    
    for each tt-estab:
    
        tt-estab.cobert = int((tt-estab.estatual * vdias) / tt-estab.qtdven). 
    
    end.
    
    totper = 0.
    for each tt-estab no-lock by tt-estab.qtdven:

        tt-estab.proper  = ((tt-estab.qtdven * 100) / totven).
        
        totper = totper + tt-estab.proper.
        
        if totper > 100
        then tt-estab.proper = tt-estab.proper - (totper - 100).
        
    end.
    if totper < 100
    then do:
        find last tt-estab use-index ind-1 where tt-estab.proper > 0
                            no-error.
        if avail tt-estab
        then tt-estab.proper = tt-estab.proper + (100 - totper).
                            
    end.    

    totdis = 0.
    totdisest = 0.
    for each tt-estab no-lock by tt-estab.qtdven:

       
        tt-estab.qtddis = int((vqtd * (tt-estab.proper / 100))).
        
        totdis = totdis + tt-estab.qtddis.
        if totdis > vqtd 
        then tt-estab.qtddis = tt-estab.qtddis - (totdis - vqtd).

        tt-estab.qtddisest = int((vqtdtot * (tt-estab.proper / 100))).
        
        totdisest = totdisest + tt-estab.qtddisest.
        if totdisest > vqtdtot 
        then tt-estab.qtddisest = tt-estab.qtddisest - (totdisest - vqtdtot).
        

        
    end.

    if totdis < vqtd
    then do:
        find last tt-estab use-index ind-1 where tt-estab.proper > 0
                            no-error.
        if avail tt-estab
        then tt-estab.qtddis = tt-estab.qtddis + (vqtd - totdis).
             
    end.
 
    if totdisest < vqtdtot
    then do:
        find last tt-estab use-index ind-1 where tt-estab.proper > 0
                            no-error.
        if avail tt-estab
        then tt-estab.qtddisest = tt-estab.qtddisest + (vqtdtot - totdisest).
             
    end.
 
    /*
             
    varquivo = "../relat/simul" + string(day(today)). 
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""simuldis""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """DISTRIBUICAO DE MERCADORIA POR FILIAL""" 
        &Width     = "130"
        &Form      = "frame f-cabcab"}
    */
      
    if vprocod = 0
    then display clase.clacod at 10
                 clase.clanom no-label format "x(30)" 
                 vqtd   label "Qdt Distribuida" at 2 format ">>>>9"
                 /*vqtdtot*/
                 totven label "Total Vendido" at 42 format ">>>>9"                              vqtdest label "Estoque Loja" at 5 format ">>>>9"
                 vestdep label "Estoque Dep." at 43 format ">>>>9"
                 int((vqtdest * vdias) / totven) at 3 label "Cob. Loja"
                 int(((/*vqtdest +*/ vestdep) * vdias) / totven) at 30 
                 label "Cob. Depo" 
                 int(((vqtdest + vestdep) * vdias) / totven) at 53 
                  label "Cob. Rede"
                         with frame f-tit1 side-label width 80 row 4.
     
              
    
    if vclacod = 0
    then display produ.procod at 10
                 produ.pronom no-label format "x(30)" 
                 vqtd   label "Qdt Distribuida" at 2 format ">>>>9"
                 /*vqtdtot*/
                 totven label "Total Vendido" at 42 format ">>>>9"                                vqtdest label "Estoque Loja" at 5 format ">>>>9"
                 vestdep label "Estoque Dep." at 43 format ">>>>9"
                 int((vqtdest * vdias) / totven) at 3 label "Cob. Loja"
                 int(((/*vqtdest +*/ vestdep) * vdias) / totven) at 30 
                 label "Cob. Depo" 
                 int(((vqtdest + vestdep) * vdias) / totven) at 53 
                 label "Cob. Rede"
                             
                             with frame f-tit2 side-label width 80 row 4.
     
    
    for each tt-estab no-lock by tt-estab.qtdven /*etbcod*/ descending:

          disp tt-estab.etbcod
               tt-estab.qtdven     column-label "Qtd Ven"  format "->>>>9"
               tt-estab.proper(total) column-label "% Venda" 
                  format "->>9.99 %"
               tt-estab.cobert column-label "Cobertura"
               tt-estab.qtddis(total) column-label "Dis S/Est" format "->>>>9"
               tt-estab.qtddisest(total) column-label "Dis C/Est" format                                                                 "->>>>9"
               tt-estab.estatual(total) format "->>>>9"
               (tt-estab.qtddisest - tt-estab.estatual)(total)
                column-label "Saldo"
                                                                format "->>>>9"
                                   with frame f3 centered down row 10.
        
    end.

    
    
    /*
    
    output close.
    
    {mrod.i}
    */
      
end.         

