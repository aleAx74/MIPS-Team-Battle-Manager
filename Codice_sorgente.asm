.data
jump_table: .word do_popola_dati, insert_gioc, insert_squad, ass_giocatore, do_stampa_giocatori, do_stampa_squad, cerca_per_id, cerca_per_nome, simula_duello, do_simula_partita, do_registra_partita, do_stampa_cronologia, do_classifica_gioc, do_classifica_squadre, do_gioc_forte, do_sq_forte, do_partite_vinte, do_gioc_liberi, do_elimina, do_cerca_roster
msg_menu:              .asciiz "0-19 o Annulla:\n0.Popola dati\n1.Inserisci giocatore\n2.Inserisci squadra\n3.Assegna giocatori\n4.Stampa giocatori\n5.Stampa squadre\n6.Cerca giocatore per ID\n7.Cerca squadra per nome\n8.Duello\n9.Simula partita\n10.Registra partita\n11.Cronologia\n12.Classifica giocatori\n13.Classifica squadre\n14.Giocatore piu forte\n15.Squadra piu forte\n16.Partite vinte da squadra\n17.Giocatori senza squadra\n18.Elimina giocatore/squadra\n19.Cerca in roster\n"
msg_non_valido:        .asciiz "input non valido\n"
msg_cerca_id:          .asciiz "id da cercare: "
msg_cerca_nome:        .asciiz "nome squadra: "
msg_id_g1:             .asciiz "id giocatore 1: "
msg_id_g2:             .asciiz "id giocatore 2: "
msg_gioc_non_trovato:  .asciiz "giocatore non trovato\n"
msg_squad_non_trovata: .asciiz "squadra non trovata\n"
msg_id_squadra_ass:    .asciiz "id squadra: "
msg_id_gioc_ass:       .asciiz "id giocatore: "
msg_altri_gioc_ass:    .asciiz "altro giocatore?"
msg_squad_piena:       .asciiz "squadra piena (max 5)\n"
msg_gioc_assegnato:    .asciiz "giocatore assegnato\n"
msg_elim_tipo:         .asciiz "1=giocatore  2=squadra: "
msg_trovato_roster:    .asciiz "trovato nello slot: "
msg_non_trovato_roster:.asciiz "giocatore non nel roster\n"

.text
.globl main
# s0=giocatori  s1=squadre  s5=partite

main:
    li   $a0, 52
    jal  create_arrayList
    move $s0, $v0
    li   $a0, 56
    jal  create_arrayList
    move $s1, $v0
    li   $a0, 32
    jal  create_arrayList
    move $s5, $v0
menu:
    li   $v0, 51
    la   $a0, msg_menu
    syscall
    beq  $a1, 0xfffffffe, fine
    slti $t0, $a0, 20
    beq  $zero, $t0, bad
    bltz $a0, bad
    la   $t1, jump_table
    sll  $t0, $a0, 2
    add  $t2, $t0, $t1
    lw   $t3, 0($t2)
    jr   $t3
bad:
    li   $v0, 55
    la   $a0, msg_non_valido
    syscall
    j    menu

# 0. POPOLA DATI
do_popola_dati:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s5
    jal  popola_dati
    j    menu

# 1. INSERISCI GIOCATORE
insert_gioc:
    jal  crea_giocatore
    move $a0, $s0
    move $a1, $v0
    jal  aggiungi_dato
    j    menu

# 2. INSERISCI SQUADRA
insert_squad:
    move $a0, $s0
    jal  crea_squadra
    move $a0, $s1
    move $a1, $v0
    jal  aggiungi_dato
    j    menu

# 3. ASSEGNA GIOCATORI
ass_giocatore:
    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s2, 8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
ass_sq:
    li   $v0, 51
    la   $a0, msg_id_squadra_ass
    syscall
    bne  $a1, $zero, ass_sq
    move $s3, $a0
    move $a0, $s1
    move $a1, $s3
    jal  cerca_ptr
    move $s2, $v0
    beq  $s2, $zero, ass_sqno
ass_loop:
ass_gi:
    li   $v0, 51
    la   $a0, msg_id_gioc_ass
    syscall
    bne  $a1, $zero, ass_gi
    move $s3, $a0
    move $a0, $s0
    move $a1, $s3
    jal  cerca_ptr
    move $s4, $v0
    beq  $s4, $zero, ass_gno
    li   $t0, 0
ass_slot:
    slti $t1, $t0, 5
    beq  $t1, $zero, ass_piena
    sll  $t1, $t0, 2
    addi $t1, $t1, 24
    add  $t1, $t1, $s2
    lw   $t2, 0($t1)
    beq  $t2, $zero, ass_ok
    addi $t0, $t0, 1
    j    ass_slot
ass_ok:
    sw   $s3, 0($t1)
    lw   $t3, 0($s2)
    sw   $t3, 48($s4)
    li   $v0, 4
    la   $a0, msg_gioc_assegnato
    syscall
    j    ass_altro
ass_piena:
    li   $v0, 4
    la   $a0, msg_squad_piena
    syscall
    j    ass_fine
ass_gno:
    li   $v0, 4
    la   $a0, msg_gioc_non_trovato
    syscall
ass_altro:
    li   $v0, 50
    la   $a0, msg_altri_gioc_ass
    syscall
    beq  $a0, 2, ass_altro
    beq  $a0, 0, ass_loop
    j    ass_fine
ass_sqno:
    li   $v0, 4
    la   $a0, msg_squad_non_trovata
    syscall
ass_fine:
    lw   $ra, 12($sp)
    lw   $s2, 8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 16
    j    menu

# 4-5. STAMPA
do_stampa_giocatori:
    move $a0, $s0
    jal  stampa_giocatori
    j    menu
do_stampa_squad:
    move $a0, $s1
    jal  stampa_squadre
    j    menu

# 6. CERCA GIOCATORE PER ID
cerca_per_id:
cp_id:
    li   $v0, 51
    la   $a0, msg_cerca_id
    syscall
    bne  $a1, $zero, cp_id
    move $a1, $a0
    move $a0, $s0
    jal  stampa_giocatore_per_id
    j    menu

# 7. CERCA SQUADRA PER NOME
cerca_per_nome:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    li   $v0, 54
    la   $a0, msg_cerca_nome
    addi $a1, $sp, 0
    li   $a2, 20
    syscall
    addi $t0, $sp, 0
cn_sn:
    lb   $t1, 0($t0)
    beq  $t1, $zero, cn_sd
    li   $t2, 10
    beq  $t1, $t2, cn_sf
    addi $t0, $t0, 1
    j    cn_sn
cn_sf:
    sb   $zero, 0($t0)
cn_sd:
    move $a0, $s1
    addi $a1, $sp, 0
    jal  stampa_squadra_per_nome
    lw   $ra, 20($sp)
    addi $sp, $sp, 24
    j    menu

# 8. DUELLO
simula_duello:
    addi $sp, $sp, -16
    sw   $s2,  0($sp)
    sw   $s3,  4($sp)
    sw   $s4,  8($sp)
    sw   $ra, 12($sp)
duel_g1:
    li   $v0, 51
    la   $a0, msg_id_g1
    syscall
    bne  $a1, $zero, duel_g1
    move $s2, $a0
duel_g2:
    li   $v0, 51
    la   $a0, msg_id_g2
    syscall
    bne  $a1, $zero, duel_g2
    move $s3, $a0
    move $a0, $s0
    move $a1, $s2
    jal  cerca_ptr
    move $s4, $v0
    beq  $s4, $zero, du_no
    move $a0, $s0
    move $a1, $s3
    jal  cerca_ptr
    beq  $v0, $zero, du_no
    move $a0, $s4
    move $a1, $v0
    jal  duello
    j    du_fine
du_no:
    li   $v0, 4
    la   $a0, msg_gioc_non_trovato
    syscall
du_fine:
    lw   $s2,  0($sp)
    lw   $s3,  4($sp)
    lw   $s4,  8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    j    menu

# 9-13. DELEGHE
do_simula_partita:
    move $a0, $s1
    move $a1, $s0
    move $a2, $s5
    jal  simula_partita
    j    menu
do_registra_partita:
    move $a0, $s1
    move $a1, $s5
    jal  registra_partita
    j    menu
do_stampa_cronologia:
    move $a0, $s5
    move $a1, $s1
    jal  stampa_cronologia
    j    menu
do_classifica_gioc:
    move $a0, $s0
    jal  stampa_classifica_giocatori
    j    menu
do_classifica_squadre:
    move $a0, $s1
    jal  stampa_classifica_squadre
    j    menu

# 14. GIOCATORE PIU' FORTE
do_gioc_forte:
    move $a0, $s0
    jal  giocatore_piu_forte
    j    menu

# 15. SQUADRA PIU' FORTE
do_sq_forte:
    move $a0, $s1
    move $a1, $s0
    jal  squadra_piu_forte
    j    menu

# 16. PARTITE VINTE DA UNA SQUADRA
do_partite_vinte:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
dpv_id:
    li   $v0, 51
    la   $a0, msg_cerca_id
    syscall
    bne  $a1, $zero, dpv_id
    move $a1, $a0
    move $a0, $s5
    jal  partite_vinte_squadra
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    j    menu

# 17. GIOCATORI SENZA SQUADRA
do_gioc_liberi:
    move $a0, $s0
    jal  giocatori_liberi
    j    menu

# 18. ELIMINAZIONE LOGICA (1=giocatore, 2=squadra)
do_elimina:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
del_tipo:
    li   $v0, 51
    la   $a0, msg_elim_tipo
    syscall
    bne  $a1, $zero, del_tipo
    move $t6, $a0
del_id:
    li   $v0, 51
    la   $a0, msg_cerca_id
    syscall
    bne  $a1, $zero, del_id
    move $t7, $a0
    li   $t0, 1
    bne  $t6, $t0, del_sq
    move $a0, $s0
    move $a1, $t7
    jal  elimina_giocatore
    j    del_fine
