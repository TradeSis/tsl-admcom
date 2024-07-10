{admcab.i}

def var vtoday as date format "99/99/9999" label "dia".
vtoday = today.
update vtoday with row 3 side-labels no-box.
for each titprotremessa where titprotremessa.dtinc = vtoday no-lock.
    disp titprotremessa
        with centered no-box.
    for each titprotremlog of titprotremessa no-lock.
        disp titprotremlog.cidcod
             titprotremlog.codocorrencia.
        disp ocorrencia
            format "x(80)"
        with no-box width 81.            

    end.
end.