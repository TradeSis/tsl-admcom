{admcab.i}
def var vetbcod like estab.etbcod.
def var varquivo as char.
def buffer btitulo for titulo.
def var vvalor      as dec                          label "Valor".
def var vdtini      like plani.pladat initial today       label "Data Inicial".
def var vdtfim      like plani.pladat initial today       label "Data Final".
def var np          as int      format ">>9".
def var vp          as dec      format ">>>,>>9.99".

update vetbcod colon 20 with side-label width 80 row 4
                    color white/cyan title " VALORES DE CONTRATOS ".
if vetbcod = 0
then display "GERAL" @ estab.etbnom no-label.
else do:
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label.
end.
update  vdtini colon 20
        vdtfim colon 65
        vvalor colon 20.

/* Inicia o Gerenciador de ImpressÆo */

if opsys = "UNIX"
then varquivo = "/admcom/relat/relct" + string(time).
else varquivo = "..\relat\relct" + string(time).

    {mdad.i 
                &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "135"
                &Page-Line = "66"
                &Nom-Rel   = ""RELCTRVL""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """LISTAGEM DE CONTRATOS = OU ACIMA DE "" +
                                string(vvalor,"">>>,>>9.99"") +
                              "" POR PERIODO DE "" +
                                string(vdtini) + "" A "" + string(vdtfim) +
                                "" - LOJA "" + string(estab.etbcod) "
                &tit-rel1  = " skip fill(""-"",120) format ""x(120)"" skip
                             ""Dt Inicial   Conta  Cliente                 ""
                             ""                  Contrato  Valor"" "
                &Width     = "135"
                &Form      = "frame f-cabcab"}

for each estab where if vetbcod = 0
                     then true
                     else estab.etbcod = vetbcod no-lock,
    each contrato where contrato.dtinicial >= vdtini and
                        contrato.dtinicial <= vdtfim and
                        contrato.etbcod = estab.etbcod no-lock:



    if contrato.vltotal >= vvalor and
       contrato.etbcod   = estab.etbcod
    then do:
        np = 0.
        vp = 0.
        for each btitulo use-index iclicod
                         where btitulo.clifor = contrato.clicod and
                               btitulo.titnat = no and
                               btitulo.titsit = "LIB" no-lock.
            np = np + 1.
            vp = vp + btitulo.titvlcob.
        end.

        find clien where clien.clicod = contrato.clicod no-lock.

        display skip(1)
                contrato.etbcod
                contrato.dtinicial format "99/99/9999"
                contrato.clicod format ">>>>>>>>>9"
                clien.clinom
                contrato.contnum format ">>>>>>>>>9"
                contrato.vltotal(total) with width 140 no-label no-box.

        /*
        for each titulo where titulo.empcod = wempre.empcod     and
                              titulo.titnat = no                and
                              titulo.modcod = "CRE"             and
                              titulo.etbcod = estab.etbcod      and
                              titulo.clifor = contrato.clicod   and
                              titulo.titnum = string(contrato.contnum)
                              no-lock break by titulo.titnum
                                            by titulo.titpar:
            if titulo.titsit = "PAG"
            then
            display titulo.titpar  at 51
                    titulo.titsit
                    titulo.titvlcob
                    titulo.titdtven space(2)
                    titulo.titdtpag
                    titulo.titvlpag with width 120 no-box frame ff1.

            else do:
               /* np = np + 1.
                vp = vp + titulo.titvlcob. */
                if last-of(titulo.titnum)
                then do:
                    display skip(1)
                            np no-label at 51
                            "Titulos em Aberto no Valor de R$"
                            vp no-label with width 120 no-box frame ff2.

                end.
            end.

        end.
        */
    end.
end.
/*
{mrod.i}
output close.
*/
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
