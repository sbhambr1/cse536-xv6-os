
user/_test4-odheap:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

/* Simple example that allocates heap memory and accesses it. */

int
main(int argc, char *argv[])
{
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
    /* Allocate as many pages as allowed. */
    int npages = 10;
    void* heappages = sbrk(4096*npages);
   8:	6529                	lui	a0,0xa
   a:	00000097          	auipc	ra,0x0
   e:	39e080e7          	jalr	926(ra) # 3a8 <sbrk>
    if (!heappages) {
  12:	cd29                	beqz	a0,6c <main+0x6c>
  14:	6785                	lui	a5,0x1
  16:	00f50633          	add	a2,a0,a5
  1a:	86b2                	mv	a3,a2
        return -1;
    }

    /* Write random numbers to the allocated heap regions. */
    int* a;
    int count = 0;
  1c:	4701                	li	a4,0
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
  1e:	787d                	lui	a6,0xfffff
    for (int i = 0; i < npages; i++) {
  20:	6505                	lui	a0,0x1
  22:	45a9                	li	a1,10
        a = ((int*) (heappages + i*PGSIZE));
  24:	010687b3          	add	a5,a3,a6
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            *a = count;
  28:	c398                	sw	a4,0(a5)
            a++;
  2a:	0791                	add	a5,a5,4 # 1004 <freep+0x4>
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  2c:	fed79ee3          	bne	a5,a3,28 <main+0x28>
        }
        count++;
  30:	2705                	addw	a4,a4,1
    for (int i = 0; i < npages; i++) {
  32:	96aa                	add	a3,a3,a0
  34:	feb718e3          	bne	a4,a1,24 <main+0x24>
    }

    /* Assert heap memory correctness by checking the regions. */
    count = 0;
  38:	4681                	li	a3,0
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
  3a:	75fd                	lui	a1,0xfffff
  3c:	00b607b3          	add	a5,a2,a1
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            if (*a != count) 
  40:	4398                	lw	a4,0(a5)
  42:	02d71f63          	bne	a4,a3,80 <main+0x80>
                goto fail;
            a++;
  46:	0791                	add	a5,a5,4
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  48:	fec79ce3          	bne	a5,a2,40 <main+0x40>
        }
        count++;
  4c:	2685                	addw	a3,a3,1
    for (int i = 0; i < npages; i++) {
  4e:	6785                	lui	a5,0x1
  50:	963e                	add	a2,a2,a5
  52:	47a9                	li	a5,10
  54:	fef694e3          	bne	a3,a5,3c <main+0x3c>
    }

    printf("[*] Heap test PASSED.\n");
  58:	00001517          	auipc	a0,0x1
  5c:	81850513          	add	a0,a0,-2024 # 870 <malloc+0x130>
  60:	00000097          	auipc	ra,0x0
  64:	628080e7          	jalr	1576(ra) # 688 <printf>
    return 0;
  68:	4501                	li	a0,0
  6a:	a025                	j	92 <main+0x92>
        printf("[X] Heap memory allocation FAILED.\n");
  6c:	00000517          	auipc	a0,0x0
  70:	7c450513          	add	a0,a0,1988 # 830 <malloc+0xf0>
  74:	00000097          	auipc	ra,0x0
  78:	614080e7          	jalr	1556(ra) # 688 <printf>
        return -1;
  7c:	557d                	li	a0,-1
  7e:	a811                	j	92 <main+0x92>

fail:
    printf("[X] Heap test FAILED.\n");
  80:	00000517          	auipc	a0,0x0
  84:	7d850513          	add	a0,a0,2008 # 858 <malloc+0x118>
  88:	00000097          	auipc	ra,0x0
  8c:	600080e7          	jalr	1536(ra) # 688 <printf>
    return -1;
  90:	557d                	li	a0,-1
  92:	60a2                	ld	ra,8(sp)
  94:	6402                	ld	s0,0(sp)
  96:	0141                	add	sp,sp,16
  98:	8082                	ret

000000000000009a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  9a:	1141                	add	sp,sp,-16
  9c:	e406                	sd	ra,8(sp)
  9e:	e022                	sd	s0,0(sp)
  a0:	0800                	add	s0,sp,16
  extern int main();
  main();
  a2:	00000097          	auipc	ra,0x0
  a6:	f5e080e7          	jalr	-162(ra) # 0 <main>
  exit(0);
  aa:	4501                	li	a0,0
  ac:	00000097          	auipc	ra,0x0
  b0:	274080e7          	jalr	628(ra) # 320 <exit>

