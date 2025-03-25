// Return the drive status from device 8

* = $C000

// Like open 15,8,15
.label DISK = 8
.label CHANNEL = 15
.label REOPEN = $60

    lda #0
    sta STATUS
    lda #DISK
    jsr TALK
    lda #REOPEN | CHANNEL
    jsr TALKSA
    bit STATUS
    bmi done  // DEVICE NOT PRESENT

loop:
    jsr ACPTR
    bit STATUS
    bvs done  // End of file
    jsr CHROUT
    jmp loop

done:
    jmp UNTLK

.label STATUS = $90
.label TALKSA = $FF96
.label ACPTR = $FFA5
.label TALK = $FFB4
.label UNTLK = $FFBA
.label CHROUT = $FFD2
