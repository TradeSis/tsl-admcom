{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-rec
        field etbcod like estab.etbcod
        field data as date
        field valor as dec
        field juro as dec.
 
def shared temp-table tt-venda
        field etbcod like estab.etbcod
        field data as date
        field vl-prazo as dec 
        field vl-vista as dec
        field avista as dec
        field aprazo as dec
        index i1 etbcod data.
 
def shared temp-table tt-index
    field etbcod like estab.etbcod
    field data as date
    field indx as dec 
    field venda as dec 
    field titulo as dec
    field vl-prazo as dec  decimals 2
    field vl-titulo as dec decimals 2
    index i1 etbcod data.

def shared temp-table tt-titulo
      field data      as date
      field etbcod like estab.etbcod
      field tipo      as char format "X(15)"  Label "Tipo"
      field titvlcob  like titulo.titvlcob label "Valor"
      field titvlpag  like titulo.titvlpag
      field entrada   as dec
      index ix is primary unique
                  tipo
                  etbcod
                  data
                  .

def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
def var vrec as dec.

/****
for each tt-estab:
    vrec = 0.
    for each   ctcartcl where
               ctcartcl.etbcod = tt-estab.etbcod and
               ctcartcl.datref >= vdti and
               ctcartcl.datref <= vdtf
               no-lock.
        vrec = vrec + ctcartcl.recebimento.
    end.
    if vrec > 0
    then delete tt-estab.
end.
find first tt-estab no-error.
if not avail tt-estab
**/

find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.recebimento > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if avail ctcartcl  
then do:
    message "JA PROCESSADO." .
    PAUSE.
    return.               
end.

sresp = no.
message "Confirma processamento? " update sresp.
if not sresp then return.

def var vetb-pag like estab.etbcod.

def var vdata1 as date. 
def var vhist as char.

    for each tt-estab no-lock:
        if tt-estab.etbcod >= 900 and
           tt-estab.etbcod <> 993
        then vetb-pag = 996.
        else vetb-pag = tt-estab.etbcod.
           
        do vdata1 = vdti to vdtf:
            disp "Processando RECEB... " tt-estab.etbcod vdata1 
                with frame fxy1 no-label 1 down centered no-box
                color message .
             pause 0.
     
            for each titulo use-index etbcod where
                 titulo.etbcobra = tt-estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:
                /*
                if titulo.cobcod = 9 or
                   titulo.cobcod = 10
                then next. 
                */  
                if titulo.clifor = 1 
                then next.
                if titulo.titnat = yes 
                then next.
                if titulo.modcod <> "CRE" 
                then next.

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                  and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then do:
                    vhist = "3 - FINANCEIRA".
                    find first tt-titulo where  tt-titulo.tipo = vhist 
                            and tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                            and tt-titulo.data = vdata1 no-error.
                    if not avail tt-titulo
                    then do:
                        create tt-titulo.
                        assign tt-titulo.data = vdata1
                           tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                           tt-titulo.tipo = vhist.
                    end.
                    if   titulo.titpar <> 0 
                    then 
                    tt-titulo.titvlcob = tt-titulo.titvlcob + titulo.titvlcob. 
                    next.
                end.    

                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                     no-lock no-error.
                
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.
                
                if avail cpcontrato and
                   cpcontrato.indecf = no 
                then do:
                    vhist = "3 - COBRANCA".
                    find first tt-titulo where  tt-titulo.tipo = vhist 
                            and tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                            and tt-titulo.data = vdata1 no-error.
                    if not avail tt-titulo
                    then do:
                        create tt-titulo.
                        assign tt-titulo.data = vdata1
                           tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                           tt-titulo.tipo = vhist.
                    end.
                    if   titulo.titpar <> 0 
                    then 
                    tt-titulo.titvlcob = tt-titulo.titvlcob + titulo.titvlcob. 
                    next.
                end.
                if avail cpcontrato and
                   cpcontrato.financeira = 9
                then do:
                    vhist = "3 - COBRANCA".
                    find first tt-titulo where  tt-titulo.tipo = vhist 
                            and tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                            and tt-titulo.data = vdata1 no-error.
                    if not avail tt-titulo
                    then do:
                        create tt-titulo.
                        assign tt-titulo.data = vdata1
                           tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                           tt-titulo.tipo = vhist.
                    end.
                    if   titulo.titpar <> 0 
                    then 
                    tt-titulo.titvlcob = tt-titulo.titvlcob + titulo.titvlcob. 
                    next.
                end.
                   
                vhist = "3 - RECEBIMENTO".
                
                find first tt-titulo where  tt-titulo.tipo = vhist 
                            and tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                            and tt-titulo.data = vdata1 no-error.
                if not avail tt-titulo
                then do:
                    create tt-titulo.
                    assign tt-titulo.data = vdata1
                           tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                           tt-titulo.tipo = vhist.
                end.
                if   titulo.titpar = 0 
                then do:
                    tt-titulo.entrada = tt-titulo.entrada + titulo.titvlcob. 
                    next.
                end.    
                
                tt-titulo.titvlcob = tt-titulo.titvlcob + titulo.titvlcob.
    
                   
                if titulo.titjuro > 0
                then do:
                        
                    vhist = "3 - JURO".

                    find first tt-titulo where  tt-titulo.tipo = vhist 
                            and tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/ 
                            and tt-titulo.data = vdata1 no-error.
                    if not avail tt-titulo
                    then do:
                            create tt-titulo.
                            assign 
                                tt-titulo.data = vdata1
                                tt-titulo.etbcod = vetb-pag /*tt-estab.etbcod*/
                                tt-titulo.tipo = vhist.
                    end.
                    tt-titulo.titvlcob = 
                                tt-titulo.titvlcob + titulo.titjuro.
                end.
            end.
        end.
    end.


for each tt-titulo where  tt-titulo.tipo = "3 - RECEBIMENTO" 
                   and tt-titulo.etbcod > 0
                   and tt-titulo.data <> ?
                    no-lock .
    
    find first ctcartcl where
               ctcartcl.etbcod = tt-titulo.etbcod and
               ctcartcl.datref = tt-titulo.data
               no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = tt-titulo.etbcod 
            ctcartcl.datref = tt-titulo.data
            .
    end.
    ctcartcl.recebimento = tt-titulo.titvlcob.
    ctcartcl.dec1 = tt-titulo.entrada * 100.
end.
for each tt-titulo where  tt-titulo.tipo = "3 - JURO" 
                   and tt-titulo.etbcod > 0
                   and tt-titulo.data <> ? 
                    no-lock .
    find first ctcartcl where
               ctcartcl.etbcod = tt-titulo.etbcod and
               ctcartcl.datref = tt-titulo.data 
               no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = tt-titulo.etbcod 
            ctcartcl.datref = tt-titulo.data
            .
    end.
    ctcartcl.juro = tt-titulo.titvlcob.
end.
for each tt-titulo where  tt-titulo.tipo = "3 - FINANCEIRA" 
                   and tt-titulo.etbcod > 0
                   and tt-titulo.data <> ?
                    no-lock .
    find first ctcartcl where
               ctcartcl.etbcod = tt-titulo.etbcod and
               ctcartcl.datref = tt-titulo.data
               no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = tt-titulo.etbcod 
            ctcartcl.datref = tt-titulo.data
            .
    end.
    ctcartcl.dec2 = tt-titulo.titvlcob * 100.
end.



procedure recebimento:
    
    def var vreceb as dec format ">>>,>>>,>>9.99".
    def var vjuro as dec format ">>>,>>>,>>9.99".
    def var vtotal as dec.
    def var vdata1 as date.
    
    for each tt-rec:
        delete tt-rec.
    end.    
    
    for each estab no-lock:
        do vdata1 = vdti to vdtf:
            disp estab.etbcod vdata1 with frame f 1 down.
            pause 0.
            for each titulo  where
                 titulo.etbcobra = estab.etbcod and
                 titulo.titdtpag = vdata1 no-lock:
                 if titulo.titvlcob <= 0
                 THEN NEXT.
        
                if titulo.clifor = 1 then next.
                if titulo.titnat = yes then next.
                if titulo.titpar = 0 then next. 
                if titulo.modcod <> "CRE" then next.
                
                find tituarqm where
                                     tituarqm.empcod = titulo.empcod and
                                     tituarqm.titnat = titulo.titnat and
                                     tituarqm.modcod = titulo.modcod and
                                     tituarqm.etbcod = titulo.etbcod and
                                     tituarqm.clifor = titulo.clifor and
                                     tituarqm.titnum = titulo.titnum and
                                     tituarqm.titpar = titulo.titpar
                                     no-error.

                if avail tituarqm and
                    tituarqm.etbcobra = estab.etbcod and
                    tituarqm.titdtpag = vdata1 
                then do:
                    if tituarqm.titsit = "PAGCTB" 
                    then.
                    else next.
                end.    
                
                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = titulo.etbcod
                                    and envfinan.clifor = titulo.clifor
                                    and envfinan.titnum = titulo.titnum
                                    no-lock no-error.
                if  avail envfinan
                then next.
                
                find cpcontrato where 
                     cpcontrato.contnum = int(titulo.titnum)
                     no-error.
                
                if titulo.titdtemi >= 01/01/2009 and
                   not avail cpcontrato
                then next.
                
                if avail cpcontrato and
                   cpcontrato.indecf = no and 
                   cpcontrato.indpag = no   
                then next.

                if avail cpcontrato and
                    cpcontrato.financeira <> 0 
                then next.
                    
                find first tt-rec where
                       tt-rec.etbcod = estab.etbcod and
                       tt-rec.data = vdata1
                       no-error.
                if not avail tt-rec
                then do: 
                    create tt-rec.
                    assign
                        tt-rec.etbcod = estab.etbcod 
                        tt-rec.data = vdata1.
                end.
                assign
                    tt-rec.valor = tt-rec.valor + titulo.titvlcob
                    tt-rec.juro  = tt-rec.juro  + titulo.titjuro
                    vreceb = vreceb + titulo.titvlcob
                    vjuro  = vjuro  + titulo.titjuro.
            end.
        end.
    end.

    for each ctcartcl where ctcartcl.etbcod > 0 and
                            ctcartcl.datref >= vdti and
                            ctcartcl.datref <= vdtf
                            :
        ctcartcl.recebimento = 0.
        ctcartcl.juro = 0.
    end.                            
    for each tt-rec where tt-rec.etbcod > 0:
        find first ctcartcl where
               ctcartcl.etbcod = tt-rec.etbcod and
               ctcartcl.datref = tt-rec.data
               no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-rec.etbcod 
                ctcartcl.datref = tt-rec.data
             .
        end.
        ctcartcl.recebimento = tt-rec.valor.
        ctcartcl.juro = tt-rec.juro.
    end.

end procedure.
  