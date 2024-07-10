/*
Consumir o WS do Notamax
*/
def input parameter par-metodo    as char.
def input parameter par-xml       as char.
def input parameter par-leretorno as log.

def shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

def var vtime   as int.
def var vretorno as char.

/***
    Socket
***/
def var vcab1   as char.
def var vlf     as char. /* line feed */
def var sh      as handle NO-UNDO.
def var sb      as memptr.
def var vb      as memptr.
def var vtam    as int.
def var vpause  as int.
def var vip     as char init "10.2.0.121". /* Servidor Notamax */.
                       
pause 0 before-hide.
vlf   = chr(10).
vtime = time.
empty temp-table tt-xmlretorno.

message "Conectando Notamax ..." vip.
create socket sh no-error.
if sh:connect("-H " + vip + " -S 80")
then do.
    message "Conectado ao Notamax...".
    set-size(sb) = 3000.
    set-size(vb) = 20001.

    vcab1 = 
        "POST /notamax/services/wsNotamax.asmx/" + par-metodo +
        " HTTP/1.1" + vlf +
        "Host: localhost" + vlf +
        "Content-Type: application/x-www-form-urlencoded" + vlf +
        "Content-Length: " + string(length(par-xml)) + vlf + vlf.

    output to value("../relat/notamax-env." + par-metodo + string(vtime)).
    put unformatted vcab1 + par-xml.
    output close.

    message "Enviando Solicitacao ao Notamax ..." length(vcab1 + par-xml).
    assign
        put-string(sb, 1) = vcab1 + par-xml.
    sh:write(sb, 1, length(vcab1 + par-xml)).
                    
    vpause = 0.
    repeat.
        vpause = vpause + 1.
        pause 2 no-message.
        vtam = sh:GET-BYTES-AVAILABLE().
        message "Aguardando retorno... (" vpause ")" vtam.
        if vtam > 0 or vpause > 5
        then leave.
    end.
    if vpause > 5
    then do.
        message "Problema no retorno da NFC-e" view-as alert-box.
        return.
    end.
        
    sh:read(vb , 1, vtam).
    assign vretorno = get-string(vb,1).

    if par-leretorno
    then run retorno.
    else do.
        output to value("../relat/notamax-rec." + par-metodo + string(vtime)).
        put unformatted vretorno.
        output close.
    end.
end.
else do.
    message "Falha ao conectar ao servidor" view-as alert-box.
    return.
end.
sh:disconnect().
hide message.
Delete Object sh.


procedure retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.

    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").

    put-string(vb, 1) = vretorno.

    output to value("../relat/notamax-rec." + par-metodo + string(vtime)).
    put unformatted vretorno.
    output close.

    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 
      
    run obtemnode ("", input hroot).
   /*Aqui chama a procedure que monta uma tt com os dados de retorno passando como parâmetro dos dados recebidos pelo load*/

end procedure.


procedure obtemnode.

    def input parameter p-root  as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.
    
    create x-noderef hc.
    /* A partir daqui monta o retorno */
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        run obtemnode (vh:name, input hc:handle).
        if trim(hc:node-value) <> ""
        then do.
            create tt-xmlretorno.
            tt-xmlretorno.root  = p-root.
            tt-xmlretorno.tag   = vh:name. /* nomes das tags */
            tt-xmlretorno.valor = trim(hc:node-value).
        end.    
    end.                       

end procedure.
