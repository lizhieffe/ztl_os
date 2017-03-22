9050 // init: The initial user-level program
9051 
9052 #include "types.h"
9053 #include "stat.h"
9054 #include "user.h"
9055 #include "fcntl.h"
9056 
9057 char *argv[] = { "sh", 0 };
9058 
9059 int
9060 main(void)
9061 {
9062   int pid, wpid;
9063 
9064   if(open("console", O_RDWR) < 0){
9065     mknod("console", 1, 1);
9066     open("console", O_RDWR);
9067   }
9068   dup(0);  // stdout
9069   dup(0);  // stderr
9070 
9071   for(;;){
9072     printf(1, "init: starting sh\n");
9073     pid = fork();
9074     if(pid < 0){
9075       printf(1, "init: fork failed\n");
9076       exit();
9077     }
9078     if(pid == 0){
9079       exec("sh", argv);
9080       printf(1, "init: exec sh failed\n");
9081       exit();
9082     }
9083     while((wpid=wait()) >= 0 && wpid != pid)
9084       printf(1, "zombie!\n");
9085   }
9086 }
9087 
9088 
9089 
9090 
9091 
9092 
9093 
9094 
9095 
9096 
9097 
9098 
9099 
