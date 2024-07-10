/*  produ_descontinuado.p              */
def input  parameter vetbcod        like estab.etbcod.
def input  parameter vprocod        like produ.procod.
def output parameter vestatual_cd   as   dec.
def output parameter vpedid_abe     like liped.lipqtd.
def output parameter vestoq_fil     like estoq.estatual.


def var vestatual995  like estoq.estatual format "->>>>9".
def var vestatual980  like estoq.estatual format "->>>>9".
def var vdisponiv993  like estoq.estatual format "->>>>9".
def var vdisponiv981  like estoq.estatual format "->>>>9".
def var vestatual993  like estoq.estatual format "->>>>9".
def var vestatual981  like estoq.estatual format "->>>>9".
def var vestatual998  like estoq.estatual format "->>>>9".
def var vestatual500  like estoq.estatual format "->>>>9".




find produ where produ.procod = vprocod no-lock no-error.

    assign
           vestatual_cd     = 0  
           vpedid_abe       = 0  
           vestoq_fil       = 0  
           vestatual995     = 0  
           vestatual980     = 0  
           vdisponiv993     = 0  
           vdisponiv981     = 0  
           vestatual993     = 0  
           vestatual981     = 0  
           vestatual998     = 0  
           vestatual500     = 0  .

if not avail produ then leave.           

    
    find estoq where estoq.etbcod = vetbcod      and 
                     estoq.procod = produ.procod no-lock no-error.
    vestoq_fil = if avail estoq 
                 then estoq.estatual
                 else 0.
                 

                         
    find estoq where estoq.etbcod = 993 and estoq.procod = vprocod
        no-lock no-error.
    if avail estoq then assign vestatual993 = vestatual993 + estoq.estatual.
    find estoq where estoq.etbcod = 981 and estoq.procod = vprocod
        no-lock no-error.
    if avail estoq then assign vestatual981 = vestatual981 + estoq.estatual.
    
    find estoq where estoq.etbcod = 995 and estoq.procod = vprocod
        no-lock no-error.
    if avail estoq then assign vestatual995 = vestatual995 + estoq.estatual.

    find estoq where estoq.etbcod = 980 and estoq.procod = vprocod
        no-lock no-error.
    if avail estoq then assign vestatual980 = vestatual980 + estoq.estatual.

    find estoq where estoq.etbcod = 998 and estoq.procod = vprocod
        no-lock no-error.
    if avail estoq then assign vestatual998 = vestatual998 + estoq.estatual.
    find estoq where estoq.etbcod = 500 and estoq.procod = vprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual500 = vestatual500 + estoq.estatual.  

    
    run compras_pendentes_entrega_CD ( input  vprocod, 
                                       output vpedid_abe).


    vestatual_cd =  vestatual993 + vestatual981 + vestatual995 +  
                    vestatual980 +  vestatual500.






procedure compras_pendentes_entrega_CD.
def input  parameter par-procod like produ.procod.
def output parameter compras_pendentes_entrega_CD as int.
    compras_pendentes_entrega_CD = 0.
    for each liped where  liped.procod = par-procod and
                                 liped.pedtdc = 1 and
                                 (liped.predtf = ? or
                                 liped.predtf >= today - 365) no-lock,
              first pedid of liped where pedid.pedsit = yes and
                            pedid.sitped <> "F"  and
                            pedid.peddat > today - 365 no-lock:
            compras_pendentes_entrega_CD = compras_pendentes_entrega_CD +
                                (liped.lipqtd - liped.lipent).
    end.

end procedure.

