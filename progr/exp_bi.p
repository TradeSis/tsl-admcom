{admcab.i}

def var vok as log.
def buffer bmovim for movim.
def var qtd_tot like movim.movqtm.
def var val_mar like plani.platot.
def var per_com as dec.
def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.
def var cod_com as int.
def var cod_ren as int.
def var vidade as dec.
def var cod_fai as int.
def var vv as int.
def var ii as int.
def var vfincod as char.
def var tipo_vendedor as int format "9".
def var codati as int.
def var xx as int.
def stream stela.
def temp-table tt-renda
    field codren as int
    field renini as dec
    field renfin as dec.
    
def temp-table tt-faixa
    field codfai as int
    field faiini as int
    field faifin as int.
    
def temp-table tt-munic
    field munic as char
    field ufecod as char format "x(02)".


def temp-table tt-niv01
    field clasup like clase.clasup
    field clacod like clase.clacod
    field clanom like clase.clanom
    field catcod like produ.catcod.

def temp-table tt-niv02
    field clasup like clase.clasup
    field clacod like clase.clacod
    field clanom like clase.clanom 
    field catcod like produ.catcod.


def temp-table tt-niv03
    field clasup like clase.clasup
    field clacod like clase.clacod
    field clanom like clase.clanom 
    field catcod like produ.catcod.


def temp-table tt-niv04
    field clasup like clase.clasup
    field clacod like clase.clacod
    field clanom like clase.clanom 
    field catcod like produ.catcod. 
        





for each produ no-lock:
    if produ.catcod = 41 or
       produ.catcod = 31
    then.
    else next.
       
    for each clase where clase.clacod = produ.clacod no-lock:
        find first tt-niv04 where tt-niv04.clacod = clase.clacod no-error.
        if not avail tt-niv04
        then do:
            create tt-niv04. 
            assign tt-niv04.clasup = clase.clasup
                   tt-niv04.clacod = clase.clacod
                   tt-niv04.clanom = clase.clanom
                   tt-niv04.catcod = produ.catcod.
        end.
    end.
end.

for each tt-niv04:
    find clase where clase.clacod = tt-niv04.clasup 
                    no-lock no-error.
    if avail clase
    then do:
        find first tt-niv03 where tt-niv03.clacod = clase.clacod no-error.
        if not avail tt-niv03
        then do:
            create tt-niv03. 
            assign tt-niv03.clasup = clase.clasup
                   tt-niv03.clacod = clase.clacod
                   tt-niv03.clanom = clase.clanom
                   tt-niv03.catcod = tt-niv04.catcod.
        end.
    end.
end.                    




for each tt-niv03:
    find clase where clase.clacod = tt-niv03.clasup 
                    no-lock no-error.
    if avail clase
    then do:
        find first tt-niv02 where tt-niv02.clacod = clase.clacod no-error.
        if not avail tt-niv02
        then do:
            create tt-niv02. 
            assign tt-niv02.clasup = clase.clasup
                   tt-niv02.clacod = clase.clacod
                   tt-niv02.clanom = clase.clanom
                   tt-niv02.catcod = tt-niv03.catcod.
        end.
    end.
end.                    
 


for each tt-niv02:
    find clase where clase.clacod = tt-niv02.clasup 
                    no-lock no-error.
    if avail clase
    then do:
        find first tt-niv01 where tt-niv02.clacod = clase.clacod no-error.
        if not avail tt-niv01
        then do:
            create tt-niv01. 
            assign tt-niv01.clasup = clase.clasup
                   tt-niv01.clacod = clase.clacod
                   tt-niv01.clanom = clase.clanom
                   tt-niv01.catcod = tt-niv02.catcod.
        end.
    end.
end.                    
 


output stream stela to terminal.
output to /admcom/ecs/bi_departamentoproduto.txt.
for each tt-niv01:
    
    put tt-niv01.catcod format "99" "|"
        tt-niv01.clacod format "9999" "|"
        tt-niv01.clanom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_grupoproduto.txt.
for each tt-niv02:
    
    put tt-niv02.clasup format "9999" "|"
        tt-niv02.clacod format "9999" "|"
        tt-niv02.clanom format "x(50)"  chr(13) + chr(10).
        
end. 
output close.
output stream stela close.

output stream stela to terminal.
output to /admcom/ecs/bi_classeproduto.txt.
for each tt-niv03:
    
    put tt-niv03.clasup format "9999" "|"
        tt-niv03.clacod format "9999" "|"
        tt-niv03.clanom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.

