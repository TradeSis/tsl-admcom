{admcab.i new}     

def var vqtd as int.
def var vtot as dec.
def var vnov as dec.
def var vlp as dec.
def buffer btitulo for titulo.
def buffer dtitulo for titulo.
def var tlp as dec.
def var tnov as dec.
def var vdtref as date init 06/01/2017.
disable triggers for load of titulo.

def temp-table tt      no-undo
    field etbcod as int
    field ano as int
    field mes as int
    field qtd as int
    field carteira as dec format "->>>>>>>>>>9.99"
    field lp as dec       format "->>>>>>>>>>9.99"
    field nov as dec  format     "->>>>>>>>>>9.99"
    index x is unique primary etbcod asc ano asc mes asc.

def var vmodo     as log init no.
def var vtitpar-1 as int.
def var vtitpar-2 as int.
def var vtpcontrato as char.

if vmodo /* verifica contratos N */
then assign
        vtitpar-1 = 30
        vtitpar-1 = 31
        vtpcontrato = "".
else assign
        vtitpar-1 = 50
        vtitpar-2 = 51
        vtpcontrato = "L".

update vdtref with side-label.
message "tem certeza" update sresp.
if not sresp then return.
pause 0 before-hide.
for each estab no-lock,
    each titulo where
        titulo.empcod = 19 and
        titulo.titnat = no and
        titulo.etbcod = estab.etbcod and
        titulo.modcod = "CRE" and
        titulo.titsit = "LIB" and
        titulo.titpar > vtitpar-1 and
        titulo.titdtemi >= vdtref and
        titulo.tpcontrato = vtpcontrato
          no-lock
          on error undo, return.

/*
      if int(titulo.titnum)  >= 300000000 and
           int(titulo.titnum)  <= 399999999
        then .
        else next.
*/

        find first btitulo use-index titnum
          where btitulo.empcod = titulo.empcod and
                btitulo.titnat = titulo.titnat and
                btitulo.modcod = titulo.modcod and
                btitulo.etbcod = titulo.etbcod and
                btitulo.clifor = titulo.clifor and
                btitulo.titnum = titulo.titnum and
                btitulo.titpar = 1 and
                btitulo.titdtemi = titulo.titdtemi
          no-lock no-error.
        if avail btitulo 
        then next.

        find first btitulo use-index titnum
          where btitulo.empcod = titulo.empcod and
                btitulo.titnat = titulo.titnat and
                btitulo.modcod = titulo.modcod and
                btitulo.etbcod = titulo.etbcod and
                btitulo.clifor = titulo.clifor and
                btitulo.titnum = titulo.titnum and
                btitulo.titpar = vtitpar-2 and
                btitulo.titdtemi = titulo.titdtemi
          no-lock no-error.
        if not avail btitulo
        then next.

        if avail btitulo 
        then do:
            disp titulo.etbcod titulo.cobcod titulo.titnum 
                titulo.titpar
                btitulo.titpar
                titulo.tpcontrato
                btitulo.tpcontrato
                titulo.titsit 
                titulo.titobs[1]  format "x(30)"
                btitulo.titobs[1] format "x(30)" 
                titulo.titvlcob (total)
                titulo.titdtemi
                titulo.clifor.
            pause 0.
                /*
            run ./hbca1.p (titulo.titnum).
            return.  
            */
            /*
            find dtitulo where recid(dtitulo) = recid(titulo).
            dtitulo.tpcontrato = "N".
            */
        end.
end.
                            
