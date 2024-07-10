{admcab.i}

def input parameter p-datref as date.

def var vtitvlcob as dec.

def temp-table tt-tbcntgen  no-undo
    field nivel as char
    field numini as char
    field numfim as char
    field valor as dec
    index i1 nivel.

for each tbcntgen where tbcntgen.tipcon = 11
                    no-lock by tbcntgen.campo1[1]  :
    create tt-tbcntgen.
    assign
        tt-tbcntgen.nivel = tbcntgen.campo1[1]
        tt-tbcntgen.numini = tbcntgen.numini
        tt-tbcntgen.numfim = tbcntgen.numfim
        tt-tbcntgen.valor = tbcntgen.valor
        .
end. 

def var q-nivel as int.
def var vi as int .
def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.

for each tt-tbcntgen no-lock.
    if tt-tbcntgen.nivel = ""
    then delete tt-tbcntgen.
    else assign
            vi = vi + 1
            a-dia[vi] = int(trim(tt-tbcntgen.numini))
            b-dia[vi] = int(trim(tt-tbcntgen.numfim))
            v-risco[vi] = tt-tbcntgen.nivel
            v-pct[vi] = tt-tbcntgen.valor
            .
end.

q-nivel = vi.

def var v-vtotal as dec format ">>>,>>>,>>9.99".
def var v-vincob as dec format ">>>,>>>,>>9.99".
def var v-v0a30 as dec format ">>>,>>>,>>9.99".
def var v-v31a90 as dec format ">>>,>>>,>>9.99".
def var v-v91a180 as dec format ">>>,>>>,>>9.99".
def var v-vencido as dec format ">>>,>>>,>>9.99".
def var v-vencer  as dec format ">>>,>>>,>>9.99".
def temp-table tt-salcli
    field clifor like clien.clicod
    field saldo as dec
    field vencido as dec
    field vencer as dec
    field v0a30 as dec
    field v31a90 as dec
    field v91a180 as dec
    field vm180 as dec
    index i1 clifor.

def var vtotal1 as dec format ">>>,>>>,>>9.99".
def var vtotal2 as dec format ">>>,>>>,>>9.99".

def buffer btitsalctb for titsalctb.

def var vtitdtven as date. 
def buffer titsalctb for SC2014.
    
def var vdatref as date format "99/99/9999".
vdatref = p-datref.
disp vdatref label "Data referencia" with frame f1 side-label width 80.

def var varquivo as char.

def var vqpro as int.

def temp-table tt-titulo
    field clifor like fin.titulo.clifor
    field titnum like fin.titulo.titnum
    field titvlcob like fin.titulo.titvlcob
    field titdtemi like fin.titulo.titdtemi
    field titdtven like fin.titulo.titdtven
    index i1 clifor titnum.

sresp = no.
message "Confirma processamento?" update sresp.
if not sresp then return.

form "Aguarde processamento...      " vqpro no-label format ">>>>>>>>9" 
     "registros processados"
      with frame f-bar 1 down
                 width 80 no-box color message side-label.

if vdatref = 12/31/10
then do:
    for each SC2010 where
             SC2010.titdtemi <= vdatref and
            (SC2010.titsit = "LIB" or 
            (SC2010.titsit = "PAG" and
             SC2010.titdtpag > vdatref)) 
             no-lock.
            
              
        find first tt-salcli where
               tt-salcli.clifor = SC2010.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2010.clifor.
        end.           
    
        v-vtotal = v-vtotal + SC2010.titvlcob.
        tt-salcli.saldo = tt-salcli.saldo + SC2010.titvlcob.
    
        if vtitdtven > vdatref
        then assign
            v-vencer = v-vencer + SC2010.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2010.titvlcob
            .
        else assign
            v-vencido = v-vencido + SC2010.titvlcob
            tt-salcli.vencido = tt-salcli.vencido + SC2010.titvlcob
            .

        if vtitdtven <= vdatref and
           vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + SC2010.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + SC2010.titvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + SC2010.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + SC2010.titvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + SC2010.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + SC2010.titvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + SC2010.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + SC2010.titvlcob
                        .

        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
        create tt-titulo.
        assign
            tt-titulo.clifor = SC2010.clifor
            tt-titulo.titnum = SC2010.titnum 
            tt-titulo.titdtemi = SC2010.titdtemi
            tt-titulo.titdtven = SC2010.titdtven
            tt-titulo.titvlcob = SC2010.titvlcob
            .

    end.
