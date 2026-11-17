
tmp0 = $00
tmp1 = $01
tmp2 = $02
tmp3 = $03
tmp4 = $04
tmp5 = $05
tmp6 = $06
tmp7 = $07
tmp8 = $08
ptrL = $09
ptrH = $0A
nmiflag = $0B
pad = $0C
padprev = $0D
padnew = $0E
state = $0F
room = $10
px = $11
py = $12
dir = $13
hp = $14
haskey = $15
dooropen = $16
doorflag = $17
swordT = $18
inv = $19
frame = $1A
oamidx = $1B
rnd = $1C
nx = $1D
ny = $1E
walk = $1F
swx = $20
swy = $21
ei = $22
step = $23
melI = $24
melT = $25
basI = $26
basT = $27
r_row = $28
ex = $30
ey = $33
ealive = $36
edir = $39
etmr = $3C
taken = $40

.org $C000

reset:
  sei
  cld
  ldx #$40
  stx $4017
  ldx #$FF
  txs
  inx
  stx $2000
  stx $2001
  stx $4010
  bit $2002
rs_v1:
  bit $2002
  bpl rs_v1
  lda #0
  tax
rs_clr:
  sta $00,x
  sta $0100,x
  sta $0300,x
  sta $0400,x
  inx
  bne rs_clr
  jsr ClearOAM
rs_v2:
  bit $2002
  bpl rs_v2
  lda #$0F
  sta $4015
  lda #$A5
  sta rnd
  lda #0
  sta state
  jsr ShowTitle
  jmp main

nmi:
  pha
  txa
  pha
  tya
  pha
  lda #0
  sta $2003
  lda #2
  sta $4014
  lda $2002
  lda #0
  sta $2005
  sta $2005
  inc frame
  jsr UpdateMusic
  lda #1
  sta nmiflag
  pla
  tay
  pla
  tax
  pla
  rti

irq:
  rti

WaitNMI:
  lda #0
  sta nmiflag
wn_l:
  lda nmiflag
  beq wn_l
  rts

ReadPad:
  lda pad
  sta padprev
  lda #1
  sta $4016
  lda #0
  sta $4016
  ldx #8
rp_l:
  lda $4016
  lsr a
  rol pad
  dex
  bne rp_l
  lda padprev
  eor #$FF
  and pad
  sta padnew
  rts

Rand:
  lda rnd
  asl a
  bcc rn_1
  eor #$1D
rn_1:
  sta rnd
  rts

AbsDiff:
  sec
  sbc tmp0
  bcs ad_ok
  eor #$FF
  clc
  adc #1
ad_ok:
  rts

ClearOAM:
  lda #$FF
  ldx #0
co_l:
  sta $0200,x
  inx
  inx
  inx
  inx
  bne co_l
  rts

LoadPalette:
  lda $2002
  lda #$3F
  sta $2006
  lda #0
  sta $2006
  ldx #0
lp_l:
  lda palettes,x
  sta $2007
  inx
  cpx #32
  bne lp_l
  rts

; ---------------- music ----------------
UpdateMusic:
  lda melT
  beq um_mnext
  dec melT
  jmp um_b
um_mnext:
  ldx melI
  lda mel_note,x
  cmp #$FF
  bne um_mplay
  ldx #0
  stx melI
um_mplay:
  lda mel_note,x
  tay
  lda mel_dur,x
  sta melT
  inc melI
  cpy #0
  beq um_mrest
  lda pul_lo,y
  sta $4006
  lda pul_hi,y
  sta $4007
  lda #$B6
  sta $4004
  jmp um_b
um_mrest:
  lda #$B0
  sta $4004
um_b:
  lda basT
  beq um_bnext
  dec basT
  rts
um_bnext:
  ldx basI
  lda bas_note,x
  cmp #$FF
  bne um_bplay
  ldx #0
  stx basI
um_bplay:
  lda bas_note,x
  tay
  lda bas_dur,x
  sta basT
  inc basI
  cpy #0
  beq um_brest
  lda tri_lo,y
  sta $400A
  lda tri_hi,y
  sta $400B
  lda #$FF
  sta $4008
  rts
