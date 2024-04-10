
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
    }
    exit(0);
}

int getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
    write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	3be58593          	addi	a1,a1,958 # 13d0 <malloc+0xe6>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	eb6080e7          	jalr	-330(ra) # ed2 <write>
    memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c8e080e7          	jalr	-882(ra) # cb8 <memset>
    gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	cc8080e7          	jalr	-824(ra) # cfe <gets>
    if (buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
        return -1;
    return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
    }
    exit(0);
}

void panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
    fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	37858593          	addi	a1,a1,888 # 13d8 <malloc+0xee>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	19a080e7          	jalr	410(ra) # 1204 <fprintf>
    exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	e3e080e7          	jalr	-450(ra) # eb2 <exit>

000000000000007c <fork1>:
}

int fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
    int pid;

    pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	e26080e7          	jalr	-474(ra) # eaa <fork>
    if (pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
        panic("fork");
    return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
        panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	34650513          	addi	a0,a0,838 # 13e0 <malloc+0xf6>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
    if (cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
    switch (cmd->type)
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	42e70713          	addi	a4,a4,1070 # 14f4 <malloc+0x20a>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
        exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	dda080e7          	jalr	-550(ra) # eb2 <exit>
        panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	30850513          	addi	a0,a0,776 # 13e8 <malloc+0xfe>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
        if (ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
        exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	df2080e7          	jalr	-526(ra) # eea <exec>
        fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	2ee58593          	addi	a1,a1,750 # 13f0 <malloc+0x106>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	0f8080e7          	jalr	248(ra) # 1204 <fprintf>
    exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	d9c080e7          	jalr	-612(ra) # eb2 <exit>
            exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	d92080e7          	jalr	-622(ra) # eb2 <exit>
        close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	db0080e7          	jalr	-592(ra) # eda <close>
        if (open(rcmd->file, rcmd->mode) < 0)
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	dbc080e7          	jalr	-580(ra) # ef2 <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
        runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
            fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	2b258593          	addi	a1,a1,690 # 1400 <malloc+0x116>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	0ac080e7          	jalr	172(ra) # 1204 <fprintf>
            exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	d50080e7          	jalr	-688(ra) # eb2 <exit>
        if (fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
            runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
        wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	d3a080e7          	jalr	-710(ra) # eba <wait>
        runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f20080e7          	jalr	-224(ra) # aa <runcmd>
        if (pipe(p) < 0)
     192:	fd840513          	addi	a0,s0,-40
     196:	00001097          	auipc	ra,0x1
     19a:	d2c080e7          	jalr	-724(ra) # ec2 <pipe>
     19e:	04054363          	bltz	a0,1e4 <runcmd+0x13a>
        if (fork1() == 0)
     1a2:	00000097          	auipc	ra,0x0
     1a6:	eda080e7          	jalr	-294(ra) # 7c <fork1>
     1aa:	e529                	bnez	a0,1f4 <runcmd+0x14a>
            close(1);
     1ac:	4505                	li	a0,1
     1ae:	00001097          	auipc	ra,0x1
     1b2:	d2c080e7          	jalr	-724(ra) # eda <close>
            dup(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	00001097          	auipc	ra,0x1
     1be:	d70080e7          	jalr	-656(ra) # f2a <dup>
            close(p[0]);
     1c2:	fd842503          	lw	a0,-40(s0)
     1c6:	00001097          	auipc	ra,0x1
     1ca:	d14080e7          	jalr	-748(ra) # eda <close>
            close(p[1]);
     1ce:	fdc42503          	lw	a0,-36(s0)
     1d2:	00001097          	auipc	ra,0x1
     1d6:	d08080e7          	jalr	-760(ra) # eda <close>
            runcmd(pcmd->left);
     1da:	6488                	ld	a0,8(s1)
     1dc:	00000097          	auipc	ra,0x0
     1e0:	ece080e7          	jalr	-306(ra) # aa <runcmd>
            panic("pipe");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	22c50513          	addi	a0,a0,556 # 1410 <malloc+0x126>
     1ec:	00000097          	auipc	ra,0x0
     1f0:	e6a080e7          	jalr	-406(ra) # 56 <panic>
        if (fork1() == 0)
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e88080e7          	jalr	-376(ra) # 7c <fork1>
     1fc:	ed05                	bnez	a0,234 <runcmd+0x18a>
            close(0);
     1fe:	00001097          	auipc	ra,0x1
     202:	cdc080e7          	jalr	-804(ra) # eda <close>
            dup(p[0]);
     206:	fd842503          	lw	a0,-40(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	d20080e7          	jalr	-736(ra) # f2a <dup>
            close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	cc4080e7          	jalr	-828(ra) # eda <close>
            close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	cb8080e7          	jalr	-840(ra) # eda <close>
            runcmd(pcmd->right);
     22a:	6888                	ld	a0,16(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e7e080e7          	jalr	-386(ra) # aa <runcmd>
        close(p[0]);
     234:	fd842503          	lw	a0,-40(s0)
     238:	00001097          	auipc	ra,0x1
     23c:	ca2080e7          	jalr	-862(ra) # eda <close>
        close(p[1]);
     240:	fdc42503          	lw	a0,-36(s0)
     244:	00001097          	auipc	ra,0x1
     248:	c96080e7          	jalr	-874(ra) # eda <close>
        wait(0);
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	c6c080e7          	jalr	-916(ra) # eba <wait>
        wait(0);
     256:	4501                	li	a0,0
     258:	00001097          	auipc	ra,0x1
     25c:	c62080e7          	jalr	-926(ra) # eba <wait>
        break;
     260:	bd55                	j	114 <runcmd+0x6a>
        if (fork1() == 0)
     262:	00000097          	auipc	ra,0x0
     266:	e1a080e7          	jalr	-486(ra) # 7c <fork1>
     26a:	ea0515e3          	bnez	a0,114 <runcmd+0x6a>
            runcmd(bcmd->cmd);
     26e:	6488                	ld	a0,8(s1)
     270:	00000097          	auipc	ra,0x0
     274:	e3a080e7          	jalr	-454(ra) # aa <runcmd>

0000000000000278 <execcmd>:
// PAGEBREAK!
//  Constructors

struct cmd *
execcmd(void)
{
     278:	1101                	addi	sp,sp,-32
     27a:	ec06                	sd	ra,24(sp)
     27c:	e822                	sd	s0,16(sp)
     27e:	e426                	sd	s1,8(sp)
     280:	1000                	addi	s0,sp,32
    struct execcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     282:	0a800513          	li	a0,168
     286:	00001097          	auipc	ra,0x1
     28a:	064080e7          	jalr	100(ra) # 12ea <malloc>
     28e:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     290:	0a800613          	li	a2,168
     294:	4581                	li	a1,0
     296:	00001097          	auipc	ra,0x1
     29a:	a22080e7          	jalr	-1502(ra) # cb8 <memset>
    cmd->type = EXEC;
     29e:	4785                	li	a5,1
     2a0:	c09c                	sw	a5,0(s1)
    return (struct cmd *)cmd;
}
     2a2:	8526                	mv	a0,s1
     2a4:	60e2                	ld	ra,24(sp)
     2a6:	6442                	ld	s0,16(sp)
     2a8:	64a2                	ld	s1,8(sp)
     2aa:	6105                	addi	sp,sp,32
     2ac:	8082                	ret

00000000000002ae <redircmd>:

struct cmd *
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ae:	7139                	addi	sp,sp,-64
     2b0:	fc06                	sd	ra,56(sp)
     2b2:	f822                	sd	s0,48(sp)
     2b4:	f426                	sd	s1,40(sp)
     2b6:	f04a                	sd	s2,32(sp)
     2b8:	ec4e                	sd	s3,24(sp)
     2ba:	e852                	sd	s4,16(sp)
     2bc:	e456                	sd	s5,8(sp)
     2be:	e05a                	sd	s6,0(sp)
     2c0:	0080                	addi	s0,sp,64
     2c2:	8b2a                	mv	s6,a0
     2c4:	8aae                	mv	s5,a1
     2c6:	8a32                	mv	s4,a2
     2c8:	89b6                	mv	s3,a3
     2ca:	893a                	mv	s2,a4
    struct redircmd *cmd;

    cmd = malloc(sizeof(*cmd));
     2cc:	02800513          	li	a0,40
     2d0:	00001097          	auipc	ra,0x1
     2d4:	01a080e7          	jalr	26(ra) # 12ea <malloc>
     2d8:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     2da:	02800613          	li	a2,40
     2de:	4581                	li	a1,0
     2e0:	00001097          	auipc	ra,0x1
     2e4:	9d8080e7          	jalr	-1576(ra) # cb8 <memset>
    cmd->type = REDIR;
     2e8:	4789                	li	a5,2
     2ea:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     2ec:	0164b423          	sd	s6,8(s1)
    cmd->file = file;
     2f0:	0154b823          	sd	s5,16(s1)
    cmd->efile = efile;
     2f4:	0144bc23          	sd	s4,24(s1)
    cmd->mode = mode;
     2f8:	0334a023          	sw	s3,32(s1)
    cmd->fd = fd;
     2fc:	0324a223          	sw	s2,36(s1)
    return (struct cmd *)cmd;
}
     300:	8526                	mv	a0,s1
     302:	70e2                	ld	ra,56(sp)
     304:	7442                	ld	s0,48(sp)
     306:	74a2                	ld	s1,40(sp)
     308:	7902                	ld	s2,32(sp)
     30a:	69e2                	ld	s3,24(sp)
     30c:	6a42                	ld	s4,16(sp)
     30e:	6aa2                	ld	s5,8(sp)
     310:	6b02                	ld	s6,0(sp)
     312:	6121                	addi	sp,sp,64
     314:	8082                	ret

0000000000000316 <pipecmd>:

struct cmd *
pipecmd(struct cmd *left, struct cmd *right)
{
     316:	7179                	addi	sp,sp,-48
     318:	f406                	sd	ra,40(sp)
     31a:	f022                	sd	s0,32(sp)
     31c:	ec26                	sd	s1,24(sp)
     31e:	e84a                	sd	s2,16(sp)
     320:	e44e                	sd	s3,8(sp)
     322:	1800                	addi	s0,sp,48
     324:	89aa                	mv	s3,a0
     326:	892e                	mv	s2,a1
    struct pipecmd *cmd;

    cmd = malloc(sizeof(*cmd));
     328:	4561                	li	a0,24
     32a:	00001097          	auipc	ra,0x1
     32e:	fc0080e7          	jalr	-64(ra) # 12ea <malloc>
     332:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     334:	4661                	li	a2,24
     336:	4581                	li	a1,0
     338:	00001097          	auipc	ra,0x1
     33c:	980080e7          	jalr	-1664(ra) # cb8 <memset>
    cmd->type = PIPE;
     340:	478d                	li	a5,3
     342:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     344:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     348:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     34c:	8526                	mv	a0,s1
     34e:	70a2                	ld	ra,40(sp)
     350:	7402                	ld	s0,32(sp)
     352:	64e2                	ld	s1,24(sp)
     354:	6942                	ld	s2,16(sp)
     356:	69a2                	ld	s3,8(sp)
     358:	6145                	addi	sp,sp,48
     35a:	8082                	ret

000000000000035c <listcmd>:

struct cmd *
listcmd(struct cmd *left, struct cmd *right)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	1800                	addi	s0,sp,48
     36a:	89aa                	mv	s3,a0
     36c:	892e                	mv	s2,a1
    struct listcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     36e:	4561                	li	a0,24
     370:	00001097          	auipc	ra,0x1
     374:	f7a080e7          	jalr	-134(ra) # 12ea <malloc>
     378:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     37a:	4661                	li	a2,24
     37c:	4581                	li	a1,0
     37e:	00001097          	auipc	ra,0x1
     382:	93a080e7          	jalr	-1734(ra) # cb8 <memset>
    cmd->type = LIST;
     386:	4791                	li	a5,4
     388:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     38a:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     38e:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     392:	8526                	mv	a0,s1
     394:	70a2                	ld	ra,40(sp)
     396:	7402                	ld	s0,32(sp)
     398:	64e2                	ld	s1,24(sp)
     39a:	6942                	ld	s2,16(sp)
     39c:	69a2                	ld	s3,8(sp)
     39e:	6145                	addi	sp,sp,48
     3a0:	8082                	ret

00000000000003a2 <backcmd>:

struct cmd *
backcmd(struct cmd *subcmd)
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	e04a                	sd	s2,0(sp)
     3ac:	1000                	addi	s0,sp,32
     3ae:	892a                	mv	s2,a0
    struct backcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     3b0:	4541                	li	a0,16
     3b2:	00001097          	auipc	ra,0x1
     3b6:	f38080e7          	jalr	-200(ra) # 12ea <malloc>
     3ba:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     3bc:	4641                	li	a2,16
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	8f8080e7          	jalr	-1800(ra) # cb8 <memset>
    cmd->type = BACK;
     3c8:	4795                	li	a5,5
     3ca:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     3cc:	0124b423          	sd	s2,8(s1)
    return (struct cmd *)cmd;
}
     3d0:	8526                	mv	a0,s1
     3d2:	60e2                	ld	ra,24(sp)
     3d4:	6442                	ld	s0,16(sp)
     3d6:	64a2                	ld	s1,8(sp)
     3d8:	6902                	ld	s2,0(sp)
     3da:	6105                	addi	sp,sp,32
     3dc:	8082                	ret

00000000000003de <gettoken>:

char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int gettoken(char **ps, char *es, char **q, char **eq)
{
     3de:	7139                	addi	sp,sp,-64
     3e0:	fc06                	sd	ra,56(sp)
     3e2:	f822                	sd	s0,48(sp)
     3e4:	f426                	sd	s1,40(sp)
     3e6:	f04a                	sd	s2,32(sp)
     3e8:	ec4e                	sd	s3,24(sp)
     3ea:	e852                	sd	s4,16(sp)
     3ec:	e456                	sd	s5,8(sp)
     3ee:	e05a                	sd	s6,0(sp)
     3f0:	0080                	addi	s0,sp,64
     3f2:	8a2a                	mv	s4,a0
     3f4:	892e                	mv	s2,a1
     3f6:	8ab2                	mv	s5,a2
     3f8:	8b36                	mv	s6,a3
    char *s;
    int ret;

    s = *ps;
     3fa:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     3fc:	00002997          	auipc	s3,0x2
     400:	c0c98993          	addi	s3,s3,-1012 # 2008 <whitespace>
     404:	00b4fe63          	bgeu	s1,a1,420 <gettoken+0x42>
     408:	0004c583          	lbu	a1,0(s1)
     40c:	854e                	mv	a0,s3
     40e:	00001097          	auipc	ra,0x1
     412:	8cc080e7          	jalr	-1844(ra) # cda <strchr>
     416:	c509                	beqz	a0,420 <gettoken+0x42>
        s++;
     418:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     41a:	fe9917e3          	bne	s2,s1,408 <gettoken+0x2a>
        s++;
     41e:	84ca                	mv	s1,s2
    if (q)
     420:	000a8463          	beqz	s5,428 <gettoken+0x4a>
        *q = s;
     424:	009ab023          	sd	s1,0(s5)
    ret = *s;
     428:	0004c783          	lbu	a5,0(s1)
     42c:	00078a9b          	sext.w	s5,a5
    switch (*s)
     430:	03c00713          	li	a4,60
     434:	06f76663          	bltu	a4,a5,4a0 <gettoken+0xc2>
     438:	03a00713          	li	a4,58
     43c:	00f76e63          	bltu	a4,a5,458 <gettoken+0x7a>
     440:	cf89                	beqz	a5,45a <gettoken+0x7c>
     442:	02600713          	li	a4,38
     446:	00e78963          	beq	a5,a4,458 <gettoken+0x7a>
     44a:	fd87879b          	addiw	a5,a5,-40
     44e:	0ff7f793          	zext.b	a5,a5
     452:	4705                	li	a4,1
     454:	06f76d63          	bltu	a4,a5,4ce <gettoken+0xf0>
    case '(':
    case ')':
    case ';':
    case '&':
    case '<':
        s++;
     458:	0485                	addi	s1,s1,1
        ret = 'a';
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
            s++;
        break;
    }
    if (eq)
     45a:	000b0463          	beqz	s6,462 <gettoken+0x84>
        *eq = s;
     45e:	009b3023          	sd	s1,0(s6)

    while (s < es && strchr(whitespace, *s))
     462:	00002997          	auipc	s3,0x2
     466:	ba698993          	addi	s3,s3,-1114 # 2008 <whitespace>
     46a:	0124fe63          	bgeu	s1,s2,486 <gettoken+0xa8>
     46e:	0004c583          	lbu	a1,0(s1)
     472:	854e                	mv	a0,s3
     474:	00001097          	auipc	ra,0x1
     478:	866080e7          	jalr	-1946(ra) # cda <strchr>
     47c:	c509                	beqz	a0,486 <gettoken+0xa8>
        s++;
     47e:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     480:	fe9917e3          	bne	s2,s1,46e <gettoken+0x90>
        s++;
     484:	84ca                	mv	s1,s2
    *ps = s;
     486:	009a3023          	sd	s1,0(s4)
    return ret;
}
     48a:	8556                	mv	a0,s5
     48c:	70e2                	ld	ra,56(sp)
     48e:	7442                	ld	s0,48(sp)
     490:	74a2                	ld	s1,40(sp)
     492:	7902                	ld	s2,32(sp)
     494:	69e2                	ld	s3,24(sp)
     496:	6a42                	ld	s4,16(sp)
     498:	6aa2                	ld	s5,8(sp)
     49a:	6b02                	ld	s6,0(sp)
     49c:	6121                	addi	sp,sp,64
     49e:	8082                	ret
    switch (*s)
     4a0:	03e00713          	li	a4,62
     4a4:	02e79163          	bne	a5,a4,4c6 <gettoken+0xe8>
        s++;
     4a8:	00148693          	addi	a3,s1,1
        if (*s == '>')
     4ac:	0014c703          	lbu	a4,1(s1)
     4b0:	03e00793          	li	a5,62
            s++;
     4b4:	0489                	addi	s1,s1,2
            ret = '+';
     4b6:	02b00a93          	li	s5,43
        if (*s == '>')
     4ba:	faf700e3          	beq	a4,a5,45a <gettoken+0x7c>
        s++;
     4be:	84b6                	mv	s1,a3
    ret = *s;
     4c0:	03e00a93          	li	s5,62
     4c4:	bf59                	j	45a <gettoken+0x7c>
    switch (*s)
     4c6:	07c00713          	li	a4,124
     4ca:	f8e787e3          	beq	a5,a4,458 <gettoken+0x7a>
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4ce:	00002997          	auipc	s3,0x2
     4d2:	b3a98993          	addi	s3,s3,-1222 # 2008 <whitespace>
     4d6:	00002a97          	auipc	s5,0x2
     4da:	b2aa8a93          	addi	s5,s5,-1238 # 2000 <symbols>
     4de:	0524f163          	bgeu	s1,s2,520 <gettoken+0x142>
     4e2:	0004c583          	lbu	a1,0(s1)
     4e6:	854e                	mv	a0,s3
     4e8:	00000097          	auipc	ra,0x0
     4ec:	7f2080e7          	jalr	2034(ra) # cda <strchr>
     4f0:	e50d                	bnez	a0,51a <gettoken+0x13c>
     4f2:	0004c583          	lbu	a1,0(s1)
     4f6:	8556                	mv	a0,s5
     4f8:	00000097          	auipc	ra,0x0
     4fc:	7e2080e7          	jalr	2018(ra) # cda <strchr>
     500:	e911                	bnez	a0,514 <gettoken+0x136>
            s++;
     502:	0485                	addi	s1,s1,1
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     504:	fc991fe3          	bne	s2,s1,4e2 <gettoken+0x104>
            s++;
     508:	84ca                	mv	s1,s2
        ret = 'a';
     50a:	06100a93          	li	s5,97
    if (eq)
     50e:	f40b18e3          	bnez	s6,45e <gettoken+0x80>
     512:	bf95                	j	486 <gettoken+0xa8>
        ret = 'a';
     514:	06100a93          	li	s5,97
     518:	b789                	j	45a <gettoken+0x7c>
     51a:	06100a93          	li	s5,97
     51e:	bf35                	j	45a <gettoken+0x7c>
     520:	06100a93          	li	s5,97
    if (eq)
     524:	f20b1de3          	bnez	s6,45e <gettoken+0x80>
     528:	bfb9                	j	486 <gettoken+0xa8>

000000000000052a <peek>:

int peek(char **ps, char *es, char *toks)
{
     52a:	7139                	addi	sp,sp,-64
     52c:	fc06                	sd	ra,56(sp)
     52e:	f822                	sd	s0,48(sp)
     530:	f426                	sd	s1,40(sp)
     532:	f04a                	sd	s2,32(sp)
     534:	ec4e                	sd	s3,24(sp)
     536:	e852                	sd	s4,16(sp)
     538:	e456                	sd	s5,8(sp)
     53a:	0080                	addi	s0,sp,64
     53c:	8a2a                	mv	s4,a0
     53e:	892e                	mv	s2,a1
     540:	8ab2                	mv	s5,a2
    char *s;

    s = *ps;
     542:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     544:	00002997          	auipc	s3,0x2
     548:	ac498993          	addi	s3,s3,-1340 # 2008 <whitespace>
     54c:	00b4fe63          	bgeu	s1,a1,568 <peek+0x3e>
     550:	0004c583          	lbu	a1,0(s1)
     554:	854e                	mv	a0,s3
     556:	00000097          	auipc	ra,0x0
     55a:	784080e7          	jalr	1924(ra) # cda <strchr>
     55e:	c509                	beqz	a0,568 <peek+0x3e>
        s++;
     560:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     562:	fe9917e3          	bne	s2,s1,550 <peek+0x26>
        s++;
     566:	84ca                	mv	s1,s2
    *ps = s;
     568:	009a3023          	sd	s1,0(s4)
    return *s && strchr(toks, *s);
     56c:	0004c583          	lbu	a1,0(s1)
     570:	4501                	li	a0,0
     572:	e991                	bnez	a1,586 <peek+0x5c>
}
     574:	70e2                	ld	ra,56(sp)
     576:	7442                	ld	s0,48(sp)
     578:	74a2                	ld	s1,40(sp)
     57a:	7902                	ld	s2,32(sp)
     57c:	69e2                	ld	s3,24(sp)
     57e:	6a42                	ld	s4,16(sp)
     580:	6aa2                	ld	s5,8(sp)
     582:	6121                	addi	sp,sp,64
     584:	8082                	ret
    return *s && strchr(toks, *s);
     586:	8556                	mv	a0,s5
     588:	00000097          	auipc	ra,0x0
     58c:	752080e7          	jalr	1874(ra) # cda <strchr>
     590:	00a03533          	snez	a0,a0
     594:	b7c5                	j	574 <peek+0x4a>

0000000000000596 <parseredirs>:
    return cmd;
}

struct cmd *
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     596:	7159                	addi	sp,sp,-112
     598:	f486                	sd	ra,104(sp)
     59a:	f0a2                	sd	s0,96(sp)
     59c:	eca6                	sd	s1,88(sp)
     59e:	e8ca                	sd	s2,80(sp)
     5a0:	e4ce                	sd	s3,72(sp)
     5a2:	e0d2                	sd	s4,64(sp)
     5a4:	fc56                	sd	s5,56(sp)
     5a6:	f85a                	sd	s6,48(sp)
     5a8:	f45e                	sd	s7,40(sp)
     5aa:	f062                	sd	s8,32(sp)
     5ac:	ec66                	sd	s9,24(sp)
     5ae:	1880                	addi	s0,sp,112
     5b0:	8a2a                	mv	s4,a0
     5b2:	89ae                	mv	s3,a1
     5b4:	8932                	mv	s2,a2
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>"))
     5b6:	00001b97          	auipc	s7,0x1
     5ba:	e82b8b93          	addi	s7,s7,-382 # 1438 <malloc+0x14e>
    {
        tok = gettoken(ps, es, 0, 0);
        if (gettoken(ps, es, &q, &eq) != 'a')
     5be:	06100c13          	li	s8,97
            panic("missing file for redirection");
        switch (tok)
     5c2:	03c00c93          	li	s9,60
    while (peek(ps, es, "<>"))
     5c6:	a02d                	j	5f0 <parseredirs+0x5a>
            panic("missing file for redirection");
     5c8:	00001517          	auipc	a0,0x1
     5cc:	e5050513          	addi	a0,a0,-432 # 1418 <malloc+0x12e>
     5d0:	00000097          	auipc	ra,0x0
     5d4:	a86080e7          	jalr	-1402(ra) # 56 <panic>
        {
        case '<':
            cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5d8:	4701                	li	a4,0
     5da:	4681                	li	a3,0
     5dc:	f9043603          	ld	a2,-112(s0)
     5e0:	f9843583          	ld	a1,-104(s0)
     5e4:	8552                	mv	a0,s4
     5e6:	00000097          	auipc	ra,0x0
     5ea:	cc8080e7          	jalr	-824(ra) # 2ae <redircmd>
     5ee:	8a2a                	mv	s4,a0
        switch (tok)
     5f0:	03e00b13          	li	s6,62
     5f4:	02b00a93          	li	s5,43
    while (peek(ps, es, "<>"))
     5f8:	865e                	mv	a2,s7
     5fa:	85ca                	mv	a1,s2
     5fc:	854e                	mv	a0,s3
     5fe:	00000097          	auipc	ra,0x0
     602:	f2c080e7          	jalr	-212(ra) # 52a <peek>
     606:	c925                	beqz	a0,676 <parseredirs+0xe0>
        tok = gettoken(ps, es, 0, 0);
     608:	4681                	li	a3,0
     60a:	4601                	li	a2,0
     60c:	85ca                	mv	a1,s2
     60e:	854e                	mv	a0,s3
     610:	00000097          	auipc	ra,0x0
     614:	dce080e7          	jalr	-562(ra) # 3de <gettoken>
     618:	84aa                	mv	s1,a0
        if (gettoken(ps, es, &q, &eq) != 'a')
     61a:	f9040693          	addi	a3,s0,-112
     61e:	f9840613          	addi	a2,s0,-104
     622:	85ca                	mv	a1,s2
     624:	854e                	mv	a0,s3
     626:	00000097          	auipc	ra,0x0
     62a:	db8080e7          	jalr	-584(ra) # 3de <gettoken>
     62e:	f9851de3          	bne	a0,s8,5c8 <parseredirs+0x32>
        switch (tok)
     632:	fb9483e3          	beq	s1,s9,5d8 <parseredirs+0x42>
     636:	03648263          	beq	s1,s6,65a <parseredirs+0xc4>
     63a:	fb549fe3          	bne	s1,s5,5f8 <parseredirs+0x62>
            break;
        case '>':
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
            break;
        case '+': // >>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE, 1);
     63e:	4705                	li	a4,1
     640:	20100693          	li	a3,513
     644:	f9043603          	ld	a2,-112(s0)
     648:	f9843583          	ld	a1,-104(s0)
     64c:	8552                	mv	a0,s4
     64e:	00000097          	auipc	ra,0x0
     652:	c60080e7          	jalr	-928(ra) # 2ae <redircmd>
     656:	8a2a                	mv	s4,a0
            break;
     658:	bf61                	j	5f0 <parseredirs+0x5a>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
     65a:	4705                	li	a4,1
     65c:	60100693          	li	a3,1537
     660:	f9043603          	ld	a2,-112(s0)
     664:	f9843583          	ld	a1,-104(s0)
     668:	8552                	mv	a0,s4
     66a:	00000097          	auipc	ra,0x0
     66e:	c44080e7          	jalr	-956(ra) # 2ae <redircmd>
     672:	8a2a                	mv	s4,a0
            break;
     674:	bfb5                	j	5f0 <parseredirs+0x5a>
        }
    }
    return cmd;
}
     676:	8552                	mv	a0,s4
     678:	70a6                	ld	ra,104(sp)
     67a:	7406                	ld	s0,96(sp)
     67c:	64e6                	ld	s1,88(sp)
     67e:	6946                	ld	s2,80(sp)
     680:	69a6                	ld	s3,72(sp)
     682:	6a06                	ld	s4,64(sp)
     684:	7ae2                	ld	s5,56(sp)
     686:	7b42                	ld	s6,48(sp)
     688:	7ba2                	ld	s7,40(sp)
     68a:	7c02                	ld	s8,32(sp)
     68c:	6ce2                	ld	s9,24(sp)
     68e:	6165                	addi	sp,sp,112
     690:	8082                	ret

0000000000000692 <parseexec>:
    return cmd;
}

struct cmd *
parseexec(char **ps, char *es)
{
     692:	7159                	addi	sp,sp,-112
     694:	f486                	sd	ra,104(sp)
     696:	f0a2                	sd	s0,96(sp)
     698:	eca6                	sd	s1,88(sp)
     69a:	e8ca                	sd	s2,80(sp)
     69c:	e4ce                	sd	s3,72(sp)
     69e:	e0d2                	sd	s4,64(sp)
     6a0:	fc56                	sd	s5,56(sp)
     6a2:	f85a                	sd	s6,48(sp)
     6a4:	f45e                	sd	s7,40(sp)
     6a6:	f062                	sd	s8,32(sp)
     6a8:	ec66                	sd	s9,24(sp)
     6aa:	1880                	addi	s0,sp,112
     6ac:	8a2a                	mv	s4,a0
     6ae:	8aae                	mv	s5,a1
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;

    if (peek(ps, es, "("))
     6b0:	00001617          	auipc	a2,0x1
     6b4:	d9060613          	addi	a2,a2,-624 # 1440 <malloc+0x156>
     6b8:	00000097          	auipc	ra,0x0
     6bc:	e72080e7          	jalr	-398(ra) # 52a <peek>
     6c0:	e905                	bnez	a0,6f0 <parseexec+0x5e>
     6c2:	89aa                	mv	s3,a0
        return parseblock(ps, es);

    ret = execcmd();
     6c4:	00000097          	auipc	ra,0x0
     6c8:	bb4080e7          	jalr	-1100(ra) # 278 <execcmd>
     6cc:	8c2a                	mv	s8,a0
    cmd = (struct execcmd *)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
     6ce:	8656                	mv	a2,s5
     6d0:	85d2                	mv	a1,s4
     6d2:	00000097          	auipc	ra,0x0
     6d6:	ec4080e7          	jalr	-316(ra) # 596 <parseredirs>
     6da:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     6dc:	008c0913          	addi	s2,s8,8
     6e0:	00001b17          	auipc	s6,0x1
     6e4:	d80b0b13          	addi	s6,s6,-640 # 1460 <malloc+0x176>
    {
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a')
     6e8:	06100c93          	li	s9,97
            panic("syntax");
        cmd->argv[argc] = q;
        cmd->eargv[argc] = eq;
        argc++;
        if (argc >= MAXARGS)
     6ec:	4ba9                	li	s7,10
    while (!peek(ps, es, "|)&;"))
     6ee:	a0b1                	j	73a <parseexec+0xa8>
        return parseblock(ps, es);
     6f0:	85d6                	mv	a1,s5
     6f2:	8552                	mv	a0,s4
     6f4:	00000097          	auipc	ra,0x0
     6f8:	1bc080e7          	jalr	444(ra) # 8b0 <parseblock>
     6fc:	84aa                	mv	s1,a0
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    cmd->eargv[argc] = 0;
    return ret;
}
     6fe:	8526                	mv	a0,s1
     700:	70a6                	ld	ra,104(sp)
     702:	7406                	ld	s0,96(sp)
     704:	64e6                	ld	s1,88(sp)
     706:	6946                	ld	s2,80(sp)
     708:	69a6                	ld	s3,72(sp)
     70a:	6a06                	ld	s4,64(sp)
     70c:	7ae2                	ld	s5,56(sp)
     70e:	7b42                	ld	s6,48(sp)
     710:	7ba2                	ld	s7,40(sp)
     712:	7c02                	ld	s8,32(sp)
     714:	6ce2                	ld	s9,24(sp)
     716:	6165                	addi	sp,sp,112
     718:	8082                	ret
            panic("syntax");
     71a:	00001517          	auipc	a0,0x1
     71e:	d2e50513          	addi	a0,a0,-722 # 1448 <malloc+0x15e>
     722:	00000097          	auipc	ra,0x0
     726:	934080e7          	jalr	-1740(ra) # 56 <panic>
        ret = parseredirs(ret, ps, es);
     72a:	8656                	mv	a2,s5
     72c:	85d2                	mv	a1,s4
     72e:	8526                	mv	a0,s1
     730:	00000097          	auipc	ra,0x0
     734:	e66080e7          	jalr	-410(ra) # 596 <parseredirs>
     738:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     73a:	865a                	mv	a2,s6
     73c:	85d6                	mv	a1,s5
     73e:	8552                	mv	a0,s4
     740:	00000097          	auipc	ra,0x0
     744:	dea080e7          	jalr	-534(ra) # 52a <peek>
     748:	e131                	bnez	a0,78c <parseexec+0xfa>
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
     74a:	f9040693          	addi	a3,s0,-112
     74e:	f9840613          	addi	a2,s0,-104
     752:	85d6                	mv	a1,s5
     754:	8552                	mv	a0,s4
     756:	00000097          	auipc	ra,0x0
     75a:	c88080e7          	jalr	-888(ra) # 3de <gettoken>
     75e:	c51d                	beqz	a0,78c <parseexec+0xfa>
        if (tok != 'a')
     760:	fb951de3          	bne	a0,s9,71a <parseexec+0x88>
        cmd->argv[argc] = q;
     764:	f9843783          	ld	a5,-104(s0)
     768:	00f93023          	sd	a5,0(s2)
        cmd->eargv[argc] = eq;
     76c:	f9043783          	ld	a5,-112(s0)
     770:	04f93823          	sd	a5,80(s2)
        argc++;
     774:	2985                	addiw	s3,s3,1
        if (argc >= MAXARGS)
     776:	0921                	addi	s2,s2,8
     778:	fb7999e3          	bne	s3,s7,72a <parseexec+0x98>
            panic("too many args");
     77c:	00001517          	auipc	a0,0x1
     780:	cd450513          	addi	a0,a0,-812 # 1450 <malloc+0x166>
     784:	00000097          	auipc	ra,0x0
     788:	8d2080e7          	jalr	-1838(ra) # 56 <panic>
    cmd->argv[argc] = 0;
     78c:	098e                	slli	s3,s3,0x3
     78e:	9c4e                	add	s8,s8,s3
     790:	000c3423          	sd	zero,8(s8)
    cmd->eargv[argc] = 0;
     794:	040c3c23          	sd	zero,88(s8)
    return ret;
     798:	b79d                	j	6fe <parseexec+0x6c>

000000000000079a <parsepipe>:
{
     79a:	7179                	addi	sp,sp,-48
     79c:	f406                	sd	ra,40(sp)
     79e:	f022                	sd	s0,32(sp)
     7a0:	ec26                	sd	s1,24(sp)
     7a2:	e84a                	sd	s2,16(sp)
     7a4:	e44e                	sd	s3,8(sp)
     7a6:	1800                	addi	s0,sp,48
     7a8:	892a                	mv	s2,a0
     7aa:	89ae                	mv	s3,a1
    cmd = parseexec(ps, es);
     7ac:	00000097          	auipc	ra,0x0
     7b0:	ee6080e7          	jalr	-282(ra) # 692 <parseexec>
     7b4:	84aa                	mv	s1,a0
    if (peek(ps, es, "|"))
     7b6:	00001617          	auipc	a2,0x1
     7ba:	cb260613          	addi	a2,a2,-846 # 1468 <malloc+0x17e>
     7be:	85ce                	mv	a1,s3
     7c0:	854a                	mv	a0,s2
     7c2:	00000097          	auipc	ra,0x0
     7c6:	d68080e7          	jalr	-664(ra) # 52a <peek>
     7ca:	e909                	bnez	a0,7dc <parsepipe+0x42>
}
     7cc:	8526                	mv	a0,s1
     7ce:	70a2                	ld	ra,40(sp)
     7d0:	7402                	ld	s0,32(sp)
     7d2:	64e2                	ld	s1,24(sp)
     7d4:	6942                	ld	s2,16(sp)
     7d6:	69a2                	ld	s3,8(sp)
     7d8:	6145                	addi	sp,sp,48
     7da:	8082                	ret
        gettoken(ps, es, 0, 0);
     7dc:	4681                	li	a3,0
     7de:	4601                	li	a2,0
     7e0:	85ce                	mv	a1,s3
     7e2:	854a                	mv	a0,s2
     7e4:	00000097          	auipc	ra,0x0
     7e8:	bfa080e7          	jalr	-1030(ra) # 3de <gettoken>
        cmd = pipecmd(cmd, parsepipe(ps, es));
     7ec:	85ce                	mv	a1,s3
     7ee:	854a                	mv	a0,s2
     7f0:	00000097          	auipc	ra,0x0
     7f4:	faa080e7          	jalr	-86(ra) # 79a <parsepipe>
     7f8:	85aa                	mv	a1,a0
     7fa:	8526                	mv	a0,s1
     7fc:	00000097          	auipc	ra,0x0
     800:	b1a080e7          	jalr	-1254(ra) # 316 <pipecmd>
     804:	84aa                	mv	s1,a0
    return cmd;
     806:	b7d9                	j	7cc <parsepipe+0x32>

0000000000000808 <parseline>:
{
     808:	7179                	addi	sp,sp,-48
     80a:	f406                	sd	ra,40(sp)
     80c:	f022                	sd	s0,32(sp)
     80e:	ec26                	sd	s1,24(sp)
     810:	e84a                	sd	s2,16(sp)
     812:	e44e                	sd	s3,8(sp)
     814:	e052                	sd	s4,0(sp)
     816:	1800                	addi	s0,sp,48
     818:	892a                	mv	s2,a0
     81a:	89ae                	mv	s3,a1
    cmd = parsepipe(ps, es);
     81c:	00000097          	auipc	ra,0x0
     820:	f7e080e7          	jalr	-130(ra) # 79a <parsepipe>
     824:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     826:	00001a17          	auipc	s4,0x1
     82a:	c4aa0a13          	addi	s4,s4,-950 # 1470 <malloc+0x186>
     82e:	a839                	j	84c <parseline+0x44>
        gettoken(ps, es, 0, 0);
     830:	4681                	li	a3,0
     832:	4601                	li	a2,0
     834:	85ce                	mv	a1,s3
     836:	854a                	mv	a0,s2
     838:	00000097          	auipc	ra,0x0
     83c:	ba6080e7          	jalr	-1114(ra) # 3de <gettoken>
        cmd = backcmd(cmd);
     840:	8526                	mv	a0,s1
     842:	00000097          	auipc	ra,0x0
     846:	b60080e7          	jalr	-1184(ra) # 3a2 <backcmd>
     84a:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     84c:	8652                	mv	a2,s4
     84e:	85ce                	mv	a1,s3
     850:	854a                	mv	a0,s2
     852:	00000097          	auipc	ra,0x0
     856:	cd8080e7          	jalr	-808(ra) # 52a <peek>
     85a:	f979                	bnez	a0,830 <parseline+0x28>
    if (peek(ps, es, ";"))
     85c:	00001617          	auipc	a2,0x1
     860:	c1c60613          	addi	a2,a2,-996 # 1478 <malloc+0x18e>
     864:	85ce                	mv	a1,s3
     866:	854a                	mv	a0,s2
     868:	00000097          	auipc	ra,0x0
     86c:	cc2080e7          	jalr	-830(ra) # 52a <peek>
     870:	e911                	bnez	a0,884 <parseline+0x7c>
}
     872:	8526                	mv	a0,s1
     874:	70a2                	ld	ra,40(sp)
     876:	7402                	ld	s0,32(sp)
     878:	64e2                	ld	s1,24(sp)
     87a:	6942                	ld	s2,16(sp)
     87c:	69a2                	ld	s3,8(sp)
     87e:	6a02                	ld	s4,0(sp)
     880:	6145                	addi	sp,sp,48
     882:	8082                	ret
        gettoken(ps, es, 0, 0);
     884:	4681                	li	a3,0
     886:	4601                	li	a2,0
     888:	85ce                	mv	a1,s3
     88a:	854a                	mv	a0,s2
     88c:	00000097          	auipc	ra,0x0
     890:	b52080e7          	jalr	-1198(ra) # 3de <gettoken>
        cmd = listcmd(cmd, parseline(ps, es));
     894:	85ce                	mv	a1,s3
     896:	854a                	mv	a0,s2
     898:	00000097          	auipc	ra,0x0
     89c:	f70080e7          	jalr	-144(ra) # 808 <parseline>
     8a0:	85aa                	mv	a1,a0
     8a2:	8526                	mv	a0,s1
     8a4:	00000097          	auipc	ra,0x0
     8a8:	ab8080e7          	jalr	-1352(ra) # 35c <listcmd>
     8ac:	84aa                	mv	s1,a0
    return cmd;
     8ae:	b7d1                	j	872 <parseline+0x6a>

00000000000008b0 <parseblock>:
{
     8b0:	7179                	addi	sp,sp,-48
     8b2:	f406                	sd	ra,40(sp)
     8b4:	f022                	sd	s0,32(sp)
     8b6:	ec26                	sd	s1,24(sp)
     8b8:	e84a                	sd	s2,16(sp)
     8ba:	e44e                	sd	s3,8(sp)
     8bc:	1800                	addi	s0,sp,48
     8be:	84aa                	mv	s1,a0
     8c0:	892e                	mv	s2,a1
    if (!peek(ps, es, "("))
     8c2:	00001617          	auipc	a2,0x1
     8c6:	b7e60613          	addi	a2,a2,-1154 # 1440 <malloc+0x156>
     8ca:	00000097          	auipc	ra,0x0
     8ce:	c60080e7          	jalr	-928(ra) # 52a <peek>
     8d2:	c12d                	beqz	a0,934 <parseblock+0x84>
    gettoken(ps, es, 0, 0);
     8d4:	4681                	li	a3,0
     8d6:	4601                	li	a2,0
     8d8:	85ca                	mv	a1,s2
     8da:	8526                	mv	a0,s1
     8dc:	00000097          	auipc	ra,0x0
     8e0:	b02080e7          	jalr	-1278(ra) # 3de <gettoken>
    cmd = parseline(ps, es);
     8e4:	85ca                	mv	a1,s2
     8e6:	8526                	mv	a0,s1
     8e8:	00000097          	auipc	ra,0x0
     8ec:	f20080e7          	jalr	-224(ra) # 808 <parseline>
     8f0:	89aa                	mv	s3,a0
    if (!peek(ps, es, ")"))
     8f2:	00001617          	auipc	a2,0x1
     8f6:	b9e60613          	addi	a2,a2,-1122 # 1490 <malloc+0x1a6>
     8fa:	85ca                	mv	a1,s2
     8fc:	8526                	mv	a0,s1
     8fe:	00000097          	auipc	ra,0x0
     902:	c2c080e7          	jalr	-980(ra) # 52a <peek>
     906:	cd1d                	beqz	a0,944 <parseblock+0x94>
    gettoken(ps, es, 0, 0);
     908:	4681                	li	a3,0
     90a:	4601                	li	a2,0
     90c:	85ca                	mv	a1,s2
     90e:	8526                	mv	a0,s1
     910:	00000097          	auipc	ra,0x0
     914:	ace080e7          	jalr	-1330(ra) # 3de <gettoken>
    cmd = parseredirs(cmd, ps, es);
     918:	864a                	mv	a2,s2
     91a:	85a6                	mv	a1,s1
     91c:	854e                	mv	a0,s3
     91e:	00000097          	auipc	ra,0x0
     922:	c78080e7          	jalr	-904(ra) # 596 <parseredirs>
}
     926:	70a2                	ld	ra,40(sp)
     928:	7402                	ld	s0,32(sp)
     92a:	64e2                	ld	s1,24(sp)
     92c:	6942                	ld	s2,16(sp)
     92e:	69a2                	ld	s3,8(sp)
     930:	6145                	addi	sp,sp,48
     932:	8082                	ret
        panic("parseblock");
     934:	00001517          	auipc	a0,0x1
     938:	b4c50513          	addi	a0,a0,-1204 # 1480 <malloc+0x196>
     93c:	fffff097          	auipc	ra,0xfffff
     940:	71a080e7          	jalr	1818(ra) # 56 <panic>
        panic("syntax - missing )");
     944:	00001517          	auipc	a0,0x1
     948:	b5450513          	addi	a0,a0,-1196 # 1498 <malloc+0x1ae>
     94c:	fffff097          	auipc	ra,0xfffff
     950:	70a080e7          	jalr	1802(ra) # 56 <panic>

0000000000000954 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd *
nulterminate(struct cmd *cmd)
{
     954:	1101                	addi	sp,sp,-32
     956:	ec06                	sd	ra,24(sp)
     958:	e822                	sd	s0,16(sp)
     95a:	e426                	sd	s1,8(sp)
     95c:	1000                	addi	s0,sp,32
     95e:	84aa                	mv	s1,a0
    struct execcmd *ecmd;
    struct listcmd *lcmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;

    if (cmd == 0)
     960:	c521                	beqz	a0,9a8 <nulterminate+0x54>
        return 0;

    switch (cmd->type)
     962:	4118                	lw	a4,0(a0)
     964:	4795                	li	a5,5
     966:	04e7e163          	bltu	a5,a4,9a8 <nulterminate+0x54>
     96a:	00056783          	lwu	a5,0(a0)
     96e:	078a                	slli	a5,a5,0x2
     970:	00001717          	auipc	a4,0x1
     974:	b9c70713          	addi	a4,a4,-1124 # 150c <malloc+0x222>
     978:	97ba                	add	a5,a5,a4
     97a:	439c                	lw	a5,0(a5)
     97c:	97ba                	add	a5,a5,a4
     97e:	8782                	jr	a5
    {
    case EXEC:
        ecmd = (struct execcmd *)cmd;
        for (i = 0; ecmd->argv[i]; i++)
     980:	651c                	ld	a5,8(a0)
     982:	c39d                	beqz	a5,9a8 <nulterminate+0x54>
     984:	01050793          	addi	a5,a0,16
            *ecmd->eargv[i] = 0;
     988:	67b8                	ld	a4,72(a5)
     98a:	00070023          	sb	zero,0(a4)
        for (i = 0; ecmd->argv[i]; i++)
     98e:	07a1                	addi	a5,a5,8
     990:	ff87b703          	ld	a4,-8(a5)
     994:	fb75                	bnez	a4,988 <nulterminate+0x34>
     996:	a809                	j	9a8 <nulterminate+0x54>
        break;

    case REDIR:
        rcmd = (struct redircmd *)cmd;
        nulterminate(rcmd->cmd);
     998:	6508                	ld	a0,8(a0)
     99a:	00000097          	auipc	ra,0x0
     99e:	fba080e7          	jalr	-70(ra) # 954 <nulterminate>
        *rcmd->efile = 0;
     9a2:	6c9c                	ld	a5,24(s1)
     9a4:	00078023          	sb	zero,0(a5)
        bcmd = (struct backcmd *)cmd;
        nulterminate(bcmd->cmd);
        break;
    }
    return cmd;
}
     9a8:	8526                	mv	a0,s1
     9aa:	60e2                	ld	ra,24(sp)
     9ac:	6442                	ld	s0,16(sp)
     9ae:	64a2                	ld	s1,8(sp)
     9b0:	6105                	addi	sp,sp,32
     9b2:	8082                	ret
        nulterminate(pcmd->left);
     9b4:	6508                	ld	a0,8(a0)
     9b6:	00000097          	auipc	ra,0x0
     9ba:	f9e080e7          	jalr	-98(ra) # 954 <nulterminate>
        nulterminate(pcmd->right);
     9be:	6888                	ld	a0,16(s1)
     9c0:	00000097          	auipc	ra,0x0
     9c4:	f94080e7          	jalr	-108(ra) # 954 <nulterminate>
        break;
     9c8:	b7c5                	j	9a8 <nulterminate+0x54>
        nulterminate(lcmd->left);
     9ca:	6508                	ld	a0,8(a0)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f88080e7          	jalr	-120(ra) # 954 <nulterminate>
        nulterminate(lcmd->right);
     9d4:	6888                	ld	a0,16(s1)
     9d6:	00000097          	auipc	ra,0x0
     9da:	f7e080e7          	jalr	-130(ra) # 954 <nulterminate>
        break;
     9de:	b7e9                	j	9a8 <nulterminate+0x54>
        nulterminate(bcmd->cmd);
     9e0:	6508                	ld	a0,8(a0)
     9e2:	00000097          	auipc	ra,0x0
     9e6:	f72080e7          	jalr	-142(ra) # 954 <nulterminate>
        break;
     9ea:	bf7d                	j	9a8 <nulterminate+0x54>

00000000000009ec <parsecmd>:
{
     9ec:	7179                	addi	sp,sp,-48
     9ee:	f406                	sd	ra,40(sp)
     9f0:	f022                	sd	s0,32(sp)
     9f2:	ec26                	sd	s1,24(sp)
     9f4:	e84a                	sd	s2,16(sp)
     9f6:	1800                	addi	s0,sp,48
     9f8:	fca43c23          	sd	a0,-40(s0)
    es = s + strlen(s);
     9fc:	84aa                	mv	s1,a0
     9fe:	00000097          	auipc	ra,0x0
     a02:	290080e7          	jalr	656(ra) # c8e <strlen>
     a06:	1502                	slli	a0,a0,0x20
     a08:	9101                	srli	a0,a0,0x20
     a0a:	94aa                	add	s1,s1,a0
    cmd = parseline(&s, es);
     a0c:	85a6                	mv	a1,s1
     a0e:	fd840513          	addi	a0,s0,-40
     a12:	00000097          	auipc	ra,0x0
     a16:	df6080e7          	jalr	-522(ra) # 808 <parseline>
     a1a:	892a                	mv	s2,a0
    peek(&s, es, "");
     a1c:	00001617          	auipc	a2,0x1
     a20:	a9460613          	addi	a2,a2,-1388 # 14b0 <malloc+0x1c6>
     a24:	85a6                	mv	a1,s1
     a26:	fd840513          	addi	a0,s0,-40
     a2a:	00000097          	auipc	ra,0x0
     a2e:	b00080e7          	jalr	-1280(ra) # 52a <peek>
    if (s != es)
     a32:	fd843603          	ld	a2,-40(s0)
     a36:	00961e63          	bne	a2,s1,a52 <parsecmd+0x66>
    nulterminate(cmd);
     a3a:	854a                	mv	a0,s2
     a3c:	00000097          	auipc	ra,0x0
     a40:	f18080e7          	jalr	-232(ra) # 954 <nulterminate>
}
     a44:	854a                	mv	a0,s2
     a46:	70a2                	ld	ra,40(sp)
     a48:	7402                	ld	s0,32(sp)
     a4a:	64e2                	ld	s1,24(sp)
     a4c:	6942                	ld	s2,16(sp)
     a4e:	6145                	addi	sp,sp,48
     a50:	8082                	ret
        fprintf(2, "leftovers: %s\n", s);
     a52:	00001597          	auipc	a1,0x1
     a56:	a6658593          	addi	a1,a1,-1434 # 14b8 <malloc+0x1ce>
     a5a:	4509                	li	a0,2
     a5c:	00000097          	auipc	ra,0x0
     a60:	7a8080e7          	jalr	1960(ra) # 1204 <fprintf>
        panic("syntax");
     a64:	00001517          	auipc	a0,0x1
     a68:	9e450513          	addi	a0,a0,-1564 # 1448 <malloc+0x15e>
     a6c:	fffff097          	auipc	ra,0xfffff
     a70:	5ea080e7          	jalr	1514(ra) # 56 <panic>

0000000000000a74 <parse_buffer>:
{
     a74:	1101                	addi	sp,sp,-32
     a76:	ec06                	sd	ra,24(sp)
     a78:	e822                	sd	s0,16(sp)
     a7a:	e426                	sd	s1,8(sp)
     a7c:	1000                	addi	s0,sp,32
     a7e:	84aa                	mv	s1,a0
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     a80:	00054783          	lbu	a5,0(a0)
     a84:	06300713          	li	a4,99
     a88:	02e78b63          	beq	a5,a4,abe <parse_buffer+0x4a>
    if (buf[0] == 'e' &&
     a8c:	06500713          	li	a4,101
     a90:	00e79863          	bne	a5,a4,aa0 <parse_buffer+0x2c>
     a94:	00154703          	lbu	a4,1(a0)
     a98:	07800793          	li	a5,120
     a9c:	06f70b63          	beq	a4,a5,b12 <parse_buffer+0x9e>
    if (fork1() == 0)
     aa0:	fffff097          	auipc	ra,0xfffff
     aa4:	5dc080e7          	jalr	1500(ra) # 7c <fork1>
     aa8:	c551                	beqz	a0,b34 <parse_buffer+0xc0>
    wait(0);
     aaa:	4501                	li	a0,0
     aac:	00000097          	auipc	ra,0x0
     ab0:	40e080e7          	jalr	1038(ra) # eba <wait>
}
     ab4:	60e2                	ld	ra,24(sp)
     ab6:	6442                	ld	s0,16(sp)
     ab8:	64a2                	ld	s1,8(sp)
     aba:	6105                	addi	sp,sp,32
     abc:	8082                	ret
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     abe:	00154703          	lbu	a4,1(a0)
     ac2:	06400793          	li	a5,100
     ac6:	fcf71de3          	bne	a4,a5,aa0 <parse_buffer+0x2c>
     aca:	00254703          	lbu	a4,2(a0)
     ace:	02000793          	li	a5,32
     ad2:	fcf717e3          	bne	a4,a5,aa0 <parse_buffer+0x2c>
        buf[strlen(buf) - 1] = 0; // chop \n
     ad6:	00000097          	auipc	ra,0x0
     ada:	1b8080e7          	jalr	440(ra) # c8e <strlen>
     ade:	fff5079b          	addiw	a5,a0,-1
     ae2:	1782                	slli	a5,a5,0x20
     ae4:	9381                	srli	a5,a5,0x20
     ae6:	97a6                	add	a5,a5,s1
     ae8:	00078023          	sb	zero,0(a5)
        if (chdir(buf + 3) < 0)
     aec:	048d                	addi	s1,s1,3
     aee:	8526                	mv	a0,s1
     af0:	00000097          	auipc	ra,0x0
     af4:	432080e7          	jalr	1074(ra) # f22 <chdir>
     af8:	fa055ee3          	bgez	a0,ab4 <parse_buffer+0x40>
            fprintf(2, "cannot cd %s\n", buf + 3);
     afc:	8626                	mv	a2,s1
     afe:	00001597          	auipc	a1,0x1
     b02:	9ca58593          	addi	a1,a1,-1590 # 14c8 <malloc+0x1de>
     b06:	4509                	li	a0,2
     b08:	00000097          	auipc	ra,0x0
     b0c:	6fc080e7          	jalr	1788(ra) # 1204 <fprintf>
     b10:	b755                	j	ab4 <parse_buffer+0x40>
        buf[1] == 'x' &&
     b12:	00254703          	lbu	a4,2(a0)
     b16:	06900793          	li	a5,105
     b1a:	f8f713e3          	bne	a4,a5,aa0 <parse_buffer+0x2c>
        buf[2] == 'i' &&
     b1e:	00354703          	lbu	a4,3(a0)
     b22:	07400793          	li	a5,116
     b26:	f6f71de3          	bne	a4,a5,aa0 <parse_buffer+0x2c>
        exit(0);
     b2a:	4501                	li	a0,0
     b2c:	00000097          	auipc	ra,0x0
     b30:	386080e7          	jalr	902(ra) # eb2 <exit>
        runcmd(parsecmd(buf));
     b34:	8526                	mv	a0,s1
     b36:	00000097          	auipc	ra,0x0
     b3a:	eb6080e7          	jalr	-330(ra) # 9ec <parsecmd>
     b3e:	fffff097          	auipc	ra,0xfffff
     b42:	56c080e7          	jalr	1388(ra) # aa <runcmd>

0000000000000b46 <main>:
{
     b46:	7179                	addi	sp,sp,-48
     b48:	f406                	sd	ra,40(sp)
     b4a:	f022                	sd	s0,32(sp)
     b4c:	ec26                	sd	s1,24(sp)
     b4e:	e84a                	sd	s2,16(sp)
     b50:	e44e                	sd	s3,8(sp)
     b52:	1800                	addi	s0,sp,48
     b54:	892a                	mv	s2,a0
     b56:	89ae                	mv	s3,a1
    while ((fd = open("console", O_RDWR)) >= 0)
     b58:	00001497          	auipc	s1,0x1
     b5c:	98048493          	addi	s1,s1,-1664 # 14d8 <malloc+0x1ee>
     b60:	4589                	li	a1,2
     b62:	8526                	mv	a0,s1
     b64:	00000097          	auipc	ra,0x0
     b68:	38e080e7          	jalr	910(ra) # ef2 <open>
     b6c:	00054963          	bltz	a0,b7e <main+0x38>
        if (fd >= 3)
     b70:	4789                	li	a5,2
     b72:	fea7d7e3          	bge	a5,a0,b60 <main+0x1a>
            close(fd);
     b76:	00000097          	auipc	ra,0x0
     b7a:	364080e7          	jalr	868(ra) # eda <close>
    if (argc == 2)
     b7e:	4789                	li	a5,2
    while (getcmd(buf, sizeof(buf)) >= 0)
     b80:	00001497          	auipc	s1,0x1
     b84:	4a048493          	addi	s1,s1,1184 # 2020 <buf.0>
    if (argc == 2)
     b88:	08f91463          	bne	s2,a5,c10 <main+0xca>
        char *shell_script_file = argv[1];
     b8c:	0089b483          	ld	s1,8(s3)
        int shfd = open(shell_script_file, O_RDWR);
     b90:	4589                	li	a1,2
     b92:	8526                	mv	a0,s1
     b94:	00000097          	auipc	ra,0x0
     b98:	35e080e7          	jalr	862(ra) # ef2 <open>
     b9c:	892a                	mv	s2,a0
        if (shfd < 0)
     b9e:	04054663          	bltz	a0,bea <main+0xa4>
        read(shfd, buf, sizeof(buf));
     ba2:	07800613          	li	a2,120
     ba6:	00001597          	auipc	a1,0x1
     baa:	47a58593          	addi	a1,a1,1146 # 2020 <buf.0>
     bae:	00000097          	auipc	ra,0x0
     bb2:	31c080e7          	jalr	796(ra) # eca <read>
            parse_buffer(buf);
     bb6:	00001497          	auipc	s1,0x1
     bba:	46a48493          	addi	s1,s1,1130 # 2020 <buf.0>
     bbe:	8526                	mv	a0,s1
     bc0:	00000097          	auipc	ra,0x0
     bc4:	eb4080e7          	jalr	-332(ra) # a74 <parse_buffer>
        } while (read(shfd, buf, sizeof(buf)) == sizeof(buf));
     bc8:	07800613          	li	a2,120
     bcc:	85a6                	mv	a1,s1
     bce:	854a                	mv	a0,s2
     bd0:	00000097          	auipc	ra,0x0
     bd4:	2fa080e7          	jalr	762(ra) # eca <read>
     bd8:	07800793          	li	a5,120
     bdc:	fef501e3          	beq	a0,a5,bbe <main+0x78>
        exit(0);
     be0:	4501                	li	a0,0
     be2:	00000097          	auipc	ra,0x0
     be6:	2d0080e7          	jalr	720(ra) # eb2 <exit>
            printf("Failed to open %s\n", shell_script_file);
     bea:	85a6                	mv	a1,s1
     bec:	00001517          	auipc	a0,0x1
     bf0:	8f450513          	addi	a0,a0,-1804 # 14e0 <malloc+0x1f6>
     bf4:	00000097          	auipc	ra,0x0
     bf8:	63e080e7          	jalr	1598(ra) # 1232 <printf>
            exit(1);
     bfc:	4505                	li	a0,1
     bfe:	00000097          	auipc	ra,0x0
     c02:	2b4080e7          	jalr	692(ra) # eb2 <exit>
        parse_buffer(buf);
     c06:	8526                	mv	a0,s1
     c08:	00000097          	auipc	ra,0x0
     c0c:	e6c080e7          	jalr	-404(ra) # a74 <parse_buffer>
    while (getcmd(buf, sizeof(buf)) >= 0)
     c10:	07800593          	li	a1,120
     c14:	8526                	mv	a0,s1
     c16:	fffff097          	auipc	ra,0xfffff
     c1a:	3ea080e7          	jalr	1002(ra) # 0 <getcmd>
     c1e:	fe0554e3          	bgez	a0,c06 <main+0xc0>
    exit(0);
     c22:	4501                	li	a0,0
     c24:	00000097          	auipc	ra,0x0
     c28:	28e080e7          	jalr	654(ra) # eb2 <exit>

0000000000000c2c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c2c:	1141                	addi	sp,sp,-16
     c2e:	e406                	sd	ra,8(sp)
     c30:	e022                	sd	s0,0(sp)
     c32:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c34:	00000097          	auipc	ra,0x0
     c38:	f12080e7          	jalr	-238(ra) # b46 <main>
  exit(0);
     c3c:	4501                	li	a0,0
     c3e:	00000097          	auipc	ra,0x0
     c42:	274080e7          	jalr	628(ra) # eb2 <exit>

0000000000000c46 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c46:	1141                	addi	sp,sp,-16
     c48:	e422                	sd	s0,8(sp)
     c4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c4c:	87aa                	mv	a5,a0
     c4e:	0585                	addi	a1,a1,1
     c50:	0785                	addi	a5,a5,1
     c52:	fff5c703          	lbu	a4,-1(a1)
     c56:	fee78fa3          	sb	a4,-1(a5)
     c5a:	fb75                	bnez	a4,c4e <strcpy+0x8>
    ;
  return os;
}
     c5c:	6422                	ld	s0,8(sp)
     c5e:	0141                	addi	sp,sp,16
     c60:	8082                	ret

0000000000000c62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c62:	1141                	addi	sp,sp,-16
     c64:	e422                	sd	s0,8(sp)
     c66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	cb91                	beqz	a5,c80 <strcmp+0x1e>
     c6e:	0005c703          	lbu	a4,0(a1)
     c72:	00f71763          	bne	a4,a5,c80 <strcmp+0x1e>
    p++, q++;
     c76:	0505                	addi	a0,a0,1
     c78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c7a:	00054783          	lbu	a5,0(a0)
     c7e:	fbe5                	bnez	a5,c6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c80:	0005c503          	lbu	a0,0(a1)
}
     c84:	40a7853b          	subw	a0,a5,a0
     c88:	6422                	ld	s0,8(sp)
     c8a:	0141                	addi	sp,sp,16
     c8c:	8082                	ret

0000000000000c8e <strlen>:

uint
strlen(const char *s)
{
     c8e:	1141                	addi	sp,sp,-16
     c90:	e422                	sd	s0,8(sp)
     c92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c94:	00054783          	lbu	a5,0(a0)
     c98:	cf91                	beqz	a5,cb4 <strlen+0x26>
     c9a:	0505                	addi	a0,a0,1
     c9c:	87aa                	mv	a5,a0
     c9e:	86be                	mv	a3,a5
     ca0:	0785                	addi	a5,a5,1
     ca2:	fff7c703          	lbu	a4,-1(a5)
     ca6:	ff65                	bnez	a4,c9e <strlen+0x10>
     ca8:	40a6853b          	subw	a0,a3,a0
     cac:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     cae:	6422                	ld	s0,8(sp)
     cb0:	0141                	addi	sp,sp,16
     cb2:	8082                	ret
  for(n = 0; s[n]; n++)
     cb4:	4501                	li	a0,0
     cb6:	bfe5                	j	cae <strlen+0x20>

0000000000000cb8 <memset>:

void*
memset(void *dst, int c, uint n)
{
     cb8:	1141                	addi	sp,sp,-16
     cba:	e422                	sd	s0,8(sp)
     cbc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cbe:	ca19                	beqz	a2,cd4 <memset+0x1c>
     cc0:	87aa                	mv	a5,a0
     cc2:	1602                	slli	a2,a2,0x20
     cc4:	9201                	srli	a2,a2,0x20
     cc6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cce:	0785                	addi	a5,a5,1
     cd0:	fee79de3          	bne	a5,a4,cca <memset+0x12>
  }
  return dst;
}
     cd4:	6422                	ld	s0,8(sp)
     cd6:	0141                	addi	sp,sp,16
     cd8:	8082                	ret

0000000000000cda <strchr>:

char*
strchr(const char *s, char c)
{
     cda:	1141                	addi	sp,sp,-16
     cdc:	e422                	sd	s0,8(sp)
     cde:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ce0:	00054783          	lbu	a5,0(a0)
     ce4:	cb99                	beqz	a5,cfa <strchr+0x20>
    if(*s == c)
     ce6:	00f58763          	beq	a1,a5,cf4 <strchr+0x1a>
  for(; *s; s++)
     cea:	0505                	addi	a0,a0,1
     cec:	00054783          	lbu	a5,0(a0)
     cf0:	fbfd                	bnez	a5,ce6 <strchr+0xc>
      return (char*)s;
  return 0;
     cf2:	4501                	li	a0,0
}
     cf4:	6422                	ld	s0,8(sp)
     cf6:	0141                	addi	sp,sp,16
     cf8:	8082                	ret
  return 0;
     cfa:	4501                	li	a0,0
     cfc:	bfe5                	j	cf4 <strchr+0x1a>

0000000000000cfe <gets>:

char*
gets(char *buf, int max)
{
     cfe:	711d                	addi	sp,sp,-96
     d00:	ec86                	sd	ra,88(sp)
     d02:	e8a2                	sd	s0,80(sp)
     d04:	e4a6                	sd	s1,72(sp)
     d06:	e0ca                	sd	s2,64(sp)
     d08:	fc4e                	sd	s3,56(sp)
     d0a:	f852                	sd	s4,48(sp)
     d0c:	f456                	sd	s5,40(sp)
     d0e:	f05a                	sd	s6,32(sp)
     d10:	ec5e                	sd	s7,24(sp)
     d12:	1080                	addi	s0,sp,96
     d14:	8baa                	mv	s7,a0
     d16:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d18:	892a                	mv	s2,a0
     d1a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d1c:	4aa9                	li	s5,10
     d1e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d20:	89a6                	mv	s3,s1
     d22:	2485                	addiw	s1,s1,1
     d24:	0344d863          	bge	s1,s4,d54 <gets+0x56>
    cc = read(0, &c, 1);
     d28:	4605                	li	a2,1
     d2a:	faf40593          	addi	a1,s0,-81
     d2e:	4501                	li	a0,0
     d30:	00000097          	auipc	ra,0x0
     d34:	19a080e7          	jalr	410(ra) # eca <read>
    if(cc < 1)
     d38:	00a05e63          	blez	a0,d54 <gets+0x56>
    buf[i++] = c;
     d3c:	faf44783          	lbu	a5,-81(s0)
     d40:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d44:	01578763          	beq	a5,s5,d52 <gets+0x54>
     d48:	0905                	addi	s2,s2,1
     d4a:	fd679be3          	bne	a5,s6,d20 <gets+0x22>
  for(i=0; i+1 < max; ){
     d4e:	89a6                	mv	s3,s1
     d50:	a011                	j	d54 <gets+0x56>
     d52:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d54:	99de                	add	s3,s3,s7
     d56:	00098023          	sb	zero,0(s3)
  return buf;
}
     d5a:	855e                	mv	a0,s7
     d5c:	60e6                	ld	ra,88(sp)
     d5e:	6446                	ld	s0,80(sp)
     d60:	64a6                	ld	s1,72(sp)
     d62:	6906                	ld	s2,64(sp)
     d64:	79e2                	ld	s3,56(sp)
     d66:	7a42                	ld	s4,48(sp)
     d68:	7aa2                	ld	s5,40(sp)
     d6a:	7b02                	ld	s6,32(sp)
     d6c:	6be2                	ld	s7,24(sp)
     d6e:	6125                	addi	sp,sp,96
     d70:	8082                	ret

0000000000000d72 <stat>:

int
stat(const char *n, struct stat *st)
{
     d72:	1101                	addi	sp,sp,-32
     d74:	ec06                	sd	ra,24(sp)
     d76:	e822                	sd	s0,16(sp)
     d78:	e426                	sd	s1,8(sp)
     d7a:	e04a                	sd	s2,0(sp)
     d7c:	1000                	addi	s0,sp,32
     d7e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d80:	4581                	li	a1,0
     d82:	00000097          	auipc	ra,0x0
     d86:	170080e7          	jalr	368(ra) # ef2 <open>
  if(fd < 0)
     d8a:	02054563          	bltz	a0,db4 <stat+0x42>
     d8e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d90:	85ca                	mv	a1,s2
     d92:	00000097          	auipc	ra,0x0
     d96:	178080e7          	jalr	376(ra) # f0a <fstat>
     d9a:	892a                	mv	s2,a0
  close(fd);
     d9c:	8526                	mv	a0,s1
     d9e:	00000097          	auipc	ra,0x0
     da2:	13c080e7          	jalr	316(ra) # eda <close>
  return r;
}
     da6:	854a                	mv	a0,s2
     da8:	60e2                	ld	ra,24(sp)
     daa:	6442                	ld	s0,16(sp)
     dac:	64a2                	ld	s1,8(sp)
     dae:	6902                	ld	s2,0(sp)
     db0:	6105                	addi	sp,sp,32
     db2:	8082                	ret
    return -1;
     db4:	597d                	li	s2,-1
     db6:	bfc5                	j	da6 <stat+0x34>

0000000000000db8 <atoi>:

int
atoi(const char *s)
{
     db8:	1141                	addi	sp,sp,-16
     dba:	e422                	sd	s0,8(sp)
     dbc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dbe:	00054683          	lbu	a3,0(a0)
     dc2:	fd06879b          	addiw	a5,a3,-48
     dc6:	0ff7f793          	zext.b	a5,a5
     dca:	4625                	li	a2,9
     dcc:	02f66863          	bltu	a2,a5,dfc <atoi+0x44>
     dd0:	872a                	mv	a4,a0
  n = 0;
     dd2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     dd4:	0705                	addi	a4,a4,1
     dd6:	0025179b          	slliw	a5,a0,0x2
     dda:	9fa9                	addw	a5,a5,a0
     ddc:	0017979b          	slliw	a5,a5,0x1
     de0:	9fb5                	addw	a5,a5,a3
     de2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     de6:	00074683          	lbu	a3,0(a4)
     dea:	fd06879b          	addiw	a5,a3,-48
     dee:	0ff7f793          	zext.b	a5,a5
     df2:	fef671e3          	bgeu	a2,a5,dd4 <atoi+0x1c>
  return n;
}
     df6:	6422                	ld	s0,8(sp)
     df8:	0141                	addi	sp,sp,16
     dfa:	8082                	ret
  n = 0;
     dfc:	4501                	li	a0,0
     dfe:	bfe5                	j	df6 <atoi+0x3e>

0000000000000e00 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e00:	1141                	addi	sp,sp,-16
     e02:	e422                	sd	s0,8(sp)
     e04:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e06:	02b57463          	bgeu	a0,a1,e2e <memmove+0x2e>
    while(n-- > 0)
     e0a:	00c05f63          	blez	a2,e28 <memmove+0x28>
     e0e:	1602                	slli	a2,a2,0x20
     e10:	9201                	srli	a2,a2,0x20
     e12:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e16:	872a                	mv	a4,a0
      *dst++ = *src++;
     e18:	0585                	addi	a1,a1,1
     e1a:	0705                	addi	a4,a4,1
     e1c:	fff5c683          	lbu	a3,-1(a1)
     e20:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e24:	fee79ae3          	bne	a5,a4,e18 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e28:	6422                	ld	s0,8(sp)
     e2a:	0141                	addi	sp,sp,16
     e2c:	8082                	ret
    dst += n;
     e2e:	00c50733          	add	a4,a0,a2
    src += n;
     e32:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e34:	fec05ae3          	blez	a2,e28 <memmove+0x28>
     e38:	fff6079b          	addiw	a5,a2,-1
     e3c:	1782                	slli	a5,a5,0x20
     e3e:	9381                	srli	a5,a5,0x20
     e40:	fff7c793          	not	a5,a5
     e44:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e46:	15fd                	addi	a1,a1,-1
     e48:	177d                	addi	a4,a4,-1
     e4a:	0005c683          	lbu	a3,0(a1)
     e4e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e52:	fee79ae3          	bne	a5,a4,e46 <memmove+0x46>
     e56:	bfc9                	j	e28 <memmove+0x28>

0000000000000e58 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e58:	1141                	addi	sp,sp,-16
     e5a:	e422                	sd	s0,8(sp)
     e5c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e5e:	ca05                	beqz	a2,e8e <memcmp+0x36>
     e60:	fff6069b          	addiw	a3,a2,-1
     e64:	1682                	slli	a3,a3,0x20
     e66:	9281                	srli	a3,a3,0x20
     e68:	0685                	addi	a3,a3,1
     e6a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e6c:	00054783          	lbu	a5,0(a0)
     e70:	0005c703          	lbu	a4,0(a1)
     e74:	00e79863          	bne	a5,a4,e84 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e78:	0505                	addi	a0,a0,1
    p2++;
     e7a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e7c:	fed518e3          	bne	a0,a3,e6c <memcmp+0x14>
  }
  return 0;
     e80:	4501                	li	a0,0
     e82:	a019                	j	e88 <memcmp+0x30>
      return *p1 - *p2;
     e84:	40e7853b          	subw	a0,a5,a4
}
     e88:	6422                	ld	s0,8(sp)
     e8a:	0141                	addi	sp,sp,16
     e8c:	8082                	ret
  return 0;
     e8e:	4501                	li	a0,0
     e90:	bfe5                	j	e88 <memcmp+0x30>

0000000000000e92 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e92:	1141                	addi	sp,sp,-16
     e94:	e406                	sd	ra,8(sp)
     e96:	e022                	sd	s0,0(sp)
     e98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e9a:	00000097          	auipc	ra,0x0
     e9e:	f66080e7          	jalr	-154(ra) # e00 <memmove>
}
     ea2:	60a2                	ld	ra,8(sp)
     ea4:	6402                	ld	s0,0(sp)
     ea6:	0141                	addi	sp,sp,16
     ea8:	8082                	ret

