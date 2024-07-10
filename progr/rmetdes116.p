{admcab.i}

def var v-wacupag as dec.
def var vval as dec initial 0.
def var dsresp as log init yes.

def temp-table tt-titulo like fin.titulo
index i1 clifor titnum titpar.

def var v-wacumeta as dec.

def var vpct-real as dec format "->>>9.99" .
def var sfor as log format "Sim/Nao".

/* Total Geral */
def var vtotmet as dec                              init 0.
def var vtotpag as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotrec as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotdeb as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotsal as dec                              init 0.
def var vtotval as dec                              init 0.

def temp-table tt-totgru
    field wmod like fin.titulo.modcod
    field tot  as dec
    index ix1 wmod.
                      
def temp-table swpag
    field wgru  like fin.titulo.modcod
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swacu
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swac-cla 
    field wmod  like fin.titulo.modcod
    field wgru  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swsetor
         field wsetcod like setaut.setcod.

def temp-table wpag
    field wgru  like fin.titulo.modcod
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    field apagar as dec
    index i1 wset wmod wano wmes.

def temp-table wgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wacu
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wac-cla 
    field wmod  like fin.titulo.modcod
    field wgru  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wfor 
    field wmod  like fin.titulo.modcod
    field wgru  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wdeb  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    field wfor  like forne.forcod
    index i1 wset wmod wano wmes.


def temp-table wmodal like fin.modal.

for each wmodal:
    delete wmodal.
end.
for each fin.modal where fin.modal.modcod <> "DEV"
                     and fin.modal.modcod <> "BON"
                     and fin.modal.modcod <> "CHP"
                     /** antonio **/
                     /** and fin.modal.modcod <> "DUP" **/ no-lock:
    create wmodal.
    assign wmodal.modcod = fin.modal.modcod
           wmodal.modnom = fin.modal.modnom.
end.

def var vdt as date.
def var vdti as date.
def var vdtf as date.
def var vtotal-apagar as dec format "->>>>,>>>,>>9.99".

assign
    vdti = date(month(today),01,year(today))
    vdtf = today.

def var vsetcod like setaut.setcod.
update vsetcod label "Setor" with frame f-sel.

if vsetcod <> 0
then do:
    find setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-sel.
end.
else disp "Relatorio geral" @ setaut.setnom with frame f-sel.

/***
find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock.
if func.funfunc begins "DIRETOR"
then.
else if vsetcod <> 0 and (func.funfunc begins "GERENTE" or
                          func.funfunc begins "CUSTOM" or
                          func.funmec = yes) and
            func.aplicod = string(vsetcod)
    then.
    else do:
        bell.
        message color red/with
        "Acesso nao autorizado." view-as alert-box.
        return.
    end.
***/

update vdti at 1 label "Periodo de Emissao"  format "99/99/9999"
       vdtf label "Ate"  format "99/99/9999"
       with frame f-sel 1 down side-label width 80.

sfor = no.
/*
message "Mostrar fornecedores?" update sfor.
*/
def var vmes as int.
def var vano as int.
def var mes-ano as int.
do vdt = vdti to vdtf :

    vmes = month(vdt).
    vano = year(vdt).
    if vmes + vano = mes-ano
    then next.
    mes-ano = vmes + vano.
    for each metadesp where  metadesp.etbcod = setbcod and
                         (if vsetcod > 0
                          then metadesp.setcod = vsetcod else true) and
                         metadesp.metano = vano and
                         metadesp.metmes = vmes and
                         metadesp.modgru = "" and
                         metadesp.modcod <> ""
                         no-lock .
        /*
        find first modgru where modgru.modcod = wpag.wmod and 
                            modgru.mogsup <> 0 no-lock no-error.
        if avail modgru
        then do:
            
        emd.                     
        else*/ do:          
            find first wpag where 
                       wpag.wmod = metadesp.modcod and
                       wpag.wset = metadesp.setcod and
                       wpag.wano = metadesp.metano and
                       wpag.wmes = metadesp.metmes no-error.
            if not avail wpag
            then do:
            
                create wpag.
                assign
                    wpag.wmod = metadesp.modcod 
                    wpag.wset = metadesp.setcod 
                    wpag.wano = metadesp.metano 
                    wpag.wmes = metadesp.metmes
                    wpag.wmet = metadesp.metval.
            end.
        end.
    end.
end.            

