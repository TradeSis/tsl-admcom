{admcab.i}
def input param ptitulos as char.
def var pfiltraperiodo as log format "Sim/Nao". 

def var pdtini as date format "99/99/9999".
def var pdtfim as date format "99/99/9999".

def var petbcod as int.

        hide message no-pause.
        message "informe filial ou zero para todas".
        update petbcod label "informe filial ou zero para todas" colon 40
            with frame ffilial
            row 9 centered side-labels overlay
            title ptitulos.
         hide message no-pause.
          
        find estab where estab.etbcod = petbcod no-lock no-error.
        if not avail estab and petbcod > 0
        then do:
            message "filial invalida".
            undo.
        end.     
        pfiltraperiodo  = no. 
        pdtini = ?.
        pdtfim = ?.
        
        update pfiltraperiodo label "filtrar periodo?"  colon 40
         with frame ffilial.
        disp pdtini colon 40 label "de" pdtfim label "ate"
                        with frame ffilial.
                        
        if pfiltraperiodo
        then do:            
            update pdtini colon 40 label "de" pdtfim label "ate"
                with frame ffilial.
        end.        
 
def temp-table ttcotas no-undo
    field fcccod    like fincotacluster.fcccod
    field etbcod    like fincotacllib.etbcod 
    field dtivig like fincotaetb.dtivig
    field dtfvig    like fincotaetb.dtivig
    field cotaslib    like fincotacllib.CotasLib
    field cotasuso  like fincotaetb.cotasuso
    index x is unique primary fcccod asc etbcod asc dtivig asc dtfvig asc .
    
def var pordem as int.
 
def var varqcsv as char format "x(65)".

    varqcsv = "/admcom/relat/cotascluster_" + 
                string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","") + ".csv".

    update varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv"
                            overlay.


message "Aguarde...". 


for each fincotacluster no-lock,
    each fincotacllib  of fincotacluster where
            no-lock:
    if petbcod <> 0 then if fincotacllib.etbcod <> petbcod then next.
    if pdtini <> ?  then if fincotacllib.dtivig < pdtini then next.
    if pdtfim <> ?  then if fincotacllib.dtfvig > pdtfim then next.
    
    find first ttcotas where  
            ttcotas.fcccod = fincotacluster.fcccod and
            ttcotas.etbcod = fincotacllib.etbcod   and
            ttcotas.dtivig  = fincotacllib.dtivig and
            ttcotas.dtfvig  = fincotacllib.dtfvig
        no-error.
    if not avail ttcotas
    then do:
        create ttcotas. 
        ttcotas.fcccod = fincotacluster.fcccod.
        ttcotas.etbcod = fincotacllib.etbcod.
        ttcotas.dtivig  = fincotacllib.dtivig.
        ttcotas.dtfvig  = fincotacllib.dtfvig .
    end.
    ttcotas.cotaslib = ttcotas.cotaslib + fincotacllib.cotaslib.   
    
    for each fincotaclplan of fincotacluster no-lock,
         each fincotaetb where 
                    fincotaetb.etbcod = fincotacllib.etbcod and
                    fincotaetb.fincod = fincotaclplan.fincod and
                    fincotaetb.dtivig = fincotacllib.dtivig and
                    fincotaetb.dtfvig = fincotacllib.dtfvig 
                    no-lock.
        ttcotas.cotasuso = ttcotas.cotasuso + fincotaetb.cotasuso.   
    end.

end.



output to value(varqcsv).
put unformatted  "filial;muncipio;CLS;Cluster;" 
                 "dataInicio;dataFinal;"
                 "cotas Liberadas;cotas Usadas;"
                 skip.

for each ttcotas.

        find fincotacluster of ttcotas no-lock.
        find estab of ttcotas no-lock.
    
        put unformatted
            ttcotas.etbcod ";"
            estab.munic ";"
            ttcotas.fcccod ";"
            fincotacluster.fccnom ";"
            ttcotas.dtivig format "99/99/9999" ";"
            ttcotas.dtfvig format "99/99/9999" ";"
            ttcotas.cotaslib ";"
            ttcotas.cotasuso ";"
            skip.

    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    




