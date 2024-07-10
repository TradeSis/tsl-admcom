{admcab.i new}

message "Programa atual 18/09/2014 BASE REAL". pause 2.

def var p-principal as dec.
def var p-acrescimo as dec.
def var p-juros as dec.

def var vi as int.
def var vb as int.

def var p-sitlan as char.
def var p-tiplan as char.

def buffer btitulo for fin.titulo.

def temp-table tt-tabdac like tabdac.

def temp-table tt-rec-moe
    field etbcod like estab.etbcod
    field datref as date
    field moecod like fin.moeda.moecod
    field valor as dec
    index i1 etbcod moecod.

def buffer moeda for fin.moeda.

/*    
def temp-table tt-rng
    field etbcod like estab.etbcod
    field clifor like clien.clicod
    field titnum like fin.titulo.titnum
    field valor as dec
    field sit as char
    index i1 etbcod clifor titnum.
 
def temp-table tt-titestcan like fin.titulo.
*/

def  var vdti as date.
def  var vdtf as date.
update vdti vdtf.
def temp-table t-titulo like fin.titulo.
def buffer btitulosal for titulosal. 
def var vcfinacr as dec.
def var vcfinan as dec.
def var vrecrng as dec.
def var vjurorng as dec.

def var vcontratodd as dec.
def var vtp as char format "x(20)" extent 3
init["GERAL","EMISSAO","RECEBIMENTO"].
def var v-index as int.
disp vtp.
choose field vtp.
v-index = frame-index.

def var vnov as log.
def var vetb-pag like estab.etbcod.

DEF VAR VRENEG AS DEC.

def temp-table tt-recmoeda
    field etbcod like estab.etbcod
    field datref as date
    field moecod like fin.moeda.moecod
    field valor  as dec
    index i1 etbcod datref moecod.

def temp-table tt-contnov like fin.contrato.
def temp-table tt-contdat like fin.contrato.
    
/***
def temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field acr-prazo as dec     /*acrescimo prazo*/
        field acr-novac as dec     /*acrescimo novacao*/
        field acr-finan as dec     /*acrescimo emissao financeira*/
        field novac-prazo as dec   /*emissao novacao*/
        field venda-prazo as dec   /*emissao venda prazo*/
        field venda-contd as dec   /*emissao contratodd*/
        field cance-finan as dec   /*cancelamento financeira*/
        field venda-finan as dec   /*emissao financeira*/
        field venda-vista as dec   /*venda vista*/
        field venda-carta as dec   /*venda cartao*/
        field venda-recargap as dec /*venda recarga prazo*/
        field venda-recargav as dec /*venda recarga vista*/
        field venda-outras as dec
        field acr-outras as dec
        field receb-prazo as dec   /*recebimento prazo*/
        field receb-entra as dec   /*recebimento entrada*/
        field receb-novac as dec   /*recebimento novacao*/
        field receb-moeda as dec
        field receb-finan as dec   /*recebimento financeira*/
        field novac-finan as dec   /*novacao financeira*/
        field novac-acrfinan as dec /*novacao financeira acrescimo*/ 
        field estor-finan as dec   /*estorno financeira*/
        field receb-juros as dec   /*recebimento juros*/
        field receb-fosal as dec   /*recebimento fora do saldo 31/12/2012*/
        field dev-prazo as dec     /*devolucao prazo*/
        field dev-vista as dec     /*devolucao vista*/
        field dev-estorno  as dec     /*estornos de devolucao*/
        field sem-cupom as dec     /*VENDA SEM CUPOM*/
        field receb-incob as dec 
        index i1 etbcod data.
 
def  temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

def temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like fin.titulo.titvlcob label "Valor"
      field titvlpag  like fin.titulo.titvlpag
      field entrada   as dec
      index ix is primary unique
                  tipo
                  etbcod
                  data
                  .
******/

def temp-table tt-venda like realtbdic.

def var vest as dec.
def var vrec1 as dec.
def var vrec2 as dec.

def var vemissao as dec.
def var vrecebimento as dec.
def var vjuro as dec.
def var vtitvlcob as dec.

def var v-devol as dec.
def var v-estorno as dec.
def var vacrescimo as dec.
def var vemiacre as dec.
def temp-table tt-estab
    field etbcod like estab.etbcod
    .
for each estab.
create tt-estab.
tt-estab.etbcod = estab.etbcod .
end.
def var vdia as int.
def var  vmes as int.
def var vano as int.

def var varqexp as char.
def stream tl .
def var vdata1 as date. 
def var vhist as char.
def var varquivo as char.
def var vetbcod like estab.etbcod.
    if opsys = "unix"
        then varqexp = 
            "/arquivo-clientes/audit/titdc_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".txt".
        else varqexp = 
            "l:\audit\titdc_" + trim(string(vetbcod,"999")) + "_" + 
                string(day(vdti),"99") +   
                string(month(vdti),"99") +   
                string(year(vdti),"9999") + "_" +  
                string(day(vdtf),"99") +   
                string(month(vdtf),"99") +   
                string(year(vdtf),"9999") + ".txt".
      
def var vrecebe-ant as dec.

def var vclifor as char.

def temp-table tt-contrato 
    field dtinicial like fin.contrato.dtinicial
    field contnum like fin.contrato.contnum
    field vltotal like fin.contrato.vltotal
    field vlacres as dec
    .

def temp-table n-contrato like fin.contrato.
def temp-table n-titulo like fin.titulo.
def temp-table fc-contrato like fin.contrato.
def temp-table d-contrato like fin.contrato.
def temp-table e-contrato like fin.contrato.
def temp-table tit-vista like fin.titulo.
 
def var val-novacao as dec.
def var vtitnum like fin.titulo.titnum.
output to value(varqexp).
output stream tl to terminal.

def var v-principal as dec.
def var v-acrescimo as dec.
def var v-novacao as log format "Sim/Nao".
def var v-financiado as dec.
def var v-clientes as dec.

def new shared temp-table tit-novado like fin.titulo.

