/*  consnota.p  */
{admcab.i}

def var vemiclfnom as char.
def var vdesclfnom as char.
def var vemicpfcgc as char.
def var vdescpfcgc as char.

pause 0.

def buffer dev-plani for plani.

def new shared var vALCIS-ARQ-NFGL   as int.

def input parameter par-rec as recid.

def var esqpos1 as int.
def var par-ok as log.
def var vps-valor as char.
def var vnotsit as char.

def buffer cancelador for func.
def buffer bplani for plani.
def var vhora as char.
def var vheader  as char.
def var vpctdescserv    as dec format ">>9.99%" label "Desc.Serv".
def var vpctdescprod    as dec format ">>9.99%" label "Desc.Prod".
def var vtotseguro      as dec.
def var vtotgarantia    as dec.
def var vobs1           as char.
def var vplanihora      as char format "x(5)".

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

find plani where recid(plani) = par-rec no-lock.
find tipmov of plani no-lock.


form header  vheader format "x(80)"
        with frame f-plani1 with no-underline.

form
        plani.emite          colon 9
        vemiclfnom no-label format "x(30)"
        vemicpfcgc no-label format "x(18)"
        plani.serie          colon 9       label "Serie" format "x(4)"
        plani.numero         format ">>>>>>>>>" label "No"
        plani.pladat         format "99/99/99"
        plani.dtinclu        format "99/99/99"   label "Inc"
        vplanihora           no-label
        plani.datexp         label "Exp" format "999999"
        plani.etbcod              colon 9 label "Estab"
        estab.etbnom no-label
        plani.modcod format "x(4)" /***plani.indemi***/         no-label
        vnotsit         format "x(7)" no-label
        plani.cxacod        label "Cx" format ">>9"
        plani.vencod        label "Vnd" format ">>>>>9"
        plani.opccod     label "Op.Com." format ">>>9" colon 9

        plani.movtdc label "TipMov" format ">>9"
        tipmov.movtnom     no-label format "x(20)"
        plani.crecod label "Cond"   format ">9"
        plani.pedcod label "Plano"
        finan.finnom no-label format "x(1)"
        finan.finfat no-label

        plani.desti          colon 9 label "Destinat" format ">>>>>>>>>9"
        vdesclfnom no-label format "x(20)"
        vdescpfcgc no-label format "x(14)"
        plani.plaufemi label "UfEmi"
        plani.plaufdes label "UfDes"

        A01_InfNFe.id    colon 9 label "Chave" format "x(44)"
        plani.NotPed label "Gaiola" format "x(15)"
        with frame f-plani1 width 81 side-label row 3 centered overlay no-box.

form
        plani.biss           colon 11  label "Vl.Tot.Fin"
        plani.bipi           label "Al.IRF" format ">>9.99%" colon 33       
        plani.aliss          label "Al.ISS" to 57
        plani.iss                           colon 63
        plani.vlserv         label "Servicos" colon 11
        plani.descserv       label "Desc.Serv"      colon 37
        vpctdescserv                               colon 63
        /*
        plani.acfserv        label "Acre.Serv"     colon 63
        */
        plani.bicms                              colon 11
        plani.icms                                  colon 37
        plani.bsubst             label "B.Subst"   colon 11
        plani.icmssubst                             colon 37
        plani.ipi                                 colon 63
        plani.protot             label "Produtos"  colon 11
        plani.descpro            label "Desc.Prod"  colon 37
        plani.acfprod            label "Acre.Prod"  colon 63
        plani.respfre            colon 1 no-label format "FOB/CIF"
        plani.frete              label "Frete"     colon 11
        plani.seguro                               colon 37  
        plani.desacess           label "Desp.Aces."     colon 63
        plani.notpis        colon 11
        plani.notcofins     colon 37
        plani.platot                               colon 63
        with frame f-plani2 width 81  side-label
                        row 10 centered no-box overlay.

