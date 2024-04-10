
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if (argc < 2)
   c:	4785                	li	a5,1
   e:	02a7db63          	bge	a5,a0,44 <main+0x44>
  12:	84ae                	mv	s1,a1
        printf("Time took 0 ticks\n");
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
        exit(1);
    }

    int startticks = uptime();
  14:	00000097          	auipc	ra,0x0
  18:	3be080e7          	jalr	958(ra) # 3d2 <uptime>
  1c:	892a                	mv	s2,a0

    // we now start the program in a separate process:
    int uutPid = fork();
  1e:	00000097          	auipc	ra,0x0
  22:	314080e7          	jalr	788(ra) # 332 <fork>

    // check if fork worked:
    if (uutPid < 0)
  26:	04054463          	bltz	a0,6e <main+0x6e>
    {
        printf("fork failed... couldn't start %s", argv[1]);
        exit(1);
    }

    if (uutPid == 0)
  2a:	e125                	bnez	a0,8a <main+0x8a>
    {
        // we are the unit under test part of the program - execute the program immediately
        exec(argv[1], argv + 1); // pass rest of the command line to the executable as args
  2c:	00848593          	addi	a1,s1,8
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	340080e7          	jalr	832(ra) # 372 <exec>
        // wait for the uut to finish
        wait(0);
        int endticks = uptime();
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
    }
    exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	2fe080e7          	jalr	766(ra) # 33a <exit>
        printf("Time took 0 ticks\n");
  44:	00001517          	auipc	a0,0x1
  48:	81c50513          	addi	a0,a0,-2020 # 860 <malloc+0xee>
  4c:	00000097          	auipc	ra,0x0
  50:	66e080e7          	jalr	1646(ra) # 6ba <printf>
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
  54:	00001517          	auipc	a0,0x1
  58:	82450513          	addi	a0,a0,-2012 # 878 <malloc+0x106>
  5c:	00000097          	auipc	ra,0x0
  60:	65e080e7          	jalr	1630(ra) # 6ba <printf>
        exit(1);
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	2d4080e7          	jalr	724(ra) # 33a <exit>
        printf("fork failed... couldn't start %s", argv[1]);
  6e:	648c                	ld	a1,8(s1)
  70:	00001517          	auipc	a0,0x1
  74:	83050513          	addi	a0,a0,-2000 # 8a0 <malloc+0x12e>
  78:	00000097          	auipc	ra,0x0
  7c:	642080e7          	jalr	1602(ra) # 6ba <printf>
        exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	2b8080e7          	jalr	696(ra) # 33a <exit>
        wait(0);
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	2b6080e7          	jalr	694(ra) # 342 <wait>
        int endticks = uptime();
  94:	00000097          	auipc	ra,0x0
  98:	33e080e7          	jalr	830(ra) # 3d2 <uptime>
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
  9c:	4125063b          	subw	a2,a0,s2
  a0:	648c                	ld	a1,8(s1)
  a2:	00001517          	auipc	a0,0x1
  a6:	82650513          	addi	a0,a0,-2010 # 8c8 <malloc+0x156>
  aa:	00000097          	auipc	ra,0x0
  ae:	610080e7          	jalr	1552(ra) # 6ba <printf>
  b2:	b761                	j	3a <main+0x3a>

00000000000000b4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
  bc:	00000097          	auipc	ra,0x0
  c0:	f44080e7          	jalr	-188(ra) # 0 <main>
  exit(0);
  c4:	4501                	li	a0,0
  c6:	00000097          	auipc	ra,0x0
  ca:	274080e7          	jalr	628(ra) # 33a <exit>

00000000000000ce <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d4:	87aa                	mv	a5,a0
  d6:	0585                	addi	a1,a1,1
  d8:	0785                	addi	a5,a5,1
  da:	fff5c703          	lbu	a4,-1(a1)
  de:	fee78fa3          	sb	a4,-1(a5)
  e2:	fb75                	bnez	a4,d6 <strcpy+0x8>
    ;
  return os;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cb91                	beqz	a5,108 <strcmp+0x1e>
  f6:	0005c703          	lbu	a4,0(a1)
  fa:	00f71763          	bne	a4,a5,108 <strcmp+0x1e>
    p++, q++;
  fe:	0505                	addi	a0,a0,1
 100:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 102:	00054783          	lbu	a5,0(a0)
 106:	fbe5                	bnez	a5,f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 108:	0005c503          	lbu	a0,0(a1)
}
 10c:	40a7853b          	subw	a0,a5,a0
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strlen>:

uint
strlen(const char *s)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cf91                	beqz	a5,13c <strlen+0x26>
 122:	0505                	addi	a0,a0,1
 124:	87aa                	mv	a5,a0
 126:	86be                	mv	a3,a5
 128:	0785                	addi	a5,a5,1
 12a:	fff7c703          	lbu	a4,-1(a5)
 12e:	ff65                	bnez	a4,126 <strlen+0x10>
 130:	40a6853b          	subw	a0,a3,a0
 134:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  for(n = 0; s[n]; n++)
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strlen+0x20>

0000000000000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 146:	ca19                	beqz	a2,15c <memset+0x1c>
 148:	87aa                	mv	a5,a0
 14a:	1602                	slli	a2,a2,0x20
 14c:	9201                	srli	a2,a2,0x20
 14e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 152:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 156:	0785                	addi	a5,a5,1
 158:	fee79de3          	bne	a5,a4,152 <memset+0x12>
  }
  return dst;
}
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strchr>:

char*
strchr(const char *s, char c)
{
 162:	1141                	addi	sp,sp,-16
 164:	e422                	sd	s0,8(sp)
 166:	0800                	addi	s0,sp,16
  for(; *s; s++)
 168:	00054783          	lbu	a5,0(a0)
 16c:	cb99                	beqz	a5,182 <strchr+0x20>
    if(*s == c)
 16e:	00f58763          	beq	a1,a5,17c <strchr+0x1a>
  for(; *s; s++)
 172:	0505                	addi	a0,a0,1
 174:	00054783          	lbu	a5,0(a0)
 178:	fbfd                	bnez	a5,16e <strchr+0xc>
      return (char*)s;
  return 0;
 17a:	4501                	li	a0,0
}
 17c:	6422                	ld	s0,8(sp)
 17e:	0141                	addi	sp,sp,16
 180:	8082                	ret
  return 0;
 182:	4501                	li	a0,0
 184:	bfe5                	j	17c <strchr+0x1a>

0000000000000186 <gets>:

