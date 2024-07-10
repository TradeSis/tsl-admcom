def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9008 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.


def var v-reg as char.
def var varqenv  as char.

vdg = "9008".
for each modal where modal.modcod <> "CRE"  no-lock : 

    for each titulo where titulo.titnat = yes
                      and titulo.empcod = 19
                      and titulo.modcod = modal.modcod
                      and titulo.titdtpag >= par-dtini
                      and titulo.titdtpag <= par-dtfim
                      no-lock.

        if titulo.titdtpag >= titulo.titdtven
        then next.
        if titulo.titvlcob = titulo.titvlpag
        then next.

        
        vldesc = 0.
        if acha("AGENDAR",titulo.titobs[2]) <> ? and
           titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
        then do:
            if acha("VALDESC",titulo.titobs[2]) <> "?"
            then vldesc   = dec(acha("VALDESC",titulo.titobs[2])).
            else vldesc = 0.
        end.
        if vldesc = 0 or
           vldesc < tbcntgen.valor
        then next.

        find first forne where forne.forcod = titulo.clifor no-lock no-error.
        if not avail forne
        then next.
        
        output to value(par-arquivo) append.
        put unformatted
            titulo.titdtpag     ";"
            vdg                 ";"
            titulo.titnum   "|"
            titulo.clifor   "|"
            titulo.titvlcob "|"
            titulo.titvlpag "|"
            titulo.titpar   "|"
            vldesc          "|"
            titulo.titdtven 
            skip.
        output close.
        find first repexporta where repexporta.TABELA       = "TITULO"
                                and repexporta.Tabela-Recid = recid(TITULO)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9008"
                                no-lock no-error.
        if not avail repexporta
        then do on error undo.
            create repexporta.
            ASSIGN repexporta.TABELA       = "TITULO"
                   repexporta.DATATRIG     = titulo.titdtpag 
                   repexporta.HORATRIG     = time
                   repexporta.EVENTO       = "9008"
                   repexporta.DATAEXP      = today
                   repexporta.HORAEXP      = time
                   repexporta.BASE         = "GESTAO_EXCECAO"
                   repexporta.Tabela-Recid = recid(TITULO).
        end.
    end.
end.

