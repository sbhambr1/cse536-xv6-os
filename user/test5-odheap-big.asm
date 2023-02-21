
user/_test5-odheap-big:     file format elf64-littleriscv


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
    int npages = MAXHEAP;
    void* heappages = sbrk(4096*npages);
   8:	003e8537          	lui	a0,0x3e8
   c:	00000097          	auipc	ra,0x0
  10:	3a2080e7          	jalr	930(ra) # 3ae <sbrk>
    if (!heappages) {
  14:	cd39                	beqz	a0,72 <main+0x72>
  16:	6785                	lui	a5,0x1
  18:	00f50633          	add	a2,a0,a5
  1c:	86b2                	mv	a3,a2
        return -1;
    }

    /* Write random numbers to the allocated heap regions. */
    int* a;
    int count = 0;
  1e:	4701                	li	a4,0
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
  20:	787d                	lui	a6,0xfffff
    for (int i = 0; i < npages; i++) {
  22:	6505                	lui	a0,0x1
  24:	3e800593          	li	a1,1000
        a = ((int*) (heappages + i*PGSIZE));
  28:	010687b3          	add	a5,a3,a6
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            *a = count;
  2c:	c398                	sw	a4,0(a5)
            a++;
  2e:	0791                	add	a5,a5,4 # 1004 <freep+0x4>
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  30:	fed79ee3          	bne	a5,a3,2c <main+0x2c>
        }
        count++;
  34:	2705                	addw	a4,a4,1
    for (int i = 0; i < npages; i++) {
  36:	96aa                	add	a3,a3,a0
  38:	feb718e3          	bne	a4,a1,28 <main+0x28>
    }

    /* Assert heap memory correctness by checking the regions. */
    count = 0;
  3c:	4781                	li	a5,0
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
  3e:	76fd                	lui	a3,0xfffff
  40:	00d60733          	add	a4,a2,a3
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            if (*a != count) 
  44:	430c                	lw	a1,0(a4)
  46:	04f59063          	bne	a1,a5,86 <main+0x86>
                goto fail;
            a++;
  4a:	0711                	add	a4,a4,4
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  4c:	fec71ce3          	bne	a4,a2,44 <main+0x44>
        }
        count++;
  50:	2785                	addw	a5,a5,1
    for (int i = 0; i < npages; i++) {
  52:	6705                	lui	a4,0x1
  54:	963a                	add	a2,a2,a4
  56:	3e800713          	li	a4,1000
  5a:	fee793e3          	bne	a5,a4,40 <main+0x40>
    }

    printf("[*] Heap test PASSED.\n");
  5e:	00001517          	auipc	a0,0x1
  62:	81250513          	add	a0,a0,-2030 # 870 <malloc+0x12a>
  66:	00000097          	auipc	ra,0x0
  6a:	628080e7          	jalr	1576(ra) # 68e <printf>
    return 0;
  6e:	4501                	li	a0,0
  70:	a025                	j	98 <main+0x98>
        printf("[X] Heap memory allocation FAILED.\n");
  72:	00000517          	auipc	a0,0x0
  76:	7be50513          	add	a0,a0,1982 # 830 <malloc+0xea>
  7a:	00000097          	auipc	ra,0x0
  7e:	614080e7          	jalr	1556(ra) # 68e <printf>
        return -1;
  82:	557d                	li	a0,-1
  84:	a811                	j	98 <main+0x98>

fail:
    printf("[X] Heap test FAILED.\n");
  86:	00000517          	auipc	a0,0x0
  8a:	7d250513          	add	a0,a0,2002 # 858 <malloc+0x112>
  8e:	00000097          	auipc	ra,0x0
  92:	600080e7          	jalr	1536(ra) # 68e <printf>
    return -1;
  96:	557d                	li	a0,-1
  98:	60a2                	ld	ra,8(sp)
  9a:	6402                	ld	s0,0(sp)
  9c:	0141                	add	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  a0:	1141                	add	sp,sp,-16
  a2:	e406                	sd	ra,8(sp)
  a4:	e022                	sd	s0,0(sp)
  a6:	0800                	add	s0,sp,16
  extern int main();
  main();
  a8:	00000097          	auipc	ra,0x0
  ac:	f58080e7          	jalr	-168(ra) # 0 <main>
  exit(0);
  b0:	4501                	li	a0,0
  b2:	00000097          	auipc	ra,0x0
  b6:	274080e7          	jalr	628(ra) # 326 <exit>

