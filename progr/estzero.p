{admcab.i}
def var vetbcod like estab.etbcod.
def var vdia    as int format ">99".
def var vdiaven as int format ">99".
def var estdep like estoq.estatual.
def var vok as l.
def var deposito like estab.etbcod.
def buffer bestab for estab.
def var varquivo as char.
def var vdatven as date.
def var vdatcom as date.

repeat:
    update vetbcod label "Filial" colon 25
               with frame f1 side-label width 80.
                    
                    
    find estab where estab.etbcod = vetbcod no-lock no-error.
    display estab.etbnom no-label with frame f1.
    
    update deposito label "Deposito" colon 25 with frame f1.
         
    find bestab where bestab.etbcod = deposito no-lock no-error.
    display bestab.etbnom no-label with frame f1.
    

    update vdia label "Tempo em estoque" colon 25 with frame f1.
 
    update vdiaven label "Tempo da ultima venda" colon 25 with frame f1.

    varquivo = "l:\relat\zero" + string(time).
     
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "100"
        &Page-Line = "66"
        &Nom-Rel   = ""estzero""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
        &Tit-Rel   = """PRODUTOS SEM ESTOQUE NA "" +
                        ""FILIAL "" + string(vetbcod)"
        &Width     = "100"
        &Form      = "frame f-cabcab1"}

    /****** Display dos parametros ******/
    
    disp "Deposito              : " bestab.etbcod no-label " - "
         bestab.etbnom no-label skip
         "Data da ultima compra : " (today - vdia) format "99/99/9999"
          no-label  skip
         "Data da ultima venda  : " (today - vdiaven) format "99/99/9999" 
         no-label.   
    
    
    
    for each produ use-index catpro
            where produ.catcod = 31 no-lock.
        
        estdep = 0.
        vok = yes.
        
        for each estab where estab.etbcod = deposito no-lock.
        
            find last movim where movim.procod = produ.procod and
                                  movim.movtdc = 4            and
                                  movim.etbcod = estab.etbcod and
                                  movim.movdat <= today - vdia 
                                            no-lock no-error.
            if not avail movim
            then do:
                find last movim where movim.procod = produ.procod and
                                      movim.movtdc = 1            and
                                      movim.etbcod = estab.etbcod and
                                      movim.movdat <= today - vdia 
                                            no-lock no-error.
                if not avail movim
                then do:
                    vok = no.
                    next.
                end.
            end.    
            
            vdatcom = movim.movdat.
            
            for each estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock.
        
                estdep = estdep + estoq.estatual.
                
            end.
        end.
        
        find estoq where estoq.etbcod = vetbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estoq.estatual > 0 or
           estdep <= 0        
           /* vok = no */
        then next.   
        
        if vok = no
        then vdatcom = 01/01/2000.

        find last movim where movim.procod = produ.procod and
                              movim.movtdc = 5 and
                              movim.etbcod = vetbcod 
                              use-index icurva no-lock no-error.
        
        if not avail movim
        then vdatven = 01/01/2000. /* next. */
        else do:
            /*
            if movim.movdat >= (today - vdiaven)
            then next.                     
            */
            vdatven = movim.movdat.
        end.                      
        
        display produ.procod
                produ.pronom 
                estdep format ">>>>9"       column-label "Estoque!Deposito"
                vdatcom format "99/99/9999" column-label "Ultima!Compra"
                vdatven format "99/99/9999" column-label "Ultima!Venda"
                        when vdatven > 01/01/2000
                "Nunca Vendeu" when vdatven = 01/01/2000        
                                                  with frame f2 down width 120.
    end.    
            
    {mrod.i}
                         
end.    
        