del_sq:
    li   $t0, 2
    bne  $t6, $t0, del_fine
    move $a0, $s1
    move $a1, $t7
    jal  elimina_squadra
del_fine:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    j    menu

# 19. RICERCA RICORSIVA NEL ROSTER
do_cerca_roster:
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s6, 0($sp)
dcr_sq:
    li   $v0, 51
    la   $a0, msg_id_squadra_ass
    syscall
    bne  $a1, $zero, dcr_sq
    move $t6, $a0               # salva id squadra subito
    move $a0, $s1               # arraylist squadre
    move $a1, $t6               # id da cercare
    jal  cerca_ptr
    beq  $v0, $zero, dcr_sqno
    move $s6, $v0               # s6 = ptr squadra trovata
dcr_gi:
    li   $v0, 51
    la   $a0, msg_id_gioc_ass
    syscall
    bne  $a1, $zero, dcr_gi
    move $t7, $a0               # id giocatore da cercare nel roster
    move $a0, $s6               # ptr squadra
    move $a1, $t7               # id giocatore
    li   $a2, 0                 # slot iniziale
    jal  cerca_in_roster_ricorsivo
    move $t8, $v0
    li   $t0, -1
    beq  $t8, $t0, dcr_no
    li   $v0, 4
    la   $a0, msg_trovato_roster
    syscall
    li   $v0, 1
    move $a0, $t8
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    j    dcr_fine
dcr_no:
    li   $v0, 4
    la   $a0, msg_non_trovato_roster
    syscall
    j    dcr_fine
dcr_sqno:
    li   $v0, 4
    la   $a0, msg_squad_non_trovata
    syscall
dcr_fine:
    lw   $ra, 4($sp)
    lw   $s6, 0($sp)
    addi $sp, $sp, 8
    j    menu

fine:
    li   $v0, 10
    syscall
























.globl create_arrayList
.globl aggiungi_dato
.globl resize

.text

# Header: 0=base 4=size 8=capacity 12=bpe
create_arrayList:           # IN: $a0=bpe  OUT: $v0=header
    move $t9, $a0
    li   $a0, 16
    li   $v0, 9
    syscall
    move $t0, $v0
    sw   $zero, 4($t0)
    li   $t1, 20
    sw   $t1,  8($t0)
    sw   $t9, 12($t0)
    mul  $a0, $t1, $t9
    li   $v0, 9
    syscall
    sw   $v0, 0($t0)
    move $v0, $t0
    jr   $ra

aggiungi_dato:              # IN: $a0=arraylist $a1=src
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $a0, 4($sp)
    sw   $a1, 0($sp)
    lw   $t0, 4($a0)
    lw   $t1, 8($a0)
    lw   $t9, 12($a0)
    bne  $t0, $t1, ad_ins
    jal  resize
    lw   $a1, 0($sp)
    lw   $a0, 4($sp)
ad_ins:
    lw   $t2, 0($a0)
    lw   $t0, 4($a0)
    lw   $t9, 12($a0)
    mul  $t3, $t0, $t9
    add  $t4, $t2, $t3
    li   $t5, 0
ad_cp:
    beq  $t5, $t9, ad_done
    lw   $t6, 0($a1)
    sw   $t6, 0($t4)
    addi $a1, $a1, 4
    addi $t4, $t4, 4
    addi $t5, $t5, 4
    j    ad_cp
ad_done:
    addi $t0, $t0, 1
    sw   $t0, 4($a0)
    lw   $ra, 8($sp)
    addi $sp, $sp, 12
    jr   $ra

resize:                     # IN: $a0=arraylist
    addi $sp, $sp, -16
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $ra, 12($sp)
    move $s0, $a0
    lw   $t0, 8($s0)
    lw   $s1, 12($s0)
    sll  $s2, $t0, 1
    mul  $a0, $s2, $s1
    li   $v0, 9
    syscall
    move $t4, $v0
    lw   $t5, 0($s0)
    lw   $t6, 4($s0)
    li   $t7, 0
rz_el:
    beq  $t7, $t6, rz_done
    mul  $t0, $t7, $s1
    add  $t1, $t5, $t0
    add  $t2, $t4, $t0
    li   $t3, 0
rz_by:
    beq  $t3, $s1, rz_nx
    lw   $t0, 0($t1)
    sw   $t0, 0($t2)
    addi $t1, $t1, 4
    addi $t2, $t2, 4
    addi $t3, $t3, 4
    j    rz_by
rz_nx:
    addi $t7, $t7, 1
    j    rz_el
rz_done:
    sw   $t4, 0($s0)
    sw   $s2, 8($s0)
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $ra, 12($sp)
    addi $sp, $sp, 16
    jr   $ra





















.data
msg_id:          .asciiz "id: "
msg_nickname:    .asciiz "nome: "
msg_livello:     .asciiz "livello: "
msg_attacco:     .asciiz "attacco: "
msg_difesa:      .asciiz "difesa: "
msg_energia:     .asciiz "energia: "
msg_vittorie:    .asciiz "vittorie: "
msg_sconfitte:   .asciiz "sconfitte: "
msg_attivo:      .asciiz "attivo?"
msg_cod_squadra: .asciiz "id squadra (0=nessuna): "
msg_gioc_eliminato: .asciiz "giocatore eliminato\n"
msg_gioc_el_nontrov:.asciiz "giocatore non trovato\n"
.align 2
giocatore_memoria: .space 52

.text
.globl crea_giocatore
.globl elimina_giocatore

# 52 byte: 0=id 4=nick(16B) 20=liv 24=att 28=dif 32=en 36=vit 40=sco 44=attivo 48=cod_sq
crea_giocatore:
    la   $t0, giocatore_memoria
gcr_id:
    li $v0, 51
    la $a0, msg_id
    syscall
    bne  $a1, $zero, gcr_id
    sw   $a0, 0($t0)
    li   $v0, 54
    la   $a0, msg_nickname
    addi $a1, $t0, 4
    li   $a2, 16
    syscall
    # strip \n dal nickname
    addi $t1, $t0, 4
gcr_sn:
    lb   $t2, 0($t1)
    beq  $t2, $zero, gcr_liv
    li   $t3, 10
    beq  $t2, $t3, gcr_sf
    addi $t1, $t1, 1
    j    gcr_sn
gcr_sf:
    sb   $zero, 0($t1)
gcr_liv:
    li $v0, 51
    la $a0, msg_livello
    syscall
    bne  $a1, $zero, gcr_liv
    sw   $a0, 20($t0)
gcr_att:
    li $v0, 51
    la $a0, msg_attacco
    syscall
    bne  $a1, $zero, gcr_att
    sw   $a0, 24($t0)
gcr_dif:
    li $v0, 51
    la $a0, msg_difesa
    syscall
    bne  $a1, $zero, gcr_dif
    sw   $a0, 28($t0)
gcr_en:
    li $v0, 51
    la $a0, msg_energia
    syscall
    bne  $a1, $zero, gcr_en
    sw   $a0, 32($t0)
gcr_vit:
    li $v0, 51
    la $a0, msg_vittorie
    syscall
    bne  $a1, $zero, gcr_vit
    sw   $a0, 36($t0)
gcr_sco:
    li $v0, 51
    la $a0, msg_sconfitte
    syscall
    bne  $a1, $zero, gcr_sco
    sw   $a0, 40($t0)
gcr_at2:
    li $v0, 50
    la $a0, msg_attivo
    syscall
    beq  $a0, 2, gcr_at2
    sw   $a0, 44($t0)
gcr_sq:
    li $v0, 51
    la $a0, msg_cod_squadra
    syscall
    bne  $a1, $zero, gcr_sq
    sw   $a0, 48($t0)
    move $v0, $t0
    jr   $ra

# 18a. elimina_giocatore
# IN:  $a0 = arraylist giocatori
#      $a1 = id da eliminare
# Eliminazione logica: pone attivo = 1  (offset 44)
elimina_giocatore:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    jal  cerca_ptr
    beq  $v0, $zero, eg_no
    li   $t0, 1
    sw   $t0, 44($v0)       
    li   $v0, 4
    la   $a0, msg_gioc_eliminato
    syscall
    j    eg_fine
eg_no:
    li   $v0, 4
    la   $a0, msg_gioc_el_nontrov
    syscall
eg_fine:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
























.data
msg_id_squadra:          .asciiz "id squadra: "
msg_nome_squadra:        .asciiz "nome squadra: "
msg_id_giocatore:        .asciiz "id giocatore (0=fine): "
msg_altri_gioc:          .asciiz "altri giocatori?"
msg_vittorie_sq:         .asciiz "vittorie: "
msg_sconfitte_sq:        .asciiz "sconfitte: "
msg_attivo_sq:           .asciiz "squadra attiva?"
msg_gioc_non_trovato_sq: .asciiz "giocatore non trovato\n"
msg_sq_eliminata:        .asciiz "squadra eliminata\n"
msg_sq_el_nontrov:       .asciiz "squadra non trovata\n"
.align 2
squadra_buffer: .space 56

.text
.globl crea_squadra
.globl elimina_squadra
.globl cerca_in_roster_ricorsivo

# 56 byte: 0=id 4=nome(20B) 24-40=gioc[5] 44=vit 48=sco 52=attivo
crea_squadra:               # IN: $a0=arraylist giocatori  OUT: $v0=squadra_buffer
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $s0, 4($sp)
    sw   $s1, 0($sp)
    move $s0, $a0
    la   $s1, squadra_buffer
    sw   $zero, 24($s1)
    sw   $zero, 28($s1)
    sw   $zero, 32($s1)
    sw   $zero, 36($s1)
    sw   $zero, 40($s1)
scr_id:
    li $v0, 51
    la $a0, msg_id_squadra
    syscall
    bne  $a1, $zero, scr_id
    sw   $a0, 0($s1)
    li   $v0, 54
    la   $a0, msg_nome_squadra
    addi $a1, $s1, 4
    li   $a2, 20
    syscall
    # strip \n dal nome
    addi $t0, $s1, 4