/**    

    
    if acha("RENOVACAO",titulo.titobs[1]) = "SIM"  and
       titpar >= 51 
    then do:
        if tpcontrato = "L"
        then next.
    end.
    
    
    if  acha("NOVACAO",titulo.titobs[1]) = "SIM" and
       titpar <= 50
    then do:
        if tpcontrato = "N"
        then next.
    end.
     
find first btitulo use-index titnum
    where btitulo.empcod = titulo.empcod and
    btitulo.titnat = titulo.titnat and
    btitulo.modcod = titulo.modcod and
    btitulo.etbcod = titulo.etbcod and
    btitulo.clifor = titulo.clifor and
    btitulo.titnum = titulo.titnum and
    btitulo.titdtemi = titulo.titdtemi and
    btitulo.titpar > 0 and
    btitulo.titpar <> titulo.titpar and
    (btitulo.titobs[1] matches "*RENOVACAO*" or
    btitulo.titobs[1] matches "*NOVACAO*" or
    btitulo.tpcontrato <> "")
    no-lock no-error.
if not avail btitulo 
then do:
disp titulo.etbcod titulo.cobcod titulo.titnum 
titulo.titpar
titulo.tpcontrato 
    titulo.titsit 
    titulo.titdtemi
    titulo.clifor.

    disp "VENDA".  

    if titulo.tpcontrato = ""
    then next.

    /**
    find dtitulo where recid(dtitulo) = recid(titulo).
    dtitulo.tpcontrato = "".
    **/
    
    next.
end.    

tlp = 0.
tnov = 0.

if btitulo.tpcontrato = "N" or     
 acha("NOVACAO",btitulo.titobs[1]) = "SIM" 
then do:
    if titulo.tpcontrato = "N"
    then next.
    
disp titulo.etbcod titulo.cobcod titulo.titnum 
titulo.titpar
btitulo.titpar  btitulo.modcod 
titulo.tpcontrato btitulo.tpcontrato
    titulo.titsit 
    titulo.titobs[1] btitulo.titobs[1] format "x(30)" 
    titulo.titdtemi
    titulo.clifor.

    disp "NOVACAO".
    
    if  titulo.titpar > 50 and
     (titulo.tpcontrato = "L" or     
      acha("RENOVACAO",titulo.titobs[1]) = "SIM" )

    then do:    
        vnov = vnov + titulo.titvlcob.
        tnov = titulo.titvlcob.
        disp "AFETA".

           find dtitulo where recid(dtitulo) = recid(titulo).
           dtitulo.tpcontrato = "N".
    end.              
end.


if btitulo.tpcontrato = "L" or     
 acha("RENOVACAO",btitulo.titobs[1]) = "SIM" 
then do:
    if titulo.tpcontrato = "L"
    then next.

disp titulo.etbcod titulo.cobcod titulo.titnum 
titulo.titpar
btitulo.titpar  btitulo.modcod 
titulo.tpcontrato btitulo.tpcontrato
    titulo.titsit 
    titulo.titobs[1] btitulo.titobs[1] format "x(30)" 
    titulo.titdtemi
    titulo.clifor.

    
    disp "RENOVACAO".
         if  titulo.titpar > 50 and
     (titulo.tpcontrato <> "L" or     
      acha("RENOVACAO",titulo.titobs[1]) <> "SIM" )

    then do:    
    
        vlp = vlp + titulo.titvlcob.
        tlp = titulo.titvlcob.
        disp "AFATA".
      
         find dtitulo where recid(dtitulo) = recid(titulo).
         dtitulo.tpcontrato = "L".
       end.
    

end.    


disp titulo.etbcod titulo.cobcod titulo.titnum 
titulo.titpar
btitulo.titpar  btitulo.modcod 
titulo.tpcontrato btitulo.tpcontrato
    titulo.titsit 
    titulo.titobs[1] btitulo.titobs[1] format "x(30)" 
    titulo.titdtven
    titulo.clifor.


vqtd = vqtd + 1.
vtot = vtot + (titulo.titvlcob).
find first tt
    where tt.etbcod = titulo.etbcod and
          tt.ano    = year(titulo.titdtven) and
          tt.mes    = month(titulo.titdtven)
    no-error.
    if not avail tt
    then do:
        create tt.
          tt.etbcod = titulo.etbcod.
          tt.ano    = year(titulo.titdtven).
          tt.mes    = month(titulo.titdtven).
    end.
    tt.nov = tt.nov + tnov.
    tt.lp = tt.lp + tlp.
    tt.qtd = tt.qtd + 1.
    tt.carteira = tt.carteira + titulo.titvlcob.
    end.
disp estab.etbcod vqtd vtot vnov vlp.    


end.
disp     vqtd vtot vnov vlp. 

output to xx.txt.
for each tt
    by tt.etbcod 
    by tt.ano
    by tt.mes.
    
    export delimiter ";" tt.
end.
output close.
**/
    

