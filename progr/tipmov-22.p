find com.tipmov where com.tipmov.movtdc = 22 no-lock.
find comloja.tipmov where comloja.tipmov.movtdc = 22 no-error.
if not avail comloja.tipmov
then do:
    create comloja.tipmov.
    
    buffer-copy com.tipmov to comloja.tipmov.
end. 