form
    cancelador.funape colon 15 label "Cancelado Por"
    vhora no-label
    with frame fhicam row 20 overlay color 
                message side-label centered no-box width 81.
form
     plani.notobs[1] format "x(75)" label "Obs" colon 4
     plani.notobs[2] format "x(75)" no-label colon 4
     plani.notobs[3] format "x(75)" no-label colon 4
     with frame fobs row 18 overlay color input side-label no-box width 80.
form
     bplani.numero label "**Cupom Fiscal Vinculado "
     with frame fextra row 8 column 47
                  color input side-label no-box
                                     overlay.
form
     bplani.numero label "**Nota Fiscal Vinculada"
     with frame fextra2 row 8 column 48 no-box
                                     color input side-label
                                     overlay.

form
     dev-plani.numero label "**Nota Fiscal Origem"
     with frame fextraorigem row 7 column 48 no-box
                                     color input side-label
                                     overlay.

form
     dev-plani.numero label "**Nota Fiscal Devolucao"
     with frame fextradevol row 7 column 48 no-box
                                     color input side-label
                                     overlay.

form
    vobs1 no-label format "x(25)"
    plani.seguro   label "Seguro"   to 63      format ">>>9.99"
    plani.isenta   label "Garantia" to 80      format ">>>9.99"
    with frame fgarantia row 9 col 1 no-box side-label
            width 80 color input  overlay.

if avail tipmov
then assign
        vheader = tipmov.movtnom + "  " +  "NOTA FISCAL " .

vheader =  
    fill(" ",integer(string(truncate(((80 - length(vheader)) / 2),0),"999"))) +
    vheader.

    find estab where estab.etbcod  = plani.etbcod no-lock no-error.
    find func where func.funcod = plani.vencod no-lock no-error.
    if not avail func
    then find func where func.funcod = int(plani.usercod) no-lock no-error.

find crepl of plani no-lock no-error.
find estab where estab.etbcod = plani.emite no-lock no-error.

/**
def new shared temp-table tt-docrefer
    field etbcod like plani.etbcod
    field placod like plani.placod
    field numero like plani.numero.

if tipmov.movtdev /* Devolucao */
then do.
    for each docrefer where docrefer.etbcod   = plani.etbcod
                        and docrefer.serierefer = plani.serie
                        and docrefer.numerodr = plani.numero
                      no-lock.
        find first bplani where bplani.etbcod = docrefer.etbcod
                            and bplani.numero = docrefer.numori
                            and bplani.pladat = docrefer.dtemiori
                        no-lock no-error.
        if avail bplani
        then do.
            create tt-docrefer.
            assign
                tt-docrefer.etbcod = bplani.etbcod
                tt-docrefer.placod = bplani.placod
                tt-docrefer.numero = bplani.numero.
        end.
    end.
    find first tt-docrefer no-error.
    if avail tt-docrefer
    then esqcom1[2] = "2.Nf Origem".
end.
else do. /* Origem */
    for each docrefer where docrefer.etbcod   = plani.etbcod
                        and docrefer.serieori = plani.serie
                        and docrefer.numori   = plani.numero
                  no-lock.

        find first bplani where bplani.etbcod = docrefer.etbcod
                            and bplani.numero = docrefer.numerodr
                            and bplani.serie  = docrefer.serierefer
                        no-lock no-error.
        if avail bplani
        then do.
            create tt-docrefer.
            assign
                tt-docrefer.etbcod = bplani.etbcod
                tt-docrefer.placod = bplani.placod
                tt-docrefer.numero = bplani.numero.
        end.
    end.

    find first tt-docrefer no-error.
    if avail tt-docrefer
    then esqcom1[2] = "2.Nf Devolucao".
end.

find first ctdevven where ctdevven.movtdc = plani.movtdc
                      and ctdevven.etbcod = plani.etbcod
                      and ctdevven.placod = plani.placod
                    no-lock no-error.
if avail ctdevven
then esqcom1[2] = "2.Nf Origem".
**/

