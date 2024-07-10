{admcab.i}

def var vrisco as char.
def var a-dia as int extent 20.
def var b-dia as int extent 20.
def var v-risco as char extent 20.
def var v-pct as dec extent 20.
def var v-vencido as dec extent 20.
def var v22 as dec.
def temp-table tt-cli no-undo 
    field clicod like clien.clicod
    field risco as char
    field titnum as char
    field titdtven as date
    field vencido as dec
    field vencer as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 clicod risco 
    .
    /***
def temp-table tt-cliv no-undo 
    field clicod like clien.clicod
    field risco as char
    field titnum as char
    field titdtven as date
    field vencido as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 clicod risco
    .
        **/

def temp-table tt-risco  no-undo
    field risco as char
    field des as char
    field vencido as dec
    field vencer as dec
    field total as dec
    field ven-90 as dec
    field ven-360 as dec
    field ven-1080 as dec
    field ven-1800 as dec
    field ven-5400 as dec
    field ven-9999 as dec
    index i1 risco
    .

def temp-table tt-tbcntgen  no-undo
    field nivel as char
    field numini as char
    field numfim as char
    field valor as dec
    index i1 nivel.

for each tbcntgen where tbcntgen.tipcon = 11
                    no-lock by tbcntgen.campo1[1]  :
    create tt-tbcntgen.
    assign
        tt-tbcntgen.nivel = tbcntgen.campo1[1]
        tt-tbcntgen.numini = tbcntgen.numini
        tt-tbcntgen.numfim = tbcntgen.numfim
        tt-tbcntgen.valor = tbcntgen.valor
        .
end. 

def var q-nivel as int.
def var v-vencer  as dec extent 20.
def var vi as int .

for each tt-tbcntgen no-lock.
    if tt-tbcntgen.nivel = ""
    then delete tt-tbcntgen.
    else assign
            vi = vi + 1
            a-dia[vi] = int(trim(tt-tbcntgen.numini))
            b-dia[vi] = int(trim(tt-tbcntgen.numfim))
            v-risco[vi] = tt-tbcntgen.nivel
            v-pct[vi] = tt-tbcntgen.valor
            .
end.

q-nivel = vi.
/*
message q-nivel b-dia[1] b-dia[2] b-dia[3] b-dia[4] b-dia[5] b-dia[6] b-dia[7]
b-dia[8] b-dia[9] b-dia[10] b-dia[11]. pause.
*/
def var vdatref as date .
def var vcatcod as int.
update vdatref  label "Data de referencia"
       help "Informe a data de referencia para Vencidos/Vencer."
              vcatcod  label "categoria"
                     help "Informe 31 para MOVEIS ou 41 para MODA."
                             with frame f11 1 down side-label width 80
                                     row 19 no-box.

if 
   vdatref < 01/01/2016
then do:
    message color red/with
    "Indisponivel para data."
    view-as alert-box.
    return.
end.
def var vtitdtven like titulo.titdtven.

disp "Aguarde processamento... "
    with frame f-pro 1 down row 10 width 80 no-box
    .
pause 0.

def var vq as int.    

/*************************

if vdatref = 07/31/15
then do:
    for each SC2015 where SC2015.titdtemi <= vdatref
                and (SC2015.titsit = "LIB" or
                    (SC2015.titsit = "PAG" and
                     SC2015.titdtpag > vdatref))
                no-lock.
        if SC2015.titsit begins "EXC"
        then next.
        
        if sc2015.cobcod = 22 and
           SC2015.titdtven > 08/20/15 then next.

        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2015.clifor /*and
                          tt-cli.titnum = SC2015.titnum*/
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                /*tt-cli.titnum = SC2015.titnum*/
                .
        end.
            
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
    end.                  
end.

