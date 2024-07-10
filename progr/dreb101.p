{admcab.i}               
def var vdtini      as date initial today.
def var vdtfin      as date initial today.
def var vdias       as int.
def var vetbcod     like estab.etbcod no-undo.
def var vcontnov    like fin.titulo.titvlcob.
def var ventrnov       like fin.titulo.titvlcob.
def var vtotcontnov    like fin.titulo.titvlcob.
def var vtotentrnov    like fin.titulo.titvlcob.
def var vatraso as int label "Atraso".


def temp-table tt-contrato
    field contnum like fin.contrato.contnum.


form with frame flin width 160.


update vetbcod colon 20.
if vetbcod > 0
then do:
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label.
end.
else
    display "GERAL " @ estab.etbnom .

update vdtini label "Data Inicial"  colon 20 format "99/99/9999"
       vdtfin label "Data Final"    format "99/99/9999".
update vdias  label "Dias de Atraso" colon 20
       with side-label color white/cyan width 80 row 4.

def var vlp as log format "Sim/Nao".
message "Com LP" update vlp.

def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/dreb001." + string(time).
else varquivo = "l:~\relat~\dreb001." + string(time).

def var p-pagas as int.
def var p-atras as int.
def var v-pagas as dec format "->>>,>>>,>>>.99".
def var v-atras as dec format "->>>,>>>,>>>.99".

def var vdtaux as date.
def var tp-pagas as int.
def var tp-atras as int.
def var tv-pagas as dec format "->>>,>>>,>>>.99".
def var tv-atras as dec format "->>>,>>>,>>>.99".

def temp-table tt-titulo like fin.titulo.

def buffer ctitulo for fin.titulo.
def buffer dtitulo for d.titulo.

def stream stela.
output stream stela to terminal.

def var vdtfincont as date.
run cel-titulo.

{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "134"
    &Page-Line = "66"
    &Nom-Rel   = """DREB001"""
    &Nom-Sis   = """SISTEMA CREDIARIO"""
    &Tit-Rel   = """CLIENTES COM PAGAMENTO ENTRE "" +
                        string(vdtini) + "" E "" +
                        string(vdtfin) + "" COM ATRASO MAIOR QUE "" +
                        string(vdias)  + "" DIAS"""
    &Width     = "134"
    &Form      = "frame f-cab"}

p-pagas = 0.
p-atras = 0.
v-pagas = 0.
v-atras = 0.

for each estab where
            (if vetbcod > 0 then estab.etbcod = vetbcod else true)
             no-lock .

    disp stream stela "Processando... " estab.etbcod  label "Filial"
            with frame f-disp 1 down centered no-box color message.
    pause 0.        
    
    p-pagas = 0.
    p-atras = 0.
    v-pagas = 0.
    v-atras = 0.
            
    for each tt-titulo use-index titdtpag
            where tt-titulo.empcod    = wempre.empcod and
                      tt-titulo.titnat    = no            and
                      tt-titulo.modcod    = "CRE"         and
                      tt-titulo.titdtpag >= vdtini        and
                      tt-titulo.titdtpag <= vdtfin        and
                      tt-titulo.etbcod    = estab.etbcod 
                                            no-lock.
                                             
    disp stream stela tt-titulo.titnum 
            with frame f-disp.
    pause 0.
    
    
    find last ctitulo use-index titnum where 
                            ctitulo.empcod = tt-titulo.empcod and
                            ctitulo.titnat = tt-titulo.titnat and
                            ctitulo.modcod = tt-titulo.modcod and
                            ctitulo.etbcod = tt-titulo.etbcod and
                            ctitulo.clifor = tt-titulo.clifor and
                            ctitulo.titnum = tt-titulo.titnum no-lock no-error.
                            
    if not avail ctitulo
    then  do:
    
        find last dtitulo use-index titnum where 
                            dtitulo.empcod = tt-titulo.empcod and
                            dtitulo.titnat = tt-titulo.titnat and
                            dtitulo.modcod = tt-titulo.modcod and
                            dtitulo.etbcod = tt-titulo.etbcod and
                            dtitulo.clifor = tt-titulo.clifor and
                            dtitulo.titnum = tt-titulo.titnum no-lock no-error.
     
        vdtfincont = dtitulo.titdtven.
    end.
    else
        vdtfincont = ctitulo.titdtven.

    vatraso = 0. 
    vatraso = tt-titulo.titdtpag - vdtfincont.

    if vatraso < 90 then next.
    
    ventrnov = 0.
    vcontnov = 0.
            

    if tt-titulo.moecod = "NOV" or tt-titulo.etbcobra > 900
    then do:
        find first tt-contrato 
        where tt-contrato.contnum = int(tt-titulo.titnum) no-lock no-error.
                         
        if not avail tt-contrato
        then do:
            create tt-contrato.
            assign tt-contrato.contnum = int(tt-titulo.titnum).
            
            for each d.titulo where  d.titulo.titdtemi = tt-titulo.titdtpag and
                                     d.titulo.clifor   = tt-titulo.clifor   and
                                     d.titulo.titnum  <> tt-titulo.titnum
                                     no-lock.
                
                if d.titulo.titpar = 0  
                then do:
                    ventrnov = ventrnov + d.titulo.titvlpag.
                end.
                else do:
                    vcontnov = vcontnov + d.titulo.titvlcob.
                end.
                                    
            end.

            for each fin.titulo where  
                            fin.titulo.titdtemi = tt-titulo.titdtpag and
                            fin.titulo.clifor   = tt-titulo.clifor   and
                            fin.titulo.titnum   <> tt-titulo.titnum
                            no-lock.
                
                if fin.titulo.titpar = 0 
                then do:
                    ventrnov = ventrnov + fin.titulo.titvlpag.
                end.
                else do:
                    vcontnov = vcontnov + fin.titulo.titvlcob.
                end.
                                    
            end.

           find clien where clien.clicod = tt-titulo.clifor no-lock.
            display 
                tt-titulo.etbcod                     
                tt-titulo.clifor
                clien.clinom   format "x(25)"
                tt-titulo.titnum
                tt-titulo.titpar  
                tt-titulo.moecod
                vdtfincont label "Dt.Fin.Contr."
                tt-titulo.titdtpag
                vatraso
                ventrnov @ tt-titulo.titvlcob
                tt-titulo.titjuro 
                ventrnov @ tt-titulo.titvlpag
                with frame flin no-box width 160 down.
                down with frame flin.

            vtotentrnov = vtotentrnov + ventrnov.
            vtotcontnov = vtotcontnov + vcontnov.

     
            
        end.
        else next.                 
    end.                     
                         
    if tt-titulo.moecod <> "NOV" and  tt-titulo.etbcobra < 900
    then do:
     
        p-pagas = p-pagas + 1.
        tp-pagas = tp-pagas + 1.
        v-pagas = v-pagas + tt-titulo.titvlcob.
        tv-pagas = tv-pagas + tt-titulo.titvlcob.
    

        find clien where clien.clicod = tt-titulo.clifor no-lock.
        display tt-titulo.etbcod                     
                tt-titulo.clifor
                clien.clinom   format "x(25)"
                tt-titulo.titnum
                tt-titulo.titpar  
                tt-titulo.moecod
                vdtfincont label "Dt.Fin.Contr."
                tt-titulo.titdtpag
                vatraso
                tt-titulo.titvlcob 
                tt-titulo.titjuro  
                tt-titulo.titvlpag 
                with frame flin no-box width 160 down.
        down with frame flin.

        p-atras = p-atras + 1.
        tp-atras = tp-atras + 1.
        v-atras = v-atras + tt-titulo.titvlcob.
        tv-atras = tv-atras + tt-titulo.titvlcob.
    end.
    
    
    
