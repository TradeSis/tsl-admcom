{admcab.i}

def var vacao-i as int format ">>>>>>9".
def var vacao-f as int format ">>>>>>9".

def var vn as log.
def var v-situacli-cod as int.
def var v-situacli-des as char format "x(16)" extent 5 init
[ "RECUPERADO","INATIVO","NOVO","ATIVO COMPRA","ATIVO CONTRATO" ].


def var vcha-situacao as char format "x(22)" extent 3 init
["   CLIENTES ATIVOS  ","  CLIENTES INATIVOS ","       AMBOS "].

def var vcha-situ-aux as char.

def var varquivo  as   char.
def var vetbcod     like estab.etbcod.
def var vetbcod_aux as char.

def var vachou as log.
def var vinativos as   integer.
def var vativos   as   integer.
def var vtotal    as   integer.
def var vemails   as   integer.

def temp-table ttfil
    field etbcod       like estab.etbcod
    field qtd-geral    as   int
    field qtd-emails   as   int
    field ativos        as int
    field ativos-pla    as int
    field inativos     as int
    field novos        as int
    field novos1       as int
    field recuperados  as int 
    index i1 etbcod.
    
def var vnovos as int.
def var vnovos1 as int.
def var vrecuperados as int.
def var vint-fil-ini as int format ">>>9".
def var vint-fil-fim as int format ">>>9".

def var vr as log.

def temp-table ttcli
    field etbcod  like estab.etbcod
    field clicod  like clien.clicod
    field clinom  like clien.clinom
    field email   like clien.zona
    field celular like clien.fax
    field situacao   as int
    field dtaniver   as char 
    index i1 etbcod clicod 
    index i2 etbcod clinom.

def var at-pla as log.
def var at-tit as log.
def var rc-pla as log.
def var rc-tit as log.
def var in-pla as log.
def var vativos-pla as int.
def buffer bplani for plani.
def buffer btitulo for titulo.

def buffer bf-estab   for estab.
def var vdt-aux as date.
update vacao-i label "Acao Inicial"
       vacao-f label "Acao Final"
       with frame f-dados width 80 side-labels.

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

update vdti at 1  label "Periodo de  "
       vdtf at 30 label "Ate"
       with frame f-dados.

update vint-fil-ini at 1  label "De Filial   "
       vint-fil-fim at 25 label "A Filial"
       with frame f-dados width 80 side-labels.

display "Escolha a situacao a ser exibida no relatorio"
    with frame f-situ-aux  row 09 overlay centered no-box.

display vcha-situacao no-label
with frame f-situacao row 10 overlay centered.

choose field vcha-situacao with frame f-situacao.

if frame-index = 1
then assign vcha-situ-aux = "Ativos".

else if frame-index = 2
then assign vcha-situ-aux = "Inativos".

else if frame-index = 3
then assign vcha-situ-aux = "Ambos".

vdt-aux = vdti - 360.

def buffer bttfil for ttfil.

sresp = no.
message "Gerar a listagem analitica de emails?" update sresp.
if not sresp then leave. 


if opsys = "UNIX"
then varquivo = "/admcom/relat/lclmaila" + string(time).
else varquivo = "l:\relat\lclmaila.txt".