um_brest:
  lda #$80
  sta $4008
  rts

; ---------------- sfx ----------------
SfxSword:
  lda #$1C
  sta $400C
  lda #$05
  sta $400E
  lda #$00
  sta $400F
  rts
SfxHit:
  lda #$1F
  sta $400C
  lda #$0A
  sta $400E
  lda #$10
  sta $400F
  rts
SfxHurt:
  lda #$1F
  sta $400C
  lda #$0E
  sta $400E
  lda #$20
  sta $400F
  rts
SfxPick:
  lda #$9F
  sta $4000
  lda #$00
  sta $4001
  lda #$80
  sta $4002
  lda #$90
  sta $4003
  rts

; ---------------- main loop ----------------
main:
  jsr WaitNMI
  jsr ReadPad
  lda state
  beq mn_title
  cmp #1
  beq mn_play
  lda padnew
  and #$10
  beq main
  lda #0
  sta state
  jsr ShowTitle
  jmp main
mn_title:
  jsr TitleFrame
  jmp main
mn_play:
  jsr GameFrame
  jmp main

TitleFrame:
  jsr Rand
  jsr ClearOAM
  lda #0
  sta oamidx
  lda #104
  sta tmp0
  lda #96
  sta tmp1
  lda #1
  sta tmp2
  lda frame
  and #$20
  asl a
  sta tmp3
  jsr DrawMeta
  lda #140
  sta tmp0
  lda #96
  sta tmp1
  lda #17
  sta tmp2
  lda #1
  sta tmp3
  jsr DrawMeta
  lda padnew
  and #$90
  beq tf_end
  jsr StartGame
tf_end:
  rts

StartGame:
  lda #3
  sta hp
  lda #0
  sta haskey
  sta dooropen
  sta doorflag
  sta swordT
  sta inv
  sta walk
  ldx #3
sg_t:
  sta taken,x
  dex
  bpl sg_t
  sta room
  lda #120
  sta px
  sta py
  lda #1
  sta dir
  sta state
  jsr EnterRoom
  rts

GameFrame:
  lda #0
  sta oamidx
  jsr ClearOAM
  jsr UpdateHero
  lda doorflag
  beq gf_nodoor
  lda #0
  sta doorflag
  sta haskey
  lda #1
  sta dooropen
  jsr SfxPick
  jsr LoadRoom
gf_nodoor:
  jsr UpdateEnemies
  lda state
  cmp #1
  bne gf_end
  jsr UpdateItem
  lda state
  cmp #1
  bne gf_end
  jsr DrawAll
gf_end:
  rts

; ---------------- hero ----------------
UpdateHero:
  lda inv
  beq uh_a
  dec inv
uh_a:
  lda swordT
  beq uh_b
  dec swordT
  jsr SwordPos
  jsr SwordHit
  rts
uh_b:
  lda padnew
  and #$C0
  beq uh_c
  lda #12
  sta swordT
  jsr SfxSword
  rts
uh_c:
  lda frame
  and #1
  clc
  adc #1
  sta step
  lda #1
  sta tmp7
  lda pad
  and #$01
  beq uh_left
  lda #3
  sta dir
  lda px
  clc
  adc step
  sta nx
  cmp #240
  bcs uh_goeast
  lda py
  sta ny
  jsr FreeBox
  bcs uh_r1
  lda nx
  sta px
  inc walk
uh_r1:
  rts
uh_goeast:
  inc room
  lda #2
  sta px
  jmp EnterRoom
uh_left:
  lda pad
  and #$02
  beq uh_up
  lda #2
  sta dir
  lda px
  sec
  sbc step
  bcc uh_gowest
  sta nx
  lda py
  sta ny
  jsr FreeBox
  bcs uh_l1
  lda nx
  sta px
  inc walk
uh_l1:
  rts
uh_gowest:
  dec room
  lda #224
  sta px
  jmp EnterRoom
