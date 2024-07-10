
repeat:

if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50 or movim.movtdc = 45 or
               movim.movtdc = 31 or movim.movtdc > 9000
then p-retorna = yes.
            
if p-retornA = yes
then leave.

find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
if avail plani
then do:
    if  plani.movtdc = 4 and
        plani.notsit = yes
    then p-retorna = yes.
                
    vnumero = string(plani.numero,"9999999").
                
end.
else vnumero = "PROBL.".
            
if avail plani and plani.modcod = "CAN"
then p-retorna = yes.
if avail plani and plani.serie = "VC"
then p-retorna = yes.

if p-retorna = yes
then leave.
find tipmov of movim no-lock no-error.

if vemit
then do: 
    if (movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 59 or
               movim.movtdc = 64 or
               movim.movtdc = 26 or
               movim.movtdc = 46 or
               movim.movtdc = 72 or
               movim.movtdc = 73)
    then. 
    else p-retorna = yes.
end.
if vdest
then do:
    if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 07 or
               movim.movtdc = 08 or
               movim.movtdc = 09 or
               movim.movtdc = 51 or
               movim.movtdc = 59 or
               movim.movtdc = 26 or
               movim.movtdc = 64 or
               movim.movtdc = 46 or
               movim.movtdc = 73
            then p-retorna = yes.

end.
if vdestaj
then do:
    if (movim.movtdc = 7  or
       movim.movtdc = 8) 
    then do:
       /*if program-name(2) begins "removest20140"
       then p-retorna = yes.*/
    end.
    else p-retorna = yes.
end.

if p-retorna = yes
then leave.            

if movim.movtdc = 5 or
   movim.movtdc = 13 or
   movim.movtdc = 14 or
   movim.movtdc = 16 or
   movim.movtdc = 8  or
   movim.movtdc = 18 or
   movim.movtdc = 59 or
   movim.movtdc = 64 or
   movim.movtdc = 46 or
   movim.movtdc = 73 or
   movim.movtdc = 26
then  sal-atu = sal-atu - movim.movqtm .

if movim.movtdc = 4  or
   movim.movtdc = 1  or
   movim.movtdc = 7  or
   movim.movtdc = 11 or
   movim.movtdc = 12 or
   movim.movtdc = 15 or
   movim.movtdc = 17 or
   movim.movtdc = 50 or
   movim.movtdc = 60 or
   movim.movtdc = 62 or
   movim.movtdc = 53 or
   movim.movtdc = 51 or
   movim.movtdc = 74
then sal-atu = sal-atu + movim.movqtm .

if movim.movtdc = 6 or
   movim.movtdc = 3
then do:
    if movim.etbcod = vetbcod
    then sal-atu = sal-atu - movim.movqtm.
            
    if movim.desti = vetbcod
    then sal-atu = sal-atu + movim.movqtm.
end.


vmovtnom = tipmov.movtnom.

if movim.movtdc = 74
then do:
    vmovtnom = "RETORNO AG".
    t-ent = t-ent + movim.movqtm.
    v-ent = v-ent + movim.movqtm.
end.
if movim.movtdc = 73
then do:
    vmovtnom = "REMESSA AG".
    t-sai = t-sai + movim.movqtm.
    v-sai = v-sai + movim.movqtm.
end.
if movim.movtdc = 1
then do:
    vmovtnom = "ORCAMENTO DE ENTRADA".
    t-ent = t-ent + movim.movqtm.
    v-ent = v-ent + movim.movqtm.
end.
if movim.movtdc = 4
            then do:
                vmovtnom = "ENTRADA".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 5
            then do:
                vmovtnom = "VENDA".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if movim.movtdc = 46
            then do:
                vmovtnom = "VENDA PJ".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if movim.movtdc = 12
            then do:
                vmovtnom = "DEV.VENDA".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 13
            then do:
                vmovtnom = "DEV.FORN.".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.

            if movim.movtdc = 14
            then do:
                vmovtnom = "SIMPLES.REM.".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if movim.movtdc = 26
            then do:
                vmovtnom = "OUTRAS SAIDAS".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end. 
            if movim.movtdc = 11
            then do:
                vmovtnom = "OUTRAS ENTRADAS".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.    
            if movim.movtdc = 53
            then do:
                vmovtnom = "E.PRO.USADO".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end. 
            
            if movim.movtdc = 64
            then do:
                vmovtnom = "EST.OUT.ENTRADAS".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end. 
 
            if movim.movtdc = 15
            then do:
                vmovtnom = "ENT.CONSERTO".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 51
            then do:
                vmovtnom = "E.P/CONSERTO".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.     
            if movim.movtdc = 16
            then do:
                vmovtnom = "REM.CONSERTO".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if movim.movtdc = 60
            then do:
                vmovtnom = "EST.DEV.COMPRA".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 62
            then do:
                vmovtnom = "EST.REM.CONSERTO".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.

            if movim.movtdc = 59
            then do:
                vmovtnom = "EST.DEV.VENDA".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.

            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.etbcod = vetbcod
            then do:
                vmovtnom = "TRANSF.SAIDA".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.desti  = vetbcod
            then do:
                vmovtnom = "TRANSF.ENTRA".
                t-ent = t-ent + movim.movqtm.
                v-ent = v-ent + movim.movqtm.
            end.
            if movim.movtdc = 17
            then do:
                 vmovtnom = "TROCA DE ENTRADA".
                 t-ent = t-ent + movim.movqtm.
                 v-ent = v-ent + movim.movqtm.   
            end.
            if movim.movtdc = 18
            then do:
                vmovtnom = "TROCA DE SAIDA".
                t-sai = t-sai + movim.movqtm.
                v-sai = v-sai + movim.movqtm.
            end.
             
vmovqtm = movim.movqtm.
if movim.movtdc = 21
then assign vmovtnom = "BALANCO ESTOQUE"
vmovqtm  = movim.movqtm - sal-atu
sal-atu  = sal-atu + vmovqtm.
            


if avail plani and 
   plani.notobs[2] <> "" and
  (plani.movtdc = 7 or
   plani.movtdc = 8)
then vmovtnom = plani.notobs[2].
datasai = movim.datexp.
            
if movim.movtdc = 12
then vdesti = movim.ocnum[7].
else vdesti = movim.desti.
if vdesti = 0 then vdesti = movim.desti.

leave.
end.
 