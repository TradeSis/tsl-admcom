/* 26112021 helio - venda carteira - csv kpmg*/
{admcab.i}

def var vcobout like cobra.cobcod label "Carteira".
def var vmensagem as char.
def temp-table ttcontrato no-undo
    field Nome_Cliente as char
    field contnum as int
    field Valor_contrato as dec
    field Valor_Aberto as dec
    field Data_Operacao as date
    field Vencimento_Final as date
    field Ultitmo_Pagamento as date
    field Tipo_Carteira as char
    field Contrato_Banco as int
    index i1 is unique primary contnum asc.
     
def var varqin as char.

    message "Selecione arquivo csv contendo os contratos na primeira coluna para carga".
    run get_file.p ("/admcom/tmp/","csv",output varqin).
    
    disp skip(2) varqin  format "x(60)" label "Entrada" colon 10
            skip(2) 
                   with frame fx
        centered 
        overlay
        side-labels
        color messages
        row 4
        with title "ARQUIVO CSV COM LISTA DE  CONTRATOS".

if search(varqin) = ?
then do:
    message "arquivo" varqin "nao encontrado".
    pause.
    undo.
end.    

def var varqout as char.
varqout = "/admcom/relat/Venda_Contratos_" +
            string(today,"99999999") + "_" + replace(string(time,"HH:MM:SS"),":","") + ".csv" .

    vmensagem = "ARQUIVO CSV SAIDA PARA KPMG".                                                                                    
    
    disp vmensagem colon 10 no-label format "x(60)" with frame fx.                      
    hide message no-pause.
    message "informe o arquivo que sera gerado".                                                                      
    update  
            varqout format "x(60)" label "Saida"   colon 10 skip(2)
                   with frame fx.

    hide message no-pause.
    message "informa a carteira".
    update  skip(2) vcobout colon 10
        with frame fx.
    find cobra where cobra.cobcod = vcobout no-lock no-error.
    disp cobra.cobnom no-labels
        skip (2)
        with frame fx.

hide message no-pause.
message "importando arquivo" varqin.

for each ttcontrato.
    delete ttcontrato.
end.
pause 0 before-hide.
input from value(varqin).
repeat transaction on error undo , next.
    create ttcontrato.
    import delimiter ";" ttcontrato.contnum no-error.
    if ttcontrato.contnum = 0 or ttcontrato.contnum = ? or error-status:error
    then do:
        delete ttcontrato.
        next.
    end.    
end.
input close.

pause before-hide.
for each ttcontrato where ttcontrato.contnum = 0 or ttcontrato.contnum = ? . 
    delete ttcontrato.
end.

form "Processando..." with frame f-br
1 down centered row 10 no-label width 80 no-box color message.


    for each ttcontrato.
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.
            find clien where clien.clicod = contrato.clicod no-lock.
            assign
                Nome_Cliente = clien.clinom
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
                   vcobout = 10
                then Tipo_Carteira = "Financeira".
                else if Tipo_Carteira = ""
                    then Tipo_Carteira = "Loja" .
            
            
            end.
    end.

output to value(varqout).
put "Nome_Cliente;Numero_Contrato;Valor_contrato;Valor_Aberto;Data_Operacao;
  Vencimento_Final;Ultimo_Pagamento;Tipo_Carteira" skip.
for each ttcontrato:
    put unformatted
        Nome_Cliente ";"
        ttcontrato.contnum format ">>>>>>>>>9" ";"
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
hide frame fx no-pause.
hide message no-pause.
message color red/with
"Arquivo gerado" skip varqout
view-as alert-box.
