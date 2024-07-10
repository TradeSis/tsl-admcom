/****
#2 - 12/12/2019 - Claudir - Sequencia alfabetic dos itens
***/


{admcab.i}
/*{alcis/tpalcis.i}*/

def input parameter par-rec as recid.

/***
*
*    Emissao de NFE
*
***/
def temp-table tt-produ no-undo
    field procod    like movim.procod
    field movqtm    like movim.movqtm
    field movpc     like movim.movpc
    
    index produ is primary unique procod.

/* NFE */
def new shared temp-table tt-pedid like pedid.
def new shared temp-table tt-liped like liped.
def new shared temp-table tt-plani like plani.
def new shared temp-table tt-movim like movim.
def new shared temp-table tt-movimimp like movimimp.

def var varq_fcgl as char. 
def var vlinha    as char.
def var varq_ctlin as int.
def var varq_qtde  as dec.
def var vqtde     as dec.
def var vestatual like estoq.estatual.
def var vmovseq   like movim.movseq.
def var vnarquivo as int.
def buffer etb-orig for estab.
def buffer etb-dest for estab.

for each tt-produ. delete tt-produ. end.
for each tt-plani: delete tt-plani. end.
for each tt-movim: delete tt-movim. end.
for each tt-movimimp. delete tt-movimimp. end.
for each tt-pedid. delete tt-pedid. end.
for each tt-liped. delete tt-liped. end.
for each tt-plani. delete tt-plani. end.
for each tt-movim. delete tt-movim. end.


find abasintegracao where recid(abasintegracao) = par-rec no-lock.

if abasintegracao.placod <> ?
then do on endkey undo:
    message "(1) Nota para gaiola " abasintegracao.ncarga " ja em uso".
    pause 1.
    return.
end.

/***
    Validacoes / Verificar estoque
***/
find tipmov where tipmov.movtdc = 6 no-lock.

if length(abasintegracao.arquivo) = 13
then vnarquivo = int(substr(abasintegracao.arquivo, 5, 5)) no-error.
else if length(abasintegracao.arquivo) = 14
     then vnarquivo = int(substr(abasintegracao.arquivo, 5, 6)) no-error.
     else if length(abasintegracao.arquivo) = 15
          then vnarquivo = int(substr(abasintegracao.arquivo, 5, 7)) no-error.


if vnarquivo = 0
then do.
    message "Nome do arquivo invalido" view-as alert-box.
    return.
end.

find etb-orig where etb-orig.etbcod = abasintegracao.etbcd no-lock no-error.
if not avail etb-orig
then do.
    message "Estab.Destino invalido" abasintegracao.etbcd view-as alert-box.
    return.
end.

find etb-dest where etb-dest.etbcod = abasintegracao.Etbcod no-lock no-error.
if not avail estab
then do.
    message "Estab.Destino invalido" abasintegracao.Etbcod view-as alert-box.
    return.
end.
if abasintegracao.NCarga = 0
then do.
    message "Gaiola invalida" abasintegracao.NCarga view-as alert-box.
    return.
end.

setbcod = 995.

find wmsarq where wmsarq.etbori   = abasintegracao.etbcd
              and wmsarq.narquivo = vnarquivo
            no-lock no-error.
if avail wmsarq
then do.
    /*
    message "Arquivo ja processado" vnarquivo view-as alert-box.
    return.
    */
end.

create tt-plani.
assign tt-plani.etbcod   = abasintegracao.etbcd
       tt-plani.placod   = ?
       tt-plani.emite    = abasintegracao.etbcd
       tt-plani.plaufemi = etb-orig.ufecod
       tt-plani.serie    = "1"
       tt-plani.numero   = ?
       tt-plani.movtdc   = tipmov.movtdc
       tt-plani.desti    = abasintegracao.Etbcod
       tt-plani.plaufdes = etb-dest.ufecod
       tt-plani.hiccod   = 5152
       tt-plani.opccod   = 5152
       tt-plani.pladat   = today
       tt-plani.datexp   = today
       tt-plani.modcod   = tipmov.modcod
       tt-plani.notfat   = abasintegracao.Etbcod
       tt-plani.dtinclu  = today
       tt-plani.horincl  = time
       tt-plani.notsit   = no
       tt-plani.vencod   = sfuncod
       tt-plani.NotPed   = "Gaiola="   + string(abasintegracao.NCarga) +
                           "|Arquivo=" + abasintegracao.arquivo
       tt-plani.notobs[1] = "Gaiola:"  + string(abasintegracao.NCarga) +
                            "Arquivo:" + abasintegracao.arquivo.

