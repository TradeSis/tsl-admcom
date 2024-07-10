def temp-table ttloja 
    field etbcod like estab.etbcod
    field titulos as int
    field nao as int.
    
def temp-table ttpag 
    field etbcod like estab.etbcod
    field etbcobra like titulo.etbcobra
    field nao      as int.

def var i as int.
def var vdataini as date format "99/99/9999".
def var vdatafim as date format "99/99/9999". 
def var d as date.

update 
    vdataini 
    vdatafim 
    with frame f-dados.
           
    if vdatafim < vdataini or
       vdatafim = ? or vdataini = ? 
    then do :
        bell. bell. bell.
        message "Datas invalidas".
        pause. clear frame f-dados all.
        next.
    end.

    hide frame f-dados.

    for each estab where estab.etbcod < 90 no-lock : 
    
        disp estab.etbcod estab.etbnom 
            with frame fff 1 down centered row 7. pause 0.
            
        do d = vdataini to vdatafim : 
            for each titulo where titulo.empcod = 19 
                      and titulo.titnat = no
                      and titulo.modcod = "CRE" 
                      and titulo.titdtpag = d
                      and titulo.etbcobra = estab.etbcod
                      and titulo.titsit = "PAG" 
                      use-index titdtpag no-lock : 

                i = i + 1.

                disp titulo.titdtemi titulo.titdtpag 
                    titulo.etbcod titulo.etbcobra i   titulo.clifor 
                    with frame ffff centered row 16 1 down.
                pause 0. 

                find first ttloja where ttloja.etbcod = titulo.etbcobra
                              no-error.
                if not avail ttloja
                then do :
                    create ttloja.
                    ttloja.etbcod = titulo.etbcobra.
                end.
        
                ttloja.titulo = ttloja.titulo + 1.
                if titulo.etbcobra <> titulo.etbcod 
                then do :
                    find first ttpag where ttpag.etbcobra = titulo.etbcobra
                        and ttpag.etbcod = titulo.etbcod no-error.
                    if not avail ttpag 
                    then do : 
                        create ttpag.
                        ttpag.etbcod = titulo.etbcod.
                        ttpag.etbcobra = titulo.etbcobra.
                    end.
                    ttpag.nao = ttpag.nao + 1.
                    ttloja.nao = ttloja.nao + 1.
                end.   
            end.
        end.
    end.
            
    hide frame fff.
    hide frame ffff.     

    
    output to pagamentos.txt.

        for each ttloja :
            find first estab where estab.etbcod = ttloja.etbcod no-lock.
            disp ttloja.etbcod
                 estab.etbnom 
                 ttloja.titulos
                 ttloja.nao
                 ttloja.nao * 100 / ttloja.titulo "%"
                 estab.regcod.
            
            for each ttpag where ttpag.etbcobra = ttloja.etbcod  :
                find first estab where estab.etbcod =  ttpag.etbcod no-lock.
                disp 
                    space(10) 
                    ttpag.etbcod 
                    estab.etbnom 
                    ttpag.nao ttpag.nao * 100 / ttloja.nao "%"
                    estab.regcod.
                    
            end.  
        end.
    output close.

    output to printer.

        for each ttloja :
            find first estab where estab.etbcod = ttloja.etbcod no-lock.
            disp ttloja.etbcod
                 estab.etbnom 
                 ttloja.titulos
                 ttloja.nao
                 ttloja.nao * 100 / ttloja.titulo "%"
                 estab.regcod.
            
            for each ttpag where ttpag.etbcobra = ttloja.etbcod  :
                find first estab where estab.etbcod =  ttpag.etbcod no-lock.
                disp 
                    space(11) 
                    ttpag.etbcod 
                    estab.etbnom 
                    ttpag.nao ttpag.nao * 100 / ttloja.nao "%"
                    estab.regcod.
                    
            end.  
        end.
    output close.
 

        


            
        
            
            
            
        

    