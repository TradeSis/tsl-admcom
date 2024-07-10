/*   alteracao - 30/10 linha 597 geracao para alcis   Luciano                */
/*                                                                           */
{admcab.i}

def input parameter par-rec as recid.

def var vmovseq   like movim.movseq.
def var vdesc     like plani.descprod format ">9.99%".
def var vforcod   like forne.forcod.
def var vvencod   like plani.vencod.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var vprotot   like  plani.protot.
def var vfrete    like  plani.frete.
def var voutras   like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotprod  like  plani.protot.
def var vtotnota  like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  plani.opccod.
def var vi        as int.
def var vplacod   like plani.placod.
def var vchave-nfe as char.
def var vdvnfe    as int.
def var vdtaux    as date.
def var vcnpj-aux like forne.forcgc.
def var vlechave  as log.
def var vlexml    as log.

def buffer bplani for plani.
def shared temp-table wfasstec like asstec.

def new shared temp-table tt-movim like movim.

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

for each wfasstec no-lock.
    find asstec where asstec.oscod = wfasstec.oscod no-lock.
    vforcod = asstec.forcod.
    find tt-movim where tt-movim.procod = wfasstec.procod no-error.
    if not avail tt-movim
    then do.
        vmovseq = vmovseq + 1.
        create tt-movim.
        assign
            tt-movim.movseq = vmovseq
            tt-movim.procod = wfasstec.procod.

        find estoq where estoq.etbcod = 999 and
                         estoq.procod = wfasstec.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem:" wfasstec.procod.
            pause.
            undo.
        end.
        tt-movim.movpc = estoq.estcusto.
    end.
    tt-movim.movqtm = tt-movim.movqtm + 1.
end.

find first tt-movim no-lock no-error.
if not avail tt-movim
then do.
    message "Sem produtos" view-as alert-box.
    return.
end.

form
    estab.etbcod  label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe    label "Cod Barras NFE" colon 16 format "x(44)"
    vcnpj-aux     label "Fornecedor" colon 15
    forne.forcod  no-label
    forne.fornom  no-label
    opcom.opccod label "Op. Fiscal" colon 15
    opcom.opcnom no-label
    vnumero colon 15
    vserie  label "Serie" 
    vpladat colon 15
    vrecdat colon 40
    with frame f1 side-label width 80 row 3 color white/cyan.

form
    vbicms   colon 15
    vicms    colon 40
    vprotot  colon 15
    vdesc    colon 40 label "Vlr.Desconto"
    vfrete   colon 15
    vipi     colon 40
    vplatot  colon 15
    with frame f2 side-label row 10 width 80 overlay.

vserie = "U".
do on error undo.
    clear frame f1 no-pause.
    clear frame f2 no-pause.

    find tipmov where tipmov.movtdc = 15 no-lock.

    find estab where estab.etbcod = setbcod no-lock.
    disp estab.etbcod
        estab.etbnom with frame f1.

    assign
        vetbcod   = estab.etbcod
        vcnpj-aux = "".

    update vchave-nfe with frame f1.
    if length(trim(vchave-nfe)) = 44
    then do:                                                       
        /* Digito Verificador */
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message "Chave da NFE invalida" view-as alert-box.
            undo.
        end.
        assign
            vserie    = string(int(substring(vchave-nfe,23,3)))
            vnumero   = int(substring(vchave-nfe,26,9))
            vlechave  = yes.
        if vserie <> "890" /* Avulsa */
        then vcnpj-aux = substring(vchave-nfe,7,14).
