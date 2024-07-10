{admcab.i new}
{retorna-pacnv.i new}

def shared var vdti as date.
def shared var vdtf as date.
def var vdata as date.
def buffer tt-estab for estab.

def var vetb-pag like estab.etbcod.

def var v-principal as dec.
def var v-acrescimo as dec.
def var v-seguro as dec.
def var v-novacao as log format "Sim/Nao".
def var v-financiado as dec.
def var v-clientes as dec.
def var vtitvlcob as dec.
def var vacrescimo as dec.
def var p-sitlan as char.
def var p-principal as dec.
def var p-acrescimo as dec.
def var p-crepes as dec.

def var p-1 as char.
def var p-2 as char.
def var p-3 as char.
def var p-4 as char.
def var p-5 as char.
def var p-6 as char.
def var p-7 as char.
def var p-8 as char.
def var p-9 as char.
def var p-0 as char.


/*
def temp-table fc-contrato like fin.contrato.
def temp-table tt-tabdac like tabdac
    index i1 etbcod clicod numlan parlan datemi tiplan sitlan
     .

def temp-table tt-venda like tabdicem.
def temp-table tt-receb like tabdicre.
*/
def new shared temp-table tit-novado like fin.titulo.

sresp = no.
message "Confirma?" update sresp.
if not sresp then return.

def var v-crepes as dec.
def var p-seguro as dec.

def temp-table fc-contrato like fin.contrato.
def temp-table tt-valores like opctbval.

procedure reinicia-variaveis:
    assign
        p-1 = ""
        p-2 = ""
        p-3 = ""
        p-4 = ""
        p-5 = ""
        p-6 = ""
        p-7 = ""
        p-8 = ""
        p-9 = ""
        p-0 = ""
        .
end procedure.

for each estab no-lock:

    disp estab.etbcod with frame f.
    pause 0.

    if estab.etbcod >= 900 and
       estab.etbcod <> 993
    then vetb-pag = 996.
    else vetb-pag = estab.etbcod.
    
    for each tt-valores: delete tt-valores. end.
    
    do vdata = vdti to vdtf:
        disp vdata with frame f.
        pause 0.                

       run estorno-cancelamento-financeira.
        
    end.
    run grava-registros.
end.            
        
procedure estorno-cancelamento-financeira:

        for each fc-contrato: delete fc-contrato. end.
        
        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata
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

        for each envfinan where 
                     envfinan.etbcod = estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata
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
                
                
                run principal-renda(input ?,
                                        input recid(contrato),
                                        input ?).
 
        
                run reinicia-variaveis.
                p-1 = "ESTORNO".
                p-2 = "FINANCEIRA".
                run grava-tt-valores (input contrato.vltotal).
                p-9 = string(contrato.contnum).
                run grava-tt-valores (input contrato.vltotal).

                if pacnv-principal > 0
                then do: 
                    p-3 = "PRINCIPAL".
                    run grava-tt-valores (input pacnv-principal).
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores (input pacnv-principal).
                end.
                if pacnv-acrescimo > 0
                then do: 
                    p-3 = "ACRESCIMO".
                    run grava-tt-valores (input pacnv-acrescimo).
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores (input pacnv-acrescimo).
                end.
                if pacnv-entrada > 0
                then do:
                    p-3 = "ENTRADA".
                    run grava-tt-valores(input pacnv-entrada).
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-entrada).
                end.
                if pacnv-seguro > 0
                then do:
                    p-3 = "SEGURO".
                    run grava-tt-valores(input pacnv-seguro).
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-seguro).
                end.
                if pacnv-abate > 0
                then do:    
                    p-3 = "ABATE".
                    run grava-tt-valores(input pacnv-abate).
                    p-9 = string(contrato.contnum).
                    run grava-tt-valores(input pacnv-abate).
                    if pacnv-voucher > 0
                    then do:
                            p-7 = "VOUCHER".
                            run grava-tt-valores(input pacnv-voucher).
                    end.
                    if pacnv-black > 0
                    then do:
                            p-7 = "BLACK".
                            run grava-tt-valores(input pacnv-black).
                    end. 
                    if pacnv-chepres > 0
                    then do:   
                            p-7 = "CHEPRES".
                            run grava-tt-valores(input pacnv-chepres).
                    end.
                    if pacnv-combo > 0
                    then do:
                            p-7 = "COMBO".
                            run grava-tt-valores(input pacnv-combo).
                    end.
                    if pacnv-troca > 0
                    then do:
                            p-7 = "TROCA".
                            run grava-tt-valores(input pacnv-troca).
                    end.
                end.
                
        end.
        
