{admcab.i }

def var vetbcod like estab.etbcod init 17.
def var vdata   as date format "99/99/9999".
def var vdata1  as date format "99/99/9999" init today.
def var vdata2 as date format "99/99/9999" init today.

def buffer bplani for plani.

def var v-opcao as char format "x(12)" extent 2 initial
    ["VALOR","PRODUTOS"].

def temp-table tt-dev
    field etbcod like estab.etbcod
    field clicod like clien.clicod
    field vldev  like plani.platot
    field contnum like titulo.titnum
    field vlven  like plani.platot
    field difer  as   dec
    field numero-dev like plani.numero
    field numero-ori like plani.numero
    field procod-ori like produ.procod
    field procod-dev like produ.procod
    field perc   as  dec format "->>9.99 %"
    
    
    field etbcod-ori like estab.etbcod
    field placod-ori like plani.placod
    field movtdc-ori like plani.movtdc
    field pladat-ori like plani.pladat
    
    field etbcod-dev like estab.etbcod
    field placod-dev like plani.placod
    field movtdc-dev like plani.movtdc
    field pladat-dev like plani.pladat .
    
def var vetbcod-ori like plani.etbcod.
def var vplacod-ori like plani.placod.
def var vmovtdc-ori like plani.movtdc.
def var vpladat-ori like plani.pladat.

def var vetbcod-dev like plani.etbcod.
def var vplacod-dev like plani.placod.
def var vmovtdc-dev like plani.movtdc.
def var vpladat-dev like plani.pladat.


def temp-table tt-etb
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    index i-etb is primary unique etbcod.
    
repeat:
    
    for each tt-etb:
        delete tt-etb.
    end.
    for each tt-dev:
        delete tt-dev.
    end.
    
    do on error undo:
        update vetbcod label "Filial......"
               with frame f-dados width 80 side-labels.
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada.".
                undo, retry.
            end.
            else disp estab.etbnom no-label with frame f-dados.

            find tt-etb where tt-etb.etbcod = estab.etbcod no-error.
            if not avail tt-etb
            then do:
                create tt-etb.
                assign tt-etb.etbcod = estab.etbcod
                       tt-etb.etbnom = estab.etbnom.
            end.       
        end.
        else do:
        
            disp "GERAL" @ estab.etbnom with frame f-dados.
        
            for each estab where estab.etbcod < 900 no-lock:
            
                if {conv_igual.i estab.etbcod} then next.
           
                find tt-etb where tt-etb.etbcod = estab.etbcod no-error.
                if not avail tt-etb
                then do:
                    create tt-etb.
                    assign tt-etb.etbcod = estab.etbcod
                           tt-etb.etbnom = estab.etbnom.
                end.       
            end.
            
        end.
    end.
    
    update skip
           vdata1 label "Data Inicial"
           vdata2 label "Data Final"
           with frame f-dados.
    
    disp v-opcao with frame f-opcao no-labels centered. 
    choose field v-opcao with frame f-opcao. 
    
    hide frame f-opcao no-pause. 
    
    if frame-index = 1 /* Valor */
    then do:
    end.
    else do: /* Produto */
    end.
    
    for each tt-etb:
        for each titulo use-index titsit
                        where titulo.empcod    = 19
                          and titulo.titnat    = yes
                          and titulo.modcod    = "DEV" 
                          and titulo.titsit    = "PAG"
                          and titulo.etbcod    = tt-etb.etbcod 
                          and titulo.titdtemi >= vdata1
                          and titulo.titdtemi <= vdata2 no-lock:
            
            find first tt-dev where tt-dev.etbcod  = titulo.etbcod
                                and tt-dev.contnum = titulo.titnum
                                and tt-dev.clicod  = titulo.clifor no-error.
            if not avail tt-dev
            then do:
                assign vetbcod-ori = 0
                       vplacod-ori = 0
                       vmovtdc-ori = 0
                       vpladat-ori = ?
                       vetbcod-dev = 0
                       vplacod-dev = 0
                       vmovtdc-dev = 0
                       vpladat-dev = ?.
                       
                assign vetbcod-ori =  int(acha("ETBCOD-ORI",titulo.titobs[1]))
                       vplacod-ori =  int(acha("PLACOD-ORI",titulo.titobs[1]))
                       vmovtdc-ori =  int(acha("MOVTDC-ORI",titulo.titobs[1]))
                       vpladat-ori = date(acha("PLADAT-ORI",titulo.titobs[1]))
               
                       vetbcod-dev = int(acha("ETBCOD-DEV",titulo.titobs[1]))
                       vplacod-dev = int(acha("PLACOD-DEV",titulo.titobs[1]))
                       vmovtdc-dev = int(acha("MOVTDC-DEV",titulo.titobs[1]))
                       vpladat-dev = date(acha("PLADAT-DEV",titulo.titobs[1])).
                
                find first plani where plani.etbcod = vetbcod-dev
                                   and plani.placod = vplacod-dev
                                   and plani.movtdc = vmovtdc-dev
                                   and plani.pladat = vpladat-dev 
                                   no-lock no-error.
                if not avail plani 
                then next.
                
                find first bplani where bplani.etbcod = vetbcod-ori
                                    and bplani.placod = vplacod-ori
                                    and bplani.movtdc = vmovtdc-ori
                                    and bplani.pladat = vpladat-ori 
                                    no-lock no-error.
                if not avail bplani
                then next.
                
                find first contnf where contnf.etbcod = bplani.etbcod
                                    and contnf.placod = bplani.placod
                                    no-lock no-error.

                create tt-dev.
                assign tt-dev.etbcod  = titulo.etbcod
                       tt-dev.clicod  = titulo.clifor
                       tt-dev.vlven   = (if plani.biss > 0
                                         then plani.biss
                                         else plani.platot)
                       tt-dev.vldev   = titulo.titvlpag
                       tt-dev.contnum = string(contnf.contnum)
                                        when avail contnf
                       tt-dev.difer   = tt-dev.vlven - tt-dev.vldev 
                       tt-dev.numero-dev = .
                       
                
            end.
        end.          
    end.                                
                            
    for each tt-dev.
        disp tt-dev.etbcod
             tt-dev.clicod
             tt-dev.vldev
             tt-dev.vlven
             tt-dev.contnum
             tt-dev.difer.
    end.
end.