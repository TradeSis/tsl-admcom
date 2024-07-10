{admcab.i}

def var vresp       as log      init no    no-undo.
def var vop as log format "GERAL/PARCIAL".
def var varquivo as char.
def var tot  like plani.platot.
def var tot1  like plani.platot.
def var vac   like plani.platot.
def var tot2  like plani.platot.
def var vde   like plani.platot.
def var vest like estoq.estatual.
def var vtipo as char format "x(10)" extent 2
                initial ["Numerica","Alfabetica"].
def var vpend   as int format "->>>9".
def var vetbcod like estab.etbcod.
def var vqtd like estoq.estinvctm format "->,>>9.99".
def var vprocod like estoq.procod.
def var vdata   like estoq.estbaldat format "99/99/9999".
def var vcatcod like produ.catcod.
def temp-table tt-importa
    field procod like produ.procod
    field qtd as int
    index i1 procod.
    
form vprocod
     produ.pronom format "x(30)"
     vqtd
     vpend
     coletor.colqtd column-label "Qtd" with frame f-pro width 80 down.

update  vcatcod with frame f-data.
find categoria where categoria.catcod = vcatcod no-lock.
display categoria.catnom no-label with frame f-data.
update  vdata label "Data Referencia" with frame f-data side-label centered.

if vcatcod = 31 or vcatcod = 41  
then do:
    message "Digitar dados ?" update vresp format "Sim/Nao".
end. 

if vresp  then
repeat:
    update vetbcod with frame f-etbcod side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento nao cadastrado".
        undo, retry.
    end.
    display estab.etbnom no-label with frame f-etbcod.
    repeat:
        assign tot  = 0 tot1 = 0 vac  = 0
               tot2 = 0 vde  = 0 vprocod = 0.

        update vprocod with frame f-pro down width 80.
        find produ where produ.procod = vprocod no-lock.
        display produ.pronom format "x(30)"
                    with frame f-pro.
        vqtd = 0.
        vpend = 0.
        find estoq where estoq.etbcod = estab.etbcod 
                     and estoq.procod = produ.procod 
                         no-lock no-error.

        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if not avail coletor
        then do transaction:
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.procod = produ.procod
                   coletor.coldat = vdata
                   coletor.catcod = vcatcod.
        end.
        do transaction:
            display coletor.colqtd with frame f-pro.
            update vqtd column-label "Quantidade"
                   vpend column-label "Pendencia" with frame f-pro.
            coletor.colacr = 0.
            coletor.coldec = 0.
            if vpend >= 0
            then coletor.colqtd =  coletor.colqtd + vqtd - vpend.
            else coletor.colqtd =  coletor.colqtd + vqtd + vpend.
            display coletor.colqtd with frame f-pro down.
            down with frame f-pro.
        end.
        vest = estoq.estatual.
        
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 08           and
                             movim.movdat > vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                       use-index plani no-lock no-error.

            if not avail plani 
            then next.
            
            vest = vest + movim.movqtm.
        end.
            
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 07           and
                             movim.movdat > vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                       use-index plani no-lock no-error.

            if not avail plani 
            then next.
            vest = vest - movim.movqtm.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            if movim.movtdc = 7 or
               movim.movtdc = 8
            then next.

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:

             if movim.movtdc = 7 or
                movim.movtdc = 8
             then next.

             find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.

    end.

    message "Deseja gerar arquivo para CONFRONTO" update sresp.
    if not sresp
    then return.

    display "GERANDO ARQUIVO PARA CONFRONTO................"
                            WITH FRAME F-MEN CENTERED ROW 10 OVERLAY.

    for each produ where produ.catcod = vcatcod no-lock:
        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        if avail coletor
        then next.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        display produ.procod with 1 down. pause 0.
        
        
        vest = estoq.estatual.
        
        
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 08           and
                             movim.movdat > vdata no-lock:
            
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

            if not avail plani 
            then next.
            vest = vest + movim.movqtm.
        end.
            
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 07           and
                             movim.movdat > vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

            if not avail plani 
            then next.
            vest = vest - movim.movqtm.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:
        
            if movim.movtdc = 7 or
               movim.movtdc = 8
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            if movim.movtdc = 7 or
               movim.movtdc = 8
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.

 
        if vest = 0
        then next.

        do transaction:
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.procod = produ.procod
                   coletor.coldat = vdata
                   coletor.colqtd = vest. 
        end.

        do transaction:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.

            if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
        
    end.
    
    run listagem.

