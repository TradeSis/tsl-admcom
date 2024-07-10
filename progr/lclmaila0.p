{admcab.i}

def var vacao-i as int format ">>>>>>9".
def var vacao-f as int format ">>>>>>9".

def var vetbnom like estab.etbnom.
def var vclinom like clien.clinom.

def var vn as log.
def var v-situacli-cod as int.
def var v-situacli-des as char format "x(20)" extent 10 init
["INATIVO","ATIVO CONTRATO","ATIVO COMPRA PRAZO","ATIVO COMPRA VISTA",
 "RECUPERADO CONTRATO","","RECUPERADO VENDA VISTA",
 "NOVO CADASTRO","NOVO COMPRA PRAZO","NOVO COMPRA VISTA"].

def var vcha-situacao as char format "x(22)" extent 3 init
["   CLIENTES ATIVOS  ","  CLIENTES INATIVOS ","      G E R A L "].

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
    field ativos       as int
    field ativos-pla   as int
    field ativos-vvi   as int
    field inativos     as int
    field novos        as int
    field novos-con       as int
    field novos-vvi       as int
    field recupera-pla as int 
    field recupera-con as int
    field recupera-vvi as int
    index i1 etbcod.
    
def var vnovos as int.
def var vnovos-con as int.
def var vnovos-vvi as int.
def var vrecupera-pla as int.
def var vrecupera-con as int.
def var vrecupera-vvi as int.

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
def var at-vvi as log.
def var rc-con as log.
def var rc-vvi as log.
def var rc-pla as log.
def var in-pla as log.
def var in-cli as log.
def var nv-cli as log.
def var nv-con as log.
def var nv-vvi as log.

def var vativos-pla as int.
def var vativos-vvi as int.
def buffer bplani for plani.
def buffer btitulo for titulo.

def buffer bf-estab   for estab.
def var vdt-aux as date.
/*
update vacao-i label "Acao Inicial"
       vacao-f label "Acao Final"
       with frame f-dados width 80 side-labels.
*/
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".

update vdti at 1  label "Periodo de  "
       vdtf at 30 label "Ate"
       with frame f-dados.

update vint-fil-ini at 1  label "De Filial   "
       vint-fil-fim at 25 label "A Filial"
       with frame f-dados width 80 side-labels.

def var vanalitico as log init no format "Sim/Nao".

disp  "Relatorio analitico?" at 1 no-label
     with frame f-dados.

update vanalitico no-label with frame f-dados.

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
then assign vcha-situ-aux = "      G E R A L ".

vdt-aux = vdti - 360.

def buffer bttfil for ttfil.

/**
sresp = no.
message "Gerar a listagem analitica de emails?" update sresp.
if not sresp then leave. 
**/

sresp = no.
message "Confirma processamento?" update sresp.
if not sresp then leave. 

if opsys = "UNIX"
then varquivo = "/admcom/relat/balancli_" +         string(today,"99999999") + "_" + string(time) + ".txt".
else varquivo = "l:\relat\balancli_" +
        string(today,"99999999") + "_" + string(time) + ".txt".

def var vq as int.

def buffer bclien for clien.

