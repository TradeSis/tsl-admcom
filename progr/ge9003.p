/* ge9003.p*/
def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.

def var vdg as char.

def var vlimite as dec.
def var assunto as char.
def var vjuro as dec.
def var diasdeatraso as int.

{/admcom/progr/cntgendf.i}

find first tbcntgen where tbcntgen.tipcon = 9003 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

for each modal where modal.modcod <> "CRE"  no-lock : 

    for each titulo where titulo.titnat = yes
                      and titulo.empcod = 19
                      and titulo.modcod = modal.modcod
                      and titulo.titdtpag >= par-dtini 
                      and titulo.titdtpag <= par-dtfim
                      
                      no-lock:
        if titulo.titvljur = 0 or titulo.titvlpag <= titulo.titvlcob
        then next.
        vjuro = titulo.titvljur.
        
        diasdeatraso = 0.


        if vjuro = 0 
        then do :
            if titulo.titvlpag > titulo.titvlcob 
            then do : 
                vjuro = titulo.titvlpag - titulo.titvlcob.
            end.
        end.
        find first forne where forne.forcod = titulo.clifor no-lock no-error.
        if not avail forne
        then next.


        if forne.forcod = 101609 then next.
        if forne.forcod = 156 then next. 
        if forne.forcod = 103462 then next. 
        if forne.forcod = 103641 then next. 
        if forne.forcod = 103542 then next. 
        if forne.forcod = 110659 then next. 
        
            
       diasdeatraso = titdtpag - titdtven.   

        vdg = "9003".
        output to value(par-arquivo) append.
        put unformatted     
                titulo.titdtpag     ";"
                vdg                 ";"
                titulo.titnum                           "|"
                forne.fornom  " (" forne.forcod ") "    "|"
                titulo.titvlcob                         "|"
                titulo.titvlpag                         "|"
                titulo.titpar                           "|"
                vjuro                                   "|"
                titulo.titdtven                         "|"
                diasdeatraso
                 skip.
        output close.
        do on error undo.
            find first repexporta where 
                                    repexporta.TABELA       = "TITULO"
                                and repexporta.Tabela-Recid = recid(TITULO)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9003"
                                no-lock no-error.
            if not avail repexporta
            then do.
                create repexporta.
                ASSIGN repexporta.TABELA       = "TITULO"
                       repexporta.DATATRIG     = titulo.titdtpag
                       repexporta.HORATRIG     = time
                       repexporta.EVENTO       = "9003"
                       repexporta.DATAEXP      = today
                       repexporta.HORAEXP      = time
                       repexporta.BASE         = "GESTAO_EXCECAO"
                       repexporta.Tabela-Recid = recid(TITULO).
            end.
        end.
    end.
end.    