for each tt-tabdac: delete tt-tabdac. end.
update vdti vdtf.
for each tt-estab  no-lock:       
    if tt-estab.etbcod >= 900 and
       tt-estab.etbcod <> 993
    then vetb-pag = 996.
    else vetb-pag = tt-estab.etbcod.

    for each tt-contdat: delete tt-contdat. end.
        
    do vdata1 = vdti to vdtf:
        disp stream tl "Processando ... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
        pause 0.

        vdia = day(vdata1).
        vmes = month(vdata1).
        vano = year(vdata1).
            
        create tt-venda.
        tt-venda.etbcod = tt-estab.etbcod.
        tt-venda.datref = vdata1.

        for each n-contrato: delete n-contrato. end.
        for each n-titulo: delete n-titulo. end.    
        for each fc-contrato: delete fc-contrato. end.
        for each d-contrato: delete d-contrato. end.
        for each e-contrato: delete e-contrato. end.
        for each tit-novado: delete tit-novado. end.
        for each tit-vista: delete tit-vista. end.

        assign
            p-principal = 0
            p-acrescimo = 0
            p-juros = 0.
            
        /**** EMISSÕES ****/      

        if v-index = 1 or v-index = 2
        then do:
            for each fin.contrato where contrato.etbcod = tt-estab.etbcod and
                                    contrato.dtinicial = vdata1
                                    no-lock:
                if contrato.vltotal <= 0
                then next.

                find first envfinan where 
                           envfinan.empcod = 19
                       and envfinan.titnat = no
                       and envfinan.modcod = "CRE"
                       and envfinan.etbcod = contrato.etbcod
                       and envfinan.clifor = contrato.clicod
                       and envfinan.titnum = string(contrato.contnum)
                           no-lock no-error.

                assign
                    v-principal = 0
                    v-acrescimo = 0
                    v-novacao = no
                    v-financiado = 0
                    v-clientes = 0
                    vtitvlcob = 0
                    vacrescimo = 0
                    .
                
                run retorna-principal-acrescimo-contrato.p
                        (input recid(contrato), 
                         output v-novacao,
                         output v-financiado,
                         output v-clientes,
                         output v-principal, 
                         output v-acrescimo).


                if v-principal > 0 and not v-novacao
                then do:
                    assign
                        vtitvlcob = v-principal
                        vacrescimo = v-acrescimo .
                        
                    find first fin.contnf where 
                         contnf.etbcod = contrato.etbcod and
                         contnf.contnum = contrato.contnum
                         no-lock no-error.
                    if avail contnf
                    then do:
                        find first com.plani where 
                                plani.etbcod = contnf.etbcod and
                                plani.placod = contnf.placod and
                                plani.movtdc = 5 and
                                plani.pladat = contrato.dtinicial
                                no-lock no-error.
                        if avail plani and
                                substr(plani.notped,1,1) = "C" and
                                plani.ufemi <> ""
                        then do: 
                            /*
                            if avail envfinan and envfinan.envsit <> "EXC"
                            then assign
                                tt-venda.venda_prazo_fdrebes =
                                tt-venda.venda_prazo_fdrebes + v-principal
                                tt-venda.acrescimo_fdrebes =
                                tt-venda.acrescimo_fdrebes + v-acrescimo
                                .
                            else do:
                                assign
                                     vtitvlcob = v-principal
                                     vacrescimo = v-acrescimo
                                     .
                                run put-contrato.
                            end.
                            */
                    
                            if avail envfinan and envfinan.envsit <> "EXC"
                            then p-sitlan = "FINANCEIRA".
                            else p-sitlan = "LEBES".
                            run put-contrato.
                        end.
                        else do:
                            /***
                            assign
                                tt-venda.venda_prazo_semcupom = 
                                tt-venda.venda_prazo_semcupom + v-principal.
                                tt-venda.acrescimo_venda_semcupom =
                                tt-venda.acrescimo_venda_semcupom + v-acrescimo
                                .
                                ***/
                            p-sitlan = "SEMCUPOM".
                            run put-contrato.        
                        end.            
                    end.
                    else do:
                        /***
                        assign
                            tt-venda.venda_prazo_outras =
                                tt-venda.venda_prazo_outras + v-principal
                            tt-venda.acrescimo_venda_outras =
                                tt-venda.acrescimo_venda_outras + v-acrescimo
                            . 
                        ***/
                        p-sitlan = "OUTROS".
                        run put-contrato.
                        
                    end.               
                end.
                else if v-principal > 0
                then do:
                    
                    if v-financiado > 0
                    then  assign
                                tt-venda.novacao_fdrebes =
                                tt-venda.novacao_fdrebes + v-financiado
                                tt-venda.acrescimo_novacao_fdrebes =
                                tt-venda.acrescimo_novacao_fdrebes + 
                                    (v-acrescimo * (v-financiado / v-principal))
                                    .
                    if v-clientes > 0
                    then assign
                            tt-venda.novacao_lebes =
                            tt-venda.novacao_lebes + v-clientes
                            tt-venda.acrescimo_novacao_lebes =
                            tt-venda.acrescimo_novacao_lebes +
                            (v-acrescimo * (v-clientes / v-principal))
                            .
            
                    create n-contrato.
                    buffer-copy fin.contrato to n-contrato.
                    n-contrato.vlfrete = v-principal.
                
                
                
                end.
                else do:
                    /*
                    tt-venda.venda_prazo_outras =
                                tt-venda.venda_prazo_outras + contrato.vltotal
                            .  
                    */

                    assign
                        vtitvlcob  = contrato.vltotal
                        vacrescimo = 0
                        p-sitlan = "OUTROS"
                        .
                    run put-contrato.    
 
                end.
            end.
                
            /*** Novacao ***/           
            for each n-contrato no-lock.
                vtitvlcob = n-contrato.vlfrete.
                vacrescimo = n-contrato.vltotal - n-contrato.vlfrete.
                
                p-sitlan = "LEBES".
                run put-contratonov.
                
            end.           
        
            /*** Cancelamento financeira ****/
            
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
                if not avail fc-contrato
                then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
                end.
                fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
            end.

            /*** Estorno financeira ****/
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                find first fc-contrato where
                          fc-contrato.contnum = int(envfinan.titnum)
                          no-error.
                if not avail fc-contrato
                then do:
                    create fc-contrato.
                    assign
                        fc-contrato.contnum   = int(envfinan.titnum)
                        fc-contrato.etbcod    = envfinan.etbcod 
                        fc-contrato.clicod    = envfinan.clifor 
                        fc-contrato.dtinicial = envfinan.dt1 
                        .
                end.
                fc-contrato.vltotal = 
                    fc-contrato.vltotal + titulo.titvlcob.
                
            end.
            for each fc-contrato no-lock:
     
                find fin.contrato where contrato.contnum =
                            fc-contrato.contnum no-lock no-error.
                if not avail contrato then next.            
                
                assign
                    v-principal = 0
                    v-acrescimo = 0
                    v-novacao = no
                    v-financiado = 0
                    v-clientes = 0
                    vtitvlcob = 0
                    vacrescimo = 0
                    .
                
                run retorna-principal-acrescimo-contrato.p
                        (input recid(contrato), 
                         output v-novacao,
                         output v-financiado,
                         output v-clientes,
                         output v-principal, 
                         output v-acrescimo).
                
                vtitvlcob  = v-principal.
                vacrescimo = v-acrescimo.
                
                p-sitlan = "LEBES".
                run put-fccontrato.
                
            end.
        end.

        /***** RECEBIMENTO ****/
        if v-index = 1 or v-index = 3

        then do:
            for each titulo where 
                     titulo.etbcobra = tt-estab.etbcod and
                     titulo.titdtpag = vdata1 and
                     titulo.modcod = "CRE" no-lock:
                     
                if titulo.titvlcob <= 0 then next.
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                
                find first tit-novado of titulo no-error.
                if avail tit-novado
                then next.
                
                p-juros = 0.
                p-principal = 0.
                p-acrescimo = 0.
                
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    /*and envfinan.titpar = titulo.titpar
                                    */
                                    no-lock no-error.

                if titulo.titpar = 0 and
                   avail envfinan and envfinan.envsit <> "EXC"
                then do:
                    tt-venda.recebimento_entrada = 
                        tt-venda.recebimento_entrada + titulo.titvlcob.
                    if titulo.moecod = "PDM"
                    then 
                    for each titpag where
                          titpag.empcod = titulo.empcod and
                          titpag.titnat = titulo.titnat and
                          titpag.modcod = titulo.modcod and
                          titpag.etbcod = titulo.etbcod and
                          titpag.clifor = titulo.clifor and
                          titpag.titnum = titulo.titnum and
                          titpag.titpar = titulo.titpar
                          no-lock:
                        find first fin.moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                        if not avail moeda
                        then find first fin.moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                        vi = 0.
                        do vi = 1 to 15:
                            if tt-venda.define_recebimento_entrada_moeda[vi] 
                                            = ""
                            then tt-venda.define_recebimento_entrada_moeda[vi]
                                    =  moeda.moecod + " - " + moeda.moenom.
                            if tt-venda.define_recebimento_entrada_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                            then do:
                                tt-venda.recebimento_entrada_moeda[vi] =
                                 tt-venda.recebimento_entrada_moeda[vi] + 
                                 titpag.titvlpag.
                                leave.
                            end.    
                        end.         
                    end.               
                    else do:
                         find first fin.moeda where 
                               moeda.moecod = titulo.moecod
                               no-lock no-error.
                         if not avail moeda
                         then find first fin.moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                         vi = 0.
                         do vi = 1 to 15:
                            if tt-venda.define_recebimento_entrada_moeda[vi]
                                                   = ""
                            then tt-venda.define_recebimento_entrada_moeda[vi]
                                =  moeda.moecod + " - " + moeda.moenom.
                            if tt-venda.define_recebimento_entrada_moeda[vi] 
                                =  moeda.moecod + " - " + moeda.moenom
                            then do:
                                tt-venda.recebimento_entrada_moeda[vi] =
                                 tt-venda.recebimento_entrada_moeda[vi] 
                                        + titulo.titvlcob.
                                leave.
                            end.    
                        end.         
                    end.   
                    next.
                end.
                
                if  avail envfinan and envfinan.envsit <> "EXC"
                then do:
                    
                    p-principal = 0.
                    p-acrescimo = 0.
                    p-juros = titulo.titjuro.
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo).

                    if p-principal + p-acrescimo <> titulo.titvlcob
                    then do:
                        if p-principal + p-acrescimo > titulo.titvlcob
                        then p-acrescimo = p-acrescimo -
                            ((p-principal + p-acrescimo) - titulo.titvlcob).
                        else if p-principal + p-acrescimo < titulo.titvlcob
                            then p-principal = p-principal +
                                (titulo.titvlcob - (p-principal + p-acrescimo)).

                    end.    
                    if p-principal <= 0 
                    then assign
                        p-principal = titulo.titvlcob
                         p-acrescimo = 0.
                    
                    p-tiplan = "RECEBIMENTO".
                    p-sitlan = "FINANCEIRA".
                    run put-recebimento.
 
                end.
                else  do:
                    
                        p-principal = 0.
                        p-acrescimo = 0.
                        p-juros = fin.titulo.titjuro.
                        run retorna-principal-acrescimo-titulo.p
                                        (input recid(fin.titulo),
                                            output p-principal, 
                                            output p-acrescimo).
 
                        if p-principal + p-acrescimo <> fin.titulo.titvlcob
                        then do:
                            if p-principal + p-acrescimo > fin.titulo.titvlcob
                            then p-acrescimo = p-acrescimo - 
                                ((p-principal + p-acrescimo) - 
                                    fin.titulo.titvlcob).
                            else if p-principal + p-acrescimo < 
                                                fin.titulo.titvlcob
                                then p-principal = p-principal +
                                    (fin.titulo.titvlcob - 
                                    (p-principal + p-acrescimo)).

                        end.
                        if p-principal <= 0
                        then assign
                            p-principal = fin.titulo.titvlcob
                            p-acrescimo = 0.
                             
                        p-tiplan = "RECEBIMENTO".
                        p-sitlan = "LEBES".
                        run put-recebimento.
                end.
                
            end.
            
            /*** recebimento NOVACA) ****/
            for each tit-novado where 
                     tit-novado.etbcod > 0  no-lock:

                p-principal = 0.
                p-acrescimo = 0.
                p-juros = 0.
                find titulo of tit-novado no-lock no-error.
                if avail titulo
                then do:
                    run retorna-principal-acrescimo-titulo.p
                                        (input recid(fin.titulo),
                                            output p-principal, 
                                            output p-acrescimo).
                    if p-principal + p-acrescimo <> titulo.titvlcob
                    then do:
                        if p-principal + p-acrescimo > titulo.titvlcob
                        then p-acrescimo = p-acrescimo -
                            ((p-principal + p-acrescimo) - titulo.titvlcob).
                        else if p-principal + p-acrescimo < titulo.titvlcob
                            then p-principal = p-principal + 
                                (titulo.titvlcob - (p-principal + p-acrescimo)).

                    end. 
                end.
                if p-principal <= 0
                then assign
                    p-principal = titulo.titvlcob
                    p-acrescimo = 0.
                    
                p-tiplan = "RECNOVACAO".
                p-sitlan = "LEBES".
                run put-recebimento-novacao.
            end.                                                        
            
            for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                find first titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                           
                p-principal = 0.
                p-acrescimo = 0.
                run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo).
                
                if p-principal + p-acrescimo <> titulo.titvlcob
                then do:
                    if p-principal + p-acrescimo > titulo.titvlcob
                    then p-acrescimo = p-acrescimo -
                        ((p-principal + p-acrescimo) - titulo.titvlcob).
                    else if p-principal + p-acrescimo < titulo.titvlcob
                        then p-principal = p-principal + 
                            (titulo.titvlcob - (p-principal + p-acrescimo)).

                end. 
                if p-principal <= 0
                then assign
                    p-principal = titulo.titvlcob
                    p-acrescimo = 0.
                    
                run put-fetitulo.
                
            end.
            
        end.            

        run devolucao.

        for each d-contrato no-lock:
            run put-devolucao.
        end.    

        run vendavista.
        
        for each tit-vista no-lock:
            run put-vendavista.
        end.
    end.
