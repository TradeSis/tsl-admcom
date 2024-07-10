/*edi/edipedid.p*/
def input param par-tabela  as char.
def input param par-recid   as recid.

if par-tabela = "PEDID"
then do on error undo:
    find pedid where recid(pedid) = par-recid no-lock.

    if pedid.clfcod = ? or
       pedid.pedtdc <> 1 or /*12.09*/
       pedid.etbcod = ? or
       pedid.pednum = ?
    then return.    
    
    find edipedid where   edipedid.clfcod = pedid.clfcod and
                          edipedid.pedtdc = pedid.pedtdc and
                          edipedid.etbcod = pedid.etbcod and
                          edipedid.pednum = pedid.pednum
        exclusive no-error.
    if not avail edipedid
    then do:
        create edipedid.
        edipedid.clfcod = pedid.clfcod. 
        edipedid.pedtdc = pedid.pedtdc. 
        edipedid.etbcod = pedid.etbcod. 
        edipedid.pednum = pedid.pednum. 
        edipedid.acao   = "INSERT".
        edipedid.dtinc = today.
        edipedid.hrinc = time. 
    end.
    else do:
        if edipedid.acao = "ENVIADO"
        then edipedid.acao   = "UPDATE".
    end.
    edipedid.dtenvio = ?.
    edipedid.diretorio = "".
    edipedid.arquivo = "".
    edipedid.hrenvio = ?.
    edipedid.dtalt   = today.
    edipedid.hralt   = time.
    
end.
if par-tabela = "LIPED"
then do on error undo:
    find liped where recid(liped) = par-recid no-lock.
    find pedid of liped no-lock.
    if pedid.clfcod = ? or
       pedid.pedtdc = ? or
       pedid.etbcod = ? or
       pedid.pednum = ?
    then return.    
    
    find edipedid where   edipedid.clfcod = pedid.clfcod and
                          edipedid.pedtdc = pedid.pedtdc and
                          edipedid.etbcod = pedid.etbcod and
                          edipedid.pednum = pedid.pednum
        exclusive no-error.
    if not avail edipedid
    then do:
        create edipedid.
        edipedid.clfcod = pedid.clfcod. 
        edipedid.pedtdc = pedid.pedtdc. 
        edipedid.etbcod = pedid.etbcod. 
        edipedid.pednum = pedid.pednum. 
        edipedid.acao   = "INSERT".
        edipedid.dtinc = today.
        edipedid.hrinc = time. 
    end.
    else do:
        if edipedid.acao = "ENVIADO"
        then edipedid.acao   = "UPDATE".
    end.
    edipedid.dtenvio = ?.
    edipedid.dtalt   = today.
    edipedid.hralt   = time.
    
end.

