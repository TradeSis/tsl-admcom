{admcab.i}
def var vcatcod like produ.catcod.
def var total_geral like plani.platot.
def var vtipo as char format "x(15)" extent 3 
    initial ["Sintetico","Analitico","Filial"].
def var vop as int.
def var vok as log.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vmovtdc like tipmov.movtdc format "99".
def var vetbcod like plani.etbcod.
def var varquivo as char.
def var varquivo1 as char.
def buffer bprodu for produ.
def buffer bmovim for movim.
def buffer bclase for clase.
def var vv as int.
def temp-table tt-cla
    field etbcod like estab.etbcod
    field vencod like func.funcod
    field pladat like plani.pladat
    field procod like produ.procod
    field numero like plani.numero
    field clacod like produ.clacod
    field movqtm like movim.movqtm
    field claadi like produ.clacod
    field ponto  like movim.movqtm.
    
def temp-table tt-ven
    field etbcod like estab.etbcod
    field vencod like plani.vencod
    field ponto  like movim.movqtm
    field per_fil as dec
    field per_ger as dec.
    
def temp-table tt-estab
    field etbcod like estab.etbcod
    field totpon like movim.movqtm
    field tot_per as dec.
        
    
repeat:

    for each tt-estab:
        delete tt-estab.
    end.        
    for each tt-ven:
        delete tt-ven.
    end.        
    for each tt-cla:
        delete tt-cla.
    end.
    
    update vcatcod label "Departamento" colon 16 with frame f1.
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    display categoria.catnom no-label with frame f1.
    
    update vetbcod label "Filial" colon 16 
        with frame f1 side-label width 80.
        
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
   
        disp estab.etbnom no-label with frame f1.
    end.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final"
                with frame f1 side-label.
    display vtipo no-label  
        with frame flista no-label row 10 centered.

    choose field vtipo with frame flista. 
    hide frame flista no-pause.  
    if frame-index = 1 
    then vop = 1. 
    else if frame-index = 2
         then vop = 2.
         else vop = 3.
    
                

    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 05           and
                         plani.pladat >= vdti        and
                         plani.datexp <= vdtf no-lock:
                                            
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat no-lock:
                             

            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod = vcatcod
            then.
            else next.
            
            find clase where clase.clacod = produ.clacod no-lock no-error.
            if not avail clase
            then next.
            
            find first tt-ven where tt-ven.vencod = plani.vencod and
                                    tt-ven.etbcod = plani.etbcod no-error.
            if not avail tt-ven
            then do:
                create tt-ven.
                assign tt-ven.vencod = plani.vencod
                       tt-ven.etbcod = plani.etbcod.
            end.

            vok = no.
            for each bmovim where bmovim.etbcod = plani.etbcod and
                                  bmovim.placod = plani.placod and
                                  bmovim.movtdc = plani.movtdc and
                                  bmovim.movdat = plani.pladat no-lock:
                                  
                find bprodu where bprodu.procod = bmovim.procod 
                            no-lock no-error.
                find bclase where bclase.clacod = bprodu.clacod
                    no-lock no-error.
                if not avail bclase
                then next.
                if bclase.clacod = clase.clacod
                then next.

                find adicla where adicla.clacod = clase.clacod and
                                  adicla.codadi  = bclase.clacod
                                  no-lock no-error.
                if not avail adicla
                then next.                  
                                      
                find first tt-cla where tt-cla.vencod = plani.vencod  and
                                        tt-cla.etbcod = plani.etbcod  and
                                        tt-cla.numero = plani.numero  and
                                        tt-cla.pladat = plani.pladat  and
                                        tt-cla.procod = bprodu.procod and
                                        tt-cla.claadi = bprodu.clacod and
                                        tt-cla.clacod = clase.clacod no-error. 

                if not avail tt-cla 
                then do:                                 
                    create tt-cla.  
                    assign tt-cla.etbcod = plani.etbcod
                           tt-cla.vencod = plani.vencod  
                           tt-cla.numero = plani.numero 
                           tt-cla.pladat = plani.pladat 
                           tt-cla.procod = bprodu.procod 
                           tt-cla.claadi = bprodu.clacod 
                           tt-cla.clacod = clase.clacod
                           tt-cla.movqtm = bmovim.movqtm.
                    tt-ven.ponto = tt-ven.ponto + bmovim.movqtm.
                end.
            /*    tt-cla.movqtm = tt-cla.movqtm + bmovim.movqtm. 
                tt-ven.ponto  = tt-ven.ponto  + bmovim.movqtm. */
                vok = yes.
            end.    
                                      
            if vok = yes
            then do:
                find first tt-cla where tt-cla.etbcod = plani.etbcod  and
                                        tt-cla.vencod = plani.vencod  and
                                        tt-cla.numero = plani.numero  and
                                        tt-cla.pladat = plani.pladat  and
                                        tt-cla.procod = produ.procod  and
                                        tt-cla.claadi = produ.clacod  and
                                        tt-cla.clacod = clase.clacod
                                                     no-error. 

                if not avail tt-cla  
                then do:  
                    create tt-cla.   
                    assign tt-cla.etbcod = plani.etbcod
                           tt-cla.vencod = plani.vencod  
                           tt-cla.numero = plani.numero  
                           tt-cla.pladat = plani.pladat  
                           tt-cla.procod = produ.procod  
                           tt-cla.claadi = produ.clacod  
                           tt-cla.clacod = clase.clacod.
                end. 
            
            end.                                 
        end. 
    end.
     
    for each tt-ven:
        find func where func.etbcod = tt-ven.etbcod and 
                        func.funcod = tt-ven.vencod no-lock no-error.
        if not avail func or tt-ven.ponto = 0
        then delete tt-ven.
    end.
    
    varquivo = "l:\relat\adic." + string(time).
                
    
    {mdad.i &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""lisadi2""
            &Nom-Sis   = """SISTEMA GERENCIAL"""
            &Tit-Rel   = """VENDA ADICIONAL FILIAL - "" + 
                            string(vetbcod) + ""  "" + 
                          string(vdti,""99/99/9999"") + "" ATE "" + 
                          string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab1"}
            
    total_geral = 0.
    for each tt-ven:
        find first tt-estab where tt-estab.etbcod = tt-ven.etbcod no-error.
        if not avail tt-estab
        then do:
            create tt-estab.
            assign tt-estab.etbcod = tt-ven.etbcod.
        end.
        tt-estab.totpon = tt-estab.totpon + tt-ven.ponto.
        total_geral = total_geral + tt-ven.ponto.
    end.    
    
    for each tt-estab:
        tt-estab.tot_per = (tt-estab.totpon / total_geral) * 100.
    end.

    for each tt-ven:
        find first tt-estab where tt-estab.etbcod = tt-ven.etbcod no-error.
        if avail tt-estab
        then tt-ven.per_fil = (tt-ven.ponto / tt-estab.totpon) * 100.
        
        tt-ven.per_ger = (tt-ven.ponto / total_geral) * 100.
        
    end.        
    
    
        
                
            
                    

    for each tt-estab by tt-estab.totpon desc:
    
        display tt-estab.etbcod label "Filial"
                tt-estab.tot_per label "Perc.Pontuacao"
                                 format ">>9.99%"
                tt-estab.totpon(total)  label "Total Pontos"
                    with frame f-estab side-label.
                
                
        if vop <> 3
        then do:
        for each tt-ven where tt-ven.etbcod = tt-estab.etbcod
                                    by tt-ven.ponto desc:

            find func where func.etbcod = tt-ven.etbcod and 
                            func.funcod = tt-ven.vencod no-lock no-error.
            if not avail func
            then next.
                        
                            
            display func.funcod column-label "Vendedor"
                    func.funnom column-label "Nome" format "x(21)"
                    tt-ven.ponto column-label "Pontuacao"
                    tt-ven.per_fil column-label "Perc.Filial"
                                   format ">99.99%" 
                    tt-ven.per_ger column-label "Perc.Geral"
                                   format ">99.99%"
                            with frame f2 width 120.                   
                 
            if vop = 2
            then do:
                        
                for each tt-cla where tt-cla.vencod = tt-ven.vencod and
                                      tt-cla.etbcod = tt-ven.etbcod
                                                      break by tt-cla.numero:
                              

                    /*
                    vv = vv + tt-cla.movqtm.
                    if first-of(tt-cla.numero)
                    then do:
                        display tt-cla.numero label "Nota Fiscal" 
                                    format ">>>>>>9"
                                tt-cla.pladat
                                    with frame f-clase side-label.
                        vv = 0.
                    end.                                
                    */
             
                    find produ where produ.procod = tt-cla.procod 
                                    no-lock no-error.
    
                    display tt-cla.numero column-label "Nota Fiscal"
                                          format ">>>>>>9"
                            tt-cla.pladat
                            produ.procod  
                            produ.pronom format "x(30)"   
                            tt-cla.claadi
                            tt-cla.movqtm(total by tt-cla.numero) 
                                    column-label "Pontuacao" format ">>>9"
                                 with frame f3 down width 120.
                end.
            end.
        end.
        end.
    end.         
        
    output close.
    if opsys = "UNIX"
    then do:
    
        run visurel.p (input varquivo,
                       input ""). 
    
    end.
    else do: 
        {mrod.i}     
    end.

end.


