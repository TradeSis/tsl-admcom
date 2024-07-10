def input parameter p-uf as char.
def output parameter p-cod as char.
def output parameter p-dig as char.

find unfed where unfed.ufecod = p-uf no-lock no-error.
if avail unfed
then do:
    if unfed.ufenom = "Acre"
    then assign p-cod = "01" p-dig = "9".
    else if unfed.ufenom = "Alagoas"
    then assign p-cod = "02" p-dig = "7".
    else if unfed.ufenom = "Amapa"
    then assign p-cod = "03" p-dig = "5".
    else if unfed.ufenom = "Amazonas"
    then assign p-cod = "04" p-dig = "3".
    else if unfed.ufenom = "Bahia"
    then assign p-cod = "05" p-dig = "1".
    else if unfed.ufenom = "Ceara"
    then assign p-cod = "06" p-dig = "0".
    else if unfed.ufenom = "Distrito Federal"
    then assign p-cod = "07" p-dig = "8".
    else if unfed.ufenom = "Espirito Santo"
    then assign p-cod = "08" p-dig = "6".
    else if unfed.ufenom = "Goias"
    then assign p-cod = "10" p-dig = "8".
    else if unfed.ufenom = "Maranhao"
    then assign p-cod = "12" p-dig = "4".
    else if unfed.ufenom = "Mato Grosso"
    then assign p-cod = "13" p-dig = "2".
    else if unfed.ufenom = "Mato Grosso do Sul"
    then assign p-cod = "28" p-dig = "0".
    else if unfed.ufenom = "Minas Gerais"
    then assign p-cod = "14" p-dig = "0".
    else if unfed.ufenom = "Para"
    then assign p-cod = "15" p-dig = "9".
    else if unfed.ufenom = "Paraiba"
    then assign p-cod = "16" p-dig = "7".
    else if unfed.ufenom = "Parana"
    then assign p-cod = "17" p-dig = "5".
    else if unfed.ufenom = "Pernambuco"
    then assign p-cod = "18" p-dig = "3".
    else if unfed.ufenom = "Piaui"
    then assign p-cod = "19" p-dig = "1".
    else if unfed.ufenom = "Rio Grande do Norte"
    then assign p-cod = "20" p-dig = "5".
    else if unfed.ufenom = "Rio Grande do Sul"
    then assign p-cod = "21" p-dig = "3".
    else if unfed.ufenom = "Rio de Janeiro"
    then assign p-cod = "22" p-dig = "1".
    else if unfed.ufenom = "Rondonia"
    then assign p-cod = "23" p-dig = "0".
    else if unfed.ufenom = "Roraima"
    then assign p-cod = "24" p-dig = "8".
    else if unfed.ufenom = "Santa Catarina"
    then assign p-cod = "25" p-dig = "6".
    else if unfed.ufenom = "Sao Paulo"
    then assign p-cod = "26" p-dig = "4".
    else if unfed.ufenom = "Sergipe"
    then assign p-cod = "27" p-dig = "2".
    else if unfed.ufenom = "Tocantins"
    then assign p-cod = "29" p-dig = "9".
end.