end.

if  p-pagas > 0 or
    p-atras > 0
then do:

put skip (2)
    "TOTAL DE ENTRADAS DE NOVACAO      VALOR: " vtotentrnov
    skip (2)
    "TOTAL DE SALDO DE NOVACAO         VALOR  " vtotcontnov
    skip (2)
    .


put /***
    "PARCELAS PAGAS NO PERIODO -       VALOR: " v-pagas 
    skip
    ***/
    skip
    "PARCELAS PAGAS ATRASO " + string(VDIAS,">>>9") + " - VALOR: " 
    format "x(41)" v-atras
    skip
    fill("-",138) format "x(138)"
    skip(1)
    .
end.
end.

output stream stela close.

/*
put /*fill("-",138) format "x(138)" skip(1)*/
    "T O T A L   G E R A L"
    skip.


put "PARCELAS PAGAS NO PERIODO -  QUANTIDADE: " tp-pagas 
    skip
    "                                  VALOR: " tv-pagas
    skip
    "PARCELAS PAGAS ATRASO " + string(VDIAS,">>>9") + " - QUANTIDADE: " 
    format "x(41)" tp-atras
    skip
    "                                  VALOR: " tv-atras
    skip
    .
*/
output close.
if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
{mrod.i}.
end.

procedure cel-titulo:

    for each tt-titulo.
        delete tt-titulo.
    end.

    for each estab where
            (if vetbcod > 0 then estab.etbcod = vetbcod else true)
            no-lock .

        disp stream stela "Processando... " estab.etbcod  label "Filial"
            with frame f-disp 1 down centered no-box color message.
        pause 0.        
    

        do vdtaux = vdtini to vdtfin :
        
        for each fin.titulo use-index titdtpag
            where fin.titulo.empcod    = wempre.empcod and
                      fin.titulo.titnat    = no            and
                      fin.titulo.modcod    = "CRE"         and
                      fin.titulo.titdtpag  = vdtaux        and
                      fin.titulo.etbcod    = estab.etbcod 
                                            no-lock:
            disp stream stela fin.titulo.titnum 
                with frame f-disp.
            pause 0.
                
            create tt-titulo.
            buffer-copy fin.titulo to tt-titulo.
            
        end.
        end.
        if vlp then
        do:
        do vdtaux = vdtini to vdtfin:
        for each d.titulo use-index titdtpag
            where d.titulo.empcod    = wempre.empcod and
                      d.titulo.titnat    = no            and
                      d.titulo.modcod    = "CRE"         and
                      d.titulo.titdtpag = vdtaux        and
                      d.titulo.etbcod    = estab.etbcod 
                                            no-lock:
            disp stream stela d.titulo.titnum 
                with frame f-disp.
            pause 0.
                
            find first tt-titulo where  tt-titulo.empcod = d.titulo.empcod and
                                        tt-titulo.titnat = d.titulo.titnat and
                                        tt-titulo.modcod = d.titulo.modcod and
                                        tt-titulo.etbcod = d.titulo.etbcod and
                                        tt-titulo.CliFor = d.titulo.clifor and
                                        tt-titulo.titnum = d.titulo.titnum and
                                        tt-titulo.titpar = d.titulo.titpar
                                        no-error.
                                        
            if avail tt-titulo then next.
                                        
            create tt-titulo.
            buffer-copy d.titulo to tt-titulo.
            
        end.
        end.
        end.
    end.
end procedure.
