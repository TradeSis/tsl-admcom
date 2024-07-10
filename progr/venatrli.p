{admcab.i}

def var vdtini  like plani.pladat label "Data Inicial".
def var vdtfim  like plani.pladat label "Data Final".
def var vatraso     as log.
def var varquivo as char.

prompt-for estab.etbcod colon 20 with width 80 color white/cyan side-labels
                                            row 4.
find estab using estab.etbcod no-lock.
display estab.etbnom no-label.
update vdtini colon 20
       vdtfim colon 60.

{confir.i 1 "Emissao do Relatorio"}


 /* Inicia o gerànciador de Impress∆o */
 if opsys = "UNIX"
 then varquivo = "/admcom/relat/ra" + string(time).
 else varquivo = "..\relat\ra" + string(time).


{mdad.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "137"
    &Page-Line = "66"
    &Nom-Rel   = """VENATR"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """VENDA COM PARCELAS ATRASADAS E LIMITES ULTRAPASSADOS "" +
                  ""LOJA "" + string(estab.etbcod)
                        + "" - ""
                        + estab.etbnom + "" DE "" + string(vdtini) + "" A "" +
                                                    string(vdtfim) "
    &tit-rel1  = " skip fill(""-"",137) format ""x(137)"" skip
                    ""Fil. Nome                             ""
                    ""         Conta     Contrato""
                    "" Dta.Venda          Valor     ""
                    ""  Entrada      Saldo    Limite""  "
    &Width     = "137"
    &Form      = "frame f-cab"}

for each contrato use-index dtini where
            contrato.etbcod    = estab.etbcod and
            contrato.dtinicial >= vdtini and
            contrato.dtinicial <= vdtfim no-lock.

     find clien where clien.clicod = contrato.clicod no-lock no-error.
     if not avail clien
     then next.
     if contrato.vltotal > clien.limcrd
     then display contrato.etbcod   at 3
                  clien.clinom
                  clien.clicod  format ">>>>>>>>>9"    space(6) 
                  contrato.contnum  format ">>>>>>>>>9" space(3)
                  contrato.dtinicial format "99/99/9999" 
                  contrato.vltotal
                  contrato.vlent
                  contrato.vltotal - contrato.vlent format ">>>,>>9.99"
                  clien.limcrd
                  with frame f-cont width 137 no-labels no-box.


end.
{fin17cpp.i}
output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.

{mrod.i}
/* Finalisa o gerànciador de Impress∆o */
 