end.
if vdatref = 12/31/11
then do:
    for each SC2011 where
             SC2011.titdtemi <= vdatref and
            (SC2011.titsit = "LIB" or 
            (SC2011.titsit = "PAG" and
             SC2011.titdtpag > vdatref)) 
             no-lock.
                   
        find first tt-salcli where
               tt-salcli.clifor = SC2011.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2011.clifor.
        end.           
    
        v-vtotal = v-vtotal + SC2011.titvlcob.
        tt-salcli.saldo = tt-salcli.saldo + SC2011.titvlcob.
    
        if vtitdtven > vdatref
        then assign
            v-vencer = v-vencer + SC2011.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2011.titvlcob
            .
        else assign
            v-vencido = v-vencido + SC2011.titvlcob
            tt-salcli.vencido = tt-salcli.vencido + SC2011.titvlcob
            .

        if vtitdtven <= vdatref and
            vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + SC2011.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + SC2011.titvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + SC2011.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + SC2011.titvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + SC2011.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + SC2011.titvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + SC2011.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + SC2011.titvlcob
                        .
        
        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
        create tt-titulo.
        assign
            tt-titulo.clifor = SC2011.clifor
            tt-titulo.titnum = SC2011.titnum 
            tt-titulo.titdtemi = SC2011.titdtemi
            tt-titulo.titdtven = SC2011.titdtven
            tt-titulo.titvlcob = SC2011.titvlcob
            .
    
    end.
end.
if vdatref = 12/31/12
then do:
    for each SC2012 where
             SC2012.titdtemi <= vdatref and
            (SC2012.titsit = "LIB" or 
            (SC2012.titsit = "PAG" and
             SC2012.titdtpag > vdatref)) 
             no-lock.
              
        find first tt-salcli where
               tt-salcli.clifor = SC2012.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2012.clifor.
        end.           
    
        v-vtotal = v-vtotal + SC2012.titvlcob.
        tt-salcli.saldo = tt-salcli.saldo + SC2012.titvlcob.
    
        if vtitdtven > vdatref
        then assign
            v-vencer = v-vencer + SC2012.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2012.titvlcob
            .
        else assign
            v-vencido = v-vencido + SC2012.titvlcob
            tt-salcli.vencido = tt-salcli.vencido + SC2012.titvlcob
            .

        if vtitdtven <= vdatref and
            vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + SC2012.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + SC2012.titvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + SC2012.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + SC2012.titvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + SC2012.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + SC2012.titvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + SC2012.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + SC2012.titvlcob
                        .
        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
        create tt-titulo.
        assign
            tt-titulo.clifor = SC2012.clifor
            tt-titulo.titnum = SC2012.titnum 
            tt-titulo.titdtemi = SC2012.titdtemi
            tt-titulo.titdtven = SC2012.titdtven
            tt-titulo.titvlcob = SC2012.titvlcob
            .

    end.
end.
if vdatref = 12/31/13
then do:
    for each SC2013 where
             SC2013.titdtemi <= vdatref and
            (SC2013.titsit = "LIB" or 
            (SC2013.titsit = "PAG" and
             SC2013.titdtpag > vdatref)) 
             no-lock.
              
        find first tt-salcli where
               tt-salcli.clifor = SC2013.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2013.clifor.
        end.           
    
        v-vtotal = v-vtotal + SC2013.titvlcob.
        tt-salcli.saldo = tt-salcli.saldo + SC2013.titvlcob.
    
        if vtitdtven > vdatref
        then assign
            v-vencer = v-vencer + SC2013.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2013.titvlcob
            .
        else assign
            v-vencido = v-vencido + SC2013.titvlcob
            tt-salcli.vencido = tt-salcli.vencido + SC2013.titvlcob
            .

        if vtitdtven <= vdatref and
            vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + SC2013.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + SC2013.titvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + SC2013.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + SC2013.titvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + SC2013.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + SC2013.titvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + SC2013.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + SC2013.titvlcob
                        .
        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
        create tt-titulo.
        assign
            tt-titulo.clifor = SC2013.clifor
            tt-titulo.titnum = SC2013.titnum 
            tt-titulo.titdtemi = SC2013.titdtemi
            tt-titulo.titdtven = SC2013.titdtven
            tt-titulo.titvlcob = SC2013.titvlcob
            .

    end.
