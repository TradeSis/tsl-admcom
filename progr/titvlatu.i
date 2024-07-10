/* Atualiza o Valor do titulo calculando Multa e Juros */

find dtextra where exdata = titulo.titdtven no-error.
if not avail dtextra
then wdtesp = no.
else do:
    wdtaux = titulo.titdtven.
    wdtesp = yes.
    repeat:
	wdtaux = wdtaux + 1.
	find dtextra where exdata = wdtaux no-error.
	if not avail dtextra
	then do:
	    if today > wdtaux
	    then do:
		wdtesp = no.
		leave.
	    end.
	    else do:
		wdtesp = yes.
		leave.
	    end.
	    leave.
	end.
    end.
end.

find dtextra where exdata = titulo.dtfixa no-error.
if not avail dtextra
then wdtesp = no.
else do:
    wdtaux2 = titulo.dtfixa.
    wdtesp2 = yes.
    repeat:
	wdtaux2 = wdtaux2 + 1.
	find dtextra where exdata = wdtaux2 no-error.
	if not avail dtextra
	then do:
	    if today > wdtaux2
	    then do:
		wdtesp = no.
		leave.
	    end.
	    else do:
		wdtesp2 = yes.
		leave.
	    end.
	    leave.
	end.
    end.
end.


    {1}     = if today > titulo.titdtven and wdtesp = no
	      then (titulo.titvlcob + (titulo.titvljur *
				    (today - titulo.titdtven))) +
				   titulo.titvlmul

	      else if ((today > titulo.titdtven and wdtesp = yes) or
		       (today > titulo.dtfixa and wdtesp = yes))
			then if titulo.titvlpon = 0
			    then titulo.titvlcob
			    else titulo.titvlcob - titulo.titvlpon

	      else if today <= titulo.titdtven and today <= titulo.dtfixa
			then if titulo.titvlpon = 0
			    then titulo.titvlcob - (titulo.titvldes *
				((titulo.dtfixa - today)))
			    else titulo.titvlcob - titulo.titvlpon

			  else titulo.titvlcob .


    /************* A N T I G O *************/
    /*{1}     = if (today > titulo.titdtven and wdtesp = no) or
		 (today > titulo.titdtven and wdtesp = yes and
		  today > titulo.titdtpag - 1)
	      then (titulo.titvlcob + (titulo.titvljur *
				    (today - titulo.titdtven))) +
				   titulo.titvlmul

	      else if today > titulo.titdtven and wdtesp = yes
		    then
			 if titulo.titvlpon = 0
			 then titulo.titvlcob - (titulo.titvldes *
			     ((titulo.dtfixa - today)))
			 else titulo.titvlcob - titulo.titvlpon

	      else if today < titulo.titdtven and today <= titulo.dtfixa
			then if titulo.titvlpon = 0
			    then titulo.titvlcob - (titulo.titvldes *
				((titulo.dtfixa - today)))
			    else titulo.titvlcob - titulo.titvlpon

		    /* else if today > titulo.dtfixa and today < titulo.titdtven
			  then titulo.titvlcob - (titulo.titvldes *
						(titulo.titdtven - today))*/

			  /* - titulo.titvlpon*/
			  else titulo.titvlcob .*/
	    /*******************************************************/
