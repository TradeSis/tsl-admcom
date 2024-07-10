{admcab.i}
{admcom_funcoes.i}

def input parameter vesc as log.
def var dsresp as log init yes.

/*
assign sfuncod = 101.

def var vesc as log initial no.
*/
def var v-wacumeta as dec.

def var sfor as log format "Sim/Nao".

/* Total Geral */
def var vtotmet as dec                              init 0.
def var vtotpag as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotrec as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotdeb as dec format "->>>>,>>>,>>9.99"    init 0.
def var vtotsal as dec                              init 0.
def var vtotval as dec                              init 0.
 
find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock.
                      
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

update vdti at 1 label "Periodo de"  format "99/99/9999"
       vdtf label "Ate"  format "99/99/9999"
       with frame f-sel 1 down side-label width 80.
sfor = no.
/*message "Mostrar fornecedores?" update sfor.
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
        do:          
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

def var vct as int.
do vdt = vdti to vdtf:
    disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 13 no-label.
    pause 0.    
    for each wmodal:
        vct = vct + 1.
        if vct mod 250 = 0
        then disp wmodal.modcod with frame f-proc .
        pause 0. 
        for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag =  vdt        and
                                  fin.titulo.titsit   =   "PAG" no-lock:

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

            vct = vct + 1.
            if vct mod 750 = 0
            then disp titulo.titnum with frame f-proc .
            pause 0.

            /*
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
            if set-cod = 0
            then set-cod = fin.titulo.titbanpag.
            */

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
                            else set-cod = fin.titulo.titbanpag. /*next.*/
            end.

            if set-cod = 0  
            then do:
                if fin.titulo.titbanpag = 0
                then set-cod = 99.
                else set-cod = fin.titulo.titbanpag.
            end.

            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod
                       /*vsetcod*/ /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*fin.titulo.titbanpag */
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod /*fin.titulo.titbanpag*/ and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = set-cod /*fin.titulo.titbanpag*/ 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            if fin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + fin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            if fin.titulo.evecod <> 9
            then run por-forne(input fin.titulo.clifor,
                          input fin.titulo.modcod,
                          input set-cod,
                          input month(fin.titulo.titdtpag),
                          input year(fin.titulo.titdtpag),
                          input fin.titulo.titvlpag,
                          input 0).
 
        end.
        
        run fin-titudesp.
        
        for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt        and
                             banfin.titulo.titsit =   "PAG" no-lock:
            
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
            
            vct = vct + 1.
            if vct mod 750 = 0
            then disp titulo.titnum with frame f-proc .
            pause 0. 
            /*
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
            if set-cod = 0
            then set-cod = banfin.titulo.titbanpag.
            */
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
                                /*next.*/
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
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .

            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*banfin.titulo.titbanpag*/ and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .
 
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = set-cod /*banfin.titulo.titbanpag*/ and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod /*banfin.titulo.titbanpag*/ 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            if banfin.titulo.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + banfin.titulo.titvlpag .
            else wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .
            if banfin.titulo.evecod <> 9
            then
            run por-forne(input banfin.titulo.clifor,
                          input banfin.titulo.modcod,
                          input set-cod,
                          input month(banfin.titulo.titdtpag),
                          input year(banfin.titulo.titdtpag),
                          input banfin.titulo.titvlpag,
                          input 0).
        end.
        
        /* Antonio */
        /**** Inici Credito ***/
        
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = no   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtpag =  vdt        and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.evecod = 8 
                                  use-index titdtpag
                                  no-lock:

            if fin.titluc.titbanpag = 0 then next.
            vct = vct + 1.
            if vct mod 750 = 0
            then disp fin.titluc.titnum with frame f-proc .
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
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            wpag.wrec  = wpag.wrec + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            wpag.wrec  = wpag.wrec  + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wrec  = wpag.wrec  + fin.titluc.titvlcob.

            run por-forne(input fin.titluc.clifor,
                          input fin.titluc.modcod,
                          input fin.titluc.titbanpag,
                          input month(fin.titluc.titdtpag),
                          input year(fin.titluc.titdtpag),
                          input 0,
                          input fin.titluc.titvlcob).
 
        end.
        /***** Fim credito ****/

        /***** Inicio Debito ******/
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = yes   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtpag =  vdt        and
                                  fin.titluc.titsit   =   "PAG" and
                                  fin.titluc.evecod = 9 
                                  use-index titdtpag
                                  no-lock:

            if fin.titluc.titbanpag = 0 then next.
            vct = vct + 1.
            if vct mod 750 = 0
            then disp fin.titluc.titnum with frame f-proc .
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
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            wpag.wdeb  = wpag.wdeb + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            wpag.wdeb  = wpag.wdeb  + fin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = fin.titluc.modcod and
                       wpag.wset = fin.titluc.titbanpag and
                       wpag.wano = year(fin.titluc.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titluc.modcod 
                    wpag.wset = fin.titluc.titbanpag 
                    wpag.wano = year(fin.titluc.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wdeb  = wpag.wdeb  + fin.titluc.titvlcob.

       end.
       /****** Fim Debito ******/
       /* fin.titluc */
       
       /** Antonio **/ 
       /**** Inicio Credito ****/
       
       for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = no            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtpag = vdt        and
                                  banfin.titluc.titsit   = "PAG" and
                                  banfin.titluc.evecod = 8
                                  use-index titdtpag
                               no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            vct = vct + 1.
            if vct mod 750 = 0
            then disp banfin.titluc.titnum with frame f-proc .
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
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wrec  = wpag.wrec  + banfin.titluc.titvlcob.
            run por-forne(input banfin.titluc.clifor,
                          input banfin.titluc.modcod,
                          input banfin.titluc.titbanpag,
                          input month(banfin.titluc.titdtpag),
                         input year(banfin.titluc.titdtpag),
                          input 0,
                          input banfin.titluc.titvlcob).
         end.
        /*** Fim Credito ****/

        /**** Inicio Debito ****/
        for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = yes            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtpag =  vdt        and
                                  banfin.titluc.titsit   = "PAG" and
                                  banfin.titluc.evecod = 9 
                                  use-index titdtpag
                                  no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            vct = vct + 1.
            if vct mod 750 = 0
            then disp banfin.titluc.titnum with frame f-proc .
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
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
            
            find first wpag where 
                       wpag.wmod = banfin.titluc.modcod and
                       wpag.wset = banfin.titluc.titbanpag and
                       wpag.wano = year(banfin.titluc.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titluc.modcod 
                    wpag.wset = banfin.titluc.titbanpag 
                    wpag.wano = year(banfin.titluc.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wdeb  = wpag.wdeb  + banfin.titluc.titvlcob.
         
        end.
        
        /*** Fim Debito ****/
        /*banfin.titluc*/
        
        /*** A pagar  ***/
        if vsetcod > 0
        then
        for each estab no-lock.
        for each fin.titulo where fin.titulo.empcod = wempre.empcod
                              and fin.titulo.titnat = yes
                              and fin.titulo.modcod = wmodal.modcod
                              and fin.titulo.etbcod = estab.etbcod
                              and fin.titulo.titdtven = vdt
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
        /***/
    end.
end.



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
        message bmetadesp.metval. pause.
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
    then varq = "/admcom/relat/rmetdes" 
         + string(time)
         + ".csv".
    else varq = "l:\relat\rmetdes"
         + string(time)
         + ".csv".

    hide message no-pause.
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
                                  fin.titulo.titdtven >=  vdti      and
                                  fin.titulo.titdtven <=  vdtf      and
                                  (fin.titulo.titsit   = "LIB"
                                   or fin.titulo.titsit = "CON") no-lock:
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
                       swpag.wset = vsetcod /*fin.titulo.ti~t~ ~banpag*/ and
                       swpag.wano = year(fin.titulo.titdtven) and
                       swpag.wmes = month(fin.titulo.titdtven) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = fin.titulo.modcod 
                    swpag.wset = fin.titulo.titbanpag 
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
                             banfin.titulo.titdtven >= vdti        and
                             banfin.titulo.titdtven <= vdtf        and
                             (banfin.titulo.titsit = "LIB"
                              or banfin.titulo.titsit = "CON") no-lock:
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
                                  fin.titluc.titdtven >=  vdti        and
                                  fin.titluc.titdtven <=  vdtf        and
                                  (fin.titluc.titsit = "LIB"
                                    or fin.titluc.titsit = "CON")
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
                                  banfin.titluc.titdtpag >=  vdti        and
                                  banfin.titluc.titdtpag <=  vdtf        and
                                  (banfin.titluc.titsit  = "LIB"
                                    or banfin.titluc.titsit = "CON")no-lock:
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
         /* message bmetadesp.metval. pause.*/
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

    def buffer bmodal for fin.modal.
    def var val-sal as dec.

    def var vtot as dec initial 0.
            def var v-tot as dec initial 0.
            def var vval as dec initial 0.
            def var  val-salac as dec initial 0.
            def var  vtotgeral as dec initial 0.


    run saldototal.

    put "Ano;Mes;Setor; ;Grupo; ;Mod; ;Limite;Realizado;Creditos;Debitos;Saldo"
    skip.

    for each wsetor:

        for each wgru where wgru.wset = wsetor.wsetcod and
                    wgru.wmod <> "" and
                    wgru.wmes <> 0
                    break 
                          by wgru.wano
                          by wgru.wmes  :
        
            find setaut where setaut.setcod = wgru.wset no-lock.
        
            v-wacumeta = 0.
        
            find first bmodal where
                   bmodal.modcod = wgru.wmod no-lock.
                   
            for each wpag where wpag.wgru = wgru.wmod and
                            wpag.wset = wgru.wset and
                            wpag.wano = wgru.wano and
                            wpag.wmes = wgru.wmes
                            no-lock:
                find first  fin.modal where 
                        modal.modcod = wpag.wmod no-lock no-error.

                assign vtot = 0
                   vval = 0
                   v-tot = 0
                   val-salac = 0
                   vtotgeral = 0
                   .
                                
                for each swpag where 
                     swpag.wmod = modal.modcod and
                     swpag.wset = wgru.wset and
                     swpag.wano = wgru.wano and
                     swpag.wmes = wgru.wmes
                            no-lock:

                    assign vtot = vtot + swpag.wpag.
                             
                end.        
                    
                val-sal = 
                    wpag.wmet - wpag.wpag + wpag.wrec - wpag.wdeb.        
            
            
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

                put unformatted
                 wgru.wano
                 ";"
                 wgru.wmes
                 ";"
                 setaut.setcod 
                 ";"
                 setaut.setnom
                 ";"
                 wgru.wmod
                 ";"
                 bmodal.modnom
                 ";"
                 modal.modcod  format "x(5)"
                 ";"
                 modal.modnom     format "x(20)"
                 ";"
                 replace(string(wpag.wmet,"->>>>>>>9.99"),".",",")
                 ";"
                 replace(string(wpag.wpag,"->>>>>>>9.99"),".",",")
                 ";"
                 replace(string(wpag.wrec,"->>>>>>>9.99"),".",",")
                 ";"
                 replace(string(wpag.wdeb,"->>>>>>>9.99"),".",",")   
                 ";"
                 replace(string(val-sal,"->>>>>>>9.99"),".",",")
                 /*";"
                 replace(string(vval,"->>>>>>>9.99"),".",",")
                 */
                 skip.
            
                v-wacumeta = v-wacumeta + wpag.wmet.
                v-tot = v-tot + vval.
            
                /****
                if sfor then
                for each wfor where
                     wfor.wmod = modal.modcod and
                     wfor.wset = wpag.wset   and
                     wfor.wmes = wpag.wmes and
                     wfor.wano = wpag.wano
                     no-lock:
                    find first forne where forne.forcod = wfor.wfor
                            no-lock no-error.
                    put unformatted
                    string(forne.forcod) + "-" +
                        (if avail forne then forne.fornom else "")
                    ";"    
                    wfor.wpag
                    ";"
                     wfor.wrec
                     skip.
                end.
                *******/
            end.     
        end.
    end.
end procedure.

procedure fin-titudesp:

    for each titudesp where titudesp.empcod = wempre.empcod and
                                  titudesp.titnat = yes   and
                                  titudesp.modcod = wmodal.modcod and
                                  titudesp.titdtpag =  vdt        and
                                  titudesp.titsit   =   "PAG" no-lock:


            vct = vct + 1.
            if vct mod 750 = 0
            then disp titudesp.titnum with frame f-proc .
            pause 0.

            /*
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
            if set-cod = 0
            then set-cod = titudesp.titbanpag.
            */

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
                then setcod = 99.
                else set-cod = titudesp.titbanpag.
            end.

            find first wpag where 
                       wpag.wmod = titudesp.modcod and
                       wpag.wset = set-cod
                       /*vsetcod*/ /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtpag) and
                       wpag.wmes = month(titudesp.titdtpag) no-error.
            if not avail wpag
            then do:
                /*next.*/
                create wpag.
                assign
                    wpag.wmod = titudesp.modcod 
                    wpag.wset = titudesp.titbanpag 
                    wpag.wano = year(titudesp.titdtpag) 
                    wpag.wmes = month(titudesp.titdtpag)  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlpag .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlpag .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtpag) and
                       wpag.wmes = month(titudesp.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod /*titudesp.titbanpag */
                    wpag.wano = year(titudesp.titdtpag) 
                    wpag.wmes = month(titudesp.titdtpag)  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlpag .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlpag .
            
            find first wpag where 
                       wpag.wmod = titudesp.modcod and
                       wpag.wset = set-cod /*titudesp.titbanpag*/ and
                       wpag.wano = year(titudesp.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = titudesp.modcod 
                    wpag.wset = set-cod /*titudesp.titbanpag*/ 
                    wpag.wano = year(titudesp.titdtpag) 
                    wpag.wmes = 0  .
            end.
            if titudesp.evecod = 9
            then wpag.wdeb  = wpag.wdeb  + titudesp.titvlpag .
            else wpag.wpag  = wpag.wpag  + titudesp.titvlpag .
            if titudesp.evecod <> 9
            then run por-forne(input titudesp.clifor,
                          input titudesp.modcod,
                          input set-cod,
                          input month(titudesp.titdtpag),
                          input year(titudesp.titdtpag),
                          input titudesp.titvlpag,
                          input 0).
 
        end.

end procedure.

