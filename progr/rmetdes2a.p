{admcab.i}              

def var v-wacumeta as decimal.
def var vtot-val-sal as decimal init 0.

def input parameter vesc as log.
def input parameter vsetcod  as char.
def input parameter vdti as date.
def input parameter vdtf as date.

/*def var vesc as log initial yes.
def var vsetcod as char initial "2".
def var vdti as date initial 12/01/2009.
def var vdtf as date initial 12/01/2009.*/


def var vset as int.
def var vs as int.
def var vs1 as int.

/*find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock.*/

def temp-table wpag
    field wgru  like fin.titulo.modcod
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wacu
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
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
    field wmet  as dec
    index i1 wset wmod wano wmes.


def temp-table swpag
    field wgru  like fin.titulo.modcod
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table swacu
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  as dec format "->>>>,>>>,>>9.99"
    field wrec  as dec format "->>>>,>>>,>>9.99"
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
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wsetor
         field wsetcod like setaut.setcod.

def temp-table swsetor
         field wsetcod like setaut.setcod.

def temp-table wmodal like fin.modal.

def temp-table tt-totgru
    field wmod like fin.titulo.modcod
    field tot  as dec
    index ix1 wmod.     


for each wmodal:
    delete wmodal.
end.
for each fin.modal where fin.modal.modcod <> "DEV"
                     and fin.modal.modcod <> "BON"
                     and fin.modal.modcod <> "CHP"
                     and fin.modal.modcod <> "DUP" no-lock:
    create wmodal.
    assign wmodal.modcod = fin.modal.modcod
           wmodal.modnom = fin.modal.modnom.
end.

def var vdt as date.

