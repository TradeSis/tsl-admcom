{admcab.i}

{setbrw.i}

define            variable vmes  as char format "x(05)" extent 13 initial
    ["  JAN","  FEV","  MAR","  ABR","  MAI","  JUN",
     "  JUL","  AGO","  SET","  OUT","  NOV","  DEZ", "TOTAL"].
form
    with   frame f-comp centered overlay row 9 .
    
def var vmes2 as char format "x(05)" extent 13.

def var vaux        as int.
def var vano        as int.
def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.
def var vtotcomp    like himov.himqtm extent 13.


def var vfabcod like produ.fabcod.
def var vdias as int format ">>>9" label "Dias de Analise" initial 90.
def var vcobertura as int format ">>>9" label "Cobertura".

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
    field etbcod    like estab.etbcod
    field proper    like distr.proper
    field estatual  like estoq.estatual
    field qtddis    like estoq.estatual
    field qtdven    like estoq.estatual
    field qtddisest like estoq.estatual
    field cobert    as int    
    index ind-1 proper.

def temp-table tt-pro
    field procod  like produ.procod
    field pronom  like produ.pronom
    field fabcod  like fabri.fabcod
    field fabnom  like fabri.fabnom
    field estdep  like vestdep
    field totven  like totven
    field cober     as   int
    field pcvenda like estoq.estvenda
    field pccusto like estoq.estcusto
    field qtdest  as int
    index iprocod procod
    index icober cober .

form
    tt-pro.procod                label "Codigo" format ">>>>>9"
    tt-pro.pronom format "x(22)" label "Produto"
    tt-pro.fabnom format "x(10)" label "Fabricante"
    tt-pro.estdep                column-label "Estoq!Depos" format "->>>>9"
    tt-pro.totven                column-label "Qtd.!Vend."  format ">>>>9"
    tt-pro.cober                   column-label "Dias!Cober" format ">>>>9"
    tt-pro.pcvenda               column-label "Preco!Venda" format ">,>>9"
    tt-pro.pccusto               column-label "Preco!Custo" format ">,>>9"
    tt-pro.qtdest                column-label "Estoq!Lojas" format "->>>>9"   
    with frame f-linha1.
    
form
    estoq.etbcod                 column-label "Estab"
    tt-pro.procod                column-label "Codigo" format ">>>>>9"
    tt-pro.pronom                column-label "Produto"
    estoq.estatual               column-label "Estoq!Atual" format "->>>>9"   
    with frame f-est.
    

