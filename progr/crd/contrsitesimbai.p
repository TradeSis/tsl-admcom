/*
*
*
*/
{admcab.i}

def input parameter par-rec as recid.
def var vmaxdevol as int.
def var vqtddevol as int.

/**
def var vtotalproduto  as dec.
def var vpercitem      as dec.
def var vunititem      as dec.
**/
def var vtotoper as char.
def var vtotal as dec.
def var psaldo as dec.



def shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.

def shared temp-table ttdevolve no-undo
    field prec as recid
    field qtddevol as int.

def new shared temp-table ttparcela
    field titpar    like titulo.titpar
    field titvltot  like titulo.titvltot
    field titvlpag  like titulo.titvlpag
    field titvlcob  like titulo.titvlcob
    field titvlprod as dec
    field titvlfrete as dec
    field titvlacres as dec
    field titvlbaixa as dec
    field titvlcredito as dec
    field novosaldo  as dec.

    def var ttitvltot  like titulo.titvltot.
    def var ttitvlpag  like titulo.titvlpag.
    def var ttitvlcob  like titulo.titvlcob.
    def var ttitvlprod as dec              .
    def var ttitvlfrete as dec             .
    def var ttitvlacres as dec             .
    def var ttitvlbaixa as dec             .
    def var ttitvlcredito as dec           .
    def var tnovosaldo  as dec.
      
find contrsite where recid(contrsite) = par-rec no-lock.
find contrato   of contrsite  no-lock.

def var vnro_parcela as int.
def var pvalor as dec.
def var pprod as dec.
def var pfret as dec .
def var pacre as dec.
def var vtitvlpag as dec.

vnro_parcela = 0.
for each titulo where titulo.contnum = contrato.contnum no-lock.
    create ttparcela.
    ttparcela.titpar = titulo.titpar.
    ttparcela.titvltot = if titulo.titvltot <> 0 
                         then titulo.titvltot
                         else titulo.titvlcob.
    ttparcela.titvlpag = titulo.titvlpag.
    ttparcela.titvlcob = ttparcela.titvltot - ttparcela.titvlpag.
    vnro_parcela = vnro_parcela + 1.    
end. 
vtotoper = "". 
pvalor = 0. 
pprod  = 0.
pfret = 0.
pacre = 0.
for each ttcancela. 
    vtotoper = ttcancela.operacao. 
    pvalor   = pvalor + ttcancela.valordevol. 
    find contrsitem where recid(contrsitem) = ttcancela.prec no-lock.
    pprod = pprod + contrsitem.valorTotal.
    pfret = pfret + contrsitem.valorFrete.
    pacre = pacre + contrsitem.valorAcres.
    
end.

vtitvlpag = round(pvalor / vnro_parcela,2).
def var vperc as dec.

  
        ttitvltot       = 0.
        ttitvlpag       = 0.
        ttitvlcob       = 0.
        ttitvlbaixa     = 0.
        ttitvlcredito   = 0.
        tnovosaldo      = 0.
        ttitvlprod      = 0.
        ttitvlfrete     = 0.
        ttitvlacres     = 0.

for each ttparcela.

    ttparcela.titvlbaixa = ttparcela.titvltot - ttparcela.titvlpag - vtitvlpag.
    if ttparcela.titvlbaixa < 0
    then do:
        ttparcela.titvlcredito = ttparcela.titvlbaixa * -1.
        ttparcela.titvlbaixa   = vtitvlpag  - ttparcela.titvlcredito.
    end.
    else ttparcela.titvlbaixa = vtitvlpag.
    
    if ttparcela.titvltot - ttparcela.titvlpag = 0    
    then do:
        ttparcela.titvlbaixa = 0.
    end.                  
    else if ttparcela.titvlbaixa >= 0
    then do:
        ttparcela.novosaldo = ttparcela.titvltot - ttparcela.titvlpag - ttparcela.titvlbaixa.
        vperc     = ttparcela.titvlbaixa / vtitvlpag.
        ttparcela.titvlpro    = round(pprod * vperc / vnro_parcela,2).
        
        ttparcela.titvlfrete  = round(pfret * vperc / vnro_parcela,2).
        ttparcela.titvlacres  = round(pacre * vperc / vnro_parcela,2).
        
   end.
    
        ttitvltot       = ttitvltot + ttparcela.titvltot.
        ttitvlpag       = ttitvlpag + ttparcela.titvlpag.
        ttitvlcob       = ttitvlcob +  ttparcela.titvlcob.
        ttitvlbaixa     = ttitvlbaixa + ttparcela.titvlbaixa.
        ttitvlcredito   = ttitvlcredito + ttparcela.titvlcredito.
        tnovosaldo      = tnovosaldo + ttparcela.novosaldo.
        ttitvlprod      = ttitvlprod + ttparcela.titvlprod.
        ttitvlfrete     = ttitvlfrete + ttparcela.titvlfrete.
        ttitvlacres     = ttitvlacres + ttparcela.titvlacres.
     
