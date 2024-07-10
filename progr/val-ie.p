def input  parameter v-uf as char.
def input  parameter v-ie as char.
def output parameter v-ok as log.

def var i as int.
def var b as int.
def var v-soma as int.
def var nro as char extent 15.
def var soma as int.
def var v-fim as int.
def var v-dig as int.
def var s as char.

find first unfed where unfed.ufecod = v-uf no-lock no-error.
if not avail unfed
then do:
    v-ok = no.
    return.
end.
if v-ie = ""
then do:
    v-ok = no.
    return.
end.
if v-ie = "ISENTO" or v-ie = "NAO CONTRIBUINTE"
then do:
    v-ok = yes.
    return.
end.
    
run value("IE-" + v-uf).

procedure IE-RS:
    if substr(v-ie,4,1) = "/"
    then  v-ie = substr(v-ie,1,3) + substr(v-ie,5,10).
    if length(v-ie) > 10
    then v-ok = no.
    else do:
        i = int(substr(v-ie,1,3)).
        if i >= 1 and i <= 467
        then do:
            do i = 1 to 10:
                nro[i] = substr(v-ie,i,1).
            end.
            b = 2.
            soma = 0.
            do i = 1 to 9:
               soma = soma + (int(nro[i]) * b).
               b = b - 1.
               if b = 1
               then b = 9.
            end.
        end.      
        v-fim = soma mod 11.      
        v-dig = 11 - v-fim.
        if v-dig >= 10
        then v-dig = 0.
        if v-dig <> int(nro[10])
        then v-ok = no.
        else v-ok = yes.
    end.        
end procedure.

procedure IE-AC:
    if length(v-ie) > 13
    then v-ok = no.
    else do:
        b = 4.
        soma = 0.
        do i = 1 to 11:
            nro[i] = substr(v-ie,i,1).
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 1 then b = 9.
        end. 
        v-fim = soma mod 11.      
        v-dig = 11 - v-fim.
        if v-dig >= 10
        then v-dig = 0.
        if v-dig <> int(nro[11])
        then v-ok = no.
        else v-ok = yes.

        b = 5.
        soma = 0.
        do i = 1 to 12:
            nro[i] = substr(v-ie,i,1).
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 1 then b = 9.
        end.
        v-fim = soma mod 11.      
        v-dig = 11 - v-fim.
        if v-dig >= 10
        then v-dig = 0.
        if v-dig <> int(nro[12])
        then v-ok = no.
        else v-ok = yes.
    end.
end procedure.

procedure IE-AL:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        b = 9.
        soma = 0.
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.
        soma = soma * 10.
        v-dig = soma - int(soma / 11) * 11.
        if v-dig >= 10 then v-dig = 0.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.    

procedure IE-AM:
    if length(v-ie) <> 9
    then v-ok = no.
    else do:
        b = 9.
        soma = 0.
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1. 
        end.
        if soma < 11
        then v-dig = 11 - soma.
        else do:
            v-fim = soma mod 11.
            if v-fim <= 1
            then v-dig = 0.
            else v-dig = 11 - v-fim.   
        end.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.

procedure IE-AP:
    def var p as int.
    def var d as int.
    def var i as int.
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        p = 0.
        d = 0.
        i = int(substr(v-ie,2,7)).
        if i >= 3000001 and i <= 3017000
        then do:
            p = 5.
            d = 0.
        end.
        else if i >= 3017001 and i <= 3019022
        then do:
            p = 9.
            d = 1.
        end.    
        b = 9.
        soma = p.
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1. 
        end.
        v-fim = soma mod 11.      
        v-dig = 11 - v-fim.
        if v-dig = 10
        then v-dig = 0.
        else if v-dig = 11
        then v-dig = d.
        if v-dig <> int(nro[9])
        then v-ok = no.
        else v-ok = yes.
    end.
end procedure.

