            

if today >= 07/24/2012 and
   today <= 07/29/2012
then do:

output to ./cria.log append.

def temp-table tt-cli
    field clicod like clien.clicod.
    
def buffer btitulo      for titulo.
def buffer bcliletb     for cliletb.

def var i as int.

def var vestab          like estab.etbcod.
def var vdtacor         as date.
def var vult            as log.
def var vpagas          as int.

disp "ini"  today string(time             ,"HH:MM:SS").

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
    
for each clilig where dias <> (today - clilig.dtven).
    do:
        clilig.dias = today - clilig.dtven.
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
    
/* Pagamentos */
disp "Pagamentos" string(time             ,"HH:MM:SS").
for each titulo use-index iclicod 
                where titulo.titnat = no
                  and titulo.empcod = 19
                  and titulo.titdtpag <> ?
                  and titulo.titdtpag >= today - 1
                  and titulo.clifor > 1
                  and titulo.titsit = "PAG"
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
            message "P" titulo.clifor.    
            */
            create tt-cli.
            tt-cli.clicod = titulo.clifor.
        end.
    end.
end.
    
/* Novos Titulos */
disp "Novos Titulos" string(time             ,"HH:MM:SS").
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
        create tt-cli.
        tt-cli.clicod = titulo.clifor.
    end.
  end.    
end.

/* Novos Vencimentos */
disp "Novos Vencimentos" string(time             ,"HH:MM:SS").
for each titulo use-index iclicod
                where titulo.titnat = no
                  and titulo.empcod = 19 
                  and titulo.titdtven >= today - 1
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
        message "V" titulo.clifor.
        */
        create tt-cli.
        tt-cli.clicod = titulo.clifor.
    end.
  end.
end.            

for each tt-cli.
    find clilig where clilig.clicod = tt-cli.clicod exclusive-lock no-error.
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
    end.
end.
            
disp "Zerado" string(time             ,"HH:MM:SS").
            
/*** acerta-clilig ***/
for each tt-cli.
    hide message no-pause.
    message tt-cli.clicod.
    run cria-clilig (tt-cli.clicod).
end.

disp "meio"  string(time             ,"HH:MM:SS").

/* Dragao */

disp "fin"  string(time             ,"HH:MM:SS").

output close.

output to ./cli.txt.
for each tt-cli.
export tt-cli.
end.
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

end.


/*

run ./criammm.p.

run ./arruma-setor.p.

/***
run conecta_d.p.

run ./criamm1.p
***/

*/