0000000000000eaa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     eaa:	4885                	li	a7,1
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <exit>:
.global exit
exit:
 li a7, SYS_exit
     eb2:	4889                	li	a7,2
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <wait>:
.global wait
wait:
 li a7, SYS_wait
     eba:	488d                	li	a7,3
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ec2:	4891                	li	a7,4
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <read>:
.global read
read:
 li a7, SYS_read
     eca:	4895                	li	a7,5
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <write>:
.global write
write:
 li a7, SYS_write
     ed2:	48c1                	li	a7,16
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <close>:
.global close
close:
 li a7, SYS_close
     eda:	48d5                	li	a7,21
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ee2:	4899                	li	a7,6
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <exec>:
.global exec
exec:
 li a7, SYS_exec
     eea:	489d                	li	a7,7
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <open>:
.global open
open:
 li a7, SYS_open
     ef2:	48bd                	li	a7,15
 ecall
     ef4:	00000073          	ecall
 ret
     ef8:	8082                	ret

0000000000000efa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     efa:	48c5                	li	a7,17
 ecall
     efc:	00000073          	ecall
 ret
     f00:	8082                	ret

0000000000000f02 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f02:	48c9                	li	a7,18
 ecall
     f04:	00000073          	ecall
 ret
     f08:	8082                	ret

