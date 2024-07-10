{admcab.i new}

def var vmes as int format "99".
def var vano as int format "9999".
def var vtipo as char format "x(15)".

def var vclifor as char.

def temp-table tt-relcxa
    field clicod like clien.clicod
    field clinom as char
    field valrecebido as dec
    field valacrescimo as dec
    field valjuro     as dec
    index i1 clicod
    index i2 clinom
    .
    
def buffer barqclien for arqclien.
def buffer carqclien for arqclien.

vtipo = "RECEBIMENTO".

update vmes label "Mes" 
       vano label "Ano"
       vtipo label "Tipo"
       with frame f-1 side-label 1 down width 80.
       
/*for each estab no-lock:
*/

for each arqclien where
             arqclien.mes = vmes and
             arqclien.ano = vano and
             /*arqclien.etbcod = estab.etbcod and*/
             arqclien.tipo begins vtipo
             no-lock:
        
        vclifor = substr(arqclien.campo2,2,10).
        
        find first tt-relcxa where
                   tt-relcxa.clicod = int(vclifor)
                   no-error.
        if not avail tt-relcxa
        then do:
            create tt-relcxa.
            tt-relcxa.clicod = int(vclifor).
            find    clien where 
                    clien.clicod = tt-relcxa.clicod no-lock no-error.
            if avail clien
            then tt-relcxa.clinom = clien.clinom.        
            else disp int(tt-relcxa.clicod).
        end.
        tt-relcxa.valrecebido = tt-relcxa.valrecebido +
                    dec(arqclien.campo8).

        find first contrato where 
                   contrato.contnum = int(arqclien.campo5)
                   no-lock no-error.
        if avail contrato
        then do:
            /*
            disp contrato.vltotal crecod.
            find first finan where finan.fincod = contrato.crecod
                        no-lock no-error.
            disp finfat vltotal * finfat dec(arqclien.campo8).            
            */
            find contnf where contnf.etbcod = contrato.etbcod and
                              contnf.contnum = contrato.contnum
                               no-lock no-error.
            if avail contnf
            then do:
                find first plani where plani.etbcod = contnf.etbcod and
                           plani.placod = contnf.placod and
                           plani.movtdc = 5
                           no-lock no-error.
                if avail plani 
                then do:
                    
                    if plani.biss - (plani.platot - plani.vlserv) > 0
                    then do:
                    /*
                    disp contrato.crecod 
                        contrato.vltotal  plani.platot - plani.vlserv
                    plani.biss - (plani.platot - plani.vlserv)
                    dec(arqclien.campo8) dec(arqclien.campo8) / plani.biss
                    (plani.biss - (plani.platot - plani.vlserv))
                    * (dec(arqclien.campo8) / plani.biss).
                    */
                    
                    if ((plani.biss - (plani.platot - plani.vlserv))
                    * (dec(arqclien.campo8) / plani.biss)) 
                       <> ?
                    then                    
                    tt-relcxa.valacrescimo = tt-relcxa.valacrescimo +
                          ((plani.biss - (plani.platot - plani.vlserv))
                    * (dec(arqclien.campo8) / plani.biss))  
                            .

                    end.
                end.
            end.
            find first titulo where 
                       titulo.clifor = contrato.clicod and
                       titulo.titnum = arqclien.campo5 and
                       titulo.titdtpag = arqclien.data and
                       titulo.etbcobra = arqclien.etbcod and
                       titulo.titpar > 0 no-lock no-error.
            if avail titulo and
               titulo.titjuro > 0
            then do:
                tt-relcxa.valjuro = tt-relcxa.valjuro +
                    titulo.titjuro.
           end.
                                          
        end.
                                  
    /*end. */
end.
/*
vtipo = "JUROS".
for each arqclien where
             arqclien.mes = vmes and
             arqclien.ano = vano and
             /*arqclien.etbcod = estab.etbcod and*/
             arqclien.tipo begins vtipo
             no-lock:
        vclifor = subst(arqclien.campo2,2,10).
        find first tt-relcxa where
                   tt-relcxa.clicod = int(vclifor)
                   no-error.
        if not avail tt-relcxa or
            tt-relcxa.valacrescimo = 0 or
            tt-relcxa.valacrescimo = ?
        then do:
            /*
            create tt-relcxa.
            tt-relcxa.clicod = (subst(arqclien.campo2,2,10)).
            find    clien where 
                    clien.clicod = int(tt-relcxa.clicod) no-lock no-error.
            if avail clien
            then tt-relcxa.clinom = clien.clinom.        
            */
            next.
        end.
        tt-relcxa.valjuro = tt-relcxa.valjuro +
                    dec(arqclien.campo8).

end. 
*/
    
def var vtotal as dec format ">>>,>>>,>>9.99".    
def var vacrescimo as dec format ">>>,>>>,>>9.99".
def var vjuros as dec format ">>>,>>>,>>9.99".
FOR EACH tt-relcxa where valacrescimo > 0 and
                         valacrescimo <> ? NO-LOCK use-index i2:
    disp tt-relcxa.clinom
         tt-relcxa.valacrescimo.
    pause 0.     
    VTOTAL = VTOTAL + tt-relcxa.valrecebido.
    vacrescimo = vacrescimo + tt-relcxa.valacrescimo.
    vjuros = vjuros + tt-relcxa.valjuro.
END.
    DISP VTOTAL vacrescimo vjuros. PAUSE.
    
