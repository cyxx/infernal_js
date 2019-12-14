
//
// system
//

const KEY_UP    = 1;
const KEY_RIGHT = 2;
const KEY_DOWN  = 3;
const KEY_LEFT  = 4;
const KEY_JUMP  = 5;

var keyboard = new Array( 6 );

function is_key_pressed( code ) {
	return keyboard[ code ];
}

function release_key( code ) {
	keyboard[ code ] = 0;
}

function set_key_pressed( jcode, state ) {
	if ( jcode == 37 ) {
		keyboard[ KEY_LEFT ] = state;
	} else if ( jcode == 38 ) {
		keyboard[ KEY_UP ] = state;
	} else if ( jcode == 39 ) {
		keyboard[ KEY_RIGHT ] = state;
	} else if ( jcode == 40 ) {
		keyboard[ KEY_DOWN ] = state;
	} else if ( jcode == 32 || jcode == 13 ) {
		keyboard[ KEY_JUMP ] = state;
	}
}

function set_touch_key( x, y, state ) {
	const r = canvas.getBoundingClientRect( );
	const w = r.width  / 2;
	const h = r.height / 2;
	const x1 = r.left + w / 2;
	const y1 = r.top  + h / 2;
	const x2 = x1 + w;
	const y2 = y1 + h;
	if ( x < x1 ) {
		keyboard[ KEY_LEFT ] = state;
	} else if ( x > x2 ) {
		keyboard[ KEY_RIGHT ] = state;
	} else if ( y < y1 ) {
		keyboard[ KEY_UP ] = state;
	} else if ( y > y2 ) {
		keyboard[ KEY_DOWN ] = state;
	} else {
		keyboard[ KEY_JUMP ] = state;
	}
}

const PALETTE_CPC = [
        0x00, 0x00, 0x00, /* 0x54 */
        0x00, 0x00, 0x80, /* 0x44 */
        0x00, 0x00, 0xff, /* 0x55 */
        0x80, 0x00, 0x00, /* 0x5c */
        0x80, 0x00, 0x80, /* 0x58 */
        0x80, 0x00, 0xff, /* 0x5d */
        0xff, 0x00, 0x00, /* 0x4c */
        0xff, 0x00, 0x80, /* 0x45 */
        0xff, 0x00, 0xff, /* 0x4d */
        0x00, 0x80, 0x00, /* 0x56 */
        0x00, 0x80, 0x80, /* 0x46 */
        0x00, 0x80, 0xff, /* 0x57 */
        0x80, 0x80, 0x00, /* 0x5e */
        0x80, 0x80, 0x80, /* 0x40 */
        0x80, 0x80, 0xff, /* 0x5f */
        0xff, 0x80, 0x00, /* 0x4e */
        0xff, 0x80, 0x80, /* 0x47 */
        0xff, 0x80, 0xff, /* 0x4f */
        0x00, 0xff, 0x00, /* 0x52 */
        0x00, 0xff, 0x80, /* 0x42 */
        0x00, 0xff, 0xff, /* 0x53 */
        0x80, 0xff, 0x00, /* 0x5a */
        0x80, 0xff, 0x80, /* 0x59 */
        0x80, 0xff, 0xff, /* 0x5b */
        0xff, 0xff, 0x00, /* 0x4a */
        0xff, 0xff, 0x80, /* 0x43 */
        0xff, 0xff, 0xff  /* 0x4b */
];

var palette32 = new Uint32Array( 4 );

function set_palette_color( pen, ink ) {
	const offset = ink * 3;
	palette32[ pen ] = (0xff << 24) | (PALETTE_CPC[ offset + 2 ] << 16) | (PALETTE_CPC[ offset + 1 ] << 8) | PALETTE_CPC[ offset ];
}

const SCREEN_W = 320;
const SCREEN_H = 200;

var screen8 = new Uint8Array( SCREEN_W * SCREEN_H ); // this is wasting 6 bits per byte but simplifies the lookups