end.
else do: 

    def var v as int.
    def var vlinha as char.
    def var vquant as int.
    def var vdata1 as date.
    def var vetbcod1 like estab.etbcod.
    
    update  vetbcod label "Filial"
            with frame f-inf1.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-inf1.        
    update varquivo  form "x(60)"  
                label "Arquivo"
          with frame f-inf1 side-label. 

    message "Confirma a importacao do arquivo inventario?"
           update sresp.
    if sresp = yes
    then do:
        if search(varquivo) = ?
        then do:
             message "Arquivo nao encontrado, favor verificar!"
                            view-as alert-box.
                    undo, retry.
        end.
        disp "Importando dados...."
            with frame fi1 row 14 1 down no-box centered
            no-label. pause 0.
        v = 1.
        for each tt-importa. delete tt-importa. end.
        input from value(varquivo).
        repeat:
            import unformatted vlinha .
            if v = 1
            then do:
                vetbcod1 = int(substr(string(vlinha),2,3)). /*2,11*/
                vdata   = date(int(substr(string(vlinha),13,2)), /*16,2*/
                               int(substr(string(vlinha),10,2)), /*13,2*/
                               int(substr(string(vlinha),16,2)) + 2000). /*19,2*/
                if vetbcod1 <> vetbcod
                then do:
                    bell.
                    message color red/with
                        "Arquivo de outra filial"
                        view-as alert-box title " Atencao! "
                        .
                    leave.    
                end. 
            end.
            else do:
                vprocod = int(substr(string(vlinha),2,14)).
                vqtd = int(substr(string(vlinha),15,20)).
                create tt-importa.
                assign
                    tt-importa.procod = vprocod
                    tt-importa.qtd = vqtd
                    vquant = vquant + vqtd.        
            end.
            v = v + 1.
            disp vetbcod1 vdata vprocod format ">>>>>>>9"
                    vquant with frame fi1.
            pause 0.
        end.
        input close.
        if vetbcod <> vetbcod1
        then return. 
        disp "Gravando dados......." with frame fi2
            1 down no-box no-label row 15 centered.
            pause 0.
        vquant = 0.
        for each tt-importa where tt-importa.procod > 0:
            vquant = vquant + tt-importa.qtd.
            disp vetbcod vdata tt-importa.procod format ">>>>>>>9"
                    vquant with frame fi2.
            pause 0.
            find first coletor where
                 coletor.etbcod = vetbcod and
                 coletor.procod = tt-importa.procod and
                 coletor.coldat = vdata
                 no-error.
            if not avail coletor
            then do transaction:     
                create coletor.
                assign
                    coletor.etbcod = vetbcod 
                    coletor.procod = tt-importa.procod
                    coletor.pronom = "COLETADO"
                    coletor.coldat = vdata.
            end.        
            do transaction:
            coletor.colqtd = tt-importa.qtd.
            end.
        end.
    end.
    
    message "Deseja gerar arquivo para CONFRONTO" update sresp.
    if not sresp
    then return.

    display "GERANDO ARQUIVO PARA CONFRONTO................"
                            WITH FRAME F-MEN1 CENTERED ROW 10 OVERLAY.

    run confronto.

    run listagem1.

end.