end.
def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 3
    init [" efetiva","  ", ""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 40.
pause 0.
    esqpos1  = 1.
    form
        ttparcela.titpar format ">9" column-label "Pc"
        ttparcela.titvltot     format ">>>9.99" column-label "Total"
        ttparcela.titvlpag     format ">>>9.99" column-label "Pago"
        ttparcela.titvlcob     format ">>>9.99" column-label "Saldo"
        "|" space(0)
        
        ttparcela.titvlbaixa   format ">>>9.99" column-label "Baixa"
        ttparcela.titvlcredito format ">>>9.99" column-label "Credito"
        ttparcela.novosaldo    format ">>>9.99" column-label "Calc"
        "|" space(0)
        ttparcela.titvlprod    format ">>9.99" column-label "Produ"
        ttparcela.titvlfrete   format ">>9.99" column-label "Frete"
        ttparcela.titvlacres   format ">>9.99" column-label "Acres"
        
        
        
        with frame frame-a 7 down centered row 9 overlay  width 80
            title " Simulacao de Devolucao de  " + string(pvalor,">>>>>>>>>9.99").

    disp
        space(4)
        ttitvltot     format ">>>9.99" column-label "Total"
        ttitvlpag     format ">>>9.99" column-label "Pago"
        ttitvlcob     format ">>>9.99" column-label "Saldo"
        "|" space(0)
        
        ttitvlbaixa   format ">>>9.99" column-label "Baixa"
        ttitvlcredito format ">>>9.99" column-label "Credito"
        tnovosaldo    format ">>>9.99" column-label "Calc"
        "|" space(0)
        ttitvlprod    format ">>9.99" column-label "Produ"
        ttitvlfrete   format ">>9.99" column-label "Frete"
        ttitvlacres   format ">>9.99" column-label "Acres"
        
        
        
        with frame frame-t 1 down centered row screen-lines - 1 overlay no-labels no-box
        width 80.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttparcela where recid(ttparcela) = recatu1 no-lock.
    if not available ttparcela
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(ttparcela).
    color display message esqcom1[esqpos1] with frame f-com1.

    repeat.
        run leitura (input "seg").
        if not available ttparcela
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find ttparcela where recid(ttparcela) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field ttparcela.titpar help ""
                go-on(cursor-down cursor-up                       cursor-left cursor-right

                      page-down   page-up
                      PF4 F4 ESC return) .
            run color-normal.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.

            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttparcela
                    then leave.
                    recatu1 = recid(ttparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttparcela
                    then leave.
                    recatu1 = recid(ttparcela).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttparcela
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttparcela
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = " efetiva"
            then do:
                
                vtotoper = "".
                vtotal = 0.
                for each ttcancela.
                    vtotoper = ttcancela.operacao.
                    vtotal   = vtotal + ttcancela.valordevol.
                end.
                psaldo = 0.
                
                if vtotoper = "cancela"
                then run crd/devolvecontrsite.p ("ECP", recid(contrsite), vtotal).
                if vtotoper = "devolve"
                then run crd/devolvecontrsite.p ("EDP", recid(contrsite), vtotal).
                
                return.
                
            end.
        
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttparcela).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.


procedure frame-a.

    display
        ttparcela.titpar
        ttparcela.titvltot
        ttparcela.titvlpag
        ttparcela.titvlcob
        ttparcela.titvlbaixa
        ttparcela.titvlcredito
        ttparcela.novosaldo
        ttparcela.titvlprod
        ttparcela.titvlfrete
        ttparcela.titvlacres
        
        with frame frame-a.
end procedure.


procedure color-message.
    color display message
            ttparcela.titpar
        ttparcela.titvltot
        ttparcela.titvlpag
        ttparcela.titvlcob
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
            ttparcela.titpar
        ttparcela.titvltot
        ttparcela.titvlpag
        ttparcela.titvlcob
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find first ttparcela no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find next ttparcela no-lock no-error.
             
if par-tipo = "up" 
then find prev ttparcela  no-lock no-error.
        
end procedure.