def var vq as int.

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

        vachou = no.
        vr = no.
        vn = no.
        at-tit = no.
        at-pla = no.
        rc-pla = no.
        rc-tit = no.
        find first titulo /*use-index iclicod*/
                          where titulo.clifor = clien.clicod
                            and titulo.modcod = "CRE"
                            and (titulo.titsit = "LIB" or
                                (titulo.titsit = "PAG" and
                                 titulo.titdtpag > vdtf))
                            and titulo.titdtemi < vdti 
                            no-lock no-error.
        if avail titulo
        then assign
                vetbcod = titulo.etbcod
                at-tit = yes.
        find first plani /*use-index plasai*/
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
            find first bplani /*use-index plasai*/
                            where bplani.movtdc = 5
                              and bplani.desti  = clien.clicod 
                              and bplani.pladat >= vdti 
                              and bplani.pladat <= vdtf 
                              no-lock no-error.
            if avail bplani
            then do:
                vetbcod = bplani.etbcod.
                find first btitulo /*use-index iclicod*/
                          where btitulo.clifor = clien.clicod
                            and btitulo.titnat = no
                            and btitulo.modcod = "CRE"
                            and (btitulo.titsit = "LIB" or
                                (btitulo.titsit = "PAG" and
                                 btitulo.titdtpag > vdtf and
                                 btitulo.datexp = btitulo.titdtpag))   
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
        find last plani /*use-index plasai*/
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
        
        if vint-fil-ini > 0 and
            vint-fil-fim > 0 then do:
        
            if int(vetbcod_aux) < vint-fil-ini or
                int(vetbcod_aux) > vint-fil-fim
            then next.

        end.
        
        vetbcod = int(vetbcod_aux).
         
        find ttfil where ttfil.etbcod = vetbcod no-error.
        if not avail ttfil
        then do:
            create ttfil.
            assign ttfil.etbcod = vetbcod.
        end.

        assign v-situacli-cod = 0.
        
        if at-pla = no and
           at-tit = no
        then do:
            if in-pla = yes
            then do:
                if rc-pla = yes or rc-tit = yes
                then assign
                        vrecuperados = vrecuperados + 1
                        v-situacli-cod = 1  
                        ttfil.recuperados = ttfil.recuperados + 1.
                else do:
                    if vachou = no
                    then do:
                        if vcha-situ-aux = "Ativos"
                        then next.
                        assign
                        vinativos = vinativos + 1
                        v-situacli-cod = 2  
                        ttfil.inativos = ttfil.inativos + 1
                        vachou = yes.
                    end.    
                end.        
            end.
            else do:
                if rc-pla = yes or rc-tit = yes
                then assign
                    vnovos = vnovos + 1
                    v-situacli-cod = 3  
                    ttfil.novos = ttfil.novos + 1.
                else if clien.dtcad >= vdti and
                       clien.dtcad <= vdtf
                then assign
                         vnovos1 = vnovos1 + 1
                         ttfil.novos1 = ttfil.novos1 + 1
                         v-situacli-cod = 3 .
                else if vachou = no
                then do: 
                    if vcha-situ-aux = "Ativos"
                    then next.
                    assign
                     vinativos = vinativos + 1
                     v-situacli-cod = 2  
                     ttfil.inativos = ttfil.inativos + 1
                     vachou = yes.
                end.     
            end.
        end.
        else do:
            if at-pla = yes
            then do:
                if vachou = no
                then do:
                    if vcha-situ-aux = "Inativos"
                    then next.
                    assign
                        vativos-pla   = vativos-pla   + 1
                        v-situacli-cod = 4  
                        ttfil.ativos-pla = ttfil.ativos-pla + 1
                        vachou = yes.
                end.   
            end.        
            else if at-tit = yes
            then do:
                if vachou = no
                then do:
                     if vcha-situ-aux = "Inativos"
                     then next.
                     assign
                        vativos   = vativos   + 1
                        v-situacli-cod = 5
                        ttfil.ativos = ttfil.ativos + 1
                        vachou = yes.
                end.        
            end.
        end.
        
        if  clien.zona matches "*@*"
        then do:
            assign 
                ttfil.qtd-emails = ttfil.qtd-emails + 1
                vemails = vemails + 1.
        end.
        
        find ttcli where ttcli.etbcod = vetbcod
                         and ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:
                create ttcli.
                assign ttcli.etbcod   = int(vetbcod_aux)
                       ttcli.clicod   = clien.clicod
                       ttcli.clinom   = clien.clinom
                       ttcli.celular  = clien.fax
                       ttcli.email    = if clien.zona <> "" then clien.zona else ""
                       ttcli.situacao = v-situacli-cod
                       ttcli.dtaniver = string(day(clien.dtnasc)) + "/" + string(month(clien.dtnasc)).
                       
            end.                       
        
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
        if not avail clien then next.
        if clien.clinom = "" or
           clien.clinom = ?
        then next.   
        vetbcod = 0.
        if clien.dtcad > vdtf then next.
        vtotal = vtotal + 1.
        
        find cpclien where 
                    cpclien.clicod = clien.clicod no-lock no-error.
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
            then vetbcod_aux = substring(vetbcod_aux,2,3).
            else
            vetbcod_aux = 
                substring(vetbcod_aux,(length(vetbcod_aux) - 1), 2).
        end.

        if vint-fil-ini > 0 and
            vint-fil-fim > 0 then do:
                            
            if int(vetbcod_aux) < vint-fil-ini or
                int(vetbcod_aux) > vint-fil-fim
            then next.
           
        end.

        vetbcod = int(vetbcod_aux).
        find ttfil where ttfil.etbcod = vetbcod no-error.
        if not avail ttfil
        then do:
            create ttfil.
            assign ttfil.etbcod = vetbcod.
        end.
       
        if at-pla = no and
           at-tit = no
        then do:
            if in-pla = yes
            then do:
                if rc-pla = yes or rc-tit = yes
                then assign
                        vrecuperados = vrecuperados + 1
                        v-situacli-cod = 1  
                        ttfil.recuperados = ttfil.recuperados + 1.
                else do:
                    if vachou = no
                    then do:
                        
                        if vcha-situ-aux = "Ativos"
                        then next.
                        
                        assign
                        vinativos = vinativos + 1
                        v-situacli-cod = 2  
                        ttfil.inativos = ttfil.inativos + 1
                        vachou = yes.
                    end.    
                end.        
            end.
            else do:
                if rc-pla = yes or rc-tit = yes
                then assign
                    vnovos = vnovos + 1
                    v-situacli-cod = 3  
                    ttfil.novos = ttfil.novos + 1.
                else if clien.dtcad >= vdti and
                       clien.dtcad <= vdtf
                then assign
                         vnovos1 = vnovos1 + 1
                         ttfil.novos1 = ttfil.novos1 + 1
                         v-situacli-cod = 3 .
                else if vachou = no
                then do:
                    
                    if vcha-situ-aux = "Ativos"
                    then next.
                     assign
                     vinativos = vinativos + 1
                     v-situacli-cod = 2  
                     ttfil.inativos = ttfil.inativos + 1
                     vachou = yes.
                end.     
            end.

        end.
        else do:
            if at-pla = yes
            then do:
                if vachou = no
                then do:
                
                    if vcha-situ-aux = "Inativos"
                    then next.
                    
                    assign
                    vativos-pla   = vativos-pla   + 1
                    v-situacli-cod = 4  
                    ttfil.ativos-pla = ttfil.ativos-pla + 1.
                    vachou = yes.
                end.    
            end.        
            else if at-tit = yes
            then do:
                if vachou = no
                then do:
                     
                    if vcha-situ-aux = "Inativos"
                    then next.
                     
                     assign
                        vativos   = vativos   + 1
                        v-situacli-cod = 5
                        ttfil.ativos = ttfil.ativos + 1
                        vachou = yes.
                end.        
            end.
        end.

        if  clien.zona matches "*@*"
        then do:
            assign 
                ttfil.qtd-emails = ttfil.qtd-emails + 1
                vemails = vemails + 1.
        end.
        
            find ttcli where ttcli.etbcod = int(vetbcod_aux)
                         and ttcli.clicod = clien.clicod no-error.
            if not avail ttcli
            then do:

                create ttcli.
                assign ttcli.etbcod   = int(vetbcod_aux)
                       ttcli.clicod   = clien.clicod
                       ttcli.clinom   = clien.clinom
                       ttcli.celular  = clien.fax
                       ttcli.email    = if clien.zona <> "" then clien.zona else ""
                       ttcli.situacao = v-situacli-cod
                       ttcli.dtaniver = string(day(clien.dtnasc)) + "/" + 
