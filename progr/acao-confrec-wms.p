{admcab.i}
{tpalcis-wms.i}

def input parameter par-arq as char.

def var varquivo as char.
def var varquivo-bkp as char.
def var vqtde    as dec.

varquivo = alcis-diretorio + "/" + par-arq.
unix silent value("quoter " + varquivo + " > ./consulta-crec.arq" ). 

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)"
    field Fornecedor        as char format "x(12)".

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field NotaFiscal        as char format "x(12)"
    field Proprietario      as char format "x(12)" 
    field Fornecedor        as char format "x(12)"
    field bloq              as char format "xx"
    field Qtde_no_Pack      as char format "x(18)".

def var varq-dep as char.
def var varq-pos as char.
def var varq-ant as char.
def var v as int.
def var vlinha as char.
def buffer xestab for estab.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/MOVEIS/bkp/" + par-arq.

input from ./consulta-crec.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1
    then do.
        create ttheader.
        assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.NotaFiscal     = substr(vlinha,26,12)
               ttheader.Proprietario   = substr(vlinha,38,12)
               ttheader.Fornecedor     = substr(vlinha,50,12).
        next.
    end.
    create ttitem.
    assign ttitem.Remetente      = substr(vlinha,  1,10)
           ttitem.Nome_arquivo   = substr(vlinha, 11,04)
           ttitem.Nome_interface = substr(vlinha, 15,08)
           ttitem.Produto        = substr(vlinha, 23,40)
           ttitem.Quantidade     = substr(vlinha, 63,18)
           ttitem.NotaFiscal     = substr(vlinha, 81,12)
           ttitem.Proprietario   = substr(vlinha, 93,12)
           ttitem.Fornecedor     = substr(vlinha,105,12)
           ttitem.bloq           = substr(vlinha,117, 2)
           ttitem.Qtde_no_Pack   = substr(vlinha,119,18).
end.
input close.

def var v-notafiscal as char.
def var v-numero as char.
def var v-serie as char.

find first ttheader no-lock.

v-notafiscal = trim(ttheader.NotaFiscal).
v-numero = substr(v-notafiscal,1,length(v-notafiscal) - 3).
v-serie  = substr(v-notafiscal,length(v-notafiscal) - 2,3).
def var vb as char.
vb = v-serie.
def var va as int.
do va = 1 to 3:
    if substr(vb,va,1) <> "0"
    then do: 
        v-serie = substr(vb,va,4 - va).
        leave.
    end.
end.

def temp-table w-movim like movim.

/***
message int(ttheader.Proprietario) int(ttheader.Fornecedor)
v-serie
int(ttheader.NotaFiscal) 
v-numero
. pause.
***/

find first plani where plani.movtdc = 4 and
                     plani.etbcod = int(ttheader.Proprietario) and
                     plani.emite  = int(ttheader.Fornecedor) and
                     plani.serie  = v-serie and
                     plani.numero = int(v-numero)
                     no-lock no-error.
if not avail plani
then find first plani where plani.movtdc = 6 and
                     plani.etbcod = int(ttheader.Fornecedor) and
                     plani.emite  = int(ttheader.Fornecedor) and
                     plani.serie  = v-serie and
                     plani.numero = int(v-numero)
                     no-lock no-error.
if avail plani
then do:  

for each ttitem.
    find produ where produ.procod = int(ttitem.produto) no-lock no-error.
    if not avail produ
    then next.
    vqtde = dec(ttitem.Qtde_no_Pack) / 1000000000.
    if vqtde > 0
    then do on error undo.
        
        find first movim where movim.etbcod = plani.etbcod and
                               movim.placod = plani.placod and
                               movim.movtdc = plani.movtdc and
                               movim.movdat = plani.pladat and
                               movim.procod = produ.procod
                               no-lock no-error.
        if not avail movim
        then do:
            /***
            find first produaux where 
                       produaux.procod     = int(ttitem.produto) and
                       produaux.nome_campo = "DIVRECALCIS"
                       no-error.
            if not avail produaux
            then do.
                create produaux.
                assign
                    produaux.procod      = int(ttitem.produto)
                    produaux.nome_campo  = "DIVRECALCIS"
                    produaux.valor_campo = string(vqtde).
            end.                
            produaux.valor_campo = string(vqtde).
            ***/
        end.
        else if movim.movqtm > vqtde
        then do:
            create w-movim.
            buffer-copy movim to w-movim.
            w-movim.movqtm = movim.movqtm - vqtde.
        end.
    end.                                      
end.

