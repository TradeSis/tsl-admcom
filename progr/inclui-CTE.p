{admcab.i}

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento" init today.
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vtipo-frete as int label "Tipo Frete".
def var vseguro   like  plani.seguro.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(03)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vbiss     like  plani.biss.
def var vdown as i.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.

def var vlechave as log.
def var vlexml   as log.
def var vchave-nfe as char.
def var vdvnfe     as int.
def var cgc-admcom like forne.forcgc.

form vetbcod label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe   label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom    label "Fornecedor" colon 15
    forne.forcod no-label
    forne.fornom no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    with frame f1 side-label width 80 row 5 color white/cyan.

def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.
def var simpnota as log format "Sim/Nao".
def var vpro-cod like movcon.procod.
def var ped-filenc like estab.etbcod.
def buffer xestab for estab.
def var vrec as recid.

def buffer bforne for forne.
def buffer bplani for plani.

form vbicms        label "Base Icms"  colon 17    format "zz,zzz,zz9.99"
     vicms         label "Valor Icms" colon 55      format "zz,zzz,zz9.99"
     vbase_subst   label "Base Icms Subst" colon 17  format "zz,zzz,zz9.99"
     v_subst       label "Valor Substituicao" colon 55 format "zz,zzz,zz9.99"
     voutras_acess label "Desp.Acessorias" colon 55 format "zz,zzz,zz9.99"
     vseguro       label "Seguro" colon 55  format "zz,zzz,zz9.99"
     vplatot       label "Total" format "zz,zzz,zz9.99" colon 55
     with frame f2 overlay row 14 width 80 side-label.