if vdatref = 08/31/15
then do:
    for each SC2015 where SC2015.titdtemi <= vdatref
                and (SC2015.titsit = "LIB" or
                    (SC2015.titsit = "PAG" and
                     SC2015.titdtpag > vdatref))
                no-lock.
        if SC2015.titsit begins "EXC"
        then next.
        if sc2015.cobcod = 22 and
           SC2015.titdtven > 02/09/15 then next.


        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2015.clifor /*and
                          tt-cli.titnum = SC2015.titnum*/
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                /*tt-cli.titnum = SC2015.titnum*/
                .
        end.
            
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
    end.                  
end.

if vdatref = 09/30/15
then do:
    for each SC2015 where SC2015.titdtemi <= vdatref
                and (SC2015.titsit = "LIB" or
                    (SC2015.titsit = "PAG" and
                     SC2015.titdtpag > vdatref))
                no-lock.
        if SC2015.titsit begins "EXC"
        then next.
        if sc2015.cobcod = 22 and
           SC2015.titdtven > 01/01/15 then next.

        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2015.clifor /*and
                          tt-cli.titnum = SC2015.titnum*/
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                /*tt-cli.titnum = SC2015.titnum*/
                .
        end.
            
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
    end.                  
end.
if vdatref = 12/31/15
then do:
    for each SC2015 use-index titdtemi where SC2015.titdtemi <= vdatref
                and  ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                no-lock.
        
        if SC2015.titsit begins "EXC"
        then next.
 
        if vdatref = 12/31/15 and
           sc2015.cobcod = 22 and
           SC2015.titdtven > 12/31/15 and
           v22 + sc2015.titvlcob <= 1613943.11 /*1617393.12*/
        then do:
            v22 = v22 + sc2015.titvlcob.
            next.
        end. 
          
        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        find first tt-cli where tt-cli.clicod = SC2015.clifor /*and
                          tt-cli.titdtven = SC2015.titdtven */
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                /*tt-cli.titdtven = vtitdtven*/
                .
        end.

        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:

                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                
                if vtitdtven <= vdatref
                then do:
                    find first tt-cliv where
                               tt-cliv.clicod = SC2015.clifor and
                               tt-cliv.risco = v-risco[vi]
                               no-error.
                    if not avail tt-cliv
                    then do:
                        create tt-cliv.
                        tt-cliv.clicod = SC2015.clifor.
                        tt-cliv.risco = v-risco[vi].
                    end.           
                    tt-cliv.vencido = tt-cliv.vencido + SC2015.titvlcob.

                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.
            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
    end.                  
end.
*****/

def var ttvencido as dec.
def var vt as int.
if vdatref >= 01/31/16
then do:
    for each SC2015 use-index INDX2  where 
                        SC2015.titnat = no and
                            SC2015.titdtemi <= vdatref
                and  ((SC2015.titdtpag > vdatref and
                      SC2015.titsit = "PAG") or
                      SC2015.titsit = "LIB")
                no-lock.

        if SC2015.titdtmovref > vdatref or
           SC2015.titdtmovref = ?
        then next.

        /*
        find clien where
             clien.clicod = SC2015.clifor no-lock no-error.
        if not avail clien 
        then next.
        */
        if vcatcod > 0
        then do:
            find first contnf where contnf.etbcod = SC2015.etbcod and
                   contnf.contnum = int(SC2015.titnum)
                                      no-lock no-error.
            if avail contnf
            then do:
                find first movim where movim.etbcod = contnf.etbcod and
                                       movim.placod = contnf.placod and
                                       movim.movtdc = 5
                                       no-lock no-error.
                if avail movim
                then do:
                    find produ where produ.procod = movim.procod 
                                no-lock no-error.
                    if avail produ and
                       int(subst(string(produ.catcod),1,1))
                           <> int(subst(string(vcatcod),1,1))
                    then next.
                end.
                else if vcatcod <> 31
                    then next. 
            end.
            else if vcatcod <> 31
                then next.
        end. 
        
        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.

        find first tt-cli where tt-cli.clicod = SC2015.clifor 
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                tt-cli.risco = "A"
                .
        end.

        ttvencido = 0.
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:

                if vtitdtven <= vdatref
                then do:
                    /*
                    find first tt-cliv where
                               tt-cliv.clicod = SC2015.clifor and
                               tt-cliv.risco = v-risco[vi]
                               no-error.
                    if not avail tt-cliv
                    then do:
                        create tt-cliv.
                        tt-cliv.clicod = SC2015.clifor.
                        tt-cliv.risco = v-risco[vi].
                    end. 
                    */          

                    if v-risco[vi] > tt-cli.risco
                    then  tt-cli.risco  = v-risco[vi].
 
                    tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                    ttvencido = SC2015.titvlcob.
                    
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.
        
        if vtitdtven <= vdatref 
        then do:
            if ttvencido = 0
            then do:
                tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                
                find first tt-risco where
                           tt-risco.risco =
                                    if tt-cli.risco <> ""
                                    then tt-cli.risco else "K"
                            no-error.
                if not avail tt-risco
                then do:
                    create tt-risco.
                    tt-risco.risco = if tt-cli.risco <> ""
                                     then tt-cli.risco else "K".
                end.
                tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
            end.
        end.
        else tt-cli.vencer = tt-cli.vencer + SC2015.titvlcob.

        if vtitdtven - vdatref > 5400
        then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
        else if vtitdtven - vdatref > 1800
        then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
        else if vtitdtven - vdatref > 1080
        then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
        else if vtitdtven - vdatref > 360
        then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
        else if vtitdtven - vdatref > 90
        then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
        else if vtitdtven - vdatref > 0
        then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
        
        /*
        vt = vt + 1.
        if vt > 100000
        then leave.
        */
    end.                  
