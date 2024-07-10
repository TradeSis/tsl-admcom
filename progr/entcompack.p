/*   alteracao - 30/10 linha 1903 geracao para alcis  Luciano
 *
 * Somente entrada de packs
*/
{admcab.i}

def var par-catcod like categoria.catcod init 41.

def new shared var vALCIS-ARQ-ORECH   as int.

def var vrecimp  as recid.
def var vdesdup as dec.
def var total_nota like plani.platot.
def var desp_acess like movim.movpc.
def var vsenha as int.
def var vv     as int.
def var xx     as char.
def var vestpro as int.
def var vchave-nfe as char.
def var perc_dif as dec.
def var total_custo as dec format "->>,>>9.9999".
def var valor_rateio like plani.platot.
def var soma_icm_comdesc like plani.platot.
def var soma_icm_semdesc like plani.platot.
def var total_icm_calc   like movim.movpc.
def var total_pro_calc   like movim.movpc.
def var total_ipi_calc   like movim.movpc.
def var maior_valor like movim.movpc.
def var libera_nota as log.
def var tranca as log.
def var valor_desconto as dec format ">>,>>9.9999".
def var v-red like clafis.perred.
def var vfre as dec format ">>,>>9.99".
def var vacr as dec format ">,>>9.99".
def var voutras like plani.outras.
def var vfrecod like frete.frecod.
def var totped  like pedid.pedtot.
def var totpen  like pedid.pedtot.
def var vcusto  as dec format ">>,>>9.9999".
def var vpreco  like estoq.estcusto.
def var vdesc   like plani.descprod format ">9.99 %".
def var i as i.
def var Vezes   as int format ">9".
def var Prazo   as int format ">>9".
def var v-ok as log.
def var vforcod like forne.forcod.
def var vsaldo    as dec.
def var vmovqtm   like  movim.movqtm.
def var vvencod   like plani.vencod.
def var vsubtotal like  movim.movqtm.
def var vpladat   like  plani.pladat.
def var vrecdat   like  plani.pladat label "Recebimento".
def var vnumero   like  plani.numero format ">>>>>>>>>>" initial 0.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var vprotot   like  plani.protot.
def var vprotot1  like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vseguro   like  plani.seguro .
def var vdesacess like  plani.desacess.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vtotal    like plani.platot.
def var vetbcod   like  plani.etbcod.
def var vserie    as char format "x(04)".
def var vopccod   like  opcom.opccod.
def var vhiccod   like  plani.hiccod initial 112.
def var vitecod   like  produpai.itecod.
def var vbiss     like  plani.biss.
def var vdown as i.
def var vi as int.
def var vqtd        like movim.movqtm.
def var v-itecod    like produpai.itecod.
def var vmovseq     like movim.movseq.
def var vplacod     like plani.placod.
def var vtotpag      like plani.platot.
def var recpro as recid.
def var ipi_item  like plani.ipi.
def var frete_item like plani.frete.
def var vdifipi as int.
def var frete_unitario like plani.platot.
def var qtd_total as int.
def var vrec as recid.
def var cgc-admcom like forne.forcgc.
def var vcnpj-aux   as character .
def var vtipo as int format "99".
def var vdesval like plani.platot.
def var vobs as char format "x(14)" extent 5.
def var v-ped as int.
def var vnum like pedid.pednum.
def var tipo_desconto as int.

def new shared workfile wfped
    field rec  as rec.

def new shared temp-table tt-proemail
    field procod like produ.procod.

def workfile wprodu
    field wpro like produ.procod
    field wqtd as int.

def temp-table w-filho
    field wrec      as   recid
    field paccod    like pack.paccod
    field procod    like movim.procod
    field movqtm    like movim.movqtm
    field movbicms  like movim.movbicms
    field movicms   like movim.movicms
    field movipi    like movim.movipi
    field movfre    like movim.movpc
    field movdes    like movim.movdes.

def temp-table w-movim-pai
    field wrec      as   recid 
    field paccod    like pack.paccod
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field movacfin  like movim.movacfin
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot"
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movbicms  like movim.movbicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc
    field movpdes   as dec format ">,>>9.9999"
    field movdes    as dec format ">,>>9.9999"
    field protot    like plani.protot
    
    index pack is primary unique wrec paccod.
    
def workfile wetique
    field wrec as recid
    field wqtd as int.

def temp-table waux
    field auxrec as recid.

def buffer bestab for estab.
def buffer xestoq for estoq.
def buffer bforne for forne.
def buffer bliped for liped.
def buffer bmovim for movim.
def buffer bplani for plani.
def buffer btitulo for titulo.

form titulo.titpar
     titulo.titnum
     prazo
     titulo.titdtven
     titulo.titvlcob with frame ftitulo down centered color white/cyan.
     