procedure confronto:
    for each produ where produ.catcod = vcatcod no-lock:
        
        message vdata estab.etbcod . 

        find coletor where coletor.etbcod = estab.etbcod and
                           coletor.procod = produ.procod and
                           coletor.coldat = vdata no-error.
        
        if not avail coletor /*and vest <> 0*/                   
        then do:
        
            create coletor.
            assign coletor.etbcod = estab.etbcod
                   coletor.procod = produ.procod
                   coletor.pronom = "NAO COLETADO"
                   coletor.coldat = vdata.
        end.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        display produ.procod with 1 down. pause 0.
        
        
        vest = estoq.estatual.
        
        
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 08           and
                             movim.movdat > vdata no-lock:
            
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

            if not avail plani 
            then next.
            vest = vest + movim.movqtm.
        end.
            
        for each movim where movim.etbcod = estab.etbcod and
                             movim.procod = produ.procod and
                             movim.movtdc = 07           and
                             movim.movdat > vdata no-lock:
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

            if not avail plani 
            then next.
            vest = vest - movim.movqtm.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.emite  = estab.etbcod and
                             movim.datexp > vdata no-lock:
        
            if movim.movtdc = 7 or
               movim.movtdc = 8
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat use-index plani
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.

            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = estab.etbcod and
                             movim.datexp > vdata no-lock:

            if movim.movtdc = 7 or
               movim.movtdc = 8
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat
                                                     no-lock no-error.

            if not avail plani
            then next.
            
            if avail plani
            then do:
                if plani.emite = 22 and plani.desti = 996
                then next.
                
            end.
            
            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then next.
            
            if plani.etbcod <> estab.etbcod and
               plani.desti  <> estab.etbcod
            then next.

            if plani.emite = 22 and
               plani.serie = "m1"
            then next.

            if plani.movtdc = 5 and
               plani.emite  <> estab.etbcod
            then next.
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  
               then do:
                   if movim.movdat >= vdata
                   then vest = vest + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 
            then do:
                if movim.movdat >= vdata
                then vest = vest - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.
                if plani.desti = estab.etbcod
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.
            end.
        end.

        assign    coletor.estatual = vest
                   coletor.estcusto = estoq.estcusto.

        do:
            if vest > coletor.colqtd
            then coletor.coldec = vest - coletor.colqtd.
            else if vest < coletor.colqtd
            then coletor.colacr = coletor.colqtd - vest.
        end.
        
    end.

end procedure.

