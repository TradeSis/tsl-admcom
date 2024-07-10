{admcab.i}

def input parameter vetb like estab.etbcod.
def output parameter vrecped as recid.

def buffer cestoq for estoq.
def buffer bfunc for func.
def buffer bestab for estab.
def buffer bprodu for produ.
def buffer bforne for forne.
def buffer bpedid for pedid.

def var vdtbase    like pedid.condat.
def var vcatcod like produ.catcod.
def var vprocod like produ.procod.
def var vpedpro like produ.procod.
def var vclacod like produ.clacod.
def var vfabcod like produ.fabcod.
def var vregcod like pedid.regcod.
def var vforcod like forne.forcod.
def var vpeddat as date.
def var vpeddti as date.
def var vpeddtf as date.
def var vcrecod like crepl.crecod format ">999".
def var vcomcod like pedid.comcod.
def var vrepcod like pedid.vencod.
def var vnfdes  like pedid.nfdes.
def var vfrete  like pedid.condes.
def var vipi    as dec .
def var vdupdes like pedid.dupdes.
def var vacrfin like pedid.acrfin.
def var vcondat like pedid.condat format "99/99/9999".
def var vcondes like pedid.condes.
def var vfrecod like pedid.frecod.
def var vfobcif like pedid.fobcif initial no.
def var vpedtot like pedid.pedtot.
def var vpedobs like pedid.pedobs.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata   like pedid.peddat.


    form vforcod      colon 18 label "Fornecedor"
         forne.fornom      no-label format "x(30)"
         forne.forcgc      colon 18
         forne.forinest    colon 50 label "I.E" format "x(17)"
         forne.forrua      colon 18 label "Endereco"
         forne.fornum
         forne.forcomp no-label
         forne.formunic   colon 18 label "Cidade"
         forne.ufecod   label "UF"
         forne.forcep      label "Cep"
         forne.forfone        colon 18 label "Fone"
         vregcod colon 18 label "Local Entrega"
         bestab.etbnom no-label
         vrepcod    colon 18
         repre.repnom no-label
         vdtbase    colon 18 label "Data Base" format "99/99/99"
         vpeddti    colon 18 label "Prazo de Entrega" format "99/99/99"
                    validate (vpeddti >= today, "")
         vpeddtf    label "A"                         format "99/99/99"
                             validate (vpeddtf >= vpeddti and
                                       vpeddtf < today + 365, "")
         vcrecod       colon 18 label "Prazo de Pagto" format "9999"
         crepl.crenom       no-label
         vcomcod       colon 18 label "Comprador"
         compr.comnom                 no-label
         vfobcif       colon 18
         vfrecod       label "Transport."
         frete.frenom no-label
         vfrete         label "Frete"
         vnfdes        colon 18 label "Desc.Nota"
         vdupdes       label "Desc.Duplicata"
         vipi          label "IPI" format ">9.99%" 
         vacrfin       label "Acres. Financ." colon 18
         with frame f-dialogo color white/cyan overlay row 6
            side-labels centered title " Inclusao de pedido ".

    form
        vpedobs[1] format "x(78)"
        vpedobs[2] format "x(78)"
        vpedobs[3] format "x(78)"
        vpedobs[4] format "x(78)"
        vpedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                                no-labels width 80 title "Observacoes".
 
