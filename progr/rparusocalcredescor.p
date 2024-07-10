{admcab.i}
def var vetbcod like estab.etbcod.
def var vclicod like clien.clicod.

update vetbcod label "Filial" with frame f1 1 down side-label width 80.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock .
    disp estab.etbnom no-label with frame f1.
end.
update vclicod at 1 label "Clientes" with frame f1.
find clien where clien.clicod = vclicod no-lock.
disp clien.clinom no-label with frame f1.

    
def var vcalclim as dec.
def var vpardias as dec.
def var vdisponivel as dec.
def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
 
run calccredscore.p (input string(vetbcod),
                        input recid(clien),
                        output vcalclim,
                        output vpardias,
                        output vdisponivel).
 
def var varquivo as char.
varquivo = "/admcom/relat/rparusocalcredescor." + string(time).

{mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "120"
            &Page-Line = "64"
            &Nom-Rel   = ""rparusocalcredescor""
            &Nom-Sis   = """SISTEMA FINANCEIRO"""
            &Tit-Rel   = """PARAMETROS USADOS NO CALCULO DO LIMITE """
            &Width     = "120"
            &Form      = "frame f-cabcab"}

disp with frame f1.
 
for each tt-dados:
disp tt-dados.parametro format "x(50)"  column-label "Parametros"
     tt-dados.valor                     column-label "Valor!parametro"
     tt-dados.valoralt                  column-label "Valor!alterado"
     tt-dados.vcalclim column-label "Limite!calculado"
     tt-dados.operacao column-label "Ope"
     tt-dados.numseq   column-label "Seq" format ">>>9"
     with width 120.
end.

output close.
run visurel.p(input varquivo, "").
