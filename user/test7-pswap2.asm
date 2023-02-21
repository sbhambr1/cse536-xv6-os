
user/_test7-pswap2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include <stdarg.h>

int
main(int argc, char *argv[])
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	add	s0,sp,32
    /* Allocate as many pages as allowed. */
    int npages = 101;
    void* heappages = sbrk(4096*npages);
   a:	00065537          	lui	a0,0x65
   e:	00000097          	auipc	ra,0x0
  12:	3a8080e7          	jalr	936(ra) # 3b6 <sbrk>
    if (!heappages) {
  16:	c531                	beqz	a0,62 <main+0x62>
  18:	882a                	mv	a6,a0
  1a:	6705                	lui	a4,0x1
  1c:	972a                	add	a4,a4,a0
        return -1;
    }

    /* Write random numbers to the allocated heap regions. */
    int* a;
    int count = 0;
  1e:	4681                	li	a3,0
    for (int i = 0; i < npages; i++) {
        a = ((int*) (heappages + i*PGSIZE));
  20:	757d                	lui	a0,0xfffff
    for (int i = 0; i < npages; i++) {
  22:	6585                	lui	a1,0x1
  24:	06500613          	li	a2,101
        a = ((int*) (heappages + i*PGSIZE));
  28:	00a707b3          	add	a5,a4,a0
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
            *a = count;
  2c:	c394                	sw	a3,0(a5)
            a++;
  2e:	0791                	add	a5,a5,4
        for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  30:	fee79ee3          	bne	a5,a4,2c <main+0x2c>
        }
        count++;
  34:	2685                	addw	a3,a3,1
    for (int i = 0; i < npages; i++) {
  36:	972e                	add	a4,a4,a1
  38:	fec698e3          	bne	a3,a2,28 <main+0x28>
    }

    /* Assert heap memory correctness by checking the regions. */
    count = 0;
    a = (int*) (heappages);
    for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  3c:	4581                	li	a1,0
  3e:	40000793          	li	a5,1024
        if (*a != count) {
  42:	00082483          	lw	s1,0(a6)
  46:	e885                	bnez	s1,76 <main+0x76>
            printf("i = %d: a = %d (expect = %d)", j, *a, count);
            goto fail;
        }
        a++;
  48:	0811                	add	a6,a6,4
    for (int j = 0; j < PGSIZE/sizeof(int); j++) {
  4a:	2585                	addw	a1,a1,1 # 1001 <freep+0x1>
  4c:	fef59be3          	bne	a1,a5,42 <main+0x42>
    }
    
    printf("[*] PSWAP TEST2 PASSED.\n");
  50:	00001517          	auipc	a0,0x1
  54:	85050513          	add	a0,a0,-1968 # 8a0 <malloc+0x152>
  58:	00000097          	auipc	ra,0x0
  5c:	63e080e7          	jalr	1598(ra) # 696 <printf>
    return 0;
  60:	a835                	j	9c <main+0x9c>
        printf("[X] Heap memory allocation FAILED.\n");
  62:	00000517          	auipc	a0,0x0
  66:	7de50513          	add	a0,a0,2014 # 840 <malloc+0xf2>
  6a:	00000097          	auipc	ra,0x0
  6e:	62c080e7          	jalr	1580(ra) # 696 <printf>
        return -1;
  72:	54fd                	li	s1,-1
  74:	a025                	j	9c <main+0x9c>
            printf("i = %d: a = %d (expect = %d)", j, *a, count);
  76:	4681                	li	a3,0
  78:	8626                	mv	a2,s1
  7a:	00000517          	auipc	a0,0x0
  7e:	7ee50513          	add	a0,a0,2030 # 868 <malloc+0x11a>
  82:	00000097          	auipc	ra,0x0
  86:	614080e7          	jalr	1556(ra) # 696 <printf>

fail:
    printf("[X] Heap test FAILED.\n");
  8a:	00000517          	auipc	a0,0x0
  8e:	7fe50513          	add	a0,a0,2046 # 888 <malloc+0x13a>
  92:	00000097          	auipc	ra,0x0
  96:	604080e7          	jalr	1540(ra) # 696 <printf>
    return -1;
  9a:	54fd                	li	s1,-1
  9c:	8526                	mv	a0,s1
  9e:	60e2                	ld	ra,24(sp)
  a0:	6442                	ld	s0,16(sp)
  a2:	64a2                	ld	s1,8(sp)
  a4:	6105                	add	sp,sp,32
  a6:	8082                	ret

00000000000000a8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  a8:	1141                	add	sp,sp,-16
  aa:	e406                	sd	ra,8(sp)
  ac:	e022                	sd	s0,0(sp)
  ae:	0800                	add	s0,sp,16
  extern int main();
  main();
  b0:	00000097          	auipc	ra,0x0
  b4:	f50080e7          	jalr	-176(ra) # 0 <main>
  exit(0);
  b8:	4501                	li	a0,0
  ba:	00000097          	auipc	ra,0x0
  be:	274080e7          	jalr	628(ra) # 32e <exit>

00000000000000c2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c2:	1141                	add	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c8:	87aa                	mv	a5,a0
  ca:	0585                	add	a1,a1,1
  cc:	0785                	add	a5,a5,1
  ce:	fff5c703          	lbu	a4,-1(a1)
  d2:	fee78fa3          	sb	a4,-1(a5)
  d6:	fb75                	bnez	a4,ca <strcpy+0x8>
    ;
  return os;
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	add	sp,sp,16
  dc:	8082                	ret

00000000000000de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  de:	1141                	add	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cb91                	beqz	a5,fc <strcmp+0x1e>
  ea:	0005c703          	lbu	a4,0(a1)
  ee:	00f71763          	bne	a4,a5,fc <strcmp+0x1e>
    p++, q++;
  f2:	0505                	add	a0,a0,1
  f4:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbe5                	bnez	a5,ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fc:	0005c503          	lbu	a0,0(a1)
}
 100:	40a7853b          	subw	a0,a5,a0
 104:	6422                	ld	s0,8(sp)
 106:	0141                	add	sp,sp,16
 108:	8082                	ret