procedure IE-BA:
    def var nummod as int.
    if length(v-ie) > 8
    then v-ok = no.
    else do:
        do i = 1 to 8:
            nro[i] = substr(v-ie,i,1).
        end.
        v-dig = -1.
        NumMod = 0.
        if nro[1] = "0" or
           nro[1] = "1" or
           nro[1] = "2" or
           nro[1] = "3" or
           nro[1] = "4" or
           nro[1] = "5" or
           nro[8] = "8"
        then NumMod = 10.
        else NumMod = 11.
        b = 7.
        soma = 0.
        do i = 1 to 6:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.  
        v-fim = soma mod 11.      
        v-dig = 11 - v-fim.
        if NumMod = 10
        then do:
            v-fim = soma mod 10.
            if v-fim = 0 then v-dig = 0.
            else v-dig = NumMod - v-fim.
        end.
        else do:
            v-fim = soma mod 11.
            if v-fim <= 1 then v-dig = 0.
            else v-dig = NumMod - v-fim.
        end.
        if v-dig = int(nro[8])
        then v-ok = yes.
        b = 8.
        soma = 0.
        do i = 1 to 6:
          soma = soma + (int(nro[1]) * b).
          b = b - 1.
        end.  
        soma = soma + (int(nro[7]) * 2).
        if NumMod = 10
        then do:
            v-fim = soma mod 10.
            if v-fim = 0 then v-dig = 0.
            else v-dig = NumMod - v-fim.
        end.
        else do:
            v-fim = soma mod 11.
            if v-fim <= 1 then v-dig = 0.
            else v-dig = NumMod - v-fim.
        end.
        if v-dig = int(nro[7])
        then v-ok = yes.
    end.
end procedure.                

procedure   IE-CE:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.
        b = 9.
        soma = 0.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
        end.
        v-fim = soma mod 11.
        v-dig = 11 - v-fim.  
        if v-dig >= 10
        then v-dig = 0.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-DF:
    if length(v-ie) > 13
    then v-ok = no.
    else do:
        do i = 1 to 13:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 4.
        soma = 0.
        do i = 1 to 11:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 1 then b = 9.
        end.    
        v-fim = soma mod 11.
        v-dig = 11 - v-fim.
        if v-dig >= 10
        then v-dig = 0.
        if v-dig = int(nro[12])
        then v-ok = yes.
        else v-ok = no.
        b = 5.
        soma = 0.
        do i = 1 to 12:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 1 then b = 9.
        end.    
        v-fim = soma mod 11.
        v-dig = 11 - v-fim.
        if v-dig >= 0
        then v-dig = 0.
        if v-dig = int(nro[13])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-ES:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        v-fim = soma mod 11.
        if v-fim < 2
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-GO:
    def var s as char.
    def var n as int.
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        s = substr(v-ie,1,2).
        if s = "10" or s = "11" or s = "15"
        then do:
            do i = 1 to 9:
               nro[i] = substr(v-ie,i,1).
            end.
            n = int(int(v-ie) / 10).
            if n = 11094402
            then do:
               if int(nro[8]) = 0 or int(nro[8]) = 1
               then v-ok = no.
            end.
            b = 9.
            soma = 0.
            do i = 1 to 8:
               soma = soma + (int(nro[i]) * b).
               b = b - 1.
            end.
            v-fim = soma mod 11.
            if v-fim = 0 then v-dig = 0.
            else if v-fim = 1
            then do:
                if n >= 10103105 and n <= 10119997
                then v-dig = 1.
                else v-dig = 0.
            end.    
            else v-dig = 11 - v-fim.
        end.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.                

procedure IE-MA:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.        
        v-fim = soma mod 11.
        if v-fim <= 1
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-MT:
    if length(v-ie) < 9
    then v-ok = no.
    else do:
        if length(v-ie) < 11
        then do while length(v-ie) <= 10:
            v-ie = "0" + v-ie.
        end.
        do i = 1 to 11:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 3.
        soma = 0.
        do i = 1 to 10:
           soma = soma + (int(nro[i]) * b).
           b = b - 1.
           if b = 1 then b = 9.
        end.  
        v-fim = soma mod 11. 
        if v-fim <= 1 then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[11])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-MS:
    if length(v-ie) > 9
    then v-ok = no.
    else if substring(v-ie,1,2) <> "28"
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.
        v-fim = soma mod 11.
        if v-fim <= 1
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-PA:
    if length(v-ie) > 9
    then v-ok = no.
    else if substr(v-ie,1,2) > "15"
    then v-ok = no.
    else do:
        do i = 1 to 9:
          nro[i] = substr(v-ie,i,1).
        end.  
        b = 9.
        soma = 0.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
        end.  
        v-fim = soma mod 11.
        if v-fim <= 1 then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-PB:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
          nro[i] = substr(v-ie,i,1).
        end.  
        b = 9.
        soma = 0.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
        end.  
        v-fim = soma mod 11.
        if v-fim <= 1 then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-PR:
    if length(v-ie) <> 10
    then v-ok = no.
    else do:
        do i = 1 to 10:
          nro[i] = substr(v-ie,i,1).
        end.  
        b = 3.
        soma = 0.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
          if b = 1 then b = 7.
        end.  
        v-fim = soma mod 11.
        if v-fim <= 1 
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig <> int(nro[9])
        then v-ok = no.
        else do:
            b = 4.
            soma = 0.
            do i = 1 to 9:
                soma = soma + (int(nro[i]) * b).
                b = b - 1.
                if b = 1 then b = 7.
            end.    
            v-fim = soma mod 11.
            if v-fim <= 1
            then v-dig = 0.
            else v-dig = 11 - v-fim.
            if v-dig = int(nro[10])
            then v-ok = yes.
        end.            
    end.