repeat:
                  
    assign vqtd    = 0
           vprocod = 0
           vclacod = 0
           totven  = 0.
           
    for each tt-pro:
        delete tt-pro.  
    end.
    hide frame f-linha1 no-pause.
        
    update vfabcod at 2 label "Fabricante" with frame f1 side-label width 80.
    if vfabcod <> 0
    then do:
        find fabri where fabri.fabcod = vfabcod no-lock.
        display fabri.fabnom format "x(30)" no-label with frame f1.
    end.
    else disp "Todos" @ fabri.fabnom with frame f1.
    
    update vcobertura at 3  
           vdias to 50
           with frame f1.
    
        
    if vfabcod <> 0
    then do:
    
        for each produ where produ.fabcod = vfabcod and
                produ.procod <= 3052 no-lock:

            vestdep = 0.
            for each estoq where (estoq.etbcod >= 900 or 
                                {conv_igual.i estab.etbcod}) and
                                 estoq.procod = produ.procod no-lock:
                                 
                vestdep = vestdep + estoq.estatual.
            end.                           

            totven = 0.                       
            do vdata = today - vdias to today:
                for each movim where movim.procod = produ.procod     and
                                         movim.movtdc = 05           and
                                         movim.movdat = vdata no-lock:
                    totven = totven + movim.movqtm.                         
                end.
            end.                                               
            
            if vestdep <= 0 and
               totven <= 0 
            then next.   

            if int((vestdep * vdias) / totven) > vcobertura
            then next. 
            
            vqtdest = 0.
            for each estoq where estoq.etbcod < 900  and
                                 estoq.etbcod <> 22 and
                                 {conv_difer.i estab.etbcod} and
                                 estoq.procod = produ.procod no-lock:
                
                vqtdest = vqtdest + estoq.estatual.  
            
            end.        
                    
            find tt-pro where tt-pro.procod = produ.procod no-error.
            if not avail tt-pro
            then do:
                find first estoq of produ no-lock.
                
                find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
                
                create tt-pro.
                assign tt-pro.procod = produ.procod
                       tt-pro.pronom = produ.pronom
                       tt-pro.fabcod = produ.fabcod
                       tt-pro.fabnom = if avail fabri
                                       then fabri.fabnom
                                       else "Nao Cadastrado"
                       tt-pro.estdep = vestdep
                       tt-pro.totven = totven
                       tt-pro.cober    = 
                           int((vestdep * vdias) / totven)
                       tt-pro.pcvenda = estoq.estvenda
                       tt-pro.pccusto = estoq.estcusto
                       tt-pro.qtdest  = vqtdest.
            
            end.
                                  /*             
            disp produ.procod
                 produ.pronom format "x(30)"
                 vestdep
                 totven
                 int((vestdep * vdias) / totven) with down.*/
        end.         
    end.

    /*ini browse*/
    
   assign a-seeid  = -1 a-recid  = -1  a-seerec = ?.
    
   {sklcls.i
       &file         = tt-pro
       &help         =  " F1=Compras F4=Retorna "
       &cfield       = tt-pro.pronom
       &ofield       = " tt-pro.procod
                         tt-pro.fabnom
                         tt-pro.estdep
                         tt-pro.totven
                         tt-pro.cober
                         tt-pro.pcvenda
                         tt-pro.pccusto
                         tt-pro.qtdest"
       &where        = "true"
       &color        = withe
       &color1       = red
       &locktype     = " use-index icober "
       &aftselect1   = " leave keys-loop. "
       &Otherkeys    = " cobert01.ok "
       &naoexiste1   = " bell. bell.
                         message color red/withe  
                         ""Nenhum Produto Cadastrado""
                         view-as alert-box title """" . leave. "
       &form         = " frame f-linha1 row   7   down width 80 
                         title "" "" overlay 
                         color with/cyan " }
                         
    /*fim browse*/
    
end.

 /***********************************************
                    /**
                    display movim.etbcod
                            movim.movdat with frame f-dis1 centered side-label.
                    pause 0.        
                    **/
                                            
                                            
                                            
                                            
                                            
                                            
                end.
            end.
            
               

     for each tt-estab:
        delete tt-estab.
    end.

    for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 and
                          {conv_difer.i estab.etbcod}
 
                          no-lock:

        if vfabcod <> 0
        then do:
            for each produ where produ.fabcod = vfabcod no-lock:
            
                for each estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
                             
                find first tt-estab
                    where tt-estab.etbcod = estab.etbcod no-error.
                if not avail tt-estab
                then do:
            
                    create tt-estab.
                    assign tt-estab.etbcod   = estab.etbcod
                       tt-estab.estatual = estoq.estatual.
            end.    

                       
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
               
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock no-error.
                             
                if not avail estoq
                then next.
                
                find first tt-estab where tt-estab.etbcod = estab.etbcod 
                                        no-error.
                if not avail tt-estab
                then do:
                
                    create tt-estab.
                    assign tt-estab.etbcod   = estab.etbcod
                           tt-estab.estatual = estoq.estatual.
                end.    

                       
                do vdata = today - vdias to today:
                    for each movim where movim.etbcod = estab.etbcod and
                                         movim.movtdc = 05           and
                                         movim.procod = produ.procod and
                                         movim.movdat = vdata no-lock:
                    
                        find first tt-estab where 
                                    tt-estab.etbcod = movim.etbcod no-error.
                        if avail tt-estab
                        then do:
                            assign tt-estab.qtdven = tt-estab.qtdven + 
                                                     movim.movqtm.
                                                     
                            totven = totven + movim.movqtm.
                        end.
                                                                    
                        display movim.etbcod
                                movim.movdat 
                                    with frame f-dis2 centered side-label.
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
                             (estoq.etbcod >= 900 or
                             {conv_igual.i estab.etbcod})
                             no-lock:

            vestdep = vestdep + estoq.estatual.

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
    then display clase.clacod at 2
                 clase.clanom no-label 
                 vqtd   label "Qdt Distribuida" at 5 format ">>>>9"
                 
                 totven label "Total Vendido  " at 5 format ">>>>9"
                 int((vqtdest * vdias) / totven) label "Cobertura Loja" at 5
                 int(((vqtdest + vestdep) * vdias) / totven)
                       label "Cobertura Rede"  
                        with frame f-tit1 side-label width 120.
              
    
    if vclacod = 0
    then display produ.procod at 10
                 produ.pronom no-label format "x(30)" 
                 vqtd   label "Qdt Distribuida" at 2 format ">>>>9"
                 /*vqtdtot*/
                 totven label "Total Vendido" at 42 format ">>>>9"                                vqtdest label "Estoque Loja" at 5 format ">>>>9"
                 vestdep label "Estoque Dep." at 43 format ">>>>9"
                 int((vqtdest * vdias) / totven) at 3 label "Cob. Loja"
                 int(((/*vqtdest +*/ vestdep) * vdias) / totven) at 25 
                 label "Cob. Depo" 
                 int(((vqtdest + vestdep) * vdias) / totven) at 41 
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
***************************************************/