0000000000000f0a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f0a:	48a1                	li	a7,8
 ecall
     f0c:	00000073          	ecall
 ret
     f10:	8082                	ret

0000000000000f12 <link>:
.global link
link:
 li a7, SYS_link
     f12:	48cd                	li	a7,19
 ecall
     f14:	00000073          	ecall
 ret
     f18:	8082                	ret

0000000000000f1a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f1a:	48d1                	li	a7,20
 ecall
     f1c:	00000073          	ecall
 ret
     f20:	8082                	ret

0000000000000f22 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f22:	48a5                	li	a7,9
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <dup>:
.global dup
dup:
 li a7, SYS_dup
     f2a:	48a9                	li	a7,10
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f32:	48ad                	li	a7,11
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f3a:	48b1                	li	a7,12
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f42:	48b5                	li	a7,13
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f4a:	48b9                	li	a7,14
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <ps>:
.global ps
ps:
 li a7, SYS_ps
     f52:	48d9                	li	a7,22
 ecall
     f54:	00000073          	ecall
 ret
     f58:	8082                	ret

0000000000000f5a <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
     f5a:	48dd                	li	a7,23
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
     f62:	48e1                	li	a7,24
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f6a:	1101                	addi	sp,sp,-32
     f6c:	ec06                	sd	ra,24(sp)
     f6e:	e822                	sd	s0,16(sp)
     f70:	1000                	addi	s0,sp,32
     f72:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f76:	4605                	li	a2,1
     f78:	fef40593          	addi	a1,s0,-17
     f7c:	00000097          	auipc	ra,0x0
     f80:	f56080e7          	jalr	-170(ra) # ed2 <write>
}
     f84:	60e2                	ld	ra,24(sp)
     f86:	6442                	ld	s0,16(sp)
     f88:	6105                	addi	sp,sp,32
     f8a:	8082                	ret

