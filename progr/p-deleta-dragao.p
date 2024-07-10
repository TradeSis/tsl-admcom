def input parameter p-tipo       as char.
def input parameter p-recid      as recid.

def buffer bf-del-titulo   for dragao.titulo.
def buffer bf-del-contrato for dragao.contrato.
def buffer bf-del-clispc   for dragao.clispc.



case (p-tipo):
when "titulo"   then run p-deleta-titulo.
when "contrato" then run p-deleta-contrato.
when "clispc"   then run p-deleta-clispc.
end case.

  
  
procedure p-deleta-titulo:

    find first dragao.bf-del-titulo
         where recid(dragao.bf-del-titulo) = p-recid
                exclusive-lock no-wait no-error.

    if avail dragao.bf-del-titulo
    then delete dragao.bf-del-titulo.

end procedure.


  
procedure p-deleta-contrato:

    find first dragao.bf-del-contrato
         where recid(dragao.bf-del-contrato) = p-recid
                exclusive-lock no-wait no-error.

    if avail dragao.bf-del-contrato
    then delete dragao.bf-del-contrato.

end procedure.



  
procedure p-deleta-clispc:

    find first dragao.bf-del-clispc
         where recid(dragao.bf-del-clispc) = p-recid
                  exclusive-lock no-wait no-error.
                             
    if avail dragao.bf-del-clispc
    then do:                             
                            
            delete dragao.bf-del-clispc.
    end.

end procedure.