string(month(clien.dtnasc)).
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

output to value("ttcli" + string(vdti,"99999999") + "." + string(time)).
for each ttcli.
    export ttcli.
end.
output close.

find first bal_cli where
           bal_cli.tipo    = 0   and 
           bal_cli.etbcod  = 0 and
           bal_cli.clicod  = 0 and  
           bal_cli.etbini  = vint-fil-ini and
           bal_cli.etbfim  = vint-fil-fim and
           bal_cli.acaoini = vacao-i and
           bal_cli.acaofim = vacao-f and
           bal_cli.datini  = vdti and
           bal_cli.datfim  = vdtf
           no-lock no-error.
if not avail bal_cli
then do on error undo:
    create bal_cli.
    assign
        bal_cli.tipo    = 0   
        bal_cli.etbcod  = 0 
        bal_cli.clicod  = 0   
        bal_cli.etbini  = vint-fil-ini 
        bal_cli.etbfim  = vint-fil-fim 
        bal_cli.acaoini = vacao-i 
        bal_cli.acaofim = vacao-f 
        bal_cli.datini  = vdti 
        bal_cli.datfim  = vdtf
        .
    for each ttfil:
        assign
            bal_cli.total_cliente = bal_cli.total_cliente + ttfil.qtd-geral
            bal_cli.com_email = bal_cli.com_email + ttfil.qtd-emails
            bal_cli.inativos  = bal_cli.inativos + ttfil.inativos
            bal_cli.recuperados = bal_cli.recuperados + ttfil.recuperados
            bal_cli.ativos_compra = bal_cli.ativos_compra + ttfil.ativos-pla
            bal_cli.ativos_contrato = bal_cli.ativos_contrato + ttfil.ativos
            bal_cli.novo_compra = bal_cli.novo_compra + ttfil.novos
            bal_cli.novo_contrato = bal_cli.novo_contrato + ttfil.novos1
            .
    end.    