0000000000000f8c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f8c:	7139                	addi	sp,sp,-64
     f8e:	fc06                	sd	ra,56(sp)
     f90:	f822                	sd	s0,48(sp)
     f92:	f426                	sd	s1,40(sp)
     f94:	f04a                	sd	s2,32(sp)
     f96:	ec4e                	sd	s3,24(sp)
     f98:	0080                	addi	s0,sp,64
     f9a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f9c:	c299                	beqz	a3,fa2 <printint+0x16>
     f9e:	0805c963          	bltz	a1,1030 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fa2:	2581                	sext.w	a1,a1
  neg = 0;
     fa4:	4881                	li	a7,0
     fa6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     faa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fac:	2601                	sext.w	a2,a2
     fae:	00000517          	auipc	a0,0x0
     fb2:	5da50513          	addi	a0,a0,1498 # 1588 <digits>
     fb6:	883a                	mv	a6,a4
     fb8:	2705                	addiw	a4,a4,1
     fba:	02c5f7bb          	remuw	a5,a1,a2
     fbe:	1782                	slli	a5,a5,0x20
     fc0:	9381                	srli	a5,a5,0x20
     fc2:	97aa                	add	a5,a5,a0
     fc4:	0007c783          	lbu	a5,0(a5)
     fc8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fcc:	0005879b          	sext.w	a5,a1
     fd0:	02c5d5bb          	divuw	a1,a1,a2
     fd4:	0685                	addi	a3,a3,1
     fd6:	fec7f0e3          	bgeu	a5,a2,fb6 <printint+0x2a>
  if(neg)
     fda:	00088c63          	beqz	a7,ff2 <printint+0x66>
    buf[i++] = '-';
     fde:	fd070793          	addi	a5,a4,-48
     fe2:	00878733          	add	a4,a5,s0
     fe6:	02d00793          	li	a5,45
     fea:	fef70823          	sb	a5,-16(a4)
     fee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff2:	02e05863          	blez	a4,1022 <printint+0x96>
     ff6:	fc040793          	addi	a5,s0,-64
     ffa:	00e78933          	add	s2,a5,a4
     ffe:	fff78993          	addi	s3,a5,-1
    1002:	99ba                	add	s3,s3,a4
    1004:	377d                	addiw	a4,a4,-1
    1006:	1702                	slli	a4,a4,0x20
    1008:	9301                	srli	a4,a4,0x20
    100a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    100e:	fff94583          	lbu	a1,-1(s2)
    1012:	8526                	mv	a0,s1
    1014:	00000097          	auipc	ra,0x0
    1018:	f56080e7          	jalr	-170(ra) # f6a <putc>
  while(--i >= 0)
    101c:	197d                	addi	s2,s2,-1
    101e:	ff3918e3          	bne	s2,s3,100e <printint+0x82>
}
    1022:	70e2                	ld	ra,56(sp)
    1024:	7442                	ld	s0,48(sp)
    1026:	74a2                	ld	s1,40(sp)
    1028:	7902                	ld	s2,32(sp)
    102a:	69e2                	ld	s3,24(sp)
    102c:	6121                	addi	sp,sp,64
    102e:	8082                	ret
    x = -xx;
    1030:	40b005bb          	negw	a1,a1
    neg = 1;
    1034:	4885                	li	a7,1
    x = -xx;
    1036:	bf85                	j	fa6 <printint+0x1a>

