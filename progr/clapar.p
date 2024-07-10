/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/clapar.p               Participacao nas Vendas por  Classe  */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{cab.i}
define temp-table wclasse
       field wclacod  like clase.clacod
       field wclanome like clase.clanome
       field wclaval  as   decimal  format ">>>,>>>,>>>,>>9.99"
                                    label  "Vlr. Vendido Cr$"
       field wclamoe  as   decimal  format ">>>,>>>,>>>,>>9.99"
                                    label  "Vlr. Moeda Alt."
       field wclasup  like clase.clasup
       field wclatipo like clase.clatipo
       field wclagrau like clase.clagrau.
define buffer bclasse for wclasse.
define variable wvlrmoe as decimal extent 12.
define variable wabrang as logical format "Classe/Produtos"
                                   label  "Abrangencia".
define variable wnivel  as integer format "9"
                                   label  "Nivel" initial 9.
define variable i       as integer format "99".
define variable d       as integer format "99".
define variable wmi     as integer format "99".
define variable wai     as integer format "9999".
define variable wmf     as integer format "99".
define variable waf     as integer format "9999".
define variable wsup  like clase.clasup.
define variable wcod  like clase.clacod.
define variable wvlr     as decimal.
define variable wmoe     as decimal.
define variable wvlrtot  as decimal.
define variable wmoeatu  as decimal.
define variable wdt      as date.

form "  Mes/Ano Inicial:" wmi no-label space(0) "/"
                space(0) wai no-label skip
     "  Mes/Ano   Final:" wmf no-label space(0) "/"
                space(0) waf no-label skip
     estab.etbcod colon 18 estab.etbnom no-label colon 25
     indic.indcod colon 18 indic.inddesc no-label colon 25
     wabrang      colon 18
     wnivel       colon 18 with row 4 frame f1 side-label width 80.

     view frame f1.
repeat:

    wabrang = yes.

    set        wmi
               wai with frame f1.

    wdt = date(wmi,01,wai).

    set        wmf
               waf with frame f1.

    wdt = date(wmf,28,waf).

    if ((waf * 12) + wmf) - ((wai * 12) + wmi) > 11
       then do:
            message "Periodo nao pode ser superior a 12 meses".
            undo.
           end.

    prompt-for estab.etbcod validate(estab.etbcod = 0 or
                                     can-find(estab using input estab.etbcod),
                                     "Estabelecimento nao cadastrado")
                                     with frame f1.
    if input estab.etbcod <> 0
       then do:
               find estab using input estab.etbcod.

               display estab.etbnom no-label with frame f1.
       end.

    prompt-for indic.indcod validate(indic.indcod = 0 or
                                     can-find(indic using input indic.indcod),
                                     "Indice Economico nao cadastrado")
                                     with frame f1.

    if input indic.indcod <> 0
       then do:
               find indic using input indcod.

               display indic.inddesc no-label with frame f1.

               if not indtipo
                  then do:
                          message "Somente Moedas".
                          undo.
                  end.

               for each inddt  where inddt.indcod = indic.indcod  and
                                     indano >= wai and indmes >=wmi and
                                     indano <= waf and indmes <=wmf:

                    do i = 1 to 31:
                        wvlrmoe[indmes] = wvlrmoe[indmes] + indvalor[i].
                        if indvalor[i] <> 0
                           then d = d + 1.
                    end.
                    wvlrmoe[indmes] = wvlrmoe[indmes] / d.
               end.

               find inddt of indic where indano = year(today) and
                                         indmes = month(today) no-error.

               if not available inddt
                  then do:
                        {confir.i 2 "impressao sem Moeda Alternativa"}
                        do i = 1 to 12:
                           wvlrmoe[i] = 0.
                        end.
                   end.
                   else wmoeatu = indvalor[day(today)].
       end.
    update wabrang help "[C] Classe ou [P] Produto" with frame f1.

    if input wabrang
       then
           update wnivel with frame f1.
       else
           wnivel = 9.

    for each clase by clanome:

        find first wclasse where wclacod = clase.clacod no-error.

        if not available wclasse
           then do:
                   create wclasse.
                   assign wclacod  = clase.clacod
                          wclasup  = clase.clasup
                          wclanome = clase.clanome
                          wclagrau = clase.clagrau
                          wclaval  = 0
                          wclamoe  = 0.
               end.

         if  clase.clatipo = yes
             then next.
         for each produ of clase:
         for each himov of produ where ( if input estab.etbcod = 0
                                         then true
                                         else himov.etbcod = input estab.etbcod)
                                  and  himov.himdata >= date(wmi,01,wai)
                                  and  himov.himdata <= date(wmf,28,waf):

             assign wclaval = wclaval +  himsaival.
             if wvlrmoe[month(himdata)] <> 0
                then wclamoe = wclamoe + (himsaival / wvlrmoe[month(himdata)]).
         end.
         end.
    end.