char*
gets(char *buf, int max)
{
 186:	711d                	addi	sp,sp,-96
 188:	ec86                	sd	ra,88(sp)
 18a:	e8a2                	sd	s0,80(sp)
 18c:	e4a6                	sd	s1,72(sp)
 18e:	e0ca                	sd	s2,64(sp)
 190:	fc4e                	sd	s3,56(sp)
 192:	f852                	sd	s4,48(sp)
 194:	f456                	sd	s5,40(sp)
 196:	f05a                	sd	s6,32(sp)
 198:	ec5e                	sd	s7,24(sp)
 19a:	1080                	addi	s0,sp,96
 19c:	8baa                	mv	s7,a0
 19e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a0:	892a                	mv	s2,a0
 1a2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a4:	4aa9                	li	s5,10
 1a6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1a8:	89a6                	mv	s3,s1
 1aa:	2485                	addiw	s1,s1,1
 1ac:	0344d863          	bge	s1,s4,1dc <gets+0x56>
    cc = read(0, &c, 1);
 1b0:	4605                	li	a2,1
 1b2:	faf40593          	addi	a1,s0,-81
 1b6:	4501                	li	a0,0
 1b8:	00000097          	auipc	ra,0x0
 1bc:	19a080e7          	jalr	410(ra) # 352 <read>
    if(cc < 1)
 1c0:	00a05e63          	blez	a0,1dc <gets+0x56>
    buf[i++] = c;
 1c4:	faf44783          	lbu	a5,-81(s0)
 1c8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1cc:	01578763          	beq	a5,s5,1da <gets+0x54>
 1d0:	0905                	addi	s2,s2,1
 1d2:	fd679be3          	bne	a5,s6,1a8 <gets+0x22>
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	a011                	j	1dc <gets+0x56>
 1da:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1dc:	99de                	add	s3,s3,s7
 1de:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e2:	855e                	mv	a0,s7
 1e4:	60e6                	ld	ra,88(sp)
 1e6:	6446                	ld	s0,80(sp)
 1e8:	64a6                	ld	s1,72(sp)
 1ea:	6906                	ld	s2,64(sp)
 1ec:	79e2                	ld	s3,56(sp)
 1ee:	7a42                	ld	s4,48(sp)
 1f0:	7aa2                	ld	s5,40(sp)
 1f2:	7b02                	ld	s6,32(sp)
 1f4:	6be2                	ld	s7,24(sp)
 1f6:	6125                	addi	sp,sp,96
 1f8:	8082                	ret

00000000000001fa <stat>:

int
stat(const char *n, struct stat *st)
{
 1fa:	1101                	addi	sp,sp,-32
 1fc:	ec06                	sd	ra,24(sp)
 1fe:	e822                	sd	s0,16(sp)
 200:	e426                	sd	s1,8(sp)
 202:	e04a                	sd	s2,0(sp)
 204:	1000                	addi	s0,sp,32
 206:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 208:	4581                	li	a1,0
 20a:	00000097          	auipc	ra,0x0
 20e:	170080e7          	jalr	368(ra) # 37a <open>
  if(fd < 0)
 212:	02054563          	bltz	a0,23c <stat+0x42>
 216:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 218:	85ca                	mv	a1,s2
 21a:	00000097          	auipc	ra,0x0
 21e:	178080e7          	jalr	376(ra) # 392 <fstat>
 222:	892a                	mv	s2,a0
  close(fd);
 224:	8526                	mv	a0,s1
 226:	00000097          	auipc	ra,0x0
 22a:	13c080e7          	jalr	316(ra) # 362 <close>
  return r;
}
 22e:	854a                	mv	a0,s2
 230:	60e2                	ld	ra,24(sp)
 232:	6442                	ld	s0,16(sp)
 234:	64a2                	ld	s1,8(sp)
 236:	6902                	ld	s2,0(sp)
 238:	6105                	addi	sp,sp,32
 23a:	8082                	ret
    return -1;
 23c:	597d                	li	s2,-1
 23e:	bfc5                	j	22e <stat+0x34>

0000000000000240 <atoi>:

int
atoi(const char *s)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 246:	00054683          	lbu	a3,0(a0)
 24a:	fd06879b          	addiw	a5,a3,-48
 24e:	0ff7f793          	zext.b	a5,a5
 252:	4625                	li	a2,9
 254:	02f66863          	bltu	a2,a5,284 <atoi+0x44>
 258:	872a                	mv	a4,a0
  n = 0;
 25a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 25c:	0705                	addi	a4,a4,1
 25e:	0025179b          	slliw	a5,a0,0x2
 262:	9fa9                	addw	a5,a5,a0
 264:	0017979b          	slliw	a5,a5,0x1
 268:	9fb5                	addw	a5,a5,a3
 26a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 26e:	00074683          	lbu	a3,0(a4)
 272:	fd06879b          	addiw	a5,a3,-48
 276:	0ff7f793          	zext.b	a5,a5
 27a:	fef671e3          	bgeu	a2,a5,25c <atoi+0x1c>
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  n = 0;
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <atoi+0x3e>

0000000000000288 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 28e:	02b57463          	bgeu	a0,a1,2b6 <memmove+0x2e>
    while(n-- > 0)
 292:	00c05f63          	blez	a2,2b0 <memmove+0x28>
 296:	1602                	slli	a2,a2,0x20
 298:	9201                	srli	a2,a2,0x20
 29a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 29e:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a0:	0585                	addi	a1,a1,1
 2a2:	0705                	addi	a4,a4,1
 2a4:	fff5c683          	lbu	a3,-1(a1)
 2a8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ac:	fee79ae3          	bne	a5,a4,2a0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
    dst += n;
 2b6:	00c50733          	add	a4,a0,a2
    src += n;
 2ba:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2bc:	fec05ae3          	blez	a2,2b0 <memmove+0x28>
 2c0:	fff6079b          	addiw	a5,a2,-1
 2c4:	1782                	slli	a5,a5,0x20
 2c6:	9381                	srli	a5,a5,0x20
 2c8:	fff7c793          	not	a5,a5
 2cc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ce:	15fd                	addi	a1,a1,-1
 2d0:	177d                	addi	a4,a4,-1
 2d2:	0005c683          	lbu	a3,0(a1)
 2d6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2da:	fee79ae3          	bne	a5,a4,2ce <memmove+0x46>
 2de:	bfc9                	j	2b0 <memmove+0x28>

00000000000002e0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e6:	ca05                	beqz	a2,316 <memcmp+0x36>
 2e8:	fff6069b          	addiw	a3,a2,-1
 2ec:	1682                	slli	a3,a3,0x20
 2ee:	9281                	srli	a3,a3,0x20
 2f0:	0685                	addi	a3,a3,1
 2f2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f4:	00054783          	lbu	a5,0(a0)
 2f8:	0005c703          	lbu	a4,0(a1)
 2fc:	00e79863          	bne	a5,a4,30c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 300:	0505                	addi	a0,a0,1
    p2++;
 302:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 304:	fed518e3          	bne	a0,a3,2f4 <memcmp+0x14>
  }
  return 0;
 308:	4501                	li	a0,0
 30a:	a019                	j	310 <memcmp+0x30>
      return *p1 - *p2;
 30c:	40e7853b          	subw	a0,a5,a4
}
 310:	6422                	ld	s0,8(sp)
 312:	0141                	addi	sp,sp,16
 314:	8082                	ret
  return 0;
 316:	4501                	li	a0,0
 318:	bfe5                	j	310 <memcmp+0x30>

