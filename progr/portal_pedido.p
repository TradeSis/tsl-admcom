{/admcom/progr/portal_host.i}

define temp-table tt-pedido no-undo serialize-name "pedido"
    field cod-pedido      as integer   serialize-name "codigo"
    field dt-pedido       as character serialize-name "data"
    field cod-estab       as integer   serialize-name "codigoEstabelecimento"
    field cod-fornec      as integer   serialize-name "codigoFornecedor"
    field dt-entrega-ini  as char      serialize-name "prazoEntregaInicial"
    field dt-entrega-fim  as char      serialize-name "prazoEntregaFinal"
    field cod-prazo-pagto as integer   serialize-name "codigoPrazoPagamento"
    field cod-comprador   as integer   serialize-name "codigoComprador"
    field frete           as character serialize-name "frete"
    field desconto-nota   as decimal   serialize-name "descontoNota"
    field desconto-dupl   as decimal   serialize-name "descontoDuplicata"
    field observacoes     as character serialize-name "observacoes".

define temp-table tt-produto no-undo serialize-name "produtos"
    field cod-produto  as integer   serialize-name "codigoProduto"
    field qtd-produto  as integer   serialize-name "quantidade"
    field observacoes  as character serialize-name "observacoes"
    field preco-venda  as decimal   serialize-name "precoVenda"
    field preco-custo  as decimal   serialize-name "precoCusto"
    field cod-pedido   as integer   serialize-hidden.

define temp-table tt-resultado no-undo
    field codigo     as int
    field integrado  as log
    field erro       as char.

DEFINE DATASET dsResult FOR tt-resultado.

define dataset pedidos serialize-name 'integracao' for tt-pedido, tt-produto
    data-relation for tt-pedido, tt-produto
relation-fields(tt-pedido.cod-pedido, tt-produto.cod-pedido) nested.

def var i-aux as int initial 0 no-undo.

Define Variable lo-arquivo   As Longchar  No-undo.
Define Variable ch-arquivo   As Character No-undo.
define variable c-json       as character no-undo.
define variable i-cod-pedido as integer   no-undo.
DEFine VARiable lc-jsonBody  AS LONGCHAR  NO-UNDO.
DEFINE VARIABLE vhSocket     AS HANDLE    NO-UNDO. 
DEFINE VARIABLE de-tamanho   AS DECIMAL   NO-UNDO.

OUTPUT TO VALUE("/admcom/logs/portal/intPed-" + replace(string(today),"/","-") + "-" + STRING(TIME, "HH:MM:SS") + ".log") APPEND.

CREATE SOCKET vhSocket.
vhSocket:CONNECT('-H ' + vcHost + ' -S ' + vcPort) NO-ERROR.

IF vhSocket:CONNECTED() = FALSE THEN DO:

    MESSAGE "Connection failure" VIEW-AS ALERT-BOX.
        
    MESSAGE ERROR-STATUS:GET-MESSAGE(1) VIEW-AS ALERT-BOX.
    RETURN.
END.
                       
vhSocket:SET-READ-RESPONSE-PROCEDURE('getResponse').

assign c-json = '~{ ~"buscarPedidos~" : ~{~} ~}'.

RUN PostRequest (INPUT 'produtos/integracaoPedidos', 
                 input c-json).
            
WAIT-FOR READ-RESPONSE OF vhSocket. 

if i-aux > 0 then do:

    vhSocket:SET-READ-RESPONSE-PROCEDURE('response').

    DATASET dsResult:WRITE-JSON("LONGCHAR", lc-jsonBody).

    RUN PostRequest (INPUT 'produtos/marcarIntegrados',
                     input lc-jsonBody).

    WAIT-FOR READ-RESPONSE OF vhSocket.

end.

vhSocket:DISCONNECT() NO-ERROR.
DELETE OBJECT vhSocket.

run logger("Integração finalizada.").

procedure response:

    run logger("Pedidos devolvidos para portal.").

end procedure.

procedure logger:

    def input param log as char no-undo.

    put unformatted "[" + STRING(TIME, "HH:MM:SS") + "] ".
    put unformatted log skip.

end.
             
PROCEDURE getResponse:
    DEFINE VARIABLE vcWebResp    AS LONGCHAR         NO-UNDO.
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    define variable i-delay      as integer          no-undo.
    /* variavel utilizada por causa do delay do socket, nao retirar */
    
    IF vhSocket:CONNECTED() = FALSE THEN do:
        run logger('Not Connected').
        RETURN.
    END.
    
    lSucess = TRUE.
                                    
    DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:                              
        SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
        vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
        vcWebResp = vcWebResp + GET-STRING(mResponse,1).
        
        Status Default  "processando...".
                
        assign i-delay = 0.
        
        do i-delay = 1 to 500:
            i-delay = i-delay + 1.
        end.
    END.
           
    If Num-entries(vcWebResp,"~{") >= 1 Then 
	Assign vcWebResp = Substring(vcWebResp,Index(vcWebResp,"~{",1),(Length(vcWebResp)))  no-error.
    Else 
	run logger("N�o retornou nada").
    
    dataset pedidos:read-json("longchar", vcwebresp,"empty").
          
    run atualiza-pedido.
END.
   
