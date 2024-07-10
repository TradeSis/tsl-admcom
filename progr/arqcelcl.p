for each clien where clien.dtcad >= today - 90 no-lock.
    if substr(clien.fax,1,1) = "1" or
       substr(clien.fax,1,1) = "2" or
       substr(clien.fax,1,1) = "3" or
       substr(clien.fax,1,1) = "4" or
       substr(clien.fax,1,1) = "5" or
       substr(clien.fax,1,1) = "6" or
       substr(clien.fax,1,1) = "7" or
       substr(clien.fax,1,1) = "8" or
       substr(clien.fax,1,1) = "9" or
       substr(clien.fax,1,1) = "0"
    then do:
        if substr(clien.fax,3,2) <> "96" and
           substr(clien.fax,3,2) <> "97" and
           substr(clien.fax,3,2) <> "98" and
           substr(clien.fax,3,2) <> "99"  
        then next.
    end.
    else next.
    disp clien.fax.
end.    
