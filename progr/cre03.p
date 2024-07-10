{admcab.i}

def var ii as int.

def new shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.

def var vcelular as char.
def temp-table tt-cel
    field celular as char
    field nome as char
    index i1 celular.

def stream stela.
def workfile wcli
    field clicod like  clien.clicod
    field clinom like  clien.clinom
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

procedure val-celular:
    def var vcelular as char.
    def var vnome as char.
    vnome = entry(1,clien.clinom,"").
    
    vcelular = "".
    if substr(clien.fax,1,1) = "1" or
       substr(clien.fax,1,1) = "2" or
       substr(clien.fax,1,1) = "3" or
       substr(clien.fax,1,1) = "4" or
       substr(clien.fax,1,1) = "5" or
       substr(clien.fax,1,1) = "6" or
       substr(clien.fax,1,1) = "7" or
       substr(clien.fax,1,1) = "8" or
       substr(clien.fax,1,1) = "9" or
       substr(clien.fax,1,1) = "0"
    then do:
        if length(clien.fax) <= 10
        then do:
            if length(clien.fax) = 10
            then vcelular = clien.fax.
            else do:
                vcelular = "51" + clien.fax.
                if length(vcelular) <> 10
                then vcelular = "".
            end.
        end.        
        if substr(vcelular,3,2) <> "81" and
           substr(vcelular,3,2) <> "82" and
           substr(vcelular,3,2) <> "83" and
           substr(vcelular,3,2) <> "84" and
           substr(vcelular,3,2) <> "85" and
           substr(vcelular,3,2) <> "86" and
           substr(vcelular,3,2) <> "87" and
           substr(vcelular,3,2) <> "88" and
           substr(vcelular,3,2) <> "89" and
           substr(vcelular,3,2) <> "90" and
           substr(vcelular,3,2) <> "91" and
           substr(vcelular,3,2) <> "92" and
           substr(vcelular,3,2) <> "93" and
           substr(vcelular,3,2) <> "94" and
           substr(vcelular,3,2) <> "95" and
           substr(vcelular,3,2) <> "96" and
           substr(vcelular,3,2) <> "97" and
           substr(vcelular,3,2) <> "98" and
           substr(vcelular,3,2) <> "99" and
           substr(vcelular,3,2) <> "80"            
        then.
        else do:
            find first tt-cel where tt-cel.celular = vcelular
                no-error.
            if not avail tt-cel
            then do:
                create tt-cel.
                tt-cel.celular = vcelular.
                tt-cel.nome    = vnome.
            end.
        end.
    end.                            
end procedure.
def var vetbcod1 like estab.etbcod.
def buffer bestab for estab.
def var vlmax as dec.
def var vcre as log format "Geral/Facil" initial yes.
def temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    index ind-1 clinom.


def temp-table tt-titulo like titulo.

def temp-table tt-cliq
    field clicod like clien.clicod
    field ano as int
    field mes as int
    index i1 clicod ano mes.

def var qtd-cli as int.
def var qtd-par as int.
def var val-cob as dec.

def var tqtd-cli as int.
def var tqtd-par as int.
def var tval-cob as dec.


repeat:
    
    for each tt-extrato.
        delete tt-extrato.
    end.
    
    for each wcli:
        delete wcli.
    end.
    /**
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

    **/
    update vetbcod colon 20 vetbcod1 label 'até' with frame f2.
    find estab where 
         estab.etbcod = vetbcod 
         no-lock no-error.
    if not avail estab
    then do:
        message "Primeiro estabelecimento invalido.".
        undo.
    end.
    find bestab where
         bestab.etbcod = vetbcod1
         no-lock no-error.
    if not avail bestab then do:
        message "Segundo estabelecimento inválido.". 
    end.      
    if vetbcod > vetbcod1 then do:
        message "Primeiro estabelecimento deve ser menor que o segundo.".
        undo.
    end. 
    display  skip 
    estab.etbnom  no-label at 22 ' - ' bestab.etbnom no-label with frame f2.
    update vdtvenini label "Vencimento Inicial" colon 20
           vdtvenfim label "Final"
                with row 4 side-labels width 80 
                 frame f2.

    vlmax = 0.
    update vcre label "Cliente" colon 20 
           vlmax label "Maior Parcela" with side-label
           frame f2.
    /*
    disp vtprel-cli no-label with frame f11 
                    centered title " Tipo Relatorio ".
    choose field vtprel-cli with frame f11.
    if frame-index = 2
    then vtsint = yes.
    else vtsint = no.
    if vtsint = no
    then do:
        disp vcont-cli no-label with frame f1 centered title " Ordenacao ".
        choose field vcont-cli with frame f1.
        if frame-index = 1
        then valfa = yes.
        else valfa = no.
    end.
    else valfa = no.    
    */
 
    disp vcont-cli no-label with frame f1 centered.
    choose field vcont-cli with frame f1.
    if frame-index = 1
    then valfa = yes.
    else valfa = no.
    VSUBTOT = 0.
    
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
            assign tt-cli.clicod = clien.clicod
                   tt-cli.clinom = clien.clinom.
        end.
    end. 

