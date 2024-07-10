def input parameter par-platot like plani.platot.
def input parameter par-dtinclu as date.

def output parameter dvalorcet as dec decimals 6 format "->>>>,>>9.9999".
def output parameter dvalorcetanual as dec decimals 6 format "->>>>,>>9.9999".

def var LOOP as int.
def var loop-max as int.
loop = 0.
loop-max = 1000.

def shared temp-table tttitulo
    field titdtven  as date
    field titvlcob  like titulo.titvlcob.

def var vnumdias as int.
def var dtaxairr as  dec decimals 6 format "->>>>,>>9.999999".
def var dtaxairrloop as dec.
def var dtaxairrant as dec decimals 6 format "->>>>,>>9.999999".
def var dnumdias as int.
def var iloop as int.
def var dvalfinneg as dec.
def var dvalfinnegabs as dec.
def var dvalfinant as dec.
def var dpvtot as dec.
def var dtxirrant as dec.
def var dvaltotpmt as dec. 
def var iprazo as int.
def var dpv as dec decimals 2 format "->>>,>>9.9999".


    dnumdias = 0.
    dvaltotpmt = 0.
    iprazo = 0.
    for each tttitulo.
        dnumdias = max(dnumdias,tttitulo.titdtven - par-dtinclu)        .
        dvaltotpmt = dvaltotpmt + tttitulo.titvlcob.
        iprazo = iprazo + 1.
    end.

    dtaxairr = exp((dvaltotpmt / par-platot),
                        (1 / dnumdias)).
     
    dtaxairr = (dtaxairr - 1) * 100.
  
    if iprazo > 1 then
            dtaxairrloop = 1.
    else dtaxairrloop = 0.
    dtaxairrant = dtaxairr - dtaxairrloop.
    iloop = 1.
    dvalfinneg = 0.
    dvalfinant = 0.
    do while iloop = 1:
        dpvtot = 0.
        dvalfinneg = par-platot * -1. 
        for each tttitulo.
            vnumdias = tttitulo.titdtven - par-dtinclu.
            dpv = tttitulo.titvlcob /
                    exp((1 + dtaxairr / 100), vnumdias).
                    
            dpvtot = dpvtot + dpv.
        end.          
        dvalfinneg = dvalfinneg + dpvtot.
        
        if dvalfinneg < 0 
            then dvalfinnegabs = dvalfinneg * -1. 
            else dvalfinnegabs = dvalfinneg.
        loop = loop + 1.
        if loop >= loop-max
        then iloop = 0.
        if dvalfinnegabs < 0.0001 or dtaxairrloop = 0 
        then iloop = 0.
        else do:
            if dvalfinneg > 0 
            then do:
                dtxirrant = dtaxairr.
                dtaxairr = dtaxairr + dtaxairrloop.
                dvalfinant = dvalfinneg.
            end.
            else do:
                dtaxairrloop = (dtaxairr - dtxirrant) * dvalfinant /
                                    (dvalfinnegabs + dvalfinant).
                dtaxairr = dtxirrant + dtaxairrloop.
            end.
        end.
    end.
   if dtaxairr < dtaxairrant then dtaxairr = dtaxairrant.

    dvalorcet = round((exp((1 + dtaxairr / 100),30) - 1) * 100, 4).
    dvalorcetanual = (exp( 1 + dvalorcet / 100,12) - 1) * 100.
    