PROCEDURE PostRequest:
    DEFINE VARIABLE vcRequest      AS Longchar.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE INPUT PARAMETER postData AS Longchar.
    
    vcRequest =
              'POST /' +
              postUrl +
              ' HTTP/1.1~r~n' +
              ' HOST: ' + vchost + ':' + vcport + '~r~n' +
              'Content-Type: application/json~r~n' +
              'Content-Length: ' + string(LENGTH(postData)) +
              '~r~n' + '~r~n' +
              postData.

    SET-SIZE(mRequest)            = 0.
    SET-SIZE(mRequest)            = LENGTH(vcRequest) + 1.
    SET-BYTE-ORDER(mRequest)      = BIG-ENDIAN.
    PUT-STRING(mRequest,1)        = vcRequest .
         
    vhSocket:WRITE(mRequest, 1, LENGTH(vcRequest)).

END PROCEDURE.


procedure atualiza-pedido:

run logger("Inciando integração.").

for each tt-pedido no-lock:
    assign i-aux = i-aux + 1.
end.

run logger(string(i-aux) + " pedidos recebidos.").

for each tt-pedido no-lock:

    find first pedid
         where pedid.etbcod = tt-pedido.cod-estab
           and pedid.pedtdc = 1
           and pedid.pednum = tt-pedido.cod-pedido
               exclusive-lock no-error.

    if not avail pedid then do:
        
	run logger("Cadastrar " + string(tt-pedido.cod-pedido) + ".").

        find first forne
             where forne.forcod = tt-pedido.cod-fornec
                   no-lock no-error.
                            
        create pedid.
        assign pedid.pedtdc    = 1
               pedid.pednum    = tt-pedido.cod-pedido
               pedid.peddat    = date(substring(tt-pedido.dt-pedido,1,10))
               pedid.etbcod    = tt-pedido.cod-estab
               pedid.clfcod    = tt-pedido.cod-fornec
               pedid.peddti    = date(substring(tt-pedido.dt-entrega-ini,1,10))
               pedid.peddtf    = date(substring(tt-pedido.dt-entrega-fim,1,10))
               pedid.crecod    = tt-pedido.cod-prazo-pagto
               pedid.comcod    = tt-pedido.cod-comprador
               /*pedid.condes  = decimal(tt-pedido.frete)*/
               pedid.nfdes     = tt-pedido.desconto-nota
               pedid.dupdes    = 0
               pedid.pedobs[1] = (string(tt-pedido.cod-pedido) +  '| Desc. Dupl: ' + string(tt-pedido.desconto-dupl) + '%')
               pedid.pedobs[2] = substring(tt-pedido.observacoes,1,50)
               pedid.pedobs[3] = substring(tt-pedido.observacoes,51,100)
               pedid.sitped    = "A"
               pedid.regcod    = tt-pedido.cod-estab
               pedid.vencod    = forne.repcod
	       pedid.pedsit    = yes.
    end.
    else do:

	run logger("Alterar " + string(tt-pedido.cod-pedido) + ".").

        find first forne
             where forne.forcod = tt-pedido.cod-fornec
                   no-lock no-error.
                  
        assign pedid.clfcod    = tt-pedido.cod-fornec
               pedid.peddti    = date(substring(tt-pedido.dt-entrega-ini,1,10))
               pedid.peddtf    = date(substring(tt-pedido.dt-entrega-fim,1,10))
               pedid.crecod    = tt-pedido.cod-prazo-pagto
               pedid.comcod    = tt-pedido.cod-comprador
               /*pedid.condes  = decimal(tt-pedido.frete)*/
               pedid.nfdes     = tt-pedido.desconto-nota
               pedid.dupdes    = 0
               pedid.vencod    = forne.repcod
               pedid.regcod    = tt-pedido.cod-estab
	       pedid.pedsit    = yes.
    end.
    
    for each tt-produto
       where tt-produto.cod-pedido = tt-pedido.cod-pedido no-lock:

        if not can-find (first liped
                         where liped.etbcod = tt-pedido.cod-estab
                           and liped.pedtdc = 1
                           and liped.pednum = tt-pedido.cod-pedido
                           and liped.procod = tt-produto.cod-produto) then do:
	    
	    run logger("Cadastrar linha pedido " + string(tt-produto.cod-produto) + ".").	

            create liped.
            assign liped.etbcod   = tt-pedido.cod-estab
                   liped.pedtdc   = 1
                   liped.pednum   = tt-pedido.cod-pedido
                   liped.procod   = tt-produto.cod-produto
                   liped.predt    = today
                   liped.lipqtd   = tt-produto.qtd-produto
                   liped.lippreco = tt-produto.preco-custo.
        end.
        else do:
            find first liped
                 where liped.etbcod = tt-pedido.cod-estab
                   and liped.pedtdc = 1
                   and liped.pednum = tt-pedido.cod-pedido
                   and liped.procod = tt-produto.cod-produto
                       exclusive-lock no-error.

	    run logger("Alterar linha pedido " + string(tt-produto.cod-produto) + ".").	

            if avail liped then do:
                assign liped.lipqtd   = tt-produto.qtd-produto
                       liped.lippreco = tt-produto.preco-custo.                
            end.
        end.
    end.
end.

for each tt-pedido no-lock:

    if not can-find(first pedid where pedid.pednum = tt-pedido.cod-pedido) then do:
	run logger("Pedido " + string(tt-pedido.cod-pedido) + " não cadastrado.").
    end.
    else do:
	
	for each tt-produto where tt-produto.cod-pedido = tt-pedido.cod-pedido no-lock:
	
	    if not can-find(first liped where liped.pednum = tt-pedido.cod-pedido
					  and liped.procod = tt-produto.cod-produto) then do:

	        run logger("Linha pedido " + string(tt-produto.cod-produto) + " (" + string(tt-pedido.cod-pedido) + ") " + "não cadastrada.").

	    end.

	end.

    end.

end.

end procedure.

OUTPUT CLOSE.