if vacao-i = 0 and vacao-f = 0
then do:
    for each clien where clien.clicod > 10 no-lock.
            
        if clien.clinom = "" or
           clien.clinom = ?
        then next.
           
        assign vetbcod = 0.

        if  clien.dtcad <> ? and
            clien.dtcad > vdtf and
            not can-find(first plani where
                              plani.movtdc = 5 and
                              plani.desti  = clien.clicod and
                              plani.pladat <= vdtf)
        then next.

        if (clien.ciccgc = ? or
           clien.ciccgc = "") and
           not can-find(first plani where
                        plani.movtdc = 5 and
                        plani.desti  = clien.clicod and
                        plani.pladat <= vdtf) and
           can-find(first bclien where
                  bclien.clinom = clien.clinom and
                  bclien.clicod <> clien.clicod and
                  bclien.ciccgc <> "" and
                  bclien.ciccgc <> ? )
        then next.            
        
        vtotal = vtotal + 1.

        find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

        assign
            vachou = no 
            vr = no vn = no 
            at-tit = no at-pla = no at-vvi = no 
            rc-con = no rc-vvi = no rc-pla = no
            in-pla = no in-cli = no
            nv-cli = no nv-con = no nv-vvi = no
            .

        if clien.dtcad >= vdti and
           clien.dtcad <= vdtf and
           not can-find(first plani where
                              plani.movtdc = 5 and
                              plani.desti  = clien.clicod and
                              plani.pladat < vdti)
        then nv-cli = yes.  

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
        else
        find first plani /*use-index plasai*/
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat >= vdt-aux 
                              and plani.pladat < vdti 
                              no-lock no-error.
        if avail plani and plani.crecod = 2
        then assign
                vetbcod = plani.etbcod
                at-pla = yes.
        else if avail plani 
        then at-vvi = yes.
        
        if at-pla = no and
           at-tit = no and
           at-vvi = no 
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
                if nv-cli 
                then do:
                    if bplani.crecod = 2
                    then assign
                        nv-con = yes
                        nv-cli = no.
                    else assign
                        nv-vvi = yes
                        nv-cli = no.
                end.
                else if bplani.crecod = 2
                then do:
                    find first btitulo /*use-index iclicod*/
                          where btitulo.clifor = clien.clicod
                            and btitulo.titnat = no
                            and btitulo.modcod = "CRE"
                            and (btitulo.titsit = "LIB" or
                                (btitulo.titsit = "PAG" and
                                 btitulo.titdtpag > vdtf))
                            and btitulo.titdtemi >= vdti 
                            and btitulo.titdtemi <= vdtf
                            and btitulo.titpar < 30
                            no-lock no-error.
                    if avail btitulo
                    then assign
                         vetbcod = btitulo.etbcod   
                         rc-con = yes.
                    else rc-pla = yes.
                end.
                else rc-vvi = yes.
            end.
            else do:
                find last plani /*use-index plasai*/
                            where plani.movtdc = 5
                              and plani.desti  = clien.clicod 
                              and plani.pladat < vdt-aux
                              no-lock no-error.
                if avail plani
                then assign
                        vetbcod = plani.etbcod
                        in-pla = yes.
                else in-cli = yes.
            end.
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

        if vetbcod = 0 
        then do:
            vetbcod_aux = string(clien.clicod).
            if length(vetbcod_aux) = 10
            then vetbcod_aux = substring(vetbcod_aux,2,3).
            else vetbcod_aux = substr(vetbcod_aux,length(vetbcod_aux) - 1,2).
        end.
        else vetbcod_aux = string(vetbcod).
        
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
           at-tit = no and
           at-vvi = no and
           nv-cli = no and
           nv-con = no and
           nv-vvi = no
        then do:
            if rc-pla or rc-con or rc-vvi
            then do:
                if rc-pla or rc-con
                then
                    assign
                        vrecupera-pla = vrecupera-pla + 1
                        v-situacli-cod = 5
                        ttfil.recupera-pla = ttfil.recupera-pla + 1
                        .
                else if rc-vvi
                then
                    assign
                        vrecupera-vvi = vrecupera-vvi + 1
                        v-situacli-cod = 7
                        ttfil.recupera-vvi = ttfil.recupera-vvi + 1
                        .
            end.
            else if in-pla or in-cli
            then do:
                /*if vachou = no
                then*/ do:
                    if vcha-situ-aux = "Ativos"
                    then next.
                    assign
                        vinativos = vinativos + 1
                        v-situacli-cod = 1  
                        ttfil.inativos = ttfil.inativos + 1
                        vachou = yes.
                end.        
            end.
        end.
        else do:
            if at-pla = yes
            then do:
                /*if vachou = no
                then*/ do:
                    if vcha-situ-aux = "Inativos"
                    then next.
                    assign
                        vativos-pla   = vativos-pla   + 1
                        v-situacli-cod = 3  
                        ttfil.ativos-pla = ttfil.ativos-pla + 1
                        vachou = yes.
                end.   
            end.        
            else if at-vvi = yes
            then do:
                /*if vachou = no
                then*/ do:
                    if vcha-situ-aux = "Inativos"
                    then next.
                    assign
                        vativos-vvi   = vativos-vvi   + 1
                        v-situacli-cod = 4  
                        ttfil.ativos-vvi = ttfil.ativos-vvi + 1
                        vachou = yes.
                end.  
            end.
            else if at-tit = yes
            then do:
                /*if vachou = no
                then*/ do:
                     if vcha-situ-aux = "Inativos"
                     then next.
                     assign
                        vativos   = vativos   + 1
                        v-situacli-cod = 2
                        ttfil.ativos = ttfil.ativos + 1
                        vachou = yes.
                end.        
            end.
            else if nv-cli
            then assign
                    vnovos = vnovos + 1
                    v-situacli-cod = 8  
                    ttfil.novos = ttfil.novos + 1.
            else if nv-con
            then assign
                     vnovos-con = vnovos-con + 1
                     v-situacli-cod = 9
                     ttfil.novos-con = ttfil.novos-con + 1.
            else assign
                    vnovos-vvi = vnovos-vvi + 1
                    v-situacli-cod = 10
                    ttfil.novos-vvi = ttfil.novos-vvi + 1.
      
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

