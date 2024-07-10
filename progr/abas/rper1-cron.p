
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

{/admcom/progr/admcab.i new}

run abas/rper1.p ("ALCIS_MOVEIS").
run abas/rper1.p ("ALCIS_MODA").



return.
