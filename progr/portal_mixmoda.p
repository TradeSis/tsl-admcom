{/admcom/progr/portal_acentos.i}
{/admcom/progr/portal_host.i}

define variable lo-arquivo as longchar  no-undo.
define variable ch-arquivo as character no-undo.
define variable vhSocket   as handle.

define variable de-tamanho as decimal no-undo.
define variable l-primeiro as logical initial yes no-undo.

define temp-table tt-valores no-undo serialize-name 'mixmoda'
    field codigo    as integer   serialize-name 'codigo'
    field descricao as character serialize-name 'descricao'
    field cod-pai   as integer   serialize-hidden.

define temp-table tt-deleta-tudo serialize-name 'produtos'
    field deleta-tudo as character serialize-name 'deletaTudo'
    field codigo      as integer   serialize-hidden.

define dataset portal serialize-name 'integracao' for tt-valores, tt-deleta-tudo
    data-relation for tt-deleta-tudo, tt-valores relation-fields(tt-deleta-tudo.codigo, tt-valores.cod-pai) nested.

create tt-deleta-tudo.
assign tt-deleta-tudo.codigo      = 1
       tt-deleta-tudo.deleta-tudo = 'Sim'.
       
for each mixmgrupo
   where mixmgrupo.situacao = yes no-lock:

    create tt-valores.
    assign tt-valores.codigo    = mixmgrupo.codgrupo
           tt-valores.descricao = fnremoveacento(mixmgrupo.nome)
           tt-valores.cod-pai   = 1.

end.
    
dataset portal:write-json("longchar", lo-arquivo, true).   

output to "/home/kbase/output.txt".
export lo-arquivo.
output close.
    
create socket vhSocket.
vhSocket:connect('-H ' + vcHost + ' -S ' + vcPort) no-error.
          
if vhSocket:CONNECTED() = FALSE then do:
    message "Connection failure" view-as alert-box.
        
    message error-status:get-message(1) view-as alert-box.
    return.
end.

vhSocket:set-read-response-procedure('getResponse').
    
run postrequest(input 'produtos/integracaoMixModa',
                input lo-arquivo).
       
wait-for READ-RESPONSE of vhSocket.
vhSocket:disconnect() no-error.
delete object vhSocket.    

procedure getResponse:
    define variable vcWebResp as longchar no-undo.
    define variable lSucess   as logical  no-undo.
    define variable mResponse as memptr   no-undo.
    
    if vhSocket:connected() = false then do:
        message 'Not Connected' view-as alert-box.
        return.
    end.
    
    lSucess = true.
    
    do while vhSocket:get-bytes-available() > 0:
        set-size(mResponse)       = vhSocket:get-bytes-available() + 1.
        set-byte-order(mResponse) = big-endian.
        vhSocket:read(mResponse,1,1,vhSocket:get-bytes-available()).
        vcWebResp                 = vcWebResp + get-string(mResponse,1).
    end.

end procedure.

procedure PostRequest:
    define variable vcRequest       as longchar.
    define variable mRequest        as memptr.

    define input parameter postUrl  as character.
    define input parameter postData as longchar.
    
    vcRequest = 'POST /' +
                postUrl  +
                ' HTTP/1.1~r~n' +
                ' HOST: ' + vchost + ':' + vcport + '~r~n' +
                'Content-Type: application/json~r~n' +
                'Content-Length: ' + string(length(postData)) +
                '~r~n' + '~r~n' +
                postData.
     
     set-size(mRequest)       = 0.
     set-size(mRequest)       = length(vcRequest) + 1.
     set-byte-order(mRequest) = big-endian.
     put-string(mRequest,1)   = vcRequest.
     
     vhSocket:write(mRequest, 1, length(vcRequest)).

end procedure.