uh_up:
  lda pad
  and #$08
  beq uh_down
  lda #0
  sta dir
  lda py
  sec
  sbc step
  sta ny
  cmp #28
  bcc uh_gonorth
  lda px
  sta nx
  jsr FreeBox
  bcs uh_u1
  lda ny
  sta py
  inc walk
uh_u1:
  rts
uh_gonorth:
  lda room
  sec
  sbc #2
  sta room
  lda #208
  sta py
  jmp EnterRoom
uh_down:
  lda pad
  and #$04
  beq uh_none
  lda #1
  sta dir
  lda py
  clc
  adc step
  sta ny
  cmp #216
  bcs uh_gosouth
  lda px
  sta nx
  jsr FreeBox
  bcs uh_d1
  lda ny
  sta py
  inc walk
uh_d1:
  rts
uh_gosouth:
  lda room
  clc
  adc #2
  sta room
  lda #28
  sta py
  jmp EnterRoom
uh_none:
  rts

SwordPos:
  lda dir
  bne sp_1
  lda px
  clc
  adc #4
  sta swx
  lda py
  sec
  sbc #8
  sta swy
  rts
sp_1:
  cmp #1
  bne sp_2
  lda px
  clc
  adc #4
  sta swx
  lda py
  clc
  adc #16
  sta swy
  rts
sp_2:
  cmp #2
  bne sp_3
  lda px
  sec
  sbc #8
  sta swx
  lda py
  clc
  adc #4
  sta swy
  rts
sp_3:
  lda px
  clc
  adc #16
  sta swx
  lda py
  clc
  adc #4
  sta swy
  rts

SwordHit:
  lda #0
  sta ei
sh_loop:
  ldx ei
  lda ealive,x
  beq sh_next
  lda swx
  clc
  adc #4
  sta tmp0
  lda ex,x
  clc
  adc #8
  jsr AbsDiff
  cmp #14
  bcs sh_next
  ldx ei
  lda swy
  clc
  adc #4
  sta tmp0
  lda ey,x
  clc
  adc #8
  jsr AbsDiff
  cmp #14
  bcs sh_next
  ldx ei
  lda #0
  sta ealive,x
  jsr SfxHit
sh_next:
  inc ei
  lda ei
  cmp #3
  bne sh_loop
  rts

; ---------------- collision ----------------
CheckCorner:
  lda tmp4
  lsr a
  lsr a
  lsr a
  lsr a
  sta tmp6
  lda tmp5
  and #$F0
  ora tmp6
  tax
  lda $0300,x
  cmp #2
  bcc cc_free
  cmp #4
  bne cc_blk
  lda tmp7
  beq cc_blk
  lda haskey
  beq cc_blk
  lda #1
  sta doorflag
cc_blk:
  sec
  rts
cc_free:
  clc
  rts

FreeBox:
  lda #0
  sta tmp8
fb_l:
  ldx tmp8
  lda nx
  clc
  adc cdx,x
  sta tmp4
  lda ny
  clc
  adc cdy,x
  sta tmp5
  jsr CheckCorner
  bcs fb_blk
  inc tmp8
  lda tmp8
  cmp #4
  bne fb_l
  clc
  rts
fb_blk:
  sec
  rts

; ---------------- enemies ----------------
UpdateEnemies:
  lda #0
  sta ei
ue_loop:
  ldx ei
  lda ealive,x
  bne ue_alive
  jmp ue_next
ue_alive:
  lda ex,x
  sta tmp0
  lda px
  jsr AbsDiff
  cmp #11
  bcs ue_nocontact
  ldx ei
  lda ey,x
  sta tmp0
  lda py
  jsr AbsDiff
  cmp #11
  bcs ue_nocontact
  lda inv
  bne ue_nocontact
  dec hp
  lda #70
  sta inv
  jsr SfxHurt
  lda hp
  bne ue_nocontact
  lda #2
  sta state
  jsr ShowGameOver
  rts
ue_nocontact:
  ldx ei
  lda etmr,x
  bne ue_tick
  jsr Rand
  and #3
  ldx ei
  sta edir,x
  jsr Rand
  and #$3F
  clc
  adc #30
  ldx ei
  sta etmr,x
  jmp ue_next
