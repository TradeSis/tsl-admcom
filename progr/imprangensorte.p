
{admcab.i}

def var vdir     as char.
def var varq     as char.
def var vlinha   as char.
def var vdtivig  as date.
def var vdtfvig  as date.
def var vordem   as int. /* #1 */

def temp-table tt-sorte
    field dtsorteio as date
    field serie     as int
    field numero    as int
    field ordem     as int /* #1 */
    index sorte is primary unique dtsorteio serie numero.

def buffer btt-sorte for tt-sorte.

form with frame f-filtro side-label 
    title " Importar arquivo novo range numeros da sorte ".
do on error undo with frame f-filtro.
    update skip(1) vdir label "Diretorio" colon 20 format "x(45)".
    update varq label "Arquivo"   colon 20 format "x(45)".

    if search(vdir + varq) = ?
    then do.
        message "Arquivo nao encontrado:" vdir + varq view-as alert-box.
        undo.
    end.
end.

sresp = yes.
message "Processar validacao do arquivo?" update sresp.
if sresp <> yes
then return.

message "Aguarde validacao do arquivo...".
/***
    Validacao do arquivo
***/
def var vqtreghdr as int.
def var vqtregdet as int.
def var vqtregtrl as int.
def var vokunico  as int.
def var vcntlin   as int.
def var vinflin   as int.
def var vqonde as char.

output to xx-impnumsorte.txt.
unix silent value("unix2dos -q " + vdir + varq).
output close.

input from value(vdir + varq).
repeat.
    import unformatted vlinha.

    if substr(vlinha, 1, 1) = "H" /* Header */
    then do.
        if substr(vlinha, 2,7) = "RETORNO" or
           substr(vlinha,12,3) = "QBE" or
           substr(vlinha,12,6) = "Zurich"
        then vqtreghdr = vqtreghdr + 1.
        
        if substr(vlinha,12,3) = "QBE"
        then vqonde = substr(vlinha,12,3).
        else if substr(vlinha,12,6) = "Zurich"
            then vqonde = substr(vlinha,12,6).
    end.

    else if substr(vlinha, 1, 1) = "D"
    then do.
        vcntlin = vcntlin + 1.

        if vcntlin >= 1
        then vqtregdet = vqtregdet + 1.

        create tt-sorte.
        if vqonde = "Zurich"
        then 
        assign
            tt-sorte.dtsorteio = date(substr(vlinha,68,8))
            tt-sorte.serie     = int(substr(vlinha, 2, 3))
            tt-sorte.numero    = int(substr(vlinha, 5, 6))
            tt-sorte.ordem     = vcntlin /* #1 */.
        else
        assign
            tt-sorte.dtsorteio = date(substr(vlinha,67,8))
            tt-sorte.serie     = int(substr(vlinha, 2, 3))
            tt-sorte.numero    = int(substr(vlinha, 5, 5))
            tt-sorte.ordem     = vcntlin /* #1 */.

        find segnumsorte where segnumsorte.dtsorteio = tt-sorte.dtsorteio
                           and segnumsorte.serie     = tt-sorte.serie
                           and segnumsorte.nsorteio  = tt-sorte.numero
                         no-lock no-error.
        if avail segnumsorte
        then vokunico = vokunico + 1.
    end.

    else if substr(vlinha, 1, 1) = "T" /* Trailer */
    then do:
        assign
            vqtregtrl = vqtregtrl + 1
            vinflin = int(substr(vlinha, 2, 6)).
        vlinha = "".
    end.    
end.
input close.

hide message no-pause.

if vqtreghdr <> 1 or
   vqtregdet =  0 or
   vqtregtrl <> 1 or
   vcntlin  = 0
then do.
    message "Arquivo nao esta completo ou correto" view-as alert-box.
    return.
end.

if vcntlin <> vinflin
then do.
    message "Registros no arquivo:" vcntlin " Informados:" vinflin
        view-as alert-box.
    return.
end.

if vokunico > 0
then do.
    message "Numeros da sorte repetidos:" vokunico view-as alert-box.
    return.
end.
def var vdtsort as date.
find first tt-sorte no-lock.
vdtsort = tt-sorte.dtsorteio.
vdtsort = date((if month(today) = 12
                 then 1 else month(today) + 1),01,(if month(today) = 12
                                    then year(today) + 1
                                    else year(today))). 
/*
if tt-sorte.dtsorteio < today
then do.
    message "Data do sorteio invalida" tt-sorte.dtsorteio view-as alert-box.
    return.
end.
*/

find first btt-sorte where btt-sorte.dtsorteio <> tt-sorte.dtsorteio
                       and recid(btt-sorte) <> recid(tt-sorte)
                     no-lock no-error.
if avail btt-sorte
then do.
    message "Arquivo com mais de uma data de sorteio:"
            tt-sorte.dtsorteio btt-sorte.dtsorteio
        view-as alert-box.
    return.
end.
/*
vdtfvig = date(month(tt-sorte.dtsorteio), 1, year(tt-sorte.dtsorteio)) - 1.
vdtivig = date(month(vdtfvig), 1, year(vdtfvig)).
*/
vdtfvig = vdtsort - 1.
vdtivig = date(month(today),01,year(today)).
find last segnumsorte use-index ordem
                      where segnumsorte.dtsorteio = tt-sorte.dtsorteio
                      no-lock no-error.
if avail segnumsorte
then vordem = segnumsorte.ordem.

find first tt-sorte no-error.

disp vdtsort label "Dt.Sorteio" colon 20 format "99/99/9999"
     vdtivig label "Dt.Inicio Vigencia" colon 20 format "99/99/9999"
     vdtfvig label "Dt.Final Vigencia"  colon 20 format "99/99/9999"
     vordem  label "Ultima Ordem Imp."  colon 20
     tt-sorte.serie label "Serie"       colon 20
     with frame f-filtro.
/*
update vdtsort with frame f-filtro.
*/
if vdtsort < today
then do.
    message "Data do sorteio invalida" vdtsort view-as alert-box.
    return.
end.

find last segnumsorte use-index ordem
                      where segnumsorte.serie = tt-sorte.serie
                      no-lock no-error.
if avail segnumsorte
then do:
    message "Range com série " tt-sorte.serie "já existe".
    return.
end.    


vdtfvig = date(month(vdtsort), 1, year(vdtsort)) - 1.
vdtivig = date(month(vdtfvig), 1, year(vdtfvig)).


disp       
       vdtivig
       vdtfvig 
       with frame f-filtro.
        
sresp = no.
message "Processar importacao?" update sresp.
if sresp <> yes
then return.

/***
for each tt-sorte.
    create segnumsorte.
    assign
        segnumsorte.dtsorteio = vdtsort
        segnumsorte.serie     = tt-sorte.serie
        segnumsorte.nsorteio  = tt-sorte.numero
        segnumsorte.dtivig    = vdtivig
        segnumsorte.dtfvig    = vdtfvig
        segnumsorte.ordem     = vordem + tt-sorte.ordem /* #1 */.
    disp tt-sorte.serie tt-sorte.numero(count).
        pause 0.
end.
message "Registros importados" view-as alert-box.
***/
