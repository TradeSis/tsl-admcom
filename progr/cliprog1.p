{admcab.i}

def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-vp
            field etbcod like estab.etbcod
            field data as date
            field valor as dec
            field acre as dec.
 
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

def shared temp-table tt-estab
    field etbcod like estab.etbcod
    .
def var vpra-z as dec.
for each tt-estab:
    vpra-z = 0.
    if tt-estab.etbcod = 22
    then delete tt-estab.
    else do:
    for each ctcartcl where
               ctcartcl.etbcod = tt-estab.etbcod and
               ctcartcl.datref >= vdti and
               ctcartcl.datref <= vdtf
               no-lock .
        vpra-z = vpra-z + ctcartcl.ecfprazo.
    end.    
    if vpra-z > 0           
    then delete tt-estab.
    end.
end.
/*
find first tt-estab no-error.
if not avail tt-estab
*/

find first ctcartcl where
           ctcartcl.datref >= vdti and
           ctcartcl.datref <= vdtf and
           ctcartcl.ecfprazo > 0 and
           ctcartcl.etbcod > 0
           no-lock no-error.
if avail ctcartcl
then do:
    message "JA PROCESSADO..." .
    PAUSE.
    return.               
end.

sresp = no.
message "Confirma processamento? " update sresp.
if not sresp
then return.
 
