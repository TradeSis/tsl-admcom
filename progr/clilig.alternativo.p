
def new global shared var varq as char.
varq = "/admcom/work/processo-call-center." + string(today,"99999999").

output to value(varq) .
put unformatted "INICIOU "  today " " 
                string(time             ,"HH:MM:SS") skip.
output close.

for each estab no-lock.
    find estrgcobra of estab no-lock no-error. 
    if avail estrgcobra  
    then next. 
    create estrgcobra. 
    estrgcobra.etbcod = estab.etbcod. 
    estrgcobra.rgccod = 1.
end.
def var xx as int.
for each clilig where dias <> (today - clilig.dtven).  
    xx = xx + 1.
    if xx mod 10000 = 0
    then do.
        output to value(varq) 
                    append .
        
        put unformatted 
            skip
        "          alteracao dtproxlig...  " string(time ,"HH:MM:SS")
        " " 
        xx
        skip.
        output close.
    end.
    do:
        if time >= 1 and time < 82800                 
        then
        clilig.dias = today - clilig.dtven.
        else clilig.dias = (today + 1) - clilig.dtven.
        char3     = "AJUSTE DIAS - " 
                  + string(today,"99/99/9999") 
                  + " - "
                  + string(time,"hh:mm:ss").        
        if clilig.dtproxlig <> ?
        then do:
            if time >= 1 and time < 82800                 
            then clilig.dtproxlig = today.                  
            else clilig.dtproxlig = today + 1.
        end.
        
    end.    
end.


/****  nova versao  *****/
run /admcom/progr/clilig.finexporta.p .
/************************/


    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char.
    
    assign
        vassunto = "LOG_PROCESSO_CALL_CENTER" 
        vdestino = "sistema@lebes.com.br;isis.vargas@lebes.com.br;"
        varquivo = "/admcom/relat/email_processo_call" + string(time) + ".html".

    output to value(varquivo).
    unix silent value("more " + varq).
    output close.
        
    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~"". 
    unix silent value(varqmail).

 

do on error undo.
    leave.
end.


def var vcriic  as int.
def var vcriic1 as int.
def var vcriic2 as int.
def var vult            as log.
def var vpagas          as int.

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

def buffer btitulo  for titulo.
def buffer bestab   for estab.
def buffer bcliletb  for cliletb.
def var vestab like titulo.etbcod.
def var vdtacor as date.

def var vv as int format ">>,>>>,>>>,>>9".
pause 0 before-hide.
for each clien no-lock by clicod desc.
    if clien.clicod = 0 then next.
    if clien.clicod = 1 then next.
    vv = vv + 1.
    if vv mod 1000 = 0
    then do.
        put skip
            vv " "
            clien.clicod " "
            string(time,"HH:MM:SS")      " "
            skip.
    end.    
    find clilig where clilig.clicod = clien.clicod  exclusive-lock no-error.
    if avail clilig 
    then do:
    
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
                clilig.titnum   = ?  .
                clilig.titpar   = ?  .
                clilig.char1    = ?.
                clilig.char3    = "".
        for each cliletb where cliletb.clicod = clilig.clicod. 
                delete cliletb.
        end. 
    end.
    run cria-clilig (clien.clicod).      
end.
put skip
    "Total de clientes " vv " "
    skip
    "FIM "
    today " "
    string(time,"HH:MM:SS")
    skip.

output close.


procedure cria-clilig.
def input parameter p-clifor like clien.clicod.
    
    
    for each btitulo use-index iclicod 
                      where btitulo.empcod  = 19                 
                       and btitulo.titnat  = no                 
                       and btitulo.modcod  = "CRE"
                       and btitulo.titsit  = "LIB" 
                       and btitulo.clifor  = p-clifor
                       /*and btitulo.etbcod  = estab.etbcod*/ no-lock
        break by btitulo.clifor.

        if first-of(btitulo.clifor)
        then do:
            find clilig where clilig.clicod = btitulo.clifor
                exclusive-lock no-error.        
             if not avail clilig
             then create clilig.
             find bestab where bestab.etbcod = btitulo.etbcod no-lock.
             find estrgcobra of bestab no-lock.
             
             
             if clilig.char3 = ""
             then do:
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
                    clilig.dtven     = btitulo.titdtven
                                       /*min(clilig.dtven,btitulo.titdtven)*/ .
                    clilig.int1      = btitulo.titpar.
                    clilig.char1     = string(today,"99/99/9999").
                    if time < 82800
                    then clilig.dtproxlig = today.
                    else clilig.dtproxlig  = (today + 1).                 
                    valdivtot        = 0.
                    clilig.char3     = "".
                end.                    
        end.   
        
        if clilig.char3 = ""
        then do:        
        if clilig.int1 = 0
        then clilig.int1 = btitulo.titpar.
        else clilig.int1 = min(clilig.int1,btitulo.titpar).
        
        assign
        clilig.dtven  = min(clilig.dtven,btitulo.titdtven).
        if time < 82800
        then clilig.dias = today - clilig.dtven.
        else clilig.dias = (today + 1) - clilig.dtven.
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
        
        if btitulo.titdtven < today and btitulo.titpar <= 30 /* aqui */
        then do:
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
        end.
                        
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
        
        /* dtacor */ 
                    
        /* Valor da Divida */                    
        clilig.valdivtot = clilig.valdivtot + btitulo.titvlcob.
        

        /*
        hide message no-pause.
        message "admcom: " clilig.clicod clilig.valdivtot.
        */
        
        /* Atualiza Setor */
        run atu-setor-clinovo.
        
        end.
        
        if last-of(btitulo.clifor) and clilig.char3 = ""
        then do:
        
        vdtacor = 01/01/0001 .
        for each clitel where clitel.clicod = clilig.clicod
            and clitel.teldat >= clilig.dtven
                        no-lock.                   
            find tipcont of clitel no-lock no-error.
            if clitel.dtpagcont <> ?
            then vdtacor = max(vdtacor,clitel.dtpagcont). 
            clilig.DtUltLig  = clitel.teldat.  
        end.
        clilig.dtacor = if vdtacor = 01/01/0001
                        then ?
                        else vdtacor. 
                        
        find last clitel where clitel.clicod = clilig.clicod and
                  (clitel.dtpagcont < today or clitel.dtpagcont = ?)
                 no-lock no-error.
        if avail clitel
        then assign clilig.DtUltLig = clitel.teldat  
                    clilig.horalig  = clitel.telhor.        
        
        
            clilig.char3     = "AJUSTE DATA - " 
                             + string(today,"99/99/9999") 
                             + " - "
                             + string(time,"hh:mm:ss").        
        end.
        
    end.                    
end procedure.


procedure atu-setor-clinovo.


        if (time < 82800 and ((today - clilig.dtven) >= vcriic)) or
           (time >= 82800 and (((today + 1) - clilig.dtven) >= vcriic))
        then do:
            vult = yes.
            def buffer xestab for estab.
            for each xestab no-lock.
                for each titulo where titulo.empcod   = 19
                                  and titulo.titnat   = no
                                  and titulo.modcod   = "CRE"
                                  and titulo.etbcod   = xestab.etbcod
                                  and titulo.titdtven > clilig.dtven
                                  and titulo.clifor   = clilig.clicod
                                  and titulo.titsit   = "LIB"
                                      no-lock.
                    vult = no.
                    leave.
                end. 
                leave.
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
        for each titulo where titulo.clifor = clilig.clicod no-lock.
                if titulo.titnat = no and
                   titulo.titdtpag <> ? and
                   titulo.titsit = "PAG"
                then. 
                else next.
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
        
end procedure.





