/* Alterado por Lucas Leote em Fev/2017 para incluir a coluna Celular */

{admcab.i}

def var ii as int.
def var vtsint as logical format "Sim/Nao".
def var vvt1 as int init 0 format ">>>>9".
def var vvt2 as int init 0 format ">>>>9".
def var vvt3 like titulo.titvlcob init 0 format "->>>,>>>,>>9.99".

def var vindex as int.
def buffer bstitulo for titulo.
def buffer bestab   for estab.

def var vcelular as char.
def temp-table tt-cel
    field celular as char
    field nome as char
    index i1 celular.

def temp-table tt-clinovo
    field clicod like clien.clicod
    index i1 clicod.
    
def var par-paga as int.
def var pag-atraso as log.
def buffer ctitulo for fin.titulo.
def var vclinovos as log format "Sim/Nao".

def new shared temp-table tt-extrato 
    field rec as recid
    field ord as int
        index ind-1 ord.
def var vcre as log format "Geral/Facil" initial yes.

def temp-table tt-sint-cob-cli
    field clicod like clien.clicod.

def temp-table tt-cli
    field clicod like clien.clicod
    field clinom like clien.clinom
    index ind-1 clinom.

def temp-table tt-sint-cob
    field etbcod like estab.etbcod
    field cobcod like titulo.cobcod
    field qtdcli as int
    field qtdpar as int
    field vlrpar like titulo.titvlcob
    index ind-1 etbcod
                cobcod.

def var vlmax like titulo.titvlcob.

def var vdtvenini as date format "99/99/9999".
def var vdtvenfim as date format "99/99/9999".
def var vsubtot  like titulo.titvlcob.
def var vetbcod  like estab.etbcod.
def var vetbcod1 like estab.etbcod.
def var vcont-cli  as char format "x(15)" extent 3
      initial ["  Alfabetica  ","  Vencimento  ","  Valor  "].

def var vtprel-cli  as char format "x(15)" extent 2
      initial ["  Analitico  ","  Sintetico  "].

def var valfa    as log.
def var varquivo as char.

def var v-consulta-parcelas-LP as logical format "Sim/Nao" initial no.
def var v-parcela-lp as log.

def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.

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
                tt-cel.nome = vnome.
            end.
        end.
    end.                            
end procedure.

def var varqsai as char.

def temp-table tt-titulo like titulo.

