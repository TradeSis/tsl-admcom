def input parameter par-etbcod as integer.

    display "Fil: " string(par-etbcod) format "x(3)" no-label
                   "Deletando Titulos " colon 10
                   string(time,"HH:MM:SS") colon 60 skip
                    with frame f-deleta no-box side-label. pause 0.
    
    
for each dragao.titulo where dragao.titulo.etbcod = par-etbcod no-lock.

    find first fin.titulo where fin.titulo.empcod   = dragao.titulo.empcod 
                            and fin.titulo.empcod   = dragao.titulo.empcod
                            and fin.titulo.titnat   = dragao.titulo.titnat  
                            and fin.titulo.modcod   = dragao.titulo.modcod  
                            and fin.titulo.etbcod   = dragao.titulo.etbcod  
                            and fin.titulo.CliFor   = dragao.titulo.CliFor  
                            and fin.titulo.titnum   = dragao.titulo.titnum  
                            and fin.titulo.titpar   = dragao.titulo.titpar  
                            and fin.titulo.titdtemi = dragao.titulo.titdtemi
                                        no-lock no-error.
    
    /* Não pode deletar se no Dragão está pago e no FIN não*/                      if avail fin.titulo
    then do:
       
       if (dragao.titulo.titsit = "PAG"
            and fin.titulo.titsit <> "PAG")
       then.
       else
       run p-deleta-dragao.p ("titulo", input recid(dragao.titulo)) .
       
    end.

end.
    
    
    display "Fil: " string(par-etbcod) format "x(3)" no-label
              "Deletando Contratos e CliSpc " colon 10
             string(time,"HH:MM:SS") colon 60 skip
                     with frame f-deleta no-box side-label. pause 0.



for each dragao.contrato where dragao.contrato.etbcod = par-etbcod no-lock.


    for each  dragao.clispc
        where dragao.clispc.contnum = dragao.contrato.contnum
          and dragao.clispc.clicod  = dragao.contrato.clicod
                                         exclusive-lock.

         find first fin.clispc where fin.clispc.clicod  = dragao.clispc.clicod
                                 and fin.clispc.dtcanc  = dragao.clispc.dtcanc
                                 and fin.clispc.contnum = dragao.clispc.contnum
                                                              no-lock no-error.

         if avail fin.clispc
         then do:
             
           run p-deleta-dragao.p ("clispc", input recid(dragao.clispc)).
                
         end.
    end.
    
    find first fin.contrato
         where fin.contrato.contnum = dragao.contrato.contnum no-lock no-error.

    if avail fin.contrato
    then do:
        run p-deleta-dragao.p ("contrato", input recid(dragao.contrato)).
        
    end.   

end.
  

