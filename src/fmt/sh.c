9100 // Shell.
9101 
9102 #include "types.h"
9103 #include "user.h"
9104 #include "fcntl.h"
9105 
9106 // Parsed command representation
9107 #define EXEC  1
9108 #define REDIR 2
9109 #define PIPE  3
9110 #define LIST  4
9111 #define BACK  5
9112 
9113 #define MAXARGS 10
9114 
9115 struct cmd {
9116   int type;
9117 };
9118 
9119 struct execcmd {
9120   int type;
9121   char *argv[MAXARGS];
9122   char *eargv[MAXARGS];
9123 };
9124 
9125 struct redircmd {
9126   int type;
9127   struct cmd *cmd;
9128   char *file;
9129   char *efile;
9130   int mode;
9131   int fd;
9132 };
9133 
9134 struct pipecmd {
9135   int type;
9136   struct cmd *left;
9137   struct cmd *right;
9138 };
9139 
9140 struct listcmd {
9141   int type;
9142   struct cmd *left;
9143   struct cmd *right;
9144 };
9145 
9146 struct backcmd {
9147   int type;
9148   struct cmd *cmd;
9149 };
9150 int fork1(void);  // Fork but panics on failure.
9151 void panic(char*);
9152 struct cmd *parsecmd(char*);
9153 
9154 // Execute cmd.  Never returns.
9155 void
9156 runcmd(struct cmd *cmd)
9157 {
9158   int p[2];
9159   struct backcmd *bcmd;
9160   struct execcmd *ecmd;
9161   struct listcmd *lcmd;
9162   struct pipecmd *pcmd;
9163   struct redircmd *rcmd;
9164 
9165   if(cmd == 0)
9166     exit();
9167 
9168   switch(cmd->type){
9169   default:
9170     panic("runcmd");
9171 
9172   case EXEC:
9173     ecmd = (struct execcmd*)cmd;
9174     if(ecmd->argv[0] == 0)
9175       exit();
9176     exec(ecmd->argv[0], ecmd->argv);
9177     printf(2, "exec %s failed\n", ecmd->argv[0]);
9178     break;
9179 
9180   case REDIR:
9181     rcmd = (struct redircmd*)cmd;
9182     close(rcmd->fd);
9183     if(open(rcmd->file, rcmd->mode) < 0){
9184       printf(2, "open %s failed\n", rcmd->file);
9185       exit();
9186     }
9187     runcmd(rcmd->cmd);
9188     break;
9189 
9190   case LIST:
9191     lcmd = (struct listcmd*)cmd;
9192     if(fork1() == 0)
9193       runcmd(lcmd->left);
9194     wait();
9195     runcmd(lcmd->right);
9196     break;
9197 
9198 
9199 
9200   case PIPE:
9201     pcmd = (struct pipecmd*)cmd;
9202     if(pipe(p) < 0)
9203       panic("pipe");
9204     if(fork1() == 0){
9205       close(1);
9206       dup(p[1]);
9207       close(p[0]);
9208       close(p[1]);
9209       runcmd(pcmd->left);
9210     }
9211     if(fork1() == 0){
9212       close(0);
9213       dup(p[0]);
9214       close(p[0]);
9215       close(p[1]);
9216       runcmd(pcmd->right);
9217     }
9218     close(p[0]);
9219     close(p[1]);
9220     wait();
9221     wait();
9222     break;
9223 
9224   case BACK:
9225     bcmd = (struct backcmd*)cmd;
9226     if(fork1() == 0)
9227       runcmd(bcmd->cmd);
9228     break;
9229   }
9230   exit();
9231 }
9232 
9233 int
9234 getcmd(char *buf, int nbuf)
9235 {
9236   printf(2, "$ ");
9237   memset(buf, 0, nbuf);
9238   gets(buf, nbuf);
9239   if(buf[0] == 0) // EOF
9240     return -1;
9241   return 0;
9242 }
9243 
9244 
9245 
9246 
9247 
9248 
9249 
9250 int
9251 main(void)
9252 {
9253   static char buf[100];
9254   int fd;
9255 
9256   // Ensure that three file descriptors are open.
9257   while((fd = open("console", O_RDWR)) >= 0){
9258     if(fd >= 3){
9259       close(fd);
9260       break;
9261     }
9262   }
9263 
9264   // Read and run input commands.
9265   while(getcmd(buf, sizeof(buf)) >= 0){
9266     if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
9267       // Chdir must be called by the parent, not the child.
9268       buf[strlen(buf)-1] = 0;  // chop \n
9269       if(chdir(buf+3) < 0)
9270         printf(2, "cannot cd %s\n", buf+3);
9271       continue;
9272     }
9273     if(fork1() == 0)
9274       runcmd(parsecmd(buf));
9275     wait();
9276   }
9277   exit();
9278 }
9279 
9280 void
9281 panic(char *s)
9282 {
9283   printf(2, "%s\n", s);
9284   exit();
9285 }
9286 
9287 int
9288 fork1(void)
9289 {
9290   int pid;
9291 
9292   pid = fork();
9293   if(pid == -1)
9294     panic("fork");
9295   return pid;
9296 }
9297 
9298 
9299 
9300 // Constructors
9301 
9302 struct cmd*
9303 execcmd(void)
9304 {
9305   struct execcmd *cmd;
9306 
9307   cmd = malloc(sizeof(*cmd));
9308   memset(cmd, 0, sizeof(*cmd));
9309   cmd->type = EXEC;
9310   return (struct cmd*)cmd;
9311 }
9312 
9313 struct cmd*
9314 redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
9315 {
9316   struct redircmd *cmd;
9317 
9318   cmd = malloc(sizeof(*cmd));
9319   memset(cmd, 0, sizeof(*cmd));
9320   cmd->type = REDIR;
9321   cmd->cmd = subcmd;
9322   cmd->file = file;
9323   cmd->efile = efile;
9324   cmd->mode = mode;
9325   cmd->fd = fd;
9326   return (struct cmd*)cmd;
9327 }
9328 
9329 struct cmd*
9330 pipecmd(struct cmd *left, struct cmd *right)
9331 {
9332   struct pipecmd *cmd;
9333 
9334   cmd = malloc(sizeof(*cmd));
9335   memset(cmd, 0, sizeof(*cmd));
9336   cmd->type = PIPE;
9337   cmd->left = left;
9338   cmd->right = right;
9339   return (struct cmd*)cmd;
9340 }
9341 
9342 
9343 
9344 
9345 
9346 
9347 
9348 
9349 
9350 struct cmd*
9351 listcmd(struct cmd *left, struct cmd *right)
9352 {
9353   struct listcmd *cmd;
9354 
9355   cmd = malloc(sizeof(*cmd));
9356   memset(cmd, 0, sizeof(*cmd));
9357   cmd->type = LIST;
9358   cmd->left = left;
9359   cmd->right = right;
9360   return (struct cmd*)cmd;
9361 }
9362 
9363 struct cmd*
9364 backcmd(struct cmd *subcmd)
9365 {
9366   struct backcmd *cmd;
9367 
9368   cmd = malloc(sizeof(*cmd));
9369   memset(cmd, 0, sizeof(*cmd));
9370   cmd->type = BACK;
9371   cmd->cmd = subcmd;
9372   return (struct cmd*)cmd;
9373 }
9374 
9375 
9376 
9377 
9378 
9379 
9380 
9381 
9382 
9383 
9384 
9385 
9386 
9387 
9388 
9389 
9390 
9391 
9392 
9393 
9394 
9395 
9396 
9397 
9398 
9399 
9400 // Parsing
9401 
9402 char whitespace[] = " \t\r\n\v";
9403 char symbols[] = "<|>&;()";
9404 
9405 int
9406 gettoken(char **ps, char *es, char **q, char **eq)
9407 {
9408   char *s;
9409   int ret;
9410 
9411   s = *ps;
9412   while(s < es && strchr(whitespace, *s))
9413     s++;
9414   if(q)
9415     *q = s;
9416   ret = *s;
9417   switch(*s){
9418   case 0:
9419     break;
9420   case '|':
9421   case '(':
9422   case ')':
9423   case ';':
9424   case '&':
9425   case '<':
9426     s++;
9427     break;
9428   case '>':
9429     s++;
9430     if(*s == '>'){
9431       ret = '+';
9432       s++;
9433     }
9434     break;
9435   default:
9436     ret = 'a';
9437     while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
9438       s++;
9439     break;
9440   }
9441   if(eq)
9442     *eq = s;
9443 
9444   while(s < es && strchr(whitespace, *s))
9445     s++;
9446   *ps = s;
9447   return ret;
9448 }
9449 
9450 int
9451 peek(char **ps, char *es, char *toks)
9452 {
9453   char *s;
9454 
9455   s = *ps;
9456   while(s < es && strchr(whitespace, *s))
9457     s++;
9458   *ps = s;
9459   return *s && strchr(toks, *s);
9460 }
9461 
9462 struct cmd *parseline(char**, char*);
9463 struct cmd *parsepipe(char**, char*);
9464 struct cmd *parseexec(char**, char*);
9465 struct cmd *nulterminate(struct cmd*);
9466 
9467 struct cmd*
9468 parsecmd(char *s)
9469 {
9470   char *es;
9471   struct cmd *cmd;
9472 
9473   es = s + strlen(s);
9474   cmd = parseline(&s, es);
9475   peek(&s, es, "");
9476   if(s != es){
9477     printf(2, "leftovers: %s\n", s);
9478     panic("syntax");
9479   }
9480   nulterminate(cmd);
9481   return cmd;
9482 }
9483 
9484 struct cmd*
9485 parseline(char **ps, char *es)
9486 {
9487   struct cmd *cmd;
9488 
9489   cmd = parsepipe(ps, es);
9490   while(peek(ps, es, "&")){
9491     gettoken(ps, es, 0, 0);
9492     cmd = backcmd(cmd);
9493   }
9494   if(peek(ps, es, ";")){
9495     gettoken(ps, es, 0, 0);
9496     cmd = listcmd(cmd, parseline(ps, es));
9497   }
9498   return cmd;
9499 }
9500 struct cmd*
9501 parsepipe(char **ps, char *es)
9502 {
9503   struct cmd *cmd;
9504 
9505   cmd = parseexec(ps, es);
9506   if(peek(ps, es, "|")){
9507     gettoken(ps, es, 0, 0);
9508     cmd = pipecmd(cmd, parsepipe(ps, es));
9509   }
9510   return cmd;
9511 }
9512 
9513 struct cmd*
9514 parseredirs(struct cmd *cmd, char **ps, char *es)
9515 {
9516   int tok;
9517   char *q, *eq;
9518 
9519   while(peek(ps, es, "<>")){
9520     tok = gettoken(ps, es, 0, 0);
9521     if(gettoken(ps, es, &q, &eq) != 'a')
9522       panic("missing file for redirection");
9523     switch(tok){
9524     case '<':
9525       cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
9526       break;
9527     case '>':
9528       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
9529       break;
9530     case '+':  // >>
9531       cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
9532       break;
9533     }
9534   }
9535   return cmd;
9536 }
9537 
9538 
9539 
9540 
9541 
9542 
9543 
9544 
9545 
9546 
9547 
9548 
9549 
9550 struct cmd*
9551 parseblock(char **ps, char *es)
9552 {
9553   struct cmd *cmd;
9554 
9555   if(!peek(ps, es, "("))
9556     panic("parseblock");
9557   gettoken(ps, es, 0, 0);
9558   cmd = parseline(ps, es);
9559   if(!peek(ps, es, ")"))
9560     panic("syntax - missing )");
9561   gettoken(ps, es, 0, 0);
9562   cmd = parseredirs(cmd, ps, es);
9563   return cmd;
9564 }
9565 
9566 struct cmd*
9567 parseexec(char **ps, char *es)
9568 {
9569   char *q, *eq;
9570   int tok, argc;
9571   struct execcmd *cmd;
9572   struct cmd *ret;
9573 
9574   if(peek(ps, es, "("))
9575     return parseblock(ps, es);
9576 
9577   ret = execcmd();
9578   cmd = (struct execcmd*)ret;
9579 
9580   argc = 0;
9581   ret = parseredirs(ret, ps, es);
9582   while(!peek(ps, es, "|)&;")){
9583     if((tok=gettoken(ps, es, &q, &eq)) == 0)
9584       break;
9585     if(tok != 'a')
9586       panic("syntax");
9587     cmd->argv[argc] = q;
9588     cmd->eargv[argc] = eq;
9589     argc++;
9590     if(argc >= MAXARGS)
9591       panic("too many args");
9592     ret = parseredirs(ret, ps, es);
9593   }
9594   cmd->argv[argc] = 0;
9595   cmd->eargv[argc] = 0;
9596   return ret;
9597 }
9598 
9599 
9600 // NUL-terminate all the counted strings.
9601 struct cmd*
9602 nulterminate(struct cmd *cmd)
9603 {
9604   int i;
9605   struct backcmd *bcmd;
9606   struct execcmd *ecmd;
9607   struct listcmd *lcmd;
9608   struct pipecmd *pcmd;
9609   struct redircmd *rcmd;
9610 
9611   if(cmd == 0)
9612     return 0;
9613 
9614   switch(cmd->type){
9615   case EXEC:
9616     ecmd = (struct execcmd*)cmd;
9617     for(i=0; ecmd->argv[i]; i++)
9618       *ecmd->eargv[i] = 0;
9619     break;
9620 
9621   case REDIR:
9622     rcmd = (struct redircmd*)cmd;
9623     nulterminate(rcmd->cmd);
9624     *rcmd->efile = 0;
9625     break;
9626 
9627   case PIPE:
9628     pcmd = (struct pipecmd*)cmd;
9629     nulterminate(pcmd->left);
9630     nulterminate(pcmd->right);
9631     break;
9632 
9633   case LIST:
9634     lcmd = (struct listcmd*)cmd;
9635     nulterminate(lcmd->left);
9636     nulterminate(lcmd->right);
9637     break;
9638 
9639   case BACK:
9640     bcmd = (struct backcmd*)cmd;
9641     nulterminate(bcmd->cmd);
9642     break;
9643   }
9644   return cmd;
9645 }
9646 
9647 
9648 
9649 
