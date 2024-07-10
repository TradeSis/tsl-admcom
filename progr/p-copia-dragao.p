def input parameter p-tipo       as char.
def input parameter p-recid      as recid.

def buffer bf2-titulo for fin.titulo.

case (p-tipo):
when "titulo"   then run p-copia-titulo.
when "contrato" then run p-copia-contrato. 
when "clispc"   then run p-copia-clispc.
end case.

procedure p-copia-titulo:

    find first dragao.titulo where recid(dragao.titulo) = p-recid
                no-lock no-error.
    
    find first dr.titulo where dr.titulo.empcod   = dragao.titulo.empcod 
                           and dr.titulo.empcod   = dragao.titulo.empcod
                           and dr.titulo.titnat   = dragao.titulo.titnat  
                           and dr.titulo.modcod   = dragao.titulo.modcod  
                           and dr.titulo.etbcod   = dragao.titulo.etbcod  
                           and dr.titulo.CliFor   = dragao.titulo.CliFor  
                           and dr.titulo.titnum   = dragao.titulo.titnum  
                           and dr.titulo.titpar   = dragao.titulo.titpar  
                           and dr.titulo.titdtemi = dragao.titulo.titdtemi
                                       no-lock no-error.
                                        
    if not avail dr.titulo
    then do:
     
        create dr.titulo.
        {tt-titulo.i dr.titulo dragao.titulo}
    
    end.
    
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

    if not avail fin.titulo
    then do:
               
       create fin.titulo.
       {tt-titulo.i fin.titulo dragao.titulo}
      
    end.
    else do:
    
       if dragao.titulo.titsit = "PAG"
           and fin.titulo.titsit <> "PAG"
       then do:
           
           find first fin.bf2-titulo
                where fin.bf2-titulo.empcod   = dragao.titulo.empcod
                  and fin.bf2-titulo.titnat   = dragao.titulo.titnat
                  and fin.bf2-titulo.modcod   = dragao.titulo.modcod
                  and fin.bf2-titulo.etbcod   = dragao.titulo.etbcod
                  and fin.bf2-titulo.CliFor   = dragao.titulo.CliFor
                  and fin.bf2-titulo.titnum   = dragao.titulo.titnum
                  and fin.bf2-titulo.titpar   = dragao.titulo.titpar
                  and fin.bf2-titulo.titdtemi = dragao.titulo.titdtemi
                                  exclusive-lock no-wait no-error.

           if avail fin.bf2-titulo
           then do:
           
               {tt-titulo.i fin.bf2-titulo dragao.titulo}
               
           end.
           
       end.
    
    end.

end procedure.



procedure p-copia-contrato:
 
    find first dragao.contrato
         where recid(dragao.contrato) = p-recid no-lock no-error.

    find first dr.contrato
         where dr.contrato.contnum = dragao.contrato.contnum
                    no-lock no-error.

    if not avail dr.contrato
    then do:

        create dr.contrato.
        {tt-contrato.i dr.contrato dragao.contrato}
        
    end.
    
    find first fin.contrato
         where fin.contrato.contnum = dragao.contrato.contnum
                                no-lock no-error.
                                
    if not avail fin.contrato
    then do:
         
       create fin.contrato.
       {tt-contrato.i fin.contrato dragao.contrato}
       
    end.
    
end procedure.




procedure p-copia-clispc:
 
    find first dragao.contrato
         where recid(dragao.contrato) = p-recid no-lock no-error.

    for each dragao.clispc
       where dragao.clispc.contnum = dragao.contrato.contnum
         and dragao.clispc.clicod  = dragao.contrato.clicod
                                        no-lock.

        find first dr.clispc where dr.clispc.clicod  = dragao.clispc.clicod
                                and dr.clispc.dtcanc  = dragao.clispc.dtcanc
                                and dr.clispc.contnum = dragao.clispc.contnum
                                no-lock no-error.
                                
        if not avail dr.clispc
        then do:

            create dr.clispc.
            assign dr.clispc.clicod  = dragao.clispc.clicod 
                   dr.clispc.datexp  = dragao.clispc.datexp 
                   dr.clispc.dtneg   = dragao.clispc.dtneg  
                   dr.clispc.dtcanc  = dragao.clispc.dtcanc 
                   dr.clispc.spcpro  = dragao.clispc.spcpro 
                   dr.clispc.contnum = dragao.clispc.contnum.
        end.
        
        find first fin.clispc where fin.clispc.clicod  = dragao.clispc.clicod
                                and fin.clispc.dtcanc  = dragao.clispc.dtcanc
                                and fin.clispc.contnum = dragao.clispc.contnum
                                no-lock no-error.
                                
        if not avail fin.clispc
        then do:
       
           create fin.clispc.
           assign fin.clispc.clicod  = dragao.clispc.clicod
                  fin.clispc.datexp  = dragao.clispc.datexp
                  fin.clispc.dtneg   = dragao.clispc.dtneg
                  fin.clispc.dtcanc  = dragao.clispc.dtcanc
                  fin.clispc.spcpro  = dragao.clispc.spcpro
                  fin.clispc.contnum = dragao.clispc.contnum.
                                    
        end.
   end. 
end procedure.