function clear_screen( ) {
	screen8.fill( 0 );
}

function draw_object( num, x, y ) {
	const w = get_object_width( num );
	const h = get_object_height( num );
	var addr = get_object_addr( num );
	for ( var j = 0; j < h; ++j ) {
		var offset = ( y + j ) * SCREEN_W + x * 4;
		for ( var i = 0; i < w; ++i ) {
			const color_mask = snapshot[ addr++ ];
			screen8[ offset++ ] ^= (((color_mask >> 3) & 1) << 1) | ((color_mask >> 7) & 1); // bit3, bit7
			screen8[ offset++ ] ^= (((color_mask >> 2) & 1) << 1) | ((color_mask >> 6) & 1); // bit2, bit6
			screen8[ offset++ ] ^= (((color_mask >> 1) & 1) << 1) | ((color_mask >> 5) & 1); // bit1, bit5
			screen8[ offset++ ] ^=  ((color_mask       & 1) << 1) | ((color_mask >> 4) & 1); // bit0, bit4
		}
	}
}

function draw_object2( num, x, y ) {
	draw_object( num, x, y );
}

//
// threads
//

const SNAPSHOT_SIZE = 0xA000;
var snapshot = new Array( SNAPSHOT_SIZE );

function get_object_width( num ) {
	return snapshot[ 0x1af6 + num ];
}

function get_object_height( num ) {
	return snapshot[ 0x1bf6 + num ];
}

function get_object_addr( num ) {
	const hi = snapshot[ 0x18f6 + num ];
	const lo = snapshot[ 0x19f6 + num ];
	return (hi << 8) | lo;
}

var thread_num;
var threads_bytecode = new Array( 256 );
var bytecode_offset;
var vars1 = new Array( 60 ); // x_pos
var vars2 = new Array( 60 ); // y_pos

function clear_vars( ) {
	vars1.fill( 0 );
	vars2.fill( 0 );
}

function get_bytecode_addr( num ) {
	const hi = snapshot[ 0x1cf6 + num ];
	const lo = snapshot[ 0x1df6 + num ];
	return (hi << 8) | lo;
}

function clear_threads( ) {
	threads_bytecode.fill( 0 );
}

function set_thread_bytecode( num, thread ) {
	threads_bytecode[ thread ] = get_bytecode_addr( num );
}

