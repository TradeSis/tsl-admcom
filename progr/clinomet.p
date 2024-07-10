{admcab.i}
def var vetbcod         like estab.etbcod.
def var vtot            as integer.
def var vclicod         like clien.clicod.
def var vcol            as integer          initial 75.
def var vachou          as log.

def stream tela.

output stream tela to terminal.

do on error undo, retry
    with centered width 80 color white/cyan side-label row 4
         title " LISTAGEM DE CLIENTES ORDEM ALFABETICA ".
    update vetbcod.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message "Estabelecimento nao Cadastrado !!".
        pause.
        undo, retry.
    end.
    display estab.etbnom no-label.
end.

message "Gerando o relatorio".
def var varquivo as char.
varquivo = "..\relat\" + STRING(TIME) + ".REL".
{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "140"
    &Page-Line = "66"
    &Nom-Rel   = """CLINOMET"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """LISTAGEM ALFABETICA DE CLIENTES POR ESTAB. "" +
                    "" - "" + string(estab.etbnom) "
    &Width     = "140"
    &Form      = "frame f-cab"}

put "Fil."                 at   1
    "Nome do Cliente"      at   6
    "Codigo"               at  45
    "Dt.Nasc"              at  55
    "Fil."                 at  71
    "Nome do Cliente"      at  76
    "Codigo"               at 115
    "Dt.Nasc"              at 125 skip.

put fill("-",140) format "x(140)".

for each clien break by clien.clinom:

    vachou = no.
    for each titulo where titulo.empcod = 19              and
                          titulo.titnat = no              and
                          titulo.modcod = "CRE"           and
                          titulo.etbcod = vetbcod         and
                          titulo.clifor = clien.clicod:

        if titulo.titsit = "LIB"
        then do:
            vachou = yes.
            leave.
        end.

        if titulo.titdtemi >= 01/01/1994
        then do:
            vachou = yes.
            leave.
        end.

    end.


    if vachou
    then do:
        vtot = vtot + 1.
        display stream tela vetbcod
                            clien.clinom
                            vtot            label "Total de Clientes"
                            with frame cbb 1 column color
                            white/red centered row 9.
        pause 0.

        if vcol = 75
        then vcol = 0.
        else vcol = 75.

        put vetbcod                      at vcol + 1
            string(clien.clinom,"x(35)") at vcol + 6  format "x(35)"
            clien.clicod                 at vcol + 45
            clien.dtnasc                 at vcol + 55.

    end.
end.

display skip(2) "TOTAL DE CLIENTES :" vtot with frame ff no-labels no-box.
output close.
bell.
bell.
message "Listar na Impressora o Arquivo " varquivo "?" update sresp.
if sresp
then dos silent value("type " + varquivo + " > prn").