end procedure.


procedure principal-renda:

    def input parameter rec-plani    as recid.
    def input parameter rec-contrato as recid.
    def input parameter rec-titulo   as recid.
    
    assign
        pacnv-avista     = 0
        pacnv-aprazo     = 0
        pacnv-principal  = 0
        pacnv-acrescimo  = 0
        pacnv-entrada    = 0
        pacnv-seguro     = 0
        pacnv-crepes     = 0
        pacnv-troca      = 0
        pacnv-voucher    = 0
        pacnv-black      = 0
        pacnv-chepres    = 0
        pacnv-combo      = 0
        pacnv-abate      = 0
        pacnv-novacao    = no
        pacnv-renovacao  = no
        pacnv-feiraonl   = no
        pacnv-cpfautoriza = ""
        pacnv-juroatu     = 0
        pacnv-juroacr     = 0
        .
        
    if rec-titulo = ?
    then do:
        run retorna-pacnv-valores-contrato.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).
    end.
    else do:
    find first titpacnv where
               titpacnv.modcod = titulo.modcod and
               titpacnv.etbcod = titulo.etbcod and 
               titpacnv.clifor = titulo.clifor and
               titpacnv.titnum = titulo.titnum and
               titpacnv.titdtemi = titulo.titdtemi
                       no-lock no-error.
    if not avail titpacnv
    then do:
        create titpacnv.
        assign
            titpacnv.modcod   = titulo.modcod
            titpacnv.etbcod   = titulo.etbcod
            titpacnv.clifor   = titulo.clifor
            titpacnv.titnum   = titulo.titnum
            titpacnv.titdtemi = titulo.titdtemi
            titpacnv.titvlcob = titulo.titvlcob
            titpacnv.titdes   = titulo.titdes
            .
          
        run retorna-pacnv-valores-contrato.p 
                    (input rec-plani, 
                     input rec-contrato, 
                     input rec-titulo).

        if  pacnv-principal <= 0 or
            pacnv-acrescimo <= 0
        then assign
                 pacnv-principal = titulo.titvlcob
                 pacnv-acrescimo = 0
                 .

        assign
            titpacnv.principal = pacnv-principal
            titpacnv.acrescimo = pacnv-acrescimo
            .
    end.
    else assign
             pacnv-principal = titpacnv.principal
             pacnv-acrescimo = titpacnv.acrescimo
             pacnv-seguro    = titpacnv.titdes
             .
    end.
end procedure.

procedure grava-tt-valores :

    def input parameter p-valor as dec.
    
    if p-valor <> 0
    then do:
        find first tt-valores where
               tt-valores.etbcod = estab.etbcod and
               tt-valores.datref = vdata and
               tt-valores.t1 = p-1 and
               tt-valores.t2 = p-2 and
               tt-valores.t3 = p-3 and
               tt-valores.t4 = p-4 and
               tt-valores.t5 = p-5 and
               tt-valores.t6 = p-6 and
               tt-valores.t7 = p-7 and
               tt-valores.t8 = p-8 and
               tt-valores.t9 = p-9 and
               tt-valores.t0 = p-0 
                               no-error.
        if not avail tt-valores
        then do:
            create tt-valores.
            assign
                tt-valores.etbcod = estab.etbcod
                tt-valores.datref = vdata 
                tt-valores.t1 = p-1
                tt-valores.t2 = p-2
                tt-valores.t3 = p-3
                tt-valores.t4 = p-4
                tt-valores.t5 = p-5
                tt-valores.t6 = p-6
                tt-valores.t7 = p-7
                tt-valores.t8 = p-8
                tt-valores.t9 = p-9
                tt-valores.t0 = p-0
                .
        end. 
        tt-valores.valor = tt-valores.valor + p-valor.
    end.     
    
    assign p-9 = "" p-0 = "" .

end procedure.

procedure grava-registros:
    for each tt-valores.
        create opctbval.
        buffer-copy tt-valores to opctbval.
    end.    