ue_tick:
  dec etmr,x
  lda frame
  and #1
  bne ue_next
  lda ex,x
  sta nx
  lda ey,x
  sta ny
  lda edir,x
  beq ue_up
  cmp #1
  beq ue_down
  cmp #2
  beq ue_left
  inc nx
  jmp ue_try
ue_up:
  dec ny
  jmp ue_try
ue_down:
  inc ny
  jmp ue_try
ue_left:
  dec nx
ue_try:
  lda nx
  cmp #20
  bcc ue_block
  cmp #224
  bcs ue_block
  lda ny
  cmp #40
  bcc ue_block
  cmp #204
  bcs ue_block
  lda #0
  sta tmp7
  jsr FreeBox
  bcs ue_block
  ldx ei
  lda nx
  sta ex,x
  lda ny
  sta ey,x
  jmp ue_next
ue_block:
  ldx ei
  lda #0
  sta etmr,x
ue_next:
  inc ei
  lda ei
  cmp #3
  beq ue_done
  jmp ue_loop
ue_done:
  rts

; ---------------- items ----------------
UpdateItem:
  ldx room
  lda itemtype,x
  beq ui_done
  lda taken,x
  bne ui_done
  lda itemx,x
  clc
  adc #4
  sta tmp0
  lda px
  clc
  adc #8
  jsr AbsDiff
  cmp #11
  bcs ui_done
  ldx room
  lda itemy,x
  clc
  adc #4
  sta tmp0
  lda py
  clc
  adc #8
  jsr AbsDiff
  cmp #11
  bcs ui_done
  ldx room
  lda itemtype,x
  cmp #2
  bne ui_notheart
  lda hp
  cmp #5
  bcs ui_done
  inc hp
  lda #1
  sta taken,x
  jsr SfxPick
  rts
ui_notheart:
  lda #1
  sta taken,x
  lda itemtype,x
  cmp #1
  beq ui_key
  lda #3
  sta state
  jsr ShowWin
  rts
ui_key:
  lda #1
  sta haskey
  jsr SfxPick
ui_done:
  rts

; ---------------- drawing ----------------
DrawOne:
  ldy oamidx
  lda tmp1
  sta $0200,y
  iny
  lda tmp2
  sta $0200,y
  iny
  lda tmp3
  sta $0200,y
  iny
  lda tmp0
  sta $0200,y
  iny
  sty oamidx
  rts

DrawMeta:
  ldy oamidx
  lda tmp3
  and #$40
  bne dm_flip
  lda tmp2
  sta tmp4
  clc
  adc #1
  sta tmp5
  jmp dm_go
dm_flip:
  lda tmp2
  clc
  adc #1
  sta tmp4
  lda tmp2
  sta tmp5
dm_go:
  lda tmp1
  sta $0200,y
  iny
  lda tmp4
  sta $0200,y
  iny
  lda tmp3
  sta $0200,y
  iny
  lda tmp0
  sta $0200,y
  iny
  lda tmp1
  sta $0200,y
  iny
  lda tmp5
  sta $0200,y
  iny
  lda tmp3
  sta $0200,y
  iny
  lda tmp0
  clc
  adc #8
  sta $0200,y
  iny
  lda tmp1
  clc
  adc #8
  sta tmp6
  sta $0200,y
  iny
  lda tmp4
  clc
  adc #2
  sta $0200,y
  iny
  lda tmp3
  sta $0200,y
  iny
  lda tmp0
  sta $0200,y
  iny
  lda tmp6
  sta $0200,y
  iny
  lda tmp5
  clc
  adc #2
  sta $0200,y
  iny
  lda tmp3
  sta $0200,y
  iny
  lda tmp0
  clc
  adc #8
  sta $0200,y
  iny
  sty oamidx
  rts

DrawAll:
  ldx #0
