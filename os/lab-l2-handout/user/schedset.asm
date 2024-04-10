
user/_schedset:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (argc != 2)
   8:	4789                	li	a5,2
   a:	00f50f63          	beq	a0,a5,28 <main+0x28>
    {
        printf("Usage: schedset [SCHED ID]\n");
   e:	00000517          	auipc	a0,0x0
  12:	7e250513          	addi	a0,a0,2018 # 7f0 <malloc+0xee>
  16:	00000097          	auipc	ra,0x0
  1a:	634080e7          	jalr	1588(ra) # 64a <printf>
        exit(1);
  1e:	4505                	li	a0,1
  20:	00000097          	auipc	ra,0x0
  24:	2aa080e7          	jalr	682(ra) # 2ca <exit>
    }
    int schedid = (*argv[1]) - '0';
  28:	659c                	ld	a5,8(a1)
  2a:	0007c503          	lbu	a0,0(a5)
    schedset(schedid);
  2e:	fd05051b          	addiw	a0,a0,-48
  32:	00000097          	auipc	ra,0x0
  36:	348080e7          	jalr	840(ra) # 37a <schedset>
    exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	28e080e7          	jalr	654(ra) # 2ca <exit>

0000000000000044 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  44:	1141                	addi	sp,sp,-16
  46:	e406                	sd	ra,8(sp)
  48:	e022                	sd	s0,0(sp)
  4a:	0800                	addi	s0,sp,16
  extern int main();
  main();
  4c:	00000097          	auipc	ra,0x0
  50:	fb4080e7          	jalr	-76(ra) # 0 <main>
  exit(0);
  54:	4501                	li	a0,0
  56:	00000097          	auipc	ra,0x0
  5a:	274080e7          	jalr	628(ra) # 2ca <exit>

000000000000005e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  64:	87aa                	mv	a5,a0
  66:	0585                	addi	a1,a1,1
  68:	0785                	addi	a5,a5,1
  6a:	fff5c703          	lbu	a4,-1(a1)
  6e:	fee78fa3          	sb	a4,-1(a5)
  72:	fb75                	bnez	a4,66 <strcpy+0x8>
    ;
  return os;
}
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  80:	00054783          	lbu	a5,0(a0)
  84:	cb91                	beqz	a5,98 <strcmp+0x1e>
  86:	0005c703          	lbu	a4,0(a1)
  8a:	00f71763          	bne	a4,a5,98 <strcmp+0x1e>
    p++, q++;
  8e:	0505                	addi	a0,a0,1
  90:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  92:	00054783          	lbu	a5,0(a0)
  96:	fbe5                	bnez	a5,86 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  98:	0005c503          	lbu	a0,0(a1)
}
  9c:	40a7853b          	subw	a0,a5,a0
  a0:	6422                	ld	s0,8(sp)
  a2:	0141                	addi	sp,sp,16
  a4:	8082                	ret

00000000000000a6 <strlen>:

uint
strlen(const char *s)
{
  a6:	1141                	addi	sp,sp,-16
  a8:	e422                	sd	s0,8(sp)
  aa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  ac:	00054783          	lbu	a5,0(a0)
  b0:	cf91                	beqz	a5,cc <strlen+0x26>
  b2:	0505                	addi	a0,a0,1
  b4:	87aa                	mv	a5,a0
  b6:	86be                	mv	a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	ff65                	bnez	a4,b6 <strlen+0x10>
  c0:	40a6853b          	subw	a0,a3,a0
  c4:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret
  for(n = 0; s[n]; n++)
  cc:	4501                	li	a0,0
  ce:	bfe5                	j	c6 <strlen+0x20>

00000000000000d0 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d6:	ca19                	beqz	a2,ec <memset+0x1c>
  d8:	87aa                	mv	a5,a0
  da:	1602                	slli	a2,a2,0x20
  dc:	9201                	srli	a2,a2,0x20
  de:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e6:	0785                	addi	a5,a5,1
  e8:	fee79de3          	bne	a5,a4,e2 <memset+0x12>
  }
  return dst;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret

00000000000000f2 <strchr>:

char*
strchr(const char *s, char c)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f8:	00054783          	lbu	a5,0(a0)
  fc:	cb99                	beqz	a5,112 <strchr+0x20>
    if(*s == c)
  fe:	00f58763          	beq	a1,a5,10c <strchr+0x1a>
  for(; *s; s++)
 102:	0505                	addi	a0,a0,1
 104:	00054783          	lbu	a5,0(a0)
 108:	fbfd                	bnez	a5,fe <strchr+0xc>
      return (char*)s;
  return 0;
 10a:	4501                	li	a0,0
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret
  return 0;
 112:	4501                	li	a0,0
 114:	bfe5                	j	10c <strchr+0x1a>

0000000000000116 <gets>:

char*
gets(char *buf, int max)
{
 116:	711d                	addi	sp,sp,-96
 118:	ec86                	sd	ra,88(sp)
 11a:	e8a2                	sd	s0,80(sp)
 11c:	e4a6                	sd	s1,72(sp)
 11e:	e0ca                	sd	s2,64(sp)
 120:	fc4e                	sd	s3,56(sp)
 122:	f852                	sd	s4,48(sp)
 124:	f456                	sd	s5,40(sp)
 126:	f05a                	sd	s6,32(sp)
 128:	ec5e                	sd	s7,24(sp)
 12a:	1080                	addi	s0,sp,96
 12c:	8baa                	mv	s7,a0
 12e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 130:	892a                	mv	s2,a0
 132:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 134:	4aa9                	li	s5,10
 136:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	2485                	addiw	s1,s1,1
 13c:	0344d863          	bge	s1,s4,16c <gets+0x56>
    cc = read(0, &c, 1);
 140:	4605                	li	a2,1
 142:	faf40593          	addi	a1,s0,-81
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	19a080e7          	jalr	410(ra) # 2e2 <read>
    if(cc < 1)
 150:	00a05e63          	blez	a0,16c <gets+0x56>
    buf[i++] = c;
 154:	faf44783          	lbu	a5,-81(s0)
 158:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 15c:	01578763          	beq	a5,s5,16a <gets+0x54>
 160:	0905                	addi	s2,s2,1
 162:	fd679be3          	bne	a5,s6,138 <gets+0x22>
  for(i=0; i+1 < max; ){
 166:	89a6                	mv	s3,s1
 168:	a011                	j	16c <gets+0x56>
 16a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 16c:	99de                	add	s3,s3,s7
 16e:	00098023          	sb	zero,0(s3)
  return buf;
}
 172:	855e                	mv	a0,s7
 174:	60e6                	ld	ra,88(sp)
 176:	6446                	ld	s0,80(sp)
 178:	64a6                	ld	s1,72(sp)
 17a:	6906                	ld	s2,64(sp)
 17c:	79e2                	ld	s3,56(sp)
 17e:	7a42                	ld	s4,48(sp)
 180:	7aa2                	ld	s5,40(sp)
 182:	7b02                	ld	s6,32(sp)
 184:	6be2                	ld	s7,24(sp)
 186:	6125                	addi	sp,sp,96
 188:	8082                	ret

000000000000018a <stat>:

int
stat(const char *n, struct stat *st)
{
 18a:	1101                	addi	sp,sp,-32
 18c:	ec06                	sd	ra,24(sp)
 18e:	e822                	sd	s0,16(sp)
 190:	e426                	sd	s1,8(sp)
 192:	e04a                	sd	s2,0(sp)
 194:	1000                	addi	s0,sp,32
 196:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 198:	4581                	li	a1,0
 19a:	00000097          	auipc	ra,0x0
 19e:	170080e7          	jalr	368(ra) # 30a <open>
  if(fd < 0)
 1a2:	02054563          	bltz	a0,1cc <stat+0x42>
 1a6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a8:	85ca                	mv	a1,s2
 1aa:	00000097          	auipc	ra,0x0
 1ae:	178080e7          	jalr	376(ra) # 322 <fstat>
 1b2:	892a                	mv	s2,a0
  close(fd);
 1b4:	8526                	mv	a0,s1
 1b6:	00000097          	auipc	ra,0x0
 1ba:	13c080e7          	jalr	316(ra) # 2f2 <close>
  return r;
}
 1be:	854a                	mv	a0,s2
 1c0:	60e2                	ld	ra,24(sp)
 1c2:	6442                	ld	s0,16(sp)
 1c4:	64a2                	ld	s1,8(sp)
 1c6:	6902                	ld	s2,0(sp)
 1c8:	6105                	addi	sp,sp,32
 1ca:	8082                	ret
    return -1;
 1cc:	597d                	li	s2,-1
 1ce:	bfc5                	j	1be <stat+0x34>

00000000000001d0 <atoi>:

int
atoi(const char *s)
{
 1d0:	1141                	addi	sp,sp,-16
 1d2:	e422                	sd	s0,8(sp)
 1d4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d6:	00054683          	lbu	a3,0(a0)
 1da:	fd06879b          	addiw	a5,a3,-48
 1de:	0ff7f793          	zext.b	a5,a5
 1e2:	4625                	li	a2,9
 1e4:	02f66863          	bltu	a2,a5,214 <atoi+0x44>
 1e8:	872a                	mv	a4,a0
  n = 0;
 1ea:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1ec:	0705                	addi	a4,a4,1
 1ee:	0025179b          	slliw	a5,a0,0x2
 1f2:	9fa9                	addw	a5,a5,a0
 1f4:	0017979b          	slliw	a5,a5,0x1
 1f8:	9fb5                	addw	a5,a5,a3
 1fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1fe:	00074683          	lbu	a3,0(a4)
 202:	fd06879b          	addiw	a5,a3,-48
 206:	0ff7f793          	zext.b	a5,a5
 20a:	fef671e3          	bgeu	a2,a5,1ec <atoi+0x1c>
  return n;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret
  n = 0;
 214:	4501                	li	a0,0
 216:	bfe5                	j	20e <atoi+0x3e>

0000000000000218 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 21e:	02b57463          	bgeu	a0,a1,246 <memmove+0x2e>
    while(n-- > 0)
 222:	00c05f63          	blez	a2,240 <memmove+0x28>
 226:	1602                	slli	a2,a2,0x20
 228:	9201                	srli	a2,a2,0x20
 22a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 22e:	872a                	mv	a4,a0
      *dst++ = *src++;
 230:	0585                	addi	a1,a1,1
 232:	0705                	addi	a4,a4,1
 234:	fff5c683          	lbu	a3,-1(a1)
 238:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 23c:	fee79ae3          	bne	a5,a4,230 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
    dst += n;
 246:	00c50733          	add	a4,a0,a2
    src += n;
 24a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 24c:	fec05ae3          	blez	a2,240 <memmove+0x28>
 250:	fff6079b          	addiw	a5,a2,-1
 254:	1782                	slli	a5,a5,0x20
 256:	9381                	srli	a5,a5,0x20
 258:	fff7c793          	not	a5,a5
 25c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 25e:	15fd                	addi	a1,a1,-1
 260:	177d                	addi	a4,a4,-1
 262:	0005c683          	lbu	a3,0(a1)
 266:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 26a:	fee79ae3          	bne	a5,a4,25e <memmove+0x46>
 26e:	bfc9                	j	240 <memmove+0x28>

0000000000000270 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 276:	ca05                	beqz	a2,2a6 <memcmp+0x36>
 278:	fff6069b          	addiw	a3,a2,-1
 27c:	1682                	slli	a3,a3,0x20
 27e:	9281                	srli	a3,a3,0x20
 280:	0685                	addi	a3,a3,1
 282:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 284:	00054783          	lbu	a5,0(a0)
 288:	0005c703          	lbu	a4,0(a1)
 28c:	00e79863          	bne	a5,a4,29c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 290:	0505                	addi	a0,a0,1
    p2++;
 292:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 294:	fed518e3          	bne	a0,a3,284 <memcmp+0x14>
  }
  return 0;
 298:	4501                	li	a0,0
 29a:	a019                	j	2a0 <memcmp+0x30>
      return *p1 - *p2;
 29c:	40e7853b          	subw	a0,a5,a4
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret
  return 0;
 2a6:	4501                	li	a0,0
 2a8:	bfe5                	j	2a0 <memcmp+0x30>

00000000000002aa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2b2:	00000097          	auipc	ra,0x0
 2b6:	f66080e7          	jalr	-154(ra) # 218 <memmove>
}
 2ba:	60a2                	ld	ra,8(sp)
 2bc:	6402                	ld	s0,0(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c2:	4885                	li	a7,1
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ca:	4889                	li	a7,2
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d2:	488d                	li	a7,3
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2da:	4891                	li	a7,4
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <read>:
.global read
read:
 li a7, SYS_read
 2e2:	4895                	li	a7,5
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <write>:
.global write
write:
 li a7, SYS_write
 2ea:	48c1                	li	a7,16
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <close>:
.global close
close:
 li a7, SYS_close
 2f2:	48d5                	li	a7,21
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fa:	4899                	li	a7,6
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <exec>:
.global exec
exec:
 li a7, SYS_exec
 302:	489d                	li	a7,7
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <open>:
.global open
open:
 li a7, SYS_open
 30a:	48bd                	li	a7,15
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 312:	48c5                	li	a7,17
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31a:	48c9                	li	a7,18
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 322:	48a1                	li	a7,8
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <link>:
.global link
link:
 li a7, SYS_link
 32a:	48cd                	li	a7,19
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 332:	48d1                	li	a7,20
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33a:	48a5                	li	a7,9
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <dup>:
.global dup
dup:
 li a7, SYS_dup
 342:	48a9                	li	a7,10
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34a:	48ad                	li	a7,11
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 352:	48b1                	li	a7,12
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 35a:	48b5                	li	a7,13
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 362:	48b9                	li	a7,14
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <ps>:
.global ps
ps:
 li a7, SYS_ps
 36a:	48d9                	li	a7,22
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 372:	48dd                	li	a7,23
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 37a:	48e1                	li	a7,24
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 382:	1101                	addi	sp,sp,-32
 384:	ec06                	sd	ra,24(sp)
 386:	e822                	sd	s0,16(sp)
 388:	1000                	addi	s0,sp,32
 38a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 38e:	4605                	li	a2,1
 390:	fef40593          	addi	a1,s0,-17
 394:	00000097          	auipc	ra,0x0
 398:	f56080e7          	jalr	-170(ra) # 2ea <write>
}
 39c:	60e2                	ld	ra,24(sp)
 39e:	6442                	ld	s0,16(sp)
 3a0:	6105                	addi	sp,sp,32
 3a2:	8082                	ret

