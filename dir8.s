// Shows the directory on device 8

* = $C000


.label DISK = 8
    // open 8,8,0,"$"
    lda #DISK
    tax
    ldy #0
    jsr SETLFS
    lda #1  // Length 1
    ldx #<filename
    ldy #>filename
    jsr SETNAM
    jsr OPEN
    bcs open_fail

    jsr READST
    bne end

    ldx #DISK
    jsr CHKIN

    // Skip start address
    jsr CHRIN; jsr CHRIN

nextline:
    // Skip next address
    jsr CHRIN; jsr CHRIN

    // Read line number
    jsr READST
    bne end

    jsr CHRIN
    tax
    jsr CHRIN
    tay
    jsr printdec


nextbyte:
    jsr READST
    bne end

    jsr CHRIN
    beq nextline
    jsr CHROUT
    jmp nextbyte

end:
    jsr CLRCHN
    lda #DISK
    jsr CLOSE
    rts


open_fail:
    // TODO - fixme - .A contains error
    rts

printdec:
    // print decimal in x<, y>
    // TODO
    lda #13
    jsr CHROUT
    lda #'0'
    jsr CHROUT
    lda #' '
    jsr CHROUT
    rts

filename:
.text "$"



.label READST = $FFB7
.label SETLFS = $FFBA
.label SETNAM = $FFBD
.label OPEN = $FFC0
.label CLOSE = $FFC3
.label CHKIN = $FFC6
.label CLRCHN = $FFCC
.label CHRIN = $FFCF
.label CHROUT = $FFD2
