/*****************************************************
* Movimentação Geral Estoque
* Resumo de Movimentos por Classe via Geracao Cron
*
* Autor: Antonio 
* Data : 01/06/2009
******************************************************/

{admcab-batch.i}
def output parameter varqsai as char.

/*
{admcab.i new}
def var varqsai as char.
*/


def var vclase-cron as int extent 16 format ">>9" initial
[220,230,260,270,274,1000,1257,1384,1456,1457,1465,1487,1523,1530,1535,1542].

def var v-cod-aux   as  char format "x(12)". 
def var v-vaux1     as  dec.
def var v-vaux2     as  dec.
def var vnivel      as int.
def var j           as int.
def var k           as int.
def var v-aux       as char format "x(17)". 
def var v-anomes    as char extent 6.
def var vdata       as date.
def var vdataux2    as date.
def var vkday       as int no-undo.
def var vkmes       as int no-undo.
def var vkyear      as int no-undo.
def var vetccod     as char format "x(03)".
def var vforcod  like forne.forcod.
def var vmes2    as int format ">9".
def var vano2    as int format "99".
def var vimp     as log format "Sim/Nao" initial no.
def var vmes     as int format ">9".
def var vetbcod  like estab.etbcod.
def var vclacod  like clase.clacod.
def var vcarcod  like caract.carcod.
def var vsubcod  like subcaract.subcod.
def var vdti     like pedid.peddat.
def var vdtf     like pedid.peddat.
def var varquivo as char.
def var vacum1 as dec extent 6.
def var vacum2 as dec extent 6.
def var v-clacod like clase.clacod. 
def var v-compra-01 as dec format "->,>>>,>>9.99". 
def var v-aberto-01 as dec format "->,>>>,>>9.99".
def var v-compra-02 as dec format "->,>>>,>>9.99". 
def var v-aberto-02 as dec format "->,>>>,>>9.99".
def var v-compra-03 as dec format "->,>>>,>>9.99". 
def var v-aberto-03 as dec format "->,>>>,>>9.99".
def var v-compra-04 as dec format "->,>>>,>>9.99". 
def var v-aberto-04 as dec format "->,>>>,>>9.99".
def var v-compra-05 as dec format "->,>>>,>>9.99". 
def var v-aberto-05 as dec format "->,>>>,>>9.99".
def var v-compra-06 as dec format "->,>>>,>>9.99". 
def var v-aberto-06 as dec format "->,>>>,>>9.99".

def temp-table tt-clase
    field clacod like clase.clacod
    field clasup like clase.clacod
    field nivel  as   int
    field clanom like clase.clanom
    field wvalor  as dec extent 6
    field wabe    as dec extent 6
    index iclase  clacod
    index iclasup clasup
                  clacod.

def temp-table tt-clase-esp
    field clacod   like clase.clacod
    field clacod_1 like clase.clacod
    field clacod_2 like clase.clacod
    field clacod_3 like clase.clacod
    field clacod_4 like clase.clacod
    field clanom   like clase.clanom
    field clasup   like clase.clacod
    field supnom   like clase.clanom
    field seq      as int   
    field nivel    as int
    field wvalor   like pedid.pedtot format "->,>>>,>>9.99" extent 6
    field wabe     like pedid.pedtot format "->,>>>,>>9.99" extent 6
    index seq    seq  
    index iclase clacod
    index sclase nivel
                 clacod
    index relato clacod_1
                 clacod_2
                 clacod_3
                 clacod_4.

def buffer btt-clase for tt-clase.
def buffer ctt-clase for tt-clase.
def buffer dtt-clase for tt-clase.
def buffer ett-clase for tt-clase.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def var wacumabe as dec extent 6.
def var vacum    like pedid.pedtot extent 6.
def var vano as int format "99".

form v-cod-aux          column-label "Cod"          format "x(12)"
     tt-clase-esp.clanom    column-label "Setor/Classe" format "x(35)"
     v-compra-01 at 50
     v-compra-02
     v-compra-03
     v-compra-04
     v-compra-05
     v-compra-06 skip
     v-aberto-01 at 50
     v-aberto-02 
     v-aberto-03 
     v-aberto-04 
     v-aberto-05 
     v-aberto-06
with frame fdisp width 145 down.


