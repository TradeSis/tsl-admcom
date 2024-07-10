def var vnov as log.
def buffer btitulo for titulo.

def temp-table tt-clien
    field clicod    like clien.clicod
    field novou     as log
    field recidcli  as recid
    index ind01 clicod.

for each tt-clien.
    delete tt-clien.
end.    

for each clien no-lock.
vnov = no.
for each titulo where titulo.titnat = no
                  and titulo.clifor = clien.clicod
                  and titulo.modcod = "CRE"
                      no-lock by titulo.titpar.
    if titulo.titpar < 30
    then next.
    vnov = yes.
    leave.
end.    
if vnov = no
then next.

hide message no-pause.
message clien.clicod titulo.titnum titulo.titpar.

find first tt-clien where tt-clien.clicod = clien.clicod no-error.
if not avail tt-clien
then do:
    hide message no-pause.
    message 333 clien.clicod.
    create tt-clien.
    tt-clien.clicod = clien.clicod.
    tt-clien.novou = vnov.
    tt-clien.recidcli = recid(clien).
end.

end.

for each tt-clien where tt-clien.novou = yes.
 disp tt-clien.
 end.