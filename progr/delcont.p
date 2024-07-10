 {admcab.i}
 def var dtini   as date label "Data Inicial".
 def var dtfim   as date label "Data Final  ".
 def var vetbcod like titulo.etbcod.
 def var conta   as integer init 0.

 def stream arq.

 output stream arq  to pagos.d.

 message "ATENCAO este procedimento apenas esta exportando os dados !!".
 update vetbcod skip
	dtini
	dtfim with color white/cyan title " LIMPEZA DE CONTRATOS "
	side-label width 80 2 column row 4.

 def buffer b-titulo for titulo.

 form "Pesquisando Titulo" titulo.titnum with frame f1
 color white/cyan row 18 centered no-label 1 down.

 form "Deletando parcela " titulo.titpar "do Titulo"
      titulo.titnum conta with frame f2
      color blue/cyan centered no-label 1 down row 12 overlay.

 for each contrato:
    for each titulo
		 where titulo.empcod = 19                       and
		       titulo.titnat = no                       and
		       titulo.modcod = "CRE"                    and
		       titulo.etbcod = vetbcod                  and
		       titulo.clifor = contrato.clicod          and
		       titulo.titnum = string(contrato.contnum):

      pause 0.
      display titulo.titnum with frame f1.

      if titulo.titdtpag >= dtini and
	 titulo.titdtpag <= dtfim
	 then do:

	  if titulo.titsit = "PAG"
	  then do:

	     export stream arq titulo.

	     /* delete titulo */

	     conta = conta + 1.
	     display titulo.titpar titulo.titnum conta with frame f2.
	  end.
       end.
    end.
 end.
 output stream arq  close.