end.

/***************

if vdatref = 02/28/15
then do:
    for each SC022015 where SC022015.titdtemi <= vdatref
                and (SC022015.titsit = "LIB" or
                     SC022015.titdtpag > vdatref)
                no-lock.
        if SC022015.titsit begins "EXCSALDO"
        then next.
        
        vq = vq + 1.
        if vq = 100
        then do:
            disp SC022015.titdtemi no-label
                 SC022015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC022015.clifor 
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC022015.clifor
                .
        end.
            
        if SC022015.titdtvenaux <> ?
        then vtitdtven = SC022015.titdtvenaux.
        else vtitdtven = SC022015.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC022015.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC022015.titvlcob.  
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC022015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC022015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC022015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC022015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC022015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC022015.titvlcob.
        /***
        find first SC032015 where
                   SC032015.empcod = 19 and
                   SC032015.titnat = no and
                   SC032015.modcod = "CRE" and
                   SC032015.etbcod = SC022015.etbcod and
                   SC032015.clifor = SC022015.clifor and
                   SC032015.titnum = SC022015.titnum and
                   SC032015.titpar = SC022015.titpar
                   no-error.
        if not avail SC032015
        then do:
            create SC032015.
            buffer-copy SC022015 to SC032015.
        end.
        ***/
    end.                  
end.

if vdatref = 01/31/15
then do:
    def buffer SC2015 for SC012015.
    for each SC2015 where SC2015.titdtemi <= vdatref
                and (SC2015.titsit = "LIB" or
                    (/*SC2015.titsit = "PAG" and*/
                     SC2015.titdtpag > vdatref))
                no-lock.
        if SC2015.titsit begins "EXCSALDO"
        then next.
        
        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2015.titdtemi no-label
                 SC2015.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2015.clifor /*and
                          tt-cli.titnum = SC2015.titnum*/
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2015.clifor
                /*tt-cli.titnum = SC2015.titnum*/
                .
        end.
            
        if SC2015.titdtvenaux <> ?
        then vtitdtven = SC2015.titdtvenaux.
        else vtitdtven = SC2015.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2015.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2015.titvlcob.  
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2015.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2015.titvlcob.
        /***
        find first SC022015 where
                   SC022015.empcod = 19 and
                   SC022015.titnat = no and
                   SC022015.modcod = "CRE" and
                   SC022015.etbcod = SC2015.etbcod and
                   SC022015.clifor = SC2015.clifor and
                   SC022015.titnum = SC2015.titnum and
                   SC022015.titpar = SC2015.titpar
                   no-error.
        if not avail SC022015
        then do:
            create SC022015.
            buffer-copy SC2015 to SC022015.
        end.
        ***/
    end.                  
