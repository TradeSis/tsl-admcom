/************************************************************************

Programa para Calculo da senha do modulo de promocoes.
Rafael Antunes 06/05/2010

************************************************************************/

{admcab.i}

def var vsenha as char.
def var vsencal as char.
def var vdec as int.

if day(today) <= 10
 then vdec = 1.

else if day(today) <= 20
 then vdec = 2.

else if day(today) <= 31
 then vdec = 3.

vsencal = string(vdec) + string(day(today) + month(today) + year(today) - vdec).

disp vsencal 
     label "Senha do M¢dulo de Promo‡äes:" with frame fsenha.

pause(7).

