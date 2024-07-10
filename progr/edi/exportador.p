def var vdiretoriosaida as char init "/admcom/tmp/edi/".
def var vqtdpedidos     as int  init 10.

def var pok as log.

def var vconta as int.
vconta = 0.

message today string(time,"HH:MM:SS") "Rodando EDI/Exportador.p".
    /* exportador */
    for each edipedid where edipedid.dtenvio = ? 
            no-lock.
        pok = no.
        if edipedid.pedtdc = 1 /*and
             10.10.2019 TODOS */  /*
           (edipedid.clfcod = 185 or
            edipedid.clfcod = 110480 or
            edipedid.clfcod = 11 or
            edipedid.clfcod = 119425 or
            edipedid.clfcod = 118398 or
            edipedid.clfcod = 32) */
        then do:        
            run edi/exporders.p (input recid(edipedid)).
        end.
        else run pok(recid(edipedid)).
    end.                                     


procedure pok.
    def input param prec as recid.
    do on error undo:
        find edipedid where recid(edipedid) = prec exclusive no-wait no-error.
        if avail edipedid
        then do:
            edipedid.acao   = "DESCARTADO".
            edipedid.dtenvio = today.
            edipedid.hrenvio = ?.
        end.
    end.


end procedure.

