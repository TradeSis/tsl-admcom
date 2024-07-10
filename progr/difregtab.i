
def {1} shared temp-table tww-retorno-dif
    field  vez        as int
    field  ban        as char
    field  tabe       as char
    field  lab        as char
    field  val        as char
    field  alterado   as logical format "sim/nao" 
    index  k1         vez
                      ban
                      tabe
                      lab. 

def {1} shared temp-table table-raw
    field registro1 as raw
    field registro2 as raw
    field char1     as char
    field char2     as char.

