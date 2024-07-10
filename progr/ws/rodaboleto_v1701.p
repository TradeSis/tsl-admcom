{/u/bsweb/progr/bsxml.i} 
def input parameter vacao as char.
def input parameter varquivoentrada as char.
def var xmltabela as char.

def new global shared var setbcod       as int.
def new global shared var vtime as int.

def new shared var vtiposervidor as char.
def new shared temp-table tt-estab
        field etbcod as int
        field etbnom as char.

def new shared temp-table GravaAcordoEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdContratosOrigem as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char.


def new shared temp-table ContratosOrigem
    field grupo as char
    field NumeroContrato as char.


def new shared temp-table ParcelasAcordo
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char.


def new shared temp-table GeraBoletoEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field NumeroParcela as char
    field Vencimento as char
    field Valor as char.
 

def new shared temp-table ClienteEntrada
    field codigo_cpfcnpj as char.


def new shared temp-table ClienteContratoEntrada
    field codigo_cpfcnpj as char
    field numero_contrato as char.



                                                            
def new shared temp-table Parcelas
    field codigo_cpfcnpj as char
    field numero_contrato as char 
    field seq_parcela as char
    field venc_parcela as char
    field vlr_parcela_pago as char.

def new shared temp-table GeraBoletoContratoEntrada
    field codigo_cpfcnpj as char
    field venc_boleto as char
    field vlr_boleto  as char
    field vlr_servicos as char.


def new shared temp-table ReenviaBoletosEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field nossonumero as char.
 

def new shared temp-table EfetivaPagamentoTedEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field idted as char
    field dtefetivacao as char
    field statusted as char.


def new shared temp-table AvisoPagamentoTedEntrada
    field codigo_cpfcnpj as char
    field banco as char
    field idted as char.



def new shared temp-table GravaPromessaEntrada
    field CNPJ_CPF as char
    field IDAcordo as char
    field DataAcordo as char
    field QtdContratosOrigem as char
    field VlPrincipal as char
    field VlJuros   as char
    field VlMulta   as char
    field VlHonorarios as char
    field VlEncargos as char
    field VlTotalAcordo as char
    field VlDesconto as char
    field OrigemAcordo as char.


def new shared temp-table ContratosPromessa
    field grupo as char
    field NumeroContrato as char.


def new shared temp-table ParcelasPromessa
    field NumeroParcela as char
    field Vencimento as char 
    field VlPrincipal as char
    field VlJuros as char
    field VlMulta as char
    field VlHonorarios as char
    field VlEncargos as char
    field NumeroContrato as char.




def var varqlog as char.
varqlog = "/u/bsweb/log/boleto" + string(today, "99999999") + ".log".

output to value(varqlog) append.
put unformatted skip
    today " " string(time, "hh:mm:ss")
    " acao=" vacao skip
    " arquivo=" varquivoentrada skip.
output close.



run value(vacao) (varquivoentrada).

/*helio 080317 - usando propath */


run value("ws/boleto/" + vacao + ".p"). 


procedure cybgravaacordo_v1701.
    def input parameter varquivoentrada as char.

    run ws/boleto/lexml_cybgravaacordo_v1701.p (input varquivoentrada).

end procedure.

procedure cybgravaacordo_v2001.
    def input parameter varquivoentrada as char.

    run ws/boleto/lexml_cybgravaacordo_v1701.p (input varquivoentrada).

end procedure.



procedure cybgeraboleto.
    def input parameter varquivoentrada as char.

    
    run ws/boleto/lexml_cybgeraboleto_v1701.p (input varquivoentrada).


end procedure.


procedure geraboletocontrato_v1701.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_geraboletocontrato_v1701.p (input varquivoentrada).


end procedure.

procedure consultacliente_v1701.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_consultacliente_v1701.p (input varquivoentrada).


end procedure.

procedure consultacliente_v1702.
    def input parameter varquivoentrada as char.
    run ws/boleto/lexml_consultacliente_v1701.p (input varquivoentrada).

end procedure.


procedure consultaparcelas_v1701.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_consultaparcelas_v1701.p (input varquivoentrada).


end procedure.



procedure reenviaboletos_v1701.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_reenviaboletos_v1701.p (input varquivoentrada).


end procedure.



procedure efetivapagamentoted_v1801.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_efetivapagamentoted_v1801.p (input varquivoentrada).


end procedure.


procedure avisopagamentoted_v1801.
    def input parameter varquivoentrada as char.


    run ws/boleto/lexml_avisopagamentoted_v1801.p (input varquivoentrada).


end procedure.


procedure cybgravapromessa_v2101.
    def input parameter varquivoentrada as char.

    run ws/boleto/lexml_cybgravapromessa_v2101.p (input varquivoentrada).

end procedure.




/**
procedure ConsultaCliente.
    def input parameter varquivoentrada as char.

    def var v-return-mode        as log  no-undo.

    v-return-mode = 
        TEMP-TABLE ConsultaCliente:READ-XML("FILE", 
                                  varquivoentrada , 
                                  "EMPTY", 
                                  ? /* v-schemapath*/ ,
                                  ? /*v-override-def-map*/ , 
                                  ? /*v-field-type-map*/ , 
                                  ? /*v-verify-schema-mode*/ ).
end procedure.

**/

