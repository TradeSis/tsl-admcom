def buffer btitulo      for titulo.
def buffer bcliletb     for cliletb.
def buffer bclilig      for clilig.

def var vestab          like estab.etbcod.
def var vdtacor         as date.
def var vult            as log.
def var vpagas          as int.

disp "ini"  today string(time             ,"HH:MM:SS").

def temp-table tt-cli
    field clicod like clien.clicod.
    
/*
for each clilig /*where clilig.char1 <> ""*/.
    clilig.char1 = "".
end.    
*/

for each tt-cli.
delete tt-cli.
end.
for each estab no-lock.

    find estrgcobra of estab no-lock no-error. 
    if avail estrgcobra  
    then next. 
    
    create estrgcobra. 
    estrgcobra.etbcod = estab.etbcod. 
    estrgcobra.rgccod = 1.
    
end.

def var vcriic  as int.
def var vcriic1 as int.
def var vcriic2 as int.

find credscore where credscore.campo = "CRIIC" no-lock no-error.
if avail credscore
then vcriic = credscore.valor.
else vcriic = 91.
find credscore where credscore.campo = "CRIIC1" no-lock no-error.
if avail credscore
then vcriic1 = credscore.valor.
else vcriic1 = 0.
find credscore where credscore.campo = "CRIIC2" no-lock no-error.
if avail credscore
then vcriic2 = credscore.valor.
else vcriic2 = 0.

for each clilig where clicod = ?.
delete clilig.
end.

/*find clilig where clilig.clicod = 12963157 no-lock.*/
for each bclilig where valdivtot = 0.

    run cria-clilig(bclilig.clicod).
    
    run atu-setor-clinovo (bclilig.clicod).
end.

for each clilig where valdivtot = 0.
delete clilig.
end.



procedure cria-clilig.
def input parameter p-clicod like clien.clicod.

