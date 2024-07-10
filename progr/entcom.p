/*   alteracao - 30/10 linha 1903 geracao para alcis  Luciano

#1 04/19 - Projeto ICMS Efetivo
*/
                                                                    
{admcab.i}

def new shared var vALCIS-ARQ-ORECH   as int.

def var vlechave as log.
def var vlexml   as log.
def var vdtemi   as date.
def var simpnota as log format "Sim/Nao".
def var vdesdup as dec.
def var total_nota like plani.platot.
def var desp_acess like movim.movpc.
def var vsenha as int.
def var vv     as int.
def var xx     as char.
def var vestpro as int.
def buffer bmovim for movim.

def new shared temp-table tt-proemail
    field procod like produ.procod.

def NEW shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)".

def var vchave-nfe as char.
def var vdvnfe     as int.
def var perc_dif as dec.
def var total_custo as dec format "->>,>>9.9999".
def var valor_rateio like plani.platot.
def var soma_icm_comdesc like plani.platot.
def var soma_icm_semdesc like plani.platot.
def var total_icm_calc   like movim.movpc.
def var total_pro_calc   like movim.movpc.
def var total_ipi_calc   like movim.movpc.
def var maior_valor like movim.movpc.
def var v-kit as log format "Sim/Nao".
def var libera_nota as log.
def var tranca as log.
def var valor_desconto as dec format ">>,>>9.9999".
def var v-red like clafis.perred.
def buffer bestab for estab.
def var vfre as dec format ">>,>>9.99".
def var voutras like plani.outras.
def buffer btitulo for titulo.
def var vfrecod like frete.frecod.
def var totped like pedid.pedtot.
def var totpen like pedid.pedtot.
def var vcusto as dec format ">>,>>9.9999".

def new shared workfile wfped field rec  as rec.
def buffer xestoq for estoq.

def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.

def temp-table w-movim 
    field wrec    as   recid 
    field codfis    like clafis.codfis 
    field sittri    as char format "xxx"
    field opfcod    like movim.opfcod
    field movqtm    like movim.movqtm 
    field movacfin  like movim.movacfin
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field valbicms  like movim.movbicms
    field movbicms  like movim.movbicms
    field movbicms2 like movim.movbicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999".
    
def workfile wetique
    field wrec as recid
    field wqtd like estoq.estatual.

def var vdesc    like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes as int format ">9".
def var Prazo as int format ">>9".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms .
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete format ">>,>>9.99".
def var vtipo-frete as int label "Tipo Frete".
def var vseguro   like  plani.seguro.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(04)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vprocod   like  produ.procod.
def var vbiss     like  plani.biss.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-procod    like produ.procod no-undo.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def buffer bplani for plani.
def var recpro as recid.
def var ipi_item  like plani.ipi.
def var frete_item like plani.frete.
def var vdifipi as int.
def var frete_unitario like plani.platot.
def var qtd_total as int.
def var vrec as recid.
def buffer bforne for forne.
def var cgc-admcom like forne.forcgc.
def buffer bliped for liped.
def var vtipo as int format "99".
def var vdesval like plani.platot.
def var vobs as char format "x(14)" extent 5.
def var v-ped as int.
def var vnum like pedid.pednum.
def var tipo_desconto as int.

def temp-table waux
    field auxrec as recid.

def temp-table tt-titulo like titulo.

form tt-titulo.titpar
     tt-titulo.titnum
     prazo
     tt-titulo.titdtven
        validate(tt-titulo.titdtven > tt-titulo.titdtemi,
                            "Data para vencimento deve ser maior que emissao.")
     tt-titulo.titvlcob 
     validate(tt-titulo.titvlcob <= vplatot,
                    "Valor da parcela deve ser menor ou igual ao total da NF.")
     with frame ftitulo down centered color white/cyan.
 
form produ.procod column-label "Codigo" format ">>>>>9"
     w-movim.movqtm format ">>>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.subtotal  format ">>>,>>9.99" column-label "Subtot"
     w-movim.valdes format ">>>,>>9.999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     w-movim.movalipi  column-label "IPI"  format ">9.99"
     w-movim.movfre    column-label "Frete" format ">>>,>>9.99"
     with frame f-produ1 row 7 12 down overlay
                centered color white/cyan width 80.

form w-movim.codfis label "NCM"  format "99999999"
     w-movim.sittri label "CST"
     w-movim.opfcod label "CFOP" format "9999"
     v-kit          label "Kit" 
     w-movim.movipi label "Total IPI" 
        with frame f-sittri side-label centered row 10 overlay.

form vprocod      label "Codigo"
     produ.pronom  no-label format "x(23)"
     vprotot1 with frame f-produ centered color message side-label
                        row 6 no-box width 81.

form estab.etbcod label "Filial" colon 15
    estab.etbnom  no-label
    vchave-nfe    label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom    label "Fornecedor" colon 15
    forne.forcod  no-label
    forne.fornom  no-label
    vopccod  label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom  no-label
    vnumero       colon 15
    vserie        label "Serie"
    vpladat colon 15
    vrecdat colon 39
    vfrecod label "Transp." colon 15
    frete.frenom no-label
    vtipo-frete
    vfrete label "Frete"
    with frame f1 side-label width 80 row 4 color white/cyan.

def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.

form vbicms        label "Base Icms"  colon 17
     vicms         label "Valor Icms" colon 50
     vbase_subst   label "Base Icms Subst" colon 17
     v_subst       label "Valor Substituicao" colon 50
     vprotot       label "Tot.Prod."          colon 50
     vfre          label "Frete"  colon 17
     vseguro       label "Seguro" colon 50
     voutras_acess label "Desp.Acessorias" colon 17
     vipi          label "IPI" colon 50
     vplatot       label "Total" format ">>,>>>,>>9.99" colon 50
     with frame f2 overlay row 14 width 80 side-label.