000000000000010a <strlen>:

uint
strlen(const char *s)
{
 10a:	1141                	add	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cf91                	beqz	a5,130 <strlen+0x26>
 116:	0505                	add	a0,a0,1
 118:	87aa                	mv	a5,a0
 11a:	86be                	mv	a3,a5
 11c:	0785                	add	a5,a5,1
 11e:	fff7c703          	lbu	a4,-1(a5)
 122:	ff65                	bnez	a4,11a <strlen+0x10>
 124:	40a6853b          	subw	a0,a3,a0
 128:	2505                	addw	a0,a0,1
    ;
  return n;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	add	sp,sp,16
 12e:	8082                	ret
  for(n = 0; s[n]; n++)
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strlen+0x20>

0000000000000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	1141                	add	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 13a:	ca19                	beqz	a2,150 <memset+0x1c>
 13c:	87aa                	mv	a5,a0
 13e:	1602                	sll	a2,a2,0x20
 140:	9201                	srl	a2,a2,0x20
 142:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 146:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14a:	0785                	add	a5,a5,1
 14c:	fee79de3          	bne	a5,a4,146 <memset+0x12>
  }
  return dst;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	add	sp,sp,16
 154:	8082                	ret

0000000000000156 <strchr>:

char*
strchr(const char *s, char c)
{
 156:	1141                	add	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	add	s0,sp,16
  for(; *s; s++)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cb99                	beqz	a5,176 <strchr+0x20>
    if(*s == c)
 162:	00f58763          	beq	a1,a5,170 <strchr+0x1a>
  for(; *s; s++)
 166:	0505                	add	a0,a0,1
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbfd                	bnez	a5,162 <strchr+0xc>
      return (char*)s;
  return 0;
 16e:	4501                	li	a0,0
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	add	sp,sp,16
 174:	8082                	ret
  return 0;
 176:	4501                	li	a0,0
 178:	bfe5                	j	170 <strchr+0x1a>

000000000000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	711d                	add	sp,sp,-96
 17c:	ec86                	sd	ra,88(sp)
 17e:	e8a2                	sd	s0,80(sp)
 180:	e4a6                	sd	s1,72(sp)
 182:	e0ca                	sd	s2,64(sp)
 184:	fc4e                	sd	s3,56(sp)
 186:	f852                	sd	s4,48(sp)
 188:	f456                	sd	s5,40(sp)
 18a:	f05a                	sd	s6,32(sp)
 18c:	ec5e                	sd	s7,24(sp)
 18e:	1080                	add	s0,sp,96
 190:	8baa                	mv	s7,a0
 192:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 194:	892a                	mv	s2,a0
 196:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 198:	4aa9                	li	s5,10
 19a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19c:	89a6                	mv	s3,s1
 19e:	2485                	addw	s1,s1,1
 1a0:	0344d863          	bge	s1,s4,1d0 <gets+0x56>
    cc = read(0, &c, 1);
 1a4:	4605                	li	a2,1
 1a6:	faf40593          	add	a1,s0,-81
 1aa:	4501                	li	a0,0
 1ac:	00000097          	auipc	ra,0x0
 1b0:	19a080e7          	jalr	410(ra) # 346 <read>
    if(cc < 1)
 1b4:	00a05e63          	blez	a0,1d0 <gets+0x56>
    buf[i++] = c;
 1b8:	faf44783          	lbu	a5,-81(s0)
 1bc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c0:	01578763          	beq	a5,s5,1ce <gets+0x54>
 1c4:	0905                	add	s2,s2,1
 1c6:	fd679be3          	bne	a5,s6,19c <gets+0x22>
  for(i=0; i+1 < max; ){
 1ca:	89a6                	mv	s3,s1
 1cc:	a011                	j	1d0 <gets+0x56>
 1ce:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d0:	99de                	add	s3,s3,s7
 1d2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d6:	855e                	mv	a0,s7
 1d8:	60e6                	ld	ra,88(sp)
 1da:	6446                	ld	s0,80(sp)
 1dc:	64a6                	ld	s1,72(sp)
 1de:	6906                	ld	s2,64(sp)
 1e0:	79e2                	ld	s3,56(sp)
 1e2:	7a42                	ld	s4,48(sp)
 1e4:	7aa2                	ld	s5,40(sp)
 1e6:	7b02                	ld	s6,32(sp)
 1e8:	6be2                	ld	s7,24(sp)
 1ea:	6125                	add	sp,sp,96
 1ec:	8082                	ret

00000000000001ee <stat>:

int
stat(const char *n, struct stat *st)
{
 1ee:	1101                	add	sp,sp,-32
 1f0:	ec06                	sd	ra,24(sp)
 1f2:	e822                	sd	s0,16(sp)
 1f4:	e426                	sd	s1,8(sp)
 1f6:	e04a                	sd	s2,0(sp)
 1f8:	1000                	add	s0,sp,32
 1fa:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fc:	4581                	li	a1,0
 1fe:	00000097          	auipc	ra,0x0
 202:	170080e7          	jalr	368(ra) # 36e <open>
  if(fd < 0)
 206:	02054563          	bltz	a0,230 <stat+0x42>
 20a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20c:	85ca                	mv	a1,s2
 20e:	00000097          	auipc	ra,0x0
 212:	178080e7          	jalr	376(ra) # 386 <fstat>
 216:	892a                	mv	s2,a0
  close(fd);
 218:	8526                	mv	a0,s1
 21a:	00000097          	auipc	ra,0x0
 21e:	13c080e7          	jalr	316(ra) # 356 <close>
  return r;
}
 222:	854a                	mv	a0,s2
 224:	60e2                	ld	ra,24(sp)
 226:	6442                	ld	s0,16(sp)
 228:	64a2                	ld	s1,8(sp)
 22a:	6902                	ld	s2,0(sp)
 22c:	6105                	add	sp,sp,32
 22e:	8082                	ret
    return -1;
 230:	597d                	li	s2,-1
 232:	bfc5                	j	222 <stat+0x34>

0000000000000234 <atoi>:

int
atoi(const char *s)
{
 234:	1141                	add	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23a:	00054683          	lbu	a3,0(a0)
 23e:	fd06879b          	addw	a5,a3,-48
 242:	0ff7f793          	zext.b	a5,a5
 246:	4625                	li	a2,9
 248:	02f66863          	bltu	a2,a5,278 <atoi+0x44>
 24c:	872a                	mv	a4,a0
  n = 0;
 24e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 250:	0705                	add	a4,a4,1 # 1001 <freep+0x1>
 252:	0025179b          	sllw	a5,a0,0x2
 256:	9fa9                	addw	a5,a5,a0
 258:	0017979b          	sllw	a5,a5,0x1
 25c:	9fb5                	addw	a5,a5,a3
 25e:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 262:	00074683          	lbu	a3,0(a4)
 266:	fd06879b          	addw	a5,a3,-48
 26a:	0ff7f793          	zext.b	a5,a5
 26e:	fef671e3          	bgeu	a2,a5,250 <atoi+0x1c>
  return n;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	add	sp,sp,16
 276:	8082                	ret
  n = 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <atoi+0x3e>

000000000000027c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27c:	1141                	add	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 282:	02b57463          	bgeu	a0,a1,2aa <memmove+0x2e>
    while(n-- > 0)
 286:	00c05f63          	blez	a2,2a4 <memmove+0x28>
 28a:	1602                	sll	a2,a2,0x20
 28c:	9201                	srl	a2,a2,0x20
 28e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 292:	872a                	mv	a4,a0
      *dst++ = *src++;
 294:	0585                	add	a1,a1,1
 296:	0705                	add	a4,a4,1
 298:	fff5c683          	lbu	a3,-1(a1)
 29c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a0:	fee79ae3          	bne	a5,a4,294 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	add	sp,sp,16
 2a8:	8082                	ret
    dst += n;
 2aa:	00c50733          	add	a4,a0,a2
    src += n;
 2ae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b0:	fec05ae3          	blez	a2,2a4 <memmove+0x28>
 2b4:	fff6079b          	addw	a5,a2,-1
 2b8:	1782                	sll	a5,a5,0x20
 2ba:	9381                	srl	a5,a5,0x20
 2bc:	fff7c793          	not	a5,a5
 2c0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2c2:	15fd                	add	a1,a1,-1
 2c4:	177d                	add	a4,a4,-1
 2c6:	0005c683          	lbu	a3,0(a1)
 2ca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2ce:	fee79ae3          	bne	a5,a4,2c2 <memmove+0x46>
 2d2:	bfc9                	j	2a4 <memmove+0x28>

00000000000002d4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2d4:	1141                	add	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2da:	ca05                	beqz	a2,30a <memcmp+0x36>
 2dc:	fff6069b          	addw	a3,a2,-1
 2e0:	1682                	sll	a3,a3,0x20
 2e2:	9281                	srl	a3,a3,0x20
 2e4:	0685                	add	a3,a3,1
 2e6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2e8:	00054783          	lbu	a5,0(a0)
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00e79863          	bne	a5,a4,300 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2f4:	0505                	add	a0,a0,1
    p2++;
 2f6:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2f8:	fed518e3          	bne	a0,a3,2e8 <memcmp+0x14>
  }
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	a019                	j	304 <memcmp+0x30>
      return *p1 - *p2;
 300:	40e7853b          	subw	a0,a5,a4
}
 304:	6422                	ld	s0,8(sp)
 306:	0141                	add	sp,sp,16
 308:	8082                	ret
  return 0;
 30a:	4501                	li	a0,0
 30c:	bfe5                	j	304 <memcmp+0x30>

000000000000030e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 30e:	1141                	add	sp,sp,-16
 310:	e406                	sd	ra,8(sp)
 312:	e022                	sd	s0,0(sp)
 314:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 316:	00000097          	auipc	ra,0x0
 31a:	f66080e7          	jalr	-154(ra) # 27c <memmove>
}
 31e:	60a2                	ld	ra,8(sp)
 320:	6402                	ld	s0,0(sp)
 322:	0141                	add	sp,sp,16
 324:	8082                	ret