scr_sn:
    lb   $t1, 0($t0)
    beq  $t1, $zero, scr_gi
    li   $t2, 10
    beq  $t1, $t2, scr_sf
    addi $t0, $t0, 1
    j    scr_sn
scr_sf:
    sb   $zero, 0($t0)
    li   $t8, 0                 # indice slot
scr_gi:
    slti $t9, $t8, 5
    beq  $t9, $zero, scr_st
scr_ig:
    li $v0, 51
    la $a0, msg_id_giocatore
    syscall
    bne  $a1, $zero, scr_ig
    beq  $a0, $zero, scr_st
    move $t7, $a0
    move $a0, $s0
    move $a1, $t7
    jal  cerca_ptr
    beq  $v0, $zero, scr_gnt
    sll  $t9, $t8, 2
    addi $t9, $t9, 24
    add  $t9, $t9, $s1
    sw   $t7, 0($t9)
    lw   $t9, 0($s1)
    sw   $t9, 48($v0)
    addi $t8, $t8, 1
    slti $t9, $t8, 5
    beq  $t9, $zero, scr_st
scr_al:
    li $v0, 50
    la $a0, msg_altri_gioc
    syscall
    beq  $a0, 2, scr_al
    beq  $a0, 0, scr_gi
    j    scr_st
scr_gnt:
    li $v0, 4
    la $a0, msg_gioc_non_trovato_sq
    syscall
    j    scr_ig
scr_st:
scr_vit:
    li $v0, 51
    la $a0, msg_vittorie_sq
    syscall
    bne  $a1, $zero, scr_vit
    sw   $a0, 44($s1)
scr_sco:
    li $v0, 51
    la $a0, msg_sconfitte_sq
    syscall
    bne  $a1, $zero, scr_sco
    sw   $a0, 48($s1)
scr_att:
    li $v0, 50
    la $a0, msg_attivo_sq
    syscall
    beq  $a0, 2, scr_att
    sw   $a0, 52($s1)
    move $v0, $s1
    lw   $ra, 8($sp)
    lw   $s0, 4($sp)
    lw   $s1, 0($sp)
    addi $sp, $sp, 12
    jr   $ra


# 18b. elimina_squadra
# IN:  $a0 = arraylist squadre
#      $a1 = id da eliminare
# Eliminazione logica: pone attivo = 1  (offset 52)

elimina_squadra:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    jal  cerca_ptr
    beq  $v0, $zero, es_no
    li   $t0, 1
    sw   $t0, 52($v0)       
    li   $v0, 4
    la   $a0, msg_sq_eliminata
    syscall
    j    es_fine
es_no:
    li   $v0, 4
    la   $a0, msg_sq_el_nontrov
    syscall
es_fine:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra


# 19. cerca_in_roster_ricorsivo  (funzione ricorsiva)
#     IN:  $a0 = ptr squadra
#          $a1 = id giocatore cercato
#          $a2 = indice slot corrente  (prima chiamata: 0)
#     OUT: $v0 = indice slot (0-4) se trovato, -1 se non trovato
#
#     Caso base:  slot >= 5  =>  ritorna -1
#     Passo ric.: se gioc[slot] == id  => ritorna slot
#                 altrimenti chiama se stessa con slot+1

cerca_in_roster_ricorsivo:
    addi $sp, $sp, -16
    sw   $ra,  12($sp)
    sw   $s0,   8($sp)
    sw   $s1,   4($sp)
    sw   $s2,   0($sp)
    move $s0, $a0           # ptr squadra
    move $s1, $a1           # id cercato
    move $s2, $a2           # indice slot corrente

    slti $t0, $s2, 5       
    beq  $t0, $zero, cirr_no  # caso base

    sll  $t1, $s2, 2        
    addi $t1, $t1, 24       
    add  $t1, $t1, $s0      
    lw   $t2, 0($t1)        # id in questo slot

    bne  $t2, $s1, cirr_next
    move $v0, $s2           # trovato: ritorna indice slot
    j    cirr_ret

cirr_next:
    move $a0, $s0
    move $a1, $s1
    addi $a2, $s2, 1        # slot + 1
    jal  cerca_in_roster_ricorsivo
    j    cirr_ret

cirr_no:
    li   $v0, -1

cirr_ret:
    lw   $ra,  12($sp)
    lw   $s0,   8($sp)
    lw   $s1,   4($sp)
    lw   $s2,   0($sp)
    addi $sp, $sp, 16
    jr   $ra






























.data
msg_separatore:    .asciiz "-------------------------\n"
msg_newline:       .asciiz "\n"
msg_id_s:          .asciiz "ID: "
msg_nickname_s:    .asciiz "Nome: "
msg_livello_s:     .asciiz "Livello: "
msg_attacco_s:     .asciiz "Attacco: "
msg_difesa_s:      .asciiz "Difesa: "
msg_energia_s:     .asciiz "Energia: "
msg_vittorie_s:    .asciiz "Vittorie: "
msg_sconfitte_s:   .asciiz "Sconfitte: "
msg_attivo_s:      .asciiz "Attivo: "
msg_cod_squadra_s: .asciiz "Squadra: "
msg_si:            .asciiz "si\n"
msg_no:            .asciiz "no\n"
msg_nessuna:       .asciiz "nessuna\n"
msg_id_sq_s:       .asciiz "ID squadra: "
msg_nome_sq_s:     .asciiz "Nome squadra: "
msg_gioc_sq_s:     .asciiz "Giocatori: "
msg_vittorie_sq_s: .asciiz "Vittorie: "
msg_sconfitte_sq_s:.asciiz "Sconfitte: "
msg_virgola:       .asciiz ", "
msg_gioc_forte:    .asciiz "=== GIOCATORE PIU' FORTE ===\n"
msg_sq_forte:      .asciiz "=== SQUADRA PIU' FORTE ===\n"
msg_potenza:       .asciiz "  Potenza: "
msg_nessun_gioc:   .asciiz "nessun giocatore presente\n"
msg_nessuna_sq:    .asciiz "nessuna squadra presente\n"
msg_titolo_liberi: .asciiz "=== GIOCATORI SENZA SQUADRA ===\n"
msg_nessun_libero: .asciiz "nessun giocatore senza squadra\n"

.text
.globl stampa_giocatore
.globl stampa_giocatori
.globl stampa_giocatore_per_id
.globl cerca_ptr
.globl cerca_puntatore_per_id
.globl cerca_puntatore_per_id_squadra
.globl stampa_squadra
.globl stampa_squadre
.globl stampa_squadra_per_nome
.globl confronta_stringhe
.globl giocatore_piu_forte
.globl squadra_piu_forte
.globl giocatori_liberi

# cerca_ptr  IN: $a0=arraylist $a1=id  OUT: $v0=ptr o 0
cerca_ptr:
cerca_puntatore_per_id:
cerca_puntatore_per_id_squadra:
    lw   $t0, 0($a0)
    lw   $t1, 4($a0)
    lw   $t2, 12($a0)
    li   $t3, 0
cp_lp:
    beq  $t3, $t1, cp_no
    mul  $t4, $t3, $t2
    add  $t5, $t0, $t4
    lw   $t6, 0($t5)
    beq  $t6, $a1, cp_ok
    addi $t3, $t3, 1
    j    cp_lp
cp_ok:
    move $v0, $t5
    jr   $ra
cp_no:
    li   $v0, 0
    jr   $ra

