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

{/admcom/barramento/pidboletagem.i 03}

procedure verifica-fim.

    INPUT FROM /admcom/barramento/ASYNCboletagem.LK.
    import unformatted VLK.
    input close.

    if vLK = "FIM" or
       (time >= 16200 and time <= 18000) /* entre 04:30 e 05:00 */
    then do:
        message "  /admcom/barramento/ASYNCboletagem.LK =" vlk string(time,"HH:MM:SS").
        message "  BYE!".
        quit.
    end.        

    lk("FIM","").

end procedure.

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
        run log("").
        run log("Processando Assinatura e Boletagem - Server 03 - Filiais 61 a 100").
        run ban/assinboletproc.p (61,100).
        run log("Finalizado Assinatura e Boletagem").

    
    
end.    

procedure Log.
def input param par-men as char.

message
today " " 
string(time,"HH:MM:SS") " "
par-men.


end procedure.
