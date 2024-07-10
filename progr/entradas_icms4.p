{admcab.i}
def var vdti as date.
def var vdtf as date.

def var vpronom like produ.pronom. 
def var vcnpjemi as char.
def var vcnpjdes as char.
def var varquivo as char.


update vdti label "Periodo" format "99/99/9999"
       vdtf no-label format "99/99/9999"
       with frame f1 width 80 side-label.

if vdti > vdtf then undo.
       

varquivo = "/admcom/relat/Entradas_ICMS4_" + 
            string(vdti,"99999999") + "_" +
            string(vdtf,"99999999") + ".csv" .

output to value(varquivo).

put "CNPJ Emitente;;CNPJ Destino;;Numero;Serie;Emissao;Recebimento;Codigo Produto Destino;Descricao Produto Destino;CFOP;Aliquota ICMS;Origem;CST;Total Nota;Total Produtos;Total Item;Chave"
skip.

for each estab no-lock:
    for each movim where movim.movtdc = 4 and
                         movim.etbcod = estab.etbcod and
                         movim.movdat >= vdti and
                         movim.movdat <= vdtf and
                         movim.movalicms = 4
                         no-lock:
        find produ where produ.procod = movim.procod no-lock no-error.
        if not avail produ
        then do:
            find first prodnewfree where
                       prodnewfree.procod = movim.procod no-lock no-error.
            if avail prodnewfree
            then vpronom = prodnewfree.pronom.
        end.               
        else vpronom = produ.pronom.
        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               movim.movtdc = plani.movtdc
                               no-lock.
        find first forne where forne.forcod = plani.emite no-lock.

        vcnpjemi = replace(forne.forcgc,".","").
        vcnpjemi = replace(vcnpjemi,"/","").
        vcnpjemi = replace(vcnpjemi,"-","").
        vcnpjdes = replace(estab.etbcgc,".","").
        vcnpjdes = replace(vcnpjdes,"/","").
        vcnpjdes = replace(vcnpjdes,"-","").

        put unformatted 
             vcnpjemi format "x(16)"
             ";"
             forne.fornom 
             ";"
             vcnpjdes format "x(16)"
             ";"
             estab.etbnom
             ";"
             plani.numero format ">>>>>>>>9"
             ";"
             plani.serie
             ";"
             plani.pladat
             ";"
             plani.dtinclu
             ";"
             movim.procod
             ";"
             vpronom
             ";"
             if movim.opfcod > 0
             then movim.opfcod else plani.opccod
             ";"
             movim.movalicms   format ">>>>>>>9.99"
             ";"
             substr(trim(movim.movcsticms),1,1)
             ";"
             substr(trim(movim.movcsticms),2,2)
             ";"
             plani.platot  format ">>>>>>>9.99"
             ";"
             plani.protot  format ">>>>>>>9.99"
             ";"
             movim.movpc * movim.movqtm format ">>>>>>>9.99"
             ";"
             plani.ufdes format "x(45)"
             skip.
              
    end.
end.
output close.                                  

message color red/with
    "Arquivo gerado" skip
    varquivo
    view-as alert-box.

    
