{admcab.i}
def input parameter par-rec as recid.
def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.

find clien where recid(clien) = par-rec no-lock.

    {mdadmcab.i
        &Saida     = "/tmp/rel"
        &Page-Size = "60"
        &Page-Line = "66"
        &Cond-Var  = "110"
        &Width     = "110"
        &Nom-Rel   = ""EXTRATO""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   =
           """PARCELAS EM ABERTO DO CLIENTE "" +
                        string(clien.clicod) + ""  "" +
                               clien.clinom "
        &Form      = "frame f-cabcab"}

display skip(1)
        clien.endereco[1] colon 15 label "Endereco"
        clien.numero  [1] colon 55 label "Num."
        clien.compl   [1] colon 15 label "Compl."
        clien.bairro  [1] colon 55  label "Bairro"
        clien.cidade  [1] colon 15  label "Cidade"
        clien.ufecod  [1] colon 55  label "UF"
        clien.fone        colon 15  when clien.fone <> ? skip(2)
        with frame f1 centered no-box side-label width 100.


for each titulo use-index iclicod where
                titulo.clifor     = clien.clicod and
                titulo.titnat     = no           no-lock by titulo.titdtven
                                                         by titulo.titnum
                                                         by titulo.titpar.
    if titulo.titsit = "PAG"
    then next.
    vtotal = 0.
    vjuro = 0.
    vdias = 0.

    if titulo.titdtven < today
    then do:
        find tabjur where tabjur.nrdias = today - titulo.titdtven
                         no-lock no-error.
        if  not avail tabjur
        then do:
            message "Fator para" today - titulo.titdtven
                    "dias de atraso, nao cadastrado".
            pause.
            undo.
        end.
        assign vjuro  = (titulo.titvlcob * tabjur.fator) - titulo.titvlcob
               vtotal = titulo.titvlcob + vjuro
               vdias  = today - titulo.titdtven.
    end.
    else vtotal = titulo.titvlcob.
    vacum = vacum + vtotal.
    display titulo.etbcod
            titulo.titnum
            titulo.titpar
            titulo.titdtven format "99/99/9999"
            vdias           when vdias > 0 column-label "Atraso"
            titulo.titvlcob column-label "Principal "   (total)
            vjuro           column-label "Juro"         (total)
            vtotal          column-label "Total"        (total)
            space(3)
            vacum           column-label "Acumulador"
            with frame flin down width 130 no-box.
end.
lpr &Saida.
