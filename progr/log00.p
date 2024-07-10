{admcab.i}

def var vetbcod like estab.etbcod.
def var vdata as date. 
def var varquivo as char format "x(20)".
def var vdia    as int format "99".
def var vmes    as int format "99".

def temp-table warquivo
    field warq-1 as char format "x(50)"
    field wetb as c format "99"
    field wmes as c format "99"
    field wdia as c format "99"
    field wtab as c format "x(20)"
    field wcol-1  as c
    field wcol-2  as c
    field wcol-3   as c.
    
def temp-table ttloja
    field wtab as char format "x(20)" 
    field etbcod like estab.etbcod
    field importou as log.

def temp-table warq
    field warq-2 as char.
        
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
repeat:
    
    for each ttloja :
        delete ttloja.
    end. 

    for each warquivo:
       delete warquivo.
    end.
    for each warq.
        delete warq.
    end.
 
    update vdti    label "Data Inicial"   colon 15
           /* vdtf label "Data Final"  */ 
           with frame f1 side-label width 80.
           
    do vdata = vdti to vdti:
    
        os-command silent dir value("..\import\log\l????" + 
                   string(month(vdata),"99") + ".d") 
                   /s/b > ..\import\log\arq.
         
        for each warq:
           delete warq.
        end.
        
        input from ..\import\log\arq.
        repeat:
            create warq.
            import warq-2.
            os-command silent i:\dlc\bin\quoter
                value(warq-2) > 
                value(substring(warq-2,1,(length(warq-2) - 1)) + "c").
        end.
        input close.

     os-command silent dir value("..\import\log\*.c") /s/b > ..\import\log\arq.

        
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

            if int(warquivo.wdia) = day(vdti)
            then do : 
                find first ttloja where ttloja.etbcod = int(warquivo.wetb)
                                    and ttloja.importou = yes  no-error.
                if not avail ttloja
                then do :
                    create ttloja.
                    ttloja.etbcod = int(warquivo.wetb).
                    ttloja.wtab = "LOG".
                    ttloja.importou = yes.
                end.
            end.
            
            if int(warquivo.wcol-3) <> 0 
            then next.

            if int(warquivo.wdia) <> day(vdti)
            then next.
            
            if warquivo.wtab = "Estabelecimento" or
               warquivo.wtab = "Finan" or
               warquivo.wtab = "Sprint" or
               warquivo.wtab = "ECF" or
               warquivo.wtab = "Impre" or
               warquivo.wtab = " " or
               warquivo.wtab = "Contrato" or
               warquivo.wtab = "TabelaMensagem" 
            then next.

            find first ttloja where ttloja.etbcod = int(warquivo.wetb)
                                and ttloja.wtab = warquivo.wtab
                                and ttloja.importou = no 
                              no-error.
            if not avail ttloja
            then do :
                create ttloja.
                ttloja.etbcod = int(warquivo.wetb).
                ttloja.wtab = warquivo.wtab.
                ttloja.importou = no.
            end.
            /*    

            disp warquivo.wetb 
                 warquivo.wmes
                 warquivo.wdia  
                 warquivo.wtab 
                 warquivo.wcol-3.
                 warquivo.wcol-1 
                 warquivo.wcol-2 
                 warquivo.wcol-3.  
            */     
        end.         
        input close.                  
    end.

    os-command silent del ..\import\log\*.c . 
    os-command silent del ..\import\log\arq . 

    for each estab where estab.etbcod < 900 :
        if estab.etbcod = 1 or
           estab.etbcod = 2 or
           estab.etbcod = 5 or
           estab.etbcod = 6 or
           estab.etbcod = 7 or
           estab.etbcod = 14 or
           estab.etbcod = 15 or
           estab.etbcod = 17 or
           estab.etbcod = 22 or
           estab.etbcod = 32 or
           estab.etbcod = 34 or
           estab.etbcod = 40
        then next.
        if {conv_igual.i estab.etbcod} then next.
        find first ttloja where ttloja.etbcod = estab.etbcod 
                            and ttloja.importou = no
                          no-error.
        disp estab.etbcod estab.etbnom with frame f-loja down column 1 
                title "LOJAS". 
        if not avail ttloja
        then do :
            find first ttloja where ttloja.etbcod = estab.etbcod
                                and ttloja.importou =  yes no-error.
            if not avail ttloja
            then 
                disp "Nao IMPORTOU" with frame f-loja.
            else 
                disp "    IMPORTOU" with frame f-loja.
        end.
        else do :
            for each ttloja where ttloja.etbcod = estab.etbcod
                              and ttloja.importou = no :
                disp ttloja.wtab label "Tabela" 
                    with frame f-loja.
            end.
        end.
    end.
    sresp = no.
    message "Deseja Imprimir o Relatorio ?" update sresp.
    if sresp
    then do:

       {mdadmcab.i &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "150"
                    &Page-Line = "66"
                    &Nom-Rel   = ""LOG00""
                    &Nom-Sis   = """CPD"""
                    &Tit-Rel   = """LISTAGEM DE LOG POR FILIAL "" +
                                    string(vdti)"
                    &Width     = "150"
                    &Form      = "frame f-cabcab"}
        for each estab where estab.etbcod < 900 :
            if estab.etbcod = 1 or 
               estab.etbcod = 2 or 
               estab.etbcod = 5 or 
               estab.etbcod = 6 or 
               estab.etbcod = 7 or 
               estab.etbcod = 14 or 
               estab.etbcod = 17 or 
               estab.etbcod = 22 or 
               estab.etbcod = 23 or 
               estab.etbcod = 32 or
               estab.etbcod = 34
            then next.
            if {conv_igual.i estab.etbcod} then next.
            find first ttloja where ttloja.etbcod = estab.etbcod 
                                and ttloja.importou = no no-error.
            disp estab.etbcod estab.etbnom with frame f-loja2 down column 1 
                    title "LOJAS". 
            if not avail ttloja
            then do :
                find first ttloja where ttloja.etbcod = estab.etbcod
                                    and ttloja.importou =  yes no-error.
                if not avail ttloja
                then  disp "Nao IMPORTOU" with frame f-loja2.
                else  disp "    IMPORTOU" with frame f-loja2.
            end.
            else do :
                for each ttloja where ttloja.etbcod = estab.etbcod
                                  and ttloja.importou = no :
                    disp ttloja.wtab label "Tabela" 
                        with frame f-loja2.
                end.
            end.
        end.
    end.
    output close.
    
 
end.

