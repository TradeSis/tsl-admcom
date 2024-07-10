{admcab.i}

def var vacao-i as int format ">>>>>>9".
def var vacao-f as int format ">>>>>>9".

def var vn as log.

def var varquivo  as   char.
def var vetbcod   like estab.etbcod.

def var vinativos as   integer.
def var vativos   as   integer.
def var vtotal    as   integer.
def var vemails   as   integer.

def temp-table ttfil
    field etbcod       like estab.etbcod
    field qtd-geral    as   int
    field qtd-emails   as   int
    field ativos        as int
    field inativos     as int
    field novos        as int
    field recuperados  as int 
    index i1 etbcod.
    
def var vnovos as int.
def var vrecuperados as int.

def var vr as log.

def temp-table ttcli
    field etbcod  like estab.etbcod
    field clicod  like clien.clicod
    field clinom  like clien.clinom
    field email   like clien.zona
    field celular like clien.fax
    index i1 etbcod clicod 
    index i2 etbcod clinom.

def buffer bf-estab   for estab.

update vacao-i label "Acao Inicial"
       vacao-f label "Acao Final"
       with frame f-dados width 80 side-labels.

/*
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

update vdti at 1 label " Periodo de"
       vdtf label "Ate"
       with frame f-dados.
 */

def buffer bttfil for ttfil.

sresp = no.
message "Gerar a listagem analitica de emails?" update sresp.
if not sresp then leave.

if opsys = "UNIX"
then varquivo = "/admcom/relat/lclmaila.txt".
else varquivo = "l:\relat\lclmaila.txt".

if vacao-i = 0 and vacao-f = 0
then do:
    for each clien no-lock.

        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
        assign vetbcod = 0.

        if avail cpclien and
                (cpclien.tememail = no or
                 cpclien.emailpromocional = no)
        then next. 
        vr = no.
        vn = no.
        /****
        find first titulo use-index iclicod
                          where titulo.clifor = clien.clicod
                            and titulo.titnat = no
                            and titulo.titsit = "LIB" no-lock no-error.
    


        if not avail titulo
        then do:
        
            find last plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
                /*vetbcod = int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2)).*/
            end.                
            else
                vetbcod = plani.etbcod.
                      
        end.
        else
            vetbcod = titulo.etbcod.
        ***/
        find first titulo use-index iclicod
                          where titulo.titnat = no
                            and titulo.clifor = clien.clicod
                            and titulo.titsit = "LIB" 
                            /*and titulo.titdtemi < vdti*/
                            no-lock no-error.
        if not avail titulo
        then do:
            vetbcod = 0.
            find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 
                              /*and plani.pladat < vdti*/
                              no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
                /**
                /*vetbcod = int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2)).*/
                find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              /*and plani.pladat >= vdti 
                              and plani.pladat <= vdtf*/
                              no-lock no-error.
                if avail plani
                then assign
                        vetbcod = plani.etbcod
                        vrecuperados = vrecuperados + 1
                        vr = yes.
                **/
            end.                
            else
                vetbcod = plani.etbcod.
                      
        end.
        else vetbcod = titulo.etbcod.

        if vetbcod > 0 /*and
           clien.dtcad >= vdti and
           clien.dtcad <= vdtf*/
        then do:
            assign
                vnovos = vnovos + 1
                vn = yes.
            if vr = yes
            then assign
                     vrecuperados = vrecuperados - 1
                     vr = no.
        end. 
        find first bf-estab where
                   bf-estab.etbcod = int(clien.refcinfo[5]) no-lock no-error.
        if avail bf-estab
        then do:           
                if clien.refcinfo[5] <> ""
                then vetbcod = int(clien.refcinfo[5]).
        end.

        find ttfil where ttfil.etbcod = vetbcod no-error.
        if not avail ttfil
        then do:
            create ttfil.
            assign ttfil.etbcod = vetbcod.
        end.
       
        if vetbcod = 0
        then do:
            assign
                vinativos = vinativos + 1
                ttfil.inativos = ttfil.inativos + 1.
            if length(string(clien.clicod)) >= 10
            then
            find first bttfil where bttfil.etbcod =
                    int(substring(string(clien.clicod),2,3)) no-error.
            else
            find first bttfil where bttfil.etbcod = 
                    int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2))
                            no-error.
            if not avail bttfil
            then do:
                create bttfil.
                if length(string(clien.clicod)) >= 10
                then bttfil.etbcod = int(substring(string(clien.clicod),2,3)).
                else bttfil.etbcod = 
                        int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2)).
            end.

            assign
                vinativos = vinativos + 1
                bttfil.inativos = bttfil.inativos + 1.

                            
        end.
        else assign
                vativos   = vativos   + 1
                ttfil.ativos = ttfil.ativos + 1.

        if vr = yes
        then ttfil.recuperados = ttfil.recuperados + 1.
        if vn = yes
        then ttfil.novos = ttfil.novos + 1.
        
        if  clien.zona matches "*@*"
        then do:
            assign 
                ttfil.qtd-emails = ttfil.qtd-emails + 1
                vemails = vemails + 1.

            find ttcli where ttcli.etbcod = vetbcod
                         and ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.etbcod  = vetbcod
                       ttcli.clicod  = clien.clicod
                       ttcli.clinom  = clien.clinom
                       ttcli.celular = clien.fax
                       ttcli.email   = clien.zona.
            end.                       
        end.
     
        vtotal = vtotal + 1.
        ttfil.qtd-geral = ttfil.qtd-geral + 1.
        
        if vtotal mod 1000 = 0
        then 
             disp vtotal format ">>>>>>>>" label "Total" 
                  with frame fxx centered side-labels 1 down. pause 0.
                
    end.

    hide frame fxx no-pause.
