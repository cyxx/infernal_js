main_loop:
		ld	a, (j_interrupt_handler+1)
		cp	39h
		ld	a, 1
		jp	nz, loc_58EE
		ld	a, 0
loc_58EE:
		ld	(byte_2936), a
		ld	a, 1
		call	sub_BC0E
		call	loc_67E5
		di
		ld	hl, interrupt_handler
		ld	(j_interrupt_handler+1), hl
		ld	a, 1
		ld	(counter1), a
		ei
loc_5906:
		call	clear_screen
		ld	a, 0
		ld	b, a
		ld	c, b
		call	set_palette_color
		ld	a, 1
		ld	b, 6
		ld	c, b
		call	set_palette_color
		call	title_screen
		call	initialize
		call	restart
		jp	loc_5906
; End of function main_loop
video_draw_tile:
		ld	a, (_video_draw_height)
		ld	hl, (_video_draw_addr)
y_loop:
		ld	(_video_draw_height), a
		ld	a, (_video_draw_y_pos)
		ld	(off_282A), a
		ld	(off_2828), a
		ld	ix, (off_282A)
		ld	e, (ix+0)
		ld	(_video_draw_addr), hl
		ld	ix, (off_2828)
		ld	d, (ix+0)
		ld	a, (_video_draw_x_pos)
		add	a, e
		ld	e, a
		ld	a, 0
		adc	a, d
		ld	d, a
		ld	bc, (_video_draw_width)
x_loop:
		ld	a, (de)
		xor	(hl)
		ld	(de), a
		inc	de
		inc	hl
		dec	bc
		ld	a, c
		cp	0
		jp	nz, x_loop
		ld	a, b
		cp	0
		jp	nz, x_loop
		ld	a, (_video_draw_y_pos)
		inc	a
		ld	(_video_draw_y_pos), a
		ld	a, (_video_draw_height)
		dec	a
		jp	nz, y_loop
		ret
; End of function video_draw_tile
opcode_0x41:
		ld	a, (player_disabled)
		cp	1
		jr	z, loc_5992
		ld	a, (var_num)
		cp	0
		jr	nz, loc_5992
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table1
		add	hl, de
		ld	a, (hl)
		bit	0, a
		jr	z, loc_59A7
loc_5992:
		ld	hl, vars1
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, (hl)
		add	a, d
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
loc_59A7:
		call	inc_bytecode_ptr
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x42:
		ld	a, (player_disabled)
		cp	1
		jr	z, loc_59CD
		ld	a, (var_num)
		cp	0
		jr	nz, loc_59CD
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table1
		add	hl, de
		ld	a, (hl)
		bit	1, a
		jr	z, loc_59E4
loc_59CD:
		ld	hl, vars1
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, a
		ld	a, (hl)
		and	a
		sbc	a, d
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
loc_59E4:
		call	inc_bytecode_ptr
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x43:
		ld	a, (player_disabled)
		cp	1
		jr	z, loc_5A0A
		ld	a, (var_num)
		cp	0
		jr	nz, loc_5A0A
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table1
		add	hl, de
		ld	a, (hl)
		bit	2, a
		jr	z, loc_5A1F
loc_5A0A:
		ld	hl, vars2
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, (hl)
		add	a, d
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
loc_5A1F:
		call	inc_bytecode_ptr
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x44:
		ld	a, (player_disabled)
		cp	1
		jr	z, loc_5A4C
		ld	a, (player_jumping)
		cp	1
		jr	z, loc_5A4C
		ld	a, (var_num)
		cp	0
		jr	nz, loc_5A4C
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table1
		add	hl, de
		ld	a, (hl)
		bit	3, a
		jr	z, loc_5A63
loc_5A4C:
		ld	hl, vars2
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, a
		ld	a, (hl)
		and	a
		sbc	a, d
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
loc_5A63:
		call	inc_bytecode_ptr
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x45:
		ld	hl, vars1
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x46:
		ld	hl, vars2
		ld	bc, (var_num)
		add	hl, bc
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
inc_bytecode_ptr:
		ld	de, (bytecode_ptr)
		inc	de
		ld	(bytecode_ptr),	de
		ret
; End of function inc_bytecode_ptr
set_bytecode_ptr:
		ld	hl, threads_bytecode_hi
		ld	de, (thread_num)
		ld	d, 0
		add	hl, de
		ld	a, (hl)
		ld	(bytecode_ptr+1), a
		ld	hl, threads_bytecode_lo
		add	hl, de
		ld	a, (hl)
		ld	(bytecode_ptr),	a
		ret
; End of function set_bytecode_ptr
opcode_0x47:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_x_pos), a
		ld	a, 0
		ld	(tilemap_x_pos+1), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_y_pos), a
		call	get_tile_ptr
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x48:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_x_pos), a
		ld	a, 0
		ld	(tilemap_x_pos+1), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_y_pos), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_op0x48_count),	a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_value), a
loc_5AF5:
		call	get_tile_ptr
		ld	a, (tilemap_value)
		ld	(hl), a
		ld	a, (tilemap_y_pos)
		inc	a
		ld	(tilemap_y_pos), a
		ld	a, (tilemap_op0x48_count)
		dec	a
		ld	(tilemap_op0x48_count),	a
		jr	nz, loc_5AF5
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x49:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_x_pos), a
		ld	a, 0
		ld	(tilemap_x_pos+1), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_y_pos), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_op0x49_count),	a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(tilemap_value), a