def var set-cod like setaut.setcod.
/*
output to /admcom/work/modal-met.txt.
for each wmodal:
    export wmodal.
end.
output close. 
*/
do vdt = vdti to vdtf:
    disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 13 no-label.
    pause 0.    
    for each wmodal where wmodal.modcod <> "DUP" and
                          wmodal.modcod <> "ICX" no-lock:
        disp wmodal.modcod with frame f-proc.
        pause 0. 
        for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtemi =  vdt 
                                  no-lock:

            find first titudesp where
                               titudesp.empcod = fin.titulo.empcod and
                               titudesp.titnat = fin.titulo.titnat and
                               titudesp.modcod = fin.titulo.modcod and
                               titudesp.etbcod = fin.titulo.etbcod and
                               titudesp.clifor = fin.titulo.clifor and
                               titudesp.titnum = fin.titulo.titnum and
                               titudesp.titdtemi = fin.titulo.titdtemi
                               no-lock no-error.
            if avail titudesp and vdt > 06/30/13
            then next. 


            disp titulo.titnum with frame f-proc .
            pause 0.
            set-cod = 0.
            if vsetcod > 0 
            then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> vsetcod
                        then next.
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                                set-cod = foraut.setcod.
                            end.
                            else next.
                        end.
            end. 
            
            else if fin.titulo.titbanpag = 0
            then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                set-cod = foraut.setcod.
                            end.
                            else set-cod = fin.titulo.titbanpag.
            end.
            
            if set-cod = 0  
            then do:
                if fin.titulo.titbanpag = 0
                then set-cod = 99.
                else set-cod = fin.titulo.titbanpag.
            end.
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtemi) and
                       wpag.wmes = month(fin.titulo.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = set-cod /*fin.titulo.titbanpag*/ 
                    wpag.wano = year(fin.titulo.titdtemi) 
                    wpag.wmes = month(fin.titulo.titdtemi)  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlcob .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtemi) and
                       wpag.wmes = month(fin.titulo.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*fin.titulo.titbanpag */
                    wpag.wano = year(fin.titulo.titdtemi) 
                    wpag.wmes = month(fin.titulo.titdtemi)  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlcob .
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = set-cod /*fin.titulo.titbanpag*/ 
                    wpag.wano = year(fin.titulo.titdtemi) 
                    wpag.wmes = 0  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlcob .
            if fin.titulo.evecod <> 9
            then
            run por-forne(input fin.titulo.clifor,
                          input fin.titulo.modcod,
                          input set-cod,
                          input month(fin.titulo.titdtemi),
                          input year(fin.titulo.titdtemi),
                          input fin.titulo.titvlcob,
                          input 0).
 
            find first tt-titulo where
                       tt-titulo.clifor = fin.titulo.clifor and
                       tt-titulo.titnum = fin.titulo.titnum and
                       tt-titulo.modcod = fin.titulo.modcod
                       no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                assign
                    tt-titulo.clifor = fin.titulo.clifor
                    tt-titulo.titnum = fin.titulo.titnum
                    tt-titulo.modcod = fin.titulo.modcod
                    .
            end.
            assign
                tt-titulo.titvlcob = tt-titulo.titvlcob + fin.titulo.titvlcob
                tt-titulo.titvlpag = tt-titulo.titvlpag + fin.titulo.titvlpag
                .
                    
                       
             
        end.
        
        if vdt > 06/30/13
        then run fin-titudesp.
        
        for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtemi = vdt 
                             no-lock:
        
            find first titudesp where
                               titudesp.empcod = banfin.titulo.empcod and
                               titudesp.titnat = banfin.titulo.titnat and
                               titudesp.modcod = banfin.titulo.modcod and
                               titudesp.etbcod = banfin.titulo.etbcod and
                               titudesp.clifor = banfin.titulo.clifor and
                               titudesp.titnum = banfin.titulo.titnum and
                               titudesp.titdtemi = banfin.titulo.titdtemi
                               no-lock no-error.
            if avail titudesp and vdt > 06/30/13
            then next. 
            
            disp titulo.titnum with frame f-proc .
            pause 0. 
            set-cod = 0.
            if vsetcod > 0 
            then do:
                
                            if  banfin.titulo.titbanpag > 0 and
                            banfin.titulo.titbanpag <> vsetcod
                            then next.
                            if banfin.titulo.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> vsetcod 
                                    then next.
                                    set-cod = foraut.setcod.
                                end.
                                else next.
                            end.
            end.
            
            else if banfin.titulo.titbanpag = 0
            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    set-cod = foraut.setcod.
                                end.
                                else set-cod = banfin.titulo.titbanpag.
            end.
            
            if set-cod = 0
            then do:
                if banfin.titulo.titbanpag = 0
                then set-cod = 99.
                else set-cod = banfin.titulo.titbanpag.
            end.
            
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = set-cod /*banfin.titulo.titbanpag*/ and
                       wpag.wano = year(banfin.titulo.titdtemi) and
                       wpag.wmes = month(banfin.titulo.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtemi) 
                    wpag.wmes = month(banfin.titulo.titdtemi)  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlcob .

            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*banfin.titulo.titbanpag*/ and
                       wpag.wano = year(banfin.titulo.titdtemi) and
                       wpag.wmes = month(banfin.titulo.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtemi) 
                    wpag.wmes = month(banfin.titulo.titdtemi)  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlcob .
 
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = set-cod /*banfin.titulo.titbanpag*/ and
                       wpag.wano = year(banfin.titulo.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtemi) 
                    wpag.wmes = 0  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlcob .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlcob .
            if banfin.titulo.evecod <> 9
            then
            run por-forne(input banfin.titulo.clifor,
                          input banfin.titulo.modcod,
                          input set-cod,
                          input month(banfin.titulo.titdtemi),
                          input year(banfin.titulo.titdtemi),
                          input banfin.titulo.titvlcob,
                          input 0).

            find first tt-titulo where
                       tt-titulo.clifor = banfin.titulo.clifor and
                       tt-titulo.titnum = banfin.titulo.titnum and
                       tt-titulo.modcod = banfin.titulo.modcod
                       no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                assign
                    tt-titulo.clifor = banfin.titulo.clifor
                    tt-titulo.titnum = banfin.titulo.titnum
                    tt-titulo.modcod = banfin.titulo.modcod
                    .
            end.
            assign
                tt-titulo.titvlcob = tt-titulo.titvlcob + 
                            banfin.titulo.titvlcob
                tt-titulo.titvlpag = tt-titulo.titvlpag + 
                            banfin.titulo.titvlpag
                .

        end.
        
        /**** Inici Credito 

        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = no   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtemi =  vdt and 
                                  fin.titluc.evecod = 8 
                                  no-lock:

            if  fin.titluc.titbanpag = 0 then next.
            disp fin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod > 0 
            then do:
                        if  fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> vsetcod
                        then next.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                                set-cod = foraut.setcod.
                            end.
                            else next.
                        end.
            end. 
            if fin.titluc.titbanpag = 0
            then next.
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = month(fin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = month(fin.titluc.titdtemi)  .
            end.
            wpag.wrec  = wpag.wrec + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = month(fin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = month(fin.titluc.titdtemi)  .
            end.
            wpag.wrec  = wpag.wrec  + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = 0  .
            end.
            wpag.wrec  = wpag.wrec  + fin.titluc.titvlcob.

            run por-forne(input fin.titluc.clifor,
                          input fin.titluc.modcod,
                          input fin.titluc.titbanpag,
                          input month(fin.titluc.titdtemi),
                          input year(fin.titluc.titdtemi),
                          input 0,
                          input fin.titluc.titvlcob).
 
        end.
        
         Fim credito ****/
        /***** Inicio Debito 
        
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = yes   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtemi =  vdt and
                                  fin.titluc.evecod = 9 
                                  no-lock:

            if  fin.titluc.titbanpag = 0 then next.
            disp fin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod > 0 
                    then do:
                        if  fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> vsetcod
                        then next.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                    end. 
            if fin.titluc.titbanpag = 0
            then next.
            
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = month(fin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = month(fin.titluc.titdtemi)  .
            end.
            wpag.wdeb  = wpag.wdeb + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = month(fin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = month(fin.titluc.titdtemi)  .
            end.
            wpag.wdeb  = wpag.wdeb  + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtemi) 
                    wpag.wmes = 0  .
            end.
            wpag.wdeb  = wpag.wdeb  + fin.titluc.titvlcob.

        end.
        /******/ Fim Debito ******/
       /* fin.titluc */
       
       /**** Inicio Credito /****/
       
       for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = no            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtemi =  vdt  /*      and
                                  banfin.titluc.titsit   = "PAG"*/ and
                                  banfin.titluc.evecod = 8  
                                  no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            disp banfin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod > 0 
            then do:
                        if  banfin.titluc.titbanpag > 0 and
                            banfin.titluc.titbanpag <> vsetcod
                        then next.
                        /*
                        if banfin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                        */
            end. 
            if banfin.titluc.titbanpag = 0
            then next.
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = month(banfin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = month(banfin.titluc.titdtemi)  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = month(banfin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = month(banfin.titluc.titdtemi)  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = 0  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            run por-forne(input banfin.titluc.clifor,
                          input banfin.titluc.modcod,
                          input banfin.titluc.titbanpag,
                          input month(banfin.titluc.titdtemi),
                         input year(banfin.titluc.titdtemi),
                          input 0,
                          input banfin.titluc.titvlcob).
         end.
       
        /***/ Fim Credito ****/
        /**** Inicio Debito /****/
        
        for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = yes            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtemi =  vdt    /*    and
                                  banfin.titluc.titsit   = "PAG"*/ and
                                  banfin.titluc.evecod = 9
                                   no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            disp banfin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod > 0 
            then do:
                        if  banfin.titluc.titbanpag > 0 and
                            banfin.titluc.titbanpag <> vsetcod
                        then next.
                        /*
                        if banfin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                        */
            end. 
            if banfin.titluc.titbanpag = 0
            then next.
            
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = month(banfin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = month(banfin.titluc.titdtemi)  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = month(banfin.titluc.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = month(banfin.titluc.titdtemi)  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtemi) 
                    wpag.wmes = 0  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
         
        end.

 
        /***/ Fim Debito ****/
        /*banfin.titluc*/
        
        if vsetcod > 0
        then do:
        for each fin.titulo where fin.titulo.empcod = wempre.empcod
                              and fin.titulo.titnat = yes
                              and fin.titulo.modcod = wmodal.modcod
                              /*and fin.titulo.etbcod = estab.etbcod*/
                              and fin.titulo.titdtemi = vdt
                              /*
                              and fin.titulo.evecod <> 9    
                              */
                            no-lock.
                            
            if fin.titulo.evecod = 9
            then next.        
            if vsetcod > 0 and fin.titulo.titbanpag <> vsetcod
            then next.

            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtven) and
                       wpag.wmes = month(fin.titulo.titdtven) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtven) 
                    wpag.wmes = month(fin.titulo.titdtven).
            end.
            wpag.apagar = wpag.apagar + fin.titulo.titvlcob
                          - fin.titulo.titvlpag.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtven) and
                       wpag.wmes = month(fin.titulo.titdtven) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtven) 
                    wpag.wmes = month(fin.titulo.titdtven).
            end.
            wpag.apagar = wpag.apagar + fin.titulo.titvlcob
                          - fin.titulo.titvlpag.
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtven) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtven) 
                    wpag.wmes = 0.
            end.
            wpag.apagar = wpag.apagar + fin.titulo.titvlcob
                          - fin.titulo.titvlpag. 
        end.
        end.

    end.