form vitecod         colon 12 column-label "Codigo"
     produpai.pronom no-label
     w-movim-pai.paccod colon 12
     pack.pacnom     no-label
     pack.modpcod    colon 12
     pack.qtde
     w-movim-pai.codfis    colon 12 label "NCM" format "99999999"
     w-movim-pai.sittri    colon 37 label "Situacao Trib." format "999"
     w-movim-pai.movqtm    colon 12 label "Qtde" format ">>>>9"
                           validate (w-movim-pai.movqtm > 0, "")
     w-movim-pai.movpc     colon 37 label "Val.Unit." format ">>,>>9.99"
                           validate (w-movim-pai.movpc > 0, "")
     w-movim-pai.subtotal  colon 12 label "Subtotal"  format ">>>,>>9.99"
     w-movim-pai.movdes    colon 12 label "Val.Desc"  format ">>,>>9.999"
     w-movim-pai.movpdes   colon 37 label "%Desc" format ">9.9999%"
     w-movim-pai.movbicms  colon 12
     w-movim-pai.movalicms colon 37 label "%ICMS" format ">9.99%"
     w-movim-pai.movicms   colon 60
     w-movim-pai.movipi    colon 12
     w-movim-pai.movalipi  colon 37 label "%IPI"  format ">9.99%"
     w-movim-pai.movfre    colon 12 label "Frete" format ">>,>>9.99"
     with frame f-pai row 11 overlay centered color white/cyan width 80.

form vprotot1
     with frame f-produ centered color message side-label
                        row screen-lines no-box width 80.

form 
    estab.etbcod label "Filial" colon 15
    estab.etbnom no-label
    vchave-nfe   label "Cod Barras NFE" colon 15 format "x(44)"
    cgc-admcom   label "Fornecedor" colon 15
    forne.forcod no-label
    forne.fornom no-label
    vopccod      label "Op. Fiscal" format "9999" colon 15 
    opcom.opcnom no-label
    vnumero      colon 15
    vserie       label "Serie"
    vpladat      colon 49
    vfrecod      label "Transp." colon 15
    frete.frenom no-label
    vfrete       colon 49 label "Frete" format ">,>>9.99"
    with frame f1 side-label width 80 row 4 color white/cyan.
 
def var vbase_subst like plani.bsubst.
def var v_subst     like plani.icmssubst.
def var voutras_acess like plani.platot.
def var vdtaux as date.

form vbicms        column-label "Base Icms" at 1
     vicms         column-label "Icms" format ">>,>>9.99"
     vbase_subst   column-label "Base Icms Subst" 
     v_subst       column-label "Substituicao" 
     vprotot       column-label "Tot.Prod." 
     with frame f-base1 row 12 overlay width 80.

form vfre          column-label "Frete"  at 1     format ">>,>>9.99"
     vseguro       column-label "Seguro"          format ">>,>>9.99"
     voutras_acess column-label "Desp.Acessorias" format ">>,>>9.99"
     vipi          column-label "IPI"   format ">>,>>9.99"
     vplatot       column-label "Total" format ">>>,>>9.99"
     with frame f2 overlay row 17 width 80.

do on error undo with frame f1.
    prompt-for estab.etbcod.
    vetbcod = input frame f1 estab.etbcod.
    {valetbnf.i estab vetbcod ""Filial""}

    display estab.etbcod
            estab.etbnom.

    vetbcod = estab.etbcod.
    libera_nota = no.
    
    update vchave-nfe.
    
    if length(vchave-nfe) = 44
    then do:
        assign vcnpj-aux = substring(vchave-nfe,7,14)
               vserie    = string(int(substring(vchave-nfe,23,3)))
               vnumero   = int(substring(vchave-nfe,26,9)).
    
        find first forne where forne.forcgc = vcnpj-aux
                          no-lock  no-error.
        if avail forne
        then do:        
            assign cgc-admcom = vcnpj-aux.
            display forne.fornom when avail forne
                    vserie
                    vnumero.
        end.        
    end.           
            
    update cgc-admcom.
    find first forne where forne.forcgc = cgc-admcom no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado !!".
        undo, retry.
    end.
    display forne.forcod forne.fornom.
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

    vdesval = 0.
    vdesc   = 0.
    valor_rateio = 0.
             
    run nffped.p (input vrec,
                  par-catcod).
    find first wfped no-lock no-error.
    if not avail wfped
    then do:
        message "Para continuar selecione pelo menos um pedido".
        undo.
    end.       

    vforcod = forne.forcod.
    vserie  = "01".
    if forne.ufecod = "RS"
    then find first opcom where opcom.movtdc = 4 no-lock.
    else find last opcom where opcom.movtdc = 4 no-lock.
    vopccod = opcom.opccod.

    do on error undo, retry:
        update vopccod.
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
            opcom.opcnom
            vserie.
    update vnumero validate( vnumero > 0, "Numero Invalido").
    run valida-serie.
    disp vserie.
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

    find tipmov where tipmov.movtdc = 4 no-lock.
    vdesc   = 0.
    vpladat = ?.
    vrecdat = today.
    do on error undo:
        update vpladat.
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
    
    update vfrecod.
    find frete where frete.frecod = vfrecod no-lock.
    display frete.frenom no-label.
    update vfrete.
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
                with frame f-des1 side-label centered no-box
                       color message.
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
    
    do on error undo, retry:
    assign
    /***
           vbicms  = 0
           vicms   = 0
           vipi    = 0
           vplatot = 0
    ***/        
           vprotot1 = 0
           vdescpro = 0
           vacfprod = 0
           vtotal  = 0
           voutras = 0
           vacr    = 0