000000000000031a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e406                	sd	ra,8(sp)
 31e:	e022                	sd	s0,0(sp)
 320:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 322:	00000097          	auipc	ra,0x0
 326:	f66080e7          	jalr	-154(ra) # 288 <memmove>
}
 32a:	60a2                	ld	ra,8(sp)
 32c:	6402                	ld	s0,0(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 332:	4885                	li	a7,1
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <exit>:
.global exit
exit:
 li a7, SYS_exit
 33a:	4889                	li	a7,2
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <wait>:
.global wait
wait:
 li a7, SYS_wait
 342:	488d                	li	a7,3
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34a:	4891                	li	a7,4
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <read>:
.global read
read:
 li a7, SYS_read
 352:	4895                	li	a7,5
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <write>:
.global write
write:
 li a7, SYS_write
 35a:	48c1                	li	a7,16
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <close>:
.global close
close:
 li a7, SYS_close
 362:	48d5                	li	a7,21
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <kill>:
.global kill
kill:
 li a7, SYS_kill
 36a:	4899                	li	a7,6
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <exec>:
.global exec
exec:
 li a7, SYS_exec
 372:	489d                	li	a7,7
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <open>:
.global open
open:
 li a7, SYS_open
 37a:	48bd                	li	a7,15
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 382:	48c5                	li	a7,17
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38a:	48c9                	li	a7,18
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 392:	48a1                	li	a7,8
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <link>:
.global link
link:
 li a7, SYS_link
 39a:	48cd                	li	a7,19
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a2:	48d1                	li	a7,20
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3aa:	48a5                	li	a7,9
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b2:	48a9                	li	a7,10
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3ba:	48ad                	li	a7,11
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c2:	48b1                	li	a7,12
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ca:	48b5                	li	a7,13
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d2:	48b9                	li	a7,14
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <ps>:
.global ps
ps:
 li a7, SYS_ps
 3da:	48d9                	li	a7,22
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 3e2:	48dd                	li	a7,23
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 3ea:	48e1                	li	a7,24
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f2:	1101                	addi	sp,sp,-32
 3f4:	ec06                	sd	ra,24(sp)
 3f6:	e822                	sd	s0,16(sp)
 3f8:	1000                	addi	s0,sp,32
 3fa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fe:	4605                	li	a2,1
 400:	fef40593          	addi	a1,s0,-17
 404:	00000097          	auipc	ra,0x0
 408:	f56080e7          	jalr	-170(ra) # 35a <write>
}
 40c:	60e2                	ld	ra,24(sp)
 40e:	6442                	ld	s0,16(sp)
 410:	6105                	addi	sp,sp,32
 412:	8082                	ret

