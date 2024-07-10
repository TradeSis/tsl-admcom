/*----------------------------------------------------------------------------*/
/* /usr/admger/applhelp.p                             Rotina Generica de Help */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def var wbk as char.
DEF VAR VCALC AS CHAR FORMAT "X(15)" extent 3
        INITIAL ["CALCULADORA","CALENDARIO","SOLICITACOES"].
{admcab.i}
if (lastkey = keycode("F5") or
    lastkey = keycode("PF5")) and
   frame-field matches "*procod*"
then run com01.p.
else do:

if lastkey = keycode("F5") or
   lastkey = keycode("PF5")
then do:
    DISP VCALC NO-LABEL WITH FRAME F ROW 4 OVERLAY SIDE-LABELS column 50.
    CHOOSE FIELD VCALC WITH FRAME F.
    IF FRAME-INDEX = 1
    THEN run calculat.p .
    ELSE if frame-index = 2
         then run calendar.p.
         else run suporte.p.
    hide frame f no-pause.
end.
end.

if lastkey = keycode("F7") or
   lastkey = keycode("PF7")
    then do:
    {zadmfin.i}
    {zadmger.i}
    {zadmcom.i}
    {zadmctb.i}
    {zadmcre.i}
    {zadmcrm.i}
    {zadmadm.i}
    end.
if lastkey = keycode("F6") or
   lastkey = keycode("PF6")
    then do:
    {hadmger.i}
    {hadmcom.i}
    {hadmfin.i}
end.
