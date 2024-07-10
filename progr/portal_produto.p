{/admcom/progr/portal_host.i}
{/admcom/progr/portal_tabela_produto.i}

define temp-table tt-caracteristica no-undo serialize-name "caracteristicas"
    field cod-produto       as int  serialize-name "codproduto"
    field caracteristica    as char serialize-name "caracteristica"
    field subcaracteristica as char serialize-name "subCaracteristica".

define temp-table tt-mix no-undo serialize-name "listaMix"
    field cod-produto as int serialize-name   "codproduto"
    field cod-mix     as int serialize-name   "codigo"
    field ativo       as log serialize-name   "ativo"
    field estmin      as int serialize-name   "estoqueMin"
    field estmax      as int serialize-name   "estoqueMax".

define temp-table tt-estabelec no-undo serialize-name "listaEstabelecimentos"
    field cod-produto as int serialize-name   "codproduto"
    field etbcod      as int serialize-name   "etb"
    field quantidade  as dec serialize-name   "quantidade".

define temp-table tt-resultado no-undo
    field codigo     as int
    field integrado  as log initial true
    field erro       as char.

def temp-table tt-erros no-undo
    field cod-target  as int
    field err-message as char.

def dataset produtos serialize-name 'integracao' for tt-produtos, tt-mix, tt-estabelec, tt-caracteristica.

def dataset dsResult for tt-resultado.

def var lo-arquivo   as longchar no-undo.
def var ch-arquivo   as char     no-undo.
def var vhSocket     as handle   no-undo.
def var vhSocketCore as handle   no-undo.
def var de-tamanho   as dec      no-undo.
def var c-json       as char     no-undo.
def var filename     as char     no-undo.
def var hour 	     as char     no-undo.
def var timer 	     as char     no-undo.
def var lc-jsonRes   as longchar no-undo.
def var i-cont 	     as int initial 0 no-undo.     

def var l-processado as log      no-undo.

empty temp-table tt-produtos       no-error.
empty temp-table tt-caracteristica no-error.
empty temp-table tt-mix            no-error.

{/admcom/progr/portal_produto_procedures.i}

/* -------------------------------------------- MAIN --------------------------------------------- */

assign filename = string(day(today), "99") + "_" + string(month(today),"99") + "_" + string(year(today),"9999") + "_" + STRING(TIME, 'HH:MM:SS') + ".log".

output to value("/admcom/logs/portal/" + filename) append.

run logger(input "Inicianto integração produtos"). 

create socket vhSocket.
create socket vhSocketCore.

vhSocket:connect('-H ' + vcHost + ' -S ' + vcPortCore).
    
if vhSocket:connected() = false then do:

    run logger(input "Connection failure").
        
    run logger(input error-status:get-message(1)).
    return.

end.
                  
run pi-request (input 'getResponse',
                input 'products/integration-admcom/request',
                input '~{ ~"buscarProdutos~" : ~{~} ~}').

if i-cont > 0 then do:

    run logger(input string(i-cont) + ' produtos sendo enviados ao portal...').

    dataset dsResult:write-json("LONGCHAR", lc-jsonRes).

    run pi-request (input 'getResponse',
                    input 'products/integration-admcom/response',
		    input lc-jsonRes).

end.

vhSocket:disconnect() no-error.

delete object vhSocket.

run logger("Integração finalizada").

output close.

