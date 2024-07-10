function banrisulmodulo11 returns integer
    (input par-numero as char,
     input par-numeron as char,
     input-output par-dv10   as int).

   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso as int.   

   vpeso = 2.
   do vct = 9 to 1 by -1.
        vparc = (int(substr(par-numeron,vct,1)) * vpeso).
        vsoma  = vsoma + vparc.
        vpeso = vpeso + 1.
        if vpeso = 8
        then vpeso = 2.
    end.        

    if vsoma < 11
    then vresto = vsoma.
    else vresto = vsoma modulo 11.
    if vresto = 1
    then do:
        vsoma = 0.
        if par-dv10 = 9
        then do:
            par-dv10 = 0.
            par-numeron = par-numero + string(par-dv10).
            vpeso = 2.
            do vct = 9 to 1 by -1.
                vparc = (int(substr(par-numeron,vct,1)) * vpeso).
                vsoma  = vsoma + vparc.
                vpeso = vpeso + 1.
                if vpeso = 8
                then vpeso = 2.
            end.        
        end.
        else do:
            par-dv10 = par-dv10 + 1.
            par-numeron = par-numero + string(par-dv10).
            vpeso = 2.
            do vct = 9 to 1 by -1.
                vparc = (int(substr(par-numeron,vct,1)) * vpeso).
                vsoma  = vsoma + vparc.
                vpeso = vpeso + 1.
                if vpeso = 8
                then vpeso = 2.
            end.  
        end.             
        if vsoma < 11 
        then vresto = vsoma. 
        else vresto = vsoma modulo 11.
    end.

    if vresto = 0
    then return 0. 
    else return 11 - vresto.

end function.


function modulo10 returns int
    (input par-numero as char).
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vpeso  as int.
   def var vresto as int.
   def var vdv1   as int.
   def var vtam   as int.

   vpeso = 2.
   vtam  = length(par-numero).
   
   do vct = vtam to 1 by -1.
        vparc = (int(substr(par-numero,vct,1)) * vpeso).
        if vparc > 9
        then vparc = vparc - 9.
        vsoma  = vsoma + vparc.
        vpeso = vpeso - 1.
        if vpeso = 0
        then vpeso = 2.
    end.        
    vresto = if vsoma < 10 then vsoma else (vsoma modulo 10).
    vdv1 = if vresto = 0 then 0 else 10 - vresto.
    return vdv1.
    
end function.


function santandermodulo11 returns integer
    (input par-numeron as char).

   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso  as int.
   def var vtam   as int.
   
   vpeso = 2.
   vtam  = length(par-numeron).
   do vct = vtam to 1 by -1.
        vparc = (int(substr(par-numeron, vct, 1)) * vpeso).
        vsoma = vsoma + vparc.
        vpeso = vpeso + 1.
        if vpeso > 9
        then vpeso = 2.
    end.
    vresto = (vsoma * 10) modulo  11.
    if vresto = 0 or vresto = 10
    then vresto = 1.

    return vresto.
end function.

function nossonumerosantander returns logical
    (input par-numero   as dec).

   def var vct    as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso  as int init 2.
   def var vtam   as int.
   def var vnumero as char.

   vnumero = string(par-numero).
   vtam  = length(vnumero) - 1.
   do vct = vtam to 1 by -1.
        vsoma = vsoma + (int(substr(vnumero, vct, 1)) * vpeso).
        vpeso = vpeso + 1.
        if vpeso > 9
        then vpeso = 2.
    end.
    vresto = vsoma modulo 11.
    if vresto <= 1
    then vresto = 0.
    else vresto = 11 - vresto.
    return string(vresto) = substring(vnumero, vtam + 1, 1).

end function.

function nossonumerobanrisul returns logical
    (input par-numero as dec).
def var vaux as char.
def var vnumero as char.
def var vnumeron as char.
def var vmodulo10 as int.
def var vmodulo11 as int.
def var v10 as int.
def var v11 as int.

    vaux = string(par-numero, "9999999999").
    vnumero = substring(vaux,1,8).
    vmodulo10 = int(substring(vaux,9,1)).
    v10 = modulo10(vnumero).

    vmodulo11 = int(substring(vaux,10,1)).
    vnumeron = vnumero + string(v10).
    v11 = banrisulmodulo11(vnumero,vnumeron,input-output v10).

    return v10 = vmodulo10 and v11 = vmodulo11.
   
end function.