end procedure.

        
/**********************************************        
        for each fc-contrato: delete fc-contrato. end.
        create tt-venda.
        tt-venda.etbcod = tt-estab.etbcod.
        tt-venda.datref = vdata1.
        create tt-receb.
        tt-receb.etbcod = tt-estab.etbcod.
        tt-receb.datref = vdata1.

        for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "CAN" and
                     envfinan.dt1 = vdata1
                     no-lock.
                /*     
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
                */           
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
                    fc-contrato.vltotal + envfinan.dec1 /*titulo.titvlcob*/.
        end.

            /*** Estorno financeira ****/
        for each envfinan where 
                     envfinan.etbcod = tt-estab.etbcod and
                     envfinan.envsit = "EST" and
                     envfinan.dt1 = vdata1
                     no-lock.
                     
                /*find first fin.titulo where
                           titulo.empcod = envfinan.empcod and
                           titulo.titnat = envfinan.titnat and
                           titulo.modcod = envfinan.modcod and
                           titulo.etbcod = envfinan.etbcod and
                           titulo.clifor = envfinan.clifor and
                           titulo.titnum = envfinan.titnum and
                           titulo.titpar = envfinan.titpar
                           no-lock no-error.
                if not avail titulo then next.
                */           
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
                    fc-contrato.vltotal + envfinan.dec1 /*titulo.titvlcob*/.
                
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
                    v-seguro = 0
                    v-crepes = 0
                    .
                
                run retorna-principal-acrescimo-contrato.p
                        (input recid(contrato), 
                         output v-novacao,
                         output v-financiado,
                         output v-clientes,
                         output v-principal, 
                         output v-acrescimo,
                         output v-seguro,
                         output v-crepes).
                
                vtitvlcob  = v-principal.
                vacrescimo = v-acrescimo.
                
                p-sitlan = "LEBES".
                run put-fccontrato.
                
        end.

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
                           
                p-principal = 0.
                p-acrescimo = 0.
                p-seguro = 0.
                p-crepes = 0.
                run retorna-principal-acrescimo-titulo.p
                                        (input recid(titulo),
                                            output p-principal, 
                                            output p-acrescimo,
                                            output p-seguro,
                                            output p-crepes).
                
                if p-principal + p-acrescimo + p-seguro <> titulo.titvlcob
                then do:
                    if p-principal + p-acrescimo + p-seguro > titulo.titvlcob
                    then p-acrescimo = p-acrescimo -
                        ((p-principal + p-acrescimo + p-seguro ) 
                                        - titulo.titvlcob).
                    else if p-principal + p-acrescimo + p-seguro
                                                < titulo.titvlcob
                        then p-principal = p-principal + 
                            (titulo.titvlcob - 
                            (p-principal + p-acrescimo + p-seguro)).

                end. 
                if p-principal <= 0
                then assign
                    p-principal = titulo.titvlcob - titulo.titdes
                    p-seguro = titulo.titdes
                    p-acrescimo = 0.
                    
                run put-fetitulo.
                
        end.
    end.
end.

message "ATUALIZANDO....".
pause 0.

run atualiza.

run desconecta_d.p.

