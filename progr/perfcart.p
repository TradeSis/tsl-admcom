{admcab.i}

def buffer btitulo for titulo.

def var vtime1 as int.
def var vtime2 as int. 
def var vtime3 as int.

def var vframeind as int.

def var varquivo as char.

def var vcargo-cod as int.
def temp-table tt-dados
    field chave as char
    field denomina as char
    field total as dec format ">>>,>>>,>>9.99"
    field perc as dec
    field venc_total as dec format ">>>,>>>,>>9.99"
    field venc_perc as dec
    field perc1 as dec
    field perc2 as dec
    index ind01 chave.
    
def temp-table tt-clifor
    field clfcod     like clien.clicod
    field chave      as char
    index ind02 clfcod.
    
def temp-table tt-idade
    field clfcod     like clien.clicod
    field dtnasc     like cpfis.dtnasc
    field idade      as int
    index ind03 clfcod.

def var vmes as int format "99".
def var vano as int format "9999".
def var vdtref as date no-undo format "99/99/9999".
def var vvariavel as char.
def var vidade as int.
def var v-escola as char.
def var vescolaridade as char.

def var vidadei as int.
def var vidadef as int.

def var vdtini as date.
def var vdtfin as date.

def var vgravar as log format "Sim/Nao" init no.

def var vtipo as char format "x(16)" extent 3
                        init ["BAIRRO",
                              "IDADE",
                              "NOVOS"].
                              
vmes = month(today).
vano = year(today).
vdtref = today.
vvariavel = "BAIRRO".

update /*vmes label "Vencimentos Mes" vano label "Ano"*/
       vdtini label "Periodo" vdtfin label "a" vdtref label "Data Ref. Atrasos"
/*       vgravar label "Deseja Gravar as Informacoes Geradas nos Dados dos Client~ es ?"*/
    with frame fopcoes side-labels.
    
def var vetbcod like estab.etbcod.

do on error undo.
    update vetbcod label "Estab" with frame fopcoes side-labels.
    if vetbcod <> 0
    then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento invalido".
        undo.
    end.
    end.
    
end.

display vtipo
        with frame fesc centered row 10 overlay
        no-label.
    choose field vtipo auto-return
    with frame fesc.
hide frame fesc no-pause.

vframeind = frame-index.

if vframeind = 1
then vvariavel = "BAIRRO".
else if vframeind = 2
     then vvariavel = "IDADE".
     else vvariavel = "NOVOS".
                         
if vvariavel = "IDADE"
then update vidadei label "Idade" vidadef label "a"
            with frame fidade overlay side-labels.
else vidadei = ?.            


/*
vdtini = date(vmes,1,vano).
vdtfin = vdtini + 35.
vdtfin = date(month(vdtfin),01,year(vdtfin)) - 1.
*/

for each tt-dados.
    delete tt-dados.
end.
    
for each tt-clifor.
    delete tt-clifor.
end.

for each tt-idade.
    delete tt-idade.
end.    

def var vconta as int.

hide message no-pause.
message "Carteira Total".

vconta = 0.
/*
message vdtini vdtfin vdtref view-as alert-box.
*/

vtime1 = time.