0000000000000326 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 326:	4885                	li	a7,1
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <exit>:
.global exit
exit:
 li a7, SYS_exit
 32e:	4889                	li	a7,2
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait>:
.global wait
wait:
 li a7, SYS_wait
 336:	488d                	li	a7,3
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 33e:	4891                	li	a7,4
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <read>:
.global read
read:
 li a7, SYS_read
 346:	4895                	li	a7,5
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <write>:
.global write
write:
 li a7, SYS_write
 34e:	48c1                	li	a7,16
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <close>:
.global close
close:
 li a7, SYS_close
 356:	48d5                	li	a7,21
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <kill>:
.global kill
kill:
 li a7, SYS_kill
 35e:	4899                	li	a7,6
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exec>:
.global exec
exec:
 li a7, SYS_exec
 366:	489d                	li	a7,7
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <open>:
.global open
open:
 li a7, SYS_open
 36e:	48bd                	li	a7,15
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 376:	48c5                	li	a7,17
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 37e:	48c9                	li	a7,18
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 386:	48a1                	li	a7,8
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <link>:
.global link
link:
 li a7, SYS_link
 38e:	48cd                	li	a7,19
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 396:	48d1                	li	a7,20
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 39e:	48a5                	li	a7,9
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3a6:	48a9                	li	a7,10
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ae:	48ad                	li	a7,11
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3b6:	48b1                	li	a7,12
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3be:	48b5                	li	a7,13
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3c6:	48b9                	li	a7,14
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ce:	1101                	add	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	1000                	add	s0,sp,32
 3d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3da:	4605                	li	a2,1
 3dc:	fef40593          	add	a1,s0,-17
 3e0:	00000097          	auipc	ra,0x0
 3e4:	f6e080e7          	jalr	-146(ra) # 34e <write>
}
 3e8:	60e2                	ld	ra,24(sp)
 3ea:	6442                	ld	s0,16(sp)
 3ec:	6105                	add	sp,sp,32
 3ee:	8082                	ret