loc_5B33:
		call	get_tile_ptr
		ld	a, (tilemap_value)
		ld	(hl), a
		ld	a, (tilemap_x_pos)
		inc	a
		ld	(tilemap_x_pos), a
		ld	a, (tilemap_op0x49_count)
		dec	a
		ld	(tilemap_op0x49_count),	a
		jr	nz, loc_5B33
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x4A:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, threads_addr_hi
		add	hl, de
		ld	a, (hl)
		ld	(bytecode_ptr+1), a
		ld	bc, (thread_num)
		ld	hl, threads_bytecode_hi
		add	hl, bc
		ld	(hl), a
		ld	hl, threads_addr_lo
		add	hl, de
		ld	a, (hl)
		ld	(bytecode_ptr),	a
		ld	hl, threads_bytecode_lo
		add	hl, bc
		ld	(hl), a
		jp	next_opcode
get_tile_ptr:
		ld	hl, _tilemap
		ld	a, (tilemap_y_pos)
		cp	0
		jr	z, loc_5B89
		ld	bc, 40
loc_5B85:
		add	hl, bc
		dec	a
		jr	nz, loc_5B85
loc_5B89:
		ld	bc, (tilemap_x_pos)
		ld	b, 0
		add	hl, bc
		ret
; End of function get_tile_ptr
opcode_0x4B:
		call	video_draw_object_from_vars
		call	inc_bytecode_ptr
		jp	next_opcode
video_draw_object_from_vars:
		ld	hl, vars1
		ld	de, (var_num)
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_x_pos), a
		ld	hl, vars2
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_y_pos), a
		call	inc_bytecode_ptr
; End of function video_draw_object_from_vars
video_draw_object:
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, _gfx_addr_hi
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_addr+1), a
		ld	hl, _gfx_addr_lo
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_addr), a
		ld	hl, _gfx_width
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_width), a
		ld	hl, _gfx_height
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_height), a
		ld	(_video_draw_height2), a
		ld	hl, byte_1600
		ld	(off_2828), hl
		ld	hl, byte_1700
		ld	(off_282A), hl
		call	video_draw_tile
		ret
; End of function video_draw_object
opcode_0x4C:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(var_num), a
		ld	a, 0
		ld	(var_num+1), a
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x4F:
		ld	a, 0
		ld	(keys_flag), a
		ld	(threads_bytecode_hi), a
		ld	(threads_bytecode_lo), a
		ld	(player_jumping), a
		jp	break_trigger
opcode_0x50:
		call	inc_bytecode_ptr
		ld	a, 1
		ld	(player_disabled), a
		ld	a, 0
		ld	(threads_bytecode_lo), a
		ld	(threads_bytecode_hi), a
		jp	next_opcode
opcode_0x51:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(player_frame),	a
		call	inc_bytecode_ptr
		jp	next_opcode
draw_player_fixed_position:
		ld	hl, player_frame
		dec	hl
		ld	(bytecode_ptr),	hl
		ld	hl, 0
		ld	(var_num), hl
		jp	video_draw_object_from_vars
; End of function draw_player_fixed_position
get_current_tile:
		ld	hl, vars1
		ld	d, (hl)
		ld	a, (vars2)
		add	a, 8
		srl	d
		srl	a
		srl	a
		srl	a
		ld	(tilemap_y_pos), a
		ld	a, d
		ld	(tilemap_x_pos), a
		ld	a, 0
		ld	(tilemap_x_pos+1), a
		call	get_tile_ptr
		ld	a, (hl)
		ret
; End of function get_current_tile
get_next_tile:
		call	get_current_tile
		cp	0
		ret	nz
		ld	hl, vars1
		inc	(hl)
		call	get_current_tile
		push	hl
		ld	hl, vars1
		dec	(hl)
		pop	hl
		ret
; End of function get_next_tile
opcode_0x52:
		call	inc_bytecode_ptr
		ld	a, (player_disabled)
		cp	1
		jp	z, loc_5CFC
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, _gfx_width
		add	hl, de
		ld	a, (hl)
		ld	(op0x52_w), a
		ld	hl, _gfx_height
		add	hl, de
		ld	a, (hl)
		ld	(op0x52_h), a
		ld	bc, (var_num)
		ld	hl, vars1
		add	hl, bc
		ld	a, (hl)
		ld	hl, vars2
		add	hl, bc
		ld	c, (hl)
		ld	b, a
		ld	a, (vars1)
		cp	b
		jr	z, loc_5CC6
		jr	nc, loc_5CB0
		add	a, 1
		cp	b
		jr	z, loc_5CC6
		jr	nc, loc_5CB0
		jr	loc_5CFC
loc_5CB0:
		ld	a, (op0x52_w)
		add	a, b
		ld	b, a
		ld	a, (vars1)
		cp	b
		jr	z, loc_5CC6
		jr	c, loc_5CC6
		add	a, 1
		cp	b
		jr	z, loc_5CC6
		jr	c, loc_5CC6
		jr	nc, loc_5CFC
loc_5CC6:
		ld	a, (vars2)
		add	a, 7
		cp	c
		jr	z, loc_5CEF
		jr	nc, loc_5CD9
		add	a, 5
		cp	c
		jr	z, loc_5CEF
		jr	nc, loc_5CD9
		jr	loc_5CFC
loc_5CD9:
		ld	a, (op0x52_h)
		add	a, c
		ld	c, a
		ld	a, (vars2)
		add	a, 7
		cp	c
		jr	c, loc_5CEF
		add	a, 5
		cp	c
		jr	z, loc_5CEF
		jr	c, loc_5CEF
		jr	nc, loc_5CFC
loc_5CEF:
		ld	hl, table3
		add	hl, de
		ld	b, d
		ld	c, e
		ld	a, (hl)
		call	set_thread_bytecode
		jp	opcode_0x50
loc_5CFC:
		call	inc_bytecode_ptr
		jp	next_opcode
