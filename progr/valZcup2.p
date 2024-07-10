
def input parameter vetbi like estab.etbcod.
def input parameter vetbf like estab.etbcod.
def input parameter vdti as date.
def input parameter vdtf as date.
def var vdata as date.

def var vcxacod as integer.
def var vnrored as integer.
def var vcont   as integer.

def var vpausa  as integer.

def buffer bmapctb for mapctb.

def var vgtotal-ini-mat  as decimal format "->>>,>>>,>>9.99".
def var vgtotal-ini-fil  as decimal format "->>>,>>>,>>9.99".

form with frame f-disp.
for each estab where estab.etbcod < 200 /*and
                estab.etbnom begins "DREBES-FIL"*/ no-lock:
       
    if estab.etbcod >= vetbi and
       estab.etbcod <= vetbf
    then. else next.
        
    if /*estab.etbcod = 10 or */
       estab.etbcod = 22 or
       estab.etbcod = 189
    then next.

    disp estab.etbcod label "Filial" with frame f-disp
            1 down no-box color message.
    pause 0.
            
    for each mapcxa where mapcxa.Etbcod = estab.etbcod
                  and mapcxa.datmov >= vdti  
                  and mapcxa.datmov <= vdtf no-lock:
        disp mapcxa.cxacod label "ECF" with frame f-disp.
        pause 0.
        find first mapctb where mapctb.Etbcod = mapcxa.etbcod
                        and mapctb.cxacod = mapcxa.cxacod
                        and mapctb.datmov = mapcxa.datmov
                                exclusive-lock no-error.


        do on error undo, retry:

            if not avail mapctb
            then create mapctb.

            buffer-copy mapcxa to mapctb.

        end.

    end. 

end. 

hide frame f-disp no-pause.