00000000000003f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3f0:	7139                	add	sp,sp,-64
 3f2:	fc06                	sd	ra,56(sp)
 3f4:	f822                	sd	s0,48(sp)
 3f6:	f426                	sd	s1,40(sp)
 3f8:	f04a                	sd	s2,32(sp)
 3fa:	ec4e                	sd	s3,24(sp)
 3fc:	0080                	add	s0,sp,64
 3fe:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 400:	c299                	beqz	a3,406 <printint+0x16>
 402:	0805c963          	bltz	a1,494 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 406:	2581                	sext.w	a1,a1
  neg = 0;
 408:	4881                	li	a7,0
 40a:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 40e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 410:	2601                	sext.w	a2,a2
 412:	00000517          	auipc	a0,0x0
 416:	50e50513          	add	a0,a0,1294 # 920 <digits>
 41a:	883a                	mv	a6,a4
 41c:	2705                	addw	a4,a4,1
 41e:	02c5f7bb          	remuw	a5,a1,a2
 422:	1782                	sll	a5,a5,0x20
 424:	9381                	srl	a5,a5,0x20
 426:	97aa                	add	a5,a5,a0
 428:	0007c783          	lbu	a5,0(a5)
 42c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 430:	0005879b          	sext.w	a5,a1
 434:	02c5d5bb          	divuw	a1,a1,a2
 438:	0685                	add	a3,a3,1
 43a:	fec7f0e3          	bgeu	a5,a2,41a <printint+0x2a>
  if(neg)
 43e:	00088c63          	beqz	a7,456 <printint+0x66>
    buf[i++] = '-';
 442:	fd070793          	add	a5,a4,-48
 446:	00878733          	add	a4,a5,s0
 44a:	02d00793          	li	a5,45
 44e:	fef70823          	sb	a5,-16(a4)
 452:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 456:	02e05863          	blez	a4,486 <printint+0x96>
 45a:	fc040793          	add	a5,s0,-64
 45e:	00e78933          	add	s2,a5,a4
 462:	fff78993          	add	s3,a5,-1
 466:	99ba                	add	s3,s3,a4
 468:	377d                	addw	a4,a4,-1
 46a:	1702                	sll	a4,a4,0x20
 46c:	9301                	srl	a4,a4,0x20
 46e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 472:	fff94583          	lbu	a1,-1(s2)
 476:	8526                	mv	a0,s1
 478:	00000097          	auipc	ra,0x0
 47c:	f56080e7          	jalr	-170(ra) # 3ce <putc>
  while(--i >= 0)
 480:	197d                	add	s2,s2,-1
 482:	ff3918e3          	bne	s2,s3,472 <printint+0x82>
}
 486:	70e2                	ld	ra,56(sp)
 488:	7442                	ld	s0,48(sp)
 48a:	74a2                	ld	s1,40(sp)
 48c:	7902                	ld	s2,32(sp)
 48e:	69e2                	ld	s3,24(sp)
 490:	6121                	add	sp,sp,64
 492:	8082                	ret
    x = -xx;
 494:	40b005bb          	negw	a1,a1
    neg = 1;
 498:	4885                	li	a7,1
    x = -xx;
 49a:	bf85                	j	40a <printint+0x1a>