end.
if vdatref = 12/31/14
then do:
    for each SC2014 where SC2014.titdtemi <= vdatref
                and (SC2014.titsit = "LIB" or
                     SC2014.titdtpag > vdatref)
                no-lock.
        /*if SC2014.titsit = "EXC"
        then next.
        */
        vq = vq + 1.
        if vq = 100
        then do:
            disp SC2014.titdtemi no-label
                 SC2014.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2014.clifor /*and
                          tt-cli.titnum = SC2014.titnum*/
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2014.clifor
                /*tt-cli.titnum = SC2014.titnum*/
                .
        end.
            
        if SC2014.titdtvenaux <> ?
        then vtitdtven = SC2014.titdtvenaux.
        else vtitdtven = SC2014.titdtven.
        
        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2014.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido +  SC2014.titvlcob.
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2014.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2014.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2014.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2014.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2014.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2014.titvlcob.
        
        /*****
        find first SC012015 where
                   SC012015.empcod = 19 and
                   SC012015.titnat = no and
                   SC012015.modcod = "CRE" and
                   SC012015.etbcod = Sc2014.etbcod and
                   SC012015.clifor = SC2014.clifor and
                   SC012015.titnum = SC2014.titnum and
                   SC012015.titpar = SC2014.titpar
                   no-error.
        if not avail SC012015
        then do:
            create SC012015.
            buffer-copy SC2014 to SC012015.
        end.
        ************/
    end.                  
end.
if vdatref = 12/31/13
then do:
    for each SC2013 where SC2013.titdtemi <= vdatref
                and (SC2013.titsit = "LIB" or
                     SC2013.titdtpag > vdatref)
                no-lock.
        
        vq = vq + 1.
        if vq = 200
        then do:
            disp SC2013.titdtemi no-label
                 SC2013.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2013.clifor /*and
                          tt-cli.titnum = SC2013.titnum    */
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2013.clifor
                /*tt-cli.titnum = SC2013.titnum*/
                .
        end.
            
        /*if SC2013.titdtvenaux <> ?
        then vtitdtven = SC2013.titdtvenaux.
        else */
        
        vtitdtven = SC2013.titdtven.

        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2013.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido +  SC2013.titvlcob.
                end.
                leave.
            end.    
        end.
    
            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2013.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2013.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2013.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2013.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2013.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2013.titvlcob.

    end.                  
         
end.
if vdatref = 12/31/12
then do:
    for each SC2012 where SC2012.titdtemi <= vdatref
                and (SC2012.titsit = "LIB" or
                     SC2012.titdtpag > vdatref)
                no-lock.
        
        vq = vq + 1.
        if vq = 200
        then do:
            disp SC2012.titdtemi no-label
                 SC2012.titnum no-label with frame f-pro.
            pause 0.
            vq = 0.
        end.

        find first tt-cli where tt-cli.clicod = SC2012.clifor /*and
                          tt-cli.titnum = SC2012.titnum  */
                          no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            assign
                tt-cli.clicod = SC2012.clifor
                /*tt-cli.titnum = SC2012.titnum*/
                .
        end.
            
        /*if SC2012.titdtvenaux <> ?
        then vtitdtven = SC2012.titdtvenaux.
        else*/
         
        vtitdtven = SC2012.titdtven.

        do vi = 1 to q-nivel:
            if vdatref - vtitdtven <= b-dia[vi] 
            then do:
                if v-risco[vi] > tt-cli.risco
                then  tt-cli.risco  = v-risco[vi].
                if vtitdtven <= vdatref
                then do:
                    tt-cli.vencido = tt-cli.vencido + SC2012.titvlcob.
                    find first tt-risco where
                           tt-risco.risco = v-risco[vi] no-error.
                    if not avail tt-risco
                    then do:
                        create tt-risco.
                        tt-risco.risco = v-risco[vi].
                    end.
                    tt-risco.vencido = tt-risco.vencido + SC2012.titvlcob.
                end.
                leave.
            end.    
        end.

            if vtitdtven - vdatref > 5400
            then tt-cli.ven-9999 = tt-cli.ven-9999 + SC2012.titvlcob.
            else if vtitdtven - vdatref > 1800
            then tt-cli.ven-5400 = tt-cli.ven-5400 + SC2012.titvlcob.
            else if vtitdtven - vdatref > 1080
            then tt-cli.ven-1800 = tt-cli.ven-1800 + SC2012.titvlcob.
            else if vtitdtven - vdatref > 360
            then tt-cli.ven-1080 = tt-cli.ven-1080 + SC2012.titvlcob.
            else if vtitdtven - vdatref > 90
            then tt-cli.ven-360 = tt-cli.ven-360 + SC2012.titvlcob.
            else if vtitdtven - vdatref > 0
            then tt-cli.ven-90 = tt-cli.ven-90 + SC2012.titvlcob.

    end.                  
         
