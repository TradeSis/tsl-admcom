{admcab.i}

def var vforcod like forne.forcod.
def var vdti as date.
def var vdtf as date.
def var vdat as date.
def var tt-orig as dec.
def var tt-juro as dec.
def var tt-desc as dec.
def var tt-atua as dec.
def var t-orig as dec.
def var t-juro as dec.
def var t-desc as dec.
def var t-atua as dec.
def var titjur as dec.
def var titdes as dec.
def var ttitjur as dec.
def var ttitdes as dec.
def var vl-desn as dec.

def var val-atual like titulo.titvlcob.
/*
define  temp-table wktit
   field seq as   i label "Nr" format "99"
   field empcod   like titulo.empcod
   field titdtdes like titulo.titdtdes column-label "Dt.Desc."
                                       format "99/99/99"
   field clifor   like titulo.clifor
   field titnum   like titulo.titnum
   field titpar   like titulo.titpar
   field titvldes like titulo.titvldes  label "Vlr. Desc." format ">,>>>,>>9.99"
   field titdtven like titulo.titdtven  label "Dt.Venc."   format "99/99/99"
   field titvlcob like titulo.titvlcob  label "Vlr. Cobr." format ">,>>>,>>9.99"
   field percdes  as dec format ">9.99" label "Des. %"
   field modcod   like titulo.modcod.
*/
def temp-table tt-forne like forne.

update vforcod label "Fornecedor"
       with frame f-ini 1 down side-label width 80.
       
if vforcod > 0
then do:
find forne where forne.forcod = vforcod no-lock no-error.
if not avail forne
then do:
    bell.
    message color red/with
    "Fornecedor nao cadastrado"
    view-as alert-box.
    undo.
end.    
disp forne.fornom no-label with frame f-ini.
end.
else disp "Geral" @ forne.fornom with frame f-ini.
/*if vforcod = 0
then*/
update vdti at 1 label "Pariodo de"
       vdtf label "Ate"
       with frame f-ini
       .
def temp-table tt-titulo like titulo.

def var vdtage as date.
if vforcod > 0
then do:
for each titulo where titulo.clifor = vforcod 
        /**
        and (titulo.titsit = "CON"  or
             titulo.titsit = "LIB" )
        **/
        no-lock:
    if titulo.titsit <> "CON" and
       titulo.titsit <> "LIB" and
       titulo.titsit <> "PAG"
    then next.
       
    if acha("AGENDAR",titulo.titobs[2]) =  ?
    then next.

    vdtage = date(acha("AGENDAR",titulo.titobs[2])).
    if vdtage = titulo.titdtven  or
       vdtage < vdti or
       vdtage > vdtf 
    then next.
    create tt-titulo.
    buffer-copy titulo to tt-titulo.
end.    
end.
else do: 
for each forne  no-lock:   
     disp forne.forcod forne.fornom
         with frame f-0 1 down no-label row 10 centered no-box.
      pause 0.   
for each titulo where titulo.clifor = forne.forcod 
       /* and (titulo.titsit = "CON"  or
             titulo.titsit = "LIB" or
             titulo.titsit = "PAG")*/ 
        and titdtven >= vdti 
        /*and acha("AGENDAR",titulo.titobs[2]) <>  ?*/
        no-lock:
    
    if titulo.titsit <> "CON" and
       titulo.titsit <> "LIB" and
       titulo.titsit <> "PAG"
    then next. 
    
    if acha("AGENDAR",titulo.titobs[2]) =  ?
    then next.
    vdtage = date(acha("AGENDAR",titulo.titobs[2])).
    if vdtage = titulo.titdtven or
       vdtage < vdti or
       vdtage > vdtf 
    then next.

    if titulo.titdtven = date(acha("AGENDAR",titulo.titobs[2]))
    then next.
    create tt-titulo.
    buffer-copy titulo to tt-titulo.
    find first tt-forne where tt-forne.forcod = titulo.clifor  no-error.
    if not avail tt-forne
    then do:
        create tt-forne.
        buffer-copy forne to tt-forne.
    end.
end.         
end.
end.             
def var varquivo as char.
if opsys = "UNIX" 
then  varquivo = "/admcom/relat/relantec" + string(time).
else  varquivo = "l:\relat\relantec" + string(time).
            
{mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""nf_conf""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """    TITULO AGENDADOS """
       &Width     = "130"
       &Form      = "frame f-cabcab"}
 
disp with frame f-ini.
   
def var vdata as date.
def var vl-juro as dec.
def var vl-desc as dec.
              
