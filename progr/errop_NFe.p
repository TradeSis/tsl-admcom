def input parameter p-chave as char.
def var varquivo as char format "x(70)".
def var varqsai as char format "x(70)".
def var varqlog as char format "x(70)".
def var varq as char format "x(70)".
varqlog = "/admcom/nfe/erp/arq.log".
def var vret as char format "x(14)".
def var v-cstat as char.
def var v-chnfe as char.
def var v-xmotivo as char.

def var vlinha as char extent 40.
def var p-valor as char.
def var arq_erro as char.
def var tp-arq as char.


find A01_infnfe where A01_infnfe.chave = p-chave no-lock no-error.

if avail A01_infnfe
then do:

    assign p-valor = "".
    run le_tabini.p (A01_infnfe.emite, 0,
                     "NFE - TIPO DE ARQUIVO", OUTPUT p-valor) .
                     p-valor.

    assign tp-arq = p-valor.
    
end.
                                                   
                                                   

if avail A01_infnfe and
        A01_infnfe.sitnfe > 200
then do:
    
    find tab_erros where tab_erros.codigo = A01_infnfe.sitnfe
                no-lock no-error.
    if avail tab_erros
    then do:
        message color red/with
        tab_erros.descricao
        view-as alert-box title " ERRO: " + string(tab_erros.codigo) + " ".
    end.            
end.
else if tp-arq = "XML"
then do:

    find B01_IdeNFe of A01_infnfe .

    message COLOR RED/WITH
            B01_IdeNFe.temite
            skip(1)
                "FAVOR ENTRAR EM CONTATO COM O SETOR FISCAL/CONTABIL"
                    view-as alert-box TITLE "  Erro na validacao da NF-e  ".

end.
else do:        

run le_tabini.p (A01_infnfe.emite, 0,
            "NFE - DIRETORIO ERRO ARQUIVO", OUTPUT p-valor) .
arq_erro = p-valor.

varquivo = arq_erro + p-chave + ".txt-erro.txt".
if search(varquivo) <> ?
then do:
    input from value(varquivo).
    repeat:
        import  vlinha.
    end.
    input close.
    message COLOR RED/WITH
        vlinha[1] vlinha[2] vlinha[3] vlinha[4] vlinha[5] vlinha[6] vlinha[7] 
        vlinha[8] vlinha[9] vlinha[10]
vlinha[11] vlinha[12] vlinha[13] vlinha[14] vlinha[15]
vlinha[16] vlinha[17] vlinha[18] vlinha[19] vlinha[20]
vlinha[21] vlinha[22] vlinha[23] vlinha[24] vlinha[25]
vlinha[26] vlinha[27] vlinha[28] vlinha[29] vlinha[30]
vlinha[31] vlinha[32] vlinha[33] vlinha[34] vlinha[35]
vlinha[36] vlinha[37] vlinha[38] vlinha[39] vlinha[40]
    skip(1)
    "FAVOR ENTRAR EM CONTATO COM O SETOR FISCAL/CONTABIL"
    view-as alert-box TITLE "  Erro na validacao da NF-e  ".
end.
end.    
 