end.
if vdatref = 12/31/14
then do:
    for each SC2014 where
             SC2014.titdtemi <= vdatref and
            (SC2014.titsit = "LIB" or 
             SC2014.titdtpag > vdatref) 
             no-lock.
              
        if SC2014.titdtvenaux <> ?
        then vtitdtven = SC2014.titdtvenaux.
        else vtitdtven = SC2014.titdtven.

        if length(string(int(year(vtitdtven)))) < 4
        then next.

        create tt-titulo.
        assign
            tt-titulo.clifor = SC2014.clifor
            tt-titulo.titnum = SC2014.titnum 
            tt-titulo.titdtemi = SC2014.titdtemi
            tt-titulo.titdtven = SC2014.titdtven
            .


        find first tt-salcli where
               tt-salcli.clifor = SC2014.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2014.clifor.
        end.           
    
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi]
            then do:
                if vtitdtven <= vdatref
                then do:
                    assign
                    v-vtotal = v-vtotal + SC2014.titvlcob
                    tt-salcli.saldo = tt-salcli.saldo + SC2014.titvlcob
                    v-vencido = v-vencido + SC2014.titvlcob
                    tt-salcli.vencido = tt-salcli.vencido + SC2014.titvlcob
                    tt-titulo.titvlcob = SC2014.titvlcob
                    .
                    vtitvlcob = SC2014.titvlcob.
                    run tot-vencido.
                end.    
                leave.
            end.
        end.

        if vtitdtven - vdatref > 0
        then assign
            v-vtotal = v-vtotal + SC2014.titvlcob
            tt-salcli.saldo = tt-salcli.saldo + SC2014.titvlcob
            v-vencer = v-vencer + SC2014.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2014.titvlcob
            tt-titulo.titvlcob = SC2014.titvlcob
            .

        /****
        if vtitdtven <= vdatref and
            vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + SC2014.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + SC2014.titvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + SC2014.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + SC2014.titvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + SC2014.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + SC2014.titvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + SC2014.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + SC2014.titvlcob
                        .
        
        ***/
        
        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
        /*
        create tt-titulo.
        assign
            tt-titulo.clifor = SC2014.clifor
            tt-titulo.titnum = SC2014.titnum 
            tt-titulo.titdtemi = SC2014.titdtemi
            tt-titulo.titdtven = SC2014.titdtven
            tt-titulo.titvlcob = SC2014.titvlcob
            .
          */
    end.
end.
if vdatref > 12/31/14
then do:
    for each SC2015 where
             SC2015.titdtemi <= vdatref and
            (SC2015.titsit = "LIB" or 
             SC2015.titdtpag > vdatref) 
             no-lock.
              
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.

        if length(string(int(year(vtitdtven)))) < 4
        then next.

        create tt-titulo.
        assign
            tt-titulo.clifor = SC2015.clifor
            tt-titulo.titnum = SC2015.titnum 
            tt-titulo.titdtemi = SC2015.titdtemi
            tt-titulo.titdtven = SC2015.titdtven
            .


        find first tt-salcli where
               tt-salcli.clifor = SC2015.clifor
               no-error.
        if not avail tt-salcli
        then do:
            create tt-salcli.
            tt-salcli.clifor = SC2015.clifor.
        end.           
    
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi]
            then do:
                if vtitdtven <= vdatref
                then do:
                    assign
                    v-vtotal = v-vtotal + SC2015.titvlcob
                    tt-salcli.saldo = tt-salcli.saldo + SC2015.titvlcob
                    v-vencido = v-vencido + SC2015.titvlcob
                    tt-salcli.vencido = tt-salcli.vencido + SC2015.titvlcob
                    tt-titulo.titvlcob = SC2015.titvlcob
                    .
                    vtitvlcob = SC2015.titvlcob.
                    run tot-vencido.
                end.    
                leave.
            end.
        end.

        if vtitdtven - vdatref > 0
        then assign
            v-vtotal = v-vtotal + SC2015.titvlcob
            tt-salcli.saldo = tt-salcli.saldo + SC2015.titvlcob
            v-vencer = v-vencer + SC2015.titvlcob
            tt-salcli.vencer = tt-salcli.vencer + SC2015.titvlcob
            tt-titulo.titvlcob = SC2015.titvlcob
            .

        vqpro = vqpro + 1.
        if vqpro mod 1000 = 0
        then disp vqpro with frame f-bar.
        pause 0.
        
    end.