repeat:

    for each tt-clase.
        delete tt-clase.
    end.
    
    assign  vetbcod = 996 /* Dep. Confeccoes */
            vforcod = 0 
            vclacod = 0 
            vetccod = "G" 
            vcarcod = 0
            vsubcod = 0
            vdti    =  today.

    assign vdti = date(month(vdti), 1, year(vdti)) 
       vkday  = 1
       vkyear = int(year(vdti))
       vkmes  = int(month(vdti)) + 6.
    if vkmes > 12 then assign  vkyear = vkyear + 1
                           vkmes  = vkmes - 12.
    assign vdtf = date(vkmes, vkday, vkyear) - 1. 
        
    /* Setor de Confeccoes */
    find first setor where setor.setcod = 41 no-lock no-error.
    find first tt-clase-esp where tt-clase-esp.clacod = 41 and 
                                tt-clase-esp.nivel = 0 no-error.
    if not avail tt-clase-esp then do:
        create tt-clase-esp.
        assign tt-clase-esp.clacod = 41
           tt-clase-esp.clanom = setor.setnom
           tt-clase-esp.nivel  = 0
           tt-clase-esp.seq = 0.
    end.
    /* Grupos Especificos */
    do j = 1 to 16:
        assign vclacod = vclase-cron[j].
        find clase where clase.clacod = vclacod no-lock.
        if avail clase 
        then do:
            create tt-clase-esp. 
            assign tt-clase-esp.clasup = setor.setcod
                   tt-clase-esp.supnom = setor.setnom
                   tt-clase-esp.clacod = clase.clacod
                   tt-clase-esp.clanom = clase.clanom
                   tt-clase-esp.seq    = j.
        end.
    end.

    assign j = 0.
    do j = 1 to 6:
        v-anomes[j] = "".
    end.

    do vdata = vdti to vdtf :
           if v-anomes[1] = "" 
           then assign v-anomes[1] = string(month(vdata),"99") + "/" +
                                string(year(vdata)). 
           else
           if v-anomes[2] = ""   
           then assign v-anomes[2] = string(month(vdata),"99") + "/" +
                                     string(year(vdata)).
           else
           if v-anomes[3] = "" 
           then assign v-anomes[3] = string(month(vdata),"99") + "/" +
                                     string(year(vdata)).
           else
           if v-anomes[4] = "" 
           then assign v-anomes[4] = string(month(vdata),"99") + "/" +
                                     string(year(vdata)).
           else
           if v-anomes[5] = ""  
           then assign v-anomes[5] = string(month(vdata),"99") + "/" +
                                     string(year(vdata)).
           else
           if v-anomes[6] = "" 
           then assign v-anomes[6] = string(month(vdata),"99") + "/" +
                                     string(year(vdata)).
           vdataux2 = vdata.
           do j = 1 to 31:
              assign vdataux2 = vdataux2 + 1.
              if month(vdataux2) = month(vdata) then next.
              vdata = vdataux2.
              leave.
           end.
           next.
     end.
     
    for each tt-clase-esp:
        do j = 1 to 6:
            assign tt-clase-esp.wvalor[j]   = 0
                   tt-clase-esp.wabe[j]     = 0.
        end.
    end.
    do j= 1 to 6:
        assign v-anomes[j] = substr(v-anomes[j],1,3)  +  
                             substr(v-anomes[j],6,2).
    end.
    leave. 

end.

assign v-clacod = 0.


run Pi-cria-tt-clase.


/* Processamento de todas as Clases */