00000000000000b4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  b4:	1141                	add	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ba:	87aa                	mv	a5,a0
  bc:	0585                	add	a1,a1,1 # fffffffffffff001 <base+0xffffffffffffdff1>
  be:	0785                	add	a5,a5,1 # 1001 <freep+0x1>
  c0:	fff5c703          	lbu	a4,-1(a1)
  c4:	fee78fa3          	sb	a4,-1(a5)
  c8:	fb75                	bnez	a4,bc <strcpy+0x8>
    ;
  return os;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	add	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	1141                	add	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb91                	beqz	a5,ee <strcmp+0x1e>
  dc:	0005c703          	lbu	a4,0(a1)
  e0:	00f71763          	bne	a4,a5,ee <strcmp+0x1e>
    p++, q++;
  e4:	0505                	add	a0,a0,1
  e6:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbe5                	bnez	a5,dc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ee:	0005c503          	lbu	a0,0(a1)
}
  f2:	40a7853b          	subw	a0,a5,a0
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	add	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strlen>:

uint
strlen(const char *s)
{
  fc:	1141                	add	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cf91                	beqz	a5,122 <strlen+0x26>
 108:	0505                	add	a0,a0,1
 10a:	87aa                	mv	a5,a0
 10c:	86be                	mv	a3,a5
 10e:	0785                	add	a5,a5,1
 110:	fff7c703          	lbu	a4,-1(a5)
 114:	ff65                	bnez	a4,10c <strlen+0x10>
 116:	40a6853b          	subw	a0,a3,a0
 11a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	add	sp,sp,16
 120:	8082                	ret
  for(n = 0; s[n]; n++)
 122:	4501                	li	a0,0
 124:	bfe5                	j	11c <strlen+0x20>

0000000000000126 <memset>:

void*
memset(void *dst, int c, uint n)
{
 126:	1141                	add	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12c:	ca19                	beqz	a2,142 <memset+0x1c>
 12e:	87aa                	mv	a5,a0
 130:	1602                	sll	a2,a2,0x20
 132:	9201                	srl	a2,a2,0x20
 134:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 138:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13c:	0785                	add	a5,a5,1
 13e:	fee79de3          	bne	a5,a4,138 <memset+0x12>
  }
  return dst;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	add	sp,sp,16
 146:	8082                	ret

0000000000000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	1141                	add	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	add	s0,sp,16
  for(; *s; s++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb99                	beqz	a5,168 <strchr+0x20>
    if(*s == c)
 154:	00f58763          	beq	a1,a5,162 <strchr+0x1a>
  for(; *s; s++)
 158:	0505                	add	a0,a0,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbfd                	bnez	a5,154 <strchr+0xc>
      return (char*)s;
  return 0;
 160:	4501                	li	a0,0
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	add	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strchr+0x1a>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	711d                	add	sp,sp,-96
 16e:	ec86                	sd	ra,88(sp)
 170:	e8a2                	sd	s0,80(sp)
 172:	e4a6                	sd	s1,72(sp)
 174:	e0ca                	sd	s2,64(sp)
 176:	fc4e                	sd	s3,56(sp)
 178:	f852                	sd	s4,48(sp)
 17a:	f456                	sd	s5,40(sp)
 17c:	f05a                	sd	s6,32(sp)
 17e:	ec5e                	sd	s7,24(sp)
 180:	1080                	add	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18a:	4aa9                	li	s5,10
 18c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18e:	89a6                	mv	s3,s1
 190:	2485                	addw	s1,s1,1
 192:	0344d863          	bge	s1,s4,1c2 <gets+0x56>
    cc = read(0, &c, 1);
 196:	4605                	li	a2,1
 198:	faf40593          	add	a1,s0,-81
 19c:	4501                	li	a0,0
 19e:	00000097          	auipc	ra,0x0
 1a2:	19a080e7          	jalr	410(ra) # 338 <read>
    if(cc < 1)
 1a6:	00a05e63          	blez	a0,1c2 <gets+0x56>
    buf[i++] = c;
 1aa:	faf44783          	lbu	a5,-81(s0)
 1ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b2:	01578763          	beq	a5,s5,1c0 <gets+0x54>
 1b6:	0905                	add	s2,s2,1
 1b8:	fd679be3          	bne	a5,s6,18e <gets+0x22>
  for(i=0; i+1 < max; ){
 1bc:	89a6                	mv	s3,s1
 1be:	a011                	j	1c2 <gets+0x56>
 1c0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c2:	99de                	add	s3,s3,s7
 1c4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c8:	855e                	mv	a0,s7
 1ca:	60e6                	ld	ra,88(sp)
 1cc:	6446                	ld	s0,80(sp)
 1ce:	64a6                	ld	s1,72(sp)
 1d0:	6906                	ld	s2,64(sp)
 1d2:	79e2                	ld	s3,56(sp)
 1d4:	7a42                	ld	s4,48(sp)
 1d6:	7aa2                	ld	s5,40(sp)
 1d8:	7b02                	ld	s6,32(sp)
 1da:	6be2                	ld	s7,24(sp)
 1dc:	6125                	add	sp,sp,96
 1de:	8082                	ret

00000000000001e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e0:	1101                	add	sp,sp,-32
 1e2:	ec06                	sd	ra,24(sp)
 1e4:	e822                	sd	s0,16(sp)
 1e6:	e426                	sd	s1,8(sp)
 1e8:	e04a                	sd	s2,0(sp)
 1ea:	1000                	add	s0,sp,32
 1ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ee:	4581                	li	a1,0
 1f0:	00000097          	auipc	ra,0x0
 1f4:	170080e7          	jalr	368(ra) # 360 <open>
  if(fd < 0)
 1f8:	02054563          	bltz	a0,222 <stat+0x42>
 1fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fe:	85ca                	mv	a1,s2
 200:	00000097          	auipc	ra,0x0
 204:	178080e7          	jalr	376(ra) # 378 <fstat>
 208:	892a                	mv	s2,a0
  close(fd);
 20a:	8526                	mv	a0,s1
 20c:	00000097          	auipc	ra,0x0
 210:	13c080e7          	jalr	316(ra) # 348 <close>
  return r;
}
 214:	854a                	mv	a0,s2
 216:	60e2                	ld	ra,24(sp)
 218:	6442                	ld	s0,16(sp)
 21a:	64a2                	ld	s1,8(sp)
 21c:	6902                	ld	s2,0(sp)
 21e:	6105                	add	sp,sp,32
 220:	8082                	ret
    return -1;
 222:	597d                	li	s2,-1
 224:	bfc5                	j	214 <stat+0x34>

0000000000000226 <atoi>:

int
atoi(const char *s)
{
 226:	1141                	add	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22c:	00054683          	lbu	a3,0(a0)
 230:	fd06879b          	addw	a5,a3,-48
 234:	0ff7f793          	zext.b	a5,a5
 238:	4625                	li	a2,9
 23a:	02f66863          	bltu	a2,a5,26a <atoi+0x44>
 23e:	872a                	mv	a4,a0
  n = 0;
 240:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 242:	0705                	add	a4,a4,1
 244:	0025179b          	sllw	a5,a0,0x2
 248:	9fa9                	addw	a5,a5,a0
 24a:	0017979b          	sllw	a5,a5,0x1
 24e:	9fb5                	addw	a5,a5,a3
 250:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 254:	00074683          	lbu	a3,0(a4)
 258:	fd06879b          	addw	a5,a3,-48
 25c:	0ff7f793          	zext.b	a5,a5
 260:	fef671e3          	bgeu	a2,a5,242 <atoi+0x1c>
  return n;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	add	sp,sp,16
 268:	8082                	ret
  n = 0;
 26a:	4501                	li	a0,0
 26c:	bfe5                	j	264 <atoi+0x3e>

000000000000026e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26e:	1141                	add	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 274:	02b57463          	bgeu	a0,a1,29c <memmove+0x2e>
    while(n-- > 0)
 278:	00c05f63          	blez	a2,296 <memmove+0x28>
 27c:	1602                	sll	a2,a2,0x20
 27e:	9201                	srl	a2,a2,0x20
 280:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 284:	872a                	mv	a4,a0
      *dst++ = *src++;
 286:	0585                	add	a1,a1,1
 288:	0705                	add	a4,a4,1
 28a:	fff5c683          	lbu	a3,-1(a1)
 28e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	add	sp,sp,16
 29a:	8082                	ret
    dst += n;
 29c:	00c50733          	add	a4,a0,a2
    src += n;
 2a0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a2:	fec05ae3          	blez	a2,296 <memmove+0x28>
 2a6:	fff6079b          	addw	a5,a2,-1
 2aa:	1782                	sll	a5,a5,0x20
 2ac:	9381                	srl	a5,a5,0x20
 2ae:	fff7c793          	not	a5,a5
 2b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b4:	15fd                	add	a1,a1,-1
 2b6:	177d                	add	a4,a4,-1
 2b8:	0005c683          	lbu	a3,0(a1)
 2bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x46>
 2c4:	bfc9                	j	296 <memmove+0x28>

00000000000002c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c6:	1141                	add	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	ca05                	beqz	a2,2fc <memcmp+0x36>
 2ce:	fff6069b          	addw	a3,a2,-1
 2d2:	1682                	sll	a3,a3,0x20
 2d4:	9281                	srl	a3,a3,0x20
 2d6:	0685                	add	a3,a3,1
 2d8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2da:	00054783          	lbu	a5,0(a0)
 2de:	0005c703          	lbu	a4,0(a1)
 2e2:	00e79863          	bne	a5,a4,2f2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e6:	0505                	add	a0,a0,1
    p2++;
 2e8:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2ea:	fed518e3          	bne	a0,a3,2da <memcmp+0x14>
  }
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	a019                	j	2f6 <memcmp+0x30>
      return *p1 - *p2;
 2f2:	40e7853b          	subw	a0,a5,a4
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	add	sp,sp,16
 2fa:	8082                	ret
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	bfe5                	j	2f6 <memcmp+0x30>

0000000000000300 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 300:	1141                	add	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 308:	00000097          	auipc	ra,0x0
 30c:	f66080e7          	jalr	-154(ra) # 26e <memmove>
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	add	sp,sp,16
 316:	8082                	ret

0000000000000318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 318:	4885                	li	a7,1
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exit>:
.global exit
exit:
 li a7, SYS_exit
 320:	4889                	li	a7,2
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <wait>:
.global wait
wait:
 li a7, SYS_wait
 328:	488d                	li	a7,3
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 330:	4891                	li	a7,4
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <read>:
.global read
read:
 li a7, SYS_read
 338:	4895                	li	a7,5
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <write>:
.global write
write:
 li a7, SYS_write
 340:	48c1                	li	a7,16
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <close>:
.global close
close:
 li a7, SYS_close
 348:	48d5                	li	a7,21
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <kill>:
.global kill
kill:
 li a7, SYS_kill
 350:	4899                	li	a7,6
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exec>:
.global exec
exec:
 li a7, SYS_exec
 358:	489d                	li	a7,7
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <open>:
.global open
open:
 li a7, SYS_open
 360:	48bd                	li	a7,15
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 368:	48c5                	li	a7,17
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 370:	48c9                	li	a7,18
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 378:	48a1                	li	a7,8
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <link>:
.global link
link:
 li a7, SYS_link
 380:	48cd                	li	a7,19
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 388:	48d1                	li	a7,20
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 390:	48a5                	li	a7,9
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <dup>:
.global dup
dup:
 li a7, SYS_dup
 398:	48a9                	li	a7,10
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a0:	48ad                	li	a7,11
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a8:	48b1                	li	a7,12
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b0:	48b5                	li	a7,13
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b8:	48b9                	li	a7,14
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c0:	1101                	add	sp,sp,-32
 3c2:	ec06                	sd	ra,24(sp)
 3c4:	e822                	sd	s0,16(sp)
 3c6:	1000                	add	s0,sp,32
 3c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3cc:	4605                	li	a2,1
 3ce:	fef40593          	add	a1,s0,-17
 3d2:	00000097          	auipc	ra,0x0
 3d6:	f6e080e7          	jalr	-146(ra) # 340 <write>
}
 3da:	60e2                	ld	ra,24(sp)
 3dc:	6442                	ld	s0,16(sp)
 3de:	6105                	add	sp,sp,32
 3e0:	8082                	ret

00000000000003e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e2:	7139                	add	sp,sp,-64
 3e4:	fc06                	sd	ra,56(sp)
 3e6:	f822                	sd	s0,48(sp)
 3e8:	f426                	sd	s1,40(sp)
 3ea:	f04a                	sd	s2,32(sp)
 3ec:	ec4e                	sd	s3,24(sp)
 3ee:	0080                	add	s0,sp,64
 3f0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f2:	c299                	beqz	a3,3f8 <printint+0x16>
 3f4:	0805c963          	bltz	a1,486 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f8:	2581                	sext.w	a1,a1
  neg = 0;
 3fa:	4881                	li	a7,0
 3fc:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 400:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 402:	2601                	sext.w	a2,a2
 404:	00000517          	auipc	a0,0x0
 408:	4e450513          	add	a0,a0,1252 # 8e8 <digits>
 40c:	883a                	mv	a6,a4
 40e:	2705                	addw	a4,a4,1
 410:	02c5f7bb          	remuw	a5,a1,a2
 414:	1782                	sll	a5,a5,0x20
 416:	9381                	srl	a5,a5,0x20
 418:	97aa                	add	a5,a5,a0
 41a:	0007c783          	lbu	a5,0(a5)
 41e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 422:	0005879b          	sext.w	a5,a1
 426:	02c5d5bb          	divuw	a1,a1,a2
 42a:	0685                	add	a3,a3,1
 42c:	fec7f0e3          	bgeu	a5,a2,40c <printint+0x2a>
  if(neg)
 430:	00088c63          	beqz	a7,448 <printint+0x66>
    buf[i++] = '-';
 434:	fd070793          	add	a5,a4,-48
 438:	00878733          	add	a4,a5,s0
 43c:	02d00793          	li	a5,45
 440:	fef70823          	sb	a5,-16(a4)
 444:	0028071b          	addw	a4,a6,2 # fffffffffffff002 <base+0xffffffffffffdff2>

  while(--i >= 0)
 448:	02e05863          	blez	a4,478 <printint+0x96>
 44c:	fc040793          	add	a5,s0,-64
 450:	00e78933          	add	s2,a5,a4
 454:	fff78993          	add	s3,a5,-1
 458:	99ba                	add	s3,s3,a4
 45a:	377d                	addw	a4,a4,-1
 45c:	1702                	sll	a4,a4,0x20
 45e:	9301                	srl	a4,a4,0x20
 460:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 464:	fff94583          	lbu	a1,-1(s2)
 468:	8526                	mv	a0,s1
 46a:	00000097          	auipc	ra,0x0
 46e:	f56080e7          	jalr	-170(ra) # 3c0 <putc>
  while(--i >= 0)
 472:	197d                	add	s2,s2,-1
 474:	ff3918e3          	bne	s2,s3,464 <printint+0x82>
}
 478:	70e2                	ld	ra,56(sp)
 47a:	7442                	ld	s0,48(sp)
 47c:	74a2                	ld	s1,40(sp)
 47e:	7902                	ld	s2,32(sp)
 480:	69e2                	ld	s3,24(sp)
 482:	6121                	add	sp,sp,64
 484:	8082                	ret
    x = -xx;
 486:	40b005bb          	negw	a1,a1
    neg = 1;
 48a:	4885                	li	a7,1
    x = -xx;
 48c:	bf85                	j	3fc <printint+0x1a>

