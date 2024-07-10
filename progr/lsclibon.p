{admcab.i}

def var vclicod as integer.
def var vlog-achou  as logical.

/* teste vclicod = 10018464 */

repeat on error undo,retry:

    update vclicod format ">>>>>>>>>>>>9" label "Informe a Conta"
                with frame f-01 row 3 side-label.

    find first clien where clien.clicod = vclicod no-lock no-error.
    if not avail clien
    then do:

        message "Conta inválida!".
        pause.
        undo,retry.

    end.
    else do:

        display clien.clinom format "x(46)"  no-label with frame f-01.

    end.

    assign vlog-achou = no.

    for each titulo where titulo.modcod = "BON"
                      and titulo.clifor = vclicod
                      and titulo.titnat   = yes no-lock
                            break by titulo.titdtemi:

        find last plani where plani.movtdc    = 5
                          and plani.desti    = titulo.clifor
                          and plani.pladat   = titulo.titdtpag
                          /*and plani.descprod = titulo.titvlpag*/ 
						                                       no-lock no-error.
		/************** ALTERADO EM 26/04/2017 PARA TRATAR BUSCAR OS BONUS NO CAMPO notobs[1] **************/
		if avail plani then do:													   
			if acha("BONUSCRM",plani.notobs[1]) <> ? and plani.notobs[1] <> "" then do:
				if decimal(acha("BONUSCRM",plani.notobs[1])) = titulo.titvlpag then do:
																   
					display titulo.titnum   column-label "Num.Bonus"  format "x(15)"
							titulo.titdtemi column-label "Dt.Emiss." format "99/99/99"
							titulo.titvlcob column-label "Vl.Bon"  format ">,>>9.99"
							titulo.titsit   column-label "Sit"
							titulo.titdtpag column-label "Dt.Util." format "99/99/99"
							plani.etbcod    column-label "Fil." when avail plani
							plani.numero    column-label "N.Nota" when avail plani
												format ">>>>>>>>9"
							plani.serie     column-label "Ser" when avail plani
												format "x(3)"
							plani.platot    column-label "Val.Nota" when avail plani
														  skip.	

					
				end.
			
			end.
			
			else if plani.descprod = titulo.titvlpag then do:
					display titulo.titnum   column-label "Num.Bonus"  format "x(15)"
							titulo.titdtemi column-label "Dt.Emiss." format "99/99/99"
							titulo.titvlcob column-label "Vl.Bon"  format ">,>>9.99"
							titulo.titsit   column-label "Sit"
							titulo.titdtpag column-label "Dt.Util." format "99/99/99"
							plani.etbcod    column-label "Fil." when avail plani
							plani.numero    column-label "N.Nota" when avail plani
												format ">>>>>>>>9"
							plani.serie     column-label "Ser" when avail plani
												format "x(3)"
							plani.platot    column-label "Val.Nota" when avail plani
														  skip.	

					
				
			end.
		
		end.
		else.
			display titulo.titnum   column-label "Num.Bonus"  format "x(15)"
							titulo.titdtemi column-label "Dt.Emiss." format "99/99/99"
							titulo.titvlcob column-label "Vl.Bon"  format ">,>>9.99"
							titulo.titsit   column-label "Sit"
							titulo.titdtpag column-label "Dt.Util." format "99/99/99"
							plani.etbcod    column-label "Fil." when avail plani
							plani.numero    column-label "N.Nota" when avail plani
												format ">>>>>>9"
							plani.serie     column-label "Ser" when avail plani
												format "x(3)" 
							plani.platot    column-label "Val.Nota" when avail plani
														  skip.	
			
		
		assign vlog-achou = yes.
    end.

    if not vlog-achou
    then do:

        message  "Não Foram encontrados Bonus para esse cliente!".

        undo,retry.

    end.

end.

