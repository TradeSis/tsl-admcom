/***
def var vmodcod like modal.modcod extent 1
                     init 
                        ["Cre"].

def buffer btitulo for titulo.

def var vachou as log.

def var vcriic  as int.
def var vcriic1 as int.
def var vcriic2 as int.

find credscore where credscore.campo = "CRIIC" no-lock no-error.
if avail credscore
then vcriic = credscore.valor.
else vcriic = 0.
find credscore where credscore.campo = "CRIIC1" no-lock no-error.
if avail credscore
then vcriic1 = credscore.valor.
else vcriic1 = 0.
find credscore where credscore.campo = "CRIIC2" no-lock no-error.
if avail credscore
then vcriic2 = credscore.valor.
else vcriic2 = 0.

def temp-table ttmodal  
    field modcod    like modal.modcod.
    
def var x as int.
do x = 1 to 1.
    create ttmodal.
    assign ttmodal.modcod = vmodcod[x].
end.

def var vpagas as int.

pause 0 before-hide.

def var vtime as int.

vtime = time.

output to criaclilig.log.

disp "ini"  string(time             ,"HH:MM:SS").
for each clilig.     
    /***
    find titulo where titulo.empcod = clilig.empcod and
                      titulo.titnat = clilig.titnat and
                      titulo.modcod = clilig.modcod and
                      titulo.etbcod = clilig.etbcod and
                      titulo.clifor = clilig.clicod and 
                      titulo.titnum = clilig.titnum and
                      titulo.titpar = clilig.titpar  
                      no-lock no-error.
    ***/
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
***/

for each estab  no-lock.  
    find estrgcobra of estab no-lock no-error. 
    if avail estrgcobra  
    then next. 
    create estrgcobra. 
    estrgcobra.etbcod = estab.etbcod. 
    estrgcobra.rgccod = 1.
end.

def var vfaz as log.
def var vv as int.
def var vestab like d.titulo.etbcod.
def var vdtven like d.titulo.titdtven.

def buffer btitulo for d.titulo.
def buffer bcliletb for cliletb.

def var vdtacor as date format "99/99/9999". 
vdtacor = 01/01/0001.
vv = 0.
for each d.modal where d.modal.modcod = "CRE".
    for each estab.
    for each d.titulo where 
        d.titulo.empcod  = 19                 and
        d.titulo.titnat  = no                 and
        d.titulo.modcod  = modal.modcod     and
        d.titulo.titsit  = "LIB" and
        d.titulo.etbcod  = estab.etbcod
        no-lock.
        
    vfaz = yes.
    for each btitulo where btitulo.empcod = d.titulo.empcod
                       and btitulo.titnat = d.titulo.titnat
                       and btitulo.modcod = "CRE"
                       and btitulo.titdtpag = d.titulo.titdtemi
                       and btitulo.etbcod = d.titulo.etbcod
                       and btitulo.clifor = d.titulo.clifor no-lock.
        if btitulo.moecod = "NOV" or btitulo.etbcod > 900
        then vfaz = yes.
        else if d.titulo.titdtven >= today
             then vfaz = no.
             else vfaz = yes.
    end.         
    
    if d.titulo.titdtven >= today and d.titulo.titpar < 30
    then vfaz = no.
        
    if vfaz = no
    then next.
        
        find clien where clien.clicod = d.titulo.clifor no-lock no-error.
        if not avail clien then next.
        /*find estab where estab.etbcod = d.titulo.etbcod no-lock. */
        find estrgcobra of estab no-lock.
        vv = vv + 1.
        find clilig where clilig.clicod = d.titulo.clifor no-error.
        if not avail clilig
        then do.
             create clilig.                       
             ASSIGN clilig.clicod = d.titulo.clifor
                    clilig.empcod   = d.titulo.empcod   . 
                    clilig.titnat   = d.titulo.titnat   . 
                    clilig.modcod   = d.titulo.modcod  . 
                    clilig.clicod   = d.titulo.clifor   . 
                    clilig.titnum   = d.titulo.titnum  . 
                    clilig.titpar   = d.titulo.titpar  .
                    clilig.DtUltLig  = 01/01/0001.
                    clilig.dtven  = 12/31/9999            .
                    clilig.etbcod = d.titulo.etbcod         .
                    clilig.modcod = d.titulo.modcod         .
                    clilig.titvlcob = d.titulo.titvlcob     .
                    clilig.rgccod    = estrgcobra.rgccod  .
                    clilig.dtacor    = 01/01/0001         .
                    clilig.dtven  = min(clilig.dtven,d.titulo.titdtven).
        end.   
        clilig.dtproxlig  = today.

        assign
        clilig.dtven  = min(clilig.dtven,d.titulo.titdtven).   

        if titulo.titpar > 30
        then do:
            clilig.modcod = "NOV".
            clilig.dtacor = clilig.dtacor - 1.
            if clilig.dtacor = ?
            then clilig.dtacor = clilig.dtven.            
        end.
                
        clilig.dias   = today - clilig.dtven.
        clilig.empcod = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.empcod  
                        else clilig.empcod .
        clilig.titnat = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.titnat
                        else clilig.titnat .
        clilig.modcod = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.modcod 
                        else clilig.modcod.

        /***/
        vestab = d.titulo.etbcod.        
        find first cliletb where cliletb.clicod = clilig.clicod
                             and cliletb.etbcod = d.titulo.etbcod
                                exclusive-lock no-error.
        if not avail cliletb
        then do:
            create cliletb.
            cliletb.clicod = clilig.clicod.
            cliletb.etbcod = d.titulo.etbcod.
        end.
        cliletb.valdivetb = cliletb.valdivetb + d.titulo.titvlcob.
        find first bcliletb where bcliletb.clicod = cliletb.clicod
                              and bcliletb.etbcod <> cliletb.etbcod
                                no-lock no-error.
        if avail bcliletb
        then vestab = 0.
                        
        clilig.etbcod = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.etbcod
                        else clilig.etbcod .
        if vestab = 0
        then clilig.etbcod = vestab.
        else .
        
        clilig.clicod = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.clifor
                        else clilig.clicod .
        clilig.titnum = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.titnum
                        else clilig.titnum .
        clilig.titpar = if clilig.dtven = d.titulo.titdtven
                        then d.titulo.titpar
                        else clilig.titpar .

        
        clilig.titvlcob = if clilig.dtven = d.titulo.titdtven
                          then d.titulo.titvlcob 
                          else clilig.titvlcob.
        clilig.rgccod    = if clilig.dtven = d.titulo.titdtven
                           then estrgcobra.rgccod
                           else clilig.rgccod.
        
        vdtacor = 01/01/0001 .
        for each clitel of clien  
            where clitel.teldat >= d.titulo.titdtven 
                        no-lock.                   
            find tipcont of clitel no-lock no-error.
            if clitel.dtpagcont <> ?
            then vdtacor = max(vdtacor,clitel.dtpagcont). 
            clilig.DtUltLig  = clitel.teldat.  
        end.
        clilig.dtacor = if vdtacor = 01/01/0001
                        then ?
                        else vdtacor. 
        find last clitel where clitel.clicod = d.titulo.clifor and
                  (clitel.dtpagcont < today or clitel.dtpagcont = ?)
                 no-lock no-error.
        if avail clitel
        then assign clilig.DtUltLig = clitel.teldat  
                    clilig.horalig  = clitel.telhor.


        def var v as int.
        v = v + 1.
        if v mod 1000 = 0
        then do. disp v with 1 down. pause 0. end.
    end.
    end.
end.                    