end.            

output close.

output stream tl close.

def temp-table tt-total like tt-venda.
def var ok-venda as log.
def var ok-recebimento as log.
def var ok-recentrada as log.
def var ok-recarga as log.

create tt-total.

for each tt-venda:
    assign
        tt-total.venda_vista = tt-total.venda_vista +
                               tt-venda.venda_vista
        tt-total.venda_cpresente  = tt-total.venda_cpresente +
                                    tt-venda.venda_cpresente 
        tt-total.venda_prazo_lebes = tt-total.venda_prazo_lebes + 
                                     tt-venda.venda_prazo_lebes
        tt-total.venda_prazo_fdrebes = tt-total.venda_prazo_fdrebes +
                                       tt-venda.venda_prazo_fdrebes
        tt-total.acrescimo_lebes = tt-total.acrescimo_lebes +
                                   tt-venda.acrescimo_lebes
        tt-total.acrescimo_fdrebes = tt-total.acrescimo_fdrebes +
                                    tt-venda.acrescimo_fdrebes
        tt-total.valor_novacao = tt-total.valor_novacao +
                                 tt-venda.valor_novacao
        tt-total.novacao_lebes = tt-total.novacao_lebes + 
                                 tt-venda.novacao_lebes
        tt-total.novacao_fdrebes = tt-total.novacao_fdrebes +
                                   tt-venda.novacao_fdrebes
        tt-total.acrescimo_novacao = tt-total.acrescimo_novacao +
                                        tt-venda.acrescimo_novacao
        tt-total.acrescimo_novacao_lebes = tt-total.acrescimo_novacao_lebes +
                                           tt-venda.acrescimo_novacao_lebes
        tt-total.acrescimo_novacao_fdrebes = tt-total.acrescimo_novacao_fdrebes
                                    + tt-venda.acrescimo_novacao_fdrebes
        tt-total.devolucao_vista = tt-total.devolucao_vista + 
                                   tt-venda.devolucao_vista
        tt-total.devolucao_prazo = tt-total.devolucao_prazo + 
                                   tt-venda.devolucao_prazo
        tt-total.estorno_devolucao = tt-total.estorno_devolucao +
                                     tt-venda.estorno_devolucao
        tt-total.recebimento_lebes = tt-total.recebimento_lebes +
                                     tt-venda.recebimento_lebes
        tt-total.recebimento_principal_lebes =
            tt-total.recebimento_principal_lebes +
            tt-venda.recebimento_principal_lebes
        tt-total.recebimento_acrescimo_lebes =
            tt-total.recebimento_acrescimo_lebes +
            tt-venda.recebimento_acrescimo_lebes
         tt-total.recebimento_fdrebes = tt-total.recebimento_fdrebes +
                                     tt-venda.recebimento_fdrebes
         tt-total.recebimento_principal_fdrebes =
            tt-total.recebimento_principal_fdrebes +
            tt-venda.recebimento_principal_fdrebes
        tt-total.recebimento_acrescimo_fdrebes =
            tt-total.recebimento_acrescimo_fdrebes +
            tt-venda.recebimento_acrescimo_fdrebes
        tt-total.recebimento_entrada = tt-total.recebimento_entrada +
                                       tt-venda.recebimento_entrada
        tt-total.recebimento_novacao = tt-total.recebimento_novacao +
                                       tt-venda.recebimento_novacao
        tt-total.recebimento_principal_novacao = 
                tt-total.recebimento_principal_novacao +
                              tt-venda.recebimento_principal_novacao
        tt-total.recebimento_acrescimo_novacao = 
                tt-total.recebimento_acrescimo_novacao +
                             tt-venda.recebimento_acrescimo_novacao
        tt-total.juros_lebes = tt-total.juros_lebes +
                               tt-venda.juros_lebes        
        tt-total.juros_fdrebes = tt-total.juros_fdrebes +
                                 tt-venda.juros_fdrebes
        tt-total.recebimento_incobraveis = tt-total.recebimento_incobraveis +
                                           tt-venda.recebimento_incobraveis 
        tt-total.recebimento_forasaldo = tt-total.recebimento_forasaldo +
                                         tt-venda.recebimento_forasaldo  
        tt-total.cancelamentos_fdrebes = tt-total.cancelamentos_fdrebes +
                                         tt-venda.cancelamentos_fdrebes
        tt-total.acrescimo_cancelamento_fdrebes = 
                tt-total.acrescimo_cancelamento_fdrebes + 
                tt-venda.acrescimo_cancelamento_fdrebes
        tt-total.estorno_cancelamento_fdrebes =
                tt-total.estorno_cancelamento_fdrebes +
                tt-venda.estorno_cancelamento_fdrebes
        tt-total.venda_prazo_adicional = tt-total.venda_prazo_adicional + 
                                         tt-venda.venda_prazo_adicional
        tt-total.venda_prazo_semcupom  = tt-total.venda_prazo_semcupom +
                                         tt-venda.venda_prazo_semcupom
        tt-total.acrescimo_venda_semcupom = 
                                tt-total.acrescimo_venda_semcupom +
                                        tt-venda.acrescimo_venda_semcupom
        tt-total.venda_prazo_outras = tt-total.venda_prazo_outras +
                                      tt-venda.venda_prazo_outras
        tt-total.acrescimo_venda_outras = tt-total.acrescimo_venda_outras +
                                    tt-venda.acrescimo_venda_outras
        .
    vi = 0.
    do vi = 1 to 15:
        ok-venda = no.
        do vb = 1 to 15:
            if tt-total.define_venda_moeda[vb] = ""
            then  tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi].
            if tt-total.define_venda_moeda[vb] =
                    tt-venda.define_venda_moeda[vi]
            then do:
                ok-venda = yes.
                leave.
            end.
        end.    
        if ok-venda = yes
        then tt-total.venda_moeda[vb] = tt-total.venda_moeda[vb] +
                                  tt-venda.venda_moeda[vi].
        ok-recarga = no.
        do vb = 1 to 15:
            if tt-total.define_venda_recarga[vb] = ""
            then tt-total.define_venda_recarga[vb] =
                tt-venda.define_venda_recarga[vi].
            if tt-total.define_venda_recarga[vb] =
                    tt-total.define_venda_recarga[vi]
            then do:
                ok-recarga = yes.
                leave.
            end.
        end.    
        if ok-recarga = yes
        then tt-total.venda_recarga[vb] = tt-total.venda_recarga[vb] +
                                    tt-venda.venda_recarga[vi].
        ok-recebimento = no.
        do vb = 1 to 15:
            if tt-total.define_recebimento_moeda[vb] = ""
            then tt-total.define_recebimento_moeda[vb] =
                    tt-venda.define_recebimento_moeda[vi].
            if tt-total.define_recebimento_moeda[vb] =
                    tt-total.define_recebimento_moeda[vi]
            then do:
                ok-recebimento = yes.
                leave.
            end.
        end.    
        if ok-recebimento = yes
        then assign
             tt-total.recebimento_moeda_lebes[vb] =         
                    tt-total.recebimento_moeda_lebes[vb] +
                    tt-venda.recebimento_moeda_lebes[vi]
             tt-total.receb_moeda_principal_lebes[vb] =         
                    tt-total.receb_moeda_principal_lebes[vb] +
                    tt-venda.receb_moeda_principal_lebes[vi]
             tt-total.receb_moeda_acrescimo_lebes[vb] =         
                    tt-total.receb_moeda_acrescimo_lebes[vb] +
                    tt-venda.receb_moeda_acrescimo_lebes[vi]
             tt-total.receb_moeda_juros_lebes[vb] =         
                    tt-total.receb_moeda_juros_lebes[vb] +
                    tt-venda.receb_moeda_juros_lebes[vi]
             tt-total.recebimento_moeda_fdrebes[vb] =         
                    tt-total.recebimento_moeda_fdrebes[vb] +
                    tt-venda.recebimento_moeda_fdrebes[vi]
             tt-total.receb_moeda_principal_fdrebes[vb] =         
                    tt-total.receb_moeda_principal_fdrebes[vb] +
                    tt-venda.receb_moeda_principal_fdrebes[vi]
             tt-total.receb_moeda_acrescimo_fdrebes[vb] =         
                    tt-total.receb_moeda_acrescimo_fdrebes[vb] +
                    tt-venda.receb_moeda_acrescimo_fdrebes[vi]
             tt-total.receb_moeda_juros_fdrebes[vb] =         
                    tt-total.receb_moeda_juros_fdrebes[vb] +
                    tt-venda.receb_moeda_juros_fdrebes[vi]
                     .
        ok-recentrada = no.
        do vb = 1 to 15:
            if tt-total.define_recebimento_entrada_moeda[vb] = ""
            then tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-venda.define_recebimento_entrada_moeda[vi].
            if tt-total.define_recebimento_entrada_moeda[vb] =
                    tt-total.define_recebimento_entrada_moeda[vi]
            then do:
                ok-recentrada = yes.
                leave.
            end.
        end.    
        if ok-recentrada = yes
        then tt-total.recebimento_entrada_moeda[vb] =         
                    tt-total.recebimento_entrada_moeda[vb] +
                    tt-venda.recebimento_entrada_moeda[vi]
                    .
        
    end.
