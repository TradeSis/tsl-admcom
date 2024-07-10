/*#1 - helio.neto ajustes do sprint 1 */
/*#2 - helio.neto sprint 6, lin_ped_colocado, exportar tabela pedid */
 
/*#2*/
/*#30 - helio.neto 24.07.2019 - Trello [Planejamento] Nova da Nova da Nova regra interfaces movim 
                Alteração Interface PEDIDO DE VENDA
                3) Os pedidos de abastecimento associados à venda, que não foram atendidos no momento da exportação em D+1 (até amanhã), [NOVA REGRA] enviar com a data                 de movimentação = amanhã.
        */ 
/*#31 - helio.neto - 01.08.2019 - LeadtimeInfo da MODA separado */
/*#32 - helio.neto - 13.08.2019 - mudanca diretorio de entrada */
/*#33 - helio.neto - 13.08.2019 - muda para processo em duas fases... */
/*#34 - helio.neto - 02.10.2019 - Alteração Regra Envio Pedido Comercial  - MOVIM_SKU e MOVIM_SKU_ESTOQUE Será acrescentado ao total do ESTOQUE quantidade de pedidos COMERCIAL com data de
atendimento MAIOR que a data da GERAÇÃO do arquivo*/

 
/*19.06.19*/
def var vpedfuturo  like estoq.estatual.
def var vdttransf   like abastransf.dttransf. /* 24.06.19 D+1 */
/*20.06.2019*/
/*22.06.2019 - retirado def var total_estoq as dec.
def buffer testoq   for estoq.*/
/* 22.06.19*/
def var t900    like estoq.estatual.

/*03.07.2019*/
def var venviar as log.
/*05.07.19*/
def var vsomarestoq as log.

def var prec as recid.
def var vproindice like produ.proindice. 
def temp-table tt-ped-colocado no-undo
    field procod        like produ.procod
    field etbcod        like abastransf.etbcod
    field abtqtd        like abastransf.abtqtd
    field tipo          as char /* TV_TRANSF_VENDA, TR_NORMAL, CO_COMPRA */
    field numero        as char
    field dtinclu       as char
    field obs           as char
    field produto       as char
    field etbdes        as char
    field data          as char
    field qtd           as char
    field qtdatend      as char
    field origem        as   char /* TRANSFERENCIA = "1", COMPRA = "NULO"       */
    field origemITEM    as   char /* TRANSFERENCIA = PROCOD, COMPRA = "NULO"    */
    field origemETB     as char
    field origemSAIDA   as char
    field origemQTD     as char
    field origemQTATE   as char
    field origemFORNE   as char
    field enviar       as log init yes     /* 03.07.2019 */
    field somarestoq   as log init yes     /* 05.07.2019 */
    
    index idx tipo asc
    index idx2 procod asc etbcod asc somarestoq asc.

def var vtipo       as char.
def var vdtinclu    like abastransf.dtinclu.
def var vobs        like abastransf.abtobs.
        
    def var vestoq_depos like estoq.estatual.
    def var vreservas as dec.
    def var vdisponivel as dec.

def var vpack as int.
def var vleadtime like abasresoper.leadtime.
def var vleadtimeINFO like abasresoper.leadtimeINFO.

def var vemite    like abasresoper.emite.

def var cdata as char.
def var vtot as int.
def var vtemcompra as log.
def var vtemvenda  as log.
def var vtemestoq  as log.
def var vtemtempo  as log.
def var vtemtransf as log.

def buffer estoq900 for estoq.
def var vcodigo_pedido as char.
def var vgrade as int.


def var vcar1 as char.
def var vsub1 as char.
def var vcar2 as char.
def var vsub2 as char.

def var xtime as int.
xtime = time.

def var par-dtini   as date.
def var par-dtfim   as date.

par-dtini = today - 7.
par-dtfim = today - 0.


def var vdir-arquivo as char format "x(50)" /* #32 init "/admcom/tmp/expabasneogrid/" */.
vdir-arquivo = "/NeoGridOut/". /*#32*/

def var tmp-arquivo  as char extent 11.
def var nome-arquivo as char extent 11 format "x(70)" .

    
def var vsysdata     as char.  
vsysdata = string(year(today) ,"9999") 
         + string(month(today),"99")
         + string(day(today)  ,"99")
/**         + string(time,"HH:MM")**/ .
vsysdata = replace(vsysdata,":","").

/* SPRINT1
Upload . Itens                                   [1] X_LOJASLEBES_AAAAMMDD_itens.txt
Upload - Origem da SKU                           [2] X_LOJASLEBES-AAAAMMDD_origens.txt
Upload - Local de estoque                        [3] X_LOJASLEBES-AAAAMMDD_localEstoque.txt
Upload - Cadastro de Dimensão de Demanda         [4] X_LOJASLEBES-AAAAMMDD_dimdemanda1.txt

Upload - Fornecedores                            [5] X_LOJASLEBES-AAAAMMDD_fornecedores.txt
Upload - Movimentação DFU                        [6] X_LOJASLEBES-AAAAMMDD_movim_dfu.txt
Upload - Movimentação SKU                        [7] X_*_LOJASLEBES-AAAAMMDD_movim_sku.txt
Upload - Movimentação SKU Atualização do Estoque [8] X_LOJASLEBES-AAAAMMDD_movim_sku_estoque.txt

Upload . SKU (Mix / Grade Mínima)                [9] X_ LOJASLEBES_AAAAMMDD_mixGrade.txt
Upload - Pedidos de Venda                        [10]  X_LOJASLEBES-AAAAMMDD_pedidovenda.txt
Upload . Tipo 1 . Linha de Pedidos Colocados     [11]  X_LOJASLEBES-AAAAMMDD_lin_ped_colocado.txt

*/

