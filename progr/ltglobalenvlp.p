def input param par-lotcre as recid.
/* Prorgama que seleciona os titulos LP par envio arquivo de remessa */

def shared temp-table tt-titulo like fin.titulo.

find lotcre where recid(lotcre) = par-lotcre no-lock.

for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                         d.titulo where d.titulo.empcod = 19
                                  and d.titulo.titnat = no
                                  and d.titulo.modcod = lotcretit.modcod
                                  and d.titulo.etbcod = lotcretit.etbcod
                                  and d.titulo.clifor = lotcretit.clfcod
                                  and d.titulo.titnum = lotcretit.titnum
                                  and d.titulo.titpar = lotcretit.titpar
                                no-lock
                   break by lotcretit.spcetbcod /***titulo.etbcod***/
                         by titulo.clifor.

    create tt-titulo.
    buffer-copy d.titulo to tt-titulo.

end.