do on error undo with frame f-dialogo.
    vetbcod = vetb.
    vdata   = today.

    update vforcod colon 18 label "Fornecedor".
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao Cadastrado" view-as alert-box.
        undo, retry.
    end.
    if forne.forpai <> 0
    then do:
          find bforne where bforne.forcod = forne.forpai 
                                no-lock no-error.
          if not avail bforne
          then do:
                message "Fornecedor pai nao cadastrado".
                 undo, retry.
          end.
          else do:
            vforcod = bforne.forcod.
            find forne where forne.forcod = vforcod no-lock no-error.
            disp vforcod.
          end.  
    end.
    /**/
    
    display
           forne.fornom
           forne.forcgc
           forne.forinest
           forne.forrua
           forne.fornum
           forne.forcomp
           forne.formunic
           forne.ufecod
           forne.forcep
           forne.forfone.
    do on error undo:
        vregcod = vetb.
        update vregcod.
        
        /* 99 e 96 nao sao mais depositos, agora sao filiais
        if vregcod = 99 or
           vregcod = 96
        then undo.
        */
        
        find bestab where bestab.etbcod = vregcod no-lock no-error.
        if not avail bestab
        then do:
            message "Local nao Cadastrado".
            undo, retry.
        end.
        disp bestab.etbnom.
        find repre where repre.repcod = forne.repcod no-lock no-error.
        if avail repre
        then vrepcod = repre.repcod.
        else update vrepcod.
        find repre where repre.repcod = vrepcod no-lock.
        display vrepcod
                repre.repnom no-label.
    end.
    if bestab.etbcod = 996
    then vcatcod = 41.
    else vcatcod = 31.

    update vdtbase.
    do on error undo.
        update vpeddti.
        update vpeddtf.
        if vpeddtf < vpeddti
        then do:
            message "Prazo de entrega invalido".
            pause.
            undo.
        end.
    end.
    do on error undo:
        update vcrecod  colon 18 label "Prazo de Pagto" format "9999".
        find crepl where crepl.crecod = vcrecod no-lock no-error.
        if not avail crepl
        then do.
            message "Prazo invalido" view-as alert-box.
            undo.
        end.
        display crepl.crenom no-label.
    end.
    do on error undo:
        update vcomcod.
        find compr where compr.comcod = vcomcod no-lock no-error.
        display compr.comnom no-label.
    end.
    update vfobcif.
    if vfobcif
    then do on error undo:
        update vfrecod.
        find frete where frete.frecod = vfrecod no-lock no-error.
        if not avail frete
        then do:
            message "Transportadora nao cadastrada".
            undo, retry.
        end.
        display frete.frenom no-label.
    end.
    update vfrete
           vnfdes
           vdupdes
           vipi
           vacrfin.
    update vpedobs[1] format "x(78)"
           vpedobs[2] format "x(78)"
           vpedobs[3] format "x(78)"
           vpedobs[4] format "x(78)"
           vpedobs[5] format "x(78)"
                 with frame fobs color white/cyan overlay row 9
                                no-labels width 80 title "Observacoes".
end.

            sresp = no.
            message "Confirma Criacao do Pedido?"
            update sresp.
            if sresp
            then do transaction.
                find last bpedid use-index ped
                                 where bpedid.etbcod = bestab.etbcod and
                                       bpedid.pedtdc = 1 no-lock  no-error.
                if avail bpedid
                then vpednum = bpedid.pednum + 1.
                else vpednum = 1.

                create pedid.
                assign pedid.pedtdc   = 1
                       pedid.pednum   = vpednum
                       pedid.clfcod   = forne.forcod
                       pedid.regcod   = bestab.etbcod
                       pedid.peddat   = vdata
                       pedid.sitped   = "A"
                       pedid.etbcod   = bestab.etbcod
                       pedid.condat   = vdtbase
                       pedid.peddti   = vpeddti
                       pedid.peddtf   = vpeddtf
                       pedid.crecod   = vcrecod
                       pedid.comcod   = vcomcod
                       pedid.condes   = vfrete
                       pedid.nfdes    = vnfdes
                       pedid.dupdes   = vdupdes
                       pedid.ipides   = vipi
                       pedid.acrfin   = vacrfin
                       pedid.frecod   = vfrecod
                       pedid.fobcif   = vfobcif
                       pedid.modcod   = "PED"
                       pedid.vencod   = vrepcod
                       pedid.pedtot   = vpedtot
                       pedid.pedobs[1] = vpedobs[1]
                       pedid.pedobs[2] = vpedobs[2]
                       pedid.pedobs[3] = vpedobs[3]
                       pedid.pedobs[4] = vpedobs[4]
                       pedid.pedobs[5] = vpedobs[5]
                       pedid.pedsit   = no /* Quando finaliza passa para yes */
                       pedid.catcod   = vcatcod.
                vrecped = recid(pedid).
            end.
            if vpednum > 0
            then message "Pedido criado:" vpednum view-as alert-box.