/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/extmo.p                             Extrato de Movimentacao */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var perini as date format "99/99/9999".
def var perfin as date format "99/99/9999".
def var  octype as char extent 8 label "Tipo"
    initial ["NFFOR","NFDVC","NFVCL","NFVCO","NFDVV","NFTRA","PLENT","PLSAI"].
def var wtotin as dec format ">>,>>9.99" label "Total Entradas".
def var wtotout as dec format ">>>,>>9.99" label "Total Saidas".
def var wtottra as dec format ">>>,>>9.99" label "Total Transferencias".
def var woper as log format "Entr./Saida" label "Oper.".
def var descrc as c format "x(52)".
def var vemite as char format "x(15)".
def var vdesti as char format "x(25)".
def var vrec as recid.
l1:
repeat with side-labels 1 down width 80 frame f1:
    form estab.etbcod colon 17 etbnom at 26 no-label
         produ.proant colon 17 descrc no-label
         perini label "Periodo" colon 17
         " A " perfin no-label.
    wtotin = 0.
    wtotout = 0.
    prompt-for estab.etbcod.
    find estab using etbcod.
    display etbnom.
    prompt-for produ.proant.
    find produ using produ.proant.
    find fabri of produ.
    display pronom + "-" + fabfant @ descrc.
    find estoq where estoq.etbcod = estab.etbcod
                 and estoq.procod = produ.procod no-error.
    if not available estoq
    then do:
           message "Registro de Estoque Inexistente.".
           undo.
    end.
    prompt-for perini validate(perini entered,"Data Inicial Obrigatoria.")
               perfin.
    if perfin not entered
    then do:
           perfin = today.
           display perfin.
    end.
    for each movim where movim.etbcod = estab.etbcod
                     and movim.procod = produ.procod
                     and movim.movdat >= input perini
                     and movim.movdat <= input perfin
                     with width 80 title " Movimentos ":
        find plani of movim.
        find tipmov of plani.
         if plani.notsit = "C" then next.
         if tipmov.movtvenda
         then wtotout = wtotout + movqtm.
         if tipmov.movttra
         then wtottra = wtottra + movqtm.
         else if not movtvenda
              then wtotin = wtotin + movqtm.

         display
                 plani.notsit
                 plani.numero
                 plani.serie    column-label "Ser".
         /*
         run leclf.p (input plani.emite,
                      output vrec).
         find clifor where recid(clifor) = vrec.
         disp clifor.clfnom @ vemite column-label "Emite".
         */
         run leclf.p (input plani.desti,
                      output vrec).
         find clifor where recid(clifor) = vrec.
         disp clifor.clfnom @ vdesti column-label "Desti".
         display movim.movdat format "99/99/99"
                 movim.movqtm format "->>>,>>9" column-label "Qtd"
                 movim.movpc  format ">>>,>>9.99" column-label "V.Unit".
        pause before-hide message "ENTER Para Totais".
    end.
    display skip(1) space(2) wtotin
            skip(1) space(2) wtottra
            skip(1) space(2) wtotout skip(1)
            with frame ftots title " Quantidade - Totais "
                       side-labels overlay row 14 column 42 color white/red.
    message "Extrato de Movimento Encerrado.".
end.
