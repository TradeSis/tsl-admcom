{admcab.i}
{rest-cli/wc-consultamargemdesconto.i new}

def stream csv.

def var vplanilha    as log format "Sim/Nao" init yes.
def var vcatcod like produ.catcod.

def var vpercmed31 like plani.platot format ">>>9.99".
def var vpercmed41  like plani.platot format ">>>9.99".

def var val-total-movim as dec.
def var val-total-plani as dec.
def var val-total-movim41 as dec.
def var val-total-plani41 as dec.

def var vetbcod like estab.etbcod.


def var vdata as date.
def var vokd as log.
def var vokc as log.
def var vltotven as dec decimals 2.
def var vltotven31 as dec decimals 2. 
def var vltotven41 as dec decimals 2.


def var vltotdes as dec.
def var vltotdes31 as dec.
def var vltotdes41 as dec.

def var v-flini like plani.etbcod init 1.
def var v-flfim like plani.etbcod init 1.
def var v-dtini like plani.pladat.
def var v-dtfim like plani.pladat.
def var v-totalvenda like plani.platot.
def var v-valdesc like plani.platot.
def var v-percent like plani.platot.

def var vpercmed like plani.platot format ">>>9.99".

def var vok as log.

v-dtini = today - 30.
v-dtfim = today.

v-totalvenda = 0.

vltotven = 0.
vltotdes = 0.

update v-flini label "Filial inicial"
           v-flfim label "Filial final"
with frame f1 centered side-label title "  Informe os dados  " width 80 overlay.

update "Periodo de: " v-dtini no-label "ate: " v-dtfim no-label with frame f1 centered width 80.

if v-flini > v-flfim then do:
  message "Filial final deve ser diferente da inicial!" view-as alert-box title "  ATENCAO!  ".
  undo, retry.
end.

if v-dtini >= 07/01/2020 /* sap*/
then do:
    message "Para periodo apos 01/07/2020, virada SAP, o resultado eh fornecido pelo barramento"
    view-as alert-box.
end. 




pause 0.
update vplanilha label "Gerar Planilha?"
    with side-labels centered row 5 overlay no-box.

if vplanilha
then do:
    unix silent value("rm -f /admcom/relat/consulta_desconto.csv").

    output stream csv to /admcom/relat/consulta_desconto.csv.
    put stream csv unformatted 
        "Filial"    ";"
        "Venda"     ";"
        "Desconto"  ";"
        "%%%"       ";"
        "Moveis Venda"          ";"
        "Moveis Desconto"       ";"
        "Moveis %%%"            ";"
        "Moda Venda"            ";"
        "Moda Desconto"       ";"
        "Moda %%%"            
        skip.        
end.


if v-dtini >= 07/01/2020 /* sap*/
then do:
 
    run psap.
    
    return.
end. 


/*disp v-flini v-flfim v-dtini v-dtfim.*/
for each estab where estab.etbcod >= v-flini and estab.etbcod <= v-flfim no-lock,
    each plani where plani.etbcod = estab.etbcod and 
                     plani.pladat >= v-dtini and 
                     plani.pladat <= v-dtfim and
                                         movtdc = 5 no-lock
                                         break by plani.etbcod:

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
            /*
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
            */ 
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
        if vokc 
        then do:

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
        
        if vokd = yes
        then do:
        if plani.notobs[2] <> ""
        then do:
            if acha("DESCONTO",plani.notobs[2]) <> ?
            then do:
                    
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

        if last-of(plani.etbcod)
    then do:
        vpercmed = ((vltotdes / vltotven) * 100).
        vpercmed31 = ((vltotdes31 / vltotven31) * 100).
        vpercmed41 = ((vltotdes41 / vltotven41) * 100).
          
      /*disp "Vnd FL " + string(plani.etbcod) + ":" format "x(9)"
        vltotven  no-label
        "Desc FL " + string(plani.etbcod) + ":" format "x(10)"
        vltotdes  no-label
        "Perc FL " + string(plani.etbcod) + ":" format "x(10)"
        vpercmed + "%"  no-label*/
        
        disp 
            estab.etbcod column-label "Fil" format ">>9"
          vltotven column-label "Venda" format ">>>>>>9"
          vltotdes column-label "Desc." format ">>>>9"
          vpercmed column-label "%%%" format ">>9.99"
          "|"
          vltotven31 column-label "Moveis!Venda" format ">>>>>>9"
          vltotdes31 column-label "Desc." format ">>>>9"
          vpercmed31 column-label "%%%" format ">>9.99"
          "|"
          vltotven41 column-label "Moda!Venda" format ">>>>>>9"
          vltotdes41 column-label "Desc." format ">>>>9"
          vpercmed41 column-label "%%%" format ">>9.99"
          
          
        with frame f2 down centered no-box.
        if vplanilha
        then do:    
            put stream csv unformatted
              estab.etbcod  format ">>9"        ";"
              vltotven      format ">>>>>>9.99"    ";"
              vltotdes      format ">>>>9.99"      ";"
              vpercmed      format ">>9.99"     ";"
              vltotven31    format ">>>>>>9.99"    ";"
              vltotdes31    format ">>>>9.99"      ";"
              vpercmed31    format ">>9.99"     ";"
              vltotven41    format ">>>>>>9.99"    ";"
              vltotdes41    format ">>>>9.99"      ";"
              vpercmed41    format ">>9.99"     ";"
                skip.
        end. 
        
        vltotven = 0. vltotven31 = 0. vltotven41 = 0. 
        vltotdes = 0. vltotdes31 = 0. vltotdes41 = 0.
        vpercmed = 0.
    end.