end.
********************/

/*****
for each tt-cliv no-lock:
    find first tt-cli where
               tt-cli.clicod = tt-cliv.clicod and
               tt-cli.risco = tt-cliv.risco
               no-lock no-error.
    if not avail tt-cli
    then do:
        create tt-cli.
        tt-cli.clicod = tt-cliv.clicod.
        tt-cli.risco = tt-cliv.risco.
    end. 
    tt-cli.vencido = tt-cli.vencido + tt-cliv.vencido.
end.               
*****/

for each tt-risco: delete tt-risco. end.

def var p-vencer as dec.
for each tt-cli :
    if tt-cli.risco = ""
    then do:
        tt-cli.risco = "K".
        output to ./cli-rico-k.txt append.
        export tt-cli.
        output close.
    end.
    find first tt-risco where
            tt-risco.risco = tt-cli.risco no-error.
    if not avail tt-risco
    then do:
        create tt-risco.
        tt-risco.risco = tt-cli.risco.
    end.    
        
    assign
        tt-risco.ven-90  = tt-risco.ven-90  + tt-cli.ven-90
        tt-risco.ven-360  = tt-risco.ven-360  + tt-cli.ven-360
        tt-risco.ven-1080  = tt-risco.ven-1080  + tt-cli.ven-1080
        tt-risco.ven-1800  = tt-risco.ven-1800  + tt-cli.ven-1800
        tt-risco.ven-5400  = tt-risco.ven-5400  + tt-cli.ven-5400
        tt-risco.ven-9999  = tt-risco.ven-9999  + tt-cli.ven-9999
        tt-risco.vencer = tt-risco.vencer + tt-cli.vencer
        tt-risco.vencido = tt-risco.vencido + tt-cli.vencido
        .

end.     

/*****
output to tt-cliv.txt.
for each tt-cliv no-lock:
    export tt-cliv.
end.
output close. 
*****/
/*****
if vdatref = 05/31/15
then do:
    find first tt-risco where
               tt-risco.risco = "H" no-error.
    if avail tt-risco
    then    
        tt-risco.vencido = tt-risco.vencido - 4676534.05
        .
end.
if vdatref = 06/30/15
then do:
    find first tt-risco where
               tt-risco.risco = "H" no-error.
    if avail tt-risco
    then    
        tt-risco.vencido = tt-risco.vencido - 9377438.21
        .
end.
if vdatref = 07/31/15
then do:
    find first tt-risco where
               tt-risco.risco = "H" no-error.
    if avail tt-risco
    then    
        tt-risco.vencido = tt-risco.vencido - 68556.29
         .
end.
if vdatref = 08/31/15
then do:
    find first tt-risco where
               tt-risco.risco = "H" no-error.
    if avail tt-risco
    then    
        tt-risco.vencido = tt-risco.vencido - 250316.74
         .
end.
if vdatref = 09/30/15
then do:
    find first tt-risco where
               tt-risco.risco = "H" no-error.
    if avail tt-risco
    then    
        tt-risco.vencido = tt-risco.vencido - 34723.92 .
end.
******/