var opcodes = {
	0x3e /* > */ : function( ) { // draw player
		draw_object( player_frame, vars1[ 0 ], vars2[ 0 ] );
	},
	0x3f /* ? */ : function( ) { // align player x position
		vars1[ 0 ] &= ~1;
	},
	0x40 /* @ */ : function( ) { // set channel bytecode
		const num     = snapshot[ bytecode_offset++ ];
		const thread = snapshot[ bytecode_offset++ ];
		set_thread_bytecode( num, thread );
	},
	0x41 /* A */ : function( ) { // add var1[var_num], imm
		if ( player_disabled != 1 && var_num == 0) {
			if ( ( snapshot[ 0x1ef6 + get_next_tile( ) ] & (1 << 0) ) == 0 ) {
				bytecode_offset += 1;
				return;
			}
		}
		vars1[ var_num ] += snapshot[ bytecode_offset++ ];
	},
	0x42 /* B */ : function( ) {
		if ( player_disabled != 1 && var_num == 0) {
			if ( ( snapshot[ 0x1ef6 + get_next_tile( ) ] & (1 << 1) ) == 0 ) {
				bytecode_offset += 1;
				return;
			}
		}
		vars1[ var_num ] -= snapshot[ bytecode_offset++ ];
	},
	0x43 /* C */ : function( ) { // add var2[var_num], imm
		if ( player_disabled != 1 && var_num == 0) {
			if ( ( snapshot[ 0x1ef6 + get_next_tile( ) ] & (1 << 2) ) == 0 ) {
				bytecode_offset += 1;
				return;
			}
		}
		vars2[ var_num ] += snapshot[ bytecode_offset++ ];
	},
	0x44 /* D */ : function( ) {
		if ( player_disabled != 1 && player_jumping != 1 && var_num == 0) {
			if ( ( snapshot[ 0x1ef6 + get_next_tile( ) ] & (1 << 3) ) == 0 ) {
				bytecode_offset += 1;
				return;
			}
		}
		vars2[ var_num ] -= snapshot[ bytecode_offset++ ];
	},
	0x45 /* E */ : function( ) { // mov var1[var_num], imm
		vars1[ var_num ] = snapshot[ bytecode_offset++ ];
	},
	0x46 /* F */ : function( ) { // mov var2[var_num], imm
		vars2[ var_num ] = snapshot[ bytecode_offset++ ];
	},
	0x47 /* G */ : function( ) { // set tilemap
		tilemap_x_pos = snapshot[ bytecode_offset++ ];
		tilemap_y_pos = snapshot[ bytecode_offset++ ];
		const value   = snapshot[ bytecode_offset++ ];
		tilemap[ get_tile_offset() ] = value;
	},
	0x48 /* H */ : function( ) { // set tilemap (vertical)
		tilemap_x_pos = snapshot[ bytecode_offset++ ];
		tilemap_y_pos = snapshot[ bytecode_offset++ ];
		const count   = snapshot[ bytecode_offset++ ];
		const value   = snapshot[ bytecode_offset++ ];
		for ( var i = 0; i < count; ++i ) {
			tilemap[ get_tile_offset() ] = value;
			tilemap_y_pos += 1;
		}
	},
	0x49 /* I */ : function( ) { // set tilemap (horizontal)
		tilemap_x_pos = snapshot[ bytecode_offset++ ];
		tilemap_y_pos = snapshot[ bytecode_offset++ ];
		const count   = snapshot[ bytecode_offset++ ];
		const value   = snapshot[ bytecode_offset++ ];
		for ( var i = 0; i < count; ++i ) {
			tilemap[ get_tile_offset() ] = value;
			tilemap_x_pos += 1;
		}
	},
	0x4a /* J */ : function( ) { // jmp
		var num = snapshot[ bytecode_offset++ ];
		set_thread_bytecode( num, thread_num );
		bytecode_offset = threads_bytecode[ thread_num ];
	},
	0x4b /* K */ : function( ) { // draw object
		const x   = vars1[ var_num ];
		const y   = vars2[ var_num ];
		const num = snapshot[ bytecode_offset++ ];
		draw_object( num, x, y );
	},
	0x4c /* L */ : function( ) { // set var_num
		var_num = snapshot[ bytecode_offset++ ];
	},
	0x4d /* M */ : function( ) { // break
		threads_bytecode[ thread_num ] = bytecode_offset;
	},
	0x4f /* O */ : function( ) { // abort
		keys_flag = 0;
		threads_bytecode[ 0 ] = 0;
		player_jumping = 0;
	},
	0x50 /* P */ : function( ) { // disable player
		player_disabled = 1;
		threads_bytecode[ 0 ] = 0;
	},
	0x51 /* Q */ : function( ) { // set player frame
		player_frame = snapshot[ bytecode_offset++ ];
	},
	0x52 /* R */ : function( ) { // test_collision
		var num = snapshot[ bytecode_offset++ ];
		var w = get_object_width( num );
		var h = get_object_height( num );
		var x = vars1[ var_num ]; // b
		var y = vars2[ var_num ]; // c
		//console.log( 'test_collision x:' + x + ' y:' + y + ' w:' + w + ' h:' + h );
		var px = vars1[ 0 ];
		if ( px < x || px + 1 < x ) {
			return;
		}
		if ( px != x && px + 1 != x ) {
			x += w;
			if ( px != x && px > x ) {
				px += 1;
				if ( px != x && px > x ) {
					return;
				}
			}
		}
		var py = vars2[ 0 ] + 7;
		if ( py < y || py + 5 < y ) {
			return;
		}
		if ( py != y && py + 5 != y ) {
			y += h;
			if ( py >= y ) {
				py += 5;
				if ( py != y && py > y ) {
					return;
				}
			}
		}
		set_thread_bytecode( snapshot[ 0x20f6 + num ], num );
	},
	0x53 /* S */ : function( ) { // set channel #0 bytecode
		var num = snapshot[ bytecode_offset++ ];
		set_thread_bytecode( num, 0 );
	},
	0x54 /* T */ : function( ) { // draw object (horizontal)
		var x     = snapshot[ bytecode_offset++ ];
		var y     = snapshot[ bytecode_offset++ ];
		var count = snapshot[ bytecode_offset++ ];
		var num   = snapshot[ bytecode_offset++ ];
		for ( var i = 0; i < count; ++i ) {
			draw_object( num, x, y );
			x += get_object_width( num );
		}
	},
	0x55 /* U */ : function( ) { // draw object (vertical)
		var x     = snapshot[ bytecode_offset++ ];
		var y     = snapshot[ bytecode_offset++ ];
		var count = snapshot[ bytecode_offset++ ];
		var num   = snapshot[ bytecode_offset++ ];
		for ( var i = 0; i < count; ++i ) {
			draw_object( num, x, y );
			y += get_object_height( num );
		}
	},
	0x56 /* V */ : function( ) { // increase score
		increase_score( 1 );
	},
	0x57 /* W */ : function( ) { // decrement and jump
		var num = snapshot[ bytecode_offset++ ];
		if ( snapshot[ 0x21f6 + num ] != 0) {
			--snapshot[ 0x21f6 + num ];
			if ( snapshot[ 0x21f6 + num ] != 0) {
				num = snapshot[ bytecode_offset++ ];
				set_thread_bytecode( num, thread_num );
				bytecode_offset = threads_bytecode[ thread_num ];
				return;
			}
		}
		bytecode_offset += 1;
	},
	0x58 /* X */ : function( ) {
		var num = snapshot[ bytecode_offset++ ];
		var val = snapshot[ bytecode_offset++ ];
		snapshot[ 0x21f6 + num ] = val;
	},
	0x59 /* Y */ : function( ) {
		var x = vars1[ var_num ];
		var y = vars2[ var_num ];
		var num = snapshot[ bytecode_offset++ ];
		draw_object2( num, x, y );
	}
};