for each titulo where titulo.titnat = no
                  and titulo.modcod = "CRE"
                  and titulo.titsit = "LIB" 
                  and (if vetbcod <> 0 
                       then titulo.etbcod = vetbcod
                       else true)
                  and titulo.titdtven >= vdtini
                  and titulo.titdtven <= vdtfin
                      no-lock.
                      
    find clien where clien.clicod = titulo.clifor no-lock no-error.
    if not avail clien
    then next.
    
    vconta = vconta + 1.
    if vconta mod 100 = 0
    then do:
        hide message no-pause.
        message "Carteira Total" vconta string(time - vtime1,"hh:mm:ss").
    end.

    find first tt-clifor where tt-clifor.clfcod = clien.clicod no-error.
    if not avail tt-clifor
    then do:
        create tt-clifor.
        tt-clifor.clfcod = clien.clicod.
        hide message no-pause.
        message tt-clifor.clfcod.
    end.

    if vvariavel = "bairro"
    then do: 

        find first tt-dados where tt-dados.chave = clien.bairro[1] no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = clien.bairro[1].
            tt-dados.denomina = tt-dados.chave.
            
            tt-clifor.chave = tt-dados.chave.

        end.
    end.
    else if vvariavel = "IDADE"
    then do: 
        if clien.dtnasc = ? or clien.dtnasc > today
        then vidade = 0.
        else vidade = (today - clien.dtnasc) / 365.

        if vidade < vidadei or
           vidade > vidadef
        then next.
           
        find first tt-dados where tt-dados.chave = string(vidade,">>>9")
            no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = string(vidade,">>>9").
            tt-dados.denomina = string(vidade,">>>9") + " anos".
            
            tt-clifor.chave = tt-dados.chave.

        end.

        if vidadei <> ?       and
           vidade  >= vidadei and
           vidade  <= vidadef
        then do:           
            find first tt-idade where tt-idade.clfcod = clien.clicod no-error.
            if not avail tt-idade
            then do:
                create tt-idade.
                tt-idade.clfcod = clien.clicod.
                tt-idade.dtnasc = clien.dtnasc.
                tt-idade.idade  = vidade.
            end.
        end.            
    end.
    else if vvariavel = "novos"
    then do: 

        find first btitulo where btitulo.titnat = titulo.titnat
                             and btitulo.clifor = titulo.clifor
                             and btitulo.modcod = titulo.modcod
                             and btitulo.titnum <> titulo.titnum
                                 no-lock no-error.
        if avail btitulo
        then next.

        find first tt-dados where tt-dados.chave = string(titulo.titpar)
            no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = string(titulo.titpar).
            tt-dados.denomina = "Parc. " + string(titulo.titpar,"99").
            
            tt-clifor.chave = tt-dados.chave.

        end.
    end.

    tt-dados.total = tt-dados.total + titulo.titvlcob.
    
    if (titulo.titdtpag = ? or
        titulo.titdtpag > vdtref)
    then do:
        tt-dados.venc_total = tt-dados.venc_total + titulo.titvlcob.    
        hide message no-pause.
        message "Carteira Vencida" vconta string(time - vtime1,"hh:mm:ss").
    end.        

    find first tt-dados where tt-dados.chave = ? no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.chave = ?.
        tt-dados.denomina = "Total Geral".
    end.
    tt-dados.total = tt-dados.total + titulo.titvlcob.
    
    if (titulo.titdtpag = ? or
        titulo.titdtpag > vdtref)
    then tt-dados.venc_total = tt-dados.venc_total + titulo.titvlcob.
        
end.

/*
message 1 view-as alert-box.
*/

hide message no-pause.
message "Carteira Paga".