end.
 

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "0"
        &Nom-Rel   = "".""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ LISTAGEM DE EMAIL - ANALITICA """
        &Width     = "130"
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
        
        /***
        for each ttfil where ttfil.etbcod <> 0 no-lock break by ttfil.etbcod.
            assign 
                vinativos = vinativos + ttfil.inativos
                vativos-pla = vativos-pla + ttfil.ativos-pla
                vativos = vativos + ttfil.ativos
                vrecuperados = vrecuperados + ttfil.recuperados
                vnovos   = vnovos + ttfil.novos
                vnovos1 = vnovos1 + ttfil.novos1
                vemails = vemails + ttfil.qtd-emails.
        end.
        ***/
        
        for each bal_cli where   bal_cli.tipo    = 0   and 
                                bal_cli.etbcod  = 0 and
                                bal_cli.clicod  = 0 and  
                                bal_cli.etbini  = vint-fil-ini and
                                bal_cli.etbfim  = vint-fil-fim and
                                bal_cli.acaoini = vacao-i and
                                bal_cli.acaofim = vacao-f and
                                bal_cli.datini  = vdti and
                                bal_cli.datfim  = vdtf
                                no-lock:

            assign 
                vinativos = vinativos + bal_cli.inativos
                vativos-pla = vativos-pla + bal_cli.ativos_compra
                vativos = vativos + bal_cli.ativos_contrato
                vrecuperados = vrecuperados + bal_cli.recuperados
                vnovos   = vnovos + bal_cli.novo_compra
                vnovos1 = vnovos1 + bal_cli.novo_contrato
                vemails = vemails + bal_cli.com_email
                .
     
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
        /*****
         disp skip (1)
            "Total de Clientes:" vtotal    skip
            "Inativos.........:" vinativos skip
            "Ativos Compra....:" vativos-pla skip
            "Ativos Contrato..:" vativos   skip
            "Recuperados......:" vrecuperados skip
            "Novos............:" vnovos skip
            "Com email........:" vemails   skip
            skip (1)
            with frame f1f width 80 no-box no-labels.
    
        put fill("-",145) format "x(145)".
        ***/
        
        for each ttfil no-lock:
            find estab where estab.etbcod = ttfil.etbcod
                        no-lock no-error.
            vtotal = ttfil.inativos + ttfil.ativos-pla + ttfil.ativos
            + ttfil.recuperados + ttfil.novos + ttfil.novos1.
 
            if vtotal = 0
            then next.

            disp skip (1)
            "Filial.....................:" ttfil.etbcod
            estab.etbnom   no-label when avail estab
            "Total de Clientes..........:" vtotal    skip
            "Clientes Inativos..........:" ttfil.inativos skip
            "Clientes Ativos Compra.....:" ttfil.ativos-pla   skip
            "Clientes Ativos Contrato...:" ttfil.ativos   skip
            "Clientes Recuperados.......:" ttfil.recuperados skip
            "Clientes Novos Compra......:" ttfil.novos    skip
            "Clientes Novos Cadastro....:" ttfil.novos1 skip
            "Clientes com email.........:" ttfil.qtd-email   skip
            skip (1)
            with width 80 no-box no-labels.
 
            /**
            disp  skip(1)
                 ttfil.etbcod label "FILIAL"   
                 estab.etbnom     no-label when ttfil.etbcod <> 0 
                 skip(1) 
                 
                 
                 ttfil.inativos   label "Inativos" skip 
                 ttfil.ativos-pla label "Ativos Compra" skip
                 ttfil.ativos     label "Ativos Contrato" skip
                 ttfil.recuperados label "Recuperados" skip
                 ttfil.novos       label "Novos" skip
                 ttfil.novos1      label "Novos 
                 ttfil.qtd-emails label "Com email"
                 skip(1)
                 with frame f-filial down side-labels.
            **/
            for each ttcli use-index i2
                        where ttcli.etbcod = ttfil.etbcod no-lock 
                             break  by ttcli.etbcod
                                    by ttcli.clinom.
               /*
               if vcha-situ-aux <> "Ambos"
               then do:
                     
                   if vcha-situ-aux = "Inativos"
                       and (ttcli.situacao = 4 or ttcli.situacao = 5)
                   then next.
                        
                   if vcha-situ-aux = "Ativos"
                       and ttcli.situacao = 2 
                   then next.    
               end.                     
               */
                                    
               find clien where clien.clicod = ttcli.clicod no-lock no-error.
           
               disp space(3)
                     ttcli.etbcod  column-label "Fil"   
                     ttcli.clicod  column-label "Codigo"
                     clien.clinom  column-label "Cliente" format "x(32)"
                        when avail clien
                     ttcli.celular column-label "Celular"
                     ttcli.email   column-label "e-mail" format "x(42)"
                     v-situacli-des[ttcli.situacao] format "x(14)"
                     when ttcli.situacao >= 1  label "Sit"
                     ttcli.dtaniver column-label "Aniver"
                     with frame f3f width 145 down.
                down with frame f3f. 
                                    

        end.
    end.

    put "======== LEGENDA ==============" SKIP
        "Total de Clientes = cadastrados ate a data final informada"
         skip
        "Clientes Inativos = nao possuem titulos em aberto e nao compram a mais de 1 anos" skip
        "Clientes ativos compra = que compraram no ultimo ano" skip
        "Clientes ativos contrato = que possuem contrato em aberto" skip
        "Clentes recuperados = nao compravam a mais de um ano e nao possuiam contrato em aberto e voltaram a comprar no periodo" skip
        "Clientes novos = Cadastrados no periodo" skip
        "Clientes com email = com email cadatrado" skip
        .

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                        input "").
    end.
    else do:
    message "Arquivos Gerado:"  varquivo. pause.
     /*   {mrod.i} */
    end. 

