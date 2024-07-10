{admcab.i}
{setbrw.i}
def var vforcod like forne.forcod.
def var vlancod like lancxa.lancod.
def var vlanhis like lancxa.lanhis.
def var vdtini as date.
def var vdtfin as date.
def var vtotal as dec.


update vforcod format ">>>>>>>9"
       vlancod format ">>>>>>>9"  label "Cod. Conta"
       vlanhis 
       vdtini at 1 label "Data inicial"
       vdtfin label "Ate" with side-label.
       
if vforcod <> 0
then do:
    find forne where forne.forcod = vforcod no-lock .
    /**
    disp forne.fornom.
    **/
end.
else if vlancod = 0
    then return.
    
def buffer blancxa for lancxa.

assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?.

if vforcod <> 0
then do:
for each lancxa
        where  lancxa.datlan >= vdtini and
               lancxa.datlan <= vdtfin and
               lancxa.forcod = vforcod
               use-index ind-3 no-lock:
        vtotal = vtotal + lancxa.vallan.
    end.           
 
disp "        " vtotal label "Total" format ">>,>>>,>>9.99" with width 80.
    

{sklcls.i
    &help = "ENTER=Altera  F1=Atualiza Linha  F4=Sair"
    &file = lancxa
    &cfield = lancxa.datlan
    &noncharacter = /*
    &ofield = " lancxa.lancod
                lancxa.lanhis
                lancxa.comhis
                lancxa.vallan
              "
    &where = " lancxa.forcod = vforcod  and
               lancxa.datlan >= vdtini and
               lancxa.datlan <= vdtfin and
               (if vlanhis <> 0
                then lancxa.lanhis = vlanhis 
                else true) use-index ind-4 "
    &aftselect1 =   "
        if keyfunction(lastkey) = ""RETURN""
        then do:
            find last blancxa where 
                      blancxa.forcod = vforcod and
                      blancxa.datlan < lancxa.datlan and
                      blancxa.lancod = lancxa.lancod and
                      (if vlanhis <> 0 
                      then blancxa.lanhis = vlanhis else true)
                      no-lock no-error.
            if avail blancxa
            then do:
            if  lancxa.lancod <> blancxa.lancod
            then lancxa.lancod = blancxa.lancod.
            if lancxa.lanhis = 0
            then    lancxa.lanhis = blancxa.lanhis .
            if lancxa.comhis = """"
            then if vlanhis = 0
                then lancxa.comhis = forne.fornom.
                else lancxa.comhis = blancxa.comhis.      
            end.
            update lancxa.lancod 
                   lancxa.lanhis
                   lancxa.comhis
                   with frame f-linha.
                   
        end.
        if keyfunction(lastkey) = ""GO""
        then do:
            find LAST blancxa where 
                       blancxa.forcod = vforcod and
                       blancxa.datlan < lancxa.datlan and
                       blancxa.lancod = lancxa.lancod and
                       (if vlanhis <> 0 
                      then blancxa.lanhis = vlanhis else true)
                       no-lock no-error.
            if avail blancxa
            then do:
            if  lancxa.lancod <> blancxa.lancod
            then lancxa.lancod = blancxa.lancod.
            if lancxa.lanhis = 0
            then    lancxa.lanhis = blancxa.lanhis .
            if lancxa.comhis = """"
            then if vlanhis = 0
                then lancxa.comhis = forne.fornom.
                else lancxa.comhis = blancxa.comhis. 
            end.
            disp lancxa.lancod 
                   lancxa.lanhis
                   lancxa.comhis
                   with frame f-linha.
             
        end.
        next keys-loop.
        "
    &naoexiste1 = " bell.
                   message color red/with
                    ""Nenhum registro encontrado""
                    view-as alert-box.
                   leave keys-loop.
                 "     
     &form = " frame f-linha down "
}
end.
else do:
    for each lancxa
        where  lancxa.datlan >= vdtini and
               lancxa.datlan <= vdtfin and
               lancxa.lancod = vlancod
               use-index ind-3 no-lock:
        vtotal = vtotal + lancxa.vallan.
    end.           
 
    disp "        " vtotal label "Total" format ">>,>>>,>>9.99" with width 80.
    
{sklcls.i
    &help = "ENTER=Altera  F1=Atualiza Linha  F4=Sair"
    &file = lancxa
    &cfield = lancxa.datlan
    &noncharacter = /*
    &ofield = " lancxa.lancod
                lancxa.lanhis
                lancxa.comhis
                lancxa.vallan
              "
    &where = " 
               lancxa.datlan >= vdtini and
               lancxa.datlan <= vdtfin and
               lancxa.lancod = vlancod
               use-index ind-3                "
    &aftselect1 =   "
        if keyfunction(lastkey) = ""RETURN""
        then do:
            /**
            find last blancxa where 
                      blancxa.lancod = vlancod and
                      blancxa.datlan < lancxa.datlan and
                      blancxa.lancod = lancxa.lancod and
                      (if vlanhis <> 0 
                      then blancxa.lanhis = vlanhis else true)
                      no-lock no-error.
            if avail blancxa
            then do:
            if  lancxa.lancod <> blancxa.lancod
            then lancxa.lancod = blancxa.lancod.
            if lancxa.lanhis = 0
            then    lancxa.lanhis = blancxa.lanhis .
            if lancxa.comhis = """"
            then if vlanhis = 0
                then lancxa.comhis = forne.fornom.
                else lancxa.comhis = blancxa.comhis.      
            end.
            **/
            vtotal = vtotal - lancxa.vallan.
            update lancxa.lancod 
                   lancxa.lanhis
                   lancxa.comhis
                   lancxa.vallan
                   with frame f-linha.
             vtotal = vtotal + lancxa.vallan.
                   
        end.
        if keyfunction(lastkey) = ""GO""
        then do:
            /**
            find LAST blancxa where 
                       blancxa.forcod = vforcod and
                       blancxa.datlan < lancxa.datlan and
                       blancxa.lancod = lancxa.lancod and
                       (if vlanhis <> 0 
                      then blancxa.lanhis = vlanhis else true)
                       no-lock no-error.
            if avail blancxa
            then do:
            if  lancxa.lancod <> blancxa.lancod
            then lancxa.lancod = blancxa.lancod.
            if lancxa.lanhis = 0
            then    lancxa.lanhis = blancxa.lanhis .
            if lancxa.comhis = """"
            then if vlanhis = 0
                then lancxa.comhis = forne.fornom.
                else lancxa.comhis = blancxa.comhis. 
            end.
            **/
            disp lancxa.lancod 
                   lancxa.lanhis
                   lancxa.comhis
                   with frame f-linha.
             
        end.
        next keys-loop.
        "
    &naoexiste1 = " bell.
                   message color red/with
                    ""Nenhum registro encontrado""
                    view-as alert-box.
                   leave keys-loop.
                 "   
    &form = " frame f-linha down "
} 
end.                
                