def var vdevol as log.
vdevol = no.
for each w-movim no-lock:
    find first ttitem where ttitem.produto = string(w-movim.procod) no-error.
    if not avail ttitem then next.
    find produ where produ.procod = w-movim.procod no-lock.
    disp produ.procod   column-label "Produto"
         produ.pronom   no-label
         w-movim.movqtm column-label "Qtd.NF"
         dec(ttitem.Quantidade) / 1000000000 format ">>>>>>>>9"
                       column-label "Qtd.WMS"
         with frame f-dif down title " Divergencias de Recebimento ".
    pause 0.
    vdevol = yes.
end.    
end.

def new shared temp-table tt-titulo like titulo.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimaux like movimaux.
def new shared temp-table tt-nfref like plani.
def new shared temp-table tt-etiqpla
    field oscod     like etiqpla.oscod
    field etopeseq  like etiqpla.etopeseq
    field etmovcod  like etiqpla.etmovcod.

def var v-bred as dec.
def var vsittri as char format "x(03)".
def var valor_icms like plani.platot.
def var base_icms  like plani.platot.
def var visenta    like plani.isenta.
def var voutras    like plani.outras.
def var vobs-os    as char.
def var vobs       as char extent 9 format "x(70)".
def var vforcod like forne.forcod.
def var vetbcod like estab.etbcod.
def var vbicms    like  plani.bicms.
def var vicms     like  plani.icms.
def var base_icms_subst like plani.bsubst.
def var icms_subst      like plani.icmssubst.
def var vprotot   like  plani.protot.
def var vdescpro  like  plani.descpro.
def var vacfprod  like  plani.acfprod.
def var vfrete    like  plani.frete.
def var vipi      like  plani.ipi.
def var vplatot   like  plani.platot.
def var vserie    like  plani.serie.
def var vnumant   like  plani.numero format "9999999".
def var vserant   as char format "x(03)".
def var vprocod   like  produ.procod.
def var vant as l.
def var vi as int.
def var vqtd        like movim.movqtm.
def var vopccod     like opcom.opccod.
def var vmovseq     like movim.movseq.
def var vtotal      like plani.platot.
def var vsubst like plani.platot.
def var vplacod like plani.placod.
def var vnumero like plani.numero.
def var vemite like plani.emite.
def buffer bestab for estab.
def buffer cestab for estab.

if vdevol and plani.movtdc = 4
then do:
    find forne where forne.forcod = plani.emite no-lock.
    find first cestab where cestab.etbcod = plani.desti no-lock.
    find tipmov where tipmov.movtdc = 13 no-lock.
    if forne.ufecod = "RS"
    then find first opcom where opcom.opccod = "5202" no-lock.
    else find last opcom where opcom.opccod = "6202"  no-lock.
    sresp = no.
    message "Emitir NF de DEVOLUCAO das divergencias encontradas?"
    update sresp.
    if sresp
    then run emissao-NFe-dev. 
end.    
else if vdevol and plani.movtdc = 6
then do:
    find first bestab where bestab.etbcod = plani.emite no-lock.
    find first cestab where cestab.etbcod = plani.desti no-lock.
    vemite = cestab.etbcod.
    sresp = no.
    message "Emitir NF de TRANSFERENCIA das divergencias encontradas?"
    update sresp.
    if sresp
    then run emissao-NFe-tra. 
end.


unix silent value("cp " + varquivo + " " + alcis-diretorio-bkp).
unix silent value("mv " + varq-ant + " " + varq-dep).

{mens-interface-wms-alcis.i "REC"}

