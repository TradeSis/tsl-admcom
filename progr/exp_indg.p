{admcab.i}

def var vetb-1 like estab.etbcod.
def var vetb-2 like estab.etbcod.

def var v as char.

def var vdti as date.
def var vdtf as date.
DEF VAR VCATEGO AS CHAR.

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.


def temp-table tt-indg
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field numero like plani.numero
    field catcod like produ.catcod
    field hora   as int
    field valor  as dec
    field produtos as int
    field parcelas as int
    field catego as char
    index i1 etbcod pladat

    .
    
update vetb-1 at 1 label "Filial de"
    with frame f-1 1 down side-label width 80 .
    
if vetb-1 > 0
then update vetb-2 label "Ate"
       with frame f-1.

if vetb-1 > vetb-2
then undo.   

update vdti at 1 label "Periodo"
       vdtf no-label 
       with frame f-1.
       
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.

def var vprodutos as int.
def var vparcelas as int.
def var vdata as date.

for each estab no-lock:
    if vetb-1 > 0 and
        estab.etbcod >= vetb-1 and
        estab.etbcod <= vetb-2
    then.
    else next.

    disp estab.etbcod label "Filial" with frame f-disp 1 down
        row 10 color messa no-box centered.
    pause 0.
        
    do vdata = vdti to vdtf:
    disp vdata label "data" with frame f-disp.
    pause 0.
    for each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 5 and
                         plani.pladat = vdata
                         no-lock.
        vprodutos = 0.
        
        /*
        if plani.crecod <> 2
        then next.
        */
        
        disp plani.numero format ">>>>>>>>9" with frame f-disp.
        pause 0.
        
        vparcelas = 0.
        if plani.crecod = 2
        then do:
            find finan where finan.fincod = plani.pedcod no-lock no-error.
            if avail finan
            then vparcelas = finan.finnpc.
        end.

        
        vcatego = "".
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc and
                             movim.movdat = plani.pladat
                             no-lock.
            find produ where produ.procod = movim.procod no-lock.
            /*
            if produ.catcod = 31
            then vcatego = "MOVEIS".
            else if vcatego = "" 
            then vcatego = "CONFECCAO".
            vprodutos = vprodutos + movim.movqtm.
            */

            val_fin = 0.                    
            val_des = 0.   
            val_dev = 0.   
            val_acr = 0. 
                         
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then
                val_fin =  ((((movim.movpc * movim.movqtm) - 
                            val_dev - val_des) /
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des +
             val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
           
            find first tt-indg where
                       tt-indg.etbcod = plani.etbcod and
                       tt-indg.pladat = plani.pladat and
                       tt-indg.numero = plani.numero and
                       tt-indg.catcod = produ.catcod
                       no-lock no-error.
            if not avail tt-indg
            then do:
                create tt-indg.
                assign
                    tt-indg.etbcod = plani.etbcod
                    tt-indg.pladat = plani.pladat
                    tt-indg.numero = plani.numero
                    tt-indg.catcod = produ.catcod
                    tt-indg.hora   = plani.horincl
                    tt-indg.parcelas = vparcelas
                    .
                if produ.catcod = 31
                then tt-indg.catego = "MOVEIS".
                else tt-indg.catego = "CONFECCAO". 
            end.   
            tt-indg.valor  = tt-indg.valor + val_com.     
            tt-indg.produtos = tt-indg.produtos + movim.movqtm.
        end.
    end.
    end.
end.    

def var vvalor as char.
def var varquivo as char.

if opsys = "UNIX"
then varquivo = "/admcom/relat/expindg." + string(time).
else varquivo = "l:\relat\expindg." + string(time).

output to value(varquivo) page-size 0.
put "Filial;Data Venda;Hora Venda;Valor Venda;Qtd. Produtos;Qtd. Parcelas;Setor"
    skip.
for each tt-indg:
    vvalor = string(tt-indg.valor).
    if num-entries(vvalor,".") = 1
    then vvalor = vvalor + ".00".
    else if length(entry(2,vvalor,".")) = 1
    then vvalor = vvalor + "0".

    vvalor = replace(vvalor,".",";").
    vvalor = replace(vvalor,",",".").
    vvalor = replace(vvalor,";",",").

    if length(trim(vvalor)) < 15
    then vvalor = substr(string(v,"x(20)"),1,15 - length(trim(vvalor)))
                + trim(vvalor).
 
    put tt-indg.etbcod ";"
        tt-indg.pladat format "99/99/9999" ";"
        string(tt-indg.hora,"hh:mm:ss") ";"
        vvalor  format "x(15)" ";"
        tt-indg.produtos ";"
        tt-indg.parcelas ";"
        tt-indg.catego format "x(10)"
        skip.
end.
output close.
        
message color red/with
        "Arquivo gerado: " varquivo
        view-as alert-box.
        
    