{gnre.i} /* #1 */

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
    prompt-for estab.etbcod with frame f1.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Filial""}

    run p-deleta-tmp.
    
    display estab.etbcod
            estab.etbnom with frame f1.
            
    vetbcod = estab.etbcod.
    
    v-kit = no.
    libera_nota = no.
    
    update vchave-nfe with frame f1.
    
    vserie = "01".
    if length(vchave-nfe) = 44
    then do:
        /* Digito Verificador */
        run nfe_caldvnfe11.p (input dec(substr(vchave-nfe,1,43)),
                              output vdvnfe).
        if substr(vchave-nfe,44,1) <> string(vdvnfe)
        then do.
            message "Chave da NFE invalida" view-as alert-box.
            undo.
        end.
           
        assign cgc-admcom = substring(vchave-nfe,7,14)
               vserie     = string(int(substring(vchave-nfe,23,3)))
               vnumero    = int(substring(vchave-nfe,26,9))
               vlechave   = yes.
    
        display cgc-admcom
                vserie
                vnumero with frame f1.
        run not_nfedistr.p(vetbcod, vchave-nfe, output sresp).
        if not sresp
        then undo.
    end.
    else vlechave  = no.
    
    update cgc-admcom when vlechave = no with frame f1.
    find first forne where forne.forcgc = cgc-admcom
                       and forne.ativo
                     no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.fornom forne.forcod with frame f1.
    
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
    
    run nffped.p (input vrec,
                  0).
    find first wfped no-lock no-error.
    if not avail wfped
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.       
    
    vforcod = forne.forcod.
    
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 4 no-lock.
    else find last opcom where opcom.movtdc = 4 no-lock.
    vopccod = opcom.opccod.

    do on error undo, retry:
        update vopccod with frame f1.
        find opcom where opcom.opccod = vopccod no-lock no-error.
        if not avail opcom or vopccod = "2101"
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
    update vnumero validate( vnumero > 0, "Numero Invalido") when vlechave = no
             with frame f1.
    if vlechave = no
    then run valida-serie.
    disp vserie with frame f1.
    find first plani where plani.numero = vnumero and
                     plani.emite  = vforcod and
                     plani.desti  = estab.etbcod and
                     plani.serie  = vserie and
                     plani.etbcod = estab.etbcod and
                     plani.movtdc = 4 no-lock no-error.
    if avail plani
    then do:
        message "Nota Fiscal Ja Existe".
        undo, retry.
    end.
    
    assign
        vpladat = ?
        vrecdat = today
        vbicms  = 0
        vicms   = 0
        vprotot1 = 0
        vipi    = 0
        vdescpro = 0
        vacfprod = 0
        vplatot = 0
        voutras = 0
        vfre    = 0
        vseguro = 0
        vprotot = 0
        vdesval = 0
        vdesc   = 0
        valor_rateio = 0.        

    if vlechave
    then run xml-retorno.

    find tipmov where tipmov.movtdc = 4 no-lock.
    do on error undo:
        disp vpladat with frame f1.
        pause 0.
        update vpladat when vlexml = no
               with frame f1.
        {valdatnf.i vpladat vrecdat}
    end.

    tranca = yes.
    find autctb where autctb.movtdc = 4 and
                      autctb.emite  = vforcod and
                      autctb.datemi = vpladat and
                      autctb.serie  = vserie  and
                      autctb.numero = vnumero no-lock no-error.
    if avail autctb
    then tranca = no.
    
    update vfrecod with frame f1.
    find frete where frete.frecod = vfrecod no-lock.
    display frete.frenom no-label with frame f1.

    repeat on endkey undo:
        update vtipo-frete format "9"
            help "Informe 0 para CIF(emitente) ou 1 para FOB(destino)"
            with frame f1.
        if vtipo-frete = 0 or
           vtipo-frete = 1
        then leave.
        else message color red/with
            "Informe 0 para CIF(emitente) ou 1 para FOB(destino)"
            view-as alert-box title " Tipo Frete ".
    end.

    if vtipo-frete = 0
    then do:
        update vfrete label "Valor Frete" with frame f1.
    end.
    else vfrete = 0.

    vvencod = vfrecod.
    
    tipo_desconto = 1.
    display "( 1 ) Sem Desconto                           " 
            "( 2 ) Desconto Total na Nota                 " 
            "( 3 ) Percentual de Desconto por Item        " 
            "( 4 ) Valor de Desconto por Val.Unitario     " 
            "( 5 ) Valor de Desconto por Val.Total do Item"
                with frame f-des 1 column centered title "Tipo de Desconto".
                
    do on error undo, retry:
        update tipo_desconto format "9" label "Tipo Desconto"
               with frame f-des1 side-label centered no-box color message.
        if tipo_desconto < 1 or
           tipo_desconto > 5
        then do:
            message "Opcao Invalida".
            undo, retry.
        end.
    end.                    
    if tipo_desconto = 2
    then do on error undo, retry:
        update vdesval label "Desconto Total da Nota"
                    with frame f-des2 side-label centered.
        if vdesval = 0
        then do:
            message "Valor Invalido".
            pause.
            undo, retry.
        end.
    end.
    hide frame f-des2 no-pause.                
    hide frame f-des1 no-pause.
    hide frame f-des  no-pause.

    disp
        vbicms 
        vicms  
        vbase_subst  
        v_subst      
        vprotot
        vfre
        vseguro
        voutras_acess
        vipi
        vplatot
        with frame f2.

    do on error undo, retry:
    do on error undo:
        hide frame f-obs no-pause.

        if vlexml = no
        then update vbicms 
               vicms  
               vbase_subst  
               v_subst      
               vprotot with frame f2.

        valor_rateio = vprotot.
       
        if vbicms = 0 or
           vicms  = 0
        then do:
            vobs[1] = "ICMS DESTACADO".
            vobs[2] = "M.E.".
            vobs[3] = "GAS".
            vobs[4] = "NEW FREE".
            vobs[5] = "SUBST. TRIBUT.".
            
            display "1§ " TO 05 vobs[1] no-label 
                    "2§ " TO 05 vobs[2] no-label 
                    "3§ " TO 05 vobs[3] no-label 
                    "4§ " to 05 vobs[4] no-label
                    "5§ " to 05 vobs[5] no-label
                        with frame f-icms side-label row 5
                                 overlay columns 50.
           
            update vtipo label "Escolha" format "99" 
                   with frame f-icms2 side-label columns 58 row 04 no-box.

            if vtipo <> 1 and
               vtipo <> 2 and
               vtipo <> 3 and
               vtipo <> 4 and
               vtipo <> 5
            then do:
                message "Opcao Invalida".
                undo, retry.
            end.
            if vtipo = 1
            then do:
                vobs[1] = "N§______  DE __/__/__".
                update vobs[1] label "Obs" format "x(21)"
                        with frame f-obs side-label
                                                centered color message.
                if substring(vobs[1],04,1) = "_" or
                   substring(vobs[1],04,1) = ""  or
                   substring(vobs[1],14,1) = "_" or
                   substring(vobs[1],14,1) = ""
                then do:
                    message "Informar nota fiscal".
                    undo, retry.
                end.
            end.
        end.
        
        hide frame f-obs no-pause.
    end.
    
    if vlexml = no
    then do on error undo, retry:
        update vfre with frame f2.
        update vseguro with frame f2.
    end.
    
    do on error undo, retry:
        update voutras_acess when vlexml = no with frame f2.
        if voutras_acess > 0
        then do:
            vsenha = 0.
            xx = string(year(today),"9999")  + 
                 string(month(today),"99") +
                 string(day(today),"99").
            
            vv =  (( (int(xx) * 0.5) - (vnumero * 4))). 

            update vsenha label "Senha" format ">>>>>>>>9"
                   with frame f-senha centered side-label.
            if vv <> vsenha        
            then do:
                message "Senha invalida".
                pause.
                undo, retry.
            end.
        end.        
    end.
    
    hide frame f-senha no-pause.
    if vlexml = no
    then update vipi 
           vplatot with frame f2.
           
    if vbicms = vplatot and
       voutras_acess > 0
    then assign vbiss = voutras_acess
                voutras_acess = 0.
    if tranca
    then do:
        if vforcod = 100725 
        then do: 
            if vplatot <> (vprotot + voutras_acess + vfre + vseguro
                           + vipi + v_subst) 
            then do:     
                message "Valor Total da Nota nao fecha".  
                undo, retry.
            end.
        end. 
        else do:  
            if tipo_desconto = 1 or
               tipo_desconto = 2
            then do:    
                if vplatot <> (vprotot + voutras_acess + vfre +  
                               vseguro +  vipi + v_subst -  vdesval)
                then do:     
                    if (vplatot - vbiss) <> 
                       
                       (vprotot + voutras_acess + vfre + 
                        vseguro +   vipi + v_subst)
                    then do:
                        message "Valor Total da Nota nao fecha".  
                        message vplatot (vprotot + 
                                         voutras_acess +
                                         vfre +    
                                         vseguro + 
                                         vipi +    
                                         v_subst -     
                                         vdesval).
                        pause. 
                        undo, retry.
                    end.
                    else valor_rateio = vprotot + vdesval. 
                end.
                else valor_rateio = vprotot.
            end.
        end.
    end.
    
    hide frame f-obs no-pause.
    clear frame f-produ1 no-pause.
    
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    bl-princ:
    repeat with 1 down:
        hide frame f-produ2 no-pause.
        vprotot1 = 0. 
        clear frame f-produ1 all no-pause.
        for each w-movim where w-movim.movqtm = 0 or
                               w-movim.movpc  = 0 or
                               w-movim.subtotal = 0:
            delete w-movim.
        end.    
        for each w-movim with frame f-produ1:
            find produ where recid(produ) = w-movim.wrec no-lock no-error.
            
            if not avail produ
            then next.
            
            display produ.procod
                    w-movim.movqtm
                    w-movim.valdes
                    w-movim.movdes
                    w-movim.subtotal
                    w-movim.movpc
                    w-movim.movalicms
                    w-movim.movalipi
                    w-movim.movfre  with frame f-produ1.
            down with frame f-produ1.
            pause 0.
            vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
            display vprotot1 with frame f-produ.
        end.
        hide frame f-sittri no-pause.
        libera_nota = no.
        prompt-for vprocod go-on (F5 F6 F8 F9 F4 PF4 
                                  F10 E e C c a A) with frame f-produ.
                                  
        if keyfunction(lastkey) = "end-error" 
        then do:
            /*
            hide frame f-produ no-pause.
            run difnfped.p ( input vrec ) .
            */
            sresp = no.
            message "Confirma Geracao de Nota Fiscal?" update sresp.
            if not sresp
            then do:
                for each w-movim:
                    delete w-movim.
                end.
                vprocod = 0.
                hide frame f-produ1 no-pause.
                hide frame f-produ no-pause.
                undo, return.
            end.
            else do:
                find first w-movim no-error.
                if not avail w-movim and
                (opcom.opccod = "1949"  or
                 opcom.opccod = "2949"  or
                 opcom.opccod = "1922"  or
                 opcom.opccod = "2922") 
                then do:
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms.
                            w-movim.valicms  = w-movim.movicms.
                        end.
                    end.
                    else do:
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms2.
                            w-movim.valicms  = w-movim.movicms2.
                        end.
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then total_pro_calc = vprotot1.
                    else total_pro_calc = vprotot1 - vdesval. 
 
                    hide frame f2 no-pause.
                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910"
                    then run atu-fat-finan.
 
                    libera_nota = yes.
                    leave bl-princ.
                end.
                else do:
                    if v-kit
                    then do:
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.
                    end. 
                      
                    if tranca 
                    then do:
                        if ((vprotot >= vprotot1 - 1) and
                            (vprotot <= vprotot1 + 1)) or
                           ((vprotot >= (vprotot1 - vdesval) - 1) and
                            (vprotot <= (vprotot1 - vdesval) + 1))
                        then.    
                        else do:
                            message "Total dos Produtos nao confere "
                            vprotot vprotot1 vdesval.
                            pause.
                            undo, retry.
                        end.
                    
                        if (((vicms >= soma_icm_comdesc - 1) and
                            (vicms <= soma_icm_comdesc + 1)) or
                           ((vicms >= soma_icm_semdesc - 1) and
                            (vicms <= soma_icm_semdesc + 1))) or 
                           vbase_subst > 0 
                        then.
                        else do:
                            message  "Valor Icms Nao Confere: CAPA= " vicms  
                                     " ITEM C/Desconto= " soma_icm_comdesc 
                                     " ITEM S/DESCONTO= " soma_icm_semdesc.
                            pause. 
                            undo, retry. 
                        end.
                        
                        if ((vipi >= ipi_item - 1) and
                            (vipi <= ipi_item + 1)) 
                        then.
                        else do:
                            message 
                            "IPI Nao Confere CAPA= " vipi " ITEM= " ipi_item. 
                            pause. 
                            undo, retry. 
                        end.
                        
                        if ((vfre >= frete_item - 1) and
                            (vfre <= frete_item + 1)) 
                        then.
                        else do:
                            message  "FRETE Nao Confere CAPA= " 
                                     vfre " ITEM= " frete_item. 
                            pause. 
                            undo, retry. 
                        end.
                    end.
                    
                    if ((vicms >= soma_icm_comdesc - 1) and
                        (vicms <= soma_icm_comdesc + 1)) 
                    then do:
                        total_icm_calc = soma_icm_comdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms.
                            w-movim.valicms  = w-movim.movicms.
                        end.
                    end.
                    else do:
                        total_icm_calc = soma_icm_semdesc.
                        
                        for each w-movim:
                            w-movim.valbicms = w-movim.movbicms2.
                            w-movim.valicms  = w-movim.movicms2.
                        end.
                    end. 
                    if ((vprotot >= vprotot1 - 1) and
                        (vprotot <= vprotot1 + 1)) 
                    then total_pro_calc = vprotot1.
                    else total_pro_calc = vprotot1 - vdesval.
 
                    hide frame f2 no-pause.

                    if opcom.opccod <> "1910" and
                       opcom.opccod <> "2910"
                    then run atu-fat-finan.
 
                    libera_nota = yes.
                    leave bl-princ.
                end.
            end.
        end.
        if lastkey = keycode("a") or lastkey = keycode("A")
        then do:            
            find produ where produ.procod = input vprocod no-lock.
            
            find first w-movim where w-movim.wrec = recid(produ) no-error.

            update w-movim.movacfin label "Acrescimo Financeiro"
                    with frame f-acr side-label centered overlay. 
            
            w-movim.subtotal = w-movim.subtotal + w-movim.movacfin.
            w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
            hide frame f-acr no-pause.
               
            vprotot1 = 0. 
            soma_icm_comdesc = 0. 
            soma_icm_semdesc = 0. 
            ipi_item  = 0.
            frete_item = 0.
            qtd_total = 0. 
            desp_acess = 0.
            for each w-movim: 
                qtd_total = qtd_total + w-movim.movqtm. 
            end.    

            desp_acess = vbiss / qtd_total.

            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock.
                display produ.procod 
                        w-movim.movqtm 
                        w-movim.valdes 
                        w-movim.movdes 
                        w-movim.subtotal 
                        w-movim.movpc 
                        w-movim.movalicms 
                        w-movim.movalipi 
                        w-movim.movfre with frame f-produ1.

                down with frame f-produ1.
                pause 0.
                w-movim.movbicms2 = (w-movim.movqtm * (w-movim.movpc + 
                                                       w-movim.movfre +
                                                       desp_acess)) *
                                   (1 - (v-red / 100)).
                w-movim.movicms2  = w-movim.movbicms2 *
                                   (w-movim.movalicms / 100).

                soma_icm_semdesc = soma_icm_semdesc + w-movim.movicms2. 
            
                if tipo_desconto < 5
                then do:
                    w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc +  
                                                           desp_acess +
                                                           w-movim.movfre -
                                                       w-movim.valdes)) *
                                        (1 - (v-red / 100)).
                    w-movim.movicms  = w-movim.movbicms *
                                        (w-movim.movalicms / 100).

                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms.

                    if w-movim.movalipi <> 0
                    then w-movim.movipi = ((w-movim.movpc + 
                                       w-movim.movfre -
                                       w-movim.valdes) * w-movim.movqtm) * 
                                     (w-movim.movalipi / 100).
                
                    ipi_item = ipi_item + w-movim.movipi.
                    frete_item = frete_item + 
                                 (w-movim.movfre * w-movim.movqtm).
                end.
                else do:
                    w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc + 
                                         desp_acess +
                                         w-movim.movfre -
                                        (w-movim.valdes / w-movim.movqtm))) *
                                        (1 - (v-red / 100)).
                    w-movim.movicms  = w-movim.movbicms  *
                                        (w-movim.movalicms / 100).

                    soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                    if w-movim.movalipi <> 0
                    then w-movim.movipi = ((w-movim.movpc + 
                                            w-movim.movfre -
                                           (w-movim.valdes / w-movim.movqtm)) 
                                           * w-movim.movqtm) * 
                                           (w-movim.movalipi / 100).

                         ipi_item = ipi_item + w-movim.movipi.
                         frete_item = frete_item + 
                                      (w-movim.movfre * w-movim.movqtm).
                end.
                       
                vprotot1 = vprotot1 + w-movim.subtotal.
                display vprotot1 with frame f-produ.
            end.
            next.            
        end.
        if lastkey = keycode("c") or lastkey = keycode("C")
        then do with frame f-produ2:
            run p-consulta.
        end.
        if lastkey = keycode("e") or lastkey = keycode("E")
        then do:
            update v-procod
                   with frame f-exclusao row 6 overlay side-label centered
                   width 80 color message no-box.
            find produ where produ.procod = v-procod no-lock no-error.
            if not avail produ
            then do:
                message "Produto nao Cadastrado".
                undo.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if not avail w-movim
            then do:
                message "Produto nao pertence a esta nota".
                undo.
            end.
            display produ.pronom format "x(35)" no-label with frame f-exclusao.
            if w-movim.movqtm <> 1
            then update vqtd validate( vqtd <= w-movim.movqtm,
                                       "Quantidade invalida" )
                        label "Qtd" with frame f-exclusao.
            else do:
                vqtd = 1.
                display vqtd with frame f-exclusao.
            end.
            find first w-movim where w-movim.wrec = recid(produ) no-error.
            if avail w-movim
            then do:
                if w-movim.movqtm = vqtd
                then delete w-movim.
                else w-movim.movqtm = w-movim.movqtm - vqtd.
                hide frame f-exclusao no-pause.
            end.
            vprotot1 = 0.
            clear frame f-produ1 all no-pause.
            for each w-movim with frame f-produ1:
                find produ where recid(produ) = w-movim.wrec no-lock.
                display produ.procod
                        w-movim.movqtm
                        w-movim.valdes
                        w-movim.movdes
                        w-movim.subtotal
                        w-movim.movpc
                        w-movim.movalicms
                        w-movim.movalipi
                        w-movim.movfre with frame f-produ1.
                down with frame f-produ1.
                pause 0.
                vprotot1 = vprotot1 + (w-movim.movqtm * w-movim.movpc).
                display vprotot1 with frame f-produ.
            end.
            next.
        end.
        
        find produ where produ.procod = input vprocod no-lock no-error.
        if not avail produ and (vhiccod <> 699 and vhiccod <> 599)
        then do:
            message "Produto nao Cadastrado" view-as alert-box.
            undo.
        end.
        
        display produ.pronom when avail produ with frame f-produ.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        display produ.pronom when avail produ with frame f-produ.
        vmovqtm = 0.
        find first w-movim where w-movim.wrec = recid(produ) no-error.
        if not avail w-movim
        then do:
            create w-movim.
            assign w-movim.wrec = recid(produ).
        end.
        vmovqtm = w-movim.movqtm.
       
        do on error undo, retry:
            display produ.procod with frame f-produ1.
           
            w-movim.codfis = produ.codfis.
            pause 0.
            
            update w-movim.codfis with frame f-sittri.
            find clafis where clafis.codfis = w-movim.codfis NO-LOCK no-error.
            if not avail clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            w-movim.sittri = "999".

            update w-movim.sittri validate(can-find(first sittri where
                                        sittri.cst = int(w-movim.sittri)),
                                        "CST nao cadastrada")
                   w-movim.opfcod validate(can-find(first opcom where
                                            opcom.opccod = w-movim.opfcod),
                                   "CFOP nao cadastrada")
                   v-kit with frame f-sittri.
            /* #1 */
            if produ.proipiper = 99 and
               (w-movim.opfcod = 2102 or
                w-movim.opfcod = 2402 or
                w-movim.opfcod = 2404 or
                w-movim.opfcod = 2403 or
                w-movim.opfcod = 2401 or
                w-movim.opfcod = 1102 or
                w-movim.opfcod = 1402 or
                w-movim.opfcod = 1404 or
                w-movim.opfcod = 1403 or
                w-movim.opfcod = 1401)
            then
                if forne.ufecod = "RS"
                then w-movim.opfcod = 1403.
                else w-movim.opfcod = 2403.

            if v-kit
            then do:       
                find autctb where autctb.movtdc = 4 and
                                  autctb.emite  = vforcod and
                                  autctb.datemi = vpladat and
                                  autctb.serie  = vserie  and
                                  autctb.numero = vnumero no-lock no-error.
                if not avail autctb
                then do:
                    assign tranca = no.

                    create autctb.
                    assign autctb.emite  = vforcod 
                           autctb.desti  = estab.etbcod 
                           autctb.movtdc = 4 
                           autctb.serie  = vserie 
                           autctb.Numero = vnumero 
                           autctb.datemi = vpladat 
                           autctb.datexp = today
                           autctb.FunCod = 12
                           autctb.Motivo = "AUTORIZACAO AUTOMATICA KIT" 
                           autctb.hora   = time.
                end.
            end.       
            
            hide frame f-sittri no-pause.
