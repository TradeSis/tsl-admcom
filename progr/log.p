{admcab.i}
def var vetbcod like estab.etbcod.
def var vdata as date. 
def var varquivo as char format "x(20)".
def var vdia    as int format "99".
def var vmes    as int format "99".
def temp-table warquivo
    field warq-1 as char format "x(50)"
    field wetb as c format ">>9"
    field wmes as c format "99"
    field wdia as c format "99"
    field wtab as c format "x(20)"
    field wcol-1  as c
    field wcol-2  as c
    field wcol-3   as c.
    
def temp-table warq
    field warq-2 as char.
        
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
repeat:
    
    for each warquivo:
       delete warquivo.
    end.
    for each warq.
        delete warq.
    end.
 
    update vdti    label "Data Inicial"   colon 15
           vdtf label "Data Final" with frame f1 side-label width 80.
           
    do vdata = vdti to vdtf:
    
        dos silent dir value("..\import\log\l????" + 
                   string(month(vdata),"99") + ".d") 
                   /s/b > ..\import\log\arq.
         
        for each warq:
           delete warq.
        end.
        
        input from ..\import\log\arq.
        repeat:
            create warq.
            import warq-2.
            dos silent i:\dlc\bin\quoter
                value(warq-2) > 
                value(substring(warq-2,1,(length(warq-2) - 1)) + "c").
        end.
        input close.

        dos silent dir value("..\import\log\*.c") /s/b > ..\import\log\arq.

        
        input from ..\import\log\arq.
        repeat:
            create warquivo.
            import warq-1.
            assign warquivo.wetb = substring(warquivo.warq-1,16,2)
                   warquivo.wmes = string(month(vdata),"99").
        end.
        input close.
    end.
    
    
    for each warquivo.
        if warquivo.warq-1 = ""
        then next.
        input from value(warquivo.warq-1).
        repeat:
            import varquivo.
            assign warquivo.wdia   = substring(varquivo,1,2)
                   warquivo.wtab   = substring(varquivo,10,20)
                   warquivo.wcol-1 = substring(varquivo,53,8)
                   warquivo.wcol-2 = substring(varquivo,66,8)
                   warquivo.wcol-3 = substring(varquivo,80,8).

                   
            disp warquivo.wetb 
                 warquivo.wmes
                 warquivo.wdia  
                 warquivo.wtab  
                 warquivo.wcol-1 
                 warquivo.wcol-2 
                 warquivo.wcol-3.
                 
        end.         
        input close.
    end.

    dos silent del ..\import\log\*.c . 
    dos silent del ..\import\log\arq . 
    
    
end.