run mostra-dados.

    run not_nfppro.p (input recid(plani)).

hide frame f-com1       no-pause.
hide frame fobs         no-pause.
hide frame f-plani1     no-pause.
hide frame f-plani2     no-pause.
hide frame fhicam       no-pause.
hide frame fextra2      no-pause.
hide frame fextra       no-pause.
hide frame fgarantia    no-pause.
hide frame fextraorigem no-pause.
hide frame fextradevol  no-pause.
hide frame f-com1 no-pause.


Procedure mostra-dados.

    find planiaux where planiaux.etbcod = plani.etbcod and
                        planiaux.emite  = plani.emite and
                        planiaux.serie  = plani.serie and
                        planiaux.numero = plani.numero and
                        planiaux.nome_campo = "SITUACAO"
                  NO-LOCK no-error.
    if plani.notsit
    then vnotsit = "Aberta".
    else vnotsit = "Fechada".
    if avail planiaux
    then vnotsit = planiaux.valor_campo.

    find A01_InfNFe where
                     A01_InfNFe.etbcod = plani.etbcod and
                     A01_InfNFe.placod = plani.placod
                              no-lock no-error.

if tipmov.movtnota /* Emite */
then do with frame f-plani1.

    if tipmov.movttra
    then do.
        find estab where estab.etbcod = plani.emite no-lock no-error.
        if avail estab
        then assign
               vemiclfnom = estab.etbnom
               vemicpfcgc = estab.etbcgc.

        find estab where estab.etbcod = plani.desti no-lock no-error.
        if avail estab
        then assign
               vdesclfnom = estab.etbnom
               vdescpfcgc = estab.etbcgc.
    end.
    else do.
        find forne where forne.forcod = plani.desti no-lock no-error.
        if avail forne
        then assign
                vdesclfnom = forne.fornom
                vdescpfcgc = forne.forcgc.
    end.

    if tipmov.movtvenda
    then do with frame f-plani1.
        find estab where estab.etbcod = plani.emite no-lock no-error.
        if avail estab
        then assign
               vemiclfnom = estab.etbnom
               vemicpfcgc = estab.etbcgc.

        find clien where clien.clicod = plani.desti no-lock.
        find finan where finan.fincod = plani.pedcod no-lock no-error.
        
        assign
            plani.desti:label = "Cliente"
            vdesclfnom = clien.clinom
            vdescpfcgc = clien.ciccgc.
        if tipmov.movtdev = no
        then plani.NotPed:label = " Cupom".
        
        disp
            finan.finnom when avail finan
            finan.finfat when avail finan no-label
            with frame f-plani1.
    end.
end.
else do.
    find forne where forne.forcod = plani.emite no-lock no-error.
    if avail forne
    then assign
            vemiclfnom = forne.fornom
            vemicpfcgc = forne.forcgc.

    find estab where estab.etbcod = plani.desti no-lock no-error.
    if avail estab
    then assign
           vdesclfnom = estab.etbnom
           vdescpfcgc = estab.etbcgc.
end.

    display
        plani.emite
        vemiclfnom
        vemicpfcgc
                            plani.serie
                            plani.numero
                            plani.pladat
                            plani.datexp
                            plani.modcod /***plani.indemi***/
                            vnotsit
                            plani.plaufemi
                            plani.plaufdes
        plani.cxacod
                            plani.etbcod
                            estab.etbnom when avail estab
                            plani.opccod 
                            plani.movtdc
        plani.crecod
        plani.pedcod
                            tipmov.movtnom when avail tipmov
                            plani.dtinclu
                            string(plani.horinc,"HH:MM") @ vplanihora
        plani.desti
        vdesclfnom
        vdescpfcgc
        plani.notped
        plani.vencod
        with frame f-plani1.
 
    if plani.ufdes <> "" and length(plani.ufdes) = 44
    then disp plani.ufdes @ A01_InfNFe.id with frame f-plani1.
    else if avail A01_InfNFe
         then disp A01_InfNFe.id with frame f-plani1.

