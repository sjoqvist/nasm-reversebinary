;;; NASM solution to the 'Reversed Binary Numbers' programming puzzle
;;;
;;; The program expects to read a decimal integer from stdin, reverse the
;;; order of the bits in it, and write the resulting number back to stdout.
;;; It's required to handle integers in the range [1, 1e9], but is designed to
;;; handled the range [0, (1<<32)-1]. However, it's not designed to handle
;;; long lines (e.g. an exaggerated amount of leading zeros) or any non-digit
;;; characters except for newline in the input.
;;;
;;; Main layout of the program:
;;;   1. Read from stdin to a buffer.
;;;   2. Parse the buffer by multiplying the previous result by 10 and adding
;;;      the new digit until an ASCII character < '0' is found.
;;;   3. Reverse the integer looping over the bits and adding them to another
;;;      register in the reverse order.
;;;   4. Write the result back to the buffer, writing from the end of the
;;;      buffer towards the beginning and diving by 10 after each iteration.
;;;   5. Print the contents of the buffer to stdout.
;;;   6. Exit with status code 0 (success).
;;;
;;; Regarding optimizations: To save space, `xor` is used to clear registers
;;; and `test` to compare with zero. Sometimes, instructions might seem out of
;;; order. This is usually done in the hopes of improving performance by
;;; utilizing the CPU pipelines better. Also, at one point a value is saved on
;;; the stack for use in a different part of the program. This is marked (*).

section .text
	global _start

_start:
	;; eax == 0 and edx == 0 (for Linux >= 2.0)
	;; other registers are unpredictable and differ between versions

read_stdin:
	;; Read from stdin to the buffer
	mov     ecx, buffer     ; arg: char __user *buf
	xor     ebx, ebx        ; arg: file descriptor 0 (stdin)
	mov     al, 3           ; syscall: sys_read
	mov     dl, buf_len-1   ; arg: size_t count, with null-termination
	mov     edi, ecx        ; store address of last byte of the buffer
	mov     esi, ecx
	add     edi, edx        ; add buffer length - 1 to reach last byte
	int     0x80

	;; syscalls should preserve everything but eax, hence:
	;; ebx == 0
	;; edi == &buffer[buf_len-1]
	;; esi == &buffer[0]

parse_integer:
	;; Parse number in buffer, from left to right, and place it in ebx
	cld                     ; loop in positive direction (left to right)
	xor     eax, eax
.loop:
	shl     ebx, 1          ; quick multiplication: x*10 == (x<<1)+(x<<3)
	mov     edx, ebx
	shl     edx, 2
	add     ebx, edx
	add     ebx, eax        ; add recently parsed digit
	lodsb
	sub     al, '0'         ; make an integer out of the ASCII digit
	jae     .loop           ; continue for as long as ASCII code is >= '0'

	;; eax & (0xffffff00) == 0
	;; ebx == parsed number
	;; edi == &buffer[buf_len - 1]

write_newline:
	;; Write newline character, and prepare for writing the reverse number
	mov     al, 0x0a        ; newline character
	std                     ; loop in negative direction (right to left)
	mov     ecx, eax        ; set denominator to 10 for division later
	push    edi             ; (*) save buffer termination address
	stosb

	;; eax == 0x0a
	;; ebx == parsed number
	;; ecx == 0x0a
	;; edi == &buffer[buf_len - 2]

reverse:
	;; Reverse ebx and place it in eax, by shifting ebx to the right and
	;; eax to the left, copying one bit at a time
	xor     eax, eax
.loop:
	shr     ebx, 1          ; shift with LSB going into CF (affects ZF)
	rcl     eax, 1          ; rotate with LSB from CF (doesn't affect ZF)
	jnz     .loop           ; continue while ebx is non-zero

	;; eax == reversed number
	;; ebx == 0
	;; ecx == 0x0a
	;; edi == &buffer[buf_len - 2]

write_integer:
	;; Write a decimal representation of eax, from right to left
.loop:
	xor     edx, edx        ; clear top half of the numerator (edx:eax)
	div     ecx
	push    ax              ; save ax while writing the remainder
	mov     al, dl
	add     al, '0'         ; write ASCII representation of the remainder
	stosb
	pop     ax              ; restore ax
	test    eax, eax
	jnz     .loop           ; loop while quotient is non-zero

	;; eax == 0
	;; ebx == 0
	;; edi == &buffer[(start of output string) - 1]

print_stdout:
	;; Print the number to stdout
	mov     ecx, edi
	pop     edx             ; (*) get buffer termination address
	sub     edx, ecx        ; arg: size_t count (end-start address diff)
	inc     ecx             ; arg: char __user *buf (first digit char)
	mov     al, 4           ; syscall: sys_write
	inc     ebx             ; arg: file descriptor 1 (stdout)
	int     0x80

	;; ebx == 1

exit:
	;; Exit
	mov     eax, ebx        ; syscall: sys_exit
	dec     ebx             ; arg: status code 0
	int     0x80

section .bss
	;; This section is zeroed out at startup

buffer  resb    64              ; reserving >256 bytes breaks the code
buf_len equ     $-buffer