function run_threads( ) {
	for ( thread_num = 0; thread_num < 256; ++thread_num ) {
		bytecode_offset = threads_bytecode[ thread_num ];
		while ( bytecode_offset != 0 ) {
			var opcode = snapshot[ bytecode_offset ];
			//console.log("bytecode_offset=" + bytecode_offset + " opcode=" + opcode);
			if ( opcode == 0x4e /* N */ ) {
				break_flag = 1;
				return;
			}
			if ( opcode == 0x5a /* Z */ ) {
				break
			}
			bytecode_offset += 1;
			opcodes[ opcode ]( );
			if ( opcode == 0x4d /* M */ || opcode == 0x4f /* O */ ) {
				break;
			}
		}
	}
}

//
// game
//

var keys;
var score;
var highscore = 0;
var boxes;
var hunger;
var lifes;
var infinite_lifes = false;
var player_disabled;
var var_num;
var keys_flag;
var player_jumping;
var ticks;
var screen_num;
var break_flag;
var start_pos;
var counter3;
var player_direction;
var player_frame;

function initialize( ) {
	// boxes
	snapshot[ 0x28cd ]      = 2;
	snapshot[ 0x28cd +  1 ] = 2;
	snapshot[ 0x28cd +  2 ] = 2;
	snapshot[ 0x28cd +  3 ] = 2;
	snapshot[ 0x28cd +  4 ] = 2;
	snapshot[ 0x28cd +  5 ] = 2;
	snapshot[ 0x28cd +  6 ] = 2;
	snapshot[ 0x28cd +  7 ] = 2;
	snapshot[ 0x28cd +  8 ] = 2;
	snapshot[ 0x28cd +  9 ] = 2;
	snapshot[ 0x28cd + 10 ] = 2;
	// keys
	snapshot[ 0x28a3 +  2 ] = 1;
	snapshot[ 0x28a3 +  5 ] = 1;
	snapshot[ 0x28a3 +  6 ] = 1;
	snapshot[ 0x28a3 +  9 ] = 1;
	snapshot[ 0x28a3 + 11 ] = 1;
	// food
	snapshot[ 0x284f +  6 ] = 1;
	snapshot[ 0x284f +  7 ] = 1;
	snapshot[ 0x284f + 10 ] = 1;
	// rewards
	snapshot[ 0x2879 +  1 ] = 1;
	snapshot[ 0x2879 +  3 ] = 1;
	keys = 0;
	score = 0;
	boxes = 0;
	hunger = 99;
	lifes = 6;
	screen_num = 4;
	ticks = 20;
	set_palette_color( 2, 21 );
	set_palette_color( 3, 14 );
	start_pos = 0;
}

