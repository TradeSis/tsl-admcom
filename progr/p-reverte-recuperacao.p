{admcab.i new}

def var vetbcod        as integer.
def var vnumero        as integer.
def var vserie         as char.
def var vmetodo        as char.
def var varquivo       as char.
def var vretorno       as char.
def var vemite-cnpj    as char.
def var v-comando      as char.
def var p-valor        as char.

def buffer bplani      for plani.

def new shared var varq-lista     as char.

def var vlinha         as char.

def var vok            as log.

def new shared temp-table tt-plani like plani
         field natoper    as char.
def new shared temp-table tt-movim like movim.

def temp-table tt-reverte
    field etbcod    as integer
    field outro-etb as integer
    field numero    as integer
    field serie     as char
    index idx01 etbcod numero.

form vetbcod    at 03   label "Filial"         skip
     vnumero    at 05   label "Nota"         skip
     vserie     at 04   label "Serie"         skip
        with frame f01 side-label.

assign vserie = "1".

assign varq-lista = "/admcom/audit/reverte_junho.csv".

update varq-lista format "x(50)" label "Arquivo"   
        with frame f05 side-labels title "Informe o caminho do arquivo com a lis~ta de notas".
/*
if search(varq-lista) = ? or varq-lista = "/admcom/audit/"
then do:

    update vetbcod format ">>>9"
            with frame f01.

    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
    
        message "Estabelecimento Invalido!" view-as alert-box.
        undo,retry.
                
    end.                
                
    update vnumero format ">>>>>>9"
            with frame f01.
                
    update vserie format "x(02)"
            with frame f01.
            
    run p-recupera-nota.        

end.        
else do:
 */
    input from value(varq-lista).

    repeat:

        import vlinha.

        if num-entries(vlinha,";") = 2
        then do:
        
            create tt-reverte.
            assign tt-reverte.etbcod = int(entry(1,vlinha,";"))
                   tt-reverte.numero = int(entry(2,vlinha,";"))
                   tt-reverte.serie  = "1".
                   
            if tt-reverte.etbcod = 993
            then assign tt-reverte.outro-etb = 998.
                   
            if tt-reverte.etbcod = 995
            then assign tt-reverte.outro-etb = 991.
            
        end.

    end.
/*
end.
*/
for each tt-reverte where tt-reverte.etbcod > 0 no-lock,

    first estab where estab.etbcod = tt-reverte.etbcod
                                no-lock,
            
    each plani where plani.etbcod = tt-reverte.outro-etb
                     and plani.numero = tt-reverte.numero
                     and plani.serie = tt-reverte.serie
                     and plani.pladat >= 06/01/2012 
                     and plani.pladat <= 06/30/2012
                                no-lock:
                                
        find first bplani where bplani.etbcod = tt-reverte.etbcod
                            and bplani.numero = tt-reverte.numero
                            and bplani.serie = tt-reverte.serie
                            and bplani.pladat = plani.pladat
                            and bplani.placod = plani.placod
                            and bplani.platot = plani.platot
                                                no-lock no-error.
        
        if avail bplani
        then
        display bplani.etbcod 
                bplani.numero (count) with frame f010 down.
                            
end.