00000000000000ba <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ba:	1141                	add	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c0:	87aa                	mv	a5,a0
  c2:	0585                	add	a1,a1,1
  c4:	0785                	add	a5,a5,1
  c6:	fff5c703          	lbu	a4,-1(a1)
  ca:	fee78fa3          	sb	a4,-1(a5)
  ce:	fb75                	bnez	a4,c2 <strcpy+0x8>
    ;
  return os;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	add	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d6:	1141                	add	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cb91                	beqz	a5,f4 <strcmp+0x1e>
  e2:	0005c703          	lbu	a4,0(a1)
  e6:	00f71763          	bne	a4,a5,f4 <strcmp+0x1e>
    p++, q++;
  ea:	0505                	add	a0,a0,1
  ec:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbe5                	bnez	a5,e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f4:	0005c503          	lbu	a0,0(a1)
}
  f8:	40a7853b          	subw	a0,a5,a0
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	add	sp,sp,16
 100:	8082                	ret

0000000000000102 <strlen>:

uint
strlen(const char *s)
{
 102:	1141                	add	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cf91                	beqz	a5,128 <strlen+0x26>
 10e:	0505                	add	a0,a0,1
 110:	87aa                	mv	a5,a0
 112:	86be                	mv	a3,a5
 114:	0785                	add	a5,a5,1
 116:	fff7c703          	lbu	a4,-1(a5)
 11a:	ff65                	bnez	a4,112 <strlen+0x10>
 11c:	40a6853b          	subw	a0,a3,a0
 120:	2505                	addw	a0,a0,1
    ;
  return n;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	add	sp,sp,16
 126:	8082                	ret
  for(n = 0; s[n]; n++)
 128:	4501                	li	a0,0
 12a:	bfe5                	j	122 <strlen+0x20>

000000000000012c <memset>:

void*
memset(void *dst, int c, uint n)
{
 12c:	1141                	add	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 132:	ca19                	beqz	a2,148 <memset+0x1c>
 134:	87aa                	mv	a5,a0
 136:	1602                	sll	a2,a2,0x20
 138:	9201                	srl	a2,a2,0x20
 13a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 142:	0785                	add	a5,a5,1
 144:	fee79de3          	bne	a5,a4,13e <memset+0x12>
  }
  return dst;
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	add	sp,sp,16
 14c:	8082                	ret

000000000000014e <strchr>:

char*
strchr(const char *s, char c)
{
 14e:	1141                	add	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	add	s0,sp,16
  for(; *s; s++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cb99                	beqz	a5,16e <strchr+0x20>
    if(*s == c)
 15a:	00f58763          	beq	a1,a5,168 <strchr+0x1a>
  for(; *s; s++)
 15e:	0505                	add	a0,a0,1
 160:	00054783          	lbu	a5,0(a0)
 164:	fbfd                	bnez	a5,15a <strchr+0xc>
      return (char*)s;
  return 0;
 166:	4501                	li	a0,0
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	add	sp,sp,16
 16c:	8082                	ret
  return 0;
 16e:	4501                	li	a0,0
 170:	bfe5                	j	168 <strchr+0x1a>

0000000000000172 <gets>:

char*
gets(char *buf, int max)
{
 172:	711d                	add	sp,sp,-96
 174:	ec86                	sd	ra,88(sp)
 176:	e8a2                	sd	s0,80(sp)
 178:	e4a6                	sd	s1,72(sp)
 17a:	e0ca                	sd	s2,64(sp)
 17c:	fc4e                	sd	s3,56(sp)
 17e:	f852                	sd	s4,48(sp)
 180:	f456                	sd	s5,40(sp)
 182:	f05a                	sd	s6,32(sp)
 184:	ec5e                	sd	s7,24(sp)
 186:	1080                	add	s0,sp,96
 188:	8baa                	mv	s7,a0
 18a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18c:	892a                	mv	s2,a0
 18e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 190:	4aa9                	li	s5,10
 192:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 194:	89a6                	mv	s3,s1
 196:	2485                	addw	s1,s1,1
 198:	0344d863          	bge	s1,s4,1c8 <gets+0x56>
    cc = read(0, &c, 1);
 19c:	4605                	li	a2,1
 19e:	faf40593          	add	a1,s0,-81
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	19a080e7          	jalr	410(ra) # 33e <read>
    if(cc < 1)
 1ac:	00a05e63          	blez	a0,1c8 <gets+0x56>
    buf[i++] = c;
 1b0:	faf44783          	lbu	a5,-81(s0)
 1b4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b8:	01578763          	beq	a5,s5,1c6 <gets+0x54>
 1bc:	0905                	add	s2,s2,1
 1be:	fd679be3          	bne	a5,s6,194 <gets+0x22>
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	a011                	j	1c8 <gets+0x56>
 1c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c8:	99de                	add	s3,s3,s7
 1ca:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ce:	855e                	mv	a0,s7
 1d0:	60e6                	ld	ra,88(sp)
 1d2:	6446                	ld	s0,80(sp)
 1d4:	64a6                	ld	s1,72(sp)
 1d6:	6906                	ld	s2,64(sp)
 1d8:	79e2                	ld	s3,56(sp)
 1da:	7a42                	ld	s4,48(sp)
 1dc:	7aa2                	ld	s5,40(sp)
 1de:	7b02                	ld	s6,32(sp)
 1e0:	6be2                	ld	s7,24(sp)
 1e2:	6125                	add	sp,sp,96
 1e4:	8082                	ret

00000000000001e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e6:	1101                	add	sp,sp,-32
 1e8:	ec06                	sd	ra,24(sp)
 1ea:	e822                	sd	s0,16(sp)
 1ec:	e426                	sd	s1,8(sp)
 1ee:	e04a                	sd	s2,0(sp)
 1f0:	1000                	add	s0,sp,32
 1f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f4:	4581                	li	a1,0
 1f6:	00000097          	auipc	ra,0x0
 1fa:	170080e7          	jalr	368(ra) # 366 <open>
  if(fd < 0)
 1fe:	02054563          	bltz	a0,228 <stat+0x42>
 202:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 204:	85ca                	mv	a1,s2
 206:	00000097          	auipc	ra,0x0
 20a:	178080e7          	jalr	376(ra) # 37e <fstat>
 20e:	892a                	mv	s2,a0
  close(fd);
 210:	8526                	mv	a0,s1
 212:	00000097          	auipc	ra,0x0
 216:	13c080e7          	jalr	316(ra) # 34e <close>
  return r;
}
 21a:	854a                	mv	a0,s2
 21c:	60e2                	ld	ra,24(sp)
 21e:	6442                	ld	s0,16(sp)
 220:	64a2                	ld	s1,8(sp)
 222:	6902                	ld	s2,0(sp)
 224:	6105                	add	sp,sp,32
 226:	8082                	ret
    return -1;
 228:	597d                	li	s2,-1
 22a:	bfc5                	j	21a <stat+0x34>

000000000000022c <atoi>:

int
atoi(const char *s)
{
 22c:	1141                	add	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 232:	00054683          	lbu	a3,0(a0)
 236:	fd06879b          	addw	a5,a3,-48 # ffffffffffffefd0 <base+0xffffffffffffdfc0>
 23a:	0ff7f793          	zext.b	a5,a5
 23e:	4625                	li	a2,9
 240:	02f66863          	bltu	a2,a5,270 <atoi+0x44>
 244:	872a                	mv	a4,a0
  n = 0;
 246:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 248:	0705                	add	a4,a4,1 # 1001 <freep+0x1>
 24a:	0025179b          	sllw	a5,a0,0x2
 24e:	9fa9                	addw	a5,a5,a0
 250:	0017979b          	sllw	a5,a5,0x1
 254:	9fb5                	addw	a5,a5,a3
 256:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 25a:	00074683          	lbu	a3,0(a4)
 25e:	fd06879b          	addw	a5,a3,-48
 262:	0ff7f793          	zext.b	a5,a5
 266:	fef671e3          	bgeu	a2,a5,248 <atoi+0x1c>
  return n;
}
 26a:	6422                	ld	s0,8(sp)
 26c:	0141                	add	sp,sp,16
 26e:	8082                	ret
  n = 0;
 270:	4501                	li	a0,0
 272:	bfe5                	j	26a <atoi+0x3e>

0000000000000274 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 274:	1141                	add	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 27a:	02b57463          	bgeu	a0,a1,2a2 <memmove+0x2e>
    while(n-- > 0)
 27e:	00c05f63          	blez	a2,29c <memmove+0x28>
 282:	1602                	sll	a2,a2,0x20
 284:	9201                	srl	a2,a2,0x20
 286:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 28a:	872a                	mv	a4,a0
      *dst++ = *src++;
 28c:	0585                	add	a1,a1,1
 28e:	0705                	add	a4,a4,1
 290:	fff5c683          	lbu	a3,-1(a1)
 294:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 298:	fee79ae3          	bne	a5,a4,28c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	add	sp,sp,16
 2a0:	8082                	ret
    dst += n;
 2a2:	00c50733          	add	a4,a0,a2
    src += n;
 2a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a8:	fec05ae3          	blez	a2,29c <memmove+0x28>
 2ac:	fff6079b          	addw	a5,a2,-1
 2b0:	1782                	sll	a5,a5,0x20
 2b2:	9381                	srl	a5,a5,0x20
 2b4:	fff7c793          	not	a5,a5
 2b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ba:	15fd                	add	a1,a1,-1
 2bc:	177d                	add	a4,a4,-1
 2be:	0005c683          	lbu	a3,0(a1)
 2c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c6:	fee79ae3          	bne	a5,a4,2ba <memmove+0x46>
 2ca:	bfc9                	j	29c <memmove+0x28>

00000000000002cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2cc:	1141                	add	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2d2:	ca05                	beqz	a2,302 <memcmp+0x36>
 2d4:	fff6069b          	addw	a3,a2,-1
 2d8:	1682                	sll	a3,a3,0x20
 2da:	9281                	srl	a3,a3,0x20
 2dc:	0685                	add	a3,a3,1
 2de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e0:	00054783          	lbu	a5,0(a0)
 2e4:	0005c703          	lbu	a4,0(a1)
 2e8:	00e79863          	bne	a5,a4,2f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ec:	0505                	add	a0,a0,1
    p2++;
 2ee:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2f0:	fed518e3          	bne	a0,a3,2e0 <memcmp+0x14>
  }
  return 0;
 2f4:	4501                	li	a0,0
 2f6:	a019                	j	2fc <memcmp+0x30>
      return *p1 - *p2;
 2f8:	40e7853b          	subw	a0,a5,a4
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	add	sp,sp,16
 300:	8082                	ret
  return 0;
 302:	4501                	li	a0,0
 304:	bfe5                	j	2fc <memcmp+0x30>

0000000000000306 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 306:	1141                	add	sp,sp,-16
 308:	e406                	sd	ra,8(sp)
 30a:	e022                	sd	s0,0(sp)
 30c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 30e:	00000097          	auipc	ra,0x0
 312:	f66080e7          	jalr	-154(ra) # 274 <memmove>
}
 316:	60a2                	ld	ra,8(sp)
 318:	6402                	ld	s0,0(sp)
 31a:	0141                	add	sp,sp,16
 31c:	8082                	ret

000000000000031e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 31e:	4885                	li	a7,1
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <exit>:
.global exit
exit:
 li a7, SYS_exit
 326:	4889                	li	a7,2
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <wait>:
.global wait
wait:
 li a7, SYS_wait
 32e:	488d                	li	a7,3
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 336:	4891                	li	a7,4
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <read>:
.global read
read:
 li a7, SYS_read
 33e:	4895                	li	a7,5
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <write>:
.global write
write:
 li a7, SYS_write
 346:	48c1                	li	a7,16
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <close>:
.global close
close:
 li a7, SYS_close
 34e:	48d5                	li	a7,21
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <kill>:
.global kill
kill:
 li a7, SYS_kill
 356:	4899                	li	a7,6
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <exec>:
.global exec
exec:
 li a7, SYS_exec
 35e:	489d                	li	a7,7
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <open>:
.global open
open:
 li a7, SYS_open
 366:	48bd                	li	a7,15
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 36e:	48c5                	li	a7,17
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 376:	48c9                	li	a7,18
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 37e:	48a1                	li	a7,8
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <link>:
.global link
link:
 li a7, SYS_link
 386:	48cd                	li	a7,19
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 38e:	48d1                	li	a7,20
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 396:	48a5                	li	a7,9
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <dup>:
.global dup
dup:
 li a7, SYS_dup
 39e:	48a9                	li	a7,10
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a6:	48ad                	li	a7,11
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ae:	48b1                	li	a7,12
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b6:	48b5                	li	a7,13
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3be:	48b9                	li	a7,14
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3c6:	1101                	add	sp,sp,-32
 3c8:	ec06                	sd	ra,24(sp)
 3ca:	e822                	sd	s0,16(sp)
 3cc:	1000                	add	s0,sp,32
 3ce:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d2:	4605                	li	a2,1
 3d4:	fef40593          	add	a1,s0,-17
 3d8:	00000097          	auipc	ra,0x0
 3dc:	f6e080e7          	jalr	-146(ra) # 346 <write>
}
 3e0:	60e2                	ld	ra,24(sp)
 3e2:	6442                	ld	s0,16(sp)
 3e4:	6105                	add	sp,sp,32
 3e6:	8082                	ret

