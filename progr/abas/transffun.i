/* INI */

function disponivel return decimal
        (input par-procod as int).
def buffer babasroman for abasroman.         
def var par-estoque as dec.
def var par-reserva as dec.

   find estoq where estoq.etbcod = vetbdepos and
                    estoq.procod = par-procod
                    no-lock no-error.
   par-Estoque = if avail estoq
                 then estoq.estatual
                 else 0.

   find estoq where estoq.etbcod = vetbdeposaux and
                    estoq.procod = par-procod
                    no-lock no-error.
   par-Estoque = par-estoque +
                 if avail estoq
                 then estoq.estatual
                 else 0.
   /* le totods os romaneuios */
   for each babastransf where babastransf.procod = par-procod 
    no-lock.
      if recid(abastransf) = recid(babastransf)
          then next.
          
      if babastransf.abtsit = "R" 
      then do:
         find babasroman where babasroman.etbcod = babastransf.EtbRoman
                         and babasroman.abrcod = babastransf.abrcod 
              no-lock no-error.
         if avail babasroman and (babasroman.placod > 0 or 
                babasroman.abrsit = "C")
         then
           next.
         par-reserva = par-reserva + 
                    /*if babastransf.qtdatend = 0
                    then babastransf.abtqtd
                    else*/ babastransf.qtdatend.
      end.
   end.

    /* se eu sou reserva negativa
        le todas as negativas < meu dia */
        
   if abastransf.abtsit <> "R" and abastransf.abatipo = "NEG"
   then
   for each babastransf where babastransf.procod = par-procod and
    babastransf.dttransf < abastransf.dttransf and
    babastransf.abatipo = "NEG" 
    no-lock .

        if recid(abastransf) = recid(babastransf)
        then next.
        
      if babastransf.abtsit = "R" 
      then next.

      if babastransf.abtsit = "A" then
        if (scliente <> "OBI"  and /* NAO EH OBINO */
            (babastransf.abatipo = "NEG" or
             babastransf.abatipo = "LOJ" or
             babastransf.abatipo = "COM"))
           or
           scliente = "OBI" /* OBINO VAI TUDO */  
        then par-Reserva = par-Reserva + 
                    if babastransf.qtdatend = 0 or
                       babastransf.qtdatend = ?
                    then babastransf.abtqtd
                    else babastransf.qtdatend.
   end.

   /* se eu sou negativa
    le todas as negativas do meu dia com 
            sequencia menor que a minha */
            
   if abastransf.abtsit <> "R" and abastransf.abatipo = "NEG"
   then
   for each babastransf where babastransf.procod = par-procod and
    babastransf.dttransf = abastransf.dttransf and
    babastransf.abatipo = "NEG" and
    babastransf.abtcod <= abastransf.abtcod no-lock .

        if recid(abastransf) = recid(babastransf)
        then next.
        
      if babastransf.abtsit = "R" 
      then next.

      if babastransf.abtsit = "A" then
        if (scliente <> "OBI"  and /* NAO EH OBINO */
            (babastransf.abatipo = "NEG" or
             babastransf.abatipo = "LOJ" or
             babastransf.abatipo = "COM"))
           or
           scliente = "OBI" /* OBINO VAI TUDO */  
        then par-Reserva = par-Reserva + 
                    if babastransf.qtdatend = 0 or
                       babastransf.qtdatend = ?
                    then babastransf.abtqtd
                    else babastransf.qtdatend.
   end.

            
    /* se nao sou reserva negativa
            le todas as negativas */
            
   if abastransf.abtsit <> "R" and abastransf.abatipo <> "NEG"
   then
   for each babastransf where babastransf.procod = par-procod and
   /* babastransf.dttransf <= abastransf.dttransf and*/
    babastransf.abatipo = "NEG" 
/*    babastransf.abtcod <= abastransf.abtcod*/ no-lock .

        if recid(abastransf) = recid(babastransf)
        then next.
        
      if babastransf.abtsit = "R" 
      then next.

      if babastransf.abtsit = "A" then
        if (scliente <> "OBI"  and /* NAO EH OBINO */
            (babastransf.abatipo = "NEG" or
             babastransf.abatipo = "LOJ" or
             babastransf.abatipo = "COM"))
           or
           scliente = "OBI" /* OBINO VAI TUDO */  
        then par-Reserva = par-Reserva + 
                    if babastransf.qtdatend = 0 or
                       babastransf.qtdatend = ?
                    then babastransf.abtqtd
                    else babastransf.qtdatend.
   end.
                                  
   if abastransf.abtsit <> "R" and abastransf.abatipo <> "NEG"
   then
   for each babastransf where babastransf.procod = par-procod and
    babastransf.dttransf < abastransf.dttransf and
    babastransf.abatipo <> "NEG" 
    no-lock .

        if recid(abastransf) = recid(babastransf)
        then next.
        
      if babastransf.abtsit = "R" 
      then next.

      if babastransf.abtsit = "A" then
        if (scliente <> "OBI"  and /* NAO EH OBINO */
            (babastransf.abatipo = "NEG" or
             babastransf.abatipo = "LOJ" or
             babastransf.abatipo = "COM"))
           or
           scliente = "OBI" /* OBINO VAI TUDO */  
        then par-Reserva = par-Reserva + 
                    if babastransf.qtdatend = 0 or
                       babastransf.qtdatend = ?
                    then babastransf.abtqtd
                    else babastransf.qtdatend.
   end.
                                  
   if abastransf.abtsit <> "R" and abastransf.abatipo <> "NEG"
   then
   for each babastransf where babastransf.procod = par-procod and
    babastransf.dttransf = abastransf.dttransf and
    babastransf.abatipo <> "NEG" and
    babastransf.abtcod <= abastransf.abtcod no-lock .

        if recid(abastransf) = recid(babastransf)
        then next.
        
      if babastransf.abtsit = "R" 
      then next.

      if babastransf.abtsit = "A" then
        if (scliente <> "OBI"  and /* NAO EH OBINO */
            (babastransf.abatipo = "NEG" or
             babastransf.abatipo = "LOJ" or
             babastransf.abatipo = "COM"))
           or
           scliente = "OBI" /* OBINO VAI TUDO */  
        then par-Reserva = par-Reserva + 
                    if babastransf.qtdatend = 0 or
                       babastransf.qtdatend = ?
                    then babastransf.abtqtd
                    else babastransf.qtdatend.
   end.
                                      
    
    return par-estoque - par-reserva /*+ abastransf.abtqtd*/ .      

end function.        

      

/*
  ATENDE
*/

function atende return logical
    (input par-procod as int,
     input par-abatipo as char,
     input vabtqtd as dec,
     output par-atende as dec).
     
def var par-disponivel as dec.
def var vresp as log.
     
   par-disponivel = disponivel(par-procod).
   
   par-atende     = if par-disponivel >= vabtqtd
                    then vabtqtd
                    else /*if par-abatipo = "NEG" or
                            par-abatipo = "LOJ" or
                            par-abatipo = "COM" 
                         then vabtqtd
                         else*/ par-disponivel.
   
   if par-disponivel <= 0
   then vresp = no.
   else if par-atende <= 0
        then vresp = no.
        else vresp = yes.

   if vresp = no
   then par-atende = 0.

    /*
   if scliente = "OBI"
   then /*if (abastransf.abatipo = "NEG" or
            abastransf.abatipo = "LOJ")
        then*/ vresp = yes. /* sempre deixa marcar */
        */
        
   return vresp.


end function.


/* FIM */