end.

/*
for each wpag where wmod <> "" and
                    wset <> 0 and
                    wano = 2013 and
                    wmes = 5
                    no-lock.
    disp wpag.wpag(total).
    pause 0.
end.    
pause .
*/

def buffer bwpag for wpag.
def buffer bmodgru for modgru.
def buffer bmetadesp for metadesp.
for each wpag where wpag.wmod <> "" and
                    wpag.wset <> 0  and
                    wpag.wano <> 0 and
                    wpag.wmes <> 0 :
                    
    find first wac-cla where wac-cla.wmod = wpag.wmod and
                             wac-cla.wset = wpag.wset
                no-error.
    if not avail wac-cla
    then do:
        create wac-cla.
        assign
            wac-cla.wmod = wpag.wmod
            wac-cla.wset = wpag.wset
            .
    end.                             
    wac-cla.wpag = wac-cla.wpag + wpag.wpag.
    wac-cla.wrec = wac-cla.wrec + wpag.wrec.
    wac-cla.wdeb = wac-cla.wdeb + wpag.wdeb.

    find first metadesp where  metadesp.etbcod = setbcod and
                         metadesp.setcod = wpag.wset and
                         metadesp.metano = wpag.wano and
                         metadesp.metmes = wpag.wmes and
                         metadesp.modgru = "" and
                         metadesp.modcod = wpag.wmod
                         no-lock no-error.
    if avail metadesp
    then assign
            wpag.wmet = metadesp.metval
            wac-cla.wmet = wac-cla.wmet + metadesp.metval. 
    
    find first modgru where modgru.modcod = wpag.wmod and 
                            modgru.mogsup <> 0 no-lock no-error.
    if not avail modgru then next.                        
    find first bmodgru where bmodgru.mogcod = modgru.mogsup no-lock.
    wpag.wgru = bmodgru.modcod.
    wac-cla.wgru = bmodgru.modcod.
    find first wgru where
               wgru.wmod = bmodgru.modcod and
               wgru.wset = wpag.wset and
               wgru.wano = wpag.wano and
               wgru.wmes = wpag.wmes 
               no-error.
    if not avail wgru
    then do:
        create wgru.
        assign
            wgru.wmod = bmodgru.modcod
            wgru.wset = wpag.wset
            wgru.wano = wpag.wano
            wgru.wmes = wpag.wmes.
    end.
    find first bmetadesp where  bmetadesp.etbcod = setbcod and
                         bmetadesp.setcod = wgru.wset and
                         bmetadesp.metano = wgru.wano and
                         bmetadesp.metmes = wgru.wmes and
                         bmetadesp.modgru = wgru.wmod and
                         bmetadesp.modcod = ""
                         no-lock no-error.
    if avail bmetadesp and bmetadesp.metval > 0
    then do:
        wgru.wmet = bmetadesp.metval.
        /*
        message wgru.wano wgru.wmes bmetadesp.modgru bmetadesp.metval. pause.
        */
    end.
    else wgru.wmet = wgru.wmet + wpag.wmet.    
    
    wgru.wpag = wgru.wpag + wpag.wpag.      
    wgru.wrec = wgru.wrec + wpag.wrec.    
    wgru.wdeb = wgru.wdeb + wpag.wdeb.
end.

for each wpag where wpag.wmod = "" and
                    wpag.wset <> 0  and
                    wpag.wano <> 0  and
                    wpag.wmes <> 0:
    find metadesp where  metadesp.etbcod = setbcod and
                         metadesp.setcod = wpag.wset and
                         metadesp.metano = wpag.wano and
                         metadesp.metmes = wpag.wmes and
                         metadesp.modgru = "" and
                         metadesp.modcod = ""
                         no-lock no-error.
    if avail metadesp and metadesp.metval <> 0
    then wpag.wmet = metadesp.metval. 
    else do:
        for each wgru where
                 wgru.wmod <> "" and
                 wgru.wset = wpag.wset and
                 wgru.wano = wpag.wano and
                 wgru.wmes = wpag.wmes
                 :
            wpag.wmet = wpag.wmet + wgru.wmet.
        end.  
    end.
end.  

def temp-table wsetor
    field wsetcod like setaut.setcod.
for each wgru:
    find first wacu where
               wacu.wset = wgru.wset and 
               wacu.wmod = wgru.wmod no-error.
    if not avail wacu
    then do:
        create wacu.
        wacu.wset = wgru.wset.
        wacu.wmod = wgru.wmod.
    end.
    wacu.wpag = wacu.wpag + wgru.wpag.
    wacu.wrec = wacu.wrec + wgru.wrec. 
    wacu.wdeb = wacu.wdeb + wgru.wdeb.
    wacu.wmet = wacu.wmet + wgru.wmet.   
    find first wsetor where wsetor.wsetcod = wgru.wset no-error.
    if not avail wsetor
    then do:
        create wsetor.
        wsetor.wsetcod = wgru.wset.
    end.
end.    
form with frame f-accla. 
form with frame f-disp3.
def buffer bwgru for wgru.
form with frame f-disp.
form with frame f-disp1.       
def var varquivo as char.


def var varq as char.

    if opsys = "UNIX"
    then varq = "/admcom/relat/rmetdes-emissao" 
         + string(time)
         + ".csv".
    else varq = "l:\relat\rmetdes"
         + string(time)
         + ".csv".

    hide message no-pause.

    /**
    message "Gerando arquivo Excel ...".

    output to value(varq).
        
    run p-arq-excel.
    
    output close.

run msg2.p (input-output dsresp, 
                input "     ARQUIVO GERADO COM SUCESSO EM:" 
                    + " !" 
                    + "!"
                    + "        " + VARQ
                    + "!"
                    + "!     PRESSIONE ENTER PARA CONTINUAR ..." , 
                input " *** ATENCAO *** ", 
                input "    OK").        
        
       **/
        
