DEF VAR vdir AS CHAR.
DEF VAR vpini AS CHAR.
DEF VAR vpf AS CHAR.

vdir = "/admcom/barramento/tsrelat/".
INPUT FROM VALUE(vdir + "tsrelat.ini").
repeat TRANSACTION:
    IMPORT UNFORMATTED vpini.
    if vpini = "" or vpini = ? then next.
    
    if ENTRY(1,vpini,"=") = "PF"         THEN vpf = ENTRY(2,vpini,"=").
    if ENTRY(1,vpini,"=") = "PROPATH"    THEN propath = ENTRY(2,vpini,"=").
end.
input close.

MESSAGE "PROPATH=" + PROPATH.

def new global shared var scontador as int.
scontador = 100000.

def var par-param as char.
def var par-pause as int.

def var ventradaarquivo as char.

par-param = SESSION:PARAMETER no-error.
par-pause = int(entry(1,par-param)) no-error.

def var vprograma as char.
def var lcjsonentrada as longchar.
def var verro as char.

def var vmensagem as log.
def var vini as log init yes.

if opsys = "UNIX"
then do:
    {/admcom/barramento/pidtsrelat.i}
end.

procedure verifica-fim.

    INPUT FROM /admcom/barramento/ASYNCtsrelat.LK.
    import unformatted VLK.
    input close.

    if vLK = "FIM" or
       (time >= 16200 and time <= 18000) /* entre 04:30 e 05:00 */
    then do:
        message "  /admcom/barramento/ASYNCtsrelat.LK =" vlk string(time,"HH:MM:SS").
        message "  BYE!".
        quit.
    end.        

    lk("FIM","").

end procedure.

    message "Eliminando Antigos 60".
    for each tsrelat where tsrelat.dtproc < today - 7.
        delete tsrelat.
    end.    

        
    message today string(time,"HH:MM:SS"). pause.
def var vloop as int.

pause 0 before-hide.
vmensagem = yes.

repeat:
    vloop = vloop + 1.

    run verifica-fim.

    if vini = no  
    then do:
        if time mod 1000 = 0 or vloop = 10
        then do:
            if par-pause = 1 
            then run log ("Sem registros...").
            else run log ("Pause " + string(par-pause)).
        
            vmensagem = yes.
            vloop = 0.
        end.    
        else vmensagem = no.
        run log ("Pause " + string(par-pause)).
        pause par-pause no-message.
    
        run verifica-fim.
        
    end.    
    else do:
    
    end.
    vini = no.
  
    par-pause = 10.
    
        for each tsrelat where
            tsrelat.dtproc = ?
                no-lock
                by tsrelat.dtinclu by tsrelat.hrinclu.
                
            run log("Processando... " + tsrelat.progcod + " ID=" + string(tsrelat.idrelat)).
            
            if search(vdir + tsrelat.progcod + ".p") <> ?
            then do:    
                if opsys = "UNIX"
                then do:
                    os-command silent value("/usr/dlc/bin/mbpro -pf " + vpf + " -p " + 
                                        vdir + tsrelat.progcod + ".p " + 
                                        " -param " + string(tsrelat.idrelat) + ">> /admcom/barramento/log/tsrelatserver.log  & " ) .            
                END.  
                ELSE DO:
                    MESSAGE   "c:\Progress\OpenEdge\bin\mbpro.bat -pf " + vpf + " -p " + 
                                        vdir + "tsdispara.p " + 
                                        " -param ~"" + string(tsrelat.idrelat) + 
                                        "," + tsrelat.progcod + 
                                        "," + vdir +  "~"" +
                                        " >>  /admcom/barramento/log/" + tsrelat.progcod + "_" + STRING(TODAY,"99999999") + ".log   &" .
                    os-command silent value("c:\Progress\OpenEdge\bin\mbpro.bat -pf " + vpf + " -p " + 
                                        vdir + "tsdispara.p " + 
                                        " -param ~"" + string(tsrelat.idrelat) + 
                                        "," + tsrelat.progcod + 
                                        "," + vdir +  "~"" +
                                        " >> /admcom/barramento/log/tsrelat-disparo_" + STRING(TODAY,"99999999") + ".log   &" ) .            
                
                END.
            end.
        end.
  
end.    


procedure Log.
def input param par-men as char.

message
today " " 
string(time,"HH:MM:SS") " "
par-men.


end procedure.