da_h:
  cpx hp
  bcs da_hd
  txa
  asl a
  sta tmp4
  asl a
  asl a
  clc
  adc tmp4
  clc
  adc #8
  sta tmp0
  lda #19
  sta tmp1
  lda #23
  sta tmp2
  lda #3
  sta tmp3
  jsr DrawOne
  inx
  jmp da_h
da_hd:
  lda haskey
  beq da_nokey
  lda #228
  sta tmp0
  lda #19
  sta tmp1
  lda #24
  sta tmp2
  lda #3
  sta tmp3
  jsr DrawOne
da_nokey:
  lda inv
  beq da_hero
  lda frame
  and #2
  beq da_hero
  jmp da_skiphero
da_hero:
  lda px
  sta tmp0
  lda py
  sta tmp1
  lda walk
  lsr a
  lsr a
  lsr a
  and #1
  sta tmp4
  lda dir
  cmp #2
  bcs da_side
  lda dir
  beq da_up
  lda #1
  sta tmp2
  jmp da_vert
da_up:
  lda #5
  sta tmp2
da_vert:
  lda tmp4
  beq da_v0
  lda #$40
da_v0:
  sta tmp3
  jsr DrawMeta
  jmp da_skiphero
da_side:
  lda tmp4
  asl a
  asl a
  clc
  adc #9
  sta tmp2
  lda dir
  cmp #2
  beq da_left
  lda #0
  sta tmp3
  jmp da_sd
da_left:
  lda #$40
  sta tmp3
da_sd:
  jsr DrawMeta
da_skiphero:
  lda swordT
  beq da_nosw
  jsr SwordPos
  lda swx
  sta tmp0
  lda swy
  sta tmp1
  lda dir
  bne da_s1
  lda #21
  sta tmp2
  lda #2
  sta tmp3
  jmp da_sdone
da_s1:
  cmp #1
  bne da_s2
  lda #21
  sta tmp2
  lda #$82
  sta tmp3
  jmp da_sdone
da_s2:
  cmp #2
  bne da_s3
  lda #22
  sta tmp2
  lda #$42
  sta tmp3
  jmp da_sdone
da_s3:
  lda #22
  sta tmp2
  lda #2
  sta tmp3
da_sdone:
  jsr DrawOne
da_nosw:
  lda #0
  sta ei
da_e:
  ldx ei
  lda ealive,x
  beq da_en
  lda ex,x
  sta tmp0
  lda frame
  lsr a
  lsr a
  lsr a
  and #1
  sta tmp4
  lda ey,x
  sec
  sbc tmp4
  sta tmp1
  lda #17
  sta tmp2
  lda #1
  sta tmp3
  jsr DrawMeta
da_en:
  inc ei
  lda ei
  cmp #3
  bne da_e
  ldx room
  lda itemtype,x
  beq da_done
  tay
  lda taken,x
  bne da_done
  lda itemx,x
  sta tmp0
  lda itemy,x
  sta tmp1
  lda itiletab,y
  sta tmp2
  lda iattrtab,y
  sta tmp3
  jsr DrawOne
da_done:
  rts

; ---------------- rooms ----------------
EnterRoom:
  lda room
  asl a
  clc
  adc room
  sta tmp0
  ldx #0
er_l:
  ldy tmp0
  lda enemy_y,y
  sta ey,x
  lda enemy_x,y
  sta ex,x
  lda #0
  sta etmr,x
  sta edir,x
  lda enemy_y,y
  beq er_set
  lda #1
er_set:
  sta ealive,x
  inc tmp0
  inx
  cpx #3
  bne er_l
  jmp LoadRoom

LoadRoom:
  lda #0
  sta $2000
  sta $2001
  lda room
  asl a
  tax
  lda room_ptrs,x
  sta ptrL
  lda room_ptrs+1,x
  sta ptrH
  ldy #0
lr_cp:
  lda (ptrL),y
  sta $0300,y
  iny
  bne lr_cp
  lda room
  cmp #3
  bne lr_nodoor
  lda dooropen
  beq lr_nodoor
  lda #0
  sta $03B7
  sta $03B8