set_thread_bytecode:
		ld	e, a
		ld	d, 0
		ld	hl, threads_addr_hi
		add	hl, de
		ld	a, (hl)
		ld	hl, threads_bytecode_hi
		add	hl, bc
		ld	(hl), a
		ld	hl, threads_addr_lo
		add	hl, de
		ld	a, (hl)
		ld	hl, threads_bytecode_lo
		add	hl, bc
		ld	(hl), a
		ret
; End of function set_thread_bytecode
opcode_0x53:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	bc, 0
		call	set_thread_bytecode
		call	inc_bytecode_ptr
		jp	next_opcode
loc_5D2A:
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table2
		add	hl, de
		ld	a, (hl)
		cp	0
		jr	z, handle_keys
		ld	bc, 0
		call	set_thread_bytecode
		jr	loc_5D41
loc_5D41:
		ld	a, 1
		ld	(keys_flag), a
		jp	loc_5F38
loc_5D49:
		call	get_next_tile
		ld	d, 0
		ld	e, a
		ld	hl, table1
		add	hl, de
		ld	a, (hl)
		ld	(tile_flags), a
		and	0F0h
		cp	0
		jr	z, loc_5D80
		call	draw_player_fixed_position
		ld	a, (tile_flags)
		ld	hl, vars1
		bit	4, a
		jr	z, loc_5D6B
		inc	(hl)
loc_5D6B:
		bit	5, a
		jr	z, loc_5D70
		dec	(hl)
loc_5D70:
		ld	hl, vars2
		bit	6, a
		jr	z, loc_5D78
		inc	(hl)
loc_5D78:
		bit	7, a
		jr	z, loc_5D7D
		dec	(hl)
loc_5D7D:
		call	draw_player_fixed_position
loc_5D80:
		jp	loc_65E6
handle_keys:
		call	handle_game_pause
		ld	a, (start_pos)
		cp	0
		jp	nz, loc_5F38
		ld	a, KEY_KEYBOARD_COPY
		call	is_key_pressed
		jr	nz, loc_5D9C
		ld	a, KEY_JOYSTICK0_DISP1
		call	is_key_pressed
		jr	z, loc_5DB5
loc_5D9C:
		ld	a, (player_direction)
		cp	0
		ld	a, 6
		jr	nz, loc_5DA7
		ld	a, 5
loc_5DA7:
		ld	bc, 0
		call	set_thread_bytecode
		ld	a, 1
		ld	(player_jumping), a
		jp	loc_5D41
loc_5DB5:
		call	get_next_tile
		ld	b, 0
		ld	c, a
		ld	hl, table1
		add	hl, bc
		ld	a, (hl)
		and	0Ch
		jr	z, loc_5DF6
		ld	a, KEY_KEYBOARD_UP
		call	is_key_pressed
		jr	nz, loc_5DD2
		ld	a, KEY_JOYSTICK0_UP
		call	is_key_pressed
		jr	z, loc_5DDD
loc_5DD2:
		ld	a, 3
		ld	bc, 0
		call	set_thread_bytecode
		jp	loc_5D41
loc_5DDD:
		ld	a, KEY_KEYBOARD_DOWN
		call	is_key_pressed
		jr	nz, loc_5DEB
		ld	a, KEY_JOYSTICK0_DOWN
		call	is_key_pressed
		jr	z, loc_5DF6
loc_5DEB:
		ld	a, 4
		ld	bc, 0
		call	set_thread_bytecode
		jp	loc_5D41
loc_5DF6:
		ld	a, KEY_KEYBOARD_RIGHT
		call	is_key_pressed
		jr	nz, loc_5E04
		ld	a, KEY_JOYSTICK0_RIGHT
		call	is_key_pressed
		jr	z, loc_5E14
loc_5E04:
		ld	a, 1
		ld	bc, 0
		call	set_thread_bytecode
		ld	a, 0
		ld	(player_direction), a
		jp	loc_5D41
loc_5E14:
		ld	a, KEY_KEYBOARD_LEFT
		call	is_key_pressed
		jr	nz, loc_5E22
		ld	a, KEY_JOYSTICK0_LEFT
		call	is_key_pressed
		jr	z, loc_5E32
loc_5E22:
		ld	a, 2
		ld	bc, 0
		call	set_thread_bytecode
		ld	a, 1
		ld	(player_direction), a
		jp	loc_5D41
loc_5E32:
		jp	loc_5F38
sub_5E35:
		call	handle_game_pause
		ld	a, (screen_num)
		ld	b, 0
		ld	c, a
		ld	hl, unk_292A
		add	hl, bc
		ld	c, (hl)
; End of function sub_5E35
wait:
		ld	b, 249
loc_5E45:
		dec	b
		jp	nz, loc_5E45
		push	bc
		call	wait_vbl
		pop	bc
		dec	c
		jp	nz, wait
		ret
; End of function wait
run_threads:
arg_21F2	=  21F6h
arg_5A8E	=  5A92h
		ld	a, 0
		ld	(thread_num), a
		ld	(thread_num+1),	a
next_thread:
		call	set_bytecode_ptr