/***
           vfre    = 0
           vseguro = 0
           vprotot = 0
***/
           .
    do on error undo:
        hide frame f-obs no-pause.
    
        update vbicms 
               vicms  
               vbase_subst  
               v_subst      
               vprotot with frame f-base1.

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
                           with frame f-icms2 side-label columns 58
                                           row 04 no-box. 
            
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
    
    update vfre
        vseguro with frame f2.
    
    do on error undo, retry:
        update voutras_acess with frame f2.
        if voutras_acess > 0
        then do:
            vsenha = 0.
            xx = string(year(today),"9999") +
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

    update vipi 
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
                if vplatot <> (vprotot + voutras_acess +   vfre +  
                               vseguro +  vipi +   v_subst -  vdesval)
                then do:     
                    if (vplatot - vbiss) <> 
                       (vprotot + voutras_acess + vfre + 
                        vseguro +   vipi +    v_subst)
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
    end.
end.

    hide frame f-obs no-pause.

/*
*
*    w-movim-pai.p    -    Esqueleto de Programacao    com esqvazio
*
*/ 
 
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].

form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels column 1 centered overlay.

assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find w-movim-pai where recid(w-movim-pai) = recatu1 no-lock.
    if not available w-movim-pai
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(w-movim-pai).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available w-movim-pai
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find w-movim-pai where recid(w-movim-pai) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field w-movim-pai.paccod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail w-movim-pai
                    then leave.
                    recatu1 = recid(w-movim-pai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail w-movim-pai
                    then leave.
                    recatu1 = recid(w-movim-pai).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail w-movim-pai
                then next.
                color display white/red w-movim-pai.paccod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail w-movim-pai
                then next.
                color display white/red w-movim-pai.paccod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
        if keyfunction(lastkey) = "end-error"
        then do.
            sresp = no.
            message "Confirma Inclusao de Nota Fiscal?" update sresp.
            if sresp
            then run grava-nf (output sresp).
            else message "Sair?" update sresp.
            if sresp
            then leave bl-princ.
            else next.
        end.        
        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do.
                    run inclusao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pai.
                    disp w-movim-pai
                         except wrec valicms movicms2 protot movacfin.
                end.
/***
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-w-movim-pai on error undo.
                    find w-movim-pai where
                            recid(w-movim-pai) = recatu1 
                        exclusive.
                    update w-movim-pai.
                end.
***/
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    sresp = no.
                    message "Confirma Exclusao de" w-movim-pai.paccod "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next w-movim-pai where true no-error.
                    if not available w-movim-pai
                    then do:
                        find w-movim-pai where recid(w-movim-pai) = recatu1.
                        find prev w-movim-pai where true no-error.
                    end.
                    recatu2 = if available w-movim-pai
                              then recid(w-movim-pai)
                              else ?.
                    find w-movim-pai where recid(w-movim-pai) = recatu1
                            exclusive.
                    delete w-movim-pai.
                    recatu1 = recatu2.
                    leave.
                end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(w-movim-pai).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-produ no-pause.
hide frame f1      no-pause.


procedure frame-a.

    find produpai where recid(produpai) = w-movim-pai.wrec no-lock no-error.

    display
        produpai.itecod       column-label "Codigo"
        w-movim-pai.paccod
        w-movim-pai.movqtm    column-label "Qtde"    format ">>>>9" 
        w-movim-pai.movpc     column-label "Vl.Unit" format ">>>>9.99"
        w-movim-pai.subtotal  column-label "Subtot"  format ">>>>>9.99"
        w-movim-pai.movdes    column-label "Vl.Desc" format ">>>9.99" 
        w-movim-pai.movpdes   column-label "%Desc"   format ">9.99" 
        w-movim-pai.movalicms column-label "ICMS"    format ">9.99"
        w-movim-pai.movalipi  column-label "IPI"     format ">9.99"
        w-movim-pai.movfre    column-label "Frete"   format ">>>9.99"
        with frame frame-a 5 down centered color white/red row 11.
end procedure.

procedure color-message.
    color display message
        produpai.itecod
        w-movim-pai.paccod
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        produpai.itecod
        w-movim-pai.paccod
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then   find first w-movim-pai no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then   find next w-movim-pai  no-lock no-error.
             
if par-tipo = "up" 
then   find prev w-movim-pai  no-lock no-error.
        
end procedure.


procedure inclusao.

    clear frame f-pai all.

    do on error undo with frame f-pai side-label.
        update vitecod.

        find produpai where produpai.itecod = vitecod no-lock no-error.
        if not avail produpai
        then do:
            message "Produto PAI nao Cadastrado" view-as alert-box.
            undo.
        end.

        find first pack of produpai no-lock no-error.
        if not avail pack
        then do.
            message "Sem pack vinculado ao produto PAI" view-as alert-box.
            undo.
        end.

        display produpai.pronom no-label.

        find first produ of produpai where produ.corcod <> "" no-lock no-error.
        find estoq where estoq.etbcod = 999 and
                         estoq.procod = produ.procod no-lock no-error.
        if not available estoq
        then do:
            message "Produto Sem Registro de Armazenagem".
            pause.
            undo.
        end.

        run cad_pack.p (recid(produpai), "Zoom").
        if sretorno = ""
        then undo.
        find pack where pack.paccod = int(sretorno) no-lock.

        v-ok = no.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-lock.
            find first lipedpai of pedid
                                where lipedpai.paccod = pack.paccod
                                no-lock no-error.
            if avail lipedpai
            then do.
                v-ok = yes.
                leave.
            end.
        end.
        if not v-ok
        then do.
            message "Pack nao esta nos pedidos selecionados"
                view-as alert-box.
            undo.
        end.

        find first w-movim-pai where w-movim-pai.wrec   = recid(produpai)
                                 and w-movim-pai.paccod = pack.paccod
                               no-error.
        if not avail w-movim-pai
        then do:
            create w-movim-pai.
            assign w-movim-pai.wrec   = recid(produpai)
                   w-movim-pai.paccod = pack.paccod.
        end.

        vsubtotal = 0.
        vmovqtm = w-movim-pai.movqtm.

        w-movim-pai.paccod = pack.paccod.
        disp
            w-movim-pai.paccod
            pack.pacnom
            pack.modpcod
            pack.qtde.
        w-movim-pai.movqtm:label  = "Qtd.Packs".
        w-movim-pai.movqtm:format = ">>9".
       
        do on error undo, retry:
            w-movim-pai.codfis = produ.codfis.
            pause 0.
            
            update w-movim-pai.codfis.
            find clafis where clafis.codfis = w-movim-pai.codfis no-error.
            if not avail clafis
            then do:
                message "Classificacao Fiscal Nao Cadastrada".
                pause.
                undo, retry.
            end.
            w-movim-pai.sittri = clafis.sittri.

            update w-movim-pai.sittri. 

            clafis.sittri = w-movim-pai.sittri.            

            for each produ of produpai.
                produ.codfis = clafis.codfis.
            end.
        end.         

        update w-movim-pai.movqtm.

        if w-movim-pai.movpc = 0
        then w-movim-pai.movpc = estoq.estcusto. 
/*       
        w-movim-pai.movqtm = vmovqtm + w-movim-pai.movqtm. 
        display w-movim-pai.movqtm.
        update w-movim-pai.subtotal.
        w-movim-pai.movpc = w-movim-pai.subtotal / w-movim-pai.movqtm.
        display w-movim-pai.movpc.
*/
        update w-movim-pai.movpc.
        w-movim-pai.subtotal = w-movim-pai.movqtm * pack.qtde
                               * w-movim-pai.movpc.
        disp w-movim-pai.subtotal.

        if (w-movim-pai.codfis >= 18060000 and 
            w-movim-pai.codfis <= 18069999) or
            w-movim-pai.codfis = 84715010
        then update w-movim-pai.movipi.

        if tipo_desconto = 2 
        then assign w-movim-pai.movpdes = ((vdesval / valor_rateio) * 100) 
                    w-movim-pai.movdes = w-movim-pai.movpc * 
                                     (vdesval / valor_rateio).

        if tipo_desconto = 3 
        then do: 
            update w-movim-pai.movpdes.
            w-movim-pai.movdes = w-movim-pai.movpc * 
                                 (w-movim-pai.movpdes / 100).
            
            vdesval = vdesval + 
                      ((w-movim-pai.movpc * (w-movim-pai.movpdes / 100)) * 
                      w-movim-pai.movqtm).
        end.    
                
        if tipo_desconto = 4 
        then do on error undo, retry: 
            update w-movim-pai.movdes.
            if w-movim-pai.movdes > w-movim-pai.movpc
            then do:
                message "Informar o Valor do Desconto Unitario". 
                pause. 
                undo, retry.
            end.    
            w-movim-pai.movpdes = (w-movim-pai.movdes / w-movim-pai.movpc)
                                * 100.
            vdesval = vdesval + (w-movim-pai.movdes * w-movim-pai.movqtm).
        end.
        
        if tipo_desconto = 5 
        then do on error undo, retry: 
            update w-movim-pai.movdes.
            if w-movim-pai.movdes > (w-movim-pai.movpc * w-movim-pai.movqtm)
            then do:
                message "Valor de Desconto Invalido". 
                pause. 
                undo, retry.
            end.    
            w-movim-pai.movpdes = ((w-movim-pai.movdes / (w-movim-pai.movpc * 
                                                 w-movim-pai.movqtm)) * 100).
            vdesval = vdesval + w-movim-pai.movdes.
        end.    

        display w-movim-pai.movdes 
                w-movim-pai.movpdes.

        if forne.ufecod = "RS" 
        then w-movim-pai.movalicms = 17. 
        else w-movim-pai.movalicms = 12. 
        
        update w-movim-pai.movalicms.
                    
        if (w-movim-pai.codfis >= 18060000 and 
            w-movim-pai.codfis <= 18069999) or 
            w-movim-pai.codfis = 84715010
        then.
        else do: 
            w-movim-pai.movalipi = clafis.peripi.
            update w-movim-pai.movalipi.
        end.
        
        update w-movim-pai.movfre.
        
        assign w-movim-pai.movfre = w-movim-pai.movfre / w-movim-pai.movqtm.   
 
        run impostos.
    end.
    hide frame f-pai no-pause.

end procedure.


procedure grava-nf.

    def output parameter par-ok as log init no.

    def var vperc as dec.

    run impostos.

    find first w-movim-pai no-error.
    if not avail w-movim-pai and
       (opcom.opccod = "1949"  or
        opcom.opccod = "2949"  or
        opcom.opccod = "1922"  or
        opcom.opccod = "2922") 
    then do:
        if ((vicms >= soma_icm_comdesc - 1) and
            (vicms <= soma_icm_comdesc + 1)) 
        then do:
            total_icm_calc = soma_icm_comdesc.
            for each w-movim-pai:
                w-movim-pai.valicms = w-movim-pai.movicms.
            end.
        end.
        else do:                        
            total_icm_calc = soma_icm_semdesc.
            for each w-movim-pai:
                w-movim-pai.valicms = w-movim-pai.movicms2.
            end.
        end. 
        if ((vprotot >= vprotot1 - 1) and
            (vprotot <= vprotot1 + 1)) 
        then total_pro_calc = vprotot1.
        else total_pro_calc = vprotot1 - vdesval.
        libera_nota = yes.
    end.
    else do:
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
                message "Valor Icms Nao Confere: CAPA= " vicms  
                        " ITEM C/Desconto= " soma_icm_comdesc 
                        " ITEM S/DESCONTO= " soma_icm_semdesc.
                pause.
                undo, retry.
            end.

            if ((vipi >= ipi_item - 1) and
                (vipi <= ipi_item + 1)) 
            then.
            else do:
                message "IPI Nao Confere CAPA= " vipi " ITEM= " ipi_item.
                pause.
                undo, retry.
            end.

            if ((vfre >= frete_item - 1) and
                (vfre <= frete_item + 1))
            then.
            else do:
                message "FRETE Nao Confere CAPA= " vfre " ITEM= " frete_item.
                pause.
                undo, retry.
            end.
        end.
                    
        if ((vicms >= soma_icm_comdesc - 1) and
            (vicms <= soma_icm_comdesc + 1)) 
        then do:
            total_icm_calc = soma_icm_comdesc.
            for each w-movim-pai:
                w-movim-pai.valicms = w-movim-pai.movicms.
            end.
        end.
        else do:
            total_icm_calc = soma_icm_semdesc.
            for each w-movim-pai:
                w-movim-pai.valicms = w-movim-pai.movicms2.
            end.
        end. 

        if ((vprotot >= vprotot1 - 1) and
            (vprotot <= vprotot1 + 1))
        then total_pro_calc = vprotot1.
        else total_pro_calc = vprotot1 - vdesval.

        libera_nota = yes.
    end.

    if libera_nota = no
    then return.

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
        for each w-movim-pai:
            if w-movim-pai.subtotal > maior_valor
            then assign maior_valor = w-movim-pai.subtotal
                        recpro      = w-movim-pai.wrec.
        end.

        find first w-movim-pai where w-movim-pai.wrec = recpro no-error.
        if avail w-movim-pai
        then do:
            w-movim-pai.movicms = w-movim-pai.movicms + 
                              (total_icm_calc / w-movim-pai.movqtm).
            w-movim-pai.movpc   = w-movim-pai.movpc   + 
                              (total_pro_calc / w-movim-pai.movqtm).
            w-movim-pai.movipi  = w-movim-pai.movipi  + 
                              (total_ipi_calc / w-movim-pai.movqtm).
        end.
    end.    
   
    qtd_total   = 0.
    total_custo = 0.
    for each w-movim-pai:
        qtd_total = qtd_total + w-movim-pai.movqtm.
    end.    
    
    frete_unitario = vfre / qtd_total.  

    for each w-movim-pai:
        find produpai where recid(produpai) = w-movim-pai.wrec no-lock.
        find pack of produpai no-lock.

        if w-movim-pai.movfre > 0
        then do:
            valor_desconto = w-movim-pai.movdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim-pai.movdes / w-movim-pai.movqtm.
             
            vcusto = (w-movim-pai.movpc + w-movim-pai.movfre
                       - valor_desconto) +
                      ( (w-movim-pai.movpc + w-movim-pai.movfre
                       - valor_desconto) *
                        (w-movim-pai.movalipi / 100)).                      
        end.
        else do:
            valor_desconto = w-movim-pai.movdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim-pai.movdes / w-movim-pai.movqtm.

            vcusto = (w-movim-pai.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim-pai.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim-pai.movalipi / 100)).
        end.
        total_custo = total_custo + (vcusto * w-movim-pai.movqtm * pack.qtde).
    end.

    find first w-movim-pai no-error.
    if avail w-movim-pai and tranca 
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
            for each w-movim-pai:
                delete w-movim-pai.
            end.    
            undo, retry.
        end.
    end.       

    find estab where estab.etbcod = vetbcod no-lock.
    find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
    if not avail bplani
    then vplacod = 1.
    else vplacod = bplani.placod + 1.

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
               plani.acfprod  = vacr
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
               plani.isenta   = plani.platot - plani.outras - plani.bicms
               plani.ufdes    = vchave-nfe.
        if plani.descprod = 0
        then plani.descprod = vdesval.
        if vtipo = 0
        then plani.notobs[3] = "".
        else plani.notobs[3] = vobs[vtipo].
    end.

    for each wfped: /* somente 1 pedido */
        find pedid where recid(pedid) = wfped.rec no-lock.
        find plaped where plaped.pedetb = pedid.etbcod and
                          plaped.plaetb = estab.etbcod and
                          plaped.pedtdc = pedid.pedtdc and
                          plaped.pednum = pedid.pednum and
                          plaped.placod = vplacod      and
                          plaped.serie  = vserie
                    no-error.
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
    for each w-movim-pai:
        qtd_total = qtd_total + w-movim-pai.movqtm. /*** ??? ***/
    end.    
    
    frete_unitario = vfre / qtd_total.  
    
    for each w-movim-pai:
    
        if w-movim-pai.movfre > 0
        then do:
            valor_desconto = w-movim-pai.movdes.
            
            if tipo_desconto = 5
            then valor_desconto = w-movim-pai.movdes / w-movim-pai.movqtm.
             
            vcusto = (w-movim-pai.movpc + w-movim-pai.movfre
                       - valor_desconto) +
                      ( (w-movim-pai.movpc + w-movim-pai.movfre
                       - valor_desconto) *
                        (w-movim-pai.movalipi / 100)).                      
        end.
        else do:
            valor_desconto = w-movim-pai.movdes.
            if tipo_desconto = 5
            then valor_desconto = w-movim-pai.movdes / w-movim-pai.movqtm.

            vcusto = (w-movim-pai.movpc + frete_unitario
                       - valor_desconto) +
                      ( (w-movim-pai.movpc + frete_unitario
                       - valor_desconto) *
                        (w-movim-pai.movalipi / 100)).
        end.

        for each estoq where estoq.procod = produ.procod.
            estoq.estcusto = vcusto.
        end.
    end.

        /*** Atualizacao de pedido: 1 pedido por NF ***/
        find first wfped no-lock.
        find pedid where recid(pedid) = wfped.rec no-lock.

    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod
                     no-lock.

