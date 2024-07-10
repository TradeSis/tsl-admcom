/******************************************************************
alteracao feita em 19092012 para ler pelo cliente e nao mais pelo titulo
    afim de verificar os tempos de processamento
******************************************************************/
run /admcom/work/luciano.xx.p.
do on error undo.
    return.
end.

def temp-table tt-cli
    field clicod like clien.clicod
    index tt-cli is primary unique clicod.
    
def buffer btitulo      for titulo.
def buffer bcliletb     for cliletb.

def var i as int.

def var vestab          like estab.etbcod.
def var vdtacor         as date.
def var vult            as log.
def var vpagas          as int.

output to value("./cria.log." + string(today,"99999999")) append.
put unformatted "ini "  today string(time             ,"HH:MM:SS") skip.
output close.

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

for each tt-cli.
    delete tt-cli.
end.
def var xx as int.
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted 
    "Iniciando alteracao dtproxlig...  " string(time             ,"HH:MM:SS")
    skip.
output close.    
xx = 0.

for each clilig where dias <> (today - clilig.dtven).
    xx = xx + 1.
    if xx mod 100 = 0
    then do.
        output to value("./cria.log." + string(today,"99999999")) append.
        put unformatted 
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
xx = 0.
def var vdata as date.
/* Pagamentos */
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted 
    "Pagamentos " string(time             ,"HH:MM:SS")
    skip.
output close.    
do vdata = today - 3 to today.
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted 
    "Pagto " vdata " " 
                    string(time             ,"HH:MM:SS")
    skip.
output close.
def var vnext as int.
for each titulo where titulo.empcod   = 19     and 
                      titulo.titnat   = no     and 
                      titulo.modcod   = "CRE"  and 
                      titulo.titdtpag = vdata 
                      
                      use-index titdtpag
                      no-lock.

    if titulo.clifor = 1      
    then do.
        vnext = vnext + 1.    
        output to 
                    value("./cria.log." + string(today,"99999999")) append.
        put unformatted  
            "Pagto " vdata " " xx " "   
                string(time             ,"HH:MM:SS") 
                " "
                "next "
                vnext
                skip. 
        output close.
        next.             
    end.
    if titulo.titsit <> "PAG" 
    then do.
        vnext = vnext + 1.    
        output to 
                    value("./cria.log." + string(today,"99999999")) append.
        put unformatted  
            "Pagto " vdata " " xx " " 
                string(time             ,"HH:MM:SS") 
                " "
                "next "
                vnext
                skip. 
        output close.
        next. 
    end.
    
    do:
        find first tt-cli where tt-cli.clicod = titulo.clifor
            no-lock no-error.
        if not avail tt-cli
        then do:
            /*
            hide message no-pause.
            message "P" titulo.clifor.    
            */
            xx = xx + 1.
            if xx mod 10 = 0
            then do.
                output to 
                    value("./cria.log." + string(today,"99999999")) append.
                put unformatted 
                    "Pagto " vdata " " xx " "
                            string(time             ,"HH:MM:SS")
                    skip.
                output close.
            end.
            create tt-cli.
            tt-cli.clicod = titulo.clifor.
            find clilig where clilig.clicod = tt-cli.clicod 
                exclusive-lock no-error.
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
            run cria-clilig (tt-cli.clicod).
       end.
    end.
end.
end.
    
/* Novos Titulos */
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted 
    "Novos Titulos " string(time             ,"HH:MM:SS")
    skip.
output close.    
xx = 0.
for each titulo use-index iclicod
        where titulo.titnat = no
          and titulo.empcod = 19
          and titulo.titdtemi >= today - 1
          and titulo.clifor > 1
          and titulo.titsit = "LIB"
          and titulo.modcod =  "CRE"

            no-lock
            break by titulo.clifor.
  if first-of(titulo.clifor)
  then do:              
    find first tt-cli where tt-cli.clicod = titulo.clifor
        no-lock no-error.
    if not avail tt-cli
    then do:
        /*
        hide message no-pause.
        message "E" titulo.clifor.    
        */
            xx = xx + 1.
            if xx mod 10 = 0
            then do.
                output to 
                    value("./cria.log." + string(today,"99999999")) append.
                put unformatted 
                    "Novos tit     E " titulo.clifor " " xx ""
                            string(time             ,"HH:MM:SS")
                    skip.
                output close.
            end.

        create tt-cli.
        tt-cli.clicod = titulo.clifor.
        find clilig where clilig.clicod = tt-cli.clicod 
                exclusive-lock no-error.
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
        run cria-clilig (tt-cli.clicod).
    end.
  end.    