0000000000001038 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1038:	715d                	addi	sp,sp,-80
    103a:	e486                	sd	ra,72(sp)
    103c:	e0a2                	sd	s0,64(sp)
    103e:	fc26                	sd	s1,56(sp)
    1040:	f84a                	sd	s2,48(sp)
    1042:	f44e                	sd	s3,40(sp)
    1044:	f052                	sd	s4,32(sp)
    1046:	ec56                	sd	s5,24(sp)
    1048:	e85a                	sd	s6,16(sp)
    104a:	e45e                	sd	s7,8(sp)
    104c:	e062                	sd	s8,0(sp)
    104e:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1050:	0005c903          	lbu	s2,0(a1)
    1054:	18090c63          	beqz	s2,11ec <vprintf+0x1b4>
    1058:	8aaa                	mv	s5,a0
    105a:	8bb2                	mv	s7,a2
    105c:	00158493          	addi	s1,a1,1
  state = 0;
    1060:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1062:	02500a13          	li	s4,37
    1066:	4b55                	li	s6,21
    1068:	a839                	j	1086 <vprintf+0x4e>
        putc(fd, c);
    106a:	85ca                	mv	a1,s2
    106c:	8556                	mv	a0,s5
    106e:	00000097          	auipc	ra,0x0
    1072:	efc080e7          	jalr	-260(ra) # f6a <putc>
    1076:	a019                	j	107c <vprintf+0x44>
    } else if(state == '%'){
    1078:	01498d63          	beq	s3,s4,1092 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
    107c:	0485                	addi	s1,s1,1
    107e:	fff4c903          	lbu	s2,-1(s1)
    1082:	16090563          	beqz	s2,11ec <vprintf+0x1b4>
    if(state == 0){
    1086:	fe0999e3          	bnez	s3,1078 <vprintf+0x40>
      if(c == '%'){
    108a:	ff4910e3          	bne	s2,s4,106a <vprintf+0x32>
        state = '%';
    108e:	89d2                	mv	s3,s4
    1090:	b7f5                	j	107c <vprintf+0x44>
      if(c == 'd'){
    1092:	13490263          	beq	s2,s4,11b6 <vprintf+0x17e>
    1096:	f9d9079b          	addiw	a5,s2,-99
    109a:	0ff7f793          	zext.b	a5,a5
    109e:	12fb6563          	bltu	s6,a5,11c8 <vprintf+0x190>
    10a2:	f9d9079b          	addiw	a5,s2,-99
    10a6:	0ff7f713          	zext.b	a4,a5
    10aa:	10eb6f63          	bltu	s6,a4,11c8 <vprintf+0x190>
    10ae:	00271793          	slli	a5,a4,0x2
    10b2:	00000717          	auipc	a4,0x0
    10b6:	47e70713          	addi	a4,a4,1150 # 1530 <malloc+0x246>
    10ba:	97ba                	add	a5,a5,a4
    10bc:	439c                	lw	a5,0(a5)
    10be:	97ba                	add	a5,a5,a4
    10c0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    10c2:	008b8913          	addi	s2,s7,8
    10c6:	4685                	li	a3,1
    10c8:	4629                	li	a2,10
    10ca:	000ba583          	lw	a1,0(s7)
    10ce:	8556                	mv	a0,s5
    10d0:	00000097          	auipc	ra,0x0
    10d4:	ebc080e7          	jalr	-324(ra) # f8c <printint>
    10d8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    10da:	4981                	li	s3,0
    10dc:	b745                	j	107c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10de:	008b8913          	addi	s2,s7,8
    10e2:	4681                	li	a3,0
    10e4:	4629                	li	a2,10
    10e6:	000ba583          	lw	a1,0(s7)
    10ea:	8556                	mv	a0,s5
    10ec:	00000097          	auipc	ra,0x0
    10f0:	ea0080e7          	jalr	-352(ra) # f8c <printint>
    10f4:	8bca                	mv	s7,s2
      state = 0;
    10f6:	4981                	li	s3,0
    10f8:	b751                	j	107c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
    10fa:	008b8913          	addi	s2,s7,8
    10fe:	4681                	li	a3,0
    1100:	4641                	li	a2,16
    1102:	000ba583          	lw	a1,0(s7)
    1106:	8556                	mv	a0,s5
    1108:	00000097          	auipc	ra,0x0
    110c:	e84080e7          	jalr	-380(ra) # f8c <printint>
    1110:	8bca                	mv	s7,s2
      state = 0;
    1112:	4981                	li	s3,0
    1114:	b7a5                	j	107c <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
    1116:	008b8c13          	addi	s8,s7,8
    111a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    111e:	03000593          	li	a1,48
    1122:	8556                	mv	a0,s5
    1124:	00000097          	auipc	ra,0x0
    1128:	e46080e7          	jalr	-442(ra) # f6a <putc>
  putc(fd, 'x');
    112c:	07800593          	li	a1,120
    1130:	8556                	mv	a0,s5
    1132:	00000097          	auipc	ra,0x0
    1136:	e38080e7          	jalr	-456(ra) # f6a <putc>
    113a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    113c:	00000b97          	auipc	s7,0x0
    1140:	44cb8b93          	addi	s7,s7,1100 # 1588 <digits>
    1144:	03c9d793          	srli	a5,s3,0x3c
    1148:	97de                	add	a5,a5,s7
    114a:	0007c583          	lbu	a1,0(a5)
    114e:	8556                	mv	a0,s5
    1150:	00000097          	auipc	ra,0x0
    1154:	e1a080e7          	jalr	-486(ra) # f6a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1158:	0992                	slli	s3,s3,0x4
    115a:	397d                	addiw	s2,s2,-1
    115c:	fe0914e3          	bnez	s2,1144 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    1160:	8be2                	mv	s7,s8
      state = 0;
    1162:	4981                	li	s3,0
    1164:	bf21                	j	107c <vprintf+0x44>
        s = va_arg(ap, char*);
    1166:	008b8993          	addi	s3,s7,8
    116a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    116e:	02090163          	beqz	s2,1190 <vprintf+0x158>
        while(*s != 0){
    1172:	00094583          	lbu	a1,0(s2)
    1176:	c9a5                	beqz	a1,11e6 <vprintf+0x1ae>
          putc(fd, *s);
    1178:	8556                	mv	a0,s5
    117a:	00000097          	auipc	ra,0x0
    117e:	df0080e7          	jalr	-528(ra) # f6a <putc>
          s++;
    1182:	0905                	addi	s2,s2,1
        while(*s != 0){
    1184:	00094583          	lbu	a1,0(s2)
    1188:	f9e5                	bnez	a1,1178 <vprintf+0x140>
        s = va_arg(ap, char*);
    118a:	8bce                	mv	s7,s3
      state = 0;
    118c:	4981                	li	s3,0
    118e:	b5fd                	j	107c <vprintf+0x44>
          s = "(null)";
    1190:	00000917          	auipc	s2,0x0
    1194:	39890913          	addi	s2,s2,920 # 1528 <malloc+0x23e>
        while(*s != 0){
    1198:	02800593          	li	a1,40
    119c:	bff1                	j	1178 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
    119e:	008b8913          	addi	s2,s7,8
    11a2:	000bc583          	lbu	a1,0(s7)
    11a6:	8556                	mv	a0,s5
    11a8:	00000097          	auipc	ra,0x0
    11ac:	dc2080e7          	jalr	-574(ra) # f6a <putc>
    11b0:	8bca                	mv	s7,s2
      state = 0;
    11b2:	4981                	li	s3,0
    11b4:	b5e1                	j	107c <vprintf+0x44>
        putc(fd, c);
    11b6:	02500593          	li	a1,37
    11ba:	8556                	mv	a0,s5
    11bc:	00000097          	auipc	ra,0x0
    11c0:	dae080e7          	jalr	-594(ra) # f6a <putc>
      state = 0;
    11c4:	4981                	li	s3,0
    11c6:	bd5d                	j	107c <vprintf+0x44>
        putc(fd, '%');
    11c8:	02500593          	li	a1,37
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	d9c080e7          	jalr	-612(ra) # f6a <putc>
        putc(fd, c);
    11d6:	85ca                	mv	a1,s2
    11d8:	8556                	mv	a0,s5
    11da:	00000097          	auipc	ra,0x0
    11de:	d90080e7          	jalr	-624(ra) # f6a <putc>
      state = 0;
    11e2:	4981                	li	s3,0
    11e4:	bd61                	j	107c <vprintf+0x44>
        s = va_arg(ap, char*);
    11e6:	8bce                	mv	s7,s3
      state = 0;
    11e8:	4981                	li	s3,0
    11ea:	bd49                	j	107c <vprintf+0x44>
    }
  }
}
    11ec:	60a6                	ld	ra,72(sp)
    11ee:	6406                	ld	s0,64(sp)
    11f0:	74e2                	ld	s1,56(sp)
    11f2:	7942                	ld	s2,48(sp)
    11f4:	79a2                	ld	s3,40(sp)
    11f6:	7a02                	ld	s4,32(sp)
    11f8:	6ae2                	ld	s5,24(sp)
    11fa:	6b42                	ld	s6,16(sp)
    11fc:	6ba2                	ld	s7,8(sp)
    11fe:	6c02                	ld	s8,0(sp)
    1200:	6161                	addi	sp,sp,80
    1202:	8082                	ret

0000000000001204 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1204:	715d                	addi	sp,sp,-80
    1206:	ec06                	sd	ra,24(sp)
    1208:	e822                	sd	s0,16(sp)
    120a:	1000                	addi	s0,sp,32
    120c:	e010                	sd	a2,0(s0)
    120e:	e414                	sd	a3,8(s0)
    1210:	e818                	sd	a4,16(s0)
    1212:	ec1c                	sd	a5,24(s0)
    1214:	03043023          	sd	a6,32(s0)
    1218:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    121c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1220:	8622                	mv	a2,s0
    1222:	00000097          	auipc	ra,0x0
    1226:	e16080e7          	jalr	-490(ra) # 1038 <vprintf>
}
    122a:	60e2                	ld	ra,24(sp)
    122c:	6442                	ld	s0,16(sp)
    122e:	6161                	addi	sp,sp,80
    1230:	8082                	ret

0000000000001232 <printf>:

void
printf(const char *fmt, ...)
{
    1232:	711d                	addi	sp,sp,-96
    1234:	ec06                	sd	ra,24(sp)
    1236:	e822                	sd	s0,16(sp)
    1238:	1000                	addi	s0,sp,32
    123a:	e40c                	sd	a1,8(s0)
    123c:	e810                	sd	a2,16(s0)
    123e:	ec14                	sd	a3,24(s0)
    1240:	f018                	sd	a4,32(s0)
    1242:	f41c                	sd	a5,40(s0)
    1244:	03043823          	sd	a6,48(s0)
    1248:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    124c:	00840613          	addi	a2,s0,8
    1250:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1254:	85aa                	mv	a1,a0
    1256:	4505                	li	a0,1
    1258:	00000097          	auipc	ra,0x0
    125c:	de0080e7          	jalr	-544(ra) # 1038 <vprintf>
}
    1260:	60e2                	ld	ra,24(sp)
    1262:	6442                	ld	s0,16(sp)
    1264:	6125                	addi	sp,sp,96
    1266:	8082                	ret

0000000000001268 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1268:	1141                	addi	sp,sp,-16
    126a:	e422                	sd	s0,8(sp)
    126c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    126e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1272:	00001797          	auipc	a5,0x1
    1276:	d9e7b783          	ld	a5,-610(a5) # 2010 <freep>
    127a:	a02d                	j	12a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    127c:	4618                	lw	a4,8(a2)
    127e:	9f2d                	addw	a4,a4,a1
    1280:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1284:	6398                	ld	a4,0(a5)
    1286:	6310                	ld	a2,0(a4)
    1288:	a83d                	j	12c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    128a:	ff852703          	lw	a4,-8(a0)
    128e:	9f31                	addw	a4,a4,a2
    1290:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1292:	ff053683          	ld	a3,-16(a0)
    1296:	a091                	j	12da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1298:	6398                	ld	a4,0(a5)
    129a:	00e7e463          	bltu	a5,a4,12a2 <free+0x3a>
    129e:	00e6ea63          	bltu	a3,a4,12b2 <free+0x4a>
{
    12a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12a4:	fed7fae3          	bgeu	a5,a3,1298 <free+0x30>
    12a8:	6398                	ld	a4,0(a5)
    12aa:	00e6e463          	bltu	a3,a4,12b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ae:	fee7eae3          	bltu	a5,a4,12a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    12b2:	ff852583          	lw	a1,-8(a0)
    12b6:	6390                	ld	a2,0(a5)
    12b8:	02059813          	slli	a6,a1,0x20
    12bc:	01c85713          	srli	a4,a6,0x1c
    12c0:	9736                	add	a4,a4,a3
    12c2:	fae60de3          	beq	a2,a4,127c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    12c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12ca:	4790                	lw	a2,8(a5)
    12cc:	02061593          	slli	a1,a2,0x20
    12d0:	01c5d713          	srli	a4,a1,0x1c
    12d4:	973e                	add	a4,a4,a5
    12d6:	fae68ae3          	beq	a3,a4,128a <free+0x22>
    p->s.ptr = bp->s.ptr;
    12da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    12dc:	00001717          	auipc	a4,0x1
    12e0:	d2f73a23          	sd	a5,-716(a4) # 2010 <freep>
}
    12e4:	6422                	ld	s0,8(sp)
    12e6:	0141                	addi	sp,sp,16
    12e8:	8082                	ret

00000000000012ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12ea:	7139                	addi	sp,sp,-64
    12ec:	fc06                	sd	ra,56(sp)
    12ee:	f822                	sd	s0,48(sp)
    12f0:	f426                	sd	s1,40(sp)
    12f2:	f04a                	sd	s2,32(sp)
    12f4:	ec4e                	sd	s3,24(sp)
    12f6:	e852                	sd	s4,16(sp)
    12f8:	e456                	sd	s5,8(sp)
    12fa:	e05a                	sd	s6,0(sp)
    12fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12fe:	02051493          	slli	s1,a0,0x20
    1302:	9081                	srli	s1,s1,0x20
    1304:	04bd                	addi	s1,s1,15
    1306:	8091                	srli	s1,s1,0x4
    1308:	0014899b          	addiw	s3,s1,1
    130c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    130e:	00001517          	auipc	a0,0x1
    1312:	d0253503          	ld	a0,-766(a0) # 2010 <freep>
    1316:	c515                	beqz	a0,1342 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1318:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    131a:	4798                	lw	a4,8(a5)
    131c:	02977f63          	bgeu	a4,s1,135a <malloc+0x70>
  if(nu < 4096)
    1320:	8a4e                	mv	s4,s3
    1322:	0009871b          	sext.w	a4,s3
    1326:	6685                	lui	a3,0x1
    1328:	00d77363          	bgeu	a4,a3,132e <malloc+0x44>
    132c:	6a05                	lui	s4,0x1
    132e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1332:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1336:	00001917          	auipc	s2,0x1
    133a:	cda90913          	addi	s2,s2,-806 # 2010 <freep>
  if(p == (char*)-1)
    133e:	5afd                	li	s5,-1
    1340:	a895                	j	13b4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1342:	00001797          	auipc	a5,0x1
    1346:	d5678793          	addi	a5,a5,-682 # 2098 <base>
    134a:	00001717          	auipc	a4,0x1
    134e:	ccf73323          	sd	a5,-826(a4) # 2010 <freep>
    1352:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1354:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1358:	b7e1                	j	1320 <malloc+0x36>
      if(p->s.size == nunits)
    135a:	02e48c63          	beq	s1,a4,1392 <malloc+0xa8>
        p->s.size -= nunits;
    135e:	4137073b          	subw	a4,a4,s3
    1362:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1364:	02071693          	slli	a3,a4,0x20
    1368:	01c6d713          	srli	a4,a3,0x1c
    136c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    136e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1372:	00001717          	auipc	a4,0x1
    1376:	c8a73f23          	sd	a0,-866(a4) # 2010 <freep>
      return (void*)(p + 1);
    137a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    137e:	70e2                	ld	ra,56(sp)
    1380:	7442                	ld	s0,48(sp)
    1382:	74a2                	ld	s1,40(sp)
    1384:	7902                	ld	s2,32(sp)
    1386:	69e2                	ld	s3,24(sp)
    1388:	6a42                	ld	s4,16(sp)
    138a:	6aa2                	ld	s5,8(sp)
    138c:	6b02                	ld	s6,0(sp)
    138e:	6121                	addi	sp,sp,64
    1390:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1392:	6398                	ld	a4,0(a5)
    1394:	e118                	sd	a4,0(a0)
    1396:	bff1                	j	1372 <malloc+0x88>
  hp->s.size = nu;
    1398:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    139c:	0541                	addi	a0,a0,16
    139e:	00000097          	auipc	ra,0x0
    13a2:	eca080e7          	jalr	-310(ra) # 1268 <free>
  return freep;
    13a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13aa:	d971                	beqz	a0,137e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13ae:	4798                	lw	a4,8(a5)
    13b0:	fa9775e3          	bgeu	a4,s1,135a <malloc+0x70>
    if(p == freep)
    13b4:	00093703          	ld	a4,0(s2)
    13b8:	853e                	mv	a0,a5
    13ba:	fef719e3          	bne	a4,a5,13ac <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13be:	8552                	mv	a0,s4
    13c0:	00000097          	auipc	ra,0x0
    13c4:	b7a080e7          	jalr	-1158(ra) # f3a <sbrk>
  if(p == (char*)-1)
    13c8:	fd5518e3          	bne	a0,s5,1398 <malloc+0xae>
        return 0;
    13cc:	4501                	li	a0,0
    13ce:	bf45                	j	137e <malloc+0x94>
