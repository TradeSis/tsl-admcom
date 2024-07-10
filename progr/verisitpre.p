/*verisitpre.p*/
                                                                 
def var fl1 as int label "De:".                                              
def var fl2 as int label "Ate:".                                             
def var tp as char label "Situacao:".                                        

tp = "PAG".

update fl1 fl2 tp. 

if fl1 > fl2
then
	message "dado incorreto".
	pause.
	return.
end.
else                                                                         
                                                          
/*for each titluc where titsit = tp and etbcod >= fl1 and etbcod <= fl2 and  
titdtemi >=                                                                  
07/01/2010 and titdtemi <= 07/31/2010 by clifor.                             
disp clifor titnum titsit titvlcob titdtven titdtemi titdtpag.               
  */                                                                         
                                                                             