output to value("/admcom/relat/clibal" + string(vdti,"99999999") + "." +
        string(time)).
for each ttcli.
    export ttcli.
end.
output close.

/**
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
**/ 

def var vtiporel as char.
if vanalitico
then vtiporel = "ANALITICO".
else vtiporel = "SINTETICO".

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "150"
        &Page-Line = "0"
        &Nom-Rel   = "".""
        &Nom-Sis   = """."""
        &Tit-Rel   = """ BALANCO DE CLIENTES "" + vtiporel "
        &Width     = "150"
        &Form      = "frame f-cabcab"}

        disp with frame f-dados.
        
        if vacao-i = 0 and vacao-f = 0
        then.
        else                
        disp skip(1)
             "Acao Inicial.....:" space(4) vacao-i skip
             "Acao Final.......:" space(4) vacao-f skip
             with frame f-ac width 80 no-box no-labels.
        
        assign
            vtotal = 0 vinativos = 0 
            vativos-pla = 0 vativos = 0 vativos-vvi = 0
            vrecupera-con = 0 vrecupera-pla = 0 vrecupera-vvi = 0
            vnovos = 0 vnovos-con = 0 vnovos-vvi = 0 
            vemails = 0
            .
        
        for each ttfil where ttfil.etbcod <> 0 no-lock break by ttfil.etbcod.
            assign 
                vinativos = vinativos + ttfil.inativos
                vativos-pla = vativos-pla + ttfil.ativos-pla
                vativos = vativos + ttfil.ativos
                vativos-vvi = vativos-vvi + ttfil.ativos-vvi
                /*vrecupera-con = vrecupera-con + ttfil.recupera-con*/
                vrecupera-pla = vrecupera-pla + 
                                ttfil.recupera-pla + ttfil.recupera-con
                vrecupera-vvi = vrecupera-vvi + ttfil.recupera-vvi
                vnovos   = vnovos + ttfil.novos
                vnovos-con = vnovos-con + ttfil.novos-con
                vnovos-vvi = vnovos-vvi + ttfil.novos-vvi
                vemails = vemails + ttfil.qtd-emails.
        end.
        
        /**
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
        **/
        
        vtotal = vtotal + vinativos + 
            vativos-vvi + vativos-pla + vativos
            + vrecupera-con + vrecupera-pla + vrecupera-vvi 
            + vnovos + vnovos-con + vnovos-vvi.
            
        disp skip (1)
            "Total de Clientes...................:" vtotal        skip
            "Clientes Inativos...................:" vinativos     skip
            "Clientes Ativos Contrato............:" vativos       skip
            "Clientes Ativos Compra Prazo........:" vativos-pla   skip
            "Clientes Ativos Compra Vista........:" vativos-vvi   skip
            "Clientes Recuperados Compra Prazo...:" vrecupera-pla skip
            "Clientes Recuperados Compra Vista...:" vrecupera-vvi skip
            "Clientes Novos Cadastro.............:" vnovos        skip
            "Clientes Novos Compra Prazo.........:" vnovos-con    skip
            "Clientes Novos Compra Vista.........:" vnovos-vvi    skip
            "Clientes com email..................:" vemails       skip
            skip (1)
            with width 80 no-box no-labels.
    
        put fill("-",80) format "x(80)".
        
        if not vanalitico
        then do:
            for each ttfil where ttfil.etbcod <> 0 no-lock 
                        break by ttfil.etbcod.
                find estab where 
                    estab.etbcod = ttfil.etbcod no-lock no-error.
                vtotal = ttfil.inativos + 
                ttfil.ativos-pla + ttfil.ativos + ttfil.ativos-vvi +
                ttfil.recupera-pla + ttfil.recupera-vvi + ttfil.recupera-con + 
                ttfil.novos + ttfil.novos-con + ttfil.novos-vvi.
 
                 disp ttfil.etbcod     column-label "Cod."
                 estab.etbnom when avail estab format "x(15)"
                 vtotal column-label "Toatal!Clientes" (total)
                 ttfil.inativos    column-label "Total!Inativos" (total)
                 ttfil.ativos  column-label "Ativos!Contrato" (total)
                 ttfil.ativos-pla column-label "Ativos!Cprazo" (total)
                 ttfil.ativos-vvi column-label "Ativos!Cvista" (total)
                 ttfil.recupera-pla column-label "Recuperados!Cprazo" (total)
                 ttfil.recupera-vvi column-label "Recuperados!Cvista" (total)
                 ttfil.novos      column-label "Novos!Cadastro"   (total)
                 ttfil.novos-con  column-label "Novos!Cprazo" (total)
                 ttfil.novos-vvi  column-label "Novos!Cvista" (total)
                 ttfil.qtd-emails column-label "Com email" (total)
                 with centered width 160.
             
            end.
        end.
        else do:
            for each ttfil no-lock:
                find estab where estab.etbcod = ttfil.etbcod
                        no-lock no-error.
                vtotal = ttfil.inativos + 
                ttfil.ativos-pla + ttfil.ativos + ttfil.ativos-vvi +
                ttfil.recupera-pla + ttfil.recupera-vvi + ttfil.recupera-con + 
                ttfil.novos + ttfil.novos-con + ttfil.novos-vvi.
 
                if vtotal = 0
                then next.

                disp skip (1)
                "Filial..............................:" format "x(37)"
                ttfil.etbcod
                estab.etbnom   no-label when avail estab format "x(30)" skip
                "Total de Clientes...................:" format "x(37)"
                vtotal          skip
                "Clientes Inativos...................:" format "x(37)"
                ttfil.inativos  skip
                "Clientes Ativos Contrato............:" format "x(37)"
                ttfil.ativos    skip
                "Clientes Ativos Compra Prazo........:" format "x(37)"
                ttfil.ativos-pla skip
                "Clientes Ativos Compra Vista........:" format "x(37)"
                ttfil.ativos-vvi skip
                "Clientes Recuperados Compra Prazo...:" format "x(37)"
                ttfil.recupera-pla skip
                "Clientes Recuperados Compra Vista...:" format "x(37)"
                ttfil.recupera-vvi skip
                "Clientes Novos Cadastro.............:" format "x(37)"
                ttfil.novos        skip
                "Clientes Novos Compra Prazo.........:" format "x(37)"
                ttfil.novos-con    skip
                "Clientes Novos Compra Vista.........:" format "x(37)"
                ttfil.novos-vvi    skip
                "Clientes com email..................:" format "x(37)"
                ttfil.qtd-email    skip
                skip (1)
                with width 80 no-box no-labels.
 
            for each ttcli use-index i2
                        where ttcli.etbcod = ttfil.etbcod no-lock 
                             break  by ttcli.etbcod
                                    by ttcli.clinom.
             
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
    end.

    put unformatted skip(2)
    "============================= L E G E N D A ==========================="
     SKIP
    "TOTAL DE CLIENTES   = cadastrados ate a data final do periodo informado"
         skip
    "                      exceto clientes sem nome, clientes duplicados sem "
         skip
    "                      CPF e sem movimento." skip 
    "CLIENTES INATIVOS   = que nao possuem titulos em aberto e nao compram a"
         skip 
    "                      mais de 1 ano." skip
    "ATIVOS CONTRATO     = que possuem contrato em aberto." skip
    "ATIVOS COMPRA PRAZO = que compraram a prazo no ultimo ano." skip
    "ATIMOS COMPRA VISTA = que compraram a vista no ultimo ano." skip
    "RECUPERADOS A PRAZO = nao compravam a mais de um ano e nao possuiam "
    skip
    "                      contrato em aberto e voltaram a comprar a prazo"
    skip
    "                      no periodo informado."
    skip
    "RECUPERADOS A VISTA = nao compravam a mais de um ano e nao possuiam "
    skip
    "                      contrato em aberto e voltaram a comprar a vista"
    skip
    "                      no periodo informado."
    skip
    "NOVOS CADASTRO      = cadastros novos no periodo sem compra." skip
    "NOVOS COMPRA PRAZO  = cadatros novos no periodo com compra a prazo." skip
    "NOVOS COMPRA VISTA  = cadatros novos no periodo com compra a vista." skip
    "CLIENTES COM EMAIL  = com email cadatrado." skip
        .

    output close.

    def var varqfil as char.
    vq = 0.
    for each ttfil no-lock:
            
        find estab where estab.etbcod = ttfil.etbcod
                        no-lock no-error.
            
        if not avail estab then next.
            
        vtotal = ttfil.inativos + 
            ttfil.ativos-pla + ttfil.ativos + ttfil.ativos-vvi +
            ttfil.recupera-pla + ttfil.recupera-vvi + ttfil.recupera-con + 
            ttfil.novos + ttfil.novos-con + ttfil.novos-vvi.
 
        if vtotal = 0
        then next.
        if not vanalitico
        then do:
            vq = vq + 1.
            vetbnom = estab.etbnom .
            varqfil = "/admcom/relat/balclifil000.csv".
            output to value(varqfil) append.
            if vq = 1
            then put unformatted 
                "      ;;Total   ;Clientes;Ativos  ;Ativos      ;Ativos      ;
                 Recuperados ;Recuperados ;Novos   ;Novos       ;Novos       ;
                 Com   ;" skip
                "Filial;;Clientes;Inativos;Contrato;Compra Prazo;Compra Vista;
                 Compra Prazo;Compra Vista;Cadastro;Compra Prazo;Compra Vista;
                 E-mail;" skip.
                 
            put unformatted
                 ttfil.etbcod ";"
                 vetbnom      ";"
                 vtotal       ";"
                 ttfil.inativos ";"
                 ttfil.ativos ";"
                 ttfil.ativos-pla ";"
                 ttfil.ativos-vvi ";"
                 ttfil.recupera-pla ";"
                 ttfil.recupera-vvi ";"
                 ttfil.novos ";"
                 ttfil.novos-con ";"
                 ttfil.novos-vvi ";"
                 ttfil.qtd-email   
                 skip.

            output close.
        end.
        else do:
            vq = vq + 1.
            if avail estab
            then assign
                    vetbnom = estab.etbnom
                    varqfil = "/admcom/relat/balclifil" +
                            string(estab.etbcod,"999") + ".csv".
            else assign
                    vetbnom = ""
                    varqfil = "/admcom/relat/balclifil" +
                              "000" + ".csv".
     
            output to value(varqfil). 

            put unformatted
            "Filial..............................;" ttfil.etbcod ";" 
            vetbnom skip
            "Total de Clientes...................;" vtotal    skip
            "Clientes Inativos...................;" ttfil.inativos     skip
            "Clientes Ativos Contrato............;" ttfil.ativos       skip
            "Clientes Ativos Compra Prazo........;" ttfil.ativos-pla   skip
            "Clientes Ativos Compra Vista........;" ttfil.ativos-vvi   skip
            "Clientes Recuperados Compra Prazo...;" ttfil.recupera-pla skip
            "Clientes Recuperados Compra Vista...;" ttfil.recupera-vvi skip
            "Clientes Novos Cadastro.............;" ttfil.novos        skip
            "Clientes Novos Compra Prazo.........;" ttfil.novos-con    skip
            "Clientes Novos Compra Vista.........;" ttfil.novos-vvi    skip
            "Clientes com email..................;" ttfil.qtd-email    skip
            skip (1).
 
            put "Filial;Codigo;Cliente;Celular;E-mail;Situação;DtAniv"
                    skip.
                    
            for each ttcli use-index i2
                        where ttcli.etbcod = ttfil.etbcod no-lock 
                             break  by ttcli.etbcod
                                    by ttcli.clinom.
             
               find clien where clien.clicod = ttcli.clicod no-lock no-error.
           
               put unformatted
                     ttcli.etbcod ";"
                     ttcli.clicod ";"
                     clien.clinom ";"
                     ttcli.celular ";"
                     ttcli.email ";"
                     v-situacli-des[ttcli.situacao] ";"
                     ttcli.dtaniver 
                     skip.
            end.
            output close.

        end.
    end.
    
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                        input "").
    end.

