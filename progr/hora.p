{admcab.i}

def var totger  as int.
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def var vv      as int.
def var v-hora  as int.
def var varquivo as char.
def temp-table  tthora
    field hora    as int extent 20
    field etbcod  like estab.etbcod.

def temp-table tt-totais
    field totdia as int
    field hora   as int.
        



repeat:

    for each tthora:
        delete tthora.
    end.
        
    
    update vetbcod label "Filial" with frame f1 side-label width 80.

    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
    
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.

    end.
    
    update vdti label "Periodo" 
           vdtf no-label with frame f1.
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 05           and
                         plani.pladat >= vdti        and
                         plani.pladat <= vdtf no-lock by horincl.
                         
                         
        if plani.horincl < 32400
        then v-hora = 8.
        
        if plani.horincl >= 32400 and
           plani.horincl <  36000
        then v-hora = 9.
        
        if plani.horincl >= 36000 and
           plani.horincl <  39600
        then v-hora = 10.
        
        if plani.horincl >= 39600 and
           plani.horincl <  43200
        then v-hora = 11.
         
        if plani.horincl >= 43200 and
           plani.horincl <  46800
        then v-hora = 12. 
        
        if plani.horincl >= 46800 and
           plani.horincl <  50400
        then v-hora = 13. 
        
        if plani.horincl >= 50400 and
           plani.horincl <  54000
        then v-hora = 14. 
        
        if plani.horincl >= 54000 and
           plani.horincl <  57600
        then v-hora = 15. 
        
        if plani.horincl >= 57600 and
           plani.horincl <  61200
        then v-hora = 16. 
        
        if plani.horincl >= 61200 and
           plani.horincl <  64800
        then v-hora = 17. 
        
        if plani.horincl >= 64800 and
           plani.horincl <  68400
        then v-hora = 18. 
        
        if plani.horincl >= 68400 and
           plani.horincl <  72000
        then v-hora = 19. 
        
        if plani.horincl >= 72000 
        then v-hora = 20.
        


        find first tthora where tthora.etbcod = estab.etbcod no-error.
        if not avail tthora
        then do:
            
            create tthora.
            assign tthora.etbcod = estab.etbcod.
            
        end.

        tthora.hora[v-hora] = tthora.hora[v-hora] + 1.
        
        find first tt-totais where tt-totais.hora = v-hora no-error.
        if not avail tt-totais
        then do:
            create tt-totais.
            assign tt-totais.hora = v-hora.
        end.
        tt-totais.totdia = tt-totais.totdia + 1.
        
        
        
                                
    end.
 
    varquivo = "..\relat\hora" + string(time).
     
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "66"
            &Nom-Rel   = ""hora""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """FLUXO DE VENDAS "" +
                        ""  - Periodo: "" + string(vdti) + "" A "" +
                            string(vdtf)"
            &Width     = "147"
            &Form      = "frame f-cabcab1"}
    
    put "Filial" 
        "    8:00"
        "      9:00"
        "     10:00"
        "     11:00"
        "     12:00"
        "     13:00"
        "     14:00"
        "     15:00"
        "     16:00"
        "     17:00"
        "     18:00"
        "     19:00"
        "     20:00" skip.  
    
                 
                
    for each tthora by tthora.etbcod:  
        
        put tthora.etbcod.
        
        do vv = 8 to 20:

            put tthora.hora[vv].
        
        end.
        
        put skip.
        
    end.
         
    put skip fill("-",135) format "x(135)" skip.
    
    put "Tot.".
    
    for each tt-totais:
    
        put tt-totais.totdia.
        

    end.
    put skip fill("-",135) format "x(135)" skip.
    
    
    
    totger = 0.
    for each tt-totais:
    
        totger = totger + tt-totais.totdia.

    end.
    
    
    put skip
        "Perc.".
    for each tt-totais:
    
        put ( (tt-totais.totdia / totger) * 100) format ">>>>>9.99%".
        

    end.
    put skip fill("-",135) format "x(135)" skip.


          
          
    
              
    output close.
    
    {mrod.i} 
    
end.
    