00000000000003a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a4:	7139                	addi	sp,sp,-64
 3a6:	fc06                	sd	ra,56(sp)
 3a8:	f822                	sd	s0,48(sp)
 3aa:	f426                	sd	s1,40(sp)
 3ac:	f04a                	sd	s2,32(sp)
 3ae:	ec4e                	sd	s3,24(sp)
 3b0:	0080                	addi	s0,sp,64
 3b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b4:	c299                	beqz	a3,3ba <printint+0x16>
 3b6:	0805c963          	bltz	a1,448 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ba:	2581                	sext.w	a1,a1
  neg = 0;
 3bc:	4881                	li	a7,0
 3be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3c4:	2601                	sext.w	a2,a2
 3c6:	00000517          	auipc	a0,0x0
 3ca:	4aa50513          	addi	a0,a0,1194 # 870 <digits>
 3ce:	883a                	mv	a6,a4
 3d0:	2705                	addiw	a4,a4,1
 3d2:	02c5f7bb          	remuw	a5,a1,a2
 3d6:	1782                	slli	a5,a5,0x20
 3d8:	9381                	srli	a5,a5,0x20
 3da:	97aa                	add	a5,a5,a0
 3dc:	0007c783          	lbu	a5,0(a5)
 3e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3e4:	0005879b          	sext.w	a5,a1
 3e8:	02c5d5bb          	divuw	a1,a1,a2
 3ec:	0685                	addi	a3,a3,1
 3ee:	fec7f0e3          	bgeu	a5,a2,3ce <printint+0x2a>
  if(neg)
 3f2:	00088c63          	beqz	a7,40a <printint+0x66>
    buf[i++] = '-';
 3f6:	fd070793          	addi	a5,a4,-48
 3fa:	00878733          	add	a4,a5,s0
 3fe:	02d00793          	li	a5,45
 402:	fef70823          	sb	a5,-16(a4)
 406:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 40a:	02e05863          	blez	a4,43a <printint+0x96>
 40e:	fc040793          	addi	a5,s0,-64
 412:	00e78933          	add	s2,a5,a4
 416:	fff78993          	addi	s3,a5,-1
 41a:	99ba                	add	s3,s3,a4
 41c:	377d                	addiw	a4,a4,-1
 41e:	1702                	slli	a4,a4,0x20
 420:	9301                	srli	a4,a4,0x20
 422:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 426:	fff94583          	lbu	a1,-1(s2)
 42a:	8526                	mv	a0,s1
 42c:	00000097          	auipc	ra,0x0
 430:	f56080e7          	jalr	-170(ra) # 382 <putc>
  while(--i >= 0)
 434:	197d                	addi	s2,s2,-1
 436:	ff3918e3          	bne	s2,s3,426 <printint+0x82>
}
 43a:	70e2                	ld	ra,56(sp)
 43c:	7442                	ld	s0,48(sp)
 43e:	74a2                	ld	s1,40(sp)
 440:	7902                	ld	s2,32(sp)
 442:	69e2                	ld	s3,24(sp)
 444:	6121                	addi	sp,sp,64
 446:	8082                	ret
    x = -xx;
 448:	40b005bb          	negw	a1,a1
    neg = 1;
 44c:	4885                	li	a7,1
    x = -xx;
 44e:	bf85                	j	3be <printint+0x1a>

