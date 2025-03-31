// Return the drive status from device 8

* = $C000

// Like open 15,8,15
.label DISK = 8
.label CHANNEL = 15
    
    lda #CHANNEL
    ldx #DISK
    tay
    jsr SETLFS
    lda #0
    jsr SETNAM
    jsr OPEN
    ldx #CHANNEL
    jsr CHKIN

nextchar:
    jsr CHRIN
    jsr CHROUT
    jsr READST
    beq nextchar

    jsr CLRCHN
    lda #CHANNEL
    jmp CLOSE

.label READST = $FFB7
.label SETLFS = $FFBA
.label SETNAM = $FFBD
.label OPEN = $FFC0
.label CLOSE = $FFC3
.label CHKIN = $FFC6
.label CLRCHN = $FFCC
.label CHRIN = $FFCF
.label CHROUT = $FFD2