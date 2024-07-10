{admcab.i}

def var vacao-i as int format ">>>>>>9".
def var vacao-f as int format ">>>>>>9".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

def var varquivo  as   char.
def var vetbcod   like estab.etbcod.

def var vr as log.
def var vn as log.

def var vinativos as   integer.
def var vativos   as   integer.
def var vtotal    as   integer.
def var vemails   as   integer.

def temp-table ttcli
    field etbcod       like estab.etbcod
    field qtd-geral    as   int
    field qtd-emails   as   int
    field inativos     as int
    field ativos       as int
    field novos        as int
    field recuperados  as int .
def var vnovos as int.
def var vrecuperados as int.

def buffer bf-estab for estab.

update vacao-i label "Acao Inicial"
       vacao-f label "Acao Final"
       with frame f-dados width 80 side-labels.

update vdti at 1 label " Periodo de"
       vdtf label "Ate"
       with frame f-dados.

sresp = no.
message "Gerar a listagem sintetica de emails?" update sresp.
if not sresp then leave.

if opsys = "UNIX"
then varquivo = "/admcom/relat/lclimail." + string(time).
else varquivo = "l:\relat\lclimail." + string(time).


if vacao-i = 0 and vacao-f = 0
then do:

    for each clien no-lock.
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
                            and titulo.titdtemi < vdti
                            no-lock no-error.
        if not avail titulo
        then do:
            vetbcod = 0.
            find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 
                              and plani.pladat < vdti
                              no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
                /*vetbcod = int(substring(string(clien.clicod),
                            length(string(clien.clicod)) - 1, 2)).*/
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
            end.                
            else
                vetbcod = plani.etbcod.
                      
        end.
        else vetbcod = titulo.etbcod.

        if vetbcod > 0 and
           clien.dtcad >= vdti and
           clien.dtcad <= vdtf
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
        
        find ttcli where ttcli.etbcod = vetbcod no-error.
        if not avail ttcli
        then do:
            create ttcli.
            assign ttcli.etbcod = vetbcod.
        end.

        if vetbcod = 0
        then assign
                vinativos = vinativos + 1
                ttcli.inativos = ttcli.inativos + 1.
        else assign
                vativos   = vativos   + 1
                ttcli.ativos = ttcli.ativos + 1.
        if vr = yes
        then ttcli.recuperados = ttcli.recuperados + 1.
        if vn = yes
        then ttcli.novos = ttcli.novos + 1.
        
        if clien.zona matches "*@*"
        then assign 
                ttcli.qtd-emails = ttcli.qtd-emails + 1
                vemails = vemails + 1.
    
    
        vtotal = vtotal + 1.
        ttcli.qtd-geral = ttcli.qtd-geral + 1.
        
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
                            and titulo.titdtemi < vdti 
                            no-lock no-error.
    
        if not avail titulo
        then do:
            vetbcod = 0.
            find last plani where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= 01/01/2004 
                              and plani.pladat < vdti
                              no-lock no-error.
            if not avail plani
            then do:
                vetbcod = 0.
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
            end.                
            else vetbcod = plani.etbcod.
        end.
        else vetbcod = titulo.etbcod.
        
        if vetbcod > 0 and
           clien.dtcad >= vdti and
           clien.dtcad <= vdtf
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
        find ttcli where ttcli.etbcod = vetbcod no-error.
        if not avail ttcli
        then do:
            create ttcli.
            assign ttcli.etbcod = vetbcod.
        end.
        if vetbcod = 0
        then assign
                vinativos = vinativos + 1
                ttcli.inativos = ttcli.inativos + 1.
        else assign
                vativos   = vativos   + 1
                ttcli.ativos = ttcli.ativos + 1.
        if vr = yes
        then ttcli.recuperados = ttcli.recuperados + 1.
        if vn = yes
        then ttcli.novos = ttcli.novos + 1.
        
        if clien.zona matches "*@*"
        then assign 
                ttcli.qtd-emails = ttcli.qtd-emails + 1
                vemails = vemails + 1.
    
    
        vtotal = vtotal + 1.
        ttcli.qtd-geral = ttcli.qtd-geral + 1.
        
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

        disp skip (1)
            "Total de Clientes..........:" vtotal    skip
            "Clientes Ativos............:" vativos   skip
            "Clientes Ativos Novos......:" vnovos    skip
            "Clientes Ativos Recuperados:" vrecuperados skip
            "Clientes Inativos..........:" vinativos skip
            "Clientes com email.........:" vemails   skip
            skip (1)
            with width 80 no-box no-labels.
    
        put fill("-",80) format "x(80)".
    
        for each ttcli where ttcli.etbcod <> 0 no-lock break by ttcli.etbcod.
            find estab where estab.etbcod = ttcli.etbcod no-lock no-error.
            
            disp ttcli.etbcod     column-label "Cod."
                 estab.etbnom when avail estab
                 ttcli.qtd-geral  column-label "Clientes!Ativos" (total)
                 ttcli.novos      column-label "Ativos!Novos"    (total)
                 ttcli.recuperados column-label "Ativos!Recuperados" (total)
                 ttcli.inativos    column-label "Inativos" (total)
                 ttcli.qtd-emails column-label "Clientes!c/email" (total)
                 with centered width 110.
             
        end.

    output close.

    if opsys = "UNIX"
    then run visurel.p (input varquivo,
                        input "").
    else do:
        {mrod.i}
    end.        
    
