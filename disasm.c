
#include <assert.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

static FILE *_out;

static uint8_t _snapshot[0x10000];

static void print_object(uint8_t num) {
	const uint8_t hi = _snapshot[0x18F6 + num];
	const uint8_t lo = _snapshot[0x19F6 + num];
	const uint16_t addr = (hi << 8) | lo;
	const uint8_t w = _snapshot[0x1AF6 + num];
	const uint8_t h = _snapshot[0x1BF6 + num];
	fprintf(_out, "\t\t\t gfx #%d offset 0x%04X w %d h %d\n", num, addr, w, h);
}

static void print_bytecode(uint8_t num) {
	const uint8_t hi = _snapshot[0x1CF6 + num];
	const uint8_t lo = _snapshot[0x1DF6 + num];
	const uint16_t addr = (hi << 8) | lo;
	fprintf(_out, "\t\t\t bytecode #%d offset 0x%04X\n", num, addr);
}

void decode(const uint8_t *ptr) {
	const uint8_t *base = ptr;
	while (1) {
		fprintf(_out, "\t %04x %c (%02x)  ", (uint16_t)(ptr - base), *ptr, *ptr);
		const uint8_t op = *ptr++;
		if (op == 0x4E /* N */ || op == 0x5A /* Z */) {
			fputc('\n', _out);
			break;
		}
		switch (op) {
		case 0x3E: // '>'
			fprintf(_out, "DRAW_PLAYER\n");
			break;
		case 0x3F: // '?'
			fprintf(_out, "VARS1(0) &= ~1\n");
			break;
		case 0x40: { // '@'
				const uint8_t num = *ptr++;
				const uint8_t trigger = *ptr++;
				fprintf(_out, "SET_TRIGGER_BYTECODE( num:%d, trigger:%d )\n", num, trigger);
				print_bytecode(num);
			}
			break;
		case 0x41: { // 'A'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS1(CURRENT_VAR) += %d\n", imm);
			}
			break;
		case 0x42: { // 'B'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS1(CURRENT_VAR) -= %d\n", imm);
			}
			break;
		case 0x43: { // 'C'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS2(CURRENT_VAR) += %d\n", imm);
			}
			break;
		case 0x44: { // 'D'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS2(CURRENT_VAR) -= %d\n", imm);
			}
			break;
		case 0x45: { // 'E'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS1(CURRENT_VAR) = %d\n", imm);
			}
			break;
		case 0x46: { // 'F'
				const uint8_t imm = *ptr++;
				fprintf(_out, "VARS2(CURRENT_VAR) = %d\n", imm);
			}
			break;
		case 0x47: { // 'G'
				const uint8_t x   = *ptr++;
				const uint8_t y   = *ptr++;
				const uint8_t val = *ptr++;
				fprintf(_out, "SET_TILEMAP x:%d y:%d value:0x%02X\n", x, y, val);
			}
			break;
		case 0x48: { // 'H'
				const uint8_t x     = *ptr++;
				const uint8_t y     = *ptr++;
				const uint8_t count = *ptr++;
				const uint8_t val   = *ptr++;
				fprintf(_out, "SET_TILEMAP_V x:%d y:%d value:0x%02X count:%d\n", x, y, val, count);
			}
			break;
		case 0x49: { // 'I'
				const uint8_t x     = *ptr++;
				const uint8_t y     = *ptr++;
				const uint8_t count = *ptr++;
				const uint8_t val   = *ptr++;
				fprintf(_out, "SET_TILEMAP_H x:%d y:%d value:0x%02X count:%d\n", x, y, val, count);
			}
			break;
		case 0x4A: { // 'J'
				const uint8_t num = *ptr++;
				fprintf(_out, "JMP_BYTECODE( num:%d )\n", num);
				print_bytecode(num);
			}
			break;
		case 0x4B: { // 'K'
				const uint8_t num = *ptr++;
				fprintf(_out, "DRAW_OBJECT num:%d x:VARS1(CURRENT_VAR) y:VARS2(CURRENT_VAR)\n", num);
				print_object(num);
			}
			break;
		case 0x4C: { // 'L'
				const uint8_t num = *ptr++;
				fprintf(_out, "CURRENT_VAR = %d\n", num);
			}
			break;
		case 0x4D: // 'M'
			fprintf(_out, "BREAK\n");
			break;
		case 0x4F: // 'O'
			fprintf(_out, "KILL_PLAYER\n");
			break;
		case 0x50: // 'P'
			fprintf(_out, "DISABLE_PLAYER\n");
			break;
		case 0x51: { // 'Q'
				const uint8_t num = *ptr++;
				fprintf(_out, "SET_PLAYER_FRAME num:%d\n", num);
			}
			break;
		case 0x52: { // 'R'
				const uint8_t num = *ptr++;
				fprintf(_out, "TEST_OBJECT_COLLISION gfx:%d\n", num);
				print_object(num);
			}
			break;
		case 0x53: { // 'S'
				const uint8_t num = *ptr++;
				fprintf(_out, "SET_TRIGGER_BYTECODE( num:%d, trigger:0 )\n", num);
				print_bytecode(num);
			}
			break;
		case 0x54: { // 'T'
				const uint8_t x     = *ptr++;
				const uint8_t y     = *ptr++;
				const uint8_t count = *ptr++;
				const uint8_t num   = *ptr++;
				fprintf(_out, "DRAW_OBJECT_H num:%d x:%d y:%d count:%d\n", num, x, y, count);
				print_object(num);
			}
			break;
		case 0x55: { // 'U'
				const uint8_t x     = *ptr++;
				const uint8_t y     = *ptr++;
				const uint8_t count = *ptr++;
				const uint8_t num   = *ptr++;
				fprintf(_out, "DRAW_OBJECT_V num:%d x:%d y:%d count:%d\n", num, x, y, count);
				print_object(num);
			}
			break;
		case 0x56: // 'V'
			fprintf(_out, "INCREASE_SCORE\n");
			break;
		case 0x57: { // 'W'
				const uint8_t var = *ptr++;
				const uint8_t num = *ptr++;
				fprintf(_out, "--COUNTERS(%d) == 0 && JUMP_BYTECODE( num:%d )\n", var, num);
				print_bytecode(num);
			}
			break;
		case 0x58: { // 'X'
				const uint8_t var = *ptr++;
				const uint8_t val = *ptr++;
				fprintf(_out, "COUNTERS(%d) = %d\n", var, val);
			}
			break;
		case 0x59: { // 'Y'
				const uint8_t num = *ptr++;
				fprintf(_out, "DRAW_OBJECT2 num:%d x:VARS1(CURRENT_VAR) y:VARS2(CURRENT_VAR)\n", num);
				print_object(num);
			}
			break;
		}
	}
}

