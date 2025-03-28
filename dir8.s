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
    bcs error
    ldx #DISK
    jsr CHKIN

    // Skip start address
    jsr read2
    jsr READST
    beq nextline
    lda #4  // File not found
    bne error

nextline:
    // Skip next address
    jsr read2
    jsr READST
    bne end

    // Read & print line number
    lda #'\r'
    jsr CHROUT
    jsr read2
    jsr LINPRT
    lda #' '
    jsr CHROUT

nextbyte:
    jsr CHRIN
    beq nextline
    jsr CHROUT
    bne nextbyte  // always branch

read2:
    // Reads a 16 bit, little endian value from disk
    // A=high byte, X=low byte
    jsr CHRIN
    tax
    jmp CHRIN

end:
    jsr CLRCHN
    lda #DISK
    jmp CLOSE


error:
    tax
    jmp ($0300)

filename:
.text "$"


.label LINPRT = $BDCD
.label READST = $FFB7
.label SETLFS = $FFBA
.label SETNAM = $FFBD
.label OPEN = $FFC0
.label CLOSE = $FFC3
.label CHKIN = $FFC6
.label CLRCHN = $FFCC
.label CHRIN = $FFCF
.label CHROUT = $FFD2