end procedure.    

procedure  IE-PE:
    
    def var vtotal-aux as integer.
    def var vpeso      as integer.
    def var vdig1-aux  as integer.
    def var vdig2-aux  as integer.

    if length(v-ie) > 14
    then v-ok = no.
    else do:
        do i = 1 to 14:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 5.
        soma = 0.
        do i = 1 to 13:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
          if b = 0 then b = 9.
        end.  
        v-fim = soma mod 11.
        v-dig = 11 - v-fim.
        if v-dig > 9
        then v-dig = v-dig - 10.
        if v-dig = int(nro[14])
        then v-ok = yes.
        else v-ok = no.
        
        /* Testa agora o novo algoritmo de IE de Pernabuco*/
        if v-ok = no
        then do:
        
            assign vtotal-aux = 0
                   vpeso  = (length(v-ie) - 2) + 1.

            do i = 1 to (length(v-ie) - 2):
            
                nro[i] = substr(v-ie,i,1).
                
                assign vtotal-aux = vtotal-aux + (int(nro[i]) * vpeso) .

                vpeso = vpeso - 1.
                
            end.
            
            if vtotal-aux mod 11 = 0 or vtotal-aux mod 11 = 1
            then assign vdig1-aux = 0.
            else do:
            
                assign vdig1-aux = 11 - (vtotal-aux mod 11).
            
            end.

            /* Valida Primeiro digito verificador, (penultimo caracter da IE) */
            if int(substr(v-ie,(length(v-ie) - 1),1)) = vdig1-aux
            then assign v-ok = yes.
            else assign v-ok = no.
            
            if v-ok = yes
            then do:
            
                assign vtotal-aux = 0
                       vpeso      = (length(v-ie) - 1) + 1.

                do i = 1 to (length(v-ie) - 1):
            
                    nro[i] = substr(v-ie,i,1).
                
                    assign vtotal-aux = vtotal-aux + (int(nro[i]) * vpeso) .

                    vpeso = vpeso - 1.
                    
                end.
            
                if vtotal-aux mod 11 = 0 or vtotal-aux mod 11 = 1
                then assign vdig2-aux = 0.
                else do:
            
                    assign vdig2-aux = 11 - (vtotal-aux mod 11).
            
                 end.
            
                /* Valida Segundo digito verificador, (ultimo caracter da IE) */
                 if int(substr(v-ie,length(v-ie),1)) = vdig2-aux
                 then assign v-ok = yes.
                 else assign v-ok = no.
                        
            end.
            
        end.
        
    end.
end procedure.            

procedure IE-PI:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
          nro[i] = substr(v-ie,i,1).
        end.  
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        v-fim = soma mod 11.
        if v-fim <= 1 
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-RJ:
    if length(v-ie) > 8
    then v-ok = no.
    else do:
        do i = 1 to 8:
          nro[i] = substr(v-ie,i,1).
        end.
        b = 2.
        soma = 0.
        do i = 1 to 7:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 1
            then b = 7.
        end.    
        v-fim = soma mod 11.
        if v-fim <= 1
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[8])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-RN:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        soma = soma * 10.
        v-fim = soma mod 11.
        if v-fim = 10 
        then v-dig = 0.
        else v-dig = v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end.            

procedure IE-RO:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.
        b = 6.
        soma = 0.
        do i = 3 to 8:
            soma = soma + (int(nro[i]) * b ).
            b = b - 1.
        end.    
        v-fim = soma mod 11.
        if v-fim >= 10
        then v-dig = v-fim - 10.
        else v-dig = v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
    if length(v-ie) > 14
    then v-ok = no.
    else do:
        do i = 1 to 14:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 6.
        soma = 0.
        do i = 1 to 4:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        b = 9.
        do i = 5 to 13:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        v-fim = soma mod 11.
        v-dig = 11 - v-fim .
        if v-dig >= 10
        then v-dig = v-dig - 10.
        if v-dig = int(nro[14])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IR-RR:
    if length(v-ie) > 9
    then v-ok = no.
    else if substring(v-ie,1,2) <= "24"
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        soma = 0.
        b = 1.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b + 1.
        end.
        v-dig = soma mod 9.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end.              

procedure IE-SC:
    
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
          soma = soma + (int(nro[i]) * b).
          b = b - 1.
        end.
        v-fim = soma mod 11.
        if v-fim <= 1
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
    
    /*Marcela Contabilidade*/
    if today = 08/29/2012
    then v-ok = yes.
    