def temp-table tt-cliq
    field clicod like clien.clicod
    field ano as int
    field mes as int
    index i1 clicod.

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
    
    for each tt-cli.
        delete tt-cli.
    end.
    
    update vetbcod colon 25 vetbcod1 label 'até' with frame f2.
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
    display  skip estab.etbnom  no-label at 22 ' - ' bestab.etbnom no-label with frame f2.
    update vdtvenini label "Vencimento Inicial" colon 25
           vdtvenfim label "Final"
                with row 4 side-labels width 80 
                 frame f2.

    vlmax = 0.
    update vcre label "Cliente" colon 25 
           vlmax label "Maior Parcela" with side-label
           frame f2.
    
    update v-consulta-parcelas-LP label "Considerar apenas LP"
     help "'Sim' = Parcelas acima de 51 / 'Nao' = Parcelas abaixo de 51"
       colon 25 with side-label
                  frame f2.
    
    update v-feirao-nome-limpo label "Considerar apenas feirao"
        colon 25 with side-label frame f2.
        
    disp vtprel-cli no-label with frame f11 
                    centered title " Tipo Relatorio ".
    choose field vtprel-cli with frame f11.
    if frame-index = 2
    then vtsint = yes.
    else vtsint = no.
    vindex = 0.
    if vtsint = no
    then do:
        disp vcont-cli no-label with frame f1 centered title " Ordenacao ".
        choose field vcont-cli with frame f1.
        if frame-index = 1
        then valfa = yes.
        else valfa = no.
        vindex = frame-index.
    end.
    else valfa = no.
        
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

    assign
        qtd-cli = 0
        qtd-par = 0
        val-cob = 0
        tqtd-cli = 0
        tqtd-par = 0
        tval-cob = 0
        .
         
    for each tt-cel: delete tt-cel. end. 
    for each tt-sint-cob : delete tt-sint-cob. end.
    for each tt-sint-cob-cli : delete tt-sint-cob-cli. end.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/posicli" + string(time) + ".txt".
    else varquivo = "l:\relat\posicli" + string(time) + ".txt".
    output to value(varquivo) page-size 62.
    PUT UNFORMATTED CHR(15)  .
    vsubtot = 0.
    PAGE.
    if valfa
    then do:
        if vcre 
        then do:
            for each estab where 
                     estab.etbcod >= vetbcod
                 and estab.etbcod <= vetbcod1
                     no-lock,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax no-lock,
                each clien where clien.clicod = titulo.clifor no-lock
                                                    break by clien.clinom
                                                          by titulo.titdtven.
                {filtro-feiraonl.i}
                
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
            
            /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
              */

                      if fin.titulo.tpcontrato = "L"      
                              then assign v-parcela-lp = yes.     
                                      else assign v-parcela-lp = no.      
                


                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
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
                        with frame fcab no-label page-top no-box width 200.
                view frame fcab.
                 vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
                
                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                 /*                      
                 display
                    titulo.etbcod    column-label "Fil."         
                    clien.clinom     column-label "Nome do Cliente"                                
                    clien.clicod     column-label "Cod."            
                    /*clien.ciccgc     column-label "CPF"*/
                    titulo.titnum      column-label "Contr."
                    titulo.titpar      column-label "Pr."   
                    titulo.titdtemi    column-label "Dt.Venda" 
                    titulo.titdtven    column-label "Vencim."  
                    titulo.titvlcob    column-label "Valor Prestacao"
                    titulo.titdtven - TODAY    column-label "Dias"
                                with width 180 .
                **/
                    run val-celular.
                end.
            end.
        end.
        else do:
            
            for each estab where
                     estab.etbcod >= vetbcod
                 and estab.etbcod <= vetbcod1 
                     no-lock,
                each tt-cli use-index ind-1,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.clifor = tt-cli.clicod and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax no-lock
                                                        by titulo.titdtven:
                {filtro-feiraonl.i}

                find clien where clien.clicod = tt-cli.clicod no-lock.
                
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


                /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                */

               if fin.titulo.tpcontrato = "L"      
                              then assign v-parcela-lp = yes.     
                                      else assign v-parcela-lp = no.

                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                
                form header
                    wempre.emprazsoc
                        space(6) "POCLI"   at 117
                        "Pag.: " at 128 page-number format ">>9" skip
                        "POSICAO GERAL P/FILIAL-CLIENTE- COM PARCELA ACIMA DE "
                        vlmax
                        " Periodo" vdtvenini " A " vdtvenfim
                        today format "99/99/9999" at 117
                        string(time,"hh:mm:ss") at 130
                        skip fill("-",137) format "x(137)" skip
                        with frame fcab1 no-label page-top no-box width 200.
                view frame fcab1.
                vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
                
                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:                       
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    /*
                display
                   titulo.etbcod     column-label "Fil." 
                   tt-cli.clinom      column-label "Nome do Cliente"                                
                   tt-cli.clicod      column-label "Cod." 
                   /*clien.ciccgc       column-label "CPF"*/ 
                    titulo.titnum      column-label "Contr." 
                    titulo.titpar      column-label "Pr."    
                    titulo.titdtemi    column-label "Dt.Venda"
                    titulo.titdtven    column-label "Vencim."    
                    titulo.titvlcob    column-label "Valor Prestacao"
                    titulo.titdtven - TODAY    column-label "Dias"
                                with width 200.
                    */
                    
                    run val-celular.
                end.
            end.
        end.
    end.    
    else if vindex = 2
    then do:
        if vcre 
        then do:
            for each estab where
                     estab.etbcod >= vetbcod
                 and estab.etbcod <= vetbcod1 
                     no-lock,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax
                                            no-lock break by titulo.titdtven:

                {filtro-feiraonl.i}

                find clien where clien.clicod = titulo.clifor no-lock no-error.

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
                        /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                        */
                        
                                if fin.titulo.tpcontrato = "L"      
                                        then assign v-parcela-lp = yes.     
                                     else assign v-parcela-lp = no.      



                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.
                
                form header
                    wempre.emprazsoc
                    space(6) "POCLI"   at 117
                    "Pag.: " at 128 page-number format ">>9" skip
                    "POSICAO GERAL P/FILIAL-CLIENTE- COM PARCELA ACIMA DE "
                    vlmax
                    " Periodo" vdtvenini " A " vdtvenfim
                    today format "99/99/9999" at 117
                    string(time,"hh:mm:ss") at 130
                    skip fill("-",137) format "x(137)" skip
                    with frame fcabb no-label page-top no-box width 200.
                view frame fcabb.
                vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.

                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    /*
                display
                    titulo.etbcod      column-label "Fil."         
                    clien.clinom when avail clien
                                    column-label "Nome do Cliente" 
                    titulo.clifor      column-label "Cod."         
                    /*clien.ciccgc  column-label "CPF"*/
                    titulo.titnum      column-label "Contr."       
                    titulo.titpar      column-label "Pr."                                            titulo.titdtemi    column-label "Dt.Venda"   
                    titulo.titdtven    column-label "Vencim."   
                    titulo.titvlcob    column-label "Valor Prestacao" 
                    titulo.titdtven - TODAY    column-label "Dias"
                                                    with width 200.
                    */
                    
                    run val-celular.
                end.
            end.
        end.
        else do:
            for each estab where
                      estab.etbcod >= vetbcod
                  and estab.etbcod <= vetbcod1
                      no-lock,
                each tt-cli,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.clifor = tt-cli.clicod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax
                                            no-lock break by titulo.titdtven:
                
                find clien where clien.clicod = tt-cli.clicod no-lock.

                {filtro-feiraonl.i}

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

             /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                */
                
                        if fin.titulo.tpcontrato = "L"      
                                then assign v-parcela-lp = yes.     
                                        else assign v-parcela-lp = no.      



                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
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
                    with frame fcabb1 no-label page-top no-box width 200.
                view frame fcabb1.
                vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
                
                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    /*
                 display
                    titulo.etbcod  column-label "Fil."  
                    tt-cli.clinom when avail clien
                                       column-label "Nome do Cliente" 
                    titulo.clifor      column-label "Cod."  
                    /*clien.ciccgc   column-label "CPF"*/       
                    titulo.titnum      column-label "Contr."      
                    titulo.titpar      column-label "Pr."         
                    titulo.titdtemi    column-label "Dt.Venda"   
                    titulo.titdtven    column-label "Vencim."    
                    titulo.titvlcob    column-label "Valor Prestacao" 
                    titulo.titdtven - TODAY    column-label "Dias"
                                                    with width 200.
                    */
                    
                    run val-celular.
                end.
            end.

        
        end.
    end.
    else if vindex = 3
    then do:
        if vcre 
        then do:
            for each estab where 
                     estab.etbcod >= vetbcod
                 and estab.etbcod <= vetbcod1
                     no-lock,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax no-lock,
                each clien where clien.clicod = titulo.clifor no-lock
                                    by titulo.titvlcob descending
                                                          .
                {filtro-feiraonl.i}

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
                                 /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                                   */
                                   
                   if fin.titulo.tpcontrato = "L"      
                  then assign v-parcela-lp = yes.     
        else assign v-parcela-lp = no.      
                                   
                                   
                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
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
                        with frame fcabc no-label page-top no-box width 200.
                view frame fcab.
                 vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
                
                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                 /*                      
                 display
                    titulo.etbcod    column-label "Fil."         
                    clien.clinom     column-label "Nome do Cliente"                                clien.clicod     column-label "Cod."            
                    /*clien.ciccgc     column-label "CPF"*/
                    titulo.titnum      column-label "Contr."
                    titulo.titpar      column-label "Pr."   
                    titulo.titdtemi    column-label "Dt.Venda" 
                    titulo.titdtven    column-label "Vencim."  
                    titulo.titvlcob    column-label "Valor Prestacao"
                    titulo.titdtven - TODAY    column-label "Dias"
                                with width 180 .
                **/
                    run val-celular.
                end.
            end.
        end.
        else do:
            
            for each estab where
                     estab.etbcod >= vetbcod
                 and estab.etbcod <= vetbcod1 
                     no-lock,
                each tt-cli use-index ind-1,
                each titulo use-index titdtven where
                                      titulo.empcod = wempre.empcod and
                                      titulo.titnat = no and
                                      titulo.modcod = "CRE" and
                                      titulo.titsit = "LIB" and
                                      titulo.clifor = tt-cli.clicod and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdtvenini and
                                      titulo.titdtven <= vdtvenfim and
                                      titulo.titvlcob >= vlmax no-lock
                                      by titulo.titvlcob descending:

                find clien where clien.clicod = tt-cli.clicod no-lock.

                {filtro-feiraonl.i}

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

                    /*
                if (fin.titulo.titpar = 0 or fin.titulo.titpar >= 51)
                    and acha("RENOVACAO",fin.titulo.titobs[1]) = "SIM"
                then assign v-parcela-lp = yes.
                else assign v-parcela-lp = no.
                      */
                      
                       if fin.titulo.tpcontrato = "L"      
                                      then assign v-parcela-lp = yes.     
                                              else assign v-parcela-lp = no.      
  
                      
                      
                if v-consulta-parcelas-LP = no
                    and v-parcela-lp = yes
                then next.
                                       
                if v-consulta-parcelas-LP = yes
                    and v-parcela-lp = no
                then next.

                
                form header
                    wempre.emprazsoc
                        space(6) "POCLI"   at 117
                        "Pag.: " at 128 page-number format ">>9" skip
                        "POSICAO GERAL P/FILIAL-CLIENTE- COM PARCELA ACIMA DE "
                        vlmax
                        " Periodo" vdtvenini " A " vdtvenfim
                        today format "99/99/9999" at 117
                        string(time,"hh:mm:ss") at 130
                        skip fill("-",137) format "x(137)" skip
                        with frame fcab2 no-label page-top no-box width 200.
                view frame fcab1.
                vsubtot = vsubtot + titulo.titvlcob.
                
                find first tt-extrato where tt-extrato.rec = recid(clien)
                                        no-error.
                if not avail tt-extrato
                then do:
                    ii = ii + 1.
                    create tt-extrato.
                    assign tt-extrato.rec = recid(clien)
                           tt-extrato.ord = ii.
                end.
                
                if vtsint = yes 
                then run Pi-Grava-Sint ( input recid(titulo), titulo.etbcod).
                else do:                       
                    create tt-titulo.
                    buffer-copy titulo to tt-titulo.
                    /*
                display
                   titulo.etbcod     column-label "Fil." 
                   tt-cli.clinom      column-label "Nome do Cliente"                              tt-cli.clicod      column-label "Cod." 
                   /*clien.ciccgc       column-label "CPF"*/ 
                    titulo.titnum      column-label "Contr." 
                    titulo.titpar      column-label "Pr."    
                    titulo.titdtemi    column-label "Dt.Venda"
                    titulo.titdtven    column-label "Vencim."    
                    titulo.titvlcob    column-label "Valor Prestacao"
                    titulo.titdtven - TODAY    column-label "Dias"
                                with width 200.
                    */
                    
                    run val-celular.
                end.
            end.
        end.
    end.
    
    if vtsint = no
    then do: 
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
                    clien.ciccgc  column-label "CPF" format "x(13)"
                    clien.fax column-label "Celular"
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
    else do:
    
        /* Sintetico */
        assign vvt1 = 0
               vvt2 = 0
               vvt3 = 0.
        form header
                    wempre.emprazsoc
                        space(6) "POCLI"   at 65
                        "Pag.: " at 70 page-number format ">>9" skip
                        "POSICAO FINANCEIRA SINT.GERAL - FILIAL" 
                        string(estab.etbcod,"999")
                        " Periodo" vdtvenini " A " vdtvenfim
                        today format "99/99/9999" at 70
                        string(time,"hh:mm:ss") at 70
                        skip fill("-",90) format "x(90)" skip
                        with frame fcabs no-label page-top 
                                no-box width 90.
        view frame fcabs.
        for each tt-sint-cob break by tt-sint-cob.etbcod
                                   by tt-sint-cob.cobcod :
            find first cobra where cobra.cobcod = tt-sint-cob.cobcod
                    no-lock no-error.
            disp tt-sint-cob.etbcod column-label "Filial"
                 when first-of(tt-sint-cob.etbcod)
                 tt-sint-cob.cobcod cobra.cobnom 
                 tt-sint-cob.qtdcli  column-label "Qtd.Clientes"    
                 tt-sint-cob.qtdpar  column-label "Qtd.Parcelas"
                 tt-sint-cob.vlrpar  column-label "Vlr.Parcelas"  
                 with frame f-resumo down no-box.
                 down with frame f-resumo width 80.  
            assign  vvt1 = vvt1 + tt-sint-cob.qtdcli
                    vvt2 = vvt2 + tt-sint-cob.qtdpar 
                    vvt3 = vvt3 + tt-sint-cob.vlrpar. 
        end.
        put skip(1).
        disp "      "  @ tt-sint-cob.etbcod
             "   "  @ tt-sint-cob.cobcod 
             "Total Geral -> " @ cobra.cobnom
             space(3)
             vvt1 @ tt-sint-cob.qtdcli
             space(3)
             vvt2 @ tt-sint-cob.qtdpar
             Space(1)
             vvt3 @ tt-sint-cob.vlrpar
             with frame f-resumot down no-box no-labels width 80.
             down with frame f-resumot.      

        /**/
    end.
    output close.

    
    if opsys = "UNIX"
    then  varqsai = "/admcom/relat/cel" + string(time) + ".txt".
    else  varqsai = "l:~\relat~\cel" + string(time) + ".txt".
    output to value(varqsai) page-size 0.
    for each tt-cel:
        put tt-cel.nome +  ";"  +
            tt-cel.celular format "x(40)" skip.
    end.    
    output close.
    message color red/with
        "Arquivo celulares gerado: "  varqsai 
        view-as alert-box.
        
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
    {mrod.i}
    end.
 
    /*dos silent value("type " + varquivo + "  > prn").*/
    
    message "Deseja imprimir extratos" update sresp.
    if sresp
    then run extrato2.p.
    