end.
else do:    
    
    for each acao-cli where acao-cli.acaocod >= vacao-i
                        and acao-cli.acaocod <= vacao-f no-lock:

        find clien where clien.clicod = acao-cli.clicod no-lock no-error.
        assign vetbcod = 0.
        
        /*****
        find first titulo use-index iclicod
                          where titulo.clifor = clien.clicod
                            and titulo.titnat = no
                            and titulo.titsit = "LIB" no-lock no-error.

        if not avail titulo
        then do:
        
            find last plani use-index plasai
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
            end.                
            else vetbcod = plani.etbcod.
                      
        end.
        else vetbcod = titulo.etbcod.
        ***/
        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
        if avail cpclien and
                (cpclien.tememail = no or
                 cpclien.emailpromocional = no)
        then next. 
        
        vr = no.
        vn = no.
        
        find first titulo use-index iclicod
                          where titulo.titnat = no
                            and titulo.clifor = clien.clicod
                            and titulo.titsit = "LIB" 
                            /*and titulo.titdtemi < vdti*/ 
                            no-lock no-error.
    
        if not avail titulo
        then do:
            vetbcod = 0.
            find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 
                              /*and plani.pladat < vdti  */
                              no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
                /*
                find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= vdti 
                              and plani.pladat <= vdtf
                              no-lock no-error.
                if avail plani
                then assign
                        vetbcod = plani.etbcod
                        vrecuperados = vrecuperados + 1
                        vr = yes.
                */
            end.                
            else vetbcod = plani.etbcod.
        end.
        else vetbcod = titulo.etbcod.
        
        if vetbcod > 0 /*and
           clien.dtcad >= vdti and
           clien.dtcad <= vdtf*/
        then do:
            assign
                vnovos = vnovos + 1
                vn = yes.
            if vr = yes
            then assign
                    vrecuperados = vrecuperados - 1.
                    vr = no.
        end. 
        find first bf-estab where
                   bf-estab.etbcod = int(clien.refcinfo[5]) no-lock no-error.
        if avail bf-estab
        then do:           
                if clien.refcinfo[5] <> ""
                then vetbcod = int(clien.refcinfo[5]).
        end.

        find ttfil where ttfil.etbcod = vetbcod no-error.
        if not avail ttfil
        then do:
            create ttfil.
            assign ttfil.etbcod = vetbcod.
        end.
       
        if vetbcod = 0
        then do:
            assign
                vinativos = vinativos + 1
                ttfil.inativos = ttfil.inativos + 1.
           
            if length(string(clien.clicod)) >= 10
            then
            find first bttfil where bttfil.etbcod = 
                    int(substring(string(clien.clicod),2,3)) no-error.
            else
            find first bttfil where bttfil.etbcod = 
                    int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2))
                            no-error.
            if not avail bttfil
            then do:
                create bttfil.
                if length(string(clien.clicod)) >= 10
                then
                bttfil.etbcod = int(substring(string(clien.clicod), 2, 3)).
                else
                bttfil.etbcod = int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2)).
            end.

            assign
                vinativos = vinativos + 1
                bttfil.inativos = bttfil.inativos + 1.

        end.
        else assign
                vativos   = vativos   + 1
                ttfil.ativos = ttfil.ativos + 1.
        if vr = yes
        then ttfil.recuperados = ttfil.recuperados + 1.
        if vn = yes
        then ttfil.novos = ttfil.novos + 1.
        
        if  clien.zona matches "*@*"
        then do:


            assign 
                ttfil.qtd-emails = ttfil.qtd-emails + 1
                vemails = vemails + 1.

            find ttcli where ttcli.etbcod = vetbcod
                         and ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:

                create ttcli.
                assign ttcli.etbcod  = vetbcod
                       ttcli.clicod  = clien.clicod
                       ttcli.clinom  = clien.clinom
                       ttcli.celular = clien.fax
                       ttcli.email   = clien.zona.
            end.                       
        end.
     
        vtotal = vtotal + 1.
        ttfil.qtd-geral = ttfil.qtd-geral + 1.
        
        if vtotal mod 1000 = 0
        then 
             disp vtotal format ">>>>>>>>" label "Total" 
                  with frame fxx2 centered side-labels 1 down. pause 0.
                
    end.

    hide frame fxx2 no-pause.