end procedure.              

procedure IE-SP:
    
    if substr(v-ie,1,1) = "P"
    then do:
        s = substr(v-ie,2,10).
        do i = 1 to 9:
           nro[i] = substr(s,i,1).
        end.
           
        soma = (int(nro[1]) * 1) + (int(nro[2]) * 3) + (int(nro[3]) * 4) 
                + (int(nro[4]) * 5) + (int(nro[5]) * 6) 
                + (int(nro[6]) * 7) + (int(nro[7]) * 8) + (int(nro[8]) * 10).
        v-fim = soma mod 11.
        v-dig = v-fim.
        if v-dig >= 10
        then v-dig = 0.        
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
    else do:        
        if length(v-ie) < 12
        then v-ok = no.
        else do:
            do i = 1 to 12:
                nro[i] = substr(v-ie,i,1).
            end.
            soma = (int(nro[1]) * 1) + (int(nro[2]) * 3) + (int(nro[3]) * 4) 
                    + (int(nro[4]) * 5) + (int(nro[5]) * 6) + (int(nro[6]) * 7) 
                    + (int(nro[7]) * 8) + (int(nro[8]) * 10).
            v-fim = soma mod 11.
            v-dig = v-fim.
            if v-dig >= 10
            then v-dig = 0.
            if v-dig = int(nro[9])
            then v-ok = yes.
            else v-ok = no.
            if v-ok
            then do:
            soma = (int(nro[1]) * 3) + (int(nro[2]) * 2) + (int(nro[3]) * 10) + 
                   (int(nro[4]) * 9) + (int(nro[5]) * 8) + (int(nro[6]) * 7) + 
                   (int(nro[7]) * 6) + (int(nro[8]) * 5) +
                   (int(nro[9]) * 4) + (int(nro[10]) * 3) + (int(nro[11]) * 2).
            v-fim = soma mod 11.
            v-dig = v-fim.
            if v-dig >= 10
            then v-dig = 0.
            if v-dig = int(nro[12])
            then v-ok = yes.
            else v-ok = no.
            end.
        end.
    end.
end procedure.     
       
procedure IE-SE:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.    
        v-fim = soma mod 11.
        v-dig = 11 - v-fim.
        if v-dig >= 10
        then v-dig = 0.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.            

procedure IE-TO:
    if length(v-ie) > 9
    then v-ok = no.
    else do:
        do i = 1 to 9:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        do i = 1 to 8:
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
        end.
        v-fim = soma mod 11.
        if v-fim < 2
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[9])
        then v-ok = yes.
        else v-ok = no.
    end.
    if length(v-ie) > 11
    then v-ok = no.
    else if length(v-ie) > 9
    then do:
        do i = 1 to 11:
            nro[i] = substr(v-ie,i,1).
        end.    
        b = 9.
        soma = 0.
        s = substr(v-ie,3,2).
        if s = "01" or s = "02" or s = "03" or s = "99"
        then do:
            do i = 1 to 10:
                if i <> 3 and i <> 4
                then do:
                    soma = soma + (int(nro[i]) * b).
                    b = b - 1.
                end.
            end.
        end.            
        v-fim = soma mod 11.
        if v-fim < 2
        then v-dig = 0.
        else v-dig = 11 - v-fim.
        if v-dig = int(nro[11])
        then v-ok = yes.
        else v-ok = no.
    end.
end procedure.        

def var total as dec.
def var ii as int.
procedure IE-MG:
    if length(v-ie) <> 13
    then v-ok = no.
    else do:
        v-ok = yes.
        /**
        do i = 1 to 13:
            nro[i] = substr(v-ie,i,1).
        end.
        b = 11.
        soma = 0.
        ii = 1.
        do i = 1 to 12: 
            soma = soma + (int(nro[i]) * b).
            b = b - 1.
            if b = 0 then b = 9.
        end.       
        v-fim = soma mod 10.
        if v-fim = 0
        then v-fim = 10.
        v-dig = 10 - v-fim.
        if v-dig = int(nro[12])
        then v-ok = yes.
        else v-ok = no.
        b = 11.
        soma = 0.
        total = 0.
        ii = 1.
        do i = 1 to 13:
            soma = soma + (int(nro[i]) * b ).
            b = b - 1.
            if b = 0 then b = 11.
        end.        
        v-fim = soma mod 11.
        if v-fim = 0 or v-fim = 1
        then v-fim = 11.
        v-dig = 3 - v-fim.
        if v-dig = int(nro[13])
        then v-ok = yes.
        else v-ok = no.
        **/
    end.
end procedure.            

    
