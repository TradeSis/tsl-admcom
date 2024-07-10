{admcab.i}
define variable wcon like contrato.contnum.
def var vtot as decimal.
def var vconta as integer.
def var vdif   as decimal.
def var vok    as log.

def stream tela.
def stream rela.

output stream tela to terminal.

output to relato.

display stream tela string(time,"HH:MM:SS") label "Horario Inicio"
        with frame fhoraini row 5.

l0:
do with frame f1:
 assign wcon = 0.
 for each contrato use-index dtini where contrato.dtinicial > 04/01/1996:


    display stream tela string(time,"HH:MM:SS") label "Hora Atual"
            with frame fhorafim row 5 column 60.
    pause 0.
    vtot = 0.
    vok  = no.
    for each titulo where   titulo.empcod = 19 and
                            titulo.titnum = string(contrato.contnum)    and
                            titulo.titnat = no                          and
                            titulo.etbcod = contrato.etbcod             and
                            titulo.clifor = contrato.clicod             and
                            titulo.modcod = "CRE":
            if titsit = "LIB" or
               titsit = "IMP"
            then vok = yes.

            if titnumger <> "" and
               titnumger <> ?
            then next.
            vtot = vtot + titulo.titvlcob.
    end.

    if not vok
    then next.

    if vtot > contrato.vltotal
    then do:
        vdif = vtot -  contrato.vltotal.
        if vdif < 0
        then do:
            if vdif > -1.00
            then next.
        end.
        else do:
            if vdif < 1.00
            then next.
        end.

        do with side-label frame f1:
            display  contrato.contnum
                     contrato.clicod.
            find clien of contrato no-error.
            display clien.clinom when avail clien.
            display contrato.dtinicial
                    contrato.etbcod
                    contrato.banco.
        end.
        do with side-label frame f2:
            display vltotal                 label "TOTAL"
                    vlentra                 label "Entrada"
                    vltotal - vlentra       label "Liquido"
                    format ">>>,>>>,>>9.99".
        end.
        for each  titulo where  titulo.empcod = 19 and
                                titulo.titnum = string(contrato.contnum) and
                                titulo.titnat = no                       and
                                titulo.etbcod = contrato.etbcod and
                                titulo.clifor = contrato.clicod          and
                                titulo.modcod = "CRE"
                                with frame f3 column 35:

            display titulo.titpar
                    titulo.titsit
                    titnumger
                    titparger
                    if titulo.titdtpag <> ?
                    then titulo.titdtpag
                    else titulo.titdtven  @ titulo.titdtpag
                             column-label "Vecto/Pagto"
                    if titulo.titdtpag <> ?
                    then titulo.titvlpag
                    else titulo.titvlcob @ titulo.titvlcob
                          column-label "Valor".
        end.

        display vtot label "Total Parcelas" with column 35 with side-label.
        vconta = vconta + 1.
    display stream tela vconta              label "Ocorrencias"
                        contrato.contnum
                        contrato.vltotal
                        vtot
                        vdif label "Diferenca"
          with centered color white/cyan row 12 side-label frame cbb no-hide.
    end.
    else pause 0.
    vtot = 0.
    pause 0.
end.
display "Total de Ocorrencias :"
        vconta no-label
        with side-label centered.
end.
