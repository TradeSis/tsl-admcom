find com.tipmov where com.tipmov.movtdc = 11 no-lock.
find comloja.tipmov where com.tipmov.movtdc = 11 no-error.
if not avail comloja.tipmov
then do:
    create comloja.tipmov.
    
    buffer-copy com.tipmov to comloja.tipmov.
end. 