{admcab-batch.i}

def var vlancod like lanaut.lancod.
def var vcxacod like lancxa.cxacod.
def var vcomhis as char.
def var v-nomes as char extent 12
    init["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO",
    "AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].

def input parameter vrec as recid.

find fin.titluc where recid(fin.titluc) = vrec no-lock.

def var vlanhis like lanaut.lanhis.
def var vcompl as char.
def var vmes as int.
def var vano as int.

vcomhis = "".
vmes = 0.
vano = 0.

find foraut where foraut.forcod = fin.titluc.clifor no-lock.
if fin.titluc.modcod = "FPA" /*clifor = 110016*/
then do:
    vmes = month(titluc.titdtven).
    vano = year(titluc.titdtven).
    
    if vmes = 1
    then assign
            vmes = 12
            vano = vano - 1.
    else vmes = vmes - 1.

    vlanhis = 21.
    vcomhis = foraut.fornom + "-" +
        v-nomes[vmes] + "-" + string(vano,"9999"). 
end.

find foraut where foraut.forcod = fin.titluc.clifor no-lock.

find lanaut where lanaut.etbcod = fin.titluc.etbcod and
                  lanaut.forcod = fin.titluc.clifor no-lock no-error.

if avail lanaut or fin.titluc.modcod = "FPA"
then do:

    if fin.titluc.modcod = "FPA"
    then assign
            vlancod = 111
            vcxacod = 4
            vlanhis = 21
            .
    else if avail lanaut
    then do:
        assign        
            vlancod = lanaut.lancod.
        vcxacod = 1.
        find first tablan where tablan.lancod = lanaut.lancod
            no-lock no-error.
        if avail tablan
        then assign
             vlancod = tablan.codred
             vcxacod = 1.
        vlanhis = lanaut.lanhis.
        vcomhis = foraut.fornom.
    end.    

    find first lancxa where 
                       lancxa.datlan = fin.titluc.titdtpag and
                       lancxa.cxacod = vcxacod and
                       lancxa.lancod = vlancod and
                       lancxa.modcod = fin.titluc.modcod and
                       lancxa.vallan = fin.titluc.titvlco and
                       lancxa.forcod = fin.titluc.clifor and
                       lancxa.titnum = fin.titluc.titnum and
                       lancxa.lantip = "c" and
                       lancxa.etbcod = fin.titluc.etbcod
                        no-error.
    if not avail lancxa
    then do:
    create lancxa.
    assign lancxa.cxacod = vcxacod
       lancxa.lancod = vlancod
       lancxa.datlan = fin.titluc.titdtpag
       lancxa.numlan = ? 
       lancxa.vallan = fin.titluc.titvlcob              
       lancxa.comhis = vcomhis 
       lancxa.lantip = "c" 
       lancxa.forcod = fin.titluc.clifor
       lancxa.titnum = fin.titluc.titnum
       lancxa.etbcod = fin.titluc.etbcod
       lancxa.modcod = fin.titluc.modcod
       lancxa.lanhis = vlanhis.


    if fin.titluc.titvldes > 0
    then do:

    create lancxa.
    assign lancxa.cxacod = 1
           lancxa.datlan = fin.titluc.titdtpag
           lancxa.numlan = ? 
           lancxa.vallan = fin.titluc.titvldes              
           lancxa.comhis = vcomhis 
           lancxa.lantip = "D" 
           lancxa.forcod = fin.titluc.clifor
           lancxa.titnum = fin.titluc.titnum
           lancxa.etbcod = fin.titluc.etbcod
           lancxa.modcod = fin.titluc.modcod.
           
           

    if fin.titluc.clifor = 101463 or
       fin.titluc.clifor = 100090
    then assign lancxa.lanhis = 204
                lancxa.lancod = 111.
    else assign lancxa.lanhis = 12
                lancxa.lancod = 439
                lancxa.comhis = fin.titluc.titnum + " " +
                                          foraut.fornom.
                                          

    end.

    if fin.titluc.titvljur > 0
    then do:

    create lancxa.
    assign lancxa.cxacod = 1 
           lancxa.lancod = 110 
           lancxa.datlan = fin.titluc.titdtpag 
           lancxa.numlan = ?  
           lancxa.vallan = fin.titluc.titvljur               
           lancxa.comhis = vcomhis  
           lancxa.lantip = "c"  
           lancxa.forcod = fin.titluc.clifor 
           lancxa.titnum = fin.titluc.titnum 
           lancxa.etbcod = fin.titluc.etbcod 
           lancxa.modcod = fin.titluc.modcod 
           lancxa.lanhis = 13.


    end.
    end.
end.
else do:

    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = fin.titluc.clifor and
                lancactb.modcod = fin.titluc.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = fin.titluc.modcod
                no-lock no-error.
    
    if avail lancactb
    then do:
        vcompl = foraut.fornom  .
        run lan-contabil("CAIXA",
                            lancactb.contacre,
                            1,
                            fin.titluc.modcod,
                            fin.titluc.titdtpag,
                            fin.titluc.titvlpag,
                            fin.titluc.clifor,
                            fin.titluc.titnum,
                            fin.titluc.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").

    end.
    
end. 
   
procedure lan-contabil:
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like fin.titulo.clifor.
    def input parameter l-titnum like fin.titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.
    def input parameter l-lantipo as char.
    def var vnumlan as int. 
    def buffer blancxa for lancxa.
    def buffer elancxa for lancxa.
    /*
    if l-landeb = 448 and
       l-landeb = 447 and
       l-landeb = 362
    then l-hiscod = "262".
    */
           
    if l-tipo = "CAIXA"
    THEN
    do on error undo:

            find first elancxa where 
                       elancxa.cxacod = lancactb.contadeb and
                       elancxa.modcod = l-modcod and
                       elancxa.forcod = l-forcod and
                       elancxa.titnum = l-titnum and
                       elancxa.lantip = "X"
                        no-error.
            if avail elancxa 
            then do on error undo:
                if month(fin.titluc.titdtpag) = month(fin.titluc.titdtemi) and
                   year(fin.titluc.titdtpag) = year(fin.titluc.titdtemi)
                then delete elancxa.
                else if lancactb.contadeb > 0
                then l-landeb = elancxa.lancod.
            end.    
            else. /* l-landeb = lancactb.contadeb.*/
            
            /* 
             message 
                l-datlan l-lancre l-landeb l-modcod l-vallan l-forcod 
                l-titnum l-lantipo l-hiscomp l-etbcod.
                pause.
            */
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = l-lantipo and
                       /*lancxa.comhis = l-hiscomp and*/
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do:            
            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-lancre
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-landeb
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = l-lantipo
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO ON ERROR UNDO:
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"      and
                       lancxa.comhis = l-hiscomp and
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do: 
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
             
                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-lancre
                    lancxa.lancod = l-landeb
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
end procedure.
    