0000000000000450 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 450:	715d                	addi	sp,sp,-80
 452:	e486                	sd	ra,72(sp)
 454:	e0a2                	sd	s0,64(sp)
 456:	fc26                	sd	s1,56(sp)
 458:	f84a                	sd	s2,48(sp)
 45a:	f44e                	sd	s3,40(sp)
 45c:	f052                	sd	s4,32(sp)
 45e:	ec56                	sd	s5,24(sp)
 460:	e85a                	sd	s6,16(sp)
 462:	e45e                	sd	s7,8(sp)
 464:	e062                	sd	s8,0(sp)
 466:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 468:	0005c903          	lbu	s2,0(a1)
 46c:	18090c63          	beqz	s2,604 <vprintf+0x1b4>
 470:	8aaa                	mv	s5,a0
 472:	8bb2                	mv	s7,a2
 474:	00158493          	addi	s1,a1,1
  state = 0;
 478:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 47a:	02500a13          	li	s4,37
 47e:	4b55                	li	s6,21
 480:	a839                	j	49e <vprintf+0x4e>
        putc(fd, c);
 482:	85ca                	mv	a1,s2
 484:	8556                	mv	a0,s5
 486:	00000097          	auipc	ra,0x0
 48a:	efc080e7          	jalr	-260(ra) # 382 <putc>
 48e:	a019                	j	494 <vprintf+0x44>
    } else if(state == '%'){
 490:	01498d63          	beq	s3,s4,4aa <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 494:	0485                	addi	s1,s1,1
 496:	fff4c903          	lbu	s2,-1(s1)
 49a:	16090563          	beqz	s2,604 <vprintf+0x1b4>
    if(state == 0){
 49e:	fe0999e3          	bnez	s3,490 <vprintf+0x40>
      if(c == '%'){
 4a2:	ff4910e3          	bne	s2,s4,482 <vprintf+0x32>
        state = '%';
 4a6:	89d2                	mv	s3,s4
 4a8:	b7f5                	j	494 <vprintf+0x44>
      if(c == 'd'){
 4aa:	13490263          	beq	s2,s4,5ce <vprintf+0x17e>
 4ae:	f9d9079b          	addiw	a5,s2,-99
 4b2:	0ff7f793          	zext.b	a5,a5
 4b6:	12fb6563          	bltu	s6,a5,5e0 <vprintf+0x190>
 4ba:	f9d9079b          	addiw	a5,s2,-99
 4be:	0ff7f713          	zext.b	a4,a5
 4c2:	10eb6f63          	bltu	s6,a4,5e0 <vprintf+0x190>
 4c6:	00271793          	slli	a5,a4,0x2
 4ca:	00000717          	auipc	a4,0x0
 4ce:	34e70713          	addi	a4,a4,846 # 818 <malloc+0x116>
 4d2:	97ba                	add	a5,a5,a4
 4d4:	439c                	lw	a5,0(a5)
 4d6:	97ba                	add	a5,a5,a4
 4d8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4da:	008b8913          	addi	s2,s7,8
 4de:	4685                	li	a3,1
 4e0:	4629                	li	a2,10
 4e2:	000ba583          	lw	a1,0(s7)
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	ebc080e7          	jalr	-324(ra) # 3a4 <printint>
 4f0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4f2:	4981                	li	s3,0
 4f4:	b745                	j	494 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f6:	008b8913          	addi	s2,s7,8
 4fa:	4681                	li	a3,0
 4fc:	4629                	li	a2,10
 4fe:	000ba583          	lw	a1,0(s7)
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	ea0080e7          	jalr	-352(ra) # 3a4 <printint>
 50c:	8bca                	mv	s7,s2
      state = 0;
 50e:	4981                	li	s3,0
 510:	b751                	j	494 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 512:	008b8913          	addi	s2,s7,8
 516:	4681                	li	a3,0
 518:	4641                	li	a2,16
 51a:	000ba583          	lw	a1,0(s7)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	e84080e7          	jalr	-380(ra) # 3a4 <printint>
 528:	8bca                	mv	s7,s2
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b7a5                	j	494 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 52e:	008b8c13          	addi	s8,s7,8
 532:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 536:	03000593          	li	a1,48
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e46080e7          	jalr	-442(ra) # 382 <putc>
  putc(fd, 'x');
 544:	07800593          	li	a1,120
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	e38080e7          	jalr	-456(ra) # 382 <putc>
 552:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 554:	00000b97          	auipc	s7,0x0
 558:	31cb8b93          	addi	s7,s7,796 # 870 <digits>
 55c:	03c9d793          	srli	a5,s3,0x3c
 560:	97de                	add	a5,a5,s7
 562:	0007c583          	lbu	a1,0(a5)
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	e1a080e7          	jalr	-486(ra) # 382 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 570:	0992                	slli	s3,s3,0x4
 572:	397d                	addiw	s2,s2,-1
 574:	fe0914e3          	bnez	s2,55c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 578:	8be2                	mv	s7,s8
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bf21                	j	494 <vprintf+0x44>
        s = va_arg(ap, char*);
 57e:	008b8993          	addi	s3,s7,8
 582:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 586:	02090163          	beqz	s2,5a8 <vprintf+0x158>
        while(*s != 0){
 58a:	00094583          	lbu	a1,0(s2)
 58e:	c9a5                	beqz	a1,5fe <vprintf+0x1ae>
          putc(fd, *s);
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	df0080e7          	jalr	-528(ra) # 382 <putc>
          s++;
 59a:	0905                	addi	s2,s2,1
        while(*s != 0){
 59c:	00094583          	lbu	a1,0(s2)
 5a0:	f9e5                	bnez	a1,590 <vprintf+0x140>
        s = va_arg(ap, char*);
 5a2:	8bce                	mv	s7,s3
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b5fd                	j	494 <vprintf+0x44>
          s = "(null)";
 5a8:	00000917          	auipc	s2,0x0
 5ac:	26890913          	addi	s2,s2,616 # 810 <malloc+0x10e>
        while(*s != 0){
 5b0:	02800593          	li	a1,40
 5b4:	bff1                	j	590 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	000bc583          	lbu	a1,0(s7)
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	dc2080e7          	jalr	-574(ra) # 382 <putc>
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b5e1                	j	494 <vprintf+0x44>
        putc(fd, c);
 5ce:	02500593          	li	a1,37
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	dae080e7          	jalr	-594(ra) # 382 <putc>
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bd5d                	j	494 <vprintf+0x44>
        putc(fd, '%');
 5e0:	02500593          	li	a1,37
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	d9c080e7          	jalr	-612(ra) # 382 <putc>
        putc(fd, c);
 5ee:	85ca                	mv	a1,s2
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	d90080e7          	jalr	-624(ra) # 382 <putc>
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bd61                	j	494 <vprintf+0x44>
        s = va_arg(ap, char*);
 5fe:	8bce                	mv	s7,s3
      state = 0;
 600:	4981                	li	s3,0
 602:	bd49                	j	494 <vprintf+0x44>
    }
  }
}
 604:	60a6                	ld	ra,72(sp)
 606:	6406                	ld	s0,64(sp)
 608:	74e2                	ld	s1,56(sp)
 60a:	7942                	ld	s2,48(sp)
 60c:	79a2                	ld	s3,40(sp)
 60e:	7a02                	ld	s4,32(sp)
 610:	6ae2                	ld	s5,24(sp)
 612:	6b42                	ld	s6,16(sp)
 614:	6ba2                	ld	s7,8(sp)
 616:	6c02                	ld	s8,0(sp)
 618:	6161                	addi	sp,sp,80
 61a:	8082                	ret

000000000000061c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 61c:	715d                	addi	sp,sp,-80
 61e:	ec06                	sd	ra,24(sp)
 620:	e822                	sd	s0,16(sp)
 622:	1000                	addi	s0,sp,32
 624:	e010                	sd	a2,0(s0)
 626:	e414                	sd	a3,8(s0)
 628:	e818                	sd	a4,16(s0)
 62a:	ec1c                	sd	a5,24(s0)
 62c:	03043023          	sd	a6,32(s0)
 630:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 634:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 638:	8622                	mv	a2,s0
 63a:	00000097          	auipc	ra,0x0
 63e:	e16080e7          	jalr	-490(ra) # 450 <vprintf>
}
 642:	60e2                	ld	ra,24(sp)
 644:	6442                	ld	s0,16(sp)
 646:	6161                	addi	sp,sp,80
 648:	8082                	ret

000000000000064a <printf>:

void
printf(const char *fmt, ...)
{
 64a:	711d                	addi	sp,sp,-96
 64c:	ec06                	sd	ra,24(sp)
 64e:	e822                	sd	s0,16(sp)
 650:	1000                	addi	s0,sp,32
 652:	e40c                	sd	a1,8(s0)
 654:	e810                	sd	a2,16(s0)
 656:	ec14                	sd	a3,24(s0)
 658:	f018                	sd	a4,32(s0)
 65a:	f41c                	sd	a5,40(s0)
 65c:	03043823          	sd	a6,48(s0)
 660:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 664:	00840613          	addi	a2,s0,8
 668:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 66c:	85aa                	mv	a1,a0
 66e:	4505                	li	a0,1
 670:	00000097          	auipc	ra,0x0
 674:	de0080e7          	jalr	-544(ra) # 450 <vprintf>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6125                	addi	sp,sp,96
 67e:	8082                	ret

0000000000000680 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 680:	1141                	addi	sp,sp,-16
 682:	e422                	sd	s0,8(sp)
 684:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 686:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68a:	00001797          	auipc	a5,0x1
 68e:	9767b783          	ld	a5,-1674(a5) # 1000 <freep>
 692:	a02d                	j	6bc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 694:	4618                	lw	a4,8(a2)
 696:	9f2d                	addw	a4,a4,a1
 698:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 69c:	6398                	ld	a4,0(a5)
 69e:	6310                	ld	a2,0(a4)
 6a0:	a83d                	j	6de <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a2:	ff852703          	lw	a4,-8(a0)
 6a6:	9f31                	addw	a4,a4,a2
 6a8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6aa:	ff053683          	ld	a3,-16(a0)
 6ae:	a091                	j	6f2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b0:	6398                	ld	a4,0(a5)
 6b2:	00e7e463          	bltu	a5,a4,6ba <free+0x3a>
 6b6:	00e6ea63          	bltu	a3,a4,6ca <free+0x4a>
{
 6ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6bc:	fed7fae3          	bgeu	a5,a3,6b0 <free+0x30>
 6c0:	6398                	ld	a4,0(a5)
 6c2:	00e6e463          	bltu	a3,a4,6ca <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c6:	fee7eae3          	bltu	a5,a4,6ba <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ca:	ff852583          	lw	a1,-8(a0)
 6ce:	6390                	ld	a2,0(a5)
 6d0:	02059813          	slli	a6,a1,0x20
 6d4:	01c85713          	srli	a4,a6,0x1c
 6d8:	9736                	add	a4,a4,a3
 6da:	fae60de3          	beq	a2,a4,694 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e2:	4790                	lw	a2,8(a5)
 6e4:	02061593          	slli	a1,a2,0x20
 6e8:	01c5d713          	srli	a4,a1,0x1c
 6ec:	973e                	add	a4,a4,a5
 6ee:	fae68ae3          	beq	a3,a4,6a2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6f2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f4:	00001717          	auipc	a4,0x1
 6f8:	90f73623          	sd	a5,-1780(a4) # 1000 <freep>
}
 6fc:	6422                	ld	s0,8(sp)
 6fe:	0141                	addi	sp,sp,16
 700:	8082                	ret

0000000000000702 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 702:	7139                	addi	sp,sp,-64
 704:	fc06                	sd	ra,56(sp)
 706:	f822                	sd	s0,48(sp)
 708:	f426                	sd	s1,40(sp)
 70a:	f04a                	sd	s2,32(sp)
 70c:	ec4e                	sd	s3,24(sp)
 70e:	e852                	sd	s4,16(sp)
 710:	e456                	sd	s5,8(sp)
 712:	e05a                	sd	s6,0(sp)
 714:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 716:	02051493          	slli	s1,a0,0x20
 71a:	9081                	srli	s1,s1,0x20
 71c:	04bd                	addi	s1,s1,15
 71e:	8091                	srli	s1,s1,0x4
 720:	0014899b          	addiw	s3,s1,1
 724:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 726:	00001517          	auipc	a0,0x1
 72a:	8da53503          	ld	a0,-1830(a0) # 1000 <freep>
 72e:	c515                	beqz	a0,75a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 730:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 732:	4798                	lw	a4,8(a5)
 734:	02977f63          	bgeu	a4,s1,772 <malloc+0x70>
  if(nu < 4096)
 738:	8a4e                	mv	s4,s3
 73a:	0009871b          	sext.w	a4,s3
 73e:	6685                	lui	a3,0x1
 740:	00d77363          	bgeu	a4,a3,746 <malloc+0x44>
 744:	6a05                	lui	s4,0x1
 746:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74e:	00001917          	auipc	s2,0x1
 752:	8b290913          	addi	s2,s2,-1870 # 1000 <freep>
  if(p == (char*)-1)
 756:	5afd                	li	s5,-1
 758:	a895                	j	7cc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 75a:	00001797          	auipc	a5,0x1
 75e:	8b678793          	addi	a5,a5,-1866 # 1010 <base>
 762:	00001717          	auipc	a4,0x1
 766:	88f73f23          	sd	a5,-1890(a4) # 1000 <freep>
 76a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 770:	b7e1                	j	738 <malloc+0x36>
      if(p->s.size == nunits)
 772:	02e48c63          	beq	s1,a4,7aa <malloc+0xa8>
        p->s.size -= nunits;
 776:	4137073b          	subw	a4,a4,s3
 77a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 77c:	02071693          	slli	a3,a4,0x20
 780:	01c6d713          	srli	a4,a3,0x1c
 784:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 786:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 78a:	00001717          	auipc	a4,0x1
 78e:	86a73b23          	sd	a0,-1930(a4) # 1000 <freep>
      return (void*)(p + 1);
 792:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 796:	70e2                	ld	ra,56(sp)
 798:	7442                	ld	s0,48(sp)
 79a:	74a2                	ld	s1,40(sp)
 79c:	7902                	ld	s2,32(sp)
 79e:	69e2                	ld	s3,24(sp)
 7a0:	6a42                	ld	s4,16(sp)
 7a2:	6aa2                	ld	s5,8(sp)
 7a4:	6b02                	ld	s6,0(sp)
 7a6:	6121                	addi	sp,sp,64
 7a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7aa:	6398                	ld	a4,0(a5)
 7ac:	e118                	sd	a4,0(a0)
 7ae:	bff1                	j	78a <malloc+0x88>
  hp->s.size = nu;
 7b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b4:	0541                	addi	a0,a0,16
 7b6:	00000097          	auipc	ra,0x0
 7ba:	eca080e7          	jalr	-310(ra) # 680 <free>
  return freep;
 7be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c2:	d971                	beqz	a0,796 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c6:	4798                	lw	a4,8(a5)
 7c8:	fa9775e3          	bgeu	a4,s1,772 <malloc+0x70>
    if(p == freep)
 7cc:	00093703          	ld	a4,0(s2)
 7d0:	853e                	mv	a0,a5
 7d2:	fef719e3          	bne	a4,a5,7c4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7d6:	8552                	mv	a0,s4
 7d8:	00000097          	auipc	ra,0x0
 7dc:	b7a080e7          	jalr	-1158(ra) # 352 <sbrk>
  if(p == (char*)-1)
 7e0:	fd5518e3          	bne	a0,s5,7b0 <malloc+0xae>
        return 0;
 7e4:	4501                	li	a0,0
 7e6:	bf45                	j	796 <malloc+0x94>
