/* helio 01062023 */
/* 05012022 helio iepro */

def var pacao   as char init "arquivo".
/*pause 0 before-hide.*/

def var vi as int.
def var poperacao   as char init "IEPRO".
def var pcodocorrencia as char.
def var pocorrencia as char.
def var parquivo as char.
def var premessa as int.
def var parquivorecid as recid.
def var dstatus   as char. 

def temp-table ttcomarca no-undo
    field cidcod    like munic.cidcod
    field qtd       as int.
    
def temp-table tttitprotesto no-undo
    field cidcod    like munic.cidcod
    field precid    as recid.


def new shared temp-table ttprot
    field precid        as recid.

def var xtime as int.
xtime = time.
/** **/
def var wcontinua as log.
        /*message "INICIO" today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "pesquisa" poperacao pacao.*/

        for each titprotesto where  titprotesto.operacao = poperacao and
                                titprotesto.acao     = pacao     and
                                titprotesto.dtacao   = ?
                no-lock.
            if (titprotesto.protocolo = ? and pacao = "ARQUIVO") or titprotesto.protocolo <> ?
            then.
            else next.

            find clien of titprotesto no-lock.
            
            create tttitprotesto.
            tttitprotesto.precid = recid(titprotesto).

            find first munic where munic.cidnom = clien.cidade[1] no-lock no-error.
            if not avail munic
            then find first munic where munic.cidnom = "PORTO ALEGRE" no-lock no-error.
        
            if avail munic and munic.cidcod <> ? 
            then tttitprotesto.cidcod = munic.cidcod.
            else tttitprotesto.cidcod = 4314902.

            find titprotcomarca where titprotcomarca.cidcod = tttitprotesto.cidcod no-lock no-error.
            if avail titprotcomarca
            then tttitprotesto.cidcod = titprotcomarca.comarca.
                
            find first ttcomarca where ttcomarca.cidcod = tttitprotesto.cidcod no-error.
            if not avail ttcomarca    
            then do:
                create ttcomarca.
                ttcomarca.cidcod = tttitprotesto.cidcod.
            end.    
            ttcomarca.qtd = ttcomarca.qtd + 1.

            
        end.

        /*message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS") .*/
        
        do while true.
            run envia.
            if wcontinua = no
            then leave.
        end.
        /*message "FIM" today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS").*/
        

procedure envia.
def var vqtd as int.
    for each ttprot.
        delete ttprot.
    end.        
    vqtd = 0.        
    wcontinua = no.
    
        for each ttcomarca.
            ttcomarca.qtd = 0.
            for each tttitprotesto where tttitprotesto.cidcod = ttcomarca.cidcod.
                ttcomarca.qtd = ttcomarca.qtd + 1. 
            end.
            if ttcomarca.qtd = 0
            then delete ttcomarca.
        end.
    
    for each ttcomarca by ttcomarca.qtd .
        /*message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS")  "Comarca" ttcomarca.cidcod "registros" ttcomarca.qtd.*/
        
        for each tttitprotesto where tttitprotesto.cidcod = ttcomarca.cidcod.
            find titprotesto where recid(titprotesto) = tttitprotesto.precid no-lock.
            vqtd = vqtd + 1.
            /**** nao tem limite
            *if vqtd > 110
            *then do:
            *    vqtd = vqtd - 1.
            *    message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS")  "fazer um arquivo -> " vqtd.
            *
            *    wcontinua = yes.
            *    leave.
            *end.    
            */
            
            create ttprot.
            ttprot.precid  = tttitprotesto.precid.   
            delete tttitprotesto.
        end.
        if wcontinua then leave.

    end.

    find first ttprot no-error.
    if not avail ttprot
    then do:
        message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS") poperacao  pacao "nenhum registro encontrado".
        pause 1.
    end.
    else do:
        if pacao = "ARQUIVO"
        then do:
            vqtd = 0.
            for each ttprot.
                vqtd = vqtd + 1.
            end.    
                        run iep/geraarquivo.p (input poperacao,
                                   input "REMESSA",
                                   output parquivorecid ,
                                   output parquivo,
                                   output premessa).
            /*message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS") premessa parquivo
                " vai enviar registros:" vqtd.*/
                      
            if parquivo = ""
            then do:
                message " --> limite de remessas do dia." string(today,"99/99/9999") parquivo
                    view-as alert-box.
                wcontinua = no.
                return.
            end.
                        
            /* GERA XML e ENVIA IEPRO - CHAMADA API */
            run iep/montaarquivo-remessa.p (    input poperacao,
                                            input parquivo,            
                                            input premessa,
                                            input xtime,
                                            output pcodocorrencia,
                                            output pocorrencia).

            message " " today string(xtime,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Remessa" premessa "Arquivo /admcom/tmp/iep/remessas/" + parquivo.
            
        end.
        
    end.
    
    for each ttprot.
        delete ttprot.
    end.    

end procedure.