procedure emissao-NFe-dev:

    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    for each tt-titulo. delete tt-titulo. end.
    
    do on error undo:
        vserie  = "1".
        create tt-plani.
        assign
            tt-plani.etbcod   = cestab.etbcod
            tt-plani.placod   = ?
            tt-plani.protot   = vprotot 
            tt-plani.desti    = forne.forcod
            tt-plani.bicms    = vbicms
            tt-plani.icms     = vicms
            tt-plani.bsubst   = base_icms_subst
            tt-plani.icmssubst = icms_subst
            tt-plani.descpro  = vdescpro
            tt-plani.acfprod  = vacfprod
            tt-plani.frete    = vfrete
            tt-plani.seguro   = 0
            tt-plani.desacess = 0
            tt-plani.ipi      = vipi
            tt-plani.platot   = vplatot + vipi 
            tt-plani.serie    = vserie
            tt-plani.numero   = ?
            tt-plani.movtdc   = tipmov.movtdc
            tt-plani.emite    = cestab.etbcod
            tt-plani.pladat   = today
            tt-plani.modcod   = tipmov.modcod
            tt-plani.opccod   = int(opcom.opccod)
            tt-plani.notfat   = cestab.etbcod
            tt-plani.dtinclu  = today
            tt-plani.horincl  = time
            tt-plani.notsit   = no
            tt-plani.dtinclu  = today
            tt-plani.notobs[1] = vobs[1] + " " + vobs[2] + " " + vobs[3] + " "
            tt-plani.notobs[2] = vobs[4] + " " + vobs[5] + " " + vobs[6] + " "
            tt-plani.notobs[3] = vobs[7] + " " + vobs[8] + " " + vobs[9] + " "
            tt-plani.hiccod   = int(opcom.opccod)
            tt-plani.outras   = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
            tt-plani.isenta = tt-plani.platot - tt-plani.outras
                               - tt-plani.bicms.

        create tt-titulo.
        assign
            tt-titulo.etbcod = plani.etbcod
            tt-titulo.titnat = no
            tt-titulo.modcod = "DCMP"
            tt-titulo.clifor = forne.forcod
            tt-titulo.titsit = "LIB"
            tt-titulo.empcod = wempre.empcod
            tt-titulo.titdtemi = today
            tt-titulo.titdtven = today
            tt-titulo.titnum = string(plani.numero)
            tt-titulo.titpar = 0
            tt-titulo.titvlcob = plani.platot
            tt-titulo.vencod = sfuncod.
    end.

    assign
        tt-plani.bicms = 0
        tt-plani.icms  = 0.

    for each w-movim :
        vmovseq = vmovseq + 1.

        create tt-movim.
        ASSIGN tt-movim.movtdc = tt-plani.movtdc
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = w-movim.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.MovAlICMS = w-movim.movalicms
               tt-movim.movicms   = w-movim.movicms
               tt-movim.MovAlIPI  = w-movim.movalipi
               tt-movim.movipi = w-movim.movipi
               tt-movim.movdes = w-movim.movdes
               tt-movim.movdat = tt-plani.pladat
               tt-movim.MovHr  = int(time)
               tt-movim.desti  = tt-plani.desti
               tt-movim.emite  = tt-plani.emite
               tt-movim.movdev = w-movim.movdev.
        
        v-bred = 0.
        
        find produ where produ.procod = tt-movim.procod no-lock.       
        find first clafis where clafis.codfis = produ.codfis
                       no-lock no-error.
        if avail clafis and
                 clafis.perred > 0
        then
            v-bred = (tt-movim.movpc * tt-movim.movqtm) -
                     ((tt-movim.movpc * tt-movim.movqtm) * 
                     (clafis.perred / 100)).
                 
        if v-bred > 0
            and (opcom.opccod = "1102" or opcom.opccod = "5202")
        then assign
                tt-movim.movicms = v-bred * (tt-movim.movalicms / 100)
                tt-plani.bicms = tt-plani.bicms + v-bred + vfrete.
        else assign
                tt-movim.movicms = (tt-movim.movpc * tt-movim.movqtm) *
                                   (tt-movim.movalicms / 100)
                tt-plani.bicms = tt-plani.bicms + 
                            (tt-movim.movpc * tt-movim.movqtm) - 
                            (tt-movim.movdes * tt-movim.movqtm) +
                            (tt-movim.movdev * tt-movim.movqtm).
        
        tt-movim.movicms = tt-movim.movicms
                              + ((tt-movim.movdev * tt-movim.movqtm)
                              - (tt-movim.movdes * tt-movim.movqtm))
                            * (tt-movim.movalicms / 100).
                         
        tt-plani.icms  = tt-plani.icms + tt-movim.movicms.
    end.



    sresp = no.
    message "Deseja visualizar o total da nota antes da emissao?"
        update sresp.
    if sresp
    then run p-mostra-nota.
    
    def var p-ok as log init no.
    
    run manager_nfe.p (input "5202",
                       input ?,
                       output p-ok).

end procedure.