0000000000000414 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 414:	7139                	addi	sp,sp,-64
 416:	fc06                	sd	ra,56(sp)
 418:	f822                	sd	s0,48(sp)
 41a:	f426                	sd	s1,40(sp)
 41c:	f04a                	sd	s2,32(sp)
 41e:	ec4e                	sd	s3,24(sp)
 420:	0080                	addi	s0,sp,64
 422:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 424:	c299                	beqz	a3,42a <printint+0x16>
 426:	0805c963          	bltz	a1,4b8 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 42a:	2581                	sext.w	a1,a1
  neg = 0;
 42c:	4881                	li	a7,0
 42e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 432:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 434:	2601                	sext.w	a2,a2
 436:	00000517          	auipc	a0,0x0
 43a:	51250513          	addi	a0,a0,1298 # 948 <digits>
 43e:	883a                	mv	a6,a4
 440:	2705                	addiw	a4,a4,1
 442:	02c5f7bb          	remuw	a5,a1,a2
 446:	1782                	slli	a5,a5,0x20
 448:	9381                	srli	a5,a5,0x20
 44a:	97aa                	add	a5,a5,a0
 44c:	0007c783          	lbu	a5,0(a5)
 450:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 454:	0005879b          	sext.w	a5,a1
 458:	02c5d5bb          	divuw	a1,a1,a2
 45c:	0685                	addi	a3,a3,1
 45e:	fec7f0e3          	bgeu	a5,a2,43e <printint+0x2a>
  if(neg)
 462:	00088c63          	beqz	a7,47a <printint+0x66>
    buf[i++] = '-';
 466:	fd070793          	addi	a5,a4,-48
 46a:	00878733          	add	a4,a5,s0
 46e:	02d00793          	li	a5,45
 472:	fef70823          	sb	a5,-16(a4)
 476:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 47a:	02e05863          	blez	a4,4aa <printint+0x96>
 47e:	fc040793          	addi	a5,s0,-64
 482:	00e78933          	add	s2,a5,a4
 486:	fff78993          	addi	s3,a5,-1
 48a:	99ba                	add	s3,s3,a4
 48c:	377d                	addiw	a4,a4,-1
 48e:	1702                	slli	a4,a4,0x20
 490:	9301                	srli	a4,a4,0x20
 492:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 496:	fff94583          	lbu	a1,-1(s2)
 49a:	8526                	mv	a0,s1
 49c:	00000097          	auipc	ra,0x0
 4a0:	f56080e7          	jalr	-170(ra) # 3f2 <putc>
  while(--i >= 0)
 4a4:	197d                	addi	s2,s2,-1
 4a6:	ff3918e3          	bne	s2,s3,496 <printint+0x82>
}
 4aa:	70e2                	ld	ra,56(sp)
 4ac:	7442                	ld	s0,48(sp)
 4ae:	74a2                	ld	s1,40(sp)
 4b0:	7902                	ld	s2,32(sp)
 4b2:	69e2                	ld	s3,24(sp)
 4b4:	6121                	addi	sp,sp,64
 4b6:	8082                	ret
    x = -xx;
 4b8:	40b005bb          	negw	a1,a1
    neg = 1;
 4bc:	4885                	li	a7,1
    x = -xx;
 4be:	bf85                	j	42e <printint+0x1a>

