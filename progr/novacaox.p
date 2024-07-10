/*
** Programa adaptado de "novacao2.p" para rodar 
** com o extrato de cobranga, "extrato2.p".
** Autor: Cristiano Hickel - 18/10/2006
*/

def input  parameter vclicod like clien.clicod.
def input  parameter p-etbcod like estab.etbcod.
def output parameter vdtven  like fin.titulo.titdtven.
def output parameter vdia    as int.
def output parameter vcond   as char format "x(40)" extent 5.
def output parameter valor_cobrado as dec extent 5.
def output parameter valor_novacao as dec extent 5.

def shared temp-table tt-titulo like fin.titulo.

def var valor_juro as dec extent 5.
def var vok        as log.
def var vtit       as char format "x(30)". 
def var vv         as int.
def var per_cor    as dec.
def var nov31      as log.

def temp-table ttservidor
    field etbcod like estab.etbcod
    field servidor like estab.etbcod.

def buffer bttservidor for ttservidor.
    
def var per_acr as dec.
def var per_des as dec.
def var vdesc as dec.
def var vdata like plani.pladat.
def var ventrada like fin.contrato.vlentra.
def var i as int.
def var varq  as char.
def var vtot  like fin.titulo.titvlcob.
def var vtitvlp like fin.titulo.titvlcob.
def var vtitj like fin.titulo.titvlcob.
def var vnumdia as i.
def var ljuros  as l.

def var vdata-futura as date format "99/99/9999".

def new shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
    index titnum empcod
                 titnat 
                 modcod 
                 etbcod 
                 clifor 
                 titnum 
                 titpar.

def temp-table wf-tit like fin.titulo.

def new shared temp-table wf-titulo like fin.titulo.
def new shared temp-table wf-contrato like fin.contrato.

def var vplano as int format "99".
def var vgera like fin.contrato.contnum.
def var wcon as int.
def var vday as int.
def var vmes as int.
def var vano as int.
def var vezes as int format ">9".

find clien where clien.clicod = vclicod no-lock no-error.
def var lp-ok as log.