lr_nodoor:
  jsr LoadPalette
  ; --- attribute buffer ---
  ldx #0
  lda #0
lr_zb:
  sta $0400,x
  inx
  cpx #64
  bne lr_zb
  sta r_row
at_row:
  lda #0
  sta tmp1
at_col:
  lda r_row
  asl a
  asl a
  asl a
  asl a
  clc
  adc tmp1
  tax
  lda $0300,x
  tax
  lda mt_pal,x
  sta tmp2
  lda r_row
  and #1
  asl a
  asl a
  sta tmp3
  lda tmp1
  and #1
  asl a
  clc
  adc tmp3
  sta tmp3
  lda tmp2
  ldx tmp3
  beq at_ns
at_sh:
  asl a
  dex
  bne at_sh
at_ns:
  sta tmp2
  lda r_row
  lsr a
  asl a
  asl a
  asl a
  sta tmp3
  lda tmp1
  lsr a
  clc
  adc tmp3
  tax
  lda $0400,x
  ora tmp2
  sta $0400,x
  inc tmp1
  lda tmp1
  cmp #16
  bne at_col
  inc r_row
  lda r_row
  cmp #15
  bne at_row
  ; --- nametable ---
  lda $2002
  lda #$20
  sta $2006
  lda #0
  sta $2006
  sta r_row
rr_row:
  lda r_row
  asl a
  asl a
  asl a
  asl a
  sta tmp0
  lda #0
  sta tmp1
rr_a:
  lda tmp0
  clc
  adc tmp1
  tax
  lda $0300,x
  tax
  lda mt_tl,x
  sta $2007
  lda mt_tr,x
  sta $2007
  inc tmp1
  lda tmp1
  cmp #16
  bne rr_a
  lda #0
  sta tmp1
rr_b:
  lda tmp0
  clc
  adc tmp1
  tax
  lda $0300,x
  tax
  lda mt_bl,x
  sta $2007
  lda mt_br,x
  sta $2007
  inc tmp1
  lda tmp1
  cmp #16
  bne rr_b
  inc r_row
  lda r_row
  cmp #15
  bne rr_row
  ; attributes follow directly at $23C0
  ldx #0
lr_at:
  lda $0400,x
  sta $2007
  inx
  cpx #64
  bne lr_at
  lda $2002
  lda #0
  sta $2005
  sta $2005
  lda #$88
  sta $2000
  lda #$1E
  sta $2001
  rts

; ---------------- text screens ----------------
ShowTitle:
  lda #<str_title
  sta ptrL
  lda #>str_title
  sta ptrH
  jmp ShowScreen
ShowGameOver:
  lda #<str_over
  sta ptrL
  lda #>str_over
  sta ptrH
  jmp ShowScreen
ShowWin:
  lda #<str_win
  sta ptrL
  lda #>str_win
  sta ptrH
  jmp ShowScreen

ShowScreen:
  lda #0
  sta $2000
  sta $2001
  jsr LoadPalette
  lda $2002
  lda #$20
  sta $2006
  lda #0
  sta $2006
  ldx #4
  ldy #0
ss_clr:
  sta $2007
  iny
  bne ss_clr
  dex
  bne ss_clr
  ldy #0
ss_next:
  lda (ptrL),y
  beq ss_done
  sta $2006
  iny
  lda (ptrL),y
  sta $2006
  iny
ss_ch:
  lda (ptrL),y
  cmp #$FF
  beq ss_end
  sta $2007
  iny
  jmp ss_ch
ss_end:
  iny
  jmp ss_next
ss_done:
  jsr ClearOAM
  lda $2002
  lda #0
  sta $2005
  sta $2005
  lda #$88
  sta $2000
  lda #$1E
  sta $2001
  rts

palettes:
  .byte 15,42,26,48,15,9,25,23,15,33,17,49,15,40,23,7
  .byte 15,23,39,22,15,33,48,1,15,48,0,23,15,40,22,48
mt_tl:
  .byte 13,13,2,6,8,0
mt_tr:
  .byte 13,1,3,7,9,0
mt_bl:
  .byte 13,13,4,7,10,0