procedure atualiza-produto:

    def var lo-teste as longchar no-undo.

    dataset produtos:write-json("LONGCHAR", lo-teste).

    output to "/home/kbase/output.json".
    export lo-teste.
    output close.

    assign l-processado = true.

    for each tt-produtos no-lock:
        i-cont = i-cont + 1.
    end.

    run logger(input (string(i-cont) + " produtos recebidos")).

    run /admcom/progr/portal_valida_produto.p (output table tt-erros, input table tt-produtos).

    for each tt-produtos no-lock:
    
        for each tt-erros no-lock
            where tt-erros.cod-target = tt-produtos.cod-produto 
            break by tt-erros.cod-target:

            if first-of(tt-erros.cod-target) then do:

                create tt-resultado.
                assign tt-resultado.codigo = tt-produtos.cod-produto
                        tt-resultado.integrado = false
                        tt-resultado.erro = tt-erros.err-message.

                run logger(input (string(tt-erros.cod-target) + ": " + tt-erros.err-message)).

            end.

        end.
	
        if avail tt-resultado and not tt-resultado.integrado then next.
  
        if not can-find(first produ where produ.procod = tt-produtos.cod-produto) then do:
                    
    	    run logger(input ("Cadastrar produto " + string(tt-produtos.cod-produto))).
    
            create produ.
    
            assign produ.procod = tt-produtos.cod-produto
                   produ.itecod = tt-produtos.cod-produto.
    
        end.
        else do:
    
            run logger(input ("Atualizar produto " + string(tt-produtos.cod-produto))).
    
            find first produ exclusive-lock 
                 where produ.procod = tt-produtos.cod-produto no-error no-wait.
    
        end.

        if locked produ then do:
            run logger(input ("Produto Locked " + string(tt-produtos.cod-produto))).
            next.
        end.

	    run logger(input ("Produto Liberado " + string(tt-produtos.cod-produto))).

	    create tt-resultado.
        assign tt-resultado.codigo = tt-produtos.cod-produto.

        assign produ.proipiper      = if tt-produtos.aliquota-icm       <> ? then tt-produtos.aliquota-icm else 0
                produ.proclafis     = if tt-produtos.cod-classific-fisc <> ? then string(tt-produtos.cod-classific-fisc) else ""
                produ.codfis        = if tt-produtos.cod-classific-fisc <> ? then tt-produtos.cod-classific-fisc else 0
                produ.proindice     = if tt-produtos.cod-barras         <> ? then string(tt-produtos.cod-barras) else ""
                produ.corcod        = if tt-produtos.cod-cor 	        <> ? then string(tt-produtos.cod-cor) else ""
                produ.catcod        = if tt-produtos.cod-departamento   <> ? then tt-produtos.cod-departamento else 0
                produ.descontinuado = if tt-produtos.descontinuado      <> ? then tt-produtos.descontinuado else false
                produ.pronom        = if tt-produtos.desc-produto       <> ? then tt-produtos.desc-produto else ""
                produ.pronomc       = if tt-produtos.desc-produto-abrev <> ? then tt-produtos.desc-produto-abrev else ""
                produ.etccod        = if tt-produtos.cod-estac	        <> ? then tt-produtos.cod-estac else 0	
                produ.fabcod        = if tt-produtos.cod-fabricante     <> ? then tt-produtos.cod-fabricante else 0
                produ.opentobuy     = if tt-produtos.open-to-buy	    <> ? then tt-produtos.open-to-buy else false
                produ.prorefter     = if tt-produtos.referencia	        <> ? then tt-produtos.referencia else ""
                produ.clacod        = if tt-produtos.cod-subclasse      <> ? then tt-produtos.cod-subclasse else 0
                produ.temp-cod      = if tt-produtos.cod-temp	        <> ? then tt-produtos.cod-temp else 0
                produ.procvcom      = if tt-produtos.volume 	        <> ? then tt-produtos.volume else 1
                produ.pvp	        = if tt-produtos.preco-fornecedor   <> ? then tt-produtos.preco-fornecedor else 0
                produ.ind_vex	    = if tt-produtos.vex		        <> ? then tt-produtos.vex else false
                produ.al_icms_efet  = if tt-produtos.aliqICMSEfetivo    <> ? then tt-produtos.aliqICMSEfetivo else 0
                produ.al_fcp	    = if tt-produtos.fcp		        <> ? then tt-produtos.fcp else 0 
                produ.loteMinimo	= if tt-produtos.loteMinimo	        <> ? then tt-produtos.loteMinimo else 0
                produ.protam	    = if tt-produtos.montagem          	  then "Sim" else "Nao"
                produ.proipival	    = if tt-produtos.pedido-especial 	  then 1     else 0
                produ.prodtcad      = date(substring(tt-produtos.dt-cadastro,1,10))
                produ.datfimvida    = date(substring(tt-produtos.dt-fim-vida,1,10))
                produ.datexp        = today no-error.

        find first fabri where fabri.fabcod = produ.fabcod no-lock no-error.
    
        if avail fabri then assign produ.prozort = fabri.fabfant.
        
        if error-status:error then do:
	
	    run logger(input (string(tt-produtos.cod-produto) + ": " + error-status:get-message(1))).

            assign tt-resultado.erro = error-status:get-message(1)
                   tt-resultado.integrado = false.
            next.

        end.

        assign tt-resultado.integrado = true.

        run logger(input ("Produto Atualizado " + string(tt-produtos.cod-produto))).

        if tt-produtos.ativo = yes then
            assign produ.proseq = 0.
        else
            assign produ.proseq = 99.
    
        run atualiza-mix(input tt-produtos.cod-produto).

        run atualiza-caracteristicas(input tt-produtos.cod-produto).

        run atualiza-produto-ecommerce(input rowid(tt-produtos)).
    
        run atualiza-produto-pai(input rowid(tt-produtos)).

        run atualiza-produaux(input rowid(tt-produtos)).

        run atualiza-abasgrad(input tt-produtos.cod-produto).

        run atualiza-abasresoper(input rowid(tt-produtos)).

        if tt-produtos.preco-venda <> ? then run atualiza-estoque(input rowid(tt-produtos)).
    
    end.