/***
            if clafis.sittri = 0
            then clafis.sittri = int(w-movim.sittri).            
            
            run atu_fis.p( input w-movim.wrec,
                           input clafis.codfis).
***/
        end.

        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or
            w-movim.codfis = 84715010
        then update w-movim.movipi
                    with frame f-sittri.
       
        update w-movim.movqtm with frame f-produ1.
                       
        w-movim.movpc  = estoq.estcusto. 
        w-movim.movqtm = vmovqtm + w-movim.movqtm. 
        display w-movim.movqtm with frame f-produ1. 
        update w-movim.subtotal with frame f-produ1.  
        
        w-movim.movpc = w-movim.subtotal / w-movim.movqtm.
        display w-movim.movpc with frame f-produ1. 

        if tipo_desconto = 2 
        then assign w-movim.movdes = ((vdesval / valor_rateio) * 100) 
                    w-movim.valdes = w-movim.movpc * 
                                     (vdesval / valor_rateio).
            
        display w-movim.valdes
                w-movim.movdes with frame f-produ1.
                    
        if tipo_desconto = 3 
        then do: 
            update w-movim.movdes with frame f-produ1. 
            w-movim.valdes = w-movim.movpc * (w-movim.movdes / 100).
            
            vdesval = vdesval + 
                      ((w-movim.movpc * (w-movim.movdes / 100)) * 
                      w-movim.movqtm).
        end.    
                
        if tipo_desconto = 4 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > w-movim.movpc
            then do:
                message "Informar o Valor do Desconto Unitario". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / w-movim.movpc) * 100).
            vdesval = vdesval + (w-movim.valdes * w-movim.movqtm).
        end.
        
        if tipo_desconto = 5 
        then do on error undo, retry: 
            update w-movim.valdes with frame f-produ1.
            if w-movim.valdes > (w-movim.movpc * w-movim.movqtm)
            then do:
                message "Valor de Desconto Invalido". 
                pause. 
                undo, retry.
            end.    
            w-movim.movdes = ((w-movim.valdes / (w-movim.movpc * 
                                                 w-movim.movqtm)) * 100).
            vdesval = vdesval + w-movim.valdes.
        end.    
        display w-movim.valdes 
                w-movim.movdes with frame f-produ1.
            
        if forne.ufecod = "RS" 
        then
            if today < 01/01/2016
            then w-movim.movalicms = 17. 
            else w-movim.movalicms = 18.
        else w-movim.movalicms = 12. 
        
        update w-movim.movalicms with frame f-produ1.
                    
        if (w-movim.codfis >= 18060000 and 
            w-movim.codfis <= 18069999) or 
            w-movim.codfis = 84715010
        then.
        else do: 
            w-movim.movalipi = clafis.peripi.
            update w-movim.movalipi with frame f-produ1.
        end.
        
        update w-movim.movfre with frame f-produ1.
        
        assign w-movim.movfre = w-movim.movfre / w-movim.movqtm.   
           
        vprotot1 = 0.
        soma_icm_comdesc = 0.
        soma_icm_semdesc = 0. 
        ipi_item  = 0.
        frete_item = 0.
        clear frame f-produ1 all no-pause.
        clear frame f-produ1 all no-pause.
        
        qtd_total = 0.  
        desp_acess = 0. 
        for each w-movim:  
            qtd_total = qtd_total + w-movim.movqtm.  
        end.    

        desp_acess = vbiss / qtd_total.

        for each w-movim:
            find produ where recid(produ) = w-movim.wrec no-lock.
            display produ.procod 
                    w-movim.movqtm 
                    w-movim.valdes 
                    w-movim.movdes 
                    w-movim.subtotal 
                    w-movim.movpc 
                    w-movim.movalicms 
                    w-movim.movalipi 
                    w-movim.movfre with frame f-produ1.

            down with frame f-produ1.
            pause 0.
            find clafis where clafis.codfis = w-movim.codfis no-lock.
            v-red = clafis.perred.

            w-movim.movbicms2 = (w-movim.movqtm * (w-movim.movpc + 
                                                    desp_acess +
                                                   w-movim.movfre)) *
                              (1 - (v-red / 100)).
            w-movim.movicms2  = w-movim.movbicms2 *
                              (w-movim.movalicms / 100).

            soma_icm_semdesc = soma_icm_semdesc + w-movim.movicms2. 
            
            if tipo_desconto < 5
            then do:
                w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc +  
                                                       w-movim.movfre -
                                                       w-movim.valdes +
                                                       desp_acess)) *
                                    (1 - (v-red / 100)).
                w-movim.movicms  = w-movim.movbicms *
                                    (w-movim.movalicms / 100).
 
                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                if w-movim.movalipi <> 0
                then w-movim.movipi = ((w-movim.movpc + 
                                   w-movim.movfre -
                                   w-movim.valdes) * w-movim.movqtm) * 
                                 (w-movim.movalipi / 100).

                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
            end.
            else do:
                w-movim.movbicms = (w-movim.movqtm * (w-movim.movpc + 
                                                        desp_acess + 
                                                        w-movim.movfre - 
                                                      (w-movim.valdes / 
                                                       w-movim.movqtm))) *
                                     (1 - (v-red / 100)).
                w-movim.movicms  = w-movim.movbicms *
                                   (w-movim.movalicms / 100).

                soma_icm_comdesc = soma_icm_comdesc + w-movim.movicms. 

                if w-movim.movalipi <> 0
                then w-movim.movipi = ((w-movim.movpc + 
                                    w-movim.movfre -
                                    (w-movim.valdes / w-movim.movqtm)) 
                                        * w-movim.movqtm) * 
                                   (w-movim.movalipi / 100).

                ipi_item = ipi_item + w-movim.movipi.
                frete_item = frete_item + (w-movim.movfre * w-movim.movqtm).
            end.
                       
            vprotot1 = vprotot1 + w-movim.subtotal.
            display vprotot1 with frame f-produ.
        end.
    end.
    end.
    else sresp = yes.
    if not sresp
    then undo, retry.
    end.
    hide frame f-produ no-pause.
    hide frame f-produ1 no-pause.
    hide frame f2 no-pause.
    if v-ok = yes
    then undo, leave.
    if libera_nota = no
    then do: 
        for each w-movim: 
            delete w-movim.
        end. 
        vprocod = 0. 
        hide frame f-produ1 no-pause. 
        hide frame f-produ no-pause. 
        undo, return.             
    end.

    total_icm_calc = vicms - total_icm_calc.
    total_pro_calc = vprotot - total_pro_calc.
    total_ipi_calc = vipi - ipi_item.
    
    if ((total_icm_calc > 0 and total_icm_calc < 1) or
        (total_icm_calc < 0 and total_icm_calc > -1)) or
       ((total_pro_calc > 0 and total_pro_calc < 1) or
        (total_pro_calc < 0 and total_pro_calc > -1)) or
       ((total_ipi_calc > 0 and total_ipi_calc < 1) or
        (total_ipi_calc < 0 and total_ipi_calc > -1)) 
    then do:    
        recpro = ?.
        maior_valor = 0.
        for each w-movim:
            if w-movim.subtotal > maior_valor
            then assign maior_valor = w-movim.subtotal
                        recpro      = w-movim.wrec.
        end.

        find first w-movim where w-movim.wrec = recpro no-error.
        if avail w-movim
        then do:            
            w-movim.movicms = w-movim.movicms + 
                              (total_icm_calc / w-movim.movqtm).
            w-movim.movpc   = w-movim.movpc   + 
                              (total_pro_calc / w-movim.movqtm).
            w-movim.movipi  = w-movim.movipi  + 
                              (total_ipi_calc / w-movim.movqtm).
        end.
    end.    
   
    qtd_total = 0.
    total_custo = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  

    for each w-movim:
        find produ where recid(produ) = w-movim.wrec no-lock.
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        else do:
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        if w-movim.movalipi = 0 and
           w-movim.movipi > 0  
        then vcusto = vcusto + (w-movim.movipi / movqtm).
           
        total_custo = total_custo + (vcusto * movqtm).        
    end.

    find first w-movim no-error.
    if avail w-movim and tranca 
    then do:
        total_nota = (vplatot - vbiss - v_subst).
        perc_dif = ( 100 - ((total_custo / total_nota) * 100)).

        if perc_dif >= 1 or
           perc_dif <= -1
        then do:
            message "Total Custo: " total_custo          
                    " Total Nota: " total_nota
                    " Diferenca:  " (total_nota - total_custo)
                    " = " ( 100 - ((total_custo / total_nota) * 100))
                    " % ".
            pause.        
            undo, retry.
        end.   

        if total_custo >= total_nota - 1 and
           total_custo <= total_nota + 1
        then.
        else do:
            message "Total Custo: " total_custo          
                    " Total Nota: " total_nota
                    " Diferenca:  " (total_nota - total_custo)
                    " = " ( 100 - ((total_custo / total_nota) * 100))
                    " % ".
            pause.        
            for each w-movim:
                delete w-movim.
            end.    
            undo, retry.
        end.
    end.       

    run trata_gnre. /* #1 */
        
    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.
    if not sresp
    then do:
        hide frame f-produ no-pause.
        hide frame f-produ1 no-pause.
        clear frame f-produ all.
        clear frame f-produ1 all.
        for each w-movim:
            delete w-movim.
        end.
        undo, retry.
    end.
    vdesdup = 0.
 
    do transaction:
        create plani.
        assign plani.etbcod   = estab.etbcod
               plani.cxacod   = frete.forcod
               plani.placod   = vplacod
               plani.biss     = vbiss
               plani.protot   = vprotot
               plani.emite    = vforcod
               plani.bicms    = vbicms
               plani.icms     = vicms
               plani.descpro  = vprotot * (vdesc / 100)
               plani.frete    = vfre
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
               PLANI.DATEXP   = today
               plani.horincl  = time
               plani.hiccod   = int(opcom.opccod)
               plani.notsit   = no
               plani.outras   = voutras
               plani.usercod  = string(sfuncod)
               plani.respfre = if vtipo-frete = 1 then yes
                                               else no
               plani.isenta   = plani.platot - plani.outras - plani.bicms
               plani.ufdes    = vchave-nfe.
        if plani.descprod = 0
        then plani.descprod = vdesval.
        if vtipo = 0
        then plani.notobs[3] = "".
        else plani.notobs[3] = vobs[vtipo].

        find       planiaux where
                   planiaux.movtdc = plani.movtdc and
                   planiaux.etbcod = plani.etbcod and
                   planiaux.emite  = plani.emite  and
                   planiaux.serie  = plani.serie  and
                   planiaux.numero = plani.numero and
                   planiaux.nome_campo = "ProgramaInclusao" and
                   planiaux.valor_campo = "entcom"
                   no-lock no-error.
        if not avail planiaux
        then do:
            create planiaux.
            assign
                planiaux.movtdc = plani.movtdc 
                planiaux.etbcod = plani.etbcod 
                planiaux.emite  = plani.emite  
                planiaux.serie  = plani.serie  
                planiaux.numero = plani.numero 
                planiaux.nome_campo = "ProgramaInclusao"
                planiaux.valor_campo = "entcom".
        end.

        run grava_gnre.

        for each tt-titulo where tt-titulo.titvlcob > 0 no-lock:
            create titulo.
            buffer-copy tt-titulo to titulo.
        end.
    end.

    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-lock.
        find plaped where plaped.pedetb = pedid.etbcod and
                          plaped.plaetb = estab.etbcod and
                          plaped.pedtdc = pedid.pedtdc and
                          plaped.pednum = pedid.pednum and
                          plaped.placod = vplacod      and
                          plaped.serie  = vserie
                    NO-LOCK no-error.
        if not avail plaped
        then do transaction: 
            create plaped.
            assign plaped.pedetb = pedid.etbcod 
                   plaped.plaetb = estab.etbcod 
                   plaped.pedtdc = pedid.pedtdc 
                   plaped.pednum = pedid.pednum 
                   plaped.placod = vplacod 
                   plaped.serie  = vserie 
                   plaped.numero = vnumero 
                   plaped.forcod = forne.forcod.
        end.
    end.
    
    for each wfped:
        create waux.
        assign waux.auxrec = wfped.rec.
    end.

    /****************** atualiza custos ********************/
    qtd_total = 0.
    for each w-movim:
        qtd_total = qtd_total + w-movim.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movim:
    
        if w-movim.movfre > 0
        then do:
            valor_desconto = w-movim.valdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.
             
            vcusto = (w-movim.movpc + w-movim.movfre
                       - valor_desconto) +
                      ( (w-movim.movpc + w-movim.movfre
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).                      
        end.
        else do:
        
            valor_desconto = w-movim.valdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim.valdes / w-movim.movqtm.

            vcusto = (w-movim.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim.movalipi / 100)).
        end.
        find produ where recid(produ) = w-movim.wrec no-error.
        do transaction:
            produ.codfis = w-movim.codfis.
        end.
            
        for each estoq where estoq.procod = produ.procod.
            do transaction:
                estoq.estcusto = vcusto.
            end.    
        end.
    end.
    
    for each w-movim:
    
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = vplacod no-lock.
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim.movqtm.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-lock no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum
                                 no-lock no-error.
                if avail liped
                then do:
                    find first wprodu where wprodu.wpro = liped.procod no-error.
                    if not avail wprodu
                    then do:
                        create wprodu.
                        assign wprodu.wpro = liped.procod.
                    end.
                    wprodu.wqtd = wprodu.wqtd + 1.
                end.
            end.
        end.
        for each wprodu:
            if wprodu.wqtd = 1
            then delete wprodu.
        end.
        vnum = 0.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-lock no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do transaction:
                   vnum = 0.
                   sresp = yes.
                   find first wprodu where wprodu.wpro = liped.procod no-error.
                   if avail wprodu
                   then do:
                        vnum = 0.
                        message "PRODUTO EXISTE EM MAIS DE UM PEDIDO".
                        find produ where produ.procod = liped.procod no-lock.
                        display produ.procod
                                produ.pronom format "x(30)"
                                w-movim.movqtm label "Qtd"
                                    with frame f-l1 side-label width 80.
                        for each waux:
                           find pedid where recid(pedid) = waux.auxrec
                                                                    no-error.
                           find first bliped where
                                      bliped.pedtdc = pedid.pedtdc and
                                      bliped.etbcod = pedid.etbcod and
                                      bliped.procod = produ.procod and
                                      bliped.pednum = pedid.pednum
                                            no-lock no-error.
                           if not avail bliped
                           then next.
                           find first wprodu where wprodu.wpro =
                                            bliped.procod no-error.
                           if not avail wprodu
                           then next.
                           disp pedid.pednum
                                bliped.procod
                                produ.pronom format "x(30)"
                                bliped.lipqtd
                                        with frame f-l2 centered color
                                                message 6 down.
                        end.
                        v-ped = 0.
                        vnum  = pedid.pednum.
                        update vnum label "Pedido"
                               v-ped label "Quantidade"
                                    with frame f-l3 centered
                                            no-box side-label
                                                color message overlay.
                        find first liped where liped.pedtdc = pedid.pedtdc and
                                               liped.etbcod = pedid.etbcod and
                                               liped.procod = produ.procod and
                                               liped.pednum = vnum no-error.
                        if avail liped
                        then liped.lipent = liped.lipent + v-ped.
                   end.
                   else liped.lipent = liped.lipent + w-movim.movqtm.
                end.
            end.
        end.
        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
        do transaction:
            create movim.
            ASSIGN movim.movtdc    = plani.movtdc
                   movim.PlaCod    = plani.placod
                   movim.etbcod    = plani.etbcod
                   movim.movseq    = vmovseq
                   movim.procod    = produ.procod
                   movim.movqtm    = w-movim.movqtm
                   movim.movpc     = w-movim.movpc
                   movim.movbicms  = w-movim.valbicms
                   movim.movicms   = w-movim.valicms
                   movim.movpdes   = w-movim.movdes
                   movim.movdes    = w-movim.valdes
                   movim.movacfin  = w-movim.movacfin
                   movim.MovAlICMS = w-movim.movalicms
                   movim.MovAlIPI  = w-movim.movalipi
                   movim.movipi    = w-movim.movipi
                   movim.movdev    = w-movim.movfre 
                   movim.movdat    = plani.pladat
                   movim.MovHr     = int(time)
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite
                   movim.opfcod    = w-movim.opfcod
                   movim.movcsticms = w-movim.sittri.

            if tipo_desconto = 5
            then movim.movdes = w-movim.valdes / w-movim.movqtm.       
                   
            if w-movim.movfre = 0
            then movim.movdev = frete_unitario.      
            
            delete w-movim.
        end.
    end.

    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        vestpro = 0.
        find last bmovim where bmovim.procod = movim.procod
                           and bmovim.movdat < movim.movdat no-lock no-error.
        if avail bmovim
        then do:
            for each estoq where estoq.etbcod >= 900
                             and estoq.procod = bmovim.procod no-lock:
                if {conv_igual.i estoq.etbcod} then next.
             
                vestpro = vestpro + estoq.estatual.
            end.
            if vestpro = 0 and movim.movqtm > 1
            then do:
                find tt-proemail where 
                     tt-proemail.procod = movim.procod no-error.
                if not avail tt-proemail
                then do:
                    create tt-proemail.
                    assign tt-proemail.procod = movim.procod.
                end.
            end.
        end.
    end.
    
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat no-lock.
        
        run atuest.p(input recid(movim),
                     input "I",
                     input 0).

    end.
    
    /* geracao para alcis */
    if plani.desti = 995
    then run alcis/orech.p (recid(plani)).
    else if plani.desti = 900
        then run alcis/orech-900.p (recid(plani)).

    /*
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            vok = no.
            totped = 0. totpen = 0.
            for each liped of pedid no-lock:
                do transaction:
                    if liped.lipent = 0
                    then pedid.sitped = "A".
                    if liped.lipent <> 0 and
                       liped.lipqtd <> liped.lipent
                    then do:
                        pedid.sitped = "P".
                        leave.
                        vok = yes.
                    end.
                end.
                if vok
                then leave.
            end.
            for each liped of pedid no-lock:
                totped = totped + liped.lipqtd.
                totpen = totpen + liped.lipent.
            end.
            if totped = totpen
            then do transaction:
                pedid.sitped = "F".
            end.
        end.
    end.
    */
    
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-error.
        if avail pedid
        then do:
            for each liped of pedid:
                do transaction:
                    liped.lipsit = "".
                    pedid.sitped = "".
                    if liped.lipent >= (liped.lipqtd - 
                                       (liped.lipqtd * 0.10)) and 
                       liped.lipent <= (liped.lipqtd + (liped.lipqtd * 0.10))
                    then liped.lipsit = "F".
                    else liped.lipsit = "P". 
                    
                    if liped.lipent = 0
                    then liped.lipsit = "A".
                end.
            end.
            
            for each liped of pedid NO-LOCK:
                do transaction:
                    if liped.lipsit = "A"
                    then pedid.sitped = "A".
                    else if liped.lipsit = "P" and
                            pedid.sitped <> "A"
                         then pedid.sitped = "P".
                         else if liped.lipsit = "F" and
                                 pedid.sitped = "" 
                              then pedid.sitped = "F". 
                end.
            end.    
        end.
    end.

    if plani.desti = 995
    then
        for each wfped.
            run alcis/pedch.p (wfped.rec).
        end.
    else if plani.desti = 900
        then for each wfped.
                run alcis/pedch-900.p (wfped.rec).
             end.
                
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
          
    simpnota = no.
    
    /***
    run atu-fat-finan.
    ***/
    
    if opsys = "UNIX"
    then run infrepd1.p (input-output table tt-proemail). 

    if vlechave
    then run not_nfecnfrec.p (recid(plani)).

    message "Nota Fiscal Incluida". pause.
    
    for each w-movim:
        delete w-movim.
    end.

    if plani.desti = 996 or
       plani.desti = 995 or
       plani.desti = 999 or
       plani.desti = 900
    then do:
        run peddis.p (input recid(plani)).
        
        find first wetique no-error.
        if not avail wetique
        then leave.
        message "Confirma emissao de Etiquetas" update sresp.
        if sresp
        then do:
            if opsys = "unix"
            then do:
                if search("/admcom/relat/etique.bat") <> ?
                then do:
                    os-command silent rm -f /admcom/relat/etique.bat.
                    os-command silent rm -f /admcom/relat/cris*.* .
                end.
            end.
            else do:
                if search("c:\temp\etique.bat") <> ?
                then do:
                    dos silent del c:\temp\etique.bat.  
                    dos silent del c:\temp\cris*.* .
                end.
            end.
             
            for each wetique:
                if plani.desti = 996 or plani.desti = 995 or
                   plani.desti = 900
                then run eti_barl.p (input wetique.wrec,
                                     input wetique.wqtd).
                
                else run etique-m2.p (input wetique.wrec,
                                      input wetique.wqtd).
            end.

            if opsys = "unix"
            then os-command silent /admcom/relat/etique.bat.
            else os-command silent c:\temp\etique.bat.
        end.
        for each wetique:
            delete wetique.
        end.
        message "Confirma relatorio de distribuicao" update sresp.
        if sresp
        then run disdep.p (input recid(plani)).
    end.