output stream stela to terminal.
output to /admcom/ecs/bi_subclasseproduto.txt.
for each tt-niv04:
    
    put tt-niv04.clasup format "9999" "|"
        tt-niv04.clacod format "9999" "|"
        tt-niv04.clanom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.




output stream stela to terminal.
output to /admcom/ecs/bi_empresa.txt.
for each empre no-lock:
    
    put empre.empcod format "99" "|"
        empre.emprazsoc format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_departamento.txt.
for each categoria no-lock:
    

    if categoria.catcod = 31 or
       categoria.catcod = 41
    then. 
    else next.
       
    put categoria.catcod "|"
        categoria.catnom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.

output stream stela to terminal.
output to /admcom/ecs/bi_setorproduto.txt.
for each categoria no-lock:
    

    if categoria.catcod = 31 or
       categoria.catcod = 41
    then. 
    else next.
       
    put categoria.catcod "|"
        categoria.catnom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.



output stream stela to terminal.
output to /admcom/ecs/bi_itemproduto.txt.
for each produ no-lock by produ.procod:
    

    if produ.catcod = 31 or
       produ.catcod = 41
    then. 
    else next.

    find last movim where movim.procod  = produ.procod
                      and movim.movdat >= 01/01/2005 no-lock no-error.
    if not avail movim
    then do:
        find first estoq where estoq.procod = produ.procod
                           and estoq.estatual > 0  no-lock no-error.
        if not avail estoq
        then next.
    end.
    
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase
    then next.
       
    put produ.clacod "|"
        produ.procod "|"
        produ.pronom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.



output to /admcom/ecs/bi_faixaetaria.txt.
/***** anterior
do ii = 1 to 20:
        
    if ii < 20
    then do:
        put ii "|"
            ((ii * 5) - 4) format ">9" " ate "
            (ii * 5) format ">9" " anos" chr(13) + chr(10).
        
        find first tt-faixa where tt-faixa.codfai = ii no-error.
        if not avail tt-faixa 
        then do: 
            create tt-faixa. 
            assign tt-faixa.codfai = ii 
                   tt-faixa.faiini = ((ii * 5) - 4)   
                   tt-faixa.faifin = (ii * 5).
        end.           
    
    end.    
    else do:
        put "20|acima de 96 anos" chr(13) + chr(10).
        
        find first tt-faixa where tt-faixa.codfai = ii no-error.
        if not avail tt-faixa
        then do:
            create tt-faixa.
            assign tt-faixa.codfai = 20
                   tt-faixa.faiini = 96  
                   tt-faixa.faifin = 10000.
        end.           
    end.

end.
***/
do ii = 1 to 21:
        
    if ii < 21
    then do:
         put ii "|"
             ((ii * 5) - 5) format ">9" " ate "
             ((ii * 5) - 1) format ">9" " anos" chr(13) + chr(10).
        
        find first tt-faixa where tt-faixa.codfai = ii no-error.
        if not avail tt-faixa 
        then do: 
            create tt-faixa. 
            assign tt-faixa.codfai = ii 
                   tt-faixa.faiini = ((ii * 5) - 5)
                   tt-faixa.faifin = ((ii * 5) - 1).
        end.           
    
    end.    
    else do:
        put "21|acima de 100 anos" chr(13) + chr(10).
        
        find first tt-faixa where tt-faixa.codfai = ii no-error.
        if not avail tt-faixa
        then do:
            create tt-faixa.
            assign tt-faixa.codfai = 21
                   tt-faixa.faiini = 100
                   tt-faixa.faifin = 10000.
        end.           
    end.

end.


output close.

ii = 0.
vv = 0.



output to /admcom/ecs/bi_rendafamiliar.txt.
/***
do ii = 0 to 2000 by 100:


    vv = vv + 1.
    if vv > 20
    then leave.
    
    put vv "|"
        ii format ">>>9" " ate "
        (ii + 100) format ">>>9" " reais" chr(13) + chr(10).
        

    find first tt-renda where tt-renda.codren = vv no-error.
    if not avail tt-renda
    then do:
        create tt-renda.
        assign tt-renda.codren = vv
               tt-renda.renini = ii
               tt-renda.renfin = ii + 100.
    end.
        
end.
    
put 21 "|acima de 2000 reais" chr(13) + chr(10). 
create tt-renda. 
assign tt-renda.codren = 21 
       tt-renda.renini = 2000
       tt-renda.renfin = 100000.
***/