procedure listagem:
vop = yes.

    message "Listagem: [ G ] Geral  [ P ] Parcial" update vop.

    display vtipo no-label with frame ff centered row 10.
    choose field vtipo with frame ff.

    if opsys = "UNIX"
    then varquivo = "../relat/digu" + string(time).
    else varquivo = "..\relat\digw" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = """dig04"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom + "" "" +
                                          string(vdata,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}
        
    if frame-index = 1
    then do:
        for each coletor where coletor.etbcod = vetbcod and
                               coletor.coldat = vdata no-lock by coletor.procod:

            find produ where produ.procod = coletor.procod no-lock.
            display produ.procod format ">>>>>>>>9"
                    produ.pronom 
                    coletor.colqtd column-label "Quantidade" format "->>,>>9.99"
                    coletor.colacr when coletor.colacr > 0 format "->>,>>9.99"
                    coletor.coldec when coletor.coldec > 0 format "->>,>>9.99"
                                        with frame f-cotac down width 200.
        end.
    end. 
    else do: 
        for each produ use-index catpro where 
                            produ.catcod = categoria.catcod no-lock,
            each coletor where coletor.etbcod = vetbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata break by produ.catcod:

            find estoq where estoq.etbcod = coletor.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq 
            then vest = estoq.estatual.
            else next.
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 08           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                vest = vest + movim.movqtm.
            
            end.
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 07           and
                                 movim.movdat > vdata no-lock:
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                vest = vest - movim.movqtm.

            end.
            
            for each movim where movim.procod = produ.procod and
                                 movim.emite  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                if plani.etbcod <> estab.etbcod and 
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and 
                   plani.serie = "m1" 
                then next.

                if plani.movtdc = 5 and 
                   plani.emite  <> estab.etbcod 
                then next.

                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                then do: 
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or 
                   movim.movtdc = 12 or 
                   movim.movtdc = 15 or 
                   movim.movtdc = 17 
                then do: 
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.
                end.
            end.
        
            for each movim where movim.procod = produ.procod and
                                 movim.desti  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                           no-lock no-error.

                if not avail plani
                then next.
            
                if avail plani
                then do:
                    if plani.emite = 22 and plani.desti = 996
                    then next.
                
                end.
            
                if movim.movtdc = 5  or  
                   movim.movtdc = 12 or  
                   movim.movtdc = 13 or  
                   movim.movtdc = 14 or  
                   movim.movtdc = 16 
                then next.
            
            
                if plani.etbcod <> estab.etbcod and
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and
                   plani.serie = "m1"
                then next.

                if plani.movtdc = 5 and
                   plani.emite  <> estab.etbcod
                then next.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.
                end.
            end.    
            
            if vest = coletor.colqtd
            then do transaction:
                assign coletor.colacr = 0
                       coletor.coldec = 0.

                if vop = no
                then next.
                
            end.
            if coletor.colqtd = 0 and
               vest = 0
               then next.
            
            if coletor.colacr >= 0
            then assign tot = coletor.colacr
                        tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                        vac  = vac  + coletor.colacr.

            if coletor.coldec >= 0
            then assign tot = coletor.coldec
                        tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                        vde  = vde  + coletor.coldec.

            
            display produ.procod  format ">>>>>>>>9"
                    produ.pronom format "x(37)"
                    vest(total by produ.catcod)
                        column-label "Comput." format "->>>>9"
                    coletor.colqtd(total by produ.catcod) 
                        column-label "Fisico" format "->>>>9"
                    coletor.colacr when coletor.colacr > 0 format "->>>>>9"
                    coletor.coldec when coletor.coldec > 0 format "->>>>>9"
                    estoq.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (coletor.colacr * estoq.estcusto) when colacr > 0
                        column-label "Acresc" format   "->>>>9"
                    (coletor.coldec * estoq.estcusto) when coldec > 0
                        column-label "Decres"  format "->>>>9"
                                        with frame f-cotac2 down width 200.
                
        end.
        put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
                 "  TOTAL ACRESCIMO     : "       vac skip
                 "TOTAL VL. DECRESCIMO: " at 40 tot2
                 "  TOTAL DECRESCIMO    : "       vde.
    end.
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"")   .
    end.
    else do:
        {mrod.i}
    end.        
end procedure.
procedure listagem1:
vop = yes.

    message "Listagem: [ G ] Geral  [ P ] Parcial" update vop.

    display vtipo no-label with frame ff centered row 10.
    choose field vtipo with frame ff.

    if opsys = "UNIX"
    then varquivo = "../relat/digu" + string(time).
    else varquivo = "..\relat\digw" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "147"
        &Page-Line = "66"
        &Nom-Rel   = """dig04"""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """CONTROLE DE ESTOQUE - "" + estab.etbnom + ""  "" +
                                                   categoria.catnom + "" "" +
                                          string(vdata,""99/99/9999"")"
        &Width     = "147"
        &Form      = "frame f-cab"}
        
    if frame-index = 1
    then do:
        for each coletor where coletor.etbcod = vetbcod and
                               coletor.coldat = vdata
                               no-lock by coletor.procod:

            find produ where produ.procod = coletor.procod no-lock.
            /**
            display produ.procod format ">>>>>>>>9"
                    produ.pronom 
                    coletor.colqtd column-label "Quantidade" format "->>,>>9.99"
                    coletor.colacr when coletor.colacr > 0 format "->>,>>9.99"
                    coletor.coldec when coletor.coldec > 0 format "->>,>>9.99"
                                        with frame f-cotac down width 200.
            **/
            display produ.procod  format ">>>>>>>>9"
                    produ.pronom format "x(37)"
                    coletor.estatual(total)
                        column-label "Comput." format "->>>>9"
                    coletor.colqtd(total) 
                        column-label "Fisico" format "->>>>9"
                    coletor.colacr when coletor.colacr > 0 format "->>>>>9"
                    coletor.coldec when coletor.coldec > 0 format "->>>>>9"
                    coletor.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (coletor.colacr * coletor.estcusto) when colacr > 0
                        column-label "Acresc" format   "->>>>9"
                    (coletor.coldec * coletor.estcusto) when coldec > 0
                        column-label "Decres"  format "->>>>9"
                                        with frame f-cotac down width 200.
             
        end.
    end. 
    else do: 
        for each produ use-index catpro where 
                            produ.catcod = categoria.catcod no-lock,
            each coletor where coletor.etbcod = vetbcod and
                               coletor.procod = produ.procod and
                               coletor.coldat = vdata break by produ.catcod:
            /***
            find estoq where estoq.etbcod = coletor.etbcod and
                             estoq.procod = produ.procod no-lock no-error.
            if avail estoq 
            then vest = estoq.estatual.
            else next.
            
        
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 08           and
                                 movim.movdat > vdata no-lock:
            
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                vest = vest + movim.movqtm.
            
            end.
            
            for each movim where movim.etbcod = estab.etbcod and
                                 movim.procod = produ.procod and
                                 movim.movtdc = 07           and
                                 movim.movdat > vdata no-lock:
            
                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                vest = vest - movim.movqtm.

            end.
            
            for each movim where movim.procod = produ.procod and
                                 movim.emite  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat 
                                         use-index plani no-lock no-error.

                if not avail plani 
                then next.
            
                if plani.etbcod <> estab.etbcod and 
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and 
                   plani.serie = "m1" 
                then next.

                if plani.movtdc = 5 and 
                   plani.emite  <> estab.etbcod 
                then next.

                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  or
                   movim.movtdc = 18
                then do: 
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or 
                   movim.movtdc = 12 or 
                   movim.movtdc = 15 or 
                   movim.movtdc = 17 
                then do: 
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.
                end.
            end.
        
            for each movim where movim.procod = produ.procod and
                                 movim.desti  = estab.etbcod and
                                 movim.datexp > vdata no-lock:

                if movim.movtdc = 7 or
                   movim.movtdc = 8
                then next.

                find first plani where plani.etbcod = movim.etbcod and
                                       plani.placod = movim.placod and
                                       plani.movtdc = movim.movtdc and
                                       plani.pladat = movim.movdat
                                           no-lock no-error.

                if not avail plani
                then next.
            
                if avail plani
                then do:
                    if plani.emite = 22 and plani.desti = 996
                    then next.
                
                end.
            
                if movim.movtdc = 5  or  
                   movim.movtdc = 12 or  
                   movim.movtdc = 13 or  
                   movim.movtdc = 14 or  
                   movim.movtdc = 16 
                then next.
            
            
                if plani.etbcod <> estab.etbcod and
                   plani.desti  <> estab.etbcod
                then next.

                if plani.emite = 22 and
                   plani.serie = "m1"
                then next.

                if plani.movtdc = 5 and
                   plani.emite  <> estab.etbcod
                then next.
                if movim.movtdc = 5 or
                   movim.movtdc = 13 or
                   movim.movtdc = 14 or
                   movim.movtdc = 16 or
                   movim.movtdc = 8  
                then do:
                    if movim.movdat >= vdata
                    then vest = vest + movim.movqtm.
                end.

                if movim.movtdc = 4 or
                   movim.movtdc = 1 or
                   movim.movtdc = 7 or
                   movim.movtdc = 12 or
                   movim.movtdc = 15 
                then do:
                    if movim.movdat >= vdata
                    then vest = vest - movim.movqtm.
                end.

                if movim.movtdc = 6
                then do:
                    if plani.etbcod = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest + movim.movqtm.
                    end.
                    if plani.desti = estab.etbcod
                    then do:
                        if movim.movdat >= vdata
                        then vest = vest - movim.movqtm.
                    end.
                end.
            end.    
            ***/
            
            if coletor.estatual = coletor.colqtd
            then do transaction:
                assign coletor.colacr = 0
                       coletor.coldec = 0.

                if vop = no
                then next.
                
            end.
            if coletor.colqtd = 0 and 
            coletor.estatual = 0
            then next.
            
            if coletor.colacr >= 0
            then assign tot = coletor.colacr
                        tot1 = tot1 + (estoq.estcusto * coletor.colacr)
                        vac  = vac  + coletor.colacr.

            if coletor.coldec >= 0
            then assign tot = coletor.coldec
                        tot2 = tot2 + (estoq.estcusto * coletor.coldec)
                        vde  = vde  + coletor.coldec.

            
            display produ.procod  format ">>>>>>>>9"
                    produ.pronom format "x(37)"
                    coletor.estatual(total by produ.catcod)
                        column-label "Comput." format "->>>>9"
                    coletor.colqtd(total by produ.catcod) 
                        column-label "Fisico" format "->>>>9"
                    coletor.colacr when coletor.colacr > 0 format "->>>>>9"
                    coletor.coldec when coletor.coldec > 0 format "->>>>>9"
                    coletor.estcusto column-label "Pc.Custo" format ">,>>9.99"
                    (coletor.colacr * coletor.estcusto) when colacr > 0
                        column-label "Acresc" format   "->>>>9"
                    (coletor.coldec * coletor.estcusto) when coldec > 0
                        column-label "Decres"  format "->>>>9"
                                        with frame f-cotac2 down width 200.
                
        end.
        put skip "TOTAL VL. ACRESCIMO : " at 40 tot1
                 "  TOTAL ACRESCIMO     : "       vac skip
                 "TOTAL VL. DECRESCIMO: " at 40 tot2
                 "  TOTAL DECRESCIMO    : "       vde.
    end.
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"")   .
    end.
    else do:
        {mrod.i}
    end.        
end procedure.
