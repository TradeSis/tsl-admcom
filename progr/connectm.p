def var vlinha  as char.
def var vfilial as char.
def var varq as char.
def var varquivo as char.
def var varquivox as char.
def var vetbcod like estab.etbcod.
def var varqdel as char.
def var vclicod like conecta.clfcod. 

repeat:
        
    pause 1 no-message.

    assign vlinha = "" varquivo = "" varq = "" vfilial = "" vclicod = 0
            vetbcod = 0.

    find first conecta where conecta.consit = 0 no-error.
    if avail conecta
    then do:
        run cria-tt.
        
        /*assign vetbcod = conecta.etbcod
               vclicod = conecta.clfcod.*/
                                              
        
        vfilial = " filial" + string(conecta.etbcod,"99").

        os-command /*no-wait */
  /home/drebes/scripts/job-rcp-conn value(conecta.clfcod) value(vfilial) " &".
        
        delete conecta.                     
        
    end.
    
end.

procedure cria-tt.         
    varquivo = "".
    varquivo = "/admcom/connect/retorna/" + string(conecta.clfcod).

    output to value(varquivo).

        for each titulo use-index iclicod where 
                 titulo.empcod = 19        and
                 titulo.titnat = no        and
                 titulo.modcod = "CRE"     and
                 titulo.clifor = conecta.clfcod no-lock:

                                           /*
             if fin.titulo.titsit   = "pag" and
                fin.titulo.titdtpag >= today - 365 
             then. 
             else next.                  */
                                               
             export titulo.empcod
                    titulo.modcod
                    titulo.clifor
                    titulo.titnum
                    titulo.titpar
                    titulo.titnat
                    titulo.etbcod
                    titulo.titdtemi
                    titulo.titdtven
                    titulo.titvlcob
                    titulo.titsit    
                    titulo.titdtpag
                    titulo.titvlpag.

        end.

        /************************ Prestacoes Global ***********************/

        for each titulo use-index iclicod where 
                 titulo.empcod = 19        and
                 titulo.titnat = no        and
                 titulo.modcod = "GLO"     and
                 titulo.clifor = conecta.clfcod  no-lock:

             export titulo.empcod
                    titulo.modcod
                    titulo.clifor
                    titulo.titnum
                    titulo.titpar
                    titulo.titnat
                    titulo.etbcod
                    titulo.titdtemi
                    titulo.titdtven
                    titulo.titvlcob
                    titulo.titsit
                    titulo.titdtpag
                    titulo.titvlpag  .
        
        end.
    output close.
    
end procedure.
