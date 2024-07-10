/*  ../progr/confccob.p         */
{admcab.i}

{setbrw.i}

def var v-cont as integer.
def var v-cod as char.
def var vmod-sel as char.

def var ii as int.

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for fin.titulo.
def var vclinovos as log format "Sim/Nao".

def var vcob as char format "x(15)".
def var vtotger as int.
def var vtotcob as int.

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


def temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
            
def temp-table tt-modalidade-selec
    field modcod as char
    index pk modcod.

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
        if length(clien.fax) <= 11
        then do:
            if length(clien.fax) = 11
            then vcelular = clien.fax.
            else do:
                vcelular = "51" + clien.fax.
                if length(vcelular) <> 11
                then vcelular = "".
            end.
        end.        
        if substr(vcelular,4,2) <> "81" and
           substr(vcelular,4,2) <> "82" and
           substr(vcelular,4,2) <> "83" and
           substr(vcelular,4,2) <> "84" and
           substr(vcelular,4,2) <> "85" and
           substr(vcelular,4,2) <> "86" and
           substr(vcelular,4,2) <> "87" and
           substr(vcelular,4,2) <> "88" and
           substr(vcelular,4,2) <> "89" and
           substr(vcelular,4,2) <> "90" and
           substr(vcelular,4,2) <> "91" and
           substr(vcelular,4,2) <> "92" and
           substr(vcelular,4,2) <> "93" and
           substr(vcelular,4,2) <> "94" and
           substr(vcelular,4,2) <> "95" and
           substr(vcelular,4,2) <> "96" and
           substr(vcelular,4,2) <> "97" and
           substr(vcelular,4,2) <> "98" and
           substr(vcelular,4,2) <> "99" and
           substr(vcelular,4,2) <> "80"            
        then.
        else do:
            find first tt-cel where tt-cel.celular = vcelular no-error.
            if not avail tt-cel
            then do:
                create tt-cel.
                tt-cel.celular = vcelular.
                tt-cel.nome    = vnome.
            end.
        end.
    end.                            
end procedure.

/***
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
***/

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

def var vval-carteira as dec.                                
                                
form
   a-seelst format "x" column-label "*"
   tt-modalidade-padrao.modcod no-label
   with frame f-nome
       centered down title "Modalidades"
       color withe/red overlay.    
                                                        
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.

    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.
        
end.