for each clase where clase.clatipo = no and clase.clasup <> 0:

    find first wclasse where wclacod = clase.clacod.
    assign wvlr = wclasse.wclaval
           wmoe = wclasse.wclamoe
           wsup = wclasse.wclasup.
    repeat:
          find first wclasse where wclacod  = wsup.

          wclaval = wclaval + wvlr.
          wclamoe = wclamoe + wmoe.

          if wclasup = 0
             then leave.
             else wsup = wclasup.
    end.
end.

do with 1 column width 80 title " Confirmacao de Emissao " frame f2:
    display skip "Prepare a Impressora, formulario 80 colunas." skip.
end.
{confir.i 1 "impressao de Participacao por Classes"}
message "Emitindo Participacao de Classes".
output to terminal page-size 60.
{ini12cpp.i}

define variable wccod like clase.clacod.
define variable wcsup like clase.clasup.
define variable wnom like clase.clanome.
form header
    wempre.emprazsoc "Administracao Comercial" at 49 today at 89
    skip "Participacao nas Vendas por Classe"
    "Pag." at 89 page-number - 1 format ">>9"
    skip fill("-",96) format "x(96)" skip
    with frame fcab page-top no-box width 100.
form header
    skip "Classe Descricao"
         " Vlr Vendido Cr$   Moeada Alter.  Superior %  Total %"  at 44 skip
    fill("-",96) format "x(96)" at 1
    with frame fdet page-top no-box width 100.
view frame fcab.
view frame fdet.
assign wccod = 0
       wcsup = 0.

for each wclasse where wclasup = 0 :
    wvlrtot = wvlrtot + wclaval.
end.

repeat:

    find first clase where clase.clasup = wccod and
                           clase.clacod > wcod no-error.

    if available clase
        then do:
            find first wclasse where wclacod = clase.clacod and
                                     wclanome = clase.clanome.
            find first bclasse where bclasse.wclacod = clase.clasup no-error.
            if not available bclasse
                   then wvlr = wvlrtot.
                   else wvlr = bclasse.wclaval.
            if wvlr = 0
               then wvlr = 1.
            if clase.clagrau <= wnivel
               then do:
                    put wclasse.wclacod
                        wclasse.wclanome at 6 + wclasse.wclagrau * 2
                        wclasse.wclaval at 42.
                    if wclasse.wclamoe = 0 or wclasse.wclamoe = ?
                       then put "  ----------" at 62.
                       else put wclasse.wclamoe
                                  format ">>>,>>>,>>9.99" at 62.
                     put wclasse.wclaval / wvlr * 100
                                           format ">>9.99"         at 80
                        wclasse.wclaval / wvlrtot * 100
                                           format ">>9.99"   at 89 skip.
                   end.
            assign wccod = clase.clacod
                   wcsup = clase.clasup
                   wcod = 0.
        end.
        else do:
             if wccod = 0 then leave.
        find first clase where clase.clacod = wccod no-error.
        if not available  clase
            then  assign wccod    =  0.
            else
            assign  wccod  = clase.clasup
                    wcod   = clase.clacod.
        end.
end.
{fin12cpp.i}
output close.
return.
end.
