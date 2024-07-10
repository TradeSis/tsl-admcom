/*
    fo#1 26.09.19 helio.neto - trello - Divisão de Margem de Desconto por Categoria 
*/
{admcab.i}
{rest-cli/wc-consultamargemdesconto.i new}

def var vpercmed like plani.platot.
def var vpercmed31 like plani.platot.
def var vpercmed41  like plani.platot.

     
def temp-table tt-plani no-undo
    field rec   as recid
    field etbcod like plani.etbcod
    field placod like plani.placod
    field movtdc like plani.movtdc
    field numero like plani.numero
    field serie  like plani.serie
    field pladat like plani.pladat
    field platot like plani.platot
    field catcod    like produ.catcod label "Cat" column-label "Cat"
    field plades like plani.descprod
    
    field pctdes as dec
    field tipo   as char
    index i1 is unique primary numero asc etbcod asc placod asc.

def var vcatcod like categoria.catcod.
def var val-total-movim as dec.
def var val-total-plani as dec.
def var val-total-movim41 as dec.
def var val-total-plani41 as dec.

def var vetbcod like estab.etbcod.

def var vdti as date.
def var vdtf as date.

def var vdata as date.
def var vokd as log.
def var vokc as log.
def var vltotven as dec decimals 2.
def var vltotven31 as dec decimals 2. 
def var vltotven41 as dec decimals 2.


def var vltotdes as dec.
def var vltotdes31 as dec.
def var vltotdes41 as dec.
vdti = today - 30.
vdtf = today. 
vetbcod = setbcod.
if vetbcod = 999
then do:
update vetbcod label "Filial"
    with frame f1 1 down width 80 side-label.
end.
disp vetbcod with frame f1.
find estab where estab.etbcod = vetbcod no-lock.
disp estab.etbnom no-label with frame f1.  
if setbcod <> 999
then do:
    sresp = no.
    run p-valsenha.
    if sresp = no then return.
end.

update vdti at 1 label "Periodo de"
     vdtf label "ate"
     with frame f3 centered no-box side-label.

if vdti >= 07/01/2020 /* sap*/
then do:
 
    run psap.
    
    return.
end. 

do vdata = vdti to vdtf:
    for each plani where   plani.movtdc = 5 and
                       plani.etbcod = vetbcod and
                       plani.pladat = vdata
                       no-lock:
        
        if acha("DESCONTO_FUNCIONARIO",plani.notobs[3]) = "SIM"
        then next.
        
        val-total-plani = 0.
    
        if plani.biss > plani.platot - plani.vlserv
        then val-total-plani = plani.biss.
        else val-total-plani = plani.platot - plani.vlserv.
            
        val-total-movim = 0.
        val-total-movim41 = 0.
        vokd = yes.
        vokc = no.
        vcatcod = 0.
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            /**
            if produ.clacod = 101 or
               produ.clacod = 102 or
               produ.clacod = 107 or
               produ.clacod = 109 or
               produ.clacod = 201 or
               produ.clacod = 191 or
               produ.clacod = 181
            then do:
                vokd = no.
                leave.
            end.
            **/
            
            if produ.catcod = 31
            then do:
                vcatcod = 31.
                vokc = yes.
                val-total-movim = 
                        val-total-movim + (movim.movpc * movim.movqtm).
            end.
            if produ.catcod = 41
            then do:
                vcatcod = 41.
                vokc = yes.
                val-total-movim41 = 
                        val-total-movim41 + (movim.movpc * movim.movqtm).

            end.
        end.   
        if vokc = no then next.

        val-total-plani41 = val-total-plani * (val-total-movim41 / plani.protot).
        val-total-plani   = val-total-plani * (val-total-movim / plani.protot).
        
        vltotven = vltotven + (val-total-plani + val-total-plani41).
        if vcatcod = 31
        then do:
            vltotven31 = vltotven31 + val-total-plani.
        end.
        if vcatcod = 41
        then do:    
            vltotven41 = vltotven41 + val-total-plani41.
        end.
        
        if vokd = no then next.
        
        if plani.notobs[2] <> ""
        then do:
            if acha("DESCONTO",plani.notobs[2]) <> ?
            then do:
                create tt-plani.
                tt-plani.rec = recid(plani).
                assign
                    tt-plani.etbcod = plani.etbcod
                    tt-plani.placod = plani.placod
                    tt-plani.movtdc = plani.movtdc
                    tt-plani.numero = plani.numero
                    tt-plani.serie  = plani.serie
                    tt-plani.pladat = plani.pladat
                    tt-plani.platot = if plani.biss > 0
                                   then plani.biss else plani.platot
                    tt-plani.plades = dec(acha("DESCONTO",plani.notobs[2])) 
                    tt-plani.tipo = "V" .
                    tt-plani.catcod = vcatcod.
                    
                vltotdes = vltotdes + dec(acha("DESCONTO",plani.notobs[2])).
                if vcatcod = 31
                then do:
                    vltotdes31 = vltotdes31 + dec(acha("DESCONTO",plani.notobs[2])).
                end.
                if vcatcod = 41
                then do:
                    vltotdes41 = vltotdes41 + dec(acha("DESCONTO",plani.notobs[2])).
                end.
                
            end.
            else do:
                if substr(plani.notobs[2],1,1) <> "J" and
                      dec(plani.notobs[2]) > 0
                then vltotdes = vltotdes + dec(plani.notobs[2]).
            end.
        end.
    end.
