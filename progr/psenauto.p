{admcab.i}

def output parameter p-ok as log.             
def var vsenauto as dec format ">>>>>>>>>9".
def var vsenaudi as dec format ">>>>>>>>>9" init 0.
def var vsen-ecom as integer.
def var vped as char.
def var senha-cal as dec init 0.
def var vmes as int.
def var vdtaux as date.

vsenauto = 0.

def var vmens as char.
def var vsen as int.
form vmens no-label format "x(30)"
    with frame fmens overlay
                   color message side-label
                   centered no-box.

form 
     vped label "Pedido"  skip
     vsen-ecom label "Senha "
with frame f-sen-ecom overlay centered row 6
               title " Senha para alteracao de endereco de entrega do pedido " side-label.
                                           
 
if sparam = ""
then do:
    update skip(1) space(2) 
       vsenauto label "Senha" blank
       skip(1)
       with frame fsenauto
                  overlay side-label title " Autorizacao do Supervisor " 
                  row 5 centered.

    /**((( setbcod * day(today) ) * month(today) ) + year(today) )**/

    if vsenauto <> ((( setbcod + day(today) ) + month(today)) 
                + int(substr(string(time,"HH:MM:SS"),1,2))
        + int(substr(string(time,"HH:MM:SS"),1,2))  )
    then p-ok = no.
    else p-ok = yes.
    hide frame fsenauto no-pause.

end.

 
if entry(1,sparam) = "pedecom"
then do:

    assign vped = string(entry(2,sparam)). 

    display
        vped skip
              with frame f-sen-ecom.
                    
    update 
       vsen-ecom blank
       with frame f-sen-ecom.

    /**((( setbcod * day(today) ) * month(today) ) + year(today) )**/

    if vsen-ecom <> integer(string(entry(2,sparam)))
                      + day(today)
                      + month(today) 
                      + integer(substr(string(time,"HH:MM:SS"),1,2))
    then p-ok = no.
    else p-ok = yes.
    hide frame fsen-ecom no-pause.

end.



if sparam = "auditoria"
then do:
    update skip(1) space(2) 
       vsenaudi label "Senha" blank
       skip(1)
       with frame fsenaudi
                  overlay side-label title " Autorizacao da Auditoria " 
                  row 10 centered.


    vmes = month(today).
    vdtaux = date(if vmes = 12 then 1 else month(today) + 1,01,
                    if vmes = 12 then year(today) + 1 else year(today)) - 1. 
     
    senha-cal = year(today) + month(today) +
                (day(vdtaux) - day(today)) + 
                + int(substr(string(time,"HH:MM:SS"),1,2)).

    if vsenaudi <> senha-cal            
    then do:
        p-ok = no.
        vmens = "Senha Invalida." .
            disp vmens with frame fmens.
            pause 1 no-message.
            hide frame fmens no-pause.
    end.
    else p-ok = yes.
    hide frame fsenaudi no-pause.
end.
if sparam = "assistencia"
then do:
    update skip(1) space(2) 
       vsenaudi label "Senha" blank
       skip(1)
       with frame fsenaudi
                  overlay side-label title " Autorizacao da Auditoria " 
                  row 10 centered.


    vmes = month(today).
    vdtaux = date(if vmes = 12 then 1 else month(today) + 1,01,
                    if vmes = 12 then year(today) + 1 else year(today)) - 1. 
     
    senha-cal = year(today) + month(today) +
                (day(vdtaux) - day(today)) /*+ 
                + int(substr(string(time,"HH:MM:SS"),1,2))*/.

    if vsenaudi <> senha-cal            
    then do:
        p-ok = no.
        vmens = "Senha Invalida." .
            disp vmens with frame fmens.
            pause 1 no-message.
            hide frame fmens no-pause.
    end.
    else p-ok = yes.
    hide frame fsenaudi no-pause.
end.

