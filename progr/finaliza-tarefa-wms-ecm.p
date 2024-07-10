def input parameter p-recid    as recid.
def input parameter p-operacao as char.

def buffer buf-wbsdocbase for wbsdocbase. 
def buffer buf-wbsdocbpro for wbsdocbpro.

def var vsituacao-aux as char.

case p-operacao:

    when "Cancelar" then assign vsituacao-aux = "C".
    when "Finalizar" then assign vsituacao-aux = "E".
    
end case.


find first buf-wbsdocbase
     where recid(buf-wbsdocbase) = p-recid
            exclusive-lock no-error.
if avail buf-wbsdocbase
then do:
                                   
    assign buf-wbsdocbase.situacao = vsituacao-aux
           buf-wbsdocbase.dtrettar = today
           buf-wbsdocbase.hrrettar = time.
                                  
    for each buf-wbsdocbpro of buf-wbsdocbase:
        buf-wbsdocbpro.situacao = vsituacao-aux.
    end.
                                   
end.

 