/***********************************************************************
***********************************************************************
***********************************************************************
 
      Laureano - Recebe qualquer data e retorna o �ltimo dia do m�s

      Chamada: {mes-fim.i 02/10/2016}.

***********************************************************************
***********************************************************************
***********************************************************************/
 
date(month(date(month({1}),28,year({1}))+ 4),
     1,
     year(date(month({1}),28,year({1}))+ 4))
     - 1.