# stampa_giocatore  IN: $a0=ptr giocatore
stampa_giocatore:
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)
    move $s0, $a0
    beq  $s0, $zero, sg_fine
    li   $v0, 4
    la   $a0, msg_separatore
    syscall
    la   $a0, msg_id_s
    syscall
    li   $v0, 1
    lw   $a0, 0($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_nickname_s
    syscall
    addi $a0, $s0, 4
    syscall
    la   $a0, msg_newline
    syscall
    la   $a0, msg_livello_s
    syscall
    li   $v0, 1
    lw   $a0, 20($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_attacco_s
    syscall
    li   $v0, 1
    lw   $a0, 24($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_difesa_s
    syscall
    li   $v0, 1
    lw   $a0, 28($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_energia_s
    syscall
    li   $v0, 1
    lw   $a0, 32($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_vittorie_s
    syscall
    li   $v0, 1
    lw   $a0, 36($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_sconfitte_s
    syscall
    li   $v0, 1
    lw   $a0, 40($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_attivo_s
    syscall
    lw   $t0, 44($s0)
    beq  $t0, $zero, sg_si
    la   $a0, msg_no
    syscall
    j    sg_sq
sg_si:
    la   $a0, msg_si
    syscall
sg_sq:
    la   $a0, msg_cod_squadra_s
    syscall
    lw   $t0, 48($s0)
    beq  $t0, $zero, sg_ness
    li   $v0, 1
    move $a0, $t0
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    j    sg_fine
sg_ness:
    la   $a0, msg_nessuna
    syscall
sg_fine:
    lw   $ra, 4($sp)
    lw   $s0, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# stampa_giocatori  IN: $a0=arraylist
stampa_giocatori:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size
    li   $s4, 0             # contatore
sgi_lp:
    beq  $s4, $s2, sgi_fine
    mul  $t0, $s4, $s3
    add  $t1, $s1, $t0
    lw   $t2, 44($t1)       # attivo (!=0 = eliminato)
    bne  $t2, $zero, sgi_nx
    move $a0, $t1
    jal  stampa_giocatore
sgi_nx:
    addi $s4, $s4, 1
    j    sgi_lp
sgi_fine:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# stampa_giocatore_per_id  IN: $a0=arraylist $a1=id
stampa_giocatore_per_id:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    jal  cerca_ptr
    beq  $v0, $zero, sgid_no
    move $a0, $v0
    jal  stampa_giocatore
    j    sgid_fine
sgid_no:
    li   $v0, 4
    la   $a0, msg_gioc_non_trovato
    syscall
sgid_fine:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# stampa_squadra  IN: $a0=ptr squadra
stampa_squadra:
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)
    move $s0, $a0
    li   $v0, 4
    la   $a0, msg_separatore
    syscall
    la   $a0, msg_id_sq_s
    syscall
    li   $v0, 1
    lw   $a0, 0($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_nome_sq_s
    syscall
    addi $a0, $s0, 4
    syscall
    la   $a0, msg_newline
    syscall
    la   $a0, msg_gioc_sq_s
    syscall
    li   $t0, 0
ssq_sl:
    slti $t1, $t0, 5
    beq  $t1, $zero, ssq_sf
    sll  $t1, $t0, 2
    addi $t1, $t1, 24
    add  $t1, $t1, $s0
    lw   $t2, 0($t1)
    beq  $t2, $zero, ssq_sk
    li   $v0, 1
    move $a0, $t2
    syscall
    li   $v0, 4
    la   $a0, msg_virgola
    syscall
ssq_sk:
    addi $t0, $t0, 1
    j    ssq_sl
ssq_sf:
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_vittorie_sq_s
    syscall
    li   $v0, 1
    lw   $a0, 44($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_sconfitte_sq_s
    syscall
    li   $v0, 1
    lw   $a0, 48($s0)
    syscall
    li   $v0, 4
    la   $a0, msg_attivo_s
    syscall
    lw   $t0, 52($s0)
    beq  $t0, $zero, ssq_si
    la   $a0, msg_no
    syscall
    j    ssq_fine
ssq_si:
    la   $a0, msg_si
    syscall
ssq_fine:
    lw   $ra, 4($sp)
    lw   $s0, 0($sp)
    addi $sp, $sp, 8
    jr   $ra

# stampa_squadre  IN: $a0=arraylist
stampa_squadre:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size
    li   $s4, 0             # contatore
ssql_lp:
    beq  $s4, $s2, ssql_fine
    mul  $t0, $s4, $s3
    add  $t1, $s1, $t0
    lw   $t2, 52($t1)       # attivo squadra (!=0 = eliminata)
    bne  $t2, $zero, ssql_nx
    move $a0, $t1
    jal  stampa_squadra
ssql_nx:
    addi $s4, $s4, 1
    j    ssql_lp
ssql_fine:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# stampa_squadra_per_nome  IN: $a0=arraylist $a1=stringa
stampa_squadra_per_nome:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s0, 20($sp)
    sw   $s1, 16($sp)
    sw   $s2, 12($sp)
    sw   $s3,  8($sp)
    sw   $s4,  4($sp)
    sw   $s5,  0($sp)
    move $s0, $a0
    move $s1, $a1
    lw   $s2, 0($s0)
    lw   $s3, 4($s0)
    lw   $s4, 12($s0)
    li   $s5, 0
snm_lp:
    beq  $s5, $s3, snm_no
    mul  $t0, $s5, $s4
    add  $t8, $s2, $t0
    addi $a0, $t8, 4
    move $a1, $s1
    jal  confronta_stringhe
    beq  $v0, $zero, snm_sk
    move $a0, $t8
    jal  stampa_squadra
    j    snm_fine
snm_sk:
    addi $s5, $s5, 1
    j    snm_lp
snm_no:
    li   $v0, 4
    la   $a0, msg_squad_non_trovata
    syscall
snm_fine:
    lw   $ra, 24($sp)
    lw   $s0, 20($sp)
    lw   $s1, 16($sp)
    lw   $s2, 12($sp)
    lw   $s3,  8($sp)
    lw   $s4,  4($sp)
    lw   $s5,  0($sp)
    addi $sp, $sp, 28
    jr   $ra

# confronta_stringhe  IN: $a0=s1 $a1=s2  OUT: $v0=1 uguali 0 diversi
confronta_stringhe:
cs_lp:
    lb   $t0, 0($a0)
    lb   $t1, 0($a1)
    bne  $t0, $t1, cs_no
    beq  $t0, $zero, cs_si
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j    cs_lp
cs_si:
    li   $v0, 1
    jr   $ra
cs_no:
    li   $v0, 0
    jr   $ra


# 14. giocatore_piu_forte
#     IN:  $a0 = arraylist giocatori
#     Potenza = lv + att + dif + en  (offset 20/24/28/32)
#     Salta i giocatori con attivo != 0 (eliminati logicamente)
giocatore_piu_forte:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size
    beq  $s2, $zero, gpf_vuoto

    li   $v0, 4
    la   $a0, msg_gioc_forte
    syscall

    li   $s4, 0             # indice corrente
    li   $t8, -1            # indice miglior giocatore
    li   $t9, -1            # potenza massima

gpf_lp:
    beq  $s4, $s2, gpf_stampa
    mul  $t0, $s4, $s3
    add  $t0, $t0, $s1      # ptr giocatore corrente
    lw   $t1, 44($t0)       # flag attivo (!=0 = eliminato)
    bne  $t1, $zero, gpf_nx
    lw   $t1, 20($t0)       # livello
    lw   $t2, 24($t0)       # attacco
    lw   $t3, 28($t0)       # difesa
    lw   $t4, 32($t0)       # energia
    add  $t1, $t1, $t2
    add  $t1, $t1, $t3
    add  $t1, $t1, $t4      # potenza totale
    ble  $t1, $t9, gpf_nx
    move $t9, $t1
    move $t8, $s4
gpf_nx:
    addi $s4, $s4, 1
    j    gpf_lp

gpf_stampa:
    beq  $t8, -1, gpf_vuoto
    mul  $t0, $t8, $s3
    add  $a0, $t0, $s1
    jal  stampa_giocatore
    li   $v0, 4
    la   $a0, msg_potenza
    syscall
    li   $v0, 1
    move $a0, $t9
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    j    gpf_fine

gpf_vuoto:
    li   $v0, 4
    la   $a0, msg_nessun_gioc
    syscall

gpf_fine:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra
    
# 15. squadra_piu_forte
#     IN:  $a0 = arraylist squadre
#          $a1 = arraylist giocatori
#     Usa calcola_potenza_squadra (Partita.asm)
#     Salta squadre con attivo != 0 (eliminate logicamente)
squadra_piu_forte:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s0, 20($sp)
    sw   $s1, 16($sp)
    sw   $s2, 12($sp)
    sw   $s3,  8($sp)
    sw   $s4,  4($sp)
    sw   $s5,  0($sp)
    move $s0, $a0           # arraylist squadre
    move $s1, $a1           # arraylist giocatori
    lw   $s2, 0($s0)        # base array squadre
    lw   $s3, 4($s0)        # count
    lw   $s4, 12($s0)       # elem size
    beq  $s3, $zero, spf_vuoto

    li   $v0, 4
    la   $a0, msg_sq_forte
    syscall

    li   $s5, 0             # indice corrente
    li   $t8, -1            # indice miglior squadra
    li   $t9, -1            # potenza massima

spf_lp:
    beq  $s5, $s3, spf_stampa
    mul  $t0, $s5, $s4
    add  $t0, $t0, $s2      # ptr squadra corrente
    lw   $t1, 52($t0)       # flag attivo squadra (!=0 = eliminata)
    bne  $t1, $zero, spf_nx
    move $a0, $t0
    move $a1, $s1
    jal  calcola_potenza_squadra
    ble  $v0, $t9, spf_nx
    move $t9, $v0
    move $t8, $s5
spf_nx:
    addi $s5, $s5, 1
    j    spf_lp

spf_stampa:
    beq  $t8, -1, spf_vuoto
    mul  $t0, $t8, $s4
    add  $a0, $t0, $s2
    jal  stampa_squadra
    li   $v0, 4
    la   $a0, msg_potenza
    syscall
    li   $v0, 1
    move $a0, $t9
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    j    spf_fine

spf_vuoto:
    li   $v0, 4
    la   $a0, msg_nessuna_sq
    syscall

spf_fine:
    lw   $ra, 24($sp)
    lw   $s0, 20($sp)
    lw   $s1, 16($sp)
    lw   $s2, 12($sp)
    lw   $s3,  8($sp)
    lw   $s4,  4($sp)
    lw   $s5,  0($sp)
    addi $sp, $sp, 28
    jr   $ra

# 17. giocatori_liberi
#     IN:  $a0 = arraylist giocatori
#     Stampa giocatori con cod_sq == 0 e non eliminati
giocatori_liberi:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size

    li   $v0, 4
    la   $a0, msg_titolo_liberi
    syscall

    li   $s4, 0             # indice
    li   $t8, 0             # contatore trovati

gl_lp:
    beq  $s4, $s2, gl_fine
    mul  $t0, $s4, $s3
    add  $t0, $t0, $s1      # ptr giocatore
    lw   $t1, 44($t0)       # attivo (!=0 = eliminato)
    bne  $t1, $zero, gl_nx
    lw   $t1, 48($t0)       # cod_sq
    bne  $t1, $zero, gl_nx
    move $a0, $t0
    jal  stampa_giocatore
    addi $t8, $t8, 1
gl_nx:
    addi $s4, $s4, 1
    j    gl_lp

gl_fine:
    bne  $t8, $zero, gl_ret
    li   $v0, 4
    la   $a0, msg_nessun_libero
    syscall
gl_ret:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra






















.data
msg_ha_perso: .asciiz " ha perso!\n"
msg_senza_energia: .asciiz "Uno o entrambi i giocatori non hanno energia per combattere\n"

.text
.globl duello

# duello  IN: $a0=g1  $a1=g2   danno=(att+liv)-dif_avv (min 1)
duello:
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $s0, 4($sp)
    sw   $s1, 0($sp)
    move $s0, $a0
    move $s1, $a1
du_loop:
    lw   $t0, 32($s0)
    blez $t0, du_noenergy
    lw   $t0, 32($s1)
    blez $t0, du_noenergy
    # g1 attacca g2
    lw   $t0, 24($s0)
    lw   $t1, 20($s0)
    add  $t0, $t0, $t1
    lw   $t1, 28($s1)
    sub  $t0, $t0, $t1
    slti $t1, $t0, 1
    beq  $t1, $zero, du_d1
    li   $t0, 1
du_d1:
    lw   $t1, 32($s1)
    sub  $t1, $t1, $t0
    sw   $t1, 32($s1)
    bgtz $t1, du_g2t
    # g2 ha perso
    li   $v0, 4
    addi $a0, $s1, 4
    syscall
    la   $a0, msg_ha_perso
    syscall
    lw   $t0, 36($s0)
    addi $t0, $t0, 1
    sw   $t0, 36($s0)
    lw   $t0, 40($s1)
    addi $t0, $t0, 1
    sw   $t0, 40($s1)
    j    du_end
du_g2t:
    # g2 attacca g1
    lw   $t0, 24($s1)
    lw   $t1, 20($s1)
    add  $t0, $t0, $t1
    lw   $t1, 28($s0)
    sub  $t0, $t0, $t1
    slti $t1, $t0, 1
    beq  $t1, $zero, du_d2
    li   $t0, 1
du_d2:
    lw   $t1, 32($s0)
    sub  $t1, $t1, $t0
    sw   $t1, 32($s0)
    bgtz $t1, du_loop
    # g1 ha perso
    li   $v0, 4
    addi $a0, $s0, 4
    syscall
    la   $a0, msg_ha_perso
    syscall
    lw   $t0, 36($s1)
    addi $t0, $t0, 1
    sw   $t0, 36($s1)
    lw   $t0, 40($s0)
    addi $t0, $t0, 1
    sw   $t0, 40($s0)
    j    du_end
du_noenergy:
    li   $v0, 4
    la   $a0, msg_senza_energia
    syscall
du_end:
    lw   $ra, 8($sp)
    lw   $s0, 4($sp)
    lw   $s1, 0($sp)
    addi $sp, $sp, 12
    jr   $ra



















.data
msg_simula_partita:  .asciiz "Simulazione partita\n"
msg_id_squadra_a:    .asciiz "ID squadra A: "
msg_id_squadra_b:    .asciiz "ID squadra B: "
msg_squadra_ntrov:   .asciiz "Squadra non trovata\n"
msg_squadra_vuota:   .asciiz "Squadra senza giocatori validi\n"
msg_vincitore:       .asciiz "\nVincitore ID: "
msg_punteggio:       .asciiz "  Punteggio: "
msg_parita_pareggio: .asciiz "Pareggio\n"
msg_rounds_sim:      .asciiz "  Round: "

.text
.globl simula_partita
.globl calcola_potenza_squadra

# simula_partita  IN: $a0=squadre $a1=giocatori $a2=partite
simula_partita:
    addi $sp, $sp, -32
    sw   $ra, 28($sp)
    sw   $s0, 24($sp)
    sw   $s1, 20($sp)
    sw   $s2, 16($sp)
    sw   $s3, 12($sp)
    sw   $s4,  8($sp)
    sw   $s5,  4($sp)
    sw   $s6,  0($sp)
    move $s0, $a0
    move $s1, $a1
    move $s6, $a2
    li   $v0, 4
    la   $a0, msg_simula_partita
    syscall
sp_ida:
    li   $v0, 51
    la   $a0, msg_id_squadra_a
    syscall
    bne  $a1, $zero, sp_ida
    move $s2, $a0
sp_idb:
    li   $v0, 51
    la   $a0, msg_id_squadra_b
    syscall
    bne  $a1, $zero, sp_idb
    move $s3, $a0
    move $a0, $s0
    move $a1, $s2
    jal  cerca_ptr
    move $s4, $v0
    beq  $s4, $zero, sp_no
    move $a0, $s0
    move $a1, $s3
    jal  cerca_ptr
    move $s5, $v0
    beq  $s5, $zero, sp_no
    move $a0, $s4
    move $a1, $s1
    jal  calcola_potenza_squadra
    move $t6, $v0
    move $a0, $s5
    move $a1, $s1
    jal  calcola_potenza_squadra
    move $t7, $v0
    beq  $t6, $zero, sp_chb
    bne  $t7, $zero, sp_cmp
sp_chb:
    beq  $t7, $zero, sp_inv
sp_cmp:
    bgt  $t6, $t7, sp_av
    blt  $t6, $t7, sp_bv
    # pareggio
    li   $v0, 4
    la   $a0, msg_parita_pareggio
    syscall
    la   $t0, partita_buffer
    lw   $t1, 0($s4)
    sw   $t1, 0($t0)
    lw   $t1, 0($s5)
    sw   $t1, 4($t0)
    sw   $t6, 8($t0)
    sw   $t7, 12($t0)
    sw   $zero, 16($t0)      # id_vincitore = 0 (pareggio)
    li   $t1, 1
    sw   $t1, 20($t0)        # rounds = 1
    sw   $zero, 24($t0)      # active = 0
    sw   $zero, 28($t0)      # pad
    j    sp_sv
sp_av:
    li   $v0, 4
    la   $a0, msg_vincitore
    syscall
    li   $v0, 1
    lw   $a0, 0($s4)
    syscall
    li   $v0, 4
    la   $a0, msg_punteggio
    syscall
    li   $v0, 1
    move $a0, $t6
    syscall
    lw   $t0, 44($s4)
    addi $t0, $t0, 1
    sw   $t0, 44($s4)
    lw   $t0, 48($s5)
    addi $t0, $t0, 1
    sw   $t0, 48($s5)
    la   $t0, partita_buffer
    lw   $t1, 0($s4)
    sw   $t1, 0($t0)
    lw   $t1, 0($s5)
    sw   $t1, 4($t0)
    sw   $t6, 8($t0)
    sw   $t7, 12($t0)
    lw   $t1, 0($s4)
    sw   $t1, 16($t0)        # id_vincitore = A
    li   $t1, 1
    sw   $t1, 20($t0)        # rounds = 1
    sw   $zero, 24($t0)      # active = 0
    sw   $zero, 28($t0)      # pad
    j    sp_sv
sp_bv:
    li   $v0, 4
    la   $a0, msg_vincitore
    syscall
    li   $v0, 1
    lw   $a0, 0($s5)
    syscall
    li   $v0, 4
    la   $a0, msg_punteggio
    syscall
    li   $v0, 1
    move $a0, $t7
    syscall
    lw   $t0, 44($s5)
    addi $t0, $t0, 1
    sw   $t0, 44($s5)
    lw   $t0, 48($s4)
    addi $t0, $t0, 1
    sw   $t0, 48($s4)
    la   $t0, partita_buffer
    lw   $t1, 0($s4)
    sw   $t1, 0($t0)
    lw   $t1, 0($s5)
    sw   $t1, 4($t0)
    sw   $t6, 8($t0)
    sw   $t7, 12($t0)
    lw   $t1, 0($s5)
    sw   $t1, 16($t0)        # id_vincitore = B
    li   $t1, 1
    sw   $t1, 20($t0)        # rounds = 1
    sw   $zero, 24($t0)      # active = 0
    sw   $zero, 28($t0)      # pad
sp_sv:
    move $a0, $s6
    la   $a1, partita_buffer
    jal  aggiungi_dato
    j    sp_fine
sp_no:
    li   $v0, 4
    la   $a0, msg_squadra_ntrov
    syscall
    j    sp_fine
sp_inv:
    li   $v0, 4
    la   $a0, msg_squadra_vuota
    syscall
sp_fine:
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    lw   $ra, 28($sp)
    lw   $s0, 24($sp)
    lw   $s1, 20($sp)
    lw   $s2, 16($sp)
    lw   $s3, 12($sp)
    lw   $s4,  8($sp)
    lw   $s5,  4($sp)
    lw   $s6,  0($sp)
    addi $sp, $sp, 32
    jr   $ra

# calcola_potenza_squadra  IN: $a0=squadra $a1=giocatori  OUT: $v0=potenza
calcola_potenza_squadra:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s0, 12($sp)
    sw   $s1,  8($sp)
    sw   $s2,  4($sp)
    sw   $s3,  0($sp)
    move $s0, $a0
    move $s1, $a1
    li   $s2, 0
    li   $s3, 0
cps_lp:
    slti $t0, $s2, 5
    beq  $t0, $zero, cps_fine
    sll  $t0, $s2, 2
    addi $t0, $t0, 24
    add  $t0, $t0, $s0
    lw   $t1, 0($t0)
    beq  $t1, $zero, cps_nx
    move $a0, $s1
    move $a1, $t1
    jal  cerca_ptr
    beq  $v0, $zero, cps_nx
    lw   $t2, 44($v0)
    bne  $t2, $zero, cps_nx
    lw   $t2, 20($v0)
    lw   $t3, 24($v0)
    lw   $t4, 28($v0)
    lw   $t5, 32($v0)
    add  $s3, $s3, $t2
    add  $s3, $s3, $t3
    add  $s3, $s3, $t4
    add  $s3, $s3, $t5
cps_nx:
    addi $s2, $s2, 1
    j    cps_lp
cps_fine:
    move $v0, $s3
    lw   $ra, 16($sp)
    lw   $s0, 12($sp)
    lw   $s1,  8($sp)
    lw   $s2,  4($sp)
    lw   $s3,  0($sp)
    addi $sp, $sp, 20
    jr   $ra
























.data
msg_reg_id_a:     .asciiz "ID squadra A: "
msg_reg_id_b:     .asciiz "ID squadra B: "
msg_reg_punt_a:   .asciiz "punteggio A: "
msg_reg_punt_b:   .asciiz "punteggio B: "
msg_sq_non_trov:  .asciiz "squadra non trovata\n"
msg_registrata:   .asciiz "partita registrata\n"
msg_sep_partita:  .asciiz "=========================\n"
msg_sq_a:         .asciiz "Squadra A: "
msg_sq_b:         .asciiz "Squadra B: "
msg_punt_a:       .asciiz "Punteggio A: "
msg_punt_b:       .asciiz "Punteggio B: "
msg_pareggio:     .asciiz "Pareggio\n"
msg_classifica_g: .asciiz "=== CLASSIFICA GIOCATORI ===\n"
msg_classifica_sq:.asciiz "=== CLASSIFICA SQUADRE ===\n"
msg_punteggio_g:  .asciiz "  Punteggio: "
msg_titolo_vinte: .asciiz "=== PARTITE VINTE DALLA SQUADRA ===\n"
msg_sq_nessuna_vit:.asciiz "nessuna vittoria trovata\n"
msg_rounds_s:      .asciiz "Round: "
msg_eliminata_p:   .asciiz "[eliminata]\n"
.align 2
partita_buffer: .space 32

.text
.globl registra_partita
.globl stampa_cronologia
.globl stampa_classifica_giocatori
.globl stampa_classifica_squadre
.globl partite_vinte_squadra

# Struct partita (32 byte): 0=id_A 4=id_B 8=ptA 12=ptB 16=id_vincitore 20=rounds 24=active 28=pad


# registra_partita
#   IN:  $a0 = ptr arraylist squadre
#        $a1 = ptr arraylist partite
registra_partita:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0           # s0 = squadre
    move $s1, $a1           # s1 = partite
    la   $s4, partita_buffer

    # leggi id squadra A
rp_ida:
    li   $v0, 51
    la   $a0, msg_reg_id_a
    syscall
    bne  $a1, $zero, rp_ida
    move $a1, $a0
    move $a0, $s0
    jal  cerca_ptr
    move $s2, $v0
    beq  $s2, $zero, rp_no
    lw   $t0, 0($s2)           # leggi ID dalla struttura (non da $a0 che e' stato sovrascritto)
    sw   $t0, 0($s4)

    # leggi id squadra B
rp_idb:
    li   $v0, 51
    la   $a0, msg_reg_id_b
    syscall
    bne  $a1, $zero, rp_idb
    move $a1, $a0
    move $a0, $s0
    jal  cerca_ptr
    move $s3, $v0
    beq  $s3, $zero, rp_no
    lw   $t0, 0($s3)           # leggi ID dalla struttura
    sw   $t0, 4($s4)

    # leggi punteggi
rp_pa:
    li   $v0, 51
    la   $a0, msg_reg_punt_a
    syscall
    bne  $a1, $zero, rp_pa
    sw   $a0, 8($s4)
rp_pb:
    li   $v0, 51
    la   $a0, msg_reg_punt_b
    syscall
    bne  $a1, $zero, rp_pb
    sw   $a0, 12($s4)

    # eggi rounds
rp_ro:
    li   $v0, 51
    la   $a0, msg_rounds_s
    syscall
    bne  $a1, $zero, rp_ro
    sw   $a0, 20($s4)

    # determina vincitore e aggiorna stats 
    lw   $t0, 8($s4)        # ptA
    lw   $t1, 12($s4)       # ptB
    beq  $t0, $t1, rp_par
    bgt  $t0, $t1, rp_av

    # vittoria B
    lw   $t2, 0($s3)
    sw   $t2, 16($s4)
    lw   $t3, 44($s3)
    addi $t3, $t3, 1
    sw   $t3, 44($s3)
    lw   $t3, 48($s2)
    addi $t3, $t3, 1
    sw   $t3, 48($s2)
    j    rp_sv

    # vittoria A
rp_av:
    lw   $t2, 0($s2)
    sw   $t2, 16($s4)
    lw   $t3, 44($s2)
    addi $t3, $t3, 1
    sw   $t3, 44($s2)
    lw   $t3, 48($s3)
    addi $t3, $t3, 1
    sw   $t3, 48($s3)
    j    rp_sv

rp_par:
    sw   $zero, 16($s4)

rp_sv:
    sw   $zero, 24($s4)       # active = 0 (partita valida)
    sw   $zero, 28($s4)       # pad
    move $a0, $s1
    la   $a1, partita_buffer
    jal  aggiungi_dato
    li   $v0, 4
    la   $a0, msg_registrata
    syscall
    j    rp_fine

rp_no:
    li   $v0, 4
    la   $a0, msg_sq_non_trov
    syscall

rp_fine:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra
    
# stampa_cronologia
#   IN:  $a0 = ptr arraylist partite
#        $a1 = ptr arraylist squadre  (non usato qui, per simmetria)
stampa_cronologia:
    addi $sp, $sp, -20
    sw   $ra, 16($sp)
    sw   $s0, 12($sp)
    sw   $s1,  8($sp)
    sw   $s2,  4($sp)
    sw   $s3,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size
    li   $t0, 0

cr_lp:
    beq  $t0, $s2, cr_fine
    mul  $t1, $t0, $s3
    add  $t2, $s1, $t1      # ptr partita corrente

    lw   $t3, 24($t2)       # active (!=0 = eliminata)
    bne  $t3, $zero, cr_nx  # salta le partite eliminate

    li   $v0, 4
    la   $a0, msg_sep_partita
    syscall

    la   $a0, msg_sq_a
    syscall
    li   $v0, 1
    lw   $a0, 0($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    la   $a0, msg_sq_b
    syscall
    li   $v0, 1
    lw   $a0, 4($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    la   $a0, msg_punt_a
    syscall
    li   $v0, 1
    lw   $a0, 8($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    la   $a0, msg_punt_b
    syscall
    li   $v0, 1
    lw   $a0, 12($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    la   $a0, msg_rounds_s
    syscall
    li   $v0, 1
    lw   $a0, 20($t2)       # rounds
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    la   $a0, msg_vincitore
    syscall
    lw   $t3, 16($t2)
    beq  $t3, $zero, cr_par
    li   $v0, 1
    move $a0, $t3
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    j    cr_nx

cr_par:
    li   $v0, 4
    la   $a0, msg_pareggio
    syscall

cr_nx:
    addi $t0, $t0, 1
    j    cr_lp

cr_fine:
    lw   $ra, 16($sp)
    lw   $s0, 12($sp)
    lw   $s1,  8($sp)
    lw   $s2,  4($sp)
    lw   $s3,  0($sp)
    addi $sp, $sp, 20
    jr   $ra

# stampa_classifica_giocatori
#   IN:  $a0 = ptr arraylist giocatori
#   Ordina per selezione (punteggio = lv+att+dif, offset 20/24/28)
stampa_classifica_giocatori:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size

    li   $v0, 4
    la   $a0, msg_classifica_g
    syscall

    # alloca array "visitati" sullo stack (count * 4 byte, azzerato)
    sll  $t0, $s2, 2
    sub  $sp, $sp, $t0
    move $s4, $sp
    li   $t1, 0
cg_az:
    beq  $t1, $t0, cg_lp
    sw   $zero, 0($s4)
    addi $s4, $s4, 4
    addi $t1, $t1, 4
    j    cg_az

    # selezione: $t8 = numero già stampati
cg_lp:
    move $s4, $sp
    li   $t8, 0
cg_pass:
    beq  $t8, $s2, cg_fine
    li   $t3, -1            # indice miglior candidato
    li   $t4, -1            # punteggio massimo trovato
    li   $t1, 0

cg_in:
    beq  $t1, $s2, cg_rf
    sll  $t2, $t1, 2
    add  $t2, $t2, $s4
    lw   $t2, 0($t2)
    bne  $t2, $zero, cg_sk  # già visitato
    mul  $t5, $t1, $s3
    add  $t5, $t5, $s1
    lw   $t6, 20($t5)       # livello
    lw   $t7, 24($t5)       # attacco
    add  $t6, $t6, $t7
    lw   $t7, 28($t5)       # difesa
    add  $t6, $t6, $t7      # punteggio totale
    ble  $t6, $t4, cg_sk
    move $t4, $t6
    move $t3, $t1
cg_sk:
    addi $t1, $t1, 1
    j    cg_in

cg_rf:
    beq  $t3, -1, cg_fine
    sll  $t2, $t3, 2
    add  $t2, $t2, $s4
    li   $t7, 1
    sw   $t7, 0($t2)        # marca visitato
    mul  $t5, $t3, $s3
    add  $t5, $t5, $s1      # ptr elem

    li   $v0, 4
    la   $a0, msg_separatore
    syscall
    la   $a0, msg_nickname_s
    syscall
    addi $a0, $t5, 4
    syscall
    la   $a0, msg_newline
    syscall
    la   $a0, msg_punteggio_g
    syscall
    li   $v0, 1
    move $a0, $t4
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    addi $t8, $t8, 1
    j    cg_pass

cg_fine:
    sll  $t0, $s2, 2
    add  $sp, $sp, $t0
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# stampa_classifica_squadre
#   IN:  $a0 = ptr arraylist squadre
#   Ordina per selezione (vittorie, offset 44)
stampa_classifica_squadre:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size

    li   $v0, 4
    la   $a0, msg_classifica_sq
    syscall

    # alloca array "visitati" sullo stack (count * 4 byte, azzerato)
    sll  $t0, $s2, 2
    sub  $sp, $sp, $t0
    move $s4, $sp
    li   $t1, 0
csq_az:
    beq  $t1, $t0, csq_lp
    sw   $zero, 0($s4)
    addi $s4, $s4, 4
    addi $t1, $t1, 4
    j    csq_az

    # selezione: $t8 = numero già stampati
csq_lp:
    move $s4, $sp
    li   $t8, 0
csq_pass:
    beq  $t8, $s2, csq_fine
    li   $t3, -1             # indice miglior candidato
    li   $t4, -1             # vittorie massime trovate
    li   $t1, 0

csq_in:
    beq  $t1, $s2, csq_rf
    sll  $t2, $t1, 2
    add  $t2, $t2, $s4
    lw   $t2, 0($t2)
    bne  $t2, $zero, csq_sk  # gi� visitato
    mul  $t5, $t1, $s3
    add  $t5, $t5, $s1
    lw   $t6, 44($t5)        # vittorie squadra
    ble  $t6, $t4, csq_sk
    move $t4, $t6
    move $t3, $t1
csq_sk:
    addi $t1, $t1, 1
    j    csq_in

csq_rf:
    beq  $t3, -1, csq_fine
    sll  $t2, $t3, 2
    add  $t2, $t2, $s4
    li   $t7, 1
    sw   $t7, 0($t2)         # marca visitato
    mul  $t5, $t3, $s3
    add  $t5, $t5, $s1       # ptr elem

    li   $v0, 4
    la   $a0, msg_sep_partita
    syscall
    la   $a0, msg_nome_sq_s
    syscall
    addi $a0, $t5, 4
    syscall
    la   $a0, msg_newline
    syscall
    la   $a0, msg_vittorie_sq_s
    syscall
    li   $v0, 1
    move $a0, $t4
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall

    addi $t8, $t8, 1
    j    csq_pass

csq_fine:
    sll  $t0, $s2, 2
    add  $sp, $sp, $t0
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra

# 16. partite_vinte_squadra
#     IN:  $a0 = arraylist partite
#          $a1 = id squadra
#     Stampa tutte le partite in cui id_vincitore == $a1
partite_vinte_squadra:
    addi $sp, $sp, -24
    sw   $ra, 20($sp)
    sw   $s0, 16($sp)
    sw   $s1, 12($sp)
    sw   $s2,  8($sp)
    sw   $s3,  4($sp)
    sw   $s4,  0($sp)
    move $s0, $a0           # arraylist partite
    move $s4, $a1           # id squadra cercata
    lw   $s1, 0($s0)        # base array
    lw   $s2, 4($s0)        # count
    lw   $s3, 12($s0)       # elem size (24)

    li   $v0, 4
    la   $a0, msg_titolo_vinte
    syscall

    li   $t0, 0             # indice
    li   $t8, 0             # contatore partite trovate

pvs_lp:
    beq  $t0, $s2, pvs_fine
    mul  $t1, $t0, $s3
    add  $t2, $s1, $t1      # ptr partita corrente
    lw   $t3, 24($t2)       # active (!=0 = eliminata)
    bne  $t3, $zero, pvs_nx # salta eliminate
    lw   $t3, 16($t2)       # id_vincitore
    bne  $t3, $s4, pvs_nx
    li   $v0, 4
    la   $a0, msg_sep_partita
    syscall
    la   $a0, msg_sq_a
    syscall
    li   $v0, 1
    lw   $a0, 0($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_sq_b
    syscall
    li   $v0, 1
    lw   $a0, 4($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_punt_a
    syscall
    li   $v0, 1
    lw   $a0, 8($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    la   $a0, msg_punt_b
    syscall
    li   $v0, 1
    lw   $a0, 12($t2)
    syscall
    li   $v0, 4
    la   $a0, msg_newline
    syscall
    addi $t8, $t8, 1
pvs_nx:
    addi $t0, $t0, 1
    j    pvs_lp

pvs_fine:
    bne  $t8, $zero, pvs_ret
    li   $v0, 4
    la   $a0, msg_sq_nessuna_vit
    syscall
pvs_ret:
    lw   $ra, 20($sp)
    lw   $s0, 16($sp)
    lw   $s1, 12($sp)
    lw   $s2,  8($sp)
    lw   $s3,  4($sp)
    lw   $s4,  0($sp)
    addi $sp, $sp, 24
    jr   $ra



























.data

# Nomi giocatori (16 byte ciascuno: max 15 char + null)

pop_nick1:  .asciiz "Arthas"
pop_nick2:  .asciiz "Sylvanas"
pop_nick3:  .asciiz "Thrall"
pop_nick4:  .asciiz "Jaina"
pop_nick5:  .asciiz "Garrosh"
pop_nick6:  .asciiz "Voljin"
pop_nick7:  .asciiz "Illidan"
pop_nick8:  .asciiz "Malfurion"
pop_nick9:  .asciiz "Anduin"
pop_nick10: .asciiz "Guldan"
pop_nick11: .asciiz "Tyrande"
pop_nick12: .asciiz "Cairne"
pop_nick13: .asciiz "Varian"
pop_nick14: .asciiz "Kelthuzad"
pop_nick15: .asciiz "Rexxar"
pop_nick16: .asciiz "Medivh"
pop_nick17: .asciiz "Uther"
pop_nick18: .asciiz "Grom"
pop_nick19: .asciiz "Ysera"
pop_nick20: .asciiz "Deathwing"

# Tabella puntatori ai nickname (20 entry x 4 byte)
pop_nick_table:
    .word pop_nick1,  pop_nick2,  pop_nick3,  pop_nick4,  pop_nick5
    .word pop_nick6,  pop_nick7,  pop_nick8,  pop_nick9,  pop_nick10
    .word pop_nick11, pop_nick12, pop_nick13, pop_nick14, pop_nick15
    .word pop_nick16, pop_nick17, pop_nick18, pop_nick19, pop_nick20

# Dati giocatori: lv, att, dif, en, cod_sq  (5 word per giocatore)
# Giocatori 1-3: squadra 1  | 4-6: squadra 2  | 7-9: squadra 3
# 10-12: sq 4 | 13-15: sq 5 | 16-18: sq 6 | 19-20: liberi (sq 0)
pop_gioc_data:
    .word 10, 9,  7,  80, 1    # giocatore 1
    .word  8,10,  5,  70, 1    # giocatore 2
    .word  9, 8,  8,  90, 1    # giocatore 3
    .word  9,10,  6,  75, 2    # giocatore 4
    .word  7, 9,  9,  85, 2    # giocatore 5
    .word  8, 7,  7,  65, 2    # giocatore 6
    .word 10,10,  4,  60, 3    # giocatore 7
    .word  6, 5, 10,  95, 3    # giocatore 8
    .word  8, 8,  8,  78, 3    # giocatore 9
    .word  9, 9,  6,  72, 4    # giocatore 10
    .word  7, 8,  9,  88, 4    # giocatore 11
    .word  6, 7, 10,  92, 4    # giocatore 12
    .word 10, 8,  7,  82, 5    # giocatore 13
    .word  9, 7,  8,  76, 5    # giocatore 14
    .word  8, 9,  6,  68, 5    # giocatore 15
    .word  7, 6,  9,  84, 6    # giocatore 16
    .word  8, 8,  7,  71, 6    # giocatore 17
    .word 10, 9,  5,  63, 6    # giocatore 18
    .word  5, 6, 10,  98, 0    # giocatore 19 (libero)
    .word  9,10,  3,  55, 0    # giocatore 20 (libero)


# Nomi squadre (20 byte ciascuno: max 19 char + null)

pop_nome_sq1:  .asciiz "Orda"
pop_nome_sq2:  .asciiz "Alleanza"
pop_nome_sq3:  .asciiz "BronzeDragon"
pop_nome_sq4:  .asciiz "ShadowCouncil"
pop_nome_sq5:  .asciiz "SilverHand"
pop_nome_sq6:  .asciiz "IronHorde"
pop_nome_sq7:  .asciiz "Kirin Tor"
pop_nome_sq8:  .asciiz "Argent Dawn"
pop_nome_sq9:  .asciiz "Earthen Ring"
pop_nome_sq10: .asciiz "Cenarion"
pop_nome_sq11: .asciiz "Frostwolves"
pop_nome_sq12: .asciiz "Warsong"
pop_nome_sq13: .asciiz "Stormwind"
pop_nome_sq14: .asciiz "Ironforge"
pop_nome_sq15: .asciiz "Darnassus"
pop_nome_sq16: .asciiz "Exodar"
pop_nome_sq17: .asciiz "Undercity"
pop_nome_sq18: .asciiz "Orgrimmar"
pop_nome_sq19: .asciiz "ThunderBluff"
pop_nome_sq20: .asciiz "Silvermoon"

pop_nome_sq_table:
    .word pop_nome_sq1,  pop_nome_sq2,  pop_nome_sq3,  pop_nome_sq4,  pop_nome_sq5
    .word pop_nome_sq6,  pop_nome_sq7,  pop_nome_sq8,  pop_nome_sq9,  pop_nome_sq10
    .word pop_nome_sq11, pop_nome_sq12, pop_nome_sq13, pop_nome_sq14, pop_nome_sq15
    .word pop_nome_sq16, pop_nome_sq17, pop_nome_sq18, pop_nome_sq19, pop_nome_sq20

# Roster squadre: 5 slot per squadra (id giocatore o 0)
# Squadre 1-6 hanno giocatori, 7-20 sono vuote
pop_roster_table:
    .word 1,2,3,0,0    # squadra 1
    .word 4,5,6,0,0    # squadra 2
    .word 7,8,9,0,0    # squadra 3
    .word 10,11,12,0,0 # squadra 4
    .word 13,14,15,0,0 # squadra 5
    .word 16,17,18,0,0 # squadra 6
    .word 0,0,0,0,0    # squadra 7
    .word 0,0,0,0,0    # squadra 8
    .word 0,0,0,0,0    # squadra 9
    .word 0,0,0,0,0    # squadra 10
    .word 0,0,0,0,0    # squadra 11
    .word 0,0,0,0,0    # squadra 12
    .word 0,0,0,0,0    # squadra 13
    .word 0,0,0,0,0    # squadra 14
    .word 0,0,0,0,0    # squadra 15
    .word 0,0,0,0,0    # squadra 16
    .word 0,0,0,0,0    # squadra 17
    .word 0,0,0,0,0    # squadra 18
    .word 0,0,0,0,0    # squadra 19
    .word 0,0,0,0,0    # squadra 20

# Vittorie/sconfitte squadre (vit, sco per ogni squadra)
pop_sq_stats:
    .word 3,1   # sq1
    .word 2,2   # sq2
    .word 1,3   # sq3
    .word 0,2   # sq4
    .word 4,0   # sq5
    .word 1,1   # sq6
    .word 0,0   # sq7
    .word 0,0   # sq8
    .word 0,0   # sq9
    .word 0,0   # sq10
    .word 0,0   # sq11
    .word 0,0   # sq12
    .word 0,0   # sq13
    .word 0,0   # sq14
    .word 0,0   # sq15
    .word 0,0   # sq16
    .word 0,0   # sq17
    .word 0,0   # sq18
    .word 0,0   # sq19
    .word 0,0   # sq20


# Partite precaricate (20 partite)
# Struct (32 byte): 0=id_A 4=id_B 8=ptA 12=ptB 16=id_vinc 20=rounds 24=active 28=pad
# Dati: id_A, id_B, ptA, ptB, id_vinc, rounds  (6 word per partita)

pop_partite_data:
    .word 1,2, 3,1, 1,3   # partita 1: sq1 vs sq2, vince sq1
    .word 3,4, 2,3, 4,2   # partita 2: sq3 vs sq4, vince sq4
    .word 5,1, 1,2, 1,4   # partita 3: sq5 vs sq1, vince sq1
    .word 2,3, 3,3, 0,5   # partita 4: sq2 vs sq3, pareggio
    .word 4,5, 4,2, 4,3   # partita 5: sq4 vs sq5, vince sq4
    .word 1,3, 2,1, 1,2   # partita 6: sq1 vs sq3, vince sq1
    .word 2,5, 1,3, 5,4   # partita 7: sq2 vs sq5, vince sq5
    .word 3,6, 2,4, 6,3   # partita 8: sq3 vs sq6, vince sq6
    .word 4,1, 1,4, 1,5   # partita 9: sq4 vs sq1, pareggio->sq1 (ptB>ptA: sq1=B)
    .word 5,6, 3,2, 5,2   # partita 10: sq5 vs sq6, vince sq5
    .word 1,4, 5,2, 1,3   # partita 11: sq1 vs sq4, vince sq1
    .word 2,6, 2,3, 6,4   # partita 12: sq2 vs sq6, vince sq6
    .word 3,5, 4,1, 3,2   # partita 13: sq3 vs sq5, vince sq3
    .word 6,1, 1,3, 1,5   # partita 14: sq6 vs sq1, vince sq1
    .word 5,2, 2,4, 2,3   # partita 15: sq5 vs sq2, vince sq2
    .word 4,6, 3,2, 4,4   # partita 16: sq4 vs sq6, vince sq4
    .word 1,5, 4,2, 1,3   # partita 17: sq1 vs sq5, vince sq1
    .word 2,4, 3,1, 2,2   # partita 18: sq2 vs sq4, vince sq2
    .word 6,3, 2,3, 3,4   # partita 19: sq6 vs sq3, vince sq3
    .word 5,3, 1,4, 3,5   # partita 20: sq5 vs sq3, vince sq3

pop_ok: .asciiz "Dati caricati\n"

.text
.globl popola_dati


# popola_dati
#   IN:  $a0 = arraylist giocatori  (s0 in main)
#        $a1 = arraylist squadre    (s1 in main)
#        $a2 = arraylist partite    (s5 in main)

popola_dati:
    addi $sp, $sp, -28
    sw   $ra, 24($sp)
    sw   $s0, 20($sp)
    sw   $s1, 16($sp)
    sw   $s2, 12($sp)
    sw   $s3,  8($sp)
    sw   $s4,  4($sp)
    sw   $s5,  0($sp)
    move $s0, $a0           # arraylist giocatori
    move $s1, $a1           # arraylist squadre
    move $s5, $a2           # arraylist partite


    # CICLO: inserisci 20 giocatori
    # $s2 = indice (0..19)
    li   $s2, 0
pop_gioc_loop:
    slti $t0, $s2, 20
    beq  $t0, $zero, pop_gioc_done

    # alloca 52 byte per il giocatore
    li   $a0, 52
    li   $v0, 9
    syscall
    move $s3, $v0           # s3 = ptr giocatore

    # id = s2 + 1
    addi $t0, $s2, 1
    sw   $t0, 0($s3)

    # copia nickname dalla tabella
    la   $t4, pop_nick_table
    sll  $t0, $s2, 2
    add  $t0, $t0, $t4
    lw   $t0, 0($t0)        # t0 = ptr stringa nickname
    addi $t1, $s3, 4        # t1 = dest offset 4
    jal  pop_strcpy

    # carica lv, att, dif, en, cod_sq dalla tabella dati
    la   $t4, pop_gioc_data
    li   $t5, 20            # 5 word * 4 byte
    mul  $t0, $s2, $t5
    add  $t4, $t4, $t0      # t4 = ptr riga dati giocatore

    lw   $t0, 0($t4)
    sw   $t0, 20($s3)       # livello
    lw   $t0, 4($t4)
    sw   $t0, 24($s3)       # attacco
    lw   $t0, 8($t4)
    sw   $t0, 28($s3)       # difesa
    lw   $t0, 12($t4)
    sw   $t0, 32($s3)       # energia
    sw   $zero, 36($s3)     # vittorie = 0
    sw   $zero, 40($s3)     # sconfitte = 0
    sw   $zero, 44($s3)     # active = 0
    lw   $t0, 16($t4)
    sw   $t0, 48($s3)       # cod_sq

    move $a0, $s0
    move $a1, $s3
    jal  aggiungi_dato

    addi $s2, $s2, 1
    j    pop_gioc_loop

pop_gioc_done:


    # CICLO: inserisci 20 squadre
    # $s2 = indice (0..19)

    li   $s2, 0
pop_sq_loop:
    slti $t0, $s2, 20
    beq  $t0, $zero, pop_sq_done

    # alloca 56 byte per la squadra
    li   $a0, 56
    li   $v0, 9
    syscall
    move $s3, $v0           # s3 = ptr squadra

    # id = s2 + 1
    addi $t0, $s2, 1
    sw   $t0, 0($s3)

    # copia nome dalla tabella
    la   $t4, pop_nome_sq_table
    sll  $t0, $s2, 2
    add  $t0, $t0, $t4
    lw   $t0, 0($t0)        # t0 = ptr stringa nome
    addi $t1, $s3, 4        # t1 = dest offset 4
    jal  pop_strcpy

    # copia 5 slot roster dalla tabella
    la   $t4, pop_roster_table
    li   $t5, 20            # 5 word * 4 byte
    mul  $t5, $s2, $t5
    add  $t4, $t4, $t5      # t4 = ptr riga roster
    li   $t5, 0             # indice slot
pop_roster_loop:
    slti $t6, $t5, 5
    beq  $t6, $zero, pop_roster_done
    sll  $t6, $t5, 2
    add  $t7, $t4, $t6      # ptr slot src
    lw   $t7, 0($t7)
    sll  $t6, $t5, 2
    addi $t6, $t6, 24
    add  $t6, $t6, $s3      # ptr slot dst
    sw   $t7, 0($t6)
    addi $t5, $t5, 1
    j    pop_roster_loop
pop_roster_done:

    # vittorie e sconfitte dalla tabella stats
    la   $t4, pop_sq_stats
    li   $t5, 8             # 2 word * 4 byte
    mul  $t5, $s2, $t5
    add  $t4, $t4, $t5
    lw   $t0, 0($t4)
    sw   $t0, 44($s3)       # vittorie
    lw   $t0, 4($t4)
    sw   $t0, 48($s3)       # sconfitte
    sw   $zero, 52($s3)     # active = 0

    move $a0, $s1
    move $a1, $s3
    jal  aggiungi_dato

    addi $s2, $s2, 1
    j    pop_sq_loop

pop_sq_done:


    # CICLO: inserisci 20 partite
    # Struct partita (32 byte):
    #   0=id_A 4=id_B 8=ptA 12=ptB 16=id_vinc 20=rounds 24=active 28=pad
    # Sorgente: pop_partite_data, 6 word per partita
    # $s2 = indice (0..19)

    la   $s4, pop_partite_buffer  # buffer temporaneo 32 byte
    li   $s2, 0
pop_part_loop:
    slti $t0, $s2, 20
    beq  $t0, $zero, pop_part_done

    la   $t4, pop_partite_data
    li   $t5, 24            # 6 word * 4 byte
    mul  $t5, $s2, $t5
    add  $t4, $t4, $t5      # t4 = ptr riga partita

    lw   $t0, 0($t4)
    sw   $t0, 0($s4)        # id_A
    lw   $t0, 4($t4)
    sw   $t0, 4($s4)        # id_B
    lw   $t0, 8($t4)
    sw   $t0, 8($s4)        # ptA
    lw   $t0, 12($t4)
    sw   $t0, 12($s4)       # ptB
    lw   $t0, 16($t4)
    sw   $t0, 16($s4)       # id_vincitore
    lw   $t0, 20($t4)
    sw   $t0, 20($s4)       # rounds
    sw   $zero, 24($s4)     # active = 0
    sw   $zero, 28($s4)     # pad

    move $a0, $s5
    move $a1, $s4
    jal  aggiungi_dato

    addi $s2, $s2, 1
    j    pop_part_loop

pop_part_done:

    li   $v0, 4
    la   $a0, pop_ok
    syscall

    lw   $ra, 24($sp)
    lw   $s0, 20($sp)
    lw   $s1, 16($sp)
    lw   $s2, 12($sp)
    lw   $s3,  8($sp)
    lw   $s4,  4($sp)
    lw   $s5,  0($sp)
    addi $sp, $sp, 28
    jr   $ra


# pop_strcpy  IN: $t0=src  $t1=dst

pop_strcpy:
pop_sc_lp:
    lb   $t2, 0($t0)
    sb   $t2, 0($t1)
    beq  $t2, $zero, pop_sc_fine
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j    pop_sc_lp
pop_sc_fine:
    jr   $ra

.data
.align 2
pop_partite_buffer: .space 32


















