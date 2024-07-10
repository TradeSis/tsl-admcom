/*  solic22495.p        */
{admcab.i }
pause 0 before-hide.
def var vdiretorio  as char format "x(60)" label "Diretorio".
def var varquivo    as char format "x(20)" label "Arquivo".

update vdiretorio  skip
       varquivo  colon 10
       with frame f side-label row 4.
def var vtip as char format "X".
def var vabast as char format "X".
def stream tela.
output stream tela to terminal.
def var vcont as int.
vcont = 0.
for each wmsender no-lock .
    vcont = vcont + 1.
end.    
def var xcont as int.
output to value(vdiretorio + "/" + varquivo).
for each wmsender no-lock .
    find wmstipend where 
            wmstipend.tipcod = wmsender.endtip no-lock no-error. 
    if not avail wmstipend then next.
    if wmsender.endtip = 1
    then vtip = "A".
    if wmsender.endtip = 2
    then vtip = "P".
    xcont = xcont + 1.
    if xcont mod 100 = 0
    then do.
        display stream tela
                xcont "de" vcont
                xcont / vcont * 100 format ">>9.99%"
                            with frame ffff 1 down
                                    no-label.
    end.
    put unformatted 
            wmsender.endcod   ";"
            wmsender.endpav   ";"
            wmsender.endrua   ";"
            wmsender.endnum   ";"
            wmsender.endand   ";"
            vtip ";".
    vabast = "N".
    for each wmsendpro of wmsender no-lock.
        if wmsendpro.qtdest > 0  then vabast = "A".
    end.
    put unformatted
            vabast ";" skip.
    
end.    

output close.
output stream tela close.
message "arquivo " vdiretorio + "/" + varquivo " gerado".
