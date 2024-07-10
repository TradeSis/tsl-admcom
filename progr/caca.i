/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : calcvnw2.i
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Include Performance de Vendas
***** Data de Criacao              : ??????

                                ALTERACOES
***** 1) Autor     : Caludir Santolin
***** 1) Descricao : Adaptacoes Sale2000
***** 1) Data      : ????2001

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

v-totalzao = 0.
do d = vdti to vdtf : 
    for each tipmov where tipmov.movtdc = 5  no-lock,
        each plani where plani.movtdc = tipmov.movtdc
                     and plani.etbcod = (if vetbcod > 0
                                     then vetbcod else plani.etbcod) 
                     and plani.pladat = d 
                     use-index pladat
                     no-lock,
        first estab where estab.etbcod = plani.etbcod
                          no-lock:
            
        disp "Processando .."
             plani.pladat
             estab.etbnom
             with frame f-mostr 1 down 
                row 10 centered no-labels color white/black.
        pause 0.
           
        /****** gerando historico de lojas ***********/
            
        find first ttloja where ttloja.etbcod = plani.etbcod no-error.
        if not avail ttloja
        then do:
            create ttloja.
            assign ttloja.etbcod = plani.etbcod
                   ttloja.etbnom = estab.etbnom
                   ttloja.metlj  = v-total.
        end.
        
        if tipmov.movtdc = 5
        then do :
            ttloja.medven = ttloja.medven + 1.
            for each movim
                where movim.etbcod = plani.etbcod
                  and movim.placod = plani.placod
                  and movim.movtdc = plani.movtdc
                  and movim.movdat >= vdti 
                  and movim.movdat <= vdtf
                  no-lock:
                ttloja.platot = ttloja.platot + 
                                (movim.movpc * movim.movqtm).
                if plani.pladat = vdtf
                then ttloja.pladia = ttloja.pladia + 
                                (movim.movpc * movim.movqtm).
            end.
        end.    
            
        if vetbcod = 0 
        then do :
            find first ttloja where ttloja.etbcod = 999 no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = 999
                       ttloja.etbnom = "G E R A L"
                       ttloja.metlj = v-total.
            end.
            
            if tipmov.movtdc = 5
            then do :
                ttloja.metlj = ttloja.metlj + v-totalzao.
                ttloja.medven = ttloja.medven + 1.
                for each movim
                    where movim.etbcod = plani.etbcod
                      and movim.placod = plani.placod
                      and movim.movtdc = plani.movtdc 
                      and movim.movdat >= vdti 
                      and movim.movdat <= vdtf
                      no-lock:

                    ttloja.platot = ttloja.platot +
                                    (movim.movpc * movim.movqtm).
                    if plani.pladat = vdtf
                    then ttloja.pladia = ttloja.pladia + 
                                    (movim.movpc * movim.movqtm).
                end.
            end.    
        end.
    end.

    for each tipmov where tipmov.movtdc = 12  no-lock,
        each plani where plani.movtdc = tipmov.movtdc
                     and plani.etbcod = (if vetbcod > 0
                                     then vetbcod else plani.etbcod) 
                     and plani.pladat = d 
                     use-index pladat
                     no-lock,
        first estab where estab.etbcod = plani.etbcod
                          no-lock:
            
        disp "Processando .."
             plani.pladat
             estab.etbnom
             with frame f-mostr 1 down 
                row 10 centered no-labels color white/black.
        pause 0.
           
        /****** gerando historico de lojas ***********/
            
        find first ttloja where ttloja.etbcod = plani.etbcod no-error.
        if not avail ttloja
        then do:
            create ttloja.
            assign ttloja.etbcod = plani.etbcod
                   ttloja.etbnom = estab.etbnom
                   ttloja.metlj  = v-total.
        end.
        
        ttloja.medven = ttloja.medven - 1.
            
        for each movim
                where movim.etbcod = plani.etbcod
                  and movim.placod = plani.placod
                  and movim.movtdc = plani.movtdc
                  and movim.movdat >= vdti 
                  and movim.movdat <= vdtf
                  no-lock:   
            
                ttloja.platot = ttloja.platot - 
                                (movim.movpc * movim.movqtm).
                if plani.pladat = vdtf
                then  ttloja.pladia = ttloja.pladia - 
                                (movim.movpc * movim.movqtm).
        end.
            
        if vetbcod = 0 
        then do :
            find first ttloja where ttloja.etbcod = 999 no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = 999
                       ttloja.etbnom = "G E R A L"
                       ttloja.metlj = v-total.
            end.
            ttloja.medven = ttloja.medven - 1.
            for each movim
                    where movim.etbcod = plani.etbcod
                      and movim.placod = plani.placod
                      and movim.movtdc = plani.movtdc
                      and movim.movdat >= vdti 
                      and movim.movdat <= vdtf
                       no-lock:

                    ttloja.platot = ttloja.platot - 
                                    (movim.movpc * movim.movqtm).
                    if plani.pladat = vdtf
                    then ttloja.pladia = ttloja.pladia -
                                    (movim.movpc * movim.movqtm).
            end.
        end.
    end.
end.
    
            

                              
                          
    
    
