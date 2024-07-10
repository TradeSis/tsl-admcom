{admcab.i new}

def shared var vdti as date.
def shared var vdtf as date.
def var vdata1 as date.
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

def temp-table fc-contrato like fin.contrato.
def temp-table tt-tabdac like tabdac
    index i1 etbcod clicod numlan parlan datemi tiplan sitlan
     .

def temp-table tt-venda like tabdicem.
def temp-table tt-receb like tabdicre.

def new shared temp-table tit-novado like fin.titulo.

sresp = no.
message "Confirma?" update sresp.
if not sresp then return.

def var v-crepes as dec.
def var p-seguro as dec.

run conecta_d.p.           

for each tt-estab no-lock:

    disp tt-estab.etbcod with frame f.
    pause 0.

    if tt-estab.etbcod >= 900 and
       tt-estab.etbcod <> 993
    then vetb-pag = 996.
    else vetb-pag = tt-estab.etbcod.

    do vdata1 = vdti to vdtf:
        disp vdata1 with frame f.
        pause 0.                
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