vetbcod = setbcod.
do:
    clear frame f1 no-pause.
    clear frame f2 no-pause.
    clear frame f-produ no-pause.
    clear frame f-produ1 no-pause.
    clear frame f-produ2 no-pause.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause .
    hide frame f-produ2  no-pause.
    hide frame f1 no-pause.
    hide frame f2 no-pause.
    update vetbcod with frame f1.
    {valetbnf.i estab vetbcod ""Filial""}
    vetbcod = estab.etbcod.
    
    display vetbcod
            estab.etbnom with frame f1.
    pause 0.        
    
    update vchave-nfe with frame f1.
    
    if length(vchave-nfe) = 44
    then do:
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message "Chave da NFE invalida" view-as alert-box.
            undo.
        end.

        assign cgc-admcom = substring(vchave-nfe,7,14)
               vserie     = string(int(substring(vchave-nfe,23,3)))
               vnumero    = int(substring(vchave-nfe,26,9)).
               vlechave   = yes.
    
        display cgc-admcom
                vserie
                vnumero with frame f1.
        pause.
        /*
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
        */
    end.
    else vlechave = no.

    update cgc-admcom when vlechave = no with frame f1.
    
    find first forne where forne.forcgc = cgc-admcom
                       and forne.ativo
                     no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado.".
        undo, retry.
    end.
    display forne.forcod forne.fornom with frame f1.
    
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
    /***
    run not_notgvlclf.p ("Forne", recid(forne), output sresp).
    if not sresp
    then undo, retry.

    if forne.forcod = 5027
    then do:
        message "Fornecedor Invalido".
        undo, retry.
    end.    
    
    if forne.forpai = 0
    then vrec = recid(forne).
    else do:
        find bforne where bforne.forcod = forne.forpai no-lock no-error.
        if not avail bforne
        then do:
            message "Fornecedor pai nao cadastrado".
            undo, retry.
        end.
        else vrec = recid(bforne).
    end.    
    */
    
    vforcod = forne.forcod.
    
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 40 no-lock.
    else find last opcom where opcom.movtdc = 40 no-lock.
    vopccod = opcom.opccod.

    do on error undo, retry:
        update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom
        then do:
            message "Operacao Fiscal Invalida".
            pause.
            undo, retry.
        end.
    end.                    
    
    vhiccod = int(opcom.opccod).
    display vopccod
            opcom.opcnom with frame f1.
    display vserie with frame f1.
    update vnumero validate(vnumero > 0, "Numero Invalido") when vlechave = no
           with frame f1.
    if vlechave = no
    then run valida-serie.
    disp vserie with frame f1.

    find first plani where plani.numero = vnumero and
                           plani.emite  = vforcod and
                           plani.desti  = estab.etbcod and
                           plani.serie  = vserie and
                           plani.etbcod = estab.etbcod and
                           plani.movtdc = 40 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.

    assign
        vpladat = ?
        simpnota = no
        vbicms  = 0
        vicms   = 0
        vprotot1 = 0
        vipi    = 0
        vdescpro = 0
        vplatot = 0
        vtotal  = 0
        vseguro = 0
        vprotot = 0.
    
    if vlechave
    then run xml-retorno.


    find tipmov where tipmov.movtdc = 40 no-lock.
    vdesc = 0.
    vrecdat = today.
    do on error undo:
        update vpladat when vlexml = no
               with frame f1.
        {valdatnf.i vpladat vrecdat}
    end.
    disp vrecdat with frame f1.

    disp
        vbicms 
        vicms  
        vbase_subst  
        v_subst
        vseguro
        voutras_acess
        vplatot
        with frame f2.

    do on error undo:
        hide frame f-obs no-pause.
    
        if vlexml = no
        then update vbicms 
               vicms  
               vbase_subst  
               v_subst      
               with frame f2.
        
       
        
        hide frame f-obs no-pause.
    end.

    do on error undo, retry:

        update voutras_acess when vlexml = no with frame f2.

    end.

    if vlexml = no
    then update vseguro with frame f2.
 
    update vplatot with frame f2.
    
    hide frame f-senha no-pause.
    
    if vplatot > 0 and vbicms > vplatot
    then do:
        message color red/with
        "Valor BASE DO ICMS nao pode ser maior que o TOTAL DOS PRODUTOS."
        view-as alert-box.
        undo, retry.
    end.        
    
    if vbicms = vplatot and
       voutras_acess > 0
    then assign vbiss = voutras_acess
                voutras_acess = 0.
        
    hide frame f-obs no-pause.
    clear frame f-produ1 no-pause.

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    
    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.placod   = vplacod
               plani.biss     = vbiss
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.descpro  = vprotot * (vdesc / 100)
               plani.seguro   = vseguro
               plani.desacess = voutras_acess
               plani.bsubst   = vbase_subst
               plani.icmssubst = v_subst
               plani.ipi      = vipi
               plani.platot   = vplatot
               plani.serie    = vserie
               plani.numero   = vnumero
               plani.movtdc   = tipmov.movtdc
               plani.desti    = estab.etbcod
               plani.modcod   = tipmov.modcod
               plani.opccod   = int(opcom.opccod)
               plani.vencod   = vvencod
               plani.notfat   = vforcod
               plani.dtinclu  = vrecdat
               plani.pladat   = vpladat
               plani.datexp   = today
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = yes /**Aberta**/
               plani.isenta = plani.platot - plani.outras - plani.bicms
               plani.ufdes  = vchave-nfe
               plani.usercod = string(sfuncod)
               plani.respfre = if vtipo-frete = 2 then yes
                                else no 
               .

    end. 

end.

procedure xml-retorno.

    def var vdata  as char.
    def var vvalor as dec.

    for each tt-xmlretorno where tt-xmlretorno.root = "ide" no-lock.
        disp tt-xmlretorno.
    end.
        
    for each tt-xmlretorno where tt-xmlretorno.root = "ide" no-lock.
        case tt-xmlretorno.tag.
            when "dEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
            when "dhEmi"
            then do.
                vdata   = tt-xmlretorno.valor. /* Ex:2013-03-21 */
                vpladat = date (int(substr(vdata, 6, 2)),
                                int(substr(vdata, 9, 2)),
                                int(substr(vdata, 1, 4))).
            end.
        end case.
    end.

    for each tt-xmlretorno where tt-xmlretorno.root = "ICMSTot" no-lock.
 /***       vlexml = yes.***/
        vvalor = dec(tt-xmlretorno.valor).
        case tt-xmlretorno.tag.
            when "vBC"    then vbicms  = vvalor.
            when "vICMS"  then vicms   = vvalor.
            when "vBCST"  then vbase_subst = vvalor.
            when "vST"    then v_subst = vvalor.
            when "vProd"  then vprotot = vvalor.
            when "vSeg"   then vseguro = vvalor.
            when "vOutro" then voutras_acess = vvalor.
            when "vNF"    then vplatot = vvalor.
        end case.
    end.

end procedure.