function restart( ) {
	if ( !infinite_lifes ) {
		lifes -= 1;
		if ( lifes == 0 ) {
			state = STATE_TITLE;
			return;
		}
	}
	console.log( 'restart start_pos:' + start_pos + ' screen_num:' + screen_num );
	if ( start_pos != 0 ) {
		if ( start_pos == 6 ) {
			return;
		}
		screen_num = snapshot[ 0x291d + start_pos ];
		start_pos += 1;
		counter3 = 100;
	}
	vars1[ 0 ] = snapshot[ 0x28f7 + screen_num ];
	vars2[ 0 ] = snapshot[ 0x2905 + screen_num ];
	player_frame = 1;
	change_screen( );
}

function run_game_threads( ) {
	clear_threads( );
	set_thread_bytecode( 100 + screen_num, 1 );
	run_threads( );
}

function set_threads_screen( ) {
	clear_threads( );
	var offset = 0;
	if ( screen_num != 0 ) {
		offset += screen_num * 128;
	}
	for ( var i = 1; i < 128; ++i ) {
		set_thread_bytecode( snapshot[ 0x221e + offset + i ], i );
	}
}

function set_thread_boxes( ) {
	if ( boxes == 10 && screen_num == 3 ) {
		set_thread_bytecode( 126, 0 );
	}
}

function change_screen( ) {
	clear_screen( );
	clear_tilemap( );
	draw_panel_score( );
	draw_panel_highscore( );
	draw_panel_hunger( );
	draw_panel_lifes( );
	threads_bytecode[ 0 ] = 0;
	run_game_threads( );
	draw_object_food( );
	draw_object_reward( );
	draw_object_key( );
	draw_object_box( );
	set_threads_screen( );
	draw_object( player_frame, vars1[ 0 ], vars2[ 0 ]);
	player_jumping = 0;
	keys_flag = 0;
	player_disabled = 0;
	break_flag = 0;
	set_thread_boxes( );
}