int main(int argc, char *argv[]) {
	_out = stdout;
	if (argc == 2) {
		FILE *fp = fopen(argv[1], "rb");
		if (fp) {
			fseek(fp, -sizeof(_snapshot), SEEK_END);
			const int count = fread(_snapshot, 1, sizeof(_snapshot), fp);
			fclose(fp);
			// fprintf(_out, "read %d bytes\n", count);
			assert(count == sizeof(_snapshot));
			for (int i = 0; i < 256; ++i) {
				const uint8_t hi = _snapshot[0x1CF6 + i];
				const uint8_t lo = _snapshot[0x1DF6 + i];
				const uint16_t addr = (hi << 8) | lo;
				fprintf(_out, "bytecode #%d offset 0x%x\n", i, addr);
				switch (i) {
				case 1:
					fprintf(_out, "\t // player going right\n");
					break;
				case 2:
					fprintf(_out, "\t // player going left\n");
					break;
				case 3:
					fprintf(_out, "\t // player going up\n");
					break;
				case 4:
					fprintf(_out, "\t // player going down\n");
					break;
				case 5:
					fprintf(_out, "\t // player jumping right\n");
					break;
				case 6:
					fprintf(_out, "\t // player jumping left\n");
					break;
				case 126:
					fprintf(_out, "\t // boxes\n");
					break;
				case 130:
					fprintf(_out, "\t // title screen\n");
					break;
				case 132:
					fprintf(_out, "\t // game completed\n");
					break;
				}
				if (addr != 0) {
					decode(_snapshot + addr);
				}
			}
		}
	}
	return 0;
}