do ii = 0 to 2000 by 100:


    vv = vv + 1.
    if vv > 20
    then leave.
    
    put vv "|"
        ii format ">,>>9.99" " ate "
        ((ii + 100) - 0.01) format ">,>>9.99" " reais" chr(13) + chr(10).
        

    find first tt-renda where tt-renda.codren = vv no-error.
    if not avail tt-renda
    then do:
        create tt-renda.
        assign tt-renda.codren = vv
               tt-renda.renini = ii
               tt-renda.renfin = ((ii + 100) - 0.01).
    end.
        
end.
    
put 21 "|acima de 2000 reais" chr(13) + chr(10). 
create tt-renda. 
assign tt-renda.codren = 21 
       tt-renda.renini = 2000
       tt-renda.renfin = 100000.


output close.






output stream stela to terminal.
output to /admcom/ecs/bi_fornecedor.txt.
for each forne no-lock by forne.forcod:
    
    find first produ where produ.fabcod = forne.forcod 
         use-index iprofab no-lock no-error.
         
    if not avail produ
    then next. 
       
    put forne.forcod "|"
        forne.fornom format "x(50)"  chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.







output stream stela to terminal.
output to /admcom/ecs/bi_formapagamento.txt.

    put "1|A VISTA" chr(13) + chr(10)
        "2|A PRAZO" chr(13) + chr(10) 
        "3|CREDIARIO" chr(13) + chr(10).
        
        
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_tipopagamento.txt.


    put "1|1001|DINHEIRO" chr(13) + chr(10)
        "1|1002|CARTAO DE DEBITO" chr(13) + chr(10) 
        "2|2001|CARTAO DE CREDITO" chr(13) + chr(10).
           
    for each finan no-lock by finan.fincod:
           
        if finan.fincod <= 1
        then next.
               
           
        put "3|3" 
            finan.fincod format "999" "|"
            finan.finnom format "x(50)" chr(13) + chr(10).
            
    end.    
        
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_vendedor.txt.



    for each estab no-lock:
    
        for each func where func.etbcod = estab.etbcod no-lock:
        
            
           if func.usercod = ""  
           then next.
        
 
            
           put estab.etbcod format "99"
               func.funcod  format "999" "|"
               func.funnom format "x(50)"  chr(13) + chr(10).
               
        end.
    end.        
    
output close.
output stream stela close.




output stream stela to terminal.
output to /admcom/ecs/bi_tipovendedor.txt.
    
    put "1|CONFECCAO" chr(13) + chr(10)
        "2|MOVEIS" chr(13) + chr(10).
        
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_vendedortipo.txt.



    for each estab no-lock:
    
        for each func where func.etbcod = estab.etbcod no-lock:
        
            
           if func.usercod = ""  
           then next.
        
           if substring(func.usercod,7,1) = "1"
           then tipo_vendedor = 1.
           else tipo_vendedor = 2.
            
           put tipo_vendedor "|"
               estab.etbcod format "99"
               func.funcod  format "999" "|"
               func.funnom format "x(50)"  chr(13) + chr(10).
   
        end.
    end.        
    
output close.
output stream stela close.




output stream stela to terminal.
output to /admcom/ecs/bi_atividade.txt.
    
    put "1|FILIAL" chr(13) + chr(10)
        "2|FABRICA" chr(13) + chr(10) 
        "3|DEPOSITO" chr(13) + chr(10).
        
output close.
output stream stela close.


output stream stela to terminal.
output to /admcom/ecs/bi_comissao.txt.
    
    put "1|A VISTA CONFECCAO" chr(13) + chr(10)
        "2|COM ENTRADA CONFECCAO" chr(13) + chr(10) 
        "3|SEM ENTRADA CONFECCAO" chr(13) + chr(10) 
        "4|A VISTA MOVEIS" chr(13) + chr(10)
        "5|COM ENTRADA MOVEIS" chr(13) + chr(10)
        "6|SEM ENTRADA MOVEIS" chr(13) + chr(10).
        
output close.
output stream stela close.
  
 
 
 


output stream stela to terminal.
output to /admcom/ecs/bi_filial.txt.
for each estab no-lock:

    if estab.etbcod >= 100
    then next.
    
    codati = 1.
    if estab.etbcod = 22
    then codati = 2.

    if estab.etbcod > 900 or
     {conv_igual.i estab.etbcod}
    then codati = 3.
    
    
    
    put codati format ">9" "|"
        estab.etbcod "|" 
        estab.etbnom format "x(50)" chr(13) + chr(10).
        
        
