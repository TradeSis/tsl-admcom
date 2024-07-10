def var vnumeropedido like contrsite.codigoPedido.

/*VERSAO 2 23062021*/

function testavalido return log
    (input par-palavra as char).
    def var vok as log.

       if  par-palavra <> "" and 
           par-palavra <> ?  and
           par-palavra <> "?"
       then vok = yes.
       else vok = no.
     return vok.

end function.


function trata-numero returns character
    (input par-num as char).

    def var par-ret as char.
    def var j as int.
    def var t as int.
    def var vletra as char.

    if par-num = ?
    then par-num = "".

    t = length(par-num).
    do j = 1 to t:
        vletra = substr(par-num,j,1).
        if vletra = "0" or
           vletra = "1" or
           vletra = "2" or
           vletra = "3" or
           vletra = "4" or
           vletra = "5" or
           vletra = "6" or
           vletra = "7" or
           vletra = "8" or
           vletra = "9"
        then assign par-ret = par-ret + vletra.
    end.
    return par-ret.

end function.


function aaaa-mm-dd_todate returns date 
    (input varchar as char).
    
    def var vdata as date.

    vdata = 
        date(int(substring(varchar,6,2)),
             int(substring(varchar,9,2)),
             int(substring(varchar,1,4))) no-error.
             
    return vdata.
    
end function.    

function true_tolog returns log 
    (input varchar as char).
    
    def var vlog as log.

    vlog = trim(varchar) = "true" no-error.
    
    if vlog = ? then vlog = no.

    return vlog.
    
end function.    

function hora_totime returns int
    (input par-hora as char).
    
        
    def var auxi as int.
    def var auxc as char.
    def var vseg as int.
    def var vmin as int.
    def var vhor as int.
    def var vtime as int.
    
    if length(par-hora) = 19 /*** mm-dd-aaaa 00:00:00 ***/
    then vtime = int(substr(par-hora, 12, 2)) * 3600 +
                 int(substr(par-hora, 15, 2)) * 60 +
                 int(substr(par-hora, 18, 2)).
    else do.

        par-hora = replace(par-hora,":","").
    
        auxi = int (par-hora).
        auxc = string(auxi,"999999").
    
        vseg = int(substr(auxc,5,2)).
        vmin = int(substr(auxc,3,2)) * 60.
        vhor = int(substr(auxc,1,2)) * 60 * 60.
    
        vtime = vseg + vmin + vhor.
    end.

    return vtime.

end function.

/*** Retirar acentos ***/
function Texto return character
    (input par-texto as char).
    
        def var vtexto as char. 
        def var vletra as char. 
        def var vct    as int. 
        def var vi     as int. 
        def var vtam   as int. 
         
         if par-texto = ? 
         then vtexto = "". 
         else vtexto = caps(par-texto).
          
         /*
         par-texto = caps(trim(replace(par-texto, "~\","."))). 
         vtam = length(par-texto). 
         do vi = 1 to vtam. 
            vletra = substring(par-texto, vi, 1). 
            if vletra = "<" or 
               vletra = ">" or 
               asc(vletra) = 34 or 
               asc(vletra) = 39 
            then vtexto = vtexto + " ". 
            else if vletra = "&" 
                 then vtexto = vtexto + "E".  
                 else if length(vletra) = 1 and  
                         asc(vletra) >  31 and   
                         asc(vletra) < 127  
                      then vtexto = vtexto + vletra.
        end.  
        */
        
        return vtexto.  

end function.
           

function enviadata returns char
    (input  par-data as date).  
    if par-data = ?
    then return "".
    else return  string(year(par-data),"9999") + "-" +
                          string(month(par-data),"99")   + "-" +
                          string(day(par-data),"99"). 
end function.
