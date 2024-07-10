 {admcab.i}

def input parameter p-data as date.

def stream stela.

def new shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.

def shared temp-table tt-titulo like fin.titulo.    

def var vdias as int.
def var vjuro as dec.
def var vtotal as dec.
def var varquivo as char.

def var ii as int init 0.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relincob." + string(time). 
else varquivo = "l:\relat\relincob." + string(time).

sresp = no.
message "Deseja emitir relatorio?" update sresp.

{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "147" 
        &Page-Line = "64" 
        &Nom-Rel   = ""cre03""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """ INCOBRAVEIS DATA BASE "" 
                        + string(p-data,""99/99/9999"") "
        &Width     = "130"
        &Form      = "frame f-cabcab"}
 
        
for each tt-titulo no-lock break by tt-titulo.etbcod
                                     by tt-titulo.titdtven:

    find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
    if not avail clien then next.
            
        assign
            vdias = 0
            vjuro = 0
            vtotal = 0
             .
             
        if tt-titulo.titdtven < today
        then do:
            vdias = today - tt-titulo.titdtven.
            if vdias > 1766
            then vdias = 1766.
 
            {sel-tabjur.i tt-titulo.etbcod vdias}
        
            if not avail fin.tabjur
            then do:
                /*
                message "Fator para" today - tt-titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause 0.
                */
             end.
            else  assign vjuro  = 
                    (tt-titulo.titvlcob * fin.tabjur.fator) - tt-titulo.titvlcob
                   vtotal = tt-titulo.titvlcob + vjuro
                   vdias  = today - tt-titulo.titdtven.
        end.
        else vtotal = tt-titulo.titvlcob.
        
        if first-of(tt-titulo.etbcod)
        then disp tt-titulo.etbcod column-label "Fil"
                with frame f-rel.
        disp tt-titulo.clifor format ">>>>>>>>>9" column-label "Conta"
             tt-titulo.titnum format "x(10)" column-label "Contrato"
             tt-titulo.titdtven column-label "Vencimento"
             tt-titulo.titpar format ">9" column-label "P"
             tt-titulo.titvlcob  (total by tt-titulo.etbcod)
                format "->,>>>,>>9.99" column-label "Val.Cobrado"
             vdias  format "->>>9" column-label "Dias"
             vjuro  (total by tt-titulo.etbcod)
                format "->,>>>,>>9.99" column-label "Juro"
             vtotal (total by tt-titulo.etbcod)
                format "->>,>>>,>>9.99" column-label "Val.Atualizado"
             with frame f-rel down width 120.
        down with frame f-rel.      
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato
    then do: 
                ii = ii + 1.
                create tt-extrato. 
                assign tt-extrato.rec = recid(clien) 
                       tt-extrato.ord = ii. 
    end.
end.
output close.

if sresp
then do:
if opsys = "UNIX"
then do:
        run visurel.p(input varquivo, input "").
end.
else do:
        os-command silent start value(varquivo).
end.        
end.

sresp = no.
message "Deseja emitir extratos? " update sresp.
if sresp 
then do:
    run relincob02.p.
    pause.
end.    
    
