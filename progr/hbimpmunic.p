def temp-table tt-munic no-undo
    field ufecod    as char format "X(02)"
    field cidcod    as int format ">>>>>>>9"
    field cidnom    as char format "x(40)".
    
def var vimp as int.
def var vnov as int.
 
pause 0 before-hide.
def var varq as char format "x(50)" init "/admcom/tmp/lista-municipios_atualizado_h.csv".
update varq.

input from value(varq).
repeat transaction.
    vimp = vimp + 1.
    create tt-munic.
    import delimiter ";" tt-munic.
    disp tt-munic.
    
    find munic where munic.cidcod = tt-munic.cidcod exclusive no-error.
    if not avail munic
    then do:
        create munic.
        munic.cidcod = tt-munic.cidcod.
        vnov = vnov + 1.
    end.    
    munic.cidnom = tt-munic.cidnom.
    munic.ufecod = tt-munic.ufecod.
    
    delete tt-munic.
    disp vimp vnov.
end.
input close.

message "FEITO" "IMPORTADO" vimp "CRIADOS" vnov .