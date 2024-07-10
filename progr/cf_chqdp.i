def var v-resultado-chq as logical format "Sim/Nao".
def var v-continua-proc as logical format "Sim/Nao".

def temp-table tw-chq-conf like chq
    field sequencia  as int
    field tipo       as char
    field data-con  as date    format "99/99/9999" label "Dt.Conf."
    field data-apre  as date    format "99/99/9999" label "Dt.Apres."
    field marca-cheq as logical format "*/" label "Conf."
    field valconf    as dec.

def temp-table tw-chq-error 
    field banco    like chqtit.banco
    field agencia  like chqtit.agencia
    field conta    like chqtit.conta
    field numero   like chqtit.numero
    field valor    like chq.valor
    field tperro   as logic format "Excedente/Faltante"
    field mens     as char format "x(30)".


/* Monta Temp de cheques Selecionados por tipo */ 
Procedure Pi-Gera-chq.

def input parameter   p-etbcod     like estab.etbcod.
def input parameter   p-tp-data    as char format "x(1)".
def input parameter   p-lote-i     as int.
def input parameter   p-lote-f     as int.
def input parameter   p-datache    as date.

/******************************
def output parameter  p-valor-lote as dec.
def output parameter  p-qtd-docs   as int.
******************************/
 
def var v-vbate-che  as decimal initial 0.
def var v-kont as int initial 0.

for each tw-chq-conf :
    delete tw-chq-conf.
end.

for each tw-chq-error :
    delete tw-chq-error.
end.    

    
for each chqconf where chqconf.data-con = p-datache no-lock:

   /* message "aqui 1 " p-datache. pause 0.*/
    
    if p-lote-i <> 0 
    then if chqconf.v-int1 < p-lote-i then next.
    if p-lote-f <> 0 
    then if chqconf.v-int1 > p-lote-f then next.

    /*message "aqui 2 " p-lote-i p-lote-f. pause 0.*/

    find first chq where chq.banco   = chqconf.banco   and
                         chq.agencia = chqconf.agencia and
                         chq.conta   = chqconf.conta   and
                         chq.numero  = chqconf.numero no-lock no-error.
     
   /* message "aqui 3 " . pause 0. */

    
    find first chqtit use-index ind-1 where chqtit.banco      =  chq.banco   and
                            chqtit.agencia =  chq.agencia and 
                            chqtit.conta   =  chq.conta   and
                            chqtit.numero  =  chq.numero 
                            no-lock no-error.

    /* message "aqui 4 " . pause 0. */

    if not avail chqtit then next.
    if chqtit.etbcod <> setbcod then next.
    if p-tp-data = "V" and chq.datemi <> chq.data then next.
    if p-tp-data = "P" and chq.data   <= chq.datemi then next.

    /* message "aqui 5 " . pause 0. */


    find first tw-chq-conf where tw-chq-conf.tipo    = p-tp-data and
                                 tw-chq-conf.banco   = chq.banco  and                                           tw-chq-conf.agencia = chq.agencia and
                                 tw-chq-conf.conta   = chq.conta and
                                 tw-chq-conf.numero  = chq.numero
                                 no-lock no-error.
    if not avail tw-chq-conf 
    then do:
        create tw-chq-conf.
    end.
    assign v-vbate-che = v-vbate-che + chq.valor
           v-kont = v-kont + 1
           tw-chq-conf.sequencia   = v-kont
           tw-chq-conf.banco       = chq.banco                       
           tw-chq-conf.agencia     = chq.agencia
           tw-chq-conf.conta       = chq.conta
           tw-chq-conf.numero      = chq.numero
           tw-chq-conf.valor       = chq.valor. 
 
end.

end procedure.


/* Batimento de Temps Selecionados e Lidos */

Procedure Pi-Bate-chq.

def output parameter p-resultado as logical.

def var v-mens-erro  as char.

for each tw-chq-error:
    delete tw-chq-error.
end.    

/* Bate Existencia - I */

