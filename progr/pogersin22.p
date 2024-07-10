{admcab.i}

def var vclinovos as log format "Sim/Nao".

def buffer btitulo for fin.titulo.
def temp-table tt-clien
    field clicod like clien.clicod
    field mostra as log init no
    index ind01 clicod.

def var varquivo as char format "x(20)".
def var vdti as date.
def var vdtf as date.
def var vporestab as log format "Sim/Nao".
def var vcre as log format "Geral/Facil" initial yes.
def var vtipo as log format "Nova/Antiga".
def var vdtref  as   date format "99/99/9999" .
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vtotal  like fin.titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like fin.titulo.titvlcob.
def var vtot2   like fin.titulo.titvlcob.

def temp-table wf
    field etbcod  like fin.titulo.etbcod
    field vencido like fin.titulo.titvlcob label "Vencido"
    field vencer  like fin.titulo.titvlcob label "Vencer".

def temp-table wfano
    field vano    as i format "9999"
    field vencidoano like fin.titulo.titvlcob label "Vencido"
    field vencerano  like fin.titulo.titvlcob label "Vencer"
    field cartano    like fin.titulo.titvlcob label "Carteira".

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int. 

def temp-table tt-cli
    field clicod like clien.clicod.

def var wvencidoano like fin.titulo.titvlcob label "Vencido".
def var wvencerano  like fin.titulo.titvlcob label "Vencer".
def var wcartano    like fin.titulo.titvlcob label "Carteira".

def temp-table tt-etbtit
    field etbcod like estab.etbcod
    field titvlcob like fin.titulo.titvlcob
    index i1 etbcod.
    
/*
update vcre label "Cliente" colon 20 with side-label
width 80.

*/

update vetbcod label "Filial"  colon 20.
if vetbcod <> 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label .
    pause 0.
    
end.
else  display "Geral" @ estab.etbnom.

vdtref = today.

if vcre = no
then do:
    
    for each tt-cli:
        delete tt-cli.
    end.
      
      
    for each clien where clien.classe = 1 no-lock:
    
        display clien.clicod
                clien.clinom
                clien.datexp format "99/99/9999" with 1 down. pause 0.
    
        create tt-cli.
        assign tt-cli.clicod = clien.clicod.
    end.
end.

for each estab no-lock:
    
    if vetbcod > 0 and
    estab.etbcod <> vetbcod then next.
    
    disp "Processando... " esta.etbcod with frame ff 1 down.
            pause 0.
            
    for each fin.titulo where
             titulo.empcod = 19 and
             titulo.titnat = no and
             titulo.modcod = "CRE" and
             titulo.etbcod = estab.etbcod and
             (titulo.titdtpag = ? or
             titulo.titdtpag > vdtref)
             no-lock:
             
        disp titulo.titnum with frame ff.
        pause 0.
        find first clien where clien.clicod = titulo.clifor
                no-lock no-error.
        if not avail clien then next.
                
        if fin.titulo.etbcod = 17 and
            vindex = 2 and
            fin.titulo.titdtemi >= 10/20/2010
        then next.  
        else if fin.titulo.etbcod = 17 and
                vindex = 1 and
                fin.titulo.titdtemi < 10/20/2010
             then next.            
            

        if fin.titulo.titdtemi > vdtref
        then next.
            
        find first wf where 
                       wf.etbcod = estab.etbcod
                       no-error.
        if not available wf
        then do:
            create wf.
            wf.etbcod = estab.etbcod.
        end.    
        if fin.titulo.titdtven <= vdtref
        then wf.vencido = wf.vencido + fin.titulo.titvlcob.
        else wf.vencer  = wf.vencer + fin.titulo.titvlcob.
    end.
end.

varquivo = "/admcom/relat/carteira-por-filial-1.csv".

{mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "140"
            &Page-Line = "66"
            &Nom-Rel   = ""pogersin""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ CARTEIRA CLIENTES "" + 
                               "" DATA BASE: "" + 
                              string(vdtref,""99/99/9999"")" 
            &Width     = "140"
            &Form      = "frame f-cabcab"}


 
for each wf by wf.etbcod.
    disp wf.etbcod
         wf.vencido(total)  format ">>>,>>>,>>9.99"
         wf.vencer(total)   format ">>>,>>>,>>9.99"
         wf.vencido + wf.vencer(total) format ">>>,>>>,>>9.99"
         with frame f-disp down
         width 100
         .
    
end.
output close.

run visurel.p(varquivo,"").
