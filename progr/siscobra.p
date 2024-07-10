

    def var tiporeceita as char.
    def var cestcivil as char.
    def var tiposexo as char.

output to "/admcom/TI/joao/siscobra.txt".

put "00".
put day(today) format "99".
put month(today) format "99".
put year(today) format "9999" skip.  


for each clien where clien.clicod > 10 no-lock.
                 pause 0.

                              
     find first titulo use-index iclicod
                  where titulo.clifor = clien.clicod and 
                        titulo.modcod begins "CP" and 
                        titulo.titsit = "LIB" and
                        titulo.titdtpag = ? and
                        titulo.titdtven < (today - 60) no-lock no-error. 


        if not avail titulo then next.
                      

                       if length(clien.ciccgc) = 11 then do:
                             tiporeceita = "F".
                              end.
                              else do:
                              tiporeceita = "J".
                              end.

                      if clien.sexo = yes then do:
                          tiposexo = "M".
                      end.
                      else do:
                          tiposexo = "F".
                      end.


                
            cestcivil = if clien.estciv = 1 then "S" else
                        if clien.estciv = 2 then "C"   else
                        if clien.estciv = 3 then "V"    else
                        if clien.estciv = 4 then "D" else
                        if clien.estciv = 5 then "D" else
                        if clien.estciv = 6 then "X" else "". 


                                                   
put "01".
put clien.ciccgc format "x(18)".
put clien.clinom format "x(40)".   /* 21-60 */
put tiporeceita  format "x(1)".    /* 61     */
put tiposexo format "x(1)".        /* 62     */
put " " format "x(4)".              /* 63-66  */
put replace(clien.endereco[1], ";", " ") format "x(40)".         /* 67 - 106 */
put replace(string(clien.numero[1]), ";", " ") format "x(10)".   /* 107 - 116 */
put replace(clien.compl[1], ";", " ") format "x(25)".      /* 117 - 141 */
put replace(clien.bairro[1], ";", " ") format "x(25)".    /* 142 - 166 */
put replace(clien.cidade[1], ";", " ") format "x(25)".    /* 167 - 191  */
put replace(clien.uf[1], ";", " ") format "x(2)".  /* 192- 193  */
put replace(clien.cep[1], ";", " ") format "x(9)".  /* 194-202 */
put " " format "x(40)".              /* 203-242  */
put " " format "x(4)".               /* 243-246  */
put replace(clien.fone, ";", " ") format "x(20)". /* 247-266 */
put " " format "x(22)".               /* 267-288  */
put replace(clien.fax, ";", " ") format "x(20)". /* 289-308 */
put clien.ciinsc format "x(18)". /* 309-326 */
put " " format "x(15)".               /* 327-341  */
put day(dtnasc) format "99".
put month(dtnasc) format "99".
put year(dtnasc) format "9999". /*342-349 */
put cestcivil format "x(1)".  /* 350 */
put " " format "x(32)".               /* 351-382  */
put  replace(clien.mae, ";", " ") format "x(45)". /* 383-427 */
put  replace(clien.pai, ";", " ") format "x(45)". /* 428-472 */
put " " format "x(90)". /* 473-492 */
put string(clien.clicod) format "x(20)". /* 563-582 */               
put " " format "x(18)".  /* 583-600 */
                   
put skip.                        
    
    
    
    
    
    
    
    
    
                             
end.


output close.