end.


procedure tot-vencido:
    if vtitdtven <= vdatref and
            vtitdtven > vdatref - 30
        then assign
            v-v0a30 = v-v0a30 + vtitvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + vtitvlcob
            .
        else if vtitdtven <= vdatref - 30 and
            vtitdtven > vdatref - 90
            then assign
                 v-v31a90 = v-v31a90 + vtitvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + vtitvlcob
                .
            else if vtitdtven <= vdatref - 90 and
                vtitdtven > vdatref - 180
                then assign
                    v-v91a180 = v-v91a180 + vtitvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + vtitvlcob
                    .    
                else if vtitdtven <= vdatref - 180
                    then  assign
                        v-vincob = v-vincob + vtitvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + vtitvlcob
                        .
end procedure.

message "AGUARDE GERANDO RELATORIOS...".
pause 0.

def var vclinom like clien.clinom.
def var varquivo1 as char.
varquivo1 = "/admcom/relat/saldo-por-clientes-" +
                    string(vdatref,"99999999") + ".csv".
output to value(varquivo1).
put "Codigo ; Nome ; Saldo ; Vencer ; Vencido ; 
    Vencidos 0a30 ; Vencidos 31a90 ; Vencidos 91a180 ; Vencidos maior 180"
    skip.
for each tt-salcli no-lock:
    find clien where clien.clicod = tt-salcli.clifor no-lock no-error.
    if avail clien
    then vclinom = clien.clinom.
    else vclinom = "".
    put tt-salcli.clifor format ">>>>>>>>>9" 
        ";"
        vclinom    format "x(50)" 
        ";"
        replace(string(tt-salcli.saldo),".",",")
        ";"
        replace(string(tt-salcli.vencer),".",",")
        ";"
        replace(string(tt-salcli.vencido),".",",")
        ";"
        replace(string(tt-salcli.v0a30),".",",")
        ";"
        replace(string(tt-salcli.v31a90),".",",")
        ";"
        replace(string(tt-salcli.v91a180),".",",")
        ";"
        replace(string(tt-salcli.vm180),".",",")
        skip.
end.
put " ; T O T A I S ; "
    replace(string(v-vtotal),".",",") 
    ";"
    replace(string(v-vencer),".",",")
    ";"
    replace(string(v-vencido),".",",")  
    ";"
    replace(string(v-v0a30),".",",") 
    ";"
    replace(string(v-v31a90),".",",") 
    ";"
    replace(string(v-v91a180),".",",") 
    ";"
    replace(string(v-vincob),".",",")
    skip.
    
output close.

def var varquivo2 as char.
varquivo2 = "/admcom/relat/saldo-por-clientes-" +
                        string(vdatref,"99999999") + ".txt".
output to value(varquivo2).
for each tt-salcli no-lock:
    find clien where clien.clicod = tt-salcli.clifor no-lock no-error.
    if avail clien 
    then vclinom = clien.clinom.
    else vclinom = "".
    
    disp tt-salcli.clifor format ">>>>>>>>>9" column-label "Codigo"
         vclinom     format "x(50)"      column-label "Nome"
         tt-salcli.saldo(total)  format ">>>,>>>,>>9.99" column-label "Saldo"
         tt-salcli.vencer(total)  format ">>>,>>>,>>9.99" column-label "Vencer"
         tt-salcli.vencido(total)
                        format ">>>,>>>,>>9.99" column-label "Vencidos"
         tt-salcli.v0a30(total)  format ">>>,>>>,>>9.99" 
                        column-label "Vencidos!0a30"
         tt-salcli.v31a90(total)  format ">>>,>>>,>>9.99"    
                        column-label "Vencidos!31a90"
         tt-salcli.v91a180(total)  format ">>>,>>>,>>9.99"
                        column-label "Vencidos!91a180"
         tt-salcli.vm180(total)  format ">>>,>>>,>>9.99"
                        column-label "Vencidos!maio 180"
         with frame f-dis width 150 down.