for each w-movim-pai:

    find pack of w-movim-pai no-lock.

    find first lipedpai where lipedpai.etbcod = pedid.etbcod
                          and lipedpai.pedtdc = pedid.pedtdc
                          and lipedpai.pednum = pedid.pednum
                          and lipedpai.itecod = pack.itecod
                          and lipedpai.paccod = pack.paccod
                        no-error.
    if avail lipedpai
    then lipedpai.lipent = lipedpai.lipent + w-movim-pai.movqtm.

    for each packprod of pack.
        find produ of packprod no-lock.
    
        create wetique.
        assign wetique.wrec = recid(produ)
               wetique.wqtd = w-movim-pai.movqtm * packprod.qtde.

        vperc = packprod.qtde / pack.qtde.
        
        create w-filho.
        assign
            w-filho.wrec     = recid(w-movim-pai)
            w-filho.paccod   = w-movim-pai.paccod
            w-filho.procod   = packprod.procod
            w-filho.movqtm   = w-movim-pai.movqtm * packprod.qtde
            w-filho.movbicms = w-movim-pai.movbicms * vperc
            w-filho.movicms  = w-movim-pai.movicms  * vperc
            w-filho.movipi   = w-movim-pai.movipi   * vperc.
            
            if tipo_desconto = 5
            then w-filho.movdes = w-movim-pai.movdes / w-movim-pai.movqtm.
            else w-filho.movdes = w-movim-pai.movdes.
            w-filho.movdes = w-filho.movdes * vperc.

            if w-movim-pai.movfre > 0
            then w-filho.movfre = w-movim-pai.movfre  * vperc.
            else w-filho.movfre = frete_unitario * vperc.

        find first liped where liped.etbcod = pedid.etbcod
                           and liped.pedtdc = pedid.pedtdc
                           and liped.pednum = pedid.pednum
                           and liped.procod = produ.procod
                           and liped.lipcor = string(pack.paccod)
                         no-error.
        if avail liped
        then liped.lipent = liped.lipent + (w-movim-pai.movqtm * packprod.qtde).