00000000000003e8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e8:	7139                	add	sp,sp,-64
 3ea:	fc06                	sd	ra,56(sp)
 3ec:	f822                	sd	s0,48(sp)
 3ee:	f426                	sd	s1,40(sp)
 3f0:	f04a                	sd	s2,32(sp)
 3f2:	ec4e                	sd	s3,24(sp)
 3f4:	0080                	add	s0,sp,64
 3f6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f8:	c299                	beqz	a3,3fe <printint+0x16>
 3fa:	0805c963          	bltz	a1,48c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3fe:	2581                	sext.w	a1,a1
  neg = 0;
 400:	4881                	li	a7,0
 402:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 406:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 408:	2601                	sext.w	a2,a2
 40a:	00000517          	auipc	a0,0x0
 40e:	4de50513          	add	a0,a0,1246 # 8e8 <digits>
 412:	883a                	mv	a6,a4
 414:	2705                	addw	a4,a4,1
 416:	02c5f7bb          	remuw	a5,a1,a2
 41a:	1782                	sll	a5,a5,0x20
 41c:	9381                	srl	a5,a5,0x20
 41e:	97aa                	add	a5,a5,a0
 420:	0007c783          	lbu	a5,0(a5)
 424:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 428:	0005879b          	sext.w	a5,a1
 42c:	02c5d5bb          	divuw	a1,a1,a2
 430:	0685                	add	a3,a3,1
 432:	fec7f0e3          	bgeu	a5,a2,412 <printint+0x2a>
  if(neg)
 436:	00088c63          	beqz	a7,44e <printint+0x66>
    buf[i++] = '-';
 43a:	fd070793          	add	a5,a4,-48
 43e:	00878733          	add	a4,a5,s0
 442:	02d00793          	li	a5,45
 446:	fef70823          	sb	a5,-16(a4)
 44a:	0028071b          	addw	a4,a6,2 # fffffffffffff002 <base+0xffffffffffffdff2>

  while(--i >= 0)
 44e:	02e05863          	blez	a4,47e <printint+0x96>
 452:	fc040793          	add	a5,s0,-64
 456:	00e78933          	add	s2,a5,a4
 45a:	fff78993          	add	s3,a5,-1
 45e:	99ba                	add	s3,s3,a4
 460:	377d                	addw	a4,a4,-1
 462:	1702                	sll	a4,a4,0x20
 464:	9301                	srl	a4,a4,0x20
 466:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46a:	fff94583          	lbu	a1,-1(s2)
 46e:	8526                	mv	a0,s1
 470:	00000097          	auipc	ra,0x0
 474:	f56080e7          	jalr	-170(ra) # 3c6 <putc>
  while(--i >= 0)
 478:	197d                	add	s2,s2,-1
 47a:	ff3918e3          	bne	s2,s3,46a <printint+0x82>
}
 47e:	70e2                	ld	ra,56(sp)
 480:	7442                	ld	s0,48(sp)
 482:	74a2                	ld	s1,40(sp)
 484:	7902                	ld	s2,32(sp)
 486:	69e2                	ld	s3,24(sp)
 488:	6121                	add	sp,sp,64
 48a:	8082                	ret
    x = -xx;
 48c:	40b005bb          	negw	a1,a1
    neg = 1;
 490:	4885                	li	a7,1
    x = -xx;
 492:	bf85                	j	402 <printint+0x1a>

