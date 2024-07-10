/* Programa que deleta os lotes enviados para assessoria */
{admcab.i}
def input param par-lotcre as recid.
def var vnumlote as int format "999999999".
find lotcre where recid(lotcre) = par-lotcre.
find lotcretp of lotcre no-lock.

assign vnumlote = lotcre.ltcrecod.


/* TITULOS LP */
if connected ("d") then disconnect d.
run conecta_d.p.
if connected ("d")
then do:
    run ltdellotelp.p (input recid(lotcre)).
    disconnect d.
end.                     
hide message no-pause.
 





for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod.
    
    find titulo where titulo.empcod = wempre.empcod
                  and titulo.titnat = lotcretp.titnat
                  and titulo.modcod = lotcretit.modcod
                  and titulo.etbcod = lotcretit.etbcod
                  and titulo.clifor = lotcretit.clfcod
                  and titulo.titnum = lotcretit.titnum
                  and titulo.titpar = lotcretit.titpar
                  and 
                  (titulo.cobcod   = 11 /* ACCESS */
                  or titulo.cobcod = 12) /* GLOBAL */
                  no-lock no-error.
    
    if not avail titulo then next.

    if avail titulo 
    then do:
    
        message "Lote não pode ser excluido. Titulo " 
        + titulo.titnum + 
        " em cobranca na assessoria" view-as alert-box.
        return. /*sai do programa*/
    end.
end.

for each agtitbra where
         agtitbra.ltcrecod = lotcre.ltcrecod :
    delete agtitbra.
end.
for each agtitfor where
         agtitfor.ltcrecod = lotcre.ltcrecod :
    delete agtitfor.
end.              

for each lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod. 

    delete lotcretit.

end.
for each lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod.

    delete lotcreag.

end.
unix silent value("rm " + lotcre.arqenv + " -f").
delete lotcre. 

message "Lote" vnumlote "excluido" view-as alert-box.
