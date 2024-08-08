/* helio 08082024 - incluido neste programa o tsrelat  */
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

par-param = SESSION:PARAMETER.
par-pause = int(entry(1,par-param)).

def var vreg as int.
def var vprograma as char.
def var lcjsonentrada as longchar.
def var verro as char.

def var vmensagem as log.
def var vini as log init yes.

if opsys = "UNIX"
then do:
    {/admcom/barramento/pidlidia.i}
end.

procedure verifica-fim.

    INPUT FROM /admcom/barramento/ASYNClidia.LK.
    import unformatted VLK.
    input close.

    if vLK = "FIM" or
       (time >= 16200 and time <= 18000) /* entre 04:30 e 05:00 */
    then do:
        message "  /admcom/barramento/ASYNClidia.LK =" vlk string(time,"HH:MM:SS").
        message "  BYE!".
        quit.
    end.        

    lk("FIM","").

end procedure.

    message "Eliminando Antigos 60 - verusjsonlidia".
    for each verusjsonlidia where verusjsonlidia.datain < today - 60.
        delete verusjsonlidia.
    end.   
    message "Eliminando Antigos 30 - tsrelat".
    for each tsrelat where tsrelat.dtproc < today - 30.
        delete tsrelat.
    end.    
   
    vreg = 0.
        
    message today string(time,"HH:MM:SS").
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
    
    if int(entry(2,string(time,"HH:MM:SS"),":")) mod 10 = 0
    then do:
        run log("Processando exportacao Lidia Contratos").
        run /admcom/progr/lid/expcontrato.p.        
        run log("Processando exportacao Lidia Limites").
        run /admcom/progr/lid/explimite.p.
    end.

    /* AGENDAMENTO */
     run log("Verificando agendamentos").
        for each tsrelagend where tsrelagend.dtprocessar <= today no-lock.
            message "   agendamento" tsrelagend.dtprocessar
                string(tsrelagend.hrprocessar,"HH:MM:SS")
                tsrelagend.progcod
                tsrelagend.nomerel .
                
            if tsrelagend.dtprocessar < today
            then do:
                
                run agendamento.
               
               
            end.
            if tsrelagend.dtprocessar = today
            then do:
                if tsrelagend.hrprocessar <= time
                then do:
                    run agendamento.
                end.
                                
            end.
        end.
    /* RELATORIOS */        
    run log("Verificando relatorios").
        for each tsrelat where
            tsrelat.dtproc = ?
                no-lock
                by tsrelat.dtinclu by tsrelat.hrinclu.
            
            run log("Processando... " + tsrelat.progcod + " ID=" + string(tsrelat.idrelat)).
        
            if search(vdir + tsrelat.progcod + ".p") <> ?
            then do:    
                if opsys = "UNIX"
                then do:
                    MESSAGE   "/usr/dlc/bin/mbpro -pf " + vpf + " -p " + 
                        vdir + "tsdispara.p " + 
                        " -param ~"" + string(tsrelat.idrelat) + 
                        "," + tsrelat.progcod + 
                        "," + vdir +  "~"" +
                        " >> /admcom/barramento/log/tsrelat-disparo_" + STRING(TODAY,"99999999") + ".log   &" .

                    os-command silent value("/usr/dlc/bin/mbpro -pf " + vpf + " -p " + 
                        vdir + "tsdispara.p " + 
                        " -param ~"" + string(tsrelat.idrelat) + 
                        "," + tsrelat.progcod + 
                        "," + vdir +  "~"" +
                        " >> /admcom/barramento/log/tsrelat-disparo_" + STRING(TODAY,"99999999") + ".log   &" ) .            
                END.  
                ELSE DO:
                    MESSAGE   "call c:\Progress\OpenEdge\bin\mbpro.bat -pf " + vpf + " -p " + 
                                        vdir + "tsdispara.p " + 
                                        " -param ~"" + string(tsrelat.idrelat) + 
                                        "," + tsrelat.progcod + 
                                        "," + vdir +  "~"" +
                                        " >> /admcom/barramento/log/tsrelat-disparo_" + STRING(TODAY,"99999999") + ".log   &" .
                    os-command silent value("call c:\Progress\OpenEdge\bin\mbpro.bat -pf " + vpf + " -p " + 
                                        vdir + "tsdispara.p " + 
                                        " -param ~"" + string(tsrelat.idrelat) + 
                                        "," + tsrelat.progcod + 
                                        "," + vdir +  "~"" +
                                        " >> /admcom/barramento/log/tsrelat-disparo_" + STRING(TODAY,"99999999") + ".log   &" ) .            
                
                END.
            END.
        end.


    
    
end.    

procedure atualizaStatus.
    def input param par-status as char.
    def input param par-obs    as char.
    do on error undo:
        find current verusjsonlidia exclusive no-wait no-error.
        if avail verusjsonlidia
        then do:
            verusjsonlidia.jsonStatus = par-status.
            verusjsonlidia.dataUP     = today.
            verusjsonlidia.horaUP     = time.
            verusjsonlidia.jsonstatusdes = par-obs.
            find current verusjsonlidia no-lock.
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



procedure agendamento.
def var vano as int.
def var vmes as int.
def var vdata as date.

do on error undo:
    
    find current tsrelagend exclusive.

    create tsrelat.
    tsrelat.idrelat = next-value(tsrelat).
    tsrelat.usercod        = tsrelagend.usercod.
    tsrelat.dtinclu        = today.
    tsrelat.hrinclu        = time.
    tsrelat.progcod        = tsrelagend.progcod.
    tsrelat.REMOTE_ADDR    = tsrelagend.REMOTE_ADDR.
    tsrelat.nomeRel        = tsrelagend.nomeRel.
    tsrelat.dtProc         = ?.
    copy-lob tsrelagend.parametrosjson to tsrelat.parametrosjson.

    if tsrelagend.periodicidade = "M"
    then do:
        vano = year(today).
        vmes = month(today) + 1.
        if vmes = 13 then vano = vano + 1.
        
        tsrelagend.dtprocessar = date(vmes,tsrelagend.diadomes1,vano).

    end.

    if tsrelagend.periodicidade = "D"
    then do:
        tsrelagend.dtprocessar = today + tsrelagend.periododias.
    end.

    if tsrelagend.periodicidade = "Q"
    then do:
        vano = year(today).
        vmes = month(today).
        if vmes = 13 then vano = vano + 1.
        if tsrelagend.diadomes1 <= day(today)
        then do:
            if tsrelagend.diadomes2 = 0
            then do:
                vmes = month(today) + 1.
                if vmes = 13 then vano = vano + 1.
                tsrelagend.dtprocessar = date(vmes,tsrelagend.diadomes1,vano).
            end.
            else do:
                if tsrelagend.diadomes2 <= day(today)
                then do:
                    vmes = month(today) + 1.
                    if vmes = 13 then vano = vano + 1.
                end.
                tsrelagend.dtprocessar = date(vmes,tsrelagend.diadomes2,vano).    
            end.
        end.
        else do:
            tsrelagend.dtprocessar = date(vmes,tsrelagend.diadomes1,vano).
        end.
    end.
    
    if tsrelagend.periodicidade = "S"
    then do:
        do vdata = today + 1 to today + 7.
            if weekday(vdata) = tsrelagend.diasemana1
            then do:
                tsrelagend.dtprocessar = vdata.
                leave.
            end.
        end.
    end.


    if tsrelagend.periodicidade = "U"
    then do:
        delete tsrelagend.
    end.


end.


end procedure.