for each pedid where pedid.pedtdc = 1       and
                     pedid.etbcod = vetbcod and  /* Confeccoes */
                     pedid.peddti >= vdti   and
                     pedid.peddti <= vdtf  no-lock:
        
            
            for each liped of pedid no-lock.

                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
        

                find first tt-clase where tt-clase.clacod = produ.clacod 
                           no-lock no-error.
                if not avail tt-clase 
                then next.

                 /* Acha Selecao */
                find first tt-clase-esp  /* 4 */
                    where tt-clase-esp.clacod = clase.clacod no-error.
                assign vnivel = 4.
                if not avail tt-clase-esp
                then do:
                  find first bclase where 
                          bclase.clacod = tt-clase.clasup  no-error.
                  find first tt-clase-esp  /* 3 */
                      where tt-clase-esp.clacod = bclase.clacod no-error.
                  assign vnivel = 3.    
                  if not avail tt-clase-esp
                  then do:
                    find first cclase where 
                        cclase.clacod = bclase.clasup  no-error.
                    find first tt-clase-esp  /* 2 */
                        where tt-clase-esp.clacod = cclase.clacod no-error.
                    assign vnivel = 2.
                    if not avail tt-clase-esp
                    then do:
                      find first dclase where  /* 1 */
                         dclase.clacod = cclase.clasup  no-error.
                      find first tt-clase-esp 
                         where tt-clase-esp.clacod = dclase.clacod no-error.
                    end.
                  end.
                end.
                if not avail tt-clase-esp then next.
                 
                /****************************
                message " tem " tt-clase.clacod tt-clase.clanom skip 
                                tt-clase-esp.clacod tt-clase-esp.clanom
                                view-as alert-box.
                **************************/
                
                if vetccod <> "G" 
                then if produ.etccod <> int(vetccod)
                     then next.
                     
                if vforcod <> 0
                then if produ.fabcod <> vforcod
                     then next.
               
                if vcarcod = 0 and 
                   vsubcod = 0
                then.
                else do:
                    if vsubcod <> 0
                    then do:
                        find procaract where 
                             procaract.procod = produ.procod and
                             procaract.subcod = vsubcod      no-lock no-error.
                        if not avail procaract
                        then next.
                    end.   
                    else do:
                        find caract where caract.carcod = vcarcod no-lock.
                        for each subcaract where
                                 subcaract.carcod = caract.carcod no-lock:
                             find procaract where 
                                  procaract.procod = produ.procod and
                                  procaract.subcod = subcaract.subcod 
                                    no-lock no-error.
                             if not avail procaract
                             then next.
                        end.
                    end.
                end.

                do j = 1 to 6:
                    if substring(string(pedid.peddti),4,5) <> v-anomes[j]
                    then next.
                    assign k = j.
                    leave. 
                end.
                
                assign tt-clase-esp.wvalor[k] = tt-clase-esp.wvalor[k] +
                (liped.lipqtd * liped.lippreco) -
                (liped.lipqtd * liped.lippreco * (pedid.nfdes / 100))
                       tt-clase-esp.wabe[k] = tt-clase-esp.wabe[k] +
                ((liped.lipqtd - liped.lipent) * liped.lippreco) -
                ((liped.lipqtd - liped.lipent) * liped.lippreco * 
                (pedid.nfdes / 100))
                 tt-clase-esp.nivel = vnivel.
 
                find first tt-clase-esp where tt-clase-esp.clacod = 41
                     no-error.
                assign tt-clase-esp.wvalor[k] = tt-clase-esp.wvalor[k] +
                (liped.lipqtd * liped.lippreco) -
                (liped.lipqtd * liped.lippreco * (pedid.nfdes / 100))
                       tt-clase-esp.wabe[k] = tt-clase-esp.wabe[k] +
                ((liped.lipqtd - liped.lipent) * liped.lippreco) -
                ((liped.lipqtd - liped.lipent) * liped.lippreco * 
                (pedid.nfdes / 100))
                       tt-clase-esp.nivel = 0.
                
            end.
