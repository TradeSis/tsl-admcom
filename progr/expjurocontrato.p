def var vcontratocsv as char init "/admcom/tmp/contrato.csv" format "x(60)" label "Contratos".
def var vsaidacsv    as char init "/admcom/tmp/planilha.csv" format "x(60)" label " Planilha".
def var vcontnum like contrato.contnum.
def temp-table ttcont no-undo
    field etbcod    like contrato.etbcod
    field contnum   like contrato.contnum
    field biss      like plani.biss
    field platot    like plani.platot
    index idx is unique primary etbcod asc contnum asc.
    
update vcontratocsv skip
       vsaidacsv
    with frame f1 row 3 width 80 side-labels.
if search(vcontratocsv) = ?
then do:
    message "Arquivo " vcontratocsv "nao Encontrado"
        view-as alert-box.
    return.
end.    
input from value(vcontratocsv).
repeat.
    import vcontnum.
    find contrato where contrato.contnum = vcontnum no-lock no-error.
    
    create ttcont.
    ttcont.contnum = vcontnum.
    ttcont.etbcod  = if avail contrato then contrato.etbcod else 0.

    if avail contrato
    then do:
        find contnf where 
                contnf.etbcod  = contrato.etbcod and
                contnf.contnum = contrato.contnum 
                no-lock no-error.
        if avail contnf
        then do:
            find plani where plani.etbcod = contrato.etbcod  and
                             plani.placod = contnf.placod
                             no-lock no-error.
            if avail plani
            then do:
                ttcont.biss     = plani.biss.
                ttcont.platot   = plani.platot.
            end.
        end.
    end.
end.
input close.

output to value(vsaidacsv).
    put unformatted
        "LOJA"  ";"
        "CONTRATO" ";"
        "VALOR NOTA FISCAL"    ";"
        "VALOR COM ACRESCIMO"   ";"
        
        skip.

for each ttcont.
    put unformatted
        ttcont.etbcod  ";"
        ttcont.contnum ";"
        replace(trim(string(ttcont.platot,">>>>>>>>>>>>9.99")),".",",")    ";"
        replace(trim(string(ttcont.biss,">>>>>>>>>>>>9.99")),".",",")    ";"
        
        skip.
end.
output close.
message "Arquivo" vsaidacsv "Gerado"
    view-as alert-box.
                                         
                 