end.

Procedure Pi-Grava-Sint.

def input parameter p-recid as recid.
def input parameter p-filial like estab.etbcod.
def var v-ac-cli as int.

find first bstitulo where recid(bstitulo) = p-recid no-lock no-error.

find first tt-sint-cob where tt-sint-cob.etbcod = p-filial and
                             tt-sint-cob.cobcod = bstitulo.cobcod no-error.

find first tt-sint-cob-cli where tt-sint-cob-cli.clicod = bstitulo.clifor
                                no-error.
                                
if not avail tt-sint-cob-cli
then do:
     create tt-sint-cob-cli.
     assign tt-sint-cob-cli.clicod = bstitulo.clifor
           v-ac-cli = 1. 
end.
else assign v-ac-cli = 0.

if not avail tt-sint-cob
then do :
    create tt-sint-cob.
    assign  tt-sint-cob.etbcod = bstitulo.etbcod
            tt-sint-cob.cobcod = bstitulo.cobcod.
end.
assign tt-sint-cob.qtdcli = tt-sint-cob.qtdcli + v-ac-cli
       tt-sint-cob.vlrpar = tt-sint-cob.vlrpar + bstitulo.titvlcob.
       tt-sint-cob.qtdpar = tt-sint-cob.qtdpar + 1.

end procedure. 

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