function update_game_state( ) {
	if ( player_disabled == 1 ) {
		run_threads( );
		if ( break_flag == 1 ) {
			return false;
		}

		return true;
	}
	var tile_flags = snapshot[ 0x1ef6 + get_next_tile( ) ];
	if ( ( tile_flags & 0xf0 ) != 0 ) { // moving walkway
		draw_object( player_frame, vars1[ 0 ], vars2[ 0 ] );
		if ( tile_flags & ( 1 << 4 ) ) {
			vars1[ 0 ] += 1;
		}
		if ( tile_flags & ( 1 << 5 ) ) {
			vars1[ 0 ] -= 1;
		}
		if ( tile_flags & ( 1 << 6 ) ) {
			vars2[ 0 ] += 1;
		}
		if ( tile_flags & ( 1 << 7 ) ) {
			vars2[ 0 ] -= 1;
		}
		draw_object( player_frame, vars1[ 0 ], vars2[ 0 ] );
	}
	var num = get_next_tile( );
	if ( snapshot[ 0x20f6 + num ] != 0 ) {
		set_thread_bytecode( snapshot[ 0x20f6 + num ], num );
	}
	if ( keys_flag != 1 ) {
		num = get_next_tile( );
		if ( snapshot[ 0x1ff6 + num ] != 0 ) {
			set_thread_bytecode( snapshot[ 0x1ff6 + num ], 0 );
			keys_flag = 1;
		} else {
			if ( start_pos == 0 ) {
				if ( is_key_pressed( KEY_JUMP ) ) {
					if ( player_direction != 0 ) {
						set_thread_bytecode( 6, 0 );
					} else {
						set_thread_bytecode( 5, 0 );
					}
					keys_flag = 1;
					player_jumping = 1;
				} else {
					num = get_next_tile( );
					if ( ( snapshot[ 0x1ef6 + num ] & 0xc ) != 0 ) { // stairs
						if ( is_key_pressed( KEY_UP ) ) {
							set_thread_bytecode( 3, 0 );
							keys_flag = 1;
						} else if ( is_key_pressed( KEY_DOWN ) ) {
							set_thread_bytecode( 4, 0 );
							keys_flag = 1;
						}
					}
					if ( is_key_pressed( KEY_RIGHT ) ) {
						set_thread_bytecode( 1, 0 );
						keys_flag = 1;
						player_direction = 0;
					} else if ( is_key_pressed( KEY_LEFT ) ) {
						set_thread_bytecode( 2, 0 );
						keys_flag = 1;
						player_direction = 1;
					}
				}
			}
		}
	}
	handle_food( );
	handle_reward( );
	handle_key( );
	handle_box( );
	run_threads( );
	if ( boxes == 10 && screen_num == 3 && vars1[ 0 ] == 2 && vars2[ 0 ] == 130 ) {
		state = STATE_COMPLETED;
	} else {

		if ( start_pos != 0 ) {
			const tmp = start_pos;
			start_pos = 0;
			if ( is_key_pressed( KEY_JUMP ) ) {
				return false;
			}
			start_pos = tmp;
			counter3 -= 1;
			if ( counter3 == 0 ) {
				return false;
			}
		}
		if ( vars2[ 0 ] == 0 || vars2[ 0 ] == 1 ) {
			vars2[ 0 ] = 150;
			screen_num += 3;
			change_screen( );
		} else if ( vars2[ 0 ] > 151 ) {
			vars2[ 0 ] = 2;
			screen_num -= 3;
			change_screen( );
		} else if ( vars1[ 0 ] == 0 ) {
			vars1[ 0 ] = 77;
			screen_num -= 1;
			change_screen( );
		} else if ( vars1[ 0 ] > 79 ) {
			vars1[ 0 ] = 2;
			screen_num += 1;
			change_screen( );
		}
	}
	return true;
}

function draw_object_food( ) {
	const offset = 0x284f + screen_num;
	if ( snapshot[ offset ] != 0 ) {
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 58, x, y );
		tilemap_x_pos =  x >> 1;
		tilemap_y_pos = (y + 7) >> 3;
		tilemap[ get_tile_offset( ) ] = 0x32;
	}
}

function handle_food( ) {
	if ( get_next_tile( ) == 0x32 ) {
		tilemap[ tilemap_offset ] = 1;
		const offset = 0x2879 + screen_num;
		snapshot[ offset ] = 0;
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 58, x, y );
		increase_score( 1 );
		draw_panel_hunger( );
		hunger = 99;
		draw_panel_hunger( );
	}
}