def var vdata as date.
def var vlvist as dec.
def var vlpraz as dec.
def var totecf as dec.
def var vtottit as dec.
def var tot-prazo as dec.
def var tot-titulo as dec.
def var a-prazo as dec.
def var a-vista as dec.
def var tot-contrato as dec.
def var tot-vista as dec.
def var val-vista as dec.
def var v-descarta as log init no.
def temp-table tt-contrato like contrato.
for each tt-estab  no-lock:
        /*if tt-estab.etbcod <> 3
        then next.
        */
        find estab where estab.etbcod = tt-estab.etbcod no-lock.
        disp "Processando INDEX-VENDAS...       "
        estab.etbcod with frame f-ndx 1 down no-label
            centered color  message no-box.
        pause 0.
        tot-prazo = 0.
        tot-titulo = 0.
        do vdata = vdti to vdtf:
            disp vdata with frame f-ndx.
            pause 0.
            assign vlvist = 0 vlpraz = 0 totecf = 0 vtottit = 0
                a-vista = 0 a-prazo = 0 tot-contrato = 0 tot-vista = 0
                val-vista = 0.
            for each tt-contrato.
                delete tt-contrato.
            end.
            
            for each mapctb where mapctb.etbcod = estab.etbcod and
                                  mapctb.datmov = vdata no-lock.

                if mapctb.ch2 = "E"                 
                then next.
                 
                totecf = totecf + 
                        (mapctb.t01 + 
                         mapctb.t02 + 
                         mapctb.t03 +
                         mapctb.vlsub).
            
            end.
 
            for each plani use-index pladat 
                                     where plani.movtdc = 5 and
                                           plani.etbcod = estab.etbcod and
                                           plani.pladat = vdata no-lock.
                if substr(string(plani.notped),1,1) <> "C"
                then next.

                v-descarta = no.
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc
                                     no-lock:

                        find first produ where produ.procod = movim.procod 
                                no-lock.
               
                        if movim.movpc = 0 or
                            movim.movqtm = 0
                        then next.   
                    
                
                        find clafis where clafis.codfis = produ.codfis 
                            no-lock no-error. 

                        if not avail clafis or produ.codfis = 0  
                        then do:
                          if produ.pronom matches "*vivo*" or
                             produ.pronom matches "*tim*" or
                             produ.pronom matches "*claro*"
                         then v-descarta = yes.
                        end.     
                end.     
                if v-descarta = yes
                then next.
                
                val-vista = 0.
                if plani.crecod = 1
                then assign
                        vlvist = vlvist + plani.platot
                        val-vista = val-vista + plani.platot.
                else if plani.crecod = 2
                then do:
                    if plani.platot > plani.biss
                    then assign
                            vlvist = vlvist + plani.vlserv.
                            val-vista = val-vista + plani.vlserv.

                    vlpraz = vlpraz + plani.biss.
                    find first contnf where contnf.etbcod = plani.etbcod
                           and contnf.placod = plani.placod no-lock
                           no-error.
                    if  avail contnf 
                    then do:
                        find contrato where 
                             contrato.contnum = contnf.contnum
                             no-lock no-error.
                        if avail contrato
                        then do:
                            
                            find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                            if  avail envfinan
                            then next.
 
                            for each  titulo where 
                                titulo.empcod = 19  and 
                                titulo.titnat = no   and
                                titulo.modcod = "CRE" and      
                                titulo.etbcod = plani.etbcod and
                                titulo.clifor = plani.desti and
                                titulo.titnum = string(contnf.contnum) 
                                    no-lock.
                                if titulo.clifor = 1 then next.
                                if titulo.titnat = yes then next.
                                if titulo.modcod <> "CRE" then next.
                                if titulo.titpar = 0 
                                then do:
                                    assign
                                        vlvist = vlvist + titulo.titvlcob
                                        val-vista = val-vista + titulo.titvlcob.
                                    next.
                                end.
                                vtottit = vtottit + titulo.titvlcob.
                            end.
                            create tt-contrato.
                            buffer-copy contrato to tt-contrato.
                            
                            find cpcontrato where
                                 cpcontrato.contnum = contrato.contnum
                                 no-error.
                            if not avail cpcontrato
                            then do:
                                create cpcontrato.
                                cpcontrato.contnum = contrato.contnum.
                            end.
                            cpcontrato.indecf = no.
                            cpcontrato.dec1 = contrato.vltotal.
                            cpcontrato.dec2 = plani.platot.
                            cpcontrato.dec3 = plani.platot - plani.vlserv.
                            
                            if cpcontrato.indecf = no
                            then do:
                                if tot-contrato + tot-vista > totecf
                                then.
                                else do:
                                    cpcontrato.indecf = yes.   
                                    tot-contrato = tot-contrato +
                                                    contrato.vltotal.
                                    tot-vista = tot-vista + val-vista.
                                end.                          
                            end.
                            
                            a-prazo = a-prazo + contrato.vltotal.
                        end.    
                    end.       
                end.
            end.
            /*
            message vdata tot-vista a-vista. pause.
            */
            assign
                a-vista = tot-vista
                a-prazo = tot-contrato
                vlpraz = vtottit.
    
            if (tot-contrato + tot-vista) > totecf
            then do:
                if tot-vista > ((tot-contrato + tot-vista) - totecf)
                then
                a-vista = a-vista - ((tot-contrato + tot-vista) - totecf).
                else do:
                a-prazo = a-prazo - (((tot-contrato + tot-vista) - totecf)
                                        - a-vista).
                a-vista = 0.
                end.
            end.
            else if tot-contrato + tot-vista < totecf
            then a-vista = a-vista + (totecf - (tot-contrato + tot-vista)).
            /*
            message vdata a-vista a-prazo tot-contrato
                        tot-vista totecf. pause.
            */
            /*
            if vlpraz > 0
            then do:
                if vlvist > ((vlvist + vlpraz) - totecf)
                then vlvist = vlvist - ((vlvist + vlpraz) - totecf).
                else do:
                    vlpraz = vlpraz - (((vlvist + vlpraz) - totecf) - vlvist).
                    vlvist = 0.
                end.
            end.
            else vlvist = totecf.
            */
            find first tt-venda where
                       tt-venda.etbcod = estab.etbcod and
                       tt-venda.dat = ? no-error.
            if not avail tt-venda
            then do:
                create tt-venda.
                tt-venda.etbcod = estab.etbcod.
                tt-venda.dat = ?.
            end.
            assign
                tt-venda.vl-vista = tt-venda.vl-vista + vlvist
                tt-venda.vl-prazo = tt-venda.vl-prazo + vlpraz
                tt-venda.aprazo   = tt-venda.aprazo + a-prazo
                tt-venda.avista   = tt-venda.avista + a-vista.
            
            find first tt-venda where
                       tt-venda.etbcod = estab.etbcod and
                       tt-venda.dat = vdata no-error.
            if not avail tt-venda
            then do:
                create tt-venda.
                tt-venda.etbcod = estab.etbcod.
                tt-venda.dat = vdata.
            end.
            assign
                tt-venda.vl-vista = tt-venda.vl-vista + vlvist
                tt-venda.vl-prazo = tt-venda.vl-prazo + vlpraz
                tt-venda.aprazo   = tt-venda.aprazo + a-prazo
                tt-venda.avista   = tt-venda.avista + a-vista.
            /**
            for each tt-contrato:
                find cpcontrato where
                     cpcontrato.contnum = tt-contrato.contnum
                     no-error.
                if not avail cpcontrato
                then do:
                    create cpcontrato.
                    cpcontrato.contnum = tt-contrato.contnum.
                end.
                cpcontrato.dec1 = tt-contrato.vltotal.
                cpcontrato.dec2 = vlpraz / vtottit.
                /*
                if cpcontrato.indecf = no
                then cpcontrato.indecf = yes.    
                */
            end.
            **/
        end.