end.

if vplanilha
then do:
    output stream csv close.
    message "ARQUIVO consulta_desconto.csv GERADO COM SUCESSO EM L:/relat".
    pause 3 no-message.
end.

/***#1 run consulta_desconto_2.p (input v-flini, v-flfim). */




procedure psap.

for each estab where estab.etbcod >= v-flini and estab.etbcod <= v-flfim no-lock.
    for each ttconsultamargemdescontoEntrada.
        delete ttconsultamargemdescontoEntrada.
    end.
    for each ttmargemdesconto.
            delete ttmargemdesconto.
    end.
    for each  ttmargemDescontoProduto.
        delete ttmargemDescontoProduto.
    end.
        
    create ttconsultamargemdescontoEntrada.
    ttconsultamargemdescontoEntrada.codigoLoja      = string(estab.etbcod).
    ttconsultamargemdescontoEntrada.codigoProduto   = "0".
    ttconsultamargemdescontoEntrada.valorProduto     = "0".
    ttconsultamargemdescontoEntrada.valorDescontoSolicitado = "0".
    ttconsultamargemdescontoEntrada.codigoOperador  = "0".

    hide message no-pause.
    message "aguarde....".
    run rest-cli/wc-consultamargemdesconto.p.

    find first ttmargemdesconto no-error.
    if avail ttmargemdesconto
    then     do:
        for each ttmargemdesconto.
            if ttmargemdesconto.linha = "MOVEIS"
            then do:
                vltotven31 = dec(ttmargemdesconto.totalVenda).
                vltotdes31 = dec(ttmargemdesconto.valorDescontoUtilizado).
            end.
            else do:
                vltotven41 = dec(ttmargemdesconto.totalVenda).
                vltotdes41 = dec(ttmargemdesconto.valorDescontoUtilizado).
            end. 
            vltotven = vltotven31 + vltotven41.
            vltotdes = vltotdes31 + vltotdes41.
        
            vpercmed = ((vltotdes / vltotven) * 100).
            vpercmed31 = ((vltotdes31 / vltotven31) * 100).
            vpercmed41 = ((vltotdes41 / vltotven41) * 100).
            delete ttmargemdesconto.
        end.
        disp 
            estab.etbcod column-label "Fil" format ">>9"
          vltotven column-label "Venda" format ">>>>>>9"
          vltotdes column-label "Desc." format ">>>>9"
          vpercmed column-label "%%%" format ">>9.99"
          "|"
          vltotven31 column-label "Moveis!Venda" format ">>>>>>9"
          vltotdes31 column-label "Desc." format ">>>>9"
          vpercmed31 column-label "%%%" format ">>9.99"
          "|"
          vltotven41 column-label "Moda!Venda" format ">>>>>>9"
          vltotdes41 column-label "Desc." format ">>>>9"
          vpercmed41 column-label "%%%" format ">>9.99"
        with frame f2 down centered no-box.
        down with frame f2.
        if vplanilha
        then do:    
            put stream csv unformatted
              estab.etbcod  format ">>9"        ";"
              vltotven      format ">>>>>>9.99"    ";"
              vltotdes      format ">>>>9.99"      ";"
              vpercmed      format ">>9.99"     ";"
              vltotven31    format ">>>>>>9.99"    ";"
              vltotdes31    format ">>>>9.99"      ";"
              vpercmed31    format ">>9.99"     ";"
              vltotven41    format ">>>>>>9.99"    ";"
              vltotdes41    format ">>>>9.99"      ";"
              vpercmed41    format ">>9.99"     ";"
                skip.
        end. 
        
        vltotven = 0. vltotven31 = 0. vltotven41 = 0. 
        vltotdes = 0. vltotdes31 = 0. vltotdes41 = 0.
        vpercmed = 0.
        
    end.
    

        /**vcodigoLoja = int(ttmargemdesconto.codigoLoja).
        
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
        **/
end.        


if vplanilha
then do:
    output stream csv close.
    message "ARQUIVO consulta_desconto.csv GERADO COM SUCESSO EM L:/relat".
    pause 3 no-message.
end.


    hide message no-pause.
    message "Informacoes do SAP". 
    pause.



end procedure.