end.
def var vjuro-lebes as dec.
def var vjuro-fdrebes as dec.
/*
    do vi = 1 to 15:
        if tt-total.recebimento_moeda_lebes[vi] <>
                 tt-total.receb_moeda_principal_lebes[vi] +
                 tt-total.receb_moeda_acrescimo_lebes[vi]
        then tt-total.receb_moeda_acrescimo_lebes[vi] -
                 (tt-total.recebimento_moeda_lebes[vi] -
                 (tt-total.receb_moeda_principal_lebes[vi] +
                  tt-total.receb_moeda_acrescimo_lebes[vi])).
        if tt-total.recebimento_moeda_fdrebes[vi] <>
                 tt-total.receb_moeda_principal_fdrebes[vi] +
                 tt-total.receb_moeda_acrescimo_fdrebes[vi]
        then tt-total.receb_moeda_acrescimo_fdrebes[vi] -
                 (tt-total.recebimento_moeda_fdrebes[vi] -
                 (tt-total.receb_moeda_principal_fdrebes[vi] +
                  tt-total.receb_moeda_acrescimo_fdrebes[vi])).
          
        vjuro-lebes = vjuro-lebes + tt-total.receb_moeda_juros_lebes[vi].
        vjuro-fdrebes = vjuro-fdrebes + 
                    tt-total.receb_moeda_juros_fdrebes[vi].          

    end.
    
    if tt-total.juros_lebes <> vjuro-lebes
    then do vi = 1 to 15:
        if tt-total.receb_moeda_juros_lebes[vi] >
            tt-total.juros_lebes - vjuro-lebes
        then tt-total.receb_moeda_juros_lebes[vi] -
                (tt-total.juros_lebes - vjuro-lebes)
                .
    end.
    
    if tt-total.juros_lebes <> vjuro-lebes
    then do vi = 1 to 15:
        if tt-total.receb_moeda_juros_fdrebes[vi] >
            tt-total.juros_fdrebes - vjuro-fdrebes
        then tt-total.receb_moeda_juros_fdrebes[vi] -
                (tt-total.juros_fdrebes - vjuro-fdrebes)
                .
    end.
***/
def var ct-resp as log format "Sim/Nao".

