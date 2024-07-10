{admcab.i}

def temp-table tt-titulo like titulo.

def var vdata as date.

update vetbcod like estab.etbcod label "Filial"
        with frame f-1 side-label width 80.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        bell.
        message color red/with
        "Filial nãa cadastrada."
        view-as alert-box.
        undo.
    end.
    else disp estab.etbnom no-label with frame f-1.
end.            

update vcontrato like contrato.contnum at 1 label "Contrato"
       vparcela  as int format ">>9"  label "Parcela"
        with frame f-1.
if vparcela > 0 and vcontrato = 0
then do:
    bell.
    message color red/with
    "Favor informar o numero do contrato."
    view-as alert-box.
    undo.
end.
        
if vcontrato = 0 
then do:
    update vdti as date at 1 format "99/99/9999" label "Data pagamento inicial"
       vdtf as date format "99/99/9999" label "Data pagamento final"
       with frame f-1.

    if vdti = ? or vdtf = ? or vdti > vdtf
    then do:
        bell.
        message color red/with
        "Periodo invalido."
        view-as alert-box.
        undo.
    end. 
end.   

if keyfunction(lastkey) = "END-ERROR"
then return.

if vetbcod > 0 
then do:
    if vcontrato > 0
    then do:
        for each titulo where titulo.titnat = no and
                              titulo.titnum = string(vcontrato) and
                              titulo.titpar = vparcela and
                              titulo.etbcod = vetbcod and
                              titulo.cobcod = 10
                              no-lock .
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
        end.                              
    end.
    else do:
        do vdata = vdti to vdtf:
            disp estab.etbcod label "Filial"
                vdata label "Pagamento"
                with frame fd 1 down side-label.
            pause 0. 
            for each titulo where titulo.titnat    = no and
                              titulo.titdtpag = vdata and
                              titulo.etbcod    = vetbcod and
                              titulo.cobcod    = 10
                              no-lock .
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
            end.
        end.  
    end.
end.
else do:
    if vcontrato > 0
    then do:
        for each titulo where titulo.titnat = no and
                              titulo.titnum = string(vcontrato) and
                              titulo.titpar = vparcela and
                              titulo.cobcod = 10
                              no-lock .
            create tt-titulo.
            buffer-copy titulo to tt-titulo.
        end.                              
    end.
    else do:
        for each estab no-lock:
            disp estab.etbcod label "Filial"
                with frame fd 1 down side-label.
            pause 0.    
            do vdata = vdti to vdtf:
                disp vdata label "Pagamento" with frame fd.
                pause 0.
                for each titulo use-index Por-Dtpag-Uo-Modal
                   where titulo.titnat    = no and
                              titulo.titdtpag = vdata and
                              titulo.etbcod    = estab.etbcod and
                              titulo.cobcod    = 10 
                              no-lock .
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                end.
            end.  
        end.
    end.
end.

def var varquivo as char.
varquivo = "/admcom/relat/rbatecf-v0118" + "." + string(time) .
{mdad_l.i
    &Saida     = "value(varquivo)"
    &Page-Size = "0"
    &Cond-Var  = "147"
    &Page-Line = "64"
    &Nom-Rel   = ""rbatecf-v0118""
    &Nom-Sis   = """SISTEMA FINANCEIRO"""
    &Tit-Rel   = """RELATORIO DE PAGAMENTOS""" 
    &Width     = "147"
    &Form      = "frame f-cabcab1"}

disp with frame f-1.
 
for each tt-titulo no-lock:
    find clien where clien.clicod = tt-titulo.clifor no-lock no-error.
    if not avail clien then next.
    disp    tt-titulo.etbcod     column-label "Filial"
            tt-titulo.clifor     column-label "Cliente"
            clien.ciccgc         column-label "CPF"
            clien.clinom         column-label "Nome"
            tt-titulo.titnum     column-label "Contrato"
            tt-titulo.titpar     column-label "Parcela"
            tt-titulo.titvlcob(total)   column-label "Valor!Cobrado"
            tt-titulo.titvlpag(total)   column-label "Valor!Pago"
            tt-titulo.titsit            column-label "Sit"
            with frame f-dis down width 150.
end.    

output close.
run visurel.p(varquivo, "").