next_opcode:
		ld	a, (bytecode_ptr+1)
		cp	0
		jp	z, break_trigger
		ld	de, (bytecode_ptr)
		ld	a, (de)
		cp	41h
		jp	z, opcode_0x41
		cp	42h
		jp	z, opcode_0x42
		cp	43h
		jp	z, opcode_0x43
		cp	44h
		jp	z, opcode_0x44
		cp	45h
		jp	z, opcode_0x45
		cp	46h
		jp	z, opcode_0x46
		cp	47h
		jp	z, opcode_0x47
		cp	48h
		jp	z, opcode_0x48
		cp	49h
		jp	z, opcode_0x49
		cp	4Ah
		jp	z, opcode_0x4A
		cp	4Bh
		jp	z, opcode_0x4B
		cp	4Ch
		jp	z, opcode_0x4C
		cp	4Fh
		jp	z, opcode_0x4F
		cp	50h
		jp	z, opcode_0x50
		cp	51h
		jp	z, opcode_0x51
		cp	52h
		jp	z, opcode_0x52
		cp	53h
		jp	z, opcode_0x53
		cp	54h
		jp	z, opcode_0x54
		cp	55h
		jp	z, opcode_0x55
		cp	56h
		jp	z, opcode_0x56
		cp	57h
		jp	z, opcode_0x57
		cp	58h
		jp	z, opcode_0x58
		cp	59h
		jp	z, opcode_0x59
		cp	40h
		jp	z, opcode_0x40
		cp	3Fh
		jp	z, opcode_0x3F
		cp	3Eh
		jp	z, opcode_0x3E
		cp	4Dh
		jr	nz, loc_5F18
		call	inc_bytecode_ptr
		ld	hl, threads_bytecode_hi
		ld	de, (thread_num)
		add	hl, de
		ld	a, (bytecode_ptr+1)
		ld	(hl), a
		ld	hl, threads_bytecode_lo
		add	hl, de
		ld	a, (bytecode_ptr)
		ld	(hl), a
		call	wait_vbl
break_trigger:
		ld	a, (thread_num)
		inc	a
		ld	(thread_num), a
		cp	0
		jp	nz, next_thread
		ret
loc_5F18:
		cp	4Eh
		jr	nz, return
		ld	a, 1
		ld	(break_flag), a
return:
		ret
update_game_state:
		ld	a, (player_disabled)
		cp	1
		jp	z, loc_5F85
		jp	loc_5D49
loc_5F2D:
		ld	a, (keys_flag)
		cp	1
		jp	z, loc_5D41
		jp	loc_5D2A
loc_5F38:
		call	handle_food
		call	handle_reward
		call	handle_key
		call	handle_box
		jp	loc_5F47
loc_5F47:
		jp	loc_5F4A
loc_5F4A:
		call	run_threads
		jp	loc_5F50
loc_5F50:
		jp	check_game_completed
loc_5F53:
		call	sub_5E35
		ld	a, (start_pos)
		cp	0
		jp	z, loc_617E
		ld	(counter2), a
		ld	a, 0
		ld	(start_pos), a
		ld	a, KEY_KEYBOARD_SPACE
		call	is_key_pressed
		ret	nz
		ld	a, KEY_JOYSTICK0_DISP1
		call	is_key_pressed
		ret	nz
		ld	a, (counter2)
		ld	(start_pos), a
		ld	a, (counter3)
		dec	a
		ld	(counter3), a
		jp	z, restart
		jp	loc_617E
loc_5F85:
		call	run_threads
		ld	a, (break_flag)
		cp	1
		jp	z, restart
		jp	loc_5F93
loc_5F93:
		call	sub_5E35
		jp	loc_5F85
opcode_0x54:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(_video_draw_x_pos), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(draw_objects_counter),	a
		call	inc_bytecode_ptr
loc_5FB4:
		ld	de, (bytecode_ptr)
		call	video_draw_object
		ld	a, (_video_draw_x_pos)
		ld	b, a
		ld	a, (_video_draw_width)
		add	a, b
		ld	(_video_draw_x_pos), a
		ld	a, (_video_draw_y_bak)
		ld	(_video_draw_y_pos), a
		ld	a, (draw_objects_counter)
		dec	a
		ld	(draw_objects_counter),	a
		jp	nz, loc_5FB4
		call	inc_bytecode_ptr
		call	wait_vbl
		jp	next_opcode
opcode_0x55:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(_video_draw_x_pos), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(draw_objects_counter),	a
		call	inc_bytecode_ptr
loc_5FFA:
		ld	de, (bytecode_ptr)
		call	video_draw_object
		ld	a, (_video_draw_y_bak)
		ld	b, a
		ld	a, (_video_draw_height2)
		add	a, b
		ld	(_video_draw_y_bak), a
		ld	(_video_draw_y_pos), a
		ld	a, (draw_objects_counter)
		dec	a
		ld	(draw_objects_counter),	a
		jp	nz, loc_5FFA
		call	inc_bytecode_ptr
		call	wait_vbl
		jp	next_opcode
; End of function run_threads
video_draw_object2:
		ld	a, (_video_draw_height)
		ld	hl, (_video_draw_addr)
loc_6028:
		ld	(_video_draw_height), a
		ld	a, (_video_draw_y_pos)
		ld	(off_282A), a
		ld	(off_2828), a
		ld	ix, (off_282A)
		ld	e, (ix+0)
		ld	(_video_draw_addr), hl
		ld	ix, (off_2828)
		ld	d, (ix+0)
		ld	a, (_video_draw_x_pos)
		add	a, e
		ld	e, a
		ld	a, 0
		adc	a, d
		ld	d, a
		ld	bc, (_video_draw_width)
loc_6052:
		ld	(word_2842), bc
		ld	a, (hl)
		ld	b, a
		ld	c, a
		srl	a
		srl	a
		srl	a
		srl	a
		add	a, b
		xor	0FFh
		ld	b, a
		ld	a, (de)
		and	b
		or	c
		ld	(de), a
		ld	bc, (word_2842)
		inc	de
		inc	hl
		dec	bc
		ld	a, c
		cp	0
		jp	nz, loc_6052
		ld	a, b
		cp	0
		jp	nz, loc_6052
		ld	a, (_video_draw_y_pos)
		inc	a
		ld	(_video_draw_y_pos), a
		ld	a, (_video_draw_height)
		dec	a
		jp	nz, loc_6028
		ret