function banrisulbarra returns logical
    (input vdoc-barra as char,
     output par-bancod   as int,
     output par-valor    as dec,
     output par-vcto     as date,
     output par-nossonro as dec).

    def var vdoc-banco      as char format "x(3)"  label "Ban".
    def var vdoc-banco2     as char.
    def var vdoc-valor      as char format "x(14)" label "Valor".
    def var vdoc-nossonro   as char format "x(14)" label "NossoNro".
    def var vdoc-fatorvcto  as char format "x(4)".
    def var vnumero  as char.
    def var vnumeron as char.
    def var v10 as int.
    def var v11 as int.

    vdoc-banco     = substring(vdoc-barra, 1, 3).
    vdoc-banco2    = substring(vdoc-barra,40, 3).
    vdoc-valor     = substring(vdoc-barra,10,10).
    vdoc-nossonro  = substring(vdoc-barra,32, 8).
    vdoc-fatorvcto = substring(vdoc-barra, 6, 4).

    if vdoc-banco = "041"
    then do.
        vnumero = vdoc-nossonro.
        v10 = modulo10(vnumero).
        vnumeron = vnumero + string(v10).
        v11 = banrisulmodulo11(vnumero,vnumeron,input-output v10).
        par-nossonro = dec(vnumero + string(v10) + string(v11)).
    end.
    else do.
        if vdoc-banco = "409"
        then vdoc-nossonro  = substring(vdoc-barra, 30, 15).
        else vdoc-nossonro  = substring(vdoc-barra, 28, 13).
        par-nossonro = dec(vdoc-nossonro).
        v10 = santandermodulo11( substring(vdoc-barra, 1,  4) +
                                 substring(vdoc-barra, 6, 39) ).
        if string(v10) <> substring(vdoc-barra, 5,  1)
        then return false.
    end.

    par-bancod   = int(vdoc-banco).
    par-valor    = dec(vdoc-valor) / 100.
    par-vcto     = 10/07/1997 + int(vdoc-fatorvcto).

    if vdoc-banco <> "041"
    then return /*** solic.19344 nossonumerosantander(par-nossonro) and ***/
                par-nossonro > 0.
    else return (vdoc-banco = "041" and vdoc-banco2 = "041" and
                 nossonumerobanrisul(par-nossonro)) and
                par-nossonro > 0.
    
end function.


function banrisuldigitavel returns logical
    (input  vdigitavel as char,
     output par-bancod    as int,
     output par-doc-valor as dec,
     output par-vcto      as date,
     output par-nossonro  as dec).

    def var vdoc-banco as char.
    def var vdoc-banco2 as char.
    def var vdoc-fatorvcto as char.
    def var vdoc-nossonro as char format "x(14)" label "NossoNro".
    def var vnumero as char.
    def var vnumeron as char.
    def var v10 as int.
    def var v11 as int.

    /* RM 10/08 - Validacao da digitacao */
    if modulo10( substr(vdigitavel, 11, 10) ) <>
       int( substr(vdigitavel, 21, 1) )
    then do.
        message "Problema no segundo grupo".
        return false.
    end.
    if modulo10( substr(vdigitavel, 22, 10) ) <>
       int( substr(vdigitavel, 32, 1) )
    then do.
        message "Problema no terceiro grupo".
        return false.
    end.
    /* */

    vdoc-banco     = substring(vdigitavel, 1,3).
    vdoc-nossonro  = substring(vdigitavel,18,3) + substring(vdigitavel,22,5).
    vdoc-banco2    = substring(vdigitavel,27,3).                          
    vdoc-fatorvcto = substring(vdigitavel,34,4).
    par-doc-valor  = dec(substring(vdigitavel,38)) / 100.

    par-vcto   = 10/07/1997 + int(vdoc-fatorvcto).
    par-bancod = int(vdoc-banco).

    if vdoc-banco = "041"
    then do.
        vnumero = vdoc-nossonro.
        v10 = modulo10(vnumero).
        vnumeron = vnumero + string(v10).
        v11 = banrisulmodulo11(vnumero,vnumeron,input-output v10).
        par-nossonro = dec(vnumero + string(v10) + string(v11)).
    end.
    else do.
        par-nossonro  = dec(substring(vdigitavel,16,5) +
                            substring(vdigitavel,22,6) ).
    end.

    if vdoc-banco <> "041"
    then return nossonumerosantander(par-nossonro) and par-nossonro > 0.
    else return (vdoc-banco = "041" and vdoc-banco2 = "041" and
                 nossonumerobanrisul(par-nossonro)) and
                par-nossonro > 0.

end function.

/**
def var vnumero as int.

update vnumero format "9999999999".

disp nossonumerobanrisul (vnumero).
**/
