/* helio 05042023 - ajustes para quebrar arquivos */
/* 03032023 helio - Orquestra 473879 - Relató PMTs */

{admcab.i}
def var vproduto as char.
def var vtpcontrato as char.
def var vcontnum as int no-undo init ?.
def var vvliof  like contrato.vliof.
def var vvlcet  like contrato.cet.
def var vvlseguro  as dec.
def var vvltfc  like contrato.vltaxa.
def var vnro_parcela as int.

def var vdir as char init "/admcom/tmp/ctb/contratos/".    

def stream csv.
 
   def var varqin  as char format "x(65)".
    def var vcobout like cobra.cobcod label "Carteira".
   def var vcp  as char init ";".
    pause 0.
    

    run get_file.p (vdir,"csv",output varqin).
    
        
if search(varqin) = ?
then do:
    message "arquivos nao encontratos em" vdir.
    pause.
    return.
end.    
def var varq as char.
def var varqsai as char format "x(65)" .
 
varq = entry(1,varqin,".") + "_RESULTADO_" + string(today,"999999") + ".csv".

varqsai = varq.

    disp skip(2) varqin  label "Entrada" colon 10
            skip(2) 
         varqsai label "Saida"   colon 10 
                   with frame fx
        centered 
        overlay
        side-labels
        color messages
        row 4
        with title "ARQUIVO CSV COM LISTA DE  CONTRATOS".


message "Confirma geração de arquivo?" update sresp.
if not sresp then return.



def var vlinha as char.
def var q-linha as int.
def var vproblema as log.
vproblema = no.
def var vexparquivo as int.
def var vexportados as int.
vexparquivo = 0.
vexportados = 0.

input from value(varqin).
repeat transaction:
    q-linha = q-linha + 1.
    import unformatted vlinha.


    if q-linha >= 1
    then do:
        vcontnum =  int(entry(1,vlinha,";")) no-error.
        if vcontnum <> ? and vcontnum <> 0 
        then do:
            find contrato where contrato.contnum = vcontnum no-lock no-error.
            if not avail contrato then next.
            find clien where clien.clicod = contrato.clicod no-lock no-error.
                         
            vnro_parcela = contrato.nro_parcela.
            if vnro_parcela = 0
            then do:
                for each  titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titdtemi = contrato.dtinicial
                        no-lock.
                        vnro_parcela = vnro_parcela + 1.    
                end.                        
            end.
            if contrato.vliof > 0
            then vvliof = contrato.vliof / vnro_parcela.
            if contrato.cet > 0
            then vvlcet = contrato.cet / vnro_parcela.
            if contrato.vlseguro > 0 
            then vvlseguro = contrato.vlseguro / vnro_parcela.  
            if contrato.vltaxa > 0
            then vvltfc = contrato.vltaxa / vnro_parcela. 
            
            vtpcontrato = contrato.tpcontrato           .
            find ctbpostitprod where ctbpostitprod.contnum = vcontnum no-lock no-error.
            if avail ctbpostitprod
            then vproduto = ctbpostitprod.produto.
            else run pegaproduto (vcontnum).

            for each  titulo where
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.modcod = contrato.modcod and
                        titulo.titnum = string(contrato.contnum) 
                        no-lock.
                if titulo.titsit = "LIB" or titulo.titsit = "PAG" 
                then. 
                else next.
                
                find cobra of titulo no-lock.
                vexportados = vexportados + 1.
                
                if vexportados = 1
                then do:
                    
                    vexparquivo = vexparquivo + 1.    
                    varqsai = entry(1,varqin,".") + "_RESULTADO_" + string(today,"999999") + "_" + string(vexparquivo) + ".csv".
                
                    output stream csv to value(varqsai).
                    put stream csv unformatted
                    "Base;"   
                    "Codigo do Cliente;"  
                    "CPF;"    
                    "Nome do cliente;" 
                    "Contrato;"    
                    "Parcela;" 
                    "Emissao;" 
                    "Pagamento;"   
                    "Moeda;"   
                    "Valor Nominal;"   
                    "Carteira;"    
                    "Modalidade;"  
                    "Tp;"  
                    "Filial;"
                    "Produto;"   
                    "Vencimento;"  
                    "Principal;"    
                    "Acrescimo;"    
                    "Seguro;"  
                    "IOF;"
                    skip.
                end.
                
                put stream csv unformatted
                    "1;"
                    contrato.clicod  ";"
                    (if avail clien then clien.ciccgc else "") ";"
                    (if avail clien then clien.clinom else "") ";"
                    contrato.contnum ";"
                    titulo.titpar ";"
                    string(contrato.dtinicial,"99/99/9999") ";"
                    if titulo.titdtpag = ? then "" else string(titulo.titdtpag,"99/99/9999") ";"
                    titulo.moecod ";"
                    trim(string(titulo.titvlcob,"->>>>>>>>>>>>9.99")) ";"
                    cobra.cobnom ";"
                    contrato.modcod ";"
                    titulo.tpcontrato ";"
                    contrato.etbcod ";"
                    vproduto ";"
                    string(titulo.titdtven,"99/99/9999") ";"
                    trim(string(titulo.vlf_principal,"->>>>>>>>>>>>9.99")) ";"
                    trim(string(vvlseguro,"->>>>>>>>>>>>9.99"))  ";"
                    trim(string(vvliof,"->>>>>>>>>>>>9.99")) ";"
                    skip .
            end.                
            if vexportados > 1000000
            then do:
                output stream csv close.
                vexportados = 0.
            end.    
        end.    
    end.          
    vcontnum = ?.               
end.
input close.
output stream csv close.
 
message "arquivo" varq "gerado".
pause 10.
return.




procedure pegaproduto.
    def input param pcontnum as int.

    find ctbpostitprod where ctbpostitprod.contnum = pcontnum no-lock no-error.
    if avail ctbpostitprod
    then do:
        vproduto = ctbpostitprod.produto.
        return.
    end.
    if vtpcontrato <> ""
    then do:
        vproduto =  if vtpcontrato = "F"
                    then "FEIRAO "
                    else if vtpcontrato = "N"
                         then "NOVACAO"
                         else if vtpcontrato = "L"
                              then "LP     "
                              else "".
        if vproduto <> ""
        then return.   
    end.    
    vproduto = "DESCONHECIDO".
    def var vcatcod as int.        
    find contrato where contrato.contnum = vcontnum no-lock no-error.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = vcontnum no-lock no-error.
        if avail contrsite
        then do:
            vproduto = "Cre Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                vproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    vproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if vproduto = "DESCONHECIDO"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-lock no-error.
                            if avail categoria
                            then do:
                                vproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = vcontnum.
        ctbpostitprod.produto = vproduto.
    end.    
    
end procedure.    

