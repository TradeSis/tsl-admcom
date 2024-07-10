def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.


def var vlinha as char.
def var vlimite as dec.
def var assunto as char.
def var vjuro as dec.
def var vok as log.
def var p-clicod like clien.clicod.

def var vvalor  as dec.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9005 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vlinha = tbcntgen.campo3[3].

def var vcon as int.
def var vdias as int.
def var a as char.
def var b as char.
def var prox as log init no.

do vcon = 1 to length(vlinha):

   if substring(vlinha,vcon,1) = ";"
   then prox = yes.

   if prox = no
   then  a = a + substring(vlinha,vcon,1).
   else if substring(vlinha,vcon,1) <> ";"
        then b = b + substring(vlinha,vcon,1).
   
end.

vvalor = int(a).
vdias = int(b).



if vvalor = 0
then vvalor = 1500.
if vdias = 0
then vdias = 10.

for each estab where estab.etbcod <= 900 no-lock :

   if  {/admcom/progr/conv_igual.i estab.etbcod} then next.

    for each plani where plani.movtdc = 5 
                     and plani.etbcod = estab.etbcod
                     and plani.pladat >= par-dtini 
                     and plani.pladat <= par-dtfim
                     
                     no-lock:

        if plani.biss <> 0
        then do:
            if plani.biss <= vvalor
            then next.
        end.
        else do:
            if plani.platot <= vvalor
            then next.
        end.

        if plani.desti = 1 
        then next.
    
        vok = yes.
        for each titulo where titulo.clifor = plani.desti no-lock :
            if titulo.titnat = yes 
            then next.
            if titulo.titdtven > (plani.pladat - vdias) /*14)*/
            then next.
            if titulo.titsit <> "LIB" 
            then next.
            
            vok = no.
            leave.
        end.
        if vok = yes then next.

        find first clien where clien.clicod = plani.desti no-lock.
        
        find first func where func.funcod = plani.vencod no-lock no-error.
        find first finan where finan.fincod = plani.pedcod no-lock.
        find first contnf where contnf.etbcod = plani.etbcod
                            and contnf.placod = plani.placod  no-lock
                            no-error.

        p-clicod = clien.clicod.
        {/admcom/progr/hiscli00.i}.

        vdg = "9005".
        
        output to value(par-arquivo) append.
        def var Autorizador as char.
        put unformatted
            plani.pladat        ";"
            vdg                 ";"
            plani.pladat            "|" 
            p-clicod                "|" 
            clien.clinom            "|" 
           (if plani.biss <> 0 
            then plani.biss  
            else plani.platot)      "|" 
            sal-aberto              "|" 
            (plani.pladat - maior-atraso)  "|" 
            plani.etbcod            "|" 
            Autorizador "|" plani.modcod   skip.    

        output close.
        find first repexporta where repexporta.TABELA       = "PLANI" 
                                and repexporta.Tabela-Recid = recid(plani)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9005"
                                no-lock no-error.
        if not avail repexporta 
        then do on error undo.
            create repexporta.
            ASSIGN repexporta.TABELA       = "PLANI"
                   repexporta.DATATRIG     = plani.pladat 
                   repexporta.HORATRIG     = time
                   repexporta.EVENTO       = "9005"
                   repexporta.DATAEXP      = today
                   repexporta.HORAEXP      = time
                   repexporta.BASE         = "GESTAO_EXCECAO"
                   repexporta.Tabela-Recid = recid(plani).
        end.
    end.
end.    