end.
  

    /* Troca-Label */
    
    assign v-aux = "Compra " + v-anomes[1].
    run pi-troca-label(input v-compra-01:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[1].
    run pi-troca-label(input v-aberto-01:handle, input v-aux).

    assign v-aux = "Compra " + v-anomes[2].
    run pi-troca-label(input v-compra-02:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[2].
    run pi-troca-label(input v-aberto-02:handle, input v-aux).

    assign v-aux = "Compra " + v-anomes[3].
    run pi-troca-label(input v-compra-03:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[3].
    run pi-troca-label(input v-aberto-03:handle, input v-aux).

    assign v-aux = "Compra " + v-anomes[4].
    run pi-troca-label(input v-compra-04:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[4].
    run pi-troca-label(input v-aberto-04:handle, input v-aux).

    assign v-aux = "Compra " + v-anomes[5].
    run pi-troca-label(input v-compra-05:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[5].
    run pi-troca-label(input v-aberto-05:handle, input v-aux).

    assign v-aux = "Compra " + v-anomes[6].
    run pi-troca-label(input v-compra-06:handle, input v-aux).
    assign v-aux = "Aberto " + v-anomes[6].
    run pi-troca-label(input v-aberto-06:handle, input v-aux).

/*****
/* Somente registros com valor */
for each tt-clase:
    assign  v-vaux1 = 0
            v-vaux2 = 0.
    do j = 1 to 6:
        assign v-vaux1 = v-vaux1 + tt-clase.wvalor[j]
               v-vaux2 = v-vaux2 + tt-clase.wabe[j].
    end.
    if (v-vaux1 + v-vaux2) = 0 then delete tt-clase.

end.
*****/

assign vacum[1] = 0 wacumabe[1] = 0
       vacum[2] = 0 wacumabe[2] = 0
       vacum[3] = 0 wacumabe[3] = 0
       vacum[4] = 0 wacumabe[4] = 0
       vacum[5] = 0 wacumabe[5] = 0
       vacum[6] = 0 wacumabe[6] = 0.


for each tt-clase-esp where tt-clase-esp.nivel <> 0:
     do j = 1 to 6:
        assign vacum[j] = vacum[j] + tt-clase-esp.wvalor[j]
               wacumabe[j] = wacumabe[j] + tt-clase-esp.wabe[j].
     end.
end.


varquivo = "/admcom/relat-auto/" + string(day(today),"99") + "-" + 
                                   string(month(today),"99") + "-" + 
                                   string(year(today),"9999") +
                        "/rped1cron-" + string(day(today),"99") +  
                                   string(month(today),"99") + 
                                   string(year(today),"9999") +
                            "." + string(time).

/**********************************************************************
varqsai = "/admcom/custom/desenv/antonio" +
                        "/rped1cron-" + string(day(today),"99") +  
                                   string(month(today),"99") + 
                                   string(year(today),"9999") +
                             "." + string(time).
***********************************************************************/


{mdad.i
 &Saida     = "value(varquivo)"
 &Page-Size = "64"
 &Cond-Var  = "145"
 &Page-Line = "66"
 &Nom-Rel   = ""relcpg-cron""
 &Nom-Sis   = """SISTEMA ESTOQUE"""
 &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL "" +
              string(vetbcod) + "" - PERIODO DE "" +
              string(vdti) + "" A "" + string(vdtf)"
 &Width     = "145"
 &Form      = "frame f-cabcab"}

 assign vacum[1] = 0 wacumabe[1] = 0
        vacum[2] = 0 wacumabe[2] = 0
        vacum[3] = 0 wacumabe[3] = 0
        vacum[4] = 0 wacumabe[4] = 0
        vacum[5] = 0 wacumabe[5] = 0
        vacum[6] = 0 wacumabe[6] = 0.


for each tt-clase-esp use-index seq: 

    v-cod-aux = string(tt-clase-esp.clacod).
    assign
      v-compra-01 = tt-clase-esp.wvalor[1]    
      v-aberto-01 = tt-clase-esp.wabe[1]   
      v-compra-02 = tt-clase-esp.wvalor[2]    
      v-aberto-02 = tt-clase-esp.wabe[2]   
      v-compra-03 = tt-clase-esp.wvalor[3]    
      v-aberto-03 = tt-clase-esp.wabe[3]   
      v-compra-04 = tt-clase-esp.wvalor[4]    
      v-aberto-04 = tt-clase-esp.wabe[4]  
      v-compra-05 = tt-clase-esp.wvalor[5]    
      v-aberto-05 = tt-clase-esp.wabe[5]   
      v-compra-06 = tt-clase-esp.wvalor[6]    
      v-aberto-06 = tt-clase-esp.wabe[6].   

    down with frame fdisp.
    disp  v-cod-aux          column-label "Cod"
          tt-clase-esp.clanom    column-label "Setor/Classe"
          v-compra-01 at 50
          v-compra-02
          v-compra-03
          v-compra-04
          v-compra-05
          v-compra-06 skip
          v-aberto-01 at 50
          v-aberto-02 
          v-aberto-03 
          v-aberto-04 
          v-aberto-05
          v-aberto-06 
         with frame fdisp width 145 down.

end.

output close.
varqsai = varquivo.
leave.

procedure Pi-troca-label.       
 
def input parameter  par-handle as handle.
def input parameter par-label  as char.
                                                             
if par-label = "NO-LABEL"                           
then par-handle:label    = ?.                       
else par-handle:label    = "  " + par-label.               
                                                         
end procedure.    

procedure Pi-cria-tt-clase.

def var vnivel as int.
assign vclacod = 0 .
 
 for each clase where clase.clasup = vclacod no-lock:
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod
              tt-clase.clanom = clase.clanom
              tt-clase.clasup = vclacod.
     end.
     for each bclase where bclase.clasup = clase.clacod no-lock: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom
                    tt-clase.clasup = clase.clacod .
           end.
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom
                        tt-clase.clasup = bclase.clacod.
               end.                          
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom
                            tt-clase.clasup = cclase.clacod.
                   end.       
               end.
           end.                                  
     end.
 end.
end procedure.

