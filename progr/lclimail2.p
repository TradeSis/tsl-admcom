{admcab.i}


def var vacao-i as int format ">>>>>>9".
def var vacao-f as int format ">>>>>>9".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

def var vetbcod_aux as char.
def var varquivo  as   char.
def var vetbcod   like estab.etbcod.

def var vr as log.
def var vn as log.
def var at-pla as log.
def var at-tit as log.
def var rc-pla as log.
def var rc-tit as log.
def var in-pla as log.
def var vachou as log.
def var vativos-pla as int.
def buffer bplani for plani.
def buffer btitulo for titulo.

def var vinativos as   integer.
def var vativos   as   integer.
def var vtotal    as   integer.
def var vemails   as   integer.

def temp-table tt-cli
    field etbcod       like estab.etbcod
    field etbnom       like estab.etbnom
    field clicod       as int
    field clinom       as char
    field inativos     as log initial no
    field ativos       as log initial no
    field ativos-pla   as log initial no
    field novos        as log initial no
    field novos1       as log initial no
    field recuperados  as log initial no
    field tem-email    as log initial no
    field email        as char. 

def temp-table tt-cli-total
    field etbcod       like estab.etbcod
    field qtd-geral    as int
    field qtd-emails   as int
    field inativos     as int
    field ativos       as int
    field ativos-pla   as int
    field novos        as int
    field novos1       as int
    field recuperados  as int.
    
def var vnovos as int.
def var vnovos1 as int.
def var vrecuperados as int.

def buffer bf-estab for estab.

update vacao-i label "Acao Inicial"
       vacao-f label "Acao Final"
       with frame f-dados width 80 side-labels.

update vdti at 1 label " Periodo de"
       vdtf label "Ate"
       with frame f-dados.

def var vdt-aux as date.
vdt-aux = vdti - 360.

sresp = no.
message "Gerar a listagem sintetica de emails?" update sresp.
if not sresp then leave.


