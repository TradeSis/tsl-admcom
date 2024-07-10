/*      cerselinc.p     */

{admcab.i}

def input-output parameter par-lotcre as recid.
def input parameter par-lotcretp as recid.
def input parameter par-tipo     as char.
def var p-sel as char format "x(15)" extent 3.
p-sel[1] = "  DUPLICATAS".
p-sel[2] = "  DESPESAS".
p-sel[3] = "  GERAL".
def var vindex as int.
def var vdtini      as date.
def var vdtfim      as date.
def var vdata       as date.
def var vselecao    as char.
def var vtitdtpag like titulo.titdtpag.
find lotcretp where recid(lotcretp) = par-lotcretp no-lock.

if par-tipo = " Selecao "
then do.
    do on error undo with frame f-filtro side-label title lotcretp.LtCreTNom.
        update vdtini colon 15 label "Vencimento de" 
               validate(vdtini <> ? and vdtini >= (today - 7), "")
               vdtfim label "ate" validate(vdtfim >= today, "")
               vtitdtpag label "Data de Pagamento"
                    validate(vtitdtpag <> ? and vtitdtpag >= today, "").
        disp p-sel with frame f-sel no-label 1 down.
        choose field p-sel with frame f-sel.
        vindex = frame-index.
    end.
    vselecao = string(vdtini) + " a " + string(vdtfim).

    for each titulo where /*titulo.empcod   = wempre.empcod and */
                       titulo.titnat
                      /*and titulo.titsit   = "CON" /* confirmados */
                      */
                      and titulo.titdtven >= vdtini
                      and titulo.titdtven <= vdtfim
                      /*and titulo.cobcod   = 3 /* Carteira Bancaria */
                      */
                    no-lock.
  
        if titulo.titsit   = "CON" then. else next.
        if titulo.cobcod   = 3 then. else next.
            
        if vindex = 1 and titulo.modcod <> "DUP"
        then next.
        if vindex = 2 and titulo.modcod = "DUP"
        then next.
            
        find last  titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-lock no-error.


        if not avail titulo2 then next.

        /*message titulo2.formpag titulo2.tippag. pause.
        */

        if titulo2.formpag <> 107
        then next.
        if titulo2.tippag <> 1
        then next.
    
        sresp = no.
        run valida-registro.
        if sresp = yes then next.
        
        if par-lotcre = ?
        then do.
            release lotcre no-error.
            run lotcria.p (input recid(lotcretp),
                           output par-lotcre).
            do on error undo.
                find lotcre where recid(lotcre) = par-lotcre exclusive.
                lotcre.ltselecao = vselecao.
                lotcre.ltcreret = vtitdtpag.
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

procedure valida-registro:
    for each lotcre where ltcredt >= today - 7 no-lock: 
        find first lotcretit where 
                   lotcretit.ltcrecod = lotcre.ltcrecod
                 and lotcretit.clfcod   = titulo.clifor
                 and lotcretit.modcod   = titulo.modcod
                 and lotcretit.etbcod   = titulo.etbcod
                 and lotcretit.titnum   = titulo.titnum
                 and lotcretit.titpar   = titulo.titpar
               no-lock no-error.
        if avail lotcretit
        then do:
            sresp = yes.
            leave.
        end.    
    end.
end procedure.    