tmp-arquivo[1] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp1".
tmp-arquivo[2] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp2".
tmp-arquivo[3] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp3".
tmp-arquivo[4] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp4".

tmp-arquivo[5] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp5".
tmp-arquivo[6] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp6".
tmp-arquivo[7] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp7".
tmp-arquivo[8] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp8".

tmp-arquivo[9] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp9".
tmp-arquivo[10] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp10".
tmp-arquivo[11] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_tmp11".



nome-arquivo[1] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_itens.txt".
nome-arquivo[2] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_origens.txt".
nome-arquivo[3] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_localEstoque.txt".
nome-arquivo[4] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_dimdemanda1.txt".

nome-arquivo[5] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_fornecedores.txt".
nome-arquivo[6] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_dfu.txt".
nome-arquivo[7] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_sku.txt".
nome-arquivo[8] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_movim_sku_estoque.txt".

nome-arquivo[9] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_mixGrade.txt".
nome-arquivo[10] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_pedidovenda.txt".
nome-arquivo[11] = vdir-arquivo + "X_LOJASLEBES-" + vsysdata + "_lin_ped_colocado.txt".

def var sresp as log format "Sim/Nao".
sresp = yes.

if SESSION:BATCH-MODE = no
then do:
    disp
        nome-arquivo no-label
        with side-labels
        1 down
        centered
        frame farquivo
        width 80.
    update
        nome-arquivo
        with frame farquivo.
    message "Eliminar os Pedidos" update sresp.
end.    

if sresp
then do on error undo:
    find abasintegracao where 
            abasintegracao.interface = "NEO" and
            abasintegracao.arquivoIntegracao = vsysdata
        exclusive no-wait no-error.
    if not avail abasintegracao
    then do:
        if not locked abasintegracao
        then create abasintegracao.
    end.            
    if avail abasintegracao
    then do:
        prec = recid(abasintegracao).
        ASSIGN
            abasintegracao.Data              = today
            abasintegracao.Hora              = time
            abasintegracao.ArquivoIntegracao = vsysdata
            abasintegracao.Diretorio         = vdir-arquivo
            abasintegracao.interface           = "NEO"
            abasintegracao.dtfim             = ?
            abasintegracao.HrFim             = ?.
    end.
end.

def var vabtsit as int.
def var cabtsit as char extent 3
    init ["AC","IN","SE"].

/* Elimina Abastransf AC Antigos */
def var vconta as int init 0.
hide message no-pause.

if sresp
then do:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Eliminando Ped.Transf NEO <=hoje ".
for each abaswms no-lock.
    for each abastransf where            
            abastransf.wms = abaswms.wms and
            abastransf.abtsit = "AC" and
            abastransf.abatipo = "NEO" and
            abastransf.dttransf <= today and 
            abastransf.qtdemwms = 0 and 
            abastransf.qtdatend = 0.
                                                .
        abastransf.abtsit = "EL".        
        vconta = vconta + 1.
        if vconta = 1 or vconta mod 100 = 0
        then do:
            hide message no-pause.
            message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Eliminando Ped.Transf NEO <=hoje " vconta.
        end.    
    end.         
    hide message no-pause. 
    message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Eliminando Ped.Transf " " <=hoje - 45" vconta.
    for each abastwms of abaswms no-lock.
        if abastwms.abatipo = "NEO" /* tratado separadamente */
        then next.
        
            for each abastransf where            
                abastransf.wms = abaswms.wms and
                abastransf.abatipo = abastwms.abatipo and
                abastransf.abtsit = "AC" and
                abastransf.dttransf < today - 45 and
                abastransf.qtdemwms = 0 and
                abastransf.qtdatend = 0.
                abastransf.abtsit = "EL".        
                vconta = vconta + 1.
                if vconta = 1 or vconta mod 100 = 0
                then do:
                    hide message no-pause.
                    message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Eliminando Ped.Transf " abastwms.abatipo " <=hoje - 45" vconta.
                end.    
            end.
            
    end.    
end.    
end.
                    

    




def var vlocal as char.
def var cmovdat as char.

def var vdata   as date.
def var vloop as int.
def var vCNPJ as char.
 
def var vcp     as char no-undo init ";".