if vacao-i = 0 and vacao-f = 0
then do:

    for each clien where clien.clicod > 9 no-lock.
    
        if clien.clinom = "" or
           clien.clinom = ?
        then next.   
        assign vetbcod = 0.
        if clien.dtcad > vdtf then next.
        vtotal = vtotal + 1.
        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
        /**
        if avail cpclien and
                (cpclien.tememail = no or
                 cpclien.emailpromocional = no)
        then next. 
        **/
        
        vachou = no.
        vr = no.
        vn = no.
        at-tit = no.
        at-pla = no.
        rc-pla = no.
        rc-tit = no.
        find first titulo use-index iclicod
                          where titulo.clifor = clien.clicod
                            and titulo.modcod = "CRE"
                            and titulo.titsit = "LIB" 
                            and titulo.titdtemi < vdti 
                            no-lock no-error.
        if avail titulo
        then assign
                vetbcod = titulo.etbcod
                at-tit = yes.

        find first plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= vdt-aux 
                              and plani.pladat < vdti 
                              no-lock no-error.
        if avail plani
        then assign
                vetbcod = plani.etbcod
                at-pla = yes.

        if at-pla = no and
           at-tit = no
        then do:   
            find first bplani use-index plasai
                            where bplani.movtdc = 5
                              and bplani.desti  = clien.clicod 
                              and bplani.pladat >= vdti 
                              and bplani.pladat <= vdtf 
                              no-lock no-error.
            if avail bplani
            then do:
                vetbcod = bplani.etbcod.
                find first btitulo use-index iclicod
                          where btitulo.clifor = clien.clicod
                            and btitulo.titnat = no
                            and btitulo.titsit = "LIB" 
                            and btitulo.titdtemi >= vdti 
                            and btitulo.titdtemi <= vdtf
                            and btitulo.tpcontrato = "" /*btitulo.titpar < 30*/
                            no-lock no-error.
                if avail btitulo
                then assign
                         vetbcod = btitulo.etbcod   
                         rc-tit = yes.
                else rc-pla = yes.
            end.
        end.
        in-pla = no.    
        find last plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat < vdt-aux
                              no-lock no-error.
         if avail plani
        then do:
            if vetbcod = 0
            then vetbcod = plani.etbcod.
            in-pla = yes.
        end.    

        if vetbcod = 0
        then do:
            find first bf-estab where
                   bf-estab.etbcod = int(clien.refcinfo[5]) no-lock no-error.
            if avail bf-estab
            then do:           
                if clien.refcinfo[5] <> ""
                then vetbcod = int(clien.refcinfo[5]).
            end.
        end.

         vetbcod_aux = string(vetbcod).
         if vetbcod = 0
                 then do:
                             vetbcod_aux = string(clien.clicod).
                                         if length(vetbcod_aux) = 10
                                                     then vetbcod_aux = substring(vetbcod_aux,2,3).
            else vetbcod_aux = substr(vetbcod_aux,length(vetbcod_aux) - 1,2).
                    end.
                    
        vetbcod = int(vetbcod_aux).
        find tt-cli-total where tt-cli-total.etbcod = vetbcod no-error.
        if not avail tt-cli-total
        then do:
            create tt-cli-total.
            assign tt-cli-total.etbcod = vetbcod.
        end.

        create tt-cli.

        if at-pla = no and
           at-tit = no
        then do:
            if in-pla = yes
            then do:
                if rc-pla = yes or rc-tit = yes
                then assign
                        tt-cli-total.recuperados = tt-cli-total.recuperados + 1
                        tt-cli.recuperados = yes.
                else do:
                    if vachou = no then
                    assign
                        tt-cli-total.inativos = tt-cli-total.inativos + 1
                        tt-cli.inativos = yes
                        vachou = yes.
                end.        
            end.
            else do:
                if rc-pla = yes or rc-tit = yes
                then assign
                    vnovos = vnovos + 1
                    tt-cli-total.novos = tt-cli-total.novos + 1
                    tt-cli.novos = yes.
                else if clien.dtcad >= vdti and
                       clien.dtcad <= vdtf
                then assign
                            vnovos1 = vnovos1 + 1
                            tt-cli-total.novos1 = tt-cli-total.novos1 + 1
                            tt-cli.novos1 = yes.
                else if vachou = no 
                then assign tt-cli-total.inativos = tt-cli-total.inativos + 1
                            tt-cli.inativos = yes
                           vachou = yes.
            end.
        end.
        else do:
            if at-pla = yes
            then do:
                if vachou = no then
                assign
                    tt-cli-total.ativos-pla = tt-cli-total.ativos-pla + 1
                    tt-cli.ativos-pla = yes
                    vachou = yes.
            end.        
            else if at-tit = yes
                then do:
                 if vachou = no then
                  assign
                        tt-cli-total.ativos = tt-cli-total.ativos + 1
                        tt-cli.ativos = yes
                        vachou = yes.
                end.        
        end.
        
        if clien.zona matches "*@*"
        then assign 
                tt-cli-total.qtd-emails = tt-cli-total.qtd-emails + 1
                tt-cli.tem-email = yes
                tt-cli.email = clien.zona.
    
        tt-cli-total.qtd-geral = tt-cli-total.qtd-geral + 1.
        
        if vtotal mod 1000 = 0
        then 
        
        disp vtotal format ">>>>>>>>" label "Total" 
                with frame fxx centered side-labels 1 down. pause 0.
        
        if tt-cli.inativos = yes  
            or tt-cli.ativos = yes    
            or tt-cli.ativos-pla = yes
            or tt-cli.novos = yes     
            or tt-cli.novos1 = yes    
            or tt-cli.recuperados = yes
            or tt-cli.tem-email = yes
        then assign        
                tt-cli.etbcod = vetbcod      
                tt-cli.clicod = clien.clicod    
                tt-cli.clinom = clien.clinom.
        else delete tt-cli.         
                
    end.

    hide frame fxx no-pause.
