def shared temp-table tt-clispc
    field clicod like clien.clicod
    index i1 is primary unique clicod.

run conecta_d.p.
if not connected("d")
then.
else do:
    run ver_spc1.p.
    disconnect d.
end.

