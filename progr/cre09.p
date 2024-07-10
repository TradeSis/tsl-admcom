{admcab.i}

def var ii as int.

def new shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.


def stream stela.
def workfile wcli
    field clicod like  clien.clicod
    field clinom as char format "x(10)"
    field wrec   as  recid.
def var vdata like plani.pladat.
def buffer btitulo for titulo.
def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 2
      initial ["  Alfabetica  ","  Vencimento  "].
def var valfa  as log.
def var varquivo as char.
repeat:
    
    for each tt-extrato.
        delete tt-extrato.
    end.
    
    for each wcli:
        delete wcli.
    end.

    update vetbcod colon 20.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido" .
            undo.
        end.
    end.
    else display "Geral" @ estab.etbnom no-label.
     
    update
       vdtvenini label "Vencimento Inicial" colon 20
       vdtvenfim label "Final"
               with row 4 side-labels width 80 .

    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    if frame-index = 1
    then valfa = yes.
    else valfa = no.
    VSUBTOT = 0.
if valfa
then do:
    do vdata = vdtvenini to vdtvenfim:
        output stream stela to terminal.
            disp stream stela vdata label "Data"
                with frame fff side-label row 10
                        color white/cyan centered.
        output stream stela close.
        pause 0.
        for each estab where if vetbcod = 0
                             then true
                             else estab.etbcod = vetbcod no-lock,
            each titulo use-index titdtven where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.titsit = "LIB" and
                 titulo.etbcod = ESTAB.etbcod and
                 titulo.titdtven = vdata no-lock:
        
            if titulo.clifor = 1
            then next.

            find first clien where clien.clicod = titulo.clifor no-lock.

            find first btitulo use-index iclicod
                    where btitulo.empcod = wempre.empcod and
                                     btitulo.titnat = no            and
                                     btitulo.modcod = "CRE"         and
                                     btitulo.titsit = "LIB"         and
                                     btitulo.clifor = titulo.clifor and
                                     btitulo.titdtven < vdtvenini
                                                       no-lock no-error.
            
            if avail btitulo
            then next.
            
            find first wcli where wcli.clicod = clien.clicod no-error.
            if not avail wcli
            then do:
                create wcli.
                assign wcli.clicod = clien.clicod
                       wcli.clinom = substring(clien.clinom,1,10) 
                       wcli.wrec   = recid(titulo).
            end.
        
        end.
    
    end. 
    
    varquivo = "l:\relat\cre03." + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "147" 
        &Page-Line = "64" 
        &Nom-Rel   = ""cre09""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """POSICAO FINANCEIRA - FILIAL "" +
                     string(vetbcod,"">>9"") +
                     ""  PERIODO DE "" +
                     string(vdtvenini,""99/99/9999"") + "" A "" +
                     string(vdtvenfim,""99/99/9999"") "
        &Width     = "147"
        &Form      = "frame f-cabcab"}
    

    for each wcli by wcli.clinom:
    
        find first titulo where recid(titulo) = wcli.wrec no-lock.

        vsubtot = vsubtot + titulo.titvlcob.
        
        find clien where clien.clicod = titulo.clifor no-lock no-error.
        if avail clien
        then do:
            find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
            if not avail tt-extrato
            then do: 
                ii = ii + 1.
                create tt-extrato. 
                assign tt-extrato.rec = recid(clien) 
                       tt-extrato.ord = ii. 
            end.
        end.         
        
        display
            clien.clinom when avail clien column-label "Nome do Cliente"
            clien.dtnasc column-label "Data Nascimento" format "99/99/9999"
            clien.ciccgc(count) column-label "CPF"
             with width 180 .
    end.
    output close.
    {mrod.i}
end.
else
for each estab where estab.etbcod = vetbcod no-lock,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = "CRE" and
        titulo.titsit = "LIB" and
        titulo.etbcod = estab.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = "CRE"         and
                             btitulo.titsit = "LIB"         and
                             btitulo.clifor = titulo.clifor  and
                             btitulo.titdtven < vdtvenini no-lock no-error.
    if avail btitulo
    then next.

        form header
            wempre.emprazsoc
                    space(6) "POCLI"   at 117
                    "Pag.: " at 128 page-number format ">>9" skip
                    "POSICAO FINANCEIRA GERAL P/FILIAL-CLIENTE-"
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 117
                    string(time,"hh:mm:ss") at 130
                    skip fill("-",137) format "x(137)" skip
                    with frame fcabb no-label page-top no-box width 137.
        view frame fcabb.
    vsubtot = vsubtot + titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato 
    then do:  
        ii = ii + 1. 
        create tt-extrato.  
        assign tt-extrato.rec = recid(clien)  
               tt-extrato.ord = ii.  
    end.

    display
        titulo.etbcod      column-label "Fil."         space(3)
        clien.clinom when avail clien
                        column-label "Nome do Cliente" space(1)
        titulo.clifor      column-label "Cod."            space(3)
        titulo.titnum      column-label "Contr."        space(3)
        titulo.titpar      column-label "Pr."         space(4)
        titulo.titdtemi    column-label "Dt.Venda"   space(4)
        titulo.titdtven    column-label "Vencim."    space(3)
        titulo.titvlcob    column-label "Valor Prestacao"  space(3)
        titulo.titdtven - TODAY    column-label "Dias"
        with width 180 .
end.
output close.

message "Deseja imprimir extratos" update sresp.
if sresp
then run extrato2.p.
    


end.