function retira-acento returns character(input texto as character):

    define variable c-retorno as character no-undo.
    define variable c-letra   as character no-undo case-sensitive.
    define variable i-conta         as integer   no-undo.
    def var i-asc as int.
    def var c-caracter as char.

    do i-conta = 1 to length(texto):
        
        c-letra = substring(texto,i-conta,1).
        i-asc = asc(c-letra).
        
        if i-asc <= 160                         then c-caracter = c-letra.
        else if i-asc >= 161 and i-asc <= 191  or
                i-asc >= 215 and i-asc <= 216  or
                i-asc >= 222 and i-asc <= 223  or
                i-asc >= 247 and i-asc <= 248       then c-caracter = " ".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc = 199                     then c-caracter = "C".
        else if i-asc >= 200 and i-asc <= 203       then c-caracter = "E".
        else if i-asc >= 204 and i-asc <= 207       then c-caracter = "I".
        else if i-asc =  208                     then c-caracter = "D".
        else if i-asc = 209                     then c-caracter = "N".
        else if i-asc >= 210 and i-asc <= 214       then c-caracter = "O".
        else if i-asc >= 217 and i-asc <= 220       then c-caracter = "U".
        else if i-asc = 221                     then c-caracter = "Y".
        else if i-asc >= 192 and i-asc <= 198       then c-caracter = "A".
        else if i-asc >= 224 and i-asc <= 230       then c-caracter = "a".
        else if i-asc = 231                     then c-caracter = "c".
        else if i-asc >= 223 and i-asc <= 235       then c-caracter = "e".
        else if i-asc >= 236 and i-asc <= 239       then c-caracter = "i".
        else if i-asc = 240                     then c-caracter = "o".
        else if i-asc = 241                     then c-caracter = "n".
        else if i-asc >= 242 and i-asc <= 246       then c-caracter = "o".
        else if i-asc >= 249 and i-asc <= 252       then c-caracter = "u".
        else if i-asc >= 253 and i-asc <= 255       then c-caracter = "y".
        else c-caracter = c-letra.
        c-retorno = c-retorno + c-caracter.

    end.
    if c-retorno = "" then c-retorno = "NULO".
    return c-retorno.
end function.


def temp-table temp-vendas no-undo
    field item              as char format "x(25)"
    field local             as char format "x(10)"
    field dtreferencia      as char format "x(16)"
    
    field qtdvenda          as dec format ">>>>>>>>>>>>9.9999"
    field pcvenda           as dec format ">>>>>>>>>>>>9.99"
    field ctomedio          as dec format ">>>>>>>>>>>>9.9999"
    
    field vltotal           as dec format ">>>>>>>>>>>>9.9999"
    field qtdtickets        as dec format ">>>>>>>>>>>>>>>>>9"
    
    field qtdtransf         as dec format ">>>>>>>>>>>>9.99"
    field estatual          as dec format ">>>>>>>>>>>>9.99"
    
    field totvenda          as dec
    index xx is primary unique item local dtreferencia.

        
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.


def var vestatual as dec.
def var vestcusto as dec.
def var vestvenda as dec.
pause 0 before-hide.


for each tt-ped-colocado.
    delete tt-ped-colocado.
end.
IF NOME-ARQUIVO[8] <> "" OR
   NOME-ARQUIVO[9] <> "" OR
   NOME-ARQUIVO[2] <> ""  OR
   NOME-ARQUIVO[6] <> "" OR
   NOME-ARQUIVO[7] <> "" OR
   NOME-ARQUIVO[10] <> "" OR
   NOME-ARQUIVO[11] <> ""    
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Buscando Pedidos de Venda, transferencia ...".