for each tt-cliq: delete tt-cliq. end.
for each tt-titulo: delete tt-titulo. end.
assign
        qtd-cli = 0
        qtd-par = 0
        val-cob = 0
        tqtd-cli = 0
        tqtd-par = 0
        tval-cob = 0
        .

if valfa
then do:
    do vdata = vdtvenini to vdtvenfim:
        output stream stela to terminal.
            disp stream stela vdata label "Data"
                with frame fff side-label row 10
                        color white/cyan centered.
        output stream stela close.
        pause 0.
        if vcre
        then
        for each estab where estab.etbcod >= vetbcod and
                             estab.etbcod <= vetbcod1
                             no-lock,
            each titulo use-index titdtven where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.titsit = "LIB" and
                 titulo.etbcod = ESTAB.etbcod and
                 titulo.titdtven = vdata and
                 titulo.titvlcob >= vlmax 
                 no-lock:
        
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
                wcli.clinom = clien.clinom
                wcli.wrec   = recid(titulo).
            end.
            run val-celular.
        end.
        else 
        for each estab where estab.etbcod >= vetbcod and
                             estab.etbcod <= vetbcod1
                             no-lock,
            each tt-cli,
            each titulo use-index titdtven where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = "CRE" and
                 titulo.titsit = "LIB" and
                 titulo.etbcod = ESTAB.etbcod and
                 titulo.clifor = tt-cli.clicod and
                 titulo.titdtven = vdata  and
                 titulo.titvlcob >= vlmax 
                 no-lock:
        
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
                wcli.clinom = clien.clinom
                wcli.wrec   = recid(titulo).
            end.
            run val-celular.
        end.

    end. 
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cre03." + string(time). 
    else varquivo = "l:\relat\cre03." + string(time).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64" 
        &Cond-Var  = "147" 
        &Page-Line = "64" 
        &Nom-Rel   = ""cre03""
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
        
        /**
        create tt-titulo.
        buffer-copy titulo to tt-titulo.
        **/
        
        display
            wcli.clinom when avail clien column-label "Nome do Cliente"
            clien.ciccgc when avail clien column-label "CPF" format "x(13)"
            titulo.clifor     column-label "Cod."
            titulo.titnum     column-label "Contr."
            titulo.titpar     column-label "Pr."
            titulo.titdtem    column-label "Dt.Venda"
            titulo.titdtven    column-label "Vencim."
            titulo.titvlcob(total) column-label "Valor Prest."
                                         format "->>>,>>9.99"
            titulo.titdtven - TODAY    column-label "Dias" with width 180 .
    end.
    /*******
    do:
        for each tt-titulo
                 break by year(tt-titulo.titdtven)
                       by month(tt-titulo.titdtven)
                       by day(tt-titulo.titdtven)
                 :
            
            find clien where clien.clicod = tt-titulo.clifor 
                    no-lock no-error.
                     
            find first tt-cliq where
                       tt-cliq.clicod = clien.clicod     and
                       tt-cliq.ano = year(tt-titulo.titdtven) and
                       tt-cliq.mes = month(tt-titulo.titdtven) no-error.
            if not avail tt-cliq
            then do:
                create tt-cliq.
                tt-cliq.clicod = clien.clicod.
                tt-cliq.ano = year(tt-titulo.titdtven).
                tt-cliq.mes = month(tt-titulo.titdtven).
                qtd-cli = qtd-cli + 1.
            end.           

            display
                    tt-titulo.etbcod  column-label "Fil."  
                    clien.clinom when avail clien
                                       column-label "Nome do Cliente" 
                                       format "x(30)"
                    clien.ciccgc column-label "CPF" format "x(13)"
                    tt-titulo.clifor      column-label "Cod."  
                    tt-titulo.titnum      column-label "Contr."      
                    tt-titulo.titpar      column-label "Pr."         
                    tt-titulo.titdtemi    column-label "Dt.Venda"   
                    tt-titulo.titdtven    column-label "Vencim."    
                    tt-titulo.titvlcob    column-label "Valor Prestacao" 
                    tt-titulo.titdtven - TODAY    column-label "Dias"
                                                    with width 200.
            
            qtd-par = qtd-par + 1.
            val-cob = val-cob + tt-titulo.titvlcob.
            
            if last-of(month(tt-titulo.titdtven))
            then do:
                tqtd-cli = tqtd-cli + qtd-cli.
                tqtd-par = tqtd-par + qtd-par.
                tval-cob = tval-cob + val-cob.
                put skip(1)
                    "TOTAL MES " STRING(month(tt-titulo.titdtven)) + "/" +
                                 string(year(tt-titulo.titdtven))
                                 format "x(10)"
                    "Total Clientes : " qtd-cli     format ">>>>>9"
                    skip
                    "                    "
                    "Total Parcelas : " qtd-par  format ">>>>>9"
                    skip
                    "                    "
                    "  Valor Total  : " val-cob    format ">>,>>>,>>9.99"
                    skip(2).     
                qtd-cli = 0.
                qtd-par = 0.
                val-cob = 0.        
            end.                     
        end. 
        put skip(1) 
            "TOTAL GERAL      "
            "Total Clientes : " tqtd-cli     format ">>>>>9"
            skip
            "                 "
            "Total Parcelas : " tqtd-par  format ">>>>>9"
            skip
            "                 "
            "  Valor Total  : " tval-cob    format ">>,>>>,>>9.99"
            skip(2).  
    end.
    *****/
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.
else do:
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cre03." + string(time). 
    else varquivo = "l:\relat\cre03." + string(time).

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

