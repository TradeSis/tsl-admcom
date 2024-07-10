/* Projeto: out/17 - Garantia e RFQ */

{admcab.i}

def var varquivo  as char format "x(45)".
def var vlidos    as int.
def var valterado as int.
def var vct       as int.
def var vprodncad as int.
def var vtempogar as int.
def temp-table tt-produ no-undo
    field procod as int
    field pronom as char
    field tempo  as int.

do on error undo with frame f-importa side-label centered.
    disp
        "Importar tempo de garantia dos produtos" skip
        "Layout (format CSV): Codigo Produto;Nome Produto;Tempo Garantia".
    update varquivo label "Arquivo".
end.
empty temp-table tt-produ.
input from value(varquivo).
repeat.
    create tt-produ.
    import delimiter ";" tt-produ.
    if tt-produ.procod > 0
    then do.
        vlidos = vlidos + 1.
        find produ where produ.procod = tt-produ.procod no-lock no-error.
        if not avail produ
        then do.
            vprodncad = vprodncad + 1.
            next.
        end.
        vtempogar = int(tt-produ.tempo) no-error.
        if vtempogar = ?
        then vtempogar = 0.
        find first produaux where produaux.procod     = tt-produ.procod
                              and produaux.Nome_Campo = "TempoGar"
                            no-error.
        if vtempogar = 0 and
           (not avail produaux) /* nao importar zerado */
        then next.

        if not avail produaux
        then do.
            create produaux.
            assign
                produaux.procod      = tt-produ.procod
                produaux.Nome_Campo  = "TempoGar".
        end.
        if produaux.valor_Campo <> string(vtempogar)
        then assign
                produaux.valor_Campo = string(tt-produ.tempo)
                produaux.exportar    = yes
                produaux.datexp      = today
                valterado = valterado + 1.
        vct = vct + 1.
    end.
end.
input close.
message "Arquivo processado: Lidos=" vlidos
        " Importados=" vct
        " Alterados=" valterado
        " Produto nao cadastrados=" vprodncad
        view-as alert-box.

