{admcab.i}

def input parameter p-host as char.
def input parameter p-port as char.
def input parameter p-post as char.
def input parameter p-arqe as char.
def input parameter p-arqt as char.
def input parameter p-arql as char.
def input parameter p-arqr as char.
def output parameter p-conecta as log init yes.
def output parameter vcwebresp    AS longchar        NO-UNDO.

def var vlf     as char. /* line feed */
vlf   = chr(10).

def var sh-socket      as handle NO-UNDO.

create socket sh-socket no-error.
sh-socket:connect("-H " + p-host + " -S " + p-port) no-error.

IF sh-socket:CONNECTED() = false 
then do:
    message ERROR-STATUS:GET-MESSAGE(1) view-as alert-box.
    p-conecta = no.
    return.
end.

sh-socket:SET-READ-RESPONSE-PROCEDURE('get_response').

run post_request(input p-post,
                 input p-host,
                 input p-port,
                 input p-arqe,
                 input p-arqt).

wait-for READ-RESPONSE OF sh-socket.
sh-socket:DISCONNECT() NO-ERROR.
delete object sh-socket.

procedure get_response:
    def var mresponse    AS MEMPTR           NO-UNDO.
    
    if sh-socket:CONNECTED() = FALSE 
    then do:
        p-conecta = no.
        return.
    end.

    do while sh-socket:GET-BYTES-AVAILABLE() > 0:
        SET-SIZE(mresponse) = sh-socket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mresponse) = BIG-ENDIAN.
        sh-socket:READ(mresponse,1,1,sh-socket:GET-BYTES-AVAILABLE()).
        vcwebresp = vcwebresp + GET-STRING(mresponse,1).
    END.
end procedure.

procedure post_request:
    def input parameter p-post  as char.
    def input parameter p-host  as char.
    def input parameter p-port  as char.
    def input parameter p-arqe  as char.
    def input parameter p-arqt  as char.
    def var vrequest    AS CHARACTER.
    def var mrequest    AS MEMPTR.

    vrequest = "POST " + p-post + " HTTP/1.1" + vlf +
        "Host: localhost" + vlf +
        "Content-Type: " + p-arqt + vlf +
        "Connection: keep-alive" + vlf +
        "Content-Length: " + string(length(p-arqe)) + vlf + vlf 
                           + p-arqe + vlf.

    
    output to value(p-arql) append.
        put unformatted vrequest skip.
    output close.

    set-size(mrequest) = 0.
    set-size(mrequest) = length(vrequest) + 1.
    SET-BYTE-ORDER(mrequest) = BIG-ENDIAN.

    put-string(mrequest, 1) = vrequest.
    sh-socket:write(mrequest, 1, length(vrequest)).

end procedure.