end.
    
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = "".""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ LISTAGEM DE EMAIL - ANALITICA """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

        if vacao-i = 0 and vacao-f = 0
        then.
        else                
        disp skip(1)
             "Acao Inicial.....:" space(4) vacao-i skip
             "Acao Final.......:" space(4) vacao-f skip
             with frame f-ac width 80 no-box no-labels.
        
        disp skip (1)
            "Total de Clientes:" vtotal    skip
            "Clientes Ativos..:" vativos   skip
            "Clientes Inativos:" vinativos skip
            "Clientes c/ email:" vemails   skip
            skip (1)
            with frame f1f width 80 no-box no-labels.
    
        put fill("-",120) format "x(120)".
    
        for each ttfil where ttfil.etbcod <> 0 
                             no-lock break by ttfil.etbcod.

            find estab where estab.etbcod = ttfil.etbcod no-lock no-error.
            
            disp skip(1)
                 ttfil.etbcod     label "FILIAL"
                 estab.etbnom     no-label skip(1)
                 space(3)
                 ttfil.qtd-geral  label "Clientes Ativos" 
                 ttfil.inativos   label "Clientes Inativos"
                 ttfil.qtd-emails label "Clientes c/email"
                 skip(1)
                 with frame f2f side-labels.
            
            for each ttcli use-index i2
                        where ttcli.etbcod = ttfil.etbcod
                                 no-lock :
                
                disp space(3)
                     ttcli.clicod  column-label "Codigo"
                     ttcli.clinom  column-label "Cliente"
                     ttcli.celular column-label "Celular"
                     ttcli.email   column-label "e-mail" format "x(50)"
                     with frame f3f width 130 down.
                down with frame f3f. 
                                    
            end.

        end.

    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo,
                        input "").
    else do:
        /*{mrod.i}*/
        os-command silent start value(varquivo).
    end.        
    