for each estab no-lock.

    do vabtsit = 1 to 3.
        for each abastipo no-lock.
            for each abastransf where
                    abastransf.abtsit   = cabtsit[vabtsit] and 
                    abastransf.abatipo  = abastipo.abatipo and
                    abastransf.etbcod = estab.etbcod
                    no-lock.

                vdtinclu    = abastransf.dttransf.

                release plani.
                if abastransf.oriplacod <> ?
                then do:
                    find first plani where plani.etbcod = abastransf.orietbcod and
                                           plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    vdtinclu = plani.pladat.        
                end.                            
                vtipo   = if avail plani
                          then "TV"
                          else "TR".
                vobs = if abastransf.abatipo = "ESP"
                       then "PE"
                       else if abastransf.abatipo= "FUT"
                            then "EF"
                            else if abastransf.abatipo = "OUT"
                                 then "OF"
                                 else if abastransf.abatipo = "NEG"
                                      then "VEX"
                                      else if abastransf.abatipo = "NEO"
                                           then "NEOGRID"
                                           else "".

                find produ of abastransf no-lock.
                if produ.catcod = 31 or
                   produ.catcod = 41
                then .
                else next.   

                vdttransf = if abastransf.dttransf <= today + 1
                            then today + 1
                            else abastransf.dttransf.
                venviar = yes.       

                vsomarestoq = vtipo = "TV" /*#34*/ or
                              ( abastransf.abatipo = "COM" 
                                 and produ.catcod = 31   /* 29.10.2019 */
                                    and vdttransf > today + 1) /*#34*/  /* 15.10.19 */
                   .
                                           /* 05.07 */
                if abastransf.dttransf <= today + 1 and
                   vtipo = "TV"
                then do:
                    venviar = no.
                    venviar = yes. /*#30*/
                end.    
                
                if vdttransf <> abastransf.dttransf
                then do:
                    vobs = vobs + /*#30*/ (if vtipo = "TV"
                                           then " PEDVENDA" 
                                           else " NEOGRID")
                                           + " ATRASADO".
                end.    

                create tt-ped-colocado.
                tt-ped-colocado.procod      = abastransf.procod.
                tt-ped-colocado.etbcod      = abastransf.etbcod.
                tt-ped-colocado.abtqtd      = abastransf.abtqtd - abastransf.qtdatend.
                
                tt-ped-colocado.tipo        = vtipo. 
                tt-ped-colocado.origem      = "1".
                tt-ped-colocado.numero      = substring(tt-ped-colocado.tipo + 
                                              string(abastransf.etbcod,"999") + 
                                              string(abastransf.abtcod),1,20).
                                              
                tt-ped-colocado.etbdes      = string(abastransf.etbcod,"999").
                tt-ped-colocado.produto      = string(abastransf.procod).
                
                tt-ped-colocado.dtinclu     = string( year(vdtinclu),"9999") +
                                              string(month(vdtinclu),"99") +
                                              string(  day(vdtinclu),"99").
                tt-ped-colocado.obs         = vobs.
                tt-ped-colocado.data        = string( year(vdttransf),"9999") +
                                              string(month(vdttransf),"99") +
                                              string(  day(vdttransf),"99").
                
                tt-ped-colocado.qtd         = trim(replace(string(abastransf.abtqtd,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.qtdatend    = trim(replace(string(abastransf.qtdatend,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.ORIGEMitem  = string(tt-ped-colocado.produto).

                tt-ped-colocado.origemETB   = "900".
                tt-ped-colocado.origemSAIDA = string( year(vdttransf),"9999") +
                                              string(month(vdttransf),"99") +
                                              string(  day(vdttransf),"99").
                tt-ped-colocado.origemQTD   = trim(replace(string(abastransf.abtqtd,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.origemQTATE = trim(replace(string(abastransf.qtdatend,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.origemFORNE = "900".
                tt-ped-colocado.enviar      = venviar.                     
                tt-ped-colocado.somarestoq  = vsomarestoq.
            end.    
        end.          
    end.
    
    /*#34 retirada esta arte
    for each pedid  where 
            pedid.etbcod = estab.etbcod and
            pedid.pedtdc = 3            and
            pedid.peddat >= today - 45  /*18.06.19 - Enviar tudo que esta em aberto and
            pedid.peddat <= today       */       
        no-lock.
        
        if pedid.sitped = "E" or /* Aguardando Corte */
           pedid.sitped = "L"    /* Cortado */
        then. /* segue*/
        else next.
        
        if pedid.condat <> ? and pedid.condat <> pedid.peddat
        then vdtinclu = pedid.condat.
        else vdtinclu = pedid.peddat.
        
        if vdtinclu = ?
        then next.
        
        vtipo   = if pedid.modcod = "PEDO" or
                     pedid.modcod = "PEDF" or
                     pedid.modcod = "PEDE"
                  then "TV"
                  else "TR".
                       
        vobs = if pedid.modcod = "PEDE"
               then "PE"
               else if pedid.modcod = "PEDF"
                    then "EF"
                    else if pedid.modcod = "PEDO"
                         then "OF"
                         else "".

                vdttransf = if pedid.peddat <= today + 1
                            then today + 1
                            else pedid.peddat.
                venviar = yes.            

                vsomarestoq = vtipo = "TV".

                if pedid.peddat <= today + 1 and
                   vtipo = "TV"
                then venviar = no.
                
                if vdttransf <> pedid.peddat
                then do:
                    vobs = vobs + /*#30*/ (if vtipo = "TV"
                                           then " PEDVENDA" 
                                           else " NEOGRID")
                                          + " ATRASADO".
                end.    

        if vdttransf = ?
        then next.
        
        for each liped of pedid no-lock.

                find produ of liped no-lock.
                if produ.catcod = 31 or
                   produ.catcod = 41
                then .
                else next.   

                create tt-ped-colocado.

                tt-ped-colocado.procod      = liped.procod.
                tt-ped-colocado.etbcod      - liped.etbcod.
                tt-ped-colocado.abtqtd      = liped.lipqtd.

                tt-ped-colocado.tipo        = vtipo. 
                tt-ped-colocado.origem      = "1".
                tt-ped-colocado.numero      = substring(tt-ped-colocado.tipo + 
                                              pedid.modcod +  
                                              string(pedid.pednum) + "_" +
                                              string(liped.procod),1,20).
                tt-ped-colocado.etbdes      = string(pedid.etbcod,"999").
                tt-ped-colocado.produto      = string(liped.procod).
                
                tt-ped-colocado.dtinclu     = string( year(vdtinclu),"9999") +
                                              string(month(vdtinclu),"99") +
                                              string(  day(vdtinclu),"99").
                tt-ped-colocado.obs         = vobs.
                tt-ped-colocado.data        = string( year(vdttransf),"9999") +
                                              string(month(vdttransf),"99") +
                                              string(  day(vdttransf),"99").

                tt-ped-colocado.qtd         = trim(replace(string(liped.lipqtd,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.qtdatend    = trim(replace(string(           0,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.ORIGEMitem  = string(tt-ped-colocado.produto).

                tt-ped-colocado.origemETB   = "900".
                tt-ped-colocado.origemSAIDA = string( year(vdttransf),"9999") +
                                              string(month(vdttransf),"99") +
                                              string(  day(vdttransf),"99").
                tt-ped-colocado.origemQTD   = trim(replace(string(liped.lipqtd,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.origemQTATE = trim(replace(string(0,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.origemFORNE = "900".
                tt-ped-colocado.enviar      = venviar.
                tt-ped-colocado.somarestoq  = vsomarestoq.               
        end.
        
    end.
    #34 **/
end.                
END.


IF NOME-ARQUIVO[6] <> "" OR
   NOME-ARQUIVO[7] <> ""
THEN DO:   
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Calculando Itens Vendidos de"  par-dtini "a" par-dtfim.

for each tipmov where movtdc = 5 or /*300519*/ tipmov.movtdc = 6 no-lock.

    for each estab where estab.etbcod >= 1 and estab.etbcod <= 1000 no-lock. 
        if tipmov.movtdc = 6 and  /* transferencia so deposito */
           estab.etbcod < 500
        then next.
        if    estab.etbcod = 995 /* 24.06.19*/
           or estab.etbcod = 988 /* 01.07.19 */
        then next.
        do vdata = par-dtini to par-dtfim .
            for each plani where plani.movtdc = tipmov.movtdc
                             and plani.etbcod = estab.etbcod
                             and plani.pladat = vdata no-lock.
                for each movim where movim.etbcod = plani.etbcod
                             and movim.placod = plani.placod
                             and movim.movtdc = plani.movtdc
                             and movim.movdat = plani.pladat no-lock,
                    first produ where produ.procod = movim.procod no-lock,
                    first sclase where sclase.clacod = produ.clacod no-lock,
                    first clase where clase.clacod = sclase.clasup no-lock,
                    first grupo where grupo.clacod = clase.clasup no-lock,
                    first setclase where setclase.clacod = grupo.clasup no-lock.
                    if setclase.clacod = 0
                    then next.
                    if produ.catcod = 41 or
                       produ.catcod = 31 
                    then.
                    else next.
                    if produ.proseq = 0
                    then.
                    else next.
                    
                    find fabri of produ no-lock no-error.
                    if not avail fabri then next.
                    find first forne where forne.forcod = fabri.fabcod 
                                no-lock no-error.
                    if not avail forne then next.
                    
                    vlocal  =  string(if movim.movtdc = 6
                                      then 900
                                      else movim.etbcod,"999").
                    cmovdat =  string(year (movim.movdat),"9999") +
                               string(month(movim.movdat),"99"  ) +
                               string(day  (movim.movdat),"99"  ).
            
                    find first temp-vendas where
                            temp-vendas.dtreferencia = cmovdat and
                            temp-vendas.item         = string(movim.procod) and
                            temp-vendas.local        = vlocal
                             no-error.
                    if not avail temp-vendas
                    then do:         
                        create temp-vendas.
                        temp-vendas.dtreferencia = cmovdat.
                        temp-vendas.item     = string(movim.procod).
                        temp-vendas.local   = vlocal.
                    end. 
                    find estoq where estoq.etbcod = movim.etbcod and 
                                    estoq.procod = movim.procod no-lock. 

                    if tipmov.movtdc = 5
                    then do:                
                        temp-vendas.qtdtickets = temp-vendas.qtdtickets + 1.
                        temp-vendas.totvenda   = temp-vendas.totvenda + (movim.movqtm * movim.movpc).
                        temp-vendas.qtdvenda   = temp-vendas.qtdvenda + movim.movqtm .
                        temp-vendas.pcvenda    = temp-vendas.totvenda / temp-vendas.qtdvenda.
                    end.
                    if tipmov.movtdc = 6
                    then do:                
                        temp-vendas.qtdtransf  = temp-vendas.qtdtransf + movim.movqtm .
                    end.

                    /* 29.06.19 */
                    vestatual = if estoq.estatual > 0 then estoq.estatual else 0.
                    if estab.etbcod = 900
                    then do:
                        run /admcom/progr/corte_disponivel.p (input  movim.procod,
                                            output vestoq_depos, 
                                            output vreservas, 
                                            output vdisponivel).
                        vestatual = vdisponivel.
                    end.
                    if vestatual < 0 then vestatual = 0.                
                    temp-vendas.ctomedio = if avail estoq then estoq.estcusto else 0.
                    temp-vendas.estatual = vestatual.

                    /* 19.06.19*/
                    vpedfuturo = 0.
                    for each tt-ped-colocado where
                        tt-ped-colocado.procod      = movim.procod and
                        tt-ped-colocado.etbcod      = movim.etbcod and
                        tt-ped-colocado.somarestoq  = yes: /* 05.07 */
                        
                        vpedfuturo = vpedfuturo + tt-ped-colocado.abtqtd.
                    end.    
                    temp-vendas.estatual = temp-vendas.estatual + vpedfuturo.
                    
                end.    /*  for each movim      */
            end.    /*  for each plani      */
        end.    /*  do vdata = vdtini   */
    end.    /*  for each estab      */
end.        /*  for each tipmov     */
END.


vconta = 0.
vtot = 0.
IF NOME-ARQUIVO[1] <> "" 
then do:

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando itens...".
output to value(tmp-arquivo[1]).
for each neoitem where neoitem.situacao = yes no-lock.

    find produ of neoitem no-lock.
                   
        put unformatted 
           string(neoitem.procod)    vcp
           neoitem.ean     vcp
           neoitem.descr   vcp
           neoitem.unidade vcp
           neoitem.emb     vcp
           neoitem.fornecedor  vcp
           neoitem.categoria  vcp
        /*#1   neoitem.dgrupo1 vcp */
           neoitem.clasetor vcp
           neoitem.clagrupo vcp
           neoitem.claclase vcp
           neoitem.clasclase vcp
           neoitem.estacao vcp
           "" vcp
           "" vcp
           "" vcp
        /*#1*/   neoitem.temporada vcp
           neoitem.caract1 vcp
           neoitem.subcaract1 vcp
           neoitem.caract2 vcp
           neoitem.subcaract2 vcp
           neoitem.tipo 
               
        skip.
end.
output close. 

END.

IF NOME-ARQUIVO[2] <> "" 
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando origens...".
output to value(tmp-arquivo[2]).
for each neoitem where neoitem.situacao = yes no-lock.
    for each neoitefil 
        where neoitefil.situacao = yes and
              neoitefil.procod = neoitem.procod 
        no-lock. 
        put unformatted 
                       string(neoitefil.procod)          vcp
                       string(neoitefil.etbcod,"999")        vcp
                       "1" vcp /* #1 */
                       neoitefil.sku-item-origem         vcp
                       neoitefil.sku-local-origem        vcp
                       neoitefil.sku-empresa-origem      vcp
                       neoitefil.sku-forne-origem        vcp
                       "1"              vcp
                       "1"              vcp
                       neoitefil.sku-LEADTIME        vcp
                       neoitefil.sku-LEADTIMEDP        vcp    
               
                       neoitefil.sku-lote                vcp
                       neoitefil.sku-unitizacao                
               
                    skip.

    end.
end.
output close.
END.

IF NOME-ARQUIVO[8] <> "" 
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando SKU_Estoque...".
output to value(tmp-arquivo[8]).
for each neoitem where neoitem.situacao = yes no-lock.
    for each neoitefil 
        where neoitefil.situacao = yes and
              neoitefil.procod = neoitem.procod 
        no-lock. 
        find produ of neoitefil no-lock.
        find estab of neoitefil no-lock.
                
        find estoq900 where estoq900.etbcod = 900 and
                            estoq900.procod = produ.procod
                        no-lock no-error.
        t900 = if avail estoq900 
               then estoq900.estatual
               else 0.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod
                    no-lock no-error.
        vestatual   = if avail estoq and estoq.estatual > 0
                      then estoq.estatual
                      else 0.

        
                    /* 19.06.19*/
                    vpedfuturo = 0.
                    for each tt-ped-colocado where
                        tt-ped-colocado.procod      = produ.procod and
                        tt-ped-colocado.etbcod      = estab.etbcod and
                        tt-ped-colocado.somarestoq  = yes :  /* 05.07 */
                        vpedfuturo = vpedfuturo + tt-ped-colocado.abtqtd.
                    end.    
                    vestatual = vestatual + vpedfuturo.

        vestcusto  = if avail estoq900 then estoq900.estcusto else 0.
        vestvenda  = if avail estoq
                     then estoq.estvenda
                     else if avail estoq900
                           then estoq900.estvenda
                           else 0.
    
         
            if estab.etbcod = 900
            then do:
                run /admcom/progr/corte_disponivel.p (input  produ.procod,
                                    output vestoq_depos, 
                                    output vreservas, 
                                    output vdisponivel).
                vestatual = vdisponivel.
            end.
        
            put unformatted 
                 string(produ.procod)      vcp     
                 string(estab.etbcod,"999")  vcp      
                 string(year (today),"9999") + 
                 string(month(today),"99"  ) +  
                 string(day  (today),"99"  ) vcp     
                 trim(replace(string(if vestatual > 0 then vestatual else 0,">>>>>>>9.999"),".",","))  vcp     
                 trim(replace(string(vestcusto,">>>>>9.99"),".",","))       
                skip.
    
        
    end.
end.    
output close.
END.

IF NOME-ARQUIVO[3] <> ""
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando ESTABS...".

output to value(tmp-arquivo[3]).
for each estab no-lock.

    if estab.tipoloja = "VIRTUAL" then next. /*25.04.19, nao enviar loja virtual*/
    
    find regiao of estab no-lock no-error.

    put unformatted 
        string(estab.etbcod,"999")    vcp
        estab.etbnom    vcp
        if estab.tamanho = "" then "N/A" else caps(estab.tamanho)   vcp
        if estab.tipoloja = "" then "N/A" else caps(estab.tipoloja)  vcp
        estab.ufecod    vcp
        regiao.regnom   vcp
        "0"             vcp
        "1"             vcp
        "0"             vcp
        ""            vcp
        "0"             vcp 
        ""            vcp
        if estab.munic = "" then "NULO" else estab.munic     
        skip.
    
end.            
output close.       
END.


IF NOME-ARQUIVO[4] <> ""
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Filiais...".
    output to value(tmp-arquivo[4]).
    for each estab no-lock.
        find regiao of estab no-lock no-error.
        put unformatted 
            string(estab.etbcod,"999") vcp
            estab.etbnom vcp
            if estab.tamanho = "" then "N/A" else caps(estab.tamanho) vcp
            if estab.tamanho = "" then "N/A" else caps(estab.tipoloja) vcp
            if estab.ufecod = "" then "N/A" else estab.ufecod    vcp
            if not avail regiao then "N/A" else regiao.regnom   vcp
            if estab.munic = "" then "N/A" else estab.munic vcp
            "" vcp
            "" vcp /* ponto e virgula de excecao */
            skip.
    end.            
    output close.       
END.

IF NOME-ARQUIVO[5] <> ""
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Fornecedores...".
output to value(tmp-arquivo[5]).
for each fabri no-lock. 
    find first forne where forne.forcod = fabri.fabcod no-lock no-error.
    if not avail forne then next.
    put unformatted 
        forne.forcod        vcp
        forne.forpai        vcp
        retira-acento(forne.fornom) format "x(40)"       vcp
        forne.forNacionalidade  vcp
        retira-acento(forne.forcont)       vcp
        "" /*retira-acento(forne.forfone) */      vcp
        ""                  vcp
        retira-acento(forne.email) format "x(40)"       vcp
        retira-acento(forne.forrua)        vcp
        retira-acento(forne.forcep)        vcp
        retira-acento(forne.ufecod)        vcp
        retira-acento(forne.formunic)      vcp
        retira-acento(forne.forpais)       vcp        
        ""                vcp
        "0"                
        skip.
end.
output close.       
END.

IF NOME-ARQUIVO[6] <> ""
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando VENDAS...".
output to value(tmp-arquivo[6] ).                    
for each temp-vendas.

    put unformatted
        temp-vendas.Item                     vcp
        temp-vendas.Local                    vcp
        "LOJASLEBES"                        vcp    
        temp-vendas.DtReferencia             vcp
        trim(replace(string(temp-vendas.qtdvenda  ,">>>>>>>>>>9.999"),".",",")) vcp
        trim(replace(string(0                     ,">>>>>>>>>>9.999"),".",",")) vcp
        trim(replace(string(temp-vendas.pcvenda   ,">>>>>>>9.99"  ),".",",")) vcp
        trim(replace(string(if temp-vendas.pcvenda - temp-vendas.ctomedio > 0
                            then temp-vendas.pcvenda - temp-vendas.ctomedio 
                            else 0 ,">>>>>>>9.99"),".",",")) vcp
        temp-vendas.Local                   
        
        skip.

end. 
output close.
END.

IF NOME-ARQUIVO[7] <> ""
THEN DO:
hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando VENDAS...".
output to value(tmp-arquivo[7] ).                    

for each temp-vendas.

    put unformatted
        temp-vendas.Item                     vcp
        temp-vendas.Local                    vcp
        temp-vendas.DtReferencia             vcp
        trim(replace(string(temp-vendas.qtdvenda  ,">>>>>>>9.999"),".",",")) vcp 
        trim(replace(string(0                     ,">>>>>>>9.999"),".",",")) vcp
        trim(replace(string(temp-vendas.pcvenda   ,">>>>>>>>>>9.99"  ),".",",")) vcp 
        trim(replace(string(if temp-vendas.pcvenda - temp-vendas.ctomedio > 0
                            then temp-vendas.pcvenda - temp-vendas.ctomedio
                            else 0  ,">>>>>>>>>>9.99"),".",",")) vcp

        trim(replace(string(temp-vendas.qtdtransf ,">>>>>>>9.999"),".",",")) vcp 
        trim(replace(string(0                     ,">>>>>>>9.999"),".",",")) vcp
        trim(replace(string(temp-vendas.ctomedio  ,">>>>>9.99"),".",",")) vcp
        trim(replace(string(temp-vendas.estatual  ,">>>>>>>9.999"),".",",")) vcp

        "" vcp /* excecao */               
        skip.

end. 
output close.
END.


IF NOME-ARQUIVO[9] <> ""
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Mix ...".
output to value(tmp-arquivo[9] ).                    

for each neoitem where neoitem.situacao = yes no-lock.
    for each neoitefil where neoitefil.situacao = yes and
                             neoitefil.procod   = neoitem.procod
                             no-lock.
      
      if neoitefil.mix-grade = ?
      then next.
      
      put unformatted
                    string(neoitefil.procod) vcp
                    string(neoitefil.etbcod,"999") vcp
                    trim(replace(string(neoitefil.mix-grade,">>>>>9"),".",","))
                    skip.
            
    end.
end.
output close.
END.


IF NOME-ARQUIVO[10] <> "" OR
   NOME-ARQUIVO[11] <> ""
THEN DO:    

IF NOME-ARQUIVO[11] <> ""
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Buscando Pedidos Compras...".
for each estab no-lock.
for each pedid where 
            pedid.pedtdc = 1            and
            pedid.etbcod = estab.etbcod and
            pedid.peddat >= 01/01/2018
        no-lock.
        
        if pedid.sitped = "A" or
           pedid.sitped = "P"
        then.
        else next.
        
        vdtinclu = pedid.peddat.
        if vdtinclu <= 01/01/2018
        then next.
        
        vtipo   = "CO".
                       
        vobs = "".

        if vdtinclu = ?
        then next.
        if pedid.peddtf = ?
        then next.
        
        for each liped of pedid no-lock.
                if liped.lipqtd <= liped.lipent
                then next.
                
                find produ of liped no-lock.
                if produ.catcod = 31 or
                   produ.catcod = 41
                then .
                else next.   

                create tt-ped-colocado.
                tt-ped-colocado.procod      = liped.procod.
                tt-ped-colocado.etbcod      = 900.
                tt-ped-colocado.abtqtd      = 0. /* so para as transf */
                
                tt-ped-colocado.tipo        = vtipo. 
                tt-ped-colocado.origem      = "".
                tt-ped-colocado.numero      = substring(tt-ped-colocado.tipo + "-" + 
                                              string(pedid.pednum),1,20).
                tt-ped-colocado.etbdes      = "900" /*(string(pedid.etbcod,"999")*/ .
                tt-ped-colocado.produto      = string(liped.procod).
                
                tt-ped-colocado.dtinclu     = string( year(vdtinclu),"9999") +
                                              string(month(vdtinclu),"99") +
                                              string(  day(vdtinclu),"99").
                tt-ped-colocado.obs         = vobs.
                tt-ped-colocado.data        = string( year(pedid.peddtf),"9999") +
                                              string(month(pedid.peddtf),"99") +
                                              string(  day(pedid.peddtf),"99").

                tt-ped-colocado.qtd         = trim(replace(string(liped.lipqtd,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.qtdatend    = trim(replace(string(liped.lipent,">>>>>>>>9.999"),".",",")).
                tt-ped-colocado.origemITEM  = "".

                tt-ped-colocado.origemETB   = "".
                tt-ped-colocado.origemSAIDA = "".
                tt-ped-colocado.origemQTD   = "".
                tt-ped-colocado.origemQTATE = "".
                tt-ped-colocado.origemFORNE = string(pedid.clfcod).
                tt-ped-colocado.enviar      = yes.
                tt-ped-colocado.somarestoq  = no.  
                               
        end.
        
end.                
end.
END.

IF NOME-ARQUIVO[10] <> ""
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Interface PedidoVenda...".
/*pedidoVenda*/
output to value(tmp-arquivo[10] ).                    

for each tt-ped-colocado where tt-ped-colocado.tipo = "TV"
        and tt-ped-colocado.enviar = yes.

        put unformatted
            "A" vcp
            "3" vcp
            tt-ped-colocado.numero vcp
            "" vcp
            tt-ped-colocado.produto vcp
            tt-ped-colocado.produto vcp
            tt-ped-colocado.etbdes vcp
            tt-ped-colocado.etbdes vcp
            "LOJASLEBES"    vcp
            tt-ped-colocado.data vcp
            tt-ped-colocado.dtinclu vcp
            tt-ped-colocado.qtd  vcp
            tt-ped-colocado.qtdatend vcp 

            "" vcp /* excecao */               
            skip.
    
end. 
output close.
END. /* [10] */

IF NOME-ARQUIVO[11] <> ""
THEN DO:
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Exportando Ped_Colocado...".
output to value(tmp-arquivo[11] ).                    
for each tt-ped-colocado
        where tt-ped-colocado.enviar = yes.

        put unformatted
            "A" vcp
            tt-ped-colocado.numero vcp
            "" vcp
            tt-ped-colocado.dtinclu vcp
            tt-ped-colocado.obs vcp
            "1" vcp
            tt-ped-colocado.produto vcp
            tt-ped-colocado.etbdes vcp
            tt-ped-colocado.data vcp
            tt-ped-colocado.qtd  vcp
            tt-ped-colocado.qtdatend vcp 
            
            tt-ped-colocado.origem vcp
            tt-ped-colocado.ORIGEMitem vcp
            tt-ped-colocado.origemETB   vcp
            tt-ped-colocado.origemSAIDA vcp
            tt-ped-colocado.origemQTD   vcp
            tt-ped-colocado.origemQTATE vcp
            tt-ped-colocado.origemFORNE
            skip.
    delete tt-ped-colocado.
    
end.
output close.
END. /* [11] */
END. /* [10] or [11] */



hide message no-pause.

message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "Encerrando...".

do vloop = 1 to 11:
    IF NOME-ARQUIVO[VLOOP] = "" THEN NEXT.
    unix silent value ("unix2dos -q " + tmp-arquivo[vloop]).
    unix silent value ("mv -f " + tmp-arquivo[vloop] + " " + nome-arquivo[vloop]).
    
end.    

if sresp
then do on error undo:
        find abasintegracao where recid(abasintegracao) = prec exclusive no-wait no-error.
        if avail abasintegracao
        then do:
            ASSIGN
                abasintegracao.dtfim             = today
                abasintegracao.HrFim             = time.
        end.                
end.

hide message no-pause.
message today string(time,"HH:MM:SS") string(time - xtime,"HH:MM:SS") "FIM" vdir-arquivo.