/*** ***/
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
/*** ***/
    end.
    else assign
            vlechave = no.

    disp
        vcnpj-aux
        vserie
        vnumero with frame f1.    

    update vcnpj-aux when vcnpj-aux = "" with frame f1.
    find first forne where forne.forcgc = vcnpj-aux
                       and forne.ativo
                     no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrado:" vcnpj-aux.
        undo, retry.
    end.
    display forne.forcod forne.fornom with frame f1.

    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

    find last cpforne where cpforne.forcod = forne.forcod no-lock no-error.
    if avail cpforne
        and date(cpforne.date-1) <> ?
        and date(cpforne.date-1) <= today
        and length(vchave-nfe) <> 44
    then do:    
        message "Fornecedor NFE desde " string(cpforne.date-1,"99/99/9999") skip
                " Informe a chave de acesso do DANFE! " view-as alert-box. 
        undo,retry.
    end.

    vforcod = forne.forcod.
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = tipmov.movtdc no-lock.
    else find last  opcom where opcom.movtdc = tipmov.movtdc no-lock.
    
    display opcom.opccod 
            opcom.opcnom with frame f1.

    display vnumero vserie with frame f1.
    update vnumero when vlechave = no validate(vnumero > 0, "Numero Invalido")
           vserie  when vlechave = no validate(vserie <> "","Serie invalida")
           with frame f1.
    find first plani where plani.numero = vnumero and
                           plani.emite  = vforcod and
                           plani.desti  = estab.etbcod and
                           plani.serie  = vserie and
                           plani.etbcod = estab.etbcod and
                           plani.movtdc = 15 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    assign vbicms  = 0
           vicms   = 0
           vfrete  = 0
           vipi    = 0
           vplatot = 0
           vdesc   = 0
           vrecdat = today.

    if vlechave
    then run xml-retorno.
    
    do on error undo, retry:
        update vpladat when vlexml = no with frame f1.
        {valdatnf.i vpladat vrecdat}
    end.

    run not_nfppro-tt.p.

    display
        vbicms
        vicms
        vfrete
        vipi
        vdesc
        vprotot
        vplatot
        with frame f2.

    if vlexml = no
    then do on error undo with frame f2.
        update vprotot validate (vprotot > 0, "").
        update vdesc.
        vplatot = vprotot - vdesc.
    end.

    assign
        vtotprod = 0
        vtotnota = 0.
    for each tt-movim.
        vtotprod = vtotprod + (tt-movim.movpc * tt-movim.movqtm).
    end.
    vtotnota = vtotprod + vipi - vdesc.

    if vprotot <> vtotprod or
       vplatot <> vtotnota
    then do.
        message "Totais invalidos: Produtos=" vtotprod "Total=" vtotnota
            view-as alert-box.
        undo.
    end.

    sresp = no.
    message "Confirma Inclusao de Nota Fiscal?" update sresp.
    if not sresp
    then undo.

    hide frame f-produ no-pause.
    hide frame f2 no-pause.

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.

    do on error undo:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.descpro  = vdesc
               plani.frete    = vfrete
               plani.desacess = voutras
               plani.ipi      = vipi
               plani.platot   = vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = 15
               plani.desti    = estab.etbcod
               plani.pladat   = vpladat
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = vrecdat
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = no
               plani.ufdes    = vchave-nfe
               plani.outras   = plani.frete  +
                              plani.seguro +
                              plani.vlserv +
                              plani.desacess +
                              plani.ipi   +
                              plani.icmssubst
              plani.isenta = plani.platot - plani.outras - plani.bicms.

        /*** AT ***/
        plani.notobs[1] = "OS:".
        for each wfasstec.
            plani.notobs[1] = plani.notobs[1] + string(wfasstec.oscod) + ",".
        end.

        for each wfasstec.
            find etiqseq of wfasstec no-lock.
            create etiqpla.
            assign
                etiqpla.etbplani = plani.etbcod
                etiqpla.plaplani = plani.placod
                etiqpla.data     = plani.dtincl
                etiqpla.hora     = plani.horincl
                etiqpla.oscod    = wfasstec.oscod
                etiqpla.etopeseq = etiqseq.etopeseq
                etiqpla.etmovcod = etiqseq.etmovcod.
        end.
    end.

    for each tt-movim:
        find plani where plani.etbcod = estab.etbcod and
                         plani.placod = vplacod no-lock.
        create movim.
        ASSIGN movim.movtdc = plani.movtdc
               movim.PlaCod = plani.placod
               movim.etbcod = plani.etbcod
               movim.movseq = tt-movim.movseq
               movim.procod = tt-movim.procod
               movim.movqtm = tt-movim.movqtm
               movim.movpc  = tt-movim.movpc
               movim.movdat = plani.pladat
               movim.emite  = plani.emite
               movim.desti  = plani.desti
               movim.MovHr  = int(time).

        run atuest.p(input recid(movim),
                     input "I",
                     input 0).
    end.
    
    /* geracao para alcis */
    if plani.desti = 995
    then run alcis/orech.p (recid(plani)).

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).

    message "Nota Fiscal Incluida".
    pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
end.


procedure xml-retorno.

    def var vdata as char.
    for each tt-xmlretorno where tt-xmlretorno.root = "ide"
                              or tt-xmlretorno.root = "ICMSTot" no-lock.
/***        vlexml = yes.***/
        case tt-xmlretorno.tag.
            when "dEmi"   then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
            when "vBC"    then vbicms  = dec(tt-xmlretorno.valor).
            when "vICMS"  then vicms   = dec(tt-xmlretorno.valor).
            when "vIPI"   then vipi    = dec(tt-xmlretorno.valor).
            when "vFrete" then vfrete  = dec(tt-xmlretorno.valor).
            when "vDesc"  then vdesc   = dec(tt-xmlretorno.valor).
/*            when "vOutro" then voutras = dec(tt-xmlretorno.valor).*/
            when "vProd"  then vprotot = dec(tt-xmlretorno.valor).
            when "vNF"    then vplatot = dec(tt-xmlretorno.valor).
        end case.
    end.
end procedure.

