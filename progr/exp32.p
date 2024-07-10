output to /linux/admcom/work/tit32.d.
for each titulo where etbcod = 32 and clifor <> 1 
            and titsit = "PAG":
   /*
   disp modcod titnat clifor titdtemi titdtven titdtpag datexp format                 "99/99/9999".   */
   export titulo.
end.
output close.   
          
