{admcab.i}

def var vaudit as char format "x(6)".

repeat.
    update vaudit label "Auditoria" with frame f-audit side-label.

    for each asstec_aux where asstec_aux.nome_campo = "Auditoria" no-lock.
        if acha("Codigo", asstec_aux.valor_campo) = vaudit
        then do.
            find asstec of asstec_aux no-lock.
            find produ of asstec no-lock.
            disp
                asstec.oscod
                asstec.procod
                produ.pronom format "x(40)"
                asstec.datexp column-label "Inclusao"
                with frame f-os down.
        end.
    end.
end.
    
