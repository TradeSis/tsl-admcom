/* helio 11/08/2021 */
{admcab.i}

def temp-table tt-result
    field Nome_Cliente as char
    field Numero_Contrato as int
    field Valor_contrato as dec
    field Valor_Aberto as dec
    field Data_Operacao as date
    field Vencimento_Final as date
    field Ultitmo_Pagamento as date
    field Tipo_Carteira as char
    field Contrato_Banco as int
    index i1 Nome_Cliente
     .
     
def var vdata as date.

form vdti as date format "99/99/9999"
        label "Periodo de"
     vdtf as date format "99/99/9999"
     label "Ate"
     with frame f-par 1 down width 80 side-label.
     
update vdti vdtf with frame f-par.

form "Processando..." with frame f-br
1 down centered row 10 no-label width 80 no-box color message.

do vdata = vdti to vdtf:
    disp vdata with frame f-br.
    pause 0.
    for each estab no-lock:
        disp estab.etbcod with frame f-br.
        pause 0.
        for each contrato where 
                 contrato.etbcod = estab.etbcod and
                 contrato.dtinicial = vdata
                 no-lock:
            find clien where clien.clicod = contrato.clicod no-lock.
            create tt-result.
            assign
                Nome_Cliente = clien.clinom
                Numero_Contrato = contrato.contnum
                Valor_contrato  = contrato.vltotal
                Data_Operacao   = contrato.dtinicial
                Contrato_Banco  = contrato.banco
                .
            for each titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = contrato.modcod and /* estava fixo CRE */
                                  titulo.etbcod = contrato.etbcod and
                                  titulo.clifor = contrato.clicod and
                                  titulo.titnum = string(contrato.contnum) and
                                  titulo.titpar > 0 
                                  no-lock by titulo.titpar:
                if titulo.titsit = "LIB"
                then Valor_Aberto = Valor_Aberto + titulo.titvlcob.
                Vencimento_Final = titulo.titdtven.
                if titulo.titsit = "PAG"
                then Ultitmo_Pagamento = titulo.titdtpag.
                if Tipo_Carteira = "" and
                   titulo.cobcod = 10
                then Tipo_Carteira = "Financeira".
                else if Tipo_Carteira = ""
                    then Tipo_Carteira = "Loja" .
            end.
        end.
    end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/Venda_Contratos_" +
            string(vdti,"99999999") + "_" + string(vdtf,"99999999") + ".csv"
            .
output to value(varquivo).
put "Nome_Cliente;Numero_Contrato;Valor_contrato;Valor_Aberto;Data_Operacao;
  Vencimento_Final;Ultimo_Pagamento;Tipo_Carteira" skip.
for each tt-result:
    put unformatted
        Nome_Cliente ";"
        Numero_Contrato format ">>>>>>>>>9" ";"
        Valor_contrato ";"
        Valor_Aberto ";"
        Data_Operacao ";"
        Vencimento_Final ";"
        Ultitmo_Pagamento ";"
        Tipo_Carteira /*";"
        Contrato_Banco */
        skip.
end.
output close.

message color red/with
"Arquivo gerado" skip varquivo
view-as alert-box.
