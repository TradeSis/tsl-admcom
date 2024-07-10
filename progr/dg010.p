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
find first tbcntgen where tbcntgen.etbcod = 10 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vaspas as char format "x(1)".

vaspas = chr(34).

def var vlimite as dec.
def var assunto as char.
def var vldesc  as dec.
def var venvmail as log init no.
def var tvlcob as dec.
def var tvlpag as dec.
def var tdesno as dec.
def var tdesan as dec.

def var varquivo as char.

def temp-table tt-env
    field titnum like titulo.titnum
    field clifor like titulo.clifor
    index ind1 titnum clifor.

def var v-reg as char.
def var varqenv  as char.
varqenv = "/admcom/relat/enviados-dg010" + string(today,"99999999") + ".txt".
def stream s-c.

if search(varqenv) = ?
then do:
     output stream s-c to value(varqenv).
     output stream s-c close.
     end.
else do:
     input stream s-c from value(varqenv).
     repeat:
         import stream s-c unformat v-reg.
         if num-entries(v-reg,";") > 1
         then do:
              create tt-env.
              assign tt-env.titnum = trim(entry(1,v-reg,";"))
                     tt-env.clifor = int(entry(2,v-reg,";")). 
         end.
     end.
     input stream s-c close.
end.

varquivo = "/admcom/work/arquivodg010.txt".
for each modal where modal.modcod <> "CRE"  no-lock : 

    for each titulo where titulo.titnat = yes
                      and titulo.empcod = 19
                      and titulo.modcod = modal.modcod
                      and titulo.titdtpag = today:

         if can-find(first tt-env 
                           where tt-env.titnum = titulo.titnum
                             and tt-env.clifor = titulo.clifor)
         then next.                           

        if titulo.titdtpag >= titulo.titdtven
        then next.
        if titulo.titvlcob = titulo.titvlpag
        then next.
        if titulo.cxmhora = "10" 
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
        
        output stream s-c to value(varqenv) append.
            put stream s-c unformat titulo.titnum  at 1
                               ";"
                               titulo.clifor skip.    
        output stream s-c close.   
        
        output to value(varquivo).
        put unformatted
        "DESCONTO PAGAMENTO ANTECIPADO  <BR>"
        "-------------------------------- <BR>"
        "Nro.Titulo : " titulo.titnum        " <BR>"
        "Dat.Vencto : " titulo.titdtven                             " <BR>"
        "Dat.Pagato : " titulo.titdtpag                             " <BR>"
        "Val.Cobrado: " titulo.titvlcob format ">>>>>9.99"          " <BR>"
        "Val.Pago   : " titulo.titvlpag format ">>>>>9.99"          " <BR>"
        "Des.Normal : " titulo.titvldes - vldesc format ">>>>>9.99" " <BR>"
        "Des.Antec. : " vldesc format ">>>>>9.99"                   " <BR>"
        "Fornecedor : " forne.fornom format "x(20)"                 " <BR>"
        "---------------------------------"                         " <BR>"
        . 
        output close.
        run /admcom/progr/envia_dg.p("10",varquivo).

        assign
            tvlcob = tvlcob + titulo.titvlcob
            tvlpag = tvlpag + titulo.titvlpag
            tdesno = tdesno + titulo.titvldes - vldesc
            tdesan = tdesan + vldesc
            venvmail = yes
            titulo.cxmhora = "10".
            
        pause 1.
      
    end.
  
end.