varquivo = "/arquivo-clientes/totais-base-real_" + 
                trim(string(vetbcod,"999")) + "_" +
                string(day(vdti),"99") +  
                string(month(vdti),"99") +  
                string(year(vdti),"9999") + "_" + 
                string(day(vdtf),"99") +  
                string(month(vdtf),"99") +  
                string(year(vdtf),"9999") + ".csv".
 
def var v_vista as dec.
def var v_recarga as dec.

output to value(varquivo).


v_vista = 0.
v_recarga = 0.
vi = 0.
do vi = 1 to 15:
        v_vista = v_vista + tt-total.venda_moeda[vi].
        v_recarga = v_recarga + tt-total.venda_recarga[1].
end.    

put  "Venda a VISTA             ;"
    replace(string(tt-total.venda_vista),".",",")
    format "x(15)"
    skip.
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_moeda[vi] <> ""
    then  do:
        put "         " 
            tt-total.define_venda_moeda[vi] " ; "
            replace(string(tt-total.venda_moeda[vi]), ".",",")
                     format "x(15)" skip.
    end.
end. 
vi = 0.
do vi = 1 to 15:
    if tt-total.define_venda_recarga[vi] <> ""
    then  do:
        put "         " tt-total.define_venda_recarga[vi] " ; "
            replace(string(tt-total.venda_recarga[vi]),".",",") 
                format "x(15)" skip.
    end.
end.  
    