end.
/* com acao */
else do:    
    
    for each acao-cli where acao-cli.acaocod >= vacao-i
                        and acao-cli.acaocod <= vacao-f no-lock:

        assign vetbcod = 0.
        
        find clien where clien.clicod = acao-cli.clicod no-lock no-error.
        if clien.clinom = "" or
           clien.clinom = ?
        then next.   
        if clien.dtcad > vdtf then next.
        vtotal = vtotal + 1.
        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
        /*
        if avail cpclien and
                (cpclien.tememail = no or
                 cpclien.emailpromocional = no)
        then next. 
        */
        vachou = no.
        vr = no.
        vn = no.
        at-tit = no.
        at-pla = no.
        rc-pla = no.
        rc-tit = no.
        find first titulo use-index iclicod
                          where titulo.clifor = clien.clicod
                            and titulo.modcod = "CRE"
                            and titulo.titsit = "LIB" 
                            and titulo.titdtemi < vdti 
                            no-lock no-error.
        if avail titulo
        then assign
                vetbcod = titulo.etbcod
                at-tit = yes.
        find first plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= vdt-aux 
                              and plani.pladat < vdti 
                              no-lock no-error.
        if avail plani
        then assign
                vetbcod = plani.etbcod
                at-pla = yes.
        if at-pla = no and
           at-tit = no
        then do:   
            find first bplani use-index plasai
                            where bplani.movtdc = 5
                              and bplani.desti  = clien.clicod 
                              and bplani.pladat >= vdti 
                              and bplani.pladat <= vdtf 
                              no-lock no-error.
            if avail bplani
            then do:
                vetbcod = bplani.etbcod.
                find first btitulo use-index iclicod
                          where btitulo.clifor = clien.clicod
                            and btitulo.titnat = no
                            and btitulo.titsit = "LIB" 
                            and btitulo.titdtemi >= vdti 
                            and btitulo.titdtemi <= vdtf
                            and btitulo.tpcontrato = "" /*btitulo.titpar < 30*/
                            no-lock no-error.
                if avail btitulo
                then assign
                         vetbcod = btitulo.etbcod   
                         rc-tit = yes.
                else rc-pla = yes.
            end.
        end.
        in-pla = no.    
        find last plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat < vdt-aux
                              no-lock no-error.
        if avail plani
        then do:
            if vetbcod = 0
            then vetbcod = plani.etbcod.
            in-pla = yes.
        end.    

        if vetbcod = 0
        then do:
            find first bf-estab where
                   bf-estab.etbcod = int(clien.refcinfo[5]) no-lock no-error.
            if avail bf-estab
            then do:           
                if clien.refcinfo[5] <> ""
                then vetbcod = int(clien.refcinfo[5]).
            end.
        end.
        
        vetbcod_aux = string(vetbcod).
        if vetbcod = 0
        then do:
            vetbcod_aux = string(clien.clicod).
            if length(vetbcod_aux) >= 10
            then vetbcod = int(substring(vetbcod_aux,2,3)).
            else 
            vetbcod = int(substring(vetbcod_aux,(length(vetbcod_aux) - 1), 2)).
        end.
        
        find tt-cli-total where tt-cli-total.etbcod = vetbcod no-error.
        if not avail tt-cli-total
        then do:
            create tt-cli-total.
            assign tt-cli-total.etbcod = vetbcod.
        end.
        
        create tt-cli.
       
        if at-pla = no and
           at-tit = no
        then do:
            if in-pla = yes
            then do:
                if rc-pla = yes or rc-tit = yes
                then assign
                        tt-cli-total.recuperados = tt-cli-total.recuperados + 1
                        tt-cli.recuperados = yes.
                else do:
                if vachou = no then
                assign
                        tt-cli-total.inativos = tt-cli-total.inativos + 1
                        tt-cli.inativos = yes
                        vachou = yes.
                end.        
            end.
            else do:
                if rc-pla = yes or rc-tit = yes
                then assign
                    vnovos = vnovos + 1
                    tt-cli-total.novos = tt-cli-total.novos + 1
                    tt-cli.novos = yes .
                else if clien.dtcad >= vdti and
                       clien.dtcad <= vdtf
                then assign
                            vnovos1 = vnovos1 + 1
                            tt-cli-total.novos1 = tt-cli-total.novos1 + 1
                            tt-cli.novos1 = yes.
                else  if vachou = no 
                then  assign
                     tt-cli-total.inativos = tt-cli-total.inativos + 1
                     tt-cli.inativos = yes
                     vachou = yes.
            end.                       
        end.
        else do:
            if at-pla = yes
            then do:
             if vachou = no then
             assign
                    tt-cli-total.ativos-pla = tt-cli-total.ativos-pla + 1
                    tt-cli.ativos-pla = yes
                    vachou = yes.
            end.        
            else if at-tit = yes
                then do:
                if vachou = no then 
                assign
                        tt-cli-total.ativos = tt-cli-total.ativos + 1
                        tt-cli.ativos = yes
                        vachou = yes.
                end.        
        end.
        
        if clien.zona matches "*@*"
        then assign 
                tt-cli-total.qtd-emails = tt-cli-total.qtd-emails + 1
                tt-cli.tem-email = yes
                tt-cli.email = clien.zona.
    
    
        tt-cli-total.qtd-geral = tt-cli-total.qtd-geral + 1.
        
        if vtotal mod 1000 = 0
        then 
        
        disp vtotal format ">>>>>>>>" label "Total" 
                with frame fxx2 centered side-labels 1 down. pause 0.
    
        if tt-cli.inativos = yes
            or tt-cli.ativos = yes
            or tt-cli.ativos-pla = yes
            or tt-cli.novos = yes
            or tt-cli.novos1 = yes
            or tt-cli.recuperados = yes
            or tt-cli.tem-email = yes
        then assign
                tt-cli.etbcod = vetbcod
                tt-cli.clicod = clien.clicod
                tt-cli.clinom = clien.clinom.
        else delete tt-cli.
                        
                
    end.

    hide frame fxx2 no-pause.