repeat:
    
    for each tt-extrato.
        delete tt-extrato.
    end.
    
    for each wcli:
        delete wcli.
    end.

    update vetbcod colon 25 vetbcod1 label 'até' with frame f2.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Primeiro estabelecimento invalido.".
        undo.
    end.
    find bestab where bestab.etbcod = vetbcod1 no-lock no-error.
    if not avail bestab then do:
        message "Segundo estabelecimento inválido.". 
    end.      
    if vetbcod > vetbcod1 then do:
        message "Primeiro estabelecimento deve ser menor que o segundo.".
        undo.
    end. 
    display  skip 
    estab.etbnom  no-label at 22 ' - ' bestab.etbnom no-label with frame f2.
    update vdtvenini label "Vencimento Inicial" colon 25
           vdtvenfim label "Final"
                with row 4 side-labels width 80 
                 frame f2.

    vlmax = 0.
    update vcre label "Cliente" colon 25 
           vlmax label "Maior Parcela" with side-label
           frame f2.

    assign sresp = false.
           
    update sresp label "Seleciona Modalidades?" colon 25
           help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
           with side-label
           width 80 frame f2.
              
    if sresp
    then do:
              
        bl_sel_filiais:
        repeat:
                      
            run p-seleciona-modal.
                                                      
            if keyfunction(lastkey) = "end-error"
            then leave bl_sel_filiais.
                                                
        end.
                                                    
    end.
    else do:
                                                    
        create tt-modalidade-selec.
        assign tt-modalidade-selec.modcod = "CRE".
    
    end.
    
    assign vmod-sel = "  ".
    for each tt-modalidade-selec.
        assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
    end.
        
    display vmod-sel format "x(40)" no-label with frame f2.
    
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
    
    vclinovos = no.
    message "Somente clientes novos(até 30 pagas) que atrasaram parcela(s)"
    update vclinovos.
    
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
                             
            each tt-modalidade-selec,                 
                             
            each titulo use-index titdtven where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = tt-modalidade-selec.modcod and
                 titulo.titsit = "LIB" and
                 titulo.etbcod = ESTAB.etbcod and
                 titulo.titdtven = vdata and
                 titulo.titvlcob >= vlmax 
                 no-lock:
        
            if titulo.clifor = 1
            then next.

            find first clien where clien.clicod = titulo.clifor 
                    no-lock no-error.
            if not avail clien then next.        

            find first btitulo use-index iclicod
                    where btitulo.empcod = wempre.empcod and
                          btitulo.titnat = no            and
                          btitulo.modcod = tt-modalidade-selec.modcod and
                          btitulo.titsit = "LIB"         and
                          btitulo.clifor = titulo.clifor and
                          btitulo.titdtven < vdtvenini
                                        no-lock no-error.
            
            if avail btitulo
            then next.
            
            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
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
            
            each tt-modalidade-selec,
            
            each titulo use-index titdtven where
                 titulo.empcod = wempre.empcod and
                 titulo.titnat = no and
                 titulo.modcod = tt-modalidade-selec.modcod and
                 titulo.titsit = "LIB" and
                 titulo.etbcod = ESTAB.etbcod and
                 titulo.clifor = tt-cli.clicod and
                 titulo.titdtven = vdata  and
                 titulo.titvlcob >= vlmax 
                 no-lock:
        
            if titulo.clifor = 1
            then next.

            find first clien where clien.clicod = titulo.clifor 
                    no-lock no-error.
            if not avail clien then next.        

            find first btitulo use-index iclicod
                    where btitulo.empcod = wempre.empcod and
                          btitulo.titnat = no            and
                          btitulo.modcod = tt-modalidade-selec.modcod and
                          btitulo.titsit = "LIB"         and
                          btitulo.clifor = titulo.clifor and
                          btitulo.titdtven < vdtvenini
                                          no-lock no-error.
            
            if avail btitulo
            then next.
            
            if vclinovos 
            then do:
                run cli-novo.
            end.

            find first tt-clinovo where 
                       tt-clinovo.clicod = fin.titulo.clifor
                       no-error.
            if not avail tt-clinovo 
                and vclinovos
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
        &Cond-Var  = "150" 
        &Page-Line = "64" 
        &Nom-Rel   = ""cre03""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """POSICAO FINANCEIRA - FILIAL "" +
                     string(vetbcod,"">>9"") +
                     ""  PERIODO DE "" +
                     string(vdtvenini,""99/99/9999"") + "" A "" +
                     string(vdtvenfim,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}
    

    vtotger = 0.
    vtotcob = 0.
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
        
        vcob = "x".
        find clilig where clilig.clicod = titulo.clifor no-lock no-error.
        
        if not avail clilig
        then run /admcom/progr/clilig_porcliente.p (titulo.clifor).
        
        find clilig where clilig.clicod = titulo.clifor no-lock no-error.
        
        if not avail clilig
        then assign vcob = "Sem Registro".
        else do:
            if clilig.setor = "CRIIC"
            then vcob = clilig.setor.
            else do:
                if clilig.dtacor >= today
                then vcob = "Acordo: " + string(clilig.dtacor).
                /*else
                if clilig.dtultlig = today
                then vcob = "Ult.Lig." + string(today,"99/99/9999").
                */
            end.
        end.
        
        vtotger = vtotger + 1.
        if vcob = "x"
        then
        vtotcob = vtotcob + 1.
        
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
            titulo.titdtven - TODAY    column-label "Dias"  
            vcob format "x(20)" column-label "Cobranca" with width 190.
    end.

    
    disp vtotcob label "Total de Clientes para Cobrar"
         vtotger label "Total de Clientes da Selecao"
         with frame ftotcli down side-labels.
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
    each tt-modalidade-selec,
    each titulo use-index titdtven where
        titulo.empcod = wempre.empcod and
        titulo.titnat = no and
        titulo.modcod = tt-modalidade-selec.modcod and
        titulo.titsit = "LIB" and
        titulo.etbcod = estab.etbcod and
        titulo.titdtven >= vdtvenini and
        titulo.titdtven <= vdtvenfim
                    no-lock break by titulo.titdtven:

    find clien where clien.clicod = titulo.clifor no-lock no-error.
    find first btitulo use-index iclicod
            where btitulo.empcod = wempre.empcod and
                             btitulo.titnat = no            and
                             btitulo.modcod = tt-modalidade-selec.modcod and
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
        with width 185 .
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

procedure cli-novo:
    find first tt-clinovo where
               tt-clinovo.clicod = fin.titulo.clifor
               no-error.
    if not avail tt-clinovo
    then do:
        par-paga = 0.
        pag-atraso = no.

        
        
        for each ctitulo where
                 ctitulo.clifor = fin.titulo.clifor 
                 no-lock:
            if ctitulo.titpar = 0 then next.
            if ctitulo.modcod = "DEV" or
                ctitulo.modcod = "BON" or
                ctitulo.modcod = "CHP"
            then next.
 
            if ctitulo.titsit = "LIB"
            then next.

            par-paga = par-paga + 1.
            if par-paga = 31
            then leave.
            if ctitulo.titdtpag > ctitulo.titdtven + 3
            then pag-atraso = yes.   
            
        end.
        find first posicli where posicli.clicod = fin.titulo.clifor
               no-lock no-error.
        if avail posicli
        then par-paga = par-paga + posicli.qtdparpg.
            
        find first credscor where credscor.clicod = fin.titulo.clifor
                        no-lock no-error.
        if avail credscor
        then  par-paga = par-paga + credscor.numpcp.
        
        if par-paga <= 30 and pag-atraso = yes
        then do:   
            create tt-clinovo.
            tt-clinovo.clicod = fin.titulo.clifor.
        end.
    end. 
end procedure.





procedure p-seleciona-modal:
            
{sklcls.i
    &File   = tt-modalidade-padrao
    &help   = "                ENTER=Marca F4=Retorna F8=Marca Tudo"
    &CField = tt-modalidade-padrao.modcod    
    &Ofield = " tt-modalidade-padrao.modcod"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-modalidade-padrao.modcod" 
    &PickFrm = "x(4)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            for each tt-modalidade-padrao no-lock:
                a-seelst = a-seelst + "","" + tt-modalidade-padrao.modcod.
                v-cont = v-cont + 1.
            end.
            message ""                         SELECIONADAS "" 
            V-CONT ""FILIAIS                                   ""
            .
                         a-seeid = -1.
            a-recid = -1.
            next keys-loop.
        end. "
    &Form = " frame f-nome" 
}. 

hide frame f-nome.
v-cont = 2.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = entry(v-cont,a-seelst).

    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = v-cod.
end.


end.





