{admcab.i new}

def input parameter par-rec as recid.
def output parameter par-ok        as log init yes.

def var vmetodo as char.
def var vxml    as char.

def new shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

find A01_infnfe where recid(A01_infnfe) = par-rec no-error.

def var vemite-cnpj as char.

find estab where estab.etbcod = A01_infnfe.etbcod no-lock.
assign vemite-cnpj = estab.etbcgc.
assign vemite-cnpj = replace(vemite-cnpj,".","").
       vemite-cnpj = replace(vemite-cnpj,"/","").
       vemite-cnpj = replace(vemite-cnpj,"-","").

vmetodo = "/notamax/services/wsNotamax.asmx/NFeEmissaoConsultarSituacao".
vxml =
"envNotamax=<?xml version='1.0'?><envNotamax>
<login>
<usuario>publico</usuario>
<senha>senha</senha>
</login>
<parametros>
<ide>
<emit_cnpj>" + vemite-cnpj + "</emit_cnpj>
<serie>" + A01_infnfe.serie + "</serie>
<nNf>" + string(A01_infnfe.numero) + "</nNf>
</ide>
</parametros>
</envNotamax>"
.
def var vb as memptr.
set-size(vb) = 20001.
 
def var varqlog as char.
varqlog = "/admcom/relat/log-consulta-situacao-nfe-" +
            string(time) + ".log".

def var varqretorno as char.
varqretorno = "/admcom/relat/retorno_consultar_sitaucao_nfe_"
                + string(time) + ".xml".

def var p-conecta as log.                                
def var vretorno as char.
run /admcom/custom/Claudir/client_socket_notamax.p(
                    input "10.2.0.121",
                    input "80",
                    input vmetodo,
                    input vxml,
 /*Content-Type*/   input "application/x-www-form-urlencoded",
                    input varqlog,
                    input varqretorno,
                    output p-conecta,
                    output vretorno).

def var vchave as char.
def var vstatus as int.
def var vamb as int.
def var desc_status as char. 
if p-conecta
then do:
    run processa_retorno.
    for each tt-xmlretorno where tt-xmlretorno.root = "dados":
        if tt-xmlretorno.tag = "chave_nfe"
        then vchave = tt-xmlretorno.valor.
        if tt-xmlretorno.tag = "status_nfe_notamax"
        then vstatus = int(tt-xmlretorno.valor).
        if tt-xmlretorno.tag = "tipo_emissao"
        then vamb = int(tt-xmlretorno.valor).
        if tt-xmlretorno.tag = "desc_status_nfe_nota"
        then desc_status = tt-xmlretorno.valor.
    end.    

    run trata-retorno-nfe.p (input varqretorno,
                             input recid(A01_InfNFe),
                             input vstatus,
                             input desc_status,
                             input vamb,
                             output vmsg-retorno).
                             
    message vmsg-retorno view-as alert-box. 

end.

procedure processa_retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.

    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").

    put-string(vb, 1) = vretorno.

    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). 
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 
      
    run obtemnode ("", input hroot).

end procedure.


procedure obtemnode.

    def input parameter p-root  as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.
    
    create x-noderef hc.
    do loop = 1 to vh:num-children: 
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
