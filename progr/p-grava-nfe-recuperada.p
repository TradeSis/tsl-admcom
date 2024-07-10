{admcab.i}

def output parameter vok     as log.

def var vok-aux              as log.

def var vcont-prod1          as int.
def var vcont-prod2          as int.

def shared temp-table tt-plani like plani
    field natoper    as char.
def shared temp-table tt-movim like movim.

def var vemite-dif           as log.
def var vdesti-dif           as log.
def var vopccod-dif          as log.
def var vplatot-dif          as log.
def var vitens-dif            as log.

def shared var varq-lista     as char.

def var varq-log              as char.
def var vgera-log             as log.

def stream str-log.

def var chave-nfe as char.
def var ibge-uf-emite as char.

def var vemitecgc      as char.
        
if varq-lista <> "/admcom/audit/"
then assign varq-log = replace(varq-lista,"csv","log") + ".csv"
            vgera-log = yes.
else assign varq-log = ""
            vgera-log = no.

assign vgera-log = no.

if vgera-log
then do:
    output stream str-log to value(varq-log) append.

    put stream str-log
        "Fil;Nota;Desti;CFOP;Vl Not;Itens;CFOP;TipMov;Movimento;Atu;" skip.
end.


form tt-plani.etbcod     format ">>9"       label "Fil"
     tt-plani.numero     format ">>>>>>>9"  label "Nota"
     vdesti-dif       format "Sim/Nao"   label "Desti"
     vopccod-dif      format "Sim/Nao"   Label "CFOP"
     vplatot-dif      format "Sim/Nao"   label "Vl Not"
     vitens-dif       format "Sim/Nao"   label "Itens"
     tt-plani.opccod     format ">>>9"      label "CFOP"
     tt-plani.movtdc     format ">>9"       label "TipMov"
     tipmov.movtnom   format "x(22)"     label "Movimento"
     vok-aux  format "Sim/Nao" label "Atu"
            with frame f-mostra down.

assign vemite-dif    = no
       vdesti-dif    = no
       vopccod-dif   = no
       vplatot-dif   = no
       vitens-dif    = no
       vcont-prod1   = 0
       vcont-prod2   = 0.

run p-verifica-plani-repetido.

if vdesti-dif
    or vopccod-dif 
    or vplatot-dif
    or vitens-dif
then do:    

    assign vok     = no
           vok-aux = no.
    
    run p-grava-nfe.

end.

for each tt-plani where tt-plani.numero <> ? no-lock.

     find first A01_infnfe where A01_infnfe.emite = tt-plani.emite
                                and A01_infnfe.serie = string(tt-plani.serie)
                                and A01_infnfe.numero = tt-plani.numero
                                        no-lock no-error.
                                        
        if not avail A01_infnfe                                
        then find first A01_infnfe where A01_infnfe.etbcod = tt-plani.etbcod
                                     and A01_infnfe.placod = tt-plani.placod
                                                    no-lock no-error.

        if not avail A01_infnfe
        then do:
        
            find estab where estab.etbcod = tt-plani.emite no-lock no-error.

            find first tabaux where tabaux.tabela = "codigo-ibge" and
                                    tabaux.nome_campo = estab.ufecod
                                                  no-lock no-error.
                                                        
            assign vemitecgc = estab.etbcgc
                   vemitecgc = replace(vemitecgc,".","")
                   vemitecgc = replace(vemitecgc,"/","")
                   vemitecgc = replace(vemitecgc,"-","").

            chave-nfe = "NFe" + ibge-uf-emite + 
                            substr(string(year(tt-plani.pladat),"9999"),3,2) +
                            string(month(tt-plani.pladat),"99") +
                            vemitecgc +
                            "55" +
                            string(int(01),"999") +
                            string(tt-plani.numero,"999999999").
         
            create A01_infnfe.
            assign A01_infnfe.chave = chave-nfe
                   A01_infnfe.emite = tt-plani.emite
                   A01_infnfe.serie = string(tt-plani.serie)
                   A01_infnfe.numero = tt-plani.numero
                   A01_infnfe.etbcod = tt-plani.etbcod
                   A01_infnfe.placod = tt-plani.placod
                   A01_infnfe.versao = 1.10
                   A01_infnfe.id     = tt-plani.ufdes.
                   
        end.
        
end.

procedure p-grava-nfe:

    for each tt-plani where tt-plani.numero <> ? no-lock.

        create plani.
        buffer-copy tt-plani to plani.

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
                       and plani.serie  = tt-plani.serie
                       and plani.movtdc < 9000
                     NO-LOCK no-error.
    if not avail plani
    then find first plani where plani.etbcod = tt-plani.etbcod
                            and plani.movtdc = tt-plani.movtdc
                            and plani.emite  = tt-plani.emite
                            and plani.serie  = tt-plani.serie
                            and plani.numero = tt-plani.numero
                            and plani.movtdc < 9000
                          NO-LOCK no-error.
    if not avail plani and tt-plani.etbcod = 993
    then do:
        message "1.0 ETB: " tt-plani.etbcod " Nota: " tt-plani.numero
                " Avail " avail plani .
    
        find first plani where plani.etbcod = 998
                           and plani.placod = tt-plani.placod
                           and plani.serie = tt-plani.serie
                           and plani.movtdc < 9000
                         no-error.

        message "2.0 ETB: " tt-plani.etbcod " Nota: " tt-plani.numero
                " Avail " avail plani .
        
        if not avail plani
        then find first plani where plani.etbcod = 998
                                and plani.movtdc = tt-plani.movtdc
                                and plani.emite  = 998
                                and plani.serie  = tt-plani.serie
                                and plani.numero = tt-plani.numero
                              no-error.

        message "3.0 ETB: " tt-plani.etbcod " Nota: " tt-plani.numero
                " Avail " avail plani .

        if avail plani and plani.emite = 998 and tt-plani.emite = 993
        then assign plani.emite = 993.

        if avail plani and plani.etbcod = 998 and tt-plani.etbcod = 993
        then do:

            for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                                and tt-movim.placod = tt-plani.placod
                                and tt-movim.movdat = tt-plani.pladat
                                                  exclusive-lock.
                                                                        
                assign tt-movim.etbcod = 998
                       tt-movim.emite = 993.
            end.
            
            assign tt-plani.etbcod = 998.
        end.
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
    
        if avail plani and plani.emite = 991 and tt-plani.emite = 995
        then assign tt-plani.emite = 991.

        if avail plani and plani.etbcod = 991 and tt-plani.etbcod = 995
        then do:
            
            for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                                and tt-movim.placod = tt-plani.placod
                                and tt-movim.movdat = tt-plani.pladat
                                        exclusive-lock.
              assign tt-movim.etbcod = 991
                     tt-movim.emite  = 991.                 
            end.
            
            assign tt-plani.etbcod = 991.
            
        end.    
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
                                
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat
                       no-lock.
            assign vcont-prod1 = vcont-prod1 + movim.procod. 
        end.                                                     

        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            and tt-movim.movdat = tt-plani.pladat
                          no-lock.
            assign vcont-prod2 = vcont-prod2 + tt-movim.procod.
        end.
    
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
pause 0.


if tt-plani.movtdc = 0
    and tt-plani.numero <> ?
    and (vdesti-dif
         or vopccod-dif
         or vplatot-dif
         or vitens-dif)
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
    end.
    
end.        

end.

end procedure.