function draw_object_reward( ) {
	const offset = 0x2879 + screen_num;
	if ( snapshot[ offset ] != 0 ) {
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 21, x, y );
		tilemap_x_pos =  x >> 1;
		tilemap_y_pos = (y + 4) >> 3;
		tilemap[ get_tile_offset( ) ] = 0x33;
	}
}

function handle_reward( ) {
	if ( get_next_tile( ) == 0x33 ) {
		tilemap[ tilemap_offset ] = 1;
		const offset = 0x2879 + screen_num;
		snapshot[ offset ] = 0;
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 21, x, y );
		increase_score( 2 );
		draw_panel_hunger( );
		hunger = 99;
		draw_panel_hunger( );
	}
}

function draw_object_key( ) {
	const offset = 0x28a3 + screen_num;
	if ( snapshot[ offset ] != 0 ) {
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 37, x, y );
		tilemap_x_pos =  x >> 1;
		tilemap_y_pos = (y + 5) >> 3;
		tilemap[ get_tile_offset( ) ] = 0x34;
	}
}

function handle_key( ) {
	if ( get_next_tile( ) == 0x34 ) {
		tilemap[ tilemap_offset ] = 1;
		const offset = 0x28a3 + screen_num;
		snapshot[ offset ] = 0;
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ];
		draw_object( 37, x, y );
		keys += 2;
		increase_score( 5 );
	}
}

function draw_object_box( ) {
	const offset = 0x28cd + screen_num;
	if ( snapshot[ offset ] != 0 ) {
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ] + 4;
		draw_object( 38, x, y );
		tilemap_x_pos =  x >> 1;
		tilemap_y_pos = (y + 4) >> 3;
		tilemap[ get_tile_offset( ) ] = 0x35;
	}
}

function handle_box( ) {
	if ( get_next_tile( ) == 0x35 ) {
		tilemap[ tilemap_offset ] = 1;
		const offset = 0x28cd + screen_num;
		snapshot[ offset ] = 0;
		const x = snapshot[ offset + 14 ];
		const y = snapshot[ offset + 28 ] + 4;
		draw_object( 38, x, y );
		draw_object( 39, x, y );
		increase_score( 4 );
		boxes += 1;
		keys -= 1;
		set_thread_boxes( );
	}
}

function increase_score( n ) {
	draw_panel_highscore( );
	draw_panel_score( );
	score += 67 * n;
	if ( score > highscore ) {
		highscore = score;
	}
	draw_panel_highscore( );
	draw_panel_score( );
}

//
// tilemap
//

var tilemap = new Array( 40 * 21 );
var tilemap_x_pos;
var tilemap_y_pos;
var tilemap_offset;

function clear_tilemap( ) {
	tilemap.fill( 0 );
}

function get_tile_offset( ) {
	tilemap_offset = tilemap_x_pos;
	if ( tilemap_y_pos != 0 ) {
		tilemap_offset += tilemap_y_pos * 40;
	}
	return tilemap_offset;
}

function get_current_tile( ) {
	tilemap_x_pos =  vars1[ 0 ] >> 1;
	tilemap_y_pos = (vars2[ 0 ] + 8) >> 3;
	return tilemap[ get_tile_offset() ];
}

function get_next_tile( ) {
	var num = get_current_tile( );
	if ( num == 0 ) {
		vars1[ 0 ] += 1;
		num = get_current_tile( );
		vars1[ 0 ] -= 1;
	}
	return num;
}

//
// panel
//

function draw_panel_number( num, digits, x, y ) {
	x += digits * 2;
	for ( var i = 0; i < digits; ++i ) {
		x -= 2;
		draw_object( 44 + ( num % 10 ), x, y );
		num = ( num / 10 ) >> 0;
	}
}

function draw_panel_score( ) {
	draw_panel_number( score, 6, 36, 176 );
}

function draw_panel_highscore( ) {
	draw_panel_number( highscore, 6, 64, 176 );
}

