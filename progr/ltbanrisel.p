/*      cerselinc.p     */

{admcab.i}

def input-output parameter par-lotcre as recid.
def input parameter par-lotcretp as recid.
def input parameter par-tipo     as char.

def var vdtini      as date.
def var vdtfim      as date.
def var vdata       as date.
def var vselecao    as char.

find lotcretp where recid(lotcretp) = par-lotcretp no-lock.

if par-tipo = " Selecao "
then do.
    do on error undo with frame f-filtro side-label title lotcretp.LtCreTNom.
        update vdtini colon 15 label "Vencimento de" 
               validate(vdtini <> ? and vdtini > today, "")
               vdtfim label "ate" validate(vdtfim > today, "").
    end.
    vselecao = string(vdtini) + " a " + string(vdtfim).

    for each titulo where titulo.empcod   = wempre.empcod
                      and titulo.titnat

                      and titulo.titsit   = "CON" /* confirmados */
                      and titulo.titdtven >= vdtini
                      and titulo.titdtven <= vdtfim
                      and titulo.cobcod   = 3 /* Carteira Bancaria */
                    no-lock.
        if par-lotcre = ?
        then do.
            run lotcria.p (input recid(lotcretp),
                           output par-lotcre).
            do on error undo.
                find lotcre where recid(lotcre) = par-lotcre exclusive.
                lotcre.ltselecao = vselecao.
            end.
            find current lotcre no-lock.
        end.

        run lotagcria.p (input par-lotcre,
                         input recid(titulo)).

        run lottitc.p   (input par-lotcre,
                         input recid(titulo),
                         ?,
                         "" /* por cliente, sitcli.titnum = "" */).
    end.
    if par-lotcre <> ?
    then run value(lotcretp.valida + ".p") (input par-lotcre).
end.

if par-tipo = " Por Cliente "
then do.
    find lotcre where recid(lotcre) = par-lotcre no-lock.
    do on error undo with frame f-cli centered row 4 width 80 side-label.
    end.
end.
