/*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : calcvnw2.i
***** Diretorio                    : movim
***** Autor                        : Andre
***** Descri‡ao Abreviada da Funcao: Include Performance de Vendas
***** Data de Criacao              : ??????

                                ALTERACOES
***** 1) Autor     : Claudir Santolin
***** 1) Descricao : Adaptacoes Sale2000
***** 1) Data      : ????2001

***** 2) Autor     : Andre Baldini
***** 2) Descricao : Adaptacoes Drebes 
***** 2) Data      : ../10/2001

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*******************************************************************************/

v-totalzao = 0.
do d = vdti to vdtf : 
    for each estab where estab.etbcod = (if vetbcod <> 0 
                                         then vetbcod
                                         else estab.etbcod)  no-lock :
        for each plani where plani.movtdc = 5
                     and  plani.etbcod = estab.etbcod
                     and plani.pladat = d 
                     no-lock :
                  
            find first tipmov where tipmov.movtdc = 5 no-lock.                
            
            disp "Processando .."
                 plani.pladat
                 estab.etbnom
                 plani.movtdc
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
                if plani.biss > 0  
                then  ttloja.platot = ttloja.platot + plani.biss.
                else  ttloja.platot = ttloja.platot + (plani.platot -                                     plani.vlserv ).
                if plani.pladat = vdtf
                then do :
                    if plani.biss > 0 
                    then ttloja.pladia = ttloja.pladia + plani.biss.
                    else ttloja.pladia = ttloja.pladia + (plani.platot -                                       plani.vlserv).
                end.                             
            end.    
            
            if vetbcod = 0 
            then do :
                find first ttloja where ttloja.etbcod = 0 no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = 0
                           ttloja.etbnom = "G E R A L"
                           ttloja.metlj = v-total.
                end.
            
                if tipmov.movtdc = 5
                then do :
                    ttloja.metlj = ttloja.metlj + v-totalzao.
                    ttloja.medven = ttloja.medven + 1.
                end.  
                if plani.biss > 0 
                then ttloja.platot = ttloja.platot + plani.biss.
                else ttloja.platot = ttloja.platot + 
                                    (plani.platot - plani.vlserv).
                
                if plani.pladat = vdtf
                then do :
                    if plani.biss > 0 
                    then ttloja.pladia = ttloja.pladia + plani.biss.
                    else ttloja.pladia = ttloja.pladia + (plani.platot -
                                         plani.vlserv).
                end.                            
            end.
        end.
    end.
end.
    

/****************** Calculo da Meta ************************/

def var vdtim as date.
def var vdtfm as date.

v-totalzao = 0.

vdtim = date(month(vdti), day(vdti), year(vdti) - 1).
vdtfm = date(month(vdtf), day(vdtf), year(vdtf) - 1).


do d = vdtim to vdtfm : 
    for each estab where estab.etbcod = (if vetbcod <> 0 
                                         then vetbcod
                                         else estab.etbcod)  no-lock :
        for each plani where plani.movtdc = 5
                     and  plani.etbcod = estab.etbcod
                     and plani.pladat = d 
                     no-lock :
                  
            find first tipmov where tipmov.movtdc = 5 no-lock.                
            
            disp "Processando .."
                 plani.pladat
                 estab.etbnom
                 plani.movtdc
                 with frame f-mostr2 1 down 
                row 10 centered no-labels color white/black.
            pause 0.
           
            /****** gerando historico de lojas ***********/
            
            find first ttloja where ttloja.etbcod = plani.etbcod no-error.
            if not avail ttloja
            then do:
                create ttloja.
                assign ttloja.etbcod = plani.etbcod
                       ttloja.etbnom = estab.etbnom.
            end.
        
            if tipmov.movtdc = 5
            then do :
                if plani.biss > 0  
                then  ttloja.metlj = ttloja.metlj + plani.biss.
                else  ttloja.metlj = ttloja.metlj + (plani.platot -                                   plani.vlserv ).
            end.    
            
            if vetbcod = 0 
            then do :
                find first ttloja where ttloja.etbcod = 0 no-error.
                if not avail ttloja
                then do:
                    create ttloja.
                    assign ttloja.etbcod = 0
                           ttloja.etbnom = "G E R A L".
                end.
            
                if tipmov.movtdc = 5
                then do :
                    ttloja.metlj = ttloja.metlj + v-totalzao.
                end.  
                if plani.biss > 0 
                then ttloja.metlj = ttloja.metlj + plani.biss.
                else ttloja.metlj = ttloja.metlj + 
                                    (plani.platot - plani.vlserv).
                
            end.
        end.
    end.
end.
             

                              
                          
    
   
