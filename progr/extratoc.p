{admcab.i}

def shared temp-table tt-contrato   like fin.contrato.
def shared temp-table tt-titulo     like fin.titulo 
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def shared temp-table tt-contnf     like fin.contnf.
def shared temp-table tt-movim      like movim.

def input parameter par-rec as recid.
def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var varquivo as char.
def var vdias   as   int.

find clien where recid(clien) = par-rec no-lock.
    
if opsys = "UNIX"
then varquivo = "/admcom/relat/lisext.txt" + string(time).
else varquivo = "l:~\relat~\lisext.txt" + string(time).
            

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
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


for each tt-titulo use-index iclicod where
                tt-titulo.clifor     = clien.clicod and
                tt-titulo.titnat     = no       no-lock by tt-titulo.titdtven
                                                         by tt-titulo.titnum
                                                         by tt-titulo.titpar.
    if tt-titulo.titsit = "PAG"
    then next.
    vtotal = 0.
    vjuro = 0.
    vdias = 0.

    if tt-titulo.titdtven < today
    then do:
        vdias = today - tt-titulo.titdtven.
        {sel-tabjur.i tt-titulo.etbcod vdias}
        /*
        find first tabjur where   tabjur.etbcod = 0 and
                            tabjur.nrdias = today - titulo.titdtven
                         no-lock no-error.
        */
        if  not avail tabjur
        then do:
            message "Fator para" today - tt-titulo.titdtven
                    "dias de atraso, nao cadastrado".
            pause.
            undo.
        end.
        assign vjuro  = (tt-titulo.titvlcob * tabjur.fator) - tt-titulo.titvlcob
               vtotal = tt-titulo.titvlcob + vjuro
               vdias  = today - tt-titulo.titdtven.
    end.
    else vtotal = tt-titulo.titvlcob.
    vacum = vacum + vtotal.
    display tt-titulo.etbcod
            tt-titulo.titnum
            tt-titulo.titpar
            string(tt-titulo.titparger) when tt-titulo.titparger > 0
                        format "xx" column-label "Ori"
            tt-titulo.titdtven format "99/99/9999"
            vdias           when vdias > 0 column-label "Atraso"
            tt-titulo.titvlcob column-label "Principal "   (total)
            vjuro           column-label "Juro"         (total)
            vtotal          column-label "Total"        (total)
            space(3)
            vacum           column-label "Acumulador"
            with frame flin down width 130 no-box.

end.

output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.
                                    