run relatorio.

hide frame f11 no-pause.
hide frame f-pro no-pause.

{setbrw.i}

assign
    a-seeid = -1 a-recid = -1 a-seerec = ?.

for each tt-risco :
    if tt-risco.risco = ""
    then delete tt-risco.
    else do:
        tt-risco.total = tt-risco.total + tt-risco.vencido + tt-risco.vencer.
        find first tt-tbcntgen where
                   tt-tbcntgen.nivel = tt-risco.risco 
                   no-error.
        if avail tt-tbcntgen
        then tt-risco.des = tt-tbcntgen.numini + "-" +
                            tt-tbcntgen.numfim.
        tt-risco.total = tt-risco.vencido + tt-risco.vencer.
    end.
end.             
         
form tt-risco.risco column-label "Faixa"
     tt-risco.des no-label   
     tt-risco.vencido column-label "Vencidos" format ">>>,>>>,>>9.99"
     tt-risco.vencer  column-label "Vencer"   format ">>>,>>>,>>9.99"
     tt-risco.total   column-label "Total"    format ">>>,>>>,>>9.99"
     with frame f-linha down centered.

l1: repeat:
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-risco  
        &help  = "Tecle ENTER pra relatorio analitico por contrato"
        &cfield = tt-risco.risco
        &noncharacter = /* 
        &ofield = " tt-risco.des
                    tt-risco.vencido
                    tt-risco.vencer
                    tt-risco.total
                    "  
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = " 
                        run relatorio-faixa-analitico(tt-risco.risco).
                        
                        " 
        &go-on = F4 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro encontrado""
                        view-as alert-box.
                        leave l1.
                        " 
        &otherkeys1 = " "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.


procedure relatorio:
    def var varquivo as char.
    def var sld-curva as dec.
    def var vprovisao as dec.
    varquivo = "/admcom/relat/bc-prodevduv" + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "190"  
        &Page-Line = "66"
        &Nom-Rel   = ""prodevduv""  
        &Nom-Sis   = """SISTEMA ADMCOM CONTABIL"""
        &Tit-Rel   = """PROVISAO DE DEVEDORES DUVIDOSOS - CONTABIL"""
        &Width     = "190"
        &Form      = "frame f-cabcab"}

    disp with frame f11.
    vi = 0.    
    for each tt-risco where tt-risco.risco <> ""  NO-LOCK:
        vi = vi + 1.    
        sld-curva = tt-risco.vencido + tt-risco.vencer.
        /*/*sld-curva +*/ tt-risco.vencido +
                    tt-risco.ven-90 + tt-risco.ven-360 +
                    tt-risco.ven-1080 + tt-risco.ven-1800 +
                    tt-risco.ven-5400 + tt-risco.ven-9999
                    .  */
        vprovisao = sld-curva * (v-pct[vi] / 100).
        disp tt-risco.risco column-label "Faixa"
             tt-risco.vencido column-label "Vencidos"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-90  column-label "Vencer!Ate 3 meses"
             format ">>>,>>>,>>9.99" (total)
             tt-risco.ven-360 column-label "Vencer!3 a 12 meses"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-1080 column-label "Vencer!1 a 3 anos"
             format ">>>,>>>,>>9.99"  (total) 
             tt-risco.ven-1800 column-label "Vencer!3 a 5 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-5400 column-label "Vencer!5 a 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             tt-risco.ven-9999 column-label "Vencer!+ 15 anos"
             format ">>>,>>>,>>9.99"  (total)
             sld-curva  column-label "Sld Curva"
             format ">>,>>>,>>>,>>9.99"  (total)
             vprovisao  column-label "Provisao"
             format ">>>,>>>,>>9.99"  (total)
             v-pct[vi] column-label "%"
             with frame f-disp down width 200.
            .
        down with frame f-disp.
end.     



    output close.
    
