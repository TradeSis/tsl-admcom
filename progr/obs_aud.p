def var vdti as date.
def var vdtf as date.

vdtf = today.
vdti = vdtf - 35.

def buffer btabobs for tabobs.
def buffer ctabobs for tabobs.

def var obs-cod like tabobs.obscod.
def var obs-tipo like tabobs.obstipo.
def var obs-titulo like tabobs.obstitulo.
def var obs-desc like tabobs.obsdesc.
/*
def var sresp as log format "Sim/Nao".
message "Confirma exportar observacoes? " update sresp.
if not sresp then return.
*/

def var vforcod as char.
def var vtipmov as char.

def var vetbcod like estab.etbcod.
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
def var varq as char.

if opsys = "unix" and sparam <> "AniTA"
then do:
        
        input from /admcom/audit/param_obs.
        repeat:
            import varq.
            vetbcod = int(substring(varq,1,3)).
            vdti    = date(int(substring(varq,6,2)),
                           int(substring(varq,4,2)),
                           int(substring(varq,8,4))).
            vdtf    = date(int(substring(varq,14,2)),
                           int(substring(varq,12,2)),
                           int(substring(varq,16,4))).
                       
        end.
        input close.
    
        if vetbcod = 999
        then return.
    end.
else do:
    update vetbcod at 5 label "Filial"
       vdti at 1 label "Periodo de"
       vdtf label "Ate"
       with frame f1 1 down side-label width 80.
    message "EM PROCESSAMENTO.... AGUARDE!".
end.

for each estab no-lock:
    if estab.etbcgc <> ""
    then.
    else next.
    if vetbcod > 0 and
    estab.etbcod <> vetbcod
    then next.
    
    for each plani where 
             plani.etbcod = estab.etbcod and
             plani.emite  = estab.etbcod and
             plani.pladat >= vdti and
             plani.pladat <= vdtf
             no-lock.
        if plani.movtdc = 5 then next.
        if plani.serie = "U" or
           plani.serie = "1"
        then.
        else next.   
        obs-desc = plani.notobs[1] + " " +
                   plani.notobs[2] + " " +
                   plani.notobs[3].
        if obs-desc <> ""  and
            length(trim(obs-desc)) > 20
        then do:
            obs-titulo = string(plani.emite,"9999999999") + " " +
                         string(plani.serie,"x(5)") + " " +
                         string(plani.numero,"9999999999").
            find first tabobs where
                       tabobs.obstitulo = obs-titulo
                       no-lock no-error.
            if avail tabobs
            then.
            else do:           
                find last btabobs no-lock no-error.
                if avail btabobs
                then obs-cod = btabobs.obscod + 1.
                else obs-cod = 1.
                if obs-titulo matches "*art*"
                then obs-tipo = "O460".
                else obs-tipo = "0450".
                create ctabobs.
                assign
                    ctabobs.obscod = obs-cod 
                    ctabobs.obstipo = obs-tipo
                    ctabobs.obstitulo = obs-titulo
                    ctabobs.obsdesc = obs-desc
                    .
            end. 
            if plani.emite = plani.desti
            then vtipmov = "E".
            else vtipmov = "S".
            if  vtipmov = "S"
            then do:
                    if plani.serie = "v"
                    then vforcod =
                        "C" + string(plani.desti,"9999999999") + "       ".
                    else if plani.emite = plani.etbcod and
                        plani.desti <> plani.etbcod
                    then vforcod =
                    "E" + string(plani.desti,"9999999") + "          ".   
                    else vforcod =
                    "F" + string(plani.desti,"9999999") + "          ".   
                end.
                else do:
                    if plani.desti = plani.etbcod and
                    plani.emite <> plani.etbcod
                    then vforcod =
                    "E" + string(plani.emite,"9999999") + "          ".   
                    else vforcod =
                    "F" + string(plani.emite,"9999999") + "          ".  
                end.
            find obsref where
                       obsref.etbcod = estab.etbcod and
                       obsref.forcod = vforcod and
                       obsref.numdoc = string(plani.numero) and 
                       obsref.serie  = plani.serie and 
                       obsref.codobs = string(obs-cod)
                       no-lock no-error.
            if not avail obsref
            then do:
                create obsref.
                assign
                    obsref.etbcod = estab.etbcod
                    obsref.numdoc = string(plani.numero)
                    obsref.serie  = plani.serie
                    obsref.codobs = string(obs-cod)
                    obsref.tipmov = vtipmov
                    obsref.forcod = vforcod
                    obsref.datadoc = plani.datexp
                    obsref.modelo  = "1"
                    obsref.tipoobs = obs-tipo
                    obsref.complemento = ""
                    .
            end.                
        end.
    end.
end.

def var vdata as date.
def var vetb as char.

if vetbcod = 0
then vetb = "".
else vetb = string(vetbcod,"999").
def var varquivo as char.

if opsys = "unix"
then varquivo = "/admcom/audit/nfobs_" + trim(string(vetb,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

else varquivo = "l:\audit\nfobs_" + trim(string(vetb,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".


output to value(varquivo).

for each obsref where
         obsref.datadoc >= vdti and
         obsref.datadoc <= vdtf and
         (if vetbcod > 0
          then obsref.etbcod = vetbcod else true)
         no-lock:   
    find tabobs where tabobs.obscod = int(obsref.codobs) no-lock no-error.
    if not avail tabobs or
        tabobs.obsdesc = ""
    then next.    

        put string(tabobs.obscod)     format "x(6)"
            string(tabobs.obstipo)    format "x(4)"
            tabobs.obstitulo  format "x(50)"
            tabobs.obsdesc    format "x(260)"
            skip.
end.

output close.        

if vetbcod = 0
then vetb = "".
else vetb = string(vetbcod,"999").
if opsys = "unix"
then varquivo = "/admcom/audit/obsref_" + trim(string(vetb,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".

else varquivo = "l:\audit\obsref_" + trim(string(vetb,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".

output to value(varquivo).

for each obsref where
         obsref.datadoc >= vdti and
         obsref.datadoc <= vdtf and
         (if vetbcod > 0
          then obsref.etbcod = vetbcod else true)
         no-lock:   
    find tabobs where tabobs.obscod = int(obsref.codobs) no-lock no-error.
    if not avail tabobs or
        tabobs.obsdesc = ""
    then next.    

    put string(obsref.etbcod) format "x(3)"
        obsref.tipmov         format "x"
        obsref.numdoc         format "x(12)"
        obsref.serie          format "x(5)"
        obsref.forcod         format "x(18)"
        string(day(obsref.datadoc),"99")  
        string(month(obsref.datadoc),"99")   
        string(year(obsref.datadoc),"9999")
        obsref.modelo         format "x(2)"
        obsref.tipoobs         format "x(4)"
        obsref.codobs         format "x(6)"
        obsref.complemento    format "x(254)"
        skip. 
        
end.
output close.
