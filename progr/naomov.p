/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/naomov.p               Relatorio de Movimentacao por Classe */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 21/09/92 Eduardo Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def var dias as integer label "Dias" format "9999".
def var ultmov as char format "x(14)" column-label "Data Ultimo Movimento".
def var liga-compress as char initial "".
def var desliga-compress as char initial "".

repeat:
form estab.etbcod colon 20 label "Estabelecimento"
     estab.etbnom at 30 no-label skip
     clase.clacod colon 20 label "Classe"
     clase.clanome at 30 no-label skip
     fabri.fabcod colon 20 label "Fabricante"
     fabri.fabnom at 30 no-label
     with side-labels width 80 frame naomov01 title " Movimentacao ".
form dias colon 20
     help "Informe a quantidade de dias a ser consultada."
     with side-labels width 80 frame naomov02 title " Periodo da Consulta ".
   prompt-for estab.etbcod validate(true,"")
      with frame naomov01.
   if input estab.etbcod <> 0
   then do:
       find estab using estab.etbcod.
       display estab.etbnom with frame naomov01.
   end.
   prompt-for clase.clacod validate(true,"")
      with frame naomov01.
   if input clase.clacod <> 0
   then do:
      find clase using clase.clacod.
      display clase.clanome with frame naomov01.
   end.
   prompt-for fabri.fabcod validate(true,"")
      with frame naomov01.
   if input fabri.fabcod <> 0
   then do:
      find fabri using fabri.fabcod.
      display fabri.fabnom with frame naomov01.
   end.
   update dias with frame naomov02.
   OUTPUT TO PRINTER PAGE-SIZE 60.
   /* OUTPUT TO /usr/admcom/es/naomov.doc PAGE-SIZE 60. */
   /* put control liga-compress. */
   FOR EACH produ WHERE
      (IF INPUT clase.clacod = 0 THEN TRUE
       ELSE produ.clacod = INPUT clase.clacod) AND
      (IF INPUT fabri.fabcod = 0 THEN TRUE
       ELSE produ.fabcod = INPUT fabri.fabcod):
       /* BY produ.clacod BY produ.fabcod: */
   FORM HEADER wempre.emprazsoc format "x(30)"
	       "M O V I M E N T A C A O " AT 68
	       TODAY TO 160 SKIP
	       "Relatorio de Produtos nao Movimentados nos Ultimos" dias "Dias"
	       "- (" SPACE(0) TODAY - dias SPACE(0) ")"
	       "Pagina" AT 151 PAGE-NUMBER FORMAT ">>9" SKIP
	       FILL("-",160) FORMAT "x(160)"
	       WITH FRAME cabecalho PAGE-TOP NO-BOX NO-ATTR-SPACE WIDTH 160.
   FORM produ.procod produ.pronom space(3)
	fabri.fabcod fabri.fabfant space(3)
	clase.clacod clase.clanome space(3)
	estoq.etbcod estoq.estatual space(2) ultmov
	WITH DOWN FRAME naomov03 NO-BOX NO-ATTR-SPACE WIDTH 160.
      for each estoq of produ where
	 (if input estab.etbcod = 0 then true
	  else estoq.etbcod = input estab.etbcod):
	 view frame cabecalho.
	 find last movim of estoq no-error.
	 if not available movim
	 then do:
	    ultmov = "Nao Movimentou".
	    if input fabri.fabcod = 0
	    then find fabri where fabri.fabcod = produ.fabcod.
	    if input clase.clacod = 0
	    then find clase where clase.clacod = produ.clacod.
	    display produ.procod produ.pronom
		    fabri.fabcod fabri.fabfant
		    clase.clacod clase.clanome
		    estoq.etbcod estoq.estatual
		    ultmov with frame naomov03.
	 end.
	 else if movim.movdat < today - dias
	      then do:
		 ultmov = (substr(string(movim.movdat),1,2) + "/" +
			   substr(string(movim.movdat),4,2) + "/" +
			   substr(string(movim.movdat),7,2)).
		 if input fabri.fabcod = 0
		 then find fabri where fabri.fabcod = produ.fabcod.
		 if input clase.clacod = 0
		 then find clase where clase.clacod = produ.clacod.
		 display produ.procod produ.pronom
			 fabri.fabcod fabri.fabfant
			 clase.clacod clase.clanome
			 estoq.etbcod estoq.estatual
			 ultmov with frame naomov03.
	      end.
	 down with frame naomov03.
      end.
   end.
   /* put control desliga-compress. */
   OUTPUT CLOSE.
end.