00000000000004c0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4c0:	715d                	addi	sp,sp,-80
 4c2:	e486                	sd	ra,72(sp)
 4c4:	e0a2                	sd	s0,64(sp)
 4c6:	fc26                	sd	s1,56(sp)
 4c8:	f84a                	sd	s2,48(sp)
 4ca:	f44e                	sd	s3,40(sp)
 4cc:	f052                	sd	s4,32(sp)
 4ce:	ec56                	sd	s5,24(sp)
 4d0:	e85a                	sd	s6,16(sp)
 4d2:	e45e                	sd	s7,8(sp)
 4d4:	e062                	sd	s8,0(sp)
 4d6:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d8:	0005c903          	lbu	s2,0(a1)
 4dc:	18090c63          	beqz	s2,674 <vprintf+0x1b4>
 4e0:	8aaa                	mv	s5,a0
 4e2:	8bb2                	mv	s7,a2
 4e4:	00158493          	addi	s1,a1,1
  state = 0;
 4e8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ea:	02500a13          	li	s4,37
 4ee:	4b55                	li	s6,21
 4f0:	a839                	j	50e <vprintf+0x4e>
        putc(fd, c);
 4f2:	85ca                	mv	a1,s2
 4f4:	8556                	mv	a0,s5
 4f6:	00000097          	auipc	ra,0x0
 4fa:	efc080e7          	jalr	-260(ra) # 3f2 <putc>
 4fe:	a019                	j	504 <vprintf+0x44>
    } else if(state == '%'){
 500:	01498d63          	beq	s3,s4,51a <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 504:	0485                	addi	s1,s1,1
 506:	fff4c903          	lbu	s2,-1(s1)
 50a:	16090563          	beqz	s2,674 <vprintf+0x1b4>
    if(state == 0){
 50e:	fe0999e3          	bnez	s3,500 <vprintf+0x40>
      if(c == '%'){
 512:	ff4910e3          	bne	s2,s4,4f2 <vprintf+0x32>
        state = '%';
 516:	89d2                	mv	s3,s4
 518:	b7f5                	j	504 <vprintf+0x44>
      if(c == 'd'){
 51a:	13490263          	beq	s2,s4,63e <vprintf+0x17e>
 51e:	f9d9079b          	addiw	a5,s2,-99
 522:	0ff7f793          	zext.b	a5,a5
 526:	12fb6563          	bltu	s6,a5,650 <vprintf+0x190>
 52a:	f9d9079b          	addiw	a5,s2,-99
 52e:	0ff7f713          	zext.b	a4,a5
 532:	10eb6f63          	bltu	s6,a4,650 <vprintf+0x190>
 536:	00271793          	slli	a5,a4,0x2
 53a:	00000717          	auipc	a4,0x0
 53e:	3b670713          	addi	a4,a4,950 # 8f0 <malloc+0x17e>
 542:	97ba                	add	a5,a5,a4
 544:	439c                	lw	a5,0(a5)
 546:	97ba                	add	a5,a5,a4
 548:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4685                	li	a3,1
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ebc080e7          	jalr	-324(ra) # 414 <printint>
 560:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 562:	4981                	li	s3,0
 564:	b745                	j	504 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 566:	008b8913          	addi	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4629                	li	a2,10
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	ea0080e7          	jalr	-352(ra) # 414 <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b751                	j	504 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4641                	li	a2,16
 58a:	000ba583          	lw	a1,0(s7)
 58e:	8556                	mv	a0,s5
 590:	00000097          	auipc	ra,0x0
 594:	e84080e7          	jalr	-380(ra) # 414 <printint>
 598:	8bca                	mv	s7,s2
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b7a5                	j	504 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 59e:	008b8c13          	addi	s8,s7,8
 5a2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5a6:	03000593          	li	a1,48
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	e46080e7          	jalr	-442(ra) # 3f2 <putc>
  putc(fd, 'x');
 5b4:	07800593          	li	a1,120
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e38080e7          	jalr	-456(ra) # 3f2 <putc>
 5c2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5c4:	00000b97          	auipc	s7,0x0
 5c8:	384b8b93          	addi	s7,s7,900 # 948 <digits>
 5cc:	03c9d793          	srli	a5,s3,0x3c
 5d0:	97de                	add	a5,a5,s7
 5d2:	0007c583          	lbu	a1,0(a5)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e1a080e7          	jalr	-486(ra) # 3f2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e0:	0992                	slli	s3,s3,0x4
 5e2:	397d                	addiw	s2,s2,-1
 5e4:	fe0914e3          	bnez	s2,5cc <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5e8:	8be2                	mv	s7,s8
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bf21                	j	504 <vprintf+0x44>
        s = va_arg(ap, char*);
 5ee:	008b8993          	addi	s3,s7,8
 5f2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5f6:	02090163          	beqz	s2,618 <vprintf+0x158>
        while(*s != 0){
 5fa:	00094583          	lbu	a1,0(s2)
 5fe:	c9a5                	beqz	a1,66e <vprintf+0x1ae>
          putc(fd, *s);
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	df0080e7          	jalr	-528(ra) # 3f2 <putc>
          s++;
 60a:	0905                	addi	s2,s2,1
        while(*s != 0){
 60c:	00094583          	lbu	a1,0(s2)
 610:	f9e5                	bnez	a1,600 <vprintf+0x140>
        s = va_arg(ap, char*);
 612:	8bce                	mv	s7,s3
      state = 0;
 614:	4981                	li	s3,0
 616:	b5fd                	j	504 <vprintf+0x44>
          s = "(null)";
 618:	00000917          	auipc	s2,0x0
 61c:	2d090913          	addi	s2,s2,720 # 8e8 <malloc+0x176>
        while(*s != 0){
 620:	02800593          	li	a1,40
 624:	bff1                	j	600 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 626:	008b8913          	addi	s2,s7,8
 62a:	000bc583          	lbu	a1,0(s7)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	dc2080e7          	jalr	-574(ra) # 3f2 <putc>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b5e1                	j	504 <vprintf+0x44>
        putc(fd, c);
 63e:	02500593          	li	a1,37
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	dae080e7          	jalr	-594(ra) # 3f2 <putc>
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bd5d                	j	504 <vprintf+0x44>
        putc(fd, '%');
 650:	02500593          	li	a1,37
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	d9c080e7          	jalr	-612(ra) # 3f2 <putc>
        putc(fd, c);
 65e:	85ca                	mv	a1,s2
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	d90080e7          	jalr	-624(ra) # 3f2 <putc>
      state = 0;
 66a:	4981                	li	s3,0
 66c:	bd61                	j	504 <vprintf+0x44>
        s = va_arg(ap, char*);
 66e:	8bce                	mv	s7,s3
      state = 0;
 670:	4981                	li	s3,0
 672:	bd49                	j	504 <vprintf+0x44>
    }
  }
}
 674:	60a6                	ld	ra,72(sp)
 676:	6406                	ld	s0,64(sp)
 678:	74e2                	ld	s1,56(sp)
 67a:	7942                	ld	s2,48(sp)
 67c:	79a2                	ld	s3,40(sp)
 67e:	7a02                	ld	s4,32(sp)
 680:	6ae2                	ld	s5,24(sp)
 682:	6b42                	ld	s6,16(sp)
 684:	6ba2                	ld	s7,8(sp)
 686:	6c02                	ld	s8,0(sp)
 688:	6161                	addi	sp,sp,80
 68a:	8082                	ret

000000000000068c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 68c:	715d                	addi	sp,sp,-80
 68e:	ec06                	sd	ra,24(sp)
 690:	e822                	sd	s0,16(sp)
 692:	1000                	addi	s0,sp,32
 694:	e010                	sd	a2,0(s0)
 696:	e414                	sd	a3,8(s0)
 698:	e818                	sd	a4,16(s0)
 69a:	ec1c                	sd	a5,24(s0)
 69c:	03043023          	sd	a6,32(s0)
 6a0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6a8:	8622                	mv	a2,s0
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e16080e7          	jalr	-490(ra) # 4c0 <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6161                	addi	sp,sp,80
 6b8:	8082                	ret

00000000000006ba <printf>:

void
printf(const char *fmt, ...)
{
 6ba:	711d                	addi	sp,sp,-96
 6bc:	ec06                	sd	ra,24(sp)
 6be:	e822                	sd	s0,16(sp)
 6c0:	1000                	addi	s0,sp,32
 6c2:	e40c                	sd	a1,8(s0)
 6c4:	e810                	sd	a2,16(s0)
 6c6:	ec14                	sd	a3,24(s0)
 6c8:	f018                	sd	a4,32(s0)
 6ca:	f41c                	sd	a5,40(s0)
 6cc:	03043823          	sd	a6,48(s0)
 6d0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d4:	00840613          	addi	a2,s0,8
 6d8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6dc:	85aa                	mv	a1,a0
 6de:	4505                	li	a0,1
 6e0:	00000097          	auipc	ra,0x0
 6e4:	de0080e7          	jalr	-544(ra) # 4c0 <vprintf>
}
 6e8:	60e2                	ld	ra,24(sp)
 6ea:	6442                	ld	s0,16(sp)
 6ec:	6125                	addi	sp,sp,96
 6ee:	8082                	ret

00000000000006f0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f0:	1141                	addi	sp,sp,-16
 6f2:	e422                	sd	s0,8(sp)
 6f4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fa:	00001797          	auipc	a5,0x1
 6fe:	9067b783          	ld	a5,-1786(a5) # 1000 <freep>
 702:	a02d                	j	72c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 704:	4618                	lw	a4,8(a2)
 706:	9f2d                	addw	a4,a4,a1
 708:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	6398                	ld	a4,0(a5)
 70e:	6310                	ld	a2,0(a4)
 710:	a83d                	j	74e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 712:	ff852703          	lw	a4,-8(a0)
 716:	9f31                	addw	a4,a4,a2
 718:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 71a:	ff053683          	ld	a3,-16(a0)
 71e:	a091                	j	762 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 720:	6398                	ld	a4,0(a5)
 722:	00e7e463          	bltu	a5,a4,72a <free+0x3a>
 726:	00e6ea63          	bltu	a3,a4,73a <free+0x4a>
{
 72a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72c:	fed7fae3          	bgeu	a5,a3,720 <free+0x30>
 730:	6398                	ld	a4,0(a5)
 732:	00e6e463          	bltu	a3,a4,73a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	fee7eae3          	bltu	a5,a4,72a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 73a:	ff852583          	lw	a1,-8(a0)
 73e:	6390                	ld	a2,0(a5)
 740:	02059813          	slli	a6,a1,0x20
 744:	01c85713          	srli	a4,a6,0x1c
 748:	9736                	add	a4,a4,a3
 74a:	fae60de3          	beq	a2,a4,704 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 74e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 752:	4790                	lw	a2,8(a5)
 754:	02061593          	slli	a1,a2,0x20
 758:	01c5d713          	srli	a4,a1,0x1c
 75c:	973e                	add	a4,a4,a5
 75e:	fae68ae3          	beq	a3,a4,712 <free+0x22>
    p->s.ptr = bp->s.ptr;
 762:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 764:	00001717          	auipc	a4,0x1
 768:	88f73e23          	sd	a5,-1892(a4) # 1000 <freep>
}
 76c:	6422                	ld	s0,8(sp)
 76e:	0141                	addi	sp,sp,16
 770:	8082                	ret

0000000000000772 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 772:	7139                	addi	sp,sp,-64
 774:	fc06                	sd	ra,56(sp)
 776:	f822                	sd	s0,48(sp)
 778:	f426                	sd	s1,40(sp)
 77a:	f04a                	sd	s2,32(sp)
 77c:	ec4e                	sd	s3,24(sp)
 77e:	e852                	sd	s4,16(sp)
 780:	e456                	sd	s5,8(sp)
 782:	e05a                	sd	s6,0(sp)
 784:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 786:	02051493          	slli	s1,a0,0x20
 78a:	9081                	srli	s1,s1,0x20
 78c:	04bd                	addi	s1,s1,15
 78e:	8091                	srli	s1,s1,0x4
 790:	0014899b          	addiw	s3,s1,1
 794:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 796:	00001517          	auipc	a0,0x1
 79a:	86a53503          	ld	a0,-1942(a0) # 1000 <freep>
 79e:	c515                	beqz	a0,7ca <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a2:	4798                	lw	a4,8(a5)
 7a4:	02977f63          	bgeu	a4,s1,7e2 <malloc+0x70>
  if(nu < 4096)
 7a8:	8a4e                	mv	s4,s3
 7aa:	0009871b          	sext.w	a4,s3
 7ae:	6685                	lui	a3,0x1
 7b0:	00d77363          	bgeu	a4,a3,7b6 <malloc+0x44>
 7b4:	6a05                	lui	s4,0x1
 7b6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ba:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7be:	00001917          	auipc	s2,0x1
 7c2:	84290913          	addi	s2,s2,-1982 # 1000 <freep>
  if(p == (char*)-1)
 7c6:	5afd                	li	s5,-1
 7c8:	a895                	j	83c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7ca:	00001797          	auipc	a5,0x1
 7ce:	84678793          	addi	a5,a5,-1978 # 1010 <base>
 7d2:	00001717          	auipc	a4,0x1
 7d6:	82f73723          	sd	a5,-2002(a4) # 1000 <freep>
 7da:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7dc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7e0:	b7e1                	j	7a8 <malloc+0x36>
      if(p->s.size == nunits)
 7e2:	02e48c63          	beq	s1,a4,81a <malloc+0xa8>
        p->s.size -= nunits;
 7e6:	4137073b          	subw	a4,a4,s3
 7ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ec:	02071693          	slli	a3,a4,0x20
 7f0:	01c6d713          	srli	a4,a3,0x1c
 7f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7fa:	00001717          	auipc	a4,0x1
 7fe:	80a73323          	sd	a0,-2042(a4) # 1000 <freep>
      return (void*)(p + 1);
 802:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 806:	70e2                	ld	ra,56(sp)
 808:	7442                	ld	s0,48(sp)
 80a:	74a2                	ld	s1,40(sp)
 80c:	7902                	ld	s2,32(sp)
 80e:	69e2                	ld	s3,24(sp)
 810:	6a42                	ld	s4,16(sp)
 812:	6aa2                	ld	s5,8(sp)
 814:	6b02                	ld	s6,0(sp)
 816:	6121                	addi	sp,sp,64
 818:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	e118                	sd	a4,0(a0)
 81e:	bff1                	j	7fa <malloc+0x88>
  hp->s.size = nu;
 820:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 824:	0541                	addi	a0,a0,16
 826:	00000097          	auipc	ra,0x0
 82a:	eca080e7          	jalr	-310(ra) # 6f0 <free>
  return freep;
 82e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 832:	d971                	beqz	a0,806 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 834:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 836:	4798                	lw	a4,8(a5)
 838:	fa9775e3          	bgeu	a4,s1,7e2 <malloc+0x70>
    if(p == freep)
 83c:	00093703          	ld	a4,0(s2)
 840:	853e                	mv	a0,a5
 842:	fef719e3          	bne	a4,a5,834 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 846:	8552                	mv	a0,s4
 848:	00000097          	auipc	ra,0x0
 84c:	b7a080e7          	jalr	-1158(ra) # 3c2 <sbrk>
  if(p == (char*)-1)
 850:	fd5518e3          	bne	a0,s5,820 <malloc+0xae>
        return 0;
 854:	4501                	li	a0,0
 856:	bf45                	j	806 <malloc+0x94>