for each titulo where titulo.titnat = no
                  and titulo.titsit = "PAG"
                  and (if vetbcod <> 0 
                       then titulo.etbcod = vetbcod
                       else true)
                  and titulo.titdtpag >= vdtini - 30
                  and titulo.titdtpag < vdtref
                  and titulo.titdtven >= vdtini
                  and titulo.titdtven <= vdtfin
                      no-lock.
                      
    if titulo.modcod <> "CRE"
    then next.
    
    find clien where clien.clicod = titulo.clifor no-lock no-error.
        
    vconta = vconta + 1.
    if vconta mod 100 = 0
    then do:
        hide message no-pause.
        message "Carteira Paga" vconta string(time - vtime1,"hh:mm:ss").
    end.

    find first tt-clifor where tt-clifor.clfcod = clien.clicod no-error.
    if not avail tt-clifor
    then do:
        create tt-clifor.
        tt-clifor.clfcod = clien.clicod.
    end.
    
    if vvariavel = "bairro"
    then do: 

        find first tt-dados where tt-dados.chave = clien.bairro[1] no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = clien.bairro[1].
            tt-dados.denomina = tt-dados.chave.
            
            tt-clifor.chave = tt-dados.chave.

        end.
    end.
    else if vvariavel = "IDADE"
    then do: 
        if clien.dtnasc = ? or clien.dtnasc > today
        then vidade = 0.
        else vidade = (today - clien.dtnasc) / 365.

        find first tt-dados where tt-dados.chave = string(vidade,">>>9")
            no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = string(vidade,">>>9").
            tt-dados.denomina = string(vidade,">>>9") + " anos".
            
            tt-clifor.chave = tt-dados.chave.

        end.

        if vidadei <> ?       and
           vidade  >= vidadei and
           vidade  <= vidadef
        then do:           
            find first tt-idade where tt-idade.clfcod = clien.clicod no-error.
            if not avail tt-idade
            then do:
                create tt-idade.
                tt-idade.clfcod = clien.clicod.
                tt-idade.dtnasc = clien.dtnasc.
                tt-idade.idade  = vidade.
            end.
        end.            
    end.                    
    else if vvariavel = "novos"
    then do: 

        find first btitulo where btitulo.titnat = titulo.titnat
                             and btitulo.clifor = titulo.clifor
                             and btitulo.modcod = titulo.modcod
                             and btitulo.titnum <> titulo.titnum
                                 no-lock no-error.
        if avail btitulo
        then next.

        find first tt-dados where tt-dados.chave = string(titulo.titpar)
            no-error.
        if not avail tt-dados
        then do:
            create tt-dados.
            tt-dados.chave = string(titulo.titpar).
            tt-dados.denomina = "Parc. " + string(titulo.titpar,"99").
            
            tt-clifor.chave = tt-dados.chave.

        end.
    end.    
                    
    tt-dados.total = tt-dados.total + titulo.titvlcob.
    if (titulo.titdtpag = ? or
        titulo.titdtpag > vdtref)
    then do:
        tt-dados.venc_total = tt-dados.venc_total + titulo.titvlcob.    
        hide message no-pause.
        message "Carteira Vencida" vconta string(time - vtime1,"hh:mm:ss").
    end.        

    find first tt-dados where tt-dados.chave = ? no-error.
    if not avail tt-dados
    then do:
        create tt-dados.
        tt-dados.chave = ?.
        tt-dados.denomina = "Total Geral".
    end.
    tt-dados.total = tt-dados.total + titulo.titvlcob.
    
    if (titulo.titdtpag = ? or
        titulo.titdtpag > vdtref)
    then tt-dados.venc_total = tt-dados.venc_total + titulo.titvlcob.
        
end.

/*
message 2 view-as alert-box.
*/

vtime2 = time.
hide message no-pause.
message string(vtime2 - vtime1,"hh:mm:ss").

if vgravar = yes
then do:
    hide message no-pause.
    message "Aguarde... Gravando Dados...".
    for each tt-dados where tt-dados.chave <> ?.
        tt-dados.perc1 = tt-dados.venc_total / tt-dados.total * 100.
/***        
        find first credscore where credscore.campo = "AGSCORE"
                               and credscore.desc-campo = vtadcod
                               and credscore.vl-char = tt-dados.chave
            exclusive-lock no-error.
        if not avail credscore
        then do:
            create credscore.
            credscore.campo = "AGSCORE".
            credscore.desc-campo = vtadcod.
            credscore.vl-char = tt-dados.chave.
        end.
        credscore.valor = tt-dados.perc1.
        credscore.observacoes = "DTINI="   + string(vdtini)  +
                                "|DTFIN="  + string(vdtfin)  +
                                "|FUNCOD=" + string(sfuncod) +
                                "|DATA="   + string(today).

        for each tt-clifor where tt-clifor.chave = tt-dados.chave.
            find first agscore where agscore.clfcod = tt-clifor.clfcod
                                 and agscore.campo  = tt-dados.campo
                                 and agscore.tabela = tt-dados.tabela
                                     exclusive-lock no-error.
            if not avail agscore
            then do:
                create agscore.
                agscore.clfcod = tt-clifor.clfcod.
                agscore.campo  = tt-dados.campo.
                agscore.tabela = tt-dados.tabela.
            end.
            agscore.agsponto = tt-dados.perc1 * 100.
        end.
    end.
    ***/
end.    