0000000000000494 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 494:	715d                	add	sp,sp,-80
 496:	e486                	sd	ra,72(sp)
 498:	e0a2                	sd	s0,64(sp)
 49a:	fc26                	sd	s1,56(sp)
 49c:	f84a                	sd	s2,48(sp)
 49e:	f44e                	sd	s3,40(sp)
 4a0:	f052                	sd	s4,32(sp)
 4a2:	ec56                	sd	s5,24(sp)
 4a4:	e85a                	sd	s6,16(sp)
 4a6:	e45e                	sd	s7,8(sp)
 4a8:	e062                	sd	s8,0(sp)
 4aa:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ac:	0005c903          	lbu	s2,0(a1)
 4b0:	18090c63          	beqz	s2,648 <vprintf+0x1b4>
 4b4:	8aaa                	mv	s5,a0
 4b6:	8bb2                	mv	s7,a2
 4b8:	00158493          	add	s1,a1,1
  state = 0;
 4bc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4be:	02500a13          	li	s4,37
 4c2:	4b55                	li	s6,21
 4c4:	a839                	j	4e2 <vprintf+0x4e>
        putc(fd, c);
 4c6:	85ca                	mv	a1,s2
 4c8:	8556                	mv	a0,s5
 4ca:	00000097          	auipc	ra,0x0
 4ce:	efc080e7          	jalr	-260(ra) # 3c6 <putc>
 4d2:	a019                	j	4d8 <vprintf+0x44>
    } else if(state == '%'){
 4d4:	01498d63          	beq	s3,s4,4ee <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4d8:	0485                	add	s1,s1,1
 4da:	fff4c903          	lbu	s2,-1(s1)
 4de:	16090563          	beqz	s2,648 <vprintf+0x1b4>
    if(state == 0){
 4e2:	fe0999e3          	bnez	s3,4d4 <vprintf+0x40>
      if(c == '%'){
 4e6:	ff4910e3          	bne	s2,s4,4c6 <vprintf+0x32>
        state = '%';
 4ea:	89d2                	mv	s3,s4
 4ec:	b7f5                	j	4d8 <vprintf+0x44>
      if(c == 'd'){
 4ee:	13490263          	beq	s2,s4,612 <vprintf+0x17e>
 4f2:	f9d9079b          	addw	a5,s2,-99
 4f6:	0ff7f793          	zext.b	a5,a5
 4fa:	12fb6563          	bltu	s6,a5,624 <vprintf+0x190>
 4fe:	f9d9079b          	addw	a5,s2,-99
 502:	0ff7f713          	zext.b	a4,a5
 506:	10eb6f63          	bltu	s6,a4,624 <vprintf+0x190>
 50a:	00271793          	sll	a5,a4,0x2
 50e:	00000717          	auipc	a4,0x0
 512:	38270713          	add	a4,a4,898 # 890 <malloc+0x14a>
 516:	97ba                	add	a5,a5,a4
 518:	439c                	lw	a5,0(a5)
 51a:	97ba                	add	a5,a5,a4
 51c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 51e:	008b8913          	add	s2,s7,8
 522:	4685                	li	a3,1
 524:	4629                	li	a2,10
 526:	000ba583          	lw	a1,0(s7)
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	ebc080e7          	jalr	-324(ra) # 3e8 <printint>
 534:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 536:	4981                	li	s3,0
 538:	b745                	j	4d8 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 53a:	008b8913          	add	s2,s7,8
 53e:	4681                	li	a3,0
 540:	4629                	li	a2,10
 542:	000ba583          	lw	a1,0(s7)
 546:	8556                	mv	a0,s5
 548:	00000097          	auipc	ra,0x0
 54c:	ea0080e7          	jalr	-352(ra) # 3e8 <printint>
 550:	8bca                	mv	s7,s2
      state = 0;
 552:	4981                	li	s3,0
 554:	b751                	j	4d8 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 556:	008b8913          	add	s2,s7,8
 55a:	4681                	li	a3,0
 55c:	4641                	li	a2,16
 55e:	000ba583          	lw	a1,0(s7)
 562:	8556                	mv	a0,s5
 564:	00000097          	auipc	ra,0x0
 568:	e84080e7          	jalr	-380(ra) # 3e8 <printint>
 56c:	8bca                	mv	s7,s2
      state = 0;
 56e:	4981                	li	s3,0
 570:	b7a5                	j	4d8 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 572:	008b8c13          	add	s8,s7,8
 576:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 57a:	03000593          	li	a1,48
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	e46080e7          	jalr	-442(ra) # 3c6 <putc>
  putc(fd, 'x');
 588:	07800593          	li	a1,120
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	e38080e7          	jalr	-456(ra) # 3c6 <putc>
 596:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 598:	00000b97          	auipc	s7,0x0
 59c:	350b8b93          	add	s7,s7,848 # 8e8 <digits>
 5a0:	03c9d793          	srl	a5,s3,0x3c
 5a4:	97de                	add	a5,a5,s7
 5a6:	0007c583          	lbu	a1,0(a5)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e1a080e7          	jalr	-486(ra) # 3c6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b4:	0992                	sll	s3,s3,0x4
 5b6:	397d                	addw	s2,s2,-1
 5b8:	fe0914e3          	bnez	s2,5a0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5bc:	8be2                	mv	s7,s8
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	bf21                	j	4d8 <vprintf+0x44>
        s = va_arg(ap, char*);
 5c2:	008b8993          	add	s3,s7,8
 5c6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ca:	02090163          	beqz	s2,5ec <vprintf+0x158>
        while(*s != 0){
 5ce:	00094583          	lbu	a1,0(s2)
 5d2:	c9a5                	beqz	a1,642 <vprintf+0x1ae>
          putc(fd, *s);
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	df0080e7          	jalr	-528(ra) # 3c6 <putc>
          s++;
 5de:	0905                	add	s2,s2,1
        while(*s != 0){
 5e0:	00094583          	lbu	a1,0(s2)
 5e4:	f9e5                	bnez	a1,5d4 <vprintf+0x140>
        s = va_arg(ap, char*);
 5e6:	8bce                	mv	s7,s3
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b5fd                	j	4d8 <vprintf+0x44>
          s = "(null)";
 5ec:	00000917          	auipc	s2,0x0
 5f0:	29c90913          	add	s2,s2,668 # 888 <malloc+0x142>
        while(*s != 0){
 5f4:	02800593          	li	a1,40
 5f8:	bff1                	j	5d4 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5fa:	008b8913          	add	s2,s7,8
 5fe:	000bc583          	lbu	a1,0(s7)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	dc2080e7          	jalr	-574(ra) # 3c6 <putc>
 60c:	8bca                	mv	s7,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b5e1                	j	4d8 <vprintf+0x44>
        putc(fd, c);
 612:	02500593          	li	a1,37
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dae080e7          	jalr	-594(ra) # 3c6 <putc>
      state = 0;
 620:	4981                	li	s3,0
 622:	bd5d                	j	4d8 <vprintf+0x44>
        putc(fd, '%');
 624:	02500593          	li	a1,37
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	d9c080e7          	jalr	-612(ra) # 3c6 <putc>
        putc(fd, c);
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	d90080e7          	jalr	-624(ra) # 3c6 <putc>
      state = 0;
 63e:	4981                	li	s3,0
 640:	bd61                	j	4d8 <vprintf+0x44>
        s = va_arg(ap, char*);
 642:	8bce                	mv	s7,s3
      state = 0;
 644:	4981                	li	s3,0
 646:	bd49                	j	4d8 <vprintf+0x44>
    }
  }
}
 648:	60a6                	ld	ra,72(sp)
 64a:	6406                	ld	s0,64(sp)
 64c:	74e2                	ld	s1,56(sp)
 64e:	7942                	ld	s2,48(sp)
 650:	79a2                	ld	s3,40(sp)
 652:	7a02                	ld	s4,32(sp)
 654:	6ae2                	ld	s5,24(sp)
 656:	6b42                	ld	s6,16(sp)
 658:	6ba2                	ld	s7,8(sp)
 65a:	6c02                	ld	s8,0(sp)
 65c:	6161                	add	sp,sp,80
 65e:	8082                	ret

0000000000000660 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 660:	715d                	add	sp,sp,-80
 662:	ec06                	sd	ra,24(sp)
 664:	e822                	sd	s0,16(sp)
 666:	1000                	add	s0,sp,32
 668:	e010                	sd	a2,0(s0)
 66a:	e414                	sd	a3,8(s0)
 66c:	e818                	sd	a4,16(s0)
 66e:	ec1c                	sd	a5,24(s0)
 670:	03043023          	sd	a6,32(s0)
 674:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 678:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 67c:	8622                	mv	a2,s0
 67e:	00000097          	auipc	ra,0x0
 682:	e16080e7          	jalr	-490(ra) # 494 <vprintf>
}
 686:	60e2                	ld	ra,24(sp)
 688:	6442                	ld	s0,16(sp)
 68a:	6161                	add	sp,sp,80
 68c:	8082                	ret

000000000000068e <printf>:

void
printf(const char *fmt, ...)
{
 68e:	711d                	add	sp,sp,-96
 690:	ec06                	sd	ra,24(sp)
 692:	e822                	sd	s0,16(sp)
 694:	1000                	add	s0,sp,32
 696:	e40c                	sd	a1,8(s0)
 698:	e810                	sd	a2,16(s0)
 69a:	ec14                	sd	a3,24(s0)
 69c:	f018                	sd	a4,32(s0)
 69e:	f41c                	sd	a5,40(s0)
 6a0:	03043823          	sd	a6,48(s0)
 6a4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6a8:	00840613          	add	a2,s0,8
 6ac:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b0:	85aa                	mv	a1,a0
 6b2:	4505                	li	a0,1
 6b4:	00000097          	auipc	ra,0x0
 6b8:	de0080e7          	jalr	-544(ra) # 494 <vprintf>
}
 6bc:	60e2                	ld	ra,24(sp)
 6be:	6442                	ld	s0,16(sp)
 6c0:	6125                	add	sp,sp,96
 6c2:	8082                	ret

00000000000006c4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6c4:	1141                	add	sp,sp,-16
 6c6:	e422                	sd	s0,8(sp)
 6c8:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ca:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ce:	00001797          	auipc	a5,0x1
 6d2:	9327b783          	ld	a5,-1742(a5) # 1000 <freep>
 6d6:	a02d                	j	700 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6d8:	4618                	lw	a4,8(a2)
 6da:	9f2d                	addw	a4,a4,a1
 6dc:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e0:	6398                	ld	a4,0(a5)
 6e2:	6310                	ld	a2,0(a4)
 6e4:	a83d                	j	722 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6e6:	ff852703          	lw	a4,-8(a0)
 6ea:	9f31                	addw	a4,a4,a2
 6ec:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ee:	ff053683          	ld	a3,-16(a0)
 6f2:	a091                	j	736 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f4:	6398                	ld	a4,0(a5)
 6f6:	00e7e463          	bltu	a5,a4,6fe <free+0x3a>
 6fa:	00e6ea63          	bltu	a3,a4,70e <free+0x4a>
{
 6fe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 700:	fed7fae3          	bgeu	a5,a3,6f4 <free+0x30>
 704:	6398                	ld	a4,0(a5)
 706:	00e6e463          	bltu	a3,a4,70e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70a:	fee7eae3          	bltu	a5,a4,6fe <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 70e:	ff852583          	lw	a1,-8(a0)
 712:	6390                	ld	a2,0(a5)
 714:	02059813          	sll	a6,a1,0x20
 718:	01c85713          	srl	a4,a6,0x1c
 71c:	9736                	add	a4,a4,a3
 71e:	fae60de3          	beq	a2,a4,6d8 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 722:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 726:	4790                	lw	a2,8(a5)
 728:	02061593          	sll	a1,a2,0x20
 72c:	01c5d713          	srl	a4,a1,0x1c
 730:	973e                	add	a4,a4,a5
 732:	fae68ae3          	beq	a3,a4,6e6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 736:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 738:	00001717          	auipc	a4,0x1
 73c:	8cf73423          	sd	a5,-1848(a4) # 1000 <freep>
}
 740:	6422                	ld	s0,8(sp)
 742:	0141                	add	sp,sp,16
 744:	8082                	ret

0000000000000746 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 746:	7139                	add	sp,sp,-64
 748:	fc06                	sd	ra,56(sp)
 74a:	f822                	sd	s0,48(sp)
 74c:	f426                	sd	s1,40(sp)
 74e:	f04a                	sd	s2,32(sp)
 750:	ec4e                	sd	s3,24(sp)
 752:	e852                	sd	s4,16(sp)
 754:	e456                	sd	s5,8(sp)
 756:	e05a                	sd	s6,0(sp)
 758:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 75a:	02051493          	sll	s1,a0,0x20
 75e:	9081                	srl	s1,s1,0x20
 760:	04bd                	add	s1,s1,15
 762:	8091                	srl	s1,s1,0x4
 764:	0014899b          	addw	s3,s1,1
 768:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 76a:	00001517          	auipc	a0,0x1
 76e:	89653503          	ld	a0,-1898(a0) # 1000 <freep>
 772:	c515                	beqz	a0,79e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 774:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 776:	4798                	lw	a4,8(a5)
 778:	02977f63          	bgeu	a4,s1,7b6 <malloc+0x70>
  if(nu < 4096)
 77c:	8a4e                	mv	s4,s3
 77e:	0009871b          	sext.w	a4,s3
 782:	6685                	lui	a3,0x1
 784:	00d77363          	bgeu	a4,a3,78a <malloc+0x44>
 788:	6a05                	lui	s4,0x1
 78a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 78e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 792:	00001917          	auipc	s2,0x1
 796:	86e90913          	add	s2,s2,-1938 # 1000 <freep>
  if(p == (char*)-1)
 79a:	5afd                	li	s5,-1
 79c:	a895                	j	810 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 79e:	00001797          	auipc	a5,0x1
 7a2:	87278793          	add	a5,a5,-1934 # 1010 <base>
 7a6:	00001717          	auipc	a4,0x1
 7aa:	84f73d23          	sd	a5,-1958(a4) # 1000 <freep>
 7ae:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7b4:	b7e1                	j	77c <malloc+0x36>
      if(p->s.size == nunits)
 7b6:	02e48c63          	beq	s1,a4,7ee <malloc+0xa8>
        p->s.size -= nunits;
 7ba:	4137073b          	subw	a4,a4,s3
 7be:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c0:	02071693          	sll	a3,a4,0x20
 7c4:	01c6d713          	srl	a4,a3,0x1c
 7c8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ca:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ce:	00001717          	auipc	a4,0x1
 7d2:	82a73923          	sd	a0,-1998(a4) # 1000 <freep>
      return (void*)(p + 1);
 7d6:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7da:	70e2                	ld	ra,56(sp)
 7dc:	7442                	ld	s0,48(sp)
 7de:	74a2                	ld	s1,40(sp)
 7e0:	7902                	ld	s2,32(sp)
 7e2:	69e2                	ld	s3,24(sp)
 7e4:	6a42                	ld	s4,16(sp)
 7e6:	6aa2                	ld	s5,8(sp)
 7e8:	6b02                	ld	s6,0(sp)
 7ea:	6121                	add	sp,sp,64
 7ec:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7ee:	6398                	ld	a4,0(a5)
 7f0:	e118                	sd	a4,0(a0)
 7f2:	bff1                	j	7ce <malloc+0x88>
  hp->s.size = nu;
 7f4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f8:	0541                	add	a0,a0,16
 7fa:	00000097          	auipc	ra,0x0
 7fe:	eca080e7          	jalr	-310(ra) # 6c4 <free>
  return freep;
 802:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 806:	d971                	beqz	a0,7da <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 808:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80a:	4798                	lw	a4,8(a5)
 80c:	fa9775e3          	bgeu	a4,s1,7b6 <malloc+0x70>
    if(p == freep)
 810:	00093703          	ld	a4,0(s2)
 814:	853e                	mv	a0,a5
 816:	fef719e3          	bne	a4,a5,808 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 81a:	8552                	mv	a0,s4
 81c:	00000097          	auipc	ra,0x0
 820:	b92080e7          	jalr	-1134(ra) # 3ae <sbrk>
  if(p == (char*)-1)
 824:	fd5518e3          	bne	a0,s5,7f4 <malloc+0xae>
        return 0;
 828:	4501                	li	a0,0
 82a:	bf45                	j	7da <malloc+0x94>
