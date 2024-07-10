{admcab.i}

def input parameter par-reclotcre  as recid.

def var vdir        as char.
def var varq        as char.
def var vlinha      as char.
def var vtime       as int.
def var vct         as int.
def var vretorno    as char.
def var vcodbarras  as char.

if opsys = "unix"
then vdir = "/admcom/banrisul/titulos/".
else vdir = "l:~\banrisul~\titulos~\".

do on error undo with frame f-filtro side-label
            title " Retorno Banrisul ".
    disp vdir label "Diretorio" colon 15 format "x(45)".
    update vdir.
    update varq label "Arquivo" colon 15 format "x(45)".
end.

if search(vdir + varq) = ?
then do.
    message "Arquivo nao encontrado:" vdir + varq view-as alert-box.
    return.
end.

sresp = no.
message "Processar o retorno  ?" update sresp.
if sresp <> yes
then return.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

vtime = time.
input from value(vdir + varq).
repeat on error undo, next.
    import unformatted vlinha.

    vct = vct + 1.
    disp vct with frame f-proc no-label centered.
    pause 0.
    if substr(vlinha,   8, 1) = "3" and
       substr(vlinha,  14, 1) = "J" 
    then do.
        vcodbarras = "Bar=" + substr(vlinha,  18, 44).
        vretorno   = substr(vlinha, 231, 10).

        find first lotcretit of lotcre where lotcretit.numero = vcodbarras
                              no-error.
        if avail lotcretit
        then do.
            lotcretit.spcretorno = vretorno.
            find titulo where titulo.empcod = wempre.empcod
                          and titulo.titnat = lotcretp.titnat
                          and titulo.modcod = lotcretit.modcod
                          and titulo.etbcod = lotcretit.etbcod
                          and titulo.clifor = lotcretit.clfcod
                          and titulo.titnum = lotcretit.titnum
                          and titulo.titpar = lotcretit.titpar
                        exclusive no-error.
            if avail titulo
            then do.
                titulo.titsit = "ELE". /* Eletronico */
            end.
        end.
    end.

end.
input close.

do on error undo.
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtretorno = today
        lotcre.lthrretorno = vtime
        lotcre.ltfnretorno = sfuncod
        lotcre.arqretorno  = vdir + varq.
end.
find current lotcre no-lock.
/*
message "Arquivo processado: Corretos=" vok "Com erro=" verro
        view-as alert-box.
*/
/*
run spc/cerretrel.p (recid(lotcre)).
*/