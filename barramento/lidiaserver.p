/* helio #11102022 - retirar passagem de ER para NP */

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

{/admcom/barramento/pidlidia.i}

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

    message "Eliminando Antigos 60".
    for each verusjsonlidia where verusjsonlidia.datain < today - 60.
        delete verusjsonlidia.
    end.    
    /* #11102022
    vreg = 0.
    for each verusjsonlidia where verusjsonlidia.jsonstatus = "ER".
        verusjsonlidia.jsonstatus = "NP".
        vreg = vreg + 1.
    end. 
    if vreg > 0 
    then run log("Ainda Existem " + string(vreg) + " Registros com Status ER").
    #11102022 */
    
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
