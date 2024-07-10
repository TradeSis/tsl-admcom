{admcab.i}

def var vsitu   like cheque.chesit.
def new shared var vtipo   as log format "PRE/DIA".

vtipo = no.

def new shared var vdti    as date format "99/99/9999".
def new shared var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.
def stream      stela.
def var vdata   like plani.pladat.
def var totval  like plani.platot.
def var totjur  like plani.platot.

def new shared temp-table tt-chq like chq.

repeat:

    for each tt-chq:
        delete tt-chq.
    end.
    
    update vtipo label "Tipo"
           vdti  label "Data Inicial"
           vdtf  label "Data Final"
           with frame f-dep centered side-label color white/red row 4.

  
    for each chq where chq.data >= vdti and
                       chq.data <= vdtf no-lock:

        if vtipo = yes and
           chq.data = chq.datemi
        then next.
           
        if vtipo = no and
           chq.data <> chq.datemi
        then next.    

        totval = totval + chq.valor.
            
        disp chq.data 
             chq.valor
             with frame f-disp centered 1 down.
        pause 0.
        

        create tt-chq.
        assign tt-chq.data    = chq.data
               tt-chq.banco   = chq.banco
               tt-chq.agencia = chq.agencia
               tt-chq.conta   = chq.conta
               tt-chq.numero  = chq.numero
               tt-chq.datemi  = chq.datemi
               tt-chq.valor   = chq.valor.
    end.
    
    hide frame f-disp no-pause.

    run chpredia-brw.p.
    
end.