procedure p-mostra-nota:

    display tt-plani.bicms  
            tt-plani.icms 
            tt-plani.bsubst
            tt-plani.icmssubst
            tt-plani.protot   
                with frame f-mostra-1 overlay row 8 width 80.
    pause 0.

    display tt-plani.frete 
            tt-plani.seguro 
            tt-plani.desacess
            tt-plani.ipi     
            tt-plani.platot  
                with frame f-mostra-2 overlay row 12 width 80.

    pause 0.

    sresp = no.

    for each tt-movim.
        display tt-movim.procod
                tt-movim.movipi
                tt-movim.movalipi
                tt-movim.movicms
                tt-movim.movalicms
                tt-movim.movdev label "Frete" with 1 col.                
    end.
                    
    message "Deseja alterar as informacoes? " update sresp.
    if sresp
    then do:
        update tt-plani.bicms  
               tt-plani.icms 
               tt-plani.bsubst
               tt-plani.icmssubst
               tt-plani.protot   
                    with frame f-mostra-1 overlay row 8 width 80.

        update tt-plani.frete 
               tt-plani.seguro 
               tt-plani.desacess
               tt-plani.ipi     
               tt-plani.platot  
                    with frame f-mostra-2 overlay row 12 width 80.
    
        for each tt-movim.
            update /***tt-movim.procod***/
                   tt-movim.movipi
                   tt-movim.movalipi
                   tt-movim.movicms
                   tt-movim.movalicms
                   tt-movim.movdev label "Frete" with 1 col.
        end.
    end.

end procedure.

procedure emissao-NFe-tra:
    def var vhiccod   like  plani.hiccod label "Op.Fiscal" initial 5152.
    for each tt-plani: delete tt-plani. end.
    for each tt-movim: delete tt-movim. end.
    
    do on error undo:
        vplacod = ?.
        vnumero = ?.
        vserie = "1".
        
        create tt-plani.
        assign tt-plani.etbcod   = cestab.etbcod
               tt-plani.placod   = vplacod
               tt-plani.emite    = cestab.etbcod
               tt-plani.alicms   = tt-plani.icms * 100 / (tt-plani.bicms *
                                (1 - (0 / 100)))
               tt-plani.serie    = vserie
               tt-plani.numero   = vnumero
               tt-plani.movtdc   = 6
               tt-plani.desti    = bestab.etbcod
               tt-plani.pladat   = today
               tt-plani.modcod   = tipmov.modcod
               tt-plani.opccod   = vhiccod
               tt-plani.notfat   = bestab.etbcod
               tt-plani.dtinclu  = today
               tt-plani.horincl  = time
               tt-plani.notsit   = no
               tt-plani.hiccod   = vhiccod
               tt-plani.notobs[3] = "D"
               tt-plani.outras = tt-plani.frete  +
                              tt-plani.seguro +
                              tt-plani.vlserv +
                              tt-plani.desacess +
                              tt-plani.ipi   +
                              tt-plani.icmssubst
              tt-plani.isenta = tt-plani.platot - tt-plani.outras 
                        - tt-plani.bicms.
    end.
    
    if not can-find (first w-movim)
    then do:    
        /*
        output stream str-log
               to value("/admcom/wms/logsnfe/nota_sem_item.csv") append.
        put stream str-log
             "ETBCOD;PLACOD;MOVTDC;PLADAT;NFTRA" skip.
        output stream str-log close.
        */
        message "Movimentacao sem itens, NFe nao sera gerada" view-as alert-box.
        undo, retry.       
    end.

    for each w-movim:
        vmovseq = vmovseq + 1.
        find produ where produ.procod = w-movim.procod no-lock no-error.
        if not avail produ
        then next.

        tt-plani.protot = tt-plani.protot + (w-movim.movqtm * w-movim.movpc).
        tt-plani.platot = tt-plani.platot + (w-movim.movqtm * w-movim.movpc).

        create tt-movim.
        ASSIGN tt-movim.movtdc = 6
               tt-movim.PlaCod = tt-plani.placod
               tt-movim.etbcod = tt-plani.etbcod
               tt-movim.movseq = vmovseq
               tt-movim.procod = produ.procod
               tt-movim.movqtm = w-movim.movqtm
               tt-movim.movpc  = w-movim.movpc
               tt-movim.movdat    = tt-plani.pladat
               tt-movim.MovHr     = int(time)
               tt-movim.emite     = tt-plani.emite
               tt-movim.desti     = tt-plani.desti
               tt-movim.ocnum[1]  = w-movim.ocnum[1] .    
        delete w-movim.
    end.

    def var p-ok as log init no.
    def var p-valor as char.
    p-valor = "".
    def var nfe-emite like plani.emite.

    nfe-emite = vemite.
    run le_tabini.p (nfe-emite, 0,
            "NFE - TIPO DOCUMENTO", OUTPUT p-valor) .
    if p-valor = "NFE"
    then
        run manager_nfe.p (input "5152",
                           input ?,
                           output p-ok).
    else message "Erro: Verifique os registros TAB_INI do emitente."    
            view-as alert-box.               

end procedure.

