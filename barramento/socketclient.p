def input parameter   cModeloSocket  as char.
def input parameter   cMetodoEntrada as char.
def input parameter  lcParamEntrada as LongChar.
def output parameter lcparamRetorno as longChar.

def var  mParamEntrada as MEMPTR.
def var  iTamEntrada as int. /* Tamanho da Entrada */

copy-lob LCParamEntrada to mParamEntrada convert target codepage "utf-8".
iTamEntrada = get-size(mParamEntrada).


DEFINE VARIABLE hSocket   AS HANDLE  NO-UNDO.
def var         mDados    as MEMPTR  no-undo.

def var pPorta as int.
def var pHost  as char.

{/admcom/barramento/socket.i}

def var         cEnvio    as char.
def var         cRetorno  as char.
def var         cStatus   as char.  

def var lOK as log.
def var iBytes  as int.


CREATE SOCKET hSocket.
hSocket:CONNECT('-H ' + pHost + ' -S ' + string(pPorta)) NO-ERROR.
IF hSocket:CONNECTED() = FALSE 
THEN DO: 
    MESSAGE 'Nao Consigo Conectar com Servidor ' pHost + ' Porta ' + string(pPorta) VIEW-AS ALERT-BOX. 
    RETURN. 
END.                      

/*hSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').*/

if cModeloSocket = "3PASSOS" or
   cModeloSocket = "PASSOSROBERTO" or
   cModeloSocket = ""
then do:
    if cModeloSocket = "" then cModeloSocket = "PASSOSROBERTO".
    run Passo1.
    run Passo2.
    run Passo3.
end.

if cModeloSocket = "HEADER"
then do:

    run PassoUnico.

end.

hSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT hSocket.
return.


procedure PassoUnico.
                                                 
    cEnvio =  "ModeloSocket=" + cModeloSocket +
             "&Metodo="       + cMetodoEntrada + 
             "&Tamanho="      + string(iTamEntrada) +
             "&".
    
    run escreverSocketHeaderLong (input hSocket,
                                  input cEnvio,
                                  input lcParamEntrada).
                          
    WAIT-FOR READ-RESPONSE OF hSocket.  
    
    iBytes = 0.
    run lerSocketLong  (input  hSocket,
                        input  iBytes, 
                        output lcParamRetorno).

end procedure.


procedure passo1.

    if CModeloSocket = "PASSOSROBERTO"
    then do:
        cEnvio = cMetodoEntrada + 
                 "&" +  string(iTamEntrada) +
                 "&".
    end.
    else do:
        cEnvio =  "ModeloSocket=" + cModeloSocket +
                 "&Metodo="       + cMetodoEntrada + 
                 "&Tamanho="      + string(iTamEntrada) +
                 "&".
    end.                          
    run escreverSocket (input hSocket,
                        input if cModeloSocket = "PASSOSROBERTO"
                              then 0
                              else 100, 
                        input cEnvio).
    WAIT-FOR READ-RESPONSE OF hSocket. 
    run lerSocket (input  hSocket,
                   input  0, 
                   output cRetorno).

    if CModeloSocket = "PASSOSROBERTO"
    then do:
        if cRetorno Begins "STATUS=OK"
        then cStatus = "OK".
    end.
    else do:
        cStatus  =     acha&("STATUS" ,string(cRetorno)). 
    end.      
    
end procedure.


procedure Passo2.

    
        run escreverSocketLong (input hSocket,
                                input lcParamEntrada).
        WAIT-FOR READ-RESPONSE OF hSocket. 

        run lerSocket (input  hSocket,
                       input  0,
                       output cRetorno).

    if CModeloSocket = "PASSOSROBERTO"
    then do:
        iBytes = int(cRetorno).
    end.
    else do:
        cStatus  =     acha&("STATUS" ,string(cRetorno)). 
        iBytes = int(acha&("TAMANHO" ,cRetorno)). 
    end.

end procedure.

procedure Passo3.

            cEnvio   = "STATUS=OK" + "&".
            run escreverSocket (input hSocket,
                                input 0,
                                input cEnvio).

            
            WAIT-FOR READ-RESPONSE OF hSocket. 

            run lerSocketLong  (input  hSocket,
                                input  iBytes, 
                                output lcParamRetorno).
            
        
end procedure.