end.

run p-listagem-total.

run p-listagem-clientes.

procedure p-listagem-clientes:

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lclimail.1." + string(time).
    else varquivo = "l:\relat\lclimail.1." + string(time).
    

    /************************* Inativos ***************************/
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = "".""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ LISTAGEM DE CLIENTES """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    display "------------------- CLIENTES INATIVOS -----------------" SKIP
                    with frame f01.

    for each tt-cli where tt-cli.inativos no-lock by tt-cli.etbcod.
    
        display tt-cli.etbcod format ">>>9" column-label "Filial"
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"
                tt-cli.clinom format "x(50)"     column-label "Nome"
                skip.                    
    
    end.

    display SKIP(3)
            "--------------------CLIENTES ATIVOS COMPRA ----------------" SKIP
                    with frame f02.

    for each tt-cli where tt-cli.ativos-pla no-lock by tt-cli.etbcod.
    
        display tt-cli.etbcod format ">>>9" column-label "Filial" 
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"
                tt-cli.clinom format "x(50)"     column-label "Nome"
                skip.                    
    
    end.
     
    display SKIP(3)                                                                        "--------------------CLIENTES ATIVOS CONTRATO ----------------" SKIP
                    with frame f03.
                                                                                    for each tt-cli where tt-cli.ativos no-lock by tt-cli.etbcod.                                                                                                      display tt-cli.etbcod format ">>>9" column-label "Filial" 
                 tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"
                 tt-cli.clinom format "x(50)"     column-label "Nome"           
                skip.                                                          
               
    end.                                                                       
    
    display SKIP(3)                                                            
          "--------------------CLIENTES RECUPERADOS ----------------" SKIP
                    with frame f04.
                                                                               
    for each tt-cli where tt-cli.recuperados no-lock by tt-cli.etbcod.                 
        display tt-cli.etbcod format ">>>9" column-label "Filial" 
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"      
                tt-cli.clinom format "x(50)"    column-label "Nome"           
                  skip.                                                           
    end.                                                                       

    
    display SKIP(3)                                                            
          "--------------------CLIENTES NOVOS COMPRA ----------------" SKIP
                    with frame f05
                    .
                                                                               
    for each tt-cli where tt-cli.novos no-lock by tt-cli.etbcod.
      
        display tt-cli.etbcod format ">>>9" column-label "Filial" 
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"      
                tt-cli.clinom format "x(50)"    column-label "Nome"           
                  skip.                                                           
    end.                                                                       
    
    
    display SKIP(3)                                                            
          "--------------------CLIENTES NOVOS CADASTRO ----------------" SKIP
                    with frame f06
                    .
                                                                               
    for each tt-cli where tt-cli.novos1 no-lock by tt-cli.etbcod.                    
        display tt-cli.etbcod format ">>>9" column-label "Filial" 
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"      
                tt-cli.clinom format "x(50)"    column-label "Nome"           
                  skip.                                                            end.                                                                       

    
    
    display SKIP(3)                                                            
          "--------------------CLIENTES COM E-MAIL ----------------" SKIP
                    with frame f07
                    .
                                                                               
    for each tt-cli where tt-cli.tem-email no-lock by tt-cli.etbcod.                   
        display tt-cli.etbcod format ">>>9" column-label "Filial" 
                tt-cli.clicod format ">>>>>>>>>>>>>>9" column-label "Cod"      
                tt-cli.clinom format "x(50)"    column-label "Nome"
                tt-cli.email  format "x(40)"    column-label "E-Mail"       
                  skip with frame f-email width 120 down.                          
    end.                                                                       
     
    

     
    

    output close.
 
    
    
    
    if opsys = "UNIX"
    then run visurel.p (input varquivo,
                        input "").
    else do:
        {mrod.i}
    end.
    
end procedure.

procedure p-listagem-total:   

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lclimail.2." + string(time).
    else varquivo = "l:\relat\lclimail.2." + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "80"
        &Page-Line = "0"
        &Nom-Rel   = "".""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ LISTAGEM DE CLIENTES """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

        if vacao-i = 0 and vacao-f = 0
        then.
        else                
        disp skip(1)
             "Acao Inicial.....:" space(4) vacao-i skip
             "Acao Final.......:" space(4) vacao-f skip
             with frame f-ac width 80 no-box no-labels.
        
        assign
            vtotal = 0 vinativos = 0 vativos-pla = 0 vativos = 0
                vrecuperados = 0 vnovos = 0 vnovos1 = 0 vemails = 0.
        for each tt-cli-total where tt-cli-total.etbcod <> 0 no-lock break by tt-cli-total.etbcod.
            assign 
                vinativos = vinativos + tt-cli-total.inativos
                vativos-pla = vativos-pla + tt-cli-total.ativos-pla
                vativos = vativos + tt-cli-total.ativos
                vrecuperados = vrecuperados + tt-cli-total.recuperados
                vnovos   = vnovos + tt-cli-total.novos
                vnovos1 = vnovos1 + tt-cli-total.novos1
                vemails = vemails + tt-cli-total.qtd-emails.
        end.
        
        vtotal = vtotal + vinativos + vativos-pla + vativos
            + vrecuperados + vnovos + vnovos1.
            
        disp skip (1)
            "Total de Clientes..........:" vtotal    skip
            "Clientes Inativos..........:" vinativos skip
            "Clientes Ativos Compra.....:" vativos-pla   skip
            "Clientes Ativos Contrato...:" vativos   skip
            "Clientes Recuperados.......:" vrecuperados skip
            "Clientes Novos Compra......:" vnovos    skip
            "Clientes Novos Cadastro....:" vnovos1 skip
            "Clientes com email.........:" vemails   skip
            skip (1)
            with width 80 no-box no-labels.
    
        put fill("-",80) format "x(80)".
    
        for each tt-cli-total where tt-cli-total.etbcod <> 0 no-lock break by tt-cli-total.etbcod.
            find estab where estab.etbcod = tt-cli-total.etbcod no-lock no-error.
            
            disp tt-cli-total.etbcod     column-label "Cod."
                 estab.etbnom when avail estab
                 tt-cli-total.inativos    column-label "Inativos" (total)
                 tt-cli-total.ativos-pla column-label "Ativos!Compra" (total)
                 tt-cli-total.ativos  column-label "Ativos!Contrato" (total)
                 tt-cli-total.recuperados column-label "Recuperados" (total)
                 tt-cli-total.novos      column-label "Novos!Compra"   (total)
                 tt-cli-total.novos1     column-label "Novos!Cadastro" (total)
                 tt-cli-total.qtd-emails column-label "Com email" (total)
                 with centered width 130.
             
        end.
    put "======== LEGENDA ==============" SKIP
        "Total de Clientes = cadastrados ate a data final informada"
         skip
        "Clientes Inativos = nao possuem titulos em aberto e nao compram a mais de 1 anos" skip
        "Clientes ativos compra = que compraram no ultimo ano" skip
        "Clientes ativos contrato = que possuem contrato em aberto" skip
        "Clentes recuperados = nao compravam a mais de um ano e nao possuiam contrato em aberto e voltaram a comprar no periodo" skip
        "Clientes novos compra = cadastrados no periodo e compraram" skip
        "Clientes novos cadastro = cadastrados no periodo e nao compraram" skip
        "Clientes com email = com email cadatrado" skip
        .
        
    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo,
                        input "").
    else do:
        {mrod.i}
    end.        
    
end procedure.    