; End of function video_draw_object2
opcode_0x56:
		call	inc_bytecode_ptr
		call	increase_score
		jp	next_opcode
increase_score:
		call	draw_panel_highscore
		call	draw_panel_score
		ld	a, (score_digit1)
		add	a, 67h
		daa
		ld	(score_digit1),	a
		ld	a, (score_digit2)
		adc	a, 0
		daa
		ld	(score_digit2),	a
		ld	a, (score_digit3)
		adc	a, 0
		daa
		ld	(score_digit3),	a
		call	update_highscore
		call	draw_panel_highscore
		call	draw_panel_score
		ret
; End of function increase_score
update_highscore:
		ld	hl, score_digit3
		ld	a, (highscore_digit3)
		cp	(hl)
		jp	c, loc_60E0
		jp	nz, locret_60DF
		dec	hl
		ld	a, (highscore_digit2)
		cp	(hl)
		jp	c, loc_60E0
		jp	nz, locret_60DF
		dec	hl
		ld	a, (highscore_digit1)
		cp	(hl)
		jp	c, loc_60E0
locret_60DF:
		ret
loc_60E0:
		ld	a, (score_digit3)
		ld	(highscore_digit3), a
		ld	a, (score_digit2)
		ld	(highscore_digit2), a
		ld	a, (score_digit1)
		ld	(highscore_digit1), a
		ret
; End of function update_highscore
opcode_0x58:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, table4
		add	hl, de
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x57:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, table4
		add	hl, de
		ld	a, (hl)
		cp	0
		jp	z, loc_6124
		dec	a
		ld	(hl), a
		cp	0
		jp	z, loc_6124
		jp	opcode_0x4A
loc_6124:
		call	inc_bytecode_ptr
		call	inc_bytecode_ptr
		jp	next_opcode
set_threads_screen:
		call	clear_thread
		ld	a, (screen_num)
		ld	hl, byte_221E
		ld	bc, 128
		cp	0
		jp	z, loc_6143
loc_613E:
		add	hl, bc
		dec	a
		jp	nz, loc_613E
loc_6143:
		ld	b, 0
		ld	de, 1
loop:
		inc	hl
		ld	c, (hl)
		ld	iy, threads_addr_hi
		add	iy, bc
		ld	a, (iy+0)
		ld	ix, threads_bytecode_hi
		add	ix, de
		ld	(ix+0),	a
		ld	iy, threads_addr_lo
		add	iy, bc
		ld	a, (iy+0)
		ld	ix, threads_bytecode_lo
		add	ix, de
		ld	(ix+0),	a
		inc	e
		ld	a, e
		cp	128
		jp	nz, loop
		ret
; End of function set_threads_screen
loc_6176:
		ld	hl, screen_num
		add	a, (hl)
		ld	(hl), a
		jp	change_screen
loc_617E:
		ld	hl, vars2
		ld	a, (hl)
		cp	0
		jp	z, loc_61A2
		cp	1
		jp	z, loc_61A2
		cp	151
		jp	nc, loc_61A9
		ld	hl, vars1
		ld	a, (hl)
		cp	0
		jp	z, loc_61B0
		cp	79
		jp	nc, loc_61B7
		jp	loc_673F
loc_61A2:
		ld	(hl), 150
		ld	a, 3
		jp	loc_6176
loc_61A9:
		ld	(hl), 2
		ld	a, -3
		jp	loc_6176
loc_61B0:
		ld	(hl), 77
		ld	a, -1
		jp	loc_6176
loc_61B7:
		ld	(hl), 2
		ld	a, 1
		jp	loc_6176
		jp	change_screen
change_screen:
		call	clear_screen
		call	clear_tilemap
		call	draw_panel_score
		call	draw_panel_highscore
		call	draw_panel_hunger
		call	draw_panel_lifes
		ld	a, 0
		ld	(threads_bytecode_hi), a
		ld	(threads_bytecode_lo), a
		call	run_game_threads
		call	draw_object_food
		call	draw_object_reward
		call	draw_object_key
		call	draw_object_box
		call	set_threads_screen
		ld	a, (vars1)
		ld	(_video_draw_x_pos), a
		ld	a, (vars2)
		ld	(_video_draw_y_pos), a
		ld	de, player_frame
		call	video_draw_object
		ld	a, 0
		ld	(player_jumping), a
		ld	(keys_flag), a
		ld	(player_disabled), a
		ld	(break_flag), a
		call	set_thread_boxes
		jp	update_game_state
opcode_0x59:
		call	opcode_0x59
		jp	next_opcode
opcode_0x59:
		ld	hl, vars1
		ld	de, (var_num)
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_x_pos), a
		ld	hl, vars2
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_y_pos), a
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	d, 0
		ld	e, a
		ld	hl, _gfx_addr_hi
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_addr+1), a
		ld	hl, _gfx_addr_lo
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_addr), a
		ld	hl, _gfx_width
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_width), a
		ld	hl, _gfx_height
		add	hl, de
		ld	a, (hl)
		ld	(_video_draw_height), a
		ld	hl, byte_1600
		ld	(off_2828), hl
		ld	hl, byte_1700
		ld	(off_282A), hl
		call	inc_bytecode_ptr
		call	video_draw_object2
		ret
; End of function opcode_0x59
video_draw_number:
		ld	(video_draw_digit), a
		ld	a, (_video_draw_y_pos)
		ld	(_video_draw_y_bak), a
		ld	a, (video_draw_digit)
		srl	a
		srl	a
		srl	a
		srl	a
		ld	c, 44
		add	a, c
		ld	de, video_draw_object_num
		ld	(de), a
		call	video_draw_object
		ld	hl, _video_draw_x_pos
		inc	(hl)
		inc	(hl)
		ld	a, (_video_draw_y_bak)
		ld	(_video_draw_y_pos), a
		ld	a, (video_draw_digit)
		and	0Fh
		ld	c, 44
		add	a, c
		ld	de, video_draw_object_num
		ld	(de), a
		call	video_draw_object
		ld	hl, _video_draw_x_pos
		inc	(hl)
		inc	(hl)
		ld	a, (_video_draw_y_bak)
		ld	(_video_draw_y_pos), a
		ret