/***
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

assign vset = num-entries(vsetcod).

def var vmes as int.
def var vano as int.
def var mes-ano as int.
do vdt = vdti to vdtf :

    do vs = 1 to vset:
    
    vmes = month(vdt).
    vano = year(vdt).
    if vmes + vano = mes-ano
    then next.
    mes-ano = vmes + vano.
    for each metadesp where  metadesp.etbcod = setbcod and
                              metadesp.setcod = int(entry(vs,vsetcod,",")) and
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
            
        end.                     
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
end.            

def var set-cod like setaut.setcod.

do vdt = vdti to vdtf:

  do vs1 = 1  to vset:
     
    disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 13 no-label.
    pause 0.    
    for each wmodal:
        disp wmodal.modcod with frame f-proc .
        pause 0. 
        for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag =  vdt        and
                                  fin.titulo.titsit   =   "PAG" no-lock:
            disp titulo.titnum with frame f-proc .
            pause 0.
            set-cod = 0.

            if vsetcod <> "0" 
            then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> int(entry(vs1,vsetcod,","))
                        then next.
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs1,vsetcod,",")) 
                                then next.
                                set-cod = foraut.setcod.
                            end.
                            else next.
                        end.
            end. 
            else do:
                    if fin.titulo.titbanpag = 0
                    then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                set-cod = foraut.setcod.
                            end.
                            else next.
                    end.

            end.
            if set-cod = 0
            then set-cod = fin.titulo.titbanpag.
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = set-cod 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod  and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = set-cod and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = set-cod  
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .

        end.
        for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt        and
                             banfin.titulo.titsit =   "PAG" no-lock:
            disp titulo.titnum with frame f-proc .
            pause 0. 
            set-cod = 0.
            if vsetcod <> "0" 
            then do:
                            if  banfin.titulo.titbanpag > 0 and
                            banfin.titulo.titbanpag <> int(entry(vs1,vsetcod,","))
                            then next.
                            if banfin.titulo.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    if foraut.setcod <> int(entry(vs1,vsetcod,",")) 
                                    then next.
                                    set-cod = foraut.setcod.
                                end.
                                else next.
                            end.
            end.
            else do:
                            if banfin.titulo.titbanpag = 0
                            then do:
                                find first foraut where
                                   foraut.forcod = banfin.titulo.clifor
                                   no-lock no-error.
                                if avail foraut 
                                then do:
                                    set-cod = foraut.setcod.
                                end.
                                else next.
                            end.

            end.
            if set-cod = 0
            then set-cod = banfin.titulo.titbanpag.

            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = set-cod  and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod  
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .

            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = set-cod  and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = set-cod  
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .
 
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = set-cod  and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = set-cod  
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .

        end.
        
        /* Antonio */
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = no   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtpag =  vdt        and
                                  fin.titluc.titsit   =   "PAG" no-lock:

            if  fin.titluc.titbanpag = 0 then next.
            disp fin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod <> "0"
                    then do:
                        if  fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> int(entry(vs1,vsetcod,","))
                        then next.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs1,vsetcod,",")) 
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

        end.
       /* fin.titluc */
       
       /** Antonio **/ 
       for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = no            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtpag =  vdt        and
                                  banfin.titluc.titsit   = "PAG" no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            disp banfin.titluc.titnum with frame f-proc .
            pause 0.
            if vsetcod <> "0" 
            then do:
                        if  banfin.titluc.titbanpag > 0 and
                         banfin.titluc.titbanpag <> int(entry(vs1,vsetcod,","))
                        then next.
                        /*
                        if banfin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs1,vsetcod,",")) 
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
         
        end.
        /*banfin.titluc*/
        
    end.
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
            wac-cla.wset = wpag.wset.
    end.                             
    wac-cla.wpag = wac-cla.wpag + wpag.wpag.
    wac-cla.wrec = wac-cla.wrec + wpag.wrec.

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
                            modgru.mogsup <> 0 no-lock.
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
    end.
    else wgru.wmet = wgru.wmet + wpag.wmet. 
    wgru.wpag = wgru.wpag + wpag.wpag.      
    wgru.wrec = wgru.wrec + wpag.wrec.     
    /**
    else 
       if wpag.wset = wgru.wset and
          wpag.wmod = wgru.wmod
       then assign  wgru.wmet = wgru.wmet + wpag.wmet. 
                    wgru.wpag = wgru.wpag + wpag.wpag.      
                    wgru.wrec = wgru.wrec + wpag.wrec.  
    **/
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
    if avail metadesp and metadesp.metval > 0   
    then wpag.wmet = metadesp.metval. 
    else do:
        for each wgru where
                 wgru.wmod <> "" and
                 wgru.wset = wpag.wset and
                 wgru.wano = wpag.wano and
                 wgru.wmes = wpag.wmes :
                 wpag.wmet = wpag.wmet + wgru.wmet. 
            wpag.wmet = 0. 
        end.  
    end.