vtime3 = time.
hide message no-pause.
message string(vtime3 - vtime1,"hh:mm:ss").
/***
if vtadcod = "IDADE"
then do:
output to value("../impress/cli_idade" + string(time)).
    for each tt-idade.
        put unformatted
            tt-idade.clfcod at 01
            tt-idade.dtnasc at 10
            tt-idade.idade  at 22
            skip.
    end.        
output close.
***/

find first tt-idade no-error.
if avail tt-idade
then
message "Arquivo de Clientes: " "../impress/cli_idade" + string(time)
    view-as alert-box.
end.    

message string(vtime1,"hh:mm:ss")
        string(vtime2,"hh:mm:ss")
        string(vtime3,"hh:mm:ss") view-as alert-box.
        
    
varquivo = "./perfcart." + string(time).
          {mdad_l.i
           &Saida     = "value(varquivo)"
           &Page-Size = "0"
           &Cond-Var  = "150"
           &Page-Line = "66"
           &Nom-Rel   = ""GERAL""
           &Nom-Sis   = """Perfil da Carteira de Cobranca"""
           &Tit-Rel   = """POSICAO EM "" + string(today) "
           &Width     = "150"
           &Form      = "frame f-cabcab"}
           
put "Parametros" skip
    "Vencimentos Mes: " vmes 
    " - Ano: " vano  
    " ( " vdtini 
    " a " vdtfin 
    ") - Data Ref. Atrasos: " vdtref 
    skip(2).

def buffer btt-dados for tt-dados.
find first btt-dados where btt-dados.chave = ?.
btt-dados.perc = 100.

put "                    CARTEIRA TOTAL                   "
     " CART. TOTAL VENCIDA "
     " % VENC "
     " % VENC" skip.
     
btt-dados.venc_perc = btt-dados.venc_total * 100 / btt-dados.total.

put "                    " btt-dados.total  "                      "     
     btt-dados.venc_total
     btt-dados.venc_perc skip.
     
for each tt-dados where tt-dados.chave <> ? by tt-dados.denomina.
tt-dados.perc = tt-dados.total * 100 / btt-dados.total.
tt-dados.venc_perc = tt-dados.venc_total * 100 / btt-dados.venc_total.
tt-dados.perc1 = tt-dados.venc_total / tt-dados.total * 100.
tt-dados.perc2 = tt-dados.venc_total / btt-dados.total * 100.

   disp /*** tt-dados.chave column-label "Codigo"***/            
     tt-dados.denomina format "x(30)" column-label "Descricao"    
     tt-dados.total format ">>>,>>>,>>9.99" column-label "R$"                  ~      tt-dados.perc format ">>>9.99%" column-label "%"             
     tt-dados.venc_total format ">>>,>>>,>>9.99" column-label "R$"             ~      tt-dados.venc_perc format ">>>9.99%" column-label "%"        
     tt-dados.perc1 format ">>>9.99%" column-label "Cart/Carg"    
     tt-dados.perc2 format ">>>9.99%" column-label "Cart/Geral"   
     with frame f-mostra down width 120.                      
end.
btt-dados.perc1 = ?.
btt-dados.perc = btt-dados.total * 100 / btt-dados.total.
btt-dados.venc_perc = btt-dados.venc_total * 100 / btt-dados.venc_total.
btt-dados.perc1 = btt-dados.venc_total / btt-dados.total.
btt-dados.perc2 = btt-dados.venc_total / btt-dados.total * 100.
disp /***btt-dados.chave when btt-dados.chave <> ? no-label***/
     btt-dados.denomina format "x(30)" no-label
     btt-dados.total format ">>>,>>>,>>9.99"  no-label
     btt-dados.perc format ">>>9.99%" no-label 
     btt-dados.venc_total format ">>>,>>>,>>9.99" no-label
     btt-dados.venc_perc format ">>>9.99%" no-label
     btt-dados.perc1 format ">>>>9.99%" no-label when btt-dados.perc1 <> ?
     btt-dados.perc2 format ">>>>>9.99%" no-label
     with frame f-mostra1 down width 120.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.          
