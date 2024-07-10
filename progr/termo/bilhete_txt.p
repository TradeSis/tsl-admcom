def input param vrec as recid.
def new global shared var setbcod as int.
def new global shared var sremoto as log.

def var vlinha as char format "x(150)".

def var varquivo-entrada    as char.
def var varquivo-saida      as char.
def var vpdf-saida          as char.
def var vdir-saida          as char.
def var vpdf                as char.
def stream entrada.
def stream saida.
def buffer bprodu for produ.

find first vndseguro where recid(vndseguro) = vrec no-lock.
find clien of vndseguro no-lock. 
find produ of vndseguro no-lock. 
find estab of vndseguro no-lock.
find segtipo    of vndseguro no-lock.

/* Produto garantido */
find movim where movim.etbcod = vndseguro.etbcod and movim.placod = vndseguro.placod and movim.movseq = vndseguro.movseq no-lock.
find bprodu of movim no-lock.
find fabri of bprodu no-lock no-error.

def var vnome as char. 
vnome = trim(clien.ciccgc) + "_" + string(vndseguro.etbcod,"999") + "_" +
        string(vndseguro.pladat,"99999999") + "_" + trim(vndseguro.certifi) .
        
if segtipo.TpSeguro = 6 /* RFQ */
then do:

    varquivo-entrada = "../progr/termo/Bilhete_RFQ.txt".
    varquivo-saida   = "bilhete_rfq_" + vnome + ".txt".
    vpdf-saida       = "bilhete_rfq_" + vnome + ".pdf".
end.    
if segtipo.TpSeguro = 5 /* GE */
then do:
    varquivo-entrada = "../progr/termo/Bilhete_GE.txt".
    varquivo-saida   = "bilhete_ge_" + vnome + ".txt".
    vpdf-saida       = "bilhete_ge_" + vnome + ".pdf".
end.    

/* 555859 - Duas Garantias em produtos iguais PRÉ VENDA - Pedido Erica if setbcod = 999
then do:
    vdir-saida       = "/admcom/relat/".
end.
else do:*/
    vdir-saida  = "/admcom/relat-loja/filial" + string(vndseguro.etbcod,"999") + "/seguro/". /* helio 28/02/2024 - pedido Erica */
/*end.*/
    


output stream saida  to   value(vdir-saida + varquivo-saida).
input stream entrada from value(varquivo-entrada).
repeat.
    import stream entrada unformatted vlinha.

    /* IOF POR COBERTURA: R$ #VALOR_IOF_GE# (ele é 7,38% do valor prêmio total a ser pago) */
    def var vVALOR_IOF_GE as dec.
    vVALOR_IOF_GE = vndseguro.PrSeguro * (7.38 / 100).

    vlinha = replace(vlinha,"#SAFE_CERTIFICADO#",vndseguro.Certifi).
    vlinha = replace(vlinha,"#DT_EMISSAO#",string(vndseguro.Pladat,"99/99/9999")).
    vlinha = replace(vlinha,"#CLIENTE_NOME#",clien.clinom).
    vlinha = replace(vlinha,"#NOME_CLIENTE#",clien.clinom).

    vlinha = replace(vlinha,"#CLIENTE_CPF_CNPJ#",   clien.ciccgc).
    vlinha = replace(vlinha,"#CLIENTE_ENDERECO#",   clien.endereco[1]).
    vlinha = replace(vlinha,"#CLIENTE_END_NR#",     string(clien.numero[1])).
    vlinha = replace(vlinha,"#CLIENTE_CIDADE#",     clien.cidade[1]).
    vlinha = replace(vlinha,"#CLIENTE_UF#",         clien.ufecod[1]).
    vlinha = replace(vlinha,"#CLIENTE_CEP#",        string(clien.cep[1])).
    vlinha = replace(vlinha,"#PRODUTO#",            produ.pronom).
    vlinha = replace(vlinha,"#PRODUTO_FORNECEDOR#", if avail fabri then fabri.fabfant else string(produ.fabcod) ).
    vlinha = replace(vlinha,"#VALOR_BASE_PRODUTO#", trim(string(movim.movpc,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#PREMIO_LIQUIDO_60#",  trim(string(vndseguro.PrSeguro - vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#IOF_COBERTURA_60#",    trim(string(vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#PREMIO_BRUTO_COBERTURA_60#", trim(string(vndseguro.PrSeguro,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#PREMIO_LIQUIDO_36#",  trim(string(vndseguro.PrSeguro - vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#IOF_COBERTURA_36#",    trim(string(vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#PREMIO_BRUTO_COBERTURA_36#", trim(string(vndseguro.PrSeguro,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#PREMIO_LIQUIDO#",      trim(string(vndseguro.PrSeguro - vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#VALOR_IOF_GE#",       trim(string(vVALOR_IOF_GE,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#VALOR_GE#",           trim(string(vndseguro.PrSeguro,"->>>>>>>>9.99"))).
    vlinha = replace(vlinha,"#INICIO_GARANTIA#",    string(vndseguro.DtIVig,"99/99/9999")).
    vlinha = replace(vlinha,"#FIM_GARANTIA#",       string(vndseguro.DtfVig,"99/99/9999")).
    vlinha = replace(vlinha,"#VALOR_COMISSAO_REPRESENTANTE_RF#",   trim(string(vndseguro.PrSeguro * 0.58,"->>>>>>>>9.99"))    ).
    vlinha = replace(vlinha,"#PERCENTUAL_COMISSAO_REPRESENTANTE_RF#",  trim(string(58,"->>>>>>>>9.99")) ).
    vlinha = replace(vlinha,"#LOJA_CIDADE#",        estab.munic).
    vlinha = replace(vlinha,"#TIPO_GARANTIA#",      segtipo.Descricao).

    vlinha = replace(vlinha,"#VALOR_PRODUTO_CUPOM#",trim(string(vndseguro.PrSeguro,"->>>>>>>>9.99"))  ).
    vlinha = replace(vlinha,"#VALOR_COMISSAO_REPRESENTANTE#",   trim(string(vndseguro.PrSeguro * 0.58,"->>>>>>>>9.99"))    ).
    vlinha = replace(vlinha,"#PERCENTUAL_COMISSAO_REPRESENTANTE#",  trim(string(58,"->>>>>>>>9.99")) ).
    vlinha = replace(vlinha,"#QT_MESES_GE#",  trim(string(vndseguro.tempo,"->>>>>>>>9")) ).

    /*
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    vlinha = replace(vlinha,"", ).
    */    
    
    if trim(vlinha) = ""
    then put    stream saida  unformatted skip(2).
    else put    stream saida  unformatted vlinha skip.
    
end.
input stream entrada close. 
output stream saida close.


 def var xremoto as log.
 xremoto = sremoto.
 sremoto = no.   
 run /admcom/progr/pdfout.p (input vdir-saida + varquivo-saida,
                  input vdir-saida,
                  input vpdf-saida,
                  input "Portrait",
                  input 8.2,
                  input 1,
                  output vpdf).
 sremoto = xremoto.   
 unix silent value("rm -f       " + vdir-saida + varquivo-saida).
 unix silent value("chmod 777   " + vdir-saida + vpdf).
 
message "arquivo gerado em " skip vdir-saida skip vpdf
    view-as alert-box.
    