color display message /***plani.indemi***/ vnotsit
                      with frame f-plani1.
color display message plani.platot
            with frame f-plani2.
pause 0.

vpctdescserv = if plani.vlserv = 0
               then 0
               else round((plani.descserv / plani.vlserv) * 100,2).
vpctdescprod = if plani.protot = 0
               then 0
               else round((plani.descprod / plani.protot),2) * 100.
            
display plani.biss
        plani.bipi
        plani.aliss
        plani.iss
        plani.vlserv
        plani.descserv
        vpctdescserv
        plani.bicms
        plani.icms
        plani.bsubst
        plani.icmssubst
        plani.protot
        plani.descpro
        if plani.acfprod < 0
        then plani.acfprod * -1
        else plani.acfprod @ plani.acfprod
        /*vpctdescprod*/
        plani.respfre
        plani.frete
        plani.seguro
        plani.desacess + plani.outras @ plani.desacess
        plani.ipi
        plani.notpis
        plani.notcofins
        plani.platot
        with frame f-plani2.

display plani.notobs[1]
        /*plani.notobs[2] + vobs @ */
        plani.notobs[2]
        plani.notobs[3]
        with frame fobs.
pause 0.

end procedure.

procedure altera.

    do on error undo.
        find current plani.
        update
            plani.opccod
            with frame f-plani1 no-validate.
        update
/*            plani.hiccod*/
            plani.frete
            plani.bsubst
            plani.icmssubst
            plani.bicms
            plani.icms
            plani.protot
            plani.platot
            with frame f-plani2 no-validate.
    end.
end procedure.


procedure opcoes.

    def var esqpos  as int init 1.
    def var esqmenu as char format "x(16)" extent 6.

    esqmenu[3] = "Dados".
    if tipmov.movtnota = no
    then do:
        assign
            esqmenu[1] = "Manifestacao NFE"
            esqmenu[5] = "RECADV".
    end.
    else if tipmov.movtvenda
    then assign
            esqmenu[1] = "P2K"
            esqmenu[2] = "Seguros".

    repeat:
        disp with frame f-plani1.
        disp with frame f-plani2.
        disp with frame fobs.
        pause 0.
        disp esqmenu with frame f-menu row screen-lines - 9 no-labels
                          column 60 overlay 1 col title " Opcoes ".
        choose field esqmenu with frame f-menu.
        esqpos = frame-index.
        if keyfunction(lastkey) = "return"
        then do.
            if esqmenu[esqpos] = "Manifestacao NFE"
            then run not_nfecnfrec.p (recid(plani)).
            else if esqmenu[esqpos] = "P2K"
            then do.
                find cmon where cmon.etbcod = plani.etbcod
                            and cmon.cxacod = plani.cxacod
                          no-lock no-error.
                if not avail cmon
                then next.
                find first pdvdoc where pdvdoc.etbcod  = plani.etbcod
                                    and pdvdoc.cmocod  = cmon.cmocod
                                    and pdvdoc.datamov = plani.dtincl
                                    and pdvdoc.placod  = plani.placod
                                  no-lock no-error.
                if avail pdvdoc
                then do.
                    find first pdvmov of pdvdoc no-lock no-error.
                    if avail pdvmov
                    then run dpdv/pdvregp2k.p (recid(pdvmov)).
                end.
            end.
            else if esqmenu[esqpos] = "Seguros"
            then run cdvndseguro.p ("Etbcod=" + string(plani.etbcod) +
                                   "|Placod=" + string(plani.placod)).
            else 
            if esqmenu[esqpos] = "Dados"
            then run not_planiaux.p (recid(plani)).
            else
            if esqmenu[esqpos] = "RECADV"
            then run edi/exprecadv.p (recid(plani)).
        end.
    end.
    hide frame f-menu no-pause.

end procedure.

