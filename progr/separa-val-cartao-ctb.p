def temp-table tt-ctbreceb like ctbreceb.
def buffer bctcartcl for ctcartcl.
def temp-table tt-valest
    field etbcod like estab.etbcod
    field valvisa as dec
    field valmaster as dec
    field valbanri as dec
    index i1 etbcod.
    
def var valbanri1  as dec format ">>>,>>>,>>9.99".
def var valbanri2  as dec format ">>>,>>>,>>9.99".
def var valbanri3  as dec format ">>>,>>>,>>9.99".
def var valvisa1   as dec format ">>>,>>>,>>9.99".
def var valvisa2   as dec format ">>>,>>>,>>9.99".
def var valvisa3   as dec format ">>>,>>>,>>9.99".
def var valmaster1 as dec format ">>>,>>>,>>9.99".
def var valmaster2 as dec format ">>>,>>>,>>9.99".
def var valmaster3 as dec format ">>>,>>>,>>9.99".

def var vmes as int format "99".
def var vano as int format "9999".
update vmes label "Mes"
       vano label "ANO"
       with frame f1 side-label width 80.
       
if vmes = 0 or vano = 0 then undo.
 
find first ctcartcl where
           ctcartcl.etbcod = 0 and
           ctcartcl.datref = date(if vmes = 12 then 1 else vmes + 1,
                                  01,
                                  if vmes = 12 then vano + 1 else vano
                                  ) - 1
           no-lock no-error.
if not avail ctcartcl then undo. 

do on error undo, retry:
update valbanri1  label "Banri10% "
       valbanri2  label "Banri50% "
       valbanri3  label "Banri5%  "
       with frame f-linha.
disp valbanri1 + valbanri2 + valbanri3 label "TOTAL"
       format ">>>,>>>,>>9.99" with frame f-linha.
update valvisa1   label "Visa10%  "
       valvisa2   label "Visa50%  "
       valvisa3   label "Visa5%   " 
       with frame f-linha.
disp valvisa1 + valvisa2 + valvisa3 label "TOTAL"
       format ">>>,>>>,>>9.99" with frame f-linha.
update valmaster1 label "Master10%"
       valmaster2 label "Master50%"
       valmaster3 label "Master5% "
       with frame f-linha 1 column.
disp valmaster1 + valmaster2 + valmaster3 label "TOTAL"
       format ">>>,>>>,>>9.99" with frame f-linha.

/*
if (valbanri1 + valbanri2 + valbanri3) <> ctcartcl.avista
then undo.
if (valvisa1 + valvisa2 + valvisa3 ) <> ctcartcl.aprazo
then undo.
if (valmaster1 + valmaster2 + valmaster3) <> ctcartcl.emissao
then undo.
*/

end.

for each bctcartcl where
         bctcartcl.etbcod > 0 and
         bctcartcl.datref >= date(vmes,01,vano) and
         bctcartcl.datref <= date(if vmes = 12 then 1 else vmes + 1,
                                  01,
                                  if vmes = 12 then vano + 1 else vano
                                  ) - 1
         no-lock:
    find first tt-valest where
               tt-valest.etbcod = bctcartcl.etbcod
               no-error.
    if not avail tt-valest
    then create tt-valest.
    assign
        tt-valest.etbcod = bctcartcl.etbcod
        tt-valest.valbanri = tt-valest.valbanri + bctcartcl.avista            
        tt-valest.valvisa  = tt-valest.valvisa  + bctcartcl.aprazo
        tt-valest.valmaster = tt-valest.valmaster + bctcartcl.emissao
        .
end.

