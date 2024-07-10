function troca-label returns character
    (input par-handle as handle,
     input par-label  as char).
         
    if par-label = "NO-LABEL"
    then par-handle:label    = ?.
    else par-handle:label    = par-label.
         
end function.