end. 
output close.
output stream stela close.




output stream stela to terminal.
output to /admcom/ecs/bi_fato_estoqueatual.txt.


    for each produ no-lock by produ.procod:
        
        if produ.catcod = 41 or
           produ.catcod = 31
        then. 
        else next.
        
        find last movim where movim.procod  = produ.procod
                          and movim.movdat >= 01/01/2005 no-lock no-error.
        if not avail movim
        then do:
            find first estoq where estoq.procod = produ.procod
                               and estoq.estatual > 0  no-lock no-error.
            if not avail estoq
            then next.
        end.
    
        find clase where clase.clacod = produ.clacod no-lock no-error.
        if not avail clase
        then next.
        
        for each estab where estab.etbcod < 100 no-lock:
        
        
            find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = produ.procod
                                        no-lock no-error.
            if not avail estoq
            then next.
            
            put "19|"
                estab.etbcod "|"
                produ.catcod "|"
                produ.procod "|"
                produ.fabcod "|"
                estoq.estatual format "->>>>>9" "|"
                estoq.estcusto format "->>>,>>9.99" "|"
                estoq.estvenda format "->>>,>>9.99" chr(13) + chr(10).
        end.
        
        display stream stela produ.procod label "Estoque"
            with frame f1 side-label centered 1 down.
        pause 0.        
    end.
        
output close.
output stream stela close.
 

 
xx = 0.
vv = 0.
                  
output stream stela to terminal.
output to /admcom/ecs/bi_cliente.txt.
for each clien no-lock by clien.clicod:

    if clien.clinom = ""
    then next.
 
    if length(clien.clinom) <= 3
    then next.
    
    

    vok = yes.
    do vv = 1 to 100:
       if substring(clien.clinom,vv,1) = "0" or
          substring(clien.clinom,vv,1) = "1" or
          substring(clien.clinom,vv,1) = "2" or
          substring(clien.clinom,vv,1) = "3" or
          substring(clien.clinom,vv,1) = "4" or
          substring(clien.clinom,vv,1) = "5" or
          substring(clien.clinom,vv,1) = "6" or
          substring(clien.clinom,vv,1) = "7" or
          substring(clien.clinom,vv,1) = "8" or
          substring(clien.clinom,vv,1) = "9" or
          substring(clien.clinom,vv,1) = "*" or
          substring(clien.clinom,vv,1) = "." or
          substring(clien.clinom,vv,1) = "-" or
          substring(clien.clinom,vv,1) = ";" 
       then vok = no.
    end.
    if vok = no
    then next.
    

    

    xx = xx + 1.
    
    if xx mod 10000 = 0
    then display stream stela xx label "Clientes"
            with frame f2 side-label centered 1 down.
    pause 0.
    
    put clien.clicod format ">>>>>>>>>>>9" "|"
        clien.clinom format "x(50)"  chr(13) + chr(10).
                

    find first tt-munic where tt-munic.munic = clien.cidade[1] no-error.
    if not avail tt-munic
    then do:
        create tt-munic. 
        assign tt-munic.munic = clien.cidade[1]
               tt-munic.ufecod = clien.ufecod[1].
    end.
                
            
end. 
output close.
output stream stela close.

                  
output to /admcom/ecs/bi_municipio.txt.

/*
for each tt-munic by tt-munic.munic:
      
    put tt-munic.munic format "x(50)"
        tt-munic.ufecod chr(13) + chr(10).
       
       
end.
*/
    put "MUNICIPIO" format "x(50)"
        "RS" chr(13) + chr(10).

output close.