end.
output close.

def var varquivo3 as char.
varquivo3 = "/admcom/relat/saldo-arquivo-documento-" +
                    string(vdatref,"99999999") + ".txt".
output to value(varquivo3).
for each tt-titulo no-lock.
    find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
    if avail clien 
    then vclinom = clien.clinom.
    else vclinom = "".
    disp tt-titulo.clifor     column-label "Codigo"     format ">>>>>>>>>9"
         vclinom         column-label "Nome"       format "x(40)"
         clien.ciccgc when avail clien column-label "CPF"        format "x(16)"
         tt-titulo.titnum     column-label "Documento"  format "x(15)"
         tt-titulo.titvlcob   column-label "Valor"      format "->>>,>>>,>>9.99"
         tt-titulo.titdtemi   column-label "Emissao"    format "99/99/9999"
         tt-titulo.titdtven   column-label "vencimento" format "99/99/9999"
         with frame f-tit down width 140.
    down with frame f-tit.     
end.         
output close.

def var varquivo4 as char.
varquivo4 = "/admcom/relat/saldo-total-clientes-" +
                    string(vdatref,"99999999") + ".txt".

output to value(varquivo4).
disp v-vtotal  label "Saldo total"
     v-vencido label "Vencidos   "
     v-vencer  label "Vencer     "
     v-v0a30   label "Vencidos 00a30"
     v-v31a90  label "Vencidos 31a90"
     v-v91a180 label "Vencidos 91a180"
     v-vincob  label "Vencidos +  180" 
     with 1 column side-label.


output close.

unix silent unix2dos value(varquivo1).
unix silent unix2dos value(varquivo2).
unix silent unix2dos value(varquivo3).
unix silent unix2dos value(varquivo4).

message color red/with
    "Arquivos gerado:" skip
    varquivo1 skip
    varquivo2 skip
    varquivo3 skip
    varquivo4
    view-as alert-box.
    

disp v-vtotal  label "Saldo total"
     v-vencido label "Vencidos   "
     v-vencer  label "Vencer     "
     v-v0a30   label "Vencidos 00a30"
     v-v31a90  label "Vencidos 31a90"
     v-v91a180 label "Vencidos 91a180"
     v-vincob  label "Vencidos +  180" 
     with 1 column side-label.
pause.
    
procedure tit-dtven:
    
    if titsalctb.titdtvenaux <= vdatref and
       titsalctb.titdtvenaux > vdatref - 30
    then assign
            v-v0a30 = v-v0a30 + titsalctb.titvlcob
            tt-salcli.v0a30 = tt-salcli.v0a30 + titsalctb.titvlcob
            .
    else if titsalctb.titdtvenaux <= vdatref - 30 and
            titsalctb.titdtvenaux > vdatref - 90
        then assign
                v-v31a90 = v-v31a90 + titsalctb.titvlcob
                tt-salcli.v31a90 = tt-salcli.v31a90 + titsalctb.titvlcob
                .
        else if titsalctb.titdtvenaux <= vdatref - 90 and
                titsalctb.titdtvenaux > vdatref - 180
            then assign
                    v-v91a180 = v-v91a180 + titsalctb.titvlcob
                    tt-salcli.v91a180 = tt-salcli.v91a180 + titsalctb.titvlcob
                    .    
            else if titsalctb.titdtvenaux <= vdatref - 180
                then assign
                        v-vincob = v-vincob + titsalctb.titvlcob
                        tt-salcli.vm180 = tt-salcli.vm180 + titsalctb.titvlcob
                        .
       
end procedure.