for each estab.
    for each btitulo where btitulo.empcod  = 19                 
                       and btitulo.titnat  = no                 
                       and btitulo.modcod  = "CRE"
                       and btitulo.titsit  = "LIB" 
                       and btitulo.etbcod  = estab.etbcod
                       and btitulo.clifor  = p-clicod no-lock.
        if btitulo.clifor = 1
        then next.
        find clilig where clilig.clicod = btitulo.clifor
            exclusive-lock no-error.
        if not avail clilig
        then do:
             create clilig.                       
             ASSIGN clilig.clicod    = btitulo.clifor
                    clilig.empcod    = btitulo.empcod   . 
                    clilig.titnat    = btitulo.titnat   . 
                    clilig.modcod    = if btitulo.titpar > 30
                                       then "NOV"
                                       else btitulo.modcod  . 
                    clilig.clicod    = btitulo.clifor  . 
                    clilig.titnum    = btitulo.titnum  . 
                    clilig.titpar    = btitulo.titpar  .
                    clilig.DtUltLig  = 01/01/0001.
                    clilig.dtven     = 12/31/9999            .
                    clilig.etbcod    = btitulo.etbcod         .
                    clilig.titvlcob  = btitulo.titvlcob     .
                    clilig.rgccod    = estrgcobra.rgccod  .
                    clilig.dtacor    = 01/01/0001         .
                    clilig.dtven     = min(clilig.dtven,btitulo.titdtven).
                    clilig.int1      = btitulo.titpar.
        end.   
        
        clilig.char1     = string(today,"99/99/9999").
                
        clilig.dtproxlig  = today.

        if clilig.int1 = 0
        then clilig.int1 = btitulo.titpar.
        else clilig.int1 = min(clilig.int1,btitulo.titpar).
        
        assign
        clilig.dtven  = min(clilig.dtven,btitulo.titdtven)
        clilig.dias   = today - clilig.dtven.
        clilig.empcod = if clilig.dtven = btitulo.titdtven
                        then btitulo.empcod  
                        else clilig.empcod .
        clilig.titnat = if clilig.dtven = btitulo.titdtven
                        then btitulo.titnat
                        else clilig.titnat .
        clilig.modcod = if clilig.dtven = btitulo.titdtven
                        then if btitulo.titpar > 30
                             then "NOV"
                             else btitulo.modcod 
                        else if btitulo.titpar > 30
                             then "NOV"
                             else clilig.modcod.
        
        if btitulo.titpar > 30
        then do:
            clilig.modcod = "NOV".
            clilig.dtacor = clilig.dtacor - 1.
            if clilig.dtacor = ?
            then clilig.dtacor = clilig.dtven.            
        end.

        /***/
        vestab = btitulo.etbcod.        
        
        find first cliletb where cliletb.clicod = clilig.clicod
                             and cliletb.etbcod = btitulo.etbcod
                                exclusive-lock no-error.
        if not avail cliletb
        then do:
            create cliletb.
            cliletb.clicod = clilig.clicod.
            cliletb.etbcod = btitulo.etbcod.
        end.
        cliletb.valdivetb = cliletb.valdivetb + btitulo.titvlcob.
        find first bcliletb where bcliletb.clicod = cliletb.clicod
                              and bcliletb.etbcod <> cliletb.etbcod
                                no-lock no-error.
        if avail bcliletb
        then vestab = 0.
                        
        clilig.etbcod = if clilig.dtven = btitulo.titdtven
                        then btitulo.etbcod
                        else clilig.etbcod .
        if vestab = 0
        then clilig.etbcod = vestab.
        else .
        
        clilig.clicod = if clilig.dtven = btitulo.titdtven
                        then btitulo.clifor
                        else clilig.clicod .
        clilig.titnum = if clilig.dtven = btitulo.titdtven
                        then btitulo.titnum
                        else clilig.titnum .
        clilig.titpar = if clilig.dtven = btitulo.titdtven
                        then btitulo.titpar
                        else clilig.titpar .

        
        clilig.titvlcob = if clilig.dtven = btitulo.titdtven
                          then btitulo.titvlcob 
                          else clilig.titvlcob.
        clilig.rgccod    = if clilig.dtven = btitulo.titdtven
                           then estrgcobra.rgccod
                           else clilig.rgccod.
        
        vdtacor = 01/01/0001 .
        for each clitel where clitel.clicod = clilig.clicod
            and clitel.teldat >= btitulo.titdtven 
                        no-lock.                   
            find tipcont of clitel no-lock no-error.
            if clitel.dtpagcont <> ?
            then vdtacor = max(vdtacor,clitel.dtpagcont). 
            clilig.DtUltLig  = clitel.teldat.  
        end.
        clilig.dtacor = if vdtacor = 01/01/0001
                        then ?
                        else vdtacor. 
        find last clitel where clitel.clicod = btitulo.clifor and
                  (clitel.dtpagcont < today or clitel.dtpagcont = ?)
                 no-lock no-error.
        if avail clitel
        then assign clilig.DtUltLig = clitel.teldat  
                    clilig.horalig  = clitel.telhor.
                    
        /* Valor da Divida */                    
        clilig.valdivtot = clilig.valdivtot + btitulo.titvlcob.
        
        /***
        disp "admcom: " clilig.clicod  format ">>>>>>>>>9"
                        clilig.char1 format "x(10)"
                        btitulo.titnum
                        btitulo.titpar
                        btitulo.titdtven
                        string(time,"hh:mm:ss").
        ***/                        

        /*
        hide message no-pause.
        message "admcom: " clilig.clicod clilig.valdivtot.
        */
        
    end.                    
end.    
end procedure.

procedure atu-setor-clinovo.
def input parameter p-clicod like clien.clicod.

    for each clilig where clilig.clicod = p-clicod.
        if today - clilig.dtven >= vcriic
        then do:
            vult = yes.
            for each titulo where titulo.titnat = no
                              and titulo.clifor = clilig.clicod
                              and titulo.titsit = "LIB"
                              and titulo.modcod = "CRE"
                              and titulo.titdtven > clilig.dtven
                                  no-lock.
                vult = no.
            end.                    
        end.
        else vult = no.

        /*
        hide message no-pause.
        message clilig.clicod.
        */
        
        if vult = yes or clilig.int1 >= 50
        then clilig.setor = "CRIIC".
        else clilig.setor = "COBRA".
        
        /* Cliente Novo */
        vpagas = 0.    
        for each titulo where titulo.titnat = no
                          and titulo.clifor = clilig.clicod
                          and titulo.titdtpag <> ?
                          and titulo.titsit = "PAG"
                              no-lock.
                if titulo.modcod = "DEV" or
                   titulo.modcod = "BON" or
                   titulo.modcod = "CHP"
                then next.                          
                vpagas = vpagas + 1.
                /***
                hide message no-pause.
                message 222 vpagas titulo.clifor titulo.titnum titulo.titpar.
                ***/
        end.
        if vpagas <= 30
        then clilig.tipo = "N".
        else clilig.tipo = "".
        
    end.
end procedure.