if opsys = "UNIX"
then varquivo = "/admcom/relat/rmetdes-emissao." + string(time).
else varquivo = "l:~\relat~\rmetdes." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """DESPESAS PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" ATE "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "120"
            &Form      = "frame f-cabcab"}
def var val-sal as dec.
def var val-pag as dec.
def var val-met as dec.
def var val-rec as dec.
def var val-deb as dec.

/* estava comentado antes de 18/04, e nao calculava o "a pagar"     */
/* recoloquei o run para ajustar                                    */   
run saldototal. 

for each wsetor:

/******************************************************************

    for each wgru where wgru.wset = wsetor.wsetcod and
                    wgru.wmod <> "" and
                    wgru.wmes <> 0
                    break 
                          by wgru.wano
                          by wgru.wmes  :
        if first-of(wgru.wmes)
        then do:
            find setaut where setaut.setcod = wgru.wset no-lock.
            disp setaut.setcod label "Setor"
                 setaut.setnom no-label
                 wgru.wmes label "Mes/Ano" format "99" 
                "/"       no-label
                wgru.wano no-label FORMAT "9999"
                with frame f-set 1 down no-box side-label.

        end.
        v-wacumeta = 0.
        for each wpag where wpag.wgru = wgru.wmod and
                            wpag.wset = wgru.wset and
                            wpag.wano = wgru.wano and
                            wpag.wmes = wgru.wmes
                            no-lock:
            find first  fin.modal where 
                        modal.modcod = wpag.wmod no-lock no-error.

            def var vtot as dec initial 0.
            def var v-tot as dec initial 0.
            def var  val-salac as dec initial 0.
            def var  vtotgeral as dec initial 0.

              assign vtot = 0
                   vval = 0.
                                
            for each swpag where 
                     swpag.wmod = modal.modcod and
                     swpag.wset = wgru.wset and
                     swpag.wano = wgru.wano and
                     swpag.wmes = wgru.wmes
                            no-lock:

              assign vtot = vtot + swpag.wpag.
                             
            end.        
                    
            val-sal = wpag.wmet - wpag.wpag + wpag.wrec - wpag.wdeb.        
            
         /* vval = val-sal - vtot + wpag.wdeb. */
            
            vval = vtot.

            find first tt-totgru where tt-totgru.wmod = wgru.wmod no-lock 
            no-error.
            if not avail tt-totgru then do:   
                create tt-totgru.
                assign tt-totgru.wmod = wgru.wmod
                       tt-totgru.tot  = tt-totgru.tot + vval.
            end.
            else do:
                assign tt-totgru.tot = tt-totgru.tot + vval.
            end.            

            
            vpct-real = ((wpag.wpag + wpag.wdeb - wpag.wrec) / wpag.wmet) * 100.
            
            disp modal.modcod   column-label "Sigla" 
                 modal.modnom     format "x(20)"  column-label "Descricao"
                 wpag.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                 wpag.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                 vpct-real when vpct-real <> ?
                 column-label "%Real" format ">>>9.99%"
                 wpag.wrec  column-label "Creditos"  format "->>,>>>,>>9.99"
                 wpag.wdeb  column-label "Debitos"   format "->>,>>>,>>9.99"   
                 val-sal  format "->>,>>>,>>9.99" column-label "Saldo" 
                 vval  format "->>,>>>,>>9.99" column-label "A pagar"
                 with frame f-disp down width 120.
            down with frame f-disp.
            
        vtotmet = vtotmet + wgru.wmet.
        vtotpag = vtotpag + wgru.wpag.
        vtotrec = vtotrec + wgru.wrec.
        vtotdeb = vtotdeb + wgru.wdeb.
        vtotsal = vtotsal + val-sal.
        vtotval = vtotval + vval.            
            
            v-wacumeta = v-wacumeta + wpag.wmet.

            v-tot = v-tot + vval.
            if sfor then
            for each wfor where
                     wfor.wmod = modal.modcod and
                     wfor.wset = wpag.wset   and
                     wfor.wmes = wpag.wmes and
                     wfor.wano = wpag.wano
                     no-lock:
                find first forne where forne.forcod = wfor.wfor
                            no-lock no-error.
                disp    
                    string(forne.forcod) + "-" +
                        (if avail forne then forne.fornom else "")
                            @ modal.modnom 
                    wfor.wpag @ wpag.wpag
                     wfor.wrec @ wpag.wrec
                     with frame f-disp.
                down with frame f-disp.
            end.
            /**
            if sfor
            then do:
                put fill("-",120) format "x(100)" skip.
            end. 
                         **/
        end.                    
        put fill("-",120) format "x(100)".
        vval = v-tot.
        find first modgru where modgru.modcod = wgru.wmod and
                modgru.mognom <> "" no-lock no-error.
                
        val-sal = wgru.wmet - wgru.wpag + wgru.wrec - wgru.wdeb.     
        
        find first tt-totgru where tt-totgru.wmod = wgru.wmod no-lock no-error.
        if avail tt-totgru then do:
            assign vval  = tt-totgru.tot
                   vtotgeral = vval + vtotgeral.
        end.
        
        vpct-real = ((wgru.wpag + wgru.wdeb - wgru.wrec) / wgru.wmet) * 100.
         
        disp modgru.modcod when avail modgru  @ modal.modcod    
             modgru.mognom when avail modgru   @ modal.modnom    
             wgru.wmet       @ wpag.wmet
             wgru.wpag       @ wpag.wpag
             vpct-real when vpct-real <> ?
              wgru.wrec       @ wpag.wrec
             wgru.wdeb       @ wpag.wdeb
             val-sal
             vval
        with frame f-disp.
        down with frame f-disp.
        put fill("=",120) format "x(100)".
        if last-of(wgru.wmes)
        then do:
            disp  
                "--------------" @ wpag.wpag
                "--------------" @ wpag.wmet
                "--------------" @ wpag.wrec
                "--------------" @ wpag.wdeb
                "--------------" @ val-sal
                "--------------" @ vval
            with frame f-disp.
            down with frame f-disp.     
                   
            find first wpag where wpag.wmod = "" and
                                  wpag.wset = wgru.wset and  
                                  wpag.wano = wgru.wano and
                                  wpag.wmes = wgru.wmes 
                                  . 
            val-sal = wpag.wmet - wpag.wpag + wpag.wrec - wpag.wdeb.                      
            
            vval = vtotgeral.
            
            vpct-real = ((wpag.wpag + wpag.wdeb - wpag.wrec) 
                            / v-wacumeta) * 100.
            disp    "Totais" @ modal.modnom
                wpag.wpag @ wpag.wpag
                /*wpag.wmet @ wpag.wmet*/
                v-wacumeta  @ wpag.wmet format "->>,>>>,>>9.99"
                vpct-real when vpct-real <> ?
                wpag.wrec @ wpag.wrec
                wpag.wdeb @ wpag.wdeb
                val-sal
                vval format "->>,>>>,>>9.99"
                with frame f-disp.
            down(1) with frame f-disp.  
            put skip(1).           
            val-sal = 0.       
             /*********************/
            put skip(1).
            find setaut where setaut.setcod = wsetor.wsetcod no-lock.
            disp setaut.setcod label "Setor"
                 setaut.setnom no-label
                 "   ACUMULADO NO MES  "
                with frame f-set2 1 down no-box side-label.

            val-sal = 0.
            val-pag = 0.
            val-met = 0.
            val-rec = 0.
            val-deb = 0.
            for each bwgru where bwgru.wset = wgru.wset and
                                 bwgru.wmod <> "" and
                                 bwgru.wano = wgru.wano and
                                 bwgru.wmes = wgru.wmes
                                 no-lock :
                find first modgru where modgru.modcod = bwgru.wmod and
                    modgru.mognom <> "" no-lock no-error.
                    val-sal = bwgru.wmet - bwgru.wpag + bwgru.wrec
                                - bwgru.wdeb.
                    
                  find first tt-totgru where 
                            tt-totgru.wmod = bwgru.wmod no-lock no-error.
            if avail tt-totgru then do:
            assign vval = tt-totgru.tot
                   vtotgeral = vval + vtotgeral.
        end.    
    
     
                vpct-real = ((bwgru.wpag + bwgru.wdeb - bwgru.wrec)
                                    / bwgru.wmet) * 100.
                
                disp 
                    modgru.modcod   when avail modgru column-label "Sigla" 
                    modgru.mognom   when avail modgru  
                    format "x(20)"  column-label "Descricao"
                    bwgru.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                    bwgru.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                    vpct-real when vpct-real <> ?  
                    column-label "%Real" format "->>>9.99%"
                    bwgru.wrec  column-label "Creditos" format "->>,>>>,>>9.99"
                    bwgru.wdeb column-label  "Debitos"  format "->>,>>>,>>9.99"
                    val-sal   format "->>,>>>,>>9.99" column-label "Saldo" 
                    vval   format "->>,>>>,>>9.99" column-label "A pagar" 
                    with frame f-disp3 down width 140.
                down with frame f-disp3. 
                val-pag = val-pag + bwgru.wpag.
                val-rec = val-rec + bwgru.wrec.
                val-deb = val-deb + bwgru.wdeb.
                val-met = val-met + bwgru.wmet.
                
        vtotmet = vtotmet + bwgru.wmet.
        vtotpag = vtotpag + bwgru.wpag.
        vtotrec = vtotrec + bwgru.wrec.
        vtotdeb = vtotdeb + bwgru.wdeb.
        vtotsal = vtotsal + val-sal.
        vtotval = vtotval + vval.                
            end.
            val-sal = 0.
            disp   
                "--------------" @ bwgru.wpag
                "--------------" @ bwgru.wmet
                "--------------" @ bwgru.wrec 
                "--------------" @ bwgru.wdeb
                "--------------" @ val-sal 
                "--------------" @ vval
                with frame f-disp3.
            down with frame f-disp3.  
            find first wpag where wpag.wmod = "" and
                                  wpag.wset = wgru.wset and  
                                  wpag.wano = wgru.wano and
                                  wpag.wmes = wgru.wmes. 
            /*                       
            val-met = wpag.wmet.
            */
            val-sal = val-met - val-pag + val-rec - val-deb.   
            vval = vtotgeral.
            vpct-real = ((val-pag + val-deb - val-rec) / val-met) * 100.
            disp    "Totais" @ modgru.mognom
                val-pag @ bwgru.wpag
                val-met @ bwgru.wmet format "->>,>>>,>>9.99"
                vpct-real when vpct-real <> ?
                val-rec @ bwgru.wrec
                val-deb @ bwgru.wdeb
                val-sal
                vval format "->>,>>>,>>9.99"
                with frame f-disp3.
            down with frame f-disp3.        
            put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
            /*********************/
        end. 
    end.
    if vdtf - vdti > 31
    then do:
        put skip(1).
        find setaut where setaut.setcod = wsetor.wsetcod no-lock.
        disp setaut.setcod label "Setor"
             setaut.setnom no-label   format "x(20)"
             "   ACUMULADO NO PERIODO - CLASSES"
            with frame f-set1 1 down no-box side-label.
        val-sal = 0.
        val-pag = 0.
        val-deb = 0.
        val-met = 0.
        val-rec = 0.
        vtotal-apagar = 0.
        for each wac-cla where wac-cla.wmod <> ""  and
                               wac-cla.wset = wsetor.wset 
                    break by wac-cla.wset
                          by wac-cla.wgru
                          by wac-cla.wmod:
            
            find first  fin.modal where 
                        modal.modcod = wac-cla.wmod no-lock no-error.
            
            release swac-cla.
            find first swac-cla where
                       swac-cla.wmod = wac-cla.wmod and
                       swac-cla.wset = wac-cla.wset
                             no-lock no-error.

            if avail swac-cla
            then assign vtotal-apagar = vtotal-apagar + swac-cla.wpag.

            val-sal = wac-cla.wmet - wac-cla.wpag + wac-cla.wrec
                        - wac-cla.wdeb.   
            vpct-real = ((wac-cla.wpag + val-deb - val-rec)
                                / wac-cla.wmet) * 100.                 
            disp modal.modcod  column-label "Sigla" 
                 modal.modnom  format "x(20)"  column-label "Descricao"
                 wac-cla.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                 wac-cla.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                 vpct-real when vpct-real <> ?  
                   column-label "%Real" format "->>>9.99"
                 val-rec  format "->>,>>>,>>9.99" column-label "Creditos"
                 val-deb  format "->>,>>>,>>9.99" column-label "Debitos"
                 val-sal  format "->>,>>>,>>9.99" column-label "Saldo" 
                 swac-cla.wpag when avail swac-cla column-label "A Pagar"
                with frame f-accla down width 140.
            down with frame f-accla.
            val-pag = val-pag + wac-cla.wpag.
            val-rec = val-rec + wac-cla.wrec.
            val-deb = val-deb + wac-cla.wdeb.
            val-met = val-met + wac-cla.wmet.
        vtotmet = vtotmet + wac-cla.wmet.
        vtotpag = vtotpag + wac-cla.wpag.
        vtotrec = vtotrec + val-rec.
        vtotdeb = vtotdeb + val-deb.
        vtotsal = vtotsal + val-sal.
        vtotval = vtotval + swac-cla.            
            if last-of(wac-cla.wgru)
            then do:
                put fill("-",120) format "x(90)".
                val-sal = 0.
                find first wacu where wacu.wmod = wac-cla.wgru and
                                  wacu.wset = wac-cla.wset no-error
                                  . 
                find first modgru where modgru.modcod = wacu.wmod and
                                modgru.mognom <> "" no-lock no-error.
                if avail wacu
                then       
                val-sal = wacu.wmet - wacu.wpag + wacu.wrec - wacu.wdeb. 
                vpct-real = (wacu.wpag + wacu.wdebwacu.wdeb -                                 wacu.wrecwacu.wrec) / wacu.wmet) * 100.   
                disp modgru.modcod when avail modgru @ modal.modcod
                    modgru.mognom when avail modgru @ modal.modnom
                    wacu.wpag when avail wacu  @ wac-cla.wpag 
                    wacu.wmet when avail wacu  @ wac-cla.wmet
                    vpct-real  when vpct-real <> ?
                    vtotal-apagar @ swac-cla.wpag
                /*  wacu.wrec @ wac-cla.wrec
                    wacu.wdeb @ wac-cla.wdeb   */
                    val-sal    
                    with frame f-accla.
                down with frame f-accla.        

                assign vtotal-apagar = 0.

                put skip(1)
                fill("=",100) format "x(90)"
                skip(1).
            end.
        end.
        val-sal = 0.
        disp   
                "--------------" @ wac-cla.wpag
                "--------------" @ wac-cla.wmet
            /*  "--------------" @ wac-cla.wrec 
                "--------------" @ wac-cla.wdeb */
                "--------------" @ val-sal 
                with frame f-accla.
         down with frame f-accla.       
        val-sal = val-met - val-pag + val-rec - val-deb.
        vpct-real = (val-pag + val-deb - val-rec) / val-met) * 100.
        disp    "Totais" @ modal.modnom
                val-pag @ wac-cla.wpag
                val-met @ wac-cla.wmet format "->>,>>>,>>9.99"
                vpct-real when vpct-real <> ?
            /*  val-rec @ wac-cla.wrec
                val-deb @ wac-cla.wdeb  */
                val-sal 
                with frame f-accla.
 
******************************************************/

        put skip(1).
        find setaut where setaut.setcod = wsetor.wsetcod no-lock.
        disp setaut.setcod label "Setor"
             setaut.setnom no-label format "x(20)"
             "   ACUMULADO NO PERIODO - GRUPOS"
            with frame f-set0 1 down no-box side-label.

        v-wacumeta = 0.
        v-wacupag = 0.
        val-rec = 0.
        val-deb = 0.
        val-pag = 0.
        val-met = 0.

        for each wacu where wacu.wset = wsetor.wsetcod:
            find first modgru where modgru.modcod = wacu.wmod and
                modgru.mognom <> "" no-lock no-error.
                /*
            vval = 0.
            find first tt-totgru where 
                            tt-totgru.wmod = modgru.modcod no-lock no-error.
            if avail tt-totgru 
            then vval = tt-totgru.tot.
                  */
            find first swacu where swacu.wmod = wacu.wmod no-lock no-error.
            
            val-sal = wacu.wmet - wacu.wpag + wacu.wrec - wacu.wdeb.
            vpct-real = ((wacu.wpag + wacu.wdeb - wacu.wrec) / wacu.wmet) * 100.
            disp 
                modgru.modcod when avail modgru  column-label "Sigla" 
                modgru.mognom when avail modgru    
                format "x(20)"  column-label "Descricao"
                wacu.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                wacu.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                vpct-real  when vpct-real <> ?
                column-label "%Real" format "->>>9.99"
                wacu.wrec  column-label "Creditos" format "->>,>>>,>>9.99"
                wacu.wdeb  column-label "Debitos"  format "->>,>>>,>>9.99"    
                val-sal    format "->>,>>>,>>9.99" column-label "Saldo"
                swacu.wpag when avail swacu column-label "A Pagar"
                with frame f-disp1 down width 140.
            down with frame f-disp1. 
        vtotmet = vtotmet + wacu.wmet.
        vtotpag = vtotpag + wacu.wpag.
        vtotrec = vtotrec + wacu.wrec.
        vtotdeb = vtotdeb + wacu.wdeb.
        vtotsal = vtotsal + val-sal.
        if avail swacu
        then vtotval = vtotval + swacu.wpag.
            v-wacumeta = v-wacumeta  + wacu.wmet.
            if avail swacu
            then v-wacupag  = v-wacupag + swacu.wpag.
            val-rec = val-rec + wacu.wrec.  
            val-deb = val-deb + wacu.wdeb.                     
            val-pag = val-pag + wacu.wpag.
            val-met = val-met + wacu.wmet.
        end.
        /*
        val-sal = 0.
        val-pag = 0.
        val-deb = 0.
        val-met = 0.
        val-rec = 0.
        */
        disp   
                "--------------" @ wacu.wpag
                "--------------" @ wacu.wmet
                "--------------" @ wacu.wrec
                "--------------" @ wacu.wdeb
                "--------------" @ val-sal
                "--------------" @ swacu.wpag
                with frame f-disp1.
         down with frame f-disp1.       
         /*
         for each wpag where wpag.wmod = "" and
                              wpag.wset = wsetor.wsetcod :

            val-rec = val-rec + wpag.wrec.  
            val-deb = val-deb + wpag.wdeb.                     
            val-pag = val-pag + wpag.wpag.
            val-met = val-met + wpag.wmet.
        end.*/
        val-sal = val-met - val-pag + val-rec - val-deb.
        vpct-real = ((val-pag + val-deb - val-rec) / v-wacumeta) * 100.
        disp    "Totais" @ modgru.mognom
                val-pag @ wacu.wpag
                /*val-met @ wacu.wmet*/
                v-wacumeta @ wacu.wmet format "->>,>>>,>>9.99"
                vpct-real when vpct-real <> ?
                val-rec @ wacu.wrec
                val-deb @ wacu.wdeb
                val-sal
                v-wacupag @ swacu.wpag
                with frame f-disp1.
        down with frame f-disp1.        
        put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
    /*end.*/
end.

            put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
            
            vpct-real = ((vtotpag + vtotdeb - vtotrec) / vtotmet) * 100.
            
            disp "Total Geral" format "x(29)" 
                 vtotmet   format "->>,>>>,>>9.99"    
                 vtotpag  format "->>,>>>,>>9.99"
                 vpct-real when   vpct-real <> ?
                 vtotrec  format "->>,>>>,>>9.99"
                 vtotdeb   format "->>,>>>,>>9.99"
                 vtotsal  format "->>,>>>,>>9.99"
                 vtotval   format "->>,>>>,>>9.99"
                 with frame f-disp10 down width 140.
            down with frame f-disp10.
            put skip(1)
            fill("=",120) format "x(90)"
            skip(1).

output close.

if sfuncod = 101
then do:
output to ./tt-titulo-meta-cl.txt.
for each tt-titulo.
    export tt-titulo.clifor
         tt-titulo.titnum
         tt-titulo.modcod
         tt-titulo.titvlcob
         tt-titulo.titvlpag
         .
end.
output close.
end. 

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
   {mrod.i} .
end.

do:
return.
end.
procedure limpa-temp:
    
    for each tt-totgru: delete tt-totgru. end.
    for each swpag: delete swpag. end.
    for each swgru: delete swgru. end.
    for each swacu: delete swacu. end.
    for each swac-cla: delete swac-cla. end.
    for each swsetor: delete swsetor. end.
    for each wpag: delete wpag. end.
    for each wgru: delete wgru. end.
    for each wacu: delete wacu. end.
    for each wfor: delete wfor. end.
    for each wmodal: delete wmodal. end. 

end procedure.

procedure saldototal:

def var vdta as date.
def var vdtini as date.
def var vdtfim as date.
def var vmesini as int.
def var vmesfim as int.
def var vano as int.
def var vseto as int.
def buffer bfmetadesp for metadesp.

/*def var mes-ano as int.*/

/*assign vseto  = num-entries(vsetcod)
       vdtini = date("01/01/" + string(year(today)))
       vdtfim = vdtf. */

do vdt = vdti to vdtf :

    vmes = month(vdt).
    vano = year(vdt).
   
    /*if vmes + vano = mes-ano
    then next.*/
    mes-ano = vmes + vano.
    

/*do vdta = vdtini to vdtfim:

    vmesini = 1.
    vmesfim = month(vdtf).
    vano = year(vdt).
    
    /*if vmes + vano = mes-ano
    then next.
    mes-ano = vmes + vano.*/*/
    
     for each bfmetadesp where  bfmetadesp.etbcod = setbcod and 
           (if vsetcod > 0 then bfmetadesp.setcod = vsetcod else true) and
                             bfmetadesp.metano = vano and
                             bfmetadesp.metmes = vmes and
                             bfmetadesp.modgru = "" and
                             bfmetadesp.modcod <> ""
                             no-lock .

        /*
        find first modgru where modgru.modcod = wpag.wmod and 
                            modgru.mogsup <> 0 no-lock no-error.
        if avail modgru
        then do:
            
        emd.                     
        else*/ do:          
            find first swpag where 
                       swpag.wmod = bfmetadesp.modcod and
                       swpag.wset = bfmetadesp.setcod and
                       swpag.wano = bfmetadesp.metano and
                       swpag.wmes = bfmetadesp.metmes no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = bfmetadesp.modcod 
                    swpag.wset = bfmetadesp.setcod 
                    swpag.wano = bfmetadesp.metano 
                    swpag.wmes = bfmetadesp.metmes
                    swpag.wmet = bfmetadesp.metval.
                    
            end.
        end.
    end.
end. 
           
           
def var set-cod1 like setaut.setcod.

/*
do vdt = vdti to vdtf:
*/
/*do vdta = vdtini to vdtfim:*/

   /* disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 13 no-label.
    pause 0.  */  
    for each wmodal:
        /*disp wmodal.modcod with frame f-proc .
        pause 0.*/ 

            for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtemi >=  vdti      and
                                  fin.titulo.titdtemi <=  vdtf   /*   and
                                  (fin.titulo.titsit   = "LIB"
                                   or fin.titulo.titsit = "CON")*/ no-lock:
               /* disp titulo.titnum with frame f-proc .
                pause 0.*/
                set-cod1 = 0.

                if vsetcod <> 0 
                    then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> vsetcod
                        then next.
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod
                                then next.
                                set-cod1 = foraut.setcod.
                            end.
                            else next.
                        end.
                    end. 
            if set-cod1 = 0
            then set-cod1 = fin.titulo.titbanpag.
            find first swpag where 
                       swpag.wmod = fin.titulo.modcod and
                       swpag.wset = set-cod1 /*fin.titulo.ti~t~ ~banpag*/ and
                       swpag.wano = year(fin.titulo.titdtven) and
                       swpag.wmes = month(fin.titulo.titdtven) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = fin.titulo.modcod 
                    swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ 
                    swpag.wano = year(fin.titulo.titdtven) 
                    swpag.wmes = month(fin.titulo.titdtven) .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlcob.
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ and
                       swpag.wano = year(fin.titulo.titdtven) and
                       swpag.wmes = month(fin.titulo.titdtven) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = set-cod1 /*fin.titulo.titbanpag */
                    swpag.wano = year(fin.titulo.titdtven) 
                    swpag.wmes = month(fin.titulo.titdtven)  .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlcob .
            
            find first swpag where 
                       swpag.wmod = fin.titulo.modcod and
                       swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ and
                       swpag.wano = year(fin.titulo.titdtven) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = fin.titulo.modcod 
                    swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ 
                    swpag.wano = year(fin.titulo.titdtven) 
                    swpag.wmes = 0  .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlcob .
        end.
        for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtemi >= vdti        and
                             banfin.titulo.titdtemi <= vdtf        /*and
                             (banfin.titulo.titsit = "LIB"
                              or banfin.titulo.titsit = "CON")*/ no-lock:
            /*disp banfin.titulo.titnum with frame f-proc .
            pause 0.*/ 
            set-cod1 = 0.
            if vsetcod <> 0 then do:
                            if banfin.titulo.titbanpag > 0 and
                            banfin.titulo.titbanpag <> 
                             vsetcod then do:
                                next.
                            end.
                            if banfin.titulo.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> 
                                       vsetcod 
                                       then next.
                                    set-cod1 = foraut.setcod.
                                end.
                                else next.
                            end.
                        end.
            if set-cod1 = 0
            then set-cod1 = banfin.titulo.titbanpag.

            find first swpag where 
                       swpag.wmod = banfin.titulo.modcod and
                       swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = banfin.titulo.modcod 
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlcob.

            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlcob .
 
            find first swpag where 
                       swpag.wmod = banfin.titulo.modcod and
                       swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ and
                       swpag.wano = year(vdti) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = banfin.titulo.modcod 
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(vdti) 
                    swpag.wmes = 0  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlcob .
        end.
        
        /* Antonio */
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = no   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtemi >=  vdti        and
                                  fin.titluc.titdtemi <=  vdtf   /*     and
                                  (fin.titluc.titsit = "LIB"
                                    or fin.titluc.titsit = "CON")  */
                                    use-index titdtven
                                  no-lock:

            if  fin.titluc.titbanpag = 0 then next.
            /*disp fin.titluc.titnum with frame f-proc .
            pause 0. */
            if vsetcod <> 0 
                    then do:
                        if  fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> vsetcod
                        then next.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod
                                then next.
                            end.
                            else next.
                        end.
                    end. 
            find first swpag where 
                       swpag.wmod = fin.titluc.modcod and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = fin.titluc.modcod 
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wrec  = swpag.wrec + fin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wrec  = swpag.wrec  + fin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = fin.titluc.modcod and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = fin.titluc.modcod 
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = 0  .
            end.
            swpag.wrec  = swpag.wrec  + fin.titluc.titvlcob.
        end.
       /* fin.titluc */
       
       /** Antonio **/ 
       for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = no            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtemi >=  vdti        and
                                  banfin.titluc.titdtemi <=  vdtf  /*      and
                                  (banfin.titluc.titsit  = "LIB"
                                    or banfin.titluc.titsit = "CON") */
                                    no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            /*disp banfin.titluc.titnum with frame f-proc .
            pause 0.*/
            if vsetcod <> 0 
            then do:
                        if  banfin.titluc.titbanpag > 0 and
                         banfin.titluc.titbanpag <> vsetcod
                        then next.
                        /*
                        if banfin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                            end.
                            else next.
                        end.
                        */
            end. 
            find first swpag where 
                       swpag.wmod = banfin.titluc.modcod and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = banfin.titluc.modcod 
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = month(vdti) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = month(vdti)  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = banfin.titluc.modcod and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(vdti) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = banfin.titluc.modcod 
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(vdti) 
                    swpag.wmes = 0  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
            
        end.
        /*banfin.titluc*/
        
    end.
/*    
end.
*/
def buffer bwpag for wpag.
def buffer bmodgru for modgru.
def buffer bmetadesp for metadesp.


    for each swpag where swpag.wmod <> "" and
                        swpag.wset <> 0  and
                        swpag.wano <> 0 and
                        swpag.wmes <> 0 :
            
                    
        find first swac-cla where swac-cla.wmod = swpag.wmod and
                                 swac-cla.wset = swpag.wset
                    no-error.
        if not avail swac-cla
        then do:
            create swac-cla.
            assign
                swac-cla.wmod = swpag.wmod
                swac-cla.wset = swpag.wset
                .
        end.                             
        swac-cla.wpag = swac-cla.wpag + swpag.wpag.
        swac-cla.wrec = swac-cla.wrec + swpag.wrec.

        find first metadesp where  metadesp.etbcod = setbcod and
                         metadesp.setcod = swpag.wset and
                         metadesp.metano = swpag.wano and
                         metadesp.metmes = swpag.wmes and
                         metadesp.modgru = "" and
                         metadesp.modcod = swpag.wmod
                         no-lock no-error.
        if avail metadesp
        then assign
                swpag.wmet = metadesp.metval
                swac-cla.wmet = swac-cla.wmet + metadesp.metval. 
    
        find first modgru where modgru.modcod = swpag.wmod and 
                                modgru.mogsup <> 0 no-lock no-error.
        if not avail modgru
        then next.
        find first bmodgru where bmodgru.mogcod = modgru.mogsup no-lock.
        swpag.wgru = bmodgru.modcod.
        swac-cla.wgru = bmodgru.modcod.
        find first swgru where
                   swgru.wmod = bmodgru.modcod and
                   swgru.wset = swpag.wset and
                   swgru.wano = swpag.wano and
                   swgru.wmes = swpag.wmes 
                   no-error.
        if not avail swgru
        then do:
            create swgru.
            assign
                swgru.wmod = bmodgru.modcod
                swgru.wset = swpag.wset
                swgru.wano = swpag.wano
                swgru.wmes = swpag.wmes.
        end.
        find first bmetadesp where  bmetadesp.etbcod = setbcod and
                             bmetadesp.setcod = swgru.wset and
                             bmetadesp.metano = swgru.wano and
                             bmetadesp.metmes = swgru.wmes and
                             bmetadesp.modgru = swgru.wmod and
                             bmetadesp.modcod = ""
                             no-lock no-error.
      if avail bmetadesp and bmetadesp.metval > 0
      then do:
          swgru.wmet = bmetadesp.metval.
      end.
      else swgru.wmet = swgru.wmet + swpag.wmet.    
           swgru.wpag = swgru.wpag + swpag.wpag.      
           swgru.wrec = swgru.wrec + swpag.wrec.    
    end.

    for each swpag where swpag.wmod = "" and
                        swpag.wset <> 0  and
                        swpag.wano <> 0  and
                        swpag.wmes <> 0:
        find metadesp where  metadesp.etbcod = setbcod and
                             metadesp.setcod = swpag.wset and
                             metadesp.metano = swpag.wano and
                             metadesp.metmes = swpag.wmes and
                             metadesp.modgru = "" and
                             metadesp.modcod = ""
                             no-lock no-error.
        if avail metadesp and metadesp.metval <> 0
        then swpag.wmet = metadesp.metval. 
        else do:
            for each swgru where
                     swgru.wmod <> "" and
                     swgru.wset = swpag.wset and
                     swgru.wano = swpag.wano and
                     swgru.wmes = swpag.wmes
                      :
                swpag.wmet = swpag.wmet + swgru.wmet.
            end.  
        end.
    end.
      
    for each swgru:
        find first swacu where
                   swacu.wset = swgru.wset and 
                   swacu.wmod = swgru.wmod no-error.
        if not avail swacu
        then do:
            create swacu.
            swacu.wset = swgru.wset.
            swacu.wmod = swgru.wmod.
        end.
        swacu.wpag = swacu.wpag + swgru.wpag.
        swacu.wrec = swacu.wrec + swgru.wrec. 
        swacu.wmet = swacu.wmet + swgru.wmet.   
        find first swsetor where swsetor.wsetcod = swgru.wset no-error.
        if not avail swsetor
        then do:
            create swsetor.
            swsetor.wsetcod = swgru.wset.
        end.
    end. 

end procedure.

procedure por-forne:
    def input parameter vforcod like forne.forcod.
    def input parameter vmodcod like fin.modal.modcod.
    def input parameter vsetcod like setor.setcod.
    def input parameter vmes    as int.
    def input parameter vano    as int.
    def input parameter vpag as dec.
    def input parameter vrec as dec.
     
    find first wfor where
               wfor.wfor = vforcod and
               wfor.wmod   = vmodcod and
               wfor.wset   = vsetcod and
               wfor.wmes   = vmes and
               wfor.wano   = vano no-error.
    if not avail wfor
    then do:
        create wfor.
        wfor.wfor = vforcod.
        wfor.wmod = vmodcod.
        wfor.wset = vsetcod.
        wfor.wmes = vmes.
        wfor.wano = vano.
    end.           
    assign
        wfor.wpag = wfor.wpag + vpag
        wfor.wrec = wfor.wrec + vrec
        .

end procedure.

procedure p-arq-excel.
run saldototal.

for each wsetor:
        put skip(1).
        find setaut where setaut.setcod = wsetor.wsetcod no-lock.
        put setaut.setcod
            ";"
             setaut.setnom
             ";"
             "   ACUMULADO NO PERIODO - GRUPOS"
             skip.

        v-wacumeta = 0.
        v-wacupag = 0.
        val-rec = 0.
        val-deb = 0.
        val-pag = 0.
        val-met = 0.

        for each wacu where wacu.wset = wsetor.wsetcod:
            find first modgru where modgru.modcod = wacu.wmod and
                modgru.mognom <> "" no-lock no-error.
            
            find first swacu where swacu.wmod = wacu.wmod no-lock no-error.
            
            val-sal = wacu.wmet - wacu.wpag + wacu.wrec - wacu.wdeb.
            put 
                (if avail modgru then modgru.modcod else "")
                ";"
                (if avail modgru then modgru.mognom else "")
                format "x(20)"
                ";"
                wacu.wmet  format "->>,>>>,>>9.99"
                ";"
                wacu.wpag format "->>,>>>,>>9.99"
                ";"
                wacu.wrec   format "->>,>>>,>>9.99"
                ";"
                wacu.wdeb  format "->>,>>>,>>9.99"
                    ";"
                val-sal    format "->>,>>>,>>9.99"
                ";"
                if avail swacu then swacu.wpag else 0
                skip.
        vtotmet = vtotmet + wacu.wmet.
        vtotpag = vtotpag + wacu.wpag.
        vtotrec = vtotrec + wacu.wrec.
        vtotdeb = vtotdeb + wacu.wdeb.
        vtotsal = vtotsal + val-sal.
        if avail swacu
        then vtotval = vtotval + swacu.wpag.
            v-wacumeta = v-wacumeta  + wacu.wmet.
            if avail swacu
            then v-wacupag  = v-wacupag + swacu.wpag.
            val-rec = val-rec + wacu.wrec.  
            val-deb = val-deb + wacu.wdeb.                     
            val-pag = val-pag + wacu.wpag.
            val-met = val-met + wacu.wmet.
        end.
        /*
        val-sal = 0.
        val-pag = 0.
        val-deb = 0.
        val-met = 0.
        val-rec = 0.
        */
        put
                "--------------"
                ";"
                "--------------"
                ";"
                "--------------"
                ";"
                "--------------"
                ";"
                "--------------"
                ";"
                "--------------"
                skip.
        val-sal = val-met - val-pag + val-rec - val-deb.
        put
            "Totais"
             ";"
                val-pag
                 ";"
                v-wacumeta  format "->>,>>>,>>9.99"
                ";"
                val-rec
                ";" 
                val-deb
                ";" 
                val-sal
                ";"
                v-wacupag
                skip.
        put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
    /*end.*/
end.

            put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
            
            put "Total Geral" format "x(29)"
                ";"
                 vtotmet / 2  format "->>,>>>,>>9.99"
                 ";"    
                 vtotpag / 2 format "->>,>>>,>>9.99"
                 ";"
                 vtotrec / 2 format "->>,>>>,>>9.99"
                 ";"
                 vtotdeb / 2 format "->>,>>>,>>9.99"
                 ";"
                 vtotsal / 2 format "->>,>>>,>>9.99"
                 ";"
                 vtotval / 2 format "->>,>>>,>>9.99"
                 skip.
            put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
end procedure.

procedure fin-titudesp:

    for each titudesp where titudesp.empcod = wempre.empcod and
                                  titudesp.titnat = yes   and
                                  titudesp.modcod = wmodal.modcod and
                                  titudesp.titdtemi =  vdt 
                                  no-lock:

            disp titudesp.titnum with frame f-proc .
            pause 0.
            set-cod = 0.
            if vsetcod > 0 
            then do:
                        if  titudesp.titbanpag > 0 and
                            titudesp.titbanpag <> vsetcod
                        then next.
                        if titudesp.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = titudesp.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> vsetcod 
                                then next.
                                set-cod = foraut.setcod.
                            end.
                            else next.
                        end.
            end. 
            
            else if titudesp.titbanpag = 0
            then do:
                            find first foraut where
                                   foraut.forcod = titudesp.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                set-cod = foraut.setcod.
                            end.
                            else set-cod = titudesp.titbanpag. /*next.*/
            end.
            
            if set-cod = 0  
            then do:
                if titudesp.titbanpag = 0
                then set-cod = 99.
                else set-cod = titudesp.titbanpag.
            end.
            
            find first wpag where 
                       wpag.wmod = titudesp.modcod and
                       wpag.wset = set-cod /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtemi) and
                       wpag.wmes = month(titudesp.titdtemi) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = titudesp.modcod 
                    wpag.wset = set-cod /*titudesp.titbanpag*/ 
                    wpag.wano = year(titudesp.titdtemi) 
                    wpag.wmes = month(titudesp.titdtemi)  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlcob .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlcob .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtemi) and
                       wpag.wmes = month(titudesp.titdtemi) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*titudesp.titbanpag */
                    wpag.wano = year(titudesp.titdtemi) 
                    wpag.wmes = month(titudesp.titdtemi)  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlcob .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlcob .
            
            find first wpag where 
                       wpag.wmod = titudesp.modcod and
                       wpag.wset = set-cod /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtemi) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = titudesp.modcod 
                    wpag.wset = set-cod /*titudesp.titbanpag*/ 
                    wpag.wano = year(titudesp.titdtemi) 
                    wpag.wmes = 0  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlcob .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlcob .
            if titudesp.evecod <> 9
            then
            run por-forne(input titudesp.clifor,
                          input titudesp.modcod,
                          input set-cod,
                          input month(titudesp.titdtemi),
                          input year(titudesp.titdtemi),
                          input titudesp.titvlcob,
                          input 0).
 
            find first tt-titulo where
                       tt-titulo.clifor = titudesp.clifor and
                       tt-titulo.titnum = titudesp.titnum and
                       tt-titulo.modcod = titudesp.modcod
                       no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                assign
                    tt-titulo.clifor = titudesp.clifor
                    tt-titulo.titnum = titudesp.titnum
                    tt-titulo.modcod = titudesp.modcod
                    .
            end.
            assign
                tt-titulo.titvlcob = tt-titulo.titvlcob + 
                            titudesp.titvlcob
                tt-titulo.titvlpag = tt-titulo.titvlpag + 
                            titudesp.titvlpag
                .

        end.

end procedure.

/*
output to ./tt-titulo-meta.txt.
for each tt-titulo.
    export tt-titulo.clifor
         tt-titulo.titnum
         tt-titulo.modcod
         tt-titulo.titvlcob
         tt-titulo.titvlpag
         .
end.
output close.    
*/