for each tt-valest where tt-valest.etbcod > 0:
  
    disp tt-valest.
    pause 0.
    
    for each bctcartcl where
         bctcartcl.etbcod = tt-valest.etbcod and
         bctcartcl.datref >= date(vmes,01,vano) and
         bctcartcl.datref <= date(if vmes = 12 then 1 else vmes + 1,
                                  01,
                                  if vmes = 12 then vano + 1 else vano
                                  ) - 1
         no-lock:
        
         if bctcartcl.avista > 0 or
            bctcartcl.aprazo > 0 or
            bctcartcl.emissao > 0
         then do:
            if bctcartcl.avista > 0
            then do:
            find first tt-ctbreceb  where
                       tt-ctbreceb.rectp = "" and
                       tt-ctbreceb.etbcod = bctcartcl.etbcod and
                       tt-ctbreceb.datref = bctcartcl.datref and
                       tt-ctbreceb.moecod = "CCB"
                       no-error.
            if not avail tt-ctbreceb
            then do:
                create tt-ctbreceb.
                assign
                    tt-ctbreceb.etbcod = bctcartcl.etbcod
                    tt-ctbreceb.datref = bctcartcl.datref
                    tt-ctbreceb.moecod = "CCB"
                    .
            end.
            assign
                tt-ctbreceb.valor1 = 
                        (valbanri1 * (tt-valest.valbanri / ctcartcl.avista))
                        * (bctcartcl.avista / tt-valest.valbanri )
                tt-ctbreceb.valor2 = 
                        (valbanri2 * (tt-valest.valbanri / ctcartcl.avista))
                        * (bctcartcl.avista / tt-valest.valbanri )
                tt-ctbreceb.valor3 = 
                        (valbanri3 * (tt-valest.valbanri / ctcartcl.avista))
                        * (bctcartcl.avista / tt-valest.valbanri )
                        .
            end.
            if bctcartcl.aprazo > 0
            then do:           
            find first tt-ctbreceb  where
                       tt-ctbreceb.rectp = "" and 
                       tt-ctbreceb.etbcod = bctcartcl.etbcod and
                       tt-ctbreceb.datref = bctcartcl.datref and
                       tt-ctbreceb.moecod = "CCV"
                       no-error.
            if not avail tt-ctbreceb
            then do:
                create tt-ctbreceb.
                assign
                    tt-ctbreceb.etbcod = bctcartcl.etbcod
                    tt-ctbreceb.datref = bctcartcl.datref
                    tt-ctbreceb.moecod = "CCV"
                    .
            end.
            assign
                tt-ctbreceb.valor1 = 
                        (valvisa1 * (tt-valest.valvisa / ctcartcl.aprazo))
                        * (bctcartcl.aprazo / tt-valest.valvisa)
                tt-ctbreceb.valor2 = 
                        (valvisa2 * (tt-valest.valvisa / ctcartcl.aprazo))
                        * (bctcartcl.aprazo / tt-valest.valvisa)
                tt-ctbreceb.valor3 = 
                        (valvisa3 * (tt-valest.valvisa / ctcartcl.aprazo))
                        * (bctcartcl.aprazo / tt-valest.valvisa)
                        .
            end.
            if bctcartcl.emissao > 0
            then do:
            find first tt-ctbreceb  where
                       tt-ctbreceb.rectp = "" and 
                       tt-ctbreceb.etbcod = bctcartcl.etbcod and
                       tt-ctbreceb.datref = bctcartcl.datref and
                       tt-ctbreceb.moecod = "CCM"
                       no-error.
            if not avail tt-ctbreceb
            then do:
                create tt-ctbreceb.
                assign
                    tt-ctbreceb.etbcod = bctcartcl.etbcod
                    tt-ctbreceb.datref = bctcartcl.datref
                    tt-ctbreceb.moecod = "CCM"
                    .
            end.
            assign
                tt-ctbreceb.valor1 = 
                        (valmaster1 * (tt-valest.valmaster / ctcartcl.emissao))
                        * (bctcartcl.emissao / tt-valest.valmaster)
                tt-ctbreceb.valor2 = 
                        (valmaster2 * (tt-valest.valmaster / ctcartcl.emissao))
                        * (bctcartcl.emissao / tt-valest.valmaster)
                tt-ctbreceb.valor3 = 
                        (valmaster3 * (tt-valest.valmaster / ctcartcl.emissao))
                        * (bctcartcl.emissao / tt-valest.valmaster)
                        .
                          
            end.           
         end.   
    
    end.
end.    
for each tt-ctbreceb:
    
    disp moecod valor1(total) valor2(total) valor3(total).
    pause 0.

    find first ctbreceb  where
                       ctbreceb.rectp = "" and
                       ctbreceb.etbcod = tt-ctbreceb.etbcod and
                       ctbreceb.datref = tt-ctbreceb.datref and
                       ctbreceb.moecod = tt-ctbreceb.moecod
                       no-error.
    if not avail ctbreceb
    then do:
       create ctbreceb.
           assign
                    ctbreceb.etbcod = tt-ctbreceb.etbcod
                    ctbreceb.datref = tt-ctbreceb.datref
                    ctbreceb.moecod = tt-ctbreceb.moecod
                    .
    end.
    assign
        ctbreceb.valor1 =  tt-ctbreceb.valor1
        ctbreceb.valor2 =  tt-ctbreceb.valor2
        ctbreceb.valor3 =  tt-ctbreceb.valor3
         .

end.    