; End of function video_draw_number
draw_panel_highscore:
		ld	a, 64
		ld	(_video_draw_x_pos), a
		ld	a, 176
		ld	(_video_draw_y_pos), a
		ld	a, (highscore_digit3)
		call	video_draw_number
		ld	a, (highscore_digit2)
		call	video_draw_number
		ld	a, (highscore_digit1)
		call	video_draw_number
		ret
; End of function draw_panel_highscore
draw_panel_score:
		ld	a, 36
		ld	(_video_draw_x_pos), a
		ld	a, 176
		ld	(_video_draw_y_pos), a
		ld	a, (score_digit3)
		call	video_draw_number
		ld	a, (score_digit2)
		call	video_draw_number
		ld	a, (score_digit1)
		call	video_draw_number
		ret
; End of function draw_panel_score
draw_panel_hunger:
		ld	a, 40
		ld	(_video_draw_x_pos), a
		ld	a, 184
		ld	(_video_draw_y_pos), a
		ld	a, (hunger)
		call	video_draw_number
		ret
; End of function draw_panel_hunger
draw_panel_lifes:
		ld	a, 68
		ld	(_video_draw_x_pos), a
		ld	a, 184
		ld	(_video_draw_y_pos), a
		ld	a, (lifes)
		call	video_draw_number
		ret
; End of function draw_panel_lifes
clear_screen:
		ld	hl, 0C000h
		ld	bc, 16336
loc_630D:
		ld	(hl), 0
		inc	hl
		dec	bc
		ld	a, c
		cp	0
		jp	nz, loc_630D
		push	hl
		push	bc
		call	wait_vbl
		pop	bc
		pop	hl
		ld	a, b
		cp	0
		jp	nz, loc_630D
		ret
; End of function clear_screen
handle_food:
		call	get_next_tile
		cp	32h
		jp	nz, return
		ld	a, 1
		ld	(hl), a
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_food
		add	ix, bc
		ld	a, 0
		ld	(ix+0),	a
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		ld	(_video_draw_y_pos), a
		ld	de, video_draw_object_num
		ld	a, 58
		ld	(de), a
		call	video_draw_object
		call	increase_score
		call	draw_panel_hunger
		ld	a, 153
		ld	(hunger), a
		call	draw_panel_hunger
return:
		ret
; End of function handle_food
handle_reward:
		call	get_next_tile
		cp	33h
		jp	nz, locret_63A7
		ld	a, 1
		ld	(hl), a
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_reward
		add	ix, bc
		ld	a, 0
		ld	(ix+0),	a
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		ld	(_video_draw_y_pos), a
		ld	de, video_draw_object_num
		ld	a, 21
		ld	(de), a
		call	video_draw_object
		call	increase_score
		call	increase_score
		call	draw_panel_hunger
		ld	a, 153
		ld	(hunger), a
		call	draw_panel_hunger
locret_63A7:
		ret
; End of function handle_reward
handle_key:
		call	get_next_tile
		cp	34h
		jp	nz, return
		ld	a, 1
		ld	(hl), a
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_key
		add	ix, bc
		ld	a, 0
		ld	(ix+0),	a
		ld	a, (ix+14)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		ld	(_video_draw_y_pos), a
		ld	de, video_draw_object_num
		ld	a, 37
		ld	(de), a
		call	video_draw_object
		ld	a, (keys)
		inc	a
		inc	a
		ld	(keys),	a
		call	increase_score
		call	increase_score
		call	increase_score
		call	increase_score
		call	increase_score
return:
		ret
; End of function handle_key
handle_box:
		ld	a, (keys)
		cp	0
		jp	z, return
		call	get_next_tile
		cp	35h
		jp	nz, return
		ld	a, 1
		ld	(hl), a
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_box
		add	ix, bc
		ld	a, 1
		ld	(ix+0),	a
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		add	a, 4
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		ld	de, video_draw_object_num
		ld	a, 38
		ld	(de), a
		call	video_draw_object
		ld	de, video_draw_object_num
		ld	a, 39
		ld	(de), a
		ld	a, (_video_draw_y_bak)
		ld	(_video_draw_y_pos), a
		call	video_draw_object
		call	increase_score
		call	increase_score
		call	increase_score
		call	increase_score
		ld	a, (boxes)
		inc	a
		ld	(boxes), a
		ld	a, (keys)
		dec	a
		ld	(keys),	a
		call	set_thread_boxes
return:
		ret
; End of function handle_box
draw_object_food:
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_food
		add	ix, bc
		ld	a, (ix+0)
		cp	0
		jp	z, return
		ld	a, (ix+14)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+28)
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		ld	de, video_draw_object_num
		ld	a, 58
		ld	(de), a
		call	video_draw_object
		ld	a, (_video_draw_x_pos)
		srl	a
		ld	(tilemap_x_pos), a
		ld	a, (_video_draw_y_bak)
		ld	b, 7
		add	a, b
		srl	a
		srl	a
		srl	a
		ld	(tilemap_y_pos), a
		call	get_tile_ptr
		ld	(hl), 32h
return:
		ret