000000000000049c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 49c:	715d                	add	sp,sp,-80
 49e:	e486                	sd	ra,72(sp)
 4a0:	e0a2                	sd	s0,64(sp)
 4a2:	fc26                	sd	s1,56(sp)
 4a4:	f84a                	sd	s2,48(sp)
 4a6:	f44e                	sd	s3,40(sp)
 4a8:	f052                	sd	s4,32(sp)
 4aa:	ec56                	sd	s5,24(sp)
 4ac:	e85a                	sd	s6,16(sp)
 4ae:	e45e                	sd	s7,8(sp)
 4b0:	e062                	sd	s8,0(sp)
 4b2:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b4:	0005c903          	lbu	s2,0(a1)
 4b8:	18090c63          	beqz	s2,650 <vprintf+0x1b4>
 4bc:	8aaa                	mv	s5,a0
 4be:	8bb2                	mv	s7,a2
 4c0:	00158493          	add	s1,a1,1
  state = 0;
 4c4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4c6:	02500a13          	li	s4,37
 4ca:	4b55                	li	s6,21
 4cc:	a839                	j	4ea <vprintf+0x4e>
        putc(fd, c);
 4ce:	85ca                	mv	a1,s2
 4d0:	8556                	mv	a0,s5
 4d2:	00000097          	auipc	ra,0x0
 4d6:	efc080e7          	jalr	-260(ra) # 3ce <putc>
 4da:	a019                	j	4e0 <vprintf+0x44>
    } else if(state == '%'){
 4dc:	01498d63          	beq	s3,s4,4f6 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4e0:	0485                	add	s1,s1,1
 4e2:	fff4c903          	lbu	s2,-1(s1)
 4e6:	16090563          	beqz	s2,650 <vprintf+0x1b4>
    if(state == 0){
 4ea:	fe0999e3          	bnez	s3,4dc <vprintf+0x40>
      if(c == '%'){
 4ee:	ff4910e3          	bne	s2,s4,4ce <vprintf+0x32>
        state = '%';
 4f2:	89d2                	mv	s3,s4
 4f4:	b7f5                	j	4e0 <vprintf+0x44>
      if(c == 'd'){
 4f6:	13490263          	beq	s2,s4,61a <vprintf+0x17e>
 4fa:	f9d9079b          	addw	a5,s2,-99
 4fe:	0ff7f793          	zext.b	a5,a5
 502:	12fb6563          	bltu	s6,a5,62c <vprintf+0x190>
 506:	f9d9079b          	addw	a5,s2,-99
 50a:	0ff7f713          	zext.b	a4,a5
 50e:	10eb6f63          	bltu	s6,a4,62c <vprintf+0x190>
 512:	00271793          	sll	a5,a4,0x2
 516:	00000717          	auipc	a4,0x0
 51a:	3b270713          	add	a4,a4,946 # 8c8 <malloc+0x17a>
 51e:	97ba                	add	a5,a5,a4
 520:	439c                	lw	a5,0(a5)
 522:	97ba                	add	a5,a5,a4
 524:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 526:	008b8913          	add	s2,s7,8
 52a:	4685                	li	a3,1
 52c:	4629                	li	a2,10
 52e:	000ba583          	lw	a1,0(s7)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	ebc080e7          	jalr	-324(ra) # 3f0 <printint>
 53c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 53e:	4981                	li	s3,0
 540:	b745                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 542:	008b8913          	add	s2,s7,8
 546:	4681                	li	a3,0
 548:	4629                	li	a2,10
 54a:	000ba583          	lw	a1,0(s7)
 54e:	8556                	mv	a0,s5
 550:	00000097          	auipc	ra,0x0
 554:	ea0080e7          	jalr	-352(ra) # 3f0 <printint>
 558:	8bca                	mv	s7,s2
      state = 0;
 55a:	4981                	li	s3,0
 55c:	b751                	j	4e0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 55e:	008b8913          	add	s2,s7,8
 562:	4681                	li	a3,0
 564:	4641                	li	a2,16
 566:	000ba583          	lw	a1,0(s7)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e84080e7          	jalr	-380(ra) # 3f0 <printint>
 574:	8bca                	mv	s7,s2
      state = 0;
 576:	4981                	li	s3,0
 578:	b7a5                	j	4e0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 57a:	008b8c13          	add	s8,s7,8
 57e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 582:	03000593          	li	a1,48
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e46080e7          	jalr	-442(ra) # 3ce <putc>
  putc(fd, 'x');
 590:	07800593          	li	a1,120
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e38080e7          	jalr	-456(ra) # 3ce <putc>
 59e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a0:	00000b97          	auipc	s7,0x0
 5a4:	380b8b93          	add	s7,s7,896 # 920 <digits>
 5a8:	03c9d793          	srl	a5,s3,0x3c
 5ac:	97de                	add	a5,a5,s7
 5ae:	0007c583          	lbu	a1,0(a5)
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	e1a080e7          	jalr	-486(ra) # 3ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5bc:	0992                	sll	s3,s3,0x4
 5be:	397d                	addw	s2,s2,-1
 5c0:	fe0914e3          	bnez	s2,5a8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5c4:	8be2                	mv	s7,s8
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bf21                	j	4e0 <vprintf+0x44>
        s = va_arg(ap, char*);
 5ca:	008b8993          	add	s3,s7,8
 5ce:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5d2:	02090163          	beqz	s2,5f4 <vprintf+0x158>
        while(*s != 0){
 5d6:	00094583          	lbu	a1,0(s2)
 5da:	c9a5                	beqz	a1,64a <vprintf+0x1ae>
          putc(fd, *s);
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	df0080e7          	jalr	-528(ra) # 3ce <putc>
          s++;
 5e6:	0905                	add	s2,s2,1
        while(*s != 0){
 5e8:	00094583          	lbu	a1,0(s2)
 5ec:	f9e5                	bnez	a1,5dc <vprintf+0x140>
        s = va_arg(ap, char*);
 5ee:	8bce                	mv	s7,s3
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b5fd                	j	4e0 <vprintf+0x44>
          s = "(null)";
 5f4:	00000917          	auipc	s2,0x0
 5f8:	2cc90913          	add	s2,s2,716 # 8c0 <malloc+0x172>
        while(*s != 0){
 5fc:	02800593          	li	a1,40
 600:	bff1                	j	5dc <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 602:	008b8913          	add	s2,s7,8
 606:	000bc583          	lbu	a1,0(s7)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	dc2080e7          	jalr	-574(ra) # 3ce <putc>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b5e1                	j	4e0 <vprintf+0x44>
        putc(fd, c);
 61a:	02500593          	li	a1,37
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	dae080e7          	jalr	-594(ra) # 3ce <putc>
      state = 0;
 628:	4981                	li	s3,0
 62a:	bd5d                	j	4e0 <vprintf+0x44>
        putc(fd, '%');
 62c:	02500593          	li	a1,37
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	d9c080e7          	jalr	-612(ra) # 3ce <putc>
        putc(fd, c);
 63a:	85ca                	mv	a1,s2
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	d90080e7          	jalr	-624(ra) # 3ce <putc>
      state = 0;
 646:	4981                	li	s3,0
 648:	bd61                	j	4e0 <vprintf+0x44>
        s = va_arg(ap, char*);
 64a:	8bce                	mv	s7,s3
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bd49                	j	4e0 <vprintf+0x44>
    }
  }
}
 650:	60a6                	ld	ra,72(sp)
 652:	6406                	ld	s0,64(sp)
 654:	74e2                	ld	s1,56(sp)
 656:	7942                	ld	s2,48(sp)
 658:	79a2                	ld	s3,40(sp)
 65a:	7a02                	ld	s4,32(sp)
 65c:	6ae2                	ld	s5,24(sp)
 65e:	6b42                	ld	s6,16(sp)
 660:	6ba2                	ld	s7,8(sp)
 662:	6c02                	ld	s8,0(sp)
 664:	6161                	add	sp,sp,80
 666:	8082                	ret

0000000000000668 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 668:	715d                	add	sp,sp,-80
 66a:	ec06                	sd	ra,24(sp)
 66c:	e822                	sd	s0,16(sp)
 66e:	1000                	add	s0,sp,32
 670:	e010                	sd	a2,0(s0)
 672:	e414                	sd	a3,8(s0)
 674:	e818                	sd	a4,16(s0)
 676:	ec1c                	sd	a5,24(s0)
 678:	03043023          	sd	a6,32(s0)
 67c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 680:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 684:	8622                	mv	a2,s0
 686:	00000097          	auipc	ra,0x0
 68a:	e16080e7          	jalr	-490(ra) # 49c <vprintf>
}
 68e:	60e2                	ld	ra,24(sp)
 690:	6442                	ld	s0,16(sp)
 692:	6161                	add	sp,sp,80
 694:	8082                	ret

0000000000000696 <printf>:

void
printf(const char *fmt, ...)
{
 696:	711d                	add	sp,sp,-96
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	add	s0,sp,32
 69e:	e40c                	sd	a1,8(s0)
 6a0:	e810                	sd	a2,16(s0)
 6a2:	ec14                	sd	a3,24(s0)
 6a4:	f018                	sd	a4,32(s0)
 6a6:	f41c                	sd	a5,40(s0)
 6a8:	03043823          	sd	a6,48(s0)
 6ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6b0:	00840613          	add	a2,s0,8
 6b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6b8:	85aa                	mv	a1,a0
 6ba:	4505                	li	a0,1
 6bc:	00000097          	auipc	ra,0x0
 6c0:	de0080e7          	jalr	-544(ra) # 49c <vprintf>
}
 6c4:	60e2                	ld	ra,24(sp)
 6c6:	6442                	ld	s0,16(sp)
 6c8:	6125                	add	sp,sp,96
 6ca:	8082                	ret

00000000000006cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6cc:	1141                	add	sp,sp,-16
 6ce:	e422                	sd	s0,8(sp)
 6d0:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6d2:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d6:	00001797          	auipc	a5,0x1
 6da:	92a7b783          	ld	a5,-1750(a5) # 1000 <freep>
 6de:	a02d                	j	708 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6e0:	4618                	lw	a4,8(a2)
 6e2:	9f2d                	addw	a4,a4,a1
 6e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e8:	6398                	ld	a4,0(a5)
 6ea:	6310                	ld	a2,0(a4)
 6ec:	a83d                	j	72a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ee:	ff852703          	lw	a4,-8(a0)
 6f2:	9f31                	addw	a4,a4,a2
 6f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6f6:	ff053683          	ld	a3,-16(a0)
 6fa:	a091                	j	73e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	6398                	ld	a4,0(a5)
 6fe:	00e7e463          	bltu	a5,a4,706 <free+0x3a>
 702:	00e6ea63          	bltu	a3,a4,716 <free+0x4a>
{
 706:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 708:	fed7fae3          	bgeu	a5,a3,6fc <free+0x30>
 70c:	6398                	ld	a4,0(a5)
 70e:	00e6e463          	bltu	a3,a4,716 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 712:	fee7eae3          	bltu	a5,a4,706 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 716:	ff852583          	lw	a1,-8(a0)
 71a:	6390                	ld	a2,0(a5)
 71c:	02059813          	sll	a6,a1,0x20
 720:	01c85713          	srl	a4,a6,0x1c
 724:	9736                	add	a4,a4,a3
 726:	fae60de3          	beq	a2,a4,6e0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 72a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 72e:	4790                	lw	a2,8(a5)
 730:	02061593          	sll	a1,a2,0x20
 734:	01c5d713          	srl	a4,a1,0x1c
 738:	973e                	add	a4,a4,a5
 73a:	fae68ae3          	beq	a3,a4,6ee <free+0x22>
    p->s.ptr = bp->s.ptr;
 73e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 740:	00001717          	auipc	a4,0x1
 744:	8cf73023          	sd	a5,-1856(a4) # 1000 <freep>
}
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	add	sp,sp,16
 74c:	8082                	ret

000000000000074e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 74e:	7139                	add	sp,sp,-64
 750:	fc06                	sd	ra,56(sp)
 752:	f822                	sd	s0,48(sp)
 754:	f426                	sd	s1,40(sp)
 756:	f04a                	sd	s2,32(sp)
 758:	ec4e                	sd	s3,24(sp)
 75a:	e852                	sd	s4,16(sp)
 75c:	e456                	sd	s5,8(sp)
 75e:	e05a                	sd	s6,0(sp)
 760:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 762:	02051493          	sll	s1,a0,0x20
 766:	9081                	srl	s1,s1,0x20
 768:	04bd                	add	s1,s1,15
 76a:	8091                	srl	s1,s1,0x4
 76c:	0014899b          	addw	s3,s1,1
 770:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 772:	00001517          	auipc	a0,0x1
 776:	88e53503          	ld	a0,-1906(a0) # 1000 <freep>
 77a:	c515                	beqz	a0,7a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 77e:	4798                	lw	a4,8(a5)
 780:	02977f63          	bgeu	a4,s1,7be <malloc+0x70>
  if(nu < 4096)
 784:	8a4e                	mv	s4,s3
 786:	0009871b          	sext.w	a4,s3
 78a:	6685                	lui	a3,0x1
 78c:	00d77363          	bgeu	a4,a3,792 <malloc+0x44>
 790:	6a05                	lui	s4,0x1
 792:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 796:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 79a:	00001917          	auipc	s2,0x1
 79e:	86690913          	add	s2,s2,-1946 # 1000 <freep>
  if(p == (char*)-1)
 7a2:	5afd                	li	s5,-1
 7a4:	a895                	j	818 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7a6:	00001797          	auipc	a5,0x1
 7aa:	86a78793          	add	a5,a5,-1942 # 1010 <base>
 7ae:	00001717          	auipc	a4,0x1
 7b2:	84f73923          	sd	a5,-1966(a4) # 1000 <freep>
 7b6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7b8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7bc:	b7e1                	j	784 <malloc+0x36>
      if(p->s.size == nunits)
 7be:	02e48c63          	beq	s1,a4,7f6 <malloc+0xa8>
        p->s.size -= nunits;
 7c2:	4137073b          	subw	a4,a4,s3
 7c6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7c8:	02071693          	sll	a3,a4,0x20
 7cc:	01c6d713          	srl	a4,a3,0x1c
 7d0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7d6:	00001717          	auipc	a4,0x1
 7da:	82a73523          	sd	a0,-2006(a4) # 1000 <freep>
      return (void*)(p + 1);
 7de:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7e2:	70e2                	ld	ra,56(sp)
 7e4:	7442                	ld	s0,48(sp)
 7e6:	74a2                	ld	s1,40(sp)
 7e8:	7902                	ld	s2,32(sp)
 7ea:	69e2                	ld	s3,24(sp)
 7ec:	6a42                	ld	s4,16(sp)
 7ee:	6aa2                	ld	s5,8(sp)
 7f0:	6b02                	ld	s6,0(sp)
 7f2:	6121                	add	sp,sp,64
 7f4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7f6:	6398                	ld	a4,0(a5)
 7f8:	e118                	sd	a4,0(a0)
 7fa:	bff1                	j	7d6 <malloc+0x88>
  hp->s.size = nu;
 7fc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 800:	0541                	add	a0,a0,16
 802:	00000097          	auipc	ra,0x0
 806:	eca080e7          	jalr	-310(ra) # 6cc <free>
  return freep;
 80a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 80e:	d971                	beqz	a0,7e2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 810:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 812:	4798                	lw	a4,8(a5)
 814:	fa9775e3          	bgeu	a4,s1,7be <malloc+0x70>
    if(p == freep)
 818:	00093703          	ld	a4,0(s2)
 81c:	853e                	mv	a0,a5
 81e:	fef719e3          	bne	a4,a5,810 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 822:	8552                	mv	a0,s4
 824:	00000097          	auipc	ra,0x0
 828:	b92080e7          	jalr	-1134(ra) # 3b6 <sbrk>
  if(p == (char*)-1)
 82c:	fd5518e3          	bne	a0,s5,7fc <malloc+0xae>
        return 0;
 830:	4501                	li	a0,0
 832:	bf45                	j	7e2 <malloc+0x94>