for each tw-chq-conf:
    
    find first chq where chq.banco    = tw-chq-conf.banco   and
                         chq.agencia  = tw-chq-conf.agencia and
                         chq.banco    = tw-chq-conf.banco   and
                         chq.conta    = tw-chq-conf.conta   and
                         chq.numero   = tw-chq-conf.numero
                no-lock no-error.
    if not avail chq
    then do:
           run Pi-Grava-erro-chq ( input tw-chq-conf.banco, tw-chq-conf.agencia,
                                   input tw-chq-conf.conta, 
                                   input tw-chq-conf.numero, no,
                                   v-mens-erro = "Cheque na cadastrado - CHQ").             next.
    end.
    
    find first  tt-chq where tt-chq.rec = recid(chq) no-error.
    if not avail tt-chq        
    then do:
         run Pi-Grava-erro-chq (input chq.banco, chq.agencia,
                               input chq.conta, chq.numero,                                                    input no,
                               input v-mens-erro = "Cheque nao Lido no Lote").
    end.


end.

/* Bate Falta - II */
for each tt-chq:
    find first chq where recid(chq) = tt-chq.rec no-lock no-error.
    if not avail chq
    then do:
          run Pi-Grava-erro-chq ( input chq.banco, chq.agencia,
                                   input chq.conta, chq.numero, chq.valor,no,
                                   v-mens-erro = "Cheque na cadastrado - CHQ").            next.
    end.
    find first  tw-chq-conf where
                tw-chq-conf.banco       = chq.banco   and                      
                tw-chq-conf.agencia     = chq.agencia and
                tw-chq-conf.conta       = chq.conta   and
                tw-chq-conf.numero      = chq.numero  and
                tw-chq-conf.valor       = chq.valor no-error.
    if not avail tw-chq-conf        
    then do:
         run Pi-Grava-erro-chq (input chq.banco, chq.agencia,
                                input chq.conta, chq.numero, 
                                input chq.valor, no,
                                v-mens-erro = "Cheque nao Selecionado no lote").     end.
 end.
 find first tw-chq-error no-error.
 if avail tw-chq-error then p-resultado = no. /* com erro */
 else p-resultado = yes.  /* sem erro */


end procedure.



/* Gravacao de Erros quando Ocorrer */
Procedure Pi-Grava-erro-chq.

def input parameter p-banco   like chqconf.banco.
def input parameter p-agencia like chqconf.agencia.
def input parameter p-conta   like chqconf.conta.
def input parameter p-numero  like chqconf.numero.
def input parameter p-valor   like chq.valor.
def input parameter p-tperro  as logical.
def input parameter p-mens    as char.


find first  tw-chq-error where 
            tw-chq-error.banco    = p-banco   and 
            tw-chq-error.agencia  = p-agencia and
            tw-chq-error.conta    = p-conta   and
            tw-chq-error.numero   = p-numero no-error.

if not avail tw-chq-error
then do:
    create tw-chq-error.
    assign  tw-chq-error.banco    = p-banco    
            tw-chq-error.agencia  = p-agencia 
            tw-chq-error.conta    = p-conta   
            tw-chq-error.numero   = p-numero 
            tw-chq-error.mens     = p-mens
            tw-chq-error.valor    = p-valor
            tw-chq-error.tperro   = p-tperro.
end.

end procedure.


Procedure Pi-Exibe-ocor.

bl-princ:
repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklcls.i
        &help = " F4 - Abandona "
        &file = tw-chq-error
        &cfield = tw-chq-error.numero
        &noncharacter = /*
        &ofield = " tw-chq-error.banco
                    tw-chq-error.agencia
                    tw-chq-error.conta 
                    tw-chq-error.mens"
        &where = " true "
        &aftfnd1 = " "
        &naoexiste1 = " next bl-princ. "
         &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                then do:
                    /*run preco-inicial.
                    next keys-loop.
                    */
                end. "    
         &otherkeys1 = " "
            /****
            if keyfunction(lastkey) = ""NEW-LINE"" OR
               keyfunction(lastkey) = ""INSERT-MODE""
            then do:
            end.
            if keyfunction(lastkey) = ""DELETE-LINE"" or
               keyfunction(lastkey) = ""CUT""
            then do:
            end.
            ****/
        &form   = " frame f-linha 10 down row 7  
                    title "" Ocorrencias em Cheques "" 
                    color with/cyan  no-label"
    }                        
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave bl-princ.
    end.    
end.

end procedure.