/*****    
    vrisco = "A".
    run gera-arquivo-scv.
    vrisco = "B".
    run gera-arquivo-scv.
    vrisco = "C".
    run gera-arquivo-scv.
    vrisco = "D".
    run gera-arquivo-scv.
    vrisco = "E".
    run gera-arquivo-scv.
    vrisco = "F".
    run gera-arquivo-scv.
    vrisco = "G".
    run gera-arquivo-scv.
    vrisco = "H".
    run gera-arquivo-scv.
*****/

    run visurel.p(varquivo,"").
    
end procedure.

procedure gera-arquivo-scv:
    def var vclinom like clien.clinom.
    def var vciccgc as char format "x(16)".
    def var varq as char.
 
    varq = "/admcom/relat/bc-devedores-" +
            string(vdatref,"99999999") + "-risco" + vrisco + ".csv". 
    output to value(varq).
    put "Codigo;Nome;CPF;Valor;Faixa" skip.
    for each tt-cli where tt-cli.clicod > 0 and
            tt-cli.risco = vrisco no-lock:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = ""
                vciccgc = "".
        if (tt-cli.vencido +
             tt-cli.ven-90  +
             tt-cli.ven-360 +
             tt-cli.ven-1080 +
             tt-cli.ven-1800 +
             tt-cli.ven-5400 +
             tt-cli.ven-9999)  = 0
        then next.
             
        vclinom = replace(vclinom,";","").
        vciccgc = replace(vciccgc,";","").
        vciccgc = replace(vciccgc,",","").
        vciccgc = replace(vciccgc,".","").
        vciccgc = replace(vciccgc,"/","").

        put tt-cli.clicod format ">>>>>>>>>9"
            ";"
            vclinom format "x(40)"
            ";"
            vciccgc format "x(16)"
            ";"
            (tt-cli.vencido +
             tt-cli.ven-90  +
             tt-cli.ven-360 +
             tt-cli.ven-1080 +
             tt-cli.ven-1800 +
             tt-cli.ven-5400 +
             tt-cli.ven-9999) format ">>>,>>>,>>9.99"
             ";"
             tt-cli.risco
             skip.
    end.
    output close. 
 
end.

procedure relatorio-faixa-analitico:
    def input parameter vrisco as char.
    def var vclinom like clien.clinom.
    def var vciccgc as char format "x(16)".
    def var varq as char.

    varq = "/admcom/relat/bc-devedores-" +
            string(vdatref,"99999999") + "-risco-" + vrisco + ".csv". 
    output to value(varq).
    put "Codigo;Nome;CPF;Valor;Faixa" skip.
    for each tt-cli where /*tt-cli.clicod > 0 and*/
            tt-cli.risco = vrisco no-lock:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if avail clien
        then assign
                vclinom = clien.clinom
                vciccgc = clien.ciccgc.
        else assign
                vclinom = ""
                vciccgc = "".
        if (tt-cli.vencido +
             tt-cli.ven-90  +
             tt-cli.ven-360 +
             tt-cli.ven-1080 +
             tt-cli.ven-1800 +
             tt-cli.ven-5400 +
             tt-cli.ven-9999)  = 0
        then next.
             
        vclinom = replace(vclinom,";","").
        vciccgc = replace(vciccgc,";","").
        vciccgc = replace(vciccgc,",","").
        vciccgc = replace(vciccgc,".","").
        vciccgc = replace(vciccgc,"/","").

        put tt-cli.clicod format ">>>>>>>>>9"
            ";"
            vclinom format "x(40)"
            ";"
            vciccgc format "x(16)"
            ";"
            (tt-cli.vencido +
             tt-cli.ven-90  +
             tt-cli.ven-360 +
             tt-cli.ven-1080 +
             tt-cli.ven-1800 +
             tt-cli.ven-5400 +
             tt-cli.ven-9999) format ">>>,>>>,>>9.99"
             ";"
             tt-cli.risco
             skip.
    end.
    output close. 
    message color red/with
        "Arquivo csv gerado:" skip
        varq
        view-as alert-box
        .
end procedure.