/*** *** REVISAR *** ***
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
                                w-movim-pai.movqtm label "Qtd"
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
                   else liped.lipent = liped.lipent + w-movim-pai.movqtm.
                end.
            end.
        end.
        hide frame f-l1 no-pause.
        hide frame f-l2 no-pause.
        hide frame f-l3 no-pause.
*** ***/

    end.
end.

    for each w-filho no-lock.
        find w-movim-pai where recid(w-movim-pai) = w-filho.wrec no-lock.

        do transaction:
            vmovseq = vmovseq + 1.
            create movim.
            ASSIGN movim.movtdc    = plani.movtdc
                   movim.PlaCod    = plani.placod
                   movim.etbcod    = plani.etbcod
                   movim.movseq    = vmovseq
                   movim.movpc     = w-movim-pai.movpc
                   movim.MovAlICMS = w-movim-pai.movalicms
                   movim.MovAlIPI  = w-movim-pai.movalipi
                   movim.movpdes   = w-movim-pai.movpdes
                   movim.movdat    = plani.pladat
                   movim.MovHr     = plani.horincl
                   MOVIM.DATEXP    = plani.datexp
                   movim.desti     = plani.desti
                   movim.emite     = plani.emite
                   
                   movim.procod   = w-filho.procod
                   movim.movqtm   = w-filho.movqtm
                   movim.movbicms = w-filho.movbicms
                   movim.movicms  = w-filho.movicms
                   movim.movipi   = w-filho.movipi
                   movim.movdes   = w-filho.movdes
                   /*movim.movacfin = w-filho.movacfin*/
                   movim.movdev   = w-filho.movfre.           
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
                find tt-proemail where tt-proemail.procod = movim.procod
                                 no-error.
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

    vmovseq = 1.
    for each w-movim-pai.
        create movimpack.
        assign
            movimpack.etbcod = plani.etbcod
            movimpack.placod = plani.placod
            movimpack.movseq = vmovseq
            movimpack.movtdc = plani.movtdc
            movimpack.paccod = w-movim-pai.paccod
            movimpack.movqtm = w-movim-pai.movqtm
            movimpack.movpc  = w-movim-pai.movpc
            movimpack.movdat = plani.dtincl
            movimpack.movhr  = plani.horincl. 
        vmovseq = vmovseq + 1.
    end.

    for each movimpack where movimpack.etbcod = plani.etbcod
                         and movimpack.placod = plani.placod
                       no-lock.
        run not_atuestpack.p(input recid(movimpack),
                             input "I",
                             input 0).
    end.
    
    /* geracao para alcis */
    if plani.desti = 995
    then do.
        run alcis/orech.p (recid(plani)).
    end.
    else if plani.desti = 900
    then do:
        run alcis/orech-900.p (recid(plani)).
    end.
    
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
            
            for each liped of pedid:
    
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
    
    vezes = 0. prazo = 0.
    find first plani where plani.etbcod = estab.etbcod and
                           plani.placod = vplacod no-lock.
                           
    if vhiccod <> 599 and
       vhiccod <> 699
    then do:
    update vezes label "Vezes"
                with frame f-tit width 80 side-label centered color white/red.
    
    /** desconto no pedido para duplicata **/
    for each wfped:
        find pedid where recid(pedid) = wfped.rec no-lock.
        vdesdup = vdesdup + pedid.dupdes.
    end.
    /*****************/
    
    if plani.platot = 0
    then vtotpag = plani.protot.
    else vtotpag = plani.platot.

    vtotpag = vtotpag - vdesdup.
    
    find first movim where movim.placod = plani.placod and
                           movim.etbcod = plani.etbcod no-lock no-error.
                           
    if avail movim and (vhiccod <> 599 and vhiccod <> 699)
    then do on error undo, retry:
        update vtotpag with frame f-tit.
    
        if vtotpag < (plani.protot + plani.ipi - vdesval - plani.descprod
                        - vdesdup)
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
                       titulo.titdtemi = plani.pladat
                       titulo.titnum = string(plani.numero)
                       titulo.titpar = i.
                if prazo <> 0
                then assign titulo.titvlcob = vtotpag
                            titulo.titdtven = titdtemi + prazo.
                else assign titulo.titvlcob = vtotpag / vezes
                            titulo.titdtven = titulo.titdtemi + (30 * i).
            end.
        end.
        vsaldo = vtotpag.
        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = yes and
                              titulo.modcod = "DUP" and
                              titulo.etbcod = estab.etbcod and
                              titulo.clifor = forne.forcod and
                              titulo.titnum = string(plani.numero).
            display titulo.titpar
                    titulo.titnum
                        with frame ftitulo down centered
                                color white/cyan.
            prazo = 0.
            update prazo with frame ftitulo.
            do transaction:
                titulo.titdtven = vpladat + prazo.
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
        if vfrete > 0
        then do transaction:
            create btitulo.
            assign btitulo.etbcod   = plani.etbcod
                   btitulo.titnat   = yes
                   btitulo.modcod   = "NEC"
                   btitulo.clifor   = frete.forcod
                   btitulo.cxacod   = forne.forcod
                   btitulo.titsit   = "lib"
                   btitulo.empcod   = wempre.empcod
                   btitulo.titdtemi = vpladat
                   btitulo.titnum   = string(plani.numero)
                   btitulo.titpar   = 1
                   btitulo.titnumger = string(plani.numero)
                   btitulo.titvlcob = vfrete.
            update btitulo.titdtven label "Venc.Frete"
                   btitulo.titnum   label "Controle"
                        with frame f-frete centered color white/cyan
                                        side-label row 15 no-validate.
        end.    
    end.
    end.

    if opsys = "UNIX"
    then run infrepd1.p (input-output table tt-proemail). /* Gerson */
        /* run entcomdg.p. */
    
    message "Nota Fiscal Incluida". pause.
    
    if plani.desti = 996 or
       plani.desti = 995 or
       plani.desti = 999 or
       plani.desti = 900
    then do:
        run peddis.p (input recid(plani)).
        
        find first wetique no-lock no-error.
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
             
            for each wetique no-lock:
                if plani.desti = 996 or
                   plani.desti = 995 or
                   plani.desti = 900
                then do.
                    find first impress where impress.codimp = setbcod
                         no-lock no-error.
                    if not avail impress
                    then do:
                        message "Sem impressora cadastrada para o estab"
                         setbcod view-as alert-box.
                    end.
                    else do.
                        run acha_imp.p (input recid(impress),
                                        output vrecimp).
                        if vrecimp <> ?
                        then do.
                            find impress where recid(impress) = vrecimp no-lock.
                            run etinvmoda2.p (input wetique.wrec,
                                              input wetique.wqtd,
                                              2,
                                              impress.dfimp).
                        end.
                    end.
                end.
                else run etique-m2.p (input wetique.wrec,
                                      input wetique.wqtd).
            end.

            if opsys = "unix"
            then os-command silent /admcom/relat/etique.bat.
            else os-command silent c:\temp\etique.bat.
        end.

        message "Confirma relatorio de distribuicao" update sresp.
        if sresp
        then run disdep.p (input recid(plani)).

        par-ok = yes. /*** <== ***/
    end.    