/*********************************************************************

        find first planiaux where planiaux.etbcod = plani.etbcod
                              and planiaux.emite  = plani.emite
                              and planiaux.serie = plani.serie
                              and planiaux.numero = plani.numero
                              and planiaux.nome_campo = "RECUPERADA"
                               no-lock no-error.
        if not avail planiaux
        then do:
            
            create planiaux.
            assign planiaux.etbcod = plani.etbcod
                   planiaux.emite  = plani.emite
                   planiaux.serie = plani.serie
                   planiaux.numero = plani.numero
                   planiaux.nome_campo = "RECUPERADA"
                   planiaux.valor_campo = string(today,"99/99/9999").
               
        end.
        
        assign vok     = yes
               vok-aux = yes.

    end.

    for each tt-movim where tt-movim.placod <> ? no-lock.

        create movim.
        buffer-copy tt-movim to movim.

        assign vok     = yes
               vok-aux = yes.

    end.

    display vok-aux format "Sim/Nao" label "Atu" with frame f-mostra down.    

    find first tt-plani.
    
    if vgera-log
    then do:
    
        if tt-plani.numero = ?
        then put stream str-log
                "Inutilizada" skip.
        else        
        put stream str-log
            vok-aux format "Sim/Nao"  skip.
    end.
    
end procedure.

procedure p-verifica-plani-repetido:        
 
assign vemite-dif    = no
       vdesti-dif    = no
       vopccod-dif   = no
       vplatot-dif   = no
       vitens-dif    = no
       vcont-prod1   = 0
       vcont-prod2   = 0.
    
for each tt-plani where tt-plani.numero <> ?.    

    find first plani where plani.etbcod = tt-plani.etbcod
                       and plani.placod = tt-plani.placod
                       and plani.serie = tt-plani.serie
                             no-lock no-error.
                              
    if not avail plani
    then find first plani where plani.etbcod = tt-plani.etbcod
                            and plani.movtdc = tt-plani.movtdc
                            and plani.emite = tt-plani.emite
                            and plani.serie = tt-plani.serie
                            and plani.numero = tt-plani.numero
                                no-lock no-error.
    
    
    if not avail plani and tt-plani.etbcod = 993
    then do:
    
        find first plani where plani.etbcod = 998
                           and plani.placod = tt-plani.placod
                           and plani.serie = tt-plani.serie
                                 no-lock no-error.
                              
        if not avail plani
        then find first plani where plani.etbcod = 998
                                and plani.movtdc = tt-plani.movtdc
                                and plani.emite = 998
                                and plani.serie = tt-plani.serie
                                and plani.numero = tt-plani.numero
                                    no-lock no-error.
    
    
    end.
    
    if not avail plani and tt-plani.etbcod = 995
    then do:
    
        find first plani where plani.etbcod = 991
                           and plani.placod = tt-plani.placod
                           and plani.serie = tt-plani.serie
                                 no-lock no-error.
                              
        if not avail plani
        then find first plani where plani.etbcod = 991
                                and plani.movtdc = tt-plani.movtdc
                                and plani.emite = 991
                                and plani.serie = tt-plani.serie
                                and plani.numero = tt-plani.numero
                                    no-lock no-error.
    
    end.
    
    if avail plani
    then do:
    
    if plani.emite <> tt-plani.emite
    then assign vemite-dif = yes.
     
    if plani.desti <> tt-plani.desti
    then assign vdesti-dif = yes.
    
    if plani.opccod <> tt-plani.opccod
    then assign vopccod-dif = yes.
    
    if plani.platot <> tt-plani.platot
    then assign vplatot-dif = yes.
                                
    for each movim where movim.etbcod = tt-plani.etbcod
                     and movim.placod = tt-plani.placod
                     and movim.movdat = tt-plani.pladat
                                 no-lock.
                                 
        assign vcont-prod1 = vcont-prod1 + movim.procod. 
                                 
    end.                                                     

    for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                        and tt-movim.placod = tt-plani.placod
                        and tt-movim.movdat = tt-plani.pladat
                                   no-lock.
                                 
        assign vcont-prod2 = vcont-prod2 + tt-movim.procod.                         end.
    
    if vcont-prod1 <> vcont-prod2
    then assign vitens-dif = yes.
    else assign vitens-dif = no.
    
    end.
    else assign vdesti-dif = yes.
    
end.

find first tt-plani no-lock.

find first tipmov where tipmov.movtdc = tt-plani.movtdc no-lock no-error.

down with frame f-mostra.

display tt-plani.etbcod     format ">>9"       label "Fil"
        tt-plani.numero     format ">>>>>>>9"  label "Nota"
        vdesti-dif       format "Sim/Nao"   label "Desti"
        vopccod-dif      format "Sim/Nao"   Label "CFOP"
        vplatot-dif      format "Sim/Nao"   label "Vl Not"
        vitens-dif       format "Sim/Nao"   label "Itens"
        tt-plani.opccod     format ">>>9"      label "CFOP"
        tt-plani.movtdc     format ">>9"       label "TipMov"
        tipmov.movtnom   format "x(22)"     label "Movimento" when avail tipmov
            with frame f-mostra down.



if tt-plani.movtdc = 0 and tt-plani.numero <> ?
then do:
    
    update tt-plani.movtdc with frame f-mostra.
    
    find first tipmov where tipmov.movtdc = tt-plani.movtdc no-lock no-error.
    
    display tipmov.movtnom when avail tipmov with frame f-mostra.

end.


if vgera-log
then
put stream str-log
    tt-plani.etbcod
     ";"
    tt-plani.numero format ">>>>>>>>>>>>>>>>9"
    ";"
    vdesti-dif    format "Sim/Nao"
    ";"
    vopccod-dif   format "Sim/Nao"
    ";"
    vplatot-dif   format "Sim/Nao"
    ";"
    vitens-dif    format "Sim/Nao"
    ";"
    tt-plani.opccod  format ">>>>>9"
    ";"
    tt-plani.movtdc format ">>>>>9"
    ";"
    tipmov.movtnom  format "x(50)"
    ";".

for each tt-movim.
    
    assign tt-movim.movtdc = tt-plani.movtdc.
            
end.

/* Altera Plani antigo caso exista */

if vdesti-dif
   or vopccod-dif
   or vplatot-dif
   or vitens-dif
then do:
            

for each tt-plani where tt-plani.numero <> ?.

    find first plani where plani.etbcod = tt-plani.etbcod
                       and plani.placod = tt-plani.placod
                       and plani.serie = tt-plani.serie
                              exclusive-lock no-error.
                              
    if not avail plani 
    then find first plani where plani.etbcod = tt-plani.etbcod
                            and plani.movtdc = tt-plani.movtdc
                            and plani.emite = tt-plani.emite
                            and plani.serie = tt-plani.serie
                            and plani.numero = tt-plani.numero
                                exclusive-lock no-error.

    if avail plani 
    then do:
    
        find first planiaux where planiaux.etbcod = plani.etbcod
                              and planiaux.emite  = plani.emite
                              and planiaux.serie = plani.serie
                              and planiaux.numero = plani.numero
                              and planiaux.nome_campo = "TIPMOV-ANTIGO"
                               no-lock no-error.
        if not avail planiaux
        then do:

            create planiaux.
            assign planiaux.etbcod = plani.etbcod
                   planiaux.emite  = plani.emite
                   planiaux.serie = plani.serie
                   planiaux.numero = plani.numero
                   planiaux.nome_campo = "TIPMOV-ANTIGO"
                   planiaux.valor_campo = string(plani.movtdc).
                   
        end.
        
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat
                                 exclusive-lock.

            assign movim.placod = int(replace(string(movim.placod),"550","559"))
                   movim.movtdc = 9998.

        end.

        assign plani.placod = int(replace(string(plani.placod),"550","559"))
               plani.movtdc = 9998.
            .

    end.
    
end.        

end.

end procedure.



**********************************************************************/