if vforcod > 0
then do:
for each tt-titulo no-lock:
   vdata     = date(acha("AGENDAR",tt-titulo.titobs[2])). 
   vl-juro   = dec(acha("VALJURO",tt-titulo.titobs[2])).
   vl-desc   = dec(acha("VALDESC",tt-titulo.titobs[2])).
   if vl-juro = ? then vl-juro = 0.
   if vl-desc = ? then vl-desc = 0.
   
   vl-desn = tt-titulo.titvldes.
   if vl-desn >= vl-desc  and tt-titulo.titsit = "PAG"
   then vl-desn = vl-desn - vl-desc.
   /*
   vl-desc = vl-desc + tt-titulo.titvldes.
   vl-juro = vl-juro + tt-titulo.titjuro.
   */ 
   disp  tt-titulo.titnum      column-label "Titulo"
         tt-titulo.titdtven    column-label "Data!Vencimento"
         vdata                 column-label "Data!Agendamento"
                        format "99/99/9999"
         tt-titulo.titdtven - date(acha("AGENDAR",tt-titulo.titobs[2]))
         column-label "Qtd!Dias" format ">>9"
         tt-titulo.titvlcob (total) column-label "Valor!Original"
                        format ">,>>>,>>>,>>9.99"
         dec(acha("PCTJD",tt-titulo.titobs[2])) column-label "Taxa"
                        format ">>9.99"
         tt-titulo.titjuro(total)   column-label "Juro!Normal"   
                        format ">>>,>>9.99"
         vl-juro (total)            column-label "Juro!Agendado"
                        format ">>>,>>9.99"
         vl-desn(total)  column-label "Desc.!Normal"
                        format ">>>,>>>,>>9.99"
         vl-desc (total)            column-label "Desc.!Agendado"
                        format ">>,>>>,>>9.99"
         tt-titulo.titvlcob + vl-juro + tt-titulo.titjuro 
                    - vl-desc - vl-desn (total) 
                                column-label "Valor!Atual"
                        format ">>>,>>>,>>9.99"
        with frame f-disp down width 150
         .
         
end.
end.
else do:
assign tt-orig = 0
     tt-juro = 0
     tt-desc = 0
     tt-atua = 0
     ttitjur = 0 ttitdes = 0.

form with frame f-disp1.
for each tt-forne no-lock:
    disp tt-forne.forcod
         tt-forne.fornom
         with frame f-ff 1 down no-box no-label side-label.
    assign t-orig = 0 t-juro = 0 t-desc = 0 t-atua = 0
        titjur = 0 titdes = 0.

for each tt-titulo where tt-titulo.clifor = tt-forne.forcod:
   vdata     = date(acha("AGENDAR",tt-titulo.titobs[2])). 
   vl-juro   = dec(acha("VALJURO",tt-titulo.titobs[2])).
   vl-desc   = dec(acha("VALDESC",tt-titulo.titobs[2])).
   if vl-juro = ? then vl-juro = 0.
   if vl-desc = ? then vl-desc = 0.
   /*
   vl-desc = vl-desc + tt-titulo.titvldes.
   vl-juro = vl-juro + tt-titulo.titjuro.
    */

   vl-desn = tt-titulo.titvldes.
   if vl-desn >= vl-desc  and tt-titulo.titsit = "PAG"
   then vl-desn = vl-desn - vl-desc.

   val-atual =  tt-titulo.titvlcob + vl-juro - vl-desc 
        + tt-titulo.titjuro - vl-desn. 
   
   disp  tt-titulo.titnum      column-label "Titulo"
         tt-titulo.titdtven    column-label "Data!Vencimento"
         vdata                 column-label "Data!Agendamento"  
                    format "99/99/9999"
         tt-titulo.titdtven - date(acha("AGENDAR",tt-titulo.titobs[2]))
         column-label "Qtd!Dias" format ">>9"
         tt-titulo.titvlcob  column-label "Valor!Original"
                    format ">>>,>>>,>>>,>>9.99"
         dec(acha("PCTJD",tt-titulo.titobs[2])) column-label "Taxa"
                    format ">>9.99"
         tt-titulo.titjuro column-label "Juro!Normal"    format ">>>,>>9.99"
         vl-juro           column-label "Juro!Agendado"  format ">>>,>>9.99"
         vl-desn           column-label "Desc.!Normal"   format ">>>,>>9.99"
         vl-desc           column-label "Desc.!Agendado" format ">,>>>,>>9.99"
         val-atual  column-label "Valor!Atual"       format ">>>,>>>,>>>,>>9.99"
        with frame f-disp1 down width 150
         .
    down with frame f-disp1.
    assign
        t-orig = t-orig + tt-titulo.titvlcob
        t-juro = t-juro + vl-juro
        titjur = titjur + tt-titulo.titjuro
        t-desc = t-desc + vl-desc
        titdes = titdes + vl-desn
        t-atua = t-atua + tt-titulo.titvlcob + vl-juro - vl-desc 
                    + tt-titulo.titjuro - vl-desn
        tt-orig = tt-orig + tt-titulo.titvlcob
        tt-juro = tt-juro + vl-juro
        ttitjur = ttitjur + tt-titulo.titjuro
        tt-desc = tt-desc + vl-desc
        ttitdes = ttitdes + vl-desn
        tt-atua = tt-atua + tt-titulo.titvlcob + vl-juro - vl-desc
                    + tt-titulo.titjuro - vl-desn
        .     

end.
down(1) with frame f-disp1.
disp t-orig @ tt-titulo.titvlcob
     t-juro @ vl-juro
     titjur @ tt-titulo.titjuro
     t-desc @ vl-desc
     titdes @ vl-desn
     t-atua @ val-atual
     with frame f-disp1
     .

end.
down(1) with frame f-disp1.
disp tt-orig @ tt-titulo.titvlcob
     tt-juro @ vl-juro
     ttitjur @ tt-titulo.titjuro
     tt-desc @ vl-desc
     ttitdes @ vl-desn
     tt-atua @ val-atual
     with frame f-disp1
     .
end.

output close.
if opsys = "UNIX"
then do: 
    run visurel.p (input varquivo, 
                   input "").     
end. 
else do: 
    {mrod.i} 
end.
    