end.


vpercmed = ((vltotdes / vltotven) * 100).
vpercmed31 = ((vltotdes31 / vltotven31) * 100).
vpercmed41 = ((vltotdes41 / vltotven41) * 100).


disp "   " at 1
     vltotven at 3 label "Venda   " format ">,>>>,>>9.99"
     vltotdes at 3 label "Desconto" format ">,>>>,>>9.99"
     vpercmed at 3 label "Percent " format ">>>9.99%"
     "    " at 1
     "MOVEIS" at 1
     
     vltotven31 at 3 label "Venda   " format ">,>>>,>>9.99"
     vltotdes31 at 3 label "Desconto" format ">,>>>,>>9.99"
     vpercmed31 at 3 label "Percent " format ">>>9.99%"
     "    " at 1
     "MODA" at 1

     vltotven41 at 3 label "Venda   " format ">,>>>,>>9.99"
     vltotdes41 at 3 label "Desconto" format ">,>>>,>>9.99"
     vpercmed41 at 3 label "Percent " format ">>>9.99%"
     "    " at 1
     
     with frame f2 color message no-box
     row 8 column 1 side-label.
form tt-plani.numero format ">>>>>>>9"
     tt-plani.pladat format "99/99/99"
     tt-plani.platot
     tt-plani.catcod
     tt-plani.plades format "->>>,>>9.99"
     /*tt-plani.pctdes label "Pct" format "->>9.99%"
     tt-plani.tipo no-label format "!"   */
     with frame f-linha down column 25 width 55
     title "  VENDAS COM DESCONTO  " .

for each tt-plani:
    if tt-plani.plades = 0
    then delete tt-plani.
    else tt-plani.pctdes = (tt-plani.plades / tt-plani.platot) * 100.
end.    
{setbrw.i}
    {sklcls.i
        &help = "                   ENTER = Produtos da venda"
        &file = tt-plani
        &cfield = tt-plani.numero
        &noncharacter = /*
        &ofield = "
            tt-plani.pladat 
            tt-plani.platot
            tt-plani.catcod
            tt-plani.plades
            "
        &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            then do on endkey undo:
                run not_consnota.p (tt-plani.rec).
                /**
                for each movim where movim.etbcod = tt-plani.etbcod and
                                     movim.placod = tt-plani.placod and
                                     movim.movtdc = tt-plani.movtdc and
                                     movim.movdat = tt-plani.pladat
                                     no-lock.
                    find produ where produ.procod = movim.procod no-lock.
                    FIND ESTOQ WHERE estoq.etbcod = movim.etbcod and
                                     estoq.procod = produ.procod
                                     no-lock.
                    disp movim.procod 
                         produ.pronom  format ""x(30)""
                         movim.movqtm format "">>>9"" column-label ""Qtd""
                         movim.movpc  format "">,>>>,>>9.99""
                         estoq.estvenda  format "">,>>>,>>9.99""
                         with frame f-mov down
                         row 10 column 11 width 70 overlay
                         title ""  "" + string(tt-plani.numero) + ""  "" + 
                         string(tt-plani.pladat,""99/99/9999"") + ""  "" +
                         string(tt-plani.platot,"">>,>>9.99"") + ""  "" +
                         string(tt-plani.plades,"">>,>>9.99"") + ""  "".
                end.
                pause.
                */
                
                next keys-loop.
            end.
            else next keys-loop.
            "
        &where = true
        &form = " frame f-linha "
}              
 

 procedure p-valsenha:
     def var vfuncod like func.funcod.
     def var vsenha like func.senha.
     def buffer bfunc for func.
     
     vfuncod = 0. vsenha = "". sresp = no.
     
     update vfuncod label "Matricula"
            vsenha  label "Senha" blank
            with frame f-senha side-label centered color message row 10.

     find bfunc where bfunc.etbcod = setbcod
                  and bfunc.funcod = vfuncod no-lock no-error.
     if not avail bfunc
     then do:
         message "Funcionario Invalido".
         sresp = no.
         undo, retry.
     end.
     if bfunc.funmec = no
     then do:
        message "Funcionario nao e gerente".
        sresp = no.
        undo, retry.
     end.
     if vsenha <> bfunc.senha
     then do:
         message "Senha invalida".
         sresp = no.
         undo, retry.
     end.
     else sresp = yes.
     hide frame f-senha no-pause.
end.


procedure psap.
def var vcodigoLoja             as int format ">>9" label "Loj".
def var vtotalVenda             as dec format ">>>>>>>9" label "Venda".
def var vpercDescontoProdutoMax as dec format "->>9.99" column-label "Perc!Max!Produto".
def var vvalorDescontoDisponivel as dec format "->>>>>>9" column-label "Desc!Disp.!Loja". /* helio 080224 - troca nomenclatura */
def var vvalorDescontoUtilizado  as dec format "->>>>>>9" column-label "Desc!Utiliz".
def var vmargemRegional        as dec format "->>9.99" column-label "Marg!Regio".
def var vmargem        as dec format "->>9.99" column-label "Marg!Loja".


def var vperiodoVendaInicial     as date format "999999" label "De".
def var vperiodoVendaFinal     as date format "999999" label "Ate".

/*     field totalVendaComAcrescimo   as char     /*":"120000.00",*/ 
     field margem       as char     /*":"2",*/ 
  */
  
create ttconsultamargemdescontoEntrada.
ttconsultamargemdescontoEntrada.codigoLoja      = string(vetbcod).
ttconsultamargemdescontoEntrada.codigoProduto   = "0".
ttconsultamargemdescontoEntrada.valorProduto     = "0".
ttconsultamargemdescontoEntrada.valorDescontoSolicitado = "0".
ttconsultamargemdescontoEntrada.codigoOperador  = "0".

message "aguarde....".
run api/margemdesconto.p.
/*
run rest-cli/wc-consultamargemdesconto.p.
*/  
find first ttmargemdesconto no-error.
if not avail ttmargemdesconto
then do:
    find first ttretornomargemdesconto no-error.
    if avail ttretornomargemdesconto
    then do:
        hide message no-pause.
        message "rest-cli barramento consultamargemdesconto" ttretornomargemdesconto.tstatus ttretornomargemdesconto.descricao. 
        message "valores nao retornados pelo barramento" view-as alert-box. 
    end.
end.
else do:
    find first ttmargemdesconto no-error.
    if not avail ttmargemdesconto
    then do:
        message "valores nao retornados pelo barramento" view-as alert-box.
        return.
    end.
    for each ttmargemdesconto.
        /**
         field codigoLoja   as char     /*":"28",*/ 
     field linha        as char     /*":"MOVEIS",*/ 
     field totalVenda   as char     /*":"90000.00",*/ 
     field totalVendaComAcrescimo   as char     /*":"120000.00",*/ 
     field margem       as char     /*":"2",*/ 
     field percDescontoProdutoMax   as char /*":"10",*/ 
     field valorDescontoDisponivel  as char /*":"2000.00",*/ 
     field valorDescontoUtilizado   as char /*":"400.00",*/ 
     field periodoVendaInicial      as char /*":"2019-12-31",*/ 
     field periodoVendaFinal        as char. /*":"2020-01-30" */
           **/
        vcodigoLoja = int(ttmargemdesconto.codigoLoja).
        
        vperiodoVendaInicial = date(int(substr(ttmargemdesconto.periodoVendaInicial,6,2)),
                                    int(substr(ttmargemdesconto.periodoVendaInicial,9,2)),
                                    int(substr(ttmargemdesconto.periodoVendaInicial,1,4))).
        vperiodoVendaFinal = date(int(substr(ttmargemdesconto.periodoVendaFinal,6,2)),
                                    int(substr(ttmargemdesconto.periodoVendaFinal,9,2)),
                                    int(substr(ttmargemdesconto.periodoVendaFinal,1,4))).

        vtotalVenda = dec(ttmargemdesconto.totalVenda).
        vpercDescontoProdutoMax = dec(percDescontoProdutoMax).
        vvalorDescontoDisponivel = dec(valorDescontoDisponivel).
        vvalorDescontoUtilizado = dec(valorDescontoUtilizado).
        vmargem = dec(ttmargemdesconto.margem).
        vmargemRegional = dec(ttmargemdesconto.margemRegional).
        

    hide message no-pause.
    message "Informacoes do SAP". 
        
        disp 
            vcodigoLoja 
            linha      format "x(6)"
            vperiodoVendaInicial
            vperiodoVendaFinal
            vtotalVenda 
            vvalorDescontoUtilizado
            vvalorDescontoDisponivel
            vpercDescontoProdutoMax
            vmargem
            /* helio 080224 - retirado Marg Regio
            *vmargemRegional
            */
            with color messages centered.
    end.        

    hide message no-pause.
    message "Informacoes do SAP". 
    pause.
end.




end procedure.