end.  
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
if opsys = "UNIX"
then varquivo = "/admcom/relat/rmetdes." + string(time).
else varquivo = "l:~\relat~\rmetdes." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "80"
            &Page-Line = "64"
            &Nom-Rel   = ""PAG4""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """DESPESAS PERIODO DE "" +
                                  string(vdti,""99/99/9999"") + "" ATE "" +
                                  string(vdtf,""99/99/9999"") "
            &Width     = "90"
            &Form      = "frame f-cabcab"}
def var val-sal as dec.
def var val-salac as dec.
def var val-pag as dec.
def var val-met as dec.
def var val-rec as dec.
def var vswmet as dec.
def var vswpag as dec.
def var vswrec as dec.
def var vtotgeral as dec.

run saldototal.

for each wsetor:
    /********************************************************
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
        for each wpag where wpag.wgru = wgru.wmod and
                            wpag.wset = wgru.wset and
                            wpag.wano = wgru.wano and
                            wpag.wmes = wgru.wmes
                            no-lock:
            find first  fin.modal where 
                        modal.modcod = wpag.wmod no-lock no-error.
            
            val-sal = wpag.wmet - wpag.wpag + wpag.wrec .        
            disp modal.modcod   column-label "Sigla" 
                 modal.modnom     format "x(20)"  column-label "Descricao"
                 wpag.wmet  column-label "Liimite" format "->>,>>>,>>9.99"
                 wpag.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                 wpag.wrec  column-label "Creditos"  format "->>,>>>,>>9.99"
                 val-sal  format "->>,>>>,>>9.99" column-label "Saldo" 
                 with frame f-disp down width 120.
            down with frame f-disp.
        end.                    
        put fill("-",120) format "x(100)".
        
        find first modgru where modgru.modcod = wgru.wmod and
                modgru.mognom <> "" no-lock.
        val-sal = wgru.wmet - wgru.wpag + wgru.wrec.     
        disp modgru.modcod   @ modal.modcod 
             modgru.mognom   @ modal.modnom
             wgru.wmet       @ wpag.wmet
             wgru.wpag       @ wpag.wpag
             wgru.wrec       @ wpag.wrec
             val-sal  
        with frame f-disp.
        down with frame f-disp.
        put fill("=",120) format "x(100)".
        if last-of(wgru.wmes)
        then do:
            disp  
                "--------------" @ wpag.wpag
                "--------------" @ wpag.wmet
                "--------------" @ wpag.wrec
                "--------------" @ val-sal
            with frame f-disp.
            down with frame f-disp.     
                   
            find first wpag where wpag.wmod = "" and
                                  wpag.wset = wgru.wset and  
                                  wpag.wano = wgru.wano and
                                  wpag.wmes = wgru.wmes 
                                  . 
            val-sal = wpag.wmet - wpag.wpag + wpag.wrec.                      
            disp   "Totais" @ modal.modnom
                wpag.wpag @ wpag.wpag
                wpag.wmet @ wpag.wmet
                wpag.wrec @ wpag.wrec
                val-sal 
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

            for each bwgru where bwgru.wset = wgru.wset and
                                 bwgru.wmod <> "" and
                                 bwgru.wano = wgru.wano and
                                 bwgru.wmes = wgru.wmes
                                 no-lock :
                find first modgru where modgru.modcod = bwgru.wmod and
                    modgru.mognom <> "" no-lock.
                    val-sal = bwgru.wmet - bwgru.wpag + bwgru.wrec.
                disp 
                    modgru.modcod   column-label "Sigla" 
                    modgru.mognom     format "x(20)"  column-label "Descricao"
                    bwgru.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                    bwgru.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                    bwgru.wrec  column-label "Creditos" format "->>,>>>,>>9.99"
                    val-sal   format "->>,>>>,>>9.99" column-label "Saldo" 
                    with frame f-disp3 down width 120.
                down with frame f-disp3. 
                val-pag = val-pag + bwgru.wpag.
                val-rec = val-rec + bwgru.wrec.
                val-met = val-met + bwgru.wmet.
            end.
            val-sal = 0.
            disp   
                "--------------" @ bwgru.wpag
                "--------------" @ bwgru.wmet
                "--------------" @ bwgru.wrec 
                "--------------" @ val-sal 
                with frame f-disp3.
            down with frame f-disp3.  
            find first wpag where wpag.wmod = "" and
                                  wpag.wset = wgru.wset and  
                                  wpag.wano = wgru.wano and
                                  wpag.wmes = wgru.wmes 
                                  . 
            val-met = wpag.wmet.
            val-sal = val-met - val-pag + val-rec.   
            disp    "Totais" @ modgru.mognom
                val-pag @ bwgru.wpag
                val-met @ bwgru.wmet
                val-rec @ bwgru.wrec
                val-sal
                with frame f-disp3.
            down with frame f-disp3.        
            put skip(1)
            fill("=",120) format "x(100)"
            skip(1).
            /*********************/
        end. 
    end.
    **************************************************/
    /*if vdtf - vdti > 31
    then*/ do:
        /***
        put skip(1).
        find setaut where setaut.setcod = wsetor.wsetcod no-lock.
        disp setaut.setcod label "Setor"
             setaut.setnom no-label   format "x(20)"
             "   ACUMULADO NO PERIODO - MODALIDADES"
            with frame f-set1 1 down no-box side-label.
        val-sal = 0.
        val-pag = 0.
        val-met = 0.
        val-rec = 0.
        for each wac-cla where wac-cla.wmod <> ""  and
                               wac-cla.wset = wsetor.wset 
                    break by wac-cla.wset
                          by wac-cla.wgru
                          by wac-cla.wmod:
            
            find first  fin.modal where 
                        modal.modcod = wac-cla.wmod no-lock no-error.
            
            val-sal = wac-cla.wmet - wac-cla.wpag + wac-cla.wrec.        
            disp modal.modcod  column-label "Sigla" 
                 modal.modnom  format "x(20)"  column-label "Descricao"
                 wac-cla.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                 wac-cla.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                 val-rec  format "->>,>>>,>>9.99" column-label "Creditos"
                 val-sal  format "->>,>>>,>>9.99" column-label "Saldo" 
                 val-salac format "->>,>>>,>>9.99" column-label "Saldo Acumulado Ano"
                with frame f-accla down width 100.
            down with frame f-accla.
            val-pag = val-pag + wac-cla.wpag.
            val-rec = val-rec + wac-cla.wrec.
            val-met = val-met + wac-cla.wmet.
            if last-of(wac-cla.wgru)
            then do:
                put fill("-",120) format "x(110)".
                val-sal = 0.
                find first wacu where wacu.wmod = wac-cla.wgru and
                                  wacu.wset = wac-cla.wset
                                  . 
                find first modgru where modgru.modcod = wacu.wmod and
                                modgru.mognom <> "" no-lock.
                val-sal = wacu.wmet - wacu.wpag + wacu.wrec.   
                disp modgru.modcod @ modal.modcod
                    modgru.mognom  @ modal.modnom
                    wacu.wpag @ wac-cla.wpag
                    wacu.wmet @ wac-cla.wmet
                    wacu.wrec @ wac-cla.wrec
                    val-sal
                    val-salac 
                    with frame f-accla.
                down with frame f-accla.        

                put skip(1)
                fill("=",100) format "x(80)"
                skip(1).
            end.
        end.
        val-sal = 0.                     
        disp   
                "--------------" @ wac-cla.wpag
                "--------------" @ wac-cla.wmet
                "--------------" @ wac-cla.wrec 
                "--------------" @ val-sal 
                "--------------" @ val-salac
                with frame f-accla.
         down with frame f-accla.       
        val-sal = val-met - val-pag + val-rec.
        disp    "Totais" @ modal.modnom
                val-pag @ wac-cla.wpag
                val-met @ wac-cla.wmet
                val-rec @ wac-cla.wrec
                val-sal
                val-salac 
                with frame f-accla.
 
        put skip(1).
        ***/


        find setaut where setaut.setcod = wsetor.wsetcod no-lock.
        disp setaut.setcod label "Setor"
             setaut.setnom no-label format "x(20)"
             "   ACUMULADO NO PERIODO - GRUPOS"
            with frame f-set0 1 down no-box side-label.

         v-wacumeta = 0.
         val-rec = 0.

         for each swgru where swgru.wset = wsetor.wsetcod and
                    swgru.wmod <> "" and
                    swgru.wmes <> 0
                    break 
                          by swgru.wano
                          by swgru.wmes  :
                          
                          
            for each swpag where swpag.wgru = swgru.wmod and
                                 swpag.wset = swgru.wset no-lock:
                assign vswmet = vswmet + swpag.wmet
                       vswpag = vswpag + swpag.wpag
                       vswrec = vswrec + swpag.wrec.            
                      
            end.
                        
            val-salac = vswmet - vswpag + vswrec.

            if not can-find (first tt-totgru where 
                               tt-totgru.wmod = swgru.wmod) then do:
                create tt-totgru.
                assign tt-totgru.wmod = swgru.wmod
                       tt-totgru.tot  = tt-totgru.tot + val-salac.
            end.
            else do:
            
                find first tt-totgru where
                           tt-totgru.wmod = swgru.wmod no-lock no-error.
                if avail tt-totgru then           
                    assign tt-totgru.tot = tt-totgru.tot + val-salac.
            end.            
        end.         


         for each wacu where wacu.wset = wsetor.wsetcod:
            find first modgru where modgru.modcod = wacu.wmod and
                modgru.mognom <> "" no-lock.
            val-sal = wacu.wmet - wacu.wpag + wacu.wrec.
            
            
            find tt-totgru where tt-totgru.wmod = wacu.wmod no-lock no-error.
            if avail tt-totgru then do:
                assign val-salac = tt-totgru.tot
                       vtotgeral = val-salac + vtotgeral.
            end.    

            
            disp 
                modgru.modcod   column-label "Sigla" 
                modgru.mognom     format "x(20)"  column-label "Descricao"
                wacu.wmet  column-label "Limite" format "->>,>>>,>>9.99"
                wacu.wpag  column-label "Realizado" format "->>,>>>,>>9.99"
                wacu.wrec  column-label "Creditos" format "->>,>>>,>>9.99"
                val-sal    format "->>,>>>,>>9.99" column-label "Saldo"
                val-salac  format "->>>,>>>,>>9.99" column-label "Saldo Acumulado Ano"
                with frame f-disp1 down width 120.
            down with frame f-disp1. 
            v-wacumeta = v-wacumeta + wacu.wmet.
            val-rec = val-rec + wacu.wrec.
            vtot-val-sal = vtot-val-sal + val-sal.
        end.
        val-sal = 0.
        val-rec = 0.
        val-pag = 0.
        val-met = 0.
        disp   
                "--------------" @ wacu.wpag
                "--------------" @ wacu.wmet
                "--------------" @ wacu.wrec
                "--------------" @ val-sal
                "--------------" @ val-salac
                with frame f-disp1.
         down with frame f-disp1.       
         for each wpag where wpag.wmod = "" and
                              wpag.wset = wsetor.wsetcod :

            val-rec = val-rec + wpag.wrec.                       
            val-pag = val-pag + wpag.wpag.
            val-met = val-met + wpag.wmet.
        end.
        val-sal = v-wacumeta - val-pag + val-rec.
        val-salac = vtotgeral.
        disp    "Totais" @ modgru.mognom
                val-pag @ wacu.wpag
                /*val-met @ wacu.wmet */
                v-wacumeta @ wacu.wmet
                val-rec @ wacu.wrec
                val-sal
                val-salac format "->>>,>>>,>>9.99"
                with frame f-disp1.
        down with frame f-disp1.        
        put skip(1)
            fill("=",120) format "x(90)"
            skip(1).
    end.
end.

output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
   {mrod.i} .
end.


procedure saldototal:

def var vdta as date.
def var vdtini as date.
def var vdtfim as date.
def var vmesini as int.
def var vmesfim as int.
def var vano as int.
def var vs2 as int.
def var vs3 as int.
def var vseto as int.
def buffer bfmetadesp for metadesp.

/*def var mes-ano as int.*/

assign vseto  = num-entries(vsetcod)
       vdtini = date("01/01/" + string(year(today)))
       vdtfim = vdtf. 

do vdta = vdtini to vdtfim:

    vmesini = 1.
    vmesfim = month(vdtf).
    vano = year(vdt).
    
    /*if vmes + vano = mes-ano
    then next.
    mes-ano = vmes + vano.*/
    
    do vs2 = 1 to vseto:
      
     for each bfmetadesp where  bfmetadesp.etbcod = setbcod and                ~    ~ ~          bfmetadesp.setcod = int(entry(vs2,vsetcod,",")) and
                             bfmetadesp.metano = vano and
                             bfmetadesp.metmes >= vmesini and
                             bfmetadesp.metmes <= vmesfim and
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
end. 
           
           
def var set-cod1 like setaut.setcod.

do vdta = vdtini to vdtfim:

   /* disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 13 no-label.
    pause 0.  */  
    for each wmodal:
        /*disp wmodal.modcod with frame f-proc .
        pause 0.*/ 

        do vs3 = 1 to vset:
            for each fin.titulo where fin.titulo.empcod = wempre.empcod and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag =  vdt        and
                                  fin.titulo.titsit   =   "PAG" no-lock:
               /* disp titulo.titnum with frame f-proc .
                pause 0.*/
                set-cod1 = 0.
                
                if vsetcod <> "0" 
                    then do:
                        if  fin.titulo.titbanpag > 0 and
                            fin.titulo.titbanpag <> int(entry(vs3,vsetcod,","))
                        then next.
                        if fin.titulo.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titulo.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs3,vsetcod,",")) 
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
                       swpag.wset = int(entry(vs3,vsetcod,",")) /*fin.titulo.ti~t~ ~banpag*/ and
                       swpag.wano = year(fin.titulo.titdtpag) and
                       swpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = fin.titulo.modcod 
                    swpag.wset = fin.titulo.titbanpag 
                    swpag.wano = year(fin.titulo.titdtpag) 
                    swpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlpag .
            
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ and
                       swpag.wano = year(fin.titulo.titdtpag) and
                       swpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = set-cod1 /*fin.titulo.titbanpag */
                    swpag.wano = year(fin.titulo.titdtpag) 
                    swpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlpag .
            
            find first swpag where 
                       swpag.wmod = fin.titulo.modcod and
                       swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ and
                       swpag.wano = year(fin.titulo.titdtpag) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = fin.titulo.modcod 
                    swpag.wset = set-cod1 /*fin.titulo.titbanpag*/ 
                    swpag.wano = year(fin.titulo.titdtpag) 
                    swpag.wmes = 0  .
            end.
            swpag.wpag  = swpag.wpag  + fin.titulo.titvlpag .

        end.
        for each banfin.titulo where 
                             banfin.titulo.empcod = wempre.empcod and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt        and
                             banfin.titulo.titsit =   "PAG" no-lock:
            /*disp banfin.titulo.titnum with frame f-proc .
            pause 0.*/ 
            set-cod1 = 0.
            if vsetcod <> "0" then do:
                            if banfin.titulo.titbanpag > 0 and
                            banfin.titulo.titbanpag <> 
                            int(entry(vs3,vsetcod,",")) then do:
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
                                       int(entry(vs3,vsetcod,"~,")) 
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
                       swpag.wano = year(banfin.titulo.titdtpag) and
                       swpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = banfin.titulo.modcod 
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(banfin.titulo.titdtpag) 
                    swpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlpag .

            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ and
                       swpag.wano = year(banfin.titulo.titdtpag) and
                       swpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(banfin.titulo.titdtpag) 
                    swpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlpag .
 
            find first swpag where 
                       swpag.wmod = banfin.titulo.modcod and
                       swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ and
                       swpag.wano = year(banfin.titulo.titdtpag) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = banfin.titulo.modcod 
                    swpag.wset = set-cod1 /*banfin.titulo.titbanpag*/ 
                    swpag.wano = year(banfin.titulo.titdtpag) 
                    swpag.wmes = 0  .
            end.
            swpag.wpag  = swpag.wpag  + banfin.titulo.titvlpag .

        end.
        
        /* Antonio */
        for each fin.titluc where fin.titluc.empcod = wempre.empcod and
                                  fin.titluc.titnat = no   and
                                  fin.titluc.modcod = wmodal.modcod and
                                  fin.titluc.titdtpag =  vdt        and
                                  fin.titluc.titsit   =   "PAG" no-lock:

            if  fin.titluc.titbanpag = 0 then next.
            /*disp fin.titluc.titnum with frame f-proc .
            pause 0. */
            if vsetcod <> "0" 
                    then do:
                        if  fin.titluc.titbanpag > 0 and
                            fin.titluc.titbanpag <> int(entry(vs3,vsetcod,","))
                        then next.
                        if fin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = fin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs3,vsetcod,",")) 
                                then next.
                            end.
                            else next.
                        end.
                    end. 
            find first swpag where 
                       swpag.wmod = fin.titluc.modcod and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(fin.titluc.titdtpag) and
                       swpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = fin.titluc.modcod 
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(fin.titluc.titdtpag) 
                    swpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            swpag.wrec  = swpag.wrec + fin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(fin.titluc.titdtpag) and
                       swpag.wmes = month(fin.titluc.titdtpag) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(fin.titluc.titdtpag) 
                    swpag.wmes = month(fin.titluc.titdtpag)  .
            end.
            swpag.wrec  = swpag.wrec  + fin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = fin.titluc.modcod and
                       swpag.wset = fin.titluc.titbanpag and
                       swpag.wano = year(fin.titluc.titdtpag) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = fin.titluc.modcod 
                    swpag.wset = fin.titluc.titbanpag 
                    swpag.wano = year(fin.titluc.titdtpag) 
                    swpag.wmes = 0  .
            end.
            swpag.wrec  = swpag.wrec  + fin.titluc.titvlcob.

        end.
       /* fin.titluc */
       
       /** Antonio **/ 
       for each banfin.titluc where banfin.titluc.empcod = wempre.empcod and
                                  banfin.titluc.titnat = no            and
                                  banfin.titluc.modcod = wmodal.modcod and
                                  banfin.titluc.titdtpag =  vdt        and
                                  banfin.titluc.titsit   = "PAG" no-lock:
            if banfin.titluc.titbanpag = 0 then next.
            /*disp banfin.titluc.titnum with frame f-proc .
            pause 0.*/
            if vsetcod <> "0" 
            then do:
                        if  banfin.titluc.titbanpag > 0 and
                         banfin.titluc.titbanpag <> int(entry(vs3,vsetcod,","))
                        then next.
                        /*
                        if banfin.titluc.titbanpag = 0
                        then do:
                            find first foraut where
                                   foraut.forcod = banfin.titluc.clifor
                                   no-lock no-error.
                            if avail foraut 
                            then do:
                                if foraut.setcod <> int(entry(vs3,vsetcod,",")) 
                                then next.
                            end.
                            else next.
                        end.
                        */
            end. 
            find first swpag where 
                       swpag.wmod = banfin.titluc.modcod and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(banfin.titluc.titdtpag) and
                       swpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail swpag
            then do:
                /*next.*/
                create swpag.
                assign
                    swpag.wmod = banfin.titluc.modcod 
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(banfin.titluc.titdtpag) 
                    swpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = "" and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(banfin.titluc.titdtpag) and
                       swpag.wmes = month(banfin.titluc.titdtpag) no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = ""
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(banfin.titluc.titdtpag) 
                    swpag.wmes = month(banfin.titluc.titdtpag)  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
            
            find first swpag where 
                       swpag.wmod = banfin.titluc.modcod and
                       swpag.wset = banfin.titluc.titbanpag and
                       swpag.wano = year(banfin.titluc.titdtpag) and
                       swpag.wmes = 0 no-error.
            if not avail swpag
            then do:
                create swpag.
                assign
                    swpag.wmod = banfin.titluc.modcod 
                    swpag.wset = banfin.titluc.titbanpag 
                    swpag.wano = year(banfin.titluc.titdtpag) 
                    swpag.wmes = 0  .
            end.
            swpag.wrec  = swpag.wrec  + banfin.titluc.titvlcob.
       end.  
        end.
        /*banfin.titluc*/
        
    end.
end.
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
                                modgru.mogsup <> 0 no-lock.
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
         /*message bmetadesp.metval. pause.*/
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