end.

procedure valida-serie:
    def var vi as int init 0.
    def var vserie-int as int init 0.
    repeat on error undo:
        vi = vi + 1.
        disp with frame f3. pause 0.
        if vi > 1
        then leave.
        else update vserie with frame f1.
        vserie-int = int(vserie).
        vserie = string(vserie-int).
    end.
    if vserie = "0"
    then vserie = "".
end procedure.

procedure p-deleta-tmp:
    for each w-movim:
        delete w-movim.
    end.
    for each wprodu:
        delete wprodu.
    end.
    for each waux:
        delete waux.
    end.
    
    for each tt-proemail.
        delete tt-proemail.
    end.
end procedure.

procedure p-consulta:
            clear frame f-produ2 all no-pause.
            for each w-movim:
                find produ where recid(produ) = w-movim.wrec no-lock no-error.
                if not avail produ
                then next.
                disp produ.procod
                     produ.pronom format "x(30)"
                     w-movim.movqtm format ">>,>>9.99" column-label "Qtd"
                     w-movim.movpc  format ">,>>9.99" column-label "Custo"
                     w-movim.movalicms column-label "ICMS"
                     w-movim.movalipi  column-label "IPI"
                            with frame f-produ2 row 5 9 down  overlay
                              centered color message width 80.
                down with frame f-produ2.
            end.
            pause. undo.
