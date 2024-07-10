

for each estab where estab.etbcod = 8 
                  or estab.etbcod = 13
                  or estab.etbcod = 20 no-lock,

    each fin.contrato where fin.contrato.etbcod = estab.etbcod no-lock,
    
    each dragao.clispc where dragao.clispc.clicod = fin.contrato.clicod
                         and dragao.clispc.contnum = fin.contrato.contnum 
                                            no-lock:
        
    find first fin.clispc where fin.clispc.clicod = dragao.clispc.clicod                                    and fin.clispc.contnum = dragao.clispc.contnum                                 and fin.clispc.dtcanc = dragao.clispc.dtcanc
                                no-lock no-error.
    if avail fin.clispc
    then next.
                                                                             create fin.clispc.
    assign fin.clispc.clicod  = dragao.clispc.clicod 
           fin.clispc.datexp  = dragao.clispc.datexp 
           fin.clispc.dtneg   = dragao.clispc.dtneg  
           fin.clispc.dtcanc  = dragao.clispc.dtcanc 
           fin.clispc.spcpro  = dragao.clispc.spcpro 
           fin.clispc.contnum = dragao.clispc.contnum.
    
    create lmn.clispc.
    assign lmn.clispc.clicod  = dragao.clispc.clicod 
           lmn.clispc.datexp  = dragao.clispc.datexp 
           lmn.clispc.dtneg   = dragao.clispc.dtneg  
           lmn.clispc.dtcanc  = dragao.clispc.dtcanc 
           lmn.clispc.spcpro  = dragao.clispc.spcpro 
           lmn.clispc.contnum = dragao.clispc.contnum.
           
    run p-deleta-clispc-dragao (input recid(dragao.clispc)).       

end.
        


procedure p-deleta-clispc-dragao:

    def input parameter p-recid as recid.

    def buffer bclispc for dragao.clispc.
    
    find first dragao.bclispc where recid(dragao.bclispc) = p-recid exclusive-lock no-wait no-error.

    if avail dragao.bclispc
    then delete dragao.bclispc.

end.