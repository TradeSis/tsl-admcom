/* helio 07022023 - https://trello.com/c/uAKaPFHH/973-pre%C3%A7os-integrando-apenas-at%C3%A9-a-loja-141
    na interface produtoloja, enviado datain para procedure de carga */

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

{/admcom/barramento/pid.i}

procedure verifica-fim.

    INPUT FROM /admcom/barramento/ASYNC.LK.
    import unformatted VLK.
    input close.

    if vLK = "FIM" or
       (time >= 16200 and time <= 18000) /* entre 04:30 e 05:00 */
    then do:
        message "  /admcom/barramento/ASYNC.LK =" vlk string(time,"HH:MM:SS").
        message "  BYE!".
        quit.
    end.        

    lk("FIM","").

end procedure.

    message "Eliminando Antigos 60".
    for each verusjsonin where verusjsonin.datain < today - 60.
        delete verusjsonin.
    end.    
    vreg = 0.
    for each verusjsonin where verusjsonin.jsonstatus = "ER".
        verusjsonin.jsonstatus = "NP".
        vreg = vreg + 1.
    end. 
    if vreg > 0 
    then run log("Ainda Existem " + string(vreg) + " Registros com Status ER").
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
        run log("Processando exportacao Bonus CRM").
        run /admcom/progr/eis4/expbosnuscrm.p.
        run log("Processando exportacao Cliente").
        run /admcom/progr/eis4/expcliente.p.

        run /admcom/progr/eis4/gerametacobrancaeis.p.

    end.
    
    vreg = 0.
    for each verusjsonin where verusjsonin.jsonstatus = "NP" no-lock.
        if      verusjsonin.interface = "cupomvendamercadoria" 
             or verusjsonin.interface = "pedidovendamercadoria"
             or verusjsonin.interface = "cupomvendaservico"
             or verusjsonin.interface = "produto"
             or verusjsonin.interface = "produtoloja"
             or verusjsonin.interface = "renegociacaocrediario"
        then next.
    
        vreg = vreg + 1.
    end.
    if vreg = 0
    then do:
        par-pause = 1.
        next.
    end.
    par-pause = 10.
    
    if vreg > 0
    then do:
        run log("Processando " + string(vreg) + " Registros com Status NP").
        for each verusjsonin where
            verusjsonin.jsonstatus = "NP"
                no-lock
                by verusjsonin.datain by verusjsonin.horain.
            if      verusjsonin.interface = "cupomvendamercadoria" 
                 or verusjsonin.interface = "pedidovendamercadoria"
                 or verusjsonin.interface = "cupomvendaservico"
                 or verusjsonin.interface = "produto"
                 or verusjsonin.interface = "produtoloja"
                 or verusjsonin.interface = "renegociacaocrediario"
            then next.
            
            run atualizaStatus ("EP",""). /* Em processamento */
            
            copy-lob FROM verusjsonin.jsonDados to lcjsonentrada CONVERT TARGET CODEPAGE 'UTF-8'.
            ventradaarquivo = "./json/" + verusjsonin.interface + "_" + string(recid(verusjsonin)) + ".json".
            output to value(ventradaarquivo) no-CONVERT.
/*            put unformatted horain "-" string(lcjsonentrada) SKIP(2).*/
            DISPLAY lcjsonentrada VIEW-AS EDITOR LARGE INNER-LINES 300 INNER-CHARS 300
              WITH FRAME x1 WIDTH 320 no-box no-labels.
            output close.
            

            find last verusasyncin where
                    verusasyncin.interface = verusjsonin.interface
                and verusasyncin.datain    = verusjsonin.datain
                and verusasyncin.horain    <= verusjsonin.horain
             no-lock no-error.
            if not avail verusasyncin         
            then
                find last verusasyncin where
                       verusasyncin.interface = verusjsonin.interface
                   and verusasyncin.datain    < verusjsonin.datain
                      no-lock no-error.
            if avail verusasyncin
            then do:
                vprograma = "/admcom/barramento/async/" + lc(verusasyncin.interface) + "_" + trim(verusasyncin.versao) + ".p".
                verro = "".
                if search(vprograma) <> ?
                then do:
                    def var xtime as int.
                    xtime = time.
                    run log("RECID=" + string(recid(verusjsonin)) + " EXEC=" + vprograma).

                    if verusjsonin.interface = "produtoloja"
                    then run value(vprograma) (input lcjsonentrada, verusjsonin.datain, output verro).  /* helio 07022023 */
                    else run value(vprograma) (input lcjsonentrada, output verro). 
                    
                    run log(string(time - xtime,"HH:MM:SS") + " retorno RECID=" + string(recid(verusjsonin)) + " EXEC=" + vprograma + " ERRO=" + verro) .
                    if verro = ""
                    then do:
                        run atualizaStatus ("PR","" ). 
                        unix silent value("rm -f  " + ventradaarquivo).
                    end.    
                    else do:
                        if verro = "LOCADO"
                        then do:
                            run log("RECID=" + string(recid(verusjsonin)) + " " + verro).
                            run atualizaStatus ("NP",verro ).
                        end.
                        else do:
                            run log("RECID=" + string(recid(verusjsonin)) + " " + verro).
                            run atualizaStatus ("ER",verro ).
                        end.
                    end.    
                end.    
                else do:
                    run log("RECID=" + string(recid(verusjsonin)) + " NO SEARCH: " + vprograma).
                    run atualizaStatus ("NP","NO SEARCH: " + vprograma ). /* Processado/Erro */ 
                end.    
            end.
            else do:  
                run atualizaStatus ("NA","NO ASYNC: " + lc(verusjsonin.interface)). /* Processado/Erro */ 
            end.
        end.
    end.

    
    vreg = 0.   
    for each verusjsonin where verusjsonin.jsonstatus = "EP" .
        if      verusjsonin.interface = "cupomvendamercadoria" 
             or verusjsonin.interface = "pedidovendamercadoria"
             or verusjsonin.interface = "cupomvendaservico"
             or verusjsonin.interface = "produto"
             or verusjsonin.interface = "produtoloja"
             or verusjsonin.interface = "renegociacaocrediario"
        then next.
    
        vreg = vreg + 1.
        verusjsonin.jsonstatus = "NP".
    end. 
    if vreg > 0
    then run log("Ainda Existem " + string(vreg) + " Registros com Status EP").
    vreg = 0.
    for each verusjsonin where verusjsonin.jsonstatus = "NA" no-lock
        break by verusjsonin.interface.
        vreg = vreg + 1.
        if last-of(verusjsonin.interface)
        then do:
            run log("Ainda Existem " + string(vreg) + " SEM ESTRUTURA " +  lc(verusjsonin.interface)).
            vreg = 0.
        end.
        run atualizaStatus ("NP","NO ASYNC: " + lc(verusjsonin.interface)). /* Processado/Erro */
    end. 
    
    
end.    

procedure atualizaStatus.
    def input param par-status as char.
    def input param par-obs    as char.
    do on error undo:
        find current verusJsonIn exclusive no-wait no-error.
        if avail verusJsonIn
        then do:
            verusJsonIn.jsonStatus = par-status.
            verusJsonIn.dataUP     = today.
            verusJsonIn.horaUP     = time.
            verusJsonIn.jsonstatusdes = par-obs.
            find current verusjsonin no-lock.
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