000000000000048e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48e:	715d                	add	sp,sp,-80
 490:	e486                	sd	ra,72(sp)
 492:	e0a2                	sd	s0,64(sp)
 494:	fc26                	sd	s1,56(sp)
 496:	f84a                	sd	s2,48(sp)
 498:	f44e                	sd	s3,40(sp)
 49a:	f052                	sd	s4,32(sp)
 49c:	ec56                	sd	s5,24(sp)
 49e:	e85a                	sd	s6,16(sp)
 4a0:	e45e                	sd	s7,8(sp)
 4a2:	e062                	sd	s8,0(sp)
 4a4:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a6:	0005c903          	lbu	s2,0(a1)
 4aa:	18090c63          	beqz	s2,642 <vprintf+0x1b4>
 4ae:	8aaa                	mv	s5,a0
 4b0:	8bb2                	mv	s7,a2
 4b2:	00158493          	add	s1,a1,1
  state = 0;
 4b6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b8:	02500a13          	li	s4,37
 4bc:	4b55                	li	s6,21
 4be:	a839                	j	4dc <vprintf+0x4e>
        putc(fd, c);
 4c0:	85ca                	mv	a1,s2
 4c2:	8556                	mv	a0,s5
 4c4:	00000097          	auipc	ra,0x0
 4c8:	efc080e7          	jalr	-260(ra) # 3c0 <putc>
 4cc:	a019                	j	4d2 <vprintf+0x44>
    } else if(state == '%'){
 4ce:	01498d63          	beq	s3,s4,4e8 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4d2:	0485                	add	s1,s1,1
 4d4:	fff4c903          	lbu	s2,-1(s1)
 4d8:	16090563          	beqz	s2,642 <vprintf+0x1b4>
    if(state == 0){
 4dc:	fe0999e3          	bnez	s3,4ce <vprintf+0x40>
      if(c == '%'){
 4e0:	ff4910e3          	bne	s2,s4,4c0 <vprintf+0x32>
        state = '%';
 4e4:	89d2                	mv	s3,s4
 4e6:	b7f5                	j	4d2 <vprintf+0x44>
      if(c == 'd'){
 4e8:	13490263          	beq	s2,s4,60c <vprintf+0x17e>
 4ec:	f9d9079b          	addw	a5,s2,-99
 4f0:	0ff7f793          	zext.b	a5,a5
 4f4:	12fb6563          	bltu	s6,a5,61e <vprintf+0x190>
 4f8:	f9d9079b          	addw	a5,s2,-99
 4fc:	0ff7f713          	zext.b	a4,a5
 500:	10eb6f63          	bltu	s6,a4,61e <vprintf+0x190>
 504:	00271793          	sll	a5,a4,0x2
 508:	00000717          	auipc	a4,0x0
 50c:	38870713          	add	a4,a4,904 # 890 <malloc+0x150>
 510:	97ba                	add	a5,a5,a4
 512:	439c                	lw	a5,0(a5)
 514:	97ba                	add	a5,a5,a4
 516:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 518:	008b8913          	add	s2,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000ba583          	lw	a1,0(s7)
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	ebc080e7          	jalr	-324(ra) # 3e2 <printint>
 52e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 530:	4981                	li	s3,0
 532:	b745                	j	4d2 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 534:	008b8913          	add	s2,s7,8
 538:	4681                	li	a3,0
 53a:	4629                	li	a2,10
 53c:	000ba583          	lw	a1,0(s7)
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	ea0080e7          	jalr	-352(ra) # 3e2 <printint>
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b751                	j	4d2 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 550:	008b8913          	add	s2,s7,8
 554:	4681                	li	a3,0
 556:	4641                	li	a2,16
 558:	000ba583          	lw	a1,0(s7)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e84080e7          	jalr	-380(ra) # 3e2 <printint>
 566:	8bca                	mv	s7,s2
      state = 0;
 568:	4981                	li	s3,0
 56a:	b7a5                	j	4d2 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 56c:	008b8c13          	add	s8,s7,8
 570:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 574:	03000593          	li	a1,48
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	e46080e7          	jalr	-442(ra) # 3c0 <putc>
  putc(fd, 'x');
 582:	07800593          	li	a1,120
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e38080e7          	jalr	-456(ra) # 3c0 <putc>
 590:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 592:	00000b97          	auipc	s7,0x0
 596:	356b8b93          	add	s7,s7,854 # 8e8 <digits>
 59a:	03c9d793          	srl	a5,s3,0x3c
 59e:	97de                	add	a5,a5,s7
 5a0:	0007c583          	lbu	a1,0(a5)
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	e1a080e7          	jalr	-486(ra) # 3c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ae:	0992                	sll	s3,s3,0x4
 5b0:	397d                	addw	s2,s2,-1
 5b2:	fe0914e3          	bnez	s2,59a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5b6:	8be2                	mv	s7,s8
      state = 0;
 5b8:	4981                	li	s3,0
 5ba:	bf21                	j	4d2 <vprintf+0x44>
        s = va_arg(ap, char*);
 5bc:	008b8993          	add	s3,s7,8
 5c0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5c4:	02090163          	beqz	s2,5e6 <vprintf+0x158>
        while(*s != 0){
 5c8:	00094583          	lbu	a1,0(s2)
 5cc:	c9a5                	beqz	a1,63c <vprintf+0x1ae>
          putc(fd, *s);
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	df0080e7          	jalr	-528(ra) # 3c0 <putc>
          s++;
 5d8:	0905                	add	s2,s2,1
        while(*s != 0){
 5da:	00094583          	lbu	a1,0(s2)
 5de:	f9e5                	bnez	a1,5ce <vprintf+0x140>
        s = va_arg(ap, char*);
 5e0:	8bce                	mv	s7,s3
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b5fd                	j	4d2 <vprintf+0x44>
          s = "(null)";
 5e6:	00000917          	auipc	s2,0x0
 5ea:	2a290913          	add	s2,s2,674 # 888 <malloc+0x148>
        while(*s != 0){
 5ee:	02800593          	li	a1,40
 5f2:	bff1                	j	5ce <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5f4:	008b8913          	add	s2,s7,8
 5f8:	000bc583          	lbu	a1,0(s7)
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	dc2080e7          	jalr	-574(ra) # 3c0 <putc>
 606:	8bca                	mv	s7,s2
      state = 0;
 608:	4981                	li	s3,0
 60a:	b5e1                	j	4d2 <vprintf+0x44>
        putc(fd, c);
 60c:	02500593          	li	a1,37
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	dae080e7          	jalr	-594(ra) # 3c0 <putc>
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bd5d                	j	4d2 <vprintf+0x44>
        putc(fd, '%');
 61e:	02500593          	li	a1,37
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	d9c080e7          	jalr	-612(ra) # 3c0 <putc>
        putc(fd, c);
 62c:	85ca                	mv	a1,s2
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	d90080e7          	jalr	-624(ra) # 3c0 <putc>
      state = 0;
 638:	4981                	li	s3,0
 63a:	bd61                	j	4d2 <vprintf+0x44>
        s = va_arg(ap, char*);
 63c:	8bce                	mv	s7,s3
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd49                	j	4d2 <vprintf+0x44>
    }
  }
}
 642:	60a6                	ld	ra,72(sp)
 644:	6406                	ld	s0,64(sp)
 646:	74e2                	ld	s1,56(sp)
 648:	7942                	ld	s2,48(sp)
 64a:	79a2                	ld	s3,40(sp)
 64c:	7a02                	ld	s4,32(sp)
 64e:	6ae2                	ld	s5,24(sp)
 650:	6b42                	ld	s6,16(sp)
 652:	6ba2                	ld	s7,8(sp)
 654:	6c02                	ld	s8,0(sp)
 656:	6161                	add	sp,sp,80
 658:	8082                	ret

000000000000065a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 65a:	715d                	add	sp,sp,-80
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	add	s0,sp,32
 662:	e010                	sd	a2,0(s0)
 664:	e414                	sd	a3,8(s0)
 666:	e818                	sd	a4,16(s0)
 668:	ec1c                	sd	a5,24(s0)
 66a:	03043023          	sd	a6,32(s0)
 66e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 672:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 676:	8622                	mv	a2,s0
 678:	00000097          	auipc	ra,0x0
 67c:	e16080e7          	jalr	-490(ra) # 48e <vprintf>
}
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6161                	add	sp,sp,80
 686:	8082                	ret

0000000000000688 <printf>:

void
printf(const char *fmt, ...)
{
 688:	711d                	add	sp,sp,-96
 68a:	ec06                	sd	ra,24(sp)
 68c:	e822                	sd	s0,16(sp)
 68e:	1000                	add	s0,sp,32
 690:	e40c                	sd	a1,8(s0)
 692:	e810                	sd	a2,16(s0)
 694:	ec14                	sd	a3,24(s0)
 696:	f018                	sd	a4,32(s0)
 698:	f41c                	sd	a5,40(s0)
 69a:	03043823          	sd	a6,48(s0)
 69e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6a2:	00840613          	add	a2,s0,8
 6a6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6aa:	85aa                	mv	a1,a0
 6ac:	4505                	li	a0,1
 6ae:	00000097          	auipc	ra,0x0
 6b2:	de0080e7          	jalr	-544(ra) # 48e <vprintf>
}
 6b6:	60e2                	ld	ra,24(sp)
 6b8:	6442                	ld	s0,16(sp)
 6ba:	6125                	add	sp,sp,96
 6bc:	8082                	ret

00000000000006be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6be:	1141                	add	sp,sp,-16
 6c0:	e422                	sd	s0,8(sp)
 6c2:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c4:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c8:	00001797          	auipc	a5,0x1
 6cc:	9387b783          	ld	a5,-1736(a5) # 1000 <freep>
 6d0:	a02d                	j	6fa <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6d2:	4618                	lw	a4,8(a2)
 6d4:	9f2d                	addw	a4,a4,a1
 6d6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6da:	6398                	ld	a4,0(a5)
 6dc:	6310                	ld	a2,0(a4)
 6de:	a83d                	j	71c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6e0:	ff852703          	lw	a4,-8(a0)
 6e4:	9f31                	addw	a4,a4,a2
 6e6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e8:	ff053683          	ld	a3,-16(a0)
 6ec:	a091                	j	730 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ee:	6398                	ld	a4,0(a5)
 6f0:	00e7e463          	bltu	a5,a4,6f8 <free+0x3a>
 6f4:	00e6ea63          	bltu	a3,a4,708 <free+0x4a>
{
 6f8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fa:	fed7fae3          	bgeu	a5,a3,6ee <free+0x30>
 6fe:	6398                	ld	a4,0(a5)
 700:	00e6e463          	bltu	a3,a4,708 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 704:	fee7eae3          	bltu	a5,a4,6f8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 708:	ff852583          	lw	a1,-8(a0)
 70c:	6390                	ld	a2,0(a5)
 70e:	02059813          	sll	a6,a1,0x20
 712:	01c85713          	srl	a4,a6,0x1c
 716:	9736                	add	a4,a4,a3
 718:	fae60de3          	beq	a2,a4,6d2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 71c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 720:	4790                	lw	a2,8(a5)
 722:	02061593          	sll	a1,a2,0x20
 726:	01c5d713          	srl	a4,a1,0x1c
 72a:	973e                	add	a4,a4,a5
 72c:	fae68ae3          	beq	a3,a4,6e0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 730:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 732:	00001717          	auipc	a4,0x1
 736:	8cf73723          	sd	a5,-1842(a4) # 1000 <freep>
}
 73a:	6422                	ld	s0,8(sp)
 73c:	0141                	add	sp,sp,16
 73e:	8082                	ret

0000000000000740 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 740:	7139                	add	sp,sp,-64
 742:	fc06                	sd	ra,56(sp)
 744:	f822                	sd	s0,48(sp)
 746:	f426                	sd	s1,40(sp)
 748:	f04a                	sd	s2,32(sp)
 74a:	ec4e                	sd	s3,24(sp)
 74c:	e852                	sd	s4,16(sp)
 74e:	e456                	sd	s5,8(sp)
 750:	e05a                	sd	s6,0(sp)
 752:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 754:	02051493          	sll	s1,a0,0x20
 758:	9081                	srl	s1,s1,0x20
 75a:	04bd                	add	s1,s1,15
 75c:	8091                	srl	s1,s1,0x4
 75e:	0014899b          	addw	s3,s1,1
 762:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 764:	00001517          	auipc	a0,0x1
 768:	89c53503          	ld	a0,-1892(a0) # 1000 <freep>
 76c:	c515                	beqz	a0,798 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 770:	4798                	lw	a4,8(a5)
 772:	02977f63          	bgeu	a4,s1,7b0 <malloc+0x70>
  if(nu < 4096)
 776:	8a4e                	mv	s4,s3
 778:	0009871b          	sext.w	a4,s3
 77c:	6685                	lui	a3,0x1
 77e:	00d77363          	bgeu	a4,a3,784 <malloc+0x44>
 782:	6a05                	lui	s4,0x1
 784:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 788:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 78c:	00001917          	auipc	s2,0x1
 790:	87490913          	add	s2,s2,-1932 # 1000 <freep>
  if(p == (char*)-1)
 794:	5afd                	li	s5,-1
 796:	a895                	j	80a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 798:	00001797          	auipc	a5,0x1
 79c:	87878793          	add	a5,a5,-1928 # 1010 <base>
 7a0:	00001717          	auipc	a4,0x1
 7a4:	86f73023          	sd	a5,-1952(a4) # 1000 <freep>
 7a8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7aa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ae:	b7e1                	j	776 <malloc+0x36>
      if(p->s.size == nunits)
 7b0:	02e48c63          	beq	s1,a4,7e8 <malloc+0xa8>
        p->s.size -= nunits;
 7b4:	4137073b          	subw	a4,a4,s3
 7b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ba:	02071693          	sll	a3,a4,0x20
 7be:	01c6d713          	srl	a4,a3,0x1c
 7c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c8:	00001717          	auipc	a4,0x1
 7cc:	82a73c23          	sd	a0,-1992(a4) # 1000 <freep>
      return (void*)(p + 1);
 7d0:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d4:	70e2                	ld	ra,56(sp)
 7d6:	7442                	ld	s0,48(sp)
 7d8:	74a2                	ld	s1,40(sp)
 7da:	7902                	ld	s2,32(sp)
 7dc:	69e2                	ld	s3,24(sp)
 7de:	6a42                	ld	s4,16(sp)
 7e0:	6aa2                	ld	s5,8(sp)
 7e2:	6b02                	ld	s6,0(sp)
 7e4:	6121                	add	sp,sp,64
 7e6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e8:	6398                	ld	a4,0(a5)
 7ea:	e118                	sd	a4,0(a0)
 7ec:	bff1                	j	7c8 <malloc+0x88>
  hp->s.size = nu;
 7ee:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f2:	0541                	add	a0,a0,16
 7f4:	00000097          	auipc	ra,0x0
 7f8:	eca080e7          	jalr	-310(ra) # 6be <free>
  return freep;
 7fc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 800:	d971                	beqz	a0,7d4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 804:	4798                	lw	a4,8(a5)
 806:	fa9775e3          	bgeu	a4,s1,7b0 <malloc+0x70>
    if(p == freep)
 80a:	00093703          	ld	a4,0(s2)
 80e:	853e                	mv	a0,a5
 810:	fef719e3          	bne	a4,a5,802 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 814:	8552                	mv	a0,s4
 816:	00000097          	auipc	ra,0x0
 81a:	b92080e7          	jalr	-1134(ra) # 3a8 <sbrk>
  if(p == (char*)-1)
 81e:	fd5518e3          	bne	a0,s5,7ee <malloc+0xae>
        return 0;
 822:	4501                	li	a0,0
 824:	bf45                	j	7d4 <malloc+0x94>
