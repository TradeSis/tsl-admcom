def temp-table tt-cli
    field clicod as int
    field etbcod like estab.etbcod.
def buffer btt-cli for tt-cli.
    
  def var vi as int.  
  pause 0 before-hide.
  def var vtotal as int.
  def var vlido as int.
  def var vsemtitcli as int.
  form with frame f.

for each clien no-lock.
    if clien.clicod  = 1 then next.
    for each tt-cli.
        delete tt-cli.
    end.
    vlido = vlido + 1.
    if vlido < 373000 then next.
    
    disp vlido with 1 down frame f.

    
    for each titulo where titulo.clifor = clien.clicod no-lock.
        if titulo.titnat = no and
           titulo.modcod = "cre" and
           (titulo.titdtpag = ? or
           titulo.titsit = "lib")
        then.
        else next.
        find first tt-cli where tt-cli.etbcod = titulo.etbcod no-error.
        if not avail tt-cli
        then create tt-cli.
        tt-cli.clicod = titulo.clifor.
        tt-cli.etbcod = titulo.etbcod.
    end.
    
    run atu.
    
    vi = 0.
    for each tt-cli.
    vi = vi + 1.
    end.
    if vi > 1
    then do:
        for each tt-cli.
            find first titcli where titcli.etbcod = tt-cli.etbcod and
                        titcli.clicod = clien.clicod
                        exclusive no-error.
            if not avail titcli
            then do:
                create titcli.
                titcli.etbcod = tt-cli.etbcod.
                titcli.clicod = clien.clicod.
                vsemtitcli = vsemtitcli + 1.
            end.                              
            titcli.dtexp = today.
            titcli.flag = yes.      
            vtotal = vtotal + 1.
        end.
    end.
    disp vsemtitcli vtotal with frame f.
                                    
end.

PROCEDURE atu.
        /*************************  CRIA TABELA TITCLI **********************/

def var ss as i.
def var nn as i.


for each tt-cli no-lock break by clicod
                              by etbcod.

    if first-of(tt-cli.clicod)
    then assign ss = 0
                nn = 0.
                
    if tt-cli.etbcod = 01 or
       tt-cli.etbcod = 06 or
       tt-cli.etbcod = 17
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(tt-cli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btt-cli where btt-cli.clicod = tt-cli.clicod.
            
                delete btt-cli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
    
end.

for each tt-cli no-lock break by tt-cli.clicod
                              by tt-cli.etbcod.

    if first-of(tt-cli.clicod)
    then assign ss = 0
                nn = 0.
                
    if tt-cli.etbcod = 10 or
       tt-cli.etbcod = 23
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(tt-cli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btt-cli where btt-cli.clicod = tt-cli.clicod.
            
                delete btt-cli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
    
end.



for each tt-cli no-lock break by tt-cli.clicod
                              by tt-cli.etbcod.

    if first-of(tt-cli.clicod)
    then assign ss = 0
                nn = 0.
                
    if tt-cli.etbcod = 15 or
       tt-cli.etbcod = 34 
    then ss = ss + 1.
    else nn = nn + 1.
    
    if last-of(tt-cli.clicod)
    then do:
        
        if ss > 0 and
           nn = 0
        then do:
            for each btt-cli where btt-cli.clicod = tt-cli.clicod.
            
                delete btt-cli. 
                
            end.
        end.  
        ss = 0.
        nn = 0.
    end.
end.
end procedure.