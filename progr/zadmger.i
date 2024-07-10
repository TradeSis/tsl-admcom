if frame-field matches "*moncod*"
then run zmoncod.p.

if frame-field matches "*forautnom*"
then run zforaut.p.

if frame-field matches "*aplinom*"
then run zaplic.p.

if frame-field matches "*codcont*"
then run ztipcont.p.

if frame-field matches "*juscod*"
then run zjusexpv.p.

if frame-field matches "*tipdep*"
then run ztipdep.p.
if frame-field matches "*tipcont*"
then run ztipcont.p.

if frame-field matches "*forcod*" or
   frame-field matches "*tracod*"
    then if program-name(2) = "cotin.p"
            then run zcotin.p.
            else run /* zforne.p. */ zforger2.p.
if frame-field matches "*codfis*"
    then run zclafis.p.
if frame-field matches "*empcod*"
    then run zempre.p.
if frame-field matches "*ufecod*"
    then run zunfed.p.
if frame-field matches "*etb*"
    then run zestab.p.
if frame-field matches "*centro*"
    then run zcentro.p.
    
if frame-field matches "*setcod*"
    then run zsetaut.p.
if frame-field matches "*clifor*"
    then do:
        if lclifor
        then
            run zclien.p.
        else
            run zforne.p.
    end.

if frame-field matches "*clicod*"
then /*if program-name(2) <> "tstzoom.p"
     then run zclien.p.
     else*/ run zclinew9.p.

if frame-field matches "*lancod*"
    then run ztablan.p.

if frame-field matches "*fordes*"
    then run zforaut.p.



if frame-field matches "*unocod*"
    then run zunorg.p.

if frame-field matches "*cep*"
    then run zcep.p.

if frame-field matches "*codbai*"
   then run zbairro.p.
 
    
if frame-field matches "*indcod*"
    then run zind.p.
if frame-field matches "*crecod*"
    then run zcrepl.p.
if frame-field matches "*repcod*"
    then run zrepre0.p.
if frame-field matches "*frecod*"
    then run zfrete.p.
if frame-field matches "*funcod*"
    then run zfunc.p.
if frame-field matches "*funfol*"
    then run zfunfol.p.
if frame-field matches "*carcod*"
    then run zcaract.p.
if frame-field matches "*subcod*"
    then run zsubcara.p.
if frame-field matches "*promocod*"
    then run zopromoc.p.
if frame-field matches "*ibge*"
    then run zcidade.p.
if frame-field matches "*munic*"
    then run zmunic.p.
if frame-field matches "*servi*"
    then run zooservi.p.
if frame-field matches "*codprof*"
    or frame-field matches "*proprof*"
    or frame-field matches "*var-int4*"
    or frame-field matches "*var-int5*"
    then run zcodprof.p.
                  
if frame-field matches "*var-char10*"
    then run zmuncod.p.

if frame-field matches "*clasup-ecom*"
    then run zclasup-ecom.p.
                             