end.
for each tt-venda where tt-venda.etbcod > 0 and
         tt-venda.dat <> ? no-lock:
    find first ctcartcl where
               ctcartcl.etbcod = tt-venda.etbcod and
               ctcartcl.datref = tt-venda.dat
               no-error.
    if not avail ctcartcl
    then do:
        create ctcartcl.
        assign
            ctcartcl.etbcod = tt-venda.etbcod 
            ctcartcl.datref = tt-venda.dat
            .
    end.
    assign
        ctcartcl.ecfvista = tt-venda.avista 
        ctcartcl.ecfprazo = tt-venda.aprazo 
        /*ctcartcl.aprazo   = tt-venda.vl-prazo
        ctcartcl.avista   = tt-venda.vl-vista
        */        .
end.

/*
run venda-prazo.
*/

procedure venda-prazo:
    
    def var vtitvlcob as dec.
    def var vacrescimo as dec.
    def var vacre as dec.
    def var vval as dec.
    def var vdata as date.
    
    for each tt-vp:
        delete tt-vp.
    end.    

    def var vsinal as char format "x".
    def var val-somdim as dec format ">>,>>>,>>9.99". 
    def var val-ajuste as dec format ">>,>>>,>>9.99". 
    def var val-ajustado as dec .
    def var vpro-filial as log format "Sim/Nao".
    
    if vsinal <> "-" and
       vsinal <> "+" and
       val-ajuste > 0
    then undo.
                 
    def var val-total as dec.
    def var val-filial as dec.
    def var val-dia as dec.
    def var val-sobra as dec.
    val-total = 0.
    val-filial = 0.
    if val-ajuste = ?
    then val-ajuste = 0.
    if val-ajuste > 0
    then
        for each ctcartcl where ctcartcl.etbcod > 0 and
                                     ctcartcl.datref >= vdti and
                                     ctcartcl.datref <= vdtf
                                     no-lock.
            val-total = val-total + ctcartcl.ecfprazo.       
        end.            
        
    for each estab no-lock:       
             
        disp estab.etbcod. pause 0.
             
        val-filial = 0 .
        if val-ajuste > 0
        then
             for each ctcartcl where ctcartcl.etbcod = estab.etbcod and
                                     ctcartcl.datref >= vdti and
                                     ctcartcl.datref <= vdtf
                                     no-lock.
                val-filial = val-filial + ctcartcl.ecfprazo.       
             end.                        
        
        do vdata = vdti to vdtf:
            val-somdim = 0.
            val-dia = 0.
            if val-ajuste > 0
            then do:
                find ctcartcl where ctcartcl.etbcod = estab.etbcod and
                                     ctcartcl.datref = vdata
                                     no-lock no-error.
                if avail ctcartcl
                then val-dia = ctcartcl.ecfprazo.
            end.
             
            if val-dia = 0  and val-ajuste > 0
            then next.
             
            if val-ajuste > 0
            then    val-somdim = (((val-ajuste * val-filial) / val-total) *
                                    val-dia) / val-filial.
      
            if val-somdim = ? then val-somdim = 0.
            if val-somdim < 0 then val-somdim = 0.
            if not vpro-filial
            then val-somdim = val-ajuste.
            else  do:
                val-somdim = val-somdim + val-sobra.
                vval = 0.
            end.

            for each contrato where contrato.etbcod = estab.etbcod and
                                    contrato.dtinicial = vdata
                                    no-lock:
                if contrato.vltotal <= 0
                then next.
                find first contnf where 
                            contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                        no-lock no-error.
                if not avail contnf
                then next.
                find first plani where plani.etbcod = contnf.etbcod and
                                 plani.placod = contnf.placod and
                                 plani.serie  = "V"
                                 no-lock no-error.
                if avail plani and
                   substr(string(plani.notped),1,1) <> "C"
                then next.                 

                find first envfinan where 
                                       envfinan.empcod = 19
                                    and envfinan.titnat = no
                                    and envfinan.modcod = "CRE"
                                    and envfinan.etbcod = contrato.etbcod
                                    and envfinan.clifor = contrato.clicod
                                  and envfinan.titnum = string(contrato.contnum)
                                    no-lock no-error.
                if  avail envfinan
                then next.

                find cpcontrato where 
                     cpcontrato.contnum = contrato.contnum
                      no-error.
                if not avail cpcontrato or
                    cpcontrato.indecf = no 
                then next.
                
                if cpcontrato.financeira <> 0 
                then do:
                    
                    if val-somdim > 0 and
                       vsinal = "+" and
                       cpcontrato.financeira = 87 and
                       cpcontrato.indacr = no and
                       /*contrato.vltotal - cpcontrato.dec3 = 0 and*/
                       val-ajustado + contrato.vltotal <= val-ajuste and
                       vval + contrato.vltotal  <= val-somdim
                    then do:
                    find first titulo where 
                               titulo.empcod = 19 and
                               titulo.titnat   = no and
                               titulo.modcod   = "CRE" and
                               titulo.etbcod   = contrato.etbcod and
                               titulo.clifor   = contrato.clicod and
                               titulo.titnum   = string(contrato.contnum) and
                               titulo.titdtpag <> ? and
                               titulo.titdtpag >= vdti and
                               titulo.titdtpag <= vdtf
                               no-lock no-error.
                    if not avail titulo
                    then do:           
                        vval = vval + contrato.vltotal.
                        val-ajustado = val-ajustado + contrato.vltotal.
                        cpcontrato.financeira = 0.
                        disp vval. pause 0.
                    end. 
                    else next.
                    end.   
                    else next.
                end.
                
                if val-somdim > 0 
                then do:
                if cpcontrato.indacr = no and
                    /*contrato.vltotal - cpcontrato.dec3 = 0  and*/
                    vsinal = "-"                            and
                    val-ajustado + contrato.vltotal <= val-ajuste
                then do:
                    if vval + contrato.vltotal  <= val-somdim
                    then do:
                    find first titulo where 
                               titulo.empcod = 19 and
                               titulo.titnat   = no and
                               titulo.modcod   = "CRE" and
                               titulo.etbcod   = contrato.etbcod and
                               titulo.clifor   = contrato.clicod and
                               titulo.titnum   = string(contrato.contnum) and
                               titulo.titdtpag <> ? and
                               titulo.titdtpag >= vdti and
                               titulo.titdtpag <= vdtf
                               no-lock no-error.
                    if not avail titulo
                    then do:           
                        vval = vval + contrato.vltotal.
                        val-ajustado = val-ajustado + contrato.vltotal.
                        cpcontrato.financeira = 87.
                        disp vval. pause 0.
                        next.
                    end. 
                    end.   
                end. 

                end.
                if contrato.vltotal - cpcontrato.dec3 > 0
                then cpcontrato.indacr = yes.
                
                find first tt-vp where tt-vp.etbcod = estab.etbcod and
                                       tt-vp.data = vdata
                                       no-error.
                if not avail tt-vp
                then do:
                    create tt-vp.
                    assign
                        tt-vp.etbcod = estab.etbcod
                        tt-vp.data   = vdata
                        .
                end. 
                
                
                if cpcontrato.indacr = yes
                then assign
                         vtitvlcob = vtitvlcob + cpcontrato.dec3
                         vacrescimo = vacrescimo +
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.acr = tt-vp.acr + 
                                (contrato.vltotal - cpcontrato.dec3)
                         tt-vp.valor = tt-vp.valor + cpcontrato.dec3 .
                
                else assign
                        vtitvlcob = vtitvlcob + contrato.vltotal
                        tt-vp.valor = tt-vp.valor + contrato.vltotal
                    .     
            end.
            if vval < val-somdim
            then val-sobra = val-somdim - vval.
        end.
    end.
    
    for each ctcartcl where
             ctcartcl.etbcod > 0 and
             ctcartcl.datref >= vdti and
             ctcartcl.datref <= vdtf
             :
        ctcartcl.ecfprazo = 0.
        ctcartcl.acrescimo = 0.
    end.             
    for each tt-vp where tt-vp.etbcod > 0:
        find first ctcartcl where
               ctcartcl.etbcod = tt-vp.etbcod and
               ctcartcl.datref = tt-vp.data
               no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-vp.etbcod 
                ctcartcl.datref = tt-vp.data
                .
        end.
        assign
            ctcartcl.ecfprazo = tt-vp.valor
            ctcartcl.acrescimo = tt-vp.acr 
            .
    end.
end procedure.
