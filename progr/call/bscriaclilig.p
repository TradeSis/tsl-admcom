def var vmodcod like modal.modcod extent 1
                     init 
                        ["Cre"].


def temp-table ttmodal  
    field modcod    like modal.modcod.
    
def var x as int.
do x = 1 to 1.
    create ttmodal.
    assign ttmodal.modcod = vmodcod[x].
end.


pause 0 before-hide.

def var vtime as int.

vtime = time.
def var vv as int.

disp "ini"  string(time             ,"HH:MM:SS").
          
for each clilig.     
    find titulo where titulo.empcod = clilig.empcod and
                      titulo.titnat = clilig.titnat and
                      titulo.modcod = clilig.modcod and
                      titulo.etbcod = clilig.etbcod and
                      titulo.clifor = clilig.clicod and 
                      titulo.titnum = clilig.titnum and
                      titulo.titpar = clilig.titpar  
                      no-lock no-error.
    do.
        clilig.dtven     = 12/31/9999.
        clilig.dias      = 12/31/9999 - today.
        clilig.etbcod    = 0.
        clilig.titcod    = ?. 
        clilig.DtProxLig = ?.   
        clilig.DtUltLig  = 01/01/0001.  
        clilig.horalig   = 0.  
        clilig.dtacor    = 01/01/0001.  
        clilig.tipo      = "".  
        clilig.titvlcob  = 0.
        clilig.modcod    = "".
        clilig.rgccod    = 0.
        clilig.empcod   = 0   .
        clilig.titnat   = ?   .
        clilig.modcod   = ""  .
        clilig.etbcod   = ?    .
        clilig.clicod   = ?   .
        clilig.titnum   = ?  .
        clilig.titpar   = ?  .
    end.        
    delete clilig.
    def var xx as int.
    xx = xx + 1.
    if xx mod 1000 = 0
    then
    disp xx .
end.    
             
disp "meio" string(time             ,"HH:MM:SS").

pause 0 before-hide. 
def var vdtacor as date format "99/99/9999". 
vdtacor = 01/01/0001.
vv = 0.
for each ttmodal.
    for each titulo where 
        titulo.empcod  = 19                 and
        titulo.titnat  = no                 and
        titulo.modcod  = ttmodal.modcod     and
        titulo.titsit  = "LIB" no-lock.

        if titulo.titdtven >= today then next.
        
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if not avail clien then next.
        find estab where estab.etbcod = titulo.etbcod no-lock. 
        find estrgcobra of estab no-lock.
        vv = vv + 1.
        find clilig where clilig.clicod = titulo.clifor no-error.
        if not avail clilig
        then do.
             create clilig.                       
             ASSIGN clilig.clicod = titulo.clifor
                    clilig.empcod   = titulo.empcod   . 
                    clilig.titnat   = titulo.titnat   . 
                    clilig.modcod   = titulo.modcod  . 
                    clilig.clicod   = titulo.clifor   . 
                    clilig.titnum   = titulo.titnum  . 
                    clilig.titpar   = titulo.titpar  .
                    clilig.DtUltLig  = 01/01/0001.
                    clilig.dtven  = 12/31/9999            .
                    clilig.etbcod = titulo.etbcod         .
                    clilig.modcod = titulo.modcod         .
                    clilig.titvlcob = titulo.titvlcob     .
                    clilig.rgccod    = estrgcobra.rgccod  .
                    clilig.dtacor    = 01/01/0001         .
                    clilig.dtven  = min(clilig.dtven,titulo.titdtven).
        end.   
        clilig.dtproxlig  = today.

        assign
        clilig.dtven  = min(clilig.dtven,titulo.titdtven)   
        clilig.dias   = today - clilig.dtven.
        clilig.empcod = if clilig.dtven = titulo.titdtven
                        then titulo.empcod  
                        else clilig.empcod .
        clilig.titnat = if clilig.dtven = titulo.titdtven
                        then titulo.titnat
                        else clilig.titnat .
        clilig.modcod = if clilig.dtven = titulo.titdtven
                        then titulo.modcod 
                        else clilig.modcod.
        clilig.etbcod = if clilig.dtven = titulo.titdtven
                        then titulo.etbcod  
                        else clilig.etbcod .
        clilig.clicod = if clilig.dtven = titulo.titdtven
                        then titulo.clifor
                        else clilig.clicod .
        clilig.titnum = if clilig.dtven = titulo.titdtven
                        then titulo.titnum
                        else clilig.titnum .
        clilig.titpar = if clilig.dtven = titulo.titdtven
                        then titulo.titpar
                        else clilig.titpar .

        
        clilig.titvlcob = if clilig.dtven = titulo.titdtven
                          then titulo.titvlcob 
                          else clilig.titvlcob.
        clilig.rgccod    = if clilig.dtven = titulo.titdtven
                           then estrgcobra.rgccod
                           else clilig.rgccod.
        
        vdtacor = 01/01/0001 .
        for each clitel of clien  
            where clitel.teldat >= titulo.titdtven 
                        no-lock.                   
            find tipcont of clitel no-lock no-error.
            if clitel.dtpagcont <> ?
            then vdtacor = max(vdtacor,clitel.dtpagcont). 
            clilig.DtUltLig  = clitel.teldat.  
        end.
        clilig.dtacor = if vdtacor = 01/01/0001
                        then ?
                        else vdtacor. 
        find last clitel where clitel.clicod = titulo.clifor and
                  (clitel.dtpagcont < today or clitel.dtpagcont = ?)
                 no-lock no-error.
        if avail clitel
        then assign clilig.DtUltLig = clitel.teldat  
                    clilig.horalig  = clitel.telhor.
    
        def var v as int.
        v = v + 1.
        if v mod 1000 = 0
        then do. disp v with 1 down.  pause 0.  end.
    end.
end.                    
disp "fim"  string(time             ,"HH:MM:SS").


for each clilig where clilig.dtven >= today.
    delete clilig.
end.



