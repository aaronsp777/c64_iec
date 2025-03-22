// Typical Hello World App
// Run with SYS 49152

* = $C000
.label CHROUT = $ffd2

    ldx #0
loop:
    lda hello,x
    jsr CHROUT
    inx
    cmp #13
    bne loop
    rts

hello:
.text "HELLO WORLD!"
.byte 13