put  skip "Venda a PRAZO             ;"
     replace(string(tt-total.venda_prazo_lebes + tt-total.venda_prazo_fdrebes +
     tt-total.venda_prazo_adicional + tt-total.venda_prazo_semcupom +
     tt-total.venda_prazo_outras),".",",")  format "x(15)"
     skip "         Venda prazo LEBES             ;"  
     replace(string(tt-total.venda_prazo_lebes),".",",")  format "x(15)"
     skip "         Venda parzo FINANCEIRA        ;"
     replace(string(tt-total.venda_prazo_fdrebes),".",",")  format "x(15)"
     skip "         Venda prazo ADICIONAL         ;"
     replace(string(tt-total.venda_prazo_adicional),".",",")  format "x(15)"
     skip "         Venda prazo SEM CUPOM         ;"
     replace(string(tt-total.venda_prazo_semcupom),".",",")  format "x(15)"
     skip "         Vneda prazo OUTRAS            ;"
     replace(string(tt-total.venda_prazo_outras),".",",")  format "x(15)"
     skip "ACRESCIMO venda prazo  ;"
     replace(string(tt-total.acrescimo_lebes + tt-total.acrescimo_fdrebes)
                        ,".",",")  format "x(15)"
     skip "         Acrescimo LEBES             ;"
     replace(string(tt-total.acrescimo_lebes),".",",")  format "x(15)"
     skip "         Acrescimo FINANCEIRA        ;"
     replace(string(tt-total.acrescimo_fdrebes),".",",")  format "x(15)"
     skip "RECEBIMENTOS               ;"
     replace(string(tt-total.recebimento_lebes + tt-total.recebimento_fdrebes +
     tt-total.recebimento_entrada + tt-total.recebimento_novacao),".",",")
       format "x(15)"
     skip "         Recebimentos LEBES             ;"
     replace(string(tt-total.recebimento_lebes),".",",")  format "x(15)"
     skip.
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_recebimento_moeda[vi] <> ""
    then  do:
        put "              " tt-total.define_recebimento_moeda[vi] " ; "
            replace(string(tt-total.recebimento_moeda_lebes[vi])
             ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_principal_lebes[vi] > 0
        then put "                   PRINCIPAL ; "
            replace(string(tt-total.receb_moeda_principal_lebes[vi])
            ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_juros_lebes[vi] > 0
        then put "                   JUROS ; "
            replace(string(tt-total.receb_moeda_juros_lebes[vi])
            ,".",",") format "x(15)" skip.
        if tt-total.receb_moeda_acrescimo_lebes[vi] > 0
        then put "                   ACRESCIMO ; "
            replace(string(tt-total.receb_moeda_acrescimo_lebes[vi])
            ,".",",") format "x(15)" skip.
            
    end.
end.    

put "         Recebimento NOVACAO ;"
        replace(string(tt-total.recebimento_novacao),".",",") format "x(15)".
     
put  skip "         Recebimentos FINANCEIRA        ;"
     replace(string(tt-total.recebimento_fdrebes),".",",") format "x(15)"
     skip "         Recebimentos ENTRADA           ;"
     replace(string(tt-total.recebimento_entrada),".",",") format "x(15)"
     skip.
vi = 0.     
do vi = 1 to 15:
    if tt-total.define_recebimento_entrada_moeda[vi] <> ""
    then  do:
        put "              " tt-total.define_recebimento_entrada_moeda[vi] " ; "
            replace(string(tt-total.recebimento_entrada_moeda[vi])
                    ,".",",") format "x(15)" skip.
    end.
end. 

put  skip "JUROS recebimento   ;"
     replace(string(tt-total.juros_lebes + tt-total.juros_fdrebes)
                ,".",",") format "x(15)"
     skip "         Juros LEBES             ;"
     replace(string(tt-total.juros_lebes),".",",") format "x(15)"
     skip "         Juros FINANCEIRA        ;"
     replace(string(tt-total.juros_fdrebes),".",",") format "x(15)"
     skip "DEVOLUCAO venda             ;"
     replace(string(tt-total.devolucao_vista + tt-total.devolucao_prazo)
                    ,".",",") format "x(15)"
     skip "         Devolucao a VISTA           ;"
     replace(string(tt-total.devolucao_vista),".",",") format "x(15)"
     skip "         Devolucao a PRAZO           ;"
     replace(string(tt-total.devolucao_prazo),".",",") format "x(15)"
     skip "Estorno por DEVOLUCAO     ;"
     replace(string(tt-total.estorno_devolucao),".",",") format "x(15)"
     skip "NOVACAO de divida        ;"
     /*replace(string(tt-total.novacao_lebes + tt-total.novacao_fdrebes)*/
     replace(string(tt-total.valor_novacao)
                    ,".",",") format "x(15)"
     skip "         Novacao LEBES             ;"
     replace(string(tt-total.novacao_lebes),".",",") format "x(15)"
     skip "         Novacao FINANCEIRA        ;"
     replace(string(tt-total.novacao_fdrebes),".",",") format "x(15)"
     skip "Acrescimo NOVACAO         ;"
     replace(string(tt-total.acrescimo_novacao),".",",") format "x(15)"
     /*
     replace(string(tt-total.acrescimo_novacao_lebes +
            tt-total.acrescimo_novacao_fdrebes),".",",") format "x(15)"
     */   
     skip "         Acrecimo novacao LEBES ;"
     replace(string(tt-total.acrescimo_novacao_lebes),".",",") format "x(15)"
     skip "         Acrescimo novacao FINANCEIRA  ;"
     replace(string(tt-total.acrescimo_novacao_fdrebes),".",",") format "x(15)"
     skip "Cancelamentos FINANCEIRA  ;"
     replace(string(tt-total.cancelamentos_fdrebes),".",",") format "x(15)"
     skip "Cancelamento ACRESCIMO ;"
     replace(string(tt-total.acrescimo_cancelamento_fdrebes),".",",")
                format "x(15)"
     skip "Estorno por CANCELAMENTO  ;"
     replace(string(tt-total.estorno_cancelamento_fdrebes),".",",")
            format "x(15)"
     .

output close.

message color red/with
        "Arquivo de totais gerado em:" skip
        varquivo
        view-as alert-box.
        
run visurel.p(varquivo, "").

message "Confirma atualizar os dados anteriores pelos atuais"
    update ct-resp.
if ct-resp
then do:    
    /*****
    for each estab no-lock:
        for each tabdac where
             tabdac.etblan = estab.etbcod and
             tabdac.datlan >= vdti and
             tabdac.datlan <= vdtf
             :
    
            delete tabdac.
        end.
    end.         
    
    
    for each tt-tabdac no-lock:
        find tabdac where
         tabdac.etbcod = tt-tabdac.etbcod and
         tabdac.clicod = tt-tabdac.clicod and
         tabdac.numlan = tt-tabdac.numlan and
         tabdac.parlan = tt-tabdac.parlan and
         tabdac.datemi = tt-tabdac.datemi and
         tabdac.tiplan = tt-tabdac.tiplan and
         tabdac.sitlan = tt-tabdac.sitlan
         no-error.
        
        if not avail tabdac
        then create tabdac.
        buffer-copy tt-tabdac to tabdac.
        /*
        if avail tabdac
        then assign
                tabdac.principal = tt-tabdac.principal
                tabdac.acrescimo = tt-tabdac.acrescimo
                .
        */
    end.
    ****************/
    
    for each realtbdic where realtbdic.datref >= vdti and
                          realtbdic.datref <= vdtf:
        delete realtbdic.
    end.
    for each tt-venda no-lock:
        /*
        find first tabdic where
                   tabdic.etbcod = tt-venda.etbcod and
                   tabdic.datref = tt-venda.datref
                   no-error.
        if avail tabdic
        then assign
                tabdic.recebimento_principal_lebes =
                    tt-venda.recebimento_principal_lebes
                tabdic.recebimento_acrescimo_lebes =
                    tt-venda.recebimento_acrescimo_lebes
                tabdic.recebimento_principal_fdrebes =
                    tt-venda.recebimento_principal_fdrebes
                tabdic.recebimento_acrescimo_fdrebes =
                    tt-venda.recebimento_acrescimo_fdrebes
                tabdic.recebimento_principal_novacao =
                    tt-venda.recebimento_principal_novacao
                tabdic.recebimento_acrescimo_novacao =
                    tt-venda.recebimento_acrescimo_novacao
                tabdic.receb_moeda_principal_lebes =
                    tt-venda.receb_moeda_principal_lebes
                tabdic.receb_moeda_acrescimo_lebes =
                    tt-venda.receb_moeda_acrescimo_lebes
                tabdic.receb_moeda_juros_lebes =
                    tt-venda.receb_moeda_juros_lebes
                tabdic.receb_moeda_principal_fdrebes =
                    tt-venda.receb_moeda_principal_fdrebes
                tabdic.receb_moeda_acrescimo_fdrebes =
                    tt-venda.receb_moeda_acrescimo_fdrebes
                tabdic.receb_moeda_juros_fdrebes =
                    tt-venda.receb_moeda_juros_fdrebes
                    .
     
        */
    
        create realtbdic.
        buffer-copy tt-venda to realtbdic.

    end.    
end.

procedure put-vendavista:
end procedure.

procedure put-contrato:

     if p-sitlan = "LEBES"
     then tt-venda.venda_prazo_lebes = 
            tt-venda.venda_prazo_lebes + vtitvlcob.
     else if p-sitlan = "FINANCEIRA"
         then tt-venda.venda_prazo_fdrebes =
                     tt-venda.venda_prazo_fdrebes + vtitvlcob.
         else if p-sitlan = "SEMCUPOM"
            then tt-venda.venda_prazo_semcupom = 
                                tt-venda.venda_prazo_semcupom + vtitvlcob.
            else tt-venda.venda_prazo_outras =
                                tt-venda.venda_prazo_outras + vtitvlcob .

     if vacrescimo > 0
     then do:           
                
        if p-sitlan = "LEBES"
        then tt-venda.acrescimo_lebes = tt-venda.acrescimo_lebes + vacrescimo.
        else if  p-sitlan = "FINANCEIRA"
            then tt-venda.acrescimo_fdrebes =
                                tt-venda.acrescimo_fdrebes + vacrescimo .
            else if p-sitlan = "SEMCUPOM"
                then  tt-venda.acrescimo_venda_semcupom =
                                tt-venda.acrescimo_venda_semcupom + vacrescimo.
                else  tt-venda.acrescimo_venda_outras =
                                tt-venda.acrescimo_venda_outras + vacrescimo.
                                                                    

     end.
end procedure.

procedure put-fccontrato:

     tt-venda.cancelamentos_fdrebes = 
            tt-venda.cancelamentos_fdrebes + vtitvlcob.
     
     if vacrescimo > 0
     then do:           

        tt-venda.acrescimo_cancelamento_fdrebes = 
                tt-venda.acrescimo_cancelamento_fdrebes + vacrescimo.
     end.
     
end procedure.

procedure put-recebimento:

    def var vtitvlpag as dec.
    vtitvlpag = 0.
     if p-tiplan = "RECNOVACAO"
     then assign
            tt-venda.recebimento_novacao = 
                tt-venda.recebimento_novacao + fin.titulo.titvlcob
            tt-venda.recebimento_principal_novacao =
                tt-venda.recebimento_principal_novacao + p-principal
            tt-venda.recebimento_acrescimo_novacao =
                tt-venda.recebimento_acrescimo_novacao + p-acrescimo
                .
     else if p-sitlan = "LEBES"
         then assign
                tt-venda.recebimento_lebes = 
                tt-venda.recebimento_lebes + titulo.titvlcob
                tt-venda.recebimento_principal_lebes =
                tt-venda.recebimento_principal_lebes + p-principal
                tt-venda.recebimento_acrescimo_lebes =
                tt-venda.recebimento_acrescimo_lebes + p-acrescimo
                .
         else if p-sitlan = "FINANCEIRA"
         then assign
                tt-venda.recebimento_fdrebes =
                        tt-venda.recebimento_fdrebes + titulo.titvlcob
                tt-venda.recebimento_principal_fdrebes =
                tt-venda.recebimento_principal_fdrebes + p-principal
                tt-venda.recebimento_acrescimo_fdrebes =
                tt-venda.recebimento_acrescimo_fdrebes + p-acrescimo

                .
         
    

    if p-tiplan = "RECNOVACAO"
    then do:
        /*
        vi = 0.        
        do vi = 1 to 15:
            if tt-venda.define_recebimento_moeda[vi] = ""
            then tt-venda.define_recebimento_moeda[vi] = "NOV - NOVACAO".
            if tt-venda.define_recebimento_moeda[vi] = "NOV - NOVACAO"
            then do:
                tt-venda.recebimento_moeda_lebes[vi] =
                   tt-venda.recebimento_moeda_lebes[vi] + titulo.titvlcob.
                leave.
            end.
        end.
        */
        /*
        tt-venda.recebimento_lebes =
                         tt-venda.recebimento_lebes + titulo.titvlcob.
        */                 
    end.
    else do:
        if titulo.moecod = "PDM"
        then do:
            for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                 

                 find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                 if not avail moeda
                 then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                 vi = 0.
                 do vi = 1 to 15:
                    if tt-venda.define_recebimento_moeda[vi] = ""
                    then tt-venda.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                    if tt-venda.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                    then do:
                        if p-sitlan = "LEBES"
                        then 
                        assign
                            vtitvlpag = titpag.titvlpag - (titulo.titvljur *
                                (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.recebimento_moeda_lebes[vi] =
                                tt-venda.recebimento_moeda_lebes[vi] +
                                 vtitvlpag
                            tt-venda.receb_moeda_principal_lebes[vi] =
                            tt-venda.receb_moeda_principal_lebes[vi] +
                            (p-principal * (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.receb_moeda_acrescimo_lebes[vi] = 
                            tt-venda.receb_moeda_acrescimo_lebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.receb_moeda_juros_lebes[vi] = 
                            tt-venda.receb_moeda_juros_lebes[vi] +
                        (titulo.titjuro * (titpag.titvlpag / titulo.titvlpag))
                            .
                        else if p-sitlan = "FINANCEIRA"
                            then 
                            assign
                            vtitvlpag = titpag.titvlpag - (titulo.titvljur *
                                (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.recebimento_moeda_fdrebes[vi] = 
                             tt-venda.recebimento_moeda_fdrebes[vi] +
                              vtitvlpag
                            tt-venda.receb_moeda_principal_fdrebes[vi] =
                            tt-venda.receb_moeda_principal_fdrebes[vi] +
                            (p-principal * (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.receb_moeda_acrescimo_fdrebes[vi] = 
                            tt-venda.receb_moeda_acrescimo_fdrebes[vi] +
                            (p-acrescimo * (titpag.titvlpag / titulo.titvlpag))
                            tt-venda.receb_moeda_juros_fdrebes[vi] = 
                            tt-venda.receb_moeda_juros_fdrebes[vi] +
                           (titulo.titjur * (titpag.titvlpag / titulo.titvlpag))
                            .

                        leave.
                    end.    
                 end.               
            end.
        end.
        else do:

            find first moeda where  moeda.moecod = titulo.moecod
                               no-lock no-error.
            if not avail moeda
            then find first moeda where moeda.moecod = "REA"
                                no-lock no-error.
            vi = 0.
            do vi = 1 to 15:
                if tt-venda.define_recebimento_moeda[vi] = ""
                then tt-venda.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                if tt-venda.define_recebimento_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                then do:
                    if p-sitlan = "LEBES"
                    then assign
                        tt-venda.recebimento_moeda_lebes[vi] =
                            tt-venda.recebimento_moeda_lebes[vi] 
                            + titulo.titvlcob
                        tt-venda.receb_moeda_principal_lebes[vi] =
                            tt-venda.receb_moeda_principal_lebes[vi] 
                            + p-principal
                        tt-venda.receb_moeda_acrescimo_lebes[vi] =
                            tt-venda.receb_moeda_acrescimo_lebes[vi] 
                            + p-acrescimo
                        tt-venda.receb_moeda_juros_lebes[vi] = 
                            tt-venda.receb_moeda_juros_lebes[vi] +
                            titulo.titjuro
                            .
                      else if p-sitlan = "FINANCEIRA"
                        then assign
                            tt-venda.recebimento_moeda_fdrebes[vi] =
                                tt-venda.recebimento_moeda_fdrebes[vi] +
                                titulo.titvlcob
                            tt-venda.receb_moeda_principal_fdrebes[vi] =
                                    tt-venda.receb_moeda_principal_fdrebes[vi] 
                                + p-principal
                            tt-venda.receb_moeda_acrescimo_fdrebes[vi] =
                               tt-venda.receb_moeda_acrescimo_fdrebes[vi] 
                                + p-acrescimo
                            tt-venda.receb_moeda_juros_fdrebes[vi] = 
                            tt-venda.receb_moeda_juros_fdrebes[vi] +
                            titulo.titjuro
                            .
  
                    leave.
                end.    
            end.         
        end.        
    end.
                   
    if titulo.titjuro > 0
    then do:
        
        if p-sitlan = "LEBES"
        then tt-venda.juros_lebes = tt-venda.juros_lebes + titulo.titjuro.
        else if p-sitlan = "FINANCEIRA"
            then tt-venda.juros_fdrebes = tt-venda.juros_fdrebes
                        + titulo.titjuro.
    end.

end procedure.

 procedure put-recebimento-novacao:

    assign
            tt-venda.recebimento_novacao = 
                tt-venda.recebimento_novacao + tit-novado.titvlcob
            tt-venda.recebimento_principal_novacao =
                tt-venda.recebimento_principal_novacao + p-principal
            tt-venda.recebimento_acrescimo_novacao = 
                tt-venda.recebimento_acrescimo_novacao + p-acrescimo
            /**
            tt-venda.recebimento_lebes =
                         tt-venda.recebimento_lebes + tit-novado.titvlcob
                         **/
                         .
    
end procedure.

procedure put-contratonov:

     
     tt-venda.valor_novacao = tt-venda.valor_novacao + vtitvlcob.
     
     if vacrescimo > 0
     then do:           
                
        tt-venda.acrescimo_novacao = 
                        tt-venda.acrescimo_novacao + vacrescimo.

     end.
end procedure.

procedure put-devolucao:
     
     if d-contrato.vltotal > 0
     then do:
                 
        tt-venda.devolucao_prazo = 
            tt-venda.devolucao_prazo + d-contrato.vltotal.
     end.
     if d-contrato.vlfrete > 0
     then do:           
                
        tt-venda.estorno_devolucao = 
            tt-venda.estorno_devolucao + d-contrato.vlfrete.
     end.
     if d-contrato.vlentra > 0
     then do:
          
        tt-venda.devolucao_vista = 
            tt-venda.devolucao_vista + d-contrato.vlentra.
     
    end.

     
end procedure.


procedure put-fetitulo:

     tt-venda.estorno_cancelamento_fdrebes = 
                tt-venda.estorno_cancelamento_fdrebes + fin.titulo.titvlcob.
     
end procedure.


procedure devolucao:

    def buffer bplani for com.plani.
    def buffer cplani for com.plani.
    def buffer bmovim for com.movim.
    def buffer cmovim for com.movim.
    def buffer ctitulo for fin.titulo.

    for each ctdevven where ctdevven.etbcod = tt-estab.etbcod and
                            ctdevven.pladat = vdata1 /*and
                            ctdevven.placod-ven = 0*/  and
                            ctdevven.serie = "1"
                            no-lock break by placod :


        if first-of(placod)
        then do: 
            find first com.plani where plani.movtdc = ctdevven.movtdc and
                          plani.etbcod = ctdevven.etbcod and
                          plani.placod = ctdevven.placod and
                          plani.serie = "1"
                          no-lock no-error.
            if not avail plani
            then next.
        end.
        
        if ctdevven.placod-ven > 0
        then
        find first bplani where bplani.movtdc = ctdevven.movtdc-ven and
                          bplani.etbcod = ctdevven.etbcod-ven and
                          bplani.placod = ctdevven.placod-ven 
                          no-lock no-error.
        
        
        find first cplani where cplani.movtdc = ctdevven.movtdc-ori and
                          cplani.etbcod = ctdevven.etbcod-ori and
                          cplani.placod = ctdevven.placod-ori
                          no-lock no-error.
            
        if avail cplani
        then do:
           
            find first fin.contnf where contnf.etbcod = cplani.etbcod and
                              contnf.placod = cplani.placod
                              no-lock no-error.
            
            if avail contnf
            then do:
                find first d-contrato where 
                          d-contrato.contnum = contnf.contnum
                          no-error.
                if not avail d-contrato
                then do:
                    create d-contrato.
                    assign
                        d-contrato.contnum = contnf.contnum
                        d-contrato.etbcod  = contnf.etbcod
                        d-contrato.dtinicial = vdata1
                        d-contrato.clicod = cplani.desti
                        .
                end.

                find first btitulo where btitulo.empcod = 19 and
                                  btitulo.titnat = no and
                                  btitulo.modcod = "CRE" and
                                  btitulo.etbcod = cplani.etbcod and
                                  btitulo.clifor = cplani.desti  and
                                  btitulo.titnum = string(contnf.contnum) and
                                  btitulo.moecod = "DEV"  
                                  no-lock no-error.
                if avail btitulo
                then
                for each fin.titulo where titulo.empcod = 19 and
                                  titulo.titnat = no and
                                  titulo.modcod = "CRE" and
                                  titulo.etbcod = cplani.etbcod and
                                  titulo.clifor = cplani.desti  and
                                  titulo.titnum = string(contnf.contnum) 
                                  no-lock:
                                  
                    if titulo.titdtemi = cplani.pladat and 
                        titulo.moecod = "DEV"
                        and titulo.etbcob = ?
                    then  assign
                        d-contrato.vltotal = 
                            d-contrato.vltotal + titulo.titvlcob
                            .
                    else if titulo.etbcob = cplani.etbcod and
                        ctdevven.pladat = titulo.titdtpag
                    then assign
                        d-contrato.vltotal =
                            d-contrato.vltotal + titulo.titvlcob.
                    else            
                    assign
                        d-contrato.vltotal =
                        d-contrato.vltotal + titulo.titvlcob
                        d-contrato.vlfrete =
                        d-contrato.vlfrete + titulo.titvlcob.
                end.  
                else do:

                     d-contrato.vlentra = d-contrato.vlentra +
                                cplani.platot.
                end.
            end.
            else do: 
              
                find first d-contrato where 
                          d-contrato.contnum = cplani.numero and
                          d-contrato.etbcod  = cplani.etbcod
                          no-error.
                if not avail d-contrato
                then do:
                    create d-contrato.
                    assign
                        d-contrato.contnum = cplani.numero
                        d-contrato.etbcod  = cplani.etbcod
                        d-contrato.dtinicial = vdata1
                        d-contrato.clicod = cplani.desti
                        .
                 end.
                 
                 d-contrato.vlentra = d-contrato.vlentra +
                    cplani.platot.
            end.
        end.
    end.

end procedure.

procedure vendavista:
    def var v-recarga as log.
    for each fin.titulo where
             titulo.etbcobra = tt-estab.etbcod and
             titulo.titdtpag = vdata1 and
             titulo.modcod   = "VVI"
             no-lock:
        
        find first com.plani where plani.etbcod = tt-estab.etbcod and
                         plani.movtdc = 5 and
                         plani.emite = tt-estab.etbcod and
                         plani.serie = "V" and
                         plani.numero = int(trim(substr(titulo.titnum,2,9)))
                         no-lock no-error.
        if avail plani and
                substr(plani.notped,1,1) = "C" and
                       plani.ufemi <> ""
        then do: 
            
            create tit-vista.
            buffer-copy titulo to tit-vista.
            
            if titulo.moecod = "PDM"
            then do:
                for each titpag where
                      titpag.empcod = titulo.empcod and
                      titpag.titnat = titulo.titnat and
                      titpag.modcod = titulo.modcod and
                      titpag.etbcod = titulo.etbcod and
                      titpag.clifor = titulo.clifor and
                      titpag.titnum = titulo.titnum and
                      titpag.titpar = titulo.titpar
                      no-lock:
                    find first moeda where 
                               moeda.moecod = titpag.moecod
                               no-lock no-error.
                    if not avail moeda
                    then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                    vi = 0.
                    do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + titpag.titvlpag.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + titpag.titvlpag.
                    
                 end.               
            end.            
            else do:
                     find first moeda where 
                               moeda.moecod = titulo.moecod
                               no-lock no-error.
                     if not avail moeda
                     then find first moeda where
                                moeda.moecod = "REA"
                                no-lock no-error.
                     vi = 0.
                     do vi = 1 to 15:
                        if tt-venda.define_venda_moeda[vi] = ""
                        then tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom.
                        
                        if tt-venda.define_venda_moeda[vi] = 
                                moeda.moecod + " - " + moeda.moenom
                        then do:
                            tt-venda.venda_moeda[vi] =
                             tt-venda.venda_moeda[vi] + titulo.titvlcob.
                            leave.
                        end.    
                    end.         
                    tt-venda.venda_vista =
                           tt-venda.venda_vista + titulo.titvlcob.
                    
            end.                     
        end.                         
        else if avail plani
        then do:
            
            v-recarga = no.
            for each com.movim where
                     movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod and
                     movim.movtdc = plani.movtdc 
                     no-lock:
                find produ where produ.procod = movim.procod no-lock.
                if produ.pronom matches "*recarga*"
                then assign
                    tt-venda.venda_recarga[1] =
                     tt-venda.venda_recarga[1] + (movim.movpc * movim.movqtm)
                    tt-venda.venda_vista = tt-venda.venda_vista +
                        (movim.movpc * movim.movqtm)
                     v-recarga = yes.  
                     .
            end.
            if v-recarga = yes
            then do:
                tt-venda.define_venda_recarga[1] = "REC - RECARGA".
                create tit-vista.
                buffer-copy titulo to tit-vista.
            end.
        end.
    end.         
end procedure.

