def input parameter vesc as log.

/*
find first func where func.funcod = sfuncod and
                      func.etbcod = setbcod no-lock.
*/
def temp-table wpag
    field wgru  like fin.titulo.modcod
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  like fin.titulo.titvlcob
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wgru
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  like fin.titulo.titvlcob
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wacu
    field wmod  like fin.titulo.modcod
    field wset  like setaut.setcod
    field wmes  as int
    field wano  as int
    field wpag  like fin.titulo.titvlcob
    field wmet  as dec
    index i1 wset wmod wano wmes.

def temp-table wmodal like fin.modal.

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
def var vdti as date.
def var vdtf as date.
assign
    vdti = date(month(today),01,year(today))
    vdtf = today.
def var vsetcod like setaut.setcod.
vsetcod = 0.
/***
update vsetcod label "Setor" with frame f-sel.

if vsetcod <> 0
then do:
    find setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label with frame f-sel.
end.
else disp "Relatorio geral" @ setaut.setnom with frame f-sel.

if func.funfunc begins "DIRETOR"
then.
else if vsetcod <> 0 and (func.funfunc begins "GERENTE" or
                          func.funfunc begins "CUSTOM") and
            func.aplicod = string(vsetcod)
    then.
    else do:
        bell.
        message color red/with
        "Acesso nao autorizado." view-as alert-box.
        return.
    end.

update vdti at 1 label "Periodo de"  format "99/99/9999"
       vdtf label "Ate"  format "99/99/9999"
       with frame f-sel 1 down side-label width 80.
**/
vdtf = today - 1.
vdti = date(month(vdtf),01,year(vdtf)).       
do vdt = vdti to vdtf:
    /*
    disp "Processando... Aguarde! " vdt
        with frame f-proc 1 down centered no-box color message
        row 10 no-label.
    pause 0.  
      */
    for each wmodal:
        /*
        disp wmodal.modcod with frame f-proc .
        pause 0.*/ 
        for each fin.titulo where fin.titulo.empcod = 19 and
                                  fin.titulo.titnat = yes   and
                                  fin.titulo.modcod = wmodal.modcod and
                                  fin.titulo.titdtpag =  vdt        and
                                  fin.titulo.titsit   =   "PAG" no-lock:
            /*disp titulo.titnum with frame f-proc .
            pause 0.*/
            if vsetcod > 0 and
                fin.titulo.titbanpag <> vsetcod
            then next.    
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = month(fin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = month(fin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .
            
            find first wpag where 
                       wpag.wmod = fin.titulo.modcod and
                       wpag.wset = fin.titulo.titbanpag and
                       wpag.wano = year(fin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = fin.titulo.modcod 
                    wpag.wset = fin.titulo.titbanpag 
                    wpag.wano = year(fin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wpag  = wpag.wpag  + fin.titulo.titvlpag .

        end.
        for each banfin.titulo where 
                             banfin.titulo.empcod = 19 and
                             banfin.titulo.titnat = yes   and
                             banfin.titulo.modcod = wmodal.modcod and
                             banfin.titulo.titdtpag =  vdt        and
                             banfin.titulo.titsit =   "PAG" no-lock:
            /*disp titulo.titnum with frame f-proc .
            pause 0.*/ 
            if vsetcod > 0 and
                banfin.titulo.titbanpag <> vsetcod
            then next.
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = banfin.titulo.titbanpag and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = banfin.titulo.titbanpag 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .

            find first wpag where 
                       wpag.wmod = "" and
                       wpag.wset = banfin.titulo.titbanpag and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = month(banfin.titulo.titdtpag) no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = ""
                    wpag.wset = banfin.titulo.titbanpag 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = month(banfin.titulo.titdtpag)  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .
 
            find first wpag where 
                       wpag.wmod = banfin.titulo.modcod and
                       wpag.wset = banfin.titulo.titbanpag and
                       wpag.wano = year(banfin.titulo.titdtpag) and
                       wpag.wmes = 0 no-error.
            if not avail wpag
            then do:
                create wpag.
                assign
                    wpag.wmod = banfin.titulo.modcod 
                    wpag.wset = banfin.titulo.titbanpag 
                    wpag.wano = year(banfin.titulo.titdtpag) 
                    wpag.wmes = 0  .
            end.
            wpag.wpag  = wpag.wpag  + banfin.titulo.titvlpag .

        end.
    end.
end.
def buffer bwpag for wpag.
def buffer bmodgru for modgru.
for each wpag where wpag.wmod <> "" and
                    wpag.wset <> 0  and
                    wpag.wano <> 0  and
                    wpag.wmes <> 0:
    find first bwpag where
               bwpag.wmod = "" and
               bwpag.wset = wpag.wset and
               bwpag.wano = wpag.wano and
               bwpag.wmes = wpag.wmes
               no-error.
    find metadesp where  metadesp.etbcod = 999 and
                         metadesp.setcod = wpag.wset and
                         metadesp.metano = wpag.wano and
                         metadesp.metmes = wpag.wmes and
                         metadesp.modcod = wpag.wmod
                         no-lock no-error.
    if avail metadesp
    then assign
            wpag.wmet = metadesp.metval
            bwpag.wmet = bwpag.wmet + metadesp.metval. 
    find first modgru where modgru.modcod = wpag.wmod and 
                            modgru.mogsup <> 0 no-lock.
    find first bmodgru where bmodgru.mogcod = modgru.mogsup no-lock.
    wpag.wgru = bmodgru.modcod.
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
        find metadesp where  metadesp.etbcod = 999 and
                         metadesp.setcod = wgru.wset and
                         metadesp.metano = wgru.wano and
                         metadesp.metmes = wgru.wmes and
                         metadesp.modcod = wgru.wmod
                         no-lock no-error.
        if avail metadesp
        then wgru.wmet = metadesp.metval. 
            
    end.     
    wgru.wpag = wgru.wpag + wpag.wpag.      
end.
for each wpag where wpag.wmod = "" and
                    wpag.wset <> 0  and
                    wpag.wano <> 0  and
                    wpag.wmes <> 0:
    find metadesp where  metadesp.etbcod = 999 and
                         metadesp.setcod = wpag.wset and
                         metadesp.metano = wpag.wano and
                         metadesp.metmes = wpag.wmes and
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
    wacu.wmet = wacu.wmet + wgru.wmet.   
    find first wsetor where wsetor.wsetcod = wgru.wset no-error.
    if not avail wsetor
    then do:
        create wsetor.
        wsetor.wsetcod = wgru.wset.
    end.
end.     
form with frame f-disp.
form with frame f-disp1.       
def var varquivo as char.

for each wpag where wpag.wmod = "" :
    find first setaut where setaut.setcod = wpag.wset no-lock no-error.
    if not avail setaut
    then next.
    if wpag.wmet = 0 or 
       wpag.wmet >= wpag.wpag
    then next.
    varquivo = "/admcom/work/arquivodg017" + string(setaut.setcod) + ".txt".
    output to value(varquivo).
        put unformatted
        "METAS DE DESPESAS  <BR>"
        "-------------------------------- <BR>"
        "Setor      : " setaut.setnom        " <BR>"
        "Periodo    : " vdti " Ate: " vdtf                    " <BR>"
        "Meta       : " wpag.wmet  format ">>,>>>,>>9.99"  " <BR>"
        "Realizado  : " wpag.wpag  format ">>,>>>,>>9.99"  " <BR>"
        "Saldo      : " wpag.wmet - wpag.wpag 
                                   format "->>,>>>,>>9.99"   " <BR>"
        "---------------------------------"                         " <BR>"
        . 
    output close.
    run /admcom/progr/envia_dg.p("17",varquivo).
    pause 1 no-message.
end. 
