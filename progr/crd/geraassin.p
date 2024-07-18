def input param p-rec as recid.
def input param p-acao as char.

find contrassin where recid(contrassin) = p-rec exclusive no-wait no-error.
if avail contrassin
then do:
    if p-acao = "HASH1"
    then do:
        contrassin.hash1 = sha1-digest(string(contrassin.contnum),"CHARACTER") no-error.
    end.
    if p-acao = "HASH2"
    then do:
        contrassin.hash2 = sha1-digest(string(contrassin.contnum) + contrassin.idbiometria,"CHARACTER") no-error.
    end.
    
end.