mt_br:
  .byte 13,13,5,6,11,0
mt_pal:
  .byte 0,0,1,2,3,0
cdx:
  .byte 3,12,3,12
cdy:
  .byte 8,8,15,15
enemy_x:
  .byte 64,176,176,80,170,200,100,130,200,50,190,60
enemy_y:
  .byte 80,152,72,120,190,120,44,196,120,70,70,150
itemtype:
  .byte 0,2,1,3
itemx:
  .byte 0,120,124,124
itemy:
  .byte 0,150,116,196
itiletab:
  .byte 0,24,23,25
iattrtab:
  .byte 0,3,3,1
room_ptrs:
  .word room0,room1,room2,room3
room0:
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,1,0,0,0,2,2,0,0,0,1,0,0,2
  .byte 2,0,0,0,0,0,0,2,2,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,1,0,0,0,0,2,2,0,0,0,0,1,0,2
  .byte 2,0,0,0,0,0,0,2,2,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,1,0,0,0,0,0,0,0,0,0,1,0,2
  .byte 2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
room1:
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,3,3,3,3,3,3,3,3,3,3,3,3,0,2
  .byte 2,0,3,3,3,3,3,3,3,3,3,3,3,3,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,2,2,0,0,0,0,0,0,2,2,0,0,2
  .byte 2,0,0,2,2,0,0,0,0,0,0,2,2,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,1,0,0,0,0,0,0,0,0,0,1,0,2
  .byte 2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
room2:
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,2,2,2,2,0,0,2,2,2,2,0,0,2
  .byte 2,0,0,2,0,0,0,0,0,0,0,0,2,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,2,0,0,0,0,0,0,0,0,2,0,0,2
  .byte 2,0,0,2,2,2,2,0,0,2,2,2,2,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,1,0,0,0,0,0,0,0,0,0,1,0,2
  .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
room3:
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
  .byte 2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
  .byte 2,0,0,0,0,2,2,4,4,2,2,0,0,0,0,2
  .byte 2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2
  .byte 2,0,0,0,0,2,0,0,0,0,2,0,0,0,0,2
  .byte 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
  .byte 5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5
mel_note:
  .byte 1,2,3,4,2,2,5,2,3,6,1,6,3,7,4,6
  .byte 4,7,8,3,2,1,5,2,3,2,5,4,7,9,10,7
  .byte 8,4,11,255
mel_dur:
  .byte 13,13,13,6,6,13,13,13,13,13,13,13,13,13,13,13
  .byte 6,6,20,6,13,13,13,13,13,6,6,13,13,13,6,6
  .byte 27,13,13,0
bas_note:
  .byte 12,13,12,13,14,15,14,15,15,16,15,16,17,18,17,18
  .byte 12,13,12,13,14,15,14,15,17,18,17,18,19,20,19,20
  .byte 255
bas_dur:
  .byte 13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
  .byte 13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13
  .byte 0
pul_lo:
  .byte 0,82,253,213,225,63,28,189,169,142,159,12,248,166,0,86
  .byte 58,116,249,76,137
pul_hi:
  .byte 0,1,0,0,0,1,1,0,0,0,0,1,3,2,5,3
  .byte 2,4,2,5,3
tri_lo:
  .byte 0,169,126,106,112,159,142,94,84,70,79,134,251,82,128,171
  .byte 28,58,124,166,196
tri_hi:
  .byte 0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,1
  .byte 1,2,1,2,1
str_title:
  .byte 33,43,23,26,36,35,0,28,32,19,30,31,255,34,74,27
  .byte 29,19,30,30,0,30,31,17,29,31,255,0
str_over:
  .byte 33,139,20,17,24,19,0,26,33,19,29,255,34,10,27,29
  .byte 19,30,30,0,30,31,17,29,31,255,0
str_win:
  .byte 33,108,35,26,32,0,34,22,25,16,255,33,204,31,21,19
  .byte 0,19,25,18,255,34,74,27,29,19,30,30,0,30,31,17
  .byte 29,31,255,0