end.

/* Novos Vencimentos */
xx = 0.
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted
    "Novos Vencimentos " string(time             ,"HH:MM:SS")
    skip.
output close.
do vdata = today - 10 to today + 160.
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted
    "Novos Vecto       " string(time             ,"HH:MM:SS")
    " "
    vdata
    skip.
output close.
for each estab no-lock .
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted
    "Novos Vecto       " string(time             ,"HH:MM:SS")
    " "
    vdata
    " "
    estab.etbcod
    skip.
output close.
for each titulo 
                where
                      titulo.empcod = 19 
                  and titulo.titnat = no
                  and titulo.modcod =  "CRE"
                  and titulo.etbcod = estab.etbcod
                  and titulo.titdtven = vdata
                  and titulo.clifor > 1
                  and titulo.titsit = "LIB"
            no-lock.

  do.
    find first tt-cli where tt-cli.clicod = titulo.clifor
        no-lock no-error.
    if not avail tt-cli
    then do:
        /*
        hide message no-pause.
        message "V" titulo.clifor.
        */
        xx = xx + 1.
        if xx mod 10 = 0
        then do.
            output to value("./cria.log." + string(today,"99999999")) append.
            put unformatted
                "Novos Vecto       " string(time             ,"HH:MM:SS")
                " "
                vdata
                " "
                estab.etbcod
                " "
                titulo.clifor
                " "
                xx
                skip.
            output close.
        end.

        create tt-cli.
        tt-cli.clicod = titulo.clifor.
        find clilig where clilig.clicod = tt-cli.clicod 
                exclusive-lock no-error.
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
        run cria-clilig (tt-cli.clicod).
    end.
  end.
end.            
end.
end.
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted
    "Zerado " string(time             ,"HH:MM:SS")
    skip.
output close.            
/*** acerta-clilig
for each tt-cli.
    hide message no-pause.
    message tt-cli.clicod.
    run cria-clilig (tt-cli.clicod).
end.
***/
output to value("./cria.log." + string(today,"99999999")) append.
put unformatted
    "meio "  string(time             ,"HH:MM:SS")
    skip.
output close.
/* Dragao */

output to value("./cria.log." + string(today,"99999999")) append.
put unformatted 
    "FIM "  string(time             ,"HH:MM:SS")
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
        
        /* Atualiza Setor */
        run atu-setor-clinovo.
        
        end.
        
        if last-of(btitulo.clifor) and clilig.char3 = ""
        then do:
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
        
end procedure.


/*
run /admcom/progr/cria.p.

run /admcom/progr/atuclilig.p.
*/



/*
run /admcom/progr/cria.p.

run /admcom/progr/atuclilig.p.
*/

/***
def var vmodcod like modal.modcod extent 1
                     init 
                        ["Cre"].

def buffer btitulo for titulo.
def buffer bcliletb for cliletb.

def var vestab like titulo.etbcod.
def var vdtven like titulo.titdtven.

def var vfaz as log.

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

for each estab  no-lock.  
    find estrgcobra of estab no-lock no-error. 
    if avail estrgcobra  
    then next. 
    create estrgcobra. 
    estrgcobra.etbcod = estab.etbcod. 
    estrgcobra.rgccod = 1.
end.

pause 0 before-hide.

def var vtime as int.

vtime = time.
def var vv as int.
output to criaclilig.log.

put unformatted 
    "ini"  string(time             ,"HH:MM:SS")
    skip.

for each cliletb.
    delete cliletb.
end.
    
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
    then.
end.    

put unformatted 
    "meio " string(time             ,"HH:MM:SS")
    skip.

pause 0 before-hide. 
def var vdtacor as date format "99/99/9999". 
vdtacor = 01/01/0001.
vv = 0.
for each ttmodal.
    for each estab.
    for each titulo where 
        titulo.empcod  = 19                 and
        titulo.titnat  = no                 and
        titulo.modcod  = ttmodal.modcod     and
        titulo.titsit  = "LIB" and
        titulo.etbcod  = estab.etbcod
        no-lock.
        
    vfaz = yes.
    for each btitulo where btitulo.empcod = titulo.empcod
                       and btitulo.titnat = titulo.titnat
                       and btitulo.modcod = "CRE"
                       and btitulo.titdtpag = titulo.titdtemi
                       and btitulo.etbcod = titulo.etbcod
                       and btitulo.clifor = titulo.clifor no-lock.
        if btitulo.moecod = "NOV" or btitulo.etbcod > 900
        then vfaz = yes.
        else if titulo.titdtven >= today
             then vfaz = no.
             else vfaz = yes.
    end.         
    
    if titulo.titdtven >= today and titulo.titpar < 30
    then vfaz = no.
        
    if vfaz = no
    then next.
        
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if not avail clien then next.
        /*find estab where estab.etbcod = titulo.etbcod no-lock. */
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
        
        if titulo.titpar > 30
        then do:
            clilig.modcod = "NOV".
            clilig.dtacor = clilig.dtacor - 1.
            if clilig.dtacor = ?
            then clilig.dtacor = clilig.dtven.            
        end.

        /***/
        vestab = titulo.etbcod.        
        /*
        for each btitulo where btitulo.clifor = clilig.clicod
                             no-lock.
            if btitulo.titsit <> "LIB"                        
            then next.
            if btitulo.etbcod = clilig.etbcod
            then next.
            if btitulo.modcod <> "CRE"
            then next.
            if btitulo.titnat <> no
            then next.
            if btitulo.empcod <> 19
            then next.
            if btitulo.titdtven >= today then next.            
            vestab = 0.
            vdtven = btitulo.titdtven.
        end.        
        */
        
        find first cliletb where cliletb.clicod = clilig.clicod
                             and cliletb.etbcod = titulo.etbcod
                                exclusive-lock no-error.
        if not avail cliletb
        then do:
            create cliletb.
            cliletb.clicod = clilig.clicod.
            cliletb.etbcod = titulo.etbcod.
        end.
        cliletb.valdivetb = cliletb.valdivetb + titulo.titvlcob.
        find first bcliletb where bcliletb.clicod = cliletb.clicod
                              and bcliletb.etbcod <> cliletb.etbcod
                                no-lock no-error.
        if avail bcliletb
        then vestab = 0.
                        
        clilig.etbcod = if clilig.dtven = titulo.titdtven
                        then titulo.etbcod
                        else clilig.etbcod .
        if vestab = 0
        then clilig.etbcod = vestab.
        else .
        
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
        then do. /*disp v with 1 down.*/ pause 0. end.
    end.
    end.
end.                    

if connected ("d") 
then disconnect d.

connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp -ld d.

run /admcom/progr/criaclilig2.p.

if connected ("d") 
then disconnect d.

disp "fim"  string(time             ,"HH:MM:SS").

/*
for each clilig where clilig.dtven >= today.
    delete clilig.
end.
*/

disp 11111 string(time             ,"HH:MM:SS").
run /admcom/progr/cliligaux.p.
disp 22222 string(time             ,"HH:MM:SS").
run /admcom/progr/cliligaux2.p. /* Atualiza Clientes Novos */
disp 33333 string(time             ,"HH:MM:SS").
run /admcom/callcenterteste/atualizaclilig.p.
disp 44444 string(time             ,"HH:MM:SS").
    /* Atualiza Setor */
for each clilig.    
    clilig.setor = "COBRA".
    if (today - clilig.dtven) >= vcriic
    then do:
        clilig.setor = "CRIIC".
    end.
end.    
disp 55555 string(time             ,"HH:MM:SS").

for each clilig where clilig.dtven >= today and clilig.modcod <> "NOV".
    delete clilig.
end.
disp 66666.
disp "final"  string(time             ,"HH:MM:SS").

disp 00000.
output close.
*****/