/* repeat: */

    for each tp-titulo:
        delete tp-titulo.
    end.

    for each wf-titulo.
        delete wf-titulo.
    end.

    for each wf-tit.
        delete wf-tit.
    end.

    assign vtot    = 0
           vtitj   = 0
           vtitvlp = 0
           vdtven  = today
           vdata-futura = today
           i = 0.

    for each tt-titulo use-index iclicod 
                     where tt-titulo.clifor = vclicod   
                                        no-lock:
                
                if tt-titulo.titnat <> no
                then next.
                if tt-titulo.modcod <> "CRE"
                then next.
                /*
                if tt-titulo.etbcod <> setbcod
                then next.
                */        
                find first tp-titulo where tp-titulo.empcod = 19
                                       and tp-titulo.titnat = no
                                       and tp-titulo.modcod = tt-titulo.modcod
                                       and tp-titulo.etbcod = tt-titulo.etbcod
                                       and tp-titulo.clifor = tt-titulo.clifor
                                       and tp-titulo.titnum = tt-titulo.titnum
                                       and tp-titulo.titpar = tt-titulo.titpar
                                                  no-error.
                if not avail tp-titulo
                then do:
                 
                    create tp-titulo.
                    assign
                        tp-titulo.empcod    = tt-titulo.empcod
                        tp-titulo.modcod    = tt-titulo.modcod
                        tp-titulo.Clifor    = tt-titulo.clifor
                        tp-titulo.titnum    = tt-titulo.titnum
                        tp-titulo.titpar    = tt-titulo.titpar
                        tp-titulo.titnat    = tt-titulo.titnat
                        tp-titulo.etbcod    = tt-titulo.etbcod
                        tp-titulo.titdtemi  = tt-titulo.titdtemi
                        tp-titulo.titdtven  = tt-titulo.titdtven
                        tp-titulo.titvlcob  = tt-titulo.titvlcob
                        tp-titulo.titsit    = tt-titulo.titsit.
                end.
                else do:
                    if tt-titulo.titsit = "PAG" and
                       tp-titulo.titsit = "LIB"
                    then delete tp-titulo.
                end. 
    end.

    for each tp-titulo:
        if tp-titulo.titsit = "PAG"
        then delete tp-titulo.
    end.
    
    /****************************************************************/
    
    for each tp-titulo use-index dt-ven:
        
        if tp-titulo.titdtven < vdtven
        then vdtven = tp-titulo.titdtven.
        
    end.
    
    nov31 = no.
    vdia = (today - vdtven).
    vdia = (vdata-futura - vdtven).
    
    if vdia < 60
    then do:
        /*
        message "Cliente com " vdia " de atraso, operacao negada". 
        undo, retry. */
        leave.
    end.

    do vv = 1 to 5:
        
        vok = yes.
        
        assign per_acr = 0  
               per_des = 0  
               per_cor = 0  
               vtot    = 0 
               vtitj   = 0 
               vtitvlp = 0.
        
        vplano = vv.

        /**** promocao
        if vplano = 1 
        then do: 
       
            if vdia > 150 
            then vok = no.
            
            if vdia >= 60 and
               vdia <= 90
            then assign per_acr = 0.
                        per_des = 0.
    
            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                        per_des = 0.

        end.
                 
        if vplano = 2
        then do: 
            if vdia <= 90 
            then vok = no.

            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                        per_des = 0.
                    
            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
        
            if vdia <= 150
            then per_acr = 0.10.
        
            per_cor = 0.

        end.

        if vplano = 3
        then do:
            if vdia <= 90
            then vok = no.
            
            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                    per_des = 0.
            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
        
            per_cor = 0.
        
            if vdia <= 150
            then per_acr = 0.15.
        
        end.

        if vplano = 4
        then do:
            if vdia <= 120
            then vok = no.

            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
                    
            if vdia >= 151
            then assign per_acr = 0.
                        per_des = 0.
                        
            per_cor     = 0.
        
            if vdia <= 150
            then per_acr = 0.20.
                            
        end.
        promocao ***/

        for each tp-titulo use-index dt-ven:     
          
            if vdata-futura > tp-titulo.titdtven
            then do:
                ljuros = yes.
                if vdata-futura - tp-titulo.titdtven = 2
                then do:
                    find fin.dtextra where exdata = vdata-futura - 2 no-error.
                    if weekday(vdata-futura - 2) = 1 or avail fin.dtextra
                    then do:
                        find fin.dtextra where exdata = vdata-futura - 1 
                            no-error.
                        if weekday(vdata-futura - 1) = 1 or avail fin.dtextra
                        then ljuros = no.
                    end.    
                end.
                else do:
                    if vdata-futura - tp-titulo.titdtven = 1
                    then do:
                        find fin.dtextra where exdata = vdata-futura - 1 
                                    no-error.
                        if weekday(vdata-futura - 1) = 1 or avail fin.dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros 
                          then 0 
                          else vdata-futura - tp-titulo.titdtven.
                
                if vnumdia > 1766
                then vnumdia = 1766.
                
                find first fin.tabjur where fin.tabjur.nrdias = vnumdia 
                            no-lock no-error.
                if  not avail fin.tabjur
                then do:
                    /*
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo.
                    */
                    next.
                end.
                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + 
                       (tp-titulo.titvlcob * fin.tabjur.fator). 
            end.
            else do:

                /*if vdia <= 90 
                then. 
                else*/ do:   
                    vnumdia = tp-titulo.titdtven - today.
                
                    assign vtot    = vtot    + tp-titulo.titvlcob.   
                           vtitvlp = vtitvlp + tp-titulo.titvlcob.
                        
                    /*
                      + (tp-titulo.titvlcob * per_cor)
                      - (tp-titulo.titvlcob * (vnumdia * (per_des / 100))).
                    */
                
                end.
                
            end.                    
    
            /*                
            display tp-titulo.etbcod
                    tp-titulo.titnum
                    tp-titulo.titpar
                    tp-titulo.titsit
                    tp-titulo.titdtven
                    tp-titulo.titvlcob(total) with frame f2 centered down.
                    
            */
                    
        end.
        
        if vdia >= 60  and
           vdia < 180  /*promocao 150*/ and
           lp-ok = no
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.
 
        /*** promoção 
        if vdia >= 61 and
           vdia <= 360
        then do:
            vtitj = vtitj - (vtitj * .33).
        end.
        else if vdia >= 361 and
                vdia <= 600
            then do:
                vtitj = vtitj - (vtitj * .66).
            end.
            else if vdia > 600
                then vtitj = vtitj / 20.
        ******/
                        
        /***** promocao
    
        if vdia >= 151 and
           vdia <= 250
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.40).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.40). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.30).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.20).
        end.
    
        
    
        if vdia >= 251 and
           vdia <= 350
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.60).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.60). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.50).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.40).
        end.
            
    
        if vdia >= 351 and
           vdia <= 500
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.70).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.70). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.60).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.50).
        end.
            

    
        if vdia >= 501 and
           vdia <= 1000
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.80).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.80). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.70).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.60).
        end.
     
    
        if vdia >= 1001
        then do:
            vtitj = vtitj - (vtitj * 0.90).
        end.
        ******/
        
        /***** promocao  /
        
        if vplano = 1
        then vtitj = vtitj.
        if vplano = 2
        then vtitj = vtitj + ((vtot + vtitj) * 0.10).
        if vplano = 3
        then vtitj = vtitj + ((vtot + vtitj) * 0.15).
        if vplano = 4
        then vtitj = vtitj + ((vtot + vtitj) * 0.20).
        if vplano = 5
        then vtitj = vtitj + ((vtot + vtitj) * 0.25).
                                
        /  ***************/
        
        vtitvlp = vtot + vtitj.
    
        if vv = 1
        then vtit = "[ 1 ]  6  vezes(1+5) ".
        if vv = 2
        then vtit = "[ 2 ]  10 vezes(1+9) ".
        if vv = 3
        then vtit = "[ 3 ]  15 vezes(1+14)".
        if vv = 4
        then vtit = "[ 4 ]  20 vezes(1+19)".
        if vv = 5
        then vtit = "[ 5 ]  25 vezes(1+24)".
         
        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = vtitj  
                    valor_novacao[vv] = vtitvlp.
        else assign vcond[vv]         = vtit + " - NAO DISPONIVEL"   
                    valor_cobrado[vv] = 0
                    valor_juro[vv]    = 0
                    valor_novacao[vv] = 0.
                    
               
        /*        
        if vok 
        then
        disp vtit 
             vtot     label "Valor Cobrado"
             vtitj    label  "Valor Juros" 
             vdtven   label "Maior Atraso" 
             vdia     label "Dias de atraso" 
             vtitvlp  label "Novacao Calculada" with frame fpag99 centered
                    overlay row 15 1 column.
                    
        vtot = vtitvlp. 
        */
        
        
    end.
    run cal-juro.
    

        /*****
        assign vok     = yes
               per_acr = 0  
               per_des = 0  
               per_cor = 0  
               vtot    = 0 
               vtitj   = 0 
               vtitvlp = 0
               vplano  = vv.
   
        if vplano = 1 
        then do: 
            if vdia > 150 
            then vok = no.
            
            if vdia >= 60 and
               vdia <= 90
            then assign per_acr = 0.
                        per_des = 0.
    
            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                        per_des = 0.
        end.
                 
        if vplano = 2
        then do: 
            if vdia <= 90 
            then vok = no.

            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                        per_des = 0.
                    
            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
        
            if vdia <= 150
            then per_acr = 0.10.
        
            per_cor = 0.
        end.
    

        if vplano = 3
        then do:
            if vdia <= 90
            then vok = no.
            
            if vdia >= 91 and
               vdia <= 120
            then assign per_acr = 0.
                    per_des = 0.
            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
        
            per_cor = 0.
        
            if vdia <= 150
            then per_acr = 0.15.
        end.

        if vplano = 4
        then do:
            if vdia <= 120
            then vok = no.

            if vdia >= 121 and
               vdia <= 150
            then assign per_acr = 0.
                        per_des = 0.
                    
            if vdia >= 151
            then assign per_acr = 0.
                        per_des = 0.
                        
            per_cor     = 0.
        
            if vdia <= 150
            then per_acr = 0.20.
        
        end.

        for each tp-titulo use-index dt-ven:     
          
            if vdata-futura > tp-titulo.titdtven
            then do:
                ljuros = yes.
                if vdata-futura - tp-titulo.titdtven = 2
                then do:
                    find fin.dtextra where exdata = vdata-futura - 2 no-error.
                    if weekday(vdata-futura - 2) = 1 or avail fin.dtextra
                    then do:
                        find fin.dtextra where exdata = vdata-futura - 1 
                                no-error.
                        if weekday(vdata-futura - 1) = 1 or avail fin.dtextra
                        then ljuros = no.
                    end.    
                end.
                else do:
                    if vdata-futura - tp-titulo.titdtven = 1
                    then do:
                        find fin.dtextra where exdata = vdata-futura - 1 no-error.
                        if weekday(vdata-futura - 1) = 1 or avail fin.dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros 
                          then 0 
                          else vdata-futura - tp-titulo.titdtven.
                find first fin.tabjur where fin.tabjur.nrdias = vnumdia no-lock no-error.
                if  not avail fin.tabjur
                then do:
                    /*
                    message "Fator para" vnumdia
                    "dias de atraso, nao cadastrado". pause. undo. */
                    next.
                end.
                assign vtot    = vtot    + tp-titulo.titvlcob
                       vtitvlp = vtitvlp + (tp-titulo.titvlcob * 
                       fin.tabjur.fator). 
            end.
            else do:

                if vdia <= 90 
                then. 
                else do:   
                    assign vnumdia = tp-titulo.titdtven - today
                           vtot    = vtot    + tp-titulo.titvlcob
                           vtitvlp = vtitvlp + tp-titulo.titvlcob.
                end.
            end.
        end.
         
    
        if vdia >= 60  and
           vdia < 150
        then nov31 = yes.
    
        vtitvlp = vtitvlp + (vtitvlp * per_acr).
    
        vtitj = vtitvlp - vtot.
    
        if vdia >= 151 and
           vdia <= 250
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.40).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.40). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.30).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.20).
        end.
    
        if vdia >= 251 and
           vdia <= 350
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.60).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.60). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.50).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.40).
        end.
    
        if vdia >= 351 and
           vdia <= 500
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.70).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.70). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.60).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.50).
        end.
    
        if vdia >= 501 and
           vdia <= 1000
        then do:
            if vplano = 1
            then vtitj = vtitj - (vtitj * 0.80).
            if vplano = 2
            then vtitj = vtitj - (vtitj * 0.80). 
            if vplano = 3
            then vtitj = vtitj - (vtitj * 0.70).
            if vplano = 4              
            then vtitj = vtitj - (vtitj * 0.60).
        end.
    
        if vdia >= 1001
        then do:
            vtitj = vtitj - (vtitj * 0.90).
        end.

        vtitvlp = vtot + vtitj.

        if vv = 1
        then vtit = "[ 1 ]  6  vezes(1+5) ".
        if vv = 2
        then vtit = "[ 2 ]  10 vezes(1+9) ".
        if vv = 3
        then vtit = "[ 3 ]  15 vezes(1+14)".
        if vv = 4
        then vtit = "[ 4 ]  20 vezes(1+19)".
        
        if vok 
        then assign vcond[vv]         = vtit
                    valor_cobrado[vv] = vtot 
                    valor_juro[vv]    = vtitj  
                    valor_novacao[vv] = vtitvlp.
        else assign vcond[vv]         = vtit + " - NAO DISPONIVEL"   
                    valor_cobrado[vv] = 0
                    valor_juro[vv]    = 0
                    valor_novacao[vv] = 0.
            ************/
   
procedure cal-juro:
    do vv = 1 to 5:
        
        if vdia > 600
        then do:
            valor_juro[vv] = valor_juro[vv] / 15 .
        end.
                             
        valor_novacao[vv] = valor_cobrado[vv] + valor_juro[vv].

        if vv = 2
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .10).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 3
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .15).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 4
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .20).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
        if vv = 5
        then do:
            valor_juro[vv] = valor_juro[vv] + (valor_novacao[1] * .25).
            valor_novacao[vv] = valor_cobrado[1] + valor_juro[vv].
        end.
                      
    end.

end procedure.


