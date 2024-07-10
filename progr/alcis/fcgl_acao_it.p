{admcab.i}
{alcis/tpalcis.i}

def input parameter par-arq as char.

/***
*
*    Emissao de NFE
*
***/
def temp-table tt-produ
    field procod    like movim.procod
    field movqtm    like movim.movqtm
    field movpc     like movim.movpc
    
    index produ is primary unique procod.

def temp-table ttheader
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as int
    field Etbcod            as int
    field N_Gaiola          as int
    field Itens             as int.

def temp-table ttitem
    field Remetente         as char format "x(10)"
    field Nome_arquivo      as char format "x(4)"
    field Nome_interface    as char format "x(8)"
    field Site              as char format "xxx"
    field Proprietario      as char format "x(12)"
    field Etbcod            as char format "x(12)"
    field N_Gaiola          as char format "x(11)"
    field Seq               as int  format ">>9"
    field Procod            as int
    field Qtd               as dec
    field Unidade           as char format "x(6)"
    field id_distrib        as char.

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

for each ttheader. delete ttheader. end.
for each ttitem.   delete ttitem.   end.
for each tt-produ. delete tt-produ. end.
for each tt-plani: delete tt-plani. end.
for each tt-movim: delete tt-movim. end.
for each tt-movimimp. delete tt-movimimp. end.
for each tt-pedid. delete tt-pedid. end.
for each tt-liped. delete tt-liped. end.
for each tt-plani. delete tt-plani. end.
for each tt-movim. delete tt-movim. end.

/***
    Leitura do arquivo Alcis
***/
varq_fcgl = alcis-diretorio + "/" + par-arq.
input from value(varq_fcgl).
repeat.
    import unformatted vlinha.
    if substr(vlinha,15,8) = "FCGLH"
    then do.
        create ttheader.
        assign ttheader.Remetente      = substr(vlinha,1 ,10)
               ttheader.Nome_arquivo   = substr(vlinha,11,4 )
               ttheader.Nome_interface = substr(vlinha,15,8 )
               ttheader.Site           = substr(vlinha,23,3 )
               ttheader.Proprietario   = int( substr(vlinha,26,12) )
               ttheader.Etbcod         = int( substr(vlinha,38,12) )
               ttheader.N_Gaiola       = int( substr(vlinha,50,11) )
               ttheader.Itens          = int( substr(vlinha,61,3) ).
    end.
    if substr(vlinha,15,8) = "FCGLI"    
    then do.
        create ttitem.
        assign 
            ttitem.Remetente      = substr(vlinha, 1,10)
            ttitem.Nome_arquivo   = substr(vlinha,11,4)
            ttitem.Nome_interface = substr(vlinha,15,8)
            ttitem.Site           = substr(vlinha,23,3)
            ttitem.Proprietario   = substr(vlinha,26,12)
            ttitem.Etbcod         = substr(vlinha,38,12)
            ttitem.N_Gaiola       = substr(vlinha,50,11)
            ttitem.seq            = int(substr(vlinha,61,3))
            ttitem.procod         = int(substr(vlinha,64,40))
            ttitem.qtd            = dec(substr(vlinha,104,18)) / 1000000000
            ttitem.unidade        = substr(vlinha,122,6)
            ttitem.id_distrib     = substr(vlinha,128,32).
    end.
end.
input close.

/***
    Validacoes / Verificar estoque
***/
find tipmov where tipmov.movtdc = 6 no-lock.

find first ttheader no-lock.

if length(par-arq) = 13
then vnarquivo = int(substr(par-arq, 5, 5)).
else if length(par-arq) = 14
then vnarquivo = int(substr(par-arq, 5, 6)).

if vnarquivo = 0
then do.
    message "Nome do arquivo invalido" view-as alert-box.
    return.
end.

find etb-orig where etb-orig.etbcod = ttheader.Proprietario no-lock no-error.
if not avail etb-orig
then do.
    message "Estab.Destino invalido" ttheader.Proprietario view-as alert-box.
    return.
end.

find etb-dest where etb-dest.etbcod = ttheader.Etbcod no-lock no-error.
if not avail estab
then do.
    message "Estab.Destino invalido" ttheader.Etbcod view-as alert-box.
    return.
end.
if ttheader.N_Gaiola = 0
then do.
    message "Gaiola invalida" ttheader.N_Gaiola view-as alert-box.
    return.
end.

setbcod = 995.

find wmsarq where wmsarq.etbori   = ttheader.Proprietario
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
assign tt-plani.etbcod   = ttheader.Proprietario
       tt-plani.placod   = ?
       tt-plani.emite    = ttheader.Proprietario
       tt-plani.plaufemi = etb-orig.ufecod
       tt-plani.serie    = "1"
       tt-plani.numero   = ?
       tt-plani.movtdc   = tipmov.movtdc
       tt-plani.desti    = ttheader.Etbcod
       tt-plani.plaufdes = etb-dest.ufecod
       tt-plani.hiccod   = 5152
       tt-plani.opccod   = 5152
       tt-plani.pladat   = today
       tt-plani.datexp   = today
       tt-plani.modcod   = tipmov.modcod
       tt-plani.notfat   = ttheader.Etbcod
       tt-plani.dtinclu  = today
       tt-plani.horincl  = time
       tt-plani.notsit   = no
       tt-plani.vencod   = sfuncod
       tt-plani.NotPed   = "Gaiola="   + string(ttheader.N_Gaiola) +
                           "|Arquivo=" + par-arq
       tt-plani.notobs[1] = "Gaiola:"  + string(ttheader.N_Gaiola) +
                            "Arquivo:" + par-arq.

for each ttitem where ttitem.qtd > 0 no-lock.

    assign
        varq_ctlin = varq_ctlin + 1
        varq_qtde  = varq_qtde + ttitem.qtd.

    find produ where produ.procod = ttitem.procod no-lock no-error.
    if not avail produ
    then do.
        message "Produto nao encontrado:" ttitem.procod view-as alert-box.
        return.
    end.

    find tt-produ where tt-produ.procod = ttitem.procod no-error.
    if not avail tt-produ
    then do.
        create tt-produ.
        tt-produ.procod = ttitem.procod.
    end.
    assign
        tt-produ.movqtm = tt-produ.movqtm + ttitem.qtd.
end.

if varq_ctlin <> ttheader.itens
then do.
    message "Arquivo possui itens faltantes:" ttheader.itens "x" varq_ctlin
            view-as alert-box.
    return.
end.

/***
    EMISSAO DA NFE
***/

/*********** controle de quantidade 11/04/2000 ***********/
for each tt-produ no-lock.
    find estoq where estoq.procod = tt-produ.procod
                 and estoq.etbcod = ttheader.Proprietario
               no-lock no-error.
    vestatual = 0.
    if avail estoq
    then vestatual = estoq.estatual.

    if vestatual - tt-produ.movqtm < 0
    then do:
        display tt-produ.procod 
            "Qtd Estoque :" at 5 vestatual  no-label format "->>,>>9.99"
            "Qtd Desejada:" at 5 tt-produ.movqtm no-label format ">>>>9.99"
            with frame f-aviso overlay row 10 side-label centered 
                        title "Estoque nao possui esta Quantidade".
        pause.
        return.
    end.
end.

vmovseq = 0.
for each tt-produ no-lock.
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
message "Confirma emisao NFE de transferencia da Gaiola" ttheader.N_Gaiola
        "para loja" ttheader.Etbcod "?" update sresp.
if not sresp
then next.

unix silent value("mv " + varq_fcgl + " /admcom/tmp/alcis/itim/").

run manager_nfe.p (input "995_5152", input ?, output sresp).

