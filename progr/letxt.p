/******************************************************************************
 Programa     : LeTXT.p
 Programador  : Cristiano Borges Brasil
 Objetivo     : Ler o arquivo .TXT recebido pelo STM-400
 Criacao      : 09/10/1996.
******************************************************************************/

def var funcao    as char format "x(78)".
def var parametro as char format "x(78)".
def var setbcod   as integer.
def var vnum      as integer.
def var vmensagem as char format "x(38)".

pause 0 before-hide.

find last estab no-lock.
do vnum = 1 to estab.etbcod:
    if vnum = 999
    then next.
    if search("..\import\mens" + string(vnum) + ".txt") <> ?
    then do:
	input from value("..\import\mens" + string(vnum) + ".txt") no-echo.
	repeat:
	    set funcao parametro.
	    if funcao = "Assunto:"
	    then setbcod = int(parametro).
	end.
	find estab where estab.etbcod = setbcod no-lock.
	display skip(1)
		" Arquivo: MENS" + string(vnum) + ".TXT" format "x(20)"
		skip
		" Loja   :"
		setbcod no-label format ">>9"
		estab.etbnom no-label
		skip(1) with width 40 title " LOCALIZANDO "
		centered row 6 color white/cyan frame f1.

	vmensagem = "Aguarde...  Copiando Arquivos !!".
	display vmensagem no-label
		with width 40 centered row 12 title " STATUS "
		color white/cyan frame f2.

	dos silent
	    value("move ..\import\mens" + string(vnum) + ".*  ..\import\loja"
			    + string(setbcod,">>9")).

	vmensagem = "Aguarde...  Descompactando Arquivos !!".
	display vmensagem no-label with frame f2.

	dos silent
	    value("pkunzip -d ..\import\loja" + string(setbcod,">>9")
			    + "\*.zip ..\import\loja" + string(setbcod,">>9")).
    end.
end.