end procedure.


procedure impostos.

    assign
        soma_icm_comdesc = 0
        soma_icm_semdesc = 0
        vprotot1   = 0
        ipi_item   = 0
        frete_item = 0
        qtd_total  = 0
        desp_acess = 0.
        
    for each w-movim-pai:  
        qtd_total = qtd_total + w-movim-pai.movqtm.  
    end.    

    desp_acess = vbiss / qtd_total.

    for each w-movim-pai:
        find pack of w-movim-pai no-lock.
        find clafis where clafis.codfis = w-movim-pai.codfis no-lock.
        v-red = clafis.perred.
           
        w-movim-pai.movicms2 = ((w-movim-pai.movqtm * pack.qtde *
                    (w-movim-pai.movpc + desp_acess + w-movim-pai.movfre)) *
                              (1 - (v-red / 100)) ) *
                              (w-movim-pai.movalicms / 100).

        soma_icm_semdesc = soma_icm_semdesc + w-movim-pai.movicms2. 
            
        if tipo_desconto < 5
        then do: 
            w-movim-pai.movbicms = ((w-movim-pai.movqtm * pack.qtde *
                                     (w-movim-pai.movpc + w-movim-pai.movfre
                                      - w-movim-pai.movdes + desp_acess)) *
                                    (1 - (v-red / 100)) ).
            w-movim-pai.movicms  = w-movim-pai.movbicms *
                                    (w-movim-pai.movalicms / 100).

            soma_icm_comdesc = soma_icm_comdesc + w-movim-pai.movicms.

            if w-movim-pai.movalipi <> 0
            then w-movim-pai.movipi = ((w-movim-pai.movpc + 
                                   w-movim-pai.movfre -
                                   w-movim-pai.movdes) * w-movim-pai.movqtm) * 
                                 (w-movim-pai.movalipi / 100).

            ipi_item = ipi_item + w-movim-pai.movipi.
            frete_item = frete_item + 
                             (w-movim-pai.movfre * w-movim-pai.movqtm).
        end.
        else do:
            w-movim-pai.movbicms = ((w-movim-pai.movqtm * pack.qtde *
                                    (w-movim-pai.movpc + desp_acess + 
                                     w-movim-pai.movfre - (w-movim-pai.movdes
                                     / w-movim-pai.movqtm))) *
                                     (1 - (v-red / 100)) ).
            w-movim-pai.movicms = w-movim-pai.movbicms *
                                     (w-movim-pai.movalicms / 100).

            soma_icm_comdesc = soma_icm_comdesc + w-movim-pai.movicms. 

            if w-movim-pai.movalipi <> 0
            then w-movim-pai.movipi = ((w-movim-pai.movpc + 
                                    w-movim-pai.movfre -
                                    (w-movim-pai.movdes / w-movim-pai.movqtm)) 
                                        * w-movim-pai.movqtm) * 
                                   (w-movim-pai.movalipi / 100).

            ipi_item = ipi_item + w-movim-pai.movipi.
            frete_item = frete_item + (w-movim-pai.movfre * w-movim-pai.movqtm).
        end.
                       
        vprotot1 = vprotot1 + w-movim-pai.subtotal.
        display vprotot1 with frame f-produ.
    end.

end procedure.


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