procedure put-fccontrato:

    find first tt-tabdac where
         tt-tabdac.etbcod = fc-contrato.etbcod and
         tt-tabdac.clicod = fc-contrato.clicod and
         tt-tabdac.numlan = string(fc-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = fc-contrato.dtinicial and
         tt-tabdac.tiplan = "EMICANFINAN" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = fc-contrato.etbcod
            tt-tabdac.etblan = fc-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = fc-contrato.clicod
            tt-tabdac.numlan = string(fc-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = fc-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = fc-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vtitvlcob
            tt-tabdac.tiplan = "EMICANFINAN"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "EMICANFINAN" + string(fc-contrato.contnum)
            tt-tabdac.anolan = year(fc-contrato.dtinicial)
            tt-tabdac.meslan = month(fc-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            .
        release tt-tabdac no-error.
    end. 
    
     tt-venda.cancelamentos_fdrebes = 
            tt-venda.cancelamentos_fdrebes + vtitvlcob.
     
     if vacrescimo > 0
     then do:           
     
        /******* ACRESCIMO ********/
        find first tt-tabdac where
         tt-tabdac.etbcod = fc-contrato.etbcod and
         tt-tabdac.clicod = fc-contrato.clicod and
         tt-tabdac.numlan = string(fc-contrato.contnum) and
         tt-tabdac.parlan = ? and
         tt-tabdac.datemi = fc-contrato.dtinicial and
         tt-tabdac.tiplan = "ACRCANFINAN" and
         tt-tabdac.sitlan = p-sitlan
         no-lock no-error.
        if not avail tt-tabdac 
        then do on error undo: 
            create tt-tabdac.
            assign
            tt-tabdac.etbcod = fc-contrato.etbcod
            tt-tabdac.etblan = fc-contrato.etbcod
            tt-tabdac.etbpag = ?
            tt-tabdac.clicod = fc-contrato.clicod
            tt-tabdac.numlan = string(fc-contrato.contnum)
            tt-tabdac.parlan = ?
            tt-tabdac.datemi = fc-contrato.dtinicial
            tt-tabdac.datven = ?
            tt-tabdac.datlan = fc-contrato.dtinicial
            tt-tabdac.datpag = ?
            tt-tabdac.datexp = today
            tt-tabdac.vallan = vacrescimo
            tt-tabdac.tiplan = "ACRCANFINAN"
            tt-tabdac.sitlan = p-sitlan
            tt-tabdac.hislan = "ACRCANFINAN" + string(fc-contrato.contnum)
            tt-tabdac.anolan = year(fc-contrato.dtinicial)
            tt-tabdac.meslan = month(fc-contrato.dtinicial)
            tt-tabdac.natlan = "+"
            .
            release tt-tabdac no-error.
        end. 
        
        tt-venda.acrescimo_cancelamento_fdrebes = 
                tt-venda.acrescimo_cancelamento_fdrebes + vacrescimo.
     end.
     
end procedure.

procedure put-fetitulo:

     find first tt-tabdac where
         tt-tabdac.etblan = vetb-pag and
         tt-tabdac.datlan = envfinan.dt1 and
         tt-tabdac.clicod = fin.titulo.clifor and
         tt-tabdac.numlan = titulo.titnum and
         tt-tabdac.parlan = titulo.titpar and
         tt-tabdac.tiplan = "RECESTFINAN" and
         tt-tabdac.sitlan = "LEBES"
         no-lock no-error.
    if not avail tt-tabdac 
    then do on error undo: 
        create tt-tabdac.
        assign
            tt-tabdac.etbcod = titulo.etbcod
            tt-tabdac.etblan = vetb-pag
            tt-tabdac.etbpag = titulo.etbcob
            tt-tabdac.clicod = titulo.clifor
            tt-tabdac.numlan = titulo.titnum
            tt-tabdac.parlan = titulo.titpar
            tt-tabdac.datemi = titulo.titdtemi
            tt-tabdac.datven = titulo.titdtven
            tt-tabdac.datlan = envfinan.dt1
            tt-tabdac.datpag = titulo.titdtpag
            tt-tabdac.datexp = today
            tt-tabdac.vallan = titulo.titvlcob
            tt-tabdac.tiplan = "RECESTFINAN"
            tt-tabdac.sitlan = "LEBES"
            tt-tabdac.hislan = "RECESTFINAN " + string(titulo.titnum)
            tt-tabdac.anolan = year(envfinan.dt1)
            tt-tabdac.meslan = month(envfinan.dt1)
            tt-tabdac.natlan = "-"
            tt-tabdac.principal = p-principal
            tt-tabdac.acrescimo = p-acrescimo
            .
        release tt-tabdac no-error.
    end. 
     
     tt-receb.estorno_cancelamento_fdrebes = 
                tt-receb.estorno_cancelamento_fdrebes + titulo.titvlcob.
     
end procedure.

procedure atualiza:

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
        then do:
            create tabdac.
            buffer-copy tt-tabdac to tabdac.
        end.
    end.
    for each tt-venda no-lock:
        find first tabdicem where
                   tabdicem.etbcod = tt-venda.etbcod and
                   tabdicem.datref = tt-venda.datref
                   no-error.
        if avail tabdicem
        then
        assign
            tabdicem.cancelamentos_fdrebes =
                tt-venda.cancelamentos_fdrebes
            tabdicem.acrescimo_cancelamento_fdrebes =
                tt-venda.acrescimo_cancelamento_fdrebes
                .
        else do:
            create tabdicem.
            buffer-copy tt-venda to tabdicem.
        end.
    end.
    for each tt-receb no-lock:
        find first tabdicre where
                   tabdicre.etbcod = tt-receb.etbcod and
                   tabdicre.datref = tt-receb.datref
                   no-error.
        if avail tabdicre
        then
        assign
            tabdicre.estorno_cancelamento_fdrebes =
                tt-receb.estorno_cancelamento_fdrebes
                .
        else do:
            create tabdicre.
            buffer-copy tt-receb to tabdicre.
        end.
    end.   
end.   
 
*************************************************/