end procedure.

procedure pi-request:

    def input param c-res-proc as char     no-undo.
    def input param c-url      as char     no-undo.
    def input param lc-body    as longchar no-undo.

    vhSocket:set-read-response-procedure(c-res-proc).

    RUN PostRequest (input c-url, input lc-body).

    WAIT-FOR READ-RESPONSE OF vhSocket.

end procedure.

procedure logger:

    def input param log as char no-undo.

    put unformatted "[" + STRING(TIME, "HH:MM:SS") + "] ".
    put unformatted log skip.

end.

procedure response:

    run logger(input "Produtos devolvidos para Portal").

end procedure.
             
PROCEDURE getResponse:

    DEFINE VARIABLE vcWebResp    AS longchar         NO-UNDO.  
    DEFINE VARIABLE lSucess      AS LOGICAL          NO-UNDO.
    DEFINE VARIABLE mResponse    AS MEMPTR           NO-UNDO.
    define variable i-delay      as integer          no-undo.        

    IF vhSocket:CONNECTED() = FALSE THEN do:
        run logger( input "Not Connected").
        RETURN.
    END.
    
    lSucess = TRUE.
                            
   DO WHILE vhSocket:GET-BYTES-AVAILABLE() > 0:
        SET-SIZE(mResponse) = vhSocket:GET-BYTES-AVAILABLE() + 1.
        SET-BYTE-ORDER(mResponse) = BIG-ENDIAN.
        vhSocket:READ(mResponse,1,1,vhSocket:GET-BYTES-AVAILABLE()).
        vcWebResp = vcWebResp + GET-STRING(mResponse,1).

        status default "processando...".
        
        assign i-delay = 0.
        
        do i-delay = 1 to 2000:
            i-delay = i-delay + 1.
        end.
    END.

    If Num-entries(vcWebResp,"~{") >= 1 Then 
	    Assign vcWebResp = Substring(vcWebResp,Index(vcWebResp,"~{",1),(Length(vcWebResp))).
    Else 
	    run logger(input "Não retornou nada").

    output to "/home/kbase/input.txt".
    export vcWebResp.
    output close.

    dataset produtos:read-json("longchar",vcWebResp,"empty").

    if not l-processado then
        run atualiza-produto.

END.

procedure PostRequest:
    DEFINE VARIABLE vcRequest      AS Longchar.
    DEFINE VARIABLE mRequest       AS MEMPTR.
    DEFINE INPUT PARAMETER postUrl AS CHAR. 
    DEFINE input PARAMETER postData AS Longchar.  
    
    vcRequest =
             'POST /' +
             postUrl +
             ' HTTP/1.1~r~n' +
             ' HOST: ' + vchost + ':' + vcportcore + '~r~n' +
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