end.

/****/

procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec format ">>,>>>,>>9.99".
    def var vdesval as dec.
    def var prazo as dec.
    def var vtot-tit as dec.
    def var vtot-par as int.
    
    vdtemi = today.
    
    if simpnota
    then do:
        
        for each tt-titulo:
            delete tt-titulo.
        end.    
                do vi = 1 to 20:
                    if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
                    then leave.
                    do transaction:
                        create tt-titulo.
                        assign 
                            tt-titulo.etbcod = estab.etbcod
                            tt-titulo.titnat = yes
                            tt-titulo.modcod = "DUP"
                            tt-titulo.clifor = forne.forcod
                            tt-titulo.titsit = "LIB"
                            tt-titulo.empcod = wempre.empcod
                            tt-titulo.titdtemi = vdtemi
                            tt-titulo.titnum = string(vnumero)
                            tt-titulo.titpar = vi  
                            tt-titulo.titvlcob = dec(acha("VAL-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            titulo.titdtven = date(acha("DTV-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            vezes = vi        
                            vtotpag = vtotpag + tt-titulo.titvlcob
                            .
                    end.
                end.
                run man-titulo.
    end.
    else repeat on endkey undo:
    
        vtotpag = vplatot.

        disp vezes vtotpag label "Total Faturamento" with frame f-pag.
                    update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 6
                title " Informe os dados para faturamento  ".
    
        do on error undo, retry:
            update vtotpag with frame f-pag.
    
            if vtotpag < vplatot
            then do:
                message "Verifique os valores da nota".
                undo, retry.
            end.
            vsaldo = 0.
            
            for each tt-titulo: delete tt-titulo. end.
            
            do i = 1 to vezes:
                
                create tt-titulo.
                assign 
                    tt-titulo.etbcod = estab.etbcod
                    tt-titulo.titnat = yes
                    tt-titulo.modcod = "DUP"
                    tt-titulo.clifor = forne.forcod
                    tt-titulo.titsit = "LIB"
                    tt-titulo.empcod = wempre.empcod
                    tt-titulo.titdtemi = vdtemi
                    tt-titulo.titnum = string(vnumero)
                    tt-titulo.titpar = i.
                    if prazo <> 0
                    then assign 
                             tt-titulo.titvlcob = vtotpag
                             tt-titulo.titdtven = tt-titulo.titdtemi + prazo.
                    else assign 
                             tt-titulo.titvlcob = vtotpag / vezes
                             tt-titulo.titdtven = tt-titulo.titdtemi + 
                                        (30 * i).
                    vsaldo = vsaldo + tt-titulo.titvlcob.
            end.
                     
            hide frame ftitulo no-pause.
            clear frame ftitulo all.
            run man-titulo.
                    
        end.
        vtot-tit = 0.
        vtot-par = 0.
        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + tt-titulo.titvlcob.
                    if tt-titulo.titvlcob > 0
                    then vtot-par = vtot-par + 1.
        end.
        if vtot-par <> vezes
        then do:
            message color red/with
                    "Numero de parcelas " vtot-par 
                    "difere do valor informdo " vezes
                    view-as alert-box.
        end.
        else if vtot-tit = vtotpag
             then leave.
             else do:
                 message color red/with
                        "Total informado " vtotpag
                        "Difere do total parcelado " vtot-tit
                        view-as alert-box.
                        next.
             end.
    end.
end procedure.

procedure man-titulo:

        for each tt-titulo where tt-titulo.empcod = wempre.empcod and
                              tt-titulo.titnat = yes and
                              tt-titulo.modcod = "DUP" and
                              tt-titulo.etbcod = estab.etbcod and
                              tt-titulo.clifor = forne.forcod and
                              tt-titulo.titnum = string(vnumero) and
                              tt-titulo.titdtemi = vdtemi.
            display tt-titulo.titpar
                    tt-titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            repeat on endkey undo, retry:
                update prazo with frame ftitulo.
                tt-titulo.titdtven = vpladat + prazo.
                tt-titulo.titvlcob = vsaldo.
                repeat on endkey undo, retry:
                    update tt-titulo.titdtven
                       tt-titulo.titvlcob 
                       with frame ftitulo no-validate.
                    leave.       
                end.
                leave.
            end.
            vsaldo = vsaldo - tt-titulo.titvlcob.
        
            down with frame ftitulo.
        end.        
        
end procedure.


/********************* 13/10/14
procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec format ">>,>>>,>>9.99".
    def var vdesval as dec.
    def var prazo as dec.
    def var vtot-tit as dec.
    def var vtot-par as int.
    
    if month(today) <> month(plani.dtinclu)
    then vdtemi = today.
    else vdtemi = plani.dtinclu.
    
    find first titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock no-error.
    if not avail titulo
    then do: 
        if plani.hiccod <> 599 and
           plani.hiccod <> 699
        then do:
            if simpnota
            then do:
                do vi = 1 to 20:
                    if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
                    then leave.
                    do transaction:
                        create titulo.
                        assign 
                            titulo.etbcod = plani.etbcod
                            titulo.titnat = yes
                            titulo.modcod = "DUP"
                            titulo.clifor = forne.forcod
                            titulo.titsit = "LIB"
                            titulo.empcod = wempre.empcod
                            titulo.titdtemi = vdtemi
                            titulo.titnum = string(plani.numero)
                            titulo.titpar = vi  
                            titulo.titvlcob = dec(acha("VAL-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            titulo.titdtven = date(acha("DTV-" + 
                                string(vi,"999"),placon.notobs[1])) 
                            vezes = vi        
                            vtotpag = vtotpag + titulo.titvlcob
                            .
                    end.
                end.
                run man-titulo.
            end.
            /*else do on error undo:*/
            else repeat on endkey undo:
    
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              .
                    delete titulo.
                end.          
                release titulo no-error.    

                if plani.platot = 0
                then vtotpag = plani.protot.
                else vtotpag = plani.platot.

                disp vezes vtotpag label "Total Faturamento" with frame f-pag.
                    update vezes label "Parcelas"
                validate(vezes > 0,"Favor informar quantidade de parcelas.")
                with frame f-pag width 80 side-label centered color white/red
                row 7
                title " Informe os dados para faturamento  ".
    
                find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
                if avail movim 
                then do on error undo, retry:
                    update vtotpag with frame f-pag.
    
                    if vtotpag < 
                        (plani.protot + plani.ipi - vdesval - plani.descprod)
                    then do:
                        message "Verifique os valores da nota".
                        undo, retry.
                    end.
                    vsaldo = 0.
                    do i = 1 to vezes:
                        do transaction:
                            create titulo.
                            assign 
                                titulo.etbcod = plani.etbcod
                                titulo.titnat = yes
                                titulo.modcod = "DUP"
                                titulo.clifor = forne.forcod
                                titulo.titsit = "LIB"
                                titulo.empcod = wempre.empcod
                                titulo.titdtemi = vdtemi
                                titulo.titnum = string(plani.numero)
                                titulo.titpar = i.
                            if prazo <> 0
                            then assign 
                                    titulo.titvlcob = vtotpag
                                    titulo.titdtven = titdtemi + prazo.
                            else assign 
                                    titulo.titvlcob = vtotpag / vezes
                                    titulo.titdtven = titulo.titdtemi + 
                                        (30 * i).
                            vsaldo = vsaldo + titulo.titvlcob.
                        end.
                    end.
                    hide frame ftitulo no-pause.
                    clear frame ftitulo all.
                    run man-titulo.
                    
                end.
                vtot-tit = 0.
                vtot-par = 0.
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + titulo.titvlcob.
                    if titulo.titvlcob > 0
                    then vtot-par = vtot-par + 1.
                end.
                if vtot-par <> vezes
                then do:
                    message color red/with
                    "Numero de parcelas " vtot-par 
                    "difere do valor informdo " vezes
                    view-as alert-box.
                end.
                else if vtot-tit = vtotpag
                    then leave.
                    else do:
                        message color red/with
                        "Total informado " vtotpag
                        "Difere do total parcelado " vtot-tit
                        view-as alert-box.
                        next.
                    end.
            end.
        end.
    end.
    else repeat on endkey undo:
        
        vtotpag = plani.platot.
        
        hide frame ftitulo no-pause.
        clear frame ftitulo all.
                            
        run man-titulo.
       
        vtot-tit = 0.
                
                for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock.
                    vtot-tit = vtot-tit + titulo.titvlcob.
                end.
                if vtot-tit = vtotpag
                then leave.
                else do:
                    message color red/with
                    "Total informado " vtotpag
                    "Difere do total parcelado " vtot-tit
                    view-as alert-box.
                end.

    end.
end procedure.

procedure man-titulo:

        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi.
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            repeat on endkey undo, retry:
                update prazo with frame ftitulo.
                titulo.titdtven = plani.pladat + prazo.
                titulo.titvlcob = vsaldo.
                repeat on endkey undo, retry:
                    update titulo.titdtven
                       titulo.titvlcob 
                       with frame ftitulo no-validate.
                    leave.       
                end.
                leave.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.        
        
        /**
        if plani.frete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = plani.emite
                   btitulo.cxacod   = plani.emite
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vdtemi
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = plani.frete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end.
        **/
end procedure.

13/10/14 **************************/

/***********************
procedure atu-fat-finan:
    
    def var vi as int.
    def var i as int.
    def var vezes as int.
    def var vtotpag as dec.
    def var vdesval as dec.
    def var prazo as dec.
    
    if month(today) <> month(plani.dtinclu)
    then vdtemi = today.
    else vdtemi = plani.dtinclu.
    
    find first titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi
                              no-lock no-error.
    if not avail titulo
    then do: 
    if plani.hiccod <> 599 and
       plani.hiccod <> 699
    then do:
    if simpnota = yes
    then do:
        do vi = 1 to 20:
            if acha("DUP-" + string(vi,"999"),placon.notobs[1]) = ?
            then leave.
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = "DUP"
                       titulo.clifor = forne.forcod
                       titulo.titsit = "LIB"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = vdtemi
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = vi  .
                       
                titulo.titvlcob =
                        dec(acha("VAL-" + string(vi,"999"),placon.notobs[1])) 
                       .
                titulo.titdtven =
                        date(acha("DTV-" + string(vi,"999"),placon.notobs[1])) 
                        .
                vezes = vi.        
                vtotpag = vtotpag + titulo.titvlcob.
            end.
        end.
        run man-titulo.
    end.
    else do on error undo:
    
    if plani.platot = 0
    then vtotpag = plani.protot.
    else vtotpag = plani.platot.

    disp vezes vtotpag label "Total Faturamento" with frame f-pag.
    update vezes label "Parcelas"
                with frame f-pag width 80 side-label centered color white/red
                row 7
                title " Informe os dados para faturamento  ".
    


    find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
    if avail movim and (plani.hiccod <> 599 and plani.hiccod <> 699)
    then do on error undo, retry:
        update vtotpag with frame f-pag.
    
        if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod)
        then do:
            message "Verifique os valores da nota".
            undo, retry.
        end.

        do i = 1 to vezes:
            do transaction:
                create titulo.
                assign titulo.etbcod = plani.etbcod
                       titulo.titnat = yes
                       titulo.modcod = "DUP"
                       titulo.clifor = forne.forcod
                       titulo.titsit = "lib"
                       titulo.empcod = wempre.empcod
                       titulo.titdtemi = vdtemi
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = i.
                if prazo <> 0
                then assign titulo.titvlcob = vtotpag
                            titulo.titdtven = titdtemi + prazo.
                else assign titulo.titvlcob = vtotpag / vezes
                            titulo.titdtven = titulo.titdtemi + (30 * i).
                vsaldo = vsaldo + titulo.titvlcob.
            end.
        end.
        run man-titulo.
        
    end.
    end.
    end.
    end.
end procedure.

procedure man-titulo:
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = plani.etbcod and
                              titulo.clifor = plani.emite and
                              titulo.titnum = string(plani.numero) and
                              titulo.titdtemi = vdtemi.
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            update prazo with frame ftitulo.
            do transaction:
                titulo.titdtven = plani.pladat + prazo.
                titulo.titvlcob = vsaldo.
                update titulo.titdtven
                       titulo.titvlcob with frame ftitulo no-validate.
            end.
            vsaldo = vsaldo - titulo.titvlcob.
        
            find titctb where titctb.forcod = titulo.clifor and
                              titctb.titnum = titulo.titnum and
                              titctb.titpar = titulo.titpar no-error.
            if not avail titctb
            then do transaction:
                create titctb.
                ASSIGN titctb.etbcod   = titulo.etbcod
                       titctb.forcod   = titulo.clifor
                       titctb.titnum   = titulo.titnum
                       titctb.titpar   = titulo.titpar
                       titctb.titsit   = titulo.titsit
                       titctb.titvlpag = titulo.titvlpag
                       titctb.titvlcob = titulo.titvlcob
                       titctb.titdtven = titulo.titdtven
                       titctb.titdtemi = titulo.titdtemi
                       titctb.titdtpag = titulo.titdtpag.
            end.
            down with frame ftitulo.
        end.
        /*
        if plani.frete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = plani.emite
                   btitulo.cxacod   = plani.emite
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vdtemi
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = plani.frete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end.
         */
end procedure.
*************************/

procedure xml-retorno.

    def var vdata  as char.
    def var vvalor as dec.
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
/***/        vlexml = yes. /***/
        vvalor = dec(tt-xmlretorno.valor).
        case tt-xmlretorno.tag.
            when "vBC"    then vbicms  = vvalor.
            when "vICMS"  then vicms   = vvalor.
            when "vBCST"  then vbase_subst = vvalor.
            when "vST"    then v_subst = vvalor.
            when "vProd"  then vprotot = vvalor.
            when "vFrete" then vfre    = vvalor.
            when "vIPI"   then vipi    = vvalor.
            when "vOutro" then voutras_acess = vvalor.
            when "vDesc"  then vdesval = vvalor.
            when "vNF"    then vplatot = vvalor.
        end case.
    end.

end procedure.

