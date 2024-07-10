{admcab.i}
def var vforcod like forne.forcod.
def var etb-i  like estab.etbcod.
def var etb-f  like estab.etbcod.
def var vdtini like plani.pladat.    
def var vdtfin like plani.pladat.
def var vcatcod like produ.catcod.
def var vetbcod like estab.etbcod.
def var vv as int.
def var reg as char.
def var varq as char format "x(23)".
def var varquivo as char format "x(30)".
def temp-table tt-produ
    field procod like produ.procod
    field bonus  like plani.platot.
    
def temp-table tt-bonus
    field etbcod like estab.etbcod  
    field data   like plani.pladat 
    field procod like produ.procod
    field fabcod like produ.fabcod
    field vencod like plani.vencod
    field valbon like plani.platot.
    
def var ii as int.
def var b-procod as char extent 7.
def var b-etbcod like estab.etbcod.
def var b-data   like plani.pladat.
def var b-bonus  as char.
def var b-vencod as char.    


repeat:

    for each tt-bonus:
        delete tt-bonus.
    end.    
        
    for each tt-produ:
        delete tt-produ.
    end.
    
   
    input from l:\work\bonus.txt.
    
    /* input from /admcom/work/bonus.txt. */
    repeat:
        import vv.
        create tt-produ.
        assign tt-produ.procod = int(substring(string(vv,"999999999"),1,6))
               tt-produ.bonus  = dec(substring(string(vv,"999999999"),7,3)).
    end.
    input close.    
    
    for each tt-produ where tt-produ.procod = 0:
        delete tt-produ.
    end.    
    
    
    update vetbcod label "Filial"
                with frame f1 side-label width 80. 
    if vetbcod = 0
    then display "Todas as filiais" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada".
            pause.
            undo, retry.
        end.
        display estab.etbnom no-label with frame f1.
    end.

    
    update vforcod label "Fornecedor" at 1
                with frame f1 side-label width 80. 
    if vforcod = 0
    then display "Todos" @ forne.fornom with frame f1.
    else do:
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor nao cadastrada".
            pause.
            undo, retry.
        end.
        display forne.fornom no-label with frame f1.
    end.
     
    
                    
                    
    update vdtini label "Periodo" at 1
           vdtfin no-label with frame f1.
           
   
    update vcatcod label "Departamento" with frame f1.
    
    find categoria where categoria.catcod = vcatcod no-lock no-error.
    if not avail categoria
    then do:
    
        message "Departamento nao cadastrado".
        pause.
        undo, retry.
    end.
    display categoria.catnom no-label with frame f1.
    
    if vetbcod = 0
    then assign etb-i = 1
                etb-f = 999.
    else assign etb-i = vetbcod
                etb-f = vetbcod.
                
            
            
    vv = 0.
    do vv = etb-i to etb-f:
        

        varq     = "l:\bonus\bon." + string(vv,"99"). 
        varquivo = "l:\bonus\bonus." + string(vv,"99").

        if search(varquivo) <> ?
        then do:
        
            dos silent value("c:\dlc\bin\quoter -d % "  + varquivo + " > " 
                              + varq).

    
 
            input from value(varq).
            repeat:  
                import reg. 
                assign b-etbcod = int(substr(reg,1,2))
                       b-data   = date(int(substr(reg,5,2)), 
                                       int(substr(reg,3,2)), 
                                       int(substr(reg,7,4)))
                       b-procod[1] = substring(reg,91,6)
                       b-procod[2] = substring(reg,97,6)  
                       b-procod[3] = substring(reg,103,6)  
                       b-procod[4] = substring(reg,109,6)  
                       b-procod[5] = substring(reg,115,6)  
                       b-procod[6] = substring(reg,121,6)  
                       b-procod[7] = substring(reg,127,6)
                       b-vencod    = substring(reg,133,3)
                       b-bonus     = substring(reg,149,13). 

                
                /*
                disp b-etbcod 
                     b-data 
                     b-procod[1]
                     b-procod[2]
                     b-procod[3]
                     b-procod[4]
                     b-procod[5]
                     b-procod[6]
                     b-procod[7]
                     dec(b-bonus).
                */
                
                
                ii = 0.
                do ii = 1 to 7:
                    if int(b-procod[ii]) = 0
                    then next.
                    if dec(b-bonus) = 0
                    then next.
                    
                    find produ where produ.procod = int(b-procod[ii]) 
                            no-lock no-error.
                            
                    if not avail produ
                    then next.
                    if produ.catcod = vcatcod
                    then.
                    else next.
                    if vforcod = 0
                    then.
                    else do:
                        if produ.fabcod = vforcod
                        then.
                        else next.
                    end.    
                                            
                    
                    /*
                    if produ.catcod = 41
                    then.
                    else do:
                    
                        find first tt-produ 
                                where tt-produ.procod = produ.procod no-error.
                        if not avail tt-produ
                        then next.
                    end.
                    */
                    
                    create tt-bonus.
                    assign tt-bonus.etbcod = b-etbcod
                           tt-bonus.data   = b-data
                           tt-bonus.vencod = int(b-vencod)
                           tt-bonus.procod = int(b-procod[ii])
                           tt-bonus.valbon = dec(b-bonus)
                           tt-bonus.fabcod = produ.fabcod.
                end.             
            end.
            input close.
    
        end.
    end.

    varquivo = "l:\relat\bon." + string(day(today)).

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""bonus""
            &Nom-Sis   = """SISTEMA GERENCIAL"""
            &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"") +
                          "" DE "" +
                                  string(vdtini,""99/99/9999"") + "" A "" +
                                  string(vdtfin,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    
    for each tt-bonus break by tt-bonus.etbcod
                            by tt-bonus.vencod:
        find produ where produ.procod = tt-bonus.procod no-lock.
        disp tt-bonus.etbcod
             tt-bonus.data
             tt-bonus.vencod column-label "Vend."
             tt-bonus.procod /* (count by tt-bonus.vencod) */
             produ.pronom format "x(30)"
             tt-bonus.fabcod column-label "Fornec"
             tt-bonus.valbon(total by tt-bonus.vencod)
                    with frame f-lista down width 120.
    end.    
    output close.

    if opsys = "unix"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}
    end.    


    
end.
    
     

