for each fin.modal no-lock:
    find banfin.modal where 
         banfin.modal.modcod = fin.modal.modcod no-lock no-error.
    if not avail banfin.modal
    then do:
        create banfin.modal.
        buffer-copy fin.modal to banfin.modal.
    end.
end.
