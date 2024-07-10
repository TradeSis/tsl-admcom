for each contrato where etbcod = 02:
    if year(dtinicial) <= 1950 then do:
       dtinicial =  date(month(dtinicial),
                          day(dtinicial),
                          year(dtinicial) + 100).
    
       disp contnum dtinicial datexp format "99/99/9999" with 1 down. pause 0.
    end.
end.