for each abasCARGAprod of abasintegracao
            where abasCARGAprod.qtd > 0 no-lock.

    assign
        varq_ctlin = varq_ctlin + 1
        varq_qtde  = varq_qtde + abasCARGAprod.qtd.

    find produ where produ.procod = abasCARGAprod.procod no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao encontrado:" abasCARGAprod.procod view-as alert-box.
        return.
    end.

    find tt-produ where tt-produ.procod = abasCARGAprod.procod no-error.
    if not avail tt-produ
    then do.
        create tt-produ.
        tt-produ.procod = abasCARGAprod.procod.
    end.
    assign
        tt-produ.movqtm = tt-produ.movqtm + abasCARGAprod.qtd.
end.

if varq_ctlin <> abasintegracao.qtdlinhas
then do.
    message "Arquivo possui itens faltantes:" abasintegracao.qtdlinhas "x" varq_ctlin
            view-as alert-box.
    return.
end.

/***
    EMISSAO DA NFE
***/

/*********** controle de quantidade 11/04/2000 ***********/
def var vestoqok as log.
vestoqok = yes.

for each tt-produ no-lock.
    find estoq where estoq.procod = tt-produ.procod
                 and estoq.etbcod = abasintegracao.etbcd
               no-lock no-error.
    vestatual = 0.
    if avail estoq
    then vestatual = estoq.estatual.

    if vestatual - tt-produ.movqtm < 0
    then do:
        display tt-produ.procod 
            vestatual  format "->>,>>9.99" 
            tt-produ.movqtm no-label format ">>>>9.99"
            with frame f-aviso overlay row 8 10 down centered 
                        title "Estoque nao possui esta Quantidade".
        vestoqok = no.
            pause.
        return.
        end.
end.
/*if vestoqok = no
then return.*/


vmovseq = 0.
for each tt-produ no-lock,
  /*#2*/  first produ where produ.procod = tt-produ.procod
                no-lock by produ.pronom:

    vmovseq = vmovseq + 1.
        
    find estoq where estoq.etbcod = 7 /*** ??? ***/ and
                     estoq.procod = tt-produ.procod
               no-lock no-error.
    create tt-movim.
    ASSIGN tt-movim.movtdc = tt-plani.movtdc
           tt-movim.PlaCod = tt-plani.placod
           tt-movim.etbcod = tt-plani.etbcod
           tt-movim.movseq = vmovseq
           tt-movim.procod = tt-produ.procod
           tt-movim.movqtm = tt-produ.movqtm
           tt-movim.movdat = tt-plani.pladat
           tt-movim.MovHr  = tt-plani.horincl
           tt-movim.desti  = tt-plani.desti
           tt-movim.emite  = tt-plani.emite.
                 
    if avail estoq
    then tt-movim.movpc  = estoq.estcusto.
/***
    else if estoq.estcusto = 0
    then tt-movim.movpc = 1.
***/
    if tt-movim.movpc = 0
    then tt-movim.movpc = 1.

    tt-plani.platot = tt-plani.platot + (tt-movim.movpc * tt-movim.movqtm).
    tt-plani.protot = tt-plani.protot + (tt-movim.movpc * tt-movim.movqtm).
end.

vqtde = 0.
for each tt-movim no-lock.
    vqtde = vqtde + tt-movim.movqtm.
end.
if vqtde <> varq_qtde
then do.
    message "Quantidade divergente:" vqtde varq_qtde view-as alert-box.
    return.
end.

sresp = no.
message "Confirma emisao NFE de transferencia da Gaiola" abasintegracao.NCarga
        "para loja" abasintegracao.Etbcod "?" update sresp.
if not sresp
then next.


/*
unix silent value("mv " + varq_fcgl + " /admcom/tmp/alcis/itim/").

*/


        do on error undo transaction:
            
            find current abasintegracao exclusive no-wait no-error.
            if not avail abasintegracao or
               avail abasintegracao and abasintegracao.placod <> ?
            then do on endkey undo:
                
                message "(2) Nota para ja sendo emitida".
                pause 1.
                return.
                
            end. 
            else do:
                abasintegracao.placod = 0. /* só marca como em uso */
            end.        
            
            find current abasintegracao no-lock.
            
        end. 

run manager_nfe.p (input "995_5152", input ?, output sresp).


        do on error undo:
            
            find current abasintegracao exclusive.
            find current tt-plani.
            
            abasintegracao.placod = tt-plani.placod.
            
        end. 

        find current abasintegracao no-lock.
        run abas/transffecha.p (recid(abasintegracao)).