; End of function draw_object_food
draw_object_reward:
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_reward
		add	ix, bc
		ld	a, (ix+0)
		cp	0
		jp	z, return
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		ld	de, video_draw_object_num
		ld	a, 21
		ld	(de), a
		call	video_draw_object
		ld	a, (_video_draw_x_pos)
		srl	a
		ld	(tilemap_x_pos), a
		ld	a, (_video_draw_y_bak)
		ld	b, 4
		add	a, b
		srl	a
		srl	a
		srl	a
		ld	(tilemap_y_pos), a
		call	get_tile_ptr
		ld	(hl), 33h
return:
		ret
; End of function draw_object_reward
draw_object_key:
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_key
		add	ix, bc
		ld	a, (ix+0)
		cp	0
		jp	z, return
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		ld	de, video_draw_object_num
		ld	a, 37
		ld	(de), a
		call	video_draw_object
		ld	a, (_video_draw_x_pos)
		srl	a
		ld	(tilemap_x_pos), a
		ld	a, (_video_draw_y_bak)
		add	a, 5
		srl	a
		srl	a
		srl	a
		ld	(tilemap_y_pos), a
		call	get_tile_ptr
		ld	(hl), 34h
return:
		ret
; End of function draw_object_key
draw_object_box:
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		ld	ix, bonus_data_box
		add	ix, bc
		ld	a, (ix+0)
		cp	0
		jp	z, return
		cp	1
		jp	z, loc_6585
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		add	a, 4
		ld	(_video_draw_y_pos), a
		ld	(_video_draw_y_bak), a
		ld	de, video_draw_object_num
		ld	a, 38
		ld	(de), a
		call	video_draw_object
		ld	a, (_video_draw_x_pos)
		srl	a
		ld	(tilemap_x_pos), a
		ld	a, (_video_draw_y_bak)
		add	a, 4
		srl	a
		srl	a
		srl	a
		ld	(tilemap_y_pos), a
		call	get_tile_ptr
		ld	(hl), 35h
return:
		ret
loc_6585:
		ld	a, (ix+0Eh)
		ld	(_video_draw_x_pos), a
		ld	a, (ix+1Ch)
		add	a, 4
		ld	(_video_draw_y_pos), a
		ld	de, video_draw_object_num
		ld	a, 27h
		ld	(de), a
		call	video_draw_object
		ret
; End of function draw_object_box
restart:
		ld	a, (start_pos)
		cp	0
		jp	z, loc_65BC
		cp	6
		ret	z
		ld	b, 0
		ld	c, a
		inc	a
		ld	(start_pos), a
		ld	hl, byte_291D
		add	hl, bc
		ld	a, (hl)
		ld	(screen_num), a
		ld	a, 100
		ld	(counter3), a
loc_65BC:
		ld	hl, screen_start_x_pos
		ld	a, (screen_num)
		ld	c, a
		ld	b, 0
		add	hl, bc
		ld	a, (hl)
		ld	(vars1), a
		ld	hl, screen_start_y_pos
		add	hl, bc
		ld	a, (hl)
		ld	(vars2), a
		ld	a, 1
		ld	(player_frame),	a
		ld	a, (lifes)
		cp	0
		jp	z, return
		nop
		ld	(lifes), a
		jp	change_screen
; End of function restart
loc_65E6:
		call	get_next_tile
		ld	b, 0
		ld	c, a
		ld	d, 0
		ld	e, a
		ld	hl, table3
		add	hl, de
		ld	a, (hl)
		cp	0
		jp	z, loc_5F2D
		call	set_thread_bytecode
		jp	loc_5F2D
run_game_threads:
		call	clear_thread
		ld	b, 100
		ld	a, (screen_num)
		add	a, b
		ld	c, a
		ld	b, 0
		ld	hl, threads_addr_hi
		add	hl, bc
		ld	a, (hl)
		ld	(threads_bytecode_hi+1), a
		ld	hl, threads_addr_lo
		add	hl, bc
		ld	a, (hl)
		ld	(threads_bytecode_lo+1), a
		call	run_threads
		ret
; End of function run_game_threads
opcode_0x40:
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	c, a
		ld	b, 0
		call	inc_bytecode_ptr
		ld	a, (de)
		ld	e, a
		ld	d, 0
		ld	hl, threads_addr_hi
		add	hl, bc
		ld	a, (hl)
		ld	hl, threads_bytecode_hi
		add	hl, de
		ld	(hl), a
		ld	hl, threads_addr_lo
		add	hl, bc
		ld	a, (hl)
		ld	hl, threads_bytecode_lo
		add	hl, de
		ld	(hl), a
		call	inc_bytecode_ptr
		jp	next_opcode
opcode_0x3F:
		ld	a, (vars1)
		srl	a
		sla	a
		ld	(vars1), a
		call	inc_bytecode_ptr
		jp	next_opcode
clear_tilemap:
		ld	hl, _tilemap
		ld	bc, 840
loc_665D:
		ld	(hl), 0
		inc	hl
		dec	bc
		ld	a, b
		cp	0
		jp	nz, loc_665D
		ld	a, c
		cp	0
		jp	nz, loc_665D
		ret
; End of function clear_tilemap
opcode_0x3E:
		call	inc_bytecode_ptr
		ld	a, (vars1)
		ld	(_video_draw_x_pos), a
		ld	a, (vars2)
		ld	(_video_draw_y_pos), a
		ld	de, player_frame
		call	video_draw_object
		jp	next_opcode
return:
		ret