xx = 0.
                  
                  
output stream stela to terminal. 
output to /admcom/ecs/bi_fato_movimento.txt.
for each produ no-lock,
    each movim use-index datsai
         where movim.procod = produ.procod and
               movim.movtdc = 05           and
               movim.movdat >= 01/01/2005  and
               movim.movdat <= 08/29/2005 no-lock:
      
    find fabri where fabri.fabcod = produ.fabcod no-lock no-error.
    if not avail fabri
    then next.
    
    find clien where clien.clicod = movim.desti no-lock no-error.
    if not avail clien
    then next.
    
    find estoq where estoq.etbcod = movim.etbcod and
                     estoq.procod = movim.procod no-lock no-error.
    if not avail estoq
    then next.
    
    /*
    find first tt-munic where tt-munic.munic = clien.cidade[1] no-error.
    if not avail tt-munic
    then next.
    */
    
    if produ.catcod = 41 or
       produ.catcod = 31
    then.
    else next.
    

    find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat no-lock no-error.
                           
    if not avail plani
    then next.
    
    
    cod_com = 0.
    if produ.catcod = 41
    then do:
        if plani.pedcod = 0
        then assign cod_com = 1
                    per_com = 0.03.
        else do:
            find finan where finan.fincod = plani.pedcod no-lock no-error.
            if avail finan
            then do:
                if finan.finent 
                then assign cod_com = 2
                            per_com = 0.03.
                else assign cod_com = 3
                            per_com = 0.02.
            end.
        end.
    end.
    else do:
        if plani.pedcod = 0
        then cod_com = 4.
        else do:
            find finan where finan.fincod = plani.pedcod no-lock no-error.
            if avail finan
            then do:
                if finan.finent 
                then cod_com = 5.
                else cod_com = 6.
            end.
        end.
        per_com = 0.013.
    end.
    if plani.crecod = 1
    then vfincod = "1001".
    else vfincod = "3" + string(plani.pedcod,"999").
    


    if clien.dtnas = ? or
       clien.dtnas > today 
    then vidade = 1.
    else vidade = int(((today - clien.dtnas) / 365) - 0.50).

    find first tt-faixa where tt-faixa.faiini >= vidade and
                              tt-faixa.faiini <= vidade no-error.
    if not avail tt-faixa
    then cod_fai = 1.
    else cod_fai = tt-faixa.codfai.
                              
                              
    find first tt-renda where tt-renda.renini >= clien.prorenda[1] and
                              tt-renda.renfin <= clien.prorenda[1] no-error.
    if not avail tt-renda
    then cod_ren = 1.
    else cod_ren = tt-renda.codren.
    
                             
    val_fin = 0.                  
    val_des = 0. 
    val_dev = 0. 
    val_acr = 0. 
                         
    val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * plani.acfprod.
    val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * plani.descprod.
    val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * plani.vlserv.
    
    if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
    then
    val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des) /
                (plani.platot - plani.vlserv - plani.descprod))
                * plani.biss) - ((movim.movpc * movim.movqtm) - 
                val_dev - val_des).

                             
    val_fin = val_fin / movim.movqtm.
    val_des = val_des / movim.movqtm.
    val_dev = val_dev / movim.movqtm. 
    val_acr = val_acr / movim.movqtm. 
    
   
    
    
    
    val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + val_acr + 
              val_fin. 
    val_com = (val_com * per_com) / movim.movqtm.
        
    val_mar = (((estoq.estvenda / estoq.estcusto) - 1) * 100).
    
    
    qtd_tot = 0.
    
    for each bmovim where bmovim.etbcod = plani.etbcod and
                          bmovim.placod = plani.placod and
                          bmovim.movtdc = plani.movtdc and
                          bmovim.movdat = plani.pladat no-lock:
                          
        qtd_tot = qtd_tot + movim.movqtm.
                           
    end.                                    
       

    put "19" "|"
        "MUNICIPIO"  format "x(50)" "|"
        movim.etbcod format "99" "|"
        produ.catcod format "99" "|" 
        plani.etbcod format "99"
        plani.vencod format "999" "|"
        movim.procod "|" 
        vfincod      format "9999" "|" 
        clien.clicod format ">>>>>>>>>>>9" "|"
        cod_fai format ">9" "|"
        cod_ren format ">9" "|" 
        fabri.fabcod "|"
        cod_com "|"
        plani.pladat   format "99/99/9999" "|"
        estoq.estcusto format "->>>>>9.99" "|"
        movim.movpc    format "->>>>>9.99" "|"
        val_acr        format "->>>>>9.99" "|"
        val_des        format "->>>>>9.99" "|"
        val_dev        format "->>>>>9.99" "|" 
        val_com        format "->>>>>9.99" "|" 
        movim.movqtm   format "->>>>>9.99" "|"
        val_mar        format "->>>>>9.99" "|"
        val_fin        format "->>>>>9.99" "|"
        plani.numero   format ">>>>>>>9"   "|"
        qtd_tot        format ">>>>>>9.99" "|"
        plani.biss     format "->>>>>>9.99" "|"
        (plani.platot - plani.descprod - plani.vlserv) format "->>>>>>9.99" 
            chr(13) + chr(10).
       
    xx = xx + 1.
    
    if xx mod 1000 = 0
    then display stream stela xx label "Movimento"
            with frame f3 side-label centered 1 down.
    pause 0.
       
end.
output close.
output stream stela close.