function draw_panel_hunger( ) {
	draw_panel_number( hunger, 2, 40, 184 );
}

function draw_panel_lifes( ) {
	draw_panel_number( lifes, 2, 68, 184 );
}

//
// html
//

var canvas;
var timer;
var audio;

const INTERVAL = 100;

function init( name ) {
	canvas = document.getElementById( name );
	document.onkeydown = function( e ) { set_key_pressed( e.keyCode, 1 ); }
	document.onkeyup   = function( e ) { set_key_pressed( e.keyCode, 0 ); }
	canvas.addEventListener( 'mousedown', function( e ) { set_touch_key( e.clientX, e.clientY, 1 ); } );
	canvas.addEventListener( 'mouseup',   function( e ) { set_touch_key( e.clientX, e.clientY, 0 ); } );
	audio = new Audio( 'inferrun.ogg' );
	audio.addEventListener( 'ended' , function( ) { this.currentTime = 0; this.play( ); }, false );
}

function pause( ) {
	if ( timer ) {
		audio.pause( );
		clearInterval( timer );
		timer = null;
		return true;
	}
	audio.play( );
	timer = setInterval( tick, INTERVAL );
	return false;
}

function reset( ) {
	clear_vars( );
	set_palette_color( 0, 0 );
	set_palette_color( 1, 6 );
	state = STATE_TITLE;
	if ( timer ) {
		clearInterval( timer );
	}
	timer = setInterval( tick, INTERVAL );
}

function mute( ) {
	if ( !audio.paused ) {
		audio.pause( );
		return true;
	}
	audio.play( );
	return false;
}

function set_infinite_lifes( b ) {
	infinite_lifes = b;
}

function update_screen( ) {
	var context = canvas.getContext( '2d' );
	var data = context.getImageData( 0, 0, SCREEN_W, SCREEN_H );
	var rgba = new Uint32Array( data.data.buffer );
	for ( var i = 0; i < SCREEN_W * SCREEN_H; ++i ) {
		const color = screen8[ i ];
		rgba[ i ] = palette32[ color ];
	}
	context.putImageData( data, 0, 0 );
}

function load_snapshot( data ) {
	for ( var i = 0; i < SNAPSHOT_SIZE; ++i ) {
		snapshot[ i ] = data.charCodeAt( i ) & 0xff;
	}
	reset( );
}

const STATE_TITLE     = 1;
const STATE_GAME      = 2;
const STATE_COMPLETED = 3;

var state, prev_state;

function tick( ) {
	if ( state != prev_state ) {
		if ( state == STATE_TITLE ) {
			clear_screen( );
			set_palette_color( 2, 2 );
			set_palette_color( 3, 26 );
			clear_threads( );
			set_thread_bytecode( 130, 10 );
		} else if ( state == STATE_GAME ) {
			initialize( );
			restart( );
		} else if ( state == STATE_COMPLETED ) {
			clear_screen( );
			clear_tilemap( );
			clear_threads( );
			set_thread_bytecode( 132, 10 );
			player_direction = 200;
		}
		prev_state = state;
	}
	if ( state == STATE_TITLE ) {
		run_threads( );
		if ( is_key_pressed( KEY_JUMP ) ) {
			release_key( KEY_JUMP );
			state = STATE_GAME;
		}
	} else if ( state == STATE_GAME ) {
		if ( !update_game_state( ) ) {
			restart( );
		} else {
			ticks -= 1;
			if ( ticks == 0 ) {
				ticks = 18;
				draw_panel_hunger( );
				hunger -= 1;
				draw_panel_hunger( );
				if ( hunger == 0 ) {
					restart( );
				}
			}
		}
	} else if ( state == STATE_COMPLETED ) {
		run_threads( );
		player_direction -= 1;
		if ( player_direction == 0 ) {
			state = STATE_TITLE;
		}
	}
	update_screen( );
}