initialize:
		ld	ix, bonus_data_box
		ld	(ix+0),	2
		ld	(ix+1),	2
		ld	(ix+2),	2
		ld	(ix+3),	2
		ld	(ix+4),	2
		ld	(ix+5),	2
		ld	(ix+6),	2
		ld	(ix+7),	2
		ld	(ix+9),	2
		ld	(ix+0Ah), 2
		ld	ix, bonus_data_key
		ld	(ix+2),	1
		ld	(ix+5),	1
		ld	(ix+6),	1
		ld	(ix+9),	1
		ld	(ix+0Bh), 1
		ld	ix, bonus_data_food
		ld	(ix+6),	1
		ld	(ix+7),	1
		ld	(ix+0Ah), 1
		ld	ix, bonus_data_reward
		ld	(ix+1),	1
		ld	(ix+3),	1
		ld	a, 0
		ld	(keys),	a
		ld	(score_digit1),	a
		ld	(score_digit2),	a
		ld	(score_digit3),	a
		ld	(boxes), a
		ld	a, 153
		ld	(hunger), a
		ld	a, 6
		ld	(lifes), a
		ld	a, 4
		ld	(screen_num), a
		ld	a, 20
		ld	(ticks), a
		ld	a, 2
		ld	b, 21
		ld	c, b
		call	set_palette_color
		ld	a, 3
		ld	b, 14
		ld	c, b
		call	set_palette_color
		ld	a, 0
		ld	(start_pos), a
		ld	ix, byte_291D
		ld	(ix+1),	4
		ld	(ix+2),	5
		ld	(ix+3),	2
		ld	(ix+4),	9
		ld	(ix+5),	11
		ld	a, 12
		ld	(counter1), a
		ret
; End of function initialize
loc_673F:
		ld	a, (ticks)
		dec	a
		ld	(ticks), a
		jp	nz, update_game_state
		ld	a, 18
		ld	(ticks), a
		call	draw_panel_hunger
		ld	a, (hunger)
		and	a
		sbc	a, 0
		daa
		ld	(hunger), a
		call	draw_panel_hunger
		ld	a, (hunger)
		cp	0
		jp	nz, update_game_state
		jp	restart
set_thread_boxes:
		ld	a, (boxes)
		cp	10
		jp	nz, return
		ld	a, (screen_num)
		cp	3
		jp	nz, return
		ld	ix, threads_addr_hi
		ld	a, (ix+126)
		ld	(threads_bytecode_hi), a
		ld	ix, threads_addr_lo
		ld	a, (ix+126)
		ld	(threads_bytecode_lo), a
return:
		ret
; End of function set_thread_boxes
check_game_completed:
		ld	a, (boxes)
		cp	10
		jp	nz, loc_67B1
		ld	a, (screen_num)
		cp	3
		jp	nz, loc_67B1
		ld	a, (vars1)
		cp	2
		jp	nc, loc_67B1
		ld	a, (vars2)
		cp	130
		jp	c, loc_67B1
		jp	game_completed
loc_67B1:
		jp	loc_5F53
wait_vbl:
		ld	a, (byte_2929)
		cp	0
		ret	z
		ld	a, 0
		ld	(byte_2929), a
		ld	hl, (word_2923)
		call	sub_BCAA
		ret	nc
		ld	bc, (word_2925)
		dec	bc
		ld	(word_2925), bc
		ld	a, b
		cp	0
		jp	nz, loc_67DA
		ld	a, c
		cp	0
		jr	z, loc_67E5
loc_67DA:
		ld	hl, (word_2923)
		ld	bc, 9
		add	hl, bc
		ld	(word_2923), hl
		ret
loc_67E5:
		ld	bc, 111h
		ld	(word_2925), bc
		ld	hl, 69EBh
		ld	(word_2923), hl
		ret
; End of function wait_vbl
handle_game_pause:
		ld	a, KEY_KEYBOARD_ESC
		call	is_key_pressed
		ret	z
		call	loc_BCB6
		call	sub_680E
loc_67FF:
		ld	a, KEY_KEYBOARD_ESC
		call	is_key_pressed
		jp	z, loc_67FF
		call	sub_680E
		call	loc_BCB9
		ret
; End of function handle_game_pause
sub_680E:
		ld	b, 0
loc_6810:
		ld	a, 0
loc_6812:
		dec	a
		jp	nz, loc_6812
		dec	b
		jp	nz, loc_6810
		ret
; End of function sub_680E
game_completed:
		call	clear_screen
		call	clear_tilemap
		call	clear_thread
		ld	a, 132
		ld	bc, 10
		call	set_thread_bytecode
		ld	a, 200
		ld	(player_direction), a
loc_6831:
		call	run_threads
		ld	c, 34
		call	wait
		ld	a, (player_direction)
		dec	a
		ld	(player_direction), a
		jp	nz, loc_6831
		ret
clear_thread:
		ld	hl, threads_bytecode_lo
		ld	d, 2
loc_6849:
		ld	e, 0
loc_684B:
		ld	(hl), 0
		inc	hl
		dec	e
		jp	nz, loc_684B
		ld	hl, threads_bytecode_hi
		dec	d
		jp	nz, loc_6849
		ret
; End of function clear_thread
title_screen:
		call	clear_screen
		ld	a, 2
		ld	b, 2
		ld	c, b
		call	set_palette_color
		ld	a, 3
		ld	b, 26
		ld	c, b
		call	set_palette_color
		call	clear_thread
		ld	a, 130
		ld	bc, 10
		call	set_thread_bytecode
		ld	a, 0
		ld	(counter2), a
loc_687D:
		call	run_threads
		ld	c, 27
		call	wait
		ld	a, KEY_KEYBOARD_SPACE
		call	is_key_pressed
		ret	nz
		ld	a, KEY_JOYSTICK0_DISP1
		call	is_key_pressed
		ret	nz
		ld	a, (counter2)
		dec	a
		ld	(counter2), a
		jp	nz, loc_687D
		call	initialize
		ld	a, 1
		ld	(start_pos), a
		call	restart
		ld	a, (start_pos)
		cp	0
		jp	nz, title_screen
		ret
; End of function title_screen
