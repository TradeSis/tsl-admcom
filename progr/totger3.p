{admcab.i}
def var vachou      as logical.
def var vetb        as logical.

def temp-table wftot
    field vetbcod  like estab.etbcod
    field vclia as dec label "Clientes Ativos"      format ">>,>>>,>>9.99"
    field vclid as dec label "Clientes Inativos"    format ">>,>>>,>>9.99"
    field vcon  as dec label "Contratos Abertos"    format ">>,>>>,>>9.99"
    field vtit  as dec label "Titulos Abertos"      format ">>,>>>,>>9.99"
    field vtot  as dec label "Valor em Aberto"      format ">>,>>>,>>9.99".


disp "TODOS OS ESTABELECIMENTOS - LENDO FILIAL"
           with side-labels color white/cyan width 80 frame fpede row 4.

FOR EACH ESTAB:

    create wftot.
    assign wftot.vetbcod = estab.etbcod.

END.
/*
DISP ESTAB.ETBCOD NO-LABEL WITH FRAME FPEDE.
*/

for each clien no-lock:

    disp clien.clicod with 1 down centered. pause 0.

    for each contrato where contrato.clicod = clien.clicod no-lock
                            break by contrato.clicod :

        find first wftot where wftot.vetbcod = contrato.etbcod.

        vetb = yes.
        for each titulo where titulo.empcod = wempre.empcod   and
                              titulo.titnat = no              and
                              titulo.modcod = "CRE"           and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = clien.clicod    and
                              titulo.titnum = string(contrato.contnum)
                                                                    no-lock:
            if titulo.titsit = "PAG"
            then do:
                vachou = no.
                next.
            end.
            else vachou = yes.

            assign vtit = vtit + 1.
            assign vtot = vtot + titulo.titvlcob.

        end.
        if vachou then vcon = vcon + 1.

        if first-of(contrato.clicod)
        then do:
            if vachou
            then vclia = vclia + 1.
            else if vetb then vclid = vclid + 1.
            assign vachou = no
                   vetb   = no.
        end.

    end.
end.

for each wftot:
    disp
     wftot.vetbcod column-label "Fl."
     wftot.vclia(TOTAL) label "Cli.Ativ."      format ">,>>>,>>9.99"
     wftot.vclid(TOTAL) label "Cli.Inat."      format ">,>>>,>>9.99"
     wftot.vcon(TOTAL)  label "Con.Aber."      format ">,>>>,>>9.99"
     wftot.vtit(TOTAL)  label "Tit.Aber."      format ">,>>>,>>9.99"
     wftot.vtot(TOTAL)  label "Val.Aber."      format ">>,>>>,>>9.99"
                    with frame fmostra down centered color white/red
                    overlay row 8.
end.
bell.
message "Prepare a Impressora...". pause.

{mdadmcab.i
      &Saida     = "printer"
      &Page-Size = "64"
      &Cond-Var  = "80"
      &Page-Line = "66"
      &Nom-Rel   = ""TOTGER3""
      &Nom-Sis   = """SISTEMA DE CREDIARIO """
      &Tit-Rel   = """RESUMO GERAL DO CREDIARIO """
      &Width     = "80"
      &Form      = "frame f-cabcab"}

for each wftot:
    disp
     wftot.vetbcod column-label "Fl."
     wftot.vclia(TOTAL) label "Cli.Ativ."      format ">,>>>,>>9.99"
     wftot.vclid(TOTAL) label "Cli.Inat."      format ">,>>>,>>9.99"
     wftot.vcon(TOTAL)  label "Con.Aber."      format ">,>>>,>>9.99"
     wftot.vtit(TOTAL)  label "Tit.Aber."      format ">,>>>,>>9.99"
     wftot.vtot(TOTAL)  label "Val.Aber."      format ">>,>>>,>>9.99"
                    with frame fimp down centered color white/red
                    overlay row 8.
end.

output close.