output to value(varquivo).
view frame fcabb.

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
    /*
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
    */
    vsubtot = vsubtot + titulo.titvlcob.
    
    find first tt-extrato where tt-extrato.rec = recid(clien) no-error.
    if not avail tt-extrato 
    then do:  
        ii = ii + 1. 
        create tt-extrato.  
        assign tt-extrato.rec = recid(clien)  
               tt-extrato.ord = ii.  
    end.
    
    create tt-titulo.
    buffer-copy titulo to tt-titulo.

    /*
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
    */    
    run val-celular.
end.
do:
        for each tt-titulo
                 break by year(tt-titulo.titdtven)
                       by month(tt-titulo.titdtven)
                       by day(tt-titulo.titdtven)
                 :
            
            find clien where clien.clicod = tt-titulo.clifor 
                    no-lock no-error.
                     
            find first tt-cliq where
                       tt-cliq.clicod = clien.clicod     and
                       tt-cliq.ano = year(tt-titulo.titdtven) and
                       tt-cliq.mes = month(tt-titulo.titdtven) no-error.
            if not avail tt-cliq
            then do:
                create tt-cliq.
                tt-cliq.clicod = clien.clicod.
                tt-cliq.ano = year(tt-titulo.titdtven).
                tt-cliq.mes = month(tt-titulo.titdtven).
                qtd-cli = qtd-cli + 1.
            end.           

            display
                    tt-titulo.etbcod  column-label "Fil."  
                    clien.clinom when avail clien
                                       column-label "Nome do Cliente" 
                                       format "x(30)"
                    clien.ciccgc column-label "CPF" format "x(13)"
                    tt-titulo.clifor      column-label "Cod."  
                    tt-titulo.titnum      column-label "Contr."      
                    tt-titulo.titpar      column-label "Pr."         
                    tt-titulo.titdtemi    column-label "Dt.Venda"   
                    tt-titulo.titdtven    column-label "Vencim."    
                    tt-titulo.titvlcob    column-label "Valor Prestacao" 
                    tt-titulo.titdtven - TODAY    column-label "Dias"
                                                    with width 200.
            
            qtd-par = qtd-par + 1.
            val-cob = val-cob + tt-titulo.titvlcob.
            
            if last-of(month(tt-titulo.titdtven))
            then do:
                tqtd-cli = tqtd-cli + qtd-cli.
                tqtd-par = tqtd-par + qtd-par.
                tval-cob = tval-cob + val-cob.
                put skip(1)
                    "TOTAL MES " STRING(month(tt-titulo.titdtven)) + "/" +
                                 string(year(tt-titulo.titdtven))
                                 format "x(10)"
                    "Total Clientes : " qtd-cli     format ">>>>>9"
                    skip
                    "                    "
                    "Total Parcelas : " qtd-par  format ">>>>>9"
                    skip
                    "                    "
                    "  Valor Total  : " val-cob    format ">>,>>>,>>9.99"
                    skip(2).     
                qtd-cli = 0.
                qtd-par = 0.
                val-cob = 0.        
            end.                     
        end. 
        put skip(1) 
            "TOTAL GERAL      "
            "Total Clientes : " tqtd-cli     format ">>>>>9"
            skip
            "                 "
            "Total Parcelas : " tqtd-par  format ">>>>>9"
            skip
            "                 "
            "  Valor Total  : " tval-cob    format ">>,>>>,>>9.99"
            skip(2).  
    end.

output close.

if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.


end.

def var varqsai as char.

if opsys = "UNIX"
then  varqsai = "/admcom/relat/cel2-" + string(time) + ".txt".
else  varqsai = "l:~\relat~\cel2-" + string(time) + ".txt".
output to value(varqsai) page-size 0.
for each tt-cel:
    put     tt-cel.nome + ";" + 
            tt-cel.celular format "x(40)"  skip.
end.    
output close.
message color red/with
        "Arquivo celulares gerado: "  varqsai 
        view-as alert-box.
 
 
message "Deseja imprimir extratos" update sresp.
if sresp
then run extrato2